#!/usr/bin/env python3
"""
Algorithms for Compositional Tropical Event-Graph Analysis

Implements the core algorithms from the research paper:
1. Max-plus matrix multiplication (O(n³))
2. Compositional transfer computation for event-graph networks
3. Throughput certification algorithm
4. Maximum cycle mean computation (Karp's algorithm)
5. Network DSL evaluator
"""

import numpy as np
from typing import List, Optional, Tuple, Union
from dataclasses import dataclass
from enum import Enum

NEG_INF = float('-inf')


# =============================================================================
# Core Max-Plus Algebra
# =============================================================================

class MaxPlusMatrix:
    """
    A matrix over the max-plus semiring (ℝ ∪ {-∞}, max, +).

    The tropical zero is -∞ (no path exists).
    The tropical one is 0 (zero-delay identity path).

    Time complexity of multiplication: O(n·m·p)
    Space complexity: O(n·p) for the result
    """

    def __init__(self, data: np.ndarray):
        """Initialize from a numpy array. Use -inf for absent edges."""
        self.data = np.array(data, dtype=float)
        self.shape = self.data.shape

    def __repr__(self) -> str:
        return f"MaxPlusMatrix({self.data})"

    def __matmul__(self, other: 'MaxPlusMatrix') -> 'MaxPlusMatrix':
        """Max-plus matrix multiplication: (A⊗B)_{ik} = max_j(A_{ij} + B_{jk})"""
        return MaxPlusMatrix(trop_matmul(self.data, other.data))

    def __or__(self, other: 'MaxPlusMatrix') -> 'MaxPlusMatrix':
        """Tropical addition (pointwise max): (A⊕B)_{ij} = max(A_{ij}, B_{ij})"""
        return MaxPlusMatrix(np.maximum(self.data, other.data))

    def max_entry(self) -> float:
        """Maximum entry (cycle-time bound for single-pass)."""
        return np.max(self.data[self.data > NEG_INF]) if np.any(self.data > NEG_INF) else NEG_INF

    @staticmethod
    def identity(n: int) -> 'MaxPlusMatrix':
        """Tropical identity: 0 on diagonal, -∞ off diagonal."""
        data = np.full((n, n), NEG_INF)
        np.fill_diagonal(data, 0.0)
        return MaxPlusMatrix(data)

    @staticmethod
    def zero(m: int, n: int) -> 'MaxPlusMatrix':
        """Tropical zero matrix: all entries -∞."""
        return MaxPlusMatrix(np.full((m, n), NEG_INF))


def trop_matmul(A: np.ndarray, B: np.ndarray) -> np.ndarray:
    """
    Max-plus matrix multiplication.

    (A ⊗ B)_{i,k} = max_j (A_{i,j} + B_{j,k})

    Args:
        A: m×n matrix
        B: n×p matrix

    Returns:
        m×p matrix

    Time: O(m·n·p)
    Space: O(m·p)
    """
    m, n = A.shape
    _, p = B.shape
    C = np.full((m, p), NEG_INF)
    for i in range(m):
        for k in range(p):
            for j in range(n):
                val = A[i, j] + B[j, k]
                if val > C[i, k]:
                    C[i, k] = val
    return C


def trop_matpow(A: np.ndarray, k: int) -> np.ndarray:
    """
    Max-plus matrix power A^⊗k.

    A^⊗k_{i,j} = max weight of a length-k walk from i to j.

    Time: O(k·n³)  (can be improved to O(n³ log k) with repeated squaring)
    """
    n = A.shape[0]
    if k == 0:
        result = np.full((n, n), NEG_INF)
        np.fill_diagonal(result, 0.0)
        return result
    result = A.copy()
    for _ in range(k - 1):
        result = trop_matmul(result, A)
    return result


def trop_kleene_star(A: np.ndarray, max_iter: int = 100) -> np.ndarray:
    """
    Tropical Kleene star: A* = I ⊕ A ⊕ A² ⊕ ...

    Computes the maximum weight path of any length between each pair of nodes.
    Converges in at most n iterations for an n×n matrix (if no positive-weight
    cycles exist).

    Time: O(n⁴) worst case
    """
    n = A.shape[0]
    result = np.full((n, n), NEG_INF)
    np.fill_diagonal(result, 0.0)
    power = np.full((n, n), NEG_INF)
    np.fill_diagonal(power, 0.0)

    for _ in range(min(max_iter, n)):
        power = trop_matmul(power, A)
        result = np.maximum(result, power)

    return result


