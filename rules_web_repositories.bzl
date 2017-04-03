# Copyright (c) 2016-2017 Dustin Doloff
# Licensed under Apache License v2.0

_YUI_BUILD_FILE = """

java_binary(
    name = "yui_compressor",
    main_class = "com.yahoo.platform.yui.compressor.Bootstrap",
    srcs = glob([ "src/**/*.java" ]) + [ "@rhino//:rhino_sources_for_yui_compiler" ],
    deps = [ "@jargs//:jargs" ],
    javacopts = [ "-extra_checks:off", "-nowarn" ],
    visibility = [ "//visibility:public" ],
)

"""

_JARGS_BUILD_FILE = """

java_library(
    name = "jargs",
    srcs = glob([ "src/jargs/gnu/**/*.java" ]),
    javacopts = [ "-extra_checks:off", "-nowarn" ],
    visibility = [ "//visibility:public" ],
)

"""

_JERICHO_SELECTOR_BUILD_FILE = """

java_library(
    name = "jericho_selector",
    srcs = glob([ "src/main/java/**/*.java" ]),
    deps = [
        "@br_com_starcode_parccser_parccser//jar",
        "@net_htmlparser_jericho_jericho_html//jar",
    ],
    visibility = [ "//visibility:public" ],
)

"""

_RHINO_BUILD_FILE = """

filegroup(
    name = "rhino_sources_for_yui_compiler",
    srcs = glob(
        include = [ "src/**/*.java" ],
        exclude = [
            "src/org/mozilla/javascript/Decompiler.java",
            "src/org/mozilla/javascript/Parser.java",
            "src/org/mozilla/javascript/Token.java",
            "src/org/mozilla/javascript/TokenStream.java",
        ],
    ),
    visibility = [ "//visibility:public" ],
)

java_library(
    name = "rhino",
    srcs = glob([ "src/**/*.java" ]),
    javacopts = [ "-extra_checks:off" ],
    visibility = [ "//visibility:public" ],
)

"""

_JINJA_BUILD_FILE = """

py_library(
    name = "jinja",
    srcs = glob([ "jinja2/*.py" ]),
    deps = [
        "@markup_safe//:markup_safe",
    ],
    visibility = [ "//visibility:public" ],
)

"""

_MARKUP_SAFE_BUILD_FILE = """

py_library(
    name = "markup_safe",
    srcs = glob([ "markupsafe/*.py" ]),
    visibility = [ "//visibility:public" ],
)

"""

_PY_BASIC_HTTP_SERVER_FILE = """

py_library(
    name = "basic_http_server",
    srcs = [
        "BasicHttpServer-1.0.0/BasicHttpServer.py",
    ],
    visibility = [ "//visibility:public" ],
)


"""

_FONT_TOOLS_BUILD_FILE = """

py_binary(
    name = "ttx",
    srcs = glob([
        "Lib/*.py",
        "Lib/**/*.py"
    ]),
    imports = [ "Lib" ],
    main = "Lib/fontTools/ttx.py",
    visibility = [ "//visibility:public" ],
)

"""

_IO_BROTLI_BUILD_FILE = """

cc_library(
    name = "brotli_enc",
    srcs = glob(["common/*.c", "enc/*.c", "enc/*.cc" ]),
    hdrs = glob(["common/*.h", "enc/*.h"]),
    visibility = [ "//visibility:public" ],
)

"""

_WOFF_2_BUILD_FILE = """

cc_binary(
    name = "ttf2woff2",
    srcs = glob(
        include = [
            "src/*.cc",
            "src/*.h",
        ],
        exclude = [
            "src/woff2_decompress.cc",
            "src/woff2_dec.cc",
        ],
    ),
    copts = [
        "-w",
    ],
    deps = [
        "@io_brotli//:brotli_enc",
    ],
    includes = [ "@io_brotli//:enc" ],
    visibility = [ "//visibility:public" ],
)

"""

_TTF_2_EOT_BUILD_FILE = """

cc_binary(
    name = "ttf2eot",
    srcs = [
        "OpenTypeUtilities.cpp",
        "OpenTypeUtilities.h",
        "ttf2eot.cpp",
    ],
    copts = [
        "-w",
    ],
    visibility = [ "//visibility:public" ],
)

"""

_PILLOW_BUILD_FILE = """

py_library(
    name = "pillow",
    srcs = glob([
        "PIL/*.py"
    ]),
    data = glob([
        "PIL/.libs/*",
        "PIL/*.so"
    ]),
    visibility = [ "//visibility:public" ],
)

"""

