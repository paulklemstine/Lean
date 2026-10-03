"""
exp_scale.py -- H4, the END-TO-END decay curve.

exp_order.py already settles the success PROBABILITY out to 2^200 for free and
exactly (it is 20/27, n-independent).  What that does NOT do is show the
algorithm actually RUNS at larger n.  This script does, in two phases:

  PHASE 1 (calibration)  measure exponentiations-per-relation for several
      factor-base sizes b at each n, to pick the cheapest b inside budget.
  PHASE 2 (the curve)    run the real end-to-end Algorithm 2.2 at each n and
      record the factor rate AND the full cost per successful factor.

PREREG-5: rate at 2^60 >= 0.70.
"""
from __future__ import annotations

import json
import math
import random
import sys
import time

from s2core import attempt, bbound_for_b, factor_base, rand_g
from stange import fb_exponents, find_relations, gen_semiprime

P_TRUE = 20.0 / 27.0


def calibrate(nbits, b, want=6, seed=880000):
    """exponentiations per accepted relation, for factor-base size b."""
    rng = random.Random(seed + nbits * 100 + b)
    n, p, q = gen_semiprime(nbits, rng)
    FB = factor_base(bbound_for_b(b), n)
    if len(FB) != b:
        return None
    g = rand_g(n, rng)
    t0 = time.time()
    rels, trials = find_relations(n, g, FB, want, rng, "random")
    dt = time.time() - t0
    return {"b": b, "BB": bbound_for_b(b), "trials": trials,
            "per_rel": trials / len(rels), "secs": dt,
            "rho_est": len(rels) / trials,
            "u": math.log(n) / math.log(bbound_for_b(b)),
            "cost_per_attempt": trials}


def run(nbits, b, c, nt, seed0):
    rng0 = random.Random(seed0)
    rows, t0 = [], time.time()
    for k in range(nt):
        rng = random.Random(seed0 + k)
        n, p, q = gen_semiprime(nbits, rng)
        FB = factor_base(bbound_for_b(b), n)
        if len(FB) != b:
            continue
        g = rand_g(n, rng)
        tk = time.time()
        try:
            r = attempt(n, p, q, g, FB, c, rng, strip="bounded")
        except RuntimeError:
            continue
        if r["factor"] is not None:
            assert n % r["factor"] == 0 and 1 < r["factor"] < n
        r["secs"] = time.time() - tk
        rows.append(r)
    f = sum(1 for r in rows if r["factor"] is not None)
    rate = f / max(len(rows), 1)
    se = math.sqrt(P_TRUE * (1 - P_TRUE) / max(len(rows), 1))
    ex = sum(r["trials"] for r in rows) / max(len(rows), 1)
    print(f"  n~2^{nbits:<3d} b={b:<3d} c={c:<2d}: {f:>3}/{len(rows):<3} = "
          f"{rate:.4f}  (z vs 20/27 {(rate-P_TRUE)/se:+.2f})  "
          f"exp/attempt {ex:,.0f}  exp per SUCCESS {ex/max(rate,1e-9):,.0f}  "
          f"{time.time()-t0:.0f}s", flush=True)
    return {"nbits": nbits, "b": b, "c": c, "N": len(rows), "f": f, "rate": rate,
            "exp_per_attempt": ex,
            "exp_per_succ": ex / max(rate, 1e-9),
            "rels_per_attempt": b + c,
            "rels_per_succ": (b + c) / max(rate, 1e-9)}


if __name__ == "__main__":
    NT = int(sys.argv[1]) if len(sys.argv) > 1 else 25
    plan = [(45, 20, 10), (50, 30, 10), (55, 40, 10), (60, 55, 10)]
    print("PHASE 1 -- calibration (exponentiations per relation)")
    cal = {}
    for nb, b, c in plan:
        r = calibrate(nb, b)
        if r is None:
            continue
        cal[(nb, b)] = r
        print(f"  n~2^{nb:<3d} b={b:<3d} BB={r['BB']:<5d} u={r['u']:5.2f} "
              f"rho~{r['rho_est']:.3e}  exp/rel {r['per_rel']:,.0f}  "
              f"exp/attempt ~{r['cost_per_attempt']*c/10:,.0f}", flush=True)
    print("\nPHASE 2 -- end-to-end decay curve")
    out = []
    for nb, b, c in plan:
        out.append(run(nb, b, c, NT, 890000 + nb * 100))
        json.dump({"cal": {f"{k[0]}_{k[1]}": v for k, v in cal.items()},
                   "curve": out}, open("scale.json", "w"), indent=1)
    print("\nH4 decay curve (end-to-end)")
    for r in out:
        bar = "#" * int(60 * r["rate"])
        print(f"  2^{r['nbits']:<3d} {r['rate']:.4f} {bar}  "
              f"{r['exp_per_succ']:,.0f} exp/success")