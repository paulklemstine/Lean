#!/usr/bin/env python3
"""Numerical exploration of unit-modulus values of log(1 + i t).

The analytic theorem guarantees a crossing in [1/2, 3].  This script
approximates one crossing, checks reflection symmetry, and demonstrates the
unitary-scalar identity numerically using only the Python standard library.
"""

from __future__ import annotations

import cmath
import math
from dataclasses import dataclass
from typing import Callable, Iterable


@dataclass(frozen=True)
class BisectionResult:
    """Result of a sign-preserving bisection search."""

    root: float
    lower: float
    upper: float
    iterations: int
    residual: float


def scalar_log(t: float) -> complex:
    """Return the principal complex logarithm log(1 + i t)."""
    return cmath.log(complex(1.0, t))


def scalar_log_norm(t: float) -> float:
    """Return |log(1 + i t)|."""
    return abs(scalar_log(t))


def scalar_log_norm_explicit(t: float) -> float:
    """Evaluate the equivalent real formula for |log(1 + i t)|."""
    real_part = 0.5 * math.log1p(t * t)
    imaginary_part = math.atan(t)
    return math.hypot(real_part, imaginary_part)


def bisection(
    function: Callable[[float], float],
    lower: float,
    upper: float,
    tolerance: float = 1.0e-13,
    max_iterations: int = 200,
) -> BisectionResult:
    """Find a sign-changing root bracket by deterministic bisection.

    Raises ValueError when the supplied endpoints do not bracket a root.
    The method has O(log((upper-lower)/tolerance)) iterations.
    """
    if not lower < upper:
        raise ValueError("lower must be strictly smaller than upper")
    if tolerance <= 0.0:
        raise ValueError("tolerance must be positive")

    f_lower = function(lower)
    f_upper = function(upper)
    if f_lower == 0.0:
        return BisectionResult(lower, lower, lower, 0, 0.0)
    if f_upper == 0.0:
        return BisectionResult(upper, upper, upper, 0, 0.0)
    if f_lower * f_upper > 0.0:
        raise ValueError("endpoints do not bracket a sign change")

    iterations = 0
    while upper - lower > tolerance and iterations < max_iterations:
        midpoint = (lower + upper) / 2.0
        f_midpoint = function(midpoint)
        iterations += 1
        if f_midpoint == 0.0:
            lower = upper = midpoint
            break
        if f_lower * f_midpoint <= 0.0:
            upper = midpoint
            f_upper = f_midpoint
        else:
            lower = midpoint
            f_lower = f_midpoint

    root = (lower + upper) / 2.0
    return BisectionResult(
        root=root,
        lower=lower,
        upper=upper,
        iterations=iterations,
        residual=abs(function(root)),
    )


def symmetry_errors(samples: Iterable[float]) -> list[tuple[float, float]]:
    """Return numerical errors in the exact identity F(-t) = F(t)."""
    return [(t, abs(scalar_log_norm(-t) - scalar_log_norm(t))) for t in samples]


def main() -> None:
    """Run endpoint, crossing, symmetry, and unitarity demonstrations."""
    objective = lambda t: scalar_log_norm(t) - 1.0

    print("Scalar logarithmic norm F(t) = |log(1 + i t)|")
    print("Certified analytic bracket: [0.5, 3.0]")
    print(f"F(0.5) = {scalar_log_norm(0.5):.15f} < 1")
    print(f"F(3.0) = {scalar_log_norm(3.0):.15f} > 1")
    print()

    result = bisection(objective, 0.5, 3.0)
    t = result.root
    z = scalar_log(t)
    print("Bisection approximation")
    print(f"  t                 = {t:.15f}")
    print(f"  final bracket     = [{result.lower:.15f}, {result.upper:.15f}]")
    print(f"  iterations        = {result.iterations}")
    print(f"  |F(t) - 1|        = {result.residual:.3e}")
    print(f"  log(1 + i t)      = {z.real:.15f} + {z.imag:.15f} i")
    print(f"  |log(1 + i t)|    = {abs(z):.15f}")
    print(f"  conjugate(z) * z = {(z.conjugate() * z).real:.15f}")
    print()

    explicit_difference = abs(scalar_log_norm(t) - scalar_log_norm_explicit(t))
    print("Equivalent real formula")
    print(f"  formula discrepancy = {explicit_difference:.3e}")
    print()

    print("Reflection symmetry F(-t) = F(t)")
    for sample, error in symmetry_errors([0.5, 1.0, t, 2.0, 3.0]):
        print(f"  t = {sample: .12f}: symmetry error = {error:.3e}")

    z_negative = scalar_log(-t)
    conjugation_error = abs(z_negative - z.conjugate())
    print(f"  conjugation error at the root = {conjugation_error:.3e}")


if __name__ == "__main__":
    main()
