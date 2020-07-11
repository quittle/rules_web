load("@com_apt_itude_rules_pip//rules:repository.bzl", "pip_repository")
load("@bazel_toolbox//:bazel_toolbox_repositories.bzl", "bazel_toolbox_repositories")
load("@io_bazel_rules_sass//:package.bzl", "rules_sass_dependencies")
load("@rules_jvm_external//:defs.bzl", "maven_install")

def rules_web_dependencies():
    bazel_toolbox_repositories()
    rules_sass_dependencies()

    pip_repository(
        name = "pip",
        python_interpreter = "python3",
        requirements = "@rules_web//:requirements.txt",
    )

    maven_install(
        artifacts = [
            "javax.xml.bind:jaxb-api:2.3.1",
            "com.yahoo.platform.yui:yuicompressor:2.4.8",
            "org.mozilla:rhino:1.7.8",
            "com.google.code.gson:gson:2.8.1",
            "joda-time:joda-time:2.9.9",
            "br.com.starcode.parccser:parccser:1.1.2-RELEASE",
            "net.htmlparser.jericho:jericho-html:3.4",
            "org.apache.commons:commons-lang3:3.7",
            "com.github.depsypher:pngtastic:1.5",
            "com.google.code.findbugs:jsr305:3.0.2",
            "com.google.javascript:closure-compiler:v20180204",
            "com.amazonaws:aws-java-sdk-core:1.11.275",
            "com.amazonaws:aws-java-sdk-kms:1.11.275",
            "com.amazonaws:aws-java-sdk-lambda:1.11.275",
            "com.amazonaws:aws-java-sdk-s3:1.11.275",
            "commons-cli:commons-cli:1.4",
            "commons-io:commons-io:2.7",
            "junit:junit:4.12",
        ],
        repositories = [
            "https://repo1.maven.org/maven2",
        ],
    )
