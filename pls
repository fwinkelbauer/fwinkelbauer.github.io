#!/usr/bin/env python3

import argparse
import os
import shutil
import subprocess
from pathlib import Path


DIRECTORY = 'public/'
BRANCH = 'gh-pages'


def announce(msg):
    print()
    print(msg)
    print('========================================')


def clean():
    announce('Clean')
    if not os.path.isdir(DIRECTORY):
        return
    for file in Path(DIRECTORY).iterdir():
        path=str(file.resolve())
        if path.endswith('.git'):
            continue
        elif os.path.isfile(path):
            os.remove(path)
        else:
            shutil.rmtree(path)


def worktree():
    announce('Worktree')
    if os.path.isdir(DIRECTORY):
        shutil.rmtree(DIRECTORY)
    run(['git', 'fetch'])
    run(['git', 'worktree', 'prune'])
    run(['git', 'worktree', 'add', '--no-checkout', '-B', BRANCH, DIRECTORY, 'origin/gh-pages'])
    run(['git', 'restore', '--staged', '.'], DIRECTORY)


def build():
    announce('Build')
    run(['emacs', '-Q', '--script', 'build.el'])


def deploy():
    worktree()
    build()
    announce('Deploy')
    run(['git', 'add', '-A'], DIRECTORY)
    run(['git', 'commit', '-m', 'Update website'], DIRECTORY)
    run(['git', 'push'], DIRECTORY)


def serve():
    announce('Serve')
    run(['python3', '-m', 'http.server', '-d', DIRECTORY])


def main():
    parser = argparse.ArgumentParser(prog='make')
    sub = parser.add_subparsers(required=True)
    add_cmd(sub, 'clean', 'Delete build artifacts', clean)
    add_cmd(sub, 'worktree', f'Setup {BRANCH} in {DIRECTORY}', worktree)
    add_cmd(sub, 'build', 'Build the website', build)
    add_cmd(sub, 'deploy', 'Build and deploy the website', deploy)
    add_cmd(sub, 'serve', f'Start a webserver in {DIRECTORY}', serve)
    args = parser.parse_args()
    args.func(args)


def add_cmd(sub, name, help, func):
    parser = sub.add_parser(name, help=help)
    parser.set_defaults(func=lambda args: func())


def run(args, cwd=None):
    subprocess.run(args, check=True, cwd=cwd)


if __name__ == '__main__':
    main()
