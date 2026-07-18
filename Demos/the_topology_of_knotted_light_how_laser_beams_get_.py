#!/usr/bin/env python3
"""Numerical demonstrations of Alexander-polynomial angular selection.

The script compares exact coprimality predictions with complex polynomial
residuals for the trefoil and cinquefoil, then demonstrates that the
figure-eight roots lie off the unit circle and produce radial rates instead.
Only Python's standard library is required.
"""

from __future__ import annotations

import cmath
import math
from dataclasses import dataclass
from typing import Iterable, Sequence


@dataclass(frozen=True)
class ChannelResidual:
    """A phase-grid index together with its phase and polynomial residual."""

    index: int
    phase: complex
    residual: float


def angular_phase(grid_size: int, index: int) -> complex:
    """Return exp(2*pi*i*index/grid_size)."""
    if grid_size <= 0:
        raise ValueError("grid_size must be positive")
    return cmath.exp(2j * math.pi * index / grid_size)


def evaluate_polynomial(coefficients: Sequence[complex], z: complex) -> complex:
    """Evaluate coefficients in ascending degree order using Horner's rule."""
    value = 0j
    for coefficient in reversed(coefficients):
        value = value * z + coefficient
    return value


def alternating_torus_coefficients(p: int) -> list[complex]:
    """Return coefficients of 1-t+t^2-...+t^(p-1), for odd p."""
    if p < 3 or p % 2 == 0:
        raise ValueError("p must be an odd integer at least 3")
    return [complex((-1) ** k) for k in range(p)]


def modular_unit_spectrum(p: int) -> list[int]:
    """Generate the exact T(2,p) spectrum predicted for odd prime p."""
    if p < 3 or p % 2 == 0:
        raise ValueError("p must be an odd integer at least 3")
    modulus = 2 * p
    return [index for index in range(modulus) if math.gcd(index, modulus) == 1]


def phase_grid_scan(
    coefficients: Sequence[complex], grid_size: int
) -> list[ChannelResidual]:
    """Evaluate a polynomial at every phase on a finite angular grid."""
    return [
        ChannelResidual(
            index=index,
            phase=(phase := angular_phase(grid_size, index)),
            residual=abs(evaluate_polynomial(coefficients, phase)),
        )
        for index in range(grid_size)
    ]


def numerical_channels(
    coefficients: Sequence[complex], grid_size: int, tolerance: float = 1e-9
) -> list[int]:
    """Return grid indices whose polynomial residual is below tolerance."""
    if tolerance <= 0:
        raise ValueError("tolerance must be positive")
    return [
        item.index
        for item in phase_grid_scan(coefficients, grid_size)
        if item.residual < tolerance
    ]


def figure_eight_roots() -> tuple[float, float]:
    """Return the exact-form numerical roots of t^2 - 3t + 1."""
    root_plus = (3.0 + math.sqrt(5.0)) / 2.0
    root_minus = (3.0 - math.sqrt(5.0)) / 2.0
    return root_plus, root_minus


def radial_rates(roots: Iterable[complex]) -> list[float]:
    """Return logarithmic moduli, the natural radial growth/decay rates."""
    rates: list[float] = []
    for root in roots:
        modulus = abs(root)
        if modulus == 0:
            raise ValueError("zero has no finite logarithmic radial rate")
        rates.append(math.log(modulus))
    return rates


def print_torus_demo(name: str, p: int) -> None:
    """Print exact and numerical spectra for one T(2,p) example."""
    coefficients = alternating_torus_coefficients(p)
    modulus = 2 * p
    exact = modular_unit_spectrum(p)
    numerical = numerical_channels(coefficients, modulus)
    print(f"\n{name}: T(2,{p})")
    print(f"  grid modulus: {modulus}")
    print(f"  exact coprime residues: {exact}")
    print(f"  numerical zero residues: {numerical}")
    print(f"  predicted channel count p-1: {p - 1}")
    assert exact == numerical
    residuals = phase_grid_scan(coefficients, modulus)
    for item in residuals:
        marker = "SELECTED" if item.index in exact else ""
        print(f"    l={item.index:2d}  |A(z)|={item.residual:.3e} {marker}")


def print_figure_eight_demo(grid_sizes: Sequence[int] = (6, 10, 64)) -> None:
    """Show absence of angular roots and the reciprocal radial rates."""
    coefficients = [1 + 0j, -3 + 0j, 1 + 0j]
    print("\nFigure-eight knot")
    for grid_size in grid_sizes:
        scan = phase_grid_scan(coefficients, grid_size)
        smallest = min(scan, key=lambda item: item.residual)
        selected = numerical_channels(coefficients, grid_size)
        print(
            f"  N={grid_size:2d}: selected={selected}, "
            f"minimum residual={smallest.residual:.6f} at l={smallest.index}"
        )
        assert not selected
    roots = figure_eight_roots()
    rates = radial_rates(roots)
    print(f"  real reciprocal roots: {roots[0]:.12f}, {roots[1]:.12f}")
    print(f"  product of roots: {roots[0] * roots[1]:.12f}")
    print(f"  logarithmic radial rates: {rates[0]:.12f}, {rates[1]:.12f}")
    assert math.isclose(roots[0] * roots[1], 1.0, abs_tol=1e-12)
    assert math.isclose(rates[0] + rates[1], 0.0, abs_tol=1e-12)


def main() -> None:
    """Run all demonstrations."""
    print("Alexander-polynomial angular spectra")
    print_torus_demo("Trefoil", 3)
    print_torus_demo("Cinquefoil", 5)
    print_figure_eight_demo()
    print("\nAll exact predictions agree with the numerical demonstrations.")


if __name__ == "__main__":
    main()
