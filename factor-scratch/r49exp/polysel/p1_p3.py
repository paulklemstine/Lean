"""
p1_p3.py -- P1 (is the anti-correlation real, and what is its mechanism),
P2 (can it be a selection rule) and P3 (is it an artefact of the r48 search).

PREDICTIONS, STATED BEFORE MEASURING
-----------------------------------
Let meanlog(c) = mean over the box of log|f(a,b)|, i.e. log of the geometric
mean of the algebraic norms.  A cell is a relation iff |f(a,b)| is y-smooth,
and the smooth rate of an integer of size X is Psi(X,y)/X, decreasing in X.

 P1.1  SIGN.  rate DEcreases with mass.  The round-48 table reports the
      opposite sign (largest mass -> most relations).  Predicted slope of
      log(rate) on log(mass): NEGATIVE, magnitude ~0.3-1.0 per e-fold of mass.
 P1.2  MECHANISM.  rate is a function of meanlog(c) alone, through the ordinary
      smooth-number law, and mass enters only insofar as it moves meanlog(c).
      Test: the slope of log(rate) on meanlog(c) must EQUAL the slope measured
      on uniform random integers of the same size at the same y.  Predicted
      agreement within 3 sigma.
 P1.3  The two families must land on ONE curve in meanlog(c), even though
      Family A varies m (and hence the geometry of the box) and Family B holds
      m fixed and moves the coefficients off the digit lattice.
 P2    A rule that minimises meanlog(c) should beat the standard "m as close to
      N^(1/d) as possible" choice.  Quantify on held-out N.
 P3    Re-measuring the FIVE round-48 polynomials with a CORRECT counter
      reproduces none of their ordering.  Predicted: the correct rates span a
      much smaller factor than their 3.7x, and their correlation with mass has
      the opposite sign.
"""
from __future__ import annotations

import json
import math
import os
import random
import sys
import time

import numpy as np

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
import core as K  # noqa: E402

D = 3
ETA = 0.08           # box side = ETA * m, the natural NFS scaling
N_CELLS = 300_000
Y = 1000
SEED = 20260903


