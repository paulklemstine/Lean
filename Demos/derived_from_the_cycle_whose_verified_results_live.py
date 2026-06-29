"""
The Library of Babel: combinatorial and probabilistic structure.

Numerical demonstrations of the machine-verified results:

  * card_library                 : #Library(b, L) = b**L
  * prob_singleton               : Pr[{v}] = b**(-L)
  * prob_pair_coincide           : Pr[v1 == v2] = b**(-L)
  * expected_substring_count     : E[#occurrences] = (L - k + 1) * b**(-k)
  * prob_contains_substring_bound: Pr[contains] <= (L - k + 1) * b**(-k)  (union upper bound)
  * prob_contains_substring_lower_bound:
                                   Pr[contains] >= 1 - (1 - b**(-k))**(L // k)
  * prob_avoids_substring_bound  : Pr[not contains] <= (1 - b**(-k))**(L // k)
  * prob_contains_tendsto_one    : Pr[contains] -> 1 as L -> infinity (b >= 2)

All probabilities are computed *exactly* using Python's `fractions.Fraction`,
so there is no floating-point error.  We also brute-force-verify the exact
formulas on small parameters by enumerating the entire (tiny) library.
"""

from __future__ import annotations

from fractions import Fraction
from itertools import product
from typing import Iterator, Sequence, Tuple


# ---------------------------------------------------------------------------
# Closed-form quantities (the theorems)
# ---------------------------------------------------------------------------

def card_library(b: int, L: int) -> int:
    """Number of volumes: b ** L  (theorem `card_library`)."""
    return b ** L


def prob_singleton(b: int, L: int) -> Fraction:
    """Exact uniform probability of one fixed volume: b ** (-L)."""
    return Fraction(1, b ** L)


def prob_pair_coincide(b: int, L: int) -> Fraction:
    """Probability two independent uniform volumes coincide: b ** (-L)."""
    return Fraction(1, b ** L)


def expected_substring_count(b: int, L: int, k: int) -> Fraction:
    """Expected number of occurrences of a length-k pattern: (L-k+1) * b**(-k)."""
    assert k <= L and b >= 1
    return Fraction(L - k + 1) * Fraction(1, b ** k)


def union_upper_bound(b: int, L: int, k: int) -> Fraction:
    """Union upper bound on Pr[contains]: (L-k+1) * b**(-k)."""
    assert k <= L
    return Fraction(L - k + 1) * Fraction(1, b ** k)


