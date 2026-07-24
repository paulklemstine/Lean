#!/usr/bin/env python3
"""Numerical demonstrations for spectra of cyclic Cayley graphs.

The script uses only the Python standard library.  It computes character-sum
spectra, applies the adjacency operator, checks Fourier eigenvector identities,
and compares the cycle spectrum with the exact cosine formula.
"""

from __future__ import annotations

import cmath
import math
from typing import Iterable, Sequence

Vector = list[complex]


def normalize_connection_set(n: int, steps: Iterable[int]) -> tuple[int, ...]:
    """Return distinct connection steps as sorted residues modulo n."""
    if n < 1:
        raise ValueError("n must be positive")
    return tuple(sorted({step % n for step in steps}))


def character(n: int, k: int) -> Vector:
    """Return the kth Fourier character x -> exp(2*pi*i*k*x/n)."""
    if n < 1:
        raise ValueError("n must be positive")
    return [cmath.exp(2j * math.pi * k * x / n) for x in range(n)]


def character_sum_eigenvalue(n: int, steps: Iterable[int], k: int) -> complex:
    """Compute sum_{s in S} exp(2*pi*i*k*s/n)."""
    residues = normalize_connection_set(n, steps)
    return sum((cmath.exp(2j * math.pi * k * s / n) for s in residues), 0j)


def cayley_spectrum(n: int, steps: Iterable[int]) -> Vector:
    """Compute all adjacency eigenvalues by character sums."""
    residues = normalize_connection_set(n, steps)
    return [character_sum_eigenvalue(n, residues, k) for k in range(n)]


def apply_adjacency(n: int, steps: Iterable[int], values: Sequence[complex]) -> Vector:
    """Apply (A f)(x) = sum_{s in S} f(x+s mod n)."""
    if len(values) != n:
        raise ValueError("values must have length n")
    residues = normalize_connection_set(n, steps)
    return [sum((values[(x + s) % n] for s in residues), 0j) for x in range(n)]


def max_error(left: Sequence[complex], right: Sequence[complex]) -> float:
    """Return the maximum coordinatewise absolute error."""
    if len(left) != len(right):
        raise ValueError("vectors must have equal length")
    return max((abs(a - b) for a, b in zip(left, right)), default=0.0)


def verify_fourier_eigenvectors(n: int, steps: Iterable[int]) -> float:
    """Return the worst residual ||A chi_k - lambda_k chi_k||_infinity."""
    residues = normalize_connection_set(n, steps)
    worst = 0.0
    for k in range(n):
        chi = character(n, k)
        eigenvalue = character_sum_eigenvalue(n, residues, k)
        actual = apply_adjacency(n, residues, chi)
        expected = [eigenvalue * value for value in chi]
        worst = max(worst, max_error(actual, expected))
    return worst


def cycle_cosine_spectrum(n: int) -> list[float]:
    """Return the exact-form cycle eigenvalues 2*cos(2*pi*k/n)."""
    if n < 3:
        raise ValueError("a cycle in this convention requires n >= 3")
    return [2.0 * math.cos(2.0 * math.pi * k / n) for k in range(n)]


def transition_absolute_gap(n: int, steps: Iterable[int]) -> float:
    """Compute 1 - max_{k != 0} |lambda_k|/degree.

    This absolute gap is zero for periodic bipartite walks having eigenvalue -1.
    """
    residues = normalize_connection_set(n, steps)
    if not residues:
        raise ValueError("the connection set must be nonempty")
    spectrum = cayley_spectrum(n, residues)
    return 1.0 - max(abs(value) / len(residues) for value in spectrum[1:])


def format_complex(value: complex, tolerance: float = 1e-10) -> str:
    """Format a nearly real or genuinely complex value readably."""
    real = 0.0 if abs(value.real) < tolerance else value.real
    imag = 0.0 if abs(value.imag) < tolerance else value.imag
    if imag == 0.0:
        return f"{real:.6f}"
    return f"{real:.6f}{imag:+.6f}i"


def demonstrate_cycle(n: int = 12) -> None:
    """Compare character sums and the cosine formula for the n-cycle."""
    computed = cayley_spectrum(n, (1, -1))
    predicted = cycle_cosine_spectrum(n)
    error = max(abs(a - b) for a, b in zip(computed, predicted))
    print(f"Cycle C_{n}")
    print("character-sum spectrum:", [format_complex(v) for v in computed])
    print("maximum cosine-formula error:", f"{error:.3e}")
    print("maximum eigenvector residual:", f"{verify_fourier_eigenvectors(n, (1, -1)):.3e}")
    print()


def demonstrate_symmetric_long_range(n: int = 12) -> None:
    """Show the real, degree-bounded spectrum for jumps ±1 and ±2."""
    steps = (1, -1, 2, -2)
    spectrum = cayley_spectrum(n, steps)
    max_imaginary = max(abs(value.imag) for value in spectrum)
    max_modulus = max(abs(value) for value in spectrum)
    print(f"Symmetric long-range graph on Z/{n}Z with steps ±1, ±2")
    print("spectrum:", [format_complex(v) for v in spectrum])
    print(f"degree = 4; maximum modulus = {max_modulus:.6f}")
    print(f"largest imaginary residual = {max_imaginary:.3e}")
    print()


def demonstrate_directed_case(n: int = 7) -> None:
    """Show that a nonsymmetric connection set may have complex eigenvalues."""
    steps = (1, 2)
    spectrum = cayley_spectrum(n, steps)
    print(f"Directed graph on Z/{n}Z with steps 1, 2")
    print("spectrum:", [format_complex(v) for v in spectrum])
    print(f"degree bound: max |lambda| = {max(map(abs, spectrum)):.6f} <= 2")
    print(f"maximum eigenvector residual = {verify_fourier_eigenvectors(n, steps):.3e}")
    print()


def main() -> None:
    demonstrate_cycle()
    demonstrate_symmetric_long_range()
    demonstrate_directed_case()


if __name__ == "__main__":
    main()
