#!/usr/bin/env python3
"""
Algorithms for Certified Mass Gap Bounds

Implements the key algorithms from the research paper:
1. Interval arithmetic eigenvalue certification
2. Casimir-based mass gap bounding
3. Strong coupling expansion evaluation
4. Tightness ratio computation
"""

import math
from typing import Tuple, List, Optional


def interval_mul(a: Tuple[float, float], b: Tuple[float, float]) -> Tuple[float, float]:
    """Multiply two intervals [a_lo, a_hi] * [b_lo, b_hi].

    Uses the standard interval arithmetic rule: the product interval is
    [min(products), max(products)] over all four endpoint combinations.

    Args:
        a: Interval (a_lo, a_hi) with a_lo <= a_hi
        b: Interval (b_lo, b_hi) with b_lo <= b_hi

    Returns:
        Product interval (lo, hi)
    """
    products = [a[0]*b[0], a[0]*b[1], a[1]*b[0], a[1]*b[1]]
    return (min(products), max(products))


def interval_div(a: Tuple[float, float], b: Tuple[float, float]) -> Tuple[float, float]:
    """Divide interval a by interval b, assuming 0 not in b.

    Args:
        a: Numerator interval
        b: Denominator interval (must not contain 0)

    Returns:
        Quotient interval
    """
    assert b[0] > 0 or b[1] < 0, "Division by interval containing 0"
    return interval_mul(a, (1.0/b[1], 1.0/b[0]))


def interval_log(a: Tuple[float, float]) -> Tuple[float, float]:
    """Compute log of a positive interval.

    Args:
        a: Interval with a[0] > 0

    Returns:
        Log interval
    """
    assert a[0] > 0, "Log requires positive interval"
    return (math.log(a[0]), math.log(a[1]))


def casimir_mass_gap_bound(c: float, beta: float) -> float:
    """Compute the Casimir-based mass gap lower bound.

    For SU(N) gauge theory with fundamental sector coefficient c,
    the mass gap is bounded below by -log(c * beta).

    Args:
        c: Fundamental sector coefficient (e.g., 2 for SU(2))
        beta: Inverse coupling parameter

    Returns:
        Lower bound on the mass gap

    Complexity: O(1) time and space
    """
    assert c > 0 and beta > 0, "Requires positive c and beta"
    return -math.log(c * beta)


def certified_gap_bounds(ev_interval: Tuple[float, float],
                         exc_interval: Tuple[float, float]) -> Tuple[float, float]:
    """Compute certified mass gap bounds from eigenvalue intervals.

    Given intervals [ev_lo, ev_hi] for the ground state eigenvalue and
    [exc_lo, exc_hi] for the first excitation, returns rigorous bounds
    on the mass gap log(ev/exc).

    Args:
        ev_interval: Ground state eigenvalue interval (must be positive)
        exc_interval: First excitation eigenvalue interval (must be positive)

    Returns:
        (gap_lower, gap_upper) - certified mass gap bounds

    Complexity: O(1) time and space

    Example:
        >>> certified_gap_bounds((0.95, 1.05), (0.05, 0.08))
        (2.474, 3.045)
    """
    ev_lo, ev_hi = ev_interval
    exc_lo, exc_hi = exc_interval

    assert ev_lo > 0 and exc_lo > 0, "Eigenvalues must be positive"
    assert exc_hi < ev_lo, "Gap must exist"

    gap_lower = math.log(ev_lo / exc_hi)
    gap_upper = math.log(ev_hi / exc_lo)
    return (gap_lower, gap_upper)


def tightness_ratio(ev_interval: Tuple[float, float],
                    exc_interval: Tuple[float, float]) -> float:
    """Compute the tightness ratio of certified gap bounds.

    A ratio of 1 means the bounds are perfectly tight (zero uncertainty).
    The ratio is always in (0, 1].

    Args:
        ev_interval: Ground state eigenvalue interval
        exc_interval: First excitation eigenvalue interval

    Returns:
        Tightness ratio in (0, 1]

    Complexity: O(1)
    """
    gap_lo, gap_hi = certified_gap_bounds(ev_interval, exc_interval)
    return gap_lo / gap_hi


