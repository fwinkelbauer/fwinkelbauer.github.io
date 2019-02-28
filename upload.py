#!/usr/bin/env python3

import getpass
import os
from ftplib import FTP


def main():
    user = input('Username: ')
    pw = getpass.getpass()
    ftp = FTP('florianwinkelbauer.com')
    ftp.login(user, pw)
    ftp.cwd('/web')
    os.chdir('fw')
    file_names = os.listdir('.')
    for file_name in file_names:
        with open(file_name, 'rb') as f:
            print('Uploading file: {}'.format(file_name))
            ftp.storbinary('STOR {}'.format(file_name), f)
    ftp.quit()


if __name__ == '__main__':
    main()
