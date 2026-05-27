"""
Algorithms for hypergraph transversal with bounded pair codegree.

Implements the rounding-and-repair algorithm for minimum transversal
with guaranteed bounds under pair codegree constraints.
"""

import numpy as np
from typing import List, Set, Tuple, Dict, Optional
from scipy.optimize import linprog


def compute_pair_codegree(n: int, edges: List[Set[int]]) -> np.ndarray:
    """Compute the pair codegree matrix.
    
    Args:
        n: Number of vertices (labeled 0..n-1)
        edges: List of edges, each a set of vertex indices
    
    Returns:
        n×n numpy array where entry (u,v) = number of edges containing both u and v
    """
    codeg = np.zeros((n, n), dtype=int)
    for e in edges:
        verts = list(e)
        for i in range(len(verts)):
            for j in range(i + 1, len(verts)):
                u, v = verts[i], verts[j]
                codeg[u, v] += 1
                codeg[v, u] += 1
    return codeg


def max_pair_codegree(n: int, edges: List[Set[int]]) -> int:
    """Compute the maximum pair codegree Δ₂(H).
    
    Args:
        n: Number of vertices
        edges: List of edges
    
    Returns:
        Maximum pair codegree (max over all pairs u ≠ v)
    """
    codeg = compute_pair_codegree(n, edges)
    np.fill_diagonal(codeg, 0)
    return int(codeg.max()) if n > 1 else 0


def pair_overlap_energy(n: int, edges: List[Set[int]], x: np.ndarray) -> float:
    """Compute the pair-overlap energy E(x).
    
    E(x) = Σ_{u≠v} codeg(u,v) · x(u) · x(v)
    
    Args:
        n: Number of vertices
        edges: List of edges
        x: Assignment vector (length n)
    
    Returns:
        The overlap energy value
    """
    codeg = compute_pair_codegree(n, edges)
    np.fill_diagonal(codeg, 0)
    energy = 0.0
    for u in range(n):
        for v in range(u + 1, n):
            energy += 2 * codeg[u, v] * x[u] * x[v]
    return energy


def solve_fractional_transversal(n: int, edges: List[Set[int]]) -> Optional[np.ndarray]:
    """Solve the fractional transversal LP.
    
    Minimize Σ x(v) subject to:
        Σ_{v∈e} x(v) ≥ 1 for all e ∈ E
        x(v) ≥ 0 for all v
    
    Args:
        n: Number of vertices
        edges: List of edges
    
    Returns:
        Optimal fractional transversal x*, or None if infeasible
    """
    if not edges:
        return np.zeros(n)
    
    c = np.ones(n)  # minimize sum
    
    # Constraints: -Σ_{v∈e} x(v) ≤ -1 for each edge
    A_ub = np.zeros((len(edges), n))
    b_ub = -np.ones(len(edges))
    
    for i, e in enumerate(edges):
        for v in e:
            A_ub[i, v] = -1.0
    
    bounds = [(0, None) for _ in range(n)]
    
    result = linprog(c, A_ub=A_ub, b_ub=b_ub, bounds=bounds, method='highs')
    
    if result.success:
        return result.x
    return None


def threshold_rounding(x: np.ndarray, d: int) -> Set[int]:
    """Classical threshold rounding at level 1/d.
    
    Args:
        x: Fractional assignment
        d: Uniformity parameter (threshold = 1/d)
    
    Returns:
        Set of vertices in the threshold set
    """
    threshold = 1.0 / d
    return {v for v in range(len(x)) if x[v] >= threshold}


def explicit_gap(d: int, K: int) -> float:
    """Compute the explicit gap defect 1/(d·(K+1))."""
    return 1.0 / (d * (K + 1))


def explicit_slack(d: int, K: int) -> float:
    """Compute the explicit slack K/(d·(K+1))."""
    return K / (d * (K + 1))