# =============================================================================
# Maximum Cycle Mean (Karp's Algorithm)
# =============================================================================

def max_cycle_mean(A: np.ndarray) -> float:
    """
    Compute the maximum cycle mean of a square matrix A using Karp's algorithm.

    The maximum cycle mean λ* is the maximum average weight over all cycles:
        λ* = max_{cycle C} (weight(C) / length(C))

    This is the asymptotic throughput of the max-plus linear system x(k+1) = A⊗x(k).

    Time: O(n³)
    Space: O(n²)

    Returns:
        Maximum cycle mean, or -inf if no cycles exist.
    """
    n = A.shape[0]
    if n == 0:
        return NEG_INF

    # Compute A^k for k = 0, 1, ..., n
    powers = [None] * (n + 1)
    powers[0] = np.full((n, n), NEG_INF)
    np.fill_diagonal(powers[0], 0.0)

    for k in range(1, n + 1):
        powers[k] = trop_matmul(powers[k-1], A)

    # Karp's formula: λ* = max_j min_{0≤k<n} (A^n_{j,j} - A^k_{j,j}) / (n - k)
    mcm = NEG_INF
    for j in range(n):
        if powers[n][j, j] == NEG_INF:
            continue
        for k in range(n):
            if powers[k][j, j] == NEG_INF:
                continue
            val = (powers[n][j, j] - powers[k][j, j]) / (n - k)
            mcm = max(mcm, val)

    return mcm


# =============================================================================
# Event Graph Network DSL
# =============================================================================

class NetworkType(Enum):
    ATOM = "atom"
    SERIES = "series"
    PARALLEL_SHARED = "parallel_shared"
    PARALLEL_DISJOINT = "parallel_disjoint"


@dataclass
class Network:
    """
    Compositional network syntax.

    Represents a network as a tree of atomic components connected by
    series and parallel composition.
    """
    kind: NetworkType
    matrix: Optional[np.ndarray] = None  # For atoms
    left: Optional['Network'] = None  # For compositions
    right: Optional['Network'] = None

    @staticmethod
    def atom(transfer: np.ndarray) -> 'Network':
        """Create an atomic network with a given transfer matrix."""
        return Network(kind=NetworkType.ATOM, matrix=transfer)

    @staticmethod
    def series(n1: 'Network', n2: 'Network') -> 'Network':
        """Series composition."""
        return Network(kind=NetworkType.SERIES, left=n1, right=n2)

    @staticmethod
    def par_shared(n1: 'Network', n2: 'Network') -> 'Network':
        """Shared-interface parallel composition."""
        return Network(kind=NetworkType.PARALLEL_SHARED, left=n1, right=n2)

    @staticmethod
    def par_disjoint(n1: 'Network', n2: 'Network') -> 'Network':
        """Disjoint-interface parallel composition."""
        return Network(kind=NetworkType.PARALLEL_DISJOINT, left=n1, right=n2)


def evaluate_network(net: Network) -> np.ndarray:
    """
    Evaluate a network to its transfer matrix.

    This is the denotational semantics: each network compositionally
    denotes a max-plus matrix.

    Time: O(n³) per series node, O(n²) per parallel node
    """
    if net.kind == NetworkType.ATOM:
        return net.matrix.copy()
    elif net.kind == NetworkType.SERIES:
        left = evaluate_network(net.left)
        right = evaluate_network(net.right)
        return trop_matmul(left, right)
    elif net.kind == NetworkType.PARALLEL_SHARED:
        left = evaluate_network(net.left)
        right = evaluate_network(net.right)
        return np.maximum(left, right)
    elif net.kind == NetworkType.PARALLEL_DISJOINT:
        left = evaluate_network(net.left)
        right = evaluate_network(net.right)
        m1, n1 = left.shape
        m2, n2 = right.shape
        result = np.zeros((m1 + m2, n1 + n2))
        result[:m1, :n1] = left
        result[m1:, n1:] = right
        return result
    else:
        raise ValueError(f"Unknown network type: {net.kind}")


