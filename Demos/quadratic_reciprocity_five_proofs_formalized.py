"""
Numerical demonstrations for "Quadratic Reciprocity Through Five Windows".

This self-contained script verifies, over many primes:

  * Euler's criterion for the Legendre symbol,
  * the first supplementary law   (-1/p) = (-1)^((p-1)/2),
  * the second supplementary law  ( 2/p) = (-1)^((p^2-1)/8),
  * Gauss's lemma count for a = 2 equals  floor(p/2) - floor(p/4),
  * the parity identity           (floor(p/2)-floor(p/4)) == (p^2-1)/8  (mod 2),
  * the main Law of Quadratic Reciprocity,
  * a fast (factorization-free) Jacobi-symbol evaluator.

Run:  python demo.py
"""

from __future__ import annotations

from typing import List


# --------------------------------------------------------------------------
# Basic number theory helpers
# --------------------------------------------------------------------------
def is_prime(n: int) -> bool:
    """Deterministic trial-division primality test."""
    if n < 2:
        return False
    i = 2
    while i * i <= n:
        if n % i == 0:
            return False
        i += 1
    return True


def primes_up_to(limit: int) -> List[int]:
    """All primes p with 2 <= p <= limit."""
    return [n for n in range(2, limit + 1) if is_prime(n)]


def legendre_symbol_bruteforce(a: int, p: int) -> int:
    """Legendre symbol (a/p) computed directly from the definition."""
    a %= p
    if a == 0:
        return 0
    squares = {(x * x) % p for x in range(1, p)}
    return 1 if a in squares else -1


def legendre_symbol_euler(a: int, p: int) -> int:
    """Legendre symbol (a/p) via Euler's criterion  a^((p-1)/2) mod p."""
    a %= p
    if a == 0:
        return 0
    r = pow(a, (p - 1) // 2, p)
    return 1 if r == 1 else -1  # r is p-1 for non-residues


def gauss_lemma_count(a: int, p: int) -> int:
    """Number of x in [1,(p-1)//2] with (a*x mod p) > p/2 (Gauss's lemma mu)."""
    half = (p - 1) // 2
    return sum(1 for x in range(1, half + 1) if (a * x) % p > p / 2)


# --------------------------------------------------------------------------
# Fast, factorization-free Jacobi symbol (uses reciprocity + supplements)
# --------------------------------------------------------------------------
def jacobi_symbol(a: int, n: int) -> int:
    """Jacobi symbol (a/n) for odd n > 0, in O(log^2 n) bit operations."""
    if n <= 0 or n % 2 == 0:
        raise ValueError("n must be a positive odd integer")
    a %= n
    result = 1
    while a != 0:
        while a % 2 == 0:  # second supplement strips factors of 2
            a //= 2
            if n % 8 in (3, 5):
                result = -result
        a, n = n, a  # reciprocity swap
        if a % 4 == 3 and n % 4 == 3:
            result = -result
        a %= n
    return result if n == 1 else 0


# --------------------------------------------------------------------------
# Demonstrations
# --------------------------------------------------------------------------
def demo_euler(primes: List[int]) -> None:
    print("== Euler's criterion vs. brute force ==")
    ok = all(
        legendre_symbol_euler(a, p) == legendre_symbol_bruteforce(a, p)
        for p in primes if p != 2
        for a in range(1, p)
    )
    print(f"  agreement over all a mod p for {len(primes)} primes: {ok}")


def demo_first_supplement(primes: List[int]) -> None:
    print("== First supplement  (-1/p) = (-1)^((p-1)/2) ==")
    for p in primes[:10]:
        if p == 2:
            continue
        lhs = legendre_symbol_bruteforce(-1, p)
        rhs = (-1) ** ((p - 1) // 2)
        residue = "square" if lhs == 1 else "non-square"
        print(f"  p={p:3d}:  (-1/p)={lhs:+d}  formula={rhs:+d}  "
              f"[-1 is a {residue} mod p;  p mod 4 = {p % 4}]")


def demo_second_supplement(primes: List[int]) -> None:
    print("== Second supplement  (2/p) = (-1)^((p^2-1)/8) ==")
    for p in primes[:10]:
        if p == 2:
            continue
        lhs = legendre_symbol_bruteforce(2, p)
        rhs = (-1) ** ((p * p - 1) // 8)
        mu = gauss_lemma_count(2, p)
        count = p // 2 - p // 4
        assert mu == count, (p, mu, count)
        assert (mu % 2) == (((p * p - 1) // 8) % 2)
        print(f"  p={p:3d}:  (2/p)={lhs:+d}  formula={rhs:+d}  "
              f"mu={mu}=floor(p/2)-floor(p/4)  [p mod 8 = {p % 8}]")


def demo_reciprocity(primes: List[int]) -> None:
    print("== Law of Quadratic Reciprocity ==")
    odd = [p for p in primes if p != 2]
    ok = True
    for p in odd:
        for q in odd:
            if p == q:
                continue
            lhs = legendre_symbol_bruteforce(p, q) * legendre_symbol_bruteforce(q, p)
            rhs = (-1) ** (((p - 1) // 2) * ((q - 1) // 2))
            if lhs != rhs:
                ok = False
    print(f"  (p/q)(q/p) = (-1)^(...) holds for all odd prime pairs up to "
          f"{odd[-1]}: {ok}")


def demo_jacobi(primes: List[int]) -> None:
    print("== Fast Jacobi symbol vs. Legendre (on primes) ==")
    ok = all(
        jacobi_symbol(a, p) == legendre_symbol_bruteforce(a, p)
        for p in primes if p != 2
        for a in range(1, p)
    )
    print(f"  fast Jacobi matches Legendre for all a mod p: {ok}")
    print(f"  example: (1001 / 9907) = {jacobi_symbol(1001, 9907)}")


def main() -> None:
    primes = primes_up_to(60)
    demo_euler(primes)
    print()
    demo_first_supplement(primes)
    print()
    demo_second_supplement(primes)
    print()
    demo_reciprocity(primes)
    print()
    demo_jacobi(primes)


if __name__ == "__main__":
    main()
