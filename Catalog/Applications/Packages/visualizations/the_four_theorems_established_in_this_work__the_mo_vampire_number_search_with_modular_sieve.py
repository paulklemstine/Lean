#!/usr/bin/env python3
"""
Arithmetic Monster Theory — Algorithms

Implements the core algorithms for vampire number detection, digit-interaction
analysis, and the modular sieve optimization.

All algorithms have been verified against formally proved theorems in Lean 4.
"""

from typing import Optional
from collections import Counter


def digits(n: int, base: int = 10) -> list[int]:
    """Return digits of n in given base (least significant first).

    Time: O(log_base(n))
    Space: O(log_base(n))

    >>> digits(1260, 10)
    [0, 6, 2, 1]
    >>> digits(255, 16)
    [15, 15]
    """
    if n == 0:
        return [0]
    if base < 2:
        return [n]
    result = []
    while n > 0:
        result.append(n % base)
        n //= base
    return result


def digit_bag(n: int, base: int = 10) -> Counter:
    """Compute the digit bag (multiset) of n in base b.

    The digit bag is the fundamental invariant of arithmetic monster theory.

    Time: O(log_base(n))
    Space: O(base)

    >>> digit_bag(1260, 10)
    Counter({0: 1, 6: 1, 2: 1, 1: 1})
    """
    return Counter(digits(n, base))


def digit_sum(n: int, base: int = 10) -> int:
    """Sum of digits of n in base b.

    By the generalized casting-out theorem:
      n ≡ digit_sum(n) (mod base - 1)

    Time: O(log_base(n))

    >>> digit_sum(1260, 10)
    9
    """
    return sum(digits(n, base))


def digit_complexity(n: int, base: int = 10) -> int:
    """Number of distinct digits used in base-b representation.

    For vampire numbers v = x*y, we proved:
      digit_complexity(v) ≤ digit_complexity(x) + digit_complexity(y)

    Time: O(log_base(n))

    >>> digit_complexity(1260, 10)
    4
    """
    return len(set(digits(n, base)))


def modular_sieve(x: int, y: int, base: int = 10) -> bool:
    """Apply the modular sieve: necessary condition for x*y to be vampire.

    By Theorem 1 (modular obstruction), if v = x*y is vampire, then
      v ≡ x + y (mod base - 1)
    i.e., x*y ≡ x + y (mod base - 1).

    This eliminates ~(base-2)/(base-1) of all candidate pairs.

    Time: O(1)
    Space: O(1)

    >>> modular_sieve(21, 60, 10)  # 1260 is vampire
    True
    >>> modular_sieve(22, 60, 10)  # 1320 is not vampire
    False
    """
    m = base - 1
    return (x * y) % m == (x + y) % m


def is_vampire(v: int, x: int, y: int, base: int = 10) -> bool:
    """Check if (x, y) is a vampire pair for v in base b.

    A vampire pair satisfies:
    1. v = x * y
    2. digit_bag(v) = digit_bag(x) + digit_bag(y) (pointwise)

    Time: O(log_base(v))
    Space: O(base)
    """
    if v != x * y:
        return False
    return digit_bag(v, base) == digit_bag(x, base) + digit_bag(y, base)


def find_vampires_sieved(max_val: int, base: int = 10) -> list[tuple[int, int, int]]:
    """Find all vampire triples (v, x, y) with v ≤ max_val, using the modular sieve.

    Algorithm:
    1. For each v from base² to max_val:
    2.   For each factor x with base ≤ x ≤ √v:
    3.     Apply modular sieve (eliminates ~8/9 of pairs in base 10)
    4.     If sieve passes, check full digit-bag equality

    Complexity:
      Time: O(max_val^{3/2} / base) average case with sieve
      Space: O(base * log(max_val)) per check

    >>> find_vampires_sieved(2000, 10)
    [(1260, 21, 60), (1395, 15, 93), (1435, 35, 41), (1530, 30, 51), (1827, 21, 87)]
    """
    results = []
    min_factor = base
    for v in range(base * base, max_val + 1):
        sqrt_v = int(v**0.5)
        for x in range(min_factor, sqrt_v + 1):
            if v % x != 0:
                continue
            y = v // x
            if y < x:
                continue
            # Apply modular sieve first (O(1))
            if not modular_sieve(x, y, base):
                continue
            # Full check (O(log v))
            if is_vampire(v, x, y, base):
                results.append((v, x, y))
    return results


