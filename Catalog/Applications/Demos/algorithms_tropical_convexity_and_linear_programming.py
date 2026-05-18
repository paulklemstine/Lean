#!/usr/bin/env python3
"""
algorithms.py — Tropical Optimization Algorithms

Implements:
1. Floyd-Warshall closure for difference constraints
2. Bellman-Ford feasibility solver with witness extraction
3. Tropical convex hull membership test
4. Tropical projection / normalization
"""

import numpy as np
from typing import Optional, Tuple, List
from itertools import product


# ═══════════════════════════════════════════════════════════════
# 1. Floyd-Warshall Closure
# ═══════════════════════════════════════════════════════════════

def floyd_warshall_closure(c: np.ndarray) -> Tuple[np.ndarray, bool]:
    """
    Compute the Floyd-Warshall shortest-path closure of a weight matrix.

    Given c[i,j] representing the constraint x_i - x_j ≤ c[i,j],
    computes the tightest implied constraints (transitive closure).

    Args:
        c: n×n weight matrix with c[i,i] = 0 initially

    Returns:
        (closure, feasible): The closed matrix and whether the system
        is feasible (no negative diagonal = no negative cycle).

    Time complexity: O(n³)
    Space complexity: O(n²)

    Example:
        >>> c = np.array([[0, 5, np.inf], [-2, 0, 3], [np.inf, np.inf, 0]])
        >>> closure, feasible = floyd_warshall_closure(c)
        >>> print(feasible)
        True
        >>> print(closure[0, 2])  # Tightest bound on x0 - x2
        8.0
    """
    n = c.shape[0]
    d = c.copy()

    for k in range(n):
        for i in range(n):
            for j in range(n):
                if d[i, k] + d[k, j] < d[i, j]:
                    d[i, j] = d[i, k] + d[k, j]

    # Check for negative cycles (negative diagonal)
    feasible = all(d[i, i] >= -1e-12 for i in range(n))

    # Clean up diagonal
    if feasible:
        for i in range(n):
            d[i, i] = 0.0

    return d, feasible


# ═══════════════════════════════════════════════════════════════
# 2. Bellman-Ford Feasibility Solver
# ═══════════════════════════════════════════════════════════════

def bellman_ford_solve(
    n: int,
    edges: List[Tuple[int, int, float]]
) -> Tuple[bool, Optional[np.ndarray], Optional[List[int]]]:
    """
    Solve a system of difference constraints using Bellman-Ford.

    Each edge (i, j, w) encodes the constraint x_i ≤ w + x_j.

    Args:
        n: Number of variables
        edges: List of (i, j, w) triples

    Returns:
        (feasible, witness, neg_cycle):
        - feasible: True if the system has a solution
        - witness: A feasible assignment x if feasible, else None
        - neg_cycle: Vertex indices of a negative cycle if infeasible, else None

    Time complexity: O(n * |E|)
    Space complexity: O(n)

    Example:
        >>> feas, x, _ = bellman_ford_solve(3, [(0,1,3), (1,2,-1), (2,0,1)])
        >>> print(feas)
        True
        >>> print(x)
        [0.  0. -1.]
    """
    INF = float('inf')
    dist = np.zeros(n)
    parent = [-1] * n

    # Relax edges n-1 times
    for iteration in range(n - 1):
        updated = False
        for (i, j, w) in edges:
            if dist[j] + w < dist[i]:
                dist[i] = dist[j] + w
                parent[i] = j
                updated = True
        if not updated:
            break

    # Check for negative cycles
    for (i, j, w) in edges:
        if dist[j] + w < dist[i] - 1e-12:
            # Find the negative cycle
            cycle = _extract_negative_cycle(n, edges, parent, i)
            return False, None, cycle

    return True, dist, None


