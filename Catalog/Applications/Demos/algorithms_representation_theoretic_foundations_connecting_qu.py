#!/usr/bin/env python3
"""
Quantum Casimir Spectral Theory — Algorithms

Type-hinted implementations of the core algorithms for quantum Casimir
spectral analysis, q-integer computation, and spectral decomposition.
"""

from typing import List, Tuple, Optional
import math


def q_integer(n: int, theta: float) -> float:
    """
    Compute the trigonometric q-integer [n]_q = sin(nθ)/sin(θ).

    The q-integer is the fundamental building block of quantum group
    representation theory. It equals the character of the (n-1)-dimensional
    irreducible representation of SU(2)_q evaluated at the maximal torus.

    Args:
        n: Non-negative integer (representation label)
        theta: Deformation parameter (radians)

    Returns:
        The q-integer value. Returns 0 if sin(theta) = 0.

    Complexity: O(1)
    """
    sin_theta = math.sin(theta)
    if abs(sin_theta) < 1e-15:
        return 0.0
    return math.sin(n * theta) / sin_theta


def spectral_numerator(n: int, theta: float) -> float:
    """
    Compute the q-Casimir spectral numerator S(n, θ) = 2sin(nθ)sin((n+1)θ).

    By the spectral decomposition theorem:
        S(n, θ) = cos(θ) - cos((2n+1)θ)

    Args:
        n: Representation label (non-negative integer)
        theta: Deformation parameter

    Returns:
        The spectral numerator value, always in [-2, 2].

    Complexity: O(1)
    """
    return math.cos(theta) - math.cos((2 * n + 1) * theta)


def q_casimir_eigenvalue(n: int, theta: float) -> float:
    """
    Compute the q-Casimir eigenvalue C_n(θ) = [n]_q · [n+1]_q.

    This is the eigenvalue of the quantum Casimir operator on the
    (n+1)-dimensional irreducible representation of U_q(sl₂).

    Args:
        n: Representation label
        theta: Deformation parameter

    Returns:
        The Casimir eigenvalue. Equals S(n,θ)/(2sin²θ) when sin(θ) ≠ 0.
    """
    return q_integer(n, theta) * q_integer(n + 1, theta)


def chebyshev_sequence(N: int, theta: float) -> List[float]:
    """
    Generate the sequence sin(nθ) for n = 0, 1, ..., N using the
    Chebyshev three-term recurrence.

    Uses the identity: sin((n+1)θ) = 2cos(θ)sin(nθ) - sin((n-1)θ)
    This is numerically stable and O(N) in time.

    Args:
        N: Maximum index
        theta: Parameter

    Returns:
        List [sin(0), sin(θ), sin(2θ), ..., sin(Nθ)]

    Complexity: O(N)
    """
    if N < 0:
        return []
    result: List[float] = [0.0]  # sin(0) = 0
    if N == 0:
        return result
    result.append(math.sin(theta))  # sin(θ)
    two_cos = 2 * math.cos(theta)
    for k in range(2, N + 1):
        next_val = two_cos * result[-1] - result[-2]
        result.append(next_val)
    return result


def spectral_numerator_sequence(N: int, theta: float) -> List[float]:
    """
    Compute spectral numerators S(0,θ), S(1,θ), ..., S(N,θ) efficiently.

    Uses the spectral decomposition: S(n,θ) = cos(θ) - cos((2n+1)θ).

    Args:
        N: Maximum representation label
        theta: Deformation parameter

    Returns:
        List of spectral numerator values.

    Complexity: O(N)
    """
    cos_theta = math.cos(theta)
    return [cos_theta - math.cos((2 * n + 1) * theta) for n in range(N + 1)]


def odd_cosine_sum(N: int, theta: float) -> float:
    """
    Compute Σ_{k=0}^{N-1} cos((2k+1)θ) using the closed-form formula.

    By the telescoping identity:
        Σ cos((2k+1)θ) = sin(2Nθ) / (2sin(θ))

    Args:
        N: Number of terms
        theta: Parameter (sin(theta) must be nonzero)

    Returns:
        The sum value.

    Complexity: O(1)
    """
    sin_theta = math.sin(theta)
    if abs(sin_theta) < 1e-15:
        raise ValueError("sin(theta) must be nonzero")
    return math.sin(2 * N * theta) / (2 * sin_theta)


