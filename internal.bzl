# Copyright (c) 2016 Dustin Doloff
# Licensed under Apache License v2.0

# Reverses a string
# string - str - The string to reverse
# str - Returns the string in reverse.
def _reverse(string):
    return string[::-1]

# Converts a struct to a dict
# structure - struct - The struct to convert
# dict - Returns a dict representation of the struct
def _struct_to_dict(structure):
    default_struct_methods = set(dir(struct()))
    ret = {}
    for key in dir(structure):
        if key not in default_struct_methods:
            ret[key] = getattr(structure, key)
    return ret

# Converts a dict to a struct
# dictionary - dict - The dict to convert
# struct - Returns a struct representation of the dict
def _dict_to_struct(dictionary):
    return struct(**dictionary)

# Merges the two structs and returns the new, merged struct
# struct_1 - struct - The first struct to merge
# struct_2 - struct - The second struct to merge
# struct - Returns a new struct containing all the entries from the inputs. The second struct's
#          entries override the first's.
def _merge_structs(struct_1, struct_2):
    return _dict_to_struct(_struct_to_dict(struct_1) + _struct_to_dict(struct_2))

# Helper function for adding optional flags to action inputs
# flag - str - The flag for the argument. E.g. "--arg-name"
# val - bool or list - A boolean to indicate if the flag should appear or not or a list, which if
#                      non-empty will result in a list with the flag followed by the contents.
# list - Returns a list that will either be empty, contain just the flag, or contain the flag and
#        the contents of val.
def _optional_arg(flag, val):
    val_type = type(val)

    if val_type == "bool" and val:
        return [ flag ]
    elif val_type == "list" and len(val) > 0:
        return [ flag ] + val
    else:
        return []

# Helper function for copying a file from one location to another
# ctx - ctx - The context to use
# file_copy_script - executable - The file_copy executable
# source_file - File - The file to copy
# destination_file - File - The file to copy it out to
def _copy(ctx, file_copy_script, source_file, destination_file):
    if (type(ctx) != "ctx"):
        fail("ctx was not a context")
    if (type(file_copy_script) != "File"):
        fail("file_copy_script was not a file")
    if (type(source_file) != "File"):
        fail("source_file was not a file")
    if (type(destination_file) != "File"):
        fail("destination_file was not a file")

    ctx.action(
        mnemonic = "CopyFile",
        arguments = [
            "--source", source_file.path,
            "--destination", destination_file.path,
        ],
        inputs = [ file_copy_script, source_file ],
        executable = file_copy_script,
        outputs = [ destination_file ],
    )

# Adds all the transitive dependencies of resource to orig_struct and returns the new struct
def _transitive_resources(orig_struct, resource):
    return struct(
        source_map = _merge_structs(getattr(orig_struct, "source_map", struct()),
                getattr(resource, "source_map", struct())),
        resources = getattr(orig_struct, "resources", set()) +
                getattr(resource, "resources", set()),
        css_resources = getattr(orig_struct, "css_resources", set()) +
                getattr(resource, "css_resources", set()),
        deferred_js_files = getattr(orig_struct, "deferred_js_files", set()) +
                getattr(resource, "deferred_js_files", set()),
        js_resources = getattr(orig_struct, "js_resources", set()) +
                getattr(resource, "js_resources", set()),
    )


# Helper function to define a label for a python script
# label - string - The label of the script
def web_internal_python_script_label(label):
    if (type(label) != "string"):
        fail("label was not a string")

    return attr.label(
        default = Label(label),
        executable = True,
        cfg = "host",
        allow_files = True,

        # single_file cannot be used while py_binary produces multiple
        # files, the binary of which is not selectable as a specific target
        # the way java_binary is
        #single_file = True,
    )

# Helper function to define a label for a tool
# label - string - The label of the tool
def web_internal_tool_label(label):
    if (type(label) != "string"):
        fail("label was not a string")

    return attr.label(
        default = Label(label),
        executable = True,
        cfg = "host",
        single_file = True,
        allow_files = True,
    )

