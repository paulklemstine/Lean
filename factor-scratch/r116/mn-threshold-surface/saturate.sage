load("lib.sage")
# DECISIVE TEST: sweep l PAST b. If the threshold is governed by nbits (not by b),
# l* must stay ~70 for every b. If governed by b, l* must drop to ~b/4.
print("nbits=256, t=4, key entropy b vs l* (l swept up to 160, well past every b)", flush=True)
for b in [16, 32, 64, 128, 192, 256]:
    first=None
    for l in range(0, 161, 8):
        h=0
        for sd in range(12): h += attack(build_instance(256,4,l,"msb",sd=sd,dbits=b))[0] is not None
        if h>=10 and first is None: first=l
    print(f"  b={b:3d}: l*={first}  t*l*={4*first if first else None}  (b/t={b//4})", flush=True)
print("same at t=2 (b/t = b/2):", flush=True)
for b in [16, 32, 64, 128, 192, 256]:
    first=None
    for l in range(0, 161, 4):
        h=0
        for sd in range(12): h += attack(build_instance(256,2,l,"msb",sd=sd,dbits=b))[0] is not None
        if h>=10 and first is None: first=l
    print(f"  b={b:3d}: l*={first}  t*l*={2*first if first else None}", flush=True)