def rsa(bits, seed):
    rng = random.Random(seed)
    from sympy import isprime
    def prime(n):
        while True:
            cand = rng.randrange(2 ** (n - 1), 2 ** n) | 1
            if isprime(cand):
                return cand
    p = prime(bits // 2)
    q = prime(bits // 2)
    while q == p:
        q = prime(bits // 2)
    return p * q


def mstar(N, d=D):
    m = int(N ** (1.0 / d))
    while m ** d >= N:
        m -= 1
    while (m + 1) ** d >= N:
        m += 1
    return m


def measure(c, a, b, y=Y, do_norm=True):
    t0 = time.time()
    r = K.count_relations(c, a, b, y=y)
    dt = time.time() - t0
    r["rate"] = r["n_smooth"] / r["n_cells"]
    r["seconds"] = dt
    if do_norm:
        r["meanlog"] = K.mean_log_norm(c, a, b)
    return r


# ---------------------------------------------------------------- families

def family_A(N, m_lo, m_hi, a, b, n=25):
    """m varies, f from base-m digits of N - m^d.  Box scales with m (ETA)."""
    out = []
    ms = np.linspace(m_lo, m_hi, n)
    for mf in ms:
        m = int(mf)
        if m ** D >= N or m < 3:
            continue
        try:
            c = K.poly_from_m(N, m, D)
        except ValueError:
            continue
        if not K.is_irreducible_cubic(c):
            continue
        # the box must be the one that belongs to THIS m, same shape/fraction
        aa, bb, B = K.sample_box(m, ETA, N_CELLS, seed=SEED)
        r = measure(c, aa, bb)
        r["family"] = "A"
        r["m"] = m
        r["m_frac"] = m / (N ** (1.0 / D))
        out.append(r)
    return out


def family_B(N, m, a_ignored=None, b_ignored=None, n=25):
    """m FIXED, coefficients moved off the digit lattice.  Box fixed."""
    aa, bb, B = K.sample_box(m, ETA, N_CELLS, seed=SEED)
    R = N - m ** D
    out = []
    cands = [("digits", K.poly_from_m(N, m, D))]
    # sweep the coefficient lattice: j moves c0 by units of m, dc2 moves c2.
    # Together they put the mass anywhere from ~0 to ~m^2 at fixed m.
    for s in np.geomspace(0.02, 60.0, n):
        j = int(s * m)
        for sgn in (1, -1):
            c = K.poly_offset(N, m, D, j=sgn * j)
            if not K.is_irreducible_cubic(c):
                continue
            cands.append((f"j{sgn*j}", c))
    for t in (-2, -1, 1, 2, 5):
        c = K.poly_offset(N, m, D, dc2=t)
        if K.is_irreducible_cubic(c):
            cands.append((f"dc2{t}", c))
    seen = set()
    for tag, c in cands:
        key = tuple(c)
        if key in seen:
            continue
        seen.add(key)
        r = measure(c, aa, bb)
        r["family"] = "B"
        r["m"] = m
        r["tag"] = tag
        out.append(r)
    return out


# ---------------------------------------------------------------- fitting

def fit_loglog(x, y, w=None):
    """OLS of log y on x, with the slope's standard error."""
    x = np.asarray(x, float)
    y = np.asarray(y, float)
    y = np.maximum(y, 1.0)            # a zero count is a censoring, not a log
    lx, ly = np.log(np.maximum(y, 1.0)), np.log(y)
    ly = np.log(y)
    A = np.vstack([np.ones_like(lx), lx]).T
    coef, *_ = np.linalg.lstsq(A, ly, rcond=None)
    resid = ly - A @ coef
    dof = max(len(lx) - 2, 1)
    s2 = float(resid @ resid) / dof
    XtXi = np.linalg.inv(A.T @ A)
    se = math.sqrt(s2 * XtXi[1, 1])
    r2 = 1.0 - s2 / float(((ly - ly.mean()) ** 2).mean())
    return float(coef[1]), float(se), float(coef[0]), r2


def random_integer_slope(y=Y, bits_list=(40, 44, 48, 52), trials=9000, seed=7):
    """Measured d log(smooth rate) / d log x for uniform random integers.

    This is the null's slope, measured in THIS harness.  P1.2 says the algebraic
    side must show the same slope: if so, "relations" are just integers of a
    certain size and the NFS-specific story is vacuous.
    """
    rows = []
    pl = K.primes_upto(y)
    rng = random.Random(seed)
    for bits in bits_list:
        hit = 0
        for _ in range(trials):
            v = rng.getrandbits(bits) | (1 << (bits - 1))
            for p in pl:
                while v % p == 0:
                    v //= p
            if v == 1:
                hit += 1
        rows.append((bits, hit / trials))
    return rows


# ---------------------------------------------------------------- P1 + P3

def p1(bits_list=(39, 45, 51), do_p3=True):
    allrows = []
    for bits in bits_list:
        N = rsa(bits, seed=1000 + bits)
        ms = mstar(N)
        print("=" * 78)
        print(f"N = {N}  ({N.bit_length()} bits)   m* = {ms}   "
              f"m*^(1/3)/N^(1/3) = {ms / N ** (1/3):.6f}")
        print("=" * 78)
        print("Family A -- m varies, box = 0.08*m, f from base-m digits")
        rowsA = family_A(N, int(0.90 * ms), ms, None, None, n=22)
        for r in rowsA:
            print(f"  m={r['m']:>12}  mass={r['mass']:>14}  meanlog={r['meanlog']:>7.3f}"
                  f"  rels={r['n_smooth']:>8}  rate={r['rate']:.4e}")
        print("Family B -- m FIXED, coefficients moved off the digit lattice")
        rowsB = family_B(N, ms)
        for r in rowsB:
            print(f"  mass={r['mass']:>14}  meanlog={r['meanlog']:>7.3f}"
                  f"  rels={r['n_smooth']:>8}  rate={r['rate']:.4e}")
        allrows.append({"bits": bits, "N": N, "m": ms,
                        "A": rowsA, "B": rowsB})

        for fam, rows in (("A", rowsA), ("B", rowsB)):
            good = [r for r in rows if r["n_smooth"] >= 20]
            if len(good) < 5:
                print(f"  [P1 {fam}] too few points with >=20 relations "
                      f"({len(good)}) -- not fitted")
                continue
            b_m, se_m, a_m, r2m = fit_loglog([r["mass"] for r in good],
                                              [r["n_smooth"] for r in good])
            b_f, se_f, a_f, r2f = fit_loglog([r["meanlog"] for r in good],
                                              [r["n_smooth"] for r in good])
            print(f"  [P1 {fam}] n={len(good)}  slope log(rate)~log(mass)   = "
                  f"{b_m:+.3f} +- {se_m:.3f}   (R2 {r2m:.3f})   PREDICTED NEGATIVE")
            print(f"  [P1 {fam}] n={len(good)}  slope log(rate)~meanlog(f)    = "
                  f"{b_f:+.4f} +- {se_f:.4f}  (R2 {r2f:.3f})")

    # one curve over everything
    allgood = [r for blk in allrows for fam in ("A", "B")
               for r in blk[fam] if r["n_smooth"] >= 20]
    if len(allgood) >= 10:
        b_m, se_m, _, r2m = fit_loglog([r["mass"] for r in allgood],
                                        [r["n_smooth"] for r in allgood])
        b_f, se_f, _, r2f = fit_loglog([r["meanlog"] for r in allgood],
                                        [r["n_smooth"] for r in allgood])
        print("=" * 78)
        print(f"ALL FAMILIES POOLED  n = {len(allgood)}")
        print(f"  log(rate) ~ log(mass)    slope {b_m:+.3f} +- {se_m:.3f}  R2 {r2m:.3f}")
        print(f"  log(rate) ~ meanlog(f)   slope {b_f:+.4f} +- {se_f:.4f}  R2 {r2f:.3f}")
        print("  (meanlog is the natural log, so the meanlog slope is per e-fold)")

    # P1.2 -- compare to the random-integer null slope
    print("=" * 78)
    print("P1.2  MECHANISM TEST -- slope of log(smooth rate) vs log x for")
    print("      uniform random integers, measured in this harness")
    rr = random_integer_slope()
    for bits, rate in rr:
        print(f"      {bits} bits: y={Y}, rate {rate:.4e}, "
              f"u = {bits / math.log2(Y):.2f}")
    xs = [b for b, _ in rr]
    ys = [r for _, r in rr]
    b_rand, se_rand, _, r2r = fit_loglog(xs, ys)
    print(f"      random-integer slope (per e-fold) = {b_rand:+.4f} +- {se_rand:.4f} "
          f" R2 {r2r:.3f}")
    if len(allgood) >= 10:
        b_f, se_f, _, _ = fit_loglog([r["meanlog"] for r in allgood],
                                     [r["n_smooth"] for r in allgood])
        # convert the per-e-fold algebraic slope to per-bit for the comparison
        bits_pooled = [r["meanlog"] / math.log(2) for r in allgood]
        b_alg_bits, se_alg, _, _ = fit_loglog(
            [r["meanlog"] / math.log(2) for r in allgood],
            [r["n_smooth"] for r in allgood])
        print(f"      algebraic slope per e-fold of |f| = {b_alg_bits * math.log(2):+.4f}"
              f" +- {se_alg * math.log(2):.4f}")
        print(f"      RATIO algebraic/random = "
              f"{(b_alg_bits / b_rand) if b_rand else float('nan'):.3f}")
        print("      agreement => the NFS relation rate is the ordinary")
        print("      smooth-number law applied to the size of f, nothing more")

    with open(os.path.join(HERE, "p1_rows.json"), "w") as fh:
        json.dump([{"bits": blk["bits"], "N": str(blk["N"]), "m": blk["m"],
                    "rows": {f: blk[f] for f in ("A", "B")}} for blk in allrows],
                  fh, default=str, indent=1)
    return allrows


# ---------------------------------------------------------------- P3

def p3():
    """Re-measure the five round-48 polynomials with a correct counter."""
    print("=" * 78)
    print("P3  IS IT AN ARTEFACT?  Re-measuring the round-48 polynomials.")
    print("=" * 78)
    N = 412333899797            # the exact N printed in I_constant.md C3
    print(f"N = {N}  (matches the round-48 table: {N.bit_length()} bits)")
    ms = mstar(N)
    rng = random.Random(4)
    rows = []
    aa, bb, B = K.sample_box(600, 1.0, 1_200_000, seed=SEED)
    # the round-48 box was a in [-600,600), b in [1,600]; use their box exactly
    a2 = np.arange(-600, 600, dtype=np.int64)
    b2 = np.arange(1, 601, dtype=np.int64)
    A2, B2 = np.meshgrid(a2, b2, indexing='ij')
    A2 = A2.ravel()
    B2 = B2.ravel()
    print(f"box: |a|<600, 1<=b<=600 -> {A2.size} cells, y=1000")
    print(f"{'m':>9}{'mass':>10}{'meanlog|f|':>13}{'rels':>9}{'rate':>12}"
          f"{'r48 rels':>11}{'r48 rate':>12}")
    # NB: do NOT import r48/exp here -- `nfs_lattice` pulls in lll_self_test,
    # which drags in fpylll and takes minutes to import.  The only thing needed
    # from it is the m-admissibility test `base_m_digits(N,m,3)[3] == 1`, which
    # is just m^3 <= N < 2 m^3, done inline.
    # The round-48 relation counts, as published in notes/I_constant.md C3.
    PUBLISHED = {6698: 1090, 7070: 539, 7294: 476, 7405: 425, 7443: 292}
    for frac in (0.90, 0.95, 0.98, 0.995, 1.0):
        m = int(ms * frac)
        if not (m ** 3 <= N < 2 * m ** 3):            # r48's `digs[3] == 1`
            continue
        # r48's make_poly emits f(x) = x^3 - d2 x^2 - d1 x - d0 with the
        # REVERSED digits, leading-first as a list.  find_relations evaluates
        # norm = sum_i fc[i] a^(3-i) b^i, which in my ascending convention is
        # exactly c = list(fc).  So c reproduces their polynomial.
        c = K.poly_from_m(N, m, 3)
        for _ in (0,):
            pass
        r = K.count_relations(c, A2, B2, y=1000)
        ml = K.mean_log_norm(c, A2, B2)
        r48 = PUBLISHED.get(m, -1)
        print(f"{m:>9}{K.mass(c):>10}{ml:>13.3f}{r['n_smooth']:>9}"
              f"{r['n_smooth']/r['n_cells']:>12.4e}{r48:>11}"
              f"{(r48/(4*600*600) if r48>0 else float('nan')):>12.4e}")
        rows.append((m, K.mass(c), ml, r["n_smooth"], r48))
    if len(rows) >= 3:
        ms_ = [r[1] for r in rows]
        correct = [r[3] for r in rows]
        r48c = [r[4] for r in rows if r[4] > 0]
        rows = [r for r in rows if r[4] > 0]
        import itertools
        def spearman(x, y):
            def rank(v):
                order = sorted(range(len(v)), key=lambda i: v[i])
                rk = [0.0] * len(v)
                i = 0
                while i < len(order):
                    j = i
                    while j + 1 < len(order) and v[order[j + 1]] == v[order[i]]:
                        j += 1
                    avg = (i + j) / 2.0 + 1
                    for k in range(i, j + 1):
                        rk[order[k]] = avg
                    i = j + 1
                return rk
            rx, ry = rank(x), rank(y)
            n = len(x)
            mx, my = sum(rx) / n, sum(ry) / n
            num = sum((a - mx) * (b - my) for a, b in zip(rx, ry))
            den = math.sqrt(sum((a - mx) ** 2 for a in rx) *
                            sum((b - my) ** 2 for b in ry))
            return num / den if den else float('nan')
        print(f"\nSpearman(mass, r48 relation count)     = "
              f"{spearman(ms_, r48c):+.3f}   <- the round-48 finding")
        print(f"Spearman(mass, CORRECT relation count) = "
              f"{spearman(ms_, correct):+.3f}   <- this re-measurement")
        spread_r48 = max(r48c) / min(r48c)
        spread_cor = max(correct) / min(correct)
        print(f"max/min ratio, r48 {spread_r48:.2f}x, correct {spread_cor:.2f}x")
        # is the correct variation even significant?
        lo, hi = min(correct), max(correct)
        z = (hi - lo) / math.sqrt(hi + lo) if hi + lo else 0
        print(f"correct-count spread is {z:.1f} sigma (Poisson) "
              f"at {lo}..{hi} relations")
    return rows


if __name__ == "__main__":
    p3()
    p1()