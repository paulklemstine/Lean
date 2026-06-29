"""Numerical demonstrations for the Korselt Units Bridge.

This script illustrates the divisibility heart of Korselt's criterion:

    If every unit u of Z/nZ satisfies u^(n-1) = 1, then for every prime
    p | n we have (p - 1) | (n - 1).

equivalently, a composite n is a Carmichael number iff n is squarefree and
(p - 1) | (n - 1) for every prime p | n.

The demos below:
  1. verify Korselt's criterion against a brute-force Carmichael test;
  2. witness the proof's descent step (orders modulo each prime factor);
  3. exhibit the maximal-order generator (primitive root) used in the proof;
  4. show that the exponent n-1 is incidental via the Carmichael function.

Self-contained: only the Python standard library is used.
"""

from __future__ import annotations

from math import gcd
from functools import reduce
from typing import Dict, List, Tuple


# --------------------------------------------------------------------------- #
# Basic number theory helpers (all inlined, no external dependencies).
# --------------------------------------------------------------------------- #

def is_prime(n: int) -> bool:
    """Deterministic trial-division primality test."""
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
    """Return the prime factorization of n as {prime: exponent}."""
    factors: Dict[int, int] = {}
    d = 2
    m = n
    while d * d <= m:
        while m % d == 0:
            factors[d] = factors.get(d, 0) + 1
            m //= d
        d += 1 if d == 2 else 2
    if m > 1:
        factors[m] = factors.get(m, 0) + 1
    return factors


def is_squarefree(n: int) -> bool:
    """True iff no prime divides n more than once."""
    return all(e == 1 for e in factorize(n).values())


def multiplicative_order(a: int, m: int) -> int:
    """Least k >= 1 with a^k ≡ 1 (mod m); assumes gcd(a, m) == 1."""
    if gcd(a, m) != 1:
        raise ValueError("multiplicative_order requires gcd(a, m) == 1")
    k = 1
    x = a % m
    while x != 1:
        x = (x * a) % m
        k += 1
    return k


def lcm(a: int, b: int) -> int:
    return a // gcd(a, b) * b


def carmichael_lambda_squarefree(n: int) -> int:
    """Carmichael function for squarefree n: lcm of (p - 1) over primes p | n."""
    primes = list(factorize(n).keys())
    return reduce(lcm, (p - 1 for p in primes), 1)


# --------------------------------------------------------------------------- #
# Carmichael / Korselt characterizations.
# --------------------------------------------------------------------------- #

def is_carmichael_bruteforce(n: int) -> bool:
    """Direct definition: composite n with a^(n-1) ≡ 1 (mod n) for all a coprime."""
    if n < 2 or is_prime(n):
        return False
    for a in range(1, n):
        if gcd(a, n) == 1 and pow(a, n - 1, n) != 1:
            return False
    return True


def is_korselt(n: int) -> bool:
    """Korselt's criterion: composite, squarefree, and (p-1)|(n-1) for all p|n."""
    if n < 2 or is_prime(n):
        return False
    if not is_squarefree(n):
        return False
    return all((p - 1) % 1 == 0 and (n - 1) % (p - 1) == 0
               for p in factorize(n).keys())


# --------------------------------------------------------------------------- #
# Demo 1 — Korselt's criterion matches the brute-force Carmichael test.
# --------------------------------------------------------------------------- #

def demo_korselt_matches_bruteforce(limit: int = 10000) -> List[int]:
    """List Carmichael numbers below `limit` two ways and check agreement."""
    print("=" * 70)
    print("DEMO 1 — Korselt's criterion == brute-force Carmichael test")
    print("=" * 70)
    carmichaels: List[int] = []
    for n in range(3, limit):
        bf = is_carmichael_bruteforce(n)
        ks = is_korselt(n)
        assert bf == ks, f"MISMATCH at n={n}: bruteforce={bf}, korselt={ks}"
        if bf:
            carmichaels.append(n)
    print(f"Carmichael numbers below {limit}: {carmichaels}")
    print("Both characterizations agree on every n in range. [OK]\n")
    return carmichaels


