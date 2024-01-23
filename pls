#!/usr/bin/env python3

import argparse
import os
import shutil
import subprocess
from pathlib import Path


DIRECTORY = './public'


def announce(msg):
    print()
    print(msg)
    print('========================================')


def build():
    announce('Build')
    if not os.path.isdir(DIRECTORY):
        run(['git', 'worktree', 'prune'])
        run(['git', 'worktree', 'add', '-B', 'gh-pages', DIRECTORY, 'origin/gh-pages'])
    for file in Path(DIRECTORY).iterdir():
        path=str(file.resolve())
        if path.endswith('.git'):
            continue
        elif os.path.isfile(path):
            os.remove(path)
        else:
            shutil.rmtree(path)
    run(['emacs', '-Q', '--script', 'build.el'])


def publish():
    build()
    announce('Publish')
    run(['git', 'add', '-A'], DIRECTORY)
    run(['git', 'commit', '-m', 'Update website'], DIRECTORY)
    run(['git', 'push'], DIRECTORY)


def serve():
    announce('Serve')
    run(['python3', '-m', 'http.server', '-d', DIRECTORY])


def main():
    parser = argparse.ArgumentParser(prog='make')
    sub = parser.add_subparsers(required=True)
    add_cmd(sub, 'build', 'Build the website', build)
    add_cmd(sub, 'publish', 'Build and publish the website', publish)
    add_cmd(sub, 'serve', 'Start a webserver', serve)
    args = parser.parse_args()
    args.func(args)


def add_cmd(sub, name, help, func):
    parser = sub.add_parser(name, help=help)
    parser.set_defaults(func=lambda args: func())


def run(args, cwd=None):
    subprocess.run(args, check=True, cwd=cwd)


if __name__ == '__main__':
    main()
