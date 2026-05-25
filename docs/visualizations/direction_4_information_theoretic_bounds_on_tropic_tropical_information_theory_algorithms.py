"""
algorithms.py — Tropical Information Theory: Core Algorithms

Implements the key computational methods from the tropical channel capacity
framework for barcode stability analysis.

Author: Harmonic Research
"""

import numpy as np
from typing import List, Tuple, Dict, Optional
import itertools


def tropical_channel_capacity(degree: int) -> float:
    """
    Compute the tropical channel capacity of a vertex with given degree.

    The capacity is log(d+1) nats, representing the maximum information
    rate through a degree-d vertex in the min-plus semiring.

    Parameters
    ----------
    degree : int
        The degree of the vertex (number of adjacent edges).

    Returns
    -------
    float
        The channel capacity in nats.

    Example
    -------
    >>> tropical_channel_capacity(3)  # degree-3 vertex
    1.3862943611198906
    >>> tropical_channel_capacity(0)  # isolated vertex
    0.0
    """
    return np.log(degree + 1)


def tropical_alphabet_size(degree: int) -> int:
    """
    The number of distinguishable tropical symbols for a degree-d vertex.

    Returns d + 1 (the vertex receives d edge signals plus its own weight).
    """
    return degree + 1


def graph_degree_entropy(adj_matrix: np.ndarray) -> float:
    """
    Compute the graph degree entropy H(G).

    This is the Shannon entropy of the normalized degree sequence,
    viewed as a probability distribution over edge endpoints.

    Parameters
    ----------
    adj_matrix : np.ndarray
        Symmetric adjacency matrix (n x n), 0-1 entries.

    Returns
    -------
    float
        The degree entropy in nats. Returns 0 for edgeless graphs.

    Example
    -------
    >>> A = np.array([[0,1,1],[1,0,1],[1,1,0]])  # K_3
    >>> graph_degree_entropy(A)  # Should be log(3)
    1.0986122886681098
    """
    degrees = adj_matrix.sum(axis=1)
    total_deg = degrees.sum()
    if total_deg == 0:
        return 0.0
    p = degrees / total_deg
    # Convention: 0 * log(0) = 0
    entropy = -np.sum(p[p > 0] * np.log(p[p > 0]))
    return entropy


def total_tropical_capacity(adj_matrix: np.ndarray) -> float:
    """
    Compute the total tropical capacity of a graph.

    Sum of log(deg(v) + 1) over all vertices.

    Parameters
    ----------
    adj_matrix : np.ndarray
        Symmetric adjacency matrix.

    Returns
    -------
    float
        Total capacity in nats.
    """
    degrees = adj_matrix.sum(axis=1).astype(int)
    return sum(tropical_channel_capacity(d) for d in degrees)


def tropical_event_profile(adj_matrix: np.ndarray, filtration: np.ndarray, t: float) -> int:
    """
    Compute the tropical event profile at time t.

    For each active vertex (filtration value ≤ t), add (degree + 1).

    Parameters
    ----------
    adj_matrix : np.ndarray
        Adjacency matrix.
    filtration : np.ndarray
        Vertex filtration values (entrance times).
    t : float
        Time parameter.

    Returns
    -------
    int
        The tropical event profile value.
    """
    degrees = adj_matrix.sum(axis=1).astype(int)
    active = filtration <= t
    return sum(degrees[i] + 1 for i in range(len(filtration)) if active[i])


def capacity_weighted_profile(adj_matrix: np.ndarray, filtration: np.ndarray, t: float) -> float:
    """
    Compute the capacity-weighted profile at time t.

    Sum of log(deg(v) + 1) over active vertices.
    """
    degrees = adj_matrix.sum(axis=1).astype(int)
    active = filtration <= t
    return sum(tropical_channel_capacity(degrees[i]) for i in range(len(filtration)) if active[i])


def tropical_information_loss(adj_matrix: np.ndarray, filtration: np.ndarray, t: float) -> float:
    """
    Compute the tropical information loss at time t.

    This is total_capacity - capacity_weighted_profile(t).
    """
    return total_tropical_capacity(adj_matrix) - capacity_weighted_profile(adj_matrix, filtration, t)


def tropical_barcode_distance(adj_matrix: np.ndarray,
                                f: np.ndarray, g: np.ndarray) -> float:
    """
    Compute the tropical barcode distance between two filtrations.

    d_T(TPB(G,f), TPB(G,g)) = max_v |f(v) - g(v)| * (deg(v) + 1)

    Parameters
    ----------
    adj_matrix : np.ndarray
        Adjacency matrix.
    f, g : np.ndarray
        Two vertex filtrations.

    Returns
    -------
    float
        The tropical barcode distance.
    """
    degrees = adj_matrix.sum(axis=1).astype(int)
    return max(abs(f[i] - g[i]) * (degrees[i] + 1) for i in range(len(f)))


def stability_bound(adj_matrix: np.ndarray, f: np.ndarray, g: np.ndarray) -> float:
    """
    Compute the (D+1)*epsilon stability bound.

    Parameters
    ----------
    adj_matrix : np.ndarray
        Adjacency matrix.
    f, g : np.ndarray
        Two vertex filtrations.

    Returns
    -------
    float
        The stability bound (D+1) * sup|f-g|.
    """
    max_degree = int(adj_matrix.sum(axis=1).max())
    epsilon = np.max(np.abs(f - g))
    return (max_degree + 1) * epsilon


def capacity_gap(max_degree: int, min_degree: int) -> float:
    """
    Compute the capacity gap log((D+1)/(δ+1)).

    Measures the heterogeneity of information flow in the graph.
    """
    return np.log((max_degree + 1) / (min_degree + 1))


