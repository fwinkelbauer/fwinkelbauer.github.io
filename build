#!/bin/bash

set -euo pipefail

directory=public

if [ ! -d "$directory" ]; then
    git worktree prune
    git worktree add -B gh-pages "$directory" origin/gh-pages
fi

cd "$directory"

files=$(git ls-files)

for file in $files; do
    if [ -f "$file" ]; then
        rm "$file"
    fi
done

cd ..

hugo --minify
