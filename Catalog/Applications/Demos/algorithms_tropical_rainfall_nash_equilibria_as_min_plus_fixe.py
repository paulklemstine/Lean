#!/usr/bin/env python3
"""
Tropical Game Theory — Algorithms

Implements the core algorithms for tropical game analysis:
1. Min-plus matrix operations (multiplication, closure/Kleene star)
2. Tropical Bellman value iteration
3. Saddle-point detection
4. Tropical game solver
"""

import numpy as np
from typing import Tuple, Optional, List


# ═══════════════════════════════════════════════════════════════════════
# Algorithm 1: Min-Plus Matrix Algebra
# ═══════════════════════════════════════════════════════════════════════

def min_plus_multiply(A: np.ndarray, B: np.ndarray) -> np.ndarray:
    """
    Min-plus matrix multiplication: (A ⊗ B)[i,k] = min_j (A[i,j] + B[j,k]).

    Time complexity: O(n³)
    Space complexity: O(n²)
    """
    n = A.shape[0]
    C = np.full((n, n), np.inf)
    for i in range(n):
        for k in range(n):
            C[i, k] = np.min(A[i, :] + B[:, k])
    return C


def min_plus_closure(A: np.ndarray, max_iter: int = 100) -> np.ndarray:
    """
    Compute the min-plus Kleene star (transitive closure):
    A* = I ⊕ A ⊕ A² ⊕ A³ ⊕ ...

    This gives the all-pairs shortest path matrix.

    Time complexity: O(n³ · min(n, max_iter))
    Space complexity: O(n²)

    Returns the closure matrix, which is min-plus idempotent.
    """
    n = A.shape[0]
    # Start with identity (0 on diagonal, +inf elsewhere)
    result = np.full((n, n), np.inf)
    np.fill_diagonal(result, 0.0)

    # Entrywise min with A
    result = np.minimum(result, A)

    # Floyd-Warshall style closure
    for k in range(n):
        for i in range(n):
            for j in range(n):
                result[i, j] = min(result[i, j], result[i, k] + result[k, j])

    return result


def is_min_plus_idempotent(A: np.ndarray, tol: float = 1e-10) -> bool:
    """Check if A ⊗ A = A in the min-plus semiring."""
    return np.allclose(min_plus_multiply(A, A), A, atol=tol)


# ═══════════════════════════════════════════════════════════════════════
# Algorithm 2: Tropical Bellman Value Iteration
# ═══════════════════════════════════════════════════════════════════════

def tropical_bellman(A: np.ndarray, x: np.ndarray) -> np.ndarray:
    """
    Apply the tropical Bellman operator:
    T_A(x)_i = min_j (A[i,j] + x[j])

    Time complexity: O(n²)
    Space complexity: O(n)
    """
    n = A.shape[0]
    return np.array([np.min(A[i, :] + x) for i in range(n)])


def tropical_value_iteration(
    A: np.ndarray,
    x0: Optional[np.ndarray] = None,
    max_iter: int = 1000,
    tol: float = 1e-12
) -> Tuple[np.ndarray, int, List[np.ndarray]]:
    """
    Tropical value iteration: repeatedly apply T_A until convergence.

    Given initial vector x0, compute x_{k+1} = T_A(x_k) until
    ||x_{k+1} - x_k||_∞ < tol.

    For min-plus idempotent A, converges in exactly 1 step (after first application).
    For general A, converges in at most n steps where n = matrix dimension.

    Args:
        A: n×n payoff matrix
        x0: initial vector (defaults to zeros)
        max_iter: maximum iterations
        tol: convergence tolerance

    Returns:
        (fixed_point, num_iterations, trajectory)

    Time complexity: O(n² · k) where k is number of iterations
    Space complexity: O(n · k) for trajectory storage
    """
    n = A.shape[0]
    if x0 is None:
        x0 = np.zeros(n)

    x = x0.copy()
    trajectory = [x.copy()]

    for k in range(max_iter):
        x_new = tropical_bellman(A, x)
        trajectory.append(x_new.copy())

        if np.max(np.abs(x_new - x)) < tol:
            return x_new, k + 1, trajectory

        x = x_new

    return x, max_iter, trajectory


# ═══════════════════════════════════════════════════════════════════════
# Algorithm 3: Saddle Point Detection
# ═══════════════════════════════════════════════════════════════════════

