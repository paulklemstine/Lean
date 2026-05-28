"""
Overlap-Adaptive Rounding for Hypergraph Transversals
=====================================================

Implements the deterministic adaptive rounding algorithm for bounded-overlap
hypergraph transversals, where the algorithm extracts an effective overlap
parameter from the LP solution itself.

Key concepts:
- Pair codegree: c_H(u,v) = number of edges containing both u and v
- Pair-overlap energy: E_H(x) = sum_{u!=v} c_H(u,v) * x(u) * x(v)
- Effective overlap diagnostic: rho = E / M^2
- Adaptive threshold rounding at theta = 1/d
"""

from __future__ import annotations
import numpy as np
from typing import Optional
from dataclasses import dataclass


@dataclass
class Hypergraph:
    """A hypergraph on vertices {0, 1, ..., n-1}.

    Attributes:
        n: Number of vertices.
        edges: List of edges, each edge is a frozenset of vertex indices.
    """
    n: int
    edges: list[frozenset[int]]

    @property
    def m(self) -> int:
        """Number of edges."""
        return len(self.edges)

    def is_uniform(self, d: int) -> bool:
        """Check if all edges have exactly d elements."""
        return all(len(e) == d for e in self.edges)

    def max_edge_size(self) -> int:
        """Maximum edge cardinality."""
        return max((len(e) for e in self.edges), default=0)

    def pair_codegree(self, u: int, v: int) -> int:
        """Number of edges containing both u and v."""
        if u == v:
            return 0
        return sum(1 for e in self.edges if u in e and v in e)

    def max_pair_codegree(self) -> int:
        """Maximum pair codegree over all distinct pairs."""
        K = 0
        for i in range(self.n):
            for j in range(i + 1, self.n):
                K = max(K, self.pair_codegree(i, j))
        return K


def pair_overlap_energy(H: Hypergraph, x: np.ndarray) -> float:
    """Compute the pair-overlap energy E_H(x) = sum_{u!=v} c_H(u,v) * x(u) * x(v).

    Args:
        H: Hypergraph.
        x: Fractional assignment, shape (n,).

    Returns:
        The pair-overlap energy (off-diagonal).
    """
    energy = 0.0
    for e in H.edges:
        edge_list = sorted(e)
        for i, u in enumerate(edge_list):
            for v in edge_list[i+1:]:
                energy += 2 * x[u] * x[v]  # count both (u,v) and (v,u)
    return energy


def edge_square_energy(H: Hypergraph, x: np.ndarray) -> float:
    """Compute sum_e (sum_{v in e} x(v))^2."""
    return sum(sum(x[v] for v in e) ** 2 for e in H.edges)


def fractional_mass(x: np.ndarray) -> float:
    """Compute M(x) = sum_v x(v)."""
    return float(np.sum(x))


def effective_overlap(H: Hypergraph, x: np.ndarray) -> float:
    """Compute the effective overlap diagnostic rho = E_H(x) / M(x)^2.

    Returns 0 if M(x) = 0.
    """
    M = fractional_mass(x)
    if M == 0:
        return 0.0
    E = pair_overlap_energy(H, x)
    return E / (M ** 2)


def threshold_round(x: np.ndarray, theta: float) -> set[int]:
    """Threshold rounding: return {v : x(v) >= theta}."""
    return {v for v in range(len(x)) if x[v] >= theta}


def adaptive_threshold(d: int, rho: float) -> float:
    """Compute the adaptive threshold.

    For the basic version, this is simply 1/d.
    The diagnostic rho serves as a certificate of instance quality.

    Args:
        d: Uniformity parameter (max edge size).
        rho: Effective overlap diagnostic.

    Returns:
        Threshold value theta.
    """
    return 1.0 / d


def adaptive_round(H: Hypergraph, x: np.ndarray, d: Optional[int] = None) -> dict:
    """Deterministic adaptive rounding algorithm.

    Algorithm:
    1. Compute M = sum x(v), E = pair_overlap_energy(H, x), rho = E/M^2
    2. Set theta = 1/d (adaptive threshold)
    3. Round: T = {v : x(v) >= theta}
    4. Return T with diagnostic certificate

    Args:
        H: Hypergraph.
        x: Fractional transversal assignment.
        d: Max edge size (computed from H if not given).

    Returns:
        Dictionary with keys:
        - 'transversal': set of selected vertices
        - 'mass': fractional mass M
        - 'energy': pair-overlap energy E
        - 'rho': effective overlap diagnostic
        - 'theta': threshold used
        - 'card': |T|
        - 'ratio': |T| / M (approximation ratio)
    """
    if d is None:
        d = H.max_edge_size()

    M = fractional_mass(x)
    E = pair_overlap_energy(H, x)
    rho = E / (M ** 2) if M > 0 else 0.0
    theta = adaptive_threshold(d, rho)

    T = threshold_round(x, theta)

    # Verify transversal property
    uncovered = [e for e in H.edges if not T & e]
    if uncovered:
        # Greedy patching phase (shouldn't be needed for valid fractional transversals)
        for e in uncovered:
            # Add vertex with highest x value from uncovered edge
            best = max(e, key=lambda v: x[v])
            T.add(best)

    return {
        'transversal': T,
        'mass': M,
        'energy': E,
        'rho': rho,
        'theta': theta,
        'card': len(T),
        'ratio': len(T) / M if M > 0 else float('inf'),
    }


