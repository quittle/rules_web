# Copyright (c) 2016-2017 Dustin Doloff
# Licensed under Apache License v2.0

_THIRD_PARTY_JAVACOPTS = [ "-XepDisableAllChecks", "-XepAllErrorsAsWarnings", "-nowarn" ]
_THIRD_PARTY_COPTS = [ "-w" ]

def _build_file(build_file):
    return (build_file
            .replace("_THIRD_PARTY_JAVACOPTS", str(_THIRD_PARTY_JAVACOPTS))
            .replace("_THIRD_PARTY_COPTS", str(_THIRD_PARTY_COPTS)))

_YUI_BUILD_FILE = _build_file("""

java_binary(
    name = "yui_compressor",
    main_class = "com.yahoo.platform.yui.compressor.Bootstrap",
    srcs = glob([ "src/**/*.java" ]) + [ "@rhino//:rhino_sources_for_yui_compiler" ],
    deps = [ "@jargs//:jargs" ],
    javacopts = _THIRD_PARTY_JAVACOPTS,
    visibility = [ "//visibility:public" ],
)

""")

_JARGS_BUILD_FILE = _build_file("""

java_library(
    name = "jargs",
    srcs = glob([ "src/jargs/gnu/**/*.java" ]),
    javacopts = _THIRD_PARTY_JAVACOPTS,
    visibility = [ "//visibility:public" ],
)

""")

_JERICHO_SELECTOR_BUILD_FILE = _build_file("""

java_library(
    name = "jericho_selector",
    srcs = glob([ "src/main/java/**/*.java" ]),
    javacopts = _THIRD_PARTY_JAVACOPTS,
    deps = [
        "@br_com_starcode_parccser_parccser//jar",
        "@net_htmlparser_jericho_jericho_html//jar",
    ],
    visibility = [ "//visibility:public" ],
)

""")

_RHINO_BUILD_FILE = _build_file("""

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
    javacopts = _THIRD_PARTY_JAVACOPTS,
    visibility = [ "//visibility:public" ],
)

""")

_JINJA_BUILD_FILE = _build_file("""

py_library(
    name = "jinja",
    srcs = glob([ "jinja2/*.py" ]),
    deps = [
        "@markup_safe//:markup_safe",
    ],
    visibility = [ "//visibility:public" ],
)

""")

_MARKUP_SAFE_BUILD_FILE = _build_file("""

py_library(
    name = "markup_safe",
    srcs = glob([ "markupsafe/*.py" ]),
    visibility = [ "//visibility:public" ],
)

""")

_PY_BASIC_HTTP_SERVER_FILE = _build_file("""

py_library(
    name = "basic_http_server",
    srcs = [
        "BasicHttpServer-1.0.0/BasicHttpServer.py",
    ],
    visibility = [ "//visibility:public" ],
)

""")

_FONT_TOOLS_BUILD_FILE = _build_file("""

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

""")

_WOFF_2_BUILD_FILE = _build_file("""

cc_binary(
    name = "ttf2woff2",
    srcs = glob(
        include = [
            "src/*.cc",
            "src/*.h",
        ],
        exclude = [
            "src/convert_woff2ttf_fuzzer*.cc",
            "src/woff2_decompress.cc",
            "src/woff2_dec.cc",
            "src/woff2_info.cc",
        ],
    ),
    copts = _THIRD_PARTY_COPTS,
    deps = [
        "@org_brotli//:brotlienc",
    ],
    includes = [ "@org_brotli//:enc" ],
    visibility = [ "//visibility:public" ],
)

""")

_TTF_2_EOT_BUILD_FILE = _build_file("""

cc_binary(
    name = "ttf2eot",
    srcs = [
        "OpenTypeUtilities.cpp",
        "OpenTypeUtilities.h",
        "ttf2eot.cpp",
    ],
    copts = _THIRD_PARTY_COPTS,
    visibility = [ "//visibility:public" ],
)

""")

_PILLOW_BUILD_FILE = _build_file("""

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

""")

