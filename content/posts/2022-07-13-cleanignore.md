---
title: "Using a .cleanignore File"
date: 2022-07-13
---

Git offers a wide range of useful command line verbs besides the "usual"
suspects such as `add`, `commit` or `push`/`pull`. One of them is
[git clean][git-clean], which can be used to delete untracked files in a
repository. This is useful when you are trying to delete generated files, but
can be annoying if your repository contains user specific files which are not in
version control. Visual Studio creates directories such as `.vs`, or files like
`*.user` and `launchSettings.json` which contain IDE configuration which are
only relevant for a specific user. You can exclude these files from `git clean`
using the `-x -e <expression>` option:

``` shell
git clean -dfx -e .vs/ -e *.user -e launchSettings.json
```

These expressions looked similar to the content of a `.gitignore` file to me, so
I added a function to my [C# build tool][build-csharp] which feeds the content
of a `.cleanignore` file into `git clean`:

``` text
# My .cleanignore file
.vs/
*.user
launchSettings.json
```

``` c#
public static void Clean()
{
    var expressions = File.ReadLines(".cleanignore")
        .Select(l => l.Trim())
        .Where(l => !string.IsNullOrEmpty(l) && !l.StartsWith("#"))
        .Select(l => $"-e {l}");

    Git(
        "clean -dfx",
        string.Join(' ', expressions));
}

private static void Git(params string[] arguments)
{
    // Run git using Process.Start
}
```

You can find the code [here][chunkyard-commands].

[git-clean]: https://git-scm.com/docs/git-clean
[build-csharp]: {{< ref "2021-10-04-building-csharp.md" >}}
[chunkyard-commands]: https://github.com/fwinkelbauer/chunkyard/blob/8c3c58efabb351296d46e6eab35c611d35a1a3ce/src/Chunkyard.Build/Commands.cs
