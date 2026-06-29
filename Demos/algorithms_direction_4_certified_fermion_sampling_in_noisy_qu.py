"""
Certified Fermion Sampling — Algorithms

Implements the core algorithms from the research:
1. Depolarizing channel simulation
2. Certified noise bound computation
3. Noise threshold determination
4. DPP pair inclusion certification
"""

import numpy as np
from typing import Tuple, List, Optional


def depolarizing_channel(K: np.ndarray, eps: float) -> np.ndarray:
    """
    Apply the depolarizing channel to a correlation matrix.

    Φ_ε(K) = (1 - ε) · K + (ε/2) · I

    This models the effect of depolarizing noise on a fermionic Gaussian
    state's correlation matrix. With probability 1-ε the state passes
    through; with probability ε it is replaced by the maximally mixed state.

    Parameters:
        K: n×n symmetric correlation matrix
        eps: noise rate ε ∈ [0, 1]

    Returns:
        The noisy correlation matrix Φ_ε(K)

    Complexity: O(n²)
    """
    n = K.shape[0]
    assert 0 <= eps <= 1, f"Noise rate must be in [0,1], got {eps}"
    assert K.shape == (n, n), f"Matrix must be square, got {K.shape}"
    return (1 - eps) * K + (eps / 2) * np.eye(n)


def iterated_depolarizing(K: np.ndarray, eps: float, d: int) -> np.ndarray:
    """
    Apply the depolarizing channel d times: Φ_ε^d(K).

    Uses the explicit formula when possible:
        Φ_ε^d(K)_ij = (1-ε)^d · K_ij + (1-(1-ε)^d)/2 · δ_ij

    Parameters:
        K: n×n symmetric correlation matrix
        eps: noise rate ε ∈ [0, 1]
        d: circuit depth (number of iterations)

    Returns:
        The d-times noisy correlation matrix

    Complexity: O(n²) using explicit formula
    """
    n = K.shape[0]
    contraction = (1 - eps) ** d
    shift = (1 - contraction) / 2
    return contraction * K + shift * np.eye(n)


def max_entry_perturbation(K: np.ndarray, K_prime: np.ndarray) -> float:
    """
    Compute the entrywise max norm of the difference: ‖K - K'‖_max.

    Parameters:
        K, K_prime: n×n matrices

    Returns:
        max_{i,j} |K_ij - K'_ij|

    Complexity: O(n²)
    """
    return float(np.max(np.abs(K - K_prime)))


def certified_entry_bound(d: int, eps: float) -> float:
    """
    Compute the certified entrywise perturbation bound: 3dε/2.

    This is the proven upper bound on ‖K - Φ_ε^d(K)‖_max for any
    fermionic correlation matrix K with |K_ij| ≤ 1.

    Parameters:
        d: circuit depth
        eps: noise rate

    Returns:
        The certified bound 3dε/2

    Theorem: circuit_noise_accumulation_entry
    """
    return 3 * d * eps / 2


def certified_neg_dep_bound(d: int, eps: float) -> float:
    """
    Compute the certified negative dependence defect bound.

    Bound: 2 · (2η + η²) where η = 3dε/2

    This bounds |P_K(i,j) - P_{K'}(i,j)| for all pairs (i,j),
    where P_K(i,j) = K_ii·K_jj - K_ij·K_ji.

    Parameters:
        d: circuit depth
        eps: noise rate

    Returns:
        The certified bound

    Theorem: certified_neg_dep_quality
    """
    eta = certified_entry_bound(d, eps)
    return 2 * (2 * eta + eta ** 2)


def noise_threshold(delta: float) -> Tuple[float, float]:
    """
    Compute the maximum noise budget (d·ε product) that preserves
    positive pair inclusion probability.

    Given that P_K(i,j) ≥ δ > 0, we need:
        2·(2·(3dε/2) + (3dε/2)²) < δ

    Let η = 3dε/2. We need 2(2η + η²) < δ, i.e., η² + 2η - δ/2 < 0.
    Solving: η < -1 + √(1 + δ/2)

    Parameters:
        delta: the ideal negative dependence gap

    Returns:
        (max_eta, max_d_eps): maximum η and corresponding d·ε
    """
    max_eta = -1 + np.sqrt(1 + delta / 2)
    max_d_eps = 2 * max_eta / 3  # since η = 3dε/2
    return float(max_eta), float(max_d_eps)


