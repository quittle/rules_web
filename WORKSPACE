# Copyright (c) 2016-2017 Dustin Doloff
# Licensed under Apache License v2.0

workspace(name = "rules_web")

git_repository(
    name = "bazel_repository_toolbox",
    remote = "https://github.com/quittle/bazel_repository_toolbox",
    commit = "8f9a64e3782908571053daad5fb9053b022d040f",
)

load(":rules_web_repositories.bzl", "rules_web_repositories")
rules_web_repositories()

load("@bazel_toolbox//:bazel_toolbox_repositories.bzl", "bazel_toolbox_repositories")
bazel_toolbox_repositories()

load("@io_bazel_rules_sass//sass:sass.bzl", "sass_repositories")
sass_repositories()
