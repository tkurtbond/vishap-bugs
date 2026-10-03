import sys,struct,math
vals=[int(l.strip().rstrip('H'),16) for l in open(sys.argv[1]) if l.strip()]
outs=[l.strip() for l in open(sys.argv[2]) if l.strip() and not l.startswith('(')]
bad=0; ex=[]
for v,o in zip(vals,outs):
    x=struct.unpack('<d',struct.pack('<Q',v))[0]
    want=struct.unpack('<Q',struct.pack('<d',math.sqrt(x)))[0]
    if int(o,16)!=want:
        bad+=1
        if len(ex)<3: ex.append((hex(v),o,'%016X'%want))
print(len(vals),'values,',len(outs),'results,',bad,'not correctly rounded',ex)
