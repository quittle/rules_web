# Copyright (c) 2016-2017 Dustin Doloff
# Licensed under Apache License v2.0

workspace(name = "rules_web")

load("@bazel_tools//tools/build_defs/repo:git.bzl", "git_repository")

git_repository(
    name = "bazel_repository_toolbox",
    commit = "f512b37be02d5575d85234c9040b0f4c795a76ef",
    remote = "https://github.com/quittle/bazel_repository_toolbox",
)

# A three part load of the dependencies is required to load them all and ensure all necessary
# installations have taken place

load(":rules_web_deps_1.bzl", "rules_web_dependencies")

rules_web_dependencies()

load(":rules_web_deps_2.bzl", "rules_web_dependencies")

rules_web_dependencies()

load(":rules_web_deps_3.bzl", "rules_web_dependencies")

rules_web_dependencies()
