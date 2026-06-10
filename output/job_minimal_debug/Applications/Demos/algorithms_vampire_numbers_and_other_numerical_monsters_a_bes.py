#!/usr/bin/env python3
"""
Algorithms for Vampire Number Theory and Arithmetic Creatures
=============================================================
Type-hinted implementations of core algorithms.
"""

from collections import Counter
from typing import List, Tuple, Optional, Set, Dict
from math import isqrt, log10, factorial
from itertools import combinations


def digits_of(n: int) -> List[int]:
    """Extract decimal digits of n as a list (least significant first)."""
    if n == 0:
        return [0]
    result: List[int] = []
    while n > 0:
        result.append(n % 10)
        n //= 10
    return result


def digit_multiset(n: int) -> Counter:
    """Compute the multiset of decimal digits of n."""
    return Counter(digits_of(n))


def digit_set(n: int) -> Set[int]:
    """Compute the set of distinct digits in n."""
    return set(digits_of(n))


def num_digits(n: int) -> int:
    """Count the number of decimal digits of n."""
    if n == 0:
        return 1
    return len(digits_of(n))


# ---------------------------------------------------------------------------
# Algorithm 1: Vampire Number Detection
# ---------------------------------------------------------------------------
def find_vampire_fangs(v: int) -> List[Tuple[int, int]]:
    """
    Find all fang pairs (x, y) such that v = x * y is a vampire factorization.

    Algorithm:
      1. Compute d = num_digits(v). If d < 4 or d is odd, return [].
      2. Set n = d // 2. Search x in [10^(n-1), 10^n).
      3. For each x dividing v, compute y = v // x.
      4. Check: num_digits(y) = n, not both trailing zeros,
         and digit_multiset(v) = digit_multiset(x) + digit_multiset(y).

    Complexity: O(10^n) where 2n = num_digits(v).
    """
    d = num_digits(v)
    if d < 4 or d % 2 != 0:
        return []

    n = d // 2
    lo = 10 ** (n - 1)
    hi = 10 ** n
    target = digit_multiset(v)
    fangs: List[Tuple[int, int]] = []

    for x in range(lo, hi):
        if v % x != 0:
            continue
        y = v // x
        if y < x or y >= hi or num_digits(y) != n:
            continue
        if x % 10 == 0 and y % 10 == 0:
            continue
        if digit_multiset(x) + digit_multiset(y) == target:
            fangs.append((x, y))

    return fangs


# ---------------------------------------------------------------------------
# Algorithm 2: Mod-9 Fang Pair Classifier
# ---------------------------------------------------------------------------
def valid_mod9_fang_pairs() -> List[Tuple[int, int]]:
    """
    Enumerate all (a, b) in {0,...,8}^2 such that (a-1)(b-1) ≡ 1 (mod 9).

    These are the only residue class pairs that can appear as vampire fangs.
    By the Resonance Mod-9 Theorem, any resonant factorization x*y satisfies
    x*y ≡ x+y (mod 9), which is equivalent to (x-1)(y-1) ≡ 1 (mod 9).

    Returns exactly φ(9) = 6 pairs.
    """
    return [(a, b) for a in range(9) for b in range(9)
            if ((a - 1) * (b - 1)) % 9 == 1]


# ---------------------------------------------------------------------------
# Algorithm 3: Ghost Number Detector
# ---------------------------------------------------------------------------
def find_ghost_factorization(v: int) -> Optional[Tuple[int, int]]:
    """
    Find a ghost factorization v = x * y where digit_set(v) is disjoint
    from both digit_set(x) and digit_set(y).

    Algorithm: Trial division up to sqrt(v), checking digit set disjointness.
    """
    dv = digit_set(v)
    for x in range(2, isqrt(v) + 1):
        if v % x != 0:
            continue
        y = v // x
        if y <= 1:
            continue
        if dv.isdisjoint(digit_set(x)) and dv.isdisjoint(digit_set(y)):
            return (x, y)
    return None


