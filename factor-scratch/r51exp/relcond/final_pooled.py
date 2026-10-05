"""
FINAL -- pooled test of the index-conditioning family at adequate power.

WHY THIS FILE EXISTS.  Three successive measurements of the same quantity gave
three answers: 1.15 (n = 60 relations), 1.02-1.03 (n = 40000 trials, 5 moduli),
0.99-1.00 (n = 30000 trials, 6 moduli, subgroup-controlled).  Only the third
divided by the actual subgroup size.  Rather than pick the answer I liked, this
runs the arms POOLED -- all moduli, all trials, one two-proportion test -- which
is the only version with the power to settle a 2% effect.

The per-modulus scatter is the whole story and it is reported first.

Run: python3 final_pooled.py
"""

from __future__ import annotations

import json
import math
import random
import sys
from pathlib import Path

import numpy as np

sys.path.insert(0, "/home/raver1975/lean/factor-scratch/r51exp/relcond")

from relcond_core import gen_semiprime, pi, smooth_mask_batch, strata  # noqa: E402

OUT = Path(__file__).parent / "results"
MODES = ("uniform", "odd_x", "even_x", "x_mod4_0")


def arm(n, g, b, mode, trials, rng):
    hits = 0
    done = 0
    while done < trials:
        bs = min(2500, trials - done)
        xs = []
        for _ in range(bs):
            if mode == "uniform":
                xs.append(rng.randrange(1, n))
            elif mode == "odd_x":
                xs.append(2 * rng.randrange(0, n // 2) + 1)
            elif mode == "even_x":
                xs.append(2 * rng.randrange(1, n // 2))
            else:
                xs.append(4 * rng.randrange(0, n // 4))
        vals = np.fromiter((pow(g, xx, n) for xx in xs), dtype=np.int64, count=bs)
        hits += int(smooth_mask_batch(vals, b).sum())
        done += bs
    return hits


def z2(k1, n1, k2, n2):
    p1, p2 = k1 / n1, k2 / n2
    p = (k1 + k2) / (n1 + n2)
    d = math.sqrt(p * (1 - p) * (1 / n1 + 1 / n2))
    return (p1 - p2) / d if d > 0 else 0.0


def main() -> None:
    print("=" * 78)
    print("FINAL -- POOLED test of index conditioning, 12 moduli")
    print("=" * 78)
    b = 2 ** 14
    trials = 25000
    seeds = list(range(6001, 6013))
    print(f"  B = {b} (pi = {pi(b)}), {trials} trials/arm/mode, {len(seeds)} moduli")
    print(f"  Total per mode = {trials * len(seeds):,} candidates\n")
    tot = {m: [0, 0] for m in MODES}
    per = []
    for sd in seeds:
        rng = random.Random(sd)
        n, p, q = gen_semiprime(40, rng)
        g = 2 + 2 * rng.randrange(0, 6)
        while math.gcd(g, n) != 1:
            g += 1
        st = strata(n, p, q, g)
        h = {}
        for m in MODES:
            h[m] = arm(n, g, b, m, trials, random.Random(sd * 104729 + hash(m) % 9973))
            tot[m][0] += h[m]
            tot[m][1] += trials
        per.append({"seed": sd, "stratum": st["cell"],
                    **{m: h[m] / trials for m in MODES}})

    print("  PER-MODULUS rates (the scatter is the finding):")
    print(f"  {'seed':>6} {'stratum':<16} {'uniform':>9} {'odd_x':>9} {'even_x':>9} {'x_mod4':>9}")
    for r in per:
        print(f"  {r['seed']:>6} {r['stratum']:<16} {r['uniform']:>9.4f} "
              f"{r['odd_x']:>9.4f} {r['even_x']:>9.4f} {r['x_mod4_0']:>9.4f}")
    sc = [r["even_x"] / r["uniform"] for r in per]
    print(f"\n  per-modulus ratio even_x/uniform: mean {np.mean(sc):.4f}, "
          f"sd {np.std(sc, ddof=1):.4f}, range {min(sc):.4f}..{max(sc):.4f}")
    print(f"  (the brief's mandatory 0.085 same-cell discrepancy: sd here is "
          f"{np.std(sc, ddof=1):.4f}, so a single modulus is worth ~{np.std(sc, ddof=1):.3f})")

    print("\n  POOLED (all 12 moduli, all trials) -- the only powered test:")
    ku, nu = tot["uniform"]
    print(f"    uniform: {ku}/{nu} = {ku/nu:.5f}")
    for m in ("odd_x", "even_x", "x_mod4_0"):
        k, nn = tot[m]
        z = z2(k, nn, ku, nu)
        rr = (k / nn) / (ku / nu)
        verdict = ("DISTINGUISHABLE" if abs(z) > 2.0 else "null")
        print(f"    {m:<10} {k}/{nn} = {k/nn:.5f}   ratio {rr:.4f}   "
              f"z = {z:+7.2f}   {verdict}")

    res = {"per_modulus": per, "pooled": {m: tot[m] for m in MODES},
           "n_moduli": len(seeds), "trials_per_arm": trials}
    (OUT / "final_pooled.json").write_text(json.dumps(res, indent=2, default=str))
    print(f"\nwrote {OUT / 'final_pooled.json'}")


if __name__ == "__main__":
    main()