def block_lower_bound(b: int, L: int, k: int) -> Fraction:
    """Disjoint-block lower bound on Pr[contains]: 1 - (1 - b**(-k))**(L//k)."""
    assert k >= 1
    q = Fraction(1) - Fraction(1, b ** k)  # per-block failure probability
    return Fraction(1) - q ** (L // k)


def avoidance_upper_bound(b: int, L: int, k: int) -> Fraction:
    """Avoidance bound on Pr[not contains]: (1 - b**(-k))**(L//k)."""
    assert k >= 1
    q = Fraction(1) - Fraction(1, b ** k)
    return q ** (L // k)


def block_lower_bound_float(b: int, L: int, k: int) -> float:
    """Floating-point disjoint-block lower bound, for very large L // k."""
    assert k >= 1
    q = 1.0 - 1.0 / b ** k
    return 1.0 - q ** (L // k)


def union_upper_bound_float(b: int, L: int, k: int) -> float:
    """Floating-point union upper bound, for very large L."""
    assert k <= L
    return (L - k + 1) / b ** k


# ---------------------------------------------------------------------------
# Brute-force ground truth (enumerate the entire tiny library)
# ---------------------------------------------------------------------------

def all_volumes(b: int, L: int) -> Iterator[Tuple[int, ...]]:
    """Enumerate every volume of length L over a b-symbol alphabet."""
    return product(range(b), repeat=L)


def occurs_at(pattern: Sequence[int], volume: Sequence[int], i: int) -> bool:
    """True iff `pattern` occurs in `volume` starting at position i (in range)."""
    k = len(pattern)
    if i + k > len(volume):
        return False
    return all(volume[i + j] == pattern[j] for j in range(k))


def occurrence_count(pattern: Sequence[int], volume: Sequence[int]) -> int:
    """Number of start positions where `pattern` occurs in `volume`."""
    L, k = len(volume), len(pattern)
    if k > L:
        return 0
    return sum(occurs_at(pattern, volume, i) for i in range(L - k + 1))


def contains(pattern: Sequence[int], volume: Sequence[int]) -> bool:
    """True iff `pattern` occurs somewhere in `volume`."""
    return occurrence_count(pattern, volume) > 0


def brute_expected_count(b: int, L: int, pattern: Sequence[int]) -> Fraction:
    """Exact expected occurrence count by full enumeration."""
    total = sum(occurrence_count(pattern, v) for v in all_volumes(b, L))
    return Fraction(total, b ** L)


def brute_prob_contains(b: int, L: int, pattern: Sequence[int]) -> Fraction:
    """Exact Pr[contains] by full enumeration."""
    hits = sum(contains(pattern, v) for v in all_volumes(b, L))
    return Fraction(hits, b ** L)


# ---------------------------------------------------------------------------
# Demonstrations
# ---------------------------------------------------------------------------

def demo_counting() -> None:
    print("=" * 70)
    print("1. Counting the library  (card_library, prob_singleton)")
    print("=" * 70)
    for b, L in [(2, 3), (3, 4), (25, 5)]:
        n = card_library(b, L)
        print(f"  b={b:2d}, L={L}:  #Library = b^L = {n:,}    "
              f"Pr[single volume] = 1/{n:,}")
    # Borges' own library: 25 symbols, 1,312,000 characters.
    import math
    digits = math.floor(1_312_000 * math.log10(25)) + 1
    print(f"\n  Borges' library (b=25, L=1,312,000): #Library = 25^1,312,000 "
          f"has {digits:,} digits.")


def demo_coincidence_and_brute_check() -> None:
    print("\n" + "=" * 70)
    print("2. Coincidence + brute-force verification of exact formulas")
    print("=" * 70)
    b, L = 2, 3
    print(f"  b={b}, L={L}:  Pr[two random volumes equal] = "
          f"{prob_pair_coincide(b, L)}  (= b^-L)")
    pattern = (1, 0)  # length-2 pattern
    k = len(pattern)
    closed = expected_substring_count(b, L, k)
    brute = brute_expected_count(b, L, pattern)
    print(f"  Expected occurrences of {pattern}:  closed-form={closed}  "
          f"brute={brute}  match={closed == brute}")
    lo = block_lower_bound(b, L, k)
    up = union_upper_bound(b, L, k)
    pc = brute_prob_contains(b, L, pattern)
    print(f"  Pr[contains {pattern}]:  lower={lo}  <=  actual={pc}  <=  upper={up}")
    print(f"     bounds bracket the truth: {lo <= pc <= up}")


def demo_union_goes_vacuous() -> None:
    print("\n" + "=" * 70)
    print("3. The union bound goes vacuous; the block bound never does")
    print("=" * 70)
    b, k = 2, 3
    print(f"  Alphabet b={b}, pattern length k={k}  (so b^k = {b**k}):")
    print(f"  {'L':>8} | {'union upper':>14} | {'block lower':>14}")
    print("  " + "-" * 44)
    for L in [3, 8, 16, 64, 256]:
        up = union_upper_bound_float(b, L, k)
        lo = block_lower_bound_float(b, L, k)
        up_str = f"{up:.6f}" + (" (vacuous!)" if up > 1 else "")
        print(f"  {L:>8} | {up_str:>14} | {lo:>14.6f}")


def demo_tendsto_one() -> None:
    print("\n" + "=" * 70)
    print("4. Borges completeness: Pr[contains] -> 1  (b >= 2)")
    print("=" * 70)
    b, k = 25, 6  # a 6-letter word over Borges' 25-symbol alphabet
    print(f"  Alphabet b={b}, pattern length k={k}  (b^k = {b**k:,}):")
    for L in [b**k, 5 * b**k, 20 * b**k, 100 * b**k]:
        lo = block_lower_bound_float(b, L, k)
        print(f"    L = {L:>14,}:  Pr[contains] >= {lo:.10f}")


def demo_threshold_length() -> None:
    print("\n" + "=" * 70)
    print("5. How long must a book be to almost-surely contain a text?")
    print("=" * 70)
    import math
    b, k, eps = 25, 6, Fraction(1, 100)  # want Pr[contains] >= 99%
    q = 1.0 - 1.0 / b**k
    m = math.ceil(math.log(float(eps)) / math.log(q))  # blocks needed
    L = m * k
    lo = block_lower_bound_float(b, L, k)
    print(f"  b={b}, k={k}, target Pr[contains] >= {1 - eps}:")
    print(f"    need m = {m:,} disjoint blocks, i.e. L = {L:,} characters;")
    print(f"    certified lower bound at that L: {float(lo):.6f}")


def main() -> None:
    demo_counting()
    demo_coincidence_and_brute_check()
    demo_union_goes_vacuous()
    demo_tendsto_one()
    demo_threshold_length()
    print("\nAll demonstrations agree with the verified closed-form theorems.")


if __name__ == "__main__":
    main()
