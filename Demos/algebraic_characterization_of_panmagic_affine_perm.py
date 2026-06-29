"""Numerical demonstrations for:

    Algebraic Characterization of Panmagic Affine Permutations over Z_n

We work with the cyclic ring Z_n and affine maps sigma_{a,b}(x) = a*x + b.

Key proven results being demonstrated:
  * mulAdd_bijective_iff / affine_bijective_iff:
        sigma_{a,b} is a permutation iff a is a unit mod n.
  * orthomorphism_iff:    x |-> sigma(x) - x is a permutation iff (a-1) is a unit.
  * completeMapping_iff:  x |-> sigma(x) + x is a permutation iff (a+1) is a unit.
  * isPanmagic_iff_units: sigma_{a,b} is panmagic iff a, a-1, a+1 are all units.
  * exists_panmagic_iff_coprime_six:
        a panmagic affine permutation of Z_n exists iff gcd(n, 6) = 1
        (universal witness: a = 2).

All functions are self-contained with type hints.
"""

from __future__ import annotations

from math import gcd
from typing import Callable, List, Tuple


# --------------------------------------------------------------------------- #
# Core ring / affine utilities
# --------------------------------------------------------------------------- #
def is_unit(a: int, n: int) -> bool:
    """Return True iff a (mod n) is a unit of Z_n, i.e. gcd(a, n) == 1."""
    return gcd(a % n, n) == 1


def affine(a: int, b: int, n: int) -> Callable[[int], int]:
    """Return the affine map x |-> (a*x + b) mod n on Z_n."""
    return lambda x: (a * x + b) % n


def is_bijection(f: Callable[[int], int], n: int) -> bool:
    """Brute-force check that f : Z_n -> Z_n hits every residue exactly once."""
    return sorted(f(x) for x in range(n)) == list(range(n))


# --------------------------------------------------------------------------- #
# Direct (brute-force) panmagic test by enumerating all 2n broken diagonals
# --------------------------------------------------------------------------- #
def is_panmagic_bruteforce(a: int, b: int, n: int) -> bool:
    """Test panmagicness directly from the definition:

    sigma, x|->sigma(x)-x, and x|->sigma(x)+x are all bijections of Z_n.
    """
    sigma = affine(a, b, n)
    diag_minus = lambda x: (sigma(x) - x) % n
    diag_plus = lambda x: (sigma(x) + x) % n
    return (
        is_bijection(sigma, n)
        and is_bijection(diag_minus, n)
        and is_bijection(diag_plus, n)
    )


# --------------------------------------------------------------------------- #
# Algebraic panmagic test (Theorem isPanmagic_iff_units)
# --------------------------------------------------------------------------- #
def is_panmagic_algebraic(a: int, b: int, n: int) -> bool:
    """Test panmagicness via the algebraic criterion: a, a-1, a+1 all units."""
    return is_unit(a, n) and is_unit(a - 1, n) and is_unit(a + 1, n)


# --------------------------------------------------------------------------- #
# Existence (Theorem exists_panmagic_iff_coprime_six) and witness (a = 2)
# --------------------------------------------------------------------------- #
def panmagic_exists(n: int) -> bool:
    """A panmagic affine permutation of Z_n exists iff gcd(n, 6) == 1."""
    return gcd(n, 6) == 1


def panmagic_witness(n: int) -> Tuple[int, int] | None:
    """Return a certified panmagic (a, b) when one exists, else None.

    The universal witness a = 2, b = 0 works for every n coprime to 6, because
    then a-1 = 1, a = 2, a+1 = 3 are all units of Z_n.
    """
    if gcd(n, 6) == 1:
        return (2 % n, 0)
    return None


# --------------------------------------------------------------------------- #
# Enumeration (P(n) and N(n))
# --------------------------------------------------------------------------- #
def count_good_multipliers(n: int) -> int:
    """P(n) = #{a in Z_n : a, a-1, a+1 all units}."""
    return sum(1 for a in range(n) if is_panmagic_algebraic(a, 0, n))


def count_panmagic(n: int) -> int:
    """N(n) = number of panmagic affine permutations of Z_n = n * P(n)."""
    return n * count_good_multipliers(n)


