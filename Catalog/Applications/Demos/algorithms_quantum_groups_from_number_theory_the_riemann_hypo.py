#!/usr/bin/env python3
"""
algorithms.py — Type-hinted implementations of the quantum zeta spectrum algorithms.

Implements q-integers, q-Casimir eigenvalues, the Chebyshev recurrence,
product-to-sum decomposition, Dirichlet kernel summation, and spectral
statistics computation.
"""

from typing import List, Tuple, Optional
import numpy as np


def q_integer(theta: float, n: int) -> float:
    """
    Compute the trigonometric q-integer [n]_q = sin(nθ)/sin(θ).

    For q = e^{iθ}, the q-integer generalizes natural numbers
    to the quantum group setting. In the classical limit θ → 0,
    [n]_q → n.

    Args:
        theta: The deformation parameter (θ where q = e^{iθ}).
        n: The integer label (non-negative).

    Returns:
        The q-integer value.
    """
    sin_theta = np.sin(theta)
    if abs(sin_theta) < 1e-15:
        return float(n)
    return np.sin(n * theta) / sin_theta


def q_casimir(theta: float, n: int) -> float:
    """
    Compute the q-Casimir eigenvalue C_q(n) = [n]_q · [n+1]_q.

    This is the eigenvalue of the Casimir element of quantum SU(2)
    acting on the n-th irreducible representation.

    Args:
        theta: The deformation parameter.
        n: The representation label.

    Returns:
        The q-Casimir eigenvalue.
    """
    return q_integer(theta, n) * q_integer(theta, n + 1)


def casimir_via_cosines(theta: float, n: int) -> float:
    """
    Compute the q-Casimir eigenvalue using the product-to-sum formula:
    C_q(n) = (cos(θ) - cos((2n+1)θ)) / (2 sin²(θ))

    This decomposition separates the constant and oscillatory parts.

    Args:
        theta: The deformation parameter.
        n: The representation label.

    Returns:
        The q-Casimir eigenvalue.
    """
    sin_theta = np.sin(theta)
    if abs(sin_theta) < 1e-15:
        return float(n * (n + 1))
    return (np.cos(theta) - np.cos((2 * n + 1) * theta)) / (2 * sin_theta ** 2)


def chebyshev_recurrence(
    theta: float, n_max: int
) -> List[float]:
    """
    Compute q-integers [0]_q, [1]_q, ..., [n_max]_q using the
    Chebyshev recurrence: [n+2]_q = 2cos(θ)·[n+1]_q - [n]_q.

    This is O(n_max) and avoids repeated trigonometric evaluations.

    Args:
        theta: The deformation parameter.
        n_max: Maximum index to compute.

    Returns:
        List of q-integers from index 0 to n_max.
    """
    if n_max < 0:
        return []

    sin_theta = np.sin(theta)
    cos_theta = np.cos(theta)

    result: List[float] = [0.0]  # [0]_q = 0
    if n_max == 0:
        return result

    if abs(sin_theta) < 1e-15:
        return [float(k) for k in range(n_max + 1)]

    result.append(1.0)  # [1]_q = 1

    two_cos = 2.0 * cos_theta
    for _ in range(2, n_max + 1):
        next_val = two_cos * result[-1] - result[-2]
        result.append(next_val)

    return result


def casimir_spectrum(theta: float, n_max: int) -> List[float]:
    """
    Compute the q-Casimir spectrum {C_q(0), C_q(1), ..., C_q(n_max)}.

    Uses the Chebyshev recurrence for efficiency.

    Args:
        theta: The deformation parameter.
        n_max: Maximum representation label.

    Returns:
        List of q-Casimir eigenvalues.
    """
    q_ints = chebyshev_recurrence(theta, n_max + 1)
    return [q_ints[n] * q_ints[n + 1] for n in range(n_max + 1)]


