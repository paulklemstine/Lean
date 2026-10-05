#!/usr/bin/env python3
"""
GIFP premise analysis: exact analytic model.

Attacks the PREMISE of Feng-Nitaj-Pan, "Generalized Implicit Factorization
Problem", SAC 2023 (arXiv:2304.08718v3), Theorem 3:
    GIFP(n, alpha, gamma) solvable in poly time when
        gamma > 4*alpha*(1 - sqrt(alpha)),  provided alpha + gamma <= 1
under Assumption 1 (algebraic independence of Coppers polynomials -> HEURISTIC).

Question: for p1, p2 drawn from INDEPENDENT entropy, how likely is the
shared-bit condition at all?  Answer computed exactly here, no floating point
in the combinatorial core.

Bit-length convention: b_0 is the MSB of the k-bit string p_1 ... p_{k-1} the LSB.
A window of length w starting at position i occupies positions [i, i+w).
"""
import math
from fractions import Fraction

# ----------------------------------------------------------------------------
# The combinatorics.  All exact.
# ----------------------------------------------------------------------------

def W_of(k, w):
    """Number of window start positions in a k-bit string for a length-w window."""
    assert 0 <= w <= k
    return k - w + 1


def match_prob_uniform(w):
    """P(two INDEPENDENT UNIFORM w-bit windows are equal) = 2^-w.  Exact."""
    return Fraction(1, 1 << w)


def expected_matching_pairs(k, w, aligned=False):
    """
    E[# of matching (i,j) window PAIRS] for p1,p2 iid uniform on {0,1}^k.

    GIFP (Definition 3) allows the shared bits at DIFFERENT positions in p1 and
    p2, so the natural count is over all ORDERED PAIRS (i,j), of which W^2.
    The `aligned=True` variant restricts to i == j (this is the classical IFP,
    May-Ritzenhofen), and is reported too so both readings are on the table.
    """
    W = W_of(k, w)
    n_pairs = W if aligned else W * W
    return n_pairs * match_prob_uniform(w)          # exact Fraction


def union_bound(k, w, aligned=False):
    """P(exists a matching window pair) <= E[#] = ...  (capped at 1)."""
    e = expected_matching_pairs(k, w, aligned)
    return min(Fraction(1), e), e


def shift_union_bound(k, w):
    """
    Second, independent union bound, via alignment SHIFTS.

    LCS(p1,p2) >= w  <=>  there are a shift s in [-(k-1), k-1] and a start t in
    [0, k-w] with p1[t:t+w) == p2[t+s : t+s+w).  For each (s,t) the event has
    probability 2^-w, and there are (2k-1)*W of them.  This counts each window
    pair exactly once, so it should agree with W^2 * 2^-w to a constant factor.
    """
    W = W_of(k, w)
    return (2 * k - 1) * W * match_prob_uniform(w)


def breakeven_w(k, aligned=False, cap=None):
    """
    Largest integer w with E[#matching pairs] >= 1, i.e. the largest shared
    block that is still PLAUSIBLE under independence.

    aligned=False  (GIFP, unaligned positions): solve W^2 * 2^-w >= 1.
    aligned=True   (IFP, same position):        solve W * 2^-w >= 1.

    Returns None if even w=0 has E >= 1.
    """
    if cap is None:
        cap = k
    best = None
    for w in range(0, cap + 1):
        if expected_matching_pairs(k, w, aligned) >= 1:
            best = w
        else:
            break
    return best


# ----------------------------------------------------------------------------
# The RSA-realistic model: p has its top t bits forced to 1 (the standard
# key-generation convention, so that N = p*q is exactly n bits) and its LSB
# forced to 1 (odd).  This is Model B.
#
# Claim (proved in RESULT.md, Thm 4): with C_i the set of FORCED bit positions
# inside window i (positions forced to the same value in p1 and p2),
#
#       P( win_i(p1) == win_j(p2) )  =  2^( -w + |C_i cap C_j| ).
#
# Hence the top window and the LSB window match with probability 2^2 * 2^-w and
# 2 * 2^-w respectively, and an interior window with 2^-w.  The correction is a
# CONSTANT factor on O(1) of the W windows.
# ----------------------------------------------------------------------------

def forced_positions(k, w, i, t=2):
    """Forced-to-1 positions inside window [i, i+w) of a k-bit RSA prime."""
    C = set()
    for b in range(t):                      # top t bits forced to 1
        if i <= b < i + w:
            C.add(b)
    if i <= k - 1 < i + w:                  # LSB forced to 1 (odd)
        C.add(k - 1)
    return C


