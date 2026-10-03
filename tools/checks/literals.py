# literals.py extract SRCDIR > LITS: list the distinct real literals in the
#   .Mod files under SRCDIR (comments and strings removed).
# literals.py compare RESULTS: RESULTS has lines "<literal> <hex bits or ERR>",
#   from literals.sh; count those that are not the nearest REAL (no D
#   exponent) or LONGREAL (D exponent).
import glob, re, struct, sys
if sys.argv[1] == 'extract':
    lits = set()
    for f in glob.glob(sys.argv[2] + '/**/*.[Mm]od', recursive=True):
        t = open(f, errors='replace').read()
        t = re.sub(r'\(\*.*?\*\)', '', t, flags=re.S)
        t = re.sub(r'"[^"\n]*"', '', t)
        lits.update(re.findall(r'(?<![\w.])(\d+\.\d*(?:[EDed][+-]?\d+)?)(?![\w.])', t))
    print('\n'.join(sorted(lits)))
else:
    right = wrong = err = 0
    for line in open(sys.argv[2]):
        lit, got = line.split()
        x = float(lit.replace('D', 'e').replace('d', 'e'))
        if 'D' in lit or 'd' in lit:
            want = '%016X' % struct.unpack('<Q', struct.pack('<d', x))[0]
        else:
            want = '%08X' % struct.unpack('<I', struct.pack('<f', x))[0]
        if got == 'ERR': err += 1
        elif got.upper() == want: right += 1
        else: wrong += 1
    print(right + wrong + err, 'literals:', right, 'right,', wrong, 'wrong,', err, 'do not compile')
