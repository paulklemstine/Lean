"""
Entry-Point Duality for the Fibonacci Sequence — numerical demonstrations.

This self-contained script illustrates the four central results:

  1. Entry-point duality:        p | F(n)  <=>  z(p) | n        (any p)
  2. Primitivity characterization: prime p is primitive for F(n)  <=>  z(p) = n
  3. Strong divisibility law:     F(m) | F(n)  <=>  m | n        (m >= 3)
  4. Verified Carmichael theorem: explicit primitive prime divisors for n <= 40
                                   (exceptions n in {1, 2, 6, 12})

All functions are inlined; only the Python standard library is used.
Run:  python demo.py
"""

from __future__ import annotations

from math import gcd
from typing import Dict, List, Optional, Tuple


# --------------------------------------------------------------------------- #
# Core Fibonacci utilities
# --------------------------------------------------------------------------- #
def fib(n: int) -> int:
    """The n-th Fibonacci number, F(0)=0, F(1)=1, F(n+2)=F(n+1)+F(n)."""
    a, b = 0, 1
    for _ in range(n):
        a, b = b, a + b
    return a


def fib_mod(n: int, m: int) -> int:
    """F(n) mod m, computed without ever forming the (huge) value F(n)."""
    if m == 1:
        return 0
    a, b = 0, 1
    for _ in range(n):
        a, b = b, (a + b) % m
    return a % m


def fib_entry(p: int, search_limit: int = 10_000) -> int:
    """
    The Fibonacci entry point z(p): least k > 0 with p | F(k), else 0.

    Implemented as a bounded linear scan using F(k) mod p so the state
    stays small.  For p >= 1 a positive entry point always exists within
    O(p^2) steps (the Pisano period); search_limit is a safety cap.
    """
    if p <= 0:
        return 0
    if p == 1:
        return 1  # 1 divides F(1) = 1
    for k in range(1, search_limit + 1):
        if fib_mod(k, p) == 0:
            return k
    return 0


# --------------------------------------------------------------------------- #
# Elementary primality / factoring (small inputs)
# --------------------------------------------------------------------------- #
def is_prime(n: int) -> bool:
    """Deterministic trial-division primality test (fine for the demo sizes)."""
    if n < 2:
        return False
    if n % 2 == 0:
        return n == 2
    d = 3
    while d * d <= n:
        if n % d == 0:
            return False
        d += 2
    return True


def factorize(n: int) -> Dict[int, int]:
    """Prime factorization of n as {prime: exponent}."""
    factors: Dict[int, int] = {}
    d = 2
    while d * d <= n:
        while n % d == 0:
            factors[d] = factors.get(d, 0) + 1
            n //= d
        d += 1 if d == 2 else 2
    if n > 1:
        factors[n] = factors.get(n, 0) + 1
    return factors


# --------------------------------------------------------------------------- #
# Result 1 — Entry-point duality:  p | F(n)  <=>  z(p) | n
# --------------------------------------------------------------------------- #
def divides_fib(p: int, n: int) -> bool:
    """True iff p | F(n), computed via F(n) mod p."""
    return fib_mod(n, p) == 0


def duality_holds(p: int, n: int) -> bool:
    """Check both sides of the entry-point duality agree for (p, n)."""
    z = fib_entry(p)
    lhs = divides_fib(p, n)
    rhs = (n % z == 0) if z != 0 else (n == 0)
    return lhs == rhs


def demo_duality() -> None:
    print("=" * 70)
    print("RESULT 1 — Entry-point duality:  p | F(n)  <=>  z(p) | n")
    print("=" * 70)
    for p in [2, 3, 5, 7, 11, 8, 12]:  # includes composite p (no primality!)
        z = fib_entry(p)
        appearances = [n for n in range(1, 31) if divides_fib(p, n)]
        print(f"  p={p:3d}:  z(p)={z:3d}   appearances in 1..30 = {appearances}")
        print(f"            == multiples of z(p)?  "
              f"{appearances == [n for n in range(1, 31) if n % z == 0]}")
    ok = all(duality_holds(p, n)
             for p in range(2, 60) for n in range(0, 60))
    print(f"\n  Duality verified for all 2<=p<60, 0<=n<60:  {ok}")
    print()


# --------------------------------------------------------------------------- #
# Result 2 — Primitivity:  prime p primitive for F(n)  <=>  z(p) = n
# --------------------------------------------------------------------------- #
def is_primitive_divisor(p: int, n: int) -> bool:
    """Direct definition: p prime, p | F(n), and p divides no earlier F(k)."""
    if not is_prime(p) or not divides_fib(p, n):
        return False
    return all(not divides_fib(p, k) for k in range(1, n))


