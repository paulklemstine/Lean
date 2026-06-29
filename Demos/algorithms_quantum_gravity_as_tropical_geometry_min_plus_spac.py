#!/usr/bin/env python3
"""
algorithms.py — Core algorithms for tropical spacetime dynamics.

Implements:
1. Tropical Einstein evolution (Bellman operator)
2. Tropical matrix multiplication and power
3. Tropical shortest-path distance computation
4. Radial horizon detection
5. Convergence analysis
"""

import numpy as np
from typing import Optional


def tropical_add(a: float, b: float) -> float:
    """Tropical addition: min(a, b)."""
    return min(a, b)


def tropical_mul(a: float, b: float) -> float:
    """Tropical multiplication: a + b."""
    return a + b


def tropical_einstein_step(K: np.ndarray, u: np.ndarray) -> np.ndarray:
    """One-step tropical Einstein evolution (Bellman update).

    Computes: u_new[x] = min_y (u[y] + K[y, x]) for all x.

    Args:
        K: Transition kernel, shape (n, n). K[y, x] = cost of y -> x.
        u: Current state, shape (n,).

    Returns:
        Evolved state, shape (n,).

    Time complexity: O(n^2)
    Space complexity: O(n)
    """
    n = len(u)
    # Broadcasting: u[:, None] + K gives (n, n) matrix of u[y] + K[y, x]
    return np.min(u[:, None] + K, axis=0)


def tropical_evolution(
    K: np.ndarray,
    u0: np.ndarray,
    T: int,
    return_trajectory: bool = False
) -> np.ndarray | list[np.ndarray]:
    """Multi-step tropical Einstein evolution.

    Args:
        K: Transition kernel, shape (n, n).
        u0: Initial state, shape (n,).
        T: Number of time steps.
        return_trajectory: If True, return list [u0, u1, ..., uT].

    Returns:
        Final state u_T (or full trajectory if return_trajectory=True).

    Time complexity: O(T * n^2)
    """
    trajectory = [u0.copy()] if return_trajectory else None
    u = u0.copy()
    for _ in range(T):
        u = tropical_einstein_step(K, u)
        if return_trajectory:
            trajectory.append(u.copy())
    return trajectory if return_trajectory else u


def tropical_mat_mul(A: np.ndarray, B: np.ndarray) -> np.ndarray:
    """Tropical matrix multiplication: C[i,k] = min_j (A[i,j] + B[j,k]).

    Args:
        A: Matrix, shape (m, p).
        B: Matrix, shape (p, n).

    Returns:
        Product matrix, shape (m, n).

    Time complexity: O(m * n * p)
    """
    m, p = A.shape
    _, n = B.shape
    # A[:, :, None] has shape (m, p, 1), B[None, :, :] has shape (1, p, n)
    return np.min(A[:, :, None] + B[None, :, :], axis=1)


def tropical_mat_pow(W: np.ndarray, n: int) -> np.ndarray:
    """Tropical matrix power: n-step shortest path matrix.

    Computes W^n in the tropical semiring using repeated multiplication.

    Args:
        W: Weight matrix, shape (k, k).
        n: Power.

    Returns:
        n-step shortest path matrix, shape (k, k).

    Time complexity: O(n * k^3). Use tropical_mat_pow_fast for O(k^3 log n).
    """
    k = W.shape[0]
    # Tropical identity: 0 on diagonal, +inf off-diagonal
    result = np.full((k, k), np.inf)
    np.fill_diagonal(result, 0.0)
    for _ in range(n):
        result = tropical_mat_mul(W, result)
    return result


def tropical_mat_pow_fast(W: np.ndarray, n: int) -> np.ndarray:
    """Tropical matrix power by repeated squaring.

    Time complexity: O(k^3 * log n)
    """
    k = W.shape[0]
    result = np.full((k, k), np.inf)
    np.fill_diagonal(result, 0.0)
    base = W.copy()
    while n > 0:
        if n % 2 == 1:
            result = tropical_mat_mul(base, result)
        base = tropical_mat_mul(base, base)
        n //= 2
    return result


def tropical_shortest_paths(W: np.ndarray) -> np.ndarray:
    """Compute all-pairs shortest paths (tropical closure).

    This is the Floyd-Warshall algorithm, equivalent to computing
    the tropical Kleene star W* = I ⊕ W ⊕ W^2 ⊕ ...

    Args:
        W: Weight matrix, shape (n, n). W[i,j] = edge cost i -> j.
            Use np.inf for non-edges.

    Returns:
        Distance matrix D, shape (n, n). D[i,j] = shortest path cost i -> j.

    Time complexity: O(n^3)
    """
    n = W.shape[0]
    D = W.copy()
    for k in range(n):
        for i in range(n):
            for j in range(n):
                if D[i, k] + D[k, j] < D[i, j]:
                    D[i, j] = D[i, k] + D[k, j]
    return D


