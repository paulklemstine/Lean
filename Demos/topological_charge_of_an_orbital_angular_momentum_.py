#!/usr/bin/env python3
"""Numerical demonstrations of winding, dressing, and torus-beam charge."""

from __future__ import annotations

import cmath
import math
from dataclasses import dataclass
from math import gcd
from typing import Callable, Iterable, Sequence

ComplexLoop = Callable[[float], complex]


@dataclass(frozen=True)
class WindingEstimate:
    """Discrete winding estimate and basic resolution diagnostics."""

    winding: float
    nearest_integer: int
    integer_error: float
    minimum_modulus: float
    maximum_phase_step: float
    samples: int


def sample_loop(loop: ComplexLoop, samples: int = 4096) -> list[complex]:
    """Sample a loop at equally spaced angles in [0, 2π)."""
    if samples < 4:
        raise ValueError("samples must be at least 4")
    values = [loop(2.0 * math.pi * j / samples) for j in range(samples)]
    if any(not (math.isfinite(z.real) and math.isfinite(z.imag)) for z in values):
        raise ValueError("loop produced a non-finite value")
    return values


def principal_increment(z0: complex, z1: complex, zero_tolerance: float = 1e-12) -> float:
    """Return Arg(z1/conj-free z0 ratio) in (-π, π]."""
    if abs(z0) <= zero_tolerance or abs(z1) <= zero_tolerance:
        raise ValueError("winding is undefined or unstable at a zero")
    return cmath.phase(z1 * z0.conjugate())


def estimate_winding(values: Sequence[complex], zero_tolerance: float = 1e-12) -> WindingEstimate:
    """Estimate winding by summing cyclic principal phase increments in O(N) time."""
    if len(values) < 4:
        raise ValueError("at least four cyclic samples are required")
    minimum_modulus = min(abs(z) for z in values)
    if minimum_modulus <= zero_tolerance:
        raise ValueError("sampled loop reaches the zero tolerance")
    increments = [
        principal_increment(values[j], values[(j + 1) % len(values)], zero_tolerance)
        for j in range(len(values))
    ]
    winding = math.fsum(increments) / (2.0 * math.pi)
    nearest = round(winding)
    return WindingEstimate(
        winding=winding,
        nearest_integer=nearest,
        integer_error=abs(winding - nearest),
        minimum_modulus=minimum_modulus,
        maximum_phase_step=max(abs(step) for step in increments),
        samples=len(values),
    )


def oam_phase(charge: int) -> ComplexLoop:
    """Return θ ↦ exp(i charge θ)."""
    return lambda theta: cmath.exp(1j * charge * theta)


def periodic_dressing(a: float, b: float) -> ComplexLoop:
    """Return exp(a cos θ + i b sin θ), which has a closing logarithm."""
    return lambda theta: cmath.exp(a * math.cos(theta) + 1j * b * math.sin(theta))


def charged_dressing(charge: int) -> ComplexLoop:
    """Return a non-vanishing envelope with the specified integer winding."""
    return oam_phase(charge)


def multiply_loops(*loops: ComplexLoop) -> ComplexLoop:
    """Return the pointwise product of finitely many loops."""
    def product(theta: float) -> complex:
        result = 1.0 + 0.0j
        for loop in loops:
            result *= loop(theta)
        return result
    return product


def laguerre_gauss_like(charge: int, radius: float) -> ComplexLoop:
    """Return the fixed-radius model r^|ℓ| exp(iℓθ)."""
    if radius <= 0.0:
        raise ValueError("radius must be positive for a non-vanishing contour")
    scale = radius ** abs(charge)
    return lambda theta: scale * cmath.exp(1j * charge * theta)


def torus_beam(p: int, q: int) -> ComplexLoop:
    """Return the model meridional phase exp(i p q θ)."""
    return oam_phase(p * q)


def integer_lcm(p: int, q: int) -> int:
    """Return the nonnegative least common multiple."""
    return 0 if p == 0 or q == 0 else abs(p * q) // gcd(p, q)


def print_estimate(label: str, loop: ComplexLoop, samples: int = 4096) -> WindingEstimate:
    """Compute and print one labeled winding estimate."""
    estimate = estimate_winding(sample_loop(loop, samples))
    print(
        f"{label:42s} winding={estimate.winding: .12f} "
        f"nearest={estimate.nearest_integer:3d} "
        f"error={estimate.integer_error:.2e} "
        f"min|z|={estimate.minimum_modulus:.3e} "
        f"max Δφ={estimate.maximum_phase_step:.3e}"
    )
    return estimate


def demonstrate_product_law() -> None:
    """Show that pointwise multiplication adds signed charges."""
    print("\n1. Product law and finite-family conservation")
    left = oam_phase(3)
    right = oam_phase(-1)
    e_left = print_estimate("charge +3", left)
    e_right = print_estimate("charge -1", right)
    e_product = print_estimate("product (+3)·(-1)", multiply_loops(left, right))
    residual = e_product.winding - e_left.winding - e_right.winding
    print(f"product-law residual: {residual:.3e}")
    family = [4, -2, -2, 5]
    print_estimate(
        f"family {family}",
        multiply_loops(*(oam_phase(charge) for charge in family)),
    )
    print_estimate("opposite-charge annihilation (+5,-5)", multiply_loops(oam_phase(5), oam_phase(-5)))


def demonstrate_dressing() -> None:
    """Compare a periodic-logarithm dressing with a charged envelope."""
    print("\n2. Periodic logarithmic dressing and exact charge shift")
    base = oam_phase(3)
    neutral = periodic_dressing(0.4, 0.2)
    charged = charged_dressing(-2)
    print_estimate("base beam, charge +3", base)
    print_estimate("neutral envelope exp(.4 cosθ+.2i sinθ)", neutral)
    print_estimate("neutral envelope × base", multiply_loops(neutral, base))
    print_estimate("charged envelope, charge -2", charged)
    print_estimate("charged envelope × base", multiply_loops(charged, base))


def demonstrate_full_amplitude() -> None:
    """Show that fixed-radius amplitude changes do not change charge."""
    print("\n3. Full off-axis Laguerre–Gauss-like amplitude")
    for radius in (0.35, 1.0, 2.0):
        print_estimate(f"charge +4 at radius {radius}", laguerre_gauss_like(4, radius))


def demonstrate_torus_arithmetic() -> None:
    """Compare torus-beam winding, products, gcd, and lcm."""
    print("\n4. Torus-beam charge and coprime lcm bridge")
    for p, q in ((2, 3), (3, 5), (2, 4)):
        estimate = print_estimate(f"torus parameters ({p},{q})", torus_beam(p, q))
        print(
            f"  p·q={p*q}, gcd={gcd(p,q)}, lcm={integer_lcm(p,q)}, "
            f"coprime={gcd(p,q)==1}, measured integer={estimate.nearest_integer}"
        )


def main() -> None:
    """Run all demonstrations."""
    print("Topological charge of orbital-angular-momentum beams")
    demonstrate_product_law()
    demonstrate_dressing()
    demonstrate_full_amplitude()
    demonstrate_torus_arithmetic()


if __name__ == "__main__":
    main()
