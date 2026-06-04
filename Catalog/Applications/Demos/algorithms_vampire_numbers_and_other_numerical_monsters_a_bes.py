"""
Digit-Morphic Factorization Algorithms
=======================================

Type-hinted implementations of the core algorithms for detecting and classifying
vampire numbers, werewolf numbers, ghost numbers, and digit-morphic factorizations
in arbitrary bases.

Key algorithms:
1. Vampire number detection via digit multiset comparison
2. Digit defect computation
3. Fang residue constraint checking
4. Base-b digit-morphic factorization search
5. Arithmetic creature enumeration
"""

from collections import Counter
from typing import Optional
from math import isqrt, gcd


def digits_base(n: int, b: int = 10) -> list[int]:
    """Return the digits of n in base b (least significant first)."""
    if n == 0:
        return [0]
    result = []
    while n > 0:
        result.append(n % b)
        n //= b
    return result


def digit_multiset(n: int, b: int = 10) -> Counter:
    """Return the multiset (Counter) of digits of n in base b."""
    return Counter(digits_base(n, b))


def digit_sum(n: int, b: int = 10) -> int:
    """Return the sum of digits of n in base b."""
    return sum(digits_base(n, b))


def num_digits(n: int, b: int = 10) -> int:
    """Return the number of digits of n in base b."""
    return len(digits_base(n, b))


def is_vampire(v: int, b: int = 10) -> bool:
    """
    Check if v is a vampire number in base b.
    
    A vampire number v has 2n digits and can be factored as v = x * y
    where x, y each have n digits and the digit multiset of v equals
    the union of digit multisets of x and y.
    """
    nd = num_digits(v, b)
    if nd < 4 or nd % 2 != 0:
        return False
    n = nd // 2
    lo = b ** (n - 1)
    hi = b ** n
    # Search for fang pairs
    for x in range(lo, hi):
        if v % x != 0:
            continue
        y = v // x
        if y < x:
            break
        if num_digits(y, b) != n:
            continue
        # Exclude both fangs ending in 0
        if x % b == 0 and y % b == 0:
            continue
        if digit_multiset(v, b) == digit_multiset(x, b) + digit_multiset(y, b):
            return True
    return False


def find_fangs(v: int, b: int = 10) -> list[tuple[int, int]]:
    """Find all fang pairs (x, y) with x <= y for a vampire number v."""
    nd = num_digits(v, b)
    if nd < 4 or nd % 2 != 0:
        return []
    n = nd // 2
    lo = b ** (n - 1)
    hi = b ** n
    fangs = []
    for x in range(lo, hi):
        if v % x != 0:
            continue
        y = v // x
        if y < x:
            break
        if num_digits(y, b) != n:
            continue
        if x % b == 0 and y % b == 0:
            continue
        if digit_multiset(v, b) == digit_multiset(x, b) + digit_multiset(y, b):
            fangs.append((x, y))
    return fangs


def digit_defect(v: int, x: int, y: int, b: int = 10) -> int:
    """
    Compute the digit defect of the factorization v = x * y in base b.
    
    The digit defect counts the total number of digit mismatches:
    |digits(v) \\ digits(x,y)| + |digits(x,y) \\ digits(v)|
    
    Theorem: This is always even when digit counts match (Digit Defect Parity).
    """
    mv = digit_multiset(v, b)
    mxy = digit_multiset(x, b) + digit_multiset(y, b)
    excess = sum((mv - mxy).values())
    deficit = sum((mxy - mv).values())
    return excess + deficit


def check_mod_constraint(x: int, y: int, b: int = 10) -> bool:
    """
    Check the fang residue constraint: (x-1)(y-1) ≡ 1 (mod b-1).
    
    This is a necessary condition for x, y to be fangs of a digit-morphic
    factorization in base b.
    """
    m = b - 1
    if m <= 0:
        return True
    return ((x - 1) * (y - 1)) % m == 1 % m


def valid_residue_pairs(b: int) -> list[tuple[int, int]]:
    """
    Enumerate all valid fang residue pairs (rx, ry) mod (b-1)
    satisfying (rx - 1)(ry - 1) ≡ 1 (mod b-1).
    """
    m = b - 1
    if m <= 1:
        return [(0, 0)]
    pairs = []
    for rx in range(m):
        for ry in range(m):
            if ((rx - 1) * (ry - 1)) % m == 1 % m:
                pairs.append((rx, ry))
    return pairs


def count_valid_residue_pairs(b: int) -> int:
    """Count the number of valid residue pairs for base b."""
    return len(valid_residue_pairs(b))


def is_ghost_number(v: int, b: int = 10) -> bool:
    """
    Check if v is a ghost number: v = x * y where the digit SETS of
    x and y are completely disjoint from the digit set of v.
    """
    if v < 4:
        return False
    dv = set(digits_base(v, b))
    for x in range(2, isqrt(v) + 1):
        if v % x != 0:
            continue
        y = v // x
        if y < 2:
            continue
        dx = set(digits_base(x, b))
        dy = set(digits_base(y, b))
        if dv.isdisjoint(dx) and dv.isdisjoint(dy):
            return True
    return False


