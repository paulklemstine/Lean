"""
The Fibonacci Divisibility Calculus -- numerical demonstrations.

This self-contained script demonstrates the four theorems of the calculus:

    1. fib_gcd_identity        F(gcd(m,n)) = gcd(F(m), F(n))           (Theorem 3.1)
    2. fib_coprime_of_coprime  gcd(m,n)=1  => gcd(F(m), F(n)) = 1      (Theorem 3.2)
    3. fib_dvd_iff             F(m) | F(n) <=> m | n   (for m >= 3)    (Theorem 3.3)
    4. prime_dvd_fib_gcd       p|F(m) & p|F(n) => p|F(gcd(m,n))        (Theorem 3.5)

Plus: sharpness of the m >= 3 hypothesis, and the rank of apparition.

Run with:  python demo.py
"""

from __future__ import annotations

from math import gcd
from functools import lru_cache
from typing import Dict, List, Tuple


# --------------------------------------------------------------------------- #
# Core: the Fibonacci function F(0)=0, F(1)=1, F(n+2)=F(n+1)+F(n)
# --------------------------------------------------------------------------- #
@lru_cache(maxsize=None)
def fib(n: int) -> int:
    """Return the n-th Fibonacci number with F(0) = 0, F(1) = 1."""
    if n < 2:
        return n
    a, b = 0, 1
    for _ in range(n - 1):
        a, b = b, a + b
    return b


# --------------------------------------------------------------------------- #
# Theorem 3.1 -- the strong divisibility law
# --------------------------------------------------------------------------- #
def check_fib_gcd_identity(m: int, n: int) -> Tuple[int, int, bool]:
    """Verify F(gcd(m,n)) == gcd(F(m), F(n)). Returns (lhs, rhs, equal)."""
    lhs = fib(gcd(m, n))
    rhs = gcd(fib(m), fib(n))
    return lhs, rhs, lhs == rhs


# --------------------------------------------------------------------------- #
# Theorem 3.2 -- coprime indices give coprime values
# --------------------------------------------------------------------------- #
def check_coprime_propagation(m: int, n: int) -> bool:
    """If gcd(m,n)=1 then gcd(F(m),F(n)) should be 1. Returns True if law holds."""
    if gcd(m, n) != 1:
        return True  # hypothesis not met; vacuously fine
    return gcd(fib(m), fib(n)) == 1


# --------------------------------------------------------------------------- #
# Theorem 3.3 -- the sharp divisibility characterization (m >= 3)
# --------------------------------------------------------------------------- #
def fib_divides_via_indices(m: int, n: int) -> bool:
    """Decide F(m) | F(n) using ONLY the indices (valid for m >= 3)."""
    assert m >= 3, "characterization requires m >= 3"
    return n % m == 0


def fib_divides_directly(m: int, n: int) -> bool:
    """Decide F(m) | F(n) by actually computing the (possibly huge) values."""
    fm = fib(m)
    if fm == 0:
        return fib(n) == 0
    return fib(n) % fm == 0


# --------------------------------------------------------------------------- #
# Theorem 3.5 -- descent step
# --------------------------------------------------------------------------- #
def check_descent(p: int, m: int, n: int) -> bool:
    """If p|F(m) and p|F(n) then p|F(gcd(m,n)) must hold."""
    if fib(m) % p == 0 and fib(n) % p == 0:
        return fib(gcd(m, n)) % p == 0
    return True  # hypothesis not met


# --------------------------------------------------------------------------- #
# Rank of apparition: least k > 0 with p | F(k), computed modulo p
# --------------------------------------------------------------------------- #
def rank_of_apparition(p: int, limit: int = 10_000) -> int:
    """Least k > 0 with p | F(k), working modulo p for efficiency."""
    a, b = 0, 1  # F(0), F(1)
    for k in range(1, limit + 1):
        if b % p == 0:
            return k
        a, b = b, (a + b) % p
    raise RuntimeError(f"rank of apparition for {p} not found below {limit}")


