#!/usr/bin/env python3
"""Numerical demonstrations for exponential--logarithmic interpolation theory.

The script uses only the Python standard library.  It demonstrates:
1. constructive separation of distinct scalars and vectors;
2. exact width accounting for the square expression with zero padding;
3. the shifted exp--log square and its certified uniform error bound.
"""

from __future__ import annotations

from dataclasses import dataclass
from math import exp, log
from typing import Callable, Sequence


@dataclass(frozen=True)
class SeparationResult:
    """Parameters and outputs for a scalar exp--log separator."""

    a: float
    b: float
    c: float
    value_x: float
    value_y: float


def log_feature(a: float, b: float, c: float, t: float) -> float:
    """Evaluate exp(a) * log(b*t+c), requiring a positive log argument."""
    argument = b * t + c
    if argument <= 0.0:
        raise ValueError("The logarithm argument must be positive.")
    return exp(a) * log(argument)


def separate_scalars(x: float, y: float) -> SeparationResult:
    """Construct parameters that separate two distinct real numbers."""
    if x == y:
        raise ValueError("Separation requires distinct inputs.")
    a, b, c = 0.0, 1.0, abs(x) + abs(y) + 1.0
    return SeparationResult(
        a=a,
        b=b,
        c=c,
        value_x=log_feature(a, b, c, x),
        value_y=log_feature(a, b, c, y),
    )


def separate_vectors(
    x: Sequence[float], y: Sequence[float]
) -> tuple[int, SeparationResult]:
    """Find a differing coordinate and construct a scalar separator there."""
    if len(x) != len(y):
        raise ValueError("Vectors must have the same dimension.")
    for index, (x_i, y_i) in enumerate(zip(x, y)):
        if x_i != y_i:
            return index, separate_scalars(x_i, y_i)
    raise ValueError("Separation requires distinct vectors.")


def shifted_exp_log_square(x: float, delta: float) -> float:
    """Evaluate exp(2*log(x+delta)) on its positive domain."""
    if delta <= 0.0:
        raise ValueError("delta must be positive.")
    if x + delta <= 0.0:
        raise ValueError("x + delta must be positive.")
    return exp(2.0 * log(x + delta))


def square_error_bound(delta: float) -> float:
    """Return the certified [0,1] uniform error bound 2*delta+delta^2."""
    if delta <= 0.0:
        raise ValueError("delta must be positive.")
    return 2.0 * delta + delta * delta


def choose_delta(epsilon: float) -> float:
    """Choose delta with 0 < delta <= 1 and 3*delta <= epsilon."""
    if epsilon <= 0.0:
        raise ValueError("epsilon must be positive.")
    return min(0.5, epsilon / 3.0)


def max_sampled_error(
    approximation: Callable[[float], float], samples: int = 10_001
) -> tuple[float, float]:
    """Return (maximum sampled error, its location) against x^2 on [0,1]."""
    if samples < 2:
        raise ValueError("At least two samples are required.")
    maximum, argmax = -1.0, 0.0
    for k in range(samples):
        x = k / (samples - 1)
        error = abs(approximation(x) - x * x)
        if error > maximum:
            maximum, argmax = error, x
    return maximum, argmax


def padded_square_width(requested_width: int) -> int:
    """Model zero padding: x*x has width 2 and each added zero adds one leaf."""
    if requested_width < 2:
        raise ValueError("An exact square requires requested width at least 2.")
    base_width = 2
    zero_leaves = requested_width - base_width
    return base_width + zero_leaves


def run_demo() -> None:
    """Print reproducible numerical examples and compare them with exact bounds."""
    print("EML INTERPOLATION THEORY: NUMERICAL DEMONSTRATIONS")
    print("=" * 62)

    x, y = -2.75, 1.5
    scalar = separate_scalars(x, y)
    print("\n1. Constructive scalar separation")
    print(f"   inputs: x={x}, y={y}")
    print(f"   parameters: a={scalar.a}, b={scalar.b}, c={scalar.c}")
    print(f"   positive arguments: {x + scalar.c:.6f}, {y + scalar.c:.6f}")
    print(f"   feature values: {scalar.value_x:.12f}, {scalar.value_y:.12f}")
    print(f"   separated: {scalar.value_x != scalar.value_y}")

    vector_x = (0.25, -3.0, 7.0)
    vector_y = (0.25, -3.0, 8.5)
    index, vector_result = separate_vectors(vector_x, vector_y)
    print("\n2. Coordinatewise vector separation")
    print(f"   vectors: {vector_x} and {vector_y}")
    print(f"   first differing coordinate: {index}")
    print(
        "   feature values on that coordinate: "
        f"{vector_result.value_x:.12f}, {vector_result.value_y:.12f}"
    )

    epsilon = 0.03
    delta = choose_delta(epsilon)
    bound = square_error_bound(delta)
    sampled, location = max_sampled_error(
        lambda t: shifted_exp_log_square(t, delta)
    )
    exact_supremum = bound  # attained at x=1
    print("\n3. Shifted exp--log approximation of x^2")
    print(f"   requested tolerance epsilon={epsilon}")
    print(f"   selected delta={delta}")
    print(f"   conservative certificate 3*delta={3.0 * delta:.12f}")
    print(f"   exact uniform error 2*delta+delta^2={exact_supremum:.12f}")
    print(f"   sampled maximum error={sampled:.12f} at x={location:.6f}")
    print(f"   certified below epsilon: {bound <= epsilon}")

    print("\n4. Exact square at any requested width N >= 2")
    for width in (2, 3, 8):
        realized_width = padded_square_width(width)
        sample_error = max(abs(t * t - t**2) for t in (0.0, 0.2, 0.7, 1.0))
        print(
            f"   requested={width}, realized={realized_width}, "
            f"sample error={sample_error:.1f}"
        )


if __name__ == "__main__":
    run_demo()