def dirichlet_kernel_sum(
    theta: float, n_max: int
) -> List[float]:
    """
    Compute partial sums S(N) = Σ_{k=1}^{N} cos(kθ) using the
    Dirichlet kernel identity:
    S(N) = (sin((N+1)θ) + sin(Nθ) - sin(θ)) / (2sin(θ))

    Args:
        theta: The angle parameter.
        n_max: Maximum number of terms.

    Returns:
        List of partial sums S(1), S(2), ..., S(n_max).
    """
    sin_theta = np.sin(theta)
    if abs(sin_theta) < 1e-15:
        return [float(k) for k in range(1, n_max + 1)]

    result: List[float] = []
    for N in range(1, n_max + 1):
        s = (np.sin((N + 1) * theta) + np.sin(N * theta) - np.sin(theta)) / (
            2 * sin_theta
        )
        result.append(s)
    return result


def pair_correlation(
    spectrum: List[float], delta: float
) -> float:
    """
    Compute the pair correlation function R₂(δ) for a spectrum.

    R₂(δ) = (1/N) · #{(i,j) : i≠j, |λ_i - λ_j| < δ}

    Args:
        spectrum: List of eigenvalues.
        delta: The correlation window.

    Returns:
        The pair correlation value.
    """
    N = len(spectrum)
    if N <= 1:
        return 0.0

    count = 0
    for i in range(N):
        for j in range(N):
            if i != j and abs(spectrum[i] - spectrum[j]) < delta:
                count += 1

    return count / N


def spacing_statistics(
    spectrum: List[float],
) -> Tuple[float, float, float]:
    """
    Compute nearest-neighbor spacing statistics.

    Returns (mean_spacing, std_spacing, level_repulsion_parameter)
    where the level repulsion parameter β is estimated from the
    spacing distribution. β = 1 for GOE, β = 2 for GUE, β = 0 for Poisson.

    Args:
        spectrum: List of eigenvalues.

    Returns:
        Tuple of (mean spacing, std spacing, estimated β).
    """
    sorted_spec = sorted(spectrum)
    spacings = [
        sorted_spec[i + 1] - sorted_spec[i]
        for i in range(len(sorted_spec) - 1)
    ]
    spacings = [s for s in spacings if abs(s) > 1e-12]

    if not spacings:
        return (0.0, 0.0, 0.0)

    mean_s = float(np.mean(spacings))
    std_s = float(np.std(spacings))

    # Normalize
    if mean_s > 1e-12:
        normalized = [s / mean_s for s in spacings]
        # Estimate β from the probability of small spacings
        # P(s < 0.1) ~ s^β for small s
        small_count = sum(1 for s in normalized if s < 0.1)
        total = len(normalized)
        # Rough β estimate
        if small_count > 0 and total > 0:
            p_small = small_count / total
            # For Poisson, P(s<0.1) ≈ 0.1; for GUE, P(s<0.1) ≈ 0.01/3
            beta_est = max(0.0, -np.log(p_small / 0.1) / np.log(10))
        else:
            beta_est = 2.0  # Strong level repulsion
    else:
        beta_est = 0.0

    return (mean_s, std_s, beta_est)


if __name__ == "__main__":
    gamma1 = 14.134725
    theta = np.pi * gamma1

    print("q-Integer spectrum (first 10):")
    q_ints = chebyshev_recurrence(theta, 10)
    for i, q in enumerate(q_ints):
        print(f"  [{i}]_q = {q:.8f}")

    print("\nq-Casimir spectrum (first 10):")
    spec = casimir_spectrum(theta, 10)
    for i, c in enumerate(spec):
        print(f"  C_q({i}) = {c:.8f}")

    print("\nSpacing statistics:")
    mean_s, std_s, beta = spacing_statistics(spec)
    print(f"  Mean spacing: {mean_s:.6f}")
    print(f"  Std spacing:  {std_s:.6f}")
    print(f"  Estimated β:  {beta:.3f}")
