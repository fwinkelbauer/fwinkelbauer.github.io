#!/bin/bash -eu

rm -rf ./public/
git worktree prune
git worktree add --no-checkout -B gh-pages ./public/ origin/gh-pages
git -C ./public/ restore --staged .
emacs -Q --script website.el