def digit_interaction_signature(v: int, x: int, y: int,
                                 base: int = 10) -> dict[str, int]:
    """Compute the digit interaction signature of a multiplication v = x*y.

    The signature decomposes digit changes into three categories:
    - preserved: digits appearing in both product and factors
    - created: digits in product but not in factors
    - destroyed: digits in factors but not in product

    Conservation law (Theorem 9): preserved + created = digit_len(v)

    Time: O(log_base(v))
    Space: O(base)

    >>> digit_interaction_signature(504, 12, 42, 10)
    {'preserved': 1, 'created': 2, 'destroyed': 3}
    """
    bag_v = digit_bag(v, base)
    bag_xy = digit_bag(x, base) + digit_bag(y, base)

    preserved = 0
    created = 0
    destroyed = 0

    all_digits = set(bag_v.keys()) | set(bag_xy.keys())
    for d in all_digits:
        bv = bag_v.get(d, 0)
        bxy = bag_xy.get(d, 0)
        preserved += min(bv, bxy)
        created += max(0, bv - bxy)
        destroyed += max(0, bxy - bv)

    return {"preserved": preserved, "created": created, "destroyed": destroyed}


def is_carry_free(a: int, b: int, base: int = 10) -> bool:
    """Check if a + b is carry-free in the given base.

    When carry-free, digit_sum(a+b) = digit_sum(a) + digit_sum(b).

    Time: O(log_base(max(a,b)))
    Space: O(1)

    >>> is_carry_free(123, 456, 10)
    True
    >>> is_carry_free(55, 55, 10)
    False
    """
    da = digits(a, base)
    db = digits(b, base)
    for i in range(max(len(da), len(db))):
        di_a = da[i] if i < len(da) else 0
        di_b = db[i] if i < len(db) else 0
        if di_a + di_b >= base:
            return False
    return True


def pythagorean_digit_filter(max_val: int, base: int = 10
                             ) -> list[tuple[int, int, int, bool]]:
    """Find Pythagorean triples and check digit sum obstruction.

    For each triple (a, b, c) with a² + b² = c²:
    - Compute digit sums mod (base-1)
    - Verify: digitSum(a)² + digitSum(b)² ≡ digitSum(c)² (mod base-1)

    This is always true by our Theorem 8, but the function returns
    the data for inspection.

    >>> pythagorean_digit_filter(30, 10)[:3]  # doctest: +NORMALIZE_WHITESPACE
    [(3, 4, 5, True), (5, 12, 13, True), (6, 8, 10, True)]
    """
    m = base - 1
    results = []
    for a in range(1, max_val):
        for b in range(a, max_val):
            c_sq = a*a + b*b
            c = int(c_sq**0.5)
            if c*c == c_sq and c <= max_val:
                ds_a = digit_sum(a, base) % m if m > 0 else 0
                ds_b = digit_sum(b, base) % m if m > 0 else 0
                ds_c = digit_sum(c, base) % m if m > 0 else 0
                check = (ds_a**2 + ds_b**2) % m == (ds_c**2) % m if m > 0 else True
                results.append((a, b, c, check))
    return results


def sieve_efficiency(max_val: int, base: int = 10) -> dict[str, float]:
    """Measure the efficiency of the modular sieve.

    Returns statistics on how many factor pairs are eliminated by the sieve
    vs requiring full digit-bag comparison.

    >>> stats = sieve_efficiency(5000, 10)
    >>> stats['elimination_rate'] > 0.8
    True
    """
    total_pairs = 0
    sieve_passed = 0
    vampire_found = 0

    for v in range(base * base, max_val + 1):
        sqrt_v = int(v**0.5)
        for x in range(base, sqrt_v + 1):
            if v % x != 0:
                continue
            y = v // x
            if y < x:
                continue
            total_pairs += 1
            if modular_sieve(x, y, base):
                sieve_passed += 1
                if is_vampire(v, x, y, base):
                    vampire_found += 1

    return {
        "total_pairs": total_pairs,
        "sieve_passed": sieve_passed,
        "vampire_found": vampire_found,
        "elimination_rate": 1 - sieve_passed / total_pairs if total_pairs > 0 else 0,
        "false_positive_rate": (sieve_passed - vampire_found) / sieve_passed if sieve_passed > 0 else 0,
    }


if __name__ == "__main__":
    print("=== Sieve Efficiency Analysis ===")
    for base in [6, 8, 10, 12, 16]:
        stats = sieve_efficiency(5000, base)
        print(f"Base {base:2d}: elimination rate = {stats['elimination_rate']:.1%}, "
              f"vampires found = {stats['vampire_found']}")

    print("\n=== Vampire Numbers up to 100000 (base 10) ===")
    vampires = find_vampires_sieved(100000, 10)
    for v, x, y in vampires:
        print(f"  {v} = {x} × {y}")
    print(f"Total: {len(vampires)}")
