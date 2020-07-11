# Copyright (c) 2016-2018 Dustin Toff
# Licensed under Apache License v2.0

load("@bazel_tools//tools/build_defs/repo:git.bzl", "git_repository")

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
        "@maven//:br_com_starcode_parccser_parccser",
        "@maven//:net_htmlparser_jericho_jericho_html",
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
    if "rules_jvm_external" not in native.existing_rules():
        github_repository(
            name = "rules_jvm_external",
            user = "bazelbuild",
            project = "rules_jvm_external",
            tag = "3.2",
            sha256 = "19d402ef15f58750352a1a38b694191209ebc7f0252104b81196124fdd43ffa0",
        )

    if "io_bazel_rules_sass" not in native.existing_rules():
        github_repository(
            name = "io_bazel_rules_sass",
            user = "bazelbuild",
            project = "rules_sass",
            tag = "1.26.10",
            sha256 = "a2b6342b8fc3f6947e47219171976ee60bb3df73c45ef7352bfdeecba9b73a38",
        )

    github_repository(
        name = "com_apt_itude_rules_pip",
        user = "apt-itude",
        project = "rules_pip",
        commit = "ce667087818553cdc4b1a2258fc53df917c4f87c",
        sha256 = "5cabd6bfb9cef095d0d076faf5e7acd5698f7172e803059c21c4e700a07b131b",
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

    if "io_bazel_rules_go" not in native.existing_rules():
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
        commit = "f1a99f4d11fdd51a47c20158d379df31155b48e1",
        sha256 = "03ad4bf1aad8c2229e09d8f5b5cd7fe8ad0d03788bb0f5e3f3c511d5d4238c86",
    )
