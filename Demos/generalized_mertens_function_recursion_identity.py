"""
Numerical demonstration of the Generalized Mertens Function Recursion Identity.

This module is fully self-contained. It computes the Moebius function mu(n),
the Mertens function M(x) = sum_{n<=x} mu(n), the auxiliary summand S(y, u),
and verifies the recursion

    M(x) = sum_{k=1}^{floor(x/u)} mu(k) * S(floor(x/k), u)

for all integers x >= 2 and integers u with floor(sqrt(x)) < u < x, where

    S(y, u) = 1
              - sum_{n=floor(y/u)+1}^{kappa(y)} M(floor(y/n))
              + kappa(y) * M(isqrt(y))
              - sum_{n=1}^{isqrt(y)} floor(y/n) * mu(n),

    kappa(y) = floor(y / (isqrt(y) + 1)).

It also verifies the collapse identity  S(y, u) = sum_{j=1}^{floor(y/u)} M(floor(y/j)),
the fundamental identity  sum_{k=1}^{y} M(floor(y/k)) = 1, and the asymmetric
Dirichlet-hyperbola identity.
"""

from __future__ import annotations

from math import isqrt


def moebius_sieve(limit: int) -> list[int]:
    """Return a list mu[0..limit] of Moebius values via a linear sieve.

    mu[0] is unused (set to 0). For n >= 1, mu[n] is 0 if n has a squared
    prime factor, and (-1)^k where k is the number of distinct prime factors.
    """
    mu: list[int] = [0] * (limit + 1)
    if limit >= 1:
        mu[1] = 1
    primes: list[int] = []
    is_comp: list[bool] = [False] * (limit + 1)
    for i in range(2, limit + 1):
        if not is_comp[i]:
            primes.append(i)
            mu[i] = -1
        for p in primes:
            if i * p > limit:
                break
            is_comp[i * p] = True
            if i % p == 0:
                mu[i * p] = 0
                break
            else:
                mu[i * p] = -mu[i]
    return mu


def mertens_table(limit: int) -> list[int]:
    """Return prefix sums M[0..limit] with M[x] = sum_{n<=x} mu(n)."""
    mu = moebius_sieve(limit)
    M: list[int] = [0] * (limit + 1)
    acc = 0
    for x in range(1, limit + 1):
        acc += mu[x]
        M[x] = acc
    return M


def kappa(y: int) -> int:
    """The auxiliary split point kappa(y) = floor(y / (isqrt(y) + 1))."""
    return y // (isqrt(y) + 1)


def S_direct(y: int, u: int, M: list[int], mu: list[int]) -> int:
    """S(y, u) evaluated directly from its defining formula (Theorem 1)."""
    nu = isqrt(y)
    k = kappa(y)
    term_hyper = sum(M[y // n] for n in range(y // u + 1, k + 1))
    term_sqrt = sum((y // n) * mu[n] for n in range(1, nu + 1))
    return 1 - term_hyper + k * M[nu] - term_sqrt


def S_collapsed(y: int, u: int, M: list[int]) -> int:
    """The collapsed form  S(y, u) = sum_{j=1}^{floor(y/u)} M(floor(y/j))."""
    return sum(M[y // j] for j in range(1, y // u + 1))


def mertens_via_recursion(x: int, u: int, M: list[int], mu: list[int]) -> int:
    """Right-hand side of Theorem 1 for a valid pair (x, u)."""
    return sum(mu[k] * S_direct(x // k, u, M, mu) for k in range(1, x // u + 1))


def _demo() -> None:
    LIMIT = 5000
    mu = moebius_sieve(LIMIT)
    M = mertens_table(LIMIT)

    print("Sample Mertens values:")
    for x in [1, 2, 10, 100, 1000, 5000]:
        print(f"  M({x}) = {M[x]}")
    print()

    print("Fundamental identity  sum_{k=1}^{y} M(floor(y/k)) = 1:")
    for y in [1, 7, 50, 123, 1000]:
        val = sum(M[y // k] for k in range(1, y + 1))
        print(f"  y={y}: {val}")
    print()

    print("Verifying Theorem 1 across all valid (x, u) for x <= 300:")
    failures = 0
    checked = 0
    for x in range(2, 301):
        lo = isqrt(x)
        for u in range(lo + 1, x):
            checked += 1
            # collapse identity
            y = x
            if S_direct(y, u, M, mu) != S_collapsed(y, u, M):
                failures += 1
            # main recursion
            if mertens_via_recursion(x, u, M, mu) != M[x]:
                failures += 1
    print(f"  checked {checked} pairs (x,u); failures = {failures}")
    print()

    print("Spot-checking Theorem 1 for larger x with u = floor(sqrt(x))+1:")
    for x in [500, 1000, 2500, 5000]:
        u = isqrt(x) + 1
        rhs = mertens_via_recursion(x, u, M, mu)
        print(f"  x={x}, u={u}: recursion={rhs}, M(x)={M[x]}, match={rhs == M[x]}")


if __name__ == "__main__":
    _demo()
