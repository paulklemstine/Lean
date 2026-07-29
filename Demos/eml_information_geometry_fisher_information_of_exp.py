#!/usr/bin/env python3
"""Numerical demonstrations for the normalized finite exp-log model.

The script uses only the Python standard library.  It demonstrates exact
scale cancellation up to floating-point roundoff, positivity and normalization,
the zero scale score, Fisher singularity, and a finite-difference check of the
shape score.
"""

from __future__ import annotations

from dataclasses import dataclass
from math import exp, isclose, log
from typing import Iterable, Sequence

Vector = list[float]
Matrix2 = tuple[tuple[float, float], tuple[float, float]]


def activations(xs: Sequence[float], b: float) -> Vector:
    """Return log(1 + b*x_i), requiring the logarithm arguments to be positive."""
    values: Vector = []
    for x in xs:
        argument = 1.0 + b * x
        if argument <= 0.0:
            raise ValueError(f"logarithm domain violation: 1 + b*x = {argument}")
        values.append(log(argument))
    return values


def activation_mass(xs: Sequence[float], b: float) -> float:
    """Return the total logarithmic activation."""
    return sum(activations(xs, b))


def raw_weights(xs: Sequence[float], a: float, b: float) -> Vector:
    """Return exp(a)*log(1+b*x_i); intended for moderate a values."""
    scale = exp(a)
    return [scale * value for value in activations(xs, b)]


def normalize(values: Sequence[float]) -> Vector:
    """Normalize a finite nonzero-mass vector."""
    total = sum(values)
    if total == 0.0:
        raise ValueError("cannot normalize a vector with zero total mass")
    return [value / total for value in values]


def probabilities(xs: Sequence[float], b: float) -> Vector:
    """Evaluate the scale-free normalized exp-log probabilities stably."""
    return normalize(activations(xs, b))


def probabilities_via_raw(xs: Sequence[float], a: float, b: float) -> Vector:
    """Evaluate probabilities through raw weights to exhibit cancellation."""
    return normalize(raw_weights(xs, a, b))


def scale_score(xs: Sequence[float], a: float, b: float) -> float:
    """Return 1-Z/Z, the normalized score in the common scale direction."""
    z = sum(raw_weights(xs, a, b))
    if z == 0.0:
        raise ValueError("partition function is zero")
    return 1.0 - z / z


def shape_scores(xs: Sequence[float], b: float) -> Vector:
    """Return the analytic b-scores d/db log p_i(b)."""
    acts = activations(xs, b)
    mass = sum(acts)
    if mass == 0.0 or any(value == 0.0 for value in acts):
        raise ValueError("shape score requires nonzero activations and mass")
    derivatives = [x / (1.0 + b * x) for x in xs]
    mass_derivative = sum(derivatives)
    return [
        derivative / activation - mass_derivative / mass
        for derivative, activation in zip(derivatives, acts)
    ]


def fisher_matrix(xs: Sequence[float], b: float) -> Matrix2:
    """Return the 2x2 Fisher matrix for coordinates (a,b)."""
    ps = probabilities(xs, b)
    sb = shape_scores(xs, b)
    information_bb = sum(p * score * score for p, score in zip(ps, sb))
    return ((0.0, 0.0), (0.0, information_bb))


def determinant_2x2(matrix: Matrix2) -> float:
    """Return the determinant of a 2x2 matrix."""
    return matrix[0][0] * matrix[1][1] - matrix[0][1] * matrix[1][0]


def finite_difference_shape_scores(
    xs: Sequence[float], b: float, step: float = 1e-6
) -> Vector:
    """Approximate d/db log p_i with a centered finite difference."""
    plus = probabilities(xs, b + step)
    minus = probabilities(xs, b - step)
    return [
        (log(p_plus) - log(p_minus)) / (2.0 * step)
        for p_plus, p_minus in zip(plus, minus)
    ]


def max_abs_difference(left: Sequence[float], right: Sequence[float]) -> float:
    """Return the maximum coordinatewise absolute difference."""
    if len(left) != len(right):
        raise ValueError("vectors must have equal length")
    return max((abs(x - y) for x, y in zip(left, right)), default=0.0)


@dataclass(frozen=True)
class DemoResult:
    """Summary of one scale-invariance comparison."""

    scale: float
    raw_mass: float
    maximum_probability_error: float


def scale_sweep(xs: Sequence[float], b: float, scales: Iterable[float]) -> list[DemoResult]:
    """Compare direct normalized raw weights against the scale-free formula."""
    reference = probabilities(xs, b)
    results: list[DemoResult] = []
    for a in scales:
        raw = raw_weights(xs, a, b)
        via_raw = normalize(raw)
        results.append(
            DemoResult(a, sum(raw), max_abs_difference(reference, via_raw))
        )
    return results


def run_demo() -> None:
    """Run three numerical demonstrations and assert their expected outcomes."""
    xs = [0.5, 1.0, 2.0, 4.0]
    b = 0.8
    ps = probabilities(xs, b)

    print("Normalized exp-log model")
    print(f"samples: {xs}")
    print(f"shape parameter b: {b}")
    print("probabilities:", [f"{p:.12f}" for p in ps])
    print(f"sum: {sum(ps):.16f}; minimum: {min(ps):.16f}")
    assert all(p > 0.0 for p in ps)
    assert isclose(sum(ps), 1.0, rel_tol=0.0, abs_tol=1e-14)

    print("\nScale-invariance sweep")
    for result in scale_sweep(xs, b, [-20.0, -5.0, 0.0, 5.0, 20.0]):
        print(
            f"a={result.scale:6.1f}  raw mass={result.raw_mass:14.6e}  "
            f"max |delta p|={result.maximum_probability_error:.3e}"
        )
        assert result.maximum_probability_error < 1e-14
        assert scale_score(xs, result.scale, b) == 0.0

    analytic = shape_scores(xs, b)
    numeric = finite_difference_shape_scores(xs, b)
    error = max_abs_difference(analytic, numeric)
    print("\nAnalytic shape scores:", [f"{s:.12f}" for s in analytic])
    print("Finite-difference scores:", [f"{s:.12f}" for s in numeric])
    print(f"maximum score error: {error:.3e}")
    assert error < 1e-8
    centered_mean = sum(p * s for p, s in zip(ps, analytic))
    print(f"probability-weighted score mean: {centered_mean:.3e}")
    assert abs(centered_mean) < 1e-14

    fisher = fisher_matrix(xs, b)
    determinant = determinant_2x2(fisher)
    print("\nFisher matrix:")
    print(f"[{fisher[0][0]:.12f}  {fisher[0][1]:.12f}]")
    print(f"[{fisher[1][0]:.12f}  {fisher[1][1]:.12f}]")
    print(f"determinant: {determinant:.12f}")
    print("quadratic form on v=(1,0): 0.000000000000")
    assert determinant == 0.0
    assert fisher[1][1] > 0.0


if __name__ == "__main__":
    run_demo()
