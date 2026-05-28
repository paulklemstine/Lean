#!/usr/bin/env python3
"""
algorithms.py — Certified Computation Pipeline for Spectral-Tropical Entropy

Implements the complete algorithm suite for computing degree entropy,
regularity deficit, KL divergence, and spectral-entropy bounds for
finite simple graphs.

All algorithms correspond to formally verified Lean 4 definitions
in Catalog/Pythagorean/TropicalBridge/SpectralTropicalEntropy.lean.
"""

import numpy as np
from typing import List, Tuple, Dict, Optional


def degree_sequence(adj: np.ndarray) -> np.ndarray:
    """Compute the degree sequence of a graph from its adjacency matrix.

    Args:
        adj: n×n symmetric binary adjacency matrix.

    Returns:
        Array of vertex degrees.

    Time: O(n²), Space: O(n).

    Example:
        >>> adj = np.array([[0,1,1],[1,0,1],[1,1,0]])
        >>> degree_sequence(adj)
        array([2, 2, 2])
    """
    return adj.sum(axis=1).astype(int)


def graph_volume(degrees: np.ndarray) -> float:
    """Compute vol(G) = sum of all vertex degrees = 2|E|.

    Lean definition: `def vol (G) := ∑ v, (G.degree v : ℝ)`

    Args:
        degrees: Array of vertex degrees.

    Returns:
        Total volume as a float.

    Time: O(n), Space: O(1).

    Example:
        >>> graph_volume(np.array([2, 2, 2]))
        6.0
    """
    return float(degrees.sum())


def degree_distribution(degrees: np.ndarray) -> np.ndarray:
    """Compute the degree probability distribution p_v = d(v) / vol(G).

    Lean definition: `def degreeProb (G) (v) := (G.degree v : ℝ) / vol G`

    Args:
        degrees: Array of vertex degrees.

    Returns:
        Probability distribution over vertices.

    Time: O(n), Space: O(n).
    Precondition: vol(G) > 0.

    Example:
        >>> degree_distribution(np.array([2, 2, 2]))
        array([0.333..., 0.333..., 0.333...])
    """
    vol = graph_volume(degrees)
    if vol == 0:
        return np.zeros_like(degrees, dtype=float)
    return degrees.astype(float) / vol


def shannon_entropy(degrees: np.ndarray) -> float:
    """Compute Shannon entropy of the degree distribution.

    H(G) = -∑_v p_v log(p_v)

    Lean definition: `def degreeEntropy (G) := -∑ v, degreeProb G v * log(degreeProb G v)`

    Uses natural logarithm. Convention: 0 · log(0) = 0.

    Args:
        degrees: Array of vertex degrees.

    Returns:
        Degree entropy H(G).

    Time: O(n), Space: O(1).

    Example:
        >>> shannon_entropy(np.array([2, 2, 2]))  # Regular graph
        1.0986...  # = log(3)
    """
    p = degree_distribution(degrees)
    h = 0.0
    for pv in p:
        if pv > 0:
            h -= pv * np.log(pv)
    return h


def max_degree(degrees: np.ndarray) -> int:
    """Maximum vertex degree Δ.

    Lean definition: `def maxDeg (G) := Finset.univ.sup (degFun G)`

    Args:
        degrees: Array of vertex degrees.

    Returns:
        Maximum degree.

    Time: O(n), Space: O(1).
    """
    return int(degrees.max())


def average_degree(degrees: np.ndarray) -> float:
    """Average vertex degree d̄ = vol(G) / |V|.

    Lean definition: `def avgDegree (G) := vol G / Fintype.card V`

    Args:
        degrees: Array of vertex degrees.

    Returns:
        Average degree.

    Time: O(n), Space: O(1).
    """
    return float(degrees.mean())


def regularity_deficit(degrees: np.ndarray) -> float:
    """Regularity deficit D(G) = log|V| - H(G).

    Lean definition: `def regularityDeficit (G) := log(Fintype.card V) - degreeEntropy G`

    Measures information-theoretic deviation from regularity.
    D(G) = 0 iff G is regular (among connected graphs).

    Args:
        degrees: Array of vertex degrees.

    Returns:
        Regularity deficit D(G) ≥ 0.

    Time: O(n), Space: O(1).
    """
    n = len(degrees)
    return np.log(n) - shannon_entropy(degrees)


def kl_divergence_from_uniform(degrees: np.ndarray) -> float:
    """KL divergence D_KL(p || u) from the degree distribution to uniform.

    Lean definition:
        `def degreeKLToUniform (G) := ∑ v, degreeProb G v * log(degreeProb G v / uniformProb V)`

    Formally verified to equal regularityDeficit(G):
        `theorem regularityDeficit_eq_degreeKLToUniform`

    Args:
        degrees: Array of vertex degrees.

    Returns:
        KL divergence.

    Time: O(n), Space: O(1).
    """
    n = len(degrees)
    p = degree_distribution(degrees)
    u = 1.0 / n
    kl = 0.0
    for pv in p:
        if pv > 0:
            kl += pv * np.log(pv / u)
    return kl