# --------------------------------------------------------------------------- #
# Demonstrations
# --------------------------------------------------------------------------- #
def demo_strong_law() -> None:
    print("=" * 70)
    print("Theorem 3.1  --  F(gcd(m,n)) = gcd(F(m), F(n))")
    print("=" * 70)
    pairs = [(12, 18), (9, 15), (10, 15), (8, 12), (7, 11), (20, 30)]
    for m, n in pairs:
        lhs, rhs, ok = check_fib_gcd_identity(m, n)
        mark = "OK" if ok else "FAIL"
        print(f"  m={m:2d} n={n:2d} | F(gcd)={lhs:6d}  gcd(F,F)={rhs:6d}  [{mark}]")
    print()


def demo_coprime() -> None:
    print("=" * 70)
    print("Theorem 3.2  --  coprime indices => coprime Fibonacci values")
    print("=" * 70)
    pairs = [(4, 9), (7, 11), (5, 8), (3, 10), (13, 21)]
    for m, n in pairs:
        ok = check_coprime_propagation(m, n)
        g_idx, g_val = gcd(m, n), gcd(fib(m), fib(n))
        print(f"  m={m:2d} n={n:2d} | gcd(m,n)={g_idx}  gcd(F{m},F{n})={g_val}  "
              f"[{'OK' if ok else 'FAIL'}]")
    print()


def demo_characterization() -> None:
    print("=" * 70)
    print("Theorem 3.3  --  F(m) | F(n)  <=>  m | n   (m >= 3)")
    print("    (index-only test agrees with direct big-integer test)")
    print("=" * 70)
    ms = [3, 4, 5, 6]
    for m in ms:
        for n in range(1, 25):
            via_idx = fib_divides_via_indices(m, n)
            direct = fib_divides_directly(m, n)
            assert via_idx == direct, f"MISMATCH at m={m}, n={n}"
        print(f"  m={m}: index-only test matches direct test for all n in [1,24]  [OK]")
    print()


def demo_sharpness() -> None:
    print("=" * 70)
    print("Proposition 3.4  --  the hypothesis m >= 3 is SHARP")
    print("=" * 70)
    print("  At m=1,2 we have F(m)=1, which divides EVERY F(n),")
    print("  so 'F(m)|F(n) <=> m|n' fails. Witness m=2:")
    for n in [3, 5, 7, 9]:
        fm_div = fib_divides_directly(2, n)   # F(2)=1 divides everything
        idx_div = (n % 2 == 0)
        print(f"    m=2 n={n}: F(2)|F(n)={fm_div}  but  2|{n}={idx_div}  "
              f"-> equivalence {'HOLDS' if fm_div == idx_div else 'BREAKS'}")
    print()


def demo_descent() -> None:
    print("=" * 70)
    print("Theorem 3.5  --  p|F(m) & p|F(n)  =>  p|F(gcd(m,n))")
    print("=" * 70)
    triples = [(2, 6, 9), (3, 8, 12), (5, 10, 15), (7, 8, 16)]
    for p, m, n in triples:
        ok = check_descent(p, m, n)
        g = gcd(m, n)
        print(f"  p={p} m={m:2d} n={n:2d} | p|F{m}={fib(m)%p==0} "
              f"p|F{n}={fib(n)%p==0} => p|F(gcd={g})={fib(g)%p==0}  "
              f"[{'OK' if ok else 'FAIL'}]")
    print()


def demo_rank() -> None:
    print("=" * 70)
    print("Rank of apparition  alpha(p) = least k>0 with p | F(k)")
    print("    Conjecture:  p | F(n)  <=>  alpha(p) | n   (p != 5)")
    print("=" * 70)
    for p in [2, 3, 5, 7, 11, 13, 17, 19, 23]:
        a = rank_of_apparition(p)
        # check the divisibility characterization of the rank for n up to 60
        ok = all((fib(n) % p == 0) == (n % a == 0) for n in range(1, 61))
        flag = "OK" if ok else "(p=5 exceptional)" if p == 5 else "FAIL"
        print(f"  alpha({p:2d}) = {a:2d}   [n|F-test up to 60: {flag}]")
    print()


def main() -> None:
    demo_strong_law()
    demo_coprime()
    demo_characterization()
    demo_sharpness()
    demo_descent()
    demo_rank()
    print("All demonstrations complete.")


if __name__ == "__main__":
    main()