def is_werewolf_number(v: int, b: int = 10) -> bool:
    """
    Check if v is a werewolf number: v = x * y where the combined
    digit multiset of x, y shares exactly one digit with v's multiset.
    """
    if v < 4:
        return False
    mv = digit_multiset(v, b)
    for x in range(2, isqrt(v) + 1):
        if v % x != 0:
            continue
        y = v // x
        if y < 2:
            continue
        mxy = digit_multiset(x, b) + digit_multiset(y, b)
        shared = sum((mv & mxy).values())
        if shared == 1:
            return True
    return False


def classify_factorization(v: int, x: int, y: int, b: int = 10) -> str:
    """
    Classify a factorization by its digit defect:
    - 'morphic' (defect 0): perfect digit preservation (vampire)
    - 'near_miss' (defect 2): minimal perturbation
    - 'distant' (defect >= 4): higher-order deviation
    """
    d = digit_defect(v, x, y, b)
    if d == 0:
        return "morphic"
    elif d == 2:
        return "near_miss"
    else:
        return "distant"


def enumerate_vampires(limit: int, b: int = 10) -> list[int]:
    """Enumerate all vampire numbers up to limit in base b."""
    vampires = []
    for v in range(1000, limit + 1):
        if is_vampire(v, b):
            vampires.append(v)
    return vampires


def enumerate_creatures(limit: int, b: int = 10) -> dict[str, list[int]]:
    """
    Enumerate all arithmetic creatures up to limit in base b.
    Returns a dict with keys 'vampire', 'ghost', 'werewolf'.
    """
    result: dict[str, list[int]] = {"vampire": [], "ghost": [], "werewolf": []}
    for v in range(4, limit + 1):
        if is_vampire(v, b):
            result["vampire"].append(v)
        if is_ghost_number(v, b):
            result["ghost"].append(v)
        if is_werewolf_number(v, b):
            result["werewolf"].append(v)
    return result


def fang_constraint_density(b: int) -> float:
    """
    Compute the fraction of residue pairs that satisfy the fang constraint.
    For base 10: only euler_totient(9)/81 ≈ 6.67% of pairs work.
    """
    m = b - 1
    if m <= 1:
        return 1.0
    valid = count_valid_residue_pairs(b)
    return valid / (m * m)


def euler_totient(n: int) -> int:
    """Compute Euler's totient function φ(n)."""
    result = n
    p = 2
    temp_n = n
    while p * p <= temp_n:
        if temp_n % p == 0:
            while temp_n % p == 0:
                temp_n //= p
            result -= result // p
        p += 1
    if temp_n > 1:
        result -= result // temp_n
    return result


if __name__ == "__main__":
    # Demonstrate the algorithms
    print("=" * 60)
    print("DIGIT-MORPHIC FACTORIZATION ALGORITHMS")
    print("=" * 60)

    # 1. Verify 1260 is a vampire number
    print("\n1. Vampire Number Verification:")
    print(f"   1260 is vampire: {is_vampire(1260)}")
    print(f"   Fangs of 1260: {find_fangs(1260)}")

    # 2. Enumerate small vampire numbers
    print("\n2. Vampire numbers up to 10000:")
    vamps = enumerate_vampires(10000)
    print(f"   Count: {len(vamps)}")
    print(f"   Numbers: {vamps}")

    # 3. Check mod-9 constraint
    print("\n3. Fang residue constraint (mod 9) for base 10:")
    pairs = valid_residue_pairs(10)
    print(f"   Valid residue pairs: {pairs}")
    print(f"   Count: {len(pairs)} out of {9*9} = {81}")
    print(f"   Density: {fang_constraint_density(10):.4f}")

    # 4. Digit defect examples
    print("\n4. Digit defect examples:")
    print(f"   1260 = 21 × 60: defect = {digit_defect(1260, 21, 60)}")
    print(f"   1260 = 20 × 63: defect = {digit_defect(1260, 20, 63)}")
    print(f"   Classification: {classify_factorization(1260, 21, 60)}")
    print(f"   Classification: {classify_factorization(1260, 20, 63)}")

    # 5. Ghost and werewolf examples
    print("\n5. Ghost and werewolf numbers up to 1000:")
    for v in range(4, 1000):
        if is_ghost_number(v):
            print(f"   Ghost: {v}")
            break
    for v in range(4, 1000):
        if is_werewolf_number(v):
            print(f"   Werewolf: {v}")
            break

    # 6. Multi-base analysis
    print("\n6. Fang constraint density across bases:")
    for base in [2, 3, 5, 8, 10, 12, 16]:
        d = fang_constraint_density(base)
        n_pairs = count_valid_residue_pairs(base)
        print(f"   Base {base:2d}: {n_pairs:3d} valid pairs, density = {d:.4f}")

    # 7. Verify digit defect parity
    print("\n7. Digit defect parity verification (should all be even):")
    import random
    random.seed(42)
    all_even = True
    for _ in range(100):
        x = random.randint(10, 99)
        y = random.randint(10, 99)
        v = x * y
        if num_digits(v) == num_digits(x) + num_digits(y):
            d = digit_defect(v, x, y)
            if d % 2 != 0:
                all_even = False
                print(f"   COUNTEREXAMPLE: {v} = {x} × {y}, defect = {d}")
    print(f"   All defects even: {all_even}")
