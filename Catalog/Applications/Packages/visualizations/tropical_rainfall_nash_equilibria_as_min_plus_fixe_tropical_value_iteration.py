#!/usr/bin/env python3
"""
Tropical Game Theory: Core Algorithms

Implements the key algorithms from the tropical game equilibrium theory:
1. Tropical Bellman operator and value iteration
2. Min-plus matrix operations (multiplication, closure, idempotence check)
3. Saddle-point detection
4. Game value computation (max-min, min-max)
5. Tropical policy extraction
"""

from typing import Optional, Tuple, List
import numpy as np


# ═══════════════════════════════════════════════
# 1. Min-Plus Matrix Algebra
# ═══════════════════════════════════════════════

def minplus_multiply(A: np.ndarray, B: np.ndarray) -> np.ndarray:
    """
    Min-plus matrix multiplication: (A ⊗ B)[i,k] = min_j (A[i,j] + B[j,k]).

    Parameters:
        A: n×m matrix
        B: m×p matrix

    Returns:
        n×p matrix C where C[i,k] = min_j (A[i,j] + B[j,k])

    Complexity: O(n·m·p)

    Example:
        >>> A = np.array([[0, 3], [2, 0]])
        >>> minplus_multiply(A, A)
        array([[0., 3.],
               [2., 0.]])
    """
    n, m = A.shape
    _, p = B.shape
    C = np.full((n, p), np.inf)
    for i in range(n):
        for k in range(p):
            C[i, k] = np.min(A[i, :] + B[:, k])
    return C


def minplus_closure(B: np.ndarray) -> np.ndarray:
    """
    Min-plus Kleene star (shortest-path closure) via Floyd-Warshall.

    Computes A = B* = I ⊕ B ⊕ B² ⊕ ... where I is the min-plus identity
    (0 on diagonal, +∞ off-diagonal) and ⊕ is componentwise min.

    The result is the unique min-plus idempotent matrix A with A ≤ B
    (componentwise) and A[i,i] = 0 for all i (assuming no negative cycles).

    Parameters:
        B: n×n matrix (non-negative entries for well-definedness)

    Returns:
        n×n min-plus idempotent shortest-path matrix

    Complexity: O(n³)
    """
    n = B.shape[0]
    A = B.copy().astype(float)
    # Set diagonal to 0 (min-plus identity)
    np.fill_diagonal(A, 0)
    for k in range(n):
        for i in range(n):
            for j in range(n):
                if A[i, k] + A[k, j] < A[i, j]:
                    A[i, j] = A[i, k] + A[k, j]
    return A


def is_minplus_idempotent(A: np.ndarray, tol: float = 1e-10) -> bool:
    """
    Check if A is min-plus idempotent: A ⊗ A = A.

    Parameters:
        A: n×n matrix
        tol: numerical tolerance

    Returns:
        True if A ⊗ A ≈ A within tolerance
    """
    return np.allclose(minplus_multiply(A, A), A, atol=tol)


# ═══════════════════════════════════════════════
# 2. Tropical Bellman Operator
# ═══════════════════════════════════════════════

def tropical_bellman(A: np.ndarray, x: np.ndarray) -> np.ndarray:
    """
    Tropical Bellman (Shapley) operator: T_A(x)_i = min_j (A[i,j] + x[j]).

    This is the min-plus matrix-vector product.

    Parameters:
        A: n×n payoff matrix
        x: n-dimensional value vector

    Returns:
        n-dimensional vector T_A(x)

    Complexity: O(n²)
    """
    n = A.shape[0]
    return np.array([np.min(A[i, :] + x) for i in range(n)])


def tropical_value_iteration(
    A: np.ndarray,
    x0: np.ndarray,
    max_iter: int = 1000,
    tol: float = 1e-12
) -> Tuple[np.ndarray, int, List[np.ndarray]]:
    """
    Tropical value iteration: repeatedly apply T_A until convergence.

    Parameters:
        A: n×n payoff matrix
        x0: initial value vector
        max_iter: maximum number of iterations
        tol: convergence tolerance (L∞ norm)

    Returns:
        (v, iterations, history) where v is the (approximate) fixed point,
        iterations is the number of steps taken, and history is the
        list of all iterates.

    Complexity: O(n² · iterations)
    """
    v = x0.copy()
    history = [v.copy()]

    for it in range(1, max_iter + 1):
        v_new = tropical_bellman(A, v)
        history.append(v_new.copy())
        if np.max(np.abs(v_new - v)) < tol:
            return v_new, it, history
        v = v_new

    return v, max_iter, history


def is_tropical_fixed_point(A: np.ndarray, v: np.ndarray, tol: float = 1e-10) -> bool:
    """
    Check if v is a fixed point of the tropical Bellman operator T_A.

    Parameters:
        A: n×n payoff matrix
        v: n-dimensional candidate fixed point

    Returns:
        True if T_A(v) ≈ v within tolerance
    """
    return np.allclose(tropical_bellman(A, v), v, atol=tol)


