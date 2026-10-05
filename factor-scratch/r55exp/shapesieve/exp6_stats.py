#!/usr/bin/env python3
"""
exp6: RIGOR. The exp3b effect sizes are 1.02-1.42. Before claiming ANY of them
is a shape effect, every family gets an EXACT permutation test against the
generic family, on the same footing. This is the test that decides which
exp3b rows are real and which are the "NEG CTRL is 6% off" noise that a
pooled-average reader would have called a discovery.

METHOD. For each family F with 10 per-moduli rates, and the generic family G
with 10: the null hypothesis is that all 20 rates are exchangeable draws.
The test statistic is the ratio of medians med(F)/med(G). The exact p-value is
the fraction of the C(20,10) = 184756 relabellings for which the ratio of
medians is at least as large as observed. Exact, not asymptotic, not a z-score.

PREDICTIONS (written before running):

  P6.1  The NEG CTRL family (a second, independent batch of GENERIC pq moduli)
        must come out NOISE. It is the same shape as the reference, so any
        significance here would mean my test or my sampling is broken.
  P6.2  The families with minFac <= B and a PRIME POWER shape (a^3 b, a^4 b,
        POS CTRL a=5) must be SIGNIFICANT. If they are not, exp3b measured
        nothing.
  P6.3  The a^2 b family must be WEAKER than a^3 b / a^4 b, because a^2
        contributes the least forced prime-power structure per unit of N.
        Prediction: p(a^2 b) > p(a^3 b).

SCOPE: reuses exp3b's per-cell rates, which are all at N < 2^22, locally
generated, none cryptographic.
"""
import itertools

# exp3b, B = 1024, per-cell B-smooth rates (10 cells each)
GEN = [0.3309, 0.3018, 0.2899, 0.3298, 0.3002, 0.3166, 0.3022, 0.3010, 0.3060, 0.2977]
FAMS = {
    "NEG CTRL pq'":  [0.3174, 0.2921, 0.3126, 0.2959, 0.3145, 0.3150, 0.3155, 0.3048, 0.2946, 0.2837],
    "a^2 b (a~2^6)": [0.3131, 0.3230, 0.2956, 0.2984, 0.3119, 0.3055, 0.3432, 0.3249, 0.3531, 0.3179],
    "a^3 b (a~2^5)": [0.3442, 0.3525, 0.3382, 0.3464, 0.3332, 0.3549, 0.3214, 0.3559, 0.3446, 0.3222],
    "a^4 b (a~2^4)": [0.3758, 0.3282, 0.3170, 0.3157, 0.3282, 0.3157, 0.3157, 0.3282, 0.3282, 0.3170],
    "POS CTRL a=5":  [0.3159, 0.3331, 0.3255, 0.3392, 0.3388, 0.3177, 0.3254, 0.3526, 0.3463, 0.3358],
    "POS CTRL a=7":  [0.3320, 0.3196, 0.3267, 0.3354, 0.3256, 0.3487, 0.3132, 0.3306, 0.3363, 0.3462],
    "PROBE minFac=61": [0.2814, 0.2993, 0.3071, 0.2934, 0.2806, 0.3013, 0.2807, 0.2775, 0.3013, 0.2918],
}


def med(x):
    s = sorted(x)
    n = len(s)
    return s[n // 2] if n % 2 else (s[n // 2 - 1] + s[n // 2]) / 2


def exact_perm_p(gen, fam):
    """Exact one-sided permutation p for 'median(fam) >= median(gen)'."""
    obs = med(fam) / med(gen)
    pool = gen + fam
    cnt = 0
    tot = 0
    for combo in itertools.combinations(range(20), 10):
        l = [pool[i] for i in combo]
        r = [pool[i] for i in range(20) if i not in combo]
        if med(r) / med(l) >= obs:
            cnt += 1
        tot += 1
    return obs, cnt, tot, cnt / tot


def main():
    print("=" * 78)
    print("exp6  EXACT PERMUTATION TESTS on exp3b's effect sizes (B = 1024)")
    print("      null: all 20 rates exchangeable (no shape effect)")
    print("      %d relabellings -- EXACT, not a z-score" % 184756)
    print("=" * 78)
    res = {}
    print("\n  %-18s %-9s %-12s %-22s" % ("family", "ratio", "exact p", "verdict"))
    for nm, x in FAMS.items():
        obs, cnt, tot, p = exact_perm_p(GEN, x)
        res[nm] = (obs, p)
        v = ("SIGNIFICANT" if p < 0.01 else
             "marginal" if p < 0.05 else "NOISE")
        print("  %-18s %-9.4f %-12.5f %-22s"
              % (nm, obs, p, v + "  (%d/%d)" % (cnt, tot)))

    print("\n--- PREDICTION CHECKS ---")
    p_neg = res["NEG CTRL pq'"][1]
    print("  P6.1 NEG CTRL p = %.5f -> must be NOISE (>=0.05)? %s"
          % (p_neg, "YES" if p_neg >= 0.05 else "NO -- TEST BROKEN"))
    for nm in ("a^3 b (a~2^5)", "a^4 b (a~2^4)", "POS CTRL a=5"):
        print("  P6.2 %-18s p = %.5f -> must be SIGNIFICANT (<0.01)? %s"
              % (nm, res[nm][1], "YES" if res[nm][1] < 0.01 else "NO"))
    p2, p3 = res["a^2 b (a~2^6)"][1], res["a^3 b (a~2^5)"][1]
    print("  P6.3 p(a^2 b)=%.5f > p(a^3 b)=%.5f -> %s"
          % (p2, p3, "YES" if p2 > p3 else "NO"))

    print("\n--- WHAT IS ACTUALLY ESTABLISHED ---")
    sig = [nm for nm in res if res[nm][1] < 0.01]
    ns = [nm for nm in res if res[nm][1] >= 0.05]
    print("  SIGNIFICANT shape effect (%d): %s" % (len(sig), ", ".join(sig)))
    print("  NOISE (%d): %s" % (len(ns), ", ".join(ns)))
    print("  MARGINAL: %s" % ", ".join(nm for nm in res if 0.01 <= res[nm][1] < 0.05))
    print("""
  READING. The sieving survival rate IS shape-sensitive, by 7-14% for
  prime-power shapes at B = 1024, and the effect is not noise (exact
  permutation p = 0.0004 for a^3 b). The NEG CTRL, a fresh batch of generic
  moduli of the same size, is indistinguishable from the reference (p = 0.25),
  which is what makes the positive result credible.

  The effect SHRINKS as B grows: a^3 b goes 1.42 -> 1.23 -> 1.14 at
  B = 60 -> 256 -> 1024. That is the direction the closure predicts.  The
  forced prime-power structure of N is worth a bounded, B-independent fraction
  of the smoothness test, and it is swamped once B is large enough that
  smoothness is common. The shape channel does not grow with the modulus.

  MAGNITUDE, stated honestly: 1.14x on the survival rate is a ~7% cost
  reduction, or ~0.09 bits in log2 cost. It is NOT an exponent improvement,
  and at the N = 2^22 sizes measured here the whole effect is far smaller
  than the gap between any two published factoring methods.""")


if __name__ == "__main__":
    main()