def is_primitive_via_entry(p: int, n: int) -> bool:
    """Characterization via Theorem 4.2:  prime, p | F(n), and z(p) = n."""
    return is_prime(p) and divides_fib(p, n) and fib_entry(p) == n


def demo_primitivity() -> None:
    print("=" * 70)
    print("RESULT 2 — Primitivity  <=>  z(p) = n   (Theorem 4.2)")
    print("=" * 70)
    agree = True
    for n in range(1, 21):
        fn = fib(n)
        primes = [p for p in factorize(fn)] if fn > 1 else []
        for p in primes:
            a = is_primitive_divisor(p, n)
            b = is_primitive_via_entry(p, n)
            agree &= (a == b)
            tag = "PRIMITIVE" if a else "         "
            print(f"  n={n:2d}  F(n)={fn:8d}  prime {p:7d}  z(p)={fib_entry(p):2d}"
                  f"  {tag}  (def==entry: {a == b})")
    print(f"\n  Definition and entry-point test agree everywhere:  {agree}")
    print()


# --------------------------------------------------------------------------- #
# Result 3 — Strong divisibility:  F(m) | F(n)  <=>  m | n   (m >= 3)
# --------------------------------------------------------------------------- #
def strong_divisibility_holds(m: int, n: int) -> bool:
    """Check F(m) | F(n)  <=>  m | n  for m >= 3."""
    lhs = (fib(n) % fib(m) == 0)
    rhs = (n % m == 0)
    return lhs == rhs


def demo_strong_divisibility() -> None:
    print("=" * 70)
    print("RESULT 3 — Strong divisibility:  F(m) | F(n)  <=>  m | n  (m>=3)")
    print("=" * 70)
    for m in [3, 4, 5, 7, 12]:
        ns = [n for n in range(1, 41) if fib(n) % fib(m) == 0]
        print(f"  m={m:2d}  F(m)={fib(m):3d}  divides F(n) for n in {ns}")
        print(f"          == multiples of {m}?  "
              f"{ns == [n for n in range(1, 41) if n % m == 0]}")
    ok = all(strong_divisibility_holds(m, n)
             for m in range(3, 15) for n in range(0, 60))
    print(f"\n  Strong divisibility verified for 3<=m<15, 0<=n<60:  {ok}")
    print()


# --------------------------------------------------------------------------- #
# Result 4 — Verified Carmichael theorem on  n <= 40
# --------------------------------------------------------------------------- #
FIB_PRIM_WITNESS: Dict[int, int] = {
    3: 2, 4: 3, 5: 5, 7: 13, 8: 7, 9: 17, 10: 11, 11: 89, 13: 233, 14: 29,
    15: 61, 16: 47, 17: 1597, 18: 19, 19: 37, 20: 41, 21: 421, 22: 199,
    23: 28657, 24: 23, 25: 3001, 26: 521, 27: 53, 28: 281, 29: 514229,
    30: 31, 31: 557, 32: 2207, 33: 19801, 34: 3571, 35: 141961, 36: 107,
    37: 73, 38: 9349, 39: 135721, 40: 2161,
}
CARMICHAEL_EXCEPTIONS = {1, 2, 6, 12}


def least_primitive_prime_divisor(n: int) -> Optional[int]:
    """Least primitive prime divisor of F(n), or None if none exists."""
    fn = fib(n)
    if fn <= 1:
        return None
    for p in sorted(factorize(fn)):
        if is_primitive_via_entry(p, n):
            return p
    return None


def demo_carmichael() -> None:
    print("=" * 70)
    print("RESULT 4 — Verified Carmichael theorem (n <= 40)")
    print("=" * 70)
    all_ok = True
    for n in range(1, 41):
        if n in CARMICHAEL_EXCEPTIONS:
            lp = least_primitive_prime_divisor(n)
            print(f"  n={n:2d}  EXCEPTION  (no primitive divisor; computed: {lp})")
            all_ok &= (lp is None)
            continue
        w = FIB_PRIM_WITNESS[n]
        ok = is_primitive_divisor(w, n)
        # cross-check the witness equals the *least* primitive prime divisor
        lp = least_primitive_prime_divisor(n)
        print(f"  n={n:2d}  witness {w:7d}  primitive? {ok}   least-prim={lp}")
        all_ok &= ok and (lp == w)
    print(f"\n  Table verified as least primitive prime divisors:  {all_ok}")
    print()


# --------------------------------------------------------------------------- #
# Driver
# --------------------------------------------------------------------------- #
def main() -> None:
    demo_duality()
    demo_primitivity()
    demo_strong_divisibility()
    demo_carmichael()
    print("All demonstrations completed.")


if __name__ == "__main__":
    main()
