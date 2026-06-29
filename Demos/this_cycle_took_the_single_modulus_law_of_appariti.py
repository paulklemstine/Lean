"""
Numerical demonstration of the multiplicative structure of the
Fibonacci rank of apparition (entry point).

The rank of apparition alpha(m) is the least k > 0 with m | F(k), where
F is the Fibonacci sequence (F(0)=0, F(1)=1, F(k+2)=F(k+1)+F(k)).

This script demonstrates, with concrete numbers, the results:

  * Law of apparition:        m | F(k)  <=>  alpha(m) | k
  * Divisibility-monotonicity: a | b    =>  alpha(a) | alpha(b)
  * Coprime multiplicativity:  gcd(m,n)=1 => alpha(m*n) = lcm(alpha(m), alpha(n))
  * Sharpness:                 alpha(4) = 6 != 3 = lcm(alpha(2), alpha(2))
  * Prime-power tower base:    alpha(p) | alpha(p^2)

Everything is self-contained: no imports beyond the standard library.
"""

from __future__ import annotations

from math import gcd
from typing import Dict, List, Tuple


def lcm(a: int, b: int) -> int:
    """Least common multiple of two positive integers."""
    if a == 0 or b == 0:
        return 0
    return a // gcd(a, b) * b


def fib(k: int) -> int:
    """The k-th Fibonacci number, with F(0)=0, F(1)=1 (iterative)."""
    a, b = 0, 1
    for _ in range(k):
        a, b = b, a + b
    return a


def fib_entry(m: int, limit: int = 100_000) -> int:
    """
    The rank of apparition alpha(m): least k > 0 with m | F(k).

    Computed by iterating Fibonacci residues modulo m (the pair-sequence
    dynamical system), which is guaranteed to terminate by the existence
    theorem. Returns 0 if no entry point is found within `limit` steps
    (never happens for m > 0 with a generous limit).
    """
    if m <= 0:
        raise ValueError("m must be positive")
    if m == 1:
        return 1
    a, b = 0, 1  # (F(0), F(1)) mod m
    for k in range(1, limit + 1):
        a, b = b % m, (a + b) % m  # now a = F(k) mod m
        if a == 0:
            return k
    return 0


def is_prime(n: int) -> bool:
    """Trial-division primality test."""
    if n < 2:
        return False
    i = 2
    while i * i <= n:
        if n % i == 0:
            return False
        i += 1
    return True


def prime_factorization(m: int) -> Dict[int, int]:
    """Return the map prime -> exponent for m > 0."""
    factors: Dict[int, int] = {}
    d = 2
    while d * d <= m:
        while m % d == 0:
            factors[d] = factors.get(d, 0) + 1
            m //= d
        d += 1
    if m > 1:
        factors[m] = factors.get(m, 0) + 1
    return factors


def fib_entry_by_crt(m: int) -> int:
    """
    Reconstruct alpha(m) as lcm over prime-power factors (Conjecture 6.1 /
    Algorithm 5.1). For coprime assembly this matches the direct scan.
    """
    if m == 1:
        return 1
    result = 1
    for p, e in prime_factorization(m).items():
        result = lcm(result, fib_entry(p ** e))
    return result


# --------------------------------------------------------------------------
# Demonstrations
# --------------------------------------------------------------------------

def demo_small_values() -> None:
    """Print alpha(m) for small m alongside the witnessing Fibonacci number."""
    print("=" * 60)
    print("Rank of apparition for small moduli")
    print("=" * 60)
    print(f"{'m':>4} | {'alpha(m)':>9} | {'F(alpha(m))':>14} | check m | F")
    print("-" * 60)
    for m in range(1, 16):
        a = fib_entry(m)
        fa = fib(a)
        ok = "ok" if fa % m == 0 else "FAIL"
        print(f"{m:>4} | {a:>9} | {fa:>14} | {ok}")
    print()


def demo_law_of_apparition() -> None:
    """Verify m | F(k)  <=>  alpha(m) | k for several m and a range of k."""
    print("=" * 60)
    print("Law of apparition:  m | F(k)  <=>  alpha(m) | k")
    print("=" * 60)
    for m in (2, 3, 4, 7, 10):
        a = fib_entry(m)
        positions: List[int] = [k for k in range(1, 41) if fib(k) % m == 0]
        predicted: List[int] = [k for k in range(1, 41) if k % a == 0]
        match = "ok" if positions == predicted else "FAIL"
        print(f"m={m:>2}  alpha={a:>2}  appearances in 1..40: {positions}  [{match}]")
    print()


