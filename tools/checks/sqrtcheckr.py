import sys,struct,ctypes
lm=ctypes.CDLL('libm.so.6'); lm.sqrtf.restype=ctypes.c_float; lm.sqrtf.argtypes=[ctypes.c_float]
vals=[int(l.strip().rstrip('H'),16) for l in open(sys.argv[1]) if l.strip()]
outs=[l.strip() for l in open(sys.argv[2]) if l.strip() and not l.startswith('(')]
bad=0
for v,o in zip(vals,outs):
    x=struct.unpack('<f',struct.pack('<I',v))[0]
    want=struct.unpack('<I',struct.pack('<f',lm.sqrtf(x)))[0]
    if int(o,16)&0xFFFFFFFF!=want: bad+=1
print(len(vals),'values,',len(outs),'results,',bad,'not correctly rounded')
