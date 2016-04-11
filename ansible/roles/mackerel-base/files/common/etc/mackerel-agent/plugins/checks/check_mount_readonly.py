#!/usr/bin/python
import sys, re

if '-h' in sys.argv:
    print("usage: %s [exclude_path_regex [exclude_path_regex ...]]" % __file__.split('/')[-1] )
    sys.exit(255)


regex_parse = re.compile('''^(?P<dev>[^\s]+)\s+(?P<mountpoint>[^\s]+)\s+(?P<type>[^\s]+)\s+(?P<option>[^\s]+).*''')
list_regex_exclude = map(lambda x: re.compile(x), sys.argv)

ret = 0
readonly_dirs = list()
for line in open('/proc/mounts'):
    try:
        m = regex_parse.match(line)
        for exclude in list_regex_exclude:
            if exclude.match(m.group('mountpoint')) :
                break
        else:
            if 'ro' in m.group('option').split(','):
                readonly_dirs.append(m.group('mountpoint'))
                ret = 1
    except:
        pass

if ret != 0:
    print('readonly found: %s' % ', '.join(readonly_dirs))
else:
    print('OK')
    
sys.exit(ret)
