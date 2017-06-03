#!/usr/bin/env python

import sys
import random
from subprocess import Popen, PIPE, check_call

macs = [
    '4E:53:50:4F:4F:40',
    '4E:53:50:4F:4F:41',
    '4E:53:50:4F:4F:42',
    '4E:53:50:4F:4F:43',
    '4E:53:50:4F:4F:44',
    '4E:53:50:4F:4F:45',
    '4E:53:50:4F:4F:46',
    '4E:53:50:4F:4F:47',
    '4E:53:50:4F:4F:48',
    '4E:53:50:4F:4F:49',
    '4E:53:50:4F:4F:4A',
    '4E:53:50:4F:4F:4B',
    '4E:53:50:4F:4F:4C',
    '4E:53:50:4F:4F:4D',
    '4E:53:50:4F:4F:4E',
    '4E:53:50:4F:4F:4F' ]
random.shuffle(macs)

def main():
    counter = 0
    check_call(['iwconfig', 'attwifi', 'txpower', '1'])

    while True:
        mac = macs[counter % len(macs)]
        counter+= 1
        check_call(['ip', 'link', 'set', 'attwifi', 'down'])
        check_call(['ip', 'link', 'set', 'attwifi', 'address', mac])

        child = Popen(['hostapd', sys.argv[1]], stdout=PIPE)
        while True:
            line = child.stdout.readline()
            sys.stdout.write(line)
            sys.stdout.flush()
            if 'disassociated' in line:
                child.kill()
                child.wait()
                break

if __name__ == '__main__':
    main()
