---
title: "Building C# using C#"
date: 2021-10-04
---

Having your own [pet project][chunkyard] gives you the great possibility to try
things you would not want to explore in a serious project. One of my latest
experiments made me rethink how I create build scripts (which I have mentioned
before in a [previous blog post][dotnet-build]): What if I would use C# as a
"scripting language" in order to create a build script. Or even better: What if
I could create a CLI tool which deals with all my build tasks? The advantages
are rather nice:

- Using a single languages makes changing the build process as approachable as
  working on the main project itself
- I can use my IDE with all its features (e.g. a debugger)
- A command line interface makes it easy to pass variables into the build
  process
- I can install and use NuGet packages (e.g.
  [commandlineparser][commandlineparser] to create CLIs)

[Here's an example][command] of a class which contains all command line
interface verbs such as `clean`, `build`, or `test`. Most of the methods found
in this class simply call the `git` or the `dotnet` CLI with parameters. You can
run the tool using `dotnet run`:

``` powershell
dotnet run --project MyProject.Build.csproj -- clean -c Debug
dotnet run --project MyProject.Build.csproj -- build -c Debug

dotnet run --project MyProject.Build.csproj -- clean
dotnet run --project MyProject.Build.csproj -- build
```

Using `dotnet run` to run a C# program which in turn calls `dotnet build` to
build some other C# program might be weird in the beginning, but we can use
wrapper scripts in PowerShell or Bash to forget about these messy details.
Here's an example written in PowerShell:

``` powershell
$root = git rev-parse --show-toplevel
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

try {
    Push-Location $root

    $project = git ls-files '*.Build.csproj'
    if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

    dotnet run --project $project -- $args
    if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
}
finally {
    Pop-Location
}
```

This script changes the above `dotnet run` command to something like this:

``` powershell
./csake clean
./csake build
```

You could even copy this script to a place which is in your PATH variable so
that you could call it from anywhere inside your project/repository. This is why
the above script changes the root directory using a call to `git rev-parse`.

Some experiments give you an opportunity to learn. Some may end up nowhere. This
one sparks joy. Well, at least for me.

[chunkyard]: https://github.com/fwinkelbauer/chunkyard
[dotnet-build]: {{< ref "2020-04-04-dotnet-build.md" >}}
[commandlineparser]: https://github.com/commandlineparser/commandline
[command]: https://github.com/fwinkelbauer/chunkyard/blob/3d2b94035931c3852882a2dc00dde3e58e63bbfc/build/Chunkyard.Build/Cli/Commands.cs
