#!/usr/bin/env python3
"""
Headroom under ties: numerical companion to
"Tie Profiles and the Ceiling of Spearman's Rho".

Everything is computed with exact rational arithmetic (fractions.Fraction),
so every equality reported below is an exact identity, not a floating-point
coincidence.  Only the Python standard library is used.

Sections
  1. Tie correction identity (variance of midranks).
  2. Product (headroom) bound over *all* pairings, by brute force.
  3. Equality for identical aligned profiles; optimality of aligned pairing.
  4. The factorisation conjecture fails: same tie factors, different ceilings.
  5. Untied dial: the product bound is strict for tied responses.
  6. Nested-profile law: max rho_u = f(coarse), max rho_c = sqrt(f(coarse)/f(fine)).
  7. Pooled reading: what an observed rho = 0.669 certifies.
  8. Exhaustive evidence for the open conjectures (equality count, ratio law).
"""
from __future__ import annotations

import itertools
import math
import random
from fractions import Fraction
from typing import Iterator, List, Sequence

Profile = List[int]


# ---------------------------------------------------------------------------
# Core definitions
# ---------------------------------------------------------------------------

def midranks(profile: Sequence[int]) -> List[Fraction]:
    """Canonical midrank vector: block j of size l_j, preceded by s_j
    observations, receives midrank s_j + (l_j + 1)/2 at each of its positions."""
    ranks: List[Fraction] = []
    s = 0
    for l in profile:
        ranks.extend([Fraction(2 * s + l + 1, 2)] * l)
        s += l
    return ranks


def tie_mass(profile: Sequence[int]) -> int:
    """T(L) = sum_j (l_j^3 - l_j)."""
    return sum(l ** 3 - l for l in profile)


def tie_factor(profile: Sequence[int]) -> Fraction:
    """f(L) = 1 - T(L) / (n^3 - n)   (requires n >= 2)."""
    n = sum(profile)
    return 1 - Fraction(tie_mass(profile), n ** 3 - n)


def rank_ss(profile: Sequence[int]) -> Fraction:
    """Centred sum of squares of the midrank vector."""
    n = sum(profile)
    c = Fraction(n + 1, 2)
    return sum((r - c) ** 2 for r in midranks(profile))


def rank_cov(L: Sequence[int], M: Sequence[int], sigma: Sequence[int]) -> Fraction:
    """Centred cross-product: observation i carries dial midrank R^L_i and
    response midrank R^M_{sigma(i)}."""
    n = sum(L)
    c = Fraction(n + 1, 2)
    rl, rm = midranks(L), midranks(M)
    return sum((rl[i] - c) * (rm[sigma[i]] - c) for i in range(n))


def rho_u(L: Sequence[int], M: Sequence[int], sigma: Sequence[int]) -> Fraction:
    """Textbook (untied-normalised) Spearman rho."""
    n = sum(L)
    return rank_cov(L, M, sigma) / Fraction(n ** 3 - n, 12)


def rho_c_sq(L: Sequence[int], M: Sequence[int], sigma: Sequence[int]) -> Fraction:
    """Square of the tie-corrected rho (Pearson correlation of midranks)."""
    return rank_cov(L, M, sigma) ** 2 / (rank_ss(L) * rank_ss(M))


def aligned_max_rho_u(L: Sequence[int], M: Sequence[int]) -> Fraction:
    """Maximal textbook rho over all pairings = aligned pairing
    (rearrangement inequality, since both midrank vectors are sorted)."""
    return rho_u(L, M, list(range(sum(L))))


def compositions(n: int) -> Iterator[Profile]:
    """All 2^(n-1) tie profiles (ordered block-size lists) of n observations."""
    for mask in range(2 ** (n - 1)):
        prof: Profile = []
        run = 1
        for i in range(n - 1):
            if (mask >> i) & 1:
                prof.append(run)
                run = 1
            else:
                run += 1
        prof.append(run)
        yield prof


