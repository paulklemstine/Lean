load("hnp_baseline_lib.sage")
import time
print("== CONTROLS ==", flush=True)
for label, nb, t, l, expect in [
    ("DEGENERATE (no leakage at all)", 96, 4, 0, 0),
    ("POSITIVE  (t*l >> floor)",       96, 4, 64, 12),
    ("POSITIVE  (small size)",         64, 4, 32, 12),
    ("AT FLOOR (t*l == log2 n)",      128, 4, 32, 0),
    ("ABOVE FLOOR (t*l > log2 n)",    128, 4, 48, 12)]:
    h = 0
    t0 = time.time()
    for sd in range(12):
        h += attack(build_instance(nb, t, l, "msb", sd=sd))[0] is not None
    print(f"  {label:34s} nbits={nb} t={t} l={l:3d} t*l={t*l:4d} floor={nb:3d}: {h}/12 "
          f"(expected {expect}) {time.time()-t0:.1f}s", flush=True)

print("== THRESHOLD SWEEP: minimal l giving >=10/12, 12 seeds per point ==", flush=True)
for nbits in [64, 96, 128, 192, 256]:
    for t in [2, 4, 8, 16]:
        step = max(1, nbits // 20)
        first = None
        for l in range(0, nbits + 1, step):
            h = 0; t0 = time.time()
            for sd in range(12):
                h += attack(build_instance(nbits, t, l, "msb", sd=sd))[0] is not None
            if h >= 10 and first is None:
                first = l
            print(f"   nbits={nbits:3d} t={t:2d} l={l:4d} t*l={t*l:5d} floor={nbits:3d} "
                  f"rate={h:2d}/12 {time.time()-t0:5.1f}s", flush=True)
        need = (nbits + t - 1)//t
        print(f"   >>> nbits={nbits} t={t}: first l with >=10/12 = {first}; floor says l>={need}", flush=True)
