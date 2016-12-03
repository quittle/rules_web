# Copyright (c) 2016 Dustin Doloff
# Licensed under Apache License v2.0

load("//:internal.bzl",
    "dict_to_struct_",
    "merge_structs_",
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

    source_file = ctx.file.src
    out_file = ctx.outputs.min_html_file

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
            "--output", out_file.path,
            source_file.path
        ],
        inputs = [
            ctx.executable._html_compressor,
            source_file,
        ],
        executable = ctx.executable._html_compressor,
        outputs = [ out_file ],
    )

    source_dict = struct_to_dict_(ctx.attr.src)

    # Replace the original mapping to the source file with a mapping to the minfied file
    # Basically, convert:
    # { Original: Generated } -> { Original: Minified, Generated: Minified }
    source_map = source_dict.get("source_map", {})
    for source, destination in source_map.items():
        if destination == source_file:
            source_map[source] = out_file

    # Sets are immutable so replace with a new set that does not contain the source file as it will
    # be replaced with the minified file
    source_dict["resources"] = set([ resource
            for resource in source_dict.get("resources", set([]))
                if resource != ctx.file.src ])

    ret = dict_to_struct_(source_dict)
    ret = merge_structs_(ret, struct(
        source_map = { source_file.short_path: out_file },
        resources = set([ out_file ]),
    ))

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
            source_map += dep.source_map
        if hasattr(dep, "resources"):
            resources.extend(list(dep.resources))
        if hasattr(dep, "css_resources"):
            css_files.extend(list(dep.css_resources))
        if hasattr(dep, "deferred_js_resources"):
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

    ctx.action(
        mnemonic = "GenerateHTMLPage",
        arguments = [
                "--template", ctx.file.template.path,
                "--config", ctx.file.config.path,
                "--body", ctx.file.body.path,
                "--output", ctx.outputs.html_file.path,
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

    source_map[ctx.outputs.html_file.short_path] = ctx.outputs.html_file

    ret = struct()

    for resource in resources + ctx.attr.css_files + ctx.attr.deferred_js_files + ctx.attr.js_files:
        ret = transitive_resources_(ret, resource)

    ret = merge_structs_(ret, struct(
        source_map = source_map,
        resources = set(
            resources +
            ctx.files.favicon_images +
            [ ctx.outputs.html_file ]
        ),
        css_resources = set(css_files),
        deferred_js_resources = set(deferred_js_files),
        js_resources = set(js_files),
    ))

    return ret
