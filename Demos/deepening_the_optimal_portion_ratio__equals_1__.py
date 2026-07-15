#!/usr/bin/env python3
"""Numerical demonstrations of the cake–plastic spectral bridge.

The script uses only the Python standard library. It computes the unique root
rho in (0, 1) of rho^3 + rho^2 = 1, derives the plastic number p = 1/rho and
the portion constant mu = 1 + rho, checks mu = p^2, verifies the Padovan
matrix eigenpair, and displays a Padovan recurrence experiment.
"""

from __future__ import annotations

from dataclasses import dataclass
from math import isclose
from typing import Iterable, Sequence, Tuple

Vector3 = Tuple[float, float, float]
Matrix3 = Tuple[Vector3, Vector3, Vector3]

PADOVAN_MATRIX: Matrix3 = (
    (0.0, 1.0, 0.0),
    (0.0, 0.0, 1.0),
    (1.0, 1.0, 0.0),
)


@dataclass(frozen=True)
class Constants:
    """Numerical values of the three equivalent algebraic scales."""

    rho: float
    plastic: float
    portion_ratio: float


def cake_polynomial(x: float) -> float:
    """Return x^3 + x^2."""
    return x * x * x + x * x


def compute_rho(iterations: int = 80) -> float:
    """Find rho by bisection on [0, 1].

    Since x^3 + x^2 is strictly increasing on the interval and crosses 1,
    each iteration halves a certified bracket containing the root.
    """
    if iterations < 1:
        raise ValueError("iterations must be positive")
    lower, upper = 0.0, 1.0
    for _ in range(iterations):
        midpoint = (lower + upper) / 2.0
        if cake_polynomial(midpoint) < 1.0:
            lower = midpoint
        else:
            upper = midpoint
    return (lower + upper) / 2.0


def derive_constants(iterations: int = 80) -> Constants:
    """Compute rho, p = 1/rho, and mu = 1 + rho."""
    rho = compute_rho(iterations)
    return Constants(rho=rho, plastic=1.0 / rho, portion_ratio=1.0 + rho)


def mat_vec(matrix: Matrix3, vector: Vector3) -> Vector3:
    """Multiply a 3-by-3 matrix by a length-three vector."""
    return tuple(
        sum(matrix[row][column] * vector[column] for column in range(3))
        for row in range(3)
    )  # type: ignore[return-value]


def scale_vector(scale: float, vector: Vector3) -> Vector3:
    """Multiply all coordinates of a vector by a scalar."""
    return tuple(scale * value for value in vector)  # type: ignore[return-value]


def max_abs_difference(left: Sequence[float], right: Sequence[float]) -> float:
    """Return the infinity-norm distance between equal-length vectors."""
    if len(left) != len(right):
        raise ValueError("vectors must have equal length")
    return max(abs(a - b) for a, b in zip(left, right))


def padovan_terms(count: int, initial: Vector3 = (1.0, 1.0, 1.0)) -> list[float]:
    """Generate terms satisfying a_(n+3) = a_(n+1) + a_n."""
    if count < 0:
        raise ValueError("count must be nonnegative")
    terms = list(initial[:count])
    while len(terms) < count:
        terms.append(terms[-2] + terms[-3])
    return terms


def successive_ratios(values: Iterable[float]) -> list[float]:
    """Compute a_(n+1)/a_n wherever the denominator is nonzero."""
    data = list(values)
    return [b / a for a, b in zip(data, data[1:]) if a != 0.0]


def print_report() -> None:
    """Run all demonstrations and print a readable numerical report."""
    constants = derive_constants()
    rho, p, mu = constants.rho, constants.plastic, constants.portion_ratio
    profile: Vector3 = (1.0, p, p * p)
    image = mat_vec(PADOVAN_MATRIX, profile)
    scaled = scale_vector(p, profile)
    residual = max_abs_difference(image, scaled)

    print("CAKE–PLASTIC SPECTRAL BRIDGE")
    print("=" * 38)
    print(f"rho (cake scale)       = {rho:.15f}")
    print(f"p   (plastic number)   = {p:.15f}")
    print(f"mu  (portion constant) = {mu:.15f}")
    print()
    print("Algebraic residuals")
    print(f"|rho^3 + rho^2 - 1| = {abs(cake_polynomial(rho) - 1.0):.3e}")
    print(f"|p^3 - p - 1|       = {abs(p**3 - p - 1.0):.3e}")
    print(f"|mu - p^2|          = {abs(mu - p * p):.3e}")
    print()
    print("Positive Padovan eigenpair")
    print(f"v     = {profile}")
    print(f"A v   = {image}")
    print(f"p v   = {scaled}")
    print(f"max coordinate residual = {residual:.3e}")
    print()

    terms = padovan_terms(24)
    ratios = successive_ratios(terms)
    print("Padovan recurrence from (1, 1, 1)")
    print("terms:", ", ".join(f"{term:g}" for term in terms[:15]), "...")
    print("last five successive ratios:")
    for ratio in ratios[-5:]:
        print(f"  {ratio:.12f}  (difference from p: {ratio - p:+.3e})")

    assert 0.0 < rho < 1.0
    assert 1.0 < p < 2.0
    assert 1.0 < mu < 2.0
    assert all(coordinate > 0.0 for coordinate in profile)
    assert isclose(mu, p * p, rel_tol=1e-14, abs_tol=1e-14)
    assert residual < 1e-13


if __name__ == "__main__":
    print_report()
