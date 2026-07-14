"""
Numerical demonstrations for:

    A Fibonacci-Pythagorean Bridge and the Index-Level Law of
    Strong Divisibility Sequences

This self-contained script demonstrates, with concrete integers, the main
results:

  1. The Fibonacci-Pythagorean identity   A_n^2 + B_n^2 = C_n^2
  2. The hypotenuse identity               C_n = F_{2n+3}
  3. The strong-divisibility law           F_m | F_n  <=>  m | n
  4. The Mersenne-type law                 a^m - 1 | a^n - 1  <=>  m | n
  5. The Fibonacci prime-index test        F_n prime  =>  n = 4 or n prime

Run:  python demo.py
"""

from __future__ import annotations

from math import gcd
from typing import List, Tuple


# --------------------------------------------------------------------------
# Core sequences
# --------------------------------------------------------------------------

def fib(n: int) -> int:
    """Return the n-th Fibonacci number with F_0 = 0, F_1 = 1."""
    a, b = 0, 1
    for _ in range(n):
        a, b = b, a + b
    return a


def is_prime(n: int) -> bool:
    """Deterministic trial-division primality test for non-negative n."""
    if n < 2:
        return False
    if n < 4:
        return True
    if n % 2 == 0:
        return False
    d = 3
    while d * d <= n:
        if n % d == 0:
            return False
        d += 2
    return True


# --------------------------------------------------------------------------
# 1-2. Fibonacci-Pythagorean triples
# --------------------------------------------------------------------------

def fib_pythagorean_data(n: int) -> Tuple[int, int, int]:
    """Return (A_n, B_n, C_n) = (F_n F_{n+3}, 2 F_{n+1} F_{n+2}, F_{n+1}^2 + F_{n+2}^2)."""
    Fn, Fn1, Fn2, Fn3 = fib(n), fib(n + 1), fib(n + 2), fib(n + 3)
    a = Fn * Fn3
    b = 2 * Fn1 * Fn2
    c = Fn1 ** 2 + Fn2 ** 2
    return a, b, c


def is_primitive(a: int, b: int, c: int) -> bool:
    """A triple is primitive iff the three sides share no common factor > 1."""
    return gcd(gcd(a, b), c) == 1


def demo_triples(max_n: int = 6) -> None:
    print("=" * 70)
    print("1-2. Fibonacci-Pythagorean triples  (A^2 + B^2 = C^2,  C = F_{2n+3})")
    print("=" * 70)
    print(f"{'n':>3} | {'A':>6} {'B':>7} {'C':>7} | {'F_(2n+3)':>9} | check | primitive")
    print("-" * 70)
    for n in range(1, max_n + 1):
        a, b, c = fib_pythagorean_data(n)
        f = fib(2 * n + 3)
        pyth_ok = (a * a + b * b == c * c)
        hyp_ok = (c == f)
        prim = is_primitive(a, b, c)
        print(f"{n:>3} | {a:>6} {b:>7} {c:>7} | {f:>9} | "
              f"{'OK' if pyth_ok and hyp_ok else 'FAIL':>5} | {prim}")
    print()


# --------------------------------------------------------------------------
# 3. Fibonacci strong-divisibility law
# --------------------------------------------------------------------------

def demo_fib_divisibility(max_idx: int = 12) -> None:
    print("=" * 70)
    print("3. Fibonacci divisibility:  F_m | F_n  <=>  m | n   (indices >= 3)")
    print("=" * 70)
    mismatches = 0
    for m in range(3, max_idx + 1):
        for n in range(m, max_idx + 1):
            term_div = (fib(n) % fib(m) == 0)
            index_div = (n % m == 0)
            if term_div != index_div:
                mismatches += 1
                print(f"  MISMATCH at (m,n)=({m},{n})")
    print(f"  checked indices 3..{max_idx}: {mismatches} mismatches "
          f"({'law holds' if mismatches == 0 else 'law violated'})")
    # Illustrative example
    print(f"  example: F_3 = {fib(3)} divides F_6, F_9, F_12 = "
          f"{fib(6)}, {fib(9)}, {fib(12)} (indices 6,9,12 are multiples of 3)")
    print()


# --------------------------------------------------------------------------
# 4. Mersenne-type divisibility law
# --------------------------------------------------------------------------

def demo_mersenne(a: int = 2, max_idx: int = 12) -> None:
    print("=" * 70)
    print(f"4. Mersenne-type law:  a^m - 1 | a^n - 1  <=>  m | n   (a = {a})")
    print("=" * 70)
    mismatches = 0
    for m in range(1, max_idx + 1):
        for n in range(m, max_idx + 1):
            term_div = ((a ** n - 1) % (a ** m - 1) == 0)
            index_div = (n % m == 0)
            if term_div != index_div:
                mismatches += 1
                print(f"  MISMATCH at (m,n)=({m},{n})")
    print(f"  checked indices 1..{max_idx}: {mismatches} mismatches "
          f"({'law holds' if mismatches == 0 else 'law violated'})")
    print(f"  example: 2^3 - 1 = {2**3 - 1} divides 2^6 - 1 = {2**6 - 1} "
          f"and 2^9 - 1 = {2**9 - 1}")
    print()


# --------------------------------------------------------------------------
# 5. Fibonacci prime-index test
# --------------------------------------------------------------------------

def demo_prime_index_test(max_idx: int = 40) -> None:
    print("=" * 70)
    print("5. Fibonacci prime-index test:  F_n prime  =>  n = 4 or n prime")
    print("=" * 70)
    violations = 0
    fib_prime_indices: List[int] = []
    for n in range(1, max_idx + 1):
        if is_prime(fib(n)):
            fib_prime_indices.append(n)
            if not (n == 4 or is_prime(n)):
                violations += 1
                print(f"  VIOLATION: F_{n} = {fib(n)} prime but n composite != 4")
    print(f"  indices n<= {max_idx} with F_n prime: {fib_prime_indices}")
    print(f"  violations of the test: {violations} "
          f"({'test holds' if violations == 0 else 'test violated'})")
    print("  note: n=4 is the sole exception (F_4 = 3 is prime, 4 is not);")
    print("  note: prime index is necessary, not sufficient: "
          f"F_19 = {fib(19)} = 37 * 113 is composite.")
    print()


# --------------------------------------------------------------------------

def main() -> None:
    demo_triples()
    demo_fib_divisibility()
    demo_mersenne()
    demo_prime_index_test()


if __name__ == "__main__":
    main()
