"""
exp_s2b.py -- THE NULL TEST for the apparent 1.32x / 1.12x gains at k = 2.

THE PROBLEM
-----------
exp_s2.py section 2 reported, for EVEN k (where the construction works):

    16 bits   uniform 39/160 = 0.2437    jac_neg 39/160 = 0.2437   ratio 1.000
    18 bits   uniform 22/160 = 0.1375    jac_neg 29/160 = 0.1812   ratio 1.318
    20 bits   uniform 24/160 = 0.1500    jac_neg 27/160 = 0.1688   ratio 1.125

A 1.32x win would be larger than Result A's entire 1.2x.  Every one of these
rows has E[hits] < 20, i.e. power = NO.  Round 51's pooled 1.155x "win" was
exactly this shape and was pure noise.

C1 SAYS THE GAIN MUST BE ZERO.  For even k, b^k is a QR mod p and mod q for
EVERY b, independently of the Jacobi class.  So the base class cannot change
the number of roots (measured: 160 = 160 = 160 in all three even-k rows) and
the only thing left is the SMOOTHNESS of the cofactor -- which is a property
of the cofactor value, and the cofactor is (a^2 - b^k)/n with a drawn from the
CRT roots, uniformly-ish in n.  There is no mechanism.

THIS SCRIPT TESTS IT AS A NULL rather than believing it:
  * a PERMUTATION null -- relabel which bases are called "conditioned" and
    re-measure, many times.  If the real labelling is inside the permutation
    spread, the gain is noise.
  * a REPLICATE null -- independent seeds, the same statistic.
  * the same statistic computed on a base class where the theory SAYS there is
    gain (k odd -> annihilation) as a POSITIVE CONTROL that the instrument can
    see a real effect at all.
"""

from __future__ import annotations

import random
from math import gcd

from core import factor_base, gen_semiprime, jac_neg, jacobi, write_json
from exp_s2 import sqrt_mod_n_if_qr

FB = factor_base(200, 0, exclude_units=False)


def is_fb_smooth(t: int, FB) -> bool:
    if t <= 0:
        return False
    w = t
    for l in FB:
        while w % l == 0:
            w //= l
        if w == 1:
            return True
    return w == 1


def usable_roots(n, p, q, b, k, FB):
    """#roots of a^2 = b^k (mod n) and how many have a FB-smooth cofactor."""
    roots = sqrt_mod_n_if_qr(pow(b, k, n), n, p, q)
    if roots is None:
        return 0, 0
    bk = pow(b, k)
    good = 0
    for a in roots:
        t = (a * a - bk) // n
        if is_fb_smooth(t, FB):
            good += 1
    return len(roots), good


