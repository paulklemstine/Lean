"""
Primitive Prime Divisors of Fibonacci Numbers -- Numerical Demonstrations
=========================================================================

This self-contained script demonstrates, numerically, the main results of the
accompanying paper on primitive prime divisors of the Fibonacci sequence:

  * Strong divisibility:        gcd(F_m, F_n) = F_{gcd(m,n)}
  * Entry point z(p) and the    p | F_n  <=>  z(p) | n
  * Primitive prime divisors    and the exceptional set {1, 2, 6, 12}
  * Lifting the exponent:       v_p(F_{n*k}) = v_p(F_k) + v_p(n)
  * Growth bound:               2^floor((n-2)/2) <= F_n
  * Entry-point localization:   z(p) | p^2 - 1   (and z(p) | p +/- 1)
  * Simultaneous apparition:    p,q primitive  =>  joint divisibility <=> lcm | n

Everything is plain Python (standard library only), with type hints, and every
helper function is inlined so the file can be run directly:

    python3 demo.py
"""

from __future__ import annotations

from math import gcd, isqrt
from typing import Dict, List, Optional, Tuple


# --------------------------------------------------------------------------- #
# Core arithmetic helpers (all inlined, no external dependencies)             #
# --------------------------------------------------------------------------- #

def fib(n: int) -> int:
    """Return the n-th Fibonacci number F_n with F_0 = 0, F_1 = 1."""
    a, b = 0, 1
    for _ in range(n):
        a, b = b, a + b
    return a


def lcm(a: int, b: int) -> int:
    """Least common multiple of a and b."""
    if a == 0 or b == 0:
        return 0
    return a // gcd(a, b) * b


def padic_val(p: int, n: int) -> int:
    """p-adic valuation v_p(n): the exponent of prime p in n (n > 0)."""
    if n == 0:
        raise ValueError("v_p(0) is undefined / infinite")
    v = 0
    while n % p == 0:
        n //= p
        v += 1
    return v


def is_prime(n: int) -> bool:
    """Deterministic trial-division primality test."""
    if n < 2:
        return False
    if n % 2 == 0:
        return n == 2
    for d in range(3, isqrt(n) + 1, 2):
        if n % d == 0:
            return False
    return True


def prime_factors(n: int) -> List[int]:
    """Return the sorted list of distinct prime factors of n (n >= 1)."""
    factors: List[int] = []
    d = 2
    while d * d <= n:
        if n % d == 0:
            factors.append(d)
            while n % d == 0:
                n //= d
        d += 1 if d == 2 else 2
    if n > 1:
        factors.append(n)
    return factors


def entry_point(p: int, bound: Optional[int] = None) -> int:
    """
    Fibonacci entry point z(p): the least k > 0 with p | F_k.
    By the localization theorem z(p) | p^2 - 1, so we search up to p^2 - 1
    unless a tighter bound is supplied.
    """
    if bound is None:
        bound = max(2, p * p - 1)
    a, b = 0, 1  # (F_0, F_1)
    for k in range(1, bound + 1):
        a, b = b, (a + b) % (p * p)  # keep numbers small; mod p^2 preserves p-divisibility info
        if a % p == 0:
            return k
    raise RuntimeError(f"no entry point found for p={p} below {bound}")


def is_primitive_prime_divisor(p: int, n: int) -> bool:
    """True iff prime p divides F_n but divides no earlier F_k (1 <= k < n)."""
    if not is_prime(p):
        return False
    if fib(n) % p != 0:
        return False
    return all(fib(k) % p != 0 for k in range(1, n))


def has_primitive_prime_divisor(n: int) -> bool:
    """True iff some prime is a primitive prime divisor of F_n."""
    Fn = fib(n)
    if Fn <= 1:
        return False
    return any(is_primitive_prime_divisor(p, n) for p in prime_factors(Fn))


def primitive_divisors(n: int) -> List[int]:
    """List the primitive prime divisors of F_n."""
    return [p for p in prime_factors(fib(n)) if is_primitive_prime_divisor(p, n)]


# --------------------------------------------------------------------------- #
# Demonstrations                                                              #
# --------------------------------------------------------------------------- #

def demo_table_of_primitive_divisors(limit: int = 20) -> None:
    print("=" * 70)
    print("Fibonacci numbers, factorizations, and primitive prime divisors")
    print("=" * 70)
    print(f"{'n':>3} | {'F_n':>10} | {'prime factors':<22} | primitive")
    print("-" * 70)
    for n in range(1, limit + 1):
        Fn = fib(n)
        pf = prime_factors(Fn)
        prim = primitive_divisors(n)
        pf_str = "*".join(map(str, pf)) if pf else "(none)"
        prim_str = ",".join(map(str, prim)) if prim else "--- (NONE)"
        print(f"{n:>3} | {Fn:>10} | {pf_str:<22} | {prim_str}")
    print()


def demo_exceptional_set(limit: int = 40) -> None:
    print("=" * 70)
    print("Carmichael's theorem: the exceptional set is exactly {1, 2, 6, 12}")
    print("=" * 70)
    no_prim = [n for n in range(1, limit + 1) if not has_primitive_prime_divisor(n)]
    print(f"Indices n in 1..{limit} with NO primitive prime divisor: {no_prim}")
    assert no_prim == [1, 2, 6, 12], "exceptional set mismatch!"
    print("Confirmed: every n >= 13 in range has a primitive prime divisor.")
    print()


