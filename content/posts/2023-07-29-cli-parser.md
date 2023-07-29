---
title: "Writing a CLI Parser"
date: 2023-07-29
---

C# offers a wide range of command line interface (CLI) parsers as NuGet
packages. The package [commandlineparser][commandlineparser] has sparked joy for
a long time, but recently I've been looking for something different. I could
have tried one of several other CLI parsers (such as the prerelease package
[System.Commandline][microsoft]), but in the end I decided to write my own. Just
for fun. [Chunkyard][chunkyard] only had one package dependency left anyway, so
why not decrement that number once more?

The starting point for this little side-project came after I read the first half
of [Crafting Interpreters][crafting] by Robert Nystrom. It gave me the courage
to tinker with my own implementation. In the end I wrote just enough code to
handle the use cases that I actually need.

## Example

One of Chunkyard's command is `store`, which is used to create a snapshot/backup
of a set of directories and/or files:

``` shell
# Create a backup of a single directory
chunkyard store --repository ~/Chunkyard --paths ~/Music

# Create a backup of multiple directories
chunkyard store --repository ~/Chunkyard --paths ~/Music ~/Videos

# Show what Chunkyard would do without any action
chunkyard store --repository ~/Chunkyard --paths ~/Music ~/Videos --preview
```

## Overview

Chunkyard's new parser works like this:

- Take a set of arguments (`string[] args`) and transform them into a semi
  structured representation described by the `Args` class
- Try to find a command parser based on `Args`
- Transform `Args` into another type which encapsulates a particular command
- Call a command handler based on the given type

The simplified definition of the `store` command example above looks like this:

``` csharp
public sealed class StoreCommand
{
    public StoreCommand(
        string repository,
        IReadOnlyCollection<string> paths,
        bool preview)
    {
        Repository = repository;
        Paths = paths;
        Preview = preview;
    }

    public string Repository { get; }

    public IEnumerable<string> Paths { get; }

    public bool Preview { get; }
}
```

## Language Specification

Command line tools come with all sorts of different input methods, ranging from
positional arguments, commands (also called verbs), flags to arguments or
pipeline operations. To make things easier I decided to limit the "language
specification" as much as possible. All Chunkyard commands follow this shape:

``` shell
# Command with a boolean flag
chunkyard some-command --flag

# Command with a list flag
chunkard some-command --flag element1 element2

# Command with several flags
chunkard some-command --flag1 --flag2 some-value --flag3 another-value and-another-value
```

This simplification means that we can represent a list of arguments as a
structure consisting of a command name and a dictionary (map) of flags:

``` csharp
public sealed class Arg
{
    public Arg(
        string command,
        IReadOnlyDictionary<string, IReadOnlyCollection<string>> flags)
    {
        Command = command;
        Flags = flags;
    }

    public string Command { get; }

    public IReadOnlyDictionary<string, IReadOnlyCollection<string>> Flags { get; }
}
```

`Args` represents semi-structured data. At this point we don't know if the
command a user wants to invoke is actually available or if all its parameters
are satisfied. We only know that the user input is valid according to the
language specification.

## Dispatching

Our next step is to use `Args` to find a specific parser. In our example above
we would want to use a `StoreCommandParser`. I am using a small interface to
define all command parsers:

``` csharp
public interface ICommandParser
{
    string Command { get; }

    string Info { get; }

    object Parse(FlagConsumer consumer);
}
```

`FlagConsumer` is a helper class which contains `Args`. We will talk more about
it in the following section.

The "main parser" has this structure:

``` csharp
public sealed class CommandParser
{
    private readonly IReadOnlyCollection<ICommandParser> _parsers;

    public CommandParser(params ICommandParser[] parsers)
    {
        _parsers = parsers;
    }

    public object Parse(params string[] args)
    {
        // - Turn args into an instance of Args
        // - Find a matching ICommandParser
        // - Put Args in an instance of FlagConsumer
        // - Pass FlagConsumer to an ICommandParser
        // - Return the output of ICommandParser
    }
}
```

This looks easy and neat, but things usually turn messy when we incorporate
error handling. Let's take a look at a few error examples:

- Arguments do not follow the language specification
- A user wants to call the command `foo` which does not exist
- The `store` command is missing required flags
- A command is called with unrecognized/unknown flags

In case of an error our CLI tool can provide two ways to help:

- Inform a user which commands are available
- Give specific information about a single command, including its flags and
  default values

The cool thing is that we can solve all these issues with another command that
we will call `HelpCommand`. A `HelpCommand` encapsulates all errors as well as
general or specific command information.

## Parsing

I mentioned in the last section that every command has its own `ICommandParser`.
Naturally we want to write as little code as possible in each parser. This is
where the `FlagConsumer` class comes into play. It keeps track of which flags
have been consumed/parsed, handles type conversion and also keeps track of all
errors that occurred. A parser for the above `StoreCommand` could look like
this:

``` csharp
public sealed class StoreCommandParser : ICommandParser
{
    public string Command => "store";

    public string Info => "Store a new snapshot";

    public object Parse(FlagConsumer consumer)
    {
        if (consumer.consumer.TryString("--repository", "The repository path", out repository)
            & consumer.TryStrings("--paths", "The files and directories to store", out var paths)
            & consumer.TryBool("--preview", "Show only a preview", out var preview))
        {
            return new StoreCommand(repository, paths, preview);
        }
        else
        {
            return consumer.Help;
        }
    }
}
```

There are few things to note in the above snippet:

- A parser contains all usage information
- We are using `out` variables to capture parsed flags. A lot of developers
  don't like the `TryX` pattern, but I think it's really handy in a situation
  like this. Functional languages solve these kinds of problems using a
  technique called [applicative functors][ploeh]
- The usage of `&` instead of `&&` allows `FlagConsumer` to collect more than a
  single error message
- Our parser returns a `HelpCommand` provided by `FlagConsumer` in case the
  parsing operation fails

## Handling

The final part of this side-project is to perform the intend behind a command.
In the beginning I wanted to solve this problem using a visitor pattern, but
since I wanted the parsing code to be reusable between projects, I was not able
pull this off. Instead I have settled on the following snippet:

``` csharp
public static class CommandHandler
{
    public static void Store(StoreCommand c)
    {
        // ...
    }

    public static void Help(HelpCommand c)
    {
        // ...
    }
}

public static class Program
{
    public static void Main(string[] args)
    {
        var parser = new CommandParser(
            new StoreCommandParser());

        var command = parser.Parse(args);

        Handle<StoreCommand>(command, CommandHandler.Store);
        Handle<HelpCommand>(command, CommandHandler.Help);
    }

    private static void Handle<T>(object obj, Action<T> handler)
    {
        if (obj is T t)
        {
            handler(t);
        }
    }
}
```

## Conclusion

And we are done! While my own implementation is not as neat or feature rich as
other solutions, I am happy with what I have created. A CLI parser is a much
easier problem than writing a parser for your own language, but it still gave me
plenty opportunities to experiment and learn.

You can find the full implementation of the Chunkard.Cli namespace (and its test
cases) [here][chunkyard-cli].

[crafting]: https://craftinginterpreters.com
[chunkyard]: https://github.com/fwinkelbauer/chunkyard
[commandlineparser]: https://github.com/commandlineparser/commandline
[microsoft]: https://github.com/dotnet/command-line-api
[ploeh]: https://blog.ploeh.dk/2018/11/05/applicative-validation/
[chunkyard-cli]: https://github.com/fwinkelbauer/chunkyard/tree/0a797d6b3e1705c087b6cba05f7d2337c15b1af8/src/Chunkyard.Cli
