"""
algorithms.py — Certified Spectral-Tropical Entropy Algorithms

Implements the core algorithms from the spectral-tropical entropy bridge theory:
degree distribution, Shannon entropy, regularity deficit, KL divergence,
and spectral-entropy lower bounds.

All algorithms operate on graphs represented as adjacency lists or
networkx Graph objects.
"""

import math
from typing import Dict, List, Tuple, Optional
import numpy as np

try:
    import networkx as nx
    HAS_NETWORKX = True
except ImportError:
    HAS_NETWORKX = False


def degree_sequence(adj: Dict[int, List[int]]) -> List[int]:
    """Compute degree sequence from adjacency list.

    Args:
        adj: Adjacency list {vertex: [neighbors]}

    Returns:
        List of degrees indexed by vertex.

    Time complexity: O(|V| + |E|)
    Space complexity: O(|V|)
    """
    return [len(adj.get(v, [])) for v in sorted(adj.keys())]


def volume(degrees: List[int]) -> int:
    """Total volume: sum of all degrees = 2|E|.

    Time complexity: O(|V|)
    """
    return sum(degrees)


def degree_distribution(degrees: List[int]) -> List[float]:
    """Compute degree probability distribution p_v = d(v) / vol(G).

    Args:
        degrees: List of vertex degrees.

    Returns:
        List of probabilities. Returns uniform if volume is 0.

    Time complexity: O(|V|)
    """
    vol = volume(degrees)
    if vol == 0:
        n = len(degrees)
        return [1.0 / n if n > 0 else 0.0] * n
    return [d / vol for d in degrees]


def degree_entropy(degrees: List[int]) -> float:
    """Shannon entropy of the degree distribution.

    H(G) = -sum_v p_v * log(p_v)

    Uses natural logarithm. Convention: 0 * log(0) = 0.

    Args:
        degrees: List of vertex degrees.

    Returns:
        Shannon entropy H(G) >= 0.

    Time complexity: O(|V|)
    """
    probs = degree_distribution(degrees)
    entropy = 0.0
    for p in probs:
        if p > 0:
            entropy -= p * math.log(p)
    return entropy


def max_degree(degrees: List[int]) -> int:
    """Maximum vertex degree Delta.

    Time complexity: O(|V|)
    """
    return max(degrees) if degrees else 0


def avg_degree(degrees: List[int]) -> float:
    """Average vertex degree d_bar = vol(G) / |V|.

    Time complexity: O(|V|)
    """
    n = len(degrees)
    if n == 0:
        return 0.0
    return volume(degrees) / n


def regularity_deficit(degrees: List[int]) -> float:
    """Regularity deficit: D(G) = log|V| - H(G).

    Measures information-theoretic deviation from regularity.
    Equals 0 iff the graph is regular.

    Time complexity: O(|V|)
    """
    n = len(degrees)
    if n == 0:
        return 0.0
    return math.log(n) - degree_entropy(degrees)


def kl_divergence_to_uniform(degrees: List[int]) -> float:
    """KL divergence of degree distribution from uniform.

    D_KL(p || u) = sum_v p_v * log(p_v / u_v)

    Theorem: This equals the regularity deficit.

    Time complexity: O(|V|)
    """
    n = len(degrees)
    if n == 0:
        return 0.0
    probs = degree_distribution(degrees)
    u = 1.0 / n
    kl = 0.0
    for p in probs:
        if p > 0:
            kl += p * math.log(p / u)
    return kl


def entropy_lower_bound_avg_max(degrees: List[int]) -> float:
    """Certified entropy lower bound: log(|V| * d_bar / Delta).

    Theorem: H(G) >= log(|V| * avgDegree / maxDegree).

    This is the core spectral-tropical entropy bound.

    Time complexity: O(|V|)
    """
    n = len(degrees)
    if n == 0:
        return 0.0
    delta = max_degree(degrees)
    d_bar = avg_degree(degrees)
    if delta == 0 or d_bar <= 0:
        return float('-inf')
    return math.log(n * d_bar / delta)


def entropy_lower_bound_spectral(degrees: List[int], spectral_radius: float) -> float:
    """Spectral entropy lower bound: log(|V| * rho / Delta).

    Given that rho <= avgDegree (which holds for spectral radius of
    adjacency matrix), provides: H(G) >= log(|V| * rho / Delta).

    Args:
        degrees: List of vertex degrees.
        spectral_radius: A lower bound on avgDegree (e.g., lambda_1).

    Returns:
        Lower bound on degree entropy.

    Time complexity: O(|V|)
    """
    n = len(degrees)
    if n == 0:
        return 0.0
    delta = max_degree(degrees)
    if delta == 0:
        return float('-inf')
    return math.log(n * spectral_radius / delta)


