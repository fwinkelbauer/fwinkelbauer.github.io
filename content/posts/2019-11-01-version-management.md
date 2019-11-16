---
title: "Dealing with Version Information"
date: 2019-11-01
---

About two years ago I was using a tool called [zero29][zero29] to update
`AssemblyInfo.cs` files in my C# projects. The author Mark Seemann (who's talks
I can highly recommend) declined my request to add [support for .nuspec
files][issue]. His point was, that zero29 is a tool to manage `AssemblyInfo.cs`
files and that's all it should ever do. While I am a big proponent of the Unix
philosophy, I wished that zero29 would act as a tool to manage version
information across all kinds of files. This would (in my opinion) still be in
line with the Unix philosophy, as there are tools such as awk, grep or sed which
do "one thing", but that "one thing" is defined in a generalized context. So I
jumped down the rabbit hole and built [Bumpy][bumpy].

I had a lot of fun writing Bumpy. I took the time to "make it right", so I wrote
several unit tests, created a fully automated build process and I even took the
time to write some form of documentation, as well as an [addin][addin] (an
extension) for the C# build tool [Cake][cake]. Inspired by
[editorconfig's][editorconfig] configuration I was trying to create a config
file in which I could define where to find version information in different
files. I kept observing the download statistics on [NuGet.org][nuget] as well as
[Chocolatey.org][chocolatey] daily and I was really hyped when I received my
[very first pull request][pr].

The latest commit on the Bumpy project was in June 2018. I realized that while I
was trying to build the project right, I was in reality not building the right
project. A core concept of Bumpy was to understand different version schemas and
some people even suggested that I should detect versions that are scattered
among [several lines of text][request]. In the end, I decided that a different
approach seemed simpler and more flexible: Why not build a "search and replace
text" tool? So I wrote a prototype in Python, because its `.ini` library comes
with a ton of interesting features. You can still find the initial code and a
few examples [here][niles]. This first version of "niles" used two config files
to describe where to find text snippets and to describe the desired content for
these snippets. After a while, I found it cumbersome to manage two files, so I
redesigned the tool, while also adding more commands. Here's the final script
together which a short example:

**hello.txt:**

``` text
Hello! My name is Florian. How are you?
```

**name.txt:**

``` text
My name is Florian.
```

**niles.ini:**

``` ini
# Python's .ini library comes with a ton of features such as referencing
# values or defined default values for other sections

[DEFAULT]
# Optional parameters. If not set, niles will use the default encoding and
# line ending defined by the operating system
_charset = utf-8
_end_of_line = crlf

[**/{hello,name}.txt]
_regex = My name is (?P<name>[A-za-z]+(\s[A-za-z]+)?)
first_name = Max
second_name = Mustermann
name = %(first_name)s %(second_name)s
```

Niles offers these commands:

- **files:** To show all files which match the defined glob patterns
- **values:** To list all values which are grabbed through the regular expressions
- **apply:** To replace all declared values

Running `niles apply`would create:

``` text
Hello! My name is Max Mustermann. How are you?
```

and

``` text
My name is Max Mustermann.
```

Here's a final example of a config file which can be used to manage versions in
C# projects:

**niles.ini (C#):**

``` ini
[DEFAULT]
major = 5
minor = 10
patch = 0

[**/AssemblyInfo.cs]
_regex = ^\[assembly: Assembly(File)?Version\("(?P<assembly_version>.+)"\)\]$
assembly_version = %(major)s.%(minor)s.%(patch)s.0

[**/*.nuspec]
_regex = ^\s*<version>(?P<semantic_version>.+)<\/version>$
semantic_version = %(major)s.%(minor)s.%(patch)s
```

So, is this the "right" approach? To be honest, I'm not sure. At the moment I
like the simplicity of a search and replace tool compared to a elaborate tool
which can perform specific operations on versions.

**niles.py:**

``` python
#!/usr/bin/env python3

import argparse
import collections
import configparser
import glob
import re


class Config(collections.namedtuple(
        'Config', 'file_names charset end_of_line regex_list values')):
    __slots__ = ()


def expand_curly(line):
    match = re.search('{([^{]*?)}', line)
    expanded_lines = []
    if match is None:
        expanded_lines.append(line)
    else:
        snippets = match.group(1).split(',')
        for snippet in snippets:
            expanded_lines.append(
                line[:match.start()] + snippet + line[match.end():])
    return expanded_lines


def fetch_files(glob_pattern):
    expanded_patterns = expand_curly(glob_pattern)
    file_names = []
    [file_names.extend(
        glob.glob(p, recursive=True)) for p in expanded_patterns]
    return file_names


def parse_config(text):
    config_parser = configparser.ConfigParser()
    config_parser.read_string(text)
    config_list = []
    for section in config_parser.sections():
        file_names = fetch_files(section)
        section_data = config_parser[section]
        charset = section_data.get('_charset')
        end_of_line_text = section_data.get('_end_of_line')
        if end_of_line_text is None:
            end_of_line = None
        elif end_of_line_text == 'lf':
            end_of_line = '\n'
        elif end_of_line_text == 'crlf':
            end_of_line = '\r\n'
        else:
            raise ValueError(
                "Supported end of line characters: 'lf' and 'crlf'")
        regex_list_text = section_data.get('_regex', '').splitlines()
        regex_list = [re.compile(r) for r in regex_list_text]
        config_list.append(Config(file_names, charset, end_of_line,
                                  regex_list, dict(config_parser[section])))
    return tuple(config_list)


def load_config():
    with open('niles.ini', 'r') as f:
        return parse_config(f.read())


def read_file_lines(file_name, charset, end_of_line):
    with open(file_name, 'r', encoding=charset, newline=end_of_line) as f:
        return f.read().splitlines()


def write_file_lines(file_name, lines, charset, end_of_line):
    with open(file_name, 'w', encoding=charset, newline=end_of_line) as f:
        for line in lines:
            f.write(line + '\n')


def replace_line(regex, line, values):
    match = regex.search(line)
    replaced_line = line
    line_changed = False
    offset = 0
    if match is not None:
        group_dict = match.groupdict()
        for group_name in group_dict.keys():
            if group_name in values:
                old_value_len = len(match.group(group_name))
                new_value = values[group_name]
                start_index = offset + match.start(group_name)
                end_index = start_index + old_value_len
                start = replaced_line[:start_index]
                end = replaced_line[end_index:]
                replaced_line = start + new_value + end
                line_changed = line != replaced_line
                offset += len(new_value) - old_value_len
    return line_changed, replaced_line


def list_values(config, read_file, log):
    for entry in config:
        for file_name in entry.file_names:
            for line in read_file(file_name, entry.charset, entry.end_of_line):
                for regex in entry.regex_list:
                    match = regex.search(line)
                    if match is not None:
                        for group_name in match.groupdict().keys():
                            log("{}: {}".format(
                                file_name, match.group(group_name)))


def apply_changes(config, read_file, write_file, log):
    for entry in config:
        for file_name in entry.file_names:
            new_lines = []
            file_dirty = False
            for line in read_file(file_name, entry.charset, entry.end_of_line):
                new_line = line
                for regex in entry.regex_list:
                    line_changed, new_line = replace_line(
                        regex, new_line, entry.values)
                    file_dirty |= line_changed
                new_lines.append(new_line)
            if file_dirty:
                write_file(
                    file_name, new_lines, entry.charset, entry.end_of_line)
                print("Wrote file '{}'".format(file_name))
            else:
                print("Skipped file '{}'".format(file_name))


def list_files(config, log):
    for entry in config:
        for file_name in entry.file_names:
            log(file_name)


def list_values_cmd():
    list_values(load_config(), read_file_lines, print)


def apply_changes_cmd():
    apply_changes(load_config(), read_file_lines, write_file_lines, print)


def list_files_cmd():
    list_files(load_config(), print)


def main():
    arg_parser = argparse.ArgumentParser(
        description='Search and replace text in files')
    subparsers = arg_parser.add_subparsers()
    values_parser = subparsers.add_parser('values', help='List all values')
    values_parser.set_defaults(func=list_values_cmd)
    apply_parser = subparsers.add_parser('apply', help='Writes values to files')
    apply_parser.set_defaults(func=apply_changes_cmd)
    files_parser = subparsers.add_parser('files', help='List all files')
    files_parser.set_defaults(func=list_files_cmd)
    args = arg_parser.parse_args()
    if hasattr(args, 'func'):
        args.func()
    else:
        arg_parser.print_help()


if __name__ == '__main__':
    main()
```

[bumpy]: https://github.com/fwinkelbauer/Bumpy
[zero29]: https://github.com/ploeh/ZeroToNine
[issue]: https://github.com/ploeh/ZeroToNine/issues/24
[cake]: https://cakebuild.net/
[addin]: https://github.com/cake-contrib/Cake.Bumpy/
[editorconfig]: https://editorconfig.org/
[nuget]: https://www.nuget.org/packages/Bumpy/
[chocolatey]: https://chocolatey.org/packages/bumpy.portable
[pr]: https://github.com/fwinkelbauer/Bumpy/pull/25
[request]: https://github.com/cake-contrib/Cake.Bumpy/issues/7
[niles]: https://github.com/fwinkelbauer/python_tools/tree/296c9aad5e2a7ae6069ac48b0ad2c503b66613b6/niles
