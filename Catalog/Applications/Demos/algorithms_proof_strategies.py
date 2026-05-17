#!/usr/bin/env python3
"""
Algorithms for Series-Parallel Tropical Network Analysis.

Implements:
1. SP expression evaluation (tropical semiring homomorphism)
2. Canonical reduction algorithm
3. Tropical vertex elimination (Schur complement)
4. SP network reconstruction from boundary data
5. Floyd-Warshall tropical closure
"""

import numpy as np
from typing import List, Tuple, Optional, Union
from dataclasses import dataclass


# ============================================================
# Data Structures
# ============================================================

@dataclass
class SPNode:
    """Node in an SP expression tree."""
    kind: str  # 'atom', 'series', 'parallel'
    weight: Optional[float] = None
    children: Optional[List['SPNode']] = None

    def __repr__(self):
        if self.kind == 'atom':
            return f"E({self.weight:.2f})"
        elif self.kind == 'series':
            return f"S({', '.join(str(c) for c in self.children)})"
        elif self.kind == 'parallel':
            return f"P({', '.join(str(c) for c in self.children)})"
        return "?"


def atom(w: float) -> SPNode:
    """Create an atom (single edge) with weight w."""
    return SPNode(kind='atom', weight=w)


def series(*children: SPNode) -> SPNode:
    """Create a series composition."""
    return SPNode(kind='series', children=list(children))


def parallel(*children: SPNode) -> SPNode:
    """Create a parallel composition."""
    return SPNode(kind='parallel', children=list(children))


# ============================================================
# Algorithm 1: Effective Distance (Tropical Evaluation)
# ============================================================

def effective_distance(node: SPNode) -> float:
    """
    Compute the effective distance of an SP expression tree.

    This is a tropical semiring homomorphism:
      series  → addition      (tropical multiplication)
      parallel → minimum      (tropical addition)

    Time complexity: O(n) where n = number of nodes
    Space complexity: O(d) where d = depth of tree (recursion stack)

    Args:
        node: Root of SP expression tree

    Returns:
        The effective distance (shortest path between terminals)
    """
    if node.kind == 'atom':
        return node.weight
    elif node.kind == 'series':
        return sum(effective_distance(c) for c in node.children)
    elif node.kind == 'parallel':
        return min(effective_distance(c) for c in node.children)
    else:
        raise ValueError(f"Unknown node kind: {node.kind}")


# ============================================================
# Algorithm 2: Canonical Reduction
# ============================================================

def canonical_reduce(node: SPNode) -> SPNode:
    """
    Reduce an SP expression to its canonical form (a single atom).

    For two-terminal networks, every SP expression with positive weights
    is equivalent to a single edge with weight = effective_distance.

    Time complexity: O(n)
    Space complexity: O(d)

    Args:
        node: Root of SP expression tree with positive weights

    Returns:
        Atom with weight equal to effective_distance(node)
    """
    return atom(effective_distance(node))


# ============================================================
# Algorithm 3: Tropical Vertex Elimination (Schur Complement)
# ============================================================

def tropical_vertex_elimination(
    distance_matrix: np.ndarray,
    interior_vertices: List[int],
    boundary_vertices: List[int]
) -> np.ndarray:
    """
    Compute the tropical Schur complement by eliminating interior vertices.

    This implements the Floyd-Warshall-style vertex elimination:
    For each interior vertex v, update:
        D[i][j] = min(D[i][j], D[i][v] + D[v][j])
    for all boundary vertices i, j.

    The result is the boundary-to-boundary shortest path distance matrix.

    Time complexity: O(|I| · |B|²) where |I| = interior, |B| = boundary
    Space complexity: O(n²) where n = total vertices

    Args:
        distance_matrix: n×n distance matrix (np.inf for absent edges)
        interior_vertices: indices of vertices to eliminate
        boundary_vertices: indices of boundary vertices

    Returns:
        |B| × |B| boundary distance matrix
    """
    n = distance_matrix.shape[0]
    D = distance_matrix.copy()

    # Eliminate interior vertices one by one (Floyd-Warshall style)
    for v in interior_vertices:
        for i in range(n):
            for j in range(n):
                if D[i][v] + D[v][j] < D[i][j]:
                    D[i][j] = D[i][v] + D[v][j]

    # Extract boundary submatrix
    b = len(boundary_vertices)
    result = np.zeros((b, b))
    for ii, i in enumerate(boundary_vertices):
        for jj, j in enumerate(boundary_vertices):
            result[ii][jj] = D[i][j]

    return result


# ============================================================
# Algorithm 4: Floyd-Warshall Tropical Closure
# ============================================================

def tropical_closure(weight_matrix: np.ndarray) -> np.ndarray:
    """
    Compute the all-pairs shortest path (tropical closure / Kleene star).

    This is the min-plus analogue of matrix inversion / Kleene star.
    Uses Floyd-Warshall algorithm.

    Time complexity: O(n³)
    Space complexity: O(n²)

    Args:
        weight_matrix: n×n weight matrix (np.inf for absent edges)

    Returns:
        n×n shortest path distance matrix
    """
    n = weight_matrix.shape[0]
    D = weight_matrix.copy()

    for k in range(n):
        for i in range(n):
            for j in range(n):
                if D[i][k] + D[k][j] < D[i][j]:
                    D[i][j] = D[i][k] + D[k][j]

    return D