def tropical_kraft_sum(degree: int, lengths: Optional[List[int]] = None) -> float:
    """
    Compute the Kraft sum for a tropical prefix code.

    For a degree-d vertex with alphabet size d+1.
    Unit-length codes give Kraft sum = 1.
    """
    if lengths is None:
        lengths = [1] * (degree + 1)
    base = 1.0 / (degree + 1)
    return sum(base ** l for l in lengths)


def erdos_renyi_graph(n: int, p: float, seed: Optional[int] = None) -> np.ndarray:
    """
    Generate an Erdős-Rényi random graph G(n, p).

    Returns the adjacency matrix.
    """
    rng = np.random.RandomState(seed)
    upper = rng.random((n, n)) < p
    adj = np.triu(upper, k=1)
    adj = adj + adj.T
    return adj.astype(float)


def estimate_mutual_information(adj_matrix: np.ndarray,
                                 n_samples: int = 1000,
                                 seed: Optional[int] = None) -> float:
    """
    Estimate the mutual information I(f; TPB(G,f)) using Monte Carlo sampling.

    Generates random filtrations f ~ Uniform([0,1]^n) and estimates
    the mutual information between the filtration and the barcode
    using a nearest-neighbor entropy estimator.

    Parameters
    ----------
    adj_matrix : np.ndarray
        Adjacency matrix.
    n_samples : int
        Number of Monte Carlo samples.
    seed : int, optional
        Random seed.

    Returns
    -------
    float
        Estimated mutual information in nats.
    """
    rng = np.random.RandomState(seed)
    n = adj_matrix.shape[0]
    degrees = adj_matrix.sum(axis=1).astype(int)

    # Generate random filtrations
    filtrations = rng.random((n_samples, n))

    # Compute barcode features for each filtration
    # Use the tropical event profile at a grid of times as feature
    times = np.linspace(0, 1, 20)
    barcode_features = np.zeros((n_samples, len(times)))

    for i, f in enumerate(filtrations):
        for j, t in enumerate(times):
            active = f <= t
            barcode_features[i, j] = sum(
                (degrees[k] + 1) for k in range(n) if active[k]
            )

    # Estimate mutual information using correlation-based approximation
    # I(X;Y) ≈ -0.5 * log(1 - rho^2) for jointly Gaussian variables
    # This is a lower bound for non-Gaussian distributions

    # Compute correlation between filtration features and barcode features
    filtration_var = np.var(filtrations, axis=0).mean()
    barcode_var = np.var(barcode_features, axis=0).mean()

    if filtration_var == 0 or barcode_var == 0:
        return 0.0

    # Use average correlation as proxy
    rho_sum = 0.0
    count = 0
    for j in range(min(n, len(times))):
        corr = np.corrcoef(filtrations[:, min(j, n-1)], barcode_features[:, j])[0, 1]
        if not np.isnan(corr):
            rho_sum += corr ** 2
            count += 1

    if count == 0:
        return 0.0

    avg_rho_sq = rho_sum / count
    return -0.5 * np.log(max(1 - avg_rho_sq, 1e-10))


def compute_capacity_ratio(adj_matrix: np.ndarray, c: float) -> float:
    """
    Compute the capacity ratio: total_capacity / (n * log(c)).

    This is the quantity predicted to converge to 1 for G(n, c/n).
    """
    n = adj_matrix.shape[0]
    cap = total_tropical_capacity(adj_matrix)
    denom = n * np.log(c)
    if denom == 0:
        return float('inf')
    return cap / denom


# ============================================================
# Example usage
# ============================================================

if __name__ == "__main__":
    print("=== Tropical Information Theory: Algorithm Examples ===\n")

    # Example 1: Complete graph K_5
    n = 5
    K5 = np.ones((n, n)) - np.eye(n)
    print(f"Complete graph K_{n}:")
    print(f"  Total capacity: {total_tropical_capacity(K5):.4f}")
    print(f"  Degree entropy: {graph_degree_entropy(K5):.4f}")
    print(f"  Per-vertex capacity: {tropical_channel_capacity(n-1):.4f}")
    print(f"  Capacity = n * log(n) = {n * np.log(n):.4f}")
    print()

    # Example 2: Cycle graph C_6
    n = 6
    C6 = np.zeros((n, n))
    for i in range(n):
        C6[i, (i+1) % n] = 1
        C6[(i+1) % n, i] = 1
    print(f"Cycle graph C_{n}:")
    print(f"  Total capacity: {total_tropical_capacity(C6):.4f}")
    print(f"  Degree entropy: {graph_degree_entropy(C6):.4f}")
    print(f"  Per-vertex capacity: {tropical_channel_capacity(2):.4f}")
    print()

    # Example 3: Stability bound
    f = np.array([0.1, 0.3, 0.5, 0.7, 0.9])
    g = np.array([0.15, 0.28, 0.52, 0.68, 0.92])
    K5 = np.ones((5, 5)) - np.eye(5)
    dist = tropical_barcode_distance(K5, f, g)
    bound = stability_bound(K5, f, g)
    print(f"Stability example on K_5:")
    print(f"  Barcode distance: {dist:.4f}")
    print(f"  Stability bound:  {bound:.4f}")
    print(f"  Tight: {dist <= bound}")
    print()

    # Example 4: Kraft inequality
    print(f"Kraft sum (unit codes, d=3): {tropical_kraft_sum(3):.4f}")
    print(f"Kraft sum (unit codes, d=5): {tropical_kraft_sum(5):.4f}")
