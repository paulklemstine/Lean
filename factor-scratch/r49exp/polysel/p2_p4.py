"""
p2_p4.py -- P2 (is it a selection RULE, and what is the held-out gain?) and
P4 (does the advantage grow or shrink with n?).

PREDICTIONS, STATED BEFORE MEASURING
-----------------------------------
 P2.1  The classical "choose m well" gain is real: minimising the mean of
      log|f(a,b)| over the box beats the standard choice m = floor(N^(1/d)),
      because at m = floor(N^(1/d)) the residual N - m^d is an arbitrary number
      up to 3m^2 and its base-m digits can be anything.  Predicted rate ratio
      R2/R0 between 1.3x and 4x, roughly constant in N.
 P2.2  meanlog(f) is a BETTER proxy for the rate than coefficient mass, so the
      rule that minimises meanlog beats the rule that minimises mass.  This is
      the claim that would make the axis a finding rather than a rerun of the
      classical heuristic; predicted modest (1.1x - 1.5x) but measurable.
 P2.3  Gain survives on HELD-OUT N (rules fixed on a disjoint training set).
 P4.1  The advantage is scale-INVARIANT: at fixed box fraction eta the geometric
      mean of |f| and the box both scale like m^3, so u = log|f| / log y is
      unchanged by N and the rate ratio between two polynomials does not move
      with N.  Predicted: the fitted slope on meanlog(f) constant across N.
 P4.2  At fixed geometry the ratio DOES move with y, because y enters only
      through u.  Extrapolation to 1024 bits is therefore a MODEL over u, not a
      measurement in n, and is labelled as such.
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
ETA = 0.08
N_CELLS = 400_000         # cells for EVALUATING the chosen polynomials
SCAN_CELLS = 150_000      # cheaper cells for the RULE SEARCH
Y = None                  # per-modulus: y = 2^(bits/3.5), i.e. u ~ 3.5


def y_for_bits(bits):
    """The NFS operating point: y tracks N^(1/3), so u = log|f|/log y is
    CONSTANT in N.  Holding y fixed at 1000 instead drove u to 5.6 by 54 bits,
    where the rates are ~1e-4 and the scan is starved of relations."""
    return int(2 ** (bits / 3.5))
SEED = 20260903
M_LO_FRAC = 0.90          # the wide scan the round-48 note says is necessary


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
    while (m + 1) ** d < N:
        m += 1
    return m


def norm_of(c, a, b, y, cells=None):
    if cells is not None:
        a, b = a[:cells], b[:cells]
    r = K.count_relations(c, a, b, y=y)
    r["rate"] = r["n_smooth"] / r["n_cells"]
    return r


def splitting_load(c, y0=3000):
    """Root-hits for p <= y0: a PARTIAL sieving-cost proxy.

    Sieve time is proportional to (cells x total root-hits over p <= y), so this
    is the only polynomial-dependent part of the cost of finding a relation at
    a fixed (y, box, cells).  Brute force over p <= 3000 is ~4.5e6 iterations,
    which is affordable; the cap is applied identically to every polynomial so
    the comparison stays fair.  (A gcd(f, x^p-x) version was tried first but
    sympy's gf_gcd kept degenerating to the constant 1; the PARI route needs a
    PARI handle that cypari2 would not build here.)
    """
    tot = 0
    nsplit = 0
    for p in K.primes_upto(y0):
        rt = K.roots_mod(c, p)
        if rt:
            nsplit += 1
            tot += len(rt)
    return nsplit, tot


# ---------------------------------------------------------------- P2

def scan_m(N, n_scan=30, cells=SCAN_CELLS, y=None):
    """Scan m over a wide range; return per-m (mass, meanlog, rate, roots)."""
    ms = mstar(N)
    lo = int(M_LO_FRAC * ms)
    out = []
    seen = set()
    for mf in np.linspace(lo, ms, n_scan):
        m = int(mf)
        if m in seen or m ** D >= N or m < 3:
            continue
        seen.add(m)
        try:
            c = K.poly_from_m(N, m, D)
        except ValueError:
            continue
        if not K.is_irreducible_cubic(c):
            continue
        a, b, B = K.sample_box(m, ETA, cells, seed=SEED)
        ml = K.mean_log_norm(c, a, b)
        r = norm_of(c, a, b, y=y, cells=cells)
        out.append({"m": m, "c": c, "mass": K.mass(c), "meanlog": ml,
                    "rate": r["rate"], "n_smooth": r["n_smooth"],
                    "n_cells": r["n_cells"], "n_zero": r["n_zero"]})
    return out


def fit(x, y, w=None):
    x = np.asarray(x, float)
    y = np.asarray(np.maximum(y, 1.0), float)
    ly = np.log(y)
    A = np.vstack([np.ones_like(x), x]).T
    coef, *_ = np.linalg.lstsq(A, ly, rcond=None)
    resid = ly - A @ coef
    s2 = float(resid @ resid) / max(len(x) - 2, 1)
    se = math.sqrt(s2 * np.linalg.inv(A.T @ A)[1, 1])
    return float(coef[1]), float(se), float(coef[0])


def p2(train_bits=(36, 42), test_bits=(45, 51, 54)):
    print("=" * 78)
    print("P2  CAN IT BE A SELECTION RULE?")
    print("=" * 78)
    rows = []
    for split, bits_list in (("TRAIN", train_bits), ("HELD-OUT", test_bits)):
        for bits in bits_list:
            N = rsa(bits, seed=3000 + bits)
            ms = mstar(N)
            yy = y_for_bits(bits)
            sc = scan_m(N, y=yy)
            print(f"  [{split}] N = {N.bit_length()} bits, m* = {ms}, "
                  f"y = {yy}, {len(sc)} admissible m, scan cells {SCAN_CELLS}")
            if len(sc) < 10:
                print(f"  [{split}] N {bits} bits: only {len(sc)} admissible m")
                continue
            # R0: the standard choice, m = floor(N^(1/d))
            R0 = [r for r in sc if r["m"] == ms][0]
            # R1: minimise coefficient MASS  (the classical / round-48 proxy)
            R1 = min(sc, key=lambda r: r["mass"])
            # R2: minimise mean log|f| over the box (the proposed rule)
            R2 = min(sc, key=lambda r: r["meanlog"])
            # R3: oracle -- maximise the MEASURED rate
            R3 = max(sc, key=lambda r: r["rate"])
            # the r48 table's actual sample: 5 m values spanning the same range
            cands = [min(sc, key=lambda r: abs(r["m"] / ms - fr))
                     for fr in (0.90, 0.95, 0.98, 0.995, 1.0)]
            cands = list({c["m"]: c for c in cands}.values())

            # re-evaluate the four chosen polynomials on MORE cells so the
            # reported gains are not noise-limited (the scan itself is
            # deliberately cheap).
            for tag, rr in (("R0", R0), ("R1", R1), ("R2", R2), ("R3", R3)):
                aa, bbx, _ = K.sample_box(rr["m"], ETA, N_CELLS, seed=SEED + 1)
                rr["rate"] = norm_of(rr["c"], aa, bbx, y=yy)["rate"]
                rr["n_smooth"] = int(rr["rate"] * N_CELLS)
                rr["meanlog"] = K.mean_log_norm(rr["c"], aa, bbx)
                rr["n_split_roots"] = splitting_load(rr["c"])

            def show(tag, r, ref=None):
                extra = ""
                if ref:
                    extra = (f"   gain {r['rate']/ref['rate']:.2f}x"
                             f"   mass ratio {r['mass']/ref['mass']:.3f}")
                print(f"    {tag:<26} m={r['m']:>9}  mass={r['mass']:>10}"
                      f"  meanlog={r['meanlog']:>7.3f}  rate={r['rate']:.4e}"
                      f"{extra}")
            show("R0 standard m=floor(N^1/3)", R0)
            show("R1 minimise MASS", R1, R0)
            show("R2 minimise meanlog(f)", R2, R0)
            show("R3 oracle (measured)", R3, R0)
            # does R2 beat R1?
            if R2 is not R1:
                print(f"    R2 vs R1 (the proposed proxy vs the classical one): "
                      f"{R2['rate']/R1['rate']:.3f}x, "
                      f"mass {R2['mass']/R1['mass']:.3f}x, "
                      f"meanlog {R2['meanlog']-R1['meanlog']:+.3f}")

            # P2.2 -- which proxy predicts the rate within the scan?
            good = [r for r in sc if r["n_smooth"] >= 15]
            if len(good) >= 8:
                b_m, se_m, _ = fit([math.log(r["mass"]) for r in good],
                                   [r["n_smooth"] for r in good])
                b_f, se_f, _ = fit([r["meanlog"] for r in good],
                                   [r["n_smooth"] for r in good])
                # residual scatter about each fit
                def resid(b, a0, xs, ys):
                    e = []
                    for r in sc:
                        if r["n_smooth"] < 15:
                            continue
                        x = xs(r)
                        e.append(math.log(max(r["n_smooth"], 1.0)) - (a0 + b * x))
                    return float(np.std(e))
                xm = lambda r: math.log(r["mass"])
                xf = lambda r: r["meanlog"]
                rm_ = resid(b_m, fit([math.log(r["mass"]) for r in good],
                                      [r["n_smooth"] for r in good])[2],
                            xm, [r["n_smooth"] for r in good])
                rf_ = resid(b_f, fit([r["meanlog"] for r in good],
                                      [r["n_smooth"] for r in good])[2],
                            xf, [r["n_smooth"] for r in good])
                print(f"    proxy comparison over the scan (n={len(good)}):")
                print(f"      slope vs log(mass)   {b_m:+.3f} +- {se_m:.3f}"
                      f"   residual sd {rm_:.4f}")
                print(f"      slope vs meanlog(f)  {b_f:+.4f} +- {se_f:.4f}"
                      f"   residual sd {rf_:.4f}")
                rows.append({"split": split, "bits": bits,
                             "b_mass": b_m, "se_mass": se_m,
                             "b_meanlog": b_f, "se_meanlog": se_f,
                             "resid_mass": rm_, "resid_meanlog": rf_,
                             "n": len(good),
                             "r0": R0["rate"], "r1": R1["rate"],
                             "r2": R2["rate"], "r3": R3["rate"]})
            rows_last = (split, bits, R0, R1, R2, R3, cands)

    print("=" * 78)
    print("P2  SUMMARY -- held-out gains")
    ho = [r for r in rows if r["split"] == "HELD-OUT"]
    if ho:
        g1 = np.array([r["r1"] / r["r0"] for r in ho])
        g2 = np.array([r["r2"] / r["r0"] for r in ho])
        g3 = np.array([r["r3"] / r["r0"] for r in ho])
        print(f"  gain of minimise-MASS   over standard : "
              f"{np.median(g1):.2f}x  (per instance: "
              f"{', '.join(f'{v:.2f}' for v in g1)})")
        print(f"  gain of minimise-meanlog over standard : "
              f"{np.median(g2):.2f}x  (per instance: "
              f"{', '.join(f'{v:.2f}' for v in g2)})")
        print(f"  oracle upper bound                     : "
              f"{np.median(g3):.2f}x")
    with open(os.path.join(HERE, "p2_rows.json"), "w") as fh:
        json.dump(rows, fh, default=str, indent=1)
    return rows


# ---------------------------------------------------------------- P4

def p4(bits_list=(45,), y_list=(500, 1000, 2000, 4000, 8000)):
    """Size dependence: real n sweep, and a y sweep that exposes the u-law."""
    print("=" * 78)
    print("P4  SIZE DEPENDENCE")
    print("=" * 78)
    out = []
    for bits in bits_list:
        N = rsa(bits, seed=1000 + bits)
        ms = mstar(N)
        yy = y_for_bits(bits)
        sc = scan_m(N, n_scan=30, y=yy)
        good = [r for r in sc if r["n_smooth"] >= 15]
        if len(good) < 8:
            print(f"  {bits} bits: too few points ({len(good)})")
            continue
        b_m, se_m, _ = fit([math.log(r["mass"]) for r in good],
                           [r["n_smooth"] for r in good])
        b_f, se_f, _ = fit([r["meanlog"] for r in good],
                           [r["n_smooth"] for r in good])
        u = np.mean([r["meanlog"] for r in good]) / math.log(yy)
        print(f"  N = {bits} bits  m* = {ms:>8}  n = {len(good):>3}  "
              f"u = {u:.3f}")
        print(f"      slope log(rate)~log(mass)  {b_m:+.3f} +- {se_m:.3f}")
        print(f"      slope log(rate)~meanlog(f) {b_f:+.4f} +- {se_f:.4f}   "
              f"(e-folds; slope ~ rho'(u)/rho(u) / log y)")
        out.append({"bits": bits, "u": u, "b_meanlog": b_f, "se": se_f,
                    "b_mass": b_m, "se_mass": se_m, "n": len(good)})

    print("-" * 78)
    print("  y sweep at ONE size -- the ratio between two fixed polynomials")
    print("  as a function of u = log|f| / log y.  This is the honest")
    print("  extrapolation axis; n enters ONLY through u.")
    N = rsa(45, seed=1045)
    ms = mstar(N)
    sc = scan_m(N, n_scan=24, y=y_for_bits(45))
    good = sorted([r for r in sc if r["n_smooth"] >= 15],
                  key=lambda r: r["meanlog"])
    if len(good) >= 4:
        lo = good[0]
        hi = good[-1]
        a, b, _ = K.sample_box(ms, ETA, 300_000, seed=SEED + 7)
        print(f"    'small' m={lo['m']} mass={lo['mass']} meanlog={lo['meanlog']:.3f}")
        print(f"    'large' m={hi['m']} mass={hi['mass']} meanlog={hi['meanlog']:.3f}")
        print(f"    {'y':>7}{'u_lo':>8}{'u_hi':>8}{'rate_lo':>12}"
              f"{'rate_hi':>12}{'ratio':>9}")
        ys = []
        for y in y_list:
            rl = norm_of(lo["c"], a, b, y=y)["rate"]
            rh = norm_of(hi["c"], a, b, y=y)["rate"]
            u_lo = lo["meanlog"] / math.log(y)
            u_hi = hi["meanlog"] / math.log(y)
            print(f"    {y:>7}{u_lo:>8.3f}{u_hi:>8.3f}{rl:>12.4e}"
                  f"{rh:>12.4e}{(rh/rl if rl else float('nan')):>9.3f}")
            ys.append({"y": y, "u_lo": u_lo, "u_hi": u_hi,
                       "rate_lo": rl, "rate_hi": rh,
                       "ratio": (rh / rl if rl else None)})
        # slope check: log(rate) vs meanlog at each y should match the
        # random-integer law  d log rho / d log x / log y
        print("    law check (per e-fold, vs rho'(u)/rho(u)/log y):")
        from importlib.util import spec_from_file_location, module_from_spec
        R48 = os.path.join(os.path.dirname(os.path.dirname(HERE)), "r48")
        sp = spec_from_file_location("sd", os.path.join(R48, "_shared", "dickman.py"))
        sd = module_from_spec(sp)
        sp.loader.exec_module(sd)
        for y, e in zip(y_list, ys):
            u = (lo["meanlog"] + hi["meanlog"]) / 2 / math.log(y)
            pred = (-sd.rho(u - 1) / (u * sd.rho(u))) / math.log(y)
            meas = math.log(max(e["rate_hi"], 1e-300) / max(e["rate_lo"], 1e-300)) / (
                hi["meanlog"] - lo["meanlog"])
            print(f"      y={y:>5} u={u:.2f}  measured {meas:+.4f}"
                  f"   Dickman law {pred:+.4f}")
    with open(os.path.join(HERE, "p4_rows.json"), "w") as fh:
        json.dump({"n_sweep": out,
                   "y_sweep": ys if (len(good) >= 4) else []}, fh,
                  default=str, indent=1)
    return out


if __name__ == "__main__":
    p2()
    p4()