def rules_web_repositories():
    native.new_git_repository(
        name = "yui_compressor",
        commit = "b3de528f45966e418d6e3e2f6f8135db4d0be7f1", # master
        remote = "https://github.com/yui/yuicompressor.git",
        build_file_content = _YUI_BUILD_FILE,
    )

    native.new_git_repository(
        name = "jargs",
        commit = "87e0009313e4e508102bb20bd9d736bc71ace30d", # master
        remote = "https://github.com/purcell/jargs.git",
        build_file_content = _JARGS_BUILD_FILE,
    )

    native.new_git_repository(
        name = "rhino",
        commit = "d89b519209853d446f2d9014e941a5e7b3867df2", # Release 1.7R2
        remote = "https://github.com/mozilla/rhino.git",
        build_file_content = _RHINO_BUILD_FILE,
    )

    native.git_repository(
        name = "io_bazel_rules_sass",
        commit = "5973952ac44b93691e137362567220d64a92e7e9", # 0.0.1
        remote = "https://github.com/bazelbuild/rules_sass.git",
    )

    native.new_git_repository(
        name = "jinja",
        commit = "966e1a409f02de57b75a0463fc953d54dad2a205", # 2.8
        remote = "https://github.com/pallets/jinja.git",
        build_file_content = _JINJA_BUILD_FILE,
    )

    native.new_git_repository(
        name = "markup_safe",
        commit = "feb1d70c16df62f60dcb521d127fdad8819fc036", # 0.23
        remote = "https://github.com/pallets/markupsafe.git",
        build_file_content = _MARKUP_SAFE_BUILD_FILE,
    )

    native.http_jar(
        name = "html_compressor",
        sha256 = "88894e330cdb0e418e805136d424f4c262236b1aa3683e51037cdb66310cb0f9",
        url = "https://storage.googleapis.com/google-code-archive-downloads/v2/code.google.com/htmlcompressor/htmlcompressor-1.5.3.jar",
    )

    native.new_git_repository(
        name = "utluiz_jericho_selector",
        commit = "3214ba810595d7d0be94a104496bb7ae7f409165",
        remote = "https://github.com/utluiz/jericho-selector.git",
        build_file_content = _JERICHO_SELECTOR_BUILD_FILE,
    )

    native.maven_jar(
        name = "org_apache_commons_cli",
        artifact = "commons-cli:commons-cli:1.4",
        sha1 = "c51c00206bb913cd8612b24abd9fa98ae89719b1",
    )

    native.maven_jar(
        name = "org_apache_commons_io",
        artifact = "commons-io:commons-io:2.5",
        sha1 = "2852e6e05fbb95076fc091f6d1780f1f8fe35e0f",
    )

    native.maven_jar(
        name = "com_amazonaws_aws_java_sdk_core",
        artifact = "com.amazonaws:aws-java-sdk-core:1.11.38",
        sha1 = "a42c623900d372a3df72c4d44f9c2c420ff64dbc",
    )

    native.maven_jar(
        name = "com_amazonaws_aws_java_sdk_kms",
        artifact = "com.amazonaws:aws-java-sdk-kms:1.11.38",
        sha1 = "34e8a0a665c7db51265b10824fb0b11eb062fc1a",
    )

    native.maven_jar(
        name = "com_amazonaws_aws_java_sdk_s3",
        artifact = "com.amazonaws:aws-java-sdk-s3:1.11.38",
        sha1 = "96e88f07d8fcba7f87a9d68ccd8282a28bb3d88c",
    )

    native.new_git_repository(
        name = "io_brotli",
        commit = "66c14517cf8afcc1a1649a7833ac789366eb0b51", # 0.5
        remote = "https://github.com/google/brotli.git",
        build_file_content = _IO_BROTLI_BUILD_FILE,
    )

    native.new_git_repository(
        name = "font_tools",
        commit = "ea155757f4887422d93fe430a06a643cbe1bb94a", # 3.1.2
        remote = "https://github.com/googlei18n/fonttools.git",
        build_file_content = _FONT_TOOLS_BUILD_FILE,
    )

    # This repo includes the patch to fix the build
    native.new_git_repository(
        name = "woff2",
        commit = "3cca6ff8a9a0d63b0224d5d28aa0e3e1e0639308", # master
        remote = "https://github.com/quittle/woff2.git",
        build_file_content = _WOFF_2_BUILD_FILE,
    )

    native.new_git_repository(
        name = "ttf2eot",
        commit = "0133021ec33552b0b6ae7b3c8f052d067f4b4193", # master
        remote = "https://github.com/metaflop/ttf2eot.git",
        build_file_content = _TTF_2_EOT_BUILD_FILE,
    )

    native.maven_jar(
        name = "pngtastic",
        artifact = "com.github.depsypher:pngtastic:1.2",
        sha1 = "ff40ec21712778285fc4977521ea3a6ba71354a2",
    )

    native.maven_jar(
        name = "com_google_javascript_closure_compiler",
        artifact = "com.google.javascript:closure-compiler:v20160208",
        sha1 = "5a2f4be6cf41e27ed7119d26cb8f106300d87d91",
    )

    native.maven_jar(
        name = "br_com_starcode_parccser_parccser",
        artifact = "br.com.starcode.parccser:parccser:1.1.1-RELEASE",
        sha1 = "98f9db564ba8887e9f36ec0ac7e2f9f3693606f0",
    )

    native.maven_jar(
        name = "net_htmlparser_jericho_jericho_html",
        artifact = "net.htmlparser.jericho:jericho-html:3.4",
        sha1 = "0799191f451f5a6910ce37b0147771489ab46fed",
    )

    native.new_http_archive(
        name = "pillow",
        url = "https://pypi.python.org/packages/c0/47/6900d13aa6112610df4c9b34d57f50a96b35308796a3a27458d0c9ac87f7/Pillow-3.4.2-cp27-cp27mu-manylinux1_x86_64.whl",
        type = "zip",
        sha256 = "fdc641ac432115e35d31441dbb253b016beea467dff402259d74b4df5e5f0f63",
        build_file_content = _PILLOW_BUILD_FILE,
    )

    native.git_repository(
        name = "bazel_toolbox",
        commit = "5bfc7704088e2d8f4510230a06be0fc19cb2f7d7",
        remote = "https://github.com/quittle/bazel_toolbox.git",
    )
