# outcheck.py VALS OUT: OUT is OutDigits's output for VALS (bit patterns of
# doubles, hexadecimal); count the numbers whose 17 significant digits do
# not read back as the same double, and those that are not the correctly
# rounded 17 digits.
import sys, struct
vals = [int(l.strip().rstrip('H'), 16) for l in open(sys.argv[1]) if l.strip()]
outs = [l.strip() for l in open(sys.argv[2]) if l.strip() and not l.startswith('(')]
back = digits = 0
for v, o in zip(vals, outs):
    x = struct.unpack('<d', struct.pack('<Q', v))[0]
    y = float(o.replace('D', 'e'))
    if y != x: back += 1
    m, e = ('%.16e' % x).split('e')
    if o.split('D')[0].lstrip('-') != m.lstrip('-'): digits += 1
print(len(vals), 'values,', len(outs), 'results,', back, 'do not read back,',
      digits, 'are not the correctly rounded 17 digits')
