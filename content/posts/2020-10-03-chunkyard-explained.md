---
title: "Chunkyard Explained"
date: 2020-10-03
---

Since my last [blog post][project-intro] about [Chunkyard][chunkyard] the
project has reached v1.1.1. Chunkyard is now a single .NET project and does no
longer rely on components written in other languages. I also took the time to
write down what the project should and should not do in the README file.

I believe that the overall internal data structure is stable, so I'd like to
take the time to document how a file is stored.

## Creating The Repository

So let's imagine that we want to store a snapshot of the `hello-world.txt` file
using the command:

``` shell
chunkyard create -r ~/chunkyard-repository -f ~/Documents/hello-world.txt
```

After the initial password prompt Chunkyard will perform the following
operations:

- The file `hello-world.txt` is read and split it into pieces (chunks) using the
  [FastCdc][fastcdc] algorithm. Since text files tend to be rather small, we'll
  most likely end up with a single chunk
- Each chunk will be AES (Galois/Counter Mode) encrypted using a 256 bit key
  which is derived from the password. **Note:** These choices are based on this
  [NDC Conference talk][ndc-talk] by Stephen Haunts
- Every encrypted chunk will be stored in a content addressable storage using
  its SHA256 hash value

In order the reconstruct the `hello-world.txt` file, we need to keep track of
several pieces of data:

- Parameters to reproduce the 256 bit key
- The file name
- The address of every file chunk in the storage system
- The AES GCM tag and the cryptographic nonce to decrypt the file chunks

Here's an overview of the file structure of the `~/chunkyard-repository`
directory:

``` text
chunkyard-repository/
  content/
    sha256/
      11/
        116d11f1a1a7301a720848382893cb931e781f31f93eeae3cbb88106b3d88ba5
      58/
        58c767a0b5c211fd26d2869ea36691b98270b7db5f22038d9c902ecdc8a818d8
  reflog/
      0.json
```

The file `116d11f1a1a7301a720848382893cb931e781f31f93eeae3cbb88106b3d88ba5`
contains our encrypted `hello-world.txt` file.

All the information to reconstruct a snapshot of `hello-world.txt` is also
stored as an encrypted chunk. Here's how the snapshot file
`58c767a0b5c211fd26d2869ea36691b98270b7db5f22038d9c902ecdc8a818d8` looks like
when it is decrypted:

``` json
{
  "CreationTime": "2020-10-03T13:05:45.5405235+02:00",
  "ContentReferences": [
    {
      "Name": "hello-world.txt",
      "Nonce": "rqesO2bAdlHs/3de",
      "Chunks": [
        {
          "ContentUri": "sha256://116d11f1a1a7301a720848382893cb931e781f31f93eeae3cbb88106b3d88ba5",
          "Tag": "d17sWwQ6DXtw7n9ud2NX/g=="
        }
      ]
    }
  ]
}
```

In this example the snapshot contains a single file which consists of a single
chunk (`116d11f1a1a7301a720848382893cb931e781f31f93eeae3cbb88106b3d88ba5`).

Finally `0.json` contains a reference to the above snapshot as well as the salt
and hashing iterations parameters needed to create our cryptographic key:

``` json
{
  "LogId": "5411e7c2-315e-4b48-9345-e2ddfc44c0ad",
  "ContentReference": {
    "Name": ".chunkyard-snapshot",
    "Nonce": "WOjfK9yWujps+w1+",
    "Chunks": [
      {
        "ContentUri": "sha256://58c767a0b5c211fd26d2869ea36691b98270b7db5f22038d9c902ecdc8a818d8",
        "Tag": "C/YhL/z9Q/rUtR1hVOv5fw=="
      }
    ]
  },
  "Salt": "GsKFv9f5GcrEn12U",
  "Iterations": 1000
}
```

## Create A New Backup

Let's change the content of our `hello-world.txt` example and re-run the
`create` command. Here's what happened to the `~/chunkyard-repository` directory:

``` text
chunkyard-repository/
  content/
    sha256/
      11/
        116d11f1a1a7301a720848382893cb931e781f31f93eeae3cbb88106b3d88ba5
      30/
        30a54e8cda4e6cc66a92eb93e28d8b9ca646c71b7d9414c120d6ebb7e34dea2f
      58/
        58c767a0b5c211fd26d2869ea36691b98270b7db5f22038d9c902ecdc8a818d8
      5b/
        5b9d6713a8cba3ecaa8b68fa71a11a2dab88ec266bbb42660fb3a1dbfb34b401
  reflog/
    0.json
    1.json
```

Chunkyard did not change any existing file, instead it created new ones. These
new JSON structures look like this:

The snapshot:

``` json
{
  "CreationTime": "2020-10-03T13:16:39.1510417+02:00",
  "ContentReferences": [
    {
      "Name": "hello-world.txt",
      "Nonce": "rqesO2bAdlHs/3de",
      "Chunks": [
        {
          "ContentUri": "sha256://5b9d6713a8cba3ecaa8b68fa71a11a2dab88ec266bbb42660fb3a1dbfb34b401",
          "Tag": "AhAY/F2rAjjFosaFnElhtw=="
        }
      ]
    }
  ]
}
```

And the `1.json` file:

``` json
{
  "LogId": "5411e7c2-315e-4b48-9345-e2ddfc44c0ad",
  "ContentReference": {
    "Name": ".chunkyard-snapshot",
    "Nonce": "3sJtajbLoV6PZAWx",
    "Chunks": [
      {
        "ContentUri": "sha256://30a54e8cda4e6cc66a92eb93e28d8b9ca646c71b7d9414c120d6ebb7e34dea2f",
        "Tag": "hAQVhHsH7V14U/bwufvMww=="
      }
    ]
  },
  "Salt": "GsKFv9f5GcrEn12U",
  "Iterations": 1000
}
```

## Restoring Files

Finally, let's walk through the performed operations when we are restoring a
snapshot using:

``` shell
chunkyard restore -r ~/chunkyard-repository -d ~/chunkyard-restored
```

- Prompt the user for a password
- Read the unencrypted JSON file found in the `reflog` directory. In our example
  this would be `1.json`
- Create the cryptographic key based on the password, salt and iteration parameters
- Decrypt and reconstruct the snapshot based on the information found in
  `1.json`
- Decrypt and reconstruct every file in the snapshot

## Closing Thoughts

Chunkyard is by far not as sophisticated as other modern backup tools, but
building the project helped me to learn more about encryption, chunking and
content addressable storages. I would not recommend anyone to use or rely on
Chunkyard, but to rather use it as an opportunity to get a basic understanding
of how these other tools work.

[project-intro]: {{< ref "2020-03-13-building-chunkyard.md" >}}
[chunkyard]: https://github.com/fwinkelbauer/chunkyard
[fastcdc]: https://www.usenix.org/system/files/conference/atc16/atc16-paper-xia.pdf
[ndc-talk]: https://www.youtube.com/watch?v=mY4ifhgpbf8