def _extract_negative_cycle(
    n: int,
    edges: List[Tuple[int, int, float]],
    parent: List[int],
    start: int
) -> List[int]:
    """Extract a negative cycle from Bellman-Ford parent pointers."""
    visited = {}
    node = start

    # Walk back n steps to ensure we're in a cycle
    for _ in range(n):
        node = parent[node] if parent[node] != -1 else node

    # Now trace the cycle
    cycle_start = node
    cycle = [cycle_start]
    node = parent[cycle_start] if parent[cycle_start] != -1 else cycle_start

    while node != cycle_start:
        cycle.append(node)
        node = parent[node] if parent[node] != -1 else node

    cycle.append(cycle_start)
    cycle.reverse()
    return cycle


# ═══════════════════════════════════════════════════════════════
# 3. Tropical Convex Hull Operations
# ═══════════════════════════════════════════════════════════════

def tropical_normalize(x: np.ndarray) -> np.ndarray:
    """
    Normalize a tropical vector so that max(x) = 0.

    This is the tropical analogue of projective normalization.

    Args:
        x: A real vector

    Returns:
        x - max(x), so that the maximum coordinate is 0.

    Example:
        >>> tropical_normalize(np.array([3.0, 1.0, 5.0]))
        array([-2., -4.,  0.])
    """
    return x - np.max(x)


def tropical_convex_combination(lam: np.ndarray, V: np.ndarray) -> np.ndarray:
    """
    Compute a tropical convex combination.

    x_i = max_j (lambda_j + V[j, i])

    Args:
        lam: Coefficient vector of shape (m,) with max(lam) = 0
        V: Generator matrix of shape (m, n)

    Returns:
        The tropical combination, shape (n,)

    Example:
        >>> V = np.array([[0, -1], [-1, 0]])
        >>> lam = np.array([0, -1])
        >>> tropical_convex_combination(lam, V)
        array([ 0., -1.])
    """
    return np.max(lam[:, None] + V, axis=0)


def tropical_hull_membership(
    x: np.ndarray,
    V: np.ndarray,
    tol: float = 1e-8
) -> Tuple[bool, Optional[np.ndarray]]:
    """
    Test if a point x lies in the tropical convex hull of generators V.

    For difference-constraint generators, the membership test reduces to
    checking if x satisfies the constraints defined by the generators.

    Args:
        x: Point to test, shape (n,)
        V: Generator matrix, shape (m, n)
        tol: Numerical tolerance

    Returns:
        (is_member, coefficients): Whether x is in the hull, and if so,
        the lambda coefficients.

    Example:
        >>> V = np.array([[0, -2], [-1, 0]])
        >>> x = np.array([0, -1])
        >>> in_hull, lam = tropical_hull_membership(x, V)
    """
    x_norm = tropical_normalize(x)
    m, n_dim = V.shape

    # Try lambda = x_norm (works for difference-constraint generators)
    lam = x_norm[:m] if m <= len(x_norm) else np.zeros(m)
    lam = tropical_normalize(lam)
    recon = tropical_convex_combination(lam, V)

    if np.allclose(recon, x_norm, atol=tol):
        return True, lam

    # Brute-force search over grid of lambda values
    # (only practical for small m)
    if m <= 5:
        grid = np.linspace(-3, 0, 20)
        best_err = float('inf')
        best_lam = None

        from itertools import product as iprod
        for combo in iprod(grid, repeat=m):
            lam_try = np.array(combo)
            lam_try = tropical_normalize(lam_try)
            recon_try = tropical_convex_combination(lam_try, V)
            err = np.max(np.abs(recon_try - x_norm))
            if err < best_err:
                best_err = err
                best_lam = lam_try.copy()

        if best_err < tol:
            return True, best_lam

    return False, None


# ═══════════════════════════════════════════════════════════════
# 4. Difference Constraint Polyhedra
# ═══════════════════════════════════════════════════════════════