def entropy_lower_bound(degrees: np.ndarray) -> float:
    """Certified lower bound on degree entropy: log(|V| · d̄ / Δ).

    Lean theorem:
        `theorem degreeEntropy_lower_bound_avg_max :
            log(|V| * avgDegree G / maxDeg G) ≤ degreeEntropy G`

    Args:
        degrees: Array of vertex degrees.

    Returns:
        Lower bound on H(G).

    Time: O(n), Space: O(1).
    """
    n = len(degrees)
    d_bar = average_degree(degrees)
    delta = max_degree(degrees)
    if delta == 0:
        return float('-inf')
    return np.log(n * d_bar / delta)


def deficit_upper_bound(degrees: np.ndarray) -> float:
    """Certified upper bound on regularity deficit: log(Δ / d̄).

    Lean theorem:
        `theorem regularityDeficit_le_log_maxDeg_div_avgDegree :
            regularityDeficit G ≤ log(maxDeg G / avgDegree G)`

    Args:
        degrees: Array of vertex degrees.

    Returns:
        Upper bound on D(G).

    Time: O(n), Space: O(1).
    """
    d_bar = average_degree(degrees)
    delta = max_degree(degrees)
    if d_bar == 0:
        return float('inf')
    return np.log(delta / d_bar)


def spectral_radius(adj: np.ndarray) -> float:
    """Largest eigenvalue of the adjacency matrix.

    For connected graphs, this is the Perron–Frobenius eigenvalue λ₁.
    Classical result: d̄ ≤ λ₁ ≤ Δ.

    Args:
        adj: n×n symmetric binary adjacency matrix.

    Returns:
        Spectral radius λ₁.

    Time: O(n³) via eigendecomposition, Space: O(n²).
    """
    eigenvalues = np.linalg.eigvalsh(adj.astype(float))
    return float(eigenvalues.max())


def spectral_entropy_bound(degrees: np.ndarray, lambda1: float) -> float:
    """Strong spectral entropy bound (conjectural): log(|V| · λ₁ / Δ).

    This is STRONGER than the certified bound when λ₁ > d̄.

    Not yet formally verified — this is the target conjecture.

    Args:
        degrees: Array of vertex degrees.
        lambda1: Spectral radius of adjacency matrix.

    Returns:
        Conjectural lower bound on H(G).
    """
    n = len(degrees)
    delta = max_degree(degrees)
    if delta == 0:
        return float('-inf')
    return np.log(n * lambda1 / delta)


def full_analysis(adj: np.ndarray) -> Dict:
    """Complete spectral-tropical entropy analysis of a graph.

    Computes all invariants and bounds, returning a dictionary
    with all results and bound verification status.

    Args:
        adj: n×n symmetric binary adjacency matrix.

    Returns:
        Dictionary with all computed invariants and verification results.

    Example:
        >>> adj = np.array([[0,1,1],[1,0,1],[1,1,0]])  # K_3
        >>> result = full_analysis(adj)
        >>> result['is_regular']
        True
        >>> abs(result['entropy'] - np.log(3)) < 1e-10
        True
    """
    degrees = degree_sequence(adj)
    n = len(degrees)

    H = shannon_entropy(degrees)
    D = regularity_deficit(degrees)
    KL = kl_divergence_from_uniform(degrees)
    lb = entropy_lower_bound(degrees)
    ub_deficit = deficit_upper_bound(degrees)
    lam1 = spectral_radius(adj)
    lb_spec = spectral_entropy_bound(degrees, lam1)

    return {
        'n': n,
        'num_edges': int(graph_volume(degrees)) // 2,
        'degrees': degrees.tolist(),
        'max_degree': max_degree(degrees),
        'avg_degree': average_degree(degrees),
        'volume': graph_volume(degrees),
        'spectral_radius': lam1,
        'entropy': H,
        'log_n': np.log(n),
        'regularity_deficit': D,
        'kl_divergence': KL,
        'deficit_kl_match': abs(D - KL) < 1e-10,
        'entropy_lower_bound': lb,
        'entropy_bound_holds': H >= lb - 1e-10,
        'deficit_upper_bound': ub_deficit,
        'deficit_bound_holds': D <= ub_deficit + 1e-10,
        'spectral_lower_bound': lb_spec,
        'spectral_bound_holds': H >= lb_spec - 1e-10,
        'is_regular': len(set(degrees.tolist())) <= 1,
        'entropy_margin_avg': H - lb,
        'entropy_margin_spectral': H - lb_spec,
    }


if __name__ == "__main__":
    # Quick demonstration
    print("=== Full Analysis: Complete Graph K_5 ===")
    K5 = np.ones((5, 5), dtype=int) - np.eye(5, dtype=int)
    result = full_analysis(K5)
    for k, v in result.items():
        print(f"  {k}: {v}")

    print("\n=== Full Analysis: Star Graph S_5 ===")
    S5 = np.zeros((5, 5), dtype=int)
    for i in range(1, 5):
        S5[0][i] = S5[i][0] = 1
    result = full_analysis(S5)
    for k, v in result.items():
        print(f"  {k}: {v}")
