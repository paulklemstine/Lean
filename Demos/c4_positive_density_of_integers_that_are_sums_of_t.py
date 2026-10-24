#!/usr/bin/env python3
"""
Sums of two anti-Fibonacci numbers: numerical companion.

The anti-Fibonacci numbers are A_n = n(n+1)/2 + 1 = 1, 2, 4, 7, 11, 16, 22, ...
An integer m is *representable* if m = A_a + A_b for some a, b >= 0.

This script illustrates, numerically:
  1. the identity 8*A_n = (2n+1)^2 + 7;
  2. the reduction  m representable  <=>  8m - 14 is a sum of two squares
                                    <=>  m >= 2 and 4m - 7 is a sum of two squares;
  3. the Fermat-type criterion (every prime q = 3 mod 4 divides 4m - 7 to an even power);
  4. the mod-9 obstruction (m = 1, 7 mod 9 is never representable: 2/9 of all integers);
  5. the exact Chinese-remainder count prod (p^2 - p + 1) of locally admissible residues;
  6. the sieve upper bound and the Euler-product inequality;
  7. density zero, and the Landau-Ramanujan-type normalisation R(N) sqrt(log N) / N,
     compared with K = 2b = 1.5284..., b the Landau-Ramanujan constant.

Only the Python standard library is used.
"""
from __future__ import annotations

import math
from typing import Dict, List, Sequence, Tuple

LANDAU_RAMANUJAN_B: float = 0.76422365358922066
K_CONST: float = 2.0 * LANDAU_RAMANUJAN_B


# ---------------------------------------------------------------------------
# Basic objects
# ---------------------------------------------------------------------------

def anti_fib(n: int) -> int:
    """The n-th anti-Fibonacci number A_n = n(n+1)/2 + 1."""
    return n * (n + 1) // 2 + 1


def representable_table(limit: int) -> bytearray:
    """rep[m] = 1 iff m = A_a + A_b for some a, b (0 <= m <= limit)."""
    rep = bytearray(limit + 1)
    vals: List[int] = []
    n = 0
    while anti_fib(n) <= limit:
        vals.append(anti_fib(n))
        n += 1
    for i, x in enumerate(vals):
        for y in vals[i:]:
            s = x + y
            if s > limit:
                break
            rep[s] = 1
    return rep


def is_sum_two_squares_brute(n: int) -> bool:
    """Brute-force test whether the integer n >= 0 is x^2 + y^2."""
    if n < 0:
        return False
    x = 0
    while 2 * x * x <= n:
        y2 = n - x * x
        y = math.isqrt(y2)
        if y * y == y2:
            return True
        x += 1
    return False


def factorize(n: int) -> Dict[int, int]:
    """Trial-division factorisation of n >= 1."""
    f: Dict[int, int] = {}
    d = 2
    while d * d <= n:
        while n % d == 0:
            f[d] = f.get(d, 0) + 1
            n //= d
        d += 1 if d == 2 else 2
    if n > 1:
        f[n] = f.get(n, 0) + 1
    return f


def fermat_criterion(m: int) -> bool:
    """m >= 2 and every prime q = 3 (mod 4) divides 4m - 7 to an even power."""
    if m < 2:
        return False
    return all(e % 2 == 0 for q, e in factorize(4 * m - 7).items() if q % 4 == 3)


def primes_up_to(n: int) -> List[int]:
    sieve = bytearray([1]) * (n + 1)
    sieve[0:2] = b"\x00\x00"
    for i in range(2, math.isqrt(n) + 1):
        if sieve[i]:
            sieve[i * i :: i] = bytearray(len(range(i * i, n + 1, i)))
    return [i for i in range(n + 1) if sieve[i]]


# ---------------------------------------------------------------------------
# The local sieve
# ---------------------------------------------------------------------------

def loc_ok(p: int, m: int) -> bool:
    """Local condition at p:  p | 4m-7  ==>  p^2 | 4m-7  (computed in the integers)."""
    u = 4 * m - 7
    return u % p != 0 or u % (p * p) == 0


def good(S: Sequence[int], m: int) -> bool:
    return all(loc_ok(p, m) for p in S)


def sieve_modulus(S: Sequence[int]) -> int:
    return math.prod(p * p for p in S)


def sieve_count(S: Sequence[int]) -> int:
    return math.prod(p * p - p + 1 for p in S)


def count_good_one_period(S: Sequence[int]) -> int:
    """Brute-force count of residues in [0, prod p^2) passing every local test."""
    return sum(1 for m in range(sieve_modulus(S)) if good(S, m))


