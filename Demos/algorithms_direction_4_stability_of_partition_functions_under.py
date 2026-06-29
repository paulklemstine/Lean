#!/usr/bin/env python3
"""
Algorithms for Ising Partition Function Stability Analysis

Implements:
1. Robustness certificate for noisy Ising couplings
2. Partition function computation with numerical stability
3. Covariance matrix computation
4. Spectral gap estimation

All algorithms correspond to formally verified theorems in the Lean development.
"""

import numpy as np
from typing import Tuple, Optional, Dict, List
from itertools import product


# =============================================================================
# Algorithm 1: Robustness Certificate
# =============================================================================

def certify_log_concavity_under_noise(
    n: int,
    beta: float,
    J: np.ndarray,
    delta: float,
    spectral_gap: Optional[float] = None,
) -> Dict:
    """
    Certify that coupling perturbation of size delta preserves Lorentzian
    signature structure of the Ising model.

    Corresponds to the formal theorem `certified_robustness_preserves_signature`:
    If HasGappedSignature(J, ε) and δ ≤ ε/(2n²), then
    HasAtMostOnePositiveEigenvalue(J') for all J' with |J'_{ij} - J_{ij}| ≤ δ.

    Also computes the log-Lipschitz bound from `isingPartition_logLipschitz`:
    |log Z(J') - log Z(J)| ≤ β n² δ.

    Args:
        n: Number of spins
        beta: Inverse temperature (> 0)
        J: Coupling matrix (n × n)
        delta: Perturbation radius
        spectral_gap: If known, the spectral gap ε. If None, estimated from J.

    Returns:
        Dictionary with:
        - certified: bool, whether the perturbation is within safe regime
        - spectral_gap: estimated or provided gap
        - safe_delta: maximum safe perturbation
        - free_energy_bound: upper bound on |log Z' - log Z|
        - message: human-readable explanation
    """
    assert n > 0 and beta > 0 and delta >= 0

    # Estimate spectral gap if not provided
    if spectral_gap is None:
        spectral_gap = _estimate_spectral_gap(J)

    # Certified tolerance: ε / (2n²)
    safe_delta = spectral_gap / (2.0 * n**2)

    # Check certification
    certified = delta <= safe_delta

    # Log-Lipschitz bound
    free_energy_bound = beta * n**2 * delta

    # Gibbs weight stability bound
    gibbs_bound = 2 * beta * n**2 * delta

    return {
        'certified': certified,
        'spectral_gap': spectral_gap,
        'safe_delta': safe_delta,
        'free_energy_bound': free_energy_bound,
        'gibbs_weight_bound': gibbs_bound,
        'message': (
            f"{'CERTIFIED' if certified else 'NOT CERTIFIED'}: "
            f"δ={delta:.6f} {'≤' if certified else '>'} "
            f"ε/(2n²)={safe_delta:.6f}"
        ),
    }


def _estimate_spectral_gap(J: np.ndarray) -> float:
    """
    Estimate the spectral gap of the coupling matrix J.

    The spectral gap is the minimum absolute value of the negative eigenvalues
    of the symmetric part of J. This controls how robustly the Lorentzian
    signature condition holds.

    Time complexity: O(n³) for eigenvalue decomposition.
    Space complexity: O(n²).
    """
    n = J.shape[0]
    # Symmetrize
    J_sym = (J + J.T) / 2
    eigenvalues = np.linalg.eigvalsh(J_sym)

    # The spectral gap is the magnitude of the most negative eigenvalue
    # that's not too close to zero
    negative_eigs = eigenvalues[eigenvalues < -1e-12]
    if len(negative_eigs) == 0:
        return 0.0  # No negative eigenvalues

    # Use the minimum absolute value of negative eigenvalues as gap
    return float(np.min(np.abs(negative_eigs)))


# =============================================================================
# Algorithm 2: Numerically Stable Partition Function
# =============================================================================