def deficit_upper_bound(degrees: List[int]) -> float:
    """Upper bound on regularity deficit: log(Delta / d_bar).

    Theorem: D(G) <= log(maxDegree / avgDegree).

    Time complexity: O(|V|)
    """
    delta = max_degree(degrees)
    d_bar = avg_degree(degrees)
    if d_bar <= 0 or delta == 0:
        return float('inf')
    return math.log(delta / d_bar)


def is_regular(degrees: List[int]) -> bool:
    """Check if graph is regular (all degrees equal).

    Time complexity: O(|V|)
    """
    if not degrees:
        return True
    return all(d == degrees[0] for d in degrees)


def spectral_radius_adjacency(adj_matrix: np.ndarray) -> float:
    """Compute spectral radius (largest eigenvalue) of adjacency matrix.

    Args:
        adj_matrix: Symmetric 0/1 adjacency matrix.

    Returns:
        Largest eigenvalue lambda_1.

    Time complexity: O(|V|^3) via eigendecomposition.
    """
    eigenvalues = np.linalg.eigvalsh(adj_matrix)
    return float(np.max(eigenvalues))


def full_spectral_entropy_analysis(adj_matrix: np.ndarray) -> Dict[str, float]:
    """Complete spectral-tropical entropy analysis of a graph.

    Args:
        adj_matrix: Symmetric 0/1 adjacency matrix.

    Returns:
        Dictionary with all computed quantities:
        - n: vertex count
        - vol: total volume
        - max_degree: maximum degree
        - avg_degree: average degree
        - entropy: degree entropy H(G)
        - log_n: log|V|
        - deficit: regularity deficit
        - kl_uniform: KL divergence from uniform
        - bound_avg_max: entropy lower bound log(n * d_bar / Delta)
        - deficit_upper: deficit upper bound log(Delta / d_bar)
        - spectral_radius: lambda_1
        - bound_spectral: spectral entropy bound log(n * lambda_1 / Delta)
        - margin_avg: H(G) - bound_avg_max
        - margin_spectral: H(G) - bound_spectral
        - is_regular: whether graph is regular
    """
    n = adj_matrix.shape[0]
    degrees = [int(np.sum(adj_matrix[i])) for i in range(n)]

    vol_val = volume(degrees)
    delta = max_degree(degrees)
    d_bar = avg_degree(degrees)
    H = degree_entropy(degrees)
    log_n = math.log(n) if n > 0 else 0.0
    deficit = regularity_deficit(degrees)
    kl = kl_divergence_to_uniform(degrees)
    bound_am = entropy_lower_bound_avg_max(degrees)
    deficit_ub = deficit_upper_bound(degrees)

    # Spectral radius
    lam1 = spectral_radius_adjacency(adj_matrix)
    bound_spec = entropy_lower_bound_spectral(degrees, lam1) if delta > 0 else float('-inf')

    return {
        'n': n,
        'vol': vol_val,
        'max_degree': delta,
        'avg_degree': d_bar,
        'entropy': H,
        'log_n': log_n,
        'deficit': deficit,
        'kl_uniform': kl,
        'bound_avg_max': bound_am,
        'deficit_upper': deficit_ub,
        'spectral_radius': lam1,
        'bound_spectral': bound_spec,
        'margin_avg': H - bound_am,
        'margin_spectral': H - bound_spec if bound_spec > float('-inf') else float('inf'),
        'is_regular': is_regular(degrees),
    }


# ─── Example usage ────────────────────────────────────────────────────────────

if __name__ == "__main__":
    # Example: Complete graph K5
    n = 5
    K5 = np.ones((n, n)) - np.eye(n)
    result = full_spectral_entropy_analysis(K5)
    print("=== Complete Graph K5 ===")
    for k, v in result.items():
        print(f"  {k}: {v}")

    # Example: Path graph P5
    P5 = np.zeros((n, n))
    for i in range(n - 1):
        P5[i][i + 1] = 1
        P5[i + 1][i] = 1
    result = full_spectral_entropy_analysis(P5)
    print("\n=== Path Graph P5 ===")
    for k, v in result.items():
        print(f"  {k}: {v}")

    # Example: Star graph S5
    S5 = np.zeros((n, n))
    for i in range(1, n):
        S5[0][i] = 1
        S5[i][0] = 1
    result = full_spectral_entropy_analysis(S5)
    print("\n=== Star Graph S5 ===")
    for k, v in result.items():
        print(f"  {k}: {v}")
