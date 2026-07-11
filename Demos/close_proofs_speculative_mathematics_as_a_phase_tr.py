"""
Numerical demonstrations for:

  "Sharp Arithmetic Transitions in the Fibonacci Sequence:
   A Lifting-the-Exponent Law and Its Threshold Interpretation"

This self-contained script verifies, with exact big-integer arithmetic:

  1. The multiple-index binomial expansion
         F_{(m+1)n} = sum_{j=0}^{n} C(n,j) F_m^{n-j} F_{m+1}^j F_j.

  2. The Fibonacci lifting-the-exponent law (odd prime p, p | F_m):
         v_p(F_{m*p}) = v_p(F_m) + 1,
     and its iterated "valuation staircase" v_p(F_{m p^r}) = v_p(F_m) + r.

  3. The failure of the law at p = 2 (jumps can exceed 1).

  4. The term-by-term valuation profile from the proof (unique minimiser).

  5. Sharp thresholds / critical lengths for mixed-radix systems,
     specialising to the factorial number system (C_n = n!).

Run:  python demo.py
"""

from __future__ import annotations

from math import comb
from functools import lru_cache
from typing import Callable, List, Tuple


# --------------------------------------------------------------------------
# Core arithmetic
# --------------------------------------------------------------------------

@lru_cache(maxsize=None)
def fib(k: int) -> int:
    """The k-th Fibonacci number, F_0 = 0, F_1 = 1 (fast doubling)."""
    if k < 0:
        raise ValueError("index must be nonnegative")
    if k == 0:
        return 0
    a, b = 0, 1  # (F_0, F_1)
    for bit in bin(k)[2:]:
        c = a * (2 * b - a)      # F_{2i}
        d = a * a + b * b        # F_{2i+1}
        if bit == "0":
            a, b = c, d
        else:
            a, b = d, c + d
    return a


def p_adic_valuation(n: int, p: int) -> int:
    """The exponent of the prime p in n (v_p(n)); requires n != 0."""
    if n == 0:
        raise ValueError("v_p(0) is infinite")
    v = 0
    n = abs(n)
    while n % p == 0:
        n //= p
        v += 1
    return v


def is_prime(n: int) -> bool:
    if n < 2:
        return False
    i = 2
    while i * i <= n:
        if n % i == 0:
            return False
        i += 1
    return True


# --------------------------------------------------------------------------
# 1. Multiple-index binomial expansion
# --------------------------------------------------------------------------

def binom_expansion_rhs(m: int, n: int) -> int:
    """Right-hand side of Theorem 3.1: sum_j C(n,j) F_m^{n-j} F_{m+1}^j F_j."""
    Fm, Fm1 = fib(m), fib(m + 1)
    return sum(comb(n, j) * Fm ** (n - j) * Fm1 ** j * fib(j)
               for j in range(n + 1))


def check_binom_expansion(max_m: int = 8, max_n: int = 8) -> bool:
    ok = True
    for m in range(max_m + 1):
        for n in range(max_n + 1):
            lhs = fib((m + 1) * n)
            rhs = binom_expansion_rhs(m, n)
            if lhs != rhs:
                ok = False
                print(f"  MISMATCH m={m} n={n}: {lhs} != {rhs}")
    return ok


# --------------------------------------------------------------------------
# 2. Fibonacci lifting-the-exponent law + valuation staircase
# --------------------------------------------------------------------------

def rank_of_apparition(p: int, limit: int = 5000) -> int:
    """Least m >= 1 with p | F_m."""
    for m in range(1, limit + 1):
        if fib(m) % p == 0:
            return m
    raise RuntimeError(f"rank of apparition not found for p={p} within limit")


def check_lte_step(p: int, m: int) -> Tuple[int, int]:
    """Return (v_p(F_m), v_p(F_{m*p})); expect the second = first + 1 for odd p."""
    return p_adic_valuation(fib(m), p), p_adic_valuation(fib(m * p), p)


def valuation_staircase(p: int, m: int, R: int) -> List[int]:
    """[v_p(F_{m p^r}) for r in 0..R]; should be an arithmetic progression."""
    return [p_adic_valuation(fib(m * p ** r), p) for r in range(R + 1)]


# --------------------------------------------------------------------------
# 4. Term-by-term valuation profile from the proof of Theorem 4.1
# --------------------------------------------------------------------------

