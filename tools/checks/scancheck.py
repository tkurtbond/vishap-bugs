#!/usr/bin/env python3
# scancheck.py VALS OUT: compare the bits Texts.Scan read (ScanBits's output)
# with the correctly rounded REAL (E or no exponent) or LONGREAL (D) of each
# numeral, and count the wrong ones and how far off the worst is.
import struct, sys
vals = open(sys.argv[1]).read().split()
out = [l for l in open(sys.argv[2]).read().split('\n') if l]
assert len(out) == len(vals), (len(out), len(vals))
n = {'R': 0, 'L': 0}; bad = {'R': 0, 'L': 0}; worst = 0
for s, o in zip(vals, out):
    k, hx = o.split(); got = int(hx, 16); n[k] += 1
    if k == 'R':
        want = struct.unpack('>I', struct.pack('>f', float(s)))[0]
    else:
        want = struct.unpack('>Q', struct.pack('>d', float(s.replace('D', 'E'))))[0]
    if got != want:
        bad[k] += 1; worst = max(worst, abs(got - want))
print('%d of %d REALs and %d of %d LONGREALs wrong, the worst %d units in the last place off'
      % (bad['R'], n['R'], bad['L'], n['L'], worst))
