---
title: "Notes on Building Chunkyard"
date: 2020-03-13
---

Based on my previous blog post I have started a new C# project called
[Chunkyard][chunkyard] where I can play with concepts such as content
addressable storage and content defined chunking. This project is highly
experimental and my goal is to implement a backup application with a limited set
of features. Chunkyard gathers files in a given directory and stores a
deduplicated and encrypted snapshot. In this post I'd like to highlight a few
topics that came up while figuring out how to implement Chunkyard.

## Encryption

To encrypt a piece of data, algorithms such as AES need a key and an
initialization vector (IV). While the key must be kept private, we need to store
the IV as part of our meta data in order the decrypt our data.
Storing an initial piece of data (a file) is easy:

- Create an IV
- Split the file into chunks
- Encrypt each chunk using the key/IV pair
- Calculate the hash of all chunks and store them using the hash information

Storing an existing file becomes more interesting. In order to gain any
deduplication effect (which is the primary reason why we would use content
defined chunking in the first place) we need to check if a given file has been
stored before, so that we can re-use its IV. Re-using an IV reduces the strength
of our encryption algorithm, so we cannot simply use a single IV for all our
files. Chunkyard creates IVs based on the relative file name, which limits the
re-usage on a file based level.

## Compression

The data ingestion process can be seen as a pipeline. We throw in a file and we
get out chunks which are encrypted and compressed. The specific order of these
steps (chunking, encrypting and compressing) matters. Compressing already
encrypted data is rather pointless, as we end up with a bunch of data which is
potentially even larger than the input file.

Compression would get the most gain when performed on the initial file, but we
might not want to hold large files in memory. We could instead compress every
chunk, but this would only be feasible for "larger chunks". The "correct"
strategy depends on the given data.

## Language Split

I am using the FastCDC algorithm to perform the actual chunking. I could not
find any C# library which implements this algorithm (or any other chunking
algorithm in general), which is why I need to rely on a Rust binary. The
"chunker" binary takes a file path and some chunk size parameters and outputs
the cut points to create our chunks. The biggest disadvantage of this approach
is that I need a file in order for the "chunker" binary to work. This leaves me
with a few sub optimal choices:

- Perform all chunking as the first step of the ingestion process
- Do not perform chunking on C# in-memory data which should be persisted
- Write temporary files

Right now I am relying on a combination of the first two strategies.

## Open Questions

- How can we support "branches" so that we can still benefit from encryption and
  deduplication?
- How can we delete old snapshots in an efficient and safe manner?

[chunkyard]: https://github.com/fwinkelbauer/chunkyard