def certify_dpp_quality(
    K_ideal: np.ndarray,
    eps: float,
    d: int
) -> dict:
    """
    Full certification pipeline for noisy fermion sampling.

    Given an ideal correlation matrix K, noise rate ε, and circuit depth d,
    computes:
    1. The noisy correlation matrix K'
    2. Entry perturbation bound
    3. Negative dependence defect bound
    4. Which pairs maintain certified positive inclusion probability

    Parameters:
        K_ideal: n×n ideal correlation matrix
        eps: per-gate noise rate
        d: circuit depth

    Returns:
        Dictionary with certification results

    Complexity: O(n²) for the channel, O(n²) for certification
    """
    n = K_ideal.shape[0]
    K_noisy = iterated_depolarizing(K_ideal, eps, d)

    entry_bound = certified_entry_bound(d, eps)
    neg_dep_bound = certified_neg_dep_bound(d, eps)
    actual_max_perturbation = max_entry_perturbation(K_ideal, K_noisy)

    # Check each pair
    certified_pairs = []
    for i in range(n):
        for j in range(i + 1, n):
            P_ideal = K_ideal[i, i] * K_ideal[j, j] - K_ideal[i, j] * K_ideal[j, i]
            P_noisy = K_noisy[i, i] * K_noisy[j, j] - K_noisy[i, j] * K_noisy[j, i]
            certified_positive = P_ideal - neg_dep_bound > 0
            certified_pairs.append({
                'i': i, 'j': j,
                'P_ideal': float(P_ideal),
                'P_noisy': float(P_noisy),
                'certified_positive': certified_positive,
                'actually_positive': float(P_noisy) > 0
            })

    return {
        'n': n,
        'eps': eps,
        'd': d,
        'entry_bound': entry_bound,
        'actual_perturbation': actual_max_perturbation,
        'neg_dep_bound': neg_dep_bound,
        'pairs': certified_pairs,
        'K_noisy': K_noisy,
        'all_certified': all(p['certified_positive'] for p in certified_pairs),
        'all_positive': all(p['actually_positive'] for p in certified_pairs)
    }


def find_noise_budget(
    K_ideal: np.ndarray,
    target_confidence: float = 0.99
) -> dict:
    """
    Find the maximum noise budget (d·ε product) that allows certified
    sampling with all pairs having positive inclusion probability.

    Parameters:
        K_ideal: ideal correlation matrix
        target_confidence: fraction of pairs that must be certified

    Returns:
        Maximum d·ε product and details
    """
    n = K_ideal.shape[0]

    # Find minimum ideal neg dep value
    min_P = float('inf')
    min_pair = (0, 0)
    for i in range(n):
        for j in range(i + 1, n):
            P = K_ideal[i, i] * K_ideal[j, j] - K_ideal[i, j] * K_ideal[j, i]
            if P < min_P:
                min_P = P
                min_pair = (i, j)

    if min_P <= 0:
        return {
            'feasible': False,
            'reason': 'Ideal kernel does not satisfy negative dependence',
            'min_P': min_P,
            'min_pair': min_pair
        }

    max_eta, max_d_eps = noise_threshold(min_P)

    return {
        'feasible': True,
        'min_P': min_P,
        'min_pair': min_pair,
        'max_eta': max_eta,
        'max_d_eps': max_d_eps,
        'example_configs': [
            {'d': d, 'max_eps': max_d_eps / d if d > 0 else float('inf')}
            for d in [10, 50, 100, 500]
        ]
    }


# Example usage
if __name__ == "__main__":
    print("=== Certified DPP Quality Pipeline ===\n")

    K = np.array([[0.7, 0.2, -0.1, 0.05],
                   [0.2, 0.6,  0.1, -0.05],
                   [-0.1, 0.1, 0.5, 0.08],
                   [0.05, -0.05, 0.08, 0.4]])

    result = certify_dpp_quality(K, eps=0.01, d=20)
    print(f"n={result['n']}, ε={result['eps']}, d={result['d']}")
    print(f"Entry perturbation: actual={result['actual_perturbation']:.6f}, "
          f"bound={result['entry_bound']:.6f}")
    print(f"Neg dep bound: {result['neg_dep_bound']:.6f}")
    print(f"All pairs certified positive: {result['all_certified']}")
    print(f"All pairs actually positive: {result['all_positive']}")

    print("\n--- Pair details ---")
    for p in result['pairs']:
        print(f"  ({p['i']},{p['j']}): P_ideal={p['P_ideal']:.6f}, "
              f"P_noisy={p['P_noisy']:.6f}, "
              f"cert={p['certified_positive']}, "
              f"actual={p['actually_positive']}")

    print("\n--- Noise budget ---")
    budget = find_noise_budget(K)
    print(f"Min ideal P: {budget['min_P']:.6f} at pair {budget['min_pair']}")
    print(f"Max d·ε product: {budget['max_d_eps']:.6f}")
    for cfg in budget['example_configs']:
        print(f"  d={cfg['d']:>4}: max ε = {cfg['max_eps']:.6f}")
