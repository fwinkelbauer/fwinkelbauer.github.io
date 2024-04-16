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
    if os.path.isdir(DIRECTORY):
        shutil.rmtree(DIRECTORY)
    run('git worktree prune')
    run(f'git worktree add --no-checkout -B {BRANCH} {DIRECTORY} origin/gh-pages')
    run('git restore --staged .', DIRECTORY)


def publish():
    announce('Publish')
    run('emacs -Q --script publish.el')


def deploy():
    clean()
    publish()
    announce('Deploy')
    run('git add -A', DIRECTORY)
    run('git commit -m "Update website"', DIRECTORY)
    run('git push', DIRECTORY)


def serve():
    announce('Serve')
    run(f'python3 -m http.server -d {DIRECTORY}')


def main():
    parser = argparse.ArgumentParser(prog='make')
    sub = parser.add_subparsers(required=True)
    add_cmd(sub, 'clean', 'Delete published artifacts', clean)
    add_cmd(sub, 'publish', 'Publish the website', publish)
    add_cmd(sub, 'deploy', 'Publish and deploy the website', deploy)
    add_cmd(sub, 'serve', 'Serve the published website on localhost', serve)
    args = parser.parse_args()
    args.func(args)


def add_cmd(sub, name, help, func):
    parser = sub.add_parser(name, help=help)
    parser.set_defaults(func=lambda args: func())


def run(args, cwd=None):
    subprocess.run(args, check=True, shell=True, cwd=cwd)


if __name__ == '__main__':
    main()
