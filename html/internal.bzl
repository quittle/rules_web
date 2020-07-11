# Copyright (c) 2016-2018 Dustin Toff
# Licensed under Apache License v2.0

load(
    "@bazel_toolbox//collections:collections.bzl",
    "dict_to_struct",
    "merge_structs",
    "struct_to_dict",
)
load(
    "//:internal.bzl",
    "optional_arg_",
    "transitive_resources_",
)

def web_internal_minify_html_impl(ctx):
    whitespace_agnostic_tags = [
        "html",
        "head",
        "script",
        "style",
        "meta",
        "title",
        "body",
        "br",
        "p",
    ]

    source_file = ctx.file.src
    out_file = ctx.outputs.min_html_file

    ctx.actions.run(
        mnemonic = "MinifyHTML",
        arguments = [
            "--remove-quotes",
            "--remove-style-attr",
            "--remove-script-attr",
            "--remove-form-attr",
            "--remove-input-attr",
            "--simple-bool-attr",
            "--remove-js-protocol",
            "--remove-surrounding-spaces",
            ",".join(whitespace_agnostic_tags),
            "--output",
            out_file.path,
            source_file.path,
        ],
        inputs = [source_file],
        tools = [ctx.executable._html_compressor],
        executable = ctx.executable._html_compressor,
        outputs = [out_file],
    )

    source_dict = struct_to_dict(ctx.attr.src)

    # Replace the original mapping to the source file with a mapping to the minfied file
    # Basically, convert:
    # { Original: Generated } -> { Original: Minified, Generated: Minified }
    source_map = source_dict.get("source_map", {})
    for source, destination in source_map.items():
        if destination == source_file:
            source_map[source] = out_file

    # Sets are immutable so replace with a new set that does not contain the source file as it will
    # be replaced with the minified file
    source_dict["resources"] = depset([
        resource
        for resource in source_dict.get("resources", depset([])).to_list()
        if resource != ctx.file.src
    ])

    ret = dict_to_struct(source_dict)
    ret = merge_structs(ret, struct(
        source_map = {source_file.short_path: out_file},
        resources = depset([out_file]),
    ))

    return ret

def _explode_deps(deps):
    ret = []
    for dep in deps:
        ret.append(dep)
        if hasattr(dep, "files"):
            ret.extend(dep.files.to_list())
    return ret