def demo_monotonicity() -> None:
    """Verify a | b  =>  alpha(a) | alpha(b)."""
    print("=" * 60)
    print("Divisibility-monotonicity:  a | b  =>  alpha(a) | alpha(b)")
    print("=" * 60)
    pairs: List[Tuple[int, int]] = [(2, 4), (2, 6), (3, 6), (2, 8), (5, 10), (3, 12)]
    for a, b in pairs:
        aa, ab = fib_entry(a), fib_entry(b)
        ok = "ok" if ab % aa == 0 else "FAIL"
        print(f"{a:>2} | {b:>2}   =>   alpha={aa:>2} | alpha={ab:>2}   [{ok}]")
    print()


def demo_coprime_multiplicativity() -> None:
    """Verify alpha(m*n) = lcm(alpha(m), alpha(n)) for coprime m, n."""
    print("=" * 60)
    print("Coprime multiplicativity:  alpha(m*n) = lcm(alpha m, alpha n)")
    print("=" * 60)
    coprime_pairs: List[Tuple[int, int]] = [
        (2, 3), (2, 5), (3, 5), (4, 3), (5, 7), (8, 9), (4, 25)
    ]
    for m, n in coprime_pairs:
        assert gcd(m, n) == 1
        lhs = fib_entry(m * n)
        rhs = lcm(fib_entry(m), fib_entry(n))
        ok = "ok" if lhs == rhs else "FAIL"
        print(
            f"m={m:>2} n={n:>2}  alpha(mn)={lhs:>3}  "
            f"lcm(alpha m={fib_entry(m)}, alpha n={fib_entry(n)})={rhs:>3}  [{ok}]"
        )
    print()


def demo_sharpness() -> None:
    """Show the identity FAILS without coprimality: m = n = 2."""
    print("=" * 60)
    print("Sharpness: coprimality is necessary (m = n = 2)")
    print("=" * 60)
    a4 = fib_entry(4)
    naive = lcm(fib_entry(2), fib_entry(2))
    print(f"alpha(4)              = {a4}")
    print(f"lcm(alpha 2, alpha 2) = lcm(3, 3) = {naive}")
    print(f"gap factor            = {a4 // naive}  (= the squared prime 2)")
    assert a4 == 6 and naive == 3
    print("=> the lcm formula undershoots by exactly the prime power delay.")
    print()


def demo_prime_power_tower() -> None:
    """Verify alpha(p) | alpha(p^2) and display the dichotomy ratio."""
    print("=" * 60)
    print("Prime-power tower:  alpha(p) | alpha(p^2), ratio in {1, p}")
    print("=" * 60)
    for p in (2, 3, 5, 7, 11, 13):
        ap, ap2 = fib_entry(p), fib_entry(p * p)
        ratio = ap2 // ap
        divides = "ok" if ap2 % ap == 0 else "FAIL"
        note = "stays" if ratio == 1 else f"x{ratio}"
        print(
            f"p={p:>2}  alpha(p)={ap:>3}  alpha(p^2)={ap2:>4}  "
            f"ratio={ratio:>2} ({note})  [{divides}]"
        )
    print()


def demo_crt_reconstruction() -> None:
    """Verify alpha(m) = lcm over prime-power factors (Conjecture 6.1)."""
    print("=" * 60)
    print("CRT reconstruction: alpha(m) = lcm_i alpha(p_i^e_i)")
    print("=" * 60)
    for m in (6, 10, 12, 30, 100, 360):
        direct = fib_entry(m)
        assembled = fib_entry_by_crt(m)
        ok = "ok" if direct == assembled else "FAIL"
        fac = " * ".join(f"{p}^{e}" for p, e in prime_factorization(m).items())
        print(f"m={m:>4} = {fac:<14}  direct={direct:>4}  assembled={assembled:>4}  [{ok}]")
    print()


def main() -> None:
    demo_small_values()
    demo_law_of_apparition()
    demo_monotonicity()
    demo_coprime_multiplicativity()
    demo_sharpness()
    demo_prime_power_tower()
    demo_crt_reconstruction()
    print("All demonstrations completed.")


if __name__ == "__main__":
    main()
