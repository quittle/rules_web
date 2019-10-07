load("@com_apt_itude_rules_pip//rules:repository.bzl", "pip_repository")
load("@bazel_toolbox//:bazel_toolbox_repositories.bzl", "bazel_toolbox_repositories")
load("@io_bazel_rules_sass//:package.bzl", "rules_sass_dependencies")

def rules_web_dependencies():
    bazel_toolbox_repositories()
    rules_sass_dependencies()

    pip_repository(
        name = "pip",
        python_interpreter = "python3",
        requirements = "//:requirements.txt",
    )
