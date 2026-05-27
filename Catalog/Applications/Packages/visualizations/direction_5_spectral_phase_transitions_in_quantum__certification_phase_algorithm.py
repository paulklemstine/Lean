#!/usr/bin/env python3
"""
Certified Quantum Phase Certification Algorithms

Implements the verified certification pipeline from the Lean formalization:
given a Hermitian Hamiltonian H with spectral gap Δ and a noise operator N
of norm σ, compute the sharp certification threshold p* = Δ/(2σ) and
determine whether a perturbation strength p preserves the quantum phase.

All algorithms have correctness guarantees matching the formal Lean proofs.
"""

import numpy as np
from dataclasses import dataclass
from enum import Enum
from typing import Optional, Tuple, List


class PhaseRegime(Enum):
    """Classification of perturbation regime relative to certification threshold."""
    STABLE = "stable"       # p < p*, certification persists
    CRITICAL = "critical"   # p = p*, gap exactly closes
    UNSTABLE = "unstable"   # p > p*, no gap-based certification


@dataclass
class CertificationDiagnosis:
    """
    Complete certification diagnosis for a perturbed quantum system.

    Matches the Lean `CertificationDiagnosis` structure.

    Attributes:
        gap: Original spectral gap Δ
        perturbation: Perturbation strength p
        noise_norm: Noise operator norm σ = ‖N‖
        threshold: Certification threshold p* = Δ/(2σ)
        residual_gap: Residual gap Δ - 2pσ
        is_subcritical: Whether the perturbation is certified subcritical
        regime: Phase regime classification
    """
    gap: float
    perturbation: float
    noise_norm: float
    threshold: float
    residual_gap: float
    is_subcritical: bool
    regime: PhaseRegime


def cert_threshold(delta: float, sigma: float) -> float:
    """
    Compute the certification threshold p* = Δ/(2σ).

    This is the critical perturbation strength at which gap-based
    certification breaks down. The factor of 2 arises because both
    ground and excited energies can shift by up to p·σ.

    Theorem (certThreshold_spec): If p < p*, then Δ - 2pσ > 0.
    Theorem (no_certification_above_threshold): If p > p*, then Δ - 2pσ < 0.

    Parameters:
        delta: Spectral gap Δ > 0
        sigma: Noise operator norm σ ≥ 0

    Returns:
        p* = Δ/(2σ), or inf if σ = 0

    Complexity: O(1) time, O(1) space
    """
    if sigma <= 0:
        return float('inf')
    return delta / (2 * sigma)


def certification_residual_gap(delta: float, p: float, sigma: float) -> float:
    """
    Compute the certification residual gap Δ - 2pσ.

    The residual gap is positive iff the perturbation is subcritical
    (Theorem: certificationResidualGap_pos_iff).

    Parameters:
        delta: Spectral gap Δ
        p: Perturbation strength
        sigma: Noise operator norm σ

    Returns:
        Δ - 2pσ

    Complexity: O(1)
    """
    return delta - 2 * p * sigma


def certify_phase(delta: float, p: float, sigma: float) -> bool:
    """
    Decidable certification checker.

    Returns True iff the residual gap is positive, meaning the perturbation
    is certified to preserve the spectral gap.

    Sound (certifyPhase_sound): True output ⟹ 0 < Δ - 2pσ
    Complete (certifyPhase_complete): 0 < Δ - 2pσ ⟹ True output

    Parameters:
        delta: Spectral gap Δ
        p: Perturbation strength
        sigma: Noise operator norm σ

    Returns:
        Whether the perturbation is certified subcritical

    Complexity: O(1)
    """
    return certification_residual_gap(delta, p, sigma) > 0


def classify_regime(delta: float, p: float, sigma: float,
                    tol: float = 1e-12) -> PhaseRegime:
    """
    Classify the perturbation regime.

    Uses a tolerance for critical regime detection (exact equality
    is fragile in floating point).

    Parameters:
        delta: Spectral gap Δ
        p: Perturbation strength
        sigma: Noise operator norm σ
        tol: Tolerance for critical regime detection

    Returns:
        PhaseRegime enum value

    Complexity: O(1)
    """
    gap = certification_residual_gap(delta, p, sigma)
    if gap > tol:
        return PhaseRegime.STABLE
    elif abs(gap) <= tol:
        return PhaseRegime.CRITICAL
    else:
        return PhaseRegime.UNSTABLE


def diagnose(delta: float, p: float, sigma: float) -> CertificationDiagnosis:
    """
    Compute a full certification diagnosis.

    Matches the Lean `diagnose` function.

    Theorem (diagnose_sound): If diagnosis.is_subcritical, then
    diagnosis.residual_gap > 0.

    Parameters:
        delta: Spectral gap Δ
        p: Perturbation strength
        sigma: Noise operator norm σ

    Returns:
        CertificationDiagnosis with all fields populated

    Complexity: O(1)
    """
    threshold = cert_threshold(delta, sigma)
    residual = certification_residual_gap(delta, p, sigma)
    return CertificationDiagnosis(
        gap=delta,
        perturbation=p,
        noise_norm=sigma,
        threshold=threshold,
        residual_gap=residual,
        is_subcritical=certify_phase(delta, p, sigma),
        regime=classify_regime(delta, p, sigma)
    )


