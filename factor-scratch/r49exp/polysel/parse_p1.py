"""
parse_p1.py -- recover the per-polynomial rows from p1.log.

The first p1() run crashed in the P1.2 block on a singular matrix (the
fit_loglog copy-paste bug) AFTER printing every row, so the rows are on disk
even though p1_rows.json was never written.  Parsing them is cheaper than
re-measuring and is checked against the printed self-consistency: the
measured/predicted column must equal rate/pred for every row.
"""
from __future__ import annotations

import json
import math
import os
import re
import sys

import numpy as np

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
from analyse import spearman, boot_spearman, rank  # noqa: E402

ROW_A = re.compile(r"^\s*m=\s*(\d+)\s+mass=\s*(\d+)\s+meanlog=\s*([\d.]+)"
                   r"\s+rels=\s*(\d+)\s+rate=([\d.e+-]+)\s+pred=([\d.e+-]+)"
                   r"\s+m/p=([\d.]+)\s*$")
ROW_B = re.compile(r"^\s+mass=\s*(\d+)\s+meanlog=\s*([\d.]+)"
                   r"\s+rels=\s*(\d+)\s+rate=([\d.e+-]+)\s+pred=([\d.e+-]+)"
                   r"\s+m/p=([\d.]+)\s*$")
BLOCK = re.compile(r"^N = (\d+)\s+\((\d+) bits\)\s+m\* = (\d+)")


def load():
    rows = []
    cur = None
    with open(os.path.join(HERE, "p1.log")) as fh:
        for line in fh:
            mb = BLOCK.match(line)
            if mb:
                cur = {"N": int(mb.group(1)), "bits": int(mb.group(2)),
                       "m": int(mb.group(3))}
                continue
            ma = ROW_A.match(line)
            mb2 = ROW_B.match(line)
            if ma:
                r = {"fam": "A", "N": cur["N"], "bits": cur["bits"],
                     "m": int(ma.group(1)), "mass": float(ma.group(2)),
                     "meanlog": float(ma.group(3)), "n_smooth": int(ma.group(4)),
                     "rate": float(ma.group(5)), "pred": float(ma.group(6)),
                     "mp": float(ma.group(7))}
                rows.append(r)
                continue
            if mb2:
                r = {"fam": "B", "N": cur["N"], "bits": cur["bits"],
                     "m": cur["m"], "mass": float(mb2.group(1)),
                     "meanlog": float(mb2.group(2)),
                     "n_smooth": int(mb2.group(3)), "rate": float(mb2.group(4)),
                     "pred": float(mb2.group(5)), "mp": float(mb2.group(6))}
                rows.append(r)
    return rows


def fit(x, y):
    x = np.asarray(x, float)
    ly = np.log(np.maximum(np.asarray(y, float), 1.0))
    A = np.vstack([np.ones_like(x), x]).T
    coef, *_ = np.linalg.lstsq(A, ly, rcond=None)
    resid = ly - A @ coef
    dof = max(len(x) - 2, 1)
    s2 = float(resid @ resid) / dof
    se = math.sqrt(s2 * np.linalg.inv(A.T @ A)[1, 1])
    tot = float(((ly - ly.mean()) ** 2).mean())
    return float(coef[1]), float(se), 1.0 - s2 / tot