def find_saddle_points(A: np.ndarray) -> List[Tuple[int, int]]:
    """
    Find all saddle points of matrix A.

    A saddle point (i0, j0) satisfies:
    - A[i0, j0] ≤ A[i0, j] for all j  (row minimum)
    - A[i, j0] ≤ A[i0, j0] for all i  (column maximum)

    Time complexity: O(n²)
    Space complexity: O(n)
    """
    n = A.shape[0]
    row_mins = np.min(A, axis=1)
    col_maxs = np.max(A, axis=0)
    saddles = []

    for i in range(n):
        for j in range(n):
            if A[i, j] == row_mins[i] and A[i, j] == col_maxs[j]:
                saddles.append((i, j))

    return saddles


def tropical_minimax_gap(A: np.ndarray) -> float:
    """
    Compute the minimax gap: min_j max_i A[i,j] - max_i min_j A[i,j].

    By our theorem, this is always ≥ 0.
    Equals 0 iff a saddle point exists (sufficient condition).

    Time complexity: O(n²)
    """
    lower = np.max(np.min(A, axis=1))
    upper = np.min(np.max(A, axis=0))
    return upper - lower


# ═══════════════════════════════════════════════════════════════════════
# Algorithm 4: Tropical Game Solver
# ═══════════════════════════════════════════════════════════════════════

def solve_tropical_game(
    A: np.ndarray,
    compute_closure: bool = True
) -> dict:
    """
    Complete tropical game analysis for matrix A.

    Returns a dictionary with:
    - lower_value: max-min value
    - upper_value: min-max value
    - minimax_gap: upper - lower (≥ 0 by theorem)
    - saddle_points: list of (i, j) saddle point coordinates
    - is_idempotent: whether A is min-plus idempotent
    - fixed_point: a fixed point of T_A (computed via value iteration)
    - closure: min-plus closure A* (if compute_closure=True)
    - closure_fixed_point: fixed point using closure matrix

    Time complexity: O(n³) for closure, O(n²) for other operations
    """
    n = A.shape[0]

    result = {
        'matrix': A,
        'size': n,
        'lower_value': float(np.max(np.min(A, axis=1))),
        'upper_value': float(np.min(np.max(A, axis=0))),
        'minimax_gap': tropical_minimax_gap(A),
        'saddle_points': find_saddle_points(A),
        'is_idempotent': is_min_plus_idempotent(A),
    }

    # Compute fixed point via value iteration
    fp, iters, traj = tropical_value_iteration(A)
    result['fixed_point'] = fp
    result['iterations_to_converge'] = iters

    if compute_closure:
        closure = min_plus_closure(A)
        result['closure'] = closure
        result['closure_is_idempotent'] = is_min_plus_idempotent(closure)

        # Fixed point via closure (converges in 1 step)
        fp_closure, iters_c, _ = tropical_value_iteration(closure)
        result['closure_fixed_point'] = fp_closure
        result['closure_iterations'] = iters_c

    return result


# ═══════════════════════════════════════════════════════════════════════
# Algorithm 5: Tropical Policy Extraction
# ═══════════════════════════════════════════════════════════════════════

def extract_optimal_policy(A: np.ndarray, v: np.ndarray) -> np.ndarray:
    """
    Given a fixed point v of T_A, extract the optimal policy:
    π(i) = argmin_j (A[i,j] + v[j])

    This is the tropical analogue of extracting a best-response strategy
    from a game value vector.

    Time complexity: O(n²)
    Space complexity: O(n)
    """
    n = A.shape[0]
    policy = np.zeros(n, dtype=int)
    for i in range(n):
        policy[i] = np.argmin(A[i, :] + v)
    return policy


if __name__ == "__main__":
    print("Tropical Game Solver — Example")
    print("=" * 50)

    A = np.array([
        [3.0, 5.0, 7.0],
        [1.0, 4.0, 6.0],
        [2.0, 3.0, 8.0]
    ])

    result = solve_tropical_game(A)

    print(f"Matrix:\n{A}")
    print(f"\nLower value (max-min): {result['lower_value']}")
    print(f"Upper value (min-max): {result['upper_value']}")
    print(f"Minimax gap: {result['minimax_gap']}")
    print(f"Saddle points: {result['saddle_points']}")
    print(f"Min-plus idempotent: {result['is_idempotent']}")
    print(f"Fixed point: {result['fixed_point']}")
    print(f"Iterations to converge: {result['iterations_to_converge']}")
    print(f"Closure is idempotent: {result['closure_is_idempotent']}")

    # Extract policy
    fp = result['fixed_point']
    policy = extract_optimal_policy(A, fp)
    print(f"\nOptimal policy: {policy}")
    print(f"Policy meaning: player i should choose action {policy}")
