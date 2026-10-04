"""
analyse.py -- read p1_rows.json and answer the predictor question directly:
which summary of f predicts the relation rate, and how well?

RANK correlation is the right statistic here: the rate spans ~3x while the
predictors span orders of magnitude, and the question "does X predict the rate"
is about ordering, not linearity.  A bootstrap over polynomials gives the CI.
"""
from __future__ import annotations

import json
import math
import os
import sys

import numpy as np

HERE = os.path.dirname(os.path.abspath(__file__))


def rank(v):
    v = np.asarray(v, float)
    order = np.argsort(v, kind="mergesort")
    rk = np.empty(len(v), float)
    i = 0
    rk_sorted = np.empty(len(v), float)
    while i < len(order):
        j = i
        while j + 1 < len(order) and v[order[j + 1]] == v[order[i]]:
            j += 1
        rk_sorted[i:j + 1] = (i + j) / 2.0 + 1
        i = j + 1
    rk[order] = rk_sorted
    return rk


def spearman(x, y):
    rx, ry = rank(x), rank(y)
    n = len(x)
    mx, my = rx.mean(), ry.mean()
    num = ((rx - mx) * (ry - my)).sum()
    den = math.sqrt(((rx - mx) ** 2).sum() * ((ry - my) ** 2).sum())
    return float(num / den) if den else float("nan")


def boot_spearman(x, y, n=4000, seed=0):
    rng = np.random.default_rng(seed)
    x = np.asarray(x, float)
    y = np.asarray(y, float)
    n_ = len(x)
    vals = []
    for _ in range(n):
        idx = rng.integers(0, n_, n_)
        if len(np.unique(idx)) < 3:
            continue
        vals.append(spearman(x[idx], y[idx]))
    v = np.array(vals)
    return float(np.percentile(v, 2.5)), float(np.percentile(v, 97.5))


def main():
    with open(os.path.join(HERE, "p1_rows.json")) as fh:
        blocks = json.load(fh)
    rows = []
    for blk in blocks:
        for fam in ("A", "B"):
            for r in blk["rows"][fam]:
                rr = dict(r)
                rr["bits"] = blk["bits"]
                rr["fam"] = fam
                rr["mass"] = float(rr["mass"])
                rr["meanlog"] = float(rr["meanlog"])
                rr["pred"] = float(rr["pred"])
                rr["n_smooth"] = int(rr["n_smooth"])
                rows.append(rr)
    good = [r for r in rows if r["n_smooth"] >= 20]
    print("=" * 78)
    print(f"PREDICTOR COMPARISON   n = {len(good)} polynomials "
          f"({sum(1 for r in good if r['fam']=='A')} family A, "
          f"{sum(1 for r in good if r['fam']=='B')} family B), "
          f"{len(blocks)} moduli")
    print("=" * 78)
    rate = [r["n_smooth"] for r in good]
    print(f"{'predictor':<22}{'Spearman rho':>15}{'95% CI':>20}")
    for name, xs in (("coefficient mass", [r["mass"] for r in good]),
                     ("mean log|f|", [r["meanlog"] for r in good]),
                     ("pointwise rho(f)", [r["pred"] for r in good])):
        rho = spearman(xs, rate)
        lo, hi = boot_spearman(xs, rate)
        print(f"  {name:<20}{rho:>+15.3f}{f'[{lo:+.3f}, {hi:+.3f}]':>20}")
    print()
    print("  NOTE: rho > 0 means larger predictor -> MORE relations.")
    print("  The round-48 claim is rho(mass) > 0.  The smooth-number law")
    print("  requires rho(meanlog) < 0 and rho(pointwise) < 0.")

    # per-family, so a Simpson-type confound across m vs within-m shows up
    print()
    print("  split by family (A varies m, B holds m fixed and moves f):")
    for fam in ("A", "B"):
        g = [r for r in good if r["fam"] == fam]
        if len(g) < 5:
            continue
        rt = [r["n_smooth"] for r in g]
        print(f"    family {fam} (n={len(g)}):")
        for name, xs in (("coefficient mass", [r["mass"] for r in g]),
                         ("mean log|f|", [r["meanlog"] for r in g]),
                         ("pointwise rho(f)", [r["pred"] for r in g])):
            lo, hi = boot_spearman(xs, rt)
            print(f"      {name:<20}{spearman(xs, rt):>+8.3f}"
                  f"{f'[{lo:+.3f}, {hi:+.3f}]':>20}")

    # per-modulus slopes: is the meanlog slope stable in n?  (P4.1)
    print()
    print("  per-modulus meanlog slope (P4.1: scale-invariance):")
    print(f"    {'bits':>6}{'n':>5}{'slope/e-fold':>16}{'s.e.':>9}"
          f"{'mean u':>9}")
    for blk in blocks:
        g = [r for r in good if r["bits"] == blk["bits"]]
        if len(g) < 8:
            continue
        x = np.array([r["meanlog"] for r in g])
        y = np.log(np.maximum([r["n_smooth"] for r in g], 1.0))
        A = np.vstack([np.ones_like(x), x]).T
        coef, *_ = np.linalg.lstsq(A, y, rcond=None)
        resid = y - A @ coef
        se = math.sqrt(float(resid @ resid) / max(len(x) - 2, 1) *
                       np.linalg.inv(A.T @ A)[1, 1])
        u = np.mean([r["meanlog"] for r in g]) / math.log(1000)
        print(f"    {blk['bits']:>6}{len(g):>5}{coef[1]:>+16.4f}{se:>9.4f}{u:>9.3f}")

    # prediction quality
    mp = np.array([r["n_smooth"] / r["n_cells"] / r["pred"] for r in good])
    print()
    print(f"  measured/predicted rate: min {mp.min():.3f}  "
          f"median {np.median(mp):.3f}  max {mp.max():.3f}  "
          f"spread {mp.max()/mp.min():.2f}x")
    print(f"  measured rate spread across all polynomials: "
          f"{max(rate)/min(rate):.2f}x")


if __name__ == "__main__":
    main()