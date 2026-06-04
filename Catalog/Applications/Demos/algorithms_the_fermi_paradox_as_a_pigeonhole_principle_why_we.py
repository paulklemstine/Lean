#!/usr/bin/env python3
"""
Sparse Occupation Theory — Core Algorithms

Type-hinted implementations of the mathematical framework
for sparse occupation systems and Drake equation analysis.
"""

from __future__ import annotations
import math
from dataclasses import dataclass


@dataclass
class DrakeSystem:
    """
    A Drake system of order k with probability factors in [0, 1].

    The per-star probability is the product of all factors.
    The expected number of civilizations is n * per_star_prob.
    """
    factors: list[float]

    def __post_init__(self) -> None:
        for i, f in enumerate(self.factors):
            assert 0 <= f <= 1, f"Factor {i} = {f} not in [0, 1]"

    @property
    def k(self) -> int:
        """Number of factors."""
        return len(self.factors)

    def per_star_prob(self) -> float:
        """Product of all Drake factors."""
        result = 1.0
        for f in self.factors:
            result *= f
        return result

    def expected_civs(self, n: int | float) -> float:
        """Expected number of civilizations with n candidate sites."""
        return n * self.per_star_prob()

    def bottleneck_index(self) -> int:
        """Index of the smallest (bottleneck) factor."""
        return min(range(self.k), key=lambda i: self.factors[i])

    def bottleneck_value(self) -> float:
        """Value of the smallest (bottleneck) factor."""
        return self.factors[self.bottleneck_index()]

    def is_single_bottleneck_sparse(self, n: int | float) -> tuple[bool, int | None]:
        """
        Check if a single factor forces sparsity (factor < 1/n).
        Returns (is_sparse, bottleneck_index_or_None).
        """
        threshold = 1.0 / n
        for i, f in enumerate(self.factors):
            if f < threshold:
                return True, i
        return False, None


@dataclass
class SparseOccupation:
    """
    A Sparse Occupation System with n slots and occupation probability p.

    Models the regime where expected occupancy np may be < 1 (sparse regime),
    making silence the likely outcome.
    """
    num_slots: int
    occ_prob: float

    def __post_init__(self) -> None:
        assert self.num_slots >= 0, "Number of slots must be non-negative"
        assert 0 <= self.occ_prob <= 1, f"Probability {self.occ_prob} not in [0, 1]"

    def expected_occ(self) -> float:
        """Expected number of occupied slots: λ = np."""
        return self.num_slots * self.occ_prob

    def silence_prob(self) -> float:
        """Silence probability: (1-p)^n."""
        return (1 - self.occ_prob) ** self.num_slots

    def contact_prob(self) -> float:
        """Contact probability: 1 - (1-p)^n."""
        return 1 - self.silence_prob()

    def is_sparse(self) -> bool:
        """Whether the system is in the sparse regime (λ < 1)."""
        return self.expected_occ() < 1

    def bernoulli_lower_bound(self) -> float:
        """Bernoulli lower bound on silence probability: 1 - np."""
        return 1 - self.expected_occ()

    def poisson_approximation(self) -> float:
        """Poisson approximation to silence probability: e^{-λ}."""
        return math.exp(-self.expected_occ())

    @classmethod
    def from_drake(cls, drake: DrakeSystem, n: int) -> SparseOccupation:
        """Construct a SparseOccupation from a Drake system with n sites."""
        return cls(num_slots=n, occ_prob=drake.per_star_prob())


def birthday_no_collision_prob(n: int, k: int) -> float:
    """
    Probability of no collision when placing k items into n slots.

    P(no collision) = ∏_{i=0}^{k-1} (1 - i/n)

    This is the quantitative anti-pigeonhole: when k << √n,
    collisions are unlikely.
    """
    assert 0 < n, "Number of slots must be positive"
    assert 0 <= k <= n, f"k={k} must be in [0, n={n}]"
    prob = 1.0
    for i in range(k):
        prob *= (1 - i / n)
    return prob


def critical_drake_factor(n: int | float, k: int) -> float:
    """
    Critical value of identical Drake factors for silence threshold.

    If all k factors equal f, silence occurs when n * f^k < 1,
    i.e., f < n^{-1/k}.

    Returns the critical factor value f_c = n^{-1/k}.
    """
    return n ** (-1.0 / k)


def silence_region_volume(n: int | float, k: int) -> float:
    """
    Volume of the silence region in [0,1]^k.

    The silence region is {f ∈ [0,1]^k : n * ∏f_i < 1}.
    Its volume relative to [0,1]^k represents the "probability"
    that random Drake factors produce silence.

    For large n, this volume approaches 1 (most parameter choices
    lead to silence).

    Computed via integration: Vol = ∫...∫_{∏f_i < 1/n} df_1...df_k
    = 1 - (1/n) * (log(n))^{k-1} / (k-1)! + higher order terms
    ≈ 1 for large n.
    """
    threshold = 1.0 / n
    if threshold >= 1:
        return 0.0  # Everything is in contact region

    # Exact computation for uniform distribution on [0,1]^k:
    # P(∏ U_i > t) = t * ∑_{j=0}^{k-1} (-log t)^j / j!
    # P(∏ U_i < t) = 1 - above
    log_t = -math.log(threshold)  # = log(n)
    survival = threshold
    factorial = 1.0
    power = 1.0
    total = 0.0
    for j in range(k):
        total += power / factorial
        power *= log_t
        factorial *= (j + 1)
    survival *= total
    return 1 - survival


if __name__ == "__main__":
    # Example usage
    drake = DrakeSystem([0.5, 0.01, 0.01, 0.01, 0.01])
    print(f"Drake per-star prob: {drake.per_star_prob():.2e}")
    print(f"Bottleneck: factor {drake.bottleneck_index()} = {drake.bottleneck_value()}")

    n = 10**10
    sos = SparseOccupation.from_drake(drake, n)
    print(f"Expected occupancy: {sos.expected_occ():.2e}")
    print(f"Is sparse: {sos.is_sparse()}")
    print(f"Silence probability: {sos.silence_prob():.10f}")
    print(f"Bernoulli lower bound: {sos.bernoulli_lower_bound():.10f}")
    print(f"Poisson approximation: {sos.poisson_approximation():.10f}")

    print(f"\nCritical Drake factor (k=7, n=1e10): {critical_drake_factor(1e10, 7):.6f}")
    print(f"Silence region volume (k=7, n=1e10): {silence_region_volume(1e10, 7):.10f}")
