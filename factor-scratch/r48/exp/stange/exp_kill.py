"""
THE KILL TEST: does Algorithm 2.2 actually produce a factor at small n?

Counts, over many random (n, g) at several sizes, how often the end-to-end
algorithm (relation finding -> kernel over Q -> alpha_t -> gcd -> order-based
gcd) yields a genuine non-trivial factor of n.

This is the decisive practical question. Note the paper's own example is
n = 62389 (16 bits). We go well above that.
"""
from __future__ import annotations
import json
import math
import random
import sys
import time
from math import gcd

sys.path.insert(0, "/home/raver1975/lean/factor-scratch/r48/exp/stange")
sys.path.insert(0, "/home/raver1975/lean/factor-scratch/r48/_shared")

from stange import (alg22, bbound_for_b, factor_base, gen_semiprime)
from sympy.ntheory import n_order


def trial(nbits, b, c, seed):
    rng = random.Random(seed)
    n, p, q = gen_semiprime(nbits, rng)
    FB = factor_base(bbound_for_b(b), n)
    if len(FB) != b:
        return None
    g = rng.randrange(2, n)
    while gcd(g, n) != 1:
        g = rng.randrange(2, n)
    try:
        res = alg22(n, g, FB, c, rng, sampler="random")
    except RuntimeError:
        return {"n": n, "factor": None, "stalled": True, "G": 0, "g": g}
    og = math.lcm(int(n_order(g, p)), int(n_order(g, q)))
    return {"n": n, "g": g, "G": res["G"], "ord_g": og,
            "h": (res["G"] // og) if (res["G"] and res["G"] % og == 0) else None,
            "factor": res["factor"], "trials": res["trials"],
            "true": sorted([p, q]), "rank": res["rank"], "dimK": res["dimK"]}


if __name__ == "__main__":
    settings = [
        dict(nbits=20, b=15, c=10, ntrials=60, seed=7),    # ~the paper's own example size
        dict(nbits=26, b=8,  c=5,  ntrials=60, seed=8),
        dict(nbits=26, b=8,  c=10, ntrials=60, seed=9),
        dict(nbits=30, b=12, c=10, ntrials=50, seed=10),
        dict(nbits=40, b=20, c=10, ntrials=30, seed=11),
    ]
    out = []
    for i, s in enumerate(settings):
        t0 = time.time()
        rows, facs, stalls = [], 0, 0
        for k in range(s["ntrials"]):
            r = trial(seed=s["seed"] * 1000 + k, **{kk: s[kk] for kk in ("nbits", "b", "c")})
            if r is None:
                continue
            rows.append(r)
            if r.get("stalled"):
                stalls += 1
            if r["factor"] in r["true"]:
                facs += 1
        N = len(rows)
        rec = {"setting": s, "n": N, "factors": facs, "stalls": stalls,
               "rate": facs / max(N, 1), "secs": round(time.time() - t0, 1),
               "rows": rows}
        out.append(rec)
        print(f"n~2^{s['nbits']} b={s['b']} c={s['c']}: FACTORS {facs}/{N} "
              f"= {facs/max(N,1):.3f}  stalls={stalls}  {rec['secs']}s", flush=True)
        with open(f"kill_{i}.json", "w") as f:
            json.dump(rec, f)
    print("done")
