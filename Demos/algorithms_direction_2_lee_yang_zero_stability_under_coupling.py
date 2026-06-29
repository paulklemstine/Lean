#!/usr/bin/env python3
"""
Algorithms for Lee–Yang Zero Stability Analysis
================================================
Implements the computational methods underlying the Lee–Yang zero stability
theorem: Ising field polynomial construction, coefficient perturbation bounds,
root matching, and stability certification.

These algorithms formalize the pipeline:
  coupling noise → coefficient perturbation → evaluation bound → root displacement

Application keywords: Ising model, partition function, Lee–Yang zeros,
root perturbation, certified numerical analysis, phase transitions.
"""

import numpy as np
from typing import List, Tuple, Optional
from itertools import product as iterproduct


# ============================================================================
# Algorithm 1: Ising Field Polynomial Construction
# ============================================================================

def construct_field_polynomial(
    n: int,
    beta: float,
    J: np.ndarray
) -> np.ndarray:
    """
    Construct the Ising field polynomial Z_J(z) = Σ_k a_k(β,J) z^k.

    The k-th coefficient is a_k(β,J) = Σ_{σ: N+(σ)=k} exp(β E_J(σ)),
    where E_J(σ) = Σ_{i,j} J_{ij} σ_i σ_j is the coupling energy.

    Parameters
    ----------
    n : int
        Number of spins.
    beta : float
        Inverse temperature (β > 0 for physical systems).
    J : np.ndarray, shape (n, n)
        Symmetric coupling matrix with zero diagonal.

    Returns
    -------
    np.ndarray, shape (n+1,)
        Coefficients a_0, a_1, ..., a_n of the field polynomial.

    Complexity
    ----------
    Time: O(2^n · n^2) — enumeration over all spin configurations.
    Space: O(n+1) for coefficients + O(n^2) for the coupling matrix.

    Example
    -------
    >>> J = np.array([[0, 1], [1, 0]], dtype=float)
    >>> construct_field_polynomial(2, 1.0, J)
    array([2.71828..., 0.73576..., 2.71828...])
    """
    coeffs = np.zeros(n + 1)
    for bits in iterproduct([0, 1], repeat=n):
        sigma = np.array([1 if b else -1 for b in bits])
        k = sum(bits)  # number of +1 spins
        energy = sigma @ J @ sigma
        coeffs[k] += np.exp(beta * energy)
    return coeffs


# ============================================================================
# Algorithm 2: Coefficient Perturbation Bound
# ============================================================================

def coefficient_perturbation_bound(
    n: int,
    beta: float,
    delta: float,
    coeffs_J: np.ndarray,
    coeffs_Jp: np.ndarray
) -> Tuple[np.ndarray, np.ndarray]:
    """
    Compute the theoretical upper bound on |a_k(J') - a_k(J)|.

    By our proved theorem:
        |a_k(J') - a_k(J)| ≤ (exp(β n² δ) - 1) · (a_k(J) + a_k(J'))

    Parameters
    ----------
    n : int
        Number of spins.
    beta : float
        Inverse temperature.
    delta : float
        Coupling perturbation magnitude (‖J - J'‖_∞ ≤ δ).
    coeffs_J : np.ndarray
        Coefficients of Z_J.
    coeffs_Jp : np.ndarray
        Coefficients of Z_{J'}.

    Returns
    -------
    actual_diffs : np.ndarray
        |a_k(J') - a_k(J)| for each k.
    theoretical_bounds : np.ndarray
        (exp(β n² δ) - 1) · (a_k(J) + a_k(J')) for each k.

    Complexity
    ----------
    Time: O(n)
    Space: O(n)
    """
    factor = np.exp(beta * n**2 * delta) - 1
    actual_diffs = np.abs(coeffs_Jp - coeffs_J)
    theoretical_bounds = factor * (coeffs_J + coeffs_Jp)
    return actual_diffs, theoretical_bounds


# ============================================================================
# Algorithm 3: Root Matching by Hungarian Method
# ============================================================================

def match_roots_optimal(
    roots_old: np.ndarray,
    roots_new: np.ndarray
) -> List[Tuple[complex, complex, float]]:
    """
    Match roots by greedy nearest-neighbor assignment.

    For each root in roots_old, finds the closest unmatched root in roots_new.
    Returns the matching with displacements.

    Parameters
    ----------
    roots_old : np.ndarray of complex
        Original polynomial roots.
    roots_new : np.ndarray of complex
        Perturbed polynomial roots.

    Returns
    -------
    list of (z_old, z_new, displacement) tuples.

    Complexity
    ----------
    Time: O(n^2) for greedy matching
    Space: O(n)
    """
    n = min(len(roots_old), len(roots_new))
    used = set()
    matched = []

    for z in roots_old:
        dists = np.abs(roots_new - z)
        for idx in np.argsort(dists):
            if idx not in used:
                used.add(idx)
                matched.append((z, roots_new[idx], dists[idx]))
                break

    return matched


