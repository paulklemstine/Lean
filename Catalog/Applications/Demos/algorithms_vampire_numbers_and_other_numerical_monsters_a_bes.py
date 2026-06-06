"""
Vampire Numbers and Arithmetic Creatures: Core Algorithms

Type-hinted implementations for detecting and enumerating vampire numbers,
ghost numbers, werewolf numbers, and related arithmetic creatures.
"""

from collections import Counter
from typing import Optional


def digits_of(n: int) -> list[int]:
    """Return the list of decimal digits of n."""
    if n == 0:
        return [0]
    result = []
    while n > 0:
        result.append(n % 10)
        n //= 10
    return result[::-1]


def digit_multiset(n: int) -> Counter:
    """Return the multiset (Counter) of decimal digits of n."""
    return Counter(digits_of(n))


def digit_set(n: int) -> set[int]:
    """Return the set of distinct decimal digits of n."""
    return set(digits_of(n))


def num_digits(n: int) -> int:
    """Return the number of decimal digits of n."""
    if n == 0:
        return 1
    count = 0
    while n > 0:
        count += 1
        n //= 10
    return count


def is_vampire(v: int) -> Optional[tuple[int, int]]:
    """
    Check if v is a vampire number. Returns (x, y) fangs if yes, None if no.
    A vampire number has 2n digits and factors v = x * y where x, y each have
    n digits and the digit multiset of v equals the union of digit multisets of x and y.
    """
    nd = num_digits(v)
    if nd < 4 or nd % 2 != 0:
        return None

    n = nd // 2
    lo = 10 ** (n - 1)
    hi = 10 ** n

    for x in range(lo, hi):
        if v % x != 0:
            continue
        y = v // x
        if y < x or y >= hi:
            continue
        if x % 10 == 0 and y % 10 == 0:
            continue
        if digit_multiset(v) == digit_multiset(x) + digit_multiset(y):
            return (x, y)
    return None


def is_ghost_number(v: int) -> Optional[tuple[int, int]]:
    """
    Check if v is a ghost number. Returns (x, y) if yes, None if no.
    A ghost number v = x * y where the digit sets of x and y are
    completely disjoint from the digit set of v.
    """
    v_digits = digit_set(v)

    for x in range(2, int(v ** 0.5) + 1):
        if v % x != 0:
            continue
        y = v // x
        if y <= 1:
            continue
        x_digits = digit_set(x)
        y_digits = digit_set(y)
        if x_digits.isdisjoint(v_digits) and y_digits.isdisjoint(v_digits):
            return (x, y)
    return None


def is_werewolf_number(v: int) -> Optional[tuple[int, int]]:
    """
    Check if v is a werewolf number. Returns (x, y) if yes, None if no.
    A werewolf number v = x * y where the combined digit multiset of x and y
    shares exactly one digit (with multiplicity) with v's digit multiset.
    """
    v_ms = digit_multiset(v)

    for x in range(2, int(v ** 0.5) + 1):
        if v % x != 0:
            continue
        y = v // x
        if y <= 1:
            continue
        combined = digit_multiset(x) + digit_multiset(y)
        intersection = sum((combined & v_ms).values())
        if intersection == 1:
            return (x, y)
    return None


def fang_residue_pairs_mod9() -> list[tuple[int, int]]:
    """
    Enumerate all valid fang residue pairs (a, b) mod 9 where
    a * b ≡ a + b (mod 9), equivalently (a-1)(b-1) ≡ 1 (mod 9).
    """
    pairs = []
    for a in range(9):
        for b in range(9):
            if (a * b) % 9 == (a + b) % 9:
                pairs.append((a, b))
    return pairs


def enumerate_vampires(limit: int) -> list[tuple[int, int, int]]:
    """Enumerate all vampire numbers up to limit. Returns list of (v, x, y)."""
    results = []
    for v in range(1000, limit):
        fangs = is_vampire(v)
        if fangs:
            results.append((v, fangs[0], fangs[1]))
    return results


def enumerate_ghosts(limit: int) -> list[tuple[int, int, int]]:
    """Enumerate ghost numbers up to limit. Returns list of (v, x, y)."""
    results = []
    for v in range(4, limit):
        result = is_ghost_number(v)
        if result:
            results.append((v, result[0], result[1]))
    return results


def vampire_density(n_digits: int) -> float:
    """
    Estimate the density of vampire numbers among 2n-digit numbers.
    Returns count / total for the given digit length.
    """
    if n_digits < 4 or n_digits % 2 != 0:
        return 0.0

    lo = 10 ** (n_digits - 1)
    hi = 10 ** n_digits
    count = 0
    for v in range(lo, hi):
        if is_vampire(v) is not None:
            count += 1
    return count / (hi - lo)


if __name__ == "__main__":
    # Demonstrate the algorithms
    print("=== Fang Residue Pairs mod 9 ===")
    pairs = fang_residue_pairs_mod9()
    print(f"Valid pairs: {pairs}")
    print(f"Count: {len(pairs)} out of 81 possible")

    print("\n=== Vampire Numbers up to 10000 ===")
    vampires = enumerate_vampires(10000)
    for v, x, y in vampires:
        print(f"  {v} = {x} × {y}")

    print(f"\nTotal 4-digit vampires: {len(vampires)}")