def expected_matching_pairs_rsa(k, w, t=2):
    """EXACT E[#matching (i,j) pairs] under Model B (top-t bits and LSB = 1)."""
    W = W_of(k, w)
    tot = Fraction(0)
    Cs = [forced_positions(k, w, i, t) for i in range(W)]
    for i in range(W):
        for j in range(W):
            tot += Fraction(1, 1 << (w - len(Cs[i] & Cs[j])))
    return tot


# ----------------------------------------------------------------------------
# Numbers
# ----------------------------------------------------------------------------

NS = [512, 1024, 2048, 3072, 4096]
ALPHAS = [0.05, 0.10, 0.15, 0.20]


def attack_gamma(alpha):
    """Theorem 3 threshold: gamma > 4*alpha*(1 - sqrt(alpha))."""
    return 4.0 * alpha * (1.0 - math.sqrt(alpha))


def main():
    print("=" * 100)
    print("PART 1/2.  EXACT BREAK-EVEN SHARED-BIT COUNT UNDER INDEPENDENT ENTROPY")
    print("=" * 100)
    print()
    print("k = (1-alpha)*n  = bit-length of p.  w = gamma*n = shared block length in BITS.")
    print("W = k - w + 1     = window start positions in ONE prime.")
    print("GIFP allows the block at DIFFERENT positions in p1 and p2, so the number of")
    print("candidate (i,j) PAIRS is W^2, and E[#matching pairs] = W^2 * 2^-w.")
    print("The aligned count W*2^-w is the classical IFP (same position); reported too.")
    print()

    hdr = (f"{'n':>6} {'alpha':>6} {'k':>7} | {'w_be(GIFP)':>11} {'gamma_be':>10} "
           f"{'w_be(IFP)':>10} {'gamma_be':>10} | {'approx 2*log2(k)':>15} "
           f"{'approx log2(k)':>15}")
    print(hdr)
    print("-" * len(hdr))
    rows = []
    for n in NS:
        for a in ALPHAS:
            k = (1 - a) * n
            ki = int(round(k))
            wb_g = breakeven_w(ki, aligned=False)
            wb_a = breakeven_w(ki, aligned=True)
            print(f"{n:>6} {a:>6.2f} {ki:>7} | {wb_g:>11} {wb_g/n:>10.5f} "
                  f"{wb_a:>10} {wb_a/n:>10.5f} | {2*math.log2(ki):>15.3f} "
                  f"{math.log2(ki):>15.3f}")
            rows.append((n, a, ki, wb_g, wb_a))
    print()
    print("Read: at n=2048, alpha=0.10 the largest block that independence even")
    print("permits is a couple of dozen BITS out of 1843 -- gamma ~ 0.01, not 0.27.")
    print()

    # asymptotics
    print("Asymptotics:  gamma_be * n = 2*log2(W) = 2*log2((1-alpha)n) - 2*log2(gamma n)...")
    print("More precisely solve (k-w+1)^2 = 2^w.  For w = O(log k) this is")
    print("    w = 2*log2(k) - 2*log2(log2 k) + O(1)   (GIFP, unaligned)")
    print("    w =     log2(k) -     log2(log2 k) + O(1)   (IFP, aligned)")
    print("so gamma = Theta(log n / n) and the shared block is Theta(log n) BITS.")
    for n in NS:
        ki = int((1 - 0.1) * n)
        asym = 2 * math.log2(ki) - 2 * math.log2(math.log2(ki))
        print(f"    n={n:>5} k={ki:>5}  2log2 k - 2log2 log2 k = {asym:>7.2f}   "
              f"exact GIFP breakeven = {breakeven_w(ki, False)}")
    print()

    print("=" * 100)
    print("PART 3.  THE ATTACK'S REQUIREMENT vs THE COLLISION-IMPOSSIBLE THRESHOLD")
    print("=" * 100)
    print()
    print("Feng-Nitaj-Pan Theorem 3 needs a shared block of  w_attack = 4*alpha*(1-sqrt(alpha))*n")
    print("BITS -- a fixed FRACTION of n.  Independence caps plausible sharing at")
    print("w_be = 2*log2(k) BITs.  Ratio below; 'ratio' = w_attack / w_be.")
    print()
    hdr2 = (f"{'n':>6} {'alpha':>6} {'k':>7} {'w_attack':>9} {'w_be':>6} "
            f"{'ratio':>9} {'log2(ratio)':>12} {'log10=orders':>14} "
            f"{'P(accidental)':>15} {'-log10 P':>10}")
    print(hdr2)
    print("-" * len(hdr2))
    headline = []
    for n in NS:
        for a in ALPHAS:
            ki = int(round((1 - a) * n))
            g_atk = attack_gamma(a)
            w_atk = int(math.floor(g_atk * n))
            wb = breakeven_w(ki, aligned=False)
            ratio = w_atk / wb
            # P(at least one accidental match of length w_atk) ~ W^2 * 2^-w_atk
            W = W_of(ki, w_atk)
            pacc = float(W * W * Fraction(1, 1 << w_atk)) if w_atk <= 64 else \
                   (W * W) * 2.0 ** (-w_atk)
            neglog10 = -math.log10(pacc) if pacc > 0 else float('inf')
            print(f"{n:>6} {a:>6.2f} {ki:>7} {w_atk:>9} {wb:>6} {ratio:>9.2f} "
                  f"{math.log2(ratio):>12.2f} {math.log10(ratio):>14.3f} "
                  f"{pacc:>15.3e} {neglog10:>10.1f}")
            headline.append((n, a, w_atk, wb, ratio, neglog10))

    print()
    print("The ratio grows LINEARLY in n: w_attack = Theta(n) while w_be = Theta(log n).")
    print("So the gap is not a constant -- it is Theta(n / log n) and unbounded.")
    print()

    print("Aligned (IFP, same-position) reading of the collision threshold, for contrast:")
    hdr3 = f"{'n':>6} {'alpha':>6} {'w_attack':>9} {'w_be(aligned)':>14} {'ratio':>9} {'orders':>9}"
    print(hdr3)
    print("-" * len(hdr3))
    for n in NS:
        for a in ALPHAS:
            ki = int(round((1 - a) * n))
            w_atk = int(math.floor(attack_gamma(a) * n))
            wb = breakeven_w(ki, aligned=True)
            print(f"{n:>6} {a:>6.2f} {w_atk:>9} {wb:>14} {w_atk/wb:>9.2f} "
                  f"{math.log10(w_atk/wb):>9.3f}")
    print()

    print("=" * 100)
    print("EXACT CHECK: the two union bounds agree to a constant factor")
    print("=" * 100)
    for (k, w) in [(1843, 12), (1843, 20), (1843, 21), (1843, 22), (461, 9),
                   (461, 10), (3696, 25)]:
        W = W_of(k, w)
        a1 = W * W * Fraction(1, 1 << w)
        a2 = shift_union_bound(k, w)
        print(f"  k={k:>5} w={w:>3}  W^2*2^-w = {float(a1):>12.6g}   "
              f"(2k-1)*W*2^-w = {float(a2):>12.6g}   ratio={float(a2/a1):>6.3f}")
    print()

    print("=" * 100)
    print("EXACT CHECK: RSA bit-constraints (Model B) change E by O(1/W), not O(1)")
    print("=" * 100)
    print(f"{'k':>7} {'w':>5} {'t':>3} {'E[Model A]':>16} {'E[Model B]':>16} {'rel.diff':>12}")
    for (k, w) in [(1843, 8), (1843, 16), (461, 6), (461, 8), (3696, 12)]:
        for t in (1, 2):
            ea = expected_matching_pairs(k, w)
            eb = expected_matching_pairs_rsa(k, w, t)
            print(f"{k:>7} {w:>5} {t:>3} {float(ea):>16.8f} {float(eb):>16.8f} "
                  f"{float(eb/ea)-1:>12.3e}")
    print()
    print("Model B raises E by a relative amount ~ (2t+1)/W, i.e. it vanishes as k grows.")
    print("The forced top bits buy a CONSTANT factor 4 on a constant number of windows.")
    print()

    print("=" * 100)
    print("CONSISTENCY: alpha + gamma <= 1 required by Theorem 3")
    print("=" * 100)
    for a in ALPHAS:
        g = attack_gamma(a)
        print(f"  alpha={a:>5.2f}  gamma_attack={g:>7.5f}  alpha+gamma={a+g:>7.5f}  "
              f"{'OK' if a + g <= 1 else 'VIOLATED'}")
    print()
    print("Sanity: gamma_attack as a fraction, for each alpha:")
    for a in ALPHAS:
        print(f"  alpha={a:>5.2f}  4a(1-sqrt a) = {attack_gamma(a):>7.5f}"
              f"   -> at n=2048 that is {attack_gamma(a)*2048:>8.1f} bits of p "
              f"(p is {int((1-a)*2048)} bits)")


if __name__ == "__main__":
    main()