def refines(fine: Sequence[int], coarse: Sequence[int]) -> bool:
    """True if every block boundary of `coarse` is also a boundary of `fine`."""
    def cuts(p: Sequence[int]) -> set[int]:
        out, s = set(), 0
        for l in p[:-1]:
            s += l
            out.add(s)
        return out
    return sum(fine) == sum(coarse) and cuts(coarse) <= cuts(fine)


def fmt(x: Fraction) -> str:
    return f"{str(x):>10s}  (= {float(x):.6f})"


# ---------------------------------------------------------------------------
# Demonstrations
# ---------------------------------------------------------------------------

def section(title: str) -> None:
    print("\n" + "=" * 78 + f"\n{title}\n" + "=" * 78)


def demo_tie_correction() -> None:
    section("1. Tie correction identity: SS(L) = ((n^3-n) - T(L))/12 = (n^3-n)/12 * f(L)")
    for L in ([1, 1, 1, 1], [2, 1, 1], [3, 4, 3], [5, 5], [1, 2, 3, 4], [10]):
        n = sum(L)
        lhs = rank_ss(L)
        rhs = Fraction((n ** 3 - n) - tie_mass(L), 12)
        assert lhs == rhs == Fraction(n ** 3 - n, 12) * tie_factor(L)
        assert 0 <= tie_factor(L) <= 1
        print(f"  L={str(L):<14s} n={n:<3d} SS={str(lhs):>7s}  f(L)={fmt(tie_factor(L))}")
    print("  identity holds exactly in every case; 0 <= f(L) <= 1.")


def demo_product_bound() -> None:
    section("2. Product bound rho_u^2 <= f(L) f(M) over ALL pairings (brute force)")
    for L, M in (([2, 1, 1], [1, 2, 1]), ([2, 2, 1], [1, 3, 1]), ([1, 1, 1, 2, 1], [3, 3])):
        n = sum(L)
        best = max(rho_u(L, M, s) for s in itertools.permutations(range(n)))
        worst_gap = min(tie_factor(L) * tie_factor(M) - rho_u(L, M, s) ** 2
                        for s in itertools.permutations(range(n)))
        assert worst_gap >= 0
        print(f"  L={L}, M={M}: max rho_u={float(best):.6f}, max rho_u^2={float(best**2):.6f}"
              f" <= f(L)f(M)={float(tie_factor(L) * tie_factor(M)):.6f}")


def demo_equality_and_alignment() -> None:
    section("3. Identical aligned profiles attain the bound; aligned pairing is optimal")
    for L in ([2, 1, 1], [3, 4, 3], [1, 2, 3, 4]):
        r = aligned_max_rho_u(L, L)
        assert r == tie_factor(L) and r ** 2 == tie_factor(L) ** 2
        print(f"  L=M={L}: aligned rho_u = f(L) = {fmt(r)}")
    rng = random.Random(1)
    for _ in range(3):
        L = rng.choice(list(compositions(6)))
        M = rng.choice(list(compositions(6)))
        brute = max(rho_u(L, M, s) for s in itertools.permutations(range(6)))
        assert brute == aligned_max_rho_u(L, M)
        print(f"  L={L}, M={M}: brute-force max = aligned value = {fmt(brute)}")


def demo_counterexample() -> None:
    section("4. The factorisation conjecture fails")
    A = ([2, 1, 1], [2, 1, 1])
    B = ([2, 1, 1], [1, 1, 2])
    for L, M in (A, B):
        print(f"  L={L}, M={M}: f(L)={tie_factor(L)}, f(M)={tie_factor(M)}, "
              f"max rho_u={aligned_max_rho_u(L, M)}")
    assert tie_factor(A[0]) == tie_factor(B[0]) and tie_factor(A[1]) == tie_factor(B[1])
    assert aligned_max_rho_u(*A) != aligned_max_rho_u(*B)
    print("  identical tie factors (9/10, 9/10) but ceilings 9/10 vs 4/5:")
    print("  the maximal rho is NOT a function of (f(L), f(M)).")


