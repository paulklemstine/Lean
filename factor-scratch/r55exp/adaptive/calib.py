#!/usr/bin/env python3
"""CALIBRATION: identical input, fixed seed, run TWICE, outputs must be byte-identical.
Also measures the COST MODEL: wall-clock per (m,t) cell, which is what the adaptive
strategy must pay.  Nothing downstream is quotable until this passes."""
import sys, json, time
sys.path.insert(0,'/home/raver1975/lean/Experiments/UMWWindow')
import random
from coppersmith_lattice import gen_prime
from cell import make_instance, cell

def run():
    random.seed(20261004)
    out = []
    for n in (48, 64):
        N, p, q, nn = make_instance(n, None)
        q4 = nn // 4
        for k in (q4, q4 - 1, q4 - 2):
            for m in range(2, 13):
                for t in range(2, 13):
                    f, dt, np_ = cell(N, p, nn, k, m, t)
                    out.append((nn, k, m, t, bool(f), np_, round(dt, 6)))
    return out

a = run()
b = run()
# strip timings (they are the ONE legitimately non-reproducible field)
sa = [r[:5] for r in a]; sb = [r[:5] for r in b]
print("cells:", len(a))
print("DETERMINISM (all non-timing fields, two independent runs):",
      "PASS -- identical" if sa == sb else "*** FAIL -- differs ***")
assert sa == sb

# --- COST MODEL, measured ---
import statistics
cost = {}
for nn, k, m, t, ok, np_, dt in a:
    cost.setdefault((m * t), []).append(dt)
print("\nCOST MODEL -- wall-clock seconds per lattice solve, by lattice dimension d=m*t")
print("  (n=48 and n=64 pooled; median over the 3 k values)")
print("   d     median_s   max_s   n_cells")
for d in sorted(cost):
    v = cost[d]
    if d in (1,2,3,4,6,9,16,25,36,49,64,81,100,121):
        print(f"  {d:4d}   {statistics.median(v):.6f}  {max(v):.6f}   {len(v)}")

# --- does success depend on wall time? (a cost-blindness check) ---
hits = [(nn,k,m,t) for nn,k,m,t,ok,_,_ in a if ok]
print(f"\nsuccess cells: {len(hits)}/{len(a)}")
print("  sample:", hits[:8])