# --------------------------------------------------------------------------- #
# Demo 2 — Witness the descent step: (p-1) | (n-1) for each prime factor.
# --------------------------------------------------------------------------- #

def demo_divisibility_fingerprint(carmichaels: List[int]) -> None:
    """For each Carmichael number show (p-1) | (n-1) at every prime factor."""
    print("=" * 70)
    print("DEMO 2 — The fingerprint (p-1) | (n-1) on each prime factor")
    print("=" * 70)
    for n in carmichaels[:6]:
        primes = list(factorize(n).keys())
        parts = " * ".join(map(str, primes))
        print(f"n = {n} = {parts},   n-1 = {n - 1}")
        for p in primes:
            q, r = divmod(n - 1, p - 1)
            print(f"    p={p:>4}:  (p-1)={p - 1:>4}  divides  (n-1)={n - 1:>5}"
                  f"   ->  {n - 1} = {p - 1} * {q}   (remainder {r})")
        print()


# --------------------------------------------------------------------------- #
# Demo 3 — The maximal-order generator (primitive root) used in the proof.
# --------------------------------------------------------------------------- #

def primitive_root(p: int) -> int:
    """Return a primitive root g mod prime p, i.e. ord_p(g) = p - 1."""
    for g in range(2, p):
        if multiplicative_order(g, p) == p - 1:
            return g
    raise RuntimeError("no primitive root found (p must be prime)")


def demo_generator_realizes_order(carmichaels: List[int]) -> None:
    """Show a primitive root mod p has order p-1, which must divide n-1."""
    print("=" * 70)
    print("DEMO 3 — A primitive root realizes the extremal order p-1")
    print("=" * 70)
    for n in carmichaels[:4]:
        print(f"n = {n}")
        for p in factorize(n).keys():
            g = primitive_root(p)
            ordg = multiplicative_order(g, p)
            assert ordg == p - 1
            assert (n - 1) % ordg == 0
            print(f"    mod p={p:>4}: generator g={g}, ord={ordg}=p-1, "
                  f"and {ordg} | {n - 1}  [forces (p-1)|(n-1)]")
        print()


# --------------------------------------------------------------------------- #
# Demo 4 — The exponent n-1 is incidental: Carmichael function viewpoint.
# --------------------------------------------------------------------------- #

def demo_carmichael_function(carmichaels: List[int]) -> None:
    """Show n is Carmichael iff lambda(n) | (n-1), with lambda = lcm(p-1)."""
    print("=" * 70)
    print("DEMO 4 — The true invariant: lambda(n) = lcm(p-1) divides n-1")
    print("=" * 70)
    for n in carmichaels[:6]:
        lam = carmichael_lambda_squarefree(n)
        ok = (n - 1) % lam == 0
        primes = list(factorize(n).keys())
        print(f"n = {n}:  lambda(n) = lcm{tuple(p - 1 for p in primes)} = {lam}"
              f",  n-1 = {n - 1},  lambda | (n-1)? {ok}")
    print("\nA non-Carmichael composite for contrast:")
    for n in (15, 21, 35):
        lam = carmichael_lambda_squarefree(n)
        ok = (n - 1) % lam == 0
        print(f"n = {n}:  lambda(n) = {lam},  n-1 = {n - 1},  "
              f"lambda | (n-1)? {ok}  (so not Carmichael)")
    print()


def main() -> None:
    carmichaels = demo_korselt_matches_bruteforce(limit=10000)
    demo_divisibility_fingerprint(carmichaels)
    demo_generator_realizes_order(carmichaels)
    demo_carmichael_function(carmichaels)
    print("All demonstrations completed successfully.")


if __name__ == "__main__":
    main()
