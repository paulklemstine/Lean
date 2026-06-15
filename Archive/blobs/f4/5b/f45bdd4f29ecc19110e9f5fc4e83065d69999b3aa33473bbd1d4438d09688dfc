"""
The Apparition-Order Bridge: numerical demonstrations.

This script demonstrates the central results of the package:

  * Stalk reduction:        p | b^n - 1  <=>  (b mod p)^n = 1
  * Apparition-Order Bridge: entryPoint(b^n - 1, p) = orderOf(b mod p)   (p prime, p not| b)
  * Fermat descent:          entryPoint(b^n - 1, p) | (p - 1)
  * Support law:             {n : p | a(n)} = {multiples of entryPoint(p)}
  * Fibonacci support law:   {n : p | F_n} = {multiples of Fibonacci entry point}

Everything is self-contained: no imports beyond the standard library.
"""

from __future__ import annotations

from math import gcd
from typing import Dict, List, Optional


# ---------------------------------------------------------------------------
# Basic number theory
# ---------------------------------------------------------------------------

def is_prime(n: int) -> bool:
    """Deterministic trial-division primality test for modest n."""
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


def multiplicative_order(b: int, p: int) -> Optional[int]:
    """orderOf(b mod p): least k > 0 with b^k = 1 (mod p), or None if gcd(b, p) != 1."""
    b %= p
    if gcd(b, p) != 1:
        return None
    acc = b % p
    k = 1
    while acc != 1 % p:
        acc = (acc * b) % p
        k += 1
    return k


# ---------------------------------------------------------------------------
# Strong divisibility sequences
# ---------------------------------------------------------------------------

def mersenne_term(b: int, n: int) -> int:
    """a(n) = b^n - 1 for the Mersenne/repunit family."""
    return b ** n - 1


def fib(n: int) -> int:
    """The n-th Fibonacci number, F_0 = 0, F_1 = 1."""
    a, c = 0, 1
    for _ in range(n):
        a, c = c, a + c
    return a


def entry_point_direct(term, p: int, search_bound: int = 5000) -> Optional[int]:
    """Brute-force rank of apparition: least k > 0 with p | term(k), searching up to bound."""
    for k in range(1, search_bound + 1):
        if term(k) % p == 0:
            return k
    return None


# ---------------------------------------------------------------------------
# The Bridge, computed locally
# ---------------------------------------------------------------------------

def mersenne_entry_point_via_order(b: int, p: int) -> Optional[int]:
    """entryPoint(b^n - 1, p) computed locally as orderOf(b mod p)."""
    if not is_prime(p) or b % p == 0:
        return None
    return multiplicative_order(b, p)


def stalk_reduction_holds(b: int, p: int, n: int) -> bool:
    """Verify  p | b^n - 1  <=>  (b mod p)^n = 1  (mod p)."""
    left = mersenne_term(b, n) % p == 0
    right = pow(b % p, n, p) == 1 % p
    return left == right


# ---------------------------------------------------------------------------
# Demonstrations
# ---------------------------------------------------------------------------

def demo_bridge_table(b: int, primes: List[int]) -> None:
    """Compare the brute-force entry point with the local order, and check Fermat descent."""
    print(f"\n=== Apparition-Order Bridge for a(n) = {b}^n - 1 ===")
    print(f"{'p':>5} | {'order(b mod p)':>15} | {'entry (brute)':>13} | "
          f"{'equal?':>6} | {'(p-1)':>6} | {'order | p-1?':>12}")
    print("-" * 78)
    for p in primes:
        if not is_prime(p) or b % p == 0:
            continue
        order = mersenne_entry_point_via_order(b, p)
        brute = entry_point_direct(lambda k: mersenne_term(b, k), p)
        equal = (order == brute)
        descent = (order is not None and (p - 1) % order == 0)
        print(f"{p:>5} | {order!s:>15} | {brute!s:>13} | "
              f"{str(equal):>6} | {p - 1:>6} | {str(descent):>12}")


def demo_stalk_reduction(b: int, p: int, n_max: int = 20) -> None:
    """Verify the stalk reduction across a range of exponents."""
    print(f"\n=== Stalk reduction: {b}^n - 1 divisible by {p}  <=>  ({b} mod {p})^n = 1 ===")
    ok = all(stalk_reduction_holds(b, p, n) for n in range(0, n_max + 1))
    appears = [n for n in range(1, n_max + 1) if mersenne_term(b, n) % p == 0]
    print(f"  all equivalences hold for 0 <= n <= {n_max}: {ok}")
    print(f"  indices n in [1,{n_max}] with {p} | {b}^n - 1: {appears}")


def demo_support_law(b: int, p: int, n_max: int = 40) -> None:
    """Show the support of p is exactly the multiples of its entry point."""
    e = mersenne_entry_point_via_order(b, p)
    support = [n for n in range(1, n_max + 1) if mersenne_term(b, n) % p == 0]
    multiples = [n for n in range(1, n_max + 1) if e is not None and n % e == 0]
    print(f"\n=== Support law for {b}^n - 1 at p = {p} (entry point e = {e}) ===")
    print(f"  support of {p}        : {support}")
    print(f"  multiples of e = {e:>2}   : {multiples}")
    print(f"  match: {support == multiples}")


def demo_fibonacci_support(p: int, n_max: int = 60) -> None:
    """Fibonacci support law: {n : p | F_n} = multiples of the Fibonacci entry point."""
    e = entry_point_direct(fib, p, search_bound=n_max)
    support = [n for n in range(1, n_max + 1) if fib(n) % p == 0]
    multiples = [n for n in range(1, n_max + 1) if e is not None and n % e == 0]
    print(f"\n=== Fibonacci support law at p = {p} (entry point e = {e}) ===")
    print(f"  support of {p}        : {support}")
    print(f"  multiples of e = {e}    : {multiples}")
    print(f"  match: {support == multiples}")


def demo_repunit_periods() -> None:
    """The order of 10 mod p is the period of the decimal expansion of 1/p."""
    print("\n=== Repunits: order of 10 mod p = period of 1/p = entry point of 10^n - 1 ===")
    print(f"{'p':>5} | {'order(10 mod p)':>16} | {'decimal period of 1/p':>22}")
    print("-" * 50)
    for p in [3, 7, 11, 13, 17, 19, 23, 29, 31]:
        if 10 % p == 0:
            continue
        order = multiplicative_order(10, p)
        # decimal period via long division
        seen: Dict[int, int] = {}
        r, pos = 1 % p, 0
        period = 0
        while r != 0 and r not in seen:
            seen[r] = pos
            r = (r * 10) % p
            pos += 1
        if r != 0:
            period = pos - seen[r]
        print(f"{p:>5} | {order!s:>16} | {period!s:>22}")


def main() -> None:
    print("#" * 78)
    print("# The Apparition-Order Bridge --- numerical demonstrations")
    print("#" * 78)

    primes = [p for p in range(3, 60) if is_prime(p)]

    demo_bridge_table(2, primes)
    demo_stalk_reduction(2, 7, n_max=20)
    demo_support_law(2, 7, n_max=40)
    demo_support_law(3, 13, n_max=40)
    demo_fibonacci_support(11, n_max=60)
    demo_fibonacci_support(7, n_max=60)
    demo_repunit_periods()

    print("\nAll demonstrations complete: the local order computation reproduces")
    print("every global rank-of-apparition fact, exactly as the Bridge predicts.")


if __name__ == "__main__":
    main()
