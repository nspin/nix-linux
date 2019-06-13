import re
import sys

yes_re = re.compile(r'CONFIG_(?P<key>[A-Za-z0-9_]+)=(?P<value>[^\n]+)\n');
no_re = re.compile(r'(#([^\n]*))?\n');

print('{')

for line in sys.stdin:
    m = yes_re.fullmatch(line)
    if m is None:
        if no_re.fullmatch(line) is None:
            raise Exception('invalid line', line)
    else:
        key = m.group('key')
        value = m.group('value')
        print('  "{}" = \'\'{}\'\';'.format(key, value))

print('}')
