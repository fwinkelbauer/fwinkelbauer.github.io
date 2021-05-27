---
title: "Minor Org-Mode Features"
date: 2021-05-26
---

This post builds upon a previous post about [org-mode links][org-links].

## Elisp Link Handlers

My previous approach to custom links defined elisp code inside a .org file,
which was rather annoying as it pops up a warning dialog to notify the user
about the code which is about to get executed. It turns out that you can
configure elisp link handlers inside your .emac.d without any warning popups:

``` emacs-lisp
(defun fw/open-git (path)
  "Opens magit at `path'"
  (magit-status path))

(org-add-link-type "git" 'fw/open-git)
```

Here's an example:

``` org
* [[git:D:/Projects/SomeProject][Some Project]]
```

Clicking the headline will open "D:/Projects/SomeProject" using Magit.

## Custom Links

The in-buffer setting

``` org
#+LINK: issue https://company.issue.tracker.com/ticket?id=

[[issue:42][Major Bug]]
```

can also be written in elisp like this:

``` emacs-lisp
(setq org-link-abbrev-alist
      '(("issue" . "https://company.issue.tracker.com/ticket?id=%s")))
```

## Smart Browser Selection

Clicking a URL inside of org-mode opens your default browser. This behavior can
be customized using the variable `browse-url-browser-function`, which is handy
if a website only loads in a specific browser. You can either write your own URL
handler, or you can specify a regex based lookup list:

``` emacs-lisp
(setq browse-url-browser-function '(("intranet" . browse-url-chrome)
                                    ("google" . browse-url-chrome)
                                    ("." . browse-url-default-browser)))
```

[org-links]: {{< ref "2019-01-30-emacs-orglink.md" >}}