def classical_threshold_round(H: Hypergraph, x: np.ndarray, d: Optional[int] = None) -> set[int]:
    """Classical threshold rounding at 1/d without diagnostics."""
    if d is None:
        d = H.max_edge_size()
    return threshold_round(x, 1.0 / d)


def randomized_round(H: Hypergraph, x: np.ndarray, rng: Optional[np.random.Generator] = None) -> set[int]:
    """Independent randomized rounding: include v with probability min(1, x(v)).

    Repeats until all edges are covered.
    """
    if rng is None:
        rng = np.random.default_rng()

    for _ in range(100):  # max attempts
        T = {v for v in range(len(x)) if rng.random() < x[v]}
        # Check coverage
        if all(T & e for e in H.edges):
            return T
        # Patch uncovered edges
        for e in H.edges:
            if not T & e:
                T.add(rng.choice(list(e)))
        if all(T & e for e in H.edges):
            return T

    return T


def generate_random_uniform_hypergraph(
    n: int, d: int, m: int, K: int = 1,
    rng: Optional[np.random.Generator] = None
) -> Hypergraph:
    """Generate a random d-uniform hypergraph with approximate pair codegree bound K.

    Strategy: generate random d-subsets, rejecting those that would exceed
    pair codegree K.

    Args:
        n: Number of vertices.
        d: Edge size.
        m: Target number of edges.
        K: Maximum pair codegree.
        rng: Random number generator.

    Returns:
        A d-uniform Hypergraph.
    """
    if rng is None:
        rng = np.random.default_rng(42)

    edges = []
    pair_count: dict[tuple[int, int], int] = {}
    attempts = 0
    max_attempts = m * 20

    while len(edges) < m and attempts < max_attempts:
        attempts += 1
        e = frozenset(rng.choice(n, size=d, replace=False))
        edge_list = sorted(e)

        # Check pair codegree constraint
        ok = True
        for i, u in enumerate(edge_list):
            for v in edge_list[i+1:]:
                if pair_count.get((u, v), 0) >= K:
                    ok = False
                    break
            if not ok:
                break

        if ok:
            edges.append(e)
            for i, u in enumerate(edge_list):
                for v in edge_list[i+1:]:
                    pair_count[(u, v)] = pair_count.get((u, v), 0) + 1

    return Hypergraph(n=n, edges=edges)


def solve_fractional_transversal_uniform(H: Hypergraph, d: int) -> np.ndarray:
    """Compute a (heuristic) fractional transversal by uniform assignment.

    For a d-uniform hypergraph, x(v) = 1/d for all vertices in at least one edge
    gives a valid fractional transversal.

    For better approximation, we use a simple iterative scheme.
    """
    x = np.zeros(H.n)
    # Start with uniform 1/d for vertices in any edge
    active = set()
    for e in H.edges:
        active |= e
    for v in active:
        x[v] = 1.0 / d

    # Iterative improvement: reduce vertices that are over-covered
    for _ in range(50):
        for v in active:
            # Try reducing x[v] slightly
            old = x[v]
            x[v] = max(0, x[v] - 0.01)
            # Check feasibility
            ok = True
            for e in H.edges:
                if v in e and sum(x[u] for u in e) < 1.0:
                    ok = False
                    break
            if not ok:
                x[v] = old

    return x


def solve_lp_transversal(H: Hypergraph) -> np.ndarray:
    """Solve the LP relaxation of minimum transversal using scipy if available.

    Falls back to uniform assignment if scipy is not available.
    """
    try:
        from scipy.optimize import linprog
        # min sum x_v
        # s.t. sum_{v in e} x_v >= 1 for all e
        # 0 <= x_v <= 1
        c = np.ones(H.n)
        A_ub = []
        b_ub = []
        for e in H.edges:
            row = np.zeros(H.n)
            for v in e:
                row[v] = -1  # -sum >= -1 i.e. sum >= 1
            A_ub.append(row)
            b_ub.append(-1.0)
        bounds = [(0, 1)] * H.n
        result = linprog(c, A_ub=A_ub, b_ub=b_ub, bounds=bounds, method='highs')
        if result.success:
            return result.x
        else:
            d = H.max_edge_size()
            return solve_fractional_transversal_uniform(H, d)
    except ImportError:
        d = H.max_edge_size()
        return solve_fractional_transversal_uniform(H, d)


if __name__ == "__main__":
    # Example usage
    rng = np.random.default_rng(42)
    H = generate_random_uniform_hypergraph(n=20, d=3, m=15, K=2, rng=rng)
    x = solve_lp_transversal(H)

    result = adaptive_round(H, x)
    print(f"Hypergraph: n={H.n}, m={H.m}, d={H.max_edge_size()}")
    print(f"LP mass (tau*): {result['mass']:.4f}")
    print(f"Energy E: {result['energy']:.4f}")
    print(f"Diagnostic rho: {result['rho']:.4f}")
    print(f"Threshold theta: {result['theta']:.4f}")
    print(f"Transversal size: {result['card']}")
    print(f"Approximation ratio: {result['ratio']:.4f}")
    print(f"Max pair codegree K: {H.max_pair_codegree()}")
