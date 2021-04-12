---
title: "Emacs Org-Mode Links are Fun"
date: 2019-01-30
---

I have started to use a few of org-mode's link features to help me stay
organized in my day job. The top of my "main" org file now includes these
statements:

``` org
#+LINK: issue https://company.issue.tracker.com/ticket?id=
#+LINK: tree elisp:(neotree-dir "%s")
#+LINK: dir elisp:(setq default-directory "%s")
```

Now I can write outlines that look something like this:

``` org
* [[tree:D:/Projects/SomeProject][Some Project]]

** [[issue:42][Major Bug]]

I have taken these steps to narrow the possible causes:

- foo
- bar
- fizz
```

The topmost headline can now give me a tree view of the "Some Project"
directory, while the second headline opens a particular ticket in my default
browser.