# ---------------------------------------------------------------------------
# Algorithm 4: Resonance Detector
# ---------------------------------------------------------------------------
def find_resonance(n: int) -> Optional[Tuple[int, int]]:
    """
    Find a resonant factorization n = x * y where
    digit_multiset(n) = digit_multiset(x) + digit_multiset(y).
    """
    target = digit_multiset(n)
    for x in range(2, isqrt(n) + 1):
        if n % x != 0:
            continue
        y = n // x
        if digit_multiset(x) + digit_multiset(y) == target:
            return (x, y)
    return None


# ---------------------------------------------------------------------------
# Algorithm 5: Creature Classifier
# ---------------------------------------------------------------------------
def classify_creature(v: int) -> Dict[str, Optional[Tuple[int, int]]]:
    """
    Classify a composite number into arithmetic creature types.
    Returns a dict with keys 'vampire', 'ghost', 'werewolf', 'resonant'.
    """
    result: Dict[str, Optional[Tuple[int, int]]] = {
        'vampire': None,
        'ghost': None,
        'werewolf': None,
        'resonant': None,
    }

    dv = digit_set(v)
    target = digit_multiset(v)

    fangs = find_vampire_fangs(v)
    if fangs:
        result['vampire'] = fangs[0]

    result['ghost'] = find_ghost_factorization(v)
    result['resonant'] = find_resonance(v)

    # Werewolf check
    for x in range(2, isqrt(v) + 1):
        if v % x != 0:
            continue
        y = v // x
        if y <= 1:
            continue
        shared = dv & (digit_set(x) | digit_set(y))
        if len(shared) == 1:
            result['werewolf'] = (x, y)
            break

    return result


# ---------------------------------------------------------------------------
# Algorithm 6: Density Estimator
# ---------------------------------------------------------------------------
def vampire_density(digit_count: int, sample_size: int = 50000) -> float:
    """
    Estimate the density of vampire numbers among numbers with a given
    even digit count, by sampling.
    """
    if digit_count < 4 or digit_count % 2 != 0:
        return 0.0
    lo = 10 ** (digit_count - 1)
    hi = 10 ** digit_count
    import random
    random.seed(42)
    count = 0
    for _ in range(sample_size):
        v = random.randint(lo, hi - 1)
        if find_vampire_fangs(v):
            count += 1
    return count / sample_size


# ---------------------------------------------------------------------------
# Algorithm 7: Stirling Approximation for Expected Fang Count
# ---------------------------------------------------------------------------
def expected_fang_density(n: int) -> float:
    """
    Theoretical expected number of valid fang pairs for a 2n-digit number.

    By the multinomial counting argument:
    - There are C(2n, n) ways to assign 2n digits to two groups of n.
    - The probability that a random assignment gives the correct digit
      multiset is approximately C(2n, n) / 10^n.
    - By Stirling: C(2n, n) ≈ 4^n / sqrt(πn), so the density is
      approximately (4/10)^n / sqrt(πn) = (2/5)^n / sqrt(πn).

    This gives an exponentially decaying density, not 1/sqrt(n).
    """
    from math import comb, sqrt, pi
    binom = comb(2 * n, n)
    return binom / (10 ** n)


if __name__ == "__main__":
    print("=== Vampire Number Algorithms ===\n")

    # Test vampire detection
    print("Vampire fangs of 1260:", find_vampire_fangs(1260))
    print("Vampire fangs of 125460:", find_vampire_fangs(125460))

    # Valid mod-9 pairs
    print("\nValid mod-9 fang pairs:", valid_mod9_fang_pairs())

    # Ghost numbers
    print("\nFirst ghost numbers:")
    for v in range(4, 100):
        g = find_ghost_factorization(v)
        if g:
            print(f"  {v} = {g[0]} × {g[1]}")

    # Creature classification
    print("\nClassification of 1260:")
    print(classify_creature(1260))
    print("\nClassification of 1827:")
    print(classify_creature(1827))

    # Theoretical density
    print("\nTheoretical fang density (expected matches per number):")
    for n in range(2, 8):
        print(f"  {2*n}-digit: {expected_fang_density(n):.8f}")