def web_internal_html_page_impl(ctx):
    if len(ctx.attr.favicon_sizes) != len(ctx.files.favicon_images):
        fail("Favicon sizes list length does not match favicon images list length")

    favicons = [
        value
        for size, favicon in zip(ctx.attr.favicon_sizes, ctx.files.favicon_images)
        for value in (str(size), "/" + favicon.path)
    ]

    source_map = {}
    resources = []
    css_files = list(ctx.files.css_files)
    deferred_js_files = list(ctx.files.deferred_js_files)
    js_files = list(ctx.files.js_files)
    inline_js_files = list(ctx.files.inline_js_files)
    for dep in _explode_deps(ctx.attr.deps):
        if hasattr(dep, "source_map"):
            source_map.update(**dep.source_map)
        if hasattr(dep, "resources"):
            resources.extend(dep.resources.to_list())
        if hasattr(dep, "css_resources"):
            css_files.extend(dep.css_resources.to_list())
        if hasattr(dep, "deferred_js_resources"):
            deferred_js_files.extend(dep.deferred_js_resources.to_list())
        if hasattr(dep, "js_resources"):
            js_files.extend(dep.js_resources.to_list())
        if type(dep) == "Target":
            for file in dep.files.to_list():
                if file.is_source:
                    source_map[file.short_path] = file
                    resources.append(file)

    resource_paths = ["/" + resource.path for resource in resources]
    css_paths = ["/" + css_file.path for css_file in css_files]
    deferred_js_paths = ["/" + js_file.path for js_file in deferred_js_files]
    js_paths = ["/" + js_file.path for js_file in js_files]
    inline_js_paths = [js_file.path for js_file in inline_js_files]

    ctx.actions.run(
        mnemonic = "GenerateHTMLPage",
        arguments = [
                        "--template",
                        ctx.file.template.path,
                        "--config",
                        ctx.file.config.path,
                        "--body",
                        ctx.file.body.path,
                        "--output",
                        ctx.outputs.html_file.path,
                    ] +
                    optional_arg_("--favicons", favicons) +
                    optional_arg_("--css-files", css_paths) +
                    optional_arg_("--deferred-js-files", deferred_js_paths) +
                    optional_arg_("--js-files", js_paths) +
                    optional_arg_("--inline-js-files", inline_js_paths),
        inputs = [
                     ctx.file.template,
                     ctx.file.config,
                     ctx.file.body,
                 ] +
                 css_files +
                 deferred_js_files +
                 js_files +
                 inline_js_files +
                 resources +
                 ctx.files.favicon_images,
        tools = [ctx.executable._html_template_script],
        executable = ctx.executable._html_template_script,
        outputs = [ctx.outputs.html_file],
    )

    source_map[ctx.outputs.html_file.short_path] = ctx.outputs.html_file

    ret = struct()

    all_resouces = (
        resources +
        ctx.attr.css_files +
        ctx.attr.deferred_js_files +
        ctx.attr.js_files +
        ctx.attr.inline_js_files
    )
    for resource in all_resouces:
        ret = transitive_resources_(ret, resource)

    ret = merge_structs(ret, struct(
        source_map = source_map,
        resources = depset(
            resources +
            ctx.files.favicon_images +
            [ctx.outputs.html_file],
        ),
        css_resources = depset(css_files),
        deferred_js_resources = depset(deferred_js_files),
        js_resources = depset(js_files),
    ))

    return ret

def web_internal_inject_html_impl(ctx):
    ctx.actions.run(
        mnemonic = "InjectHtmlSection",
        arguments = [
            "--outer-html",
            ctx.file.outer_html.path,
            "--inner-html",
            ctx.file.inner_html.path,
            "--query-selector",
            ctx.attr.query_selector,
            "--insertion-mode",
            ctx.attr.insertion_mode,
            "--output",
            ctx.outputs.html_file.path,
        ],
        inputs = [
            ctx.file.outer_html,
            ctx.file.inner_html,
        ],
        tools = [ctx.executable._inject_html_script],
        executable = ctx.executable._inject_html_script,
        outputs = [ctx.outputs.html_file],
    )

    ret = struct()
    for resource in [ctx.attr.outer_html, ctx.attr.inner_html]:
        ret = transitive_resources_(ret, resource)
    ret = merge_structs(ret, struct(
        resources = depset([ctx.outputs.html_file]),
    ))

    ret_dict = struct_to_dict(ret)
    resources_copy = ret_dict["resources"].to_list()
    if ctx.file.outer_html in resources_copy:
        resources_copy.remove(ctx.file.outer_html)
    if ctx.file.inner_html in resources_copy:
        resources_copy.remove(ctx.file.inner_html)
    ret_dict["resources"] = depset(resources_copy)
    ret = dict_to_struct(ret_dict)

    return ret

def web_internal_validate_html_impl(ctx):
    args = [ctx.outputs.stamp_file.path]
    inputs = [ctx.file.src]
    if ctx.attr.fail_on_warning:
        args.append("--Werror")
    if ctx.attr.filter_pattern:
        args.extend(["--filterpattern", ctx.attr.filter_pattern])
    if ctx.attr.filter_file:
        args.extend(["--filterfile", ctx.file.filter_file.path])
        inputs.append(ctx.file.filter_file)
    args.append(ctx.file.src.path)

    ctx.actions.run(
        mnemonic = "ValidateHtml",
        arguments = args,
        inputs = inputs,
        executable = ctx.executable._wrapped_w3c_validator,
        outputs = [ctx.outputs.stamp_file],
    )