def sieve_upper_bound(S: Sequence[int], N: int) -> int:
    """#{m < N representable} <= (N // Q + 1) * C."""
    return (N // sieve_modulus(S) + 1) * sieve_count(S)


# ---------------------------------------------------------------------------
# Demonstrations
# ---------------------------------------------------------------------------

def demo_identity_and_reduction(limit: int = 3000) -> None:
    print("=" * 72)
    print("1-3. Identity, reduction to sums of two squares, Fermat-type criterion")
    print("=" * 72)
    print("First anti-Fibonacci numbers:", [anti_fib(n) for n in range(12)])
    assert all(8 * anti_fib(n) == (2 * n + 1) ** 2 + 7 for n in range(10_000))
    print("Checked 8*A_n = (2n+1)^2 + 7 for n < 10000.")
    rep = representable_table(limit)
    for m in range(limit + 1):
        r = bool(rep[m])
        assert r == is_sum_two_squares_brute(8 * m - 14), m
        assert r == (m >= 2 and is_sum_two_squares_brute(4 * m - 7)), m
        assert r == fermat_criterion(m), m
    print(f"All three characterisations agree for every m <= {limit}.")
    print("Representable m <= 40:", [m for m in range(41) if rep[m]])
    m = 38
    print(f"Example: m = {m}: 4m-7 = {4*m-7} = {factorize(4*m-7)}, "
          f"representable = {bool(rep[m])}")
    m = 37
    print(f"Example: m = {m}: 4m-7 = {4*m-7} = {factorize(4*m-7)}, "
          f"representable = {bool(rep[m])}")
    print()


def demo_mod_nine(limit: int = 90_000) -> None:
    print("=" * 72)
    print("4. The mod-9 obstruction (the 2/9 lower bound)")
    print("=" * 72)
    rep = representable_table(limit)
    residues = sorted({m % 9 for m in range(2, limit + 1) if rep[m]})
    print("Residues mod 9 attained by representable m:", residues)
    assert 1 not in residues and 7 not in residues
    for k in (1, 10, 100, 1000, 10_000):
        nonrep = sum(1 for m in range(9 * k) if not rep[m])
        assert nonrep >= 2 * k
        print(f"  k = {k:>6}: non-representable in [0, 9k) = {nonrep:>6}  >= 2k = {2*k}")
    print()


def demo_crt_count() -> None:
    print("=" * 72)
    print("5. Exact CRT count of locally admissible residues")
    print("=" * 72)
    for S in ([3], [7], [3, 7], [3, 11], [7, 11], [3, 7, 11]):
        brute = count_good_one_period(S)
        formula = sieve_count(S)
        assert brute == formula
        print(f"  S = {S!s:<12} Q = {sieve_modulus(S):>8}   "
              f"count = {brute:>7} = prod(p^2-p+1)   ratio = {formula/sieve_modulus(S):.4f}")
    print()


def demo_sieve_bound(N: int = 1_000_000) -> None:
    print("=" * 72)
    print("6. Sieve upper bound and Euler-product inequality")
    print("=" * 72)
    rep = representable_table(N)
    R = sum(rep[:N])  # m < N
    S: List[int] = []
    for p in [3, 7, 11, 19, 23]:
        S.append(p)
        Q, C = sieve_modulus(S), sieve_count(S)
        rhs = 1.0 / (1.0 + 0.5 * sum(1.0 / q for q in S))
        assert C / Q <= rhs + 1e-15
        ub = sieve_upper_bound(S, N)
        assert R <= ub
        print(f"  S = {S!s:<20} C/Q = {C/Q:.4f} <= 1/(1+sum/2) = {rhs:.4f};  "
              f"R({N}) = {R} <= {ub}")
    print()


def demo_density(limit: int = 4_000_000) -> List[Tuple[int, int, float, float]]:
    print("=" * 72)
    print("7. Density zero and the Landau-Ramanujan normalisation")
    print("=" * 72)
    rep = representable_table(limit)
    rows: List[Tuple[int, int, float, float]] = []
    running = 0
    checkpoints = {10 ** k for k in range(2, 8)} | {limit}
    for m in range(limit + 1):
        running += rep[m]
        if m in checkpoints:
            dens = running / m
            norm = running * math.sqrt(math.log(m)) / m
            rows.append((m, running, dens, norm))
    print(f"  {'N':>9} {'R(N)':>9} {'R(N)/N':>9} {'R(N)sqrt(logN)/N':>18}")
    for N, R, d, nrm in rows:
        print(f"  {N:>9} {R:>9} {d:>9.4f} {nrm:>18.4f}")
    print(f"  Predicted limit K = 2b = {K_CONST:.5f}; convergence is slow "
          f"(relative error of order 1/log N).")
    print()
    return rows


def main() -> None:
    demo_identity_and_reduction()
    demo_mod_nine()
    demo_crt_count()
    demo_sieve_bound()
    demo_density()


if __name__ == "__main__":
    main()
