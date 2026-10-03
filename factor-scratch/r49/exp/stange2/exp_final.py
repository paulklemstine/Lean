"""
exp_final.py -- the four schemes, cost per successful factor, HELD OUT.

Schemes (each run on identical fresh instances):
  S0 BASELINE   g uniform, c = 10, full stripper.  Faithful reproduction of
                the configuration r48 measured 181/240 on.
  S1 PREREG-6   g uniform, c = 1,  bounded stripper.  The index h is stripped
                away (self-test T7), so buying accuracy on it with relations
                buys nothing.
  S2 H1-bias    g with Jacobi(g/n) = -1, c = 10.  EXACT theory (order_theory.
                py): P(factor | Jacobi = -1) = 8/9 = 0.8889 vs 20/27 = 0.7407
                unbiased.  The test costs one Legendre symbol, O(log n), and
                ZERO extra relations.
  S3 COMBINED   g with Jacobi(g/n) = -1, c = 1.  Both.

HELD OUT: seeds 990000+.  Tuning used 510000-540000 (cost), 610000-650000
(H1), 770000 (baseline), 890000 (scale).  No instance here was seen while any
parameter was being chosen.
"""
from __future__ import annotations

import json
import math
import random
import sys
import time
from math import gcd

from s2core import (attempt, bbound_for_b, factor_base, jacobi, order_mod_n,
                    rand_g)
from stange import gen_semiprime

P_BASE = 20.0 / 27.0        # 0.7407407
P_BIAS = 8.0 / 9.0          # 0.8888889


def pick_g(n, rng, nonres):
    if not nonres:
        return rand_g(n, rng)
    while True:
        g = rng.randrange(2, n)
        # Euler's criterion pow(g,(n-1)/2,n)==n-1 is WRONG here -- n is
        # composite, so it never fires.  Use the Jacobi symbol, O(log n).
        if gcd(g, n) == 1 and jacobi(g, n) == -1:
            return g


def one(nbits, b, c, seed, nonres, strip):
    rng = random.Random(seed)
    n, p, q = gen_semiprime(nbits, rng)
    FB = factor_base(bbound_for_b(b), n)
    if len(FB) != b:
        return None
    g = pick_g(n, rng, nonres)
    t0 = time.time()
    r = attempt(n, p, q, g, FB, c, rng, strip=strip)
    r["secs"] = time.time() - t0
    if r["factor"] is not None:
        assert n % r["factor"] == 0 and 1 < r["factor"] < n
        r["ok"] = True
    return r


SCHEMES = [
    ("S0 BASELINE (g uniform, c=10, full strip)", False, 10, "full"),
    ("S1 PREREG-6 (g uniform, c=1, bounded strip)", False, 1, "bounded"),
    ("S2 H1-bias (Jacobi(g/n)=-1, c=10)", True, 10, "full"),
    ("S3 COMBINED (Jacobi=-1, c=1, bounded strip)", True, 1, "bounded"),
]

if __name__ == "__main__":
    NT = int(sys.argv[1]) if len(sys.argv) > 1 else 200
    SEED0 = int(sys.argv[2]) if len(sys.argv) > 2 else 990000
    configs = [(26, 8), (30, 12), (30, 20)]
    out = {}
    agg = {}
    for (nbits, b) in configs:
        print(f"\n=== HELD-OUT  n~2^{nbits}, b={b}, {NT} fresh instances "
              f"(seed {SEED0}+) ===")
        print(f"{'scheme':<48}{'rate':>7}{'z_own':>8}{'rels/succ':>11}"
              f"{'exp/succ':>11}{'rel-SUCCESS vs S0':>20}")
        base_cps = None
        rows = []
        for (name, nr, c, st) in SCHEMES:
            t0 = time.time()
            rs = [one(nbits, b, c, SEED0 + k, nr, st) for k in range(NT)]
            rs = [r for r in rs if r]
            f = sum(1 for r in rs if r["ok"])
            rate = f / max(len(rs), 1)
            pred = P_BIAS if nr else P_BASE
            se = math.sqrt(pred * (1 - pred) / max(len(rs), 1))
            rels_succ = (b + c) / max(rate, 1e-9)
            ex = sum(r["trials"] for r in rs) / max(len(rs), 1)
            ex_succ = ex / max(rate, 1e-9)
            if base_cps is None:
                base_cps = ex_succ
            rows.append({"scheme": name, "N": len(rs), "f": f, "rate": rate,
                         "pred": pred, "z": (rate - pred) / se,
                         "rels_per_succ": rels_succ, "exp_per_succ": ex_succ,
                         "exp_ratio_vs_S0": base_cps / ex_succ,
                         "rels": b + c, "secs": round(time.time() - t0, 1)})
            print(f"{name:<48}{rate:>7.4f}{(rate-pred)/se:>+8.2f}"
                  f"{rels_succ:>11.1f}{ex_succ:>11,.0f}"
                  f"{base_cps/ex_succ:>19.2f}x", flush=True)
        out[f"{nbits}_{b}"] = rows
        for r in rows:
            agg.setdefault(r["scheme"], []).append(r["exp_ratio_vs_S0"])
    json.dump(out, open("final.json", "w"), indent=1)
    print("\n=== POOLED over all held-out configs ===")
    for (name, *_ ) in SCHEMES:
        v = agg[name]
        print(f"  {name:<48} mean exp-per-success ratio vs S0 = "
              f"{sum(v)/len(v):.3f}x")
    # normalized alpha diagnostic
    print("\n=== alpha_t: RAW vs NORMALISED by ord(g) (r48's confound) ===")
    rng = random.Random(SEED0 + 500)
    rf = rn2 = rn3 = nn2 = nn3 = nn = 0
    N = 300
    for k in range(N):
        n, p, q = gen_semiprime(30, rng)
        FB = factor_base(bbound_for_b(12), n)
        r = attempt(n, p, q, rand_g(n, rng), FB, 5, rng, strip="bounded")
        nn += r["norm_n"]
        rf += r["raw_frac2"]
        rn2 += r["norm_frac2"]
        rn3 += r["raw_frac3"]
        nn3 += r["norm_frac3"]
    print(f"  N={N} instances, {nn} normalised alpha_t")
    print(f"  RAW alpha_t divisible by 2: {rn2/N:.4f}   "
          f"(random model 0.5)  -> {rn2/N/0.5:.2f}x")
    print(f"  alpha_t/ord divisible by 2: {nn2/N:.4f}   "
          f"(random model 0.5)  -> {nn2/N/0.5:.2f}x   <-- the honest number")
    print(f"  RAW alpha_t divisible by 3: {rn3/N:.4f}   "
          f"(random model 1/3)  -> {rn3/N/(1/3):.2f}x")
    print(f"  alpha_t/ord divisible by 3: {nn3/N:.4f}   "
          f"(random model 1/3)  -> {nn3/N/(1/3):.2f}x   <-- the honest number")
    json.dump({"raw2": rn2/N, "norm2": nn2/N, "raw3": rn3/N, "norm3": nn3/N,
               "N": N, "nalpha": nn}, open("alpha_norm.json", "w"), indent=1)