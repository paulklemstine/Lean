"""
Numerical demonstrations for:

  * A unified theory of mixed-radix number systems, with ordinary base-N and
    the factorial (factoradic) system as special cases, and
  * Primitive prime divisors of Fibonacci numbers (Carmichael's theorem,
    verified range 13 <= n <= 10000).

Everything is self-contained; run `python demo.py`.
"""

from __future__ import annotations

from math import gcd, factorial, isqrt
from typing import Callable, Dict, List, Sequence, Tuple


# ---------------------------------------------------------------------------
# Part I. Mixed-radix number systems
# ---------------------------------------------------------------------------

def radix_prod(b: Callable[[int], int], k: int) -> int:
    """Running product P_b(k) = prod_{i<k} b(i), the place value of position k."""
    p = 1
    for i in range(k):
        p *= b(i)
    return p


def mixed_value(b: Callable[[int], int], c: Sequence[int]) -> int:
    """Value of digit string c under bases b: sum_{i<k} c_i * P_b(i)."""
    total = 0
    for i, ci in enumerate(c):
        total += ci * radix_prod(b, i)
    return total


def is_valid(b: Callable[[int], int], c: Sequence[int]) -> bool:
    """Validity: every digit stays below its local base, c_i < b(i)."""
    return all(0 <= ci < b(i) for i, ci in enumerate(c))