# ============================================================
# Algorithm 5: Boundary Distance Matrix
# ============================================================

def boundary_distance_matrix(node: SPNode) -> np.ndarray:
    """
    Compute the 2×2 boundary distance matrix of a two-terminal SP network.

    Returns [[0, d], [d, 0]] where d = effective_distance(node).

    Time complexity: O(n)
    Space complexity: O(1) (plus recursion for effective_distance)
    """
    d = effective_distance(node)
    return np.array([[0.0, d], [d, 0.0]])


# ============================================================
# Algorithm 6: SP Expression Size and Depth
# ============================================================

def sp_size(node: SPNode) -> int:
    """Number of atom nodes in the SP expression."""
    if node.kind == 'atom':
        return 1
    return sum(sp_size(c) for c in node.children)


def sp_depth(node: SPNode) -> int:
    """Depth of the SP expression tree."""
    if node.kind == 'atom':
        return 0
    return 1 + max(sp_depth(c) for c in node.children)


# ============================================================
# Algorithm 7: SP Network from Weight List
# ============================================================

def sp_from_weights(
    weights: List[float],
    structure: str = 'series'
) -> SPNode:
    """
    Build an SP expression from a list of weights.

    Args:
        weights: list of positive edge weights
        structure: 'series' (chain), 'parallel' (fork), or 'balanced' (tree)

    Returns:
        SPNode representing the constructed network
    """
    if len(weights) == 0:
        raise ValueError("Need at least one weight")
    if len(weights) == 1:
        return atom(weights[0])

    if structure == 'series':
        result = atom(weights[0])
        for w in weights[1:]:
            result = series(result, atom(w))
        return result
    elif structure == 'parallel':
        result = atom(weights[0])
        for w in weights[1:]:
            result = parallel(result, atom(w))
        return result
    elif structure == 'balanced':
        mid = len(weights) // 2
        left = sp_from_weights(weights[:mid], 'balanced')
        right = sp_from_weights(weights[mid:], 'balanced')
        return series(left, right)
    else:
        raise ValueError(f"Unknown structure: {structure}")


# ============================================================
# Demonstrations
# ============================================================

def demo_all_algorithms():
    """Run demonstrations of all algorithms."""

    print("=" * 60)
    print("ALGORITHM DEMONSTRATIONS")
    print("=" * 60)

    # Algorithm 1: Effective distance
    print("\n--- Algorithm 1: Effective Distance ---")
    e = series(
        parallel(atom(2), atom(5)),
        parallel(atom(3), atom(1))
    )
    print(f"Expression: {e}")
    print(f"Effective distance: {effective_distance(e)}")
    print(f"Size: {sp_size(e)}, Depth: {sp_depth(e)}")

    # Algorithm 2: Canonical reduction
    print("\n--- Algorithm 2: Canonical Reduction ---")
    reduced = canonical_reduce(e)
    print(f"Original: {e} → eff_dist = {effective_distance(e)}")
    print(f"Reduced:  {reduced} → eff_dist = {effective_distance(reduced)}")

    # Algorithm 3: Vertex elimination
    print("\n--- Algorithm 3: Tropical Vertex Elimination ---")
    # Path graph: 0 --3-- 1 --5-- 2
    D = np.array([
        [0, 3, np.inf],
        [3, 0, 5],
        [np.inf, 5, 0]
    ])
    print(f"Original distance matrix:\n{D}")
    D_boundary = tropical_vertex_elimination(D, [1], [0, 2])
    print(f"After eliminating vertex 1:\n{D_boundary}")

    # Algorithm 4: Tropical closure
    print("\n--- Algorithm 4: Tropical Closure (Floyd-Warshall) ---")
    W = np.array([
        [0, 3, np.inf],
        [3, 0, 5],
        [np.inf, 5, 0]
    ])
    closure = tropical_closure(W)
    print(f"Weight matrix:\n{W}")
    print(f"Tropical closure:\n{closure}")

    # Algorithm 5: Boundary matrix
    print("\n--- Algorithm 5: Boundary Distance Matrix ---")
    e1 = series(atom(3), atom(5))
    M = boundary_distance_matrix(e1)
    print(f"Expression: {e1}")
    print(f"Boundary matrix:\n{M}")

    # Algorithm 7: Network construction
    print("\n--- Algorithm 7: SP Network from Weights ---")
    weights = [1, 2, 3, 4]
    for struct in ['series', 'parallel', 'balanced']:
        net = sp_from_weights(weights, struct)
        print(f"  {struct:10s}: {net} → eff_dist = {effective_distance(net)}")

    print("\n✓ All algorithm demonstrations complete")


if __name__ == "__main__":
    demo_all_algorithms()
