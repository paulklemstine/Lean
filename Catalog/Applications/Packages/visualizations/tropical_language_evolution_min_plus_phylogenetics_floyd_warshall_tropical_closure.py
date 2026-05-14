#!/usr/bin/env python3
"""
Tropical Phylogenetics: Core Algorithms

Implements the key algorithms from the tropical language evolution framework:
1. Tropical diffusion (min-plus matrix action)
2. Floyd-Warshall shortest paths in min-plus semiring
3. Neighbor-joining tree reconstruction from distance matrices
4. Four-point condition checker and tree metric verification
5. Glottochronological dating from tree distances

All algorithms operate over the min-plus semiring (ℝ ∪ {+∞}, min, +).
"""

import numpy as np
from typing import List, Tuple, Optional, Dict


# ═══════════════════════════════════════════════════════════════════════
# Algorithm 1: Tropical Diffusion
# ═══════════════════════════════════════════════════════════════════════

def tropical_matrix_multiply(A: np.ndarray, B: np.ndarray) -> np.ndarray:
    """
    Min-plus matrix multiplication: C[i,j] = min_k (A[i,k] + B[k,j]).
    
    This is the fundamental operation in the tropical semiring.
    Time: O(n³)  Space: O(n²)
    
    Parameters
    ----------
    A, B : np.ndarray, shape (n, n)
    
    Returns
    -------
    np.ndarray, shape (n, n)
    """
    n = A.shape[0]
    C = np.full((n, n), np.inf)
    for i in range(n):
        for j in range(n):
            for k in range(n):
                C[i, j] = min(C[i, j], A[i, k] + B[k, j])
    return C


