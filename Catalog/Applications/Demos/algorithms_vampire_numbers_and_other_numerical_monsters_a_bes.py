"""
Vampire Numbers and Arithmetic Creatures: Algorithms
=====================================================

Type-hinted implementations for detecting and enumerating
vampire numbers, werewolf numbers, ghost numbers, and spectral numbers.
"""

from collections import Counter
from typing import List, Tuple, Optional
from itertools import combinations
import math


def digit_multiset(n: int) -> Counter:
    """Return the multiset (Counter) of decimal digits of n."""
    return Counter(str(n))


def num_digits(n: int) -> int:
    """Return the number of decimal digits of n."""
    if n == 0:
        return 1
    return len(str(n))


def digit_sum(n: int) -> int:
    """Return the sum of decimal digits of n."""
    return sum(int(d) for d in str(n))


def is_vampire(v: int) -> Tuple[bool, Optional[Tuple[int, int]]]:
    """
    Check if v is a vampire number.

    A vampire number has 2n digits and can be factored as v = x * y
    where x and y each have n digits, the digit multiset of v equals
    the union of digit multisets of x and y, and not both x, y end in 0.

    Returns (True, (x, y)) if vampire, (False, None) otherwise.
    """
    s = str(v)
    d = len(s)
    if d < 4 or d % 2 != 0:
        return False, None

    n = d // 2
    lo = 10 ** (n - 1)
    hi = 10 ** n

    target = sorted(s)

    for x in range(lo, hi):
        if v % x != 0:
            continue
        y = v // x
        if y < lo or y >= hi:
            continue
        if x % 10 == 0 and y % 10 == 0:
            continue
        if sorted(str(x) + str(y)) == target:
            return True, (x, y)

    return False, None


def find_all_vampires(limit: int) -> List[Tuple[int, int, int]]:
    """
    Find all vampire numbers up to limit.
    Returns list of (v, x, y) tuples.
    """
    results = []
    # Vampire numbers have even digit counts, minimum 4 digits
    for num_d in range(4, len(str(limit)) + 1, 2):
        n = num_d // 2
        lo_v = 10 ** (num_d - 1)
        hi_v = min(10 ** num_d, limit + 1)
        lo_f = 10 ** (n - 1)
        hi_f = 10 ** n

        for x in range(lo_f, hi_f):
            # y must also be n digits: lo_f <= y < hi_f
            y_lo = max(lo_f, (lo_v + x - 1) // x)  # ceil(lo_v / x)
            y_hi = min(hi_f, hi_v // x + 1)
            for y in range(max(y_lo, x), y_hi):  # y >= x to avoid duplicates
                v = x * y
                if v >= hi_v:
                    break
                if x % 10 == 0 and y % 10 == 0:
                    continue
                if sorted(str(v)) == sorted(str(x) + str(y)):
                    results.append((v, x, y))
    return sorted(results)


def is_ghost_number(v: int) -> Tuple[bool, Optional[Tuple[int, int]]]:
    """
    Check if v is a ghost number: v = x * y where the digit SETS
    of x and y are completely disjoint from the digit set of v.
    """
    if v < 4:
        return False, None

    v_digits = set(str(v))

    for x in range(2, int(math.isqrt(v)) + 1):
        if v % x != 0:
            continue
        y = v // x
        if y <= 1:
            continue
        x_digits = set(str(x))
        y_digits = set(str(y))
        if v_digits.isdisjoint(x_digits) and v_digits.isdisjoint(y_digits):
            return True, (x, y)

    return False, None


def is_werewolf_number(v: int) -> Tuple[bool, Optional[Tuple[int, int]]]:
    """
    Check if v is a werewolf number: v = x * y where the combined
    digit multiset of x and y shares exactly one digit with v's multiset.
    """
    if v < 4:
        return False, None

    v_counter = digit_multiset(v)

    for x in range(2, int(math.isqrt(v)) + 1):
        if v % x != 0:
            continue
        y = v // x
        if y <= 1:
            continue
        combined = digit_multiset(x) + digit_multiset(y)
        # Count shared elements (intersection with multiplicity)
        shared = sum((combined & v_counter).values())
        if shared == 1:
            return True, (x, y)

    return False, None


def is_spectral_number(v: int) -> Tuple[bool, Optional[Tuple[int, int]]]:
    """
    Check if v is a spectral number: v = x * y where sorting digits
    of v matches sorting combined digits of x, y, but multisets differ.

    Our Lean proof shows this set is EMPTY — spectral numbers don't exist,
    because sorted digits uniquely determine the multiset. This function
    confirms the theorem computationally.
    """
    if v < 4:
        return False, None

    v_sorted = sorted(str(v))

    for x in range(2, int(math.isqrt(v)) + 1):
        if v % x != 0:
            continue
        y = v // x
        if y <= 1:
            continue
        combined_sorted = sorted(str(x) + str(y))
        if combined_sorted == v_sorted:
            # Check if multisets are different
            if Counter(str(v)) != Counter(str(x) + str(y)):
                return True, (x, y)

    return False, None


def mod9_fang_constraint(x: int, y: int) -> bool:
    """
    Verify the vampire mod-9 constraint: (x-1)(y-1) ≡ 1 (mod 9).
    This is a necessary condition for x, y to be vampire fangs.
    """
    return ((x - 1) * (y - 1)) % 9 == 1


def valid_fang_residue_pairs() -> List[Tuple[int, int]]:
    """
    Enumerate all pairs (a, b) with 0 ≤ a, b < 9 such that
    (a)(b) ≡ 1 (mod 9), i.e., valid residue classes for
    (x-1, y-1) mod 9 in vampire factorizations.
    """
    pairs = []
    for a in range(9):
        for b in range(9):
            if (a * b) % 9 == 1:
                pairs.append(((a + 1) % 9, (b + 1) % 9))
    return pairs


def vampire_density(num_digits: int) -> float:
    """
    Estimate the density of vampire numbers among all numbers
    with the given (even) number of digits.

    Uses the heuristic: C(2n, n) / 10^n ≈ 4^n / (sqrt(πn) * 10^n)
    = (2/5)^n / sqrt(πn), which goes to 0 but slowly.
    """
    if num_digits % 2 != 0 or num_digits < 4:
        return 0.0
    n = num_digits // 2
    # C(2n, n) / 10^n
    from math import comb
    return comb(2 * n, n) / (10 ** n)


if __name__ == "__main__":
    print("=== Vampire Number Algorithms ===")
    print()

    # Valid residue pairs
    pairs = valid_fang_residue_pairs()
    print(f"Valid fang residue pairs (x mod 9, y mod 9): {pairs}")
    print(f"Number of valid pairs: {len(pairs)} out of 81 possible")
    print()

    # Density estimates
    for d in [4, 6, 8, 10, 12]:
        print(f"Heuristic density for {d}-digit vampires: {vampire_density(d):.6f}")
