load("lib.sage")

NB = 256                 # realistic scale throughout
print("== CONTROLS (b=128, t=4, nbits=256) ==", flush=True)
for l, note in [(0,"no leakage, must be 0"), (32,"half the predicted threshold, expect ~0"),
                (64,"at predicted boundary t*l=256>128, expect high"),
                (128,"double the boundary, expect 12")]:
    h = sum(attack(build_instance(NB,4,l,"msb",sd=sd,dbits=128))[0] is not None for sd in range(12))
    print(f"  l={l:3d} t*l={4*l:4d} b=128 -> {h}/12   ({note})", flush=True)

print("== 2D SURFACE: first l reaching >=10/12, 12 seeds/point ==", flush=True)
print("  b = key entropy bits (d < 2^b); prediction: t*l* ~ 1.03-1.5 x b", flush=True)
rows = []
for b in [64, 96, 128, 192, 256]:
    for t in [2, 4, 8]:
        first = None
        for l in range(0, b + 1, max(1, b // 24)):
            h = 0
            for sd in range(12):
                h += attack(build_instance(NB, t, l, "msb", sd=sd, dbits=b))[0] is not None
            if h >= 10 and first is None:
                first = l
        tl = t * first if first is not None else None
        rows.append((b, t, first, tl))
        print(f"  b={b:3d} t={t}: l*={first}  t*l*={tl}  ratio t*l*/b="
              f"{float(tl)/b if tl else None}  (t*l*>=b predicted)", flush=True)
print("== BOUNDARY FIT: t*l* = c(b,t) * b ==", flush=True)
for b,t,lst,tl in rows:
    if tl: print(f"  b={b:3d} t={t}: c = {float(tl)/b:.3f}", flush=True)