def web_internal_minify_css_impl(ctx):
    source_paths = [ source.path for source in ctx.files.srcs ]

    ctx.action(
        mnemonic = "MinifyCSS",
        arguments = source_paths +
            [
                "--type", "css",
                "-o", ctx.outputs.min_css_file.path,
            ],
        inputs = [ ctx.executable._yui_binary ] + ctx.files.srcs,
        executable = ctx.executable._yui_binary,
        outputs = [ ctx.outputs.min_css_file ],
    )

    return struct(
        css_resources = set([ ctx.outputs.min_css_file ]),
    )

def web_internal_minify_js_impl(ctx):
    source_paths = [ source.path for source in ctx.files.srcs ]

    ctx.action(
        mnemonic = "MinifyJavascript",
        arguments = source_paths +
            [
                "--type", "js",
                "-o", ctx.outputs.min_js_file.path,
            ],
        inputs = [ ctx.executable._yui_binary ] + ctx.files.srcs,
        executable = ctx.executable._yui_binary,
        outputs = [ ctx.outputs.min_js_file ],
    )

    return struct(
        js_resources = set([ ctx.outputs.min_js_file ]),
    )

def web_internal_closure_compile_impl(ctx):
    source_paths = [ source.path for source in ctx.files.srcs ]
    extern_paths = [ extern.path for extern in ctx.files.externs ]

    ctx.action(
        mnemonic = "ClosureCompilingJavascript",
        arguments = source_paths +
            [
                "--js_output_file", ctx.outputs.compiled_js.path,
                "--compilation_level", ctx.attr.compilation_level,
                "--jscomp_error", "*",
                "--warning_level", ctx.attr.warning_level,
                "--language_in", "ECMASCRIPT6_STRICT",
                "--language_out", "ECMASCRIPT5",
            ] +
            _optional_arg("--externs", extern_paths) +
            ctx.attr.extra_args,
        inputs = ctx.files.srcs + ctx.files.externs,
        executable = ctx.executable._closure_compiler,
        outputs = [ ctx.outputs.compiled_js ],
    )

    return struct(
        js_resources = set(
            [ ctx.outputs.compiled_js ] +
            ctx.files.externs
        ),
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
        source_map = _dict_to_struct(source_map),
        resources = set([ ctx.outputs.min_html_file ]),
    )

    ret = _transitive_resources(ret, ctx.attr.src)

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
            source_map += _struct_to_dict(dep.source_map)
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
            _optional_arg("--favicons", favicons) +
            _optional_arg("--css-files", css_paths) +
            _optional_arg("--js-files", js_paths) +
            _optional_arg("--deferred-js-files", deferred_js_paths),
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
        source_map = _dict_to_struct(source_map),
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
        ret = _transitive_resources(ret, resource)

    return ret

def _minify_png(ctx, pngtastic, in_png, out_png, iterations):
    if (type(ctx) != "ctx"):
        fail("ctx was not a context")
    if (type(pngtastic) != "File"):
        fail("pngtastic was not a File")
    if (type(in_png) != "File"):
        fail("in_png was not a File")
    if (type(out_png) != "File"):
        fail("out_png was not a File")
    if (type(iterations) != "int"):
        fail("iterations was not a int")

    ctx.action(
        mnemonic = "MinifyPNG",
        arguments = [
            "--input", in_png.path,
            "--output", out_png.path,
            "--iterations", str(iterations),
        ],
        inputs = [ in_png ],
        executable = pngtastic,
        outputs = [ out_png ],
    )

def web_internal_minify_png(ctx):
    _minify_png(
        ctx,
        ctx.executable._pngtastic,
        ctx.file.png,
        ctx.outputs.min_png,
        ctx.attr.iterations,
    )

    source_map = {}
    source_map[ctx.file.png.short_path] = ctx.outputs.min_png

    return struct(
        source_map = struct(**source_map),
        resources = set([ ctx.outputs.min_png ]),
    )

