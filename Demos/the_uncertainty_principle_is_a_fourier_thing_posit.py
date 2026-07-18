#!/usr/bin/env python3
"""Dependency-free numerical illustrations of transform uncertainty.

Finite windows and sampled grids diagnose concentration, not exact support.
"""
from __future__ import annotations

import cmath
import math
from typing import Callable, Sequence


def trapezoid(values: Sequence[complex], spacing: float) -> complex:
    """Integrate equally spaced complex samples by the trapezoidal rule."""
    if len(values) < 2:
        raise ValueError("at least two samples are required")
    return spacing * (0.5 * values[0] + sum(values[1:-1]) + 0.5 * values[-1])


def energy_width(axis: Sequence[float], values: Sequence[complex], spacing: float) -> float:
    """Return the standard deviation of energy density |values|^2."""
    weights = [abs(v) ** 2 * spacing for v in values]
    total = sum(weights)
    if total <= 0.0 or len(axis) != len(values):
        raise ValueError("matching nonzero samples are required")
    mean = sum(x * w for x, w in zip(axis, weights)) / total
    variance = sum((x - mean) ** 2 * w for x, w in zip(axis, weights)) / total
    return math.sqrt(max(variance, 0.0))


def direct_fourier(signal: Sequence[complex], spacing: float) -> tuple[list[float], list[complex]]:
    """Compute a centered angular-frequency DFT in O(N^2) time."""
    n = len(signal)
    indices = list(range(-n // 2, n // 2))
    frequencies = [2.0 * math.pi * m / (n * spacing) for m in indices]
    transform = [
        spacing * sum(value * cmath.exp(-1j * k * ((j - n // 2) * spacing))
                      for j, value in enumerate(signal))
        for k in frequencies
    ]
    return frequencies, transform


def gaussian_fourier_experiment(
    sigmas: Sequence[float] = (0.35, 0.7, 1.4), n: int = 512, half_window: float = 10.0
) -> list[tuple[float, float, float, float]]:
    """Measure reciprocal Gaussian widths using a dependency-free DFT."""
    spacing = 2.0 * half_window / n
    x = [(j - n // 2) * spacing for j in range(n)]
    rows: list[tuple[float, float, float, float]] = []
    for sigma in sigmas:
        signal = [complex(math.exp(-(q * q) / (4.0 * sigma * sigma))) for q in x]
        k, spectrum = direct_fourier(signal, spacing)
        dk = k[1] - k[0]
        delta_x = energy_width(x, signal, spacing)
        delta_k = energy_width(k, spectrum, dk)
        rows.append((sigma, delta_x, delta_k, delta_x * delta_k))
    return rows


def box_transform(half_width: float, frequency: float) -> float:
    """Return the exact transform 2 sin(a k)/k of the box on [-a,a]."""
    return 2.0 * half_width if frequency == 0.0 else 2.0 * math.sin(half_width * frequency) / frequency


def sampled_laplace_exp(s: complex, horizon: float = 30.0, n: int = 20000) -> complex:
    """Approximate the Laplace transform of exp(-t), exactly 1/(s+1)."""
    h = horizon / n
    values = [cmath.exp(-(s + 1.0) * (j * h)) for j in range(n + 1)]
    return trapezoid(values, h)


def sampled_mellin_exp(
    sigma: float, omega: float, u_min: float = -12.0, u_max: float = 5.0, n: int = 30000
) -> complex:
    """Approximate the Mellin transform of exp(-x) after x=exp(u)."""
    h = (u_max - u_min) / n
    values: list[complex] = []
    for j in range(n + 1):
        u = u_min + j * h
        x = math.exp(u)
        values.append(math.exp(-x) * cmath.exp(complex(sigma, omega) * u))
    return trapezoid(values, h)


def gram_discriminant(signal: Sequence[float], probe: Sequence[float]) -> float:
    """Compute ||u||^2||v||^2-<u,v>^2, a nonnegative quantity."""
    if len(signal) != len(probe):
        raise ValueError("vectors must have equal length")
    uu = sum(x * x for x in signal)
    vv = sum(x * x for x in probe)
    uv = sum(x * y for x, y in zip(signal, probe))
    return uu * vv - uv * uv


def main() -> None:
    print("Gaussian Fourier width reciprocity")
    print(" sigma       delta_x      delta_k      product")
    for row in gaussian_fourier_experiment():
        print(f" {row[0]:5.2f}   {row[1]:11.7f} {row[2]:11.7f} {row[3]:11.7f}")

    print("\nBox transform samples: noncompact sinc tails")
    for k in (0.0, 1.0, math.pi, 5.0, 10.0):
        print(f" k={k:8.4f}, value={box_transform(1.0, k): .8f}")

    print("\nLaplace transform of exp(-t)")
    for s in (0.2 + 0j, 0.5 + 2j, 1.0 - 5j):
        numerical = sampled_laplace_exp(s)
        exact = 1.0 / (s + 1.0)
        print(f" s={s!s:>10}, magnitude={abs(numerical):.7f}, error={abs(numerical-exact):.2e}")

    print("\nMellin transform of exp(-x) on Re(s)=1")
    for omega in (-8.0, -4.0, 0.0, 4.0, 8.0):
        value = sampled_mellin_exp(1.0, omega)
        print(f" omega={omega:5.1f}, value={value.real: .5e}{value.imag:+.5e}j")

    print("\nGram discriminant:", gram_discriminant((1.0, -2.0, 3.0), (2.0, 1.0, -1.0)))


if __name__ == "__main__":
    main()