def _factorize(n: int) -> List[Tuple[int, int]]:
    """Return the prime factorization of n as a list of (prime, exponent)."""
    factors: List[Tuple[int, int]] = []
    m, d = n, 2
    while d * d <= m:
        if m % d == 0:
            k = 0
            while m % d == 0:
                m //= d
                k += 1
            factors.append((d, k))
        d += 1
    if m > 1:
        factors.append((m, 1))
    return factors


def P_closed_form(n: int) -> int:
    """Closed-form multiplicative count: P(n) = prod_{p^k || n} p^{k-1}(p-3).

    Returns 0 if n is divisible by 2 or 3 (Lemmas not_units_zmod_two/three).
    """
    if n == 1:
        return 1
    result = 1
    for p, k in _factorize(n):
        if p in (2, 3):
            return 0
        result *= p ** (k - 1) * (p - 3)
    return result


# --------------------------------------------------------------------------- #
# Demonstrations
# --------------------------------------------------------------------------- #
def demo_equivalence_bruteforce_vs_algebraic(n_max: int = 31) -> None:
    """Confirm the algebraic criterion matches brute force for all small n."""
    print("=" * 70)
    print("Brute force (definition) vs algebraic criterion (a, a-1, a+1 units)")
    print("=" * 70)
    mismatches = 0
    for n in range(1, n_max + 1):
        for a in range(n):
            for b in range(n):
                bf = is_panmagic_bruteforce(a, b, n)
                alg = is_panmagic_algebraic(a, b, n)
                if bf != alg:
                    mismatches += 1
                    print(f"  MISMATCH n={n} a={a} b={b}: bf={bf} alg={alg}")
    print(f"Checked all (a, b) for 1 <= n <= {n_max}: {mismatches} mismatches.\n")


def demo_existence(n_max: int = 30) -> None:
    """Show existence is exactly gcd(n, 6) = 1, with the a = 2 witness."""
    print("=" * 70)
    print("Existence of a panmagic affine permutation (iff gcd(n,6)=1)")
    print("=" * 70)
    print(f"{'n':>3} | {'gcd(n,6)':>8} | {'exists?':>7} | witness (a,b)")
    print("-" * 70)
    for n in range(1, n_max + 1):
        w = panmagic_witness(n)
        exists = panmagic_exists(n)
        # Cross-check: brute-force search for any panmagic (a, b).
        bf_exists = any(
            is_panmagic_bruteforce(a, b, n)
            for a in range(n)
            for b in range(n)
        )
        assert exists == bf_exists, f"existence mismatch at n={n}"
        if w is not None:
            assert is_panmagic_bruteforce(w[0], w[1], n), f"bad witness at n={n}"
        print(f"{n:>3} | {gcd(n, 6):>8} | {str(exists):>7} | {w}")
    print()


def demo_counting(n_max: int = 35) -> None:
    """Show N(n) = n * P(n) and that the closed form matches direct counting."""
    print("=" * 70)
    print("Enumeration: P(n) = #good multipliers, N(n) = n * P(n)")
    print("=" * 70)
    print(f"{'n':>3} | {'P(n) direct':>11} | {'P(n) formula':>12} | {'N(n)':>6}")
    print("-" * 70)
    for n in range(1, n_max + 1):
        p_direct = count_good_multipliers(n)
        p_formula = P_closed_form(n)
        assert p_direct == p_formula, f"P(n) mismatch at n={n}"
        print(f"{n:>3} | {p_direct:>11} | {p_formula:>12} | {count_panmagic(n):>6}")
    print()


def demo_example_square(n: int = 5, a: int = 2, b: int = 0) -> None:
    """Display the pandiagonal array built from sigma_{a,b} on Z_n."""
    print("=" * 70)
    print(f"Pandiagonal array from sigma(x) = {a}x + {b} on Z_{n}")
    print("=" * 70)
    sigma = affine(a, b, n)
    # Cell (i, j) holds (sigma(i) + j) mod n; rows, columns, and both broken
    # diagonal families are transversals exactly because sigma is panmagic.
    grid = [[(sigma(i) + j) % n for j in range(n)] for i in range(n)]
    for row in grid:
        print("  " + " ".join(f"{v:2d}" for v in row))
    print(f"\n  panmagic? {is_panmagic_bruteforce(a, b, n)}\n")


if __name__ == "__main__":
    demo_equivalence_bruteforce_vs_algebraic(n_max=25)
    demo_existence(n_max=30)
    demo_counting(n_max=35)
    demo_example_square(n=5, a=2, b=0)
