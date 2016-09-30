# Copyright (c) 2016 Dustin Doloff
# Licensed under Apache License v2.0

_YUI_BUILD_FILE = """

java_binary(
    name = "yui_compressor",
    main_class = "com.yahoo.platform.yui.compressor.Bootstrap",
    srcs = glob([ "src/**/*.java" ]) + [ "@rhino//:rhino_sources_for_yui_compiler" ],
    deps = [ "@jargs//:jargs" ],
    javacopts = [ "-extra_checks:off" ],
    visibility = [ "//visibility:public" ],
)

"""

_JARGS_BUILD_FILE = """

java_library(
    name = "jargs",
    srcs = glob([ "src/jargs/gnu/**/*.java" ]),
    javacopts = [ "-extra_checks:off" ],
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

def rules_web_repositories():
    native.new_git_repository(
        name = "yui_compressor",
        commit = "b3de528f45966e418d6e3e2f6f8135db4d0be7f1",
        remote = "https://github.com/yui/yuicompressor.git",
        build_file_content = _YUI_BUILD_FILE,
    )

    native.new_git_repository(
        name = "jargs",
        commit = "87e0009313e4e508102bb20bd9d736bc71ace30d",
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
        commit = "5973952ac44b93691e137362567220d64a92e7e9",
        remote = "https://github.com/bazelbuild/rules_sass.git",
    )

    native.new_git_repository(
        name = "jinja",
        commit = "368e1b117e74d998f0d3796169c412374708efaf",
        remote = "https://github.com/pallets/jinja.git",
        build_file_content = _JINJA_BUILD_FILE,
    )

    native.new_git_repository(
        name = "markup_safe",
        commit = "feb1d70c16df62f60dcb521d127fdad8819fc036",
        remote = "https://github.com/pallets/markupsafe.git",
        build_file_content = _MARKUP_SAFE_BUILD_FILE,
    )

    native.http_jar(
        name = "http_compressor",
        sha256 = "88894e330cdb0e418e805136d424f4c262236b1aa3683e51037cdb66310cb0f9",
        url = "https://storage.googleapis.com/google-code-archive-downloads/v2/code.google.com/htmlcompressor/htmlcompressor-1.5.3.jar",
    )

    native.maven_jar(
        name = "org_apache_commons_cli",
        artifact = "commons-cli:commons-cli:1.3.1",
        sha1 = "1303efbc4b181e5a58bf2e967dc156a3132b97c0",
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
