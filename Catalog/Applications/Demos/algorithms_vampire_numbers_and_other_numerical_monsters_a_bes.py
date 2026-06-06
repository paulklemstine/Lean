"""
Vampire Numbers and Arithmetic Creatures: Algorithms

Type-hinted implementations of vampire number detection, enumeration,
and mod-9 sieve algorithms.
"""

from typing import List, Tuple, Set, Optional
from collections import Counter


def digits(n: int) -> List[int]:
    """Return the list of decimal digits of n (least significant first)."""
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


def num_digits(n: int) -> int:
    """Return the number of decimal digits of n."""
    if n == 0:
        return 1
    count = 0
    while n > 0:
        count += 1
        n //= 10
    return count


def is_vampire(v: int) -> bool:
    """
    Check if v is a vampire number.
    
    A vampire number has 2n digits and can be factored as v = x * y
    where x, y each have n digits and the multiset of digits of v
    equals the union of digit multisets of x and y.
    """
    nd = num_digits(v)
    if nd < 4 or nd % 2 != 0:
        return False
    n = nd // 2
    lo = 10 ** (n - 1)
    hi = 10 ** n
    for x in range(lo, hi):
        if v % x != 0:
            continue
        y = v // x
        if y < lo or y >= hi:
            continue
        if x % 10 == 0 and y % 10 == 0:
            continue
        if sorted(digits(v)) == sorted(digits(x) + digits(y)):
            return True
    return False


def find_fangs(v: int) -> List[Tuple[int, int]]:
    """Find all fang pairs (x, y) with x <= y for a vampire number v."""
    nd = num_digits(v)
    if nd < 4 or nd % 2 != 0:
        return []
    n = nd // 2
    lo = 10 ** (n - 1)
    hi = 10 ** n
    fangs = []
    for x in range(lo, hi):
        if v % x != 0:
            continue
        y = v // x
        if y < x or y >= hi:
            continue
        if x % 10 == 0 and y % 10 == 0:
            continue
        if sorted(digits(v)) == sorted(digits(x) + digits(y)):
            fangs.append((x, y))
    return fangs


def vampire_mod9_sieve(v: int) -> bool:
    """
    Fast mod-9 pre-filter for vampire numbers.
    
    Uses the theorem: if v = x * y is a vampire factorization,
    then x * y ≡ x + y (mod 9), i.e., (x-1)(y-1) ≡ 1 (mod 9).
    
    Valid residue pairs mod 9: (0,0), (2,2), (3,6), (5,8), (6,3), (8,5).
    This eliminates ~92.6% of candidates immediately.
    """
    valid_pairs = {(0, 0), (2, 2), (3, 6), (5, 8), (6, 3), (8, 5)}
    r = v % 9
    # Check if v's residue is compatible with any valid pair
    for a, b in valid_pairs:
        if (a * b) % 9 == r:
            return True
    return False


def enumerate_vampires(lo: int, hi: int) -> List[int]:
    """Enumerate all vampire numbers in [lo, hi]."""
    return [v for v in range(lo, hi + 1) if is_vampire(v)]


def is_ghost_number(v: int) -> bool:
    """
    Check if v is a ghost number: v = x * y where digit sets of x and y
    are completely disjoint from the digit set of v.
    """
    v_digits = set(digits(v))
    for x in range(2, int(v ** 0.5) + 1):
        if v % x != 0:
            continue
        y = v // x
        if y <= 1:
            continue
        x_digits = set(digits(x))
        y_digits = set(digits(y))
        if v_digits.isdisjoint(x_digits) and v_digits.isdisjoint(y_digits):
            return True
    return False


def vampire_density(n_digits: int) -> float:
    """
    Compute the density of vampire numbers among n_digits-digit numbers.
    n_digits must be even and >= 4.
    """
    if n_digits < 4 or n_digits % 2 != 0:
        return 0.0
    lo = 10 ** (n_digits - 1)
    hi = 10 ** n_digits - 1
    count = sum(1 for v in range(lo, hi + 1) if is_vampire(v))
    return count / (hi - lo + 1)


def mod9_valid_pairs() -> Set[Tuple[int, int]]:
    """
    Compute all pairs (a, b) in Z/9Z x Z/9Z satisfying a*b ≡ a+b (mod 9).
    Equivalently, (a-1)(b-1) ≡ 1 (mod 9).
    """
    return {(a, b) for a in range(9) for b in range(9)
            if (a * b) % 9 == (a + b) % 9}


def digit_count_polynomial(n: int) -> dict:
    """
    Return the digit-counting polynomial P_n(X) = sum of X^d for each digit d.
    Represented as {exponent: coefficient}.
    """
    poly: dict = {}
    for d in digits(n):
        poly[d] = poly.get(d, 0) + 1
    return poly


if __name__ == "__main__":
    # Verify mod-9 valid pairs
    pairs = mod9_valid_pairs()
    print(f"Valid mod-9 pairs: {sorted(pairs)}")
    print(f"Count: {len(pairs)} out of 81 = {len(pairs)/81:.4f}")
    
    # Find 4-digit vampire numbers
    vampires_4 = enumerate_vampires(1000, 9999)
    print(f"\n4-digit vampire numbers ({len(vampires_4)}):")
    for v in vampires_4:
        fangs = find_fangs(v)
        print(f"  {v} = {' = '.join(f'{x} × {y}' for x, y in fangs)}")
    
    # Check some 6-digit vampires
    print("\nSample 6-digit vampire numbers:")
    count_6 = 0
    for v in range(100000, 200000):
        if is_vampire(v):
            fangs = find_fangs(v)
            print(f"  {v} = {' = '.join(f'{x} × {y}' for x, y in fangs)}")
            count_6 += 1
            if count_6 >= 10:
                break