# ═══════════════════════════════════════════════
# 3. Tropical Game Values
# ═══════════════════════════════════════════════

def tropical_lower_value(A: np.ndarray) -> float:
    """
    Lower (max-min) value: v̲(A) = max_i min_j A[i,j].

    This is the row player's guaranteed minimum payoff.

    Parameters:
        A: n×n payoff matrix

    Returns:
        The lower value

    Complexity: O(n²)
    """
    return float(np.max(np.min(A, axis=1)))


def tropical_upper_value(A: np.ndarray) -> float:
    """
    Upper (min-max) value: v̄(A) = min_j max_i A[i,j].

    This is the column player's guaranteed maximum loss.

    Parameters:
        A: n×n payoff matrix

    Returns:
        The upper value

    Complexity: O(n²)
    """
    return float(np.min(np.max(A, axis=0)))


def tropical_minimax_gap(A: np.ndarray) -> float:
    """
    Minimax gap: v̄(A) - v̲(A) ≥ 0.

    Always non-negative by the tropical minimax inequality.

    Parameters:
        A: n×n payoff matrix

    Returns:
        The non-negative gap
    """
    return tropical_upper_value(A) - tropical_lower_value(A)


# ═══════════════════════════════════════════════
# 4. Saddle-Point Detection
# ═══════════════════════════════════════════════

def find_saddle_point(A: np.ndarray) -> Optional[Tuple[int, int]]:
    """
    Find a saddle point (i₀, j₀) where A[i₀,j₀] is the minimum in its row
    and the maximum in its column.

    A saddle point satisfies:
        ∀j: A[i₀,j₀] ≤ A[i₀,j]    (row min)
        ∀i: A[i,j₀] ≤ A[i₀,j₀]    (column max)

    Parameters:
        A: n×n payoff matrix

    Returns:
        (i₀, j₀) if a saddle point exists, None otherwise

    Complexity: O(n²)
    """
    n = A.shape[0]
    row_mins = np.min(A, axis=1)
    col_maxs = np.max(A, axis=0)

    for i in range(n):
        for j in range(n):
            if A[i, j] == row_mins[i] and A[i, j] == col_maxs[j]:
                return (i, j)
    return None


def find_all_saddle_points(A: np.ndarray) -> List[Tuple[int, int]]:
    """
    Find all saddle points of a matrix.

    Parameters:
        A: n×n payoff matrix

    Returns:
        List of (i, j) pairs that are saddle points
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


# ═══════════════════════════════════════════════
# 5. Tropical Policy Extraction
# ═══════════════════════════════════════════════

def extract_greedy_policy(A: np.ndarray, v: np.ndarray) -> np.ndarray:
    """
    Extract the greedy (optimal) policy from a value vector.

    σ(i) = argmin_j (A[i,j] + v[j])

    Parameters:
        A: n×n payoff matrix
        v: n-dimensional value vector

    Returns:
        n-dimensional integer array of optimal actions

    Complexity: O(n²)
    """
    n = A.shape[0]
    return np.array([np.argmin(A[i, :] + v) for i in range(n)])


# ═══════════════════════════════════════════════
# Example Usage
# ═══════════════════════════════════════════════

if __name__ == "__main__":
    print("Tropical Game Theory: Algorithm Demonstrations")
    print("=" * 50)

    # Example 1: Min-plus idempotent matrix and one-step convergence
    B = np.array([
        [0, 3, 7],
        [2, 0, 4],
        [5, 1, 0]
    ], dtype=float)

    A = minplus_closure(B)
    print(f"\nOriginal matrix B:\n{B}")
    print(f"\nShortest-path closure A = B*:\n{A}")
    print(f"Min-plus idempotent: {is_minplus_idempotent(A)}")

    x0 = np.array([100.0, 200.0, 300.0])
    v, iters, history = tropical_value_iteration(A, x0)
    print(f"\nValue iteration from x₀ = {x0}:")
    print(f"  Converged in {iters} iteration(s)")
    print(f"  Fixed point: {v}")
    print(f"  Greedy policy: {extract_greedy_policy(A, v)}")

    # Example 2: Minimax computation
    M = np.array([
        [3, 5, 7],
        [1, 4, 6],
        [2, 3, 8]
    ], dtype=float)

    print(f"\nPayoff matrix M:\n{M}")
    print(f"Lower value (max-min): {tropical_lower_value(M)}")
    print(f"Upper value (min-max): {tropical_upper_value(M)}")
    print(f"Minimax gap: {tropical_minimax_gap(M)}")
    saddle = find_saddle_point(M)
    print(f"Saddle point: {saddle}")
    if saddle:
        i0, j0 = saddle
        print(f"Game value = M[{i0},{j0}] = {M[i0, j0]}")
