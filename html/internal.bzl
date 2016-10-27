# Copyright (c) 2016 Dustin Doloff
# Licensed under Apache License v2.0

load("//:internal.bzl",
    "dict_to_struct_",
    "optional_arg_",
    "struct_to_dict_",
    "transitive_resources_",
)

def web_internal_minify_html_impl(ctx):
    whitespace_agnostic_tags = [
        "html",
        "head", "script", "style", "meta", "title",
        "body", "br", "p",
    ]

    ctx.action(
        mnemonic = "MinifyHTML",
        arguments = [
            "--remove-quotes",
            "--remove-style-attr",
            "--remove-script-attr",
            "--remove-form-attr",
            "--remove-input-attr",
            "--simple-bool-attr",
            "--remove-js-protocol",
            "--remove-http-protocol",
            "--remove-https-protocol",
            "--remove-surrounding-spaces", ",".join(whitespace_agnostic_tags),
            "--output", ctx.outputs.min_html_file.path,
            ctx.file.src.path
        ],
        inputs = [ ctx.executable._html_compressor, ctx.file.src ],
        executable = ctx.executable._html_compressor,
        outputs = [ ctx.outputs.min_html_file ],
    )

    source_map = {}
    source_map[ctx.file.src.short_path] = ctx.outputs.min_html_file

    ret = struct(
        source_map = dict_to_struct_(source_map),
        resources = set([ ctx.outputs.min_html_file ]),
    )

    ret = transitive_resources_(ret, ctx.attr.src)

    return ret

def web_internal_html_page_impl(ctx):
    if len(ctx.attr.favicon_sizes) != len(ctx.files.favicon_images):
        fail("Favicon sizes list length does not match favicon images list length")

    favicons = [ value
        for size, favicon in zip(ctx.attr.favicon_sizes, ctx.files.favicon_images)
            for value in (str(size), favicon.path)
    ]

    source_map = {}
    resources = []
    css_files = ctx.files.css_files
    deferred_js_files = ctx.files.deferred_js_files
    js_files = ctx.files.js_files
    for dep in ctx.attr.deps:
        if hasattr(dep, "source_map"):
            source_map += struct_to_dict_(dep.source_map)
        if hasattr(dep, "resources"):
            resources.extend(list(dep.resources))
        if hasattr(dep, "css_resources"):
            css_files.extend(list(dep.css_resources))
        if hasattr(dep, "deferred_js_files"):
            deferred_js_files.extend(list(dep.deferred_js_files))
        if hasattr(dep, "js_resources"):
            js_files.extend(list(dep.js_resources))
        for file in dep.files:
            if file.is_source:
                source_map[file.short_path] = file
                resources.append(file)

    resource_paths = [ resource.path for resource in resources ]
    css_paths = [ css_file.path for css_file in css_files ]
    deferred_js_paths = [ js_file.path for js_file in deferred_js_files ]
    js_paths = [ js_file.path for js_file in js_files ]

    path_map = {
        in_relative_path: out_file.path
            for in_relative_path, out_file in source_map.items()
    }

    path_object = {}
    for short_path, full_path in path_map.items():
        path_list = short_path.split("/")
        cur_obj = path_object
        for item in path_list[:-1]:
            if item not in cur_obj:
                cur_obj[item] = {}
            cur_obj = cur_obj[item]
        cur_obj[path_list[-1]] = full_path

    ctx.action(
        mnemonic = "GenerateHTMLPage",
        arguments = [
                "--template", ctx.file.template.path,
                "--config", ctx.file.config.path,
                "--body", ctx.file.body.path,
                "--output", ctx.outputs.html_file.path,
                "--resource-json-map", str(path_object),
            ] +
            optional_arg_("--favicons", favicons) +
            optional_arg_("--css-files", css_paths) +
            optional_arg_("--js-files", js_paths) +
            optional_arg_("--deferred-js-files", deferred_js_paths),
        inputs = [
                ctx.executable._html_template_script,
                ctx.file.template,
                ctx.file.config,
                ctx.file.body,
            ] +
            css_files +
            deferred_js_files +
            js_files +
            resources +
            ctx.files.favicon_images,
        executable = ctx.executable._html_template_script,
        outputs = [ ctx.outputs.html_file ],
    )

    ret = struct(
        source_map = dict_to_struct_(source_map),
        resources = set(
            resources +
            ctx.files.favicon_images +
            [ ctx.outputs.html_file ]
        ),
        css_resources = set(css_files),
        deferred_js_resources = set(deferred_js_files),
        js_resources = set(js_files),
    )

    for resource in resources + ctx.attr.css_files + ctx.attr.deferred_js_files + ctx.attr.js_files:
        ret = transitive_resources_(ret, resource)

    return ret
