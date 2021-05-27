---
title: "Minor Org-Mode Features"
date: 2021-05-26
---

This post builds upon a previous post about [org-mode links][org-links].

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
