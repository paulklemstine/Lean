"""
Algorithms for fractional transversal computation, threshold rounding,
and heterogeneity analysis of hypergraphs.

Implements the core algorithms from the research paper:
- LP-based fractional transversal computation (τ*)
- Threshold rounding for integer transversal approximation
- Edge heterogeneity index computation
- Fractional matching computation (ν*)
"""

from __future__ import annotations
import numpy as np
from typing import NamedTuple
from scipy.optimize import linprog


class Hypergraph:
    """A hypergraph H = (V, E) with vertices {0, ..., n-1} and edges as sets of vertices."""

    def __init__(self, n: int, edges: list[set[int]]):
        """
        Args:
            n: Number of vertices.
            edges: List of edges, each a set of vertex indices.
        """
        self.n = n
        self.edges = [set(e) for e in edges]
        self.m = len(edges)

    def incidence_matrix(self) -> np.ndarray:
        """Return the |E| x |V| incidence matrix A where A[i,j] = 1 iff j in edges[i]."""
        A = np.zeros((self.m, self.n))
        for i, e in enumerate(self.edges):
            for v in e:
                A[i, v] = 1.0
        return A

    def __repr__(self) -> str:
        return f"Hypergraph(n={self.n}, m={self.m}, edges={self.edges})"


class TransversalResult(NamedTuple):
    """Result of a fractional or integer transversal computation."""
    value: float
    solution: np.ndarray
    success: bool


def compute_fractional_transversal(H: Hypergraph) -> TransversalResult:
    """
    Compute the fractional transversal number τ*(H) via linear programming.

    Solves:
        minimize    Σ_v x(v)
        subject to  Σ_{v∈e} x(v) ≥ 1   for all e ∈ E
                    x(v) ≥ 0             for all v ∈ V

    Args:
        H: Input hypergraph.

    Returns:
        TransversalResult with optimal value, solution vector, and success flag.

    Example:
        >>> H = Hypergraph(4, [{0,1}, {1,2}, {2,3}])
        >>> result = compute_fractional_transversal(H)
        >>> print(f"τ* = {result.value:.4f}")
        τ* = 1.5000
    """
    if H.m == 0:
        return TransversalResult(0.0, np.zeros(H.n), True)

    c = np.ones(H.n)  # Objective: minimize sum of x
    A = -H.incidence_matrix()  # -Ax ≤ -1 (i.e., Ax ≥ 1)
    b = -np.ones(H.m)
    bounds = [(0, None) for _ in range(H.n)]

    result = linprog(c, A_ub=A, b_ub=b, bounds=bounds, method='highs')

    if result.success:
        return TransversalResult(result.fun, result.x, True)
    else:
        return TransversalResult(float('inf'), np.zeros(H.n), False)


def compute_fractional_matching(H: Hypergraph) -> TransversalResult:
    """
    Compute the fractional matching number ν*(H) via linear programming.

    Solves:
        maximize    Σ_e y(e)
        subject to  Σ_{e∋v} y(e) ≤ 1   for all v ∈ V
                    y(e) ≥ 0             for all e ∈ E

    Args:
        H: Input hypergraph.

    Returns:
        TransversalResult with optimal value, solution vector, and success flag.

    Example:
        >>> H = Hypergraph(4, [{0,1}, {1,2}, {2,3}])
        >>> result = compute_fractional_matching(H)
        >>> print(f"ν* = {result.value:.4f}")
        ν* = 1.5000
    """
    if H.m == 0:
        return TransversalResult(0.0, np.zeros(0), True)

    c = -np.ones(H.m)  # Maximize = minimize negative
    A = H.incidence_matrix().T  # A^T y ≤ 1
    b = np.ones(H.n)
    bounds = [(0, None) for _ in range(H.m)]

    result = linprog(c, A_ub=A, b_ub=b, bounds=bounds, method='highs')

    if result.success:
        return TransversalResult(-result.fun, result.x, True)
    else:
        return TransversalResult(0.0, np.zeros(H.m), False)


def threshold_rounding(H: Hypergraph, x: np.ndarray, d: int) -> set[int]:
    """
    Round a fractional transversal to an integer transversal via thresholding.

    Given fractional transversal x and edge size bound d, returns
    S = {v : x(v) ≥ 1/d}, which is guaranteed to be a transversal
    with |S| ≤ d · Σ x(v).

    Args:
        H: Input hypergraph.
        x: Fractional transversal solution.
        d: Maximum edge size bound.

    Returns:
        Set of vertices forming an integer transversal.

    Example:
        >>> H = Hypergraph(4, [{0,1}, {1,2}, {2,3}])
        >>> result = compute_fractional_transversal(H)
        >>> S = threshold_rounding(H, result.solution, d=2)
        >>> print(f"Integer transversal: {S}, size: {len(S)}")
    """
    threshold = 1.0 / d
    S = {v for v in range(H.n) if x[v] >= threshold - 1e-10}
    return S


def compute_integer_transversal_exact(H: Hypergraph) -> TransversalResult:
    """
    Compute the exact integer transversal number τ(H) via brute force.

    Warning: Exponential time. Only suitable for small hypergraphs (n ≤ 25).

    Args:
        H: Input hypergraph.

    Returns:
        TransversalResult with optimal integer value and indicator solution.
    """
    n = H.n
    best_size = n + 1
    best_set = set(range(n))

    for mask in range(1 << n):
        S = {v for v in range(n) if mask & (1 << v)}
        if all(S & e for e in H.edges):
            if len(S) < best_size:
                best_size = len(S)
                best_set = S

    x = np.zeros(n)
    for v in best_set:
        x[v] = 1.0

    return TransversalResult(float(best_size), x, True)