def compute_partition_function(
    n: int,
    beta: float,
    J: np.ndarray,
    h: np.ndarray,
) -> Tuple[float, float]:
    """
    Compute the Ising partition function Z and log Z with numerical stability.

    Uses the log-sum-exp trick to avoid overflow/underflow.

    Corresponds to the formal definition `isingPartition`.

    Args:
        n: Number of spins
        beta: Inverse temperature
        J: Coupling matrix (n × n)
        h: External field vector (n,)

    Returns:
        (Z, log_Z): partition function and its logarithm

    Time complexity: O(2^n · n²) for computing all energies.
    Space complexity: O(2^n) for storing energies.
    """
    configs = np.array(list(product([-1, 1], repeat=n)), dtype=float)

    # Compute energies for all configurations
    energies = np.array([
        np.dot(h, s) + s @ J @ s
        for s in configs
    ])

    # Log-sum-exp for numerical stability
    beta_energies = beta * energies
    max_be = np.max(beta_energies)
    log_Z = max_be + np.log(np.sum(np.exp(beta_energies - max_be)))
    Z = np.exp(log_Z)

    return float(Z), float(log_Z)


# =============================================================================
# Algorithm 3: Covariance Matrix and Susceptibility
# =============================================================================

def compute_covariance_matrix(
    n: int,
    beta: float,
    J: np.ndarray,
    h: np.ndarray,
) -> np.ndarray:
    """
    Compute the spin covariance matrix Cov(σ_i, σ_j).

    Corresponds to the formal definition `spinCovariance` and the theorem
    `covarianceForm_eq_variance` which proves this equals the variance
    of linear spin observables.

    The covariance matrix is always positive semidefinite
    (theorem `covarianceForm_nonneg`).

    Args:
        n: Number of spins
        beta: Inverse temperature
        J: Coupling matrix (n × n)
        h: External field vector (n,)

    Returns:
        Covariance matrix (n × n), guaranteed PSD.

    Time complexity: O(2^n · n²).
    Space complexity: O(2^n + n²).
    """
    configs = np.array(list(product([-1, 1], repeat=n)), dtype=float)

    # Compute Gibbs weights
    energies = np.array([np.dot(h, s) + s @ J @ s for s in configs])
    beta_energies = beta * energies
    beta_energies -= np.max(beta_energies)
    weights = np.exp(beta_energies)
    weights /= np.sum(weights)

    # Compute expectations
    mean_sigma = configs.T @ weights  # (n,)

    # Covariance: E[σσ^T] - E[σ]E[σ]^T
    cov = np.zeros((n, n))
    for k in range(len(configs)):
        cov += weights[k] * np.outer(configs[k], configs[k])
    cov -= np.outer(mean_sigma, mean_sigma)

    return cov


def verify_covariance_identity(
    n: int,
    beta: float,
    J: np.ndarray,
    h: np.ndarray,
    v: np.ndarray,
) -> Dict:
    """
    Verify the covariance form identity:
    ∑_{i,j} Cov(σ_i, σ_j) v_i v_j = E[(∑ v_i σ_i)²] - E[∑ v_i σ_i]²

    This is the computational verification of theorem `covarianceForm_eq_variance`.

    Returns:
        Dictionary with LHS, RHS, and verification status.
    """
    configs = np.array(list(product([-1, 1], repeat=n)), dtype=float)

    energies = np.array([np.dot(h, s) + s @ J @ s for s in configs])
    beta_energies = beta * energies
    beta_energies -= np.max(beta_energies)
    weights = np.exp(beta_energies)
    weights /= np.sum(weights)

    # LHS: v^T Cov v
    cov = compute_covariance_matrix(n, beta, J, h)
    lhs = v @ cov @ v

    # RHS: E[(v·σ)²] - E[v·σ]²
    linear_obs = configs @ v
    E_sq = np.sum(weights * linear_obs**2)
    E_val = np.sum(weights * linear_obs)
    rhs = E_sq - E_val**2

    return {
        'lhs': float(lhs),
        'rhs': float(rhs),
        'difference': float(abs(lhs - rhs)),
        'verified': abs(lhs - rhs) < 1e-10,
    }


