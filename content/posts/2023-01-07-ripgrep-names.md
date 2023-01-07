---
title: "Search File Names using ripgrep"
date: 2023-01-07
---

The other day I was wondering if I could use [ripgrep][rg] to do a combined
search of file names and their content. While this feature does not come out of
the box, it turns out that one can implement it in a straightforward way.
Ripgrep comes with a `--files` flag which lists all files that a search
operation would consider (Remember: ripgrep can decide to skip files based on
some criteria, e.g. if a file is listed in a `.gitignore` file). Since the
output of `--files` is text based, we can use a pipe to also search through
those lines as well. A bash script could look like this:

``` shell
rg --files | rg "$1"
rg "$1"
```

Other command line tools such as `find` or [fd][fd] might be better suited to
search for file names, but the above approach has a convenience aspect, since we
can use the same search expression for two different searches. Thanks Andrew for
coming up with such an awesome tool!

[rg]: https://github.com/BurntSushi/ripgrep
[fd]: https://github.com/sharkdp/fd