def spectral_gap_from_hamiltonian(H: np.ndarray,
                                   ground_dim: int = 1) -> float:
    """
    Compute the spectral gap of a Hermitian matrix H.

    The spectral gap is the difference between the (ground_dim)-th
    smallest eigenvalue and the (ground_dim+1)-th smallest.

    Parameters:
        H: Hermitian matrix
        ground_dim: Dimension of the ground space

    Returns:
        Spectral gap Δ

    Complexity: O(n³) for n×n matrix (eigenvalue decomposition)
    """
    eigenvalues = np.sort(np.linalg.eigvalsh(H))
    if ground_dim >= len(eigenvalues):
        return 0.0
    return eigenvalues[ground_dim] - eigenvalues[ground_dim - 1]


def diagnose_matrix(H: np.ndarray, N: np.ndarray, p: float,
                     ground_dim: int = 1) -> CertificationDiagnosis:
    """
    Full certification diagnosis from matrices.

    Computes the spectral gap of H, the operator norm of N, and
    returns a complete diagnosis.

    Parameters:
        H: Hermitian Hamiltonian matrix
        N: Hermitian noise matrix
        p: Perturbation strength
        ground_dim: Dimension of the ground space

    Returns:
        CertificationDiagnosis

    Complexity: O(n³) for eigenvalue decomposition
    """
    delta = spectral_gap_from_hamiltonian(H, ground_dim)
    sigma = np.linalg.norm(N, ord=2)
    return diagnose(delta, p, sigma)


def scan_transition(delta: float, sigma: float,
                    p_min: float = 0.0,
                    p_max: Optional[float] = None,
                    n_points: int = 100) -> Tuple[np.ndarray, np.ndarray, float]:
    """
    Scan the certification transition.

    Returns perturbation strengths, residual gaps, and the threshold.

    Parameters:
        delta: Spectral gap
        sigma: Noise norm
        p_min: Minimum perturbation strength
        p_max: Maximum perturbation strength (default: 2*p*)
        n_points: Number of scan points

    Returns:
        (p_values, residual_gaps, threshold)

    Complexity: O(n_points)
    """
    threshold = cert_threshold(delta, sigma)
    if p_max is None:
        p_max = 2 * threshold if np.isfinite(threshold) else 10.0
    p_values = np.linspace(p_min, p_max, n_points)
    residual_gaps = np.array([
        certification_residual_gap(delta, p, sigma) for p in p_values
    ])
    return p_values, residual_gaps, threshold


def multi_noise_comparison(delta: float,
                           sigma_values: List[float],
                           n_points: int = 100) -> dict:
    """
    Compare certification transitions across multiple noise scales.

    Demonstrates the antitonicity theorem: larger noise ⟹ earlier transition.

    Parameters:
        delta: Spectral gap
        sigma_values: List of noise scales to compare
        n_points: Number of scan points per noise scale

    Returns:
        Dictionary with thresholds and scan data

    Complexity: O(len(sigma_values) * n_points)
    """
    results = {}
    for sigma in sigma_values:
        p_vals, gaps, threshold = scan_transition(delta, sigma, n_points=n_points)
        results[sigma] = {
            'p_values': p_vals,
            'residual_gaps': gaps,
            'threshold': threshold
        }
    return results


# ─────────────────────────────────────────────────────────────────
# Example usage
# ─────────────────────────────────────────────────────────────────

if __name__ == "__main__":
    print("Spectral Phase Transition Certification Algorithms")
    print("=" * 55)

    # Example 1: Simple diagnosis
    print("\n--- Example 1: Simple diagnosis ---")
    d = diagnose(delta=2.0, p=0.3, sigma=1.0)
    print(f"Diagnosis: {d}")
    print(f"  Threshold: {d.threshold:.4f}")
    print(f"  Residual gap: {d.residual_gap:.4f}")
    print(f"  Subcritical: {d.is_subcritical}")
    print(f"  Regime: {d.regime.value}")

    # Example 2: Matrix-based diagnosis
    print("\n--- Example 2: Matrix-based diagnosis ---")
    n = 10
    H = np.diag([0.0] * 2 + [2.0 + 0.1 * i for i in range(n - 2)])
    rng = np.random.default_rng(42)
    A = rng.standard_normal((n, n))
    N = (A + A.T) / 2
    N = N / np.linalg.norm(N, ord=2)

    d = diagnose_matrix(H, N, p=0.5, ground_dim=2)
    print(f"  Gap: {d.gap:.4f}")
    print(f"  Noise norm: {d.noise_norm:.4f}")
    print(f"  Threshold: {d.threshold:.4f}")
    print(f"  Subcritical: {d.is_subcritical}")

    # Example 3: Transition scan
    print("\n--- Example 3: Transition scan ---")
    p_vals, gaps, threshold = scan_transition(2.0, 1.0, n_points=10)
    print(f"  Threshold: {threshold:.4f}")
    for p, g in zip(p_vals, gaps):
        status = "✓" if g > 0 else "✗"
        print(f"  p = {p:.3f}, gap = {g:.3f} {status}")

    print("\nAll examples completed successfully.")
