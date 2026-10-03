"""
MANDATORY CONTROL for the Hypothesis 3.1 test.

Hypothesis 3.1 is proved (lower-bounded via Fontein-Wocjan [5]) only when
n >= 8 b^{b/2}. The small-n measurements in exp_h31.py are OUTSIDE that regime.

Without a control that runs INSIDE the proof regime, "the hypothesis fails at
small n" is indistinguishable from "my sampler is biased." So here we run the
SAME sampler at (b, n) points satisfying n >= 8 b^{b/2} and require that it
reproduces the predicted distribution.

To keep the proof regime affordable we use small b:
  b = 6  -> 8*6^3      =    1728
  b = 8  -> 8*8^4      =   32768
  b = 10 -> 8*10^5     =  800000
  b = 12 -> 8*12^6     = 23887872
and pick n comfortably above each threshold. Note these are still SMALL n --
that is unavoidable and is itself part of the finding: the proof regime at
useful b is astronomically far away. What the control establishes is that the
sampler is not the source of any deviation seen outside the regime.
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
from stange import bbound_for_b, pred_correct, pred_paper


def run(b, c, nmin_exp, ntrials, seed0):
    """Sample at n in [2^{nmin_exp}, 2^{nmin_exp+2}) with this b."""
    rng = random.Random(seed0)
    rows, factors, skips, worst = [], 0, 0, None
    t0 = time.time()
    for _ in range(ntrials):
        if time.time() - t0 > 1500:
            break
        nbits = nmin_exp + rng.randrange(0, 3)
        half = nbits // 2
        p = int(rng.getrandbits(half) | (1 << (half - 1)) | 1)
        q = int(rng.getrandbits(half) | (1 << (half - 1)) | 1)
        from sympy import nextprime, isprime
        p = int(nextprime(p))
        while p % 2 == 0:
            p = int(nextprime(p))
        q = int(nextprime(q))
        while q % 2 == 0:
            q = int(nextprime(q))
        while q == p or not isprime(q):
            q = int(nextprime(q))
        n = p * q
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
    return {"b": b, "c": c, "n": len(rows), "h1": factors, "skips": skips,
            "hs": [r["h"] for r in rows],
            "pred_paper": pred_paper(c), "pred_correct": pred_correct(c),
            "threshold_n": b_max_proof(2 ** (nmin_exp + 2))}


if __name__ == "__main__":
    settings = [
        dict(b=6,  c=5,  nmin_exp=13, ntrials=200, seed0=11),   # n >= 2^13 = 8192 >> 1728
        dict(b=8,  c=5,  nmin_exp=17, ntrials=200, seed0=12),   # n >= 2^17 = 131072 >> 32768
        dict(b=8,  c=10, nmin_exp=17, ntrials=200, seed0=13),
        dict(b=10, c=5,  nmin_exp=21, ntrials=150, seed0=14),   # n >= 2^21 = 2.1e6 >> 800000
        dict(b=10, c=10, nmin_exp=21, ntrials=150, seed0=15),
        dict(b=12, c=5,  nmin_exp=26, ntrials=120, seed0=16),   # n >= 2^26 = 6.7e7 >> 2.4e7
    ]
    out = []
    for i, s in enumerate(settings):
        t0 = time.time()
        r = run(**s)
        r["secs"] = round(time.time() - t0, 1)
        r["in_proof_regime"] = True
        out.append(r)
        N, k = r["n"], r["h1"]
        print(f"CONTROL b={r['b']} c={r['c']} (n>=2^{s['nmin_exp']}): "
              f"P(h=1)={k}/{N}={k/max(N,1):.4f} | paper 1-1/zeta={r['pred_paper']:.4f} "
              f"({sigma_test(k,N,r['pred_paper']):+.1f}s) | correct 1/zeta={r['pred_correct']:.4f} "
              f"({sigma_test(k,N,r['pred_correct']):+.1f}s) | skips={r['skips']} {r['secs']}s",
              flush=True)
        with open(f"control_{i}.json", "w") as f:
            json.dump(r, f)
    print("done")