def web_internal_generate_ico(ctx):
    ctx.action(
        mnemonic = "GenerateICO",
        arguments = [
                "--source", ctx.file.source.path,
                "--output", ctx.outputs.ico.path,
            ] +
            [ "--sizes" ] + [ str(size) for size in ctx.attr.sizes ] +
            _optional_arg("--allow-upsizing", ctx.attr.allow_upsizing),
        inputs = [ ctx.file.source ],
        executable = ctx.executable._generate_ico,
        outputs = [ ctx.outputs.ico ],
    )

    return struct(
        resources = set([ ctx.outputs.ico ]),
    )

def web_internal_favicon_image_generator(ctx):
    if len(ctx.attr.output_files) != len(ctx.attr.output_sizes):
        fail("Same number of output files as sizes expected")

    additional_args = (
        _optional_arg("--allow-upsizing", ctx.attr.allow_upsizing) +
        _optional_arg("--allow-stretching", ctx.attr.allow_stretching)
    )

    outputs = []

    for size, out_file in zip(ctx.attr.output_sizes, ctx.outputs.output_files):
        unoptimized_png = ctx.new_file(out_file.short_path + "-unoptimized.png")

        ctx.action(
            mnemonic = "GenerateFaviconSize",
            arguments = [
                    "--source", ctx.file.image.path,
                    "--width", str(size),
                    "--height", str(size),
                    "--output", unoptimized_png.path,
                ] +
                additional_args,
            inputs = [
                ctx.executable._resize_image,
                ctx.file.image,
            ],
            executable = ctx.executable._resize_image,
            outputs = [ unoptimized_png ],
        )

        _minify_png(
            ctx,
            ctx.executable._pngtastic,
            unoptimized_png,
            out_file,
            ctx.attr.png_optimize_iterations,
        )

        outputs.append(out_file)

    return struct(
        resources = set(outputs),
    )

def _generate_ttx(ctx, in_ttf, out_ttx, ttx_executable):
    if (type(ctx) != "ctx"):
        fail("ctx was not a context")
    if (type(in_ttf) != "File"):
        fail("in_ttf was not a File")
    if (type(out_ttx) != "File"):
        fail("out_ttx was not a File")
    if (type(ttx_executable) != "File"):
        fail("ttx_executable was not a File")

    ctx.action(
        mnemonic = "GenerateTTX",
        arguments = [
            "-o", out_ttx.path,
            in_ttf.path,
        ],
        inputs = [ in_ttf ],
        executable = ttx_executable,
        outputs = [ out_ttx ],
    )

def web_internal_minify_ttf(ctx):
    name = ctx.label.name
    ttx = ctx.new_file("{name}__generated_ttx.ttx".format(name = name))
    min_ttx = ctx.new_file("{name}__generated_min_ttx.ttx".format(name = name))

    _generate_ttx(ctx, ctx.file.ttf, ttx, ctx.executable._ttx)

    # BUG: There is a currently a bug where running ttx via `ctx.action` but not directly or even
    # via `bazel run @font_tools//:ttx` causes ttx to act strangely. For instance, a minimal action
    # that runs `ttx --version` will show 3.0 instead of 3.1.2. This is mostly fine, however.
    ctx.action(
        mnemonic = "MinifyTTX",
        arguments = [
            "--in-ttx", ttx.path,
            "--out-ttx", min_ttx.path,
        ],
        inputs = [ ttx ],
        executable = ctx.executable._minify_ttx,
        outputs = [ min_ttx ],
    )

    ctx.action(
        mnemonic = "GenerateMinimalTTX",
        arguments = [
            "-o", ctx.outputs.out_ttf.path,
            min_ttx.path,
        ],
        inputs = [ min_ttx ],
        executable = ctx.executable._ttx,
        outputs = [ ctx.outputs.out_ttf ],
    )

    return struct(
        resources = set([ ctx.outputs.out_ttf ]),
    )

def web_internal_ttf_to_woff(ctx):
    name = ctx.label.name
    ttx = ctx.new_file("{name}__generated_ttx.ttx".format(name = name))

    _generate_ttx(ctx, ctx.file.ttf, ttx, ctx.executable._ttx)

    ctx.action(
        mnemonic = "GenerateWOFF",
        arguments = [
            "-o", ctx.outputs.out_woff.path,
            "--flavor", "woff",
            ttx.path,
        ],
        inputs = [ ttx ],
        executable = ctx.executable._ttx,
        outputs = [ ctx.outputs.out_woff ],
    )

    return struct(
        resources = set([ ctx.outputs.out_woff ]),
    )