# =============================================================================
# Algorithm 4: Perturbation Analysis
# =============================================================================

def analyze_perturbation_stability(
    n: int,
    beta: float,
    J: np.ndarray,
    delta: float,
    h: np.ndarray,
    num_trials: int = 100,
    seed: int = 42,
) -> Dict:
    """
    Analyze the stability of the partition function under coupling perturbation.

    Verifies the bound from theorem `isingPartition_logLipschitz`:
    |log Z(J') - log Z(J)| ≤ β n² δ

    And the Gibbs weight bound from theorem `gibbs_weight_ratio_bound`:
    |w(σ; J') - w(σ; J)| ≤ 2β n² δ

    Args:
        n: Number of spins
        beta: Inverse temperature
        J: Base coupling matrix
        delta: Perturbation radius
        h: External field
        num_trials: Number of random perturbations to test
        seed: Random seed

    Returns:
        Dictionary with statistics and verification results.
    """
    rng = np.random.default_rng(seed)

    _, log_Z_base = compute_partition_function(n, beta, J, h)
    theoretical_bound = beta * n**2 * delta

    log_diffs = []
    for _ in range(num_trials):
        noise = rng.uniform(-delta, delta, size=(n, n))
        noise = (noise + noise.T) / 2
        np.fill_diagonal(noise, 0)
        J_pert = J + noise

        _, log_Z_pert = compute_partition_function(n, beta, J_pert, h)
        log_diffs.append(abs(log_Z_pert - log_Z_base))

    log_diffs = np.array(log_diffs)

    return {
        'n': n,
        'beta': beta,
        'delta': delta,
        'theoretical_bound': theoretical_bound,
        'max_observed': float(np.max(log_diffs)),
        'mean_observed': float(np.mean(log_diffs)),
        'bound_ratio': float(np.max(log_diffs) / theoretical_bound) if theoretical_bound > 0 else 0,
        'all_within_bound': bool(np.all(log_diffs <= theoretical_bound * 1.001)),
    }


# =============================================================================
# Example Usage
# =============================================================================

if __name__ == '__main__':
    print("=" * 60)
    print("  Ising Partition Function Stability — Algorithm Suite")
    print("=" * 60)
    print()

    n = 6
    beta = 1.0
    J = np.ones((n, n)) / n
    np.fill_diagonal(J, 0)
    h = np.zeros(n)

    # 1. Robustness Certificate
    print("--- Algorithm 1: Robustness Certificate ---")
    cert = certify_log_concavity_under_noise(n, beta, J, delta=0.001)
    print(f"  {cert['message']}")
    print(f"  Free energy bound: {cert['free_energy_bound']:.6f}")
    print()

    # 2. Partition Function
    print("--- Algorithm 2: Partition Function ---")
    Z, logZ = compute_partition_function(n, beta, J, h)
    print(f"  Z = {Z:.6f}, log Z = {logZ:.6f}")
    print()

    # 3. Covariance Matrix
    print("--- Algorithm 3: Covariance Matrix ---")
    cov = compute_covariance_matrix(n, beta, J, h)
    eigs = np.linalg.eigvalsh(cov)
    print(f"  Eigenvalues: {np.sort(eigs)}")
    print(f"  All nonneg: {np.all(eigs >= -1e-10)}")

    v = np.random.default_rng(42).standard_normal(n)
    identity_check = verify_covariance_identity(n, beta, J, h, v)
    print(f"  Identity check: LHS={identity_check['lhs']:.8f}, "
          f"RHS={identity_check['rhs']:.8f}, "
          f"verified={identity_check['verified']}")
    print()

    # 4. Perturbation Analysis
    print("--- Algorithm 4: Perturbation Analysis ---")
    result = analyze_perturbation_stability(n, beta, J, 0.01, h)
    print(f"  Theoretical bound: {result['theoretical_bound']:.6f}")
    print(f"  Max observed: {result['max_observed']:.6f}")
    print(f"  Bound ratio: {result['bound_ratio']:.4f}")
    print(f"  All within bound: {result['all_within_bound']}")
