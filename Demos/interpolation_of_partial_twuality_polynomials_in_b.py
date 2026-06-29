"""
Numerical demonstrations for:

    Interpolation of Partial-Twuality Polynomials in Binary Delta-Matroids

This self-contained script illustrates the main theorems by direct enumeration
over the powerset of a finite ground set. Every helper function is inlined and
type-hinted; the script has no third-party dependencies.

Key facts demonstrated:
  * twuality_spectrum:  {|F △ A| : A ⊆ E} = {0,...,|E|}                 (no gaps)
  * ptCoeff_pos_iff:    ptCoeff(E,F,k) > 0  iff  k <= |E|
  * ptCoeff_interpolating: support is exactly the interval [0, |E|]
  * Exact form:         ptCoeff(E,F,k) = C(|E|, k),  P_{E,F}(z) = (1+z)^{|E|}
  * ptCoeff_twist_invariant: ptCoeff(E, F△B, k) = ptCoeff(E, F, k)
  * Worked example:     E={0,1}, F={0}  ->  coefficients (1, 2, 1)
"""

from __future__ import annotations

from itertools import combinations
from math import comb
from typing import Dict, FrozenSet, Iterator, List, Set, Tuple


# ---------------------------------------------------------------------------
# Core set-system primitives
# ---------------------------------------------------------------------------

def symmetric_difference(x: FrozenSet[int], y: FrozenSet[int]) -> FrozenSet[int]:
    """The symmetric difference  x △ y = (x \\ y) ∪ (y \\ x)."""
    return x ^ y


def powerset(ground: FrozenSet[int]) -> Iterator[FrozenSet[int]]:
    """Yield every subset of `ground` as a frozenset."""
    elems: List[int] = sorted(ground)
    for r in range(len(elems) + 1):
        for combo in combinations(elems, r):
            yield frozenset(combo)


def twist(feasible: FrozenSet[int], a: FrozenSet[int]) -> FrozenSet[int]:
    """Twist (partial twuality) of a single feasible set by A:  F △ A."""
    return symmetric_difference(feasible, a)


# ---------------------------------------------------------------------------
# Partial-twuality polynomial
# ---------------------------------------------------------------------------

def pt_coeff(ground: FrozenSet[int], feasible: FrozenSet[int], k: int) -> int:
    """ptCoeff(E, F, k) = #{ A ⊆ E : |F △ A| = k } by direct enumeration."""
    return sum(1 for a in powerset(ground) if len(twist(feasible, a)) == k)


def pt_polynomial(ground: FrozenSet[int], feasible: FrozenSet[int]) -> List[int]:
    """Coefficient vector (c_0, ..., c_n), n = |E|, of the partial-twuality polynomial."""
    n: int = len(ground)
    return [pt_coeff(ground, feasible, k) for k in range(n + 1)]


def twuality_spectrum(ground: FrozenSet[int], feasible: FrozenSet[int]) -> Set[int]:
    """The set of attained sizes {|F △ A| : A ⊆ E}."""
    return {len(twist(feasible, a)) for a in powerset(ground)}


# ---------------------------------------------------------------------------
# Interpolation predicate
# ---------------------------------------------------------------------------

def interpolation_range(coeffs: List[int]) -> Tuple[int, int]:
    """Return (lo, hi): least and greatest index with a positive coefficient."""
    support: List[int] = [k for k, c in enumerate(coeffs) if c > 0]
    return support[0], support[-1]


def is_interpolating(coeffs: List[int]) -> bool:
    """True iff the support of `coeffs` is a contiguous interval [lo, hi] (no gaps)."""
    lo, hi = interpolation_range(coeffs)
    return all(coeffs[k] > 0 for k in range(lo, hi + 1))


def poly_str(coeffs: List[int]) -> str:
    """Pretty-print a coefficient vector as a polynomial in z."""
    terms: List[str] = []
    for k, c in enumerate(coeffs):
        if c == 0:
            continue
        if k == 0:
            terms.append(f"{c}")
        elif k == 1:
            terms.append(f"{c}z")
        else:
            terms.append(f"{c}z^{k}")
    return " + ".join(terms) if terms else "0"


# ---------------------------------------------------------------------------
# Demonstrations
# ---------------------------------------------------------------------------

