---
title: "Conference Talk Ideas"
---

In the future I would like to give presentations at software conferences. Here
are few topic ideas:

## Neat Tricks When Building .NET Pipelines

Command line tools such as git and dotnet are terrific assets for building and
publishing your applications. We will investigate how they can be used in
different situations:

- Using git commands such as `git rev-parse` or `git clean` to improve a build
  pipeline
- The versatility of `dotnet publish`
  - Single binary, ahead-of-time compilation or self-contained builds
  - Add commit ID information
- Utility dotnet sub-commands such as `dotnet format` or `dotnet list package
  --outdated`
- Derive version information from a `CHANGELOG.md` file, automate release
  commits and tagging

## Having a Hobby Project

In the last few years I built [Chunkyard][chunkyard], a backup tool which
combines full and incremental backups while also including features such as
copying and validating backups. Chunkyard does not offer much that other open
source backups tool provide, but it gave me several opportunities to explore
topics such as:

- How "modern" backup applications work
- Use .NET on Windows and Linux
- Testing new language features
- Limit myself to the standard library
- Create a useful and fast testing suite
- Tinker with build and publish automation

[chunkyard]: https://github.com/fwinkelbauer/chunkyard/

## Content Addressable Storage + Content Defined Chunking

Modern backup tools use techniques such as content addressable storage and
content defined chunking to create deduplicated and verifiable backups. We will
explore how these techniques work and how they could be applied to other areas
such as:

- Version control systems
- Application downloader/updater
- Artifact storage for build pipelines
- Verifiable URLs

## Teaching an Old ~~Dog~~ Monolith New Tricks

Its 2023 but some of us are still doing manual deployments to ship software.
Let's have a look at a concrete example of a distributed monolith and what we
can do to automate its deployment:

- Implement a "deployment configuration" using a templating language, reusable
  configuration files and scripts
- Generate a "deployment configuration" using different criteria
- Use a package manager like [Chocolatey][chocolatey] (Windows)

[chocolatey]: https://chocolatey.org/
