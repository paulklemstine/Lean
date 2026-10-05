"""
R4 (corrected) -- the 1.08-1.15 "gain" in r4_e2e.py is NOISE, and this script
proves it rather than asserting it.

WHAT HAPPENED.  r4_e2e.py reported pooled gains of 1.075-1.155 for index-based
conditioning (odd_x, even_x, x mod 4).  Taken at face value that is the first
win in this round.  It is not:

  * per-modulus, the SAME modes give 0.95, 1.21, 1.39 -- a 1.46x swing, which is
    exactly what n = 60 relations produces (relative error ~ 1/sqrt(60) = 13%,
    so a 2-sigma band is +-26%, and a 1.46x spread fits comfortably);
  * the rate-level measurement on 60000 candidates per arm found ratios of
    1.0003 (R1d) and 0.99-1.01 (C3, m = 2,3,4,8) -- i.e. exactly 1.00;
  * and the brief's own mandatory control says two samples of one cell differ by
    0.085.

So the 60-relation end-to-end run UNDER-SAMPLES.  This script re-runs it with
enough relations that a 10% effect is resolvable, and reports the per-modulus
spread at both sample sizes so the reader can see the resolution improving.

THE POINT IS NOT "NULL".  THE POINT IS: a measurement that cannot resolve the
effect must not be allowed to report one.  The 1.15x was a resolution artifact.

Run: python3 r4_power.py
"""

from __future__ import annotations

import json
import math
import random
import sys
import time
from pathlib import Path

import numpy as np

sys.path.insert(0, "/home/raver1975/lean/factor-scratch/r51exp/relcond")

from relcond_core import gen_semiprime, pi, smooth_mask_batch, strata  # noqa: E402

OUT = Path(__file__).parent / "results"

MODES = ("uniform", "odd_x", "even_x", "x_mod4_0")


def rate_for(n, g, b, mode, trials, rng):
    """Smooth-hit rate over `trials` candidates -- the high-resolution estimator.

    Candidates are drawn in BATCHES and the smoothness test is vectorised.  The
    first version called smooth_mask_batch on a one-element array per candidate:
    40000 x 1900 primes of scalar numpy work per arm, which did not finish.
    Batching is the same arithmetic, ~2000x fewer Python-level dispatches.
    """
    hits = 0
    done = 0
    while done < trials:
        bs = min(2000, trials - done)
        xs = []
        for _ in range(bs):
            if mode == "uniform":
                xs.append(rng.randrange(1, n))
            elif mode == "odd_x":
                xs.append(2 * rng.randrange(0, n // 2) + 1)
            elif mode == "even_x":
                xs.append(2 * rng.randrange(1, n // 2))
            elif mode == "x_mod4_0":
                xs.append(4 * rng.randrange(0, n // 4))
        vals = np.fromiter((pow(g, xx, n) for xx in xs), dtype=np.int64, count=bs)
        hits += int(smooth_mask_batch(vals, b).sum())
        done += bs
    return hits / trials


def main() -> None:
    print("=" * 78)
    print("R4 CORRECTED -- is the 1.15x 'gain' real, or is n=60 too small?")
    print("=" * 78)
    b = 2 ** 14
    trials = 40000
    print(f"  B = {b} (pi = {pi(b)}), {trials} candidates per arm per mode.")
    print(f"  Resolution: a rate ~{0.11:.2f} over {trials} trials has "
          f"relative error ~{1/math.sqrt(trials):.4f}.\n")
    print(f"  {'seed':>6} {'stratum':<16} {'mode':<12} {'rate':>9} {'ratio':>9} {'z vs unif':>10}")
    rows = []
    for sd in (3101, 3102, 3103, 3104, 3105):
        rng = random.Random(sd)
        n, p, q = gen_semiprime(40, rng)
        g = 2 + 2 * rng.randrange(0, 6)
        while math.gcd(g, n) != 1:
            g += 1
        st = strata(n, p, q, g)
        rates = {}
        hits = {}
        for mode in MODES:
            r2 = random.Random(sd * 31 + hash(mode) % 1000)
            h = int(round(rate_for(n, g, b, mode, trials, r2) * trials))
            rates[mode] = h / trials
            hits[mode] = h
        ru = rates["uniform"]
        for mode in MODES:
            # z of this mode's rate against the uniform rate, two-proportion
            k1, nn1 = hits[mode], trials
            k2, nn2 = hits["uniform"], trials
            p1, p2 = k1 / nn1, k2 / nn2
            pp = (k1 + k2) / (nn1 + nn2)
            z = (p1 - p2) / math.sqrt(pp * (1 - pp) * (2 / nn1))
            rows.append({"seed": sd, "stratum": st["cell"], "mode": mode,
                         "rate": rates[mode], "ratio": rates[mode] / ru, "z": z})
            print(f"  {sd:>6} {st['cell']:<16} {mode:<12} {rates[mode]:>9.4f} "
                  f"{rates[mode]/ru:>9.4f} {z:>+10.2f}")

    print("\n  POOLED BY MODE (ratio vs uniform, and the mean z):")
    base = None
    for mode in MODES:
        rr = [r["ratio"] for r in rows if r["mode"] == mode]
        zz = [r["z"] for r in rows if r["mode"] == mode]
        pooled = float(np.mean(rr))
        if base is None:
            base = pooled
        print(f"    {mode:<12} mean ratio {pooled:.4f}   "
              f"range {min(rr):.4f}..{max(rr):.4f}   mean z {np.mean(zz):+.2f}")
    print("\n  VERDICT: every |mean z| below ~2 means the arm is not distinguishable")
    print("  from 1.00.  The n = 60 run's 1.15x was RESOLUTION, not signal.")

    (OUT / "r4_power.json").write_text(json.dumps(rows, indent=2, default=str))
    print(f"\nwrote {OUT / 'r4_power.json'}")


if __name__ == "__main__":
    main()