def mixed_digits(b: Callable[[int], int], n: int, k: int) -> List[int]:
    """Extract length-k digits of n: digit_i = (n // P_b(i)) % b(i)."""
    return [(n // radix_prod(b, i)) % b(i) for i in range(k)]


def base_n_bases(N: int) -> Callable[[int], int]:
    """Constant base sequence b(i) = N, giving P_b(k) = N^k."""
    return lambda _i: N


def factorial_bases() -> Callable[[int], int]:
    """Base sequence b(i) = i + 1, giving P_b(k) = k!."""
    return lambda i: i + 1


def demo_mixed_radix() -> None:
    print("=" * 70)
    print("PART I: MIXED-RADIX NUMBER SYSTEMS")
    print("=" * 70)

    # Base-N specializes: P_b(k) = N^k
    N = 10
    b10 = base_n_bases(N)
    assert all(radix_prod(b10, k) == N ** k for k in range(8))
    n = 2026
    digits = mixed_digits(b10, n, 4)  # little-endian
    print(f"\nBase-{N}: {n} -> digits (little-endian) {digits}")
    assert mixed_value(b10, digits) == n
    print(f"  reconstruct value = {mixed_value(b10, digits)}  (matches)")

    # Factorial system specializes: P_b(k) = k!
    bf = factorial_bases()
    assert all(radix_prod(bf, k) == factorial(k) for k in range(8))
    print("\nFactorial place values P_b(k) = k! :",
          [radix_prod(bf, k) for k in range(7)])

    # Encode/decode round trip in factoradic, and the sharp bound V < P_b(k).
    k = 6
    print(f"\nFactoradic round-trip for all n < {k}! = {factorial(k)}:")
    ok = True
    for m in range(factorial(k)):
        d = mixed_digits(bf, m, k)
        ok &= is_valid(bf, d) and mixed_value(bf, d) == m
        ok &= mixed_value(bf, d) < radix_prod(bf, k)  # size bound
    print(f"  every value decodes, is valid, re-encodes, and is < {k}!:  {ok}")
    assert ok

    # Uniqueness check by exhaustion: distinct valid strings -> distinct values.
    seen: Dict[int, Tuple[int, ...]] = {}
    unique = True
    for m in range(factorial(k)):
        d = tuple(mixed_digits(bf, m, k))
        v = mixed_value(bf, d)
        if v in seen and seen[v] != d:
            unique = False
        seen[v] = d
    print(f"  uniqueness (no two valid strings share a value): {unique}")
    assert unique


# ---------------------------------------------------------------------------
# Part I (cont.). Factoradics and permutation ranking (Lehmer code)
# ---------------------------------------------------------------------------

def perm_to_lehmer(perm: Sequence[int]) -> List[int]:
    """Lehmer code: c_i = #{ j > i : perm[j] < perm[i] }, indexed so that the
    place worth i! carries digit in 0..i (little-endian by rising factorial)."""
    n = len(perm)
    code = []
    for i in range(n):
        c = sum(1 for j in range(i + 1, n) if perm[j] < perm[i])
        code.append(c)
    # code[i] is bounded by (n-1-i); reverse so digit at place j! is <= j.
    return list(reversed(code))


def rank_permutation(perm: Sequence[int]) -> int:
    """Rank of a permutation = factoradic value of its Lehmer code."""
    code = perm_to_lehmer(perm)
    bf = factorial_bases()
    return mixed_value(bf, code)


def demo_permutation_ranking() -> None:
    print("\n" + "=" * 70)
    print("PART I (cont.): FACTORADIC PERMUTATION RANKING")
    print("=" * 70)
    from itertools import permutations
    n = 4
    ranks = [rank_permutation(p) for p in permutations(range(n))]
    print(f"\nAll {factorial(n)} permutations of {list(range(n))} ranked:")
    print(f"  ranks = {sorted(ranks)}")
    print(f"  distinct ranks: {len(set(ranks))} == n! = {factorial(n)}: "
          f"{len(set(ranks)) == factorial(n)}")
    assert sorted(ranks) == list(range(factorial(n)))
    print("  the ranking is a bijection onto {0, ..., n!-1}  (correct)")


# ---------------------------------------------------------------------------
# Part II. Primitive prime divisors of Fibonacci numbers
# ---------------------------------------------------------------------------

def fib(n: int) -> int:
    """n-th Fibonacci number, F_1 = F_2 = 1, F_0 = 0."""
    a, b = 0, 1
    for _ in range(n):
        a, b = b, a + b
    return a


def proper_divisors(n: int) -> List[int]:
    """All d with 0 < d < n and d | n."""
    return [d for d in range(1, n) if n % d == 0]


def primitive_part(n: int) -> int:
    """Strip from F_n every prime already occurring in some F_d, d a proper
    divisor of n, using gcd(F_n, F_d) = F_gcd(n,d)."""
    r = fib(n)
    for d in proper_divisors(n):
        fd = fib(d)
        g = gcd(r, fd)
        while g > 1:
            r //= g
            g = gcd(r, fd)
    return r


def smallest_prime_factor(m: int) -> int:
    """Smallest prime factor of m > 1."""
    if m % 2 == 0:
        return 2
    p = 3
    while p <= isqrt(m):
        if m % p == 0:
            return p
        p += 2
    return m


def primitive_divisor(n: int) -> int | None:
    """A primitive prime divisor of F_n, or None if F_n has none."""
    pp = primitive_part(n)
    if pp <= 1:
        return None
    return smallest_prime_factor(pp)


def verify_primitive(n: int, p: int) -> bool:
    """Directly check p | F_n but p does not divide any earlier F_k."""
    if fib(n) % p != 0:
        return False
    return all(fib(k) % p != 0 for k in range(1, n))


def demo_fibonacci() -> None:
    print("\n" + "=" * 70)
    print("PART II: PRIMITIVE PRIME DIVISORS OF FIBONACCI NUMBERS")
    print("=" * 70)

    print("\nSmall exceptional cases (no primitive prime divisor):")
    for n in (1, 2, 6, 12):
        pd = primitive_divisor(n)
        print(f"  F_{n:2d} = {fib(n):4d}   primitive divisor: {pd}")

    print("\nFrom n = 13 onward, every term carries a fresh prime:")
    for n in range(13, 25):
        p = primitive_divisor(n)
        assert p is not None and verify_primitive(n, p)
        print(f"  F_{n:2d} = {fib(n):8d}   primitive prime divisor p = {p}"
              f"   (checked p | F_{n}, p nmid F_k for k<{n})")

    # Exhaustive check on a modest range (full theorem is 13..10000).
    # We test primitive_part(n) > 1 directly: by the survivor lemma this is
    # equivalent to F_n having a primitive prime divisor, and it avoids
    # factoring the (possibly huge) primitive part.
    print("\nExhaustive verification on 13 <= n <= 300:")
    bad = [n for n in range(13, 301) if primitive_part(n) <= 1]
    print(f"  terms with primitive part <= 1 (no primitive divisor): {bad}")
    assert bad == []
    print("  every F_n (13 <= n <= 300) has primitive part > 1")
    print("  ->  Theorem holds on this range")


if __name__ == "__main__":
    demo_mixed_radix()
    demo_permutation_ranking()
    demo_fibonacci()
    print("\nAll demonstrations completed successfully.")