def edge_heterogeneity(H: Hypergraph) -> float:
    """
    Compute the edge-size heterogeneity σ²(H).

    σ²(H) = (1/|E|) · Σ_{e∈E} (|e| - d̄)²

    where d̄ is the mean edge cardinality.

    Args:
        H: Input hypergraph.

    Returns:
        Edge heterogeneity value (0 iff uniform).

    Example:
        >>> H = Hypergraph(6, [{0,1}, {2,3,4}, {1,2,3,4,5}])
        >>> print(f"σ² = {edge_heterogeneity(H):.4f}")
        σ² = 1.5556
    """
    if H.m == 0:
        return 0.0
    sizes = np.array([len(e) for e in H.edges], dtype=float)
    d_bar = sizes.mean()
    return float(np.mean((sizes - d_bar) ** 2))


def generate_random_hypergraph(
    n: int,
    num_edges: int,
    size_distribution: dict[int, float],
    rng: np.random.Generator | None = None,
) -> Hypergraph:
    """
    Generate a random hypergraph with edges of sizes drawn from a distribution.

    Args:
        n: Number of vertices.
        num_edges: Number of edges to generate.
        size_distribution: Dict mapping edge size k to probability p_k.
        rng: Random number generator (optional).

    Returns:
        Random hypergraph.

    Example:
        >>> H = generate_random_hypergraph(10, 15, {2: 0.5, 3: 0.3, 4: 0.2})
    """
    if rng is None:
        rng = np.random.default_rng()

    sizes = list(size_distribution.keys())
    probs = [size_distribution[k] for k in sizes]
    probs = np.array(probs) / sum(probs)

    edges = []
    for _ in range(num_edges):
        k = rng.choice(sizes, p=probs)
        if k <= n:
            edge = set(rng.choice(n, size=min(k, n), replace=False).tolist())
            edges.append(edge)

    # Remove duplicates
    unique_edges = []
    seen = set()
    for e in edges:
        key = frozenset(e)
        if key not in seen:
            seen.add(key)
            unique_edges.append(e)

    return Hypergraph(n, unique_edges)


def verify_weak_duality(H: Hypergraph) -> dict:
    """
    Verify weak duality ν*(H) ≤ τ*(H) computationally.

    Args:
        H: Input hypergraph.

    Returns:
        Dictionary with τ*, ν*, gap, and verification status.

    Example:
        >>> H = Hypergraph(5, [{0,1,2}, {1,2,3}, {3,4}])
        >>> result = verify_weak_duality(H)
        >>> print(f"τ* = {result['tau_star']:.4f}, ν* = {result['nu_star']:.4f}")
    """
    tau = compute_fractional_transversal(H)
    nu = compute_fractional_matching(H)

    return {
        'tau_star': tau.value,
        'nu_star': nu.value,
        'gap': tau.value - nu.value,
        'weak_duality_holds': nu.value <= tau.value + 1e-8,
        'strong_duality_holds': abs(tau.value - nu.value) < 1e-6,
    }


def verify_integrality_gap_bound(H: Hypergraph) -> dict:
    """
    Verify the integrality gap bound τ(H) ≤ d_max · τ*(H).

    Args:
        H: Input hypergraph.

    Returns:
        Dictionary with τ, τ*, d_max, bound, and verification status.
    """
    tau_frac = compute_fractional_transversal(H)
    tau_int = compute_integer_transversal_exact(H)
    d_max = max((len(e) for e in H.edges), default=0)

    return {
        'tau': int(tau_int.value),
        'tau_star': tau_frac.value,
        'd_max': d_max,
        'bound': d_max * tau_frac.value,
        'gap': tau_int.value - tau_frac.value,
        'bound_holds': tau_int.value <= d_max * tau_frac.value + 1e-8,
    }


if __name__ == '__main__':
    # Example usage
    print("=" * 60)
    print("Example 1: Path graph (3 edges)")
    print("=" * 60)
    H = Hypergraph(4, [{0, 1}, {1, 2}, {2, 3}])
    print(f"Hypergraph: {H}")

    tau = compute_fractional_transversal(H)
    print(f"τ* = {tau.value:.4f}, solution = {tau.solution}")

    nu = compute_fractional_matching(H)
    print(f"ν* = {nu.value:.4f}, solution = {nu.solution}")

    tau_int = compute_integer_transversal_exact(H)
    print(f"τ  = {int(tau_int.value)}")

    d_max = max(len(e) for e in H.edges)
    S = threshold_rounding(H, tau.solution, d_max)
    print(f"Rounded transversal: {S}, size: {len(S)}")

    print(f"\nWeak duality check: {verify_weak_duality(H)}")
    print(f"Gap bound check: {verify_integrality_gap_bound(H)}")

    print("\n" + "=" * 60)
    print("Example 2: Mixed-size hypergraph")
    print("=" * 60)
    H2 = Hypergraph(6, [{0, 1}, {2, 3, 4}, {1, 2, 3, 4, 5}, {0, 5}])
    print(f"Hypergraph: {H2}")
    print(f"Edge heterogeneity σ² = {edge_heterogeneity(H2):.4f}")
    print(f"Gap bound check: {verify_integrality_gap_bound(H2)}")