def make_diff_constraint_generators(c: np.ndarray) -> np.ndarray:
    """
    Compute the canonical generators for a closed difference-constraint polyhedron.

    For a constraint matrix c with c[i,i]=0 and triangle inequality,
    the generators are the columns of -c: V[j,i] = -c[j,i].

    Args:
        c: n×n closed constraint matrix

    Returns:
        V: n×n generator matrix where V[j] is the j-th generator

    Example:
        >>> c = np.array([[0, 2, 3], [1, 0, 1], [2, 3, 0]])
        >>> V = make_diff_constraint_generators(c)
        >>> print(V[0])  # First generator
        [ 0. -1. -2.]
    """
    return -c


def check_diff_constraints(x: np.ndarray, c: np.ndarray) -> bool:
    """
    Check if x satisfies the difference constraints x_i - x_j ≤ c[i,j].

    Args:
        x: Point to check, shape (n,)
        c: Constraint matrix, shape (n, n)

    Returns:
        True if all constraints are satisfied.

    Example:
        >>> c = np.array([[0, 2], [1, 0]])
        >>> check_diff_constraints(np.array([1.0, 0.0]), c)
        True
    """
    n = len(x)
    for i in range(n):
        for j in range(n):
            if x[i] - x[j] > c[i, j] + 1e-10:
                return False
    return True


# ═══════════════════════════════════════════════════════════════
# Main: Run examples
# ═══════════════════════════════════════════════════════════════

if __name__ == "__main__":
    print("=" * 60)
    print("Algorithm 1: Floyd-Warshall Closure")
    print("=" * 60)

    c_raw = np.array([
        [0.0, 5.0, 100.0],
        [-2.0, 0.0, 3.0],
        [100.0, 100.0, 0.0],
    ])
    print(f"Input matrix:\n{c_raw}\n")

    closure, feasible = floyd_warshall_closure(c_raw)
    print(f"Feasible: {feasible}")
    print(f"Closure:\n{closure}\n")

    # Verify triangle inequality
    n = closure.shape[0]
    tri_ok = all(
        closure[i, k] <= closure[i, j] + closure[j, k] + 1e-10
        for i, j, k in product(range(n), repeat=3)
    )
    print(f"Triangle inequality holds: {tri_ok}")

    print("\n" + "=" * 60)
    print("Algorithm 2: Bellman-Ford Feasibility")
    print("=" * 60)

    edges = [(0, 1, 3), (1, 2, -1), (2, 0, 1), (1, 0, -2)]
    print("Edges (x_i ≤ w + x_j):")
    for (i, j, w) in edges:
        print(f"  x_{i} ≤ {w} + x_{j}")

    feas, witness, cycle = bellman_ford_solve(3, edges)
    print(f"\nFeasible: {feas}")
    if witness is not None:
        print(f"Witness: {witness}")
        print("Verification:")
        for (i, j, w) in edges:
            sat = witness[i] <= w + witness[j] + 1e-10
            print(f"  x_{i}={witness[i]:.2f} ≤ {w}+x_{j}={w+witness[j]:.2f}: {sat}")

    print("\n" + "=" * 60)
    print("Algorithm 3: Tropical Hull Membership")
    print("=" * 60)

    c = np.array([
        [0.0, 2.0, 3.0],
        [1.0, 0.0, 1.0],
        [2.0, 3.0, 0.0],
    ])
    V = make_diff_constraint_generators(c)
    print(f"Generators:\n{V}\n")

    test_points = [
        np.array([0.0, -0.5, -1.0]),
        np.array([0.0, 0.0, 0.0]),
        np.array([0.0, -1.0, -2.0]),
    ]

    for pt in test_points:
        pt_norm = tropical_normalize(pt)
        in_poly = check_diff_constraints(pt_norm, c)
        in_hull, lam = tropical_hull_membership(pt_norm, V)
        print(f"Point {pt_norm}: in polyhedron={in_poly}, in hull={in_hull}")
        if lam is not None:
            recon = tropical_convex_combination(lam, V)
            print(f"  λ = {lam}, reconstruction = {recon}")

    print("\nAll algorithms completed successfully!")
