#!/usr/bin/env python3
"""Numerical demonstrations of additive generalization-complexity budgets.

The script uses only Python's standard library.  It evaluates certificate
inequalities, architecture-based sample thresholds, strict compression gains,
and invariance under increases in ambient parameter dimension.
"""

from __future__ import annotations

from dataclasses import dataclass
from math import ceil, log, sqrt
from typing import Iterable, Sequence


@dataclass(frozen=True)
class ComplexityProfile:
    """A numerical effective-complexity profile."""

    parameter_dimension: int
    quotient_complexity: int
    code_length: int
    posterior_kl: float
    sample_size: int

    def __post_init__(self) -> None:
        integer_values = (
            self.parameter_dimension,
            self.quotient_complexity,
            self.code_length,
            self.sample_size,
        )
        if any(value < 0 for value in integer_values):
            raise ValueError("Discrete profile quantities must be nonnegative.")
        if self.posterior_kl < 0:
            raise ValueError("Posterior KL divergence must be nonnegative.")

    @property
    def effective_complexity(self) -> float:
        return self.quotient_complexity + self.code_length + self.posterior_kl

    def overparameterized_by(self, extra_parameters: int) -> "ComplexityProfile":
        if extra_parameters < 0:
            raise ValueError("The number of added parameters must be nonnegative.")
        return ComplexityProfile(
            self.parameter_dimension + extra_parameters,
            self.quotient_complexity,
            self.code_length,
            self.posterior_kl,
            self.sample_size,
        )


@dataclass(frozen=True)
class ComplexityCertificate:
    """Separate structural and posterior upper bounds."""

    structural_budget: int
    posterior_budget: float

    @property
    def total_budget(self) -> float:
        return self.structural_budget + self.posterior_budget

    def certifies(self, profile: ComplexityProfile) -> bool:
        return (
            profile.quotient_complexity + profile.code_length
            <= self.structural_budget
            and profile.posterior_kl <= self.posterior_budget
        )


def complexity_radius(complexity: float, samples: int) -> float:
    """Return sqrt(complexity / samples) on its statistical domain."""
    if complexity < 0:
        raise ValueError("Complexity must be nonnegative.")
    if samples <= 0:
        raise ValueError("Sample size must be positive.")
    return sqrt(complexity / samples)


def generalizes_at_scale(
    profile: ComplexityProfile, epsilon: float, delta: float
) -> bool:
    """Evaluate the deterministic budget defining the requested scale."""
    return (
        epsilon > 0
        and delta > 0
        and profile.effective_complexity <= profile.sample_size * epsilon**2
    )


def certificate_generalizes(
    profile: ComplexityProfile,
    certificate: ComplexityCertificate,
    epsilon: float,
    delta: float,
) -> bool:
    """Check all component bounds and the total certificate budget."""
    return (
        certificate.certifies(profile)
        and epsilon > 0
        and delta > 0
        and certificate.total_budget <= profile.sample_size * epsilon**2
    )


def confidence_certificate_generalizes(
    profile: ComplexityProfile,
    certificate: ComplexityCertificate,
    epsilon: float,
    delta: float,
) -> bool:
    """Check the specialization using posterior budget log(1/delta)."""
    if not 0 < delta < 1 or epsilon <= 0:
        return False
    confidence_cost = log(1.0 / delta)
    return (
        certificate.certifies(profile)
        and certificate.posterior_budget <= confidence_cost
        and certificate.structural_budget + confidence_cost
        <= profile.sample_size * epsilon**2
    )


def structural_complexity(active_parameters: int, widths: Sequence[int]) -> int:
    """Compute active parameters plus the sum of layer widths."""
    if active_parameters < 0 or any(width < 0 for width in widths):
        raise ValueError("Architecture quantities must be nonnegative.")
    return active_parameters + sum(widths)


def required_samples(total_budget: float, epsilon: float) -> int:
    """Return ceil(total_budget / epsilon^2)."""
    if total_budget < 0:
        raise ValueError("The total budget must be nonnegative.")
    if epsilon <= 0:
        raise ValueError("Epsilon must be positive.")
    return ceil(total_budget / epsilon**2 - 1e-12)


def compare_compressions(complexities: Iterable[float], samples: int) -> list[tuple[float, float]]:
    """Return complexities and radii ordered from tightest to loosest."""
    pairs = [(value, complexity_radius(value, samples)) for value in complexities]
    return sorted(pairs, key=lambda pair: pair[0])


def demonstrate_certificate() -> None:
    profile = ComplexityProfile(1_000_000, 120, 180, 4.0, 10_000)
    certificate = ComplexityCertificate(300, 4.0)
    epsilon, delta = 0.2, 0.01
    print("1. Unified compression and posterior certificate")
    print(f"   effective complexity: {profile.effective_complexity:.3f}")
    print(f"   certificate total:    {certificate.total_budget:.3f}")
    print(f"   sample budget:        {profile.sample_size * epsilon**2:.3f}")
    print(f"   radius:               {complexity_radius(profile.effective_complexity, profile.sample_size):.6f}")
    print(f"   generic criterion:    {certificate_generalizes(profile, certificate, epsilon, delta)}")
    print(f"   confidence criterion: {confidence_certificate_generalizes(profile, certificate, epsilon, delta)}")


def demonstrate_architecture() -> None:
    widths = [100, 50, 10]
    active, posterior = 240, 90.0
    structural = structural_complexity(active, widths)
    total = structural + posterior
    epsilon = 0.35
    print("\n2. Retained architecture and sample complexity")
    print(f"   widths:               {widths}")
    print(f"   structural complexity:{structural:8d}")
    print(f"   total budget:         {total:8.3f}")
    print(f"   samples required at epsilon={epsilon}: {required_samples(total, epsilon)}")
    print(f"   radius at 4,000 samples: {complexity_radius(total, 4_000):.6f}")


def demonstrate_strict_compression() -> None:
    candidates = [1_000_000.0, 2_900.0, 490.0, 330.0]
    print("\n3. Strict compression gives a strictly tighter radius")
    for complexity, radius in compare_compressions(candidates, 50_000):
        print(f"   complexity {complexity:10.1f} -> radius {radius:.6f}")


def demonstrate_overparameterization() -> None:
    base = ComplexityProfile(750, 1, 0, 0.0, 1_000)
    epsilon, delta = 0.1, 0.05
    print("\n4. Ambient overparameterization invariance")
    for extra in [0, 1_000, 1_000_000]:
        enlarged = base.overparameterized_by(extra)
        print(
            f"   dimension {enlarged.parameter_dimension:9d}, "
            f"effective complexity {enlarged.effective_complexity:.1f}, "
            f"radius {complexity_radius(enlarged.effective_complexity, enlarged.sample_size):.6f}, "
            f"criterion {generalizes_at_scale(enlarged, epsilon, delta)}"
        )


def main() -> None:
    demonstrate_certificate()
    demonstrate_architecture()
    demonstrate_strict_compression()
    demonstrate_overparameterization()


if __name__ == "__main__":
    main()