def web_internal_ttf_to_woff2(ctx):
    # The tool unfortunately does not take the output path as an argument and simply creates a new
    # file next to the old one with a new extension
    copied_source = ctx.new_file(ctx.outputs.out_woff2.basename.replace(".woff2", ".ttf"))

    _copy(ctx, ctx.executable._file_copy, ctx.file.ttf, copied_source)

    ctx.action(
        mnemonic = "GenerateWOFF2",
        arguments = [
            copied_source.path,
        ],
        inputs = [ copied_source ],
        executable = ctx.executable._ttf2woff2,
        outputs = [ ctx.outputs.out_woff2 ],
    )

    return struct(
        resources = set([ ctx.outputs.out_woff2 ]),
    )

def web_internal_ttf_to_eot(ctx):
    ctx.action(
        mnemonic = "GenerateEOT",
        arguments = [
            ctx.file.ttf.path,
            ctx.outputs.out_eot.path,
        ],
        inputs = [ ctx.file.ttf ],
        executable = ctx.executable._ttf2eot,
        outputs = [ ctx.outputs.out_eot ],
    )

    return struct(
        resources = set([ ctx.outputs.out_eot ]),
    )

def web_internal_font_generator(ctx):
    # CSS src line for ie support
    single_source = ""
    # CSS  src line with multiple fonts for non-ie support. Contains tupples of (url, type)
    multi_source = []
    if ctx.file.eot != None:
        eot = ctx.file.eot.path
        single_source = "src: url('{eot}');".format(eot = eot)
        multi_source.append(("{eot}?#iefix".format(eot = eot), "embedded-opentype"))
    if ctx.file.ttf != None:
        ttf = ctx.file.ttf.path
        multi_source.append((ttf, "truetype"))
    if ctx.file.woff != None:
        woff = ctx.file.woff.path
        multi_source.append((woff, "woff"))
    if ctx.file.woff2 != None:
        woff2 = ctx.file.woff2.path
        multi_source.append((woff2, "woff2"))
    if ctx.file.svg != None:
        svg = ctx.file.svg.path
        multi_source.append((
                "{svg}#{name}-{weight}-{style}".format( # Must be unique per variant
                        svg = svg,
                        name = ctx.attr.name,
                        weight = ctx.attr.weight,
                        style = ctx.attr.style),
                "svg"))

    multi_source = [
            "url('{path}') format('{type}')".format(path=path,type=type)
                    for (path, type) in multi_source ]
    if len(multi_source) > 0:
        multi_source = "src: {formats};".format(formats = ",".join(multi_source))

    content = """
                /* AUTO-GENERATED FILE. DO NOT EDIT */

                @font-face {{
                    font-family: '{name}';
                    {single_source}
                    {multi_source}
                    font-weight: {weight};
                    font-style: {style};
                }}
            """.format(
                name = ctx.attr.font_name,
                single_source = single_source,
                multi_source = multi_source,
                weight = ctx.attr.weight,
                style = ctx.attr.style,
            )

    ctx.file_action(
        output = ctx.outputs.out_css,
        content = content
    )

    return struct(
        resources = set(
            [ file for file in
                [
                    ctx.file.eot,
                    ctx.file.ttf,
                    ctx.file.woff,
                    ctx.file.woff2,
                    ctx.file.svg,
                ] if file != None ]
        ),
        css_resources = set([
            ctx.outputs.out_css,
        ]),
    )

def web_internal_zip_site(ctx):
    resources = set()
    source_map = {}
    for resource in ctx.attr.root_files + ctx.attr.resources:
        source_map += _struct_to_dict(getattr(resource, "source_map", struct()))
        resources += getattr(resource, "resources", set())
        resources += getattr(resource, "css_resources", set())
        resources += getattr(resource, "js_resources", set())
    resources += ctx.files.resources

    root_files = [ page.path for page in ctx.files.root_files ]
    resource_paths = [ resource.path for resource in resources ]

    ctx.action(
        mnemonic = "ZipSite",
        arguments = [
                "--output", ctx.outputs.out_zip.path,
            ] +
            _optional_arg("--root-files", root_files) +
            _optional_arg("--resources", resource_paths),
        inputs = [
                ctx.executable._zip_site_script,
            ] +
            list(resources) +
            ctx.files.root_files,
        executable = ctx.executable._zip_site_script,
        outputs = [ ctx.outputs.out_zip ]
    )


    return struct(
        source_map = _dict_to_struct(source_map),
    )

