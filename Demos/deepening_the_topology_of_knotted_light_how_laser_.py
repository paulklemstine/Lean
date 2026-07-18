#!/usr/bin/env python3
"""Numerical demonstrations of winding laws for nonvanishing optical modes.

The program uses only Python's standard library.  It evaluates the normalized
logarithmic-derivative integral with a periodic trapezoidal rule and compares
it with a discrete phase-increment estimator.
"""

from __future__ import annotations

import cmath
import math
from dataclasses import dataclass
from typing import Callable

ComplexFunction = Callable[[float], complex]


@dataclass(frozen=True)
class WindingEstimate:
    """Numerical winding together with the smallest sampled amplitude."""

    value: complex
    minimum_amplitude: float


def winding_from_log_derivative(
    field: ComplexFunction,
    derivative: ComplexFunction,
    samples: int = 8192,
    zero_tolerance: float = 1.0e-10,
) -> WindingEstimate:
    """Estimate (2*pi*i)^(-1) integral field'/field over one turn.

    A uniform periodic trapezoidal rule is used.  The routine refuses to divide
    by a sample whose amplitude is below ``zero_tolerance``.
    """
    if samples < 4:
        raise ValueError("samples must be at least 4")
    step = 2.0 * math.pi / samples
    total = 0.0j
    minimum = math.inf
    for j in range(samples):
        theta = j * step
        value = field(theta)
        amplitude = abs(value)
        minimum = min(minimum, amplitude)
        if amplitude <= zero_tolerance:
            raise ValueError("the sampled contour approaches or crosses a zero")
        total += derivative(theta) / value
    integral = step * total
    return WindingEstimate(integral / (2.0j * math.pi), minimum)


def winding_from_phase(field: ComplexFunction, samples: int = 8192) -> float:
    """Estimate winding by summing principal phase increments around the loop."""
    if samples < 4:
        raise ValueError("samples must be at least 4")
    values = [field(2.0 * math.pi * j / samples) for j in range(samples)]
    if any(value == 0 for value in values):
        raise ValueError("the sampled contour crosses a zero")
    phase_change = 0.0
    for current, following in zip(values, values[1:] + values[:1]):
        phase_change += cmath.phase(following / current)
    return phase_change / (2.0 * math.pi)


def helical_mode(charge: int, modulation: float = 0.0) -> tuple[ComplexFunction, ComplexFunction]:
    """Return a positive-amplitude modulated helical mode and its derivative."""
    if abs(modulation) >= 1.0:
        raise ValueError("|modulation| must be below 1 to prevent zeros")

    def field(theta: float) -> complex:
        amplitude = 1.0 + modulation * math.cos(theta)
        return amplitude * cmath.exp(1.0j * charge * theta)

    def derivative(theta: float) -> complex:
        phase = cmath.exp(1.0j * charge * theta)
        return (-modulation * math.sin(theta) + 1.0j * charge *
                (1.0 + modulation * math.cos(theta))) * phase

    return field, derivative


def integer_power_mode(
    field: ComplexFunction, derivative: ComplexFunction, exponent: int
) -> tuple[ComplexFunction, ComplexFunction]:
    """Construct an integer power and its derivative for a nonzero field."""
    def powered(theta: float) -> complex:
        return field(theta) ** exponent

    def powered_derivative(theta: float) -> complex:
        if exponent == 0:
            return 0.0j
        value = field(theta)
        return exponent * value ** (exponent - 1) * derivative(theta)

    return powered, powered_derivative


def product_mode(
    left: tuple[ComplexFunction, ComplexFunction],
    right: tuple[ComplexFunction, ComplexFunction],
) -> tuple[ComplexFunction, ComplexFunction]:
    """Construct a product field and its product-rule derivative."""
    left_field, left_derivative = left
    right_field, right_derivative = right

    def field(theta: float) -> complex:
        return left_field(theta) * right_field(theta)

    def derivative(theta: float) -> complex:
        return (left_derivative(theta) * right_field(theta) +
                left_field(theta) * right_derivative(theta))

    return field, derivative


def show_estimate(label: str, mode: tuple[ComplexFunction, ComplexFunction]) -> None:
    """Print derivative- and phase-based estimates for one mode."""
    field, derivative = mode
    estimate = winding_from_log_derivative(field, derivative)
    phase_estimate = winding_from_phase(field)
    print(f"{label:34s} log-derivative={estimate.value.real: .12f}"
          f"{estimate.value.imag:+.2e}i  phase={phase_estimate: .12f}"
          f"  min|field|={estimate.minimum_amplitude:.3f}")


def main() -> None:
    """Run three demonstrations of product, power, and cancellation laws."""
    gamma = helical_mode(2, modulation=0.30)
    delta = helical_mode(-3, modulation=-0.20)

    print("Demo 1: arbitrary smooth amplitude modulation preserves helical winding")
    show_estimate("gamma: expected 2", gamma)
    show_estimate("delta: expected -3", delta)

    print("\nDemo 2: integer-powered two-mode composition")
    k, ell = 4, -1
    composite = product_mode(integer_power_mode(*gamma, k),
                             integer_power_mode(*delta, ell))
    show_estimate("gamma^4 delta^-1: expected 11", composite)
    gamma_w = winding_from_log_derivative(*gamma).value
    delta_w = winding_from_log_derivative(*delta).value
    composite_w = winding_from_log_derivative(*composite).value
    residual = composite_w - k * gamma_w - ell * delta_w
    print(f"composition residual: {abs(residual):.3e}")

    print("\nDemo 3: nonconstant zero-winding cancellation")
    charge_three = helical_mode(3, modulation=0.15)
    cancellation = product_mode(integer_power_mode(*gamma, 3),
                                integer_power_mode(*charge_three, -2))
    show_estimate("gamma^3 eta^-2: expected 0", cancellation)


if __name__ == "__main__":
    main()
