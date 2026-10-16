load("lib.sage")
# INTEGRATION CHECK demanded by the brief: dbits = nbits must reproduce round 115.
r115 = {(64,2):33,(64,4):18,(64,8):12,(96,4):28,(128,4):36,(192,8):27,(256,4):72}
print("(nbits,t) | l* measured now | l* round-115 | t*l* | floor b=nbits", flush=True)
for (nb,t),lstar in sorted(r115.items()):
    # walk upward until first l with >=10/12
    first=None
    for l in range(0, nb+1, max(1, nb//20)):
        h=0
        for sd in range(12): h += attack(build_instance(nb,t,l,"msb",sd=sd,dbits=nb))[0] is not None
        if h>=10 and first is None: first=l
    print(f"  {nb:3d},{t:1d} | {first} | {lstar} | t*l*={(first*t) if first else None} | {nb}"
          f" | {'MATCH' if first==lstar else 'MISMATCH'}", flush=True)