def spectral_consecutive_differences(N: int, theta: float) -> List[float]:
    """
    Compute the spectral velocity: S(n+1,θ) - S(n,θ) = 2sin(θ)sin((2n+2)θ).

    The spectral velocity measures how fast the Casimir eigenvalue changes
    with the representation label. It factors as a product of sines.

    Args:
        N: Maximum index for differences
        theta: Deformation parameter

    Returns:
        List of differences [S(1)-S(0), S(2)-S(1), ..., S(N)-S(N-1)]

    Complexity: O(N)
    """
    two_sin_theta = 2 * math.sin(theta)
    return [two_sin_theta * math.sin((2 * n + 2) * theta) for n in range(N)]


def find_spectral_zeros(theta: float, N_max: int = 1000) -> List[int]:
    """
    Find representation labels n where S(n, θ) = 0.

    The spectral numerator vanishes when sin(nθ) = 0 or sin((n+1)θ) = 0,
    i.e., when nθ or (n+1)θ is a multiple of π.

    Args:
        theta: Deformation parameter
        N_max: Search up to this representation label

    Returns:
        List of n values where |S(n,θ)| < tolerance.
    """
    zeros: List[int] = []
    tol = 1e-12
    for n in range(N_max + 1):
        if abs(spectral_numerator(n, theta)) < tol:
            zeros.append(n)
    return zeros


def isospectrality_offset(theta1: float, theta2: float) -> float:
    """
    Compute the isospectrality offset δ = cos(θ₁) - cos(θ₂).

    By the spectral isospectrality constraint theorem, if two quantum
    Casimir spectra agree at all levels, then
    cos((2n+1)θ₁) - cos((2n+1)θ₂) = δ for all n.

    Args:
        theta1: First deformation parameter
        theta2: Second deformation parameter

    Returns:
        The offset δ.
    """
    return math.cos(theta1) - math.cos(theta2)


def verify_isospectrality(
    theta1: float, theta2: float, N: int = 100
) -> Tuple[bool, float]:
    """
    Check whether two deformation parameters could give isospectral
    quantum Casimir spectra.

    Returns (is_isospectral, max_deviation) where max_deviation measures
    how far the spectral functions deviate from each other.

    Args:
        theta1, theta2: Deformation parameters
        N: Number of levels to check

    Returns:
        Tuple of (is_isospectral, max_deviation)
    """
    max_dev = 0.0
    for n in range(N + 1):
        s1 = spectral_numerator(n, theta1)
        s2 = spectral_numerator(n, theta2)
        max_dev = max(max_dev, abs(s1 - s2))
    return (max_dev < 1e-10, max_dev)


def level_one_decomposition(theta: float) -> Tuple[float, float, float]:
    """
    Compute the level-one spectral decomposition.

    At level n=1: cos(θ) - cos(3θ) = 4cos(θ)sin²(θ)

    Returns (spectral_value, cos_factor, sin_sq_factor) where
    spectral_value = 4 * cos_factor * sin_sq_factor.

    Args:
        theta: Deformation parameter

    Returns:
        Tuple (spectral_value, cos(θ), sin²(θ))
    """
    c = math.cos(theta)
    s2 = math.sin(theta) ** 2
    return (4 * c * s2, c, s2)


if __name__ == "__main__":
    # Quick verification of all algorithms
    theta = math.pi / 5

    print("q-integers [1] through [5]:")
    for n in range(1, 6):
        print(f"  [{n}]_q = {q_integer(n, theta):.6f}")

    print(f"\nChebyshev sequence (first 6 terms): {chebyshev_sequence(5, theta)}")

    print(f"\nSpectral numerators S(0) through S(4): {spectral_numerator_sequence(4, theta)}")

    print(f"\nOdd cosine sum (N=10): {odd_cosine_sum(10, theta):.6f}")

    print(f"\nSpectral zeros at θ=π/3: {find_spectral_zeros(math.pi/3, 20)}")

    iso, dev = verify_isospectrality(theta, -theta)
    print(f"\nIsospectrality θ vs -θ: {iso} (deviation: {dev:.2e})")

    iso, dev = verify_isospectrality(theta, theta + 0.1)
    print(f"Isospectrality θ vs θ+0.1: {iso} (deviation: {dev:.2e})")
