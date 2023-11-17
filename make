#!/usr/bin/env python3

import argparse
import os
import shutil
import subprocess
from pathlib import Path


DIRECTORY = './public'


def clean():
    run('git clean -dfx')


def publish():
    if not os.path.isdir(DIRECTORY):
        run('git worktree prune')
        run(f"git worktree add -B gh-pages {DIRECTORY} origin/gh-pages")
    for file in Path(DIRECTORY).iterdir():
        path=str(file.resolve())
        if path.endswith('.git'):
            continue
        elif os.path.isfile(path):
            os.remove(path)
        else:
            shutil.rmtree(path)
    run('emacs -Q --script publish.el')


def serve():
    run('python3 -m http.server', cwd=DIRECTORY)


def main():
    parser = argparse.ArgumentParser(prog='make')
    sub = parser.add_subparsers(required=True)
    add_cmd(sub, 'clean', 'Remove all generated files', clean)
    add_cmd(sub, 'publish', 'Build the website', publish)
    add_cmd(sub, 'serve', 'Start a webserver', serve)
    args = parser.parse_args()
    args.func(args)


def add_cmd(sub, name, help, func):
    parser = sub.add_parser(name, help=help)
    parser.set_defaults(func=lambda args: func())


def run(args, cwd=None):
    subprocess.run(args.split(), cwd=cwd, check=True)


if __name__ == '__main__':
    main()
