"""
exp_cost.py -- PREREG-6.  The structural cost reduction.

Since factor_from_multiple() strips G down to ord(g) EXACTLY (self-test T7),
the index h = G/ord(g) is erased before the gcd.  Therefore:

  * the per-attempt success rate is 20/27 regardless of the relation set
    (exp_order.py, 33 000 instances, flat from 2^20 to 2^200), and
  * it is INDEPENDENT of c.  The relations still must be found, so the
    cost per attempt is (b + c) relations and the cost per SUCCESSFUL factor is
    (b + c) / P = (b + c) * 27/20.

So the whole optimisation problem is: minimise (b + c).  The paper uses c = 10,
which buys nothing, because the index it is buying accuracy on gets stripped.

This script measures:
  PART A  success rate vs c  -- preregistered FLAT (PREREG-6)
  PART B  success rate vs b  -- preregistered FLAT
  PART C  cost per successful factor = (b+c)/P, plus measured exponentiation
          cost per relation, and a b-sweep of the FULL cost
          (b+c)/P * (1/rho) i.e. (b+c) * trials/relations per attempt.

Everything uses the bounded stripper (validated == full stripper in T8), which
is what makes c = 1 usable at all: with c=1, G is a single large alpha and
factorint(G) would be intractable.
"""
from __future__ import annotations

import json
import math
import random
import sys
import time
from collections import defaultdict

from s2core import attempt, bbound_for_b, factor_base, order_mod_n, rand_g
from stange import gen_semiprime

P_TRUE = 20.0 / 27.0     # exact order-step success probability


def trial(nbits, b, c, seed):
    rng = random.Random(seed)
    n, p, q = gen_semiprime(nbits, rng)
    FB = factor_base(bbound_for_b(b), n)
    if len(FB) != b:
        return None
    g = rand_g(n, rng)
    t0 = time.time()
    r = attempt(n, p, q, g, FB, c, rng, strip="bounded")
    r["secs"] = time.time() - t0
    if r["factor"] is not None:
        assert n % r["factor"] == 0 and 1 < r["factor"] < n
    return r


def sweep(nbits, b, cs, nt, seed0, label):
    print(f"\n--- {label}: n~2^{nbits}, b={b} (factor base bound "
          f"{bbound_for_b(b)}) ---")
    print(f"{'c':>3} {'N':>5} {'factors':>9} {'rate':>7} {'z vs 20/27':>11} "
          f"{'rels/att':>9} {'rels per SUCCESS':>16} {'exp/rel':>8} "
          f"{'exp per SUCCESS':>16} {'secs':>7}")
    rows = []
    for c in cs:
        t0 = time.time()
        rs = [trial(nbits, b, c, seed0 + 1000 * c + k) for k in range(nt)]
        rs = [r for r in rs if r]
        f = sum(1 for r in rs if r["factor"] is not None)
        rate = f / max(len(rs), 1)
        se = math.sqrt(P_TRUE * (1 - P_TRUE) / max(len(rs), 1))
        ex = sum(r["trials"] for r in rs) / max(len(rs), 1)
        rows.append({"c": c, "N": len(rs), "f": f, "rate": rate,
                     "rels": b + c, "rels_per_succ": (b + c) / max(rate, 1e-9),
                     "exp_per_rel": ex / (b + c), "exp": ex,
                     "exp_per_succ": ex / max(rate, 1e-9),
                     "secs": round(time.time() - t0, 1)})
        rr = rows[-1]
        print(f"{c:>3} {rr['N']:>5} {f:>5}/{len(rs):<3} {rate:>7.4f} "
              f"{(rate-P_TRUE)/se:>+11.2f} {b+c:>9} {rr['rels_per_succ']:>16.1f} "
              f"{rr['exp_per_rel']:>8.0f} {rr['exp_per_succ']:>16.0f} "
              f"{rr['secs']:>7.1f}", flush=True)
    return rows


if __name__ == "__main__":
    NT = int(sys.argv[1]) if len(sys.argv) > 1 else 120
    out = {}
    print(f"PREREG-6 reference: P(success) = 20/27 = {P_TRUE:.6f}, "
          f"predicted FLAT in c and in b.")
    out["A_c_sweep_2^30_b12"] = sweep(30, 12, [1, 2, 3, 5, 8, 10, 15], NT,
                                      510000, "PART A: c-sweep")
    out["A2_c_sweep_2^26_b8"] = sweep(26, 8, [1, 2, 5, 10], NT, 520000,
                                      "PART A2: c-sweep, smaller b")
    out["B_b_sweep_2^30_c1"] = sweep(30, 6, [1], NT, 530000,
                                     "PART B: b=6, c=1")
    out["B_b_sweep_2^30_c1b2"] = sweep(30, 20, [1], NT, 540000,
                                       "PART B: b=20, c=1")
    json.dump(out, open("cost.json", "w"), indent=1)
    print("\ndone")