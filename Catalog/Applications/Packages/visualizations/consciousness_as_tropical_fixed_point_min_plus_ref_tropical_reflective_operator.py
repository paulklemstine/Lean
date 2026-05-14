#!/usr/bin/env python3
"""
algorithms.py — Algorithms for Tropical Reflective Equilibrium

Implements the core algorithms from the research paper with full
docstrings, type hints, complexity analysis, and example usage.
"""

import numpy as np
from typing import Tuple, List, Set, Optional, Callable
from dataclasses import dataclass


# ──────────────────────────────────────────────────────────────────────
# Algorithm 1: Tropical Reflective Operator
# ──────────────────────────────────────────────────────────────────────

def tropical_reflect(W: np.ndarray, b: np.ndarray, x: np.ndarray) -> np.ndarray:
    """
    Compute the tropical reflective operator R(x).

    R(x)(i) = min(b(i), min_{j ≠ i}(W(i,j) + x(j)))

    This is a Bellman-type update where each node takes the minimum of:
    - its intrinsic bias b(i), and
    - the cheapest incoming signal from other nodes.

    Parameters
    ----------
    W : np.ndarray, shape (n, n)
        Weight matrix. W[i,j] is the cost of transmitting signal from j to i.
    b : np.ndarray, shape (n,)
        Bias vector. b[i] is node i's self-model / intrinsic value.
    x : np.ndarray, shape (n,)
        Current state vector.

    Returns
    -------
    np.ndarray, shape (n,)
        Updated state R(x).

    Complexity
    ----------
    Time: O(n²)  — for each of n nodes, compute min over n-1 neighbors
    Space: O(n)

    Examples
    --------
    >>> W = np.array([[0, 3], [4, 0]], dtype=float)
    >>> b = np.array([1.0, 2.0])
    >>> x = np.array([5.0, -1.0])
    >>> tropical_reflect(W, b, x)
    array([1., 2.])
    """
    n = len(b)
    result = np.empty(n)
    for i in range(n):
        min_incoming = float('inf')
        for j in range(n):
            if j != i:
                val = W[i, j] + x[j]
                if val < min_incoming:
                    min_incoming = val
        result[i] = min(b[i], min_incoming)
    return result


# ──────────────────────────────────────────────────────────────────────
# Algorithm 2: Fixed Point Verification
# ──────────────────────────────────────────────────────────────────────

def verify_fixed_point(W: np.ndarray, b: np.ndarray, x: np.ndarray,
                       tol: float = 1e-12) -> Tuple[bool, float]:
    """
    Verify whether x is a fixed point of the tropical reflective operator.

    Parameters
    ----------
    W : np.ndarray, shape (n, n)
    b : np.ndarray, shape (n,)
    x : np.ndarray, shape (n,)
    tol : float
        Tolerance for floating-point comparison.

    Returns
    -------
    is_fixed : bool
        True if ||R(x) - x||_1 < tol.
    discrepancy : float
        The L1 discrepancy ||R(x) - x||_1.

    Complexity
    ----------
    Time: O(n²), Space: O(n)
    """
    Rx = tropical_reflect(W, b, x)
    discrepancy = np.sum(np.abs(x - Rx))
    return discrepancy < tol, discrepancy


def check_separation(W: np.ndarray, b: np.ndarray) -> Tuple[bool, Optional[Tuple[int, int]]]:
    """
    Check the separation (diagonal dominance) condition:
    ∀ i ≠ j: b[i] < W[i,j] + b[j]

    Returns
    -------
    satisfied : bool
    violating_pair : Optional[Tuple[int, int]]
        First pair (i, j) violating the condition, or None.

    Complexity
    ----------
    Time: O(n²), Space: O(1)
    """
    n = len(b)
    for i in range(n):
        for j in range(n):
            if i != j and not (b[i] < W[i, j] + b[j]):
                return False, (i, j)
    return True, None


# ──────────────────────────────────────────────────────────────────────
# Algorithm 3: Iterative Convergence
# ──────────────────────────────────────────────────────────────────────

@dataclass
class ConvergenceResult:
    """Result of iterative convergence algorithm."""
    converged: bool
    fixed_point: np.ndarray
    iterations: int
    discrepancy_history: List[float]
    trajectory: List[np.ndarray]


