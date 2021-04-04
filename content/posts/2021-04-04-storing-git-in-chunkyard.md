---
title: "Storing Git Repositories Using Chunkyard"
date: 2021-04-04
---

Sometimes you don't want to store a Git repository on a dedicated server. An
easy trick is to use a network drive or a cloud drive (e.g. Dropbox, NextCloud
or others) by using a bare repository:

``` shell
cd ~/SynchronizedFolder
mkdir my-git-project
cd my-git-project
git init --bare
```

Which can than be used like this:

``` shell
cd ~/Projects/my-git-project
git add remote origin ~/SynchronizedFolder/my-git-project
git push --set-upstream origin master
```

I have recently experimented with storing such repositories using my backup tool
[Chunkyard][chunkyard]. After restoring one of these repositories I was
surprised that I could not clone the bare repository:

``` shell
cd ~/temp
git clone ~/Restored/my-git-project
```

``` text
fatal: repository '~/Restored/my-git-project' does not exist
```

Running `ll ~/Restored/my-git-project` printed this result:

``` text
drwxrwxr-x 5 flo flo 4096 Apr  3 15:57 ./
drwxrwxr-x 4 flo flo 4096 Apr  3 15:57 ../
-rw-rw-r-- 1 flo flo  104 Apr  3 15:57 config
-rw-rw-r-- 1 flo flo   73 Apr  3 15:57 description
-rw-rw-r-- 1 flo flo   23 Apr  3 15:57 HEAD
drwxrwxr-x 2 flo flo 4096 Apr  3 15:57 hooks/
drwxrwxr-x 2 flo flo 4096 Apr  3 15:57 info/
drwxrwxr-x 4 flo flo 4096 Apr  3 15:57 objects/
-rw-rw-r-- 1 flo flo  105 Apr  3 15:57 packed-refs
```

I ran `git gc` prior to creating the backup, which explains the `packed-refs`
file. As a result the `refs` directory became empty. Chunkyard does only care
about files, so any empty directory will not be included in a backup. And that
caused Git to error out when trying to clone the repository. The fix is rather
easy:

``` text
cd ~/restored/my-git-project
mkdir refs
```

[chunkyard]: https://github.com/fwinkelbauer/chunkyard
