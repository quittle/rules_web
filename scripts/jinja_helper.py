# Copyright (c) 2016 Dustin Doloff
# Licensed under Apache License v2.0

import jinja2
import os

MESSAGE_FILL = '`'
AUTO_GEN_MESSAGE = """
``````````````````````````````````````````````````````
``````````````````````````````````````````````````````
````````______________________________________  ``````
```````/                                     /\  `````
``````/                                     /..\  ````
`````/  AUTO-GENERATED FILE. DO NOT EDIT   /....\  ```
````/                                     /______\  ``
```/_____________________________________/````````````
``````````````````````````````````````````````````````
``````````````````````````````````````````````````````
"""

def reverse(v):
    """
        Reverses any iterable value
    """
    return v[::-1]

def auto_gen_message(open, fill, close):
    """
        Produces the auto-generated warning header with language-spcific syntax
        open - str - The language-specific opening of the comment
        fill - str - The values to fill the background with
        close - str - The language-specific closing of the comment
    """
    assert open or fill or close

    message = AUTO_GEN_MESSAGE.strip()
    if open:
        message = message.replace(MESSAGE_FILL * len(open), open, 1)
    if close:
        message = reverse(reverse(message).replace(MESSAGE_FILL * len(close), close[::-1], 1))
    if fill:
        message = message.replace(MESSAGE_FILL * len(fill), fill)
    return message

def generate(template, config, out_file, pretty=False):
    path, ext = os.path.splitext(out_file.name)
    ext = ext[1:]

    if pretty:
        if ext == 'py':
            out_file.write(auto_gen_message('#', '#', ''))
        elif ext == 'html':
            out_file.write(auto_gen_message('<!--', '-', '-->'))

    template_path, template_filename = os.path.split(template)
    env = jinja2.Environment(loader = jinja2.FileSystemLoader([template_path]))
    template = env.get_template(template_filename)
    template.stream(config).dump(out_file)

    # There needs to be an extra line at the end to make it a valid text file. Jinja strips trailing
    # whitespace
    if pretty:
        out_file.write(os.linesep)
