#!/usr/bin/env python3
"""
Spectral Lorentzian Stability — Algorithms

Implements the core algorithms from the research paper:
1. Graph Laplacian computation and algebraic connectivity
2. Spanning tree polynomial evaluation
3. Quadratic leaf Hessian computation
4. Lorentzian signature verification
5. Certified stability radius computation
6. Empirical stability radius estimation via binary search
"""

import numpy as np
from itertools import combinations
from typing import List, Tuple, Optional


def graph_laplacian(adj: np.ndarray) -> np.ndarray:
    """Compute the graph Laplacian L = D - A.
    
    Args:
        adj: n×n symmetric adjacency matrix (0/1 entries)
    
    Returns:
        n×n Laplacian matrix with eigenvalues 0 = λ₁ ≤ λ₂ ≤ ... ≤ λ_n
    
    Time: O(n²)
    Space: O(n²)
    """
    D = np.diag(adj.sum(axis=1))
    return D - adj


def algebraic_connectivity(L: np.ndarray) -> float:
    """Compute λ₂(L), the algebraic connectivity (Fiedler value).
    
    Args:
        L: n×n graph Laplacian
    
    Returns:
        Second-smallest eigenvalue of L
    
    Time: O(n³) via eigendecomposition
    """
    evals = np.linalg.eigvalsh(L)
    evals.sort()
    return float(evals[1]) if len(evals) > 1 else 0.0


def fiedler_vector(L: np.ndarray) -> np.ndarray:
    """Compute the Fiedler vector (eigenvector for λ₂).
    
    Args:
        L: n×n graph Laplacian
    
    Returns:
        Eigenvector corresponding to the second-smallest eigenvalue
    """
    evals, evecs = np.linalg.eigh(L)
    idx = np.argsort(evals)
    return evecs[:, idx[1]]


def edge_list(adj: np.ndarray) -> List[Tuple[int, int]]:
    """Extract edges from adjacency matrix.
    
    Args:
        adj: n×n adjacency matrix
    
    Returns:
        List of (i, j) pairs with i < j
    """
    n = adj.shape[0]
    return [(i, j) for i in range(n) for j in range(i + 1, n) if adj[i, j] > 0]


def enumerate_spanning_trees(adj: np.ndarray) -> Tuple[List[Tuple[int, ...]], List[Tuple[int, int]]]:
    """Enumerate all spanning trees of a graph.
    
    Uses brute force enumeration for small graphs (n ≤ 10).
    
    Args:
        adj: n×n adjacency matrix
    
    Returns:
        (trees, edges) where trees is a list of edge index tuples
    
    Time: O(C(m, n-1) · n) where m = |E|
    """
    n = adj.shape[0]
    edges = edge_list(adj)
    m = len(edges)
    trees = []
    
    for combo in combinations(range(m), n - 1):
        edge_set = [edges[i] for i in combo]
        # Connectivity check via DFS
        adj_tree = {i: [] for i in range(n)}
        for u, v in edge_set:
            adj_tree[u].append(v)
            adj_tree[v].append(u)
        visited = set()
        stack = [0]
        while stack:
            node = stack.pop()
            if node not in visited:
                visited.add(node)
                stack.extend(nb for nb in adj_tree[node] if nb not in visited)
        if len(visited) == n:
            trees.append(combo)
    
    return trees, edges


def spanning_tree_count(adj: np.ndarray) -> int:
    """Count spanning trees via Kirchhoff's matrix tree theorem.
    
    τ(G) = (1/n) · ∏ᵢ₌₂ⁿ λᵢ(L)
    
    Args:
        adj: n×n adjacency matrix
    
    Returns:
        Number of spanning trees
    
    Time: O(n³)
    """
    n = adj.shape[0]
    if n <= 1:
        return 1
    L = graph_laplacian(adj)
    evals = np.linalg.eigvalsh(L)
    evals.sort()
    # Product of nonzero eigenvalues divided by n
    nonzero = evals[1:]
    return int(round(np.prod(nonzero) / n))