def radial_update(m: float, r: float) -> float:
    """Tropical radial update: min(r, 2m).

    Args:
        m: Mass parameter.
        r: Current radius.

    Returns:
        Updated radius.
    """
    return min(r, 2 * m)


def find_horizon(m: float) -> float:
    """Find the tropical Schwarzschild horizon radius.

    The horizon is the greatest nonneg fixed point of radialUpdate(m, ·).

    Args:
        m: Mass parameter (must be ≥ 0).

    Returns:
        Horizon radius 2m.
    """
    assert m >= 0, "Mass must be nonneg"
    return 2 * m


def iterate_to_fixed_point(
    update_fn,
    r0: float,
    tol: float = 1e-12,
    max_iter: int = 1000
) -> tuple[float, int]:
    """Iterate a map to its fixed point.

    Args:
        update_fn: The update function r -> R(r).
        r0: Initial value.
        tol: Convergence tolerance.
        max_iter: Maximum iterations.

    Returns:
        Tuple (fixed_point, num_iterations).
    """
    r = r0
    for i in range(max_iter):
        r_new = update_fn(r)
        if abs(r_new - r) < tol:
            return r_new, i + 1
        r = r_new
    return r, max_iter


def verify_monotonicity(
    K: np.ndarray,
    u: np.ndarray,
    v: np.ndarray,
    T: int
) -> bool:
    """Verify monotonicity of tropical evolution: u ≤ v => evolve(u) ≤ evolve(v).

    Args:
        K: Transition kernel.
        u, v: Initial data with u ≤ v pointwise.
        T: Number of steps.

    Returns:
        True if monotonicity holds at every step.
    """
    assert np.all(u <= v), "Requires u ≤ v pointwise"
    for _ in range(T):
        u = tropical_einstein_step(K, u)
        v = tropical_einstein_step(K, v)
        if not np.all(u <= v + 1e-12):
            return False
    return True


def verify_shift_equivariance(
    K: np.ndarray,
    u: np.ndarray,
    c: float,
    T: int
) -> bool:
    """Verify shift equivariance: evolve(u + c) = evolve(u) + c.

    Args:
        K: Transition kernel.
        u: Initial data.
        c: Constant shift.
        T: Number of steps.

    Returns:
        True if equivariance holds at every step.
    """
    u1 = u.copy()
    u2 = u.copy() + c
    for _ in range(T):
        u1 = tropical_einstein_step(K, u1)
        u2 = tropical_einstein_step(K, u2)
        if not np.allclose(u2, u1 + c):
            return False
    return True


if __name__ == "__main__":
    # Quick self-test
    print("Running algorithm self-tests...")

    K = np.array([[0, 1, 4], [3, 0, 2], [1, 5, 0]], dtype=float)
    u = np.array([0.0, np.inf, np.inf])

    # Test evolution
    result = tropical_evolution(K, u, T=3)
    print(f"Evolution result: {result}")

    # Test matrix multiplication
    W2 = tropical_mat_mul(K, K)
    W2_fast = tropical_mat_pow_fast(K, 2)
    assert np.allclose(W2, W2_fast), "Matrix power mismatch"
    print(f"W^2 =\n{W2}")

    # Test shortest paths
    D = tropical_shortest_paths(K)
    print(f"All-pairs shortest paths:\n{D}")

    # Test horizon
    for m in [1.0, 5.0, 10.0]:
        h = find_horizon(m)
        fp, iters = iterate_to_fixed_point(lambda r, m=m: radial_update(m, r), 100.0)
        assert abs(fp - h) < 1e-10
        print(f"m={m}: horizon={h}, iterated={fp} ({iters} iters)")

    # Test monotonicity
    u_lo = np.array([0.0, 1.0, 2.0])
    u_hi = np.array([1.0, 2.0, 3.0])
    assert verify_monotonicity(K, u_lo, u_hi, T=10)
    print("Monotonicity: PASSED")

    # Test shift equivariance
    assert verify_shift_equivariance(K, u_lo, c=7.5, T=10)
    print("Shift equivariance: PASSED")

    print("\nAll self-tests passed!")
