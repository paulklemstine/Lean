"""
Vampire Numbers and Arithmetic Creatures: Algorithms

Type-hinted implementations of the core algorithms for finding and classifying
vampire numbers, ghost numbers, werewolf numbers, and related arithmetic creatures.
"""

from collections import Counter
from typing import List, Tuple, Optional, Set
from itertools import combinations
import math


def digits(n: int) -> List[int]:
    """Return the decimal digits of n as a list (least significant first)."""
    if n == 0:
        return [0]
    result = []
    while n > 0:
        result.append(n % 10)
        n //= 10
    return result


def digit_multiset(n: int) -> Counter:
    """Return the multiset (Counter) of decimal digits of n."""
    return Counter(digits(n))


def digit_set(n: int) -> Set[int]:
    """Return the set of distinct decimal digits of n."""
    return set(digits(n))


def num_digits(n: int) -> int:
    """Number of decimal digits of n (n >= 1)."""
    if n == 0:
        return 1
    return len(str(n))


def is_vampire(v: int) -> Tuple[bool, Optional[Tuple[int, int]]]:
    """
    Check if v is a vampire number.
    Returns (True, (x, y)) if v = x * y is a valid vampire factorization,
    or (False, None) otherwise.

    A vampire number has 2n digits (n >= 2) and admits v = x * y where
    x, y each have n digits, the digit multiset of v equals that of x and y
    combined, and not both x, y end in 0.
    """
    nd = num_digits(v)
    if nd < 4 or nd % 2 != 0:
        return False, None

    n = nd // 2
    lo = 10 ** (n - 1)
    hi = 10 ** n

    v_digits = digit_multiset(v)

    for x in range(lo, hi):
        if v % x != 0:
            continue
        y = v // x
        if y < lo or y >= hi:
            continue
        if x % 10 == 0 and y % 10 == 0:
            continue
        if digit_multiset(x) + digit_multiset(y) == v_digits:
            return True, (x, y)

    return False, None


def is_ghost_number(v: int) -> Tuple[bool, Optional[Tuple[int, int]]]:
    """
    Check if v is a ghost number: v = x * y where digit sets of x and y
    are disjoint from the digit set of v.
    """
    v_set = digit_set(v)
    for x in range(2, int(math.isqrt(v)) + 1):
        if v % x != 0:
            continue
        y = v // x
        if y <= 1:
            continue
        if digit_set(x).isdisjoint(v_set) and digit_set(y).isdisjoint(v_set):
            return True, (x, y)
    return False, None


def is_werewolf_number(v: int) -> Tuple[bool, Optional[Tuple[int, int]]]:
    """
    Check if v is a werewolf number: v = x * y where the combined digit
    multiset of x, y shares exactly one digit (with multiplicity) with v.
    """
    v_counter = digit_multiset(v)
    for x in range(2, int(math.isqrt(v)) + 1):
        if v % x != 0:
            continue
        y = v // x
        if y <= 1:
            continue
        fang_counter = digit_multiset(x) + digit_multiset(y)
        overlap = sum((fang_counter & v_counter).values())
        if overlap == 1:
            return True, (x, y)
    return False, None


def valid_fang_pairs_mod9() -> List[Tuple[int, int]]:
    """
    Enumerate all valid (x mod 9, y mod 9) pairs for vampire fangs.
    These satisfy (x-1)(y-1) ≡ 1 (mod 9).
    """
    pairs = []
    for a in range(9):
        for b in range(9):
            if ((a - 1) * (b - 1)) % 9 == 1:
                pairs.append((a, b))
    return pairs


def fang_mod3_filter(candidates: List[int]) -> List[int]:
    """
    Apply the Fang Mod-3 Elimination theorem: remove candidates
    that are ≡ 1 (mod 3), since they cannot be vampire fangs.
    """
    return [x for x in candidates if x % 3 != 1]


def digit_overlap_index(v: int, x: int, y: int) -> int:
    """
    Compute the digit overlap index: the size of the multiset intersection
    between digits(v) and digits(x) + digits(y).
    """
    v_counter = digit_multiset(v)
    fang_counter = digit_multiset(x) + digit_multiset(y)
    return sum((v_counter & fang_counter).values())


def classify_factorization(v: int, x: int, y: int) -> str:
    """
    Classify a factorization v = x * y along the creature spectrum.
    Returns one of: 'vampire', 'ghost', 'werewolf', 'phantom', 'partial'
    """
    v_counter = digit_multiset(v)
    fang_counter = digit_multiset(x) + digit_multiset(y)

    if v_counter == fang_counter:
        return 'vampire'

    v_set = digit_set(v)
    if digit_set(x).isdisjoint(v_set) and digit_set(y).isdisjoint(v_set):
        return 'ghost'

    overlap = sum((v_counter & fang_counter).values())
    if overlap == 1:
        return 'werewolf'
    elif overlap == 0:
        return 'phantom'
    else:
        return 'partial'


def find_vampires_in_range(lo: int, hi: int) -> List[Tuple[int, int, int]]:
    """Find all vampire numbers in [lo, hi]. Returns list of (v, x, y)."""
    results = []
    for v in range(lo, hi + 1):
        ok, fangs = is_vampire(v)
        if ok:
            results.append((v, fangs[0], fangs[1]))
    return results


def find_ghosts_in_range(lo: int, hi: int) -> List[Tuple[int, int, int]]:
    """Find all ghost numbers in [lo, hi]. Returns list of (v, x, y)."""
    results = []
    for v in range(lo, hi + 1):
        ok, factors = is_ghost_number(v)
        if ok:
            results.append((v, factors[0], factors[1]))
    return results


def excess_deficit_verify(v: int, x: int, y: int) -> Tuple[int, int, bool]:
    """
    Verify the Excess-Deficit Duality theorem for a specific factorization.
    Returns (excess, deficit, duality_holds).
    For balanced factorizations (same total digit count), excess always equals deficit.
    """
    v_counter = digit_multiset(v)
    fang_counter = digit_multiset(x) + digit_multiset(y)

    # Excess: digits in fang but not in v
    excess_counter = fang_counter - v_counter
    excess = sum(excess_counter.values())

    # Deficit: digits in v but not in fang
    deficit_counter = v_counter - fang_counter
    deficit = sum(deficit_counter.values())

    v_total = sum(v_counter.values())
    fang_total = sum(fang_counter.values())
    balanced = v_total == fang_total

    return excess, deficit, (not balanced or excess == deficit)


if __name__ == "__main__":
    # Quick demonstration
    print("=== Valid Fang Pairs mod 9 ===")
    pairs = valid_fang_pairs_mod9()
    print(f"  {len(pairs)} pairs: {pairs}")

    print("\n=== 4-digit Vampire Numbers ===")
    vampires = find_vampires_in_range(1000, 9999)
    for v, x, y in vampires:
        print(f"  {v} = {x} × {y}  (fangs mod 3: {x%3}, {y%3})")

    print("\n=== Mod-3 Elimination Verification ===")
    for v, x, y in vampires:
        assert x % 3 != 1, f"Fang {x} ≡ 1 mod 3!"
        assert y % 3 != 1, f"Fang {y} ≡ 1 mod 3!"
    print("  All fangs pass mod-3 elimination ✓")
