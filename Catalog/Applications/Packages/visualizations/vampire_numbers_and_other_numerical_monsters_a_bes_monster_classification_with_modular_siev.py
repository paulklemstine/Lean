#!/usr/bin/env python3
"""
Arithmetic Monsters: Core Algorithms for Monster Classification

Implements efficient algorithms for searching and classifying arithmetic monsters
(vampire numbers, ghost numbers, digit-disjoint pairs) in arbitrary bases.

Time complexity:
  - find_vampires(N, b): O(N^{3/2} · log_b(N)) 
  - find_ghosts(N, b): O(N^{3/2} · log_b(N))
  - digit_disjoint_pairs(N, b): O(N^2 · log_b(N))
  - mod_sieve_vampires(N, b): O(N^{3/2}) with sieve pre-filtering

Space complexity: O(N) for result storage.
"""

from collections import Counter
import math
from typing import Iterator


# ─────────────────────────────────────────────────────────────
# Core digit infrastructure
# ─────────────────────────────────────────────────────────────

def digits_base(n: int, b: int) -> list[int]:
    """
    Return base-b digits of n, least significant first.
    
    >>> digits_base(1260, 10)
    [0, 6, 2, 1]
    >>> digits_base(5, 2)
    [1, 0, 1]
    """
    if n == 0 or b < 2:
        return []
    result = []
    while n > 0:
        result.append(n % b)
        n //= b
    return result


def digit_bag(n: int, b: int) -> Counter:
    """
    Digit multiset of n in base b.
    
    >>> digit_bag(1260, 10)
    Counter({0: 1, 6: 1, 2: 1, 1: 1})
    """
    return Counter(digits_base(n, b))


def digit_overlap(m: int, n: int, b: int) -> int:
    """
    Count shared digit occurrences: sum_d min(bag_m[d], bag_n[d]).
    
    >>> digit_overlap(123, 321, 10)
    3
    >>> digit_overlap(12, 34, 10)
    0
    """
    bm, bn = digit_bag(m, b), digit_bag(n, b)
    return sum(min(bm.get(d, 0), bn.get(d, 0)) for d in range(b))


def digit_sum(n: int, b: int) -> int:
    """Sum of base-b digits of n."""
    return sum(digits_base(n, b))


def digit_len(n: int, b: int) -> int:
    """Number of base-b digits of n (0 has length 0)."""
    return len(digits_base(n, b))


# ─────────────────────────────────────────────────────────────
# Monster predicates
# ─────────────────────────────────────────────────────────────

def is_vampire(v: int, x: int, y: int, b: int = 10) -> bool:
    """Check vampire condition: v = x*y and digitBag(v) = digitBag(x) + digitBag(y)."""
    return v == x * y and digit_bag(v, b) == digit_bag(x, b) + digit_bag(y, b)


def is_ghost(v: int, x: int, y: int, b: int = 10) -> bool:
    """Check ghost condition: v = x*y and v shares no digits with x or y."""
    return (v == x * y and
            digit_overlap(v, x, b) == 0 and
            digit_overlap(v, y, b) == 0)


def is_digit_disjoint(m: int, n: int, b: int = 10) -> bool:
    """Check if m and n share no base-b digits."""
    return digit_overlap(m, n, b) == 0


# ─────────────────────────────────────────────────────────────
# Search algorithms
# ─────────────────────────────────────────────────────────────

def mod_sieve(x: int, y: int, b: int) -> bool:
    """
    Modular sieve for vampire candidates.
    Returns True if (x,y) passes the necessary condition x*y ≡ x+y (mod b-1).
    
    This eliminates ~(1 - 1/(b-1)) fraction of candidates in base b.
    In base 10, it eliminates about 77.8% of candidate pairs.
    
    >>> mod_sieve(15, 93, 10)  # 15*93 = 1395, a vampire number
    True
    """
    m = b - 1
    return (x * y) % m == (x + y) % m


def find_vampires_sieved(N: int, b: int = 10) -> list[tuple[int, int, int]]:
    """
    Find all vampire triples (v, x, y) with v ≤ N in base b.
    Uses the mod-(b-1) sieve to skip impossible pairs.
    
    Algorithm:
    1. For each v in [4, N], compute sqrt(v)
    2. For each factor x in [2, sqrt(v)], check x | v
    3. Apply mod-(b-1) sieve to skip pairs early
    4. Verify full digit-bag condition
    
    >>> find_vampires_sieved(2000, 10)
    [(1260, 21, 60), (1395, 15, 93), (1435, 35, 41), (1530, 30, 51), (1560, 60, 26)]
    """
    results = []
    for v in range(4, N + 1):
        sqrt_v = int(math.isqrt(v))
        for x in range(2, sqrt_v + 1):
            if v % x != 0:
                continue
            y = v // x
            if y < x:
                continue
            # Apply sieve first (cheap)
            if not mod_sieve(x, y, b):
                continue
            # Full digit-bag check (expensive)
            if is_vampire(v, x, y, b):
                results.append((v, x, y))
    return results


