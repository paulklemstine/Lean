#!/usr/bin/env python3.12
"""THE MEASUREMENT: F(N) = box_rate / scan_rate across bit sizes, plus the
decomposition of the mechanism.

Arms (identical N, identical m-distribution, identical H, identical l(m), identical
exact isqrt -- they differ ONLY in where c comes from):

  BOX  : m ~ U[m0, 2 m0],  c ~ Uniform(CPOOL)            (m ~ N^(1/3), |c| <= 31)
  SCAN : m ~ U[m0, 2 m0],  c := m^3 mod N, centred       (|c| ~ N/3)

m0 = floor(N^(1/3)).  This is exactly the A/B contrast of ~/factor47/V4/T1exact.py,
which is where the file's "47x (24 bits) to 326x (32 bits)" comes from.

Everything is EXACT integer arithmetic (math.isqrt) with the QR prefilter verified
lossless by 01_selftest.py.  Sample sizes are set by TARGET EVENTS, not by a fixed
trial count, because the scan rate falls by ~N^(-2/3) and a fixed trial count starves
at 32 bits -- which is what produced the file's 5-event 32-bit point.

DECOMPOSITION.  To separate a CONSTANT pool-selection bias from a SIZE-DEPENDENT one,
the pool is varied at fixed m while |c| is independently varied:

  (D1) pool composition:  CPOOL (16 hand-picked) vs ALL of [1,31] vs random 16-subsets
                          of [1,31].  Any change here is a CONSTANT factor.
  (D2) |c| scale:         c ~ U[1, s] for s = 31, 10^2, ..., at ONE fixed N.
                          rate ~ |c|^(-beta).  This is the size-dependent part, and
                          alpha is predicted to equal beta.
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
TARGET = int(os.environ.get("TARGET", "600"))     # target scan events per bit size
WORKERS = int(os.environ.get("WORKERS", "6"))
BITS = [int(x) for x in os.environ.get("BITS", "20,24,28,32,36").split(",")]


def poisson_ci(k, alpha=0.05):
    """Exact (Garwood) Poisson confidence interval for a mean, via chi2 quantiles."""
    from scipy.stats import chi2
    lo = 0.0 if k == 0 else chi2.ppf(alpha / 2, 2 * k) / 2.0
    hi = chi2.ppf(1 - alpha / 2, 2 * k + 2) / 2.0
    return lo, hi


def scan_and_box(args):
    """One (bits, n_inst, seed) job.  Returns counts for both arms, summed over
    SEVERAL distinct semiprimes N at this size (the file used one N per size, which
    it listed as a caveat; multiple N removes that confound)."""
    bits, n_inst, seed = args
    rng = random.Random(seed)
    n_distinct = 8
    per_N = max(1, n_inst // n_distinct)
    S.prime_3mod4(1 << (bits // 2 - 1), 1 << (bits // 2))
    ps = [x for x in S.prime_3mod4((1 << (bits // 2 - 1)) | 1, 1 << (bits // 2))
          if x > 3]
    pq = [(p, q) for p in ps for q in ps if p < q
          and (1 << (bits - 1)) <= p * q < (1 << bits)]
    if not pq:
        return None
    rng.shuffle(pq)
    pq = pq[:n_distinct]

    tot_scan = tot_box = 0
    n_used = 0
    for (p, q) in pq:
        N = p * q
        m0 = S.icbrt_floor(N)
        ms = [m0 + rng.randrange(m0 + 1) for _ in range(per_N)]
        cs_scan = []
        for m in ms:
            v = (m * m * m) % N
            cs_scan.append(v - N if v > N // 2 else v)
        cs_box = [S.CPOOL[rng.randrange(16)] for _ in range(per_N)]
        c_scan, _ = S.rels_batch(ms, cs_scan)
        c_box, _ = S.rels_batch(ms, cs_box)
        tot_scan += sum(c_scan)
        tot_box += sum(c_box)
        n_used += per_N
    return dict(bits=bits, n_inst=n_used, n_N=len(pq), rel_scan=tot_scan,
                rel_box=tot_box)


def decompose_cscale(args):
    """(D2) rate as a function of |c| at ONE fixed N.  Isolates the size-dependent
    mechanism from the pool composition."""
    bits, seed = args
    rng = random.Random(seed)
    N, p, q = S.make_semiprime(bits, rng)
    m0 = S.icbrt_floor(N)
    out = []
    n_per = 4000
    ms = [m0 + rng.randrange(m0 + 1) for _ in range(n_per)]
    for s in (31, 100, 316, 1000, 3162, 10000, 31623, 100000, 316228, 1000000):
        if s > N:
            break
        cs = [rng.randrange(1, s + 1) for _ in range(n_per)]
        cnt, _ = S.rels_batch(ms, cs)
        out.append(dict(bits=bits, cscale=s, n=n_per, rel=sum(cnt)))
    return out


def decompose_pool(args):
    """(D1) pool composition at fixed |c| scale.  Any variation is a CONSTANT."""
    bits, seed = args
    rng = random.Random(seed)
    N, p, q = S.make_semiprime(bits, rng)
    m0 = S.icbrt_floor(N)
    n_per = 8000
    ms = [m0 + rng.randrange(m0 + 1) for _ in range(n_per)]
    out = []
    pools = {
        "CPOOL(16 hand-picked)": list(S.CPOOL),
        "all of [1,31] (31)": list(range(1, 32)),
        "random16 #1": sorted(rng.sample(range(1, 32), 16)),
        "random16 #2": sorted(rng.sample(range(1, 32), 16)),
        "even only [2,30] (15)": list(range(2, 31, 2)),
        "primes<=31 (11)": [2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31],
    }
    for name, pool in pools.items():
        cs = [pool[rng.randrange(len(pool))] for _ in range(n_per)]
        cnt, _ = S.rels_batch(ms, cs)
        out.append(dict(bits=bits, pool=name, size=len(pool), n=n_per, rel=sum(cnt)))
    return out


if __name__ == "__main__":
    t00 = time.time()
    print("=" * 96)
    print("MEASUREMENT 1 -- F(N) = box_rate / scan_rate.  seed=%d, target>=%d scan events"
          % (SEED, TARGET))
    print("=" * 96)
    print("%5s %8s %5s %10s %10s %14s %14s %14s %14s %8s"
          % ("bits", "inst", "#N", "rel_scan", "rel_box", "scan rate", "box rate",
             "F", "F 95% CI", "inferred a"))

    # size the job: pilot at 32 bits to get the scan rate, then scale.
    rows = []
    jobs = []
    for bits in BITS:
        # crude a-priori guess, refined by the pilot below
        guess = 3.0e-2 * (2.0 ** (bits - 20)) ** (-0.6)
        n = int(min(4_000_000, max(20_000, TARGET / max(guess, 1e-7))))
        jobs.append((bits, n, SEED + bits))
    with Pool(WORKERS) as pool:
        for res in pool.imap_unordered(scan_and_box, jobs):
            rows.append(res)
    rows.sort(key=lambda r: r["bits"])

    for r in rows:
        bits = r["bits"]
        n = r["n_inst"]
        rs, rb = r["rel_scan"], r["rel_box"]
        rate_s, rate_b = rs / n, rb / n
        F = rate_b / rate_s if rate_s > 0 else float("inf")
        lo_s, hi_s = poisson_ci(rs)
        lo_b, hi_b = poisson_ci(rb)
        # F CI: box is essentially exact (thousands of events); scan is Poisson
        F_lo = (rb / n) / (hi_s / n) if hi_s > 0 else float("nan")
        F_hi = (rb / n) / (lo_s / n) if lo_s > 0 else float("inf")
        print("%5d %8d %5d %10d %10d %14.5e %14.5e %14.2f [%8.1f,%9.1f] %8s"
              % (bits, n, r["n_N"], rs, rb, rate_s, rate_b, F, F_lo, F_hi, "-"),
              flush=True)

    json.dump(rows, open("/home/raver1975/lean/factor-scratch/r49/exp/supply/"
                         "03_measure.json", "w"), indent=1)

    # ---- fit alpha -------------------------------------------------------
    print()
    print("=" * 96)
    print("FIT: log F vs log N   (unweighted least squares, and a Poisson-weighted version)")
    print("=" * 96)
    xs, ys, sig = [], [], []
    for r in rows:
        if r["rel_scan"] <= 0:
            continue
        xs.append(math.log(2.0 ** r["bits"]))
        ys.append(math.log(r["rel_box"] / r["rel_scan"]))
        # sigma of log F from the scan Poisson error only
        sig.append(1.0 / math.sqrt(r["rel_scan"]))
    n = len(xs)
    if n >= 3:
        mx = sum(xs) / n
        my = sum(ys) / n
        sxx = sum((x - mx) ** 2 for x in xs)
        sxy = sum((x - mx) * (y - my) for x, y in zip(xs, ys))
        alpha = sxy / sxx
        # slope standard error
        resid = [y - (my + alpha * (x - mx)) for x, y in zip(xs, ys)]
        s2 = sum(r * r for r in resid) / (n - 2)
        se = math.sqrt(s2 / sxx)
        # weighted (inverse-variance) fit
        w = [1.0 / (sg * sg) for sg in sig]
        Sw = sum(w)
        mxw = sum(wi * xi for wi, xi in zip(w, xs)) / Sw
        myw = sum(wi * yi for wi, yi in zip(w, ys)) / Sw
        sxxw = sum(wi * (xi - mxw) ** 2 for wi, xi in zip(w, xs))
        sxyw = sum(wi * (xi - mxw) * (yi - myw) for wi, xi, yi in zip(w, xs, ys))
        aw = sxyw / sxxw
        sew = 1.0 / math.sqrt(sxxw)
        print("n points = %d, bit sizes = %s" % (n, [r["bits"] for r in rows]))
        print("alpha (unweighted) = %+.4f  +- %.4f  (2se [%+.4f, %+.4f])  dof=%d"
              % (alpha, se, alpha - 2 * se, alpha + 2 * se, n - 2))
        print("alpha (Poisson-weighted) = %+.4f  +- %.4f" % (aw, sew))
        print()
        print("PREDICTED BEFORE MEASURING (00_PREREG.md): alpha POSITIVE, in [0.3, 0.6]")
        verdict = "CONFIRMED" if 0.3 <= alpha <= 0.6 and alpha - 2 * se > 0 else \
                  ("REFUTED: alpha not positive" if alpha + 2 * se <= 0 else
                   "REFUTED: alpha outside the preregistered range")
        print("VERDICT ON H: %s" % verdict)
        print()
        print("true supply exponent (1/6 + alpha):")
        print("   unweighted   : %+.4f" % (1.0 / 6.0 + alpha))
        print("   weighted     : %+.4f" % (1.0 / 6.0 + aw))
        print("   the record's box exponent is -1/6 = -0.1667")

    # ---- decompositions --------------------------------------------------
    print()
    print("=" * 96)
    print("DECOMPOSITION D2: rate vs |c| at fixed N (isolates the SIZE-DEPENDENT part)")
    print("=" * 96)
    with Pool(min(WORKERS, 3)) as pool:
        d2 = pool.map(decompose_cscale, [(24, SEED + 1), (32, SEED + 2), (40, SEED + 3)])
    flat = [row for grp in d2 for row in grp]
    print("%6s %12s %10s %12s %14s" % ("bits", "c scale", "inst", "relations", "rate"))
    for row in flat:
        print("%6d %12d %10d %12d %14.5e"
              % (row["bits"], row["cscale"], row["n"], row["rel"],
                 row["rel"] / row["n"]))
    # fit beta = -dlog(rate)/dlog(cscale), separately per bit size
    print()
    print("beta = -dlog(rate)/dlog|c|, fitted per bit size (only rows with rel>0):")
    for grp in d2:
        g = [r for r in grp if r["rel"] > 0 and r["rel"] >= 20]
        if len(g) < 3:
            continue
        X = [math.log(r["cscale"]) for r in g]
        Y = [math.log(r["rel"] / r["n"]) for r in g]
        nn = len(X)
        mxx = sum(X) / nn
        myy = sum(Y) / nn
        sxx = sum((x - mxx) ** 2 for x in X)
        sxy = sum((x - mxx) * (y - myy) for x, y in zip(X, Y))
        b = sxy / sxx
        print("   bits=%2d  n=%2d  beta = %+.4f   (alpha predicted to equal this)"
              % (grp[0]["bits"], nn, b))

    print()
    print("=" * 96)
    print("DECOMPOSITION D1: POOL COMPOSITION at fixed |c| scale (the CONSTANT part)")
    print("=" * 96)
    with Pool(min(WORKERS, 3)) as pool:
        d1 = pool.map(decompose_pool, [(24, SEED + 11), (32, SEED + 12)])
    print("%6s %26s %6s %10s %12s %10s"
          % ("bits", "pool", "size", "inst", "relations", "rate"))
    for grp in d1:
        base = None
        for row in grp:
            rt = row["rel"] / row["n"]
            if base is None:
                base = rt
            print("%6d %26s %6d %10d %12d %10.5f  (x%.3f)"
                  % (row["bits"], row["pool"], row["size"], row["n"], row["rel"], rt,
                     rt / base if base else float("nan")))
    json.dump(dict(d1=d1, d2=d2), open("/home/raver1975/lean/factor-scratch/r49/"
                                       "exp/supply/03_decomp.json", "w"), indent=1)
    print("\n[secs %.1f]" % (time.time() - t00))
