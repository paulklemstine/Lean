"""
INDEPENDENT VERIFICATION of the round-48 headline: Stange's Q-kernel method
factors ~75% of instances.

I did not write this method and I did not choose the original seeds. This
script re-runs the SAME trial() from exp_kill.py, imported from stange.py,
on seeds that appear nowhere in the original work (base seeds 900001+,
disjoint from the original 7..11). If 75% is a property of the METHOD it
survives; if it is a property of the particular instances chosen, it will
not.

This is the discipline the program has imposed on every agent since round
47 -- applied here to the program's own headline number, which is overdue.

Also re-runs the selftest, and reports the per-band counts so the
comparison against 46/60, 50/60, 42/60, 28/40, 15/20 is direct.
"""

import random
import sys

sys.path.insert(0, "/home/raver1975/lean/factor-scratch/r48/exp/stange")

from exp_kill import trial  # noqa: E402

# Identical (nbits, b, c, ntrials) to the original sweep, fresh seed bases.
BANDS = [
    dict(nbits=20, b=15, c=10, ntrials=60),
    dict(nbits=26, b=8, c=5, ntrials=60),
    dict(nbits=26, b=8, c=10, ntrials=60),
    dict(nbits=30, b=12, c=10, ntrials=50),
    dict(nbits=40, b=20, c=10, ntrials=30),
]
ORIGINAL = {20: 46, 26: 46, 30: 42, 40: 28}  # nbits -> factors (two 26 bands share)
ORIG_SEQ = "46/60, 50/60, 42/60, 28/40, 15/20"

FRESH_BASE = 900001  # disjoint from every seed in the original work


def main() -> None:
    print("=" * 74)
    print("INDEPENDENT RE-RUN, FRESH SEEDS (base %d), SAME trial() CODE" % FRESH_BASE)
    print("original reported: " + ORIG_SEQ)
    print("=" * 74)

    total_f = total_n = 0
    per_band = []
    for idx, s in enumerate(BANDS):
        facs = 0
        N = s["ntrials"]
        for k in range(N):
            seed = FRESH_BASE + idx * 10_000 + k
            r = trial(seed, s["nbits"], s["b"], s["c"])
            if r:
                facs += 1
        total_f += facs
        total_n += N
        per_band.append((s["nbits"], facs, N))
        print(f"  n~2^{s['nbits']:<3d} b={s['b']:<3d} c={s['c']:<3d}: "
              f"{facs:3d}/{N:<3d} = {facs/N:.3f}")

    print("-" * 74)
    print(f"  fresh-seed sequence : " + ", ".join(f"{f}/{n}" for _, f, n in per_band))
    print(f"  original sequence   : {ORIG_SEQ}")
    print(f"  FRESH TOTAL         : {total_f}/{total_n} = {total_f/total_n:.3f}")
    print(f"  ORIGINAL TOTAL      : 181/240 = 0.754")
    print()

    # Two-proportion comparison against the original 181/240.
    import math
    p1, n1 = total_f, total_n
    p2, n2 = 181, 240
    pooled = (p1 + p2) / (n1 + n2)
    se = math.sqrt(pooled * (1 - pooled) * (1 / n1 + 1 / n2))
    if se > 0:
        z = (p1 / n1 - p2 / n2) / se
        print(f"  difference from original: {p1/n1 - p2/n2:+.4f}, z = {z:+.2f} sigma")
        verdict = ("REPRODUCES -- 75% is a property of the METHOD"
                   if abs(z) < 2.0 else
                   "DOES NOT REPRODUCE -- 75% was a property of the INSTANCES")
        print(f"  VERDICT: {verdict}")
    print()
    print("  NOTE: this re-runs the ORIGINAL agent's trial(), so it tests instance")
    print("  independence, NOT implementation independence. An implementation-level")
    print("  check would require a from-scratch reimplementation.")


if __name__ == "__main__":
    main()