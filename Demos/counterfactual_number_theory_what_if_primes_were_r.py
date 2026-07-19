#!/usr/bin/env python3
"""Numerical illustrations for counterfactual prime models.

The script demonstrates finite shadows of three rigorous phenomena:
(1) growth of Cramér-density partial sums;
(2) independent Bernoulli selections with prime-like probabilities; and
(3) irreducibility and nonunique factorization in the monoid n ≡ 1 (mod 4).
Finite computation illustrates but does not prove infinite or almost-sure claims.
"""

from __future__ import annotations

import argparse
import math
import random
from dataclasses import dataclass
from typing import Iterable, Sequence


def cramer_probability(candidate: int) -> float:
    """Return min(1, 1/log(candidate)), a valid simulation probability."""
    if candidate < 2:
        raise ValueError("candidate must be at least 2")
    return min(1.0, 1.0 / math.log(candidate))


def cramer_partial_sum(terms: int, q: int = 1, a: int = 0) -> float:
    """Compute sum_{n < terms} 1/log(q*n+a+2)."""
    if terms < 0:
        raise ValueError("terms must be nonnegative")
    if q <= 0 or a < 0:
        raise ValueError("require q > 0 and a >= 0")
    return math.fsum(1.0 / math.log(q * n + a + 2) for n in range(terms))


def density_table(cutoffs: Iterable[int], q: int = 1, a: int = 0) -> list[tuple[int, float]]:
    """Return partial density sums at specified positive cutoffs."""
    table: list[tuple[int, float]] = []
    for cutoff in cutoffs:
        if cutoff <= 0:
            raise ValueError("cutoffs must be positive")
        table.append((cutoff, cramer_partial_sum(cutoff, q, a)))
    return table


def sample_random_primes(limit: int, seed: int, q: int = 1, a: int = 0) -> list[int]:
    """Sample candidates q*n+a+2 independently for 0 <= n < limit."""
    if limit < 0 or q <= 0 or a < 0:
        raise ValueError("require limit >= 0, q > 0, and a >= 0")
    rng = random.Random(seed)
    selected: list[int] = []
    for n in range(limit):
        candidate = q * n + a + 2
        if rng.random() < cramer_probability(candidate):
            selected.append(candidate)
    return selected


def in_hilbert_monoid(n: int) -> bool:
    """Return whether n belongs to H = {n in N : n ≡ 1 (mod 4)}."""
    return n >= 0 and n % 4 == 1


def hilbert_factor_pairs(n: int) -> list[tuple[int, int]]:
    """List unordered nonunit factorizations n=a*b with a,b in H."""
    if n < 1:
        return []
    pairs: list[tuple[int, int]] = []
    for a in range(5, math.isqrt(n) + 1, 4):
        if n % a == 0:
            b = n // a
            if in_hilbert_monoid(b):
                pairs.append((a, b))
    return pairs


def is_hilbert_prime(n: int) -> bool:
    """Test irreducibility among natural numbers congruent to 1 modulo 4."""
    return n >= 2 and in_hilbert_monoid(n) and not hilbert_factor_pairs(n)


def hilbert_primes_up_to(bound: int) -> list[int]:
    """Enumerate Hilbert primes not exceeding bound by trial division."""
    if bound < 0:
        raise ValueError("bound must be nonnegative")
    return [n for n in range(5, bound + 1, 4) if is_hilbert_prime(n)]


@dataclass(frozen=True)
class FactorizationWitness:
    """A product and two distinct Hilbert-prime factor lists."""

    value: int
    left: tuple[int, ...]
    right: tuple[int, ...]

    def is_valid(self) -> bool:
        """Check products, irreducibility, and distinction of multisets."""
        return (
            math.prod(self.left) == self.value
            and math.prod(self.right) == self.value
            and all(is_hilbert_prime(x) for x in self.left + self.right)
            and sorted(self.left) != sorted(self.right)
        )


def print_density_demo(cutoffs: Sequence[int]) -> None:
    """Print full-sequence and arithmetic-progression partial sums."""
    print("\nCramér-density partial sums")
    print(" cutoff | full sequence | progression 4n+1 (candidate 4n+3)")
    print("--------+---------------+----------------------------------")
    full = density_table(cutoffs)
    progression = density_table(cutoffs, q=4, a=1)
    for (n, total), (_, prog_total) in zip(full, progression):
        print(f"{n:7d} | {total:13.6f} | {prog_total:32.6f}")


def print_random_demo(limit: int, seeds: Sequence[int]) -> None:
    """Print counts and initial selections from independent trials."""
    print("\nIndependent prime-like selections")
    expected = math.fsum(cramer_probability(n + 2) for n in range(limit))
    print(f"candidates per trial: {limit}; expected count: {expected:.3f}")
    for seed in seeds:
        selected = sample_random_primes(limit, seed)
        preview = ", ".join(map(str, selected[:12]))
        suffix = ", ..." if len(selected) > 12 else ""
        print(f"seed {seed:3d}: count={len(selected):4d}; first selections: {preview}{suffix}")


def print_factorization_demo(bound: int) -> None:
    """Print Hilbert primes and verify the 441 nonuniqueness witness."""
    primes = hilbert_primes_up_to(bound)
    witness = FactorizationWitness(441, (9, 49), (21, 21))
    print("\nHilbert multiplicative universe H = {n : n ≡ 1 mod 4}")
    print(f"Hilbert primes up to {bound}: {primes}")
    print(f"9 prime in H: {is_hilbert_prime(9)}")
    print(f"21 prime in H: {is_hilbert_prime(21)}")
    print(f"49 prime in H: {is_hilbert_prime(49)}")
    print("441 = 9 × 49 = 21 × 21")
    print(f"distinct irreducible factorizations verified: {witness.is_valid()}")


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--limit", type=int, default=10_000, help="number of random candidates")
    parser.add_argument("--hilbert-bound", type=int, default=100, help="Hilbert-prime search bound")
    args = parser.parse_args()

    print_density_demo((10, 100, 1_000, 10_000))
    print_random_demo(args.limit, (7, 19, 41))
    print_factorization_demo(args.hilbert_bound)


if __name__ == "__main__":
    main()
