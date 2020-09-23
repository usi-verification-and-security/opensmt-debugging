#!/usr/bin/env python3

import sys
import re
import os
import os.path

UNKNOWN = 'indet'
TIMEOUT = 'indet'
TIMEOUT_VAL = 100

if __name__ == '__main__':
    if len(sys.argv) < 2:
        print("Usage: %s <result-dir>" % sys.argv[0])
        sys.exit(1)

    files = map(lambda x: os.path.join(sys.argv[1], x), \
            os.listdir(sys.argv[1]))

    base = map(lambda x: x[:-len(".out")], filter(lambda x: x[-len(".out"):] == ".out", files))

    for file in base:
        out = open("%s.out" % file)
        err = open("%s.err" % file)
        time = open("%s.time" % file)
        out_l = out.readlines()
        err_l = err.readlines()
        time_s = time.read()

        name = out_l[0].strip()

        if len(out_l) >= 2:
            result = out_l[1].strip()
        elif re.search("Command terminated by signal 24",\
                time_s[0].strip()):
            result = TIMEOUT
        else:
            result = UNKNOWN

        if (result != TIMEOUT):
            utime = float(re.search("(.*)user", time_s).group(1))
        else:
            utime = TIMEOUT_VAL

        print("%s %s %.02f" % (name, result, utime))

