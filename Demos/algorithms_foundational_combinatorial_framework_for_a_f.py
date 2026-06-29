#!/usr/bin/env python3
"""
Algorithms for the Selberg Class Census framework.

Provides type-hinted implementations of:
1. Conductor counting with polynomial bounds
2. Spectral invariant computation
3. Factorization ordering and decomposition
4. Census enumeration
"""

from fractions import Fraction
from dataclasses import dataclass, field
from typing import List, Tuple, Iterator, Optional
from math import gcd
import heapq


@dataclass(frozen=True, order=True)
class SelbergDatum:
    """Invariant data (d, q, μ) of a Selberg class L-function.

    Attributes:
        d: degree (number of Gamma factors)
        q: conductor (positive integer)
        mu: spectral shift parameters (rational numbers, len = d)
    """
    d: int
    q: int
    mu: Tuple[Fraction, ...] = field(default_factory=tuple)

    def __post_init__(self):
        object.__setattr__(self, 'mu', tuple(self.mu))

    def spectral_complexity(self) -> Fraction:
        """C(σ) = d + Σ|μ_j|. Additive under products."""
        return Fraction(self.d) + sum(abs(m) for m in self.mu)

    def spectral_entropy(self) -> Fraction:
        """H(σ) = Σ(|num(μ_j)| + den(μ_j)). Additive under products."""
        return sum(
            Fraction(abs(m.numerator)) + Fraction(m.denominator)
            for m in self.mu
        )

    def dc_energy(self) -> int:
        """E(σ) = d · q. Strictly decreases under nontrivial factorization."""
        return self.d * self.q

    def filtration_level(self) -> int:
        """Maximum denominator among spectral parameters (or 1)."""
        if not self.mu:
            return 1
        return max((m.denominator for m in self.mu), default=1)

    def is_primitive(self) -> bool:
        """A datum is primitive iff d = 1."""
        return self.d == 1

    def product(self, other: "SelbergDatum") -> "SelbergDatum":
        """Rankin-Selberg product: degrees add, conductors multiply,
        spectral parameters concatenate."""
        return SelbergDatum(
            d=self.d + other.d,
            q=self.q * other.q,
            mu=self.mu + other.mu,
        )


def count_bounded_data(d: int, Q: int, B: int) -> int:
    """Count Selberg data with degree d, conductor ≤ Q, and spectral
    parameters with |numerator| ≤ B and 1 ≤ denominator ≤ B.

    Args:
        d: degree
        Q: conductor upper bound
        B: spectral parameter complexity bound

    Returns:
        N_d(Q, B) = Q · ((2B+1)·B)^d
    """
    return Q * ((2 * B + 1) * B) ** d


def poly_bound(d: int, Q: int, B: int) -> int:
    """Polynomial upper bound Q · ((2B+1)B)^d.
    Equals count_bounded_data by construction."""
    return Q * ((2 * B + 1) * B) ** d


def enumerate_data(d: int, Q: int, B: int) -> Iterator[SelbergDatum]:
    """Enumerate all Selberg data with fixed degree d, conductor ≤ Q,
    and bounded spectral parameters.

    Yields SelbergDatum objects in order of increasing conductor.
    """
    from itertools import product as cartesian

    param_space = [
        Fraction(a, b)
        for a in range(-B, B + 1)
        for b in range(1, B + 1)
    ]
    # Deduplicate (e.g., 2/4 = 1/2)
    param_space = sorted(set(param_space))

    for q in range(1, Q + 1):
        if d == 0:
            yield SelbergDatum(d=0, q=q, mu=())
        else:
            for params in cartesian(*([param_space] * d)):
                yield SelbergDatum(d=d, q=q, mu=params)


def selberg_lt(s1: SelbergDatum, s2: SelbergDatum) -> bool:
    """Factorization ordering: s1 < s2 iff d1 < d2, or d1=d2 and q1 < q2.
    This ordering is well-founded (proved formally)."""
    if s1.d < s2.d:
        return True
    if s1.d == s2.d and s1.q < s2.q:
        return True
    return False


def factorize_datum(sigma: SelbergDatum) -> List[SelbergDatum]:
    """Decompose a datum into primitive (degree-1) factors.

    Since the product concatenates spectral parameters, the factorization
    simply splits the parameter list into singletons.

    Returns:
        List of primitive data whose product equals sigma.
    """
    factors = []
    # We need to distribute the conductor among factors.
    # For the canonical decomposition, assign q to the first factor
    # and 1 to the rest (this is one valid factorization).
    for i, mu_i in enumerate(sigma.mu):
        factors.append(SelbergDatum(
            d=1,
            q=sigma.q if i == 0 else 1,
            mu=(mu_i,),
        ))
    return factors


def census_by_complexity(max_complexity: Fraction, B: int = 5) -> List[SelbergDatum]:
    """Find all Selberg data with spectral complexity ≤ max_complexity
    and bounded spectral parameters.

    Uses the polynomial bound to limit the search space.
    """
    results = []
    max_d = int(max_complexity)  # degree ≤ complexity

    for d in range(1, max_d + 1):
        # For each degree, enumerate data with small conductors
        # Complexity = d + sum|μ_j|, so sum|μ_j| ≤ max_complexity - d
        param_budget = max_complexity - d
        if param_budget < 0:
            continue

        for q in range(1, 100):  # conductor search limit
            for datum in _enumerate_params(d, q, B, param_budget):
                if datum.spectral_complexity() <= max_complexity:
                    results.append(datum)

    return sorted(results, key=lambda s: (float(s.spectral_complexity()), s.q))


def _enumerate_params(
    d: int, q: int, B: int, budget: Fraction
) -> Iterator[SelbergDatum]:
    """Helper: enumerate parameter vectors with sum of |μ_j| ≤ budget."""
    from itertools import product as cartesian

    params = [
        Fraction(a, b)
        for a in range(-B, B + 1)
        for b in range(1, B + 1)
        if abs(Fraction(a, b)) <= budget
    ]
    params = sorted(set(params))

    if d == 0:
        yield SelbergDatum(d=0, q=q, mu=())
        return

    if d == 1:
        for p in params:
            yield SelbergDatum(d=1, q=q, mu=(p,))
        return

    # For d > 1, use recursive pruning
    for p in params:
        remaining = budget - abs(p)
        if remaining < 0:
            continue
        for rest in _enumerate_params(d - 1, q, B, remaining):
            yield SelbergDatum(d=d, q=q, mu=(p,) + rest.mu)


if __name__ == "__main__":
    # Quick sanity checks
    zeta = SelbergDatum(d=1, q=1, mu=(Fraction(0),))
    print(f"Zeta: {zeta}")
    print(f"  Complexity: {zeta.spectral_complexity()}")
    print(f"  Entropy: {zeta.spectral_entropy()}")
    print(f"  Primitive: {zeta.is_primitive()}")

    print(f"\nCount N_1(100, 5) = {count_bounded_data(1, 100, 5)}")
    print(f"Count N_2(100, 5) = {count_bounded_data(2, 100, 5)}")

    print(f"\nCensus with complexity ≤ 2, B=1:")
    for s in census_by_complexity(Fraction(2), B=1):
        print(f"  {s} -> C={s.spectral_complexity()}")
