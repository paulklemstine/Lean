"""
exp_main.py -- H0 (baseline reproduction), the alpha_t non-uniformity
re-measurement, and the H2 diagnostic tables.

Runs at r48's own kill-test settings so PREREG-0 is a like-for-like
reproduction, but with MY seeds and MY code path (s2core.attempt, which
re-derives the alpha_t, computes the index h = G/ord(g) itself, and counts a
success only if the returned factor divides n and lies in (1,n)).
"""
from __future__ import annotations

import json
import math
import random
import sys
import time
from collections import Counter, defaultdict
from math import gcd

from s2core import (attempt, bbound_for_b, factor_base, order_mod_n, rand_g,
                    v_p, zeta)
from stange import gen_semiprime
from sympy.ntheory import n_order

SETTINGS = [
    # (nbits, b, c, ntrials)  -- r48 kill_0..4
    (20, 15, 10, 60),
    (26, 8, 5, 60),
    (26, 8, 10, 60),
    (30, 12, 10, 50),
    (40, 20, 10, 30),
]
SEEDS = 77000  # disjoint from r48's seeds (7..11) -- these are FRESH instances


def one(nbits, b, c, seed):
    rng = random.Random(seed)
    n, p, q = gen_semiprime(nbits, rng)
    BB = bbound_for_b(b)
    FB = factor_base(BB, n)
    if len(FB) != b:
        return None
    g = rand_g(n, rng)
    t0 = time.time()
    r = attempt(n, p, q, g, FB, c, rng)
    r["secs"] = round(time.time() - t0, 3)
    r["true"] = (p, q)
    # sanity, never trust an unverified factor
    if r["factor"] is not None:
        assert n % r["factor"] == 0 and 1 < r["factor"] < n
        r["ok"] = True
    return r


def main():
    out = {"settings": [], "rows": []}
    tot_f = tot_n = 0
    # accumulators for the diagnostics
    hsucc = defaultdict(lambda: [0, 0])
    v2succ = defaultdict(lambda: [0, 0])
    v3succ = defaultdict(lambda: [0, 0])
    hvals = Counter()
    div2 = Counter()      # # alpha_t divisible by 2, per trial
    div3 = Counter()
    div5 = Counter()
    hdiv = {2: [0, 0], 3: [0, 0], 5: [0, 0]}   # P(p|h) vs random model p^-c

    for si, (nbits, b, c, nt) in enumerate(SETTINGS):
        t0 = time.time()
        rows = []
        for k in range(nt):
            r = one(nbits, b, c, SEEDS + si * 10000 + k)
            if r is None:
                continue
            rows.append(r)
        facs = sum(1 for r in rows if r["ok"])
        tot_f += facs
        tot_n += len(rows)
        rate = facs / max(len(rows), 1)
        rec = {"nbits": nbits, "b": b, "c": c, "N": len(rows), "facs": facs,
               "rate": rate, "secs": round(time.time() - t0, 1)}
        out["settings"].append(rec)
        out["rows"].extend(rows)
        json.dump(out, open("main.json", "w"))
        print(f"n~2^{nbits:<3d} b={b:<3d} c={c:<3d}: FACTORS {facs}/{len(rows)} "
              f"= {rate:.4f}   ({rec['secs']}s)", flush=True)

        # ---- diagnostics, accumulated only at c == 5 (tables need a fixed c)
        if c == 5:
            for r in rows:
                s = r["ok"]
                h = r["h"] or 1
                hsucc["h=1" if h == 1 else "h>1"][0] += s
                hsucc["h=1" if h == 1 else "h>1"][1] += 1
                hvals[h] += 1
                mv2, mv3 = r["maxv2"], r["maxv3"]
                key2 = "maxv2>=1" if mv2 >= 1 else "maxv2=0"
                v2succ[key2][0] += s
                v2succ[key2][1] += 1
                key3 = "maxv3>=1" if mv3 >= 1 else "maxv3=0"
                v3succ[key3][0] += s
                v3succ[key3][1] += 1
                for d in (2, 3, 5):
                    hdiv[d][0] += (h % d == 0)
                    hdiv[d][1] += 1

    print()
    print("=" * 72)
    print(f"BASELINE (PREREG-0): {tot_f}/{tot_n} = {tot_f/max(tot_n,1):.4f}   "
          f"r48 reported 181/240 = 0.7542")
    print("=" * 72)

    def pr(a, b_):
        return f"{a}/{b_} = {a/max(b_,1):.4f}" if b_ else "n/a"

    print("\nH2 TABLE 1 -- success vs the index h")
    for k in ("h=1", "h>1"):
        a, b_ = hsucc[k]
        print(f"  {k:<6} {pr(a,b_)}")
    print("  (PREREG-3 predicted P(succ|h>1) >= P(succ|h=1); r48's own artifacts"
          " showed the OPPOSITE)")
    print("  h distribution:", dict(sorted(hvals.items())[:14]),
          "... max h =", max(hvals) if hvals else None)

    print("\nH2 TABLE 2 -- success vs v2 of the alpha_t")
    for k in ("maxv2=0", "maxv2>=1"):
        a, b_ = v2succ[k]
        print(f"  {k:<10} {pr(a,b_)}")

    print("\nH2 TABLE 3 -- success vs v3 of the alpha_t")
    for k in ("maxv3=0", "maxv3>=1"):
        a, b_ = v3succ[k]
        print(f"  {k:<10} {pr(a,b_)}")

    print("\nALPHA_T NON-UNIFORMITY (re-measured, not taken from the note)")
    print("  Hypothesis 3.1 model: h = gcd(alpha_1..alpha_c)/ord behaves as the "
          "gcd of c random integers,")
    print("  so P(p|h) should be p^-c for a random p.")
    for p, cnt in hdiv.items():
        obs = cnt[0] / max(cnt[1], 1)
        pred = p ** (-c)
        se = math.sqrt(pred * (1 - pred) / max(cnt[1], 1))
        print(f"  P({p}|h) observed {obs:.5f}  random model {pred:.6f}  "
              f"ratio {obs/pred:5.2f}x   z={(obs-pred)/se:+8.1f}  (N={cnt[1]})")

    json.dump({"hsucc": {k: v for k, v in hsucc.items()},
               "v2succ": {k: v for k, v in v2succ.items()},
               "v3succ": {k: v for k, v in v3succ.items()},
               "hvals": dict(hvals),
               "hdiv": {str(k): v for k, v in hdiv.items()},
               "tot_f": tot_f, "tot_n": tot_n},
              open("diag.json", "w"), indent=1)


if __name__ == "__main__":
    main()