def tropical_power(w: np.ndarray, k: int) -> np.ndarray:
    """
    Compute the k-th tropical power of matrix w.
    
    w^(k)[i,j] = min over all k-step walks from i to j of the total cost.
    Uses repeated squaring for efficiency.
    
    Time: O(n³ log k)  Space: O(n²)
    """
    n = w.shape[0]
    if k == 0:
        result = np.full((n, n), np.inf)
        np.fill_diagonal(result, 0)
        return result
    if k == 1:
        return w.copy()
    
    half = tropical_power(w, k // 2)
    result = tropical_matrix_multiply(half, half)
    if k % 2 == 1:
        result = tropical_matrix_multiply(result, w)
    return result


def tropical_diffusion_iterate(w: np.ndarray, L: np.ndarray, steps: int) -> List[np.ndarray]:
    """
    Iterate tropical diffusion, recording the language at each step.
    
    Parameters
    ----------
    w : np.ndarray, shape (n, n)
        Replacement kernel.
    L : np.ndarray, shape (n,)
        Initial language.
    steps : int
        Number of diffusion steps.
    
    Returns
    -------
    List of np.ndarray
        Languages at each step [L₀, L₁, ..., L_steps].
    """
    trajectory = [L.copy()]
    current = L.copy()
    for _ in range(steps):
        n = len(current)
        new = np.full(n, np.inf)
        for j in range(n):
            for i in range(n):
                new[j] = min(new[j], current[i] + w[i, j])
        current = new
        trajectory.append(current.copy())
    return trajectory


# ═══════════════════════════════════════════════════════════════════════
# Algorithm 2: Tropical Shortest Paths (Floyd-Warshall)
# ═══════════════════════════════════════════════════════════════════════

def tropical_closure(w: np.ndarray) -> np.ndarray:
    """
    Compute the tropical (Kleene) closure: shortest-path distances.
    
    This is the min-plus analogue of matrix inversion. The result
    d[i,j] is the shortest-path distance from i to j.
    
    Implements Floyd-Warshall algorithm.
    Time: O(n³)  Space: O(n²)
    
    Parameters
    ----------
    w : np.ndarray, shape (n, n)
        Edge weight matrix.
    
    Returns
    -------
    np.ndarray, shape (n, n)
        Shortest-path distance matrix.
    """
    n = w.shape[0]
    d = w.copy().astype(float)
    
    for k in range(n):
        for i in range(n):
            for j in range(n):
                if d[i, k] + d[k, j] < d[i, j]:
                    d[i, j] = d[i, k] + d[k, j]
    
    return d


def tropical_closure_with_paths(w: np.ndarray) -> Tuple[np.ndarray, np.ndarray]:
    """
    Shortest paths with path reconstruction.
    
    Returns both the distance matrix and the predecessor matrix
    for reconstructing optimal paths.
    
    Time: O(n³)  Space: O(n²)
    """
    n = w.shape[0]
    d = w.copy().astype(float)
    pred = np.full((n, n), -1, dtype=int)
    
    for i in range(n):
        for j in range(n):
            if i != j and w[i, j] < np.inf:
                pred[i, j] = i
    
    for k in range(n):
        for i in range(n):
            for j in range(n):
                if d[i, k] + d[k, j] < d[i, j]:
                    d[i, j] = d[i, k] + d[k, j]
                    pred[i, j] = pred[k, j]
    
    return d, pred


def reconstruct_path(pred: np.ndarray, u: int, v: int) -> List[int]:
    """Reconstruct shortest path from predecessor matrix."""
    if pred[u, v] == -1:
        return [] if u != v else [u]
    path = [v]
    while path[-1] != u:
        path.append(pred[u, path[-1]])
        if len(path) > pred.shape[0]:
            return []  # no path
    return list(reversed(path))


# ═══════════════════════════════════════════════════════════════════════
# Algorithm 3: Four-Point Condition and Tree Metric Detection
# ═══════════════════════════════════════════════════════════════════════

def check_four_point(d: np.ndarray, tol: float = 1e-10) -> Tuple[bool, float, Optional[Tuple]]:
    """
    Check whether a distance matrix satisfies the four-point condition.
    
    The four-point condition: for all a,b,c,e,
      d(a,b) + d(c,e) ≤ max(d(a,c) + d(b,e), d(a,e) + d(b,c))
    
    This characterizes tree metrics (additive metrics realizable on a tree).
    
    Time: O(n⁴)  Space: O(1)
    
    Returns
    -------
    (is_tree_metric, max_violation, worst_quadruple)
    """
    n = d.shape[0]
    max_violation = 0.0
    worst = None
    
    for a in range(n):
        for b in range(a + 1, n):
            for c in range(b + 1, n):
                for e in range(c + 1, n):
                    sums = sorted([
                        d[a, b] + d[c, e],
                        d[a, c] + d[b, e],
                        d[a, e] + d[b, c]
                    ])
                    # Four-point: the two largest should be equal (or close)
                    # Equivalently: smallest ≤ each of the other two
                    violation = sums[0] - sums[1]  # should be ≤ 0
                    # Actually check: each sum ≤ max of other two
                    for s in [d[a, b] + d[c, e], d[a, c] + d[b, e], d[a, e] + d[b, c]]:
                        others = [d[a, b] + d[c, e], d[a, c] + d[b, e], d[a, e] + d[b, c]]
                        others.remove(s)
                        v = s - max(others)
                        if v > max_violation:
                            max_violation = v
                            worst = (a, b, c, e)
    
    return max_violation <= tol, max_violation, worst


def check_ultrametric(d: np.ndarray, tol: float = 1e-10) -> Tuple[bool, float]:
    """
    Check whether a distance matrix is an ultrametric.
    
    Ultrametric condition: d(a,c) ≤ max(d(a,b), d(b,c)) for all a,b,c.
    
    Time: O(n³)  Space: O(1)
    """
    n = d.shape[0]
    max_violation = 0.0
    
    for a in range(n):
        for b in range(n):
            for c in range(n):
                v = d[a, c] - max(d[a, b], d[b, c])
                max_violation = max(max_violation, v)
    
    return max_violation <= tol, max_violation


# ═══════════════════════════════════════════════════════════════════════
# Algorithm 4: Neighbor-Joining Tree Reconstruction
# ═══════════════════════════════════════════════════════════════════════

def neighbor_joining(d: np.ndarray, labels: Optional[List[str]] = None) -> Dict:
    """
    Neighbor-joining algorithm for phylogenetic tree reconstruction.
    
    Given a distance matrix, constructs a tree that realizes (approximately)
    the input distances. For additive (tree) metrics, the reconstruction is exact.
    
    Time: O(n³)  Space: O(n²)
    
    Parameters
    ----------
    d : np.ndarray, shape (n, n)
        Distance matrix.
    labels : list of str, optional
        Labels for the leaves.
    
    Returns
    -------
    dict with keys:
        'edges': list of (node1, node2, weight)
        'labels': dict mapping node_id to label
    """
    n = d.shape[0]
    if labels is None:
        labels = [f"L{i}" for i in range(n)]
    
    active = list(range(n))
    dist = d.copy().astype(float)
    node_labels = {i: labels[i] for i in range(n)}
    edges = []
    next_id = n
    
    while len(active) > 2:
        m = len(active)
        
        # Compute Q matrix
        Q = np.full((m, m), np.inf)
        for i_idx in range(m):
            for j_idx in range(m):
                if i_idx != j_idx:
                    i, j = active[i_idx], active[j_idx]
                    row_sum_i = sum(dist[i, active[k]] for k in range(m))
                    row_sum_j = sum(dist[j, active[k]] for k in range(m))
                    Q[i_idx, j_idx] = (m - 2) * dist[i, j] - row_sum_i - row_sum_j
        
        # Find minimum Q
        min_val = np.inf
        min_i, min_j = 0, 1
        for i_idx in range(m):
            for j_idx in range(i_idx + 1, m):
                if Q[i_idx, j_idx] < min_val:
                    min_val = Q[i_idx, j_idx]
                    min_i, min_j = i_idx, j_idx
        
        i, j = active[min_i], active[min_j]
        
        # Compute edge lengths to new node
        row_sum_i = sum(dist[i, active[k]] for k in range(m))
        row_sum_j = sum(dist[j, active[k]] for k in range(m))
        
        if m > 2:
            d_iu = dist[i, j] / 2 + (row_sum_i - row_sum_j) / (2 * (m - 2))
        else:
            d_iu = dist[i, j] / 2
        d_ju = dist[i, j] - d_iu
        
        # Create new node
        u = next_id
        next_id += 1
        node_labels[u] = f"Internal_{u}"
        
        edges.append((u, i, max(0, d_iu)))
        edges.append((u, j, max(0, d_ju)))
        
        # Update distance matrix
        new_size = max(max(active) + 1, u + 1)
        if new_size > dist.shape[0]:
            new_dist = np.full((new_size, new_size), np.inf)
            new_dist[:dist.shape[0], :dist.shape[1]] = dist
            dist = new_dist
        
        for k_idx in range(m):
            k = active[k_idx]
            if k != i and k != j:
                dist[u, k] = (dist[i, k] + dist[j, k] - dist[i, j]) / 2
                dist[k, u] = dist[u, k]
        dist[u, u] = 0
        
        active.remove(i)
        active.remove(j)
        active.append(u)
    
    # Connect last two nodes
    if len(active) == 2:
        i, j = active
        edges.append((i, j, dist[i, j]))
    
    return {'edges': edges, 'labels': node_labels}


# ═══════════════════════════════════════════════════════════════════════
# Algorithm 5: Glottochronological Dating
# ═══════════════════════════════════════════════════════════════════════

def glottochronological_date(d_xy: float, rho: float) -> float:
    """
    Compute divergence time from tropical distance and evolution rate.
    
    Under ultrametric assumptions:
        divergence_time = tropical_distance / (2 * ρ)
    
    Parameters
    ----------
    d_xy : float
        Tropical distance between languages x and y.
    rho : float
        Constant lexical evolution rate (> 0).
    
    Returns
    -------
    float
        Estimated divergence time.
    """
    assert rho > 0, "Evolution rate must be positive"
    return d_xy / (2 * rho)


def estimate_evolution_rate(distances: List[Tuple[float, float]]) -> float:
    """
    Estimate evolution rate ρ from known (distance, time) pairs.
    
    Uses least-squares: ρ = Σ(d_i * t_i) / Σ(2 * t_i²)
    
    Parameters
    ----------
    distances : list of (tropical_distance, known_divergence_time)
    
    Returns
    -------
    float
        Estimated ρ.
    """
    num = sum(d * t for d, t in distances)
    den = sum(2 * t * t for _, t in distances)
    return num / den if den > 0 else 0.0


# ═══════════════════════════════════════════════════════════════════════
# Example Usage
# ═══════════════════════════════════════════════════════════════════════

if __name__ == "__main__":
    print("=== Tropical Phylogenetics Algorithms ===\n")
    
    # Example: Indo-European-like distance matrix
    # Languages: English, German, French, Italian, Russian
    labels = ["English", "German", "French", "Italian", "Russian"]
    d = np.array([
        [0, 3, 7, 8, 10],
        [3, 0, 8, 9, 11],
        [7, 8, 0, 3, 9],
        [8, 9, 3, 0, 10],
        [10, 11, 9, 10, 0]
    ], dtype=float)
    
    print("Distance matrix:")
    for i, l in enumerate(labels):
        print(f"  {l:>8s}: {d[i]}")
    
    is_tree, viol, worst = check_four_point(d)
    print(f"\nFour-point condition satisfied: {is_tree} (violation: {viol:.4f})")
    
    tree = neighbor_joining(d, labels)
    print(f"\nReconstructed tree edges:")
    for u, v, w in tree['edges']:
        label_u = tree['labels'].get(u, str(u))
        label_v = tree['labels'].get(v, str(v))
        print(f"  {label_u} -- {label_v} : {w:.2f}")
    
    print(f"\nGlottochronological dating (ρ = 0.5):")
    rho = 0.5
    for i in range(len(labels)):
        for j in range(i + 1, len(labels)):
            t = glottochronological_date(d[i, j], rho)
            print(f"  {labels[i]:>8s} vs {labels[j]:<8s}: dist = {d[i,j]:.0f}, time = {t:.1f}")