def rounding_with_gap_estimate(
    n: int,
    edges: List[Set[int]],
    d: int,
    K: int,
    x: Optional[np.ndarray] = None
) -> Tuple[Set[int], Dict[str, float]]:
    """Rounding algorithm with gap estimate under bounded codegree.
    
    Implements the quantitative rounding-and-repair algorithm:
    1. Solve the fractional LP (or use provided x)
    2. Apply threshold rounding at 1/d
    3. Compute gap estimates
    
    Args:
        n: Number of vertices
        edges: List of edges (each a set of vertex indices)
        d: Uniformity parameter
        K: Pair codegree bound
        x: Optional pre-computed fractional transversal
    
    Returns:
        Tuple of (transversal set, info dict with gap estimates)
    """
    if x is None:
        x = solve_fractional_transversal(n, edges)
        if x is None:
            return set(), {"error": "LP infeasible"}
    
    frac_value = float(np.sum(x))
    
    # Threshold rounding
    S = threshold_rounding(x, d)
    
    # Verify transversal property
    uncovered = [e for e in edges if not S.intersection(e)]
    
    # Greedy repair for uncovered edges
    for e in uncovered:
        # Add one vertex from each uncovered edge
        S.add(min(e))
    
    # Compute bounds
    gap = explicit_gap(d, K)
    slack = explicit_slack(d, K)
    classical_bound = d * frac_value
    improved_bound = (d - gap) * frac_value + slack * n
    
    # Compute overlap energy
    energy = pair_overlap_energy(n, edges, x)
    energy_bound = K * frac_value ** 2
    
    info = {
        "frac_value": frac_value,
        "transversal_size": len(S),
        "classical_bound": classical_bound,
        "improved_bound": improved_bound,
        "gap_ratio": len(S) / frac_value if frac_value > 0 else float('inf'),
        "overlap_energy": energy,
        "energy_bound": energy_bound,
        "energy_ratio": energy / energy_bound if energy_bound > 0 else 0.0,
        "actual_max_codegree": max_pair_codegree(n, edges),
        "uncovered_edges": len(uncovered),
    }
    
    return S, info


def generate_d_uniform_hypergraph(
    n: int,
    d: int,
    m: int,
    max_codegree: int = None
) -> List[Set[int]]:
    """Generate a random d-uniform hypergraph with optional codegree constraint.
    
    Args:
        n: Number of vertices
        d: Edge size
        m: Target number of edges
        max_codegree: Maximum allowed pair codegree (None = unconstrained)
    
    Returns:
        List of edges satisfying the constraints
    """
    from itertools import combinations
    
    edges = []
    codeg = np.zeros((n, n), dtype=int)
    attempts = 0
    max_attempts = m * 100
    
    while len(edges) < m and attempts < max_attempts:
        attempts += 1
        # Random d-element subset
        verts = set(np.random.choice(n, d, replace=False).tolist())
        
        if verts in [set(e) for e in edges]:
            continue
        
        # Check codegree constraint
        if max_codegree is not None:
            ok = True
            verts_list = list(verts)
            for i in range(len(verts_list)):
                for j in range(i + 1, len(verts_list)):
                    if codeg[verts_list[i], verts_list[j]] >= max_codegree:
                        ok = False
                        break
                if not ok:
                    break
            if not ok:
                continue
        
        edges.append(verts)
        verts_list = list(verts)
        for i in range(len(verts_list)):
            for j in range(i + 1, len(verts_list)):
                codeg[verts_list[i], verts_list[j]] += 1
                codeg[verts_list[j], verts_list[i]] += 1
    
    return edges


if __name__ == "__main__":
    # Example usage
    np.random.seed(42)
    
    n, d, K = 30, 3, 2
    edges = generate_d_uniform_hypergraph(n, d, m=50, max_codegree=K)
    
    print(f"Generated {len(edges)} edges on {n} vertices (d={d}, K={K})")
    print(f"Actual max codegree: {max_pair_codegree(n, edges)}")
    
    S, info = rounding_with_gap_estimate(n, edges, d, K)
    
    print(f"\nFractional value τ* = {info['frac_value']:.3f}")
    print(f"Transversal size τ = {info['transversal_size']}")
    print(f"Gap ratio τ/τ* = {info['gap_ratio']:.3f}")
    print(f"Classical bound: {info['classical_bound']:.3f}")
    print(f"Improved bound: {info['improved_bound']:.3f}")
    print(f"Overlap energy: {info['overlap_energy']:.3f}")
    print(f"Energy bound: {info['energy_bound']:.3f}")
    print(f"Energy ratio E/(K·(Σx)²) = {info['energy_ratio']:.3f}")