def rules_web_repositories():
    native.new_git_repository(
        name = "yui_compressor",
        commit = "958491db9bff77fe97d3ea0b8af38953aa1f6216", # master
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
        commit = "f5debf685ede0531f27377536fe05872b78aa63c", # 0.0.2 + patch
        remote = "https://github.com/quittle/rules_sass.git",
    )

    native.new_git_repository(
        name = "jinja",
        commit = "d78a1b079cd985eea7d636f79124ab4fc44cb538", # 2.9.6
        remote = "https://github.com/pallets/jinja.git",
        build_file_content = _JINJA_BUILD_FILE,
    )

    native.new_git_repository(
        name = "markup_safe",
        commit = "d2a40c41dd1930345628ea9412d97e159f828157", # 1.0
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
        name = "com_fasterxml_jackson_core_jackson_annotations",
        artifact = "com.fasterxml.jackson.core:jackson-annotations:2.9.0",
        sha1 = "07c10d545325e3a6e72e06381afe469fd40eb701",
    )

    native.maven_jar(
        name = "com_fasterxml_jackson_core_jackson_core",
        artifact = "com.fasterxml.jackson.core:jackson-core:2.9.0",
        sha1 = "88e7c6220be3b3497b3074d3fc7754213289b987",
    )

    native.maven_jar(
        name = "com_fasterxml_jackson_core_jackson_databind",
        artifact = "com.fasterxml.jackson.core:jackson-databind:2.9.0",
        sha1 = "14fb5f088cc0b0dc90a73ba745bcade4961a3ee3",
    )

    native.maven_jar(
        name = "com_google_code_gson_gson",
        artifact = "com.google.code.gson:gson:2.8.1",
        sha1 = "02a8e0aa38a2e21cb39e2f5a7d6704cbdc941da0",
    )

    native.maven_jar(
        name = "joda_time_joda_time",
        artifact = "joda-time:joda-time:2.9.9",
        sha1 = "f7b520c458572890807d143670c9b24f4de90897",
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
        name = "org_apache_commons_lang3",
        artifact = "org.apache.commons:commons-lang3:3.6",
        sha1 = "9d28a6b23650e8a7e9063c04588ace6cf7012c17",
    )

    native.maven_jar(
        name = "org_apache_commons_logging",
        artifact = "commons-logging:commons-logging:1.2",
        sha1 = "4bfc12adfe4842bf07b657f0369c4cb522955686",
    )

    native.maven_jar(
        name = "org_apache_httpcomponents_httpclient",
        artifact = "org.apache.httpcomponents:httpclient:4.5.3",
        sha1 = "d1577ae15f01ef5438c5afc62162457c00a34713",
    )

    native.maven_jar(
        name = "org_apache_httpcomponents_httpcore",
        artifact = "org.apache.httpcomponents:httpcore:4.4.6",
        sha1 = "e3fd8ced1f52c7574af952e2e6da0df8df08eb82",
    )

    native.maven_jar(
        name = "com_amazonaws_aws_java_sdk_core",
        artifact = "com.amazonaws:aws-java-sdk-core:1.11.184",
        sha1 = "1c2b17dd004e9b721b6639b8a1797e64939cc700",
    )

    native.maven_jar(
        name = "com_amazonaws_aws_java_sdk_kms",
        artifact = "com.amazonaws:aws-java-sdk-kms:1.11.184",
        sha1 = "f00b787f614aa061899adcb44b40c68f6a9fd4d3",
    )

    native.maven_jar(
        name = "com_amazonaws_aws_java_sdk_lambda",
        artifact = "com.amazonaws:aws-java-sdk-lambda:1.11.123",
        sha1 = "04d7adf30778264f2c32b00532b31bd86556d2f5",
    )

    native.maven_jar(
        name = "com_amazonaws_aws_java_sdk_s3",
        artifact = "com.amazonaws:aws-java-sdk-s3:1.11.184",
        sha1 = "21c34af4d83fe8156b0c3ae33324de532ad2b216",
    )

    native.git_repository(
        name = "io_bazel_rules_go",
        remote = "https://github.com/bazelbuild/rules_go.git",
        tag = "0.4.4",
    )

    native.git_repository(
        name = "org_brotli",
        commit = "46c1a881b41bb638c76247558aa04b1591af3aa7", # 0.6.0
        remote = "https://github.com/google/brotli.git",
    )

    native.new_git_repository(
        name = "font_tools",
        commit = "b7cfdaf367a7c8f05bde68bd665842b6c84031dc", # 3.15.1
        remote = "https://github.com/googlei18n/fonttools.git",
        build_file_content = _FONT_TOOLS_BUILD_FILE,
    )

    native.new_git_repository(
        name = "woff2",
        commit = "aa283a500aeb655834d77f3cf9cf1b093b0b4389", # master
        remote = "https://github.com/google/woff2.git",
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
        artifact = "com.github.depsypher:pngtastic:1.4",
        sha1 = "3b101e1170c7bd09ef257681ea56808dca4b3823",
    )

    native.maven_jar(
        name = "com_google_javascript_closure_compiler",
        artifact = "com.google.javascript:closure-compiler:v20170806",
        sha1 = "708706764914ee53821d70f24db33c3b40c19812",
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

    native.maven_jar(
        name = "junit",
        artifact = "junit:junit:4.12",
        sha1 = "2973d150c0dc1fefe998f834810d68f278ea58ec",
    )

    native.new_http_archive(
        name = "pillow",
        url = "https://pypi.python.org/packages/43/5a/904f2cc20ef9f9ba05f9ff1fb3dfadb1e6923e3bf6f8c8363d5dc3a179ab/Pillow-4.2.1-cp27-cp27mu-manylinux1_x86_64.whl",
        type = "zip",
        sha256 = "24e8bef1269598ef8f1f418575b12a15bb1a019ea177ad9445b197b8f209a7c8",
        build_file_content = _PILLOW_BUILD_FILE,
    )

    native.git_repository(
        name = "bazel_toolbox",
        commit = "c12909cccdaef1d092652a49aedb928d4b2d90a3",
        remote = "https://github.com/quittle/bazel_toolbox.git",
    )