def certify_throughput(net: Network) -> float:
    """
    Compositionally certify a throughput bound for a network.

    Returns a certified upper bound on the cycle time (maximum entry
    of the transfer matrix) computed compositionally without evaluating
    the full transfer matrix.

    This demonstrates the key theorem: bounds compose algebraically.

    Time: O(n) in the number of network nodes (ignores matrix sizes)
    """
    if net.kind == NetworkType.ATOM:
        return float(np.max(net.matrix))
    elif net.kind == NetworkType.SERIES:
        c1 = certify_throughput(net.left)
        c2 = certify_throughput(net.right)
        return c1 + c2  # Series: bounds add
    elif net.kind == NetworkType.PARALLEL_SHARED:
        c1 = certify_throughput(net.left)
        c2 = certify_throughput(net.right)
        return max(c1, c2)  # Parallel: bounds take max
    elif net.kind == NetworkType.PARALLEL_DISJOINT:
        c1 = certify_throughput(net.left)
        c2 = certify_throughput(net.right)
        return max(c1, c2)  # Disjoint parallel: bounds take max
    else:
        raise ValueError(f"Unknown network type: {net.kind}")


def verify_certification(net: Network) -> Tuple[float, float, bool]:
    """
    Verify that the compositional bound is sound.

    Returns (actual_max, certified_bound, is_sound).
    """
    actual = float(np.max(evaluate_network(net)))
    certified = certify_throughput(net)
    return actual, certified, actual <= certified


# =============================================================================
# Example Usage
# =============================================================================

if __name__ == "__main__":
    print("=" * 60)
    print("Max-Plus Matrix Algebra")
    print("=" * 60)

    A = MaxPlusMatrix(np.array([[1, 3], [2, 4]]))
    B = MaxPlusMatrix(np.array([[5, 6], [7, 8]]))
    C = A @ B
    print(f"A = {A.data}")
    print(f"B = {B.data}")
    print(f"A ⊗ B = {C.data}")
    print(f"Max entry (cycle-time bound): {C.max_entry()}")

    print("\n" + "=" * 60)
    print("Karp's Maximum Cycle Mean")
    print("=" * 60)

    W = np.array([[NEG_INF, 3, NEG_INF],
                   [NEG_INF, NEG_INF, 2],
                   [4, NEG_INF, NEG_INF]])
    mcm = max_cycle_mean(W)
    print(f"Weight matrix:\n{W}")
    print(f"Maximum cycle mean: {mcm}")
    print(f"Expected: {(3+2+4)/3:.4f} (single cycle 3→2→4)")

    print("\n" + "=" * 60)
    print("Network DSL Evaluation")
    print("=" * 60)

    # Build: (A series B) parallel_shared (C series D)
    A_mat = np.array([[2, 1], [3, 2]])
    B_mat = np.array([[4, 3], [1, 5]])
    C_mat = np.array([[1, 6], [2, 3]])
    D_mat = np.array([[5, 1], [3, 4]])

    net = Network.par_shared(
        Network.series(Network.atom(A_mat), Network.atom(B_mat)),
        Network.series(Network.atom(C_mat), Network.atom(D_mat))
    )

    result = evaluate_network(net)
    actual, certified, sound = verify_certification(net)
    print(f"Network: (A→B) ∥ (C→D)")
    print(f"Transfer matrix:\n{result}")
    print(f"Actual max delay: {actual}")
    print(f"Certified bound: {certified}")
    print(f"✓ Sound: {sound}")

    print("\n" + "=" * 60)
    print("Tropical Kleene Star (All-Pairs Longest Paths)")
    print("=" * 60)

    G = np.array([[NEG_INF, 2, NEG_INF],
                   [NEG_INF, NEG_INF, 3],
                   [NEG_INF, NEG_INF, NEG_INF]])
    star = trop_kleene_star(G)
    print(f"Graph adjacency:\n{G}")
    print(f"Kleene star (max-weight reachability):\n{star}")

    print("\nAll algorithms completed successfully!")