def main():
    rows = load()
    print(f"parsed {len(rows)} polynomial measurements from p1.log")
    # self-consistency of the parse
    bad = [r for r in rows if abs(r["rate"] / r["pred"] - r["mp"]) > 2e-3]
    print(f"parse self-check (rate/pred == printed m/p): {len(bad)} mismatches")
    good = [r for r in rows if r["n_smooth"] >= 20]
    print(f"{len(good)} rows with >= 20 relations")
    print()
    print("=" * 78)
    print("P1  WHICH SUMMARY OF f PREDICTS THE RELATION RATE?")
    print("=" * 78)
    rate = [r["n_smooth"] for r in good]
    print(f"  measured rate spread over all {len(good)} polynomials: "
          f"{max(rate)/min(rate):.2f}x")
    print()
    print(f"  {'predictor':<22}{'Spearman':>10}{'95% CI':>20}")
    for name, xs in (("coefficient mass", [r["mass"] for r in good]),
                     ("mean log|f|", [r["meanlog"] for r in good]),
                     ("pointwise rho(f)", [r["pred"] for r in good])):
        lo, hi = boot_spearman(xs, rate)
        print(f"  {name:<22}{spearman(xs, rate):>+10.3f}{f'[{lo:+.3f},{hi:+.3f}]':>20}")
    print()
    print("  rho>0: larger predictor -> MORE relations.  The round-48 claim is")
    print("  rho(mass)>0.  The smooth-number law requires rho(meanlog)<0.")
    print()
    for fam in ("A", "B"):
        g = [r for r in good if r["fam"] == fam]
        if len(g) < 5:
            continue
        rt = [r["n_smooth"] for r in g]
        print(f"  family {fam} (n={len(g)}), rate spread "
              f"{max(rt)/min(rt):.2f}x:")
        for name, xs in (("coefficient mass", [r["mass"] for r in g]),
                         ("mean log|f|", [r["meanlog"] for r in g]),
                         ("pointwise rho(f)", [r["pred"] for r in g])):
            lo, hi = boot_spearman(xs, rt)
            print(f"    {name:<21}{spearman(xs, rt):>+8.3f}"
                  f"{f'[{lo:+.3f},{hi:+.3f}]':>20}")
        b_m, se_m, r2m = fit([math.log(r["mass"]) for r in g], rt)
        b_f, se_f, r2f = fit([r["meanlog"] for r in g], rt)
        print(f"    OLS log(rate)~log(mass)  {b_m:+.3f} +- {se_m:.3f}  R2 {r2m:.3f}")
        print(f"    OLS log(rate)~meanlog(f) {b_f:+.4f} +- {se_f:.4f}  R2 {r2f:.3f}")
        print()
    b_m, se_m, r2m = fit([math.log(r["mass"]) for r in good], rate)
    b_f, se_f, r2f = fit([r["meanlog"] for r in good], rate)
    b_p, se_p, r2p = fit([r["pred"] for r in good], rate)
    print("  POOLED")
    print(f"    OLS log(rate)~log(mass)  {b_m:+.3f} +- {se_m:.3f}  R2 {r2m:.3f}"
          f"     <- PREDICTED NEGATIVE")
    print(f"    OLS log(rate)~meanlog(f) {b_f:+.4f} +- {se_f:.4f}  R2 {r2f:.3f}")
    print(f"    OLS log(rate)~pointwise   {b_p:+.3f} +- {se_p:.3f}  R2 {r2p:.3f}")
    print()
    print("  P4.1  per-modulus meanlog slope (scale-invariance check)")
    print(f"    {'bits':>6}{'n':>5}{'slope/e-fold':>15}{'s.e.':>9}{'mean u':>9}")
    for bits in sorted({r["bits"] for r in good}):
        g = [r for r in good if r["bits"] == bits]
        if len(g) < 8:
            continue
        sl, se, _ = fit([r["meanlog"] for r in g], [r["n_smooth"] for r in g])
        u = float(np.mean([r["meanlog"] for r in g])) / math.log(1000)
        print(f"    {bits:>6}{len(g):>5}{sl:>+15.4f}{se:>9.4f}{u:>9.3f}")
    mp = np.array([r["mp"] for r in good])
    print()
    print(f"  measured / pointwise-rho-prediction: min {mp.min():.2f}  "
          f"median {np.median(mp):.2f}  max {mp.max():.2f}  "
          f"spread {mp.max()/mp.min():.2f}x")
    with open(os.path.join(HERE, "p1_rows.json"), "w") as fh:
        json.dump(rows, fh, indent=1)


if __name__ == "__main__":
    main()