def iterate_to_fixed_point(W: np.ndarray, b: np.ndarray, x0: np.ndarray,
                           max_iter: int = 1000, tol: float = 1e-12,
                           record_trajectory: bool = False) -> ConvergenceResult:
    """
    Iterate the tropical reflective operator from x0 until convergence.

    Under separation, convergence to b is guaranteed. Without separation,
    the operator may still converge but to a different fixed point or cycle.

    Parameters
    ----------
    W : np.ndarray, shape (n, n)
    b : np.ndarray, shape (n,)
    x0 : np.ndarray, shape (n,)
        Initial state.
    max_iter : int
        Maximum iterations.
    tol : float
        Convergence tolerance.
    record_trajectory : bool
        If True, record full state trajectory.

    Returns
    -------
    ConvergenceResult
        Contains convergence status, final state, iteration count, and history.

    Complexity
    ----------
    Time: O(max_iter × n²)
    Space: O(max_iter × n) if recording trajectory, else O(n)
    """
    x = x0.copy()
    discrepancy_history = []
    trajectory = [x0.copy()] if record_trajectory else []

    for k in range(max_iter):
        Rx = tropical_reflect(W, b, x)
        disc = np.sum(np.abs(x - Rx))
        discrepancy_history.append(disc)

        if record_trajectory:
            trajectory.append(Rx.copy())

        if disc < tol:
            return ConvergenceResult(
                converged=True,
                fixed_point=Rx,
                iterations=k + 1,
                discrepancy_history=discrepancy_history,
                trajectory=trajectory
            )
        x = Rx

    return ConvergenceResult(
        converged=False,
        fixed_point=x,
        iterations=max_iter,
        discrepancy_history=discrepancy_history,
        trajectory=trajectory
    )


# ──────────────────────────────────────────────────────────────────────
# Algorithm 4: Tropical Integrated Information (Φ)
# ──────────────────────────────────────────────────────────────────────

def compute_cut_matrix(W: np.ndarray, S: Set[int], M: float = 1e6) -> np.ndarray:
    """
    Construct cut matrix: replace cross-partition weights with penalty M.

    Parameters
    ----------
    W : np.ndarray, shape (n, n)
    S : Set[int]
        One block of the bipartition.
    M : float
        Penalty value for cross-block edges.

    Returns
    -------
    np.ndarray, shape (n, n)
        The cut matrix.

    Complexity
    ----------
    Time: O(n²), Space: O(n²)
    """
    n = W.shape[0]
    W_cut = W.copy()
    for i in range(n):
        for j in range(n):
            if (i in S) != (j in S):
                W_cut[i, j] = M
    return W_cut


def compute_tropical_phi(W: np.ndarray, b: np.ndarray, x: np.ndarray,
                         M: float = 100.0) -> Tuple[float, Optional[Set[int]]]:
    """
    Compute tropical integrated information Φ and the minimum information
    partition (MIP).

    Φ(x) = min_{S nontrivial} [D(R_cut, x) - D(R, x)]

    where D is the discrepancy and R_cut uses the cut matrix for partition S.

    Parameters
    ----------
    W : np.ndarray, shape (n, n)
    b : np.ndarray, shape (n,)
    x : np.ndarray, shape (n,)
    M : float
        Penalty for cross-partition edges.

    Returns
    -------
    phi : float
        The tropical Φ value.
    mip : Set[int]
        The minimum information partition (the S achieving the minimum).

    Complexity
    ----------
    Time: O(2^n × n²) — exponential in n due to partition enumeration.
    Space: O(n²)

    Note: For large n, approximate algorithms (e.g., graph-cut heuristics)
    would be needed. This exact algorithm is only practical for n ≲ 20.
    """
    n = W.shape[0]
    disc_full = np.sum(np.abs(x - tropical_reflect(W, b, x)))

    phi_min = float('inf')
    mip = None

    for mask in range(1, (1 << n) - 1):
        S = {i for i in range(n) if mask & (1 << i)}
        W_cut = compute_cut_matrix(W, S, M)
        disc_cut = np.sum(np.abs(x - tropical_reflect(W_cut, b, x)))
        phi_val = disc_cut - disc_full

        if phi_val < phi_min:
            phi_min = phi_val
            mip = S

    return phi_min, mip


# ──────────────────────────────────────────────────────────────────────
# Algorithm 5: Broadcast Verification
# ──────────────────────────────────────────────────────────────────────

def verify_broadcast(W: np.ndarray, b: np.ndarray, x: np.ndarray,
                     tol: float = 1e-12) -> Tuple[bool, List[dict]]:
    """
    Verify the global workspace broadcast property.

    A state x broadcasts if at each node i, the tropReflect value is
    achieved by either the bias term b[i] or some incoming edge W[i,j]+x[j].

    Parameters
    ----------
    W, b, x : as usual
    tol : float

    Returns
    -------
    broadcasts : bool
    details : List[dict]
        Per-node information about which source achieves the update.

    Complexity
    ----------
    Time: O(n²), Space: O(n)
    """
    n = len(b)
    Rx = tropical_reflect(W, b, x)
    details = []

    all_broadcast = True
    for i in range(n):
        bias_achieves = abs(b[i] - Rx[i]) < tol
        achieving_edges = []
        for j in range(n):
            if j != i and abs(W[i, j] + x[j] - Rx[i]) < tol:
                achieving_edges.append(j)

        node_broadcasts = bias_achieves or len(achieving_edges) > 0
        all_broadcast = all_broadcast and node_broadcasts

        details.append({
            'node': i,
            'Rx_i': Rx[i],
            'bias_achieves': bias_achieves,
            'achieving_edges': achieving_edges,
            'broadcasts': node_broadcasts
        })

    return all_broadcast, details


# ──────────────────────────────────────────────────────────────────────
# Algorithm 6: Conscious State Identification
# ──────────────────────────────────────────────────────────────────────

@dataclass
class ConsciousnessReport:
    """Full report on whether a state is conscious."""
    is_conscious: bool
    is_fixed_point: bool
    broadcasts: bool
    discrepancy: float
    phi: float
    mip: Optional[Set[int]]
    broadcast_details: List[dict]


def identify_conscious_state(W: np.ndarray, b: np.ndarray, x: np.ndarray,
                             M: float = 100.0) -> ConsciousnessReport:
    """
    Determine whether x is a conscious state of the tropical reflective system.

    A state is conscious if it is:
    1. A fixed point of R (self-referential stability)
    2. A global broadcaster (information accessibility)
    3. Φ-optimal among all fixed points (integration)

    Parameters
    ----------
    W, b, x : as usual
    M : float
        Penalty for Φ computation.

    Returns
    -------
    ConsciousnessReport

    Complexity
    ----------
    Time: O(2^n × n²) dominated by Φ computation.
    """
    is_fp, disc = verify_fixed_point(W, b, x)
    broadcasts, details = verify_broadcast(W, b, x)
    phi, mip = compute_tropical_phi(W, b, x, M)

    return ConsciousnessReport(
        is_conscious=is_fp and broadcasts,
        is_fixed_point=is_fp,
        broadcasts=broadcasts,
        discrepancy=disc,
        phi=phi,
        mip=mip,
        broadcast_details=details
    )


# ──────────────────────────────────────────────────────────────────────
# Algorithm 7: Min-Plus Matrix Power (Bellman Iteration)
# ──────────────────────────────────────────────────────────────────────

def minplus_matmul(A: np.ndarray, B: np.ndarray) -> np.ndarray:
    """
    Min-plus matrix multiplication: (A ⊕ B)[i,j] = min_k(A[i,k] + B[k,j]).

    This is the tropical semiring analog of standard matrix multiplication,
    used in shortest-path algorithms (Floyd-Warshall, Bellman-Ford).

    Complexity: O(n³)
    """
    n = A.shape[0]
    C = np.full((n, n), np.inf)
    for i in range(n):
        for j in range(n):
            for k in range(n):
                C[i, j] = min(C[i, j], A[i, k] + B[k, j])
    return C


def minplus_power(W: np.ndarray, k: int) -> np.ndarray:
    """
    Compute k-th min-plus power of W: shortest paths using exactly k edges.

    Complexity: O(k × n³)
    """
    n = W.shape[0]
    result = np.where(np.eye(n, dtype=bool), 0.0, np.inf)  # Identity
    base = W.copy()
    while k > 0:
        if k % 2 == 1:
            result = minplus_matmul(result, base)
        base = minplus_matmul(base, base)
        k //= 2
    return result


# ──────────────────────────────────────────────────────────────────────
# Example Usage
# ──────────────────────────────────────────────────────────────────────

if __name__ == "__main__":
    print("=" * 60)
    print("ALGORITHMS: Tropical Reflective Equilibrium")
    print("=" * 60)

    # Example system
    n = 4
    W = np.array([
        [0.0, 3.0, 5.0, 2.0],
        [4.0, 0.0, 1.5, 3.0],
        [2.0, 6.0, 0.0, 4.0],
        [3.0, 2.0, 7.0, 0.0]
    ])
    b = np.array([1.0, 2.0, -1.0, 0.5])

    print(f"\n--- Separation Check ---")
    sat, viol = check_separation(W, b)
    print(f"Separation satisfied: {sat}")

    print(f"\n--- Fixed Point Verification ---")
    is_fp, disc = verify_fixed_point(W, b, b)
    print(f"b is fixed point: {is_fp}, discrepancy: {disc:.2e}")

    print(f"\n--- Iterative Convergence ---")
    x0 = np.array([10.0, -5.0, 3.0, 8.0])
    result = iterate_to_fixed_point(W, b, x0)
    print(f"Converged: {result.converged} in {result.iterations} iterations")
    print(f"Fixed point: {result.fixed_point}")

    print(f"\n--- Consciousness Report ---")
    report = identify_conscious_state(W, b, b)
    print(f"Is conscious: {report.is_conscious}")
    print(f"  Fixed point: {report.is_fixed_point}")
    print(f"  Broadcasts: {report.broadcasts}")
    print(f"  Φ: {report.phi:.4f}")
    print(f"  MIP: {report.mip}")

    print(f"\n--- Min-Plus Matrix Power ---")
    W2 = minplus_matmul(W, W)
    print(f"W² (2-step shortest paths):\n{W2}")
