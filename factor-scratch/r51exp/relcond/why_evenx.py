"""
WHY WOULD even_x BE SLIGHTLY BETTER?  Mechanism hunt.

OBSERVATION.  At 40000 trials/arm, conditioning on x even (equivalently: sampling
from the SQUARE SUBGROUP <g^2> of <g>) gives a mean smooth-hit ratio of 1.024
(mean z +0.99), and x divisible by 4 (the subgroup <g^4>) gives 1.026 (+1.08).
Odd x gives 1.009 (+0.35), i.e. nothing.  The 60-relation run put x_mod4 at 1.15;
that was resolution.  But 1.02-1.03 with a monotone pattern
(odd 1.009 < even 1.024 < mult-of-4 1.026) is not obviously noise.

HYPOTHESIS H1 -- STRUCTURE, NOT MAGIC.  Restricting x to multiples of m restricts
the candidate to the subgroup <g^m>, of size ord(g)/gcd(ord(g), m).  If ord(g) is
even, the square subgroup is a proper subgroup of index 2, and its elements are
the SQUARES mod n.  Squares are sparser in [1,n) (about n/4 of them), and -- this
is the part that could matter -- the density of FB-smooth numbers AMONG squares
can differ from the density among all integers, at FINITE size, because the
integer representatives of squares are not equidistributed mod small primes at
the O(n^-1/2) level we are measuring at.

HYPOTHESIS H2 -- PURE NOISE with a selection effect: I ran 3 arms and reported the
largest, and the moduli are not independent (same host, same B).

DECISIVE TEST: vary the SUBGROUP SIZE directly by conditioning on x mod m for many
m, and check whether the effect tracks ord(g) (H1) or wanders (H2).  If the gain
is a property of the subgroup rather than of the parity, it should scale with
m in the way group theory predicts.  If it is noise, it will not.

Also measures the ACTUAL subgroup sizes, so the prediction is not hand-waved.

Run: python3 why_evenx.py
"""

from __future__ import annotations

import json
import math
import random
import sys
from pathlib import Path

import numpy as np
from sympy.ntheory import n_order

sys.path.insert(0, "/home/raver1975/lean/factor-scratch/r51exp/relcond")

from relcond_core import gen_semiprime, pi, smooth_mask_batch, strata  # noqa: E402

OUT = Path(__file__).parent / "results"


def rate(n, g, b, m, trials, rng):
    """Smooth-hit rate sampling x uniformly from the m-th power subgroup."""
    hits = 0
    done = 0
    while done < trials:
        bs = min(2000, trials - done)
        xs = [m * rng.randrange(0, n // m) for _ in range(bs)]
        vals = np.fromiter((pow(g, xx, n) for xx in xs), dtype=np.int64, count=bs)
        hits += int(smooth_mask_batch(vals, b).sum())
        done += bs
    return hits, trials


def main() -> None:
    print("=" * 78)
    print("MECHANISM HUNT -- does the even_x effect track the SUBGROUP?")
    print("=" * 78)
    b = 2 ** 14
    trials = 30000
    print(f"  B={b} (pi={pi(b)}), {trials} trials/arm.  m = 1 is uniform.\n")
    rows = []
    for sd in (5001, 5002, 5003, 5004, 5005, 5006):
        rng = random.Random(sd)
        n, p, q = gen_semiprime(40, rng)
        g = 2 + 2 * rng.randrange(0, 6)
        while math.gcd(g, n) != 1:
            g += 1
        ord_g = int(n_order(g, n))
        st = strata(n, p, q, g)
        # subgroup size for the m-th power condition, from the ACTUAL order
        sub = {m: ord_g // math.gcd(ord_g, m) for m in (1, 2, 3, 4, 6, 8)}
        print(f"  seed {sd}: stratum {st['cell']}, ord(g) = {ord_g}"
              f"  (subgroup sizes {sub})")
        hits = {}
        for m in sub:
            r2 = random.Random(sd * 7919 + m)
            hits[m] = rate(n, g, b, m, trials, r2)
        hu = hits[1][0]
        pu = hits[1][1]
        ru = hu / pu
        for m in sub:
            rr = (hits[m][0] / hits[m][1]) / ru
            rows.append({"seed": sd, "stratum": st["cell"], "m": m,
                         "subgroup": sub[m], "ratio": rr})
            print(f"      m={m}  |<g^{m}>|={sub[m]:>12}  ratio vs uniform = {rr:.4f}")
        print()

    print("  POOLED BY m (mean ratio over moduli):")
    summary = {}
    for m in (1, 2, 3, 4, 6, 8):
        rr = [r["ratio"] for r in rows if r["m"] == m]
        mr = float(np.mean(rr))
        summary[m] = mr
        print(f"    m={m}: mean ratio {mr:.4f}   range {min(rr):.4f}..{max(rr):.4f}"
              f"   (uniform=1 by construction)")
    print("\n  H1 PREDICTS: the gain should track |<g^m>| / ord(g), i.e. be")
    print("  LARGEST where the subgroup is SMALLEST relative to ord(g).")
    print("  H2 PREDICTS: no monotone structure; the values scatter around 1.")
    # correlation between subgroup index and ratio
    idx, rat = [], []
    for r in rows:
        if r["m"] == 1:
            continue
        idx.append(r["subgroup"])
        rat.append(r["ratio"])
    idx = np.array(idx, dtype=float)
    rat = np.array(rat)
    c = float(np.corrcoef(np.log(idx), rat)[0, 1]) if idx.std() > 0 else 0.0
    print(f"\n  corr(ln|<g^m>|, ratio) = {c:+.4f}")
    print(f"  (H1 wants a clearly NEGATIVE correlation: smaller subgroup -> higher rate)")

    (OUT / "why_evenx.json").write_text(json.dumps(
        {"rows": rows, "summary": summary, "corr": c}, indent=2, default=str))
    print(f"\nwrote {OUT / 'why_evenx.json'}")


if __name__ == "__main__":
    main()