def spanning_tree_polynomial_eval(adj: np.ndarray, x: np.ndarray) -> float:
    """Evaluate T_G(x) = Σ_T Π_{e∈T} x_e.
    
    Args:
        adj: n×n adjacency matrix
        x: m-dimensional vector (one coordinate per edge)
    
    Returns:
        Value of the spanning tree polynomial at x
    
    Time: O(C(m, n-1) · n)
    """
    trees, _ = enumerate_spanning_trees(adj)
    return sum(np.prod([x[e] for e in tree]) for tree in trees)


def numerical_hessian(f, x: np.ndarray, eps: float = 1e-5) -> np.ndarray:
    """Compute the Hessian of f at x via finite differences.
    
    Args:
        f: Function from R^m to R
        x: Point at which to evaluate
        eps: Step size for finite differences
    
    Returns:
        m×m Hessian matrix
    
    Time: O(m² · T(f)) where T(f) is the evaluation time of f
    """
    m = len(x)
    H = np.zeros((m, m))
    f0 = f(x)
    
    for i in range(m):
        ei = np.zeros(m)
        ei[i] = eps
        for j in range(i, m):
            ej = np.zeros(m)
            ej[j] = eps
            H[i, j] = (f(x + ei + ej) - f(x + ei - ej) - f(x - ei + ej) + f(x - ei - ej)) / (4 * eps ** 2)
            H[j, i] = H[i, j]
    
    return H


def check_at_most_one_positive_eigenvalue(H: np.ndarray, tol: float = 1e-8) -> bool:
    """Check if a symmetric matrix has at most one positive eigenvalue.
    
    Args:
        H: Symmetric matrix
        tol: Tolerance for considering an eigenvalue positive
    
    Returns:
        True if at most one eigenvalue is positive
    """
    evals = np.linalg.eigvalsh(H)
    threshold = tol * max(abs(evals.max()), abs(evals.min()), 1.0)
    return int(np.sum(evals > threshold)) <= 1


def compute_spectral_gap(H: np.ndarray) -> float:
    """Compute the spectral gap of a Lorentzian-signature matrix.
    
    For a matrix with exactly one positive eigenvalue, the spectral gap
    is the absolute value of the second-largest eigenvalue (which is ≤ 0).
    
    Args:
        H: Symmetric matrix with at most one positive eigenvalue
    
    Returns:
        Absolute value of the second-largest eigenvalue
    """
    evals = np.linalg.eigvalsh(H)
    evals_sorted = np.sort(evals)[::-1]  # Descending
    if len(evals_sorted) >= 2:
        return abs(evals_sorted[1])
    return 0.0


def certified_stability_radius(spectral_gap: float, n_edges: int, n_vars: int) -> float:
    """Compute the certified stability radius from the proved theorem.
    
    From the formally verified result:
      StabilityRadiusAtLeast ≥ gap / 2  (in quadratic form norm)
    
    For entrywise perturbations:
      tolerance ≥ gap / (2n)
    
    Args:
        spectral_gap: Minimum spectral gap across all quadratic leaves
        n_edges: Number of edges |E|
        n_vars: Dimension of the Hessian matrices
    
    Returns:
        Certified lower bound on the entrywise perturbation tolerance
    """
    if n_vars == 0 or n_edges == 0:
        return 0.0
    return spectral_gap / (2 * n_vars)


def estimate_stability_radius_binary_search(
    adj: np.ndarray,
    num_trials: int = 30,
    max_perturbation: float = 10.0,
    tol: float = 1e-3
) -> float:
    """Estimate the Lorentzian stability radius via binary search.
    
    Searches for the largest perturbation magnitude that preserves
    the at-most-one-positive-eigenvalue property for quadratic leaves.
    
    Algorithm:
    1. Start with perturbation range [0, max_perturbation]
    2. Binary search: at each midpoint, check Lorentzian property
    3. Use random perturbation directions for robustness
    
    Args:
        adj: Adjacency matrix
        num_trials: Number of random trials per perturbation level
        max_perturbation: Initial upper bound for search
        tol: Convergence tolerance
    
    Returns:
        Estimated stability radius
    
    Time: O(log(max_perturbation/tol) · num_trials · T(Hessian))
    """
    edges = edge_list(adj)
    m = len(edges)
    
    if m == 0:
        return 0.0
    
    x = np.ones(m)
    f = lambda y: spanning_tree_polynomial_eval(adj, np.abs(y))
    
    def is_lorentzian_under_perturbation(magnitude):
        for _ in range(num_trials):
            x_pert = x + magnitude * np.random.randn(m)
            x_pert = np.abs(x_pert) + 0.01  # Ensure positivity
            f_pert = lambda y: spanning_tree_polynomial_eval(adj, y)
            H = numerical_hessian(f_pert, x_pert)
            if not check_at_most_one_positive_eigenvalue(H):
                return False
        return True
    
    lo, hi = 0.0, max_perturbation
    
    # Find upper bound
    while is_lorentzian_under_perturbation(hi) and hi < 1000:
        hi *= 2
    
    # Binary search
    for _ in range(50):
        mid = (lo + hi) / 2
        if is_lorentzian_under_perturbation(mid):
            lo = mid
        else:
            hi = mid
        if hi - lo < tol:
            break
    
    return lo


def cheeger_constant_estimate(adj: np.ndarray) -> float:
    """Estimate the Cheeger constant h(G) using the Fiedler vector.
    
    Uses the sweep cut heuristic: sort vertices by Fiedler vector,
    and find the minimum conductance cut.
    
    Args:
        adj: n×n adjacency matrix
    
    Returns:
        Estimated Cheeger constant
    
    Time: O(n² + n log n)
    """
    n = adj.shape[0]
    if n <= 1:
        return 0.0
    
    L = graph_laplacian(adj)
    fv = fiedler_vector(L)
    
    # Sort vertices by Fiedler vector value
    order = np.argsort(fv)
    
    best_h = float('inf')
    vol_total = adj.sum()
    
    for k in range(1, n):
        S = set(order[:k])
        # Count edges crossing the cut
        cut_edges = 0
        vol_S = 0
        for i in S:
            for j in range(n):
                if adj[i, j] > 0:
                    vol_S += adj[i, j]
                    if j not in S:
                        cut_edges += adj[i, j]
        
        vol_complement = vol_total - vol_S
        min_vol = min(vol_S, vol_complement)
        
        if min_vol > 0:
            h = cut_edges / min_vol
            best_h = min(best_h, h)
    
    return best_h if best_h < float('inf') else 0.0


def max_degree(adj: np.ndarray) -> int:
    """Maximum vertex degree."""
    return int(adj.sum(axis=1).max())


def cheeger_stability_bound(h_cheeger: float, d_max: int, n_edges: int) -> float:
    """Certified stability bound via Cheeger inequality.
    
    From the formally verified theorem:
      ρ ≥ h² / (4 · d_max)
    
    The discrete Cheeger inequality gives λ₂ ≥ h²/(2d_max),
    so the stability radius is ≥ h²/(4d_max).
    """
    if d_max == 0 or n_edges == 0:
        return 0.0
    return h_cheeger ** 2 / (4 * d_max)


# ─── Example usage ────────────────────────────────────────────

if __name__ == "__main__":
    print("Spectral Lorentzian Stability — Algorithm Demonstrations")
    print("=" * 60)
    
    # Example: K_4
    n = 4
    adj = np.ones((n, n)) - np.eye(n)
    
    print(f"\nGraph: K_{n}")
    print(f"Adjacency matrix:\n{adj}")
    
    L = graph_laplacian(adj)
    print(f"\nLaplacian:\n{L}")
    
    lam2 = algebraic_connectivity(L)
    print(f"\nAlgebraic connectivity λ₂ = {lam2:.4f}")
    
    tau = spanning_tree_count(adj)
    print(f"Spanning trees τ(G) = {tau}")
    
    fv = fiedler_vector(L)
    print(f"Fiedler vector: {fv.round(4)}")
    
    h = cheeger_constant_estimate(adj)
    d = max_degree(adj)
    print(f"Cheeger constant estimate h ≈ {h:.4f}")
    print(f"Max degree d_max = {d}")
    
    edges = edge_list(adj)
    m = len(edges)
    
    cert = certified_stability_radius(lam2, m, m)
    print(f"\nCertified stability radius (entrywise) ≥ {cert:.6f}")
    
    cheeger_bound = cheeger_stability_bound(h, d, m)
    print(f"Cheeger-based stability bound ≥ {cheeger_bound:.6f}")
    
    print(f"\nλ₂/|E| = {lam2 / m:.6f}")
    print(f"This ratio should control the stability radius.")