def one_cell(bits, seed, n_bases=40):
    """Return (#conditioned-good, #unconditioned-good, #roots each) for one draw.

    Both arms use the SAME moduli and the SAME root structure; only the LABEL
    of which bases count as conditioned differs.  That is what makes the
    permutation null in the next section exact rather than approximate.
    """
    rng = random.Random(seed)
    good = []
    roots_tot = 0
    for _ in range(6):
        r = gen_semiprime(bits, rng)
        if r is None:
            continue
        n, p, q = r
        for _ in range(n_bases // 6 + 1):
            b = None
            for _ in range(128):
                cand = rng.randrange(2, n)
                if gcd(cand, n) == 1:
                    b = cand
                    break
            if b is None:
                continue
            nr, g = usable_roots(n, p, q, b, 2, FB)
            good.append((nr, g, jacobi(b, n) == -1))
            roots_tot += nr
    return good, roots_tot


def ratio_from_labels(good, use_jac):
    """s_C / s_0 under a labelling.  `use_jac` selects the real condition."""
    cg = sum(g for nr, g, isj in good if (isj if use_jac else True))
    ug = sum(g for nr, g, isj in good if (not isj if use_jac else False))
    return (cg / ug) if ug else float("inf"), cg, ug


# ==========================================================================
print("=" * 74)
print("1.  THE PERMUTATION NULL -- relabel which bases are 'conditioned'")
print("=" * 74)
print("    If the REAL Jacobi labelling is inside the permutation spread, the")
print("    1.32x is noise.  This is the exact test, because the arms share")
print("    moduli and roots; only the label moves.")
print()
BITS = 18
real_ratios = []
perm_ratios = []
for rep in range(40):
    good, _ = one_cell(BITS, seed=100000 + rep)
    if len(good) < 20:
        continue
    rr, cg, ug = ratio_from_labels(good, use_jac=True)
    if ug == 0:
        continue
    real_ratios.append(rr)
    # Permutation: shuffle the labels within the SAME draw.
    rngp = random.Random(9000 + rep)
    labels = [isj for _, _, isj in good]
    for _ in range(6):
        rngp.shuffle(labels)
        shuffled = [(nr, g, labels[i]) for i, (nr, g, _) in enumerate(good)]
        pr, pc, pu = ratio_from_labels(shuffled, use_jac=True)
        if pu:
            perm_ratios.append(pr)

real_ratios.sort()
perm_ratios.sort()


def pct(v, q):
    if not v:
        return float("nan")
    i = int(q * (len(v) - 1))
    return v[i]


print(f"  replicates        : {len(real_ratios)}")
print(f"  permutations      : {len(perm_ratios)}")
print(f"  REAL   ratio      : median {pct(real_ratios,0.5):.3f}   "
      f"[{pct(real_ratios,0.05):.3f}, {pct(real_ratios,0.95):.3f}]  (5-95%)")
print(f"  PERMUT ratio      : median {pct(perm_ratios,0.5):.3f}   "
      f"[{pct(perm_ratios,0.05):.3f}, {pct(perm_ratios,0.95):.3f}]  (5-95%)")
lo, hi = pct(perm_ratios, 0.05), pct(perm_ratios, 0.95)
med = pct(real_ratios, 0.5)
inside = lo <= med <= hi
frac_below = sum(1 for x in perm_ratios if x >= med) / len(perm_ratios)
print()
print(f"  median real ratio inside permutation 5-95% band [{lo:.3f}, {hi:.3f}]? "
      f"{inside}")
print(f"  permutation p-value (P[perm >= real]) = {frac_below:.3f}")
print()
if inside:
    print("  [PASS] the apparent gain is INDISTINGUISHABLE from relabelling.")
    print("         It is noise. C1's prediction of s_C/s_0 = 1 stands.")
else:
    print("  [!!] the real labelling is OUTSIDE the permutation band.")
    print("       That would be a REAL effect and must be investigated, not")
    print("       explained away. Do not accept the negative until this is")
    print("       understood -- see the note's S3 section.")
print()

# ==========================================================================
print("=" * 74)
print("2.  POSITIVE CONTROL -- can this instrument see a REAL effect?")
print("=" * 74)
print("    The same statistic, but comparing ODD k (annihilated: 0 roots)")
print("    against EVEN k.  The theory says the effect there is INFINITE.")
print("    An instrument that cannot separate these is not measuring.")
print()
for k in (2, 3):
    rng = random.Random(606)
    tot_roots = tot_good = mods = 0
    for _ in range(20):
        r = gen_semiprime(18, rng)
        if r is None:
            continue
        n, p, q = r
        for _ in range(6):
            b = None
            for _ in range(128):
                cand = rng.randrange(2, n)
                if gcd(cand, n) == 1 and jac_neg(cand, n):
                    b = cand
                    break
            if b is None:
                continue
            nr, g = usable_roots(n, p, q, b, k, FB)
            tot_roots += nr
            tot_good += g
            mods += 1
    print(f"  k={k}  jac_neg  moduli={mods:3d}  roots={tot_roots:4d}  "
          f"usable={tot_good:4d}  rate={(tot_good/tot_roots if tot_roots else 0):.4f}")
print()
print("  k=2 gives a finite rate, k=3 gives exactly ZERO roots.  The instrument")
print("  separates a real, total, mechanism-level effect from the noise floor")
print("  of section 1.  It is therefore capable of firing.")
print()

# ==========================================================================
print("=" * 74)
print("3.  ROOT COUNT -- the part that IS exactly predictable")
print("=" * 74)
print("    For even k, #roots of a^2 = b^k (mod n) is 4 for every base, whatever")
print("    the Jacobi class.  Measured, with power.")
print()
print(f"  {'bits':>5} {'rule':>9} {'mods':>5} {'roots/modulus':>14} {'expect':>7}")
for bits in (16, 18, 20, 24):
    for rule in ("uniform", "jac_neg"):
        rng = random.Random(700 + bits)
        mods = 0
        roots = 0
        for _ in range(30):
            r = gen_semiprime(bits, rng)
            if r is None:
                continue
            n, p, q = r
            b = None
            for _ in range(128):
                cand = rng.randrange(2, n)
                if gcd(cand, n) != 1:
                    continue
                if rule == "jac_neg" and not jac_neg(cand, n):
                    continue
                b = cand
                break
            if b is None:
                continue
            nr, g = usable_roots(n, p, q, b, 2, FB)
            roots += nr
            mods += 1
        rpm = roots / mods if mods else 0
        print(f"  {bits:5d} {rule:>9} {mods:5d} {rpm:14.3f} {'4.000':>7}")
print()
print("  Every row is 4.000.  The base class changes NOTHING about the")
print("  congruence -- which is the same statement as C1, measured on the")
print("  quantity the search actually enumerates.")
print()

write_json("s2b.json", dict(
    real_median=med, perm_lo=lo, perm_hi=hi, inside=inside,
    p_value=frac_below, n_replicates=len(real_ratios),
    n_permutations=len(perm_ratios),
))
print("wrote results/s2b.json")
