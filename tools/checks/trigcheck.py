import sys,struct,math,ctypes
lm=ctypes.CDLL('libm.so.6')
for n in ('sinf','cosf','tanf'): getattr(lm,n).restype=ctypes.c_float; getattr(lm,n).argtypes=[ctypes.c_float]
f32=lambda v: struct.unpack('f',struct.pack('f',v))[0]
vals=[int(l.strip().rstrip('H'),16) for l in open(sys.argv[1]) if l.strip()]
outs=[l.split() for l in open(sys.argv[2]) if l.strip() and not l.startswith('(')]
def ulps_d(a,b):
    ia=struct.unpack('<q',struct.pack('<d',a))[0]; ib=struct.unpack('<q',struct.pack('<d',b))[0]
    if ia<0: ia=-(ia&0x7FFFFFFFFFFFFFFF)
    if ib<0: ib=-(ib&0x7FFFFFFFFFFFFFFF)
    return abs(ia-ib)
def ulps_f(a,b):
    ia=struct.unpack('<i',struct.pack('<f',a))[0]; ib=struct.unpack('<i',struct.pack('<f',b))[0]
    if ia<0: ia=-(ia&0x7FFFFFFF)
    if ib<0: ib=-(ib&0x7FFFFFFF)
    return abs(ia-ib)
worstd=[0,0,0]; worstf=[0,0,0]; nf=0
for v,o in zip(vals,outs):
    x=struct.unpack('<d',struct.pack('<Q',v))[0]
    got=[struct.unpack('<d',struct.pack('<Q',int(t,16)))[0] for t in o[:3]]
    for k,fn in enumerate((math.sin,math.cos,math.tan)):
        u=ulps_d(got[k],fn(x)); 
        if u>worstd[k]: worstd[k]=u
    xf=f32(x) if abs(x)<3.4e38 else None
    if xf is not None and abs(xf)!=float('inf'):
        nf+=1
        gotf=[struct.unpack('<f',struct.pack('<I',int(t,16)))[0] for t in o[3:6]]
        for k,fn in enumerate((lm.sinf,lm.cosf,lm.tanf)):
            u=ulps_f(gotf[k],fn(xf))
            if u>worstf[k]: worstf[k]=u
print(len(vals),'values; MathL worst ulps sin/cos/tan',worstd,'; Math (',nf,'REAL) worst ulps',worstf)
