# Web Rules for Bazel [![Build Status](https://api.travis-ci.org/quittle/rules_web.svg?branch=master)](https://travis-ci.org/quittle/rules_web)

## How to use
1. Install [Bazel](https://bazel.build/versions/master/docs/install.html) and set up a workspace
2. Add `rules_web` as a `git_repository` to the `WORKSPACE` file

  ```
    git_repository(
        name = "rules_web",
        remote = "https://github.com/quittle/rules_web.git",
    )
  ```
3. Add the dependencies as well in the `WORKSPACE`

  ```
    load("@rules_web//:rules_web_repositories.bzl", "rules_web_repositories")
    rules_web_repositories()
  ```
4. Load rule files from non-`internal.bzl` Bazel files.

  ```
    load("@rules_web//html:html.bzl", "html_page")
    load("@rules_web//fonts:fonts.bzl", "font_generator", "minify_ttf")
  ```

## Rules
`//css:css.bzl`
* `minify_css` Minified a bunch of CSS files into one
  * `srcs` A label list of sources to merge and minify

`//fonts:fonts.bzl`
* `font_generator` Generates a CSS file with the `font-family` representing this group of font files.
  * `font_name` The name of the font that it will be referenced by
  * `eot` An optional EOT font file to use
  * `ttf` An optional TTF font file to use
  * `woff` An optional WOFF font file to use
  * `woff2` An optional WOFF2 font file to use
  * `svg` An optional SVG font file to use
  * `weight` The weight of these fonts. Defaults to `normal`
  * `style` The style of these fonts. Defaults to `normal`
* `minify_ttf` Generates a smaller version of a TTF font file by renaming glyphs and removing unnessary tables.
  * `ttf` The TTF file to shrink
* `ttf_to_eot` Convertes a TTF font file to an EOT font file
  * `ttf` The TTF file to convert
* `ttf_to_woff` Converts a TTF font file to a WOFF font file
  * `ttf` The TTF file to convert
* `ttf_to_woff2` Converts a TTF font file to a WOFF2 font file
  * `ttf` The TTF file to convert

`//generate:generate.bzl`
* `generate_variables` Generates constants for various languages
  * `config` A JSON file containing the variables
  * `out_css` An optional CSS file to write the mapping of the variables to
  * `out_js` An optional Javascript file to write the mapping of the variables to
  * `out_scss` An optional SCSS file to write the mapping of the variables to

`//html:html.bzl`
* `minify_html` Minifies an HTML file
  * `src` The HTML file to minify
* `html_page` Builds an HTML file including or referencing the provided sources
  * `template` An optional Jinja2 template for the HTML page that overrides the default.
  * `config` A JSON file that contains basic meta-data about the page
  * `body` An HTML file containing the `<body>` of the page including the body open and closing tags.
  * `deferred_js_files` Javascript files that should be downloaded and run only after the `window`'s `load` event has fired.
  * `js_files` Javascript files that should be downloaded and run before the body is loaded.
  * `css_files` CSS files that should be downloaded and evaluated asynchronously.
  * `favicon_images` A list of favicon images at various sizes. This must be the same length as `favicon_sizes`
  * `favicon_sizes` A list of ints that represent the square-size of the images in `favicon_images`. Must be the same length as `favicon_images`.
  * `deps` Other files that may be referrenced by resources in the page.

`//images/images.bzl`
* `favicon_image_generator` Generates favicons of various sizes
  * `image` The source image
  * `output_files` The files to generate. Must be the same length as `output_sizes`
  * `output_sizes` A list of ints representing the square-size of the images generated. Must be the same length as `output_files`.
  * `allow_upsizing` An optional boolean of whether the build should not fail if the image needs to be stretched larger to generate any of the images. Defaults to `False`
  * `allow_stretching` An optional boolean of whether the build should not fail if the image needs to be distorted to a different aspect-ratio. Defaults to `False`.
* `minify_png` Minimizes the size of a PNG image
  * `png` The PNG the shrink.
* `resize_image` Resizes an image
  * `image` The image to resize
  * `width` Optionally the width of the image to output. If set, height must also be set.
  * `height` Optionally the height of the image to output. If set, width must also be set.
  * `scale` Optionally the scaling ratio of the image as a string. If set, width and height must not be set.

`//js/js.bzl`
* `resource_map` Generates a Javascript file mapping resources to a deeply nested dictionary representing the file system structure. For example if `["src/path/file.txt", "src/other-path/image.png"]` were mapped, it would generate `{ "src": { "path": "file.txt", "other-path": "image.png" } }`.
  * `constant_name` The contant name that holds the dictionary. E.g. `"RESOURCE_MAP"` would map to `window.RESOURCE_MAP`.
  * `deps` The labels to put in the dictionary.
* `minify_js` Minifies a Javascript files together into one, smaller file.
  * `srcs` The source files to minify and combine.
* `closure_compile` Compiles Javascript files together with the Closure Compiler.
  * `srcs` The Javascript files to merge and compile.
  * `externs` The external Javascript files whose contents should not be minified in the generated file.
  * `compilation_level` The compilation level to compile with.
  * `warning_level` The warning level to compile with.
  * `extra_args` A list of extra arguments to pass to the compiler

`//site_zip:site_zip.bzl`
* `zip_site` Zips all the sources for a website into one file
  * `root_files` The root files of the website that will be requested by the user directly. This should be your base html pages, robots.txt and other resources like that.
  * `resouces` All the possible resources that `root_files` might reference to be included in the zip.
  * `out_zip` The zip file to generate.
* `minify_site_zip` Minifies a zip file by minifying file names and references in the zip.
  * `site_zip` The site zip to minify.
  * `root_files` The root files that will be directly accessed by customers and should not be renamed.
  * `minified_zip` The minified zip file to generate.
* `rename_zip_paths` Renames entries in the zip. This is useful as all generated files will have a path in the bazel-out directory
  * `source_zip` The source zip to renmae entries of.
  * `path_map_labels_in` A list of labels for the entries in `source_zip` to rename.
  * `path_map_labels_out` A list of new names for the entries specified by `path_map_labels_in`. The entries in this list map directly to the entries in `path_map_labels_in` with the same index.
  * `out_zip` The zip file to generate.
* `zip_server` Runs a localhost server that serves a zip file. This is not a secure implementation and should only be used for testing.
  * `zip` The zip file to server.
  * `port` The port to listen on. Defaults to `80`.

### Currently broken
`//deploy:deploy.bzl`
* `deploy_site_zip_s3_script`
  * `aws_access_key` The AWS access key string to use
  * `aws_secret_key` The AWS secret access key string to use
  * `bucket` The AWS bucket to upload to
  * `zip_file` A zip file whose contents should be uploaded

`//images:images.bzl`
* `generate_ico` Generates an ICO image file by resizing a source to multiple sizes
  * `source` The source image to resize
  * `sizes` A list of sizes to resize the `source` image to
  * `allow_upsizing` An optional boolean of whether the build should not fail if one of the generated sizes is larger than the source image. Defaults to `False`.
