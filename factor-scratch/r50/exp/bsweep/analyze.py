"""
analyze.py -- the reconciliation, computed.

Three objectives, all using MY MEASURED smoothness density (1/delta = exp/rel),
never a model:

  OBJ-1  (b+c) * exp/rel / rate            <- the objective I was asked to minimise
  OBJ-2  (b+c) * exp/rel * (1+b) / rate    <- (b+c)(1+b)/delta, BB's honest objective
  OBJ-3  wall clock, measured              <- the pipeline's own timer

Why (1+b): my relation search costs ONE `pow(g,x,n)` per candidate, which is
Theta(log n) modular multiplications, plus ONE reduction per factor-base prime
(`fb_exponents` loops all b primes), i.e. b reductions.  In BB's currency -- one
stride multiplication = 1 unit -- a `pow` is ~2*log2(x) units, so a candidate is
(2*log2(x) + b) units, not 1.  OBJ-2 is OBJ-1 with that factor left in; OBJ-1
implicitly prices a `pow` at 1 unit and a reduction at 0.

Density is taken from the MEASURED exp/rel, so OBJ-2 is not sensitive to whether
Dickman rho or the exact Psi is the right null -- which matters, because BB
measured rho to be 8.46x too small at u ~ 6.2.
"""
from __future__ import annotations

import json
import math
import os

HERE = os.path.dirname(os.path.abspath(__file__))
P = 20.0 / 27.0


def load(name):
    p = os.path.join(HERE, name)
    return json.load(open(p)) if os.path.exists(p) else {}


def main():
    sw, ex = load("sweep.json"), load("extra.json")
    for nbits in (30, 40):
        rows = list(sw.get(f"phase1_n{nbits}_c1", [])) + \
               list(ex.get(f"E1_n{nbits}", []))
        rows = [r for r in rows if "exp_per_rel" in r]
        rows.sort(key=lambda r: r["b"])
        c = 1
        print(f"\n{'='*104}\nn ~ 2^{nbits}, c={c}, rate = {P:.4f} "
              f"(measured density, NOT Dickman)\n{'='*104}")
        print(f"{'b':>5}{'exp/rel':>11}{'1/rho(u)':>12}{'meas/rho':>10}"
              f"{'u':>7}{'OBJ-1':>12}{'OBJ-2 (1+b)':>14}{'u in 5-8?':>11}")
        b1 = b2 = None
        v1 = v2 = None
        for r in rows:
            b = r["b"]
            e = r["exp_per_rel"]
            o1 = (b + c) * e / P
            o2 = (b + c) * (1 + b) * e / P
            u = r["nbits"] and math.log2(r["nbits"]) if False else None
            from bsweep_core import u_of
            u = u_of(b, nbits)
            print(f"{b:>5}{e:>11.4g}{r['model_exp_per_rel']:>12.4g}"
                  f"{r['measured_over_model']:>10.3f}{u:>7.2f}"
                  f"{o1:>12.5g}{o2:>14.5g}"
                  f"{('YES' if 5 <= u <= 8 else ''):>11}")
            if v1 is None or o1 < v1:
                v1, b1 = o1, b
            if v2 is None or o2 < v2:
                v2, b2 = o2, b
        print(f"\n  OBJ-1 argmin (as asked):      b* = {b1}, cost/success = {v1:.5g}")
        print(f"  OBJ-2 argmin (honest, 1+b):   b* = {b2}, cost/success = {v2:.5g}")
        # how flat is the OBJ-2 minimum?
        band = [r for r in rows
                if (r["b"] + c) * (1 + r["b"]) * r["exp_per_rel"] <= 1.10 * v2]
        print(f"  OBJ-2 within 10% of its minimum: b in "
              f"[{min(r['b'] for r in band)}, {max(r['b'] for r in band)}]")

    # wall clock
    for nbits in (30, 40):
        rows = [r for r in sw.get(f"phase2_n{nbits}_c1", [])
                if "secs_per_attempt" in r]
        if not rows:
            continue
        bw = min(rows, key=lambda r: r["secs_per_attempt"])
        ba = min(rows, key=lambda r: r["cost_per_success"])
        print(f"\nn ~ 2^{nbits}: WALL-CLOCK argmin b = {bw['b']} "
              f"({bw['secs_per_attempt']:.2f} s/attempt); "
              f"EXPONENTIATION argmin b = {ba['b']} "
              f"({ba['cost_per_success']:.5g})  -> they differ by "
              f"{ba['b']/bw['b']:.1f}x in b")

    # b=6 gap, both objectives
    for nbits in (30, 40):
        rows = {r["b"]: r for r in sw.get(f"phase1_n{nbits}_c1", [])
                if "exp_per_rel" in r}
        rows.update({r["b"]: r for r in ex.get(f"E1_n{nbits}", [])
                     if "exp_per_rel" in r})
        if 6 not in rows:
            continue
        b6 = rows[6]
        best1 = min(rows.values(), key=lambda r: (r["b"] + 1) * r["exp_per_rel"])
        best2 = min(rows.values(),
                    key=lambda r: (r["b"] + 1) * (1 + r["b"]) * r["exp_per_rel"])
        def o1(bb, r):
            return (bb + 1) * r["exp_per_rel"]
        def o2(bb, r):
            return (bb + 1) * (1 + bb) * r["exp_per_rel"]
        g1 = o1(6, b6) / o1(best1["b"], best1)
        g2 = o2(6, b6) / o2(best2["b"], best2)
        print(f"\nn ~ 2^{nbits}: the b-gap b=6 -> best b")
        print(f"   in EXPONENTIATIONS (OBJ-1): {g1:.1f}x  "
              f"(b=6 -> b={best1['b']})")
        print(f"   in OPERATIONS (OBJ-2):      {g2:.1f}x  "
              f"(b=6 -> b={best2['b']})")


if __name__ == "__main__":
    import sys
    sys.path.insert(0, HERE)
    main()