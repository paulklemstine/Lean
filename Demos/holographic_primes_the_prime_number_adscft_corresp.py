#!/usr/bin/env python3
"""Numerical demonstrations of finite prime holographic factorization.

The script uses only the Python standard library.  It compares the factored
boundary partition with direct bulk enumeration, displays the tropical
low-temperature limit, and separates occupation and prime cutoff effects.
"""

from __future__ import annotations

from itertools import product
from math import exp, log, prod
from typing import Iterable, Iterator, Sequence


def primes_below(limit: int) -> list[int]:
    """Return all primes strictly below ``limit`` by an Eratosthenes sieve."""
    if limit <= 2:
        return []
    sieve = bytearray(b"\x01") * limit
    sieve[0:2] = b"\x00\x00"
    for p in range(2, int((limit - 1) ** 0.5) + 1):
        if sieve[p]:
            sieve[p * p : limit : p] = b"\x00" * (((limit - 1 - p * p) // p) + 1)
    return [n for n in range(2, limit) if sieve[n]]


def occupation_profiles(mode_count: int, cutoff: int) -> Iterator[tuple[int, ...]]:
    """Generate every occupation vector with entries from zero through cutoff."""
    if mode_count < 0 or cutoff < 0:
        raise ValueError("mode_count and cutoff must be nonnegative")
    yield from product(range(cutoff + 1), repeat=mode_count)


def hamiltonian(primes: Sequence[int], occupations: Sequence[int]) -> float:
    """Compute H(a) = sum_p a_p log(p)."""
    if len(primes) != len(occupations):
        raise ValueError("primes and occupations must have equal length")
    return sum(a * log(p) for p, a in zip(primes, occupations))


def boundary_partition(primes: Sequence[int], cutoff: int, beta: float) -> float:
    """Evaluate the product of finite local prime partition sums."""
    if cutoff < 0:
        raise ValueError("cutoff must be nonnegative")
    return prod(sum(p ** (-beta * n) for n in range(cutoff + 1)) for p in primes)


def bulk_partition(primes: Sequence[int], cutoff: int, beta: float) -> float:
    """Evaluate the Gibbs sum by explicit occupation-lattice enumeration."""
    return sum(
        exp(-beta * hamiltonian(primes, profile))
        for profile in occupation_profiles(len(primes), cutoff)
    )


def finite_unrestricted_partition(primes: Sequence[int], beta: float) -> float:
    """Evaluate the finite-prime product with unrestricted occupations."""
    if beta <= 0:
        raise ValueError("beta must be positive for geometric convergence")
    return prod(1.0 / (1.0 - p ** (-beta)) for p in primes)


def occupation_ratio(primes: Sequence[int], cutoff: int, beta: float) -> float:
    """Return Z_(x,N)/Z_(x,infinity), isolating occupation truncation."""
    return prod(1.0 - p ** (-beta * (cutoff + 1)) for p in primes)


def tropical_proxy(partition: float, beta: float) -> float:
    """Return log(Z)/beta, which tends to the zero vacuum value here."""
    if partition <= 0 or beta <= 0:
        raise ValueError("partition and beta must be positive")
    return log(partition) / beta


def zeta_dirichlet(beta: float, terms: int = 500_000) -> float:
    """Approximate zeta(beta) by a Dirichlet sum plus an integral tail.

    The tail correction uses integral comparison at the endpoint.  This is a
    transparent numerical approximation, not an analytic-continuation method.
    """
    if beta <= 1:
        raise ValueError("this demonstration requires beta > 1")
    subtotal = sum(n ** (-beta) for n in range(1, terms + 1))
    return subtotal + terms ** (1.0 - beta) / (beta - 1.0)


def demonstrate_factorization() -> None:
    """Compare exact finite boundary and bulk organizations numerically."""
    primes = [2, 3, 5]
    cutoff = 3
    beta = 1.4
    boundary = boundary_partition(primes, cutoff, beta)
    bulk = bulk_partition(primes, cutoff, beta)
    print("FINITE HOLOGRAPHIC FACTORIZATION")
    print(f"primes={primes}, N={cutoff}, beta={beta}")
    print(f"boundary product : {boundary:.15f}")
    print(f"bulk Gibbs sum   : {bulk:.15f}")
    print(f"absolute residual: {abs(boundary - bulk):.3e}\n")


def demonstrate_tropical_limit() -> None:
    """Show normalized log partition approaching vacuum energy zero."""
    primes = [2, 3, 5, 7]
    cutoff = 2
    print("TROPICAL LOW-TEMPERATURE LIMIT")
    print("beta       Z(beta)          log(Z)/beta")
    for beta in (0.5, 1.0, 2.0, 4.0, 8.0, 16.0):
        z_value = boundary_partition(primes, cutoff, beta)
        print(f"{beta:4.1f}  {z_value:14.9f}  {tropical_proxy(z_value, beta):14.9f}")
    print("ground-state energy = 0\n")


def demonstrate_cutoffs() -> None:
    """Separate occupation truncation from the finite-prime approximation."""
    beta = 2.0
    print("CUTOFF DIAGNOSTICS AT beta=2")
    print("x    N    finite Z       occupation ratio")
    for limit in (6, 12, 30):
        primes = primes_below(limit)
        for cutoff in (1, 2, 5):
            z_value = boundary_partition(primes, cutoff, beta)
            ratio = occupation_ratio(primes, cutoff, beta)
            print(f"{limit:2d}   {cutoff:2d}   {z_value:12.9f}   {ratio:14.10f}")
    approximation = zeta_dirichlet(beta)
    print(f"\nDirichlet approximation to zeta(2): {approximation:.10f}")
    print(f"Known comparison pi^2/6 is not used by the computation.\n")


def main() -> None:
    demonstrate_factorization()
    demonstrate_tropical_limit()
    demonstrate_cutoffs()


if __name__ == "__main__":
    main()