def term_valuation_profile(p: int, m: int) -> List[Tuple[int, int]]:
    """For F_{m*p} expanded via base (m-1), exponent p, return (j, v_p(T_j))
    for the nonzero terms T_j = C(p,j) F_{m-1}^{p-j} F_m^j F_j."""
    Fm1_lo, Fm = fib(m - 1), fib(m)
    profile = []
    for j in range(p + 1):
        term = comb(p, j) * Fm1_lo ** (p - j) * Fm ** j * fib(j)
        if term != 0:
            profile.append((j, p_adic_valuation(term, p)))
    return profile


# --------------------------------------------------------------------------
# 5. Sharp thresholds / critical lengths in mixed-radix systems
# --------------------------------------------------------------------------

def capacity(bases: List[int]) -> List[int]:
    """Prefix products C_n = prod_{k<n} b_k, for n = 0..len(bases)."""
    caps = [1]
    for b in bases:
        caps.append(caps[-1] * b)
    return caps


def critical_length(bases: Callable[[int], int], target: int,
                    max_len: int = 200) -> int:
    """Least n with C_n > target, where C_n = prod_{k<n} bases(k)."""
    cap = 1
    for n in range(max_len + 1):
        if cap > target:
            return n
        cap *= bases(n)
    raise RuntimeError("critical length exceeds max_len")


def factorial_critical_length(target: int) -> int:
    """Least n with n! > target (factorial system, bases b_i = i+1)."""
    return critical_length(lambda i: i + 1, target)


# --------------------------------------------------------------------------
# Driver
# --------------------------------------------------------------------------

def main() -> None:
    print("=" * 70)
    print("1. Multiple-index binomial expansion  F_{(m+1)n} = sum ...")
    print("=" * 70)
    ok = check_binom_expansion(8, 8)
    print(f"  All identities hold for 0<=m,n<=8:  {ok}")
    print(f"  Example m=3,n=5:  F_20 = {fib(20)} = {binom_expansion_rhs(3,5)}")

    print()
    print("=" * 70)
    print("2. Fibonacci lifting-the-exponent (odd primes) + staircase")
    print("=" * 70)
    for p in [3, 5, 7, 11, 13]:
        m = rank_of_apparition(p)
        v0, v1 = check_lte_step(p, m)
        stair = valuation_staircase(p, m, 3)
        status = "OK" if v1 == v0 + 1 else "FAIL"
        print(f"  p={p:2d}  rank m={m:2d}:  v_p(F_m)={v0}, v_p(F_mp)={v1}  [{status}]")
        print(f"         staircase v_p(F_(m p^r)), r=0..3:  {stair}")

    print()
    print("=" * 70)
    print("3. Failure at p = 2 (jumps can exceed 1)")
    print("=" * 70)
    for m in [3, 6]:
        v0, v1 = check_lte_step(2, m)
        print(f"  p=2  m={m}:  v_2(F_m)={v0}, v_2(F_2m)={v1}  (jump={v1-v0})")

    print()
    print("=" * 70)
    print("4. Term-by-term valuation profile (unique minimiser at j=1)")
    print("=" * 70)
    p, m = 11, rank_of_apparition(11)
    v = p_adic_valuation(fib(m), p)
    print(f"  p={p}, m={m}, v=v_p(F_m)={v}; critical valuation should be v+1={v+1}")
    for j, vj in term_valuation_profile(p, m):
        mark = "  <-- unique minimiser (= v+1)" if vj == v + 1 else ""
        print(f"    j={j:2d}:  v_p(T_j) = {vj}{mark}")

    print()
    print("=" * 70)
    print("5. Sharp thresholds / critical lengths (factorial system, C_n = n!)")
    print("=" * 70)
    for N in [5, 100, 1000, 10 ** 6, 10 ** 12]:
        tau = factorial_critical_length(N)
        caps = capacity(list(range(1, tau + 1)))
        print(f"  target N={N:>13}:  critical length tau={tau:2d}  "
              f"(with C_tau={caps[tau]} > N >= C_(tau-1)={caps[tau-1]})")

    # Anti-monotonicity: smaller bases percolate slower (Conjecture C3 flavour).
    print()
    print("  Base-comparison (target N=1000):")
    fact_tau = factorial_critical_length(1000)
    const2_tau = critical_length(lambda i: 2, 1000)     # binary: bases all 2
    const3_tau = critical_length(lambda i: 3, 1000)     # ternary: bases all 3
    print(f"    factorial (b_i=i+1): tau={fact_tau}")
    print(f"    ternary   (b_i=3)  : tau={const3_tau}")
    print(f"    binary    (b_i=2)  : tau={const2_tau}")
    print("    (smaller bases => larger threshold => slower to percolate)")


if __name__ == "__main__":
    main()
