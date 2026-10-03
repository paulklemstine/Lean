#!/usr/bin/env python3.12
"""THE FIT, done correctly given the per-N variance finding.

04_perN.py showed the scan rate is NOT a function of N: at 32 bits, 14 of 20
semiprimes give ZERO relations in 15000 instances, and the spread across N is larger
than Poisson.  So:

  * F(N) must be averaged over MANY N per size (the file used ONE).
  * The uncertainty must include the N-to-N spread, not just Poisson.
  * The file's three points must be re-derived as single draws from this
    distribution -- which is what they are.

Reports, per bit size: box rate (very well determined), scan rate averaged over K
distinct N, F, and a CI that propagates BOTH the Poisson error and the across-N
variability (bootstrap over N).
"""
from __future__ import annotations

import json
import math
import os
import random
import sys
import time
from multiprocessing import Pool

sys.path.insert(0, "/home/raver1975/lean/factor-scratch/r49/exp/supply")
import S_common as S

SEED = 20261003
BITS = [int(x) for x in os.environ.get("BITS", "20,24,28,32,36").split(",")]
K_N = int(os.environ.get("K_N", "24"))          # distinct semiprimes per size
INST = int(os.environ.get("INST", "15000"))     # m-instances per N
WORKERS = int(os.environ.get("WORKERS", "6"))


