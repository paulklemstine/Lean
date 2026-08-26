#!/usr/bin/env python3
"""E-5: adaptive vs static ECM differentiation at 200-bit moduli (~60-digit factors)."""
import sys, os, json, time
sys.path.insert(0, os.path.dirname(__file__))
from e2_adaptive_ecm import gen_semiprime, arm_adaptive, arm_fixed, arm_oracle
rows = []
for s in (60, 70):
    N = gen_semiprime(s)
    for name, fn in (("fixed_11k", lambda: arm_fixed(N, 11000)),
                     ("fixed_250k", lambda: arm_fixed(N, 250000)),
                     ("adaptive", lambda: arm_adaptive(N)),
                     ("oracle", lambda: arm_oracle(N, 2**s))):
        t0 = time.perf_counter(); f, el = fn()
        ok = bool(f) and N % f == 0; el = time.perf_counter() - t0
        rows.append({"size": s, "arm": name, "s": round(el,1), "ok": bool(ok)})
        print(f"[{name:>10}] p~{s}b: {el:8.1f}s ok={ok}", flush=True)
json.dump(rows, open(os.path.join(os.path.dirname(__file__),'e5_results.json'),'w'), indent=1)
print("SUMMARY:", json.dumps({a: [r for r in rows if r['arm']==a] for a in ('fixed_11k','fixed_250k','adaptive','oracle')}, default=str)[:400])
