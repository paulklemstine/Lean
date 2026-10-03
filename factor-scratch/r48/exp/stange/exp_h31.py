"""
Hypothesis 3.1 test + end-to-end factor count for Stange arXiv:2211.06821.

Measures, for many random (n, g) at small n:
  h = gcd(alpha_1..alpha_c) / ord(g)     [the index, Algorithm 2.2]
and compares P(h == 1) to the two competing predictions:
  pred_paper(c)   = 1 - 1/zeta(c+1)      (Hypothesis 3.1 AS PRINTED, p.4)
  pred_correct(c) = 1/zeta(c+1)          (P(gcd of c+1 random ints = 1))

Also runs the END-TO-END factor test and the extrapolation-gap table.
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

from stange import (alg22, bbound_for_b, build_M, factor_base, find_relations,
                    gen_semiprime, index_S_full, kernel_basis, order_mod_n,
                    pred_correct, pred_paper, primitive, zeta)
from dickman import rho
from sympy.ntheory import n_order


def alpha_index(n, p, q, g, b, c, rng):
    """Algorithm 2.2 exactly: b+c relations, kernel of M over Q, primitive
    basis, alpha_t = sum_j (b_t)_j x_j, G = gcd, h = G / ord(g)."""
    FB = factor_base(bbound_for_b(b), n)
    if len(FB) != b:
        return None
    rels, trials = find_relations(n, g, FB, b + c, rng, "random")
    M = build_M(rels, b)
    K, rank = kernel_basis(M)
    if len(K) < c:
        return None
    xs = [rels[j][1] for j in range(len(rels))]
    betas = [sum(primitive(v)[j] * xs[j] for j in range(len(rels))) for v in K[:c]]
    G = 0
    for a in betas:
        G = gcd(G, abs(a))
    if G == 0:
        return {"h": 0, "G": 0, "nzero": sum(1 for a in betas if a == 0),
                "dimK": len(K), "rank": rank, "trials": trials}
    og = math.lcm(int(n_order(g, p)), int(n_order(g, q)))
    if G % og != 0:
        return None
    return {"h": G // og, "G": G, "ord_g": og, "nzero": sum(1 for a in betas if a == 0),
            "dimK": len(K), "rank": rank, "trials": trials}


def sample_setting(nbits, b, c, ntrials, seed0=0, timeout_each=300):
    rng_master = random.Random(seed0)
    rows, skips, factors = [], 0, 0
    t0 = time.time()
    for t in range(ntrials):
        if time.time() - t0 > timeout_each:
            break
        n, p, q = gen_semiprime(nbits, rng_master)
        g = rng_master.randrange(2, n)
        while gcd(g, n) != 1:
            g = rng_master.randrange(2, n)
        try:
            r = alpha_index(n, p, q, g, b, c, rng_master)
        except RuntimeError:
            skips += 1
            continue
        if r is None:
            skips += 1
            continue
        r.update(n=n, p=p, q=q, g=g, b=b, c=c)
        rows.append(r)
        if r["h"] == 1:
            factors += 1
    return {"nbits": nbits, "b": b, "c": c, "rows": rows, "skips": skips,
            "n": len(rows), "h1": factors,
            "pred_paper": pred_paper(c), "pred_correct": pred_correct(c)}


def sigma_test(k, N, p):
    """deviation in sigma of an observed count k out of N against probability p."""
    if N == 0:
        return float("inf")
    exp = N * p
    sd = math.sqrt(max(N * p * (1 - p), 1e-12))
    return (k - exp) / sd


if __name__ == "__main__":
    mode = sys.argv[1] if len(sys.argv) > 1 else "h31"
    if mode == "h31":
        # c is the paper's suggested value; also scan c to test the whole curve.
        settings = [
            dict(nbits=26, b=8,  c=5,  ntrials=300),
            dict(nbits=26, b=8,  c=10, ntrials=300),
            dict(nbits=30, b=12, c=10, ntrials=300),
            dict(nbits=30, b=12, c=20, ntrials=300),
            dict(nbits=34, b=16, c=10, ntrials=200),
        ]
        out = []
        for i, s in enumerate(settings):
            t0 = time.time()
            res = sample_setting(seed0=1000 + i, **s)
            res["secs"] = round(time.time() - t0, 1)
            out.append(res)
            N, k = res["n"], res["h1"]
            print(f"n~2^{s['nbits']} b={s['b']} c={s['c']}: "
                  f"P(h=1)={k}/{N}={k/max(N,1):.4f}  "
                  f"paper(1-1/zeta)={res['pred_paper']:.4f} "
                  f"({sigma_test(k, N, res['pred_paper']):+.1f}s)  "
                  f"correct(1/zeta)={res['pred_correct']:.4f} "
                  f"({sigma_test(k, N, res['pred_correct']):+.1f}s)  "
                  f"skips={res['skips']} {res['secs']}s", flush=True)
            with open(f"h31_{i}.json", "w") as f:
                json.dump(res, f)
        print("done")
