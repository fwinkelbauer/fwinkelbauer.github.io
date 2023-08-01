---
title: "Conference Talk Ideas"
---

In the future I would like to give presentations at software conferences. Here
are few topic ideas:

## Using dotnet and git in a build system

Command line tools such as git and dotnet are terrific assets for building and
publishing your applications. We will investigate how they can be used in
different situations:

- Using git commands such as rev-parse or clean to improve a build pipeline
- The versatility of dotnet publish
- Utility dotnet sub-commands such as format or list package
- Derive version information from a CHANGELOG and automate release commits

## Build Tools in .NET

Most programming languages come with their own build system. C# ships with
MSBuild, but the community built several other projects on top of it. Nowadays
we can choose between Fake, Cake, Psake or Nuke. This talk gives an overview
over all these systems.

## Content Addressable Storage + Content Defined Chunking

Modern backup tools use techniques such as content addressable storage and
content defined chunking to create deduplicated and verifiable backups. What are
these techniques, how do they work and how can they be applied in other
applications such as:

- Application downloader or updater
- Artifact storage
- URLs

## Teaching an Old ~~Dog~~ Monolith New Tricks

Its 2023 but some of us are still doing manual deployments to ship software.
Let's have a look at a concrete example of a distributed monolith and what we
can do to automate its deployment:

- Implement a "deployment configuration" using a templating language, reusable
  configuration files and scripts
- Generate a "deployment configuration" using different criteria
- Use a package manager like Chocolatey (Windows)