def demo_worked_example() -> None:
    """E = {0,1}, F = {0}: reproduce the coefficients (1, 2, 1)."""
    print("=" * 70)
    print("Worked example:  E = {0, 1},  F = {0}")
    print("=" * 70)
    ground: FrozenSet[int] = frozenset({0, 1})
    feasible: FrozenSet[int] = frozenset({0})
    for a in powerset(ground):
        t = twist(feasible, a)
        a_str = str(set(a)) if a else "∅"
        t_str = str(set(t)) if t else "∅"
        print(f"  A = {a_str:<10}  F △ A = {t_str:<10}  size = {len(t)}")
    coeffs = pt_polynomial(ground, feasible)
    print(f"\n  Spectrum of sizes : {sorted(twuality_spectrum(ground, feasible))}")
    print(f"  Coefficients      : {coeffs}   (degrees 0,1,2)")
    print(f"  Polynomial        : P(z) = {poly_str(coeffs)}  = (1+z)^2")
    assert coeffs == [1, 2, 1]
    assert is_interpolating(coeffs)
    print("  Interpolating?    :", is_interpolating(coeffs), "on", interpolation_range(coeffs))


def demo_spectrum_and_binomial() -> None:
    """Verify the spectrum is {0,...,n} and ptCoeff = C(n,k) for several E, F."""
    print("\n" + "=" * 70)
    print("Spectrum completeness and exact binomial form")
    print("=" * 70)
    for n in range(0, 6):
        ground: FrozenSet[int] = frozenset(range(n))
        # try every feasible subset F of the ground set
        for feasible in powerset(ground):
            spectrum = twuality_spectrum(ground, feasible)
            coeffs = pt_polynomial(ground, feasible)
            binom = [comb(n, k) for k in range(n + 1)]
            assert spectrum == set(range(n + 1)), (n, feasible, spectrum)
            assert coeffs == binom, (n, feasible, coeffs, binom)
            assert is_interpolating(coeffs)
        print(f"  n = {n}:  every F gives spectrum {{0,...,{n}}}, "
              f"coeffs = {[comb(n, k) for k in range(n + 1)]}  -> (1+z)^{n}  ✓")


def demo_twist_invariance() -> None:
    """ptCoeff(E, F△B, k) = ptCoeff(E, F, k) for all base twists B."""
    print("\n" + "=" * 70)
    print("Twist-orbit invariance:  polynomial unchanged by twisting the base F")
    print("=" * 70)
    ground: FrozenSet[int] = frozenset({0, 1, 2})
    feasible: FrozenSet[int] = frozenset({1})
    base_coeffs = pt_polynomial(ground, feasible)
    print(f"  Base F = {set(feasible)}:  coeffs = {base_coeffs}")
    for b in powerset(ground):
        twisted = twist(feasible, b)
        coeffs = pt_polynomial(ground, twisted)
        assert coeffs == base_coeffs
        b_str = str(set(b)) if b else "∅"
        t_str = str(set(twisted)) if twisted else "∅"
        print(f"    twist base by B = {b_str:<12} -> F△B = {t_str:<12}"
              f" coeffs = {coeffs}  ✓")


def demo_nontriviality() -> None:
    """For nonempty E the support has at least two distinct degrees (0 and |E|)."""
    print("\n" + "=" * 70)
    print("Nontriviality:  support contains distinct degrees 0 and |E| (E nonempty)")
    print("=" * 70)
    for n in range(1, 5):
        ground: FrozenSet[int] = frozenset(range(n))
        feasible: FrozenSet[int] = frozenset({0}) if n >= 1 else frozenset()
        coeffs = pt_polynomial(ground, feasible)
        lo, hi = interpolation_range(coeffs)
        assert lo == 0 and hi == n and lo != hi
        print(f"  n = {n}:  support = [{lo}, {hi}],  distinct degrees -> not a monomial  ✓")


if __name__ == "__main__":
    demo_worked_example()
    demo_spectrum_and_binomial()
    demo_twist_invariance()
    demo_nontriviality()
    print("\nAll demonstrations passed: the single-feasible-set partial-twuality")
    print("polynomial is always the gap-free binomial (1+z)^|E|.")