def demo_strong_divisibility(pairs: List[Tuple[int, int]]) -> None:
    print("=" * 70)
    print("Strong divisibility:  gcd(F_m, F_n) = F_{gcd(m,n)}")
    print("=" * 70)
    for m, n in pairs:
        lhs = gcd(fib(m), fib(n))
        rhs = fib(gcd(m, n))
        status = "OK" if lhs == rhs else "FAIL"
        print(f"  gcd(F_{m}, F_{n}) = {lhs:>6}   F_gcd({m},{n})=F_{gcd(m,n)} = {rhs:>6}  [{status}]")
        assert lhs == rhs
    print()


def demo_entry_point_characterization(primes: List[int], n_max: int = 30) -> None:
    print("=" * 70)
    print("Entry point z(p) and characterization:  p | F_n  <=>  z(p) | n")
    print("=" * 70)
    for p in primes:
        z = entry_point(p)
        divides = [n for n in range(1, n_max + 1) if fib(n) % p == 0]
        predicted = [n for n in range(1, n_max + 1) if n % z == 0]
        status = "OK" if divides == predicted else "FAIL"
        print(f"  p={p:>3}: z(p)={z:>3}; indices n<= {n_max} with p|F_n: {divides}  [{status}]")
        assert divides == predicted
    print()


def demo_entry_point_localization(primes: List[int]) -> None:
    print("=" * 70)
    print("Entry-point localization:  z(p) | p^2 - 1   and   z(p) | p +/- 1")
    print("=" * 70)
    for p in primes:
        if p == 5:
            continue
        z = entry_point(p)
        div_sq = (p * p - 1) % z == 0
        side = "p-1" if (p - 1) % z == 0 else ("p+1" if (p + 1) % z == 0 else "neither")
        print(f"  p={p:>3}: z(p)={z:>3}; z | p^2-1: {div_sq}; divides {side}")
        assert div_sq
    print()


def demo_lifting_the_exponent(cases: List[Tuple[int, int, int]]) -> None:
    print("=" * 70)
    print("Lifting the exponent:  v_p(F_{n*k}) = v_p(F_k) + v_p(n)   (p odd, p|F_k, p∤n)")
    print("=" * 70)
    for p, k, n in cases:
        lhs = padic_val(p, fib(n * k))
        rhs = padic_val(p, fib(k)) + padic_val(p, n)
        status = "OK" if lhs == rhs else "FAIL"
        print(f"  p={p:>2}, k={k:>2}, n={n:>2}: v_p(F_{n*k})={lhs}  v_p(F_{k})+v_p({n})={rhs}  [{status}]")
        assert lhs == rhs
    print()


def demo_growth_bound(n_max: int = 25) -> None:
    print("=" * 70)
    print("Exponential growth bound:  2^floor((n-2)/2) <= F_n   (n >= 2)")
    print("=" * 70)
    for n in range(2, n_max + 1):
        lower = 2 ** ((n - 2) // 2)
        ok = lower <= fib(n)
        if n <= 14 or not ok:
            print(f"  n={n:>2}: 2^{(n-2)//2:<2} = {lower:>6} <= F_{n} = {fib(n):>6}  [{'OK' if ok else 'FAIL'}]")
        assert ok
    print("  (all checks pass through n =", n_max, ")")
    print()


def demo_simultaneous_apparition(p: int, q: int, n_max: int = 60) -> None:
    print("=" * 70)
    print("Simultaneous apparition:  (p|F_n and q|F_n) <=> lcm(z(p), z(q)) | n")
    print("=" * 70)
    a, b = entry_point(p), entry_point(q)
    L = lcm(a, b)
    joint = [n for n in range(1, n_max + 1) if fib(n) % p == 0 and fib(n) % q == 0]
    predicted = [n for n in range(1, n_max + 1) if n % L == 0]
    status = "OK" if joint == predicted else "FAIL"
    print(f"  p={p} (z={a}), q={q} (z={b}); lcm = {L}")
    print(f"  joint divisibility indices <= {n_max}: {joint}")
    print(f"  multiples of lcm <= {n_max}:        {predicted}  [{status}]")
    assert joint == predicted
    print()


def main() -> None:
    demo_table_of_primitive_divisors(limit=20)
    demo_exceptional_set(limit=40)
    demo_strong_divisibility([(12, 8), (15, 10), (21, 14), (6, 9)])
    demo_entry_point_characterization([2, 3, 5, 7, 11, 13], n_max=30)
    demo_entry_point_localization([2, 3, 7, 11, 13, 17, 19, 23])
    demo_lifting_the_exponent([
        (3, 4, 2), (3, 4, 5), (7, 8, 2), (7, 8, 3), (11, 10, 2), (11, 10, 4),
    ])
    demo_growth_bound(n_max=25)
    demo_simultaneous_apparition(2, 3, n_max=60)
    print("All numerical demonstrations passed. \u2713")


if __name__ == "__main__":
    main()