def strong_coupling_eval(a0: float, a1: float, beta: float) -> float:
    """Evaluate a strong coupling expansion a0 + a1 * beta.

    Args:
        a0: Leading coefficient
        a1: First-order coefficient
        beta: Coupling parameter

    Returns:
        Evaluated expansion
    """
    return a0 + a1 * beta


def gap_perturbation_bound(delta: float) -> float:
    """Maximum shift in spectral gap from eigenvalue perturbation delta.

    Theorem: If each eigenvalue is perturbed by at most delta,
    the spectral gap shifts by at most 2*delta.

    Args:
        delta: Maximum eigenvalue perturbation

    Returns:
        Maximum gap perturbation (= 2*delta)
    """
    return 2 * delta


def finite_volume_correction(m_inf: float, C: float, L: int) -> Tuple[float, float]:
    """Compute finite-volume gap bounds.

    For an L×L lattice with infinite-volume gap m_inf and correction
    constant C, the finite-volume gap lies in [m_inf - C/L², m_inf + C/L²].

    Args:
        m_inf: Infinite-volume mass gap
        C: Finite-size correction constant
        L: Lattice linear size

    Returns:
        (gap_lower, gap_upper) bounds
    """
    correction = C / L**2
    return (m_inf - correction, m_inf + correction)


def find_minimum_lattice_size(m_inf: float, C: float) -> int:
    """Find minimum lattice size for positive finite-volume gap.

    Returns the smallest L such that m_inf - C/L² > 0.

    Args:
        m_inf: Infinite-volume mass gap (must be positive)
        C: Correction constant (must be positive)

    Returns:
        Minimum lattice size L₀

    Complexity: O(sqrt(C/m_inf))
    """
    assert m_inf > 0 and C > 0
    L = 1
    while m_inf - C / L**2 <= 0:
        L += 1
    return L


def transfer_matrix_su2(beta: float, L: int) -> List[float]:
    """Approximate SU(2) transfer matrix eigenvalues.

    Uses the strong coupling expansion for an L×L lattice:
    - Ground state: 1 + O(β)
    - First excitation: 2β + O(β²)
    - Higher excitations: O(β²)

    Args:
        beta: Inverse coupling
        L: Lattice linear size

    Returns:
        List of approximate eigenvalues (sorted descending)
    """
    n_plaquettes = (L - 1) ** 2
    ground = 1.0 + n_plaquettes * (-0.5 * beta**2)
    excite1 = 2 * beta * (1 + n_plaquettes * (-0.3 * beta))
    excite2 = beta**2 * (1 + n_plaquettes * (-0.2 * beta))
    return sorted([ground, excite1, excite2], reverse=True)


# ─── Example usage ───

if __name__ == "__main__":
    print("Certified Mass Gap Bounds - Algorithm Examples")
    print("=" * 50)

    # Example 1: Casimir bound
    for beta in [0.1, 0.2, 0.3]:
        bound = casimir_mass_gap_bound(2.0, beta)
        print(f"SU(2) Casimir bound at β={beta}: {bound:.4f}")

    # Example 2: Certified gap
    gap = certified_gap_bounds((0.95, 1.05), (0.05, 0.08))
    print(f"\nCertified gap bounds: [{gap[0]:.4f}, {gap[1]:.4f}]")
    print(f"Tightness: {tightness_ratio((0.95, 1.05), (0.05, 0.08)):.4f}")

    # Example 3: Minimum lattice size
    L0 = find_minimum_lattice_size(1.5, 10.0)
    print(f"\nMinimum lattice size for positive gap: L₀ = {L0}")

    # Example 4: Transfer matrix
    for L in [2, 3, 4]:
        eigs = transfer_matrix_su2(0.2, L)
        gap = math.log(eigs[0] / eigs[1]) if eigs[1] > 0 else float('inf')
        print(f"SU(2) L={L}: eigs={[f'{e:.4f}' for e in eigs]}, gap={gap:.4f}")
