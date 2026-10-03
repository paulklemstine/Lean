"""
THE RIGOROUS CONTROL: c = b + 1, inside the proved regime.

Stange p.4 verbatim: "If b and n satisfy the relationship n >= 8b^{b/2} as n
tends to infinity, then taking c = b + 1, it is known that the probability has
a lower bound [5, Theorem 1.1]."

So the PROVED regime is the PAIR (n >= 8 b^{b/2}, c = b+1) -- i.e. 2b+1
relations collected. The earlier control (exp_control.py) used c=5 and c=10 at
varying b and therefore sat in the n-condition but NOT the c-condition. This
script runs the actual proved configuration.

Prediction in that regime: P(h=1) should be at least the Fontein-Wocjan lower
bound, and the heuristic target is 1 - 1/zeta(c+1) = 1/zeta(b+2).
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

from exp_h31 import alpha_index, sigma_test
from exp_gap import b_max_proof
from stange import pred_correct, pred_paper
from sympy import nextprime, isprime


def run(b, nmin_exp, ntrials, seed0, time_cap=900):
    """c = b+1 exactly, n in [2^nmin_exp, 2^nmin_exp+2) with n >= 8 b^{b/2}."""
    c = b + 1
    rng = random.Random(seed0)
    rows, factors, skips = [], 0, 0
    t0 = time.time()
    thr = 8.0 * b ** (b / 2.0)
    while True:
        for _ in range(ntrials):
            if time.time() - t0 > time_cap:
                break
            nbits = nmin_exp + rng.randrange(0, 3)
            half = nbits // 2
            p = int(nextprime(rng.getrandbits(half) | (1 << (half - 1)) | 1))
            q = int(nextprime(rng.getrandbits(half) | (1 << (half - 1)) | 1))
            while q % 2 == 0:
                q = int(nextprime(q))
            while q == p or not isprime(q):
                q = int(nextprime(q))
            n = p * q
            if n < thr:          # MUST satisfy the proof regime's n-condition
                continue
            g = rng.randrange(2, n)
            while gcd(g, n) != 1:
                g = rng.randrange(2, n)
            try:
                r = alpha_index(n, p, q, g, b, c, rng)
            except RuntimeError:
                skips += 1
                continue
            if r is None:
                skips += 1
                continue
            rows.append(r)
            if r["h"] == 1:
                factors += 1
        if time.time() - t0 > time_cap:
            break
        if len(rows) >= 20:
            break
    return {"b": b, "c": c, "n": len(rows), "h1": factors, "skips": skips,
            "hs": [r["h"] for r in rows], "pred_paper": pred_paper(c),
            "pred_correct": pred_correct(c), "threshold_n": thr,
            "nmin_exp": nmin_exp}


if __name__ == "__main__":
    # (b, 2^nmin_exp chosen so that 2^nmin_exp comfortably exceeds 8 b^{b/2})
    settings = [
        (4, 12), (5, 13), (6, 14), (8, 17), (10, 21), (12, 26),
    ]
    out = []
    for i, (b, ne) in enumerate(settings):
        t0 = time.time()
        r = run(b, ne, 150, seed0=200 + i)
        r["secs"] = round(time.time() - t0, 1)
        r["c_is_b_plus_1"] = True
        out.append(r)
        N, k = r["n"], r["h1"]
        ok_regime = (2 ** ne) >= r["threshold_n"]
        print(f"CTL c=b+1: b={b} c={r['c']} n>=2^{ne} (thr 8b^({b}/2)={r['threshold_n']:.3g}, "
              f"regime_ok={ok_regime}): P(h=1)={k}/{N}={k/max(N,1):.4f} | "
              f"paper 1-1/zeta={r['pred_paper']:.4f} ({sigma_test(k,N,r['pred_paper']):+.1f}s) | "
              f"1/zeta={r['pred_correct']:.4f} ({sigma_test(k,N,r['pred_correct']):+.1f}s) "
              f"| {r['secs']}s", flush=True)
        with open(f"controlB_{i}.json", "w") as f:
            json.dump(r, f)
    print("done")