def one_size(args):
    bits, seed = args
    rng = random.Random(seed)
    ps = [x for x in S.prime_3mod4((1 << (bits // 2 - 1)) | 1, 1 << (bits // 2))
          if x > 3]
    pq = [(p, q) for p in ps for q in ps if p < q
          and (1 << (bits - 1)) <= p * q < (1 << bits)]
    rng.shuffle(pq)
    pq = pq[:K_N]
    per_N_scan, per_N_box = [], []
    for (p, q) in pq:
        N = p * q
        m0 = S.icbrt_floor(N)
        ms = [m0 + rng.randrange(m0 + 1) for _ in range(INST)]
        cs = []
        for m in ms:
            v = (m * m * m) % N
            cs.append(v - N if v > N // 2 else v)
        csb = [S.CPOOL[rng.randrange(16)] for _ in range(INST)]
        c1, _ = S.rels_batch(ms, cs)
        c2, _ = S.rels_batch(ms, csb)
        per_N_scan.append(sum(c1) / INST)
        per_N_box.append(sum(c2) / INST)
    return dict(bits=bits, scan=per_N_scan, box=per_N_box, nN=len(pq))


def boot_mean_ci(v, nboot=4000, seed=1):
    """Bootstrap CI for the MEAN of a heavy-tailed sample (many exact zeros)."""
    rng = random.Random(seed)
    n = len(v)
    means = []
    for _ in range(nboot):
        means.append(sum(v[rng.randrange(n)] for _ in range(n)) / n)
    means.sort()
    return means[int(0.025 * nboot)], means[int(0.975 * nboot)]


if __name__ == "__main__":
    t0 = time.time()
    print("=" * 104)
    print("F(N) AVERAGED OVER %d DISTINCT SEMIPRIMES PER SIZE, %d instances each"
          % (K_N, INST))
    print("seed = %d" % SEED)
    print("=" * 104)
    print("%5s %4s %10s %10s %12s %12s %11s %11s %22s %7s"
          % ("bits", "#N", "scan mean", "scan median", "box mean", "F", "F lo", "F hi",
             "N giving ZERO", "t"))
    out = []
    with Pool(WORKERS) as pool:
        for r in pool.imap_unordered(one_size, [(b, SEED + 31 * b) for b in BITS]):
            out.append(r)
    out.sort(key=lambda r: r["bits"])
    for r in out:
        b = r["bits"]
        sm = sum(r["scan"]) / len(r["scan"])
        smed = sorted(r["scan"])[len(r["scan"]) // 2]
        bm = sum(r["box"]) / len(r["box"])
        z = sum(1 for x in r["scan"] if x == 0)
        lo, hi = boot_mean_ci(r["scan"], seed=b)
        F = bm / sm if sm > 0 else float("inf")
        F_lo = bm / hi if hi > 0 else float("inf")
        F_hi = bm / lo if lo > 0 else float("inf")
        r["F"] = F
        print("%5d %4d %10.4e %10.4e %12.5e %11.4g %11.4g %11.4g %10d/%-9d %7.0f"
              % (b, r["nN"], sm, smed, bm, F, F_lo, F_hi, z, r["nN"],
                 time.time() - t0), flush=True)

    json.dump(out, open("/home/raver1975/lean/factor-scratch/r49/exp/supply/"
                        "05_fit.json", "w"), indent=1)

    # ---------------- the fit -------------------------------------------
    print()
    print("=" * 104)
    print("FIT alpha:  log F = alpha * log N + c      (F = box rate / scan rate)")
    print("=" * 104)
    pts = [(r["bits"], r["F"]) for r in out if r["F"] > 0 and math.isfinite(r["F"])]
    print("points (bits, F): " + ", ".join("%d:%.4g" % p for p in pts))
    X = [b * math.log(2.0) for b, _ in pts]
    Y = [math.log(F) for _, F in pts]
    n = len(X)
    mx = sum(X) / n
    my = sum(Y) / n
    sxx = sum((x - mx) ** 2 for x in X)
    sxy = sum((x - mx) * (y - my) for x, y in zip(X, Y))
    alpha = sxy / sxx
    c = my - alpha * mx
    resid = [y - (c + alpha * x) for x, y in zip(X, Y)]
    s2 = sum(r * r for r in resid) / max(1, n - 2)
    se = math.sqrt(s2 / sxx)
    # per-point sigma from the bootstrap CI on the mean scan rate
    sig = []
    for r in out:
        if r["F"] > 0 and math.isfinite(r["F"]):
            lo, hi = boot_mean_ci(r["scan"], seed=r["bits"])
            bm = sum(r["box"]) / len(r["box"])
            fl, fh = bm / hi, bm / lo
            sig.append(max(math.log(fh) - math.log(r["F"]),
                           math.log(r["F"]) - math.log(fl)) / 1.96 if fl > 0 else 1.0)
    w = [1.0 / (s * s) for s in sig]
    Sw = sum(w)
    mxw = sum(wi * xi for wi, xi in zip(w, X)) / Sw
    myw = sum(wi * yi for wi, yi in zip(w, Y)) / Sw
    sxxw = sum(wi * (xi - mxw) ** 2 for wi, xi in zip(w, X))
    sxyw = sum(wi * (xi - mxw) * (yi - myw) for wi, xi, yi in zip(w, X, Y))
    aw = sxyw / sxxw
    cw = myw - aw * mxw
    sew = 1.0 / math.sqrt(sxxw)
    print("n points = %d" % n)
    print("alpha (OLS)              = %+.4f  +- %.4f   2se [%+.4f, %+.4f]  dof=%d"
          % (alpha, se, alpha - 2 * se, alpha + 2 * se, n - 2))
    print("alpha (inverse-var)      = %+.4f  +- %.4f   2se [%+.4f, %+.4f]"
          % (aw, sew, aw - 2 * sew, aw + 2 * sew))
    for (b, F), x, y, r in zip(pts, X, Y, resid):
        print("   bits %2d  F=%12.5g  fitted %12.5g  resid %+8.4f (%.2f sigma)"
              % (b, F, math.exp(c + alpha * x), r, r / (se * math.sqrt(sxx))))
    print()
    print("PREREGISTERED PREDICTION (00_PREREG.md): alpha POSITIVE, in [0.3, 0.6].")
    lo2, hi2 = aw - 2 * sew, aw + 2 * sew
    if lo2 > 0:
        print("VERDICT: alpha is POSITIVE at 2se -> the exponent -(1/6) does NOT survive.")
    elif hi2 < 0:
        print("VERDICT: alpha is NEGATIVE at 2se -> H REFUTED, F shrinks with N.")
    else:
        print("VERDICT: alpha is NOT distinguishable from 0 -> F is CONSTANT, "
              "the exponent -(1/6) survives.")
    inrange = (aw - 2 * sew) <= 0.6 and (aw + 2 * sew) >= 0.3
    print("within the preregistered [0.3,0.6] range: %s" % inrange)
    print()
    print("TRUE SUPPLY EXPONENT  -(1/6 + alpha):")
    print("   from OLS          : %+.4f" % (-(1.0 / 6.0 + alpha)))
    print("   from inverse-var  : %+.4f  +- %.4f" % (-(1.0 / 6.0 + aw), sew))
    print("   the record's box exponent is -1/6 = -0.1667")
    print("\n[secs %.1f]" % (time.time() - t0))
