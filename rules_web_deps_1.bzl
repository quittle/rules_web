# Copyright (c) 2016-2018 Dustin Toff
# Licensed under Apache License v2.0

load(
    "@bazel_repository_toolbox//:github_repository.bzl",
    "github_repository",
    "new_github_repository",
)
load("@bazel_tools//tools/build_defs/repo:git.bzl", "new_git_repository")
load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive", "http_jar")

_THIRD_PARTY_JAVACOPTS = ["-XepDisableAllChecks", "-XepAllErrorsAsWarnings", "-nowarn"]
_THIRD_PARTY_COPTS = ["-w"]

def _build_file(build_file):
    return (build_file.replace("_THIRD_PARTY_JAVACOPTS", str(_THIRD_PARTY_JAVACOPTS)).replace("_THIRD_PARTY_COPTS", str(_THIRD_PARTY_COPTS)))

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
            "include/**/*.h",
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
    includes = [
        "include",
        "@org_brotli//:enc",
    ],
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

_NU_VALIDATOR_BUILD_FILE = _build_file("""

java_import(
    name = "validator",
    jars = [
        "//:vnu.jar",
    ],
    visibility = [ "//visibility:public" ],
)

""")

def rules_web_dependencies():
    native.maven_jar(
        name = "com_yahoo_platform_yui_yuicompressor",
        artifact = "com.yahoo.platform.yui:yuicompressor:2.4.8",
        sha1 = "900a7296bb52d740418d53274c1ecac5c83c760e",
    )

    github_repository(
        name = "io_bazel_rules_sass",
        user = "bazelbuild",
        project = "rules_sass",
        tag = "1.23.0",
        sha256 = "d9c4166f5eeaae2bc0985435bcc69a5f8ce0b6d4c2bfb8c04d97bf439e4d8c3b",
    )

    github_repository(
        name = "com_apt_itude_rules_pip",
        user = "apt-itude",
        project = "rules_pip",
        commit = "ce667087818553cdc4b1a2258fc53df917c4f87c",
        sha256 = "5cabd6bfb9cef095d0d076faf5e7acd5698f7172e803059c21c4e700a07b131b",
    )

    github_repository(
        name = "rules_jvm_external",
        user = "bazelbuild",
        project = "rules_jvm_external",
        tag = "2.8",
        sha256 = "4b9cd81a08d9ea89218428c1e7a59f06abfaa1042402efa407efb7d3e607df84",
    )

    http_jar(
        name = "html_compressor",
        sha256 = "88894e330cdb0e418e805136d424f4c262236b1aa3683e51037cdb66310cb0f9",
        url = "https://storage.googleapis.com/google-code-archive-downloads/v2/code.google.com/htmlcompressor/htmlcompressor-1.5.3.jar",
    )

    new_git_repository(
        name = "utluiz_jericho_selector",
        commit = "8d2b47df389fe5ff62d6676c6477c60559665ced",
        remote = "https://github.com/utluiz/jericho-selector.git",
        build_file_content = _JERICHO_SELECTOR_BUILD_FILE,
    )

    native.maven_jar(
        name = "org_mozilla_rhino",
        artifact = "org.mozilla:rhino:1.7.8",
        sha1 = "f4810305c9d2053db38f5d768b859cd8aeb80648",
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
        name = "org_apache_commons_lang3",
        artifact = "org.apache.commons:commons-lang3:3.7",
        sha1 = "557edd918fd41f9260963583ebf5a61a43a6b423",
    )

    native.maven_jar(
        name = "org_apache_commons_logging",
        artifact = "commons-logging:commons-logging:1.2",
        sha1 = "4bfc12adfe4842bf07b657f0369c4cb522955686",
    )

    native.maven_jar(
        name = "org_apache_httpcomponents_httpclient",
        artifact = "org.apache.httpcomponents:httpclient:4.5.5",
        sha1 = "1603dfd56ebcd583ccdf337b6c3984ac55d89e58",
    )

    native.maven_jar(
        name = "org_apache_httpcomponents_httpcore",
        artifact = "org.apache.httpcomponents:httpcore:4.4.9",
        sha1 = "a86ce739e5a7175b4b234c290a00a5fdb80957a0",
    )

    native.maven_jar(
        name = "com_amazonaws_aws_java_sdk_core",
        artifact = "com.amazonaws:aws-java-sdk-core:1.11.275",
        sha1 = "74ef283b06892b2398f6e9013a772868b06d84b9",
    )

    native.maven_jar(
        name = "com_amazonaws_aws_java_sdk_kms",
        artifact = "com.amazonaws:aws-java-sdk-kms:1.11.275",
        sha1 = "42a5484659a58dfa339f516310bc64c0babfe57e",
    )

    native.maven_jar(
        name = "com_amazonaws_aws_java_sdk_lambda",
        artifact = "com.amazonaws:aws-java-sdk-lambda:1.11.275",
        sha1 = "a365dd512aa2a62cd622d817de8ace574e56b061",
    )

    native.maven_jar(
        name = "com_amazonaws_aws_java_sdk_s3",
        artifact = "com.amazonaws:aws-java-sdk-s3:1.11.275",
        sha1 = "4309dd431b168eeeb97adf7062c82d9713f14f01",
    )

    github_repository(
        name = "io_bazel_rules_go",
        user = "bazelbuild",
        project = "rules_go",
        tag = "0.9.0",
        sha256 = "dea9e0405aae86e5339b1ccdd656387b4982352da7cec3ab688f1965440d3326",
    )

    github_repository(
        name = "org_brotli",
        user = "google",
        project = "brotli",
        tag = "v1.0.7",
        sha256 = "4c61bfb0faca87219ea587326c467b95acb25555b53d1a421ffa3c8a9296ee2c",
    )

    new_github_repository(
        name = "font_tools",
        user = "fonttools",
        project = "fonttools",
        tag = "3.22.0",
        build_file_content = _FONT_TOOLS_BUILD_FILE,
        sha256 = "e403b7ab34c4d7ee4130289850e2bf63299868e40086e46c9357e7005e37d8a4",
    )

    new_github_repository(
        name = "woff2",
        user = "google",
        project = "woff2",
        tag = "v1.0.2",
        build_file_content = _WOFF_2_BUILD_FILE,
        sha256 = "add272bb09e6384a4833ffca4896350fdb16e0ca22df68c0384773c67a175594",
    )

    new_github_repository(
        name = "ttf2eot",
        user = "metaflop",
        project = "ttf2eot",
        commit = "0133021ec33552b0b6ae7b3c8f052d067f4b4193",  # master
        build_file_content = _TTF_2_EOT_BUILD_FILE,
        sha256 = "b27613e9415304adeb3de9abd7c0ce5e01b3fc5289055275c6f8c9fe97e7cead",
    )

    native.maven_jar(
        name = "pngtastic",
        artifact = "com.github.depsypher:pngtastic:1.5",
        sha1 = "837f0b6cf384f337a6dd710b72dda9b112589044",
    )

    native.maven_jar(
        name = "com_google_javascript_closure_compiler",
        artifact = "com.google.javascript:closure-compiler:v20180204",
        sha1 = "755c8d0aa25b6a62462ce79189854fcf80db162c",
    )

    native.maven_jar(
        name = "br_com_starcode_parccser_parccser",
        artifact = "br.com.starcode.parccser:parccser:1.1.2-RELEASE",
        sha1 = "7c018e07fcfbeccd5b363a33ecfbfa2ce4de45d4",
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

    native.maven_jar(
        name = "com_google_code_findbugs_jsr305",
        artifact = "com.google.code.findbugs:jsr305:3.0.2",
        sha1 = "25ea2e8b0c338a877313bd4672d3fe056ea78f0d",
    )

    http_archive(
        name = "nu_validator",
        url = "https://github.com/validator/validator/releases/download/18.3.0/vnu.jar_18.3.0.zip",
        sha256 = "9f8bcdc94b5496b9fcb8c01e20fd22684a7dcbbae48804aeb027f17315fb3f8d",
        strip_prefix = "dist",
        build_file_content = _NU_VALIDATOR_BUILD_FILE,
    )

    github_repository(
        name = "bazel_toolbox",
        user = "quittle",
        project = "bazel_toolbox",
        commit = "debed2fb5ed7ce3c96ea87c006b9f962e2357177",
        sha256 = "e044e18f8fbe845e1cecffb60ef919b1e3b0b34d111acf2838b1a194b9073099",
    )
