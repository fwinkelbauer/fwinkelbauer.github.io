#!/usr/bin/env python3

import argparse
import subprocess
import os


DIRECTORY = './public'


def clean(args):
    run(['git', 'clean', '-dfx'])


def publish(args):
    if not os.path.isdir(DIRECTORY):
        run(['git', 'worktree', 'prune'])
        run(['git', 'worktree', 'add', '-B', 'gh-pages', DIRECTORY, 'origin/gh-pages'])
    files = query(['git', 'ls-files'], cwd=DIRECTORY)
    for file in files:
        relative_file = os.path.join(DIRECTORY, file)
        if os.path.isfile(relative_file):
            os.remove(relative_file)
    run(['emacs', '-Q', '--script', './publish.el'])


def serve(args):
    run(['python3', '-m', 'http.server'], cwd=DIRECTORY)


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


def run(args, cwd=None):
    subprocess.run(args, cwd=cwd, check=True)


def query(args, cwd=None):
    process = subprocess.run(args, cwd=cwd, check=True, capture_output=True, text=True)
    return process.stdout.splitlines()


if __name__ == '__main__':
    main()