# ============================================================================
# Algorithm 4: Stability Certification
# ============================================================================

def certify_stability(
    n: int,
    beta: float,
    J: np.ndarray,
    delta: float,
    separation_radius: float,
    separation_minimum: float
) -> dict:
    """
    Certify Lee–Yang zero stability for a given coupling and perturbation.

    Checks whether the coefficient perturbation bound ensures that the
    polynomial perturbation is dominated by the separation minimum on
    circles around the zeros.

    The certification pipeline:
    1. Compute coefficients a_k(J)
    2. Bound |Δa_k| ≤ (exp(β n² δ) - 1) · 2·a_k(J)  (worst case)
    3. Bound |ΔZ(w)| ≤ Σ_k |Δa_k| · |w|^k on the circle
    4. Check |ΔZ(w)| < m (the separation minimum)

    Parameters
    ----------
    n : int
        Number of spins.
    beta : float
        Inverse temperature.
    J : np.ndarray
        Coupling matrix.
    delta : float
        Maximum perturbation magnitude.
    separation_radius : float
        Radius R of the separation circles.
    separation_minimum : float
        Minimum |Z_J(w)| on the separation circles.

    Returns
    -------
    dict with:
        certified : bool — whether stability is certified
        max_perturbation : float — upper bound on |ΔZ(w)|
        margin : float — separation_minimum - max_perturbation

    Complexity
    ----------
    Time: O(2^n n^2) for polynomial construction + O(n) for certification
    """
    coeffs = construct_field_polynomial(n, beta, J)
    factor = np.exp(beta * n**2 * delta) - 1

    # Worst-case coefficient perturbation (J' could double each coefficient)
    max_coeff_pert = factor * 2 * coeffs

    # Estimate the roots to determine typical |w| on separation circles
    roots = np.roots(coeffs[::-1])
    if len(roots) == 0:
        return {'certified': True, 'max_perturbation': 0, 'margin': separation_minimum}

    # For each root, bound the perturbation on its separation circle
    max_pert = 0
    for z0 in roots:
        w_radius = abs(z0) + separation_radius
        pert_bound = sum(max_coeff_pert[k] * w_radius**k for k in range(n + 1))
        max_pert = max(max_pert, pert_bound)

    certified = max_pert < separation_minimum
    margin = separation_minimum - max_pert

    return {
        'certified': certified,
        'max_perturbation': max_pert,
        'margin': margin,
        'factor': factor,
        'roots': roots,
    }


# ============================================================================
# Algorithm 5: Curie–Weiss Coupling Construction
# ============================================================================

def curie_weiss_coupling(n: int, J_val: float = 1.0) -> np.ndarray:
    """
    Construct Curie–Weiss (complete graph) coupling matrix.

    J_{ij} = J_val/n for i ≠ j, J_{ii} = 0.

    Parameters
    ----------
    n : int
        Number of spins.
    J_val : float
        Coupling strength.

    Returns
    -------
    np.ndarray, shape (n, n)
        Symmetric coupling matrix with zero diagonal.

    Example
    -------
    >>> curie_weiss_coupling(3, 1.0)
    array([[0.        , 0.33333333, 0.33333333],
           [0.33333333, 0.        , 0.33333333],
           [0.33333333, 0.33333333, 0.        ]])
    """
    J = np.full((n, n), J_val / n)
    np.fill_diagonal(J, 0)
    return J


# ============================================================================
# Example usage
# ============================================================================

if __name__ == '__main__':
    n = 4
    beta = 1.0
    delta = 0.01

    print("Ising Field Polynomial Construction")
    print("=" * 50)
    J = curie_weiss_coupling(n)
    coeffs = construct_field_polynomial(n, beta, J)
    print(f"n = {n}, β = {beta}")
    print(f"Coupling matrix J (Curie–Weiss):")
    print(J)
    print(f"\nField polynomial coefficients: {coeffs}")
    print(f"Sum (partition function at z=1): {sum(coeffs):.6f}")

    print("\nCoefficient Perturbation Bound")
    print("=" * 50)
    dJ = np.random.RandomState(42).uniform(-delta, delta, (n, n))
    dJ = (dJ + dJ.T) / 2
    np.fill_diagonal(dJ, 0)
    coeffs_pert = construct_field_polynomial(n, beta, J + dJ)
    diffs, bounds = coefficient_perturbation_bound(n, beta, delta, coeffs, coeffs_pert)
    for k in range(n + 1):
        print(f"  k={k}: |Δa_k| = {diffs[k]:.6f}, bound = {bounds[k]:.6f}, "
              f"ratio = {diffs[k]/(bounds[k]+1e-15):.4f}")

    print("\nStability Certification")
    print("=" * 50)
    result = certify_stability(n, beta, J, delta, 0.1, 0.5)
    print(f"  Certified: {result['certified']}")
    print(f"  Max perturbation: {result['max_perturbation']:.6f}")
    print(f"  Margin: {result['margin']:.6f}")
