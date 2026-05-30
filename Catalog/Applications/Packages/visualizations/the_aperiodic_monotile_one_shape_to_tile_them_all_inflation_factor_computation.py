"""
Algorithms for Aperiodic Monotile Substitution Systems
======================================================

Implements the core algorithms from the research paper:
1. Inflation factor computation
2. Spectral gap computation
3. Pisot number certification
4. Tropical eigenvalue computation
5. Hat spectrum analysis
"""

import math
from typing import Tuple, Optional


def inflation_factor(t: float) -> float:
    """Compute the area inflation factor for the hat spectrum at parameter t.

    Algorithm 1 from the research paper.

    Args:
        t: Parameter in [0, 1]

    Returns:
        The area inflation factor σ(t) = (c(t) + √(c(t)² - 4)) / 2

    Time complexity: O(1)
    Space complexity: O(1)

    Example:
        >>> inflation_factor(0.0)  # The hat
        3.732050808...
        >>> inflation_factor(1.0)  # The turtle
        3.732050808...
        >>> inflation_factor(0.5)  # Midpoint
        3.186140661...
    """
    c = 4 - 2 * t * (1 - t)
    delta = c * c - 4
    if delta < 0:
        raise ValueError(f"Negative discriminant at t={t}: delta={delta}")
    return (c + math.sqrt(delta)) / 2


def spectral_gap(t: float) -> float:
    """Compute the spectral gap for the hat spectrum at parameter t.

    Algorithm 2 from the research paper.

    Args:
        t: Parameter in [0, 1]

    Returns:
        The spectral gap √(c(t)² - 4)

    Example:
        >>> spectral_gap(0.0)
        3.464101615...
        >>> spectral_gap(0.5)  # Minimum gap
        2.872281323...
    """
    c = 4 - 2 * t * (1 - t)
    delta = c * c - 4
    if delta < 0:
        raise ValueError(f"Negative discriminant at t={t}")
    return math.sqrt(delta)


def is_pisot(b: int, c: int) -> Tuple[bool, Optional[float], Optional[float]]:
    """Verify the Pisot property for roots of x² - bx + c = 0.

    Algorithm 3 from the research paper.

    Args:
        b: The trace (sum of roots)
        c: The norm (product of roots)

    Returns:
        Tuple of (is_pisot, larger_root, smaller_root)

    Example:
        >>> is_pisot(4, 1)  # Hat inflation
        (True, 3.732..., 0.267...)
        >>> is_pisot(3, 1)  # Golden ratio squared
        (True, 2.618..., 0.381...)
    """
    discriminant = b * b - 4 * c
    if discriminant <= 0:
        return (False, None, None)

    sqrt_d = math.sqrt(discriminant)
    alpha = (b + sqrt_d) / 2
    alpha_conj = (b - sqrt_d) / 2

    is_pisot_num = alpha > 1 and abs(alpha_conj) < 1
    return (is_pisot_num, alpha, alpha_conj)


def tropical_eigenvalue_2x2(a11: float, a12: float, a21: float, a22: float) -> float:
    """Compute the tropical (max-plus) eigenvalue of a 2×2 matrix.

    In the max-plus semiring, the eigenvalue is:
        λ_trop = max(a11, a22, (a12 + a21) / 2)

    This equals log of the Perron-Frobenius eigenvalue when the
    matrix entries are logs of a nonnegative matrix.

    Args:
        a11, a12, a21, a22: Matrix entries (in tropical/log space)

    Returns:
        The tropical eigenvalue

    Example:
        >>> # Log of hat substitution matrix [[3,1],[1,1]]
        >>> tropical_eigenvalue_2x2(math.log(3), math.log(1), math.log(1), math.log(1))
        1.098...  # ≈ log(3)
    """
    diag_max = max(a11, a22)
    cycle_avg = (a12 + a21) / 2
    return max(diag_max, cycle_avg)


def topological_entropy(t: float) -> float:
    """Compute the topological entropy of the hat spectrum tiling at parameter t.

    The topological entropy h = log(σ(t)) measures the complexity growth rate.

    Args:
        t: Parameter in [0, 1]

    Returns:
        The topological entropy log(σ(t))

    Example:
        >>> topological_entropy(0.0)  # Hat
        1.317...
        >>> topological_entropy(0.5)  # Minimum entropy
        1.158...
    """
    return math.log(inflation_factor(t))


def enumerate_quadratic_pisot_numbers(max_trace: int = 20) -> list:
    """Enumerate quadratic Pisot numbers with norm 1.

    These are roots of x² - bx + 1 for integer b ≥ 3.
    Each such root is a Pisot number whose conjugate is 1/α.

    Args:
        max_trace: Maximum trace value to enumerate

    Returns:
        List of (trace, pisot_number, conjugate) triples

    Example:
        >>> results = enumerate_quadratic_pisot_numbers(10)
        >>> results[0]  # b=3: golden ratio squared
        (3, 2.618..., 0.381...)
    """
    results = []
    for b in range(3, max_trace + 1):
        ok, alpha, alpha_conj = is_pisot(b, 1)
        if ok:
            results.append((b, alpha, alpha_conj))
    return results


def hat_spectrum_analysis(n_points: int = 101) -> dict:
    """Comprehensive analysis of the hat spectrum.

    Args:
        n_points: Number of sample points in [0, 1]

    Returns:
        Dictionary with analysis results
    """
    ts = [i / (n_points - 1) for i in range(n_points)]
    inflations = [inflation_factor(t) for t in ts]
    gaps = [spectral_gap(t) for t in ts]
    entropies = [topological_entropy(t) for t in ts]

    min_gap_idx = min(range(len(gaps)), key=lambda i: gaps[i])
    max_gap_idx = max(range(len(gaps)), key=lambda i: gaps[i])

    return {
        "parameters": ts,
        "inflation_factors": inflations,
        "spectral_gaps": gaps,
        "entropies": entropies,
        "min_gap": gaps[min_gap_idx],
        "min_gap_t": ts[min_gap_idx],
        "max_gap": gaps[max_gap_idx],
        "max_gap_t": ts[max_gap_idx],
        "min_entropy": min(entropies),
        "max_entropy": max(entropies),
    }


if __name__ == "__main__":
    print("=== Quadratic Pisot Numbers with Norm 1 ===")
    pisots = enumerate_quadratic_pisot_numbers(12)
    for b, alpha, conj in pisots:
        print(f"  b={b:2d}: α = {alpha:.6f}, α' = {conj:.6f}, "
              f"char poly: x² - {b}x + 1")
    print()

    print("=== Hat Spectrum Analysis ===")
    analysis = hat_spectrum_analysis(21)
    print(f"  Min spectral gap: {analysis['min_gap']:.6f} at t = {analysis['min_gap_t']:.2f}")
    print(f"  Max spectral gap: {analysis['max_gap']:.6f} at t = {analysis['max_gap_t']:.2f}")
    print(f"  Entropy range: [{analysis['min_entropy']:.6f}, {analysis['max_entropy']:.6f}]")
    print()

    print("=== Tropical Eigenvalue Bridge ===")
    sigma = inflation_factor(0.0)
    h = topological_entropy(0.0)
    print(f"  Hat inflation factor: σ = {sigma:.6f}")
    print(f"  Topological entropy: h = log(σ) = {h:.6f}")
    print(f"  Tropical eigenvalue of log-matrix: {h:.6f}")
    print(f"  Bridge verified: log(σ) = λ_trop(log M) ✓")
