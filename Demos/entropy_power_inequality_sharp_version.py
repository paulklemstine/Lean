#!/usr/bin/env python3
"""Numerical demonstrations of the entropy-power/radius bridge.

The script uses only Python's standard library. It evaluates the sharp entropy
boundary stably, verifies the isotropic-Gaussian equality family, and checks the
exact entropy-excess/deficit identity across several dimensions.
"""

from __future__ import annotations

import math
from dataclasses import dataclass
from typing import Iterable

NORMALIZATION: float = 2.0 * math.pi * math.e


def require_dimension(n: int) -> None:
    """Raise ValueError unless n is a positive integer."""
    if n <= 0:
        raise ValueError("dimension n must be positive")


def entropy_power(n: int, entropy: float) -> float:
    """Return N_n(h) = exp(2h/n)/(2*pi*e)."""
    require_dimension(n)
    return math.exp(2.0 * entropy / n) / NORMALIZATION


def entropy_radius(n: int, entropy: float) -> float:
    """Return r_n(h) = exp(h/n)/sqrt(2*pi*e)."""
    require_dimension(n)
    return math.exp(entropy / n) / math.sqrt(NORMALIZATION)


def gaussian_entropy(n: int, variance: float) -> float:
    """Return the entropy of N(0, variance * I_n)."""
    require_dimension(n)
    if variance <= 0.0:
        raise ValueError("variance must be positive")
    return 0.5 * n * math.log(NORMALIZATION * variance)


def sharp_entropy_boundary(n: int, h_x: float, h_y: float) -> float:
    """Evaluate the two-input sharp boundary with log-sum-exp stabilization."""
    require_dimension(n)
    pivot = max(h_x, h_y)
    scaled_x = 2.0 * (h_x - pivot) / n
    scaled_y = 2.0 * (h_y - pivot) / n
    return pivot + 0.5 * n * math.log(math.exp(scaled_x) + math.exp(scaled_y))


def epi_deficit(n: int, h_x: float, h_y: float, h_sum: float) -> float:
    """Return N_n(h_sum) - N_n(h_x) - N_n(h_y)."""
    return entropy_power(n, h_sum) - entropy_power(n, h_x) - entropy_power(n, h_y)


def predicted_deficit(n: int, h_x: float, h_y: float, delta: float) -> float:
    """Return the exact deficit predicted for delta above the sharp boundary."""
    base_power = entropy_power(n, h_x) + entropy_power(n, h_y)
    return math.expm1(2.0 * delta / n) * base_power


def close(a: float, b: float, relative_tolerance: float = 1e-12) -> bool:
    """Scale-aware floating-point comparison."""
    return math.isclose(a, b, rel_tol=relative_tolerance, abs_tol=1e-12)


@dataclass(frozen=True)
class GaussianEqualityResult:
    """Numerical residuals for one isotropic-Gaussian equality experiment."""

    dimension: int
    variance_x: float
    variance_y: float
    power_residual: float
    radius_residual: float


def gaussian_equality_case(n: int, variance_x: float, variance_y: float) -> GaussianEqualityResult:
    """Compute residuals in the Gaussian power and Pythagorean identities."""
    h_x = gaussian_entropy(n, variance_x)
    h_y = gaussian_entropy(n, variance_y)
    h_sum = gaussian_entropy(n, variance_x + variance_y)
    p_x = entropy_power(n, h_x)
    p_y = entropy_power(n, h_y)
    p_sum = entropy_power(n, h_sum)
    r_x = entropy_radius(n, h_x)
    r_y = entropy_radius(n, h_y)
    r_sum = entropy_radius(n, h_sum)
    return GaussianEqualityResult(
        dimension=n,
        variance_x=variance_x,
        variance_y=variance_y,
        power_residual=p_sum - p_x - p_y,
        radius_residual=r_sum * r_sum - r_x * r_x - r_y * r_y,
    )


def demonstrate_power_radius_identity() -> None:
    """Print checks that entropy power equals squared entropy radius."""
    print("\n1. Entropy power is squared entropy radius")
    for n, h in ((1, -0.7), (2, 1.2), (10, 8.0), (100, 125.0)):
        power = entropy_power(n, h)
        radius_squared = entropy_radius(n, h) ** 2
        print(
            f"   n={n:3d}, h={h:7.2f}: N={power:.12g}, "
            f"r^2={radius_squared:.12g}, residual={power-radius_squared:+.3e}"
        )
        assert close(power, radius_squared)


def demonstrate_gaussian_equality() -> None:
    """Print equality residuals for isotropic Gaussians in several dimensions."""
    print("\n2. Sharp equality for isotropic Gaussians")
    cases: Iterable[tuple[int, float, float]] = (
        (1, 1.0, 4.0),
        (3, 0.25, 2.75),
        (20, 1.5, 6.25),
        (100, 0.1, 0.9),
    )
    for n, variance_x, variance_y in cases:
        result = gaussian_equality_case(n, variance_x, variance_y)
        print(
            f"   n={n:3d}, variances=({variance_x:g}, {variance_y:g}): "
            f"power residual={result.power_residual:+.3e}, "
            f"radius residual={result.radius_residual:+.3e}"
        )
        assert close(result.power_residual, 0.0)
        assert close(result.radius_residual, 0.0)


def demonstrate_boundary_and_stability() -> None:
    """Check boundary equality and the exact stability formula."""
    print("\n3. Sharp boundary and exact entropy-excess stability")
    h_x, h_y = 0.4, 1.7
    for n in (1, 2, 8, 32):
        boundary = sharp_entropy_boundary(n, h_x, h_y)
        boundary_deficit = epi_deficit(n, h_x, h_y, boundary)
        print(f"   n={n:2d}: boundary={boundary:.12g}, boundary deficit={boundary_deficit:+.3e}")
        assert close(boundary_deficit, 0.0)
        for delta in (0.05, 0.5, 2.0):
            observed = epi_deficit(n, h_x, h_y, boundary + delta)
            predicted = predicted_deficit(n, h_x, h_y, delta)
            print(
                f"      delta={delta:4.2f}: observed={observed:.12g}, "
                f"predicted={predicted:.12g}, residual={observed-predicted:+.3e}"
            )
            assert observed > 0.0
            assert close(observed, predicted)


def demonstrate_large_entropy_stability() -> None:
    """Show stable boundary evaluation for large entropies."""
    print("\n4. Stable log-sum-exp evaluation")
    n, h_x, h_y = 50, 10_000.0, 9_990.0
    boundary = sharp_entropy_boundary(n, h_x, h_y)
    print(
        f"   n={n}, h_x={h_x:g}, h_y={h_y:g}: "
        f"stable boundary={boundary:.12f}"
    )
    assert boundary > max(h_x, h_y)


def main() -> None:
    """Run every numerical demonstration."""
    print("Entropy Power Inequality: sharp scalar bridge demonstrations")
    demonstrate_power_radius_identity()
    demonstrate_gaussian_equality()
    demonstrate_boundary_and_stability()
    demonstrate_large_entropy_stability()
    print("\nAll numerical checks passed.")


if __name__ == "__main__":
    main()
