#!/usr/bin/env python3

import argparse
import subprocess
import os


DIRECTORY = './public'


def clean(args):
    subprocess.run(['git', 'clean', '-dfx'], check=True)


def publish(args):
    if not os.path.isdir(DIRECTORY):
        subprocess.run(['git', 'worktree', 'prune'], check=True)
        subprocess.run(['git', 'worktree', 'add', '-B', 'gh-pages', DIRECTORY, 'origin/gh-pages'], check=True)
    process = subprocess.run(['git', 'ls-files'], capture_output=True, text=True, cwd=DIRECTORY, check=True)
    files = process.stdout.splitlines()
    for file in files:
        relative_file = os.path.join(DIRECTORY, file)
        if os.path.isfile(relative_file):
            os.remove(relative_file)
    subprocess.run(['emacs', '-Q', '--script', './publish.el'], check=True)


def serve(args):
    subprocess.run(['python3', '-m', 'http.server'], cwd=DIRECTORY, check=True)


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
    parser.set_defaults(func=func)


if __name__ == '__main__':
    main()
