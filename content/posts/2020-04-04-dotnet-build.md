---
title: "Dotnet Build Tools"
date: 2020-04-04
---

In the last five years, the dotnet build environment has grown so much. When I
started as a C# developer a few years ago, all my builds were done by hand.
Deploying an artifact meant to manually copy it onto the target machine. Since
then I have improved my process step by step.

## Abusing the Pre/Post Build Snippets

A `csproj` file can contain pre- and post-build snippets. I have used this
feature to create an automated deployment when switching the build configuration
from "Debug" to "Release". While this solution worked, I never felt at easy, as
I could run these snippets on accident when testing something in Visual Studio.

## Custom MSBuild Scripts

MSBuild is a fully fledged build tool, which supports custom actions and even
comes with predefined commands to do various operations such as copying or
archiving files. The major downside is that MSBuild scripts, similar to Ant
scripts, are written in XML. While they work pretty fine, maintaining these
scripts is a pain.

## Psake

Several languages come with their own version of `make`. Psake is a build system
written in PowerShell. We still need to call MSBuild to compile a C# solution,
but we can leverage a pretty good shell to perform other tasks such as running a
linter, or archiving artifacts.

## Cake

Back when I found psake, the project did not have an active maintainer, which
meant that at one point I could not use it with newer versions of MSBuild and
Visual Studio. This lead me to Cake. Cake comes with a decent set of features
and can get even better with all the available addins which extend the feature
set even more. I even built my own addin for a version bumping CLI tool I used
to develop. While the development was rather straightforward, I started to ask
myself why if I am over-complicating things and why I don't just leverage CLI
tools without any wrapper code.

## Back to Psake

While switching most of my projects over from .NET Framework to .NET Core, I was
surprised how terrific the `dotnet` CLI is. Instead of downloading `nuget.exe`
to restore dependencies I can run `dotnet restore`. Instead of finding MSBuild
(which depends on your version and edition of Visual Studio) to compile my code,
I can run `dotnet build`. The CLI is the major reason why I switched back to
psake.

A "typical" build script for my projects will now perform these tasks:

- Run C# and PowerShell linters
- Clean, restore and build the C# solution
- Use `dotnet publish` to create binaries in a separate artifacts directory
- Run unit, integration or end-to-end tests
- Create and push Chocolatey packages