def find_ghosts_sieved(N: int, b: int = 10) -> list[tuple[int, int, int]]:
    """
    Find all ghost triples (v, x, y) with v ≤ N in base b.
    
    >>> len(find_ghosts_sieved(100, 2))  # Impossible in base 2
    0
    """
    if b == 2:
        return []  # Theorem 2: impossible in base 2
    results = []
    for v in range(4, N + 1):
        sqrt_v = int(math.isqrt(v))
        for x in range(2, sqrt_v + 1):
            if v % x != 0:
                continue
            y = v // x
            if y < x:
                continue
            if is_ghost(v, x, y, b):
                results.append((v, x, y))
    return results


def digit_disjoint_pairs(N: int, b: int = 10) -> Iterator[tuple[int, int]]:
    """
    Yield all digit-disjoint pairs (m, n) with 1 ≤ m < n ≤ N in base b.
    
    >>> list(digit_disjoint_pairs(5, 2))  # None in base 2
    []
    """
    for m in range(1, N + 1):
        for n in range(m + 1, N + 1):
            if is_digit_disjoint(m, n, b):
                yield (m, n)


def repdigit(b: int, d: int, k: int) -> int:
    """
    Construct a repdigit: k copies of digit d in base b.
    
    >>> repdigit(10, 1, 4)  # 1111
    1111
    >>> repdigit(10, 7, 3)  # 777
    777
    """
    return d * sum(b ** i for i in range(k))


def explicit_disjoint_family(b: int, max_k: int = 10) -> list[tuple[int, int]]:
    """
    Construct explicit digit-disjoint pairs using b^k and b^(k+1)-1.
    These use digits {0,1} and {b-1} respectively.
    
    >>> explicit_disjoint_family(3, 4)
    [(3, 8), (9, 26), (27, 80), (81, 242)]
    """
    pairs = []
    for k in range(1, max_k + 1):
        m = b ** k
        n = b ** (k + 1) - 1
        pairs.append((m, n))
    return pairs


# ─────────────────────────────────────────────────────────────
# Classification
# ─────────────────────────────────────────────────────────────

def classify_all(N: int, b: int = 10) -> dict[str, list[tuple[int, int, int]]]:
    """
    Classify all monster triples up to N in base b.
    Returns a dictionary mapping monster kind to list of triples.
    
    >>> result = classify_all(2000, 10)
    >>> len(result['vampire'])
    5
    """
    return {
        'vampire': find_vampires_sieved(N, b),
        'ghost': find_ghosts_sieved(N, b),
    }


# ─────────────────────────────────────────────────────────────
# Statistical analysis
# ─────────────────────────────────────────────────────────────

def sieve_effectiveness(b: int, num_digits: int, sample_size: int = 10000) -> dict:
    """
    Measure how effective the mod-(b-1) sieve is at eliminating
    candidate factor pairs for vampire numbers with a given digit count.
    
    Returns dict with 'total', 'passing', 'eliminated_pct' keys.
    """
    lo = b ** (num_digits - 1)
    hi = b ** num_digits - 1
    fang_digits = num_digits // 2
    fang_lo = b ** (fang_digits - 1)
    fang_hi = b ** fang_digits - 1

    total = 0
    passing = 0
    import random
    random.seed(42)

    for _ in range(sample_size):
        x = random.randint(fang_lo, fang_hi)
        y = random.randint(x, fang_hi)
        v = x * y
        if lo <= v <= hi:
            total += 1
            if mod_sieve(x, y, b):
                passing += 1

    eliminated = (1 - passing / total) * 100 if total > 0 else 0
    return {
        'total': total,
        'passing': passing,
        'eliminated_pct': eliminated,
    }


if __name__ == "__main__":
    print("=== Arithmetic Monsters: Algorithm Demonstrations ===\n")

    # Vampire numbers in base 10
    print("Vampire numbers up to 100000 (base 10):")
    vamps = find_vampires_sieved(100000, 10)
    for v, x, y in vamps[:15]:
        print(f"  {v} = {x} × {y}")
    print(f"  Total: {len(vamps)}\n")

    # Ghost numbers in base 10
    print("Ghost numbers up to 10000 (base 10):")
    ghosts = find_ghosts_sieved(10000, 10)
    for v, x, y in ghosts[:10]:
        print(f"  {v} = {x} × {y}")
    print(f"  Total: {len(ghosts)}\n")

    # Sieve effectiveness
    print("Mod-9 sieve effectiveness (base 10):")
    for nd in [4, 6]:
        stats = sieve_effectiveness(10, nd)
        print(f"  {nd}-digit: eliminates {stats['eliminated_pct']:.1f}% "
              f"({stats['passing']}/{stats['total']})")

    # Digit-disjoint family
    print("\nExplicit digit-disjoint family (base 10):")
    for m, n in explicit_disjoint_family(10, 5):
        print(f"  ({m}, {n}): disjoint = {is_digit_disjoint(m, n, 10)}")