def web_internal_minify_site_zip(ctx):
    root_files = [ file.path for file in ctx.files.root_files ]

    ctx.action(
        mnemonic = "MinifySiteZip",
        arguments = [
                "--in-zip", ctx.file.site_zip.path,
                "--out-zip", ctx.outputs.minified_zip.path,
            ] +
            _optional_arg("--root-files", root_files),
        inputs = [
                ctx.executable._minify_site_zip_script,
                ctx.file.site_zip,
            ] +
            ctx.files.root_files,
        executable = ctx.executable._minify_site_zip_script,
        outputs = [ ctx.outputs.minified_zip ],
    )

def web_internal_rename_zip_paths(ctx):
    if len(ctx.files.path_map_labels_in) != len(ctx.attr.path_map_labels_out):
        fail("path_map_labels_in must be the same size as path_map_labels_out")


    path_map = { key: value for key, value in ctx.attr.path_map.items() }
    path_map.update({
            in_label.path: out_path
                    for in_label, out_path in
                            zip(ctx.files.path_map_labels_in, ctx.attr.path_map_labels_out) })

    path_map_list = [
        value
            for key in path_map
                for value in (key, path_map[key]) ]

    ctx.action(
        mnemonic = "RenameZipPaths",
        arguments = [
                "--in-zip", ctx.file.source_zip.path,
                "--out-zip", ctx.outputs.out_zip.path,
            ] +
            [ "--path-map" ] + path_map_list,
        inputs = [
            ctx.executable._rename_zip_paths_script,
            ctx.file.source_zip,
        ],
        executable = ctx.executable._rename_zip_paths_script,
        outputs = [ ctx.outputs.out_zip ],
    )

def web_internal_generate_jinja_file(ctx, template, config, out_file):
    if (type(ctx) != "ctx"):
        fail("ctx was not a context")
    if (type(template) != "File"):
        fail("template was not a File")
    if (type(config) != "dict"):
        fail("config was not a dictionary")
    if (type(out_file) != "File"):
        fail("out_file was not a File")

    ctx.action(
        mnemonic = "GeneratingFileFromJinjaTemplate",
        arguments = [
            "--template", template.path,
            "--config", str(config),
            "--out-file", out_file.path,
        ],
        inputs = [ template ],
        executable = ctx.executable._generate_jinja_file,
        outputs = [ out_file ],
    )

def web_internal_generate_zip_server_python_file(ctx):
    config = {
        "port": ctx.attr.port,
        "zip": ctx.file.zip.basename,
    }

    web_internal_generate_jinja_file(ctx, ctx.file._template, config, ctx.outputs.out_file)

def web_internal_generate_deploy_site_zip_s3_script(ctx):
    ctx.action(
        mnemonic = "GeneratingS3DeployScript",
        arguments = [
            "--aws-access-key", ctx.attr.aws_access_key,
            "--aws-secret-key", ctx.attr.aws_secret_key,
            "--bucket", ctx.attr.bucket,
            "--deploy-executable", ctx.executable._s3_website_deploy.path,
            "--deployment-jinja-template", ctx.file._deploy_site_zip_to_s3_template.path,
            "--generated-file", ctx.outputs.generated_script.path,
            "--website-zip", ctx.file.zip.path,
        ],
        inputs = [
            ctx.file.zip,
            ctx.file._deploy_site_zip_to_s3_template,
            ctx.executable._s3_website_deploy,
            ctx.executable._s3_website_deploy_script_builder,
        ],
        outputs = [ ctx.outputs.generated_script ],
        executable = ctx.executable._s3_website_deploy_script_builder,
    )