def demo_untied_dial() -> None:
    section("5. Untied dial: max rho_u = f(M), max rho_c = sqrt f(M); product bound strict")
    for M in ([3, 4, 3], [2, 2, 2, 2, 2], [1, 8, 1], [6, 6, 6, 6, 6]):
        n = sum(M)
        flat = [1] * n
        r = aligned_max_rho_u(flat, M)
        fm = tie_factor(M)
        assert r == fm and rho_c_sq(flat, M, list(range(n))) == fm
        assert r ** 2 < fm  # strict, since 0 < f(M) < 1
        print(f"  M={str(M):<18s} f(M)={float(fm):.6f}  max rho_u={float(r):.6f}  "
              f"max rho_u^2={float(r*r):.6f} < f(M)  max rho_c={math.sqrt(fm):.6f}")


def demo_nested() -> None:
    section("6. Nested profiles: headrooms combine as a RATIO")
    pairs = (([1, 2, 1, 1, 3, 2], [3, 2, 5]), ([1, 1, 2, 2, 1, 1], [2, 4, 2]),
             ([2, 1, 1, 2, 1, 1, 2], [4, 6]))
    for fine, coarse in pairs:
        assert refines(fine, coarse)
        r = aligned_max_rho_u(fine, coarse)
        rc2 = rho_c_sq(fine, coarse, list(range(sum(fine))))
        assert r == tie_factor(coarse)
        assert rc2 == tie_factor(coarse) / tie_factor(fine)
        print(f"  fine={fine}, coarse={coarse}")
        print(f"     max rho_u = f(coarse) = {float(r):.6f};  "
              f"max rho_c = sqrt(f_c/f_f) = {math.sqrt(rc2):.6f}  "
              f"(product guess sqrt(f_c f_f) would give {math.sqrt(tie_factor(coarse)*tie_factor(fine)):.6f})")


def demo_pooled_reading(observed: float = 0.669) -> None:
    section(f"7. Pooled reading rho = {observed} with an untied dial")
    print(f"  textbook rho:     f(M) >= {observed:.6f}")
    print(f"  tie-corrected rho: f(M) >= {observed**2:.6f}")
    # Illustrate with equal-block response scales of n = 120 observations.
    print("  equal-block response scales on n = 120 observations:")
    for k in (2, 3, 4, 5, 10):
        M = [120 // k] * k
        fm = float(tie_factor(M))
        verdict_u = "consistent" if fm >= observed else "IMPOSSIBLE"
        verdict_c = "consistent" if fm >= observed ** 2 else "IMPOSSIBLE"
        print(f"    {k:>2d} categories: f(M)={fm:.4f}  textbook-reading {verdict_u:<10s} "
              f"corrected-reading {verdict_c}")


def demo_conjectures(max_n: int = 7) -> None:
    section("8. Exhaustive evidence for open conjectures")
    print("   n | #pairs with max rho_u^2 = f(L)f(M) | 3*2^(n-1)-2 | ratio-law violations | nested equalities")
    for n in range(2, max_n + 1):
        eq = viol = nested_eq = nested_tot = 0
        profs = list(compositions(n))
        for L in profs:
            for M in profs:
                r = aligned_max_rho_u(L, M)
                fl, fm = tie_factor(L), tie_factor(M)
                if r * r == fl * fm:
                    eq += 1
                if fl > 0 and fm > 0:
                    rc2 = r * r / (fl * fm)
                    bound = min(fl, fm) / max(fl, fm)
                    if rc2 > bound:
                        viol += 1
                    if refines(L, M) or refines(M, L):
                        nested_tot += 1
                        nested_eq += rc2 == bound
        print(f"  {n:>2d} | {eq:>34d} | {3 * 2 ** (n - 1) - 2:>11d} | {viol:>20d} | {nested_eq}/{nested_tot}")


def main() -> None:
    demo_tie_correction()
    demo_product_bound()
    demo_equality_and_alignment()
    demo_counterexample()
    demo_untied_dial()
    demo_nested()
    demo_pooled_reading()
    demo_conjectures()


if __name__ == "__main__":
    main()
