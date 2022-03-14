---
title: "Having A Hobby Project"
date: 2022-03-13
---

It has been two years since I have started to work on my hobby project
[Chunkyard][chunkyard]. Over these years I have used this project to test out
different ideas and concepts, which is something that you cannot always do in a
professional environment. This post highlights a few topics which I have
explored.

## Ambitions

My initial plans were to create some sort of general purpose library (hah!) that
I could use to implement different types of applications such as a version
control system, a backup tool or some sort of application installer/updater. But
reality is messy and so I had to abandon those plans rather quickly. Creating a
content-addressable storage with or without encryption comes with its own set of
pitfalls, which makes it hard to come up with a general solution. So instead of
a library I settled for the application that I wanted to build.

## Tests

A backup tool must be reliable. You don't want to end up in a situation where a
bug breaks your data. All my backups are done using Chunkyard, so preventing
mistakes is something that is important to me in more than one way. While I
cannot ensure that the code base is free of bugs, I have come up with a testing
suite that gives me enough confidence to explore ideas or implement features.

## Design

Since I do not have any "real" users (besides myself), I can test out all sorts
of designs without having to consider backwards compatibility. Re-reading older
posts such as [Chunkyard Explained][explained] makes me laugh, because the
serialized data format has changed more than once since I have written that
post.

Chunkyard was the first project in which I have developed a makefile-style build
tool in C#. Some of my work colleagues liked the idea and we ported the concept
to one our own projects.

## Performance

I have no deep understanding of how a computer actually works. Don't get me
wrong, Chunkyard is not slow, but listening to people such as Martin Thompson
makes you wonder how much resources you are wasting for non-essential work. His
conference talks motivated me to write a lock-free ring buffer which is still an
experimental feature for creating backups. Measuring is not always easy since
antivirus software, the actual hardware and some OS-internal caching magic makes
it hard to get meaningful data.

## Future Work

- Figure out how to use [FsCheck][fscheck]
- Learn to utilize a profiler to find bottlenecks
- Try to replace [commandlineparser][parser] with [System.CommandLine][system]

[chunkyard]: https://github.com/fwinkelbauer/chunkyard
[explained]: {{< ref "2020-10-03-chunkyard-explained.md" >}}
[fscheck]: https://fscheck.github.io/FsCheck/
[parser]: https://github.com/commandlineparser/commandline
[system]: https://github.com/dotnet/command-line-api
