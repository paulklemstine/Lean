#!/usr/bin/env python3
"""
Algorithms for Tropical Vertical Composition

Implements the core algorithms from the tropical compositional dynamics theory,
including tropical matrix-vector multiplication, vertical iteration, spectral
bound computation, maximum cycle mean (Karp's algorithm), and tropical
eigenvector computation (Howard's policy iteration).

All algorithms include docstrings, type hints, complexity analysis, and examples.
"""

import numpy as np
from typing import Tuple, List, Optional


def trop_mat_vec(A: np.ndarray, x: np.ndarray) -> np.ndarray:
    """Tropical matrix-vector product: (A ⊗ x)_i = max_j(A_ij + x_j).

    This is the fundamental operation of max-plus linear algebra.
    In the tropical semiring (ℝ ∪ {-∞}, max, +), this replaces the
    standard matrix-vector product (sum of products) with max of sums.

    Args:
        A: n×n matrix (numpy array)
        x: n-vector (numpy array)

    Returns:
        n-vector y where y_i = max_j(A_ij + x_j)

    Time complexity: O(n²)
    Space complexity: O(n)

    Example:
        >>> A = np.array([[1.0, 2.0], [3.0, 0.0]])
        >>> x = np.array([1.0, -1.0])
        >>> trop_mat_vec(A, x)
        array([2., 4.])
    """
    # Broadcasting: A + x[np.newaxis, :] adds x to each row of A
    return np.max(A + x[np.newaxis, :], axis=1)


def trop_mat_mul(A: np.ndarray, B: np.ndarray) -> np.ndarray:
    """Tropical matrix multiplication: (A ⊗ B)_ij = max_k(A_ik + B_kj).

    Args:
        A: n×m matrix
        B: m×p matrix

    Returns:
        n×p matrix C where C_ij = max_k(A_ik + B_kj)

    Time complexity: O(n·m·p)
    Space complexity: O(n·p)

    Example:
        >>> A = np.array([[1.0, 2.0], [3.0, 0.0]])
        >>> B = np.array([[0.0, 1.0], [2.0, -1.0]])
        >>> trop_mat_mul(A, B)
        array([[4., 1.],
               [3., 4.]])
    """
    n, m = A.shape
    _, p = B.shape
    C = np.full((n, p), -np.inf)
    for i in range(n):
        for j in range(p):
            C[i, j] = np.max(A[i, :] + B[:, j])
    return C


def vertical_iterate(A: np.ndarray, k: int, x: np.ndarray) -> np.ndarray:
    """k-fold tropical matrix-vector iteration: A^⊗k ⊗ x.

    Computes k applications of the tropical matrix-vector product,
    modeling depth-k computation in a tropical neural network.

    Args:
        A: n×n weight matrix
        k: number of iterations (depth)
        x: initial n-vector

    Returns:
        Result of k tropical matrix-vector multiplications

    Time complexity: O(k·n²)
    Space complexity: O(n)

    Example:
        >>> A = np.array([[1.0, 0.0], [0.0, 1.0]])
        >>> x = np.array([0.0, 0.0])
        >>> vertical_iterate(A, 3, x)
        array([3., 3.])
    """
    result = x.copy()
    for _ in range(k):
        result = trop_mat_vec(A, result)
    return result


def sup_norm(x: np.ndarray) -> float:
    """Sup-norm (tropical Lyapunov function): max_i x_i.

    Args:
        x: n-vector

    Returns:
        Maximum component value

    Time complexity: O(n)

    Example:
        >>> sup_norm(np.array([1.0, -2.0, 3.0]))
        3.0
    """
    return float(np.max(x))


def mat_max_entry(A: np.ndarray) -> float:
    """Maximum matrix entry (tropical spectral bound).

    This is the simplest upper bound on the per-step growth rate
    of tropical vertical composition. Our main theorem states:
    supNorm(A ⊗ x) ≤ matMaxEntry(A) + supNorm(x)

    Args:
        A: n×n matrix

    Returns:
        Maximum entry of A

    Time complexity: O(n²)

    Example:
        >>> mat_max_entry(np.array([[1.0, -2.0], [3.0, 0.0]]))
        3.0
    """
    return float(np.max(A))


def max_cycle_mean_karp(A: np.ndarray) -> float:
    """Maximum cycle mean via Karp's algorithm.

    Computes the tropical spectral radius: the maximum average weight
    over all directed cycles in the weighted digraph defined by A.

    This is the tightest possible growth rate for vertical iteration:
    lim_{k→∞} supNorm(A^k ⊗ 0) / k = maxCycleMean(A)

    Algorithm: Karp (1978)
        μ(A) = max_i min_{0≤k<n} (d_n(i) - d_k(i)) / (n - k)
    where d_k(i) = max weight of any k-step path ending at i.

    Args:
        A: n×n matrix (entries can be -∞ for absent edges)

    Returns:
        Maximum cycle mean (tropical spectral radius)

    Time complexity: O(n³)
    Space complexity: O(n²)

    Example:
        >>> A = np.array([[1.0, 2.0], [3.0, 0.0]])
        >>> max_cycle_mean_karp(A)  # cycle 0→1→0 has mean (2+3)/2 = 2.5
        2.5
    """
    n = A.shape[0]
    d = np.full((n + 1, n), -np.inf)
    d[0, :] = 0.0

    for step in range(1, n + 1):
        for i in range(n):
            for j in range(n):
                if d[step - 1][j] > -np.inf:
                    d[step][i] = max(d[step][i], d[step - 1][j] + A[i][j])

    result = -np.inf
    for i in range(n):
        if d[n][i] <= -np.inf:
            continue
        min_ratio = np.inf
        for k in range(n):
            if d[k][i] > -np.inf:
                ratio = (d[n][i] - d[k][i]) / (n - k)
                min_ratio = min(min_ratio, ratio)
        if min_ratio < np.inf:
            result = max(result, min_ratio)

    return float(result)


def tropical_eigenvector_howard(A: np.ndarray, max_iter: int = 100) -> Tuple[float, np.ndarray]:
    """Tropical eigenvector via Howard's policy iteration.

    Finds λ and v such that A ⊗ v = λ + v (tropical eigenvalue/eigenvector).
    The eigenvalue λ equals the maximum cycle mean.

    Algorithm: Howard's policy iteration (1960)
    1. Start with an arbitrary policy π (for each i, choose j = π(i))
    2. Solve the mean-payoff system for current policy
    3. Improve policy greedily
    4. Repeat until convergence

    Args:
        A: n×n matrix
        max_iter: maximum iterations

    Returns:
        (eigenvalue, eigenvector) tuple

    Time complexity: O(n³) per iteration, at most n iterations → O(n⁴) worst case
    Space complexity: O(n)

    Example:
        >>> A = np.array([[2.0, -100.0], [-100.0, 2.0]])
        >>> lam, v = tropical_eigenvector_howard(A)
        >>> np.isclose(lam, 2.0)
        True
    """
    n = A.shape[0]

    # Initial policy: greedy
    policy = np.argmax(A, axis=1)

    for _ in range(max_iter):
        # Extract policy matrix: P_ij = A[i, policy[i]]
        # Solve: A[i, π(i)] + v[π(i)] = λ + v[i] for all i
        # This is a system of linear equations in (λ, v)

        # Build the cycle structure of the policy
        visited = np.full(n, -1, dtype=int)
        cycle_nodes = set()
        lam = -np.inf

        for start in range(n):
            if visited[start] >= 0:
                continue
            path = []
            node = start
            while visited[node] < 0:
                visited[node] = len(path)
                path.append(node)
                node = policy[node]
            if node in path[visited[node]:]:
                # Found a cycle
                cycle_start_idx = path.index(node)
                cycle = path[cycle_start_idx:]
                cycle_weight = sum(A[cycle[i], cycle[(i+1) % len(cycle)]]
                                  for i in range(len(cycle)))
                cycle_mean = cycle_weight / len(cycle)
                lam = max(lam, cycle_mean)
                cycle_nodes.update(cycle)

        # Compute eigenvector: set v[i] = 0 for some node in max-mean cycle,
        # then propagate
        v = np.zeros(n)
        # BFS from cycle nodes
        processed = np.zeros(n, dtype=bool)
        # Find nodes in the maximum cycle
        for start in range(n):
            node = start
            path = [node]
            seen = {node}
            while policy[node] not in seen:
                node = policy[node]
                path.append(node)
                seen.add(node)
            cycle_start = policy[node]
            cycle = []
            idx = path.index(cycle_start)
            cycle = path[idx:]
            if len(cycle) > 0:
                cw = sum(A[cycle[i], cycle[(i+1) % len(cycle)]]
                        for i in range(len(cycle)))
                cm = cw / len(cycle)
                if np.isclose(cm, lam):
                    for c in cycle:
                        processed[c] = True

        # Propagate v along policy graph
        changed = True
        iterations = 0
        while changed and iterations < n:
            changed = False
            for i in range(n):
                if not processed[i] and processed[policy[i]]:
                    v[i] = A[i, policy[i]] + v[policy[i]] - lam
                    processed[i] = True
                    changed = True
            iterations += 1

        # Policy improvement
        new_policy = np.empty(n, dtype=int)
        for i in range(n):
            new_policy[i] = np.argmax(A[i, :] + v)
        if np.array_equal(new_policy, policy):
            break
        policy = new_policy

    return float(lam), v


def depth_stability_certificate(A: np.ndarray, max_depth: int,
                                 x: np.ndarray) -> dict:
    """Compute depth stability certificate for a tropical network.

    Returns a certificate containing:
    - The matMaxEntry bound (coarse)
    - The maxCycleMean bound (tight)
    - Actual growth trajectory
    - Whether the network is contracting, neutral, or growing

    Args:
        A: n×n weight matrix
        max_depth: maximum depth to analyze
        x: initial input vector

    Returns:
        Dictionary with certificate data

    Example:
        >>> A = np.array([[-1.0, -2.0], [-2.0, -1.0]])
        >>> cert = depth_stability_certificate(A, 10, np.zeros(2))
        >>> cert['regime']
        'contracting'
    """
    M = mat_max_entry(A)
    mcm = max_cycle_mean_karp(A)
    s0 = sup_norm(x)

    trajectory = []
    coarse_bounds = []
    tight_bounds = []

    for k in range(max_depth + 1):
        y = vertical_iterate(A, k, x)
        sn = sup_norm(y)
        trajectory.append(sn)
        coarse_bounds.append(k * M + s0)
        tight_bounds.append(k * mcm + s0)

    regime = 'contracting' if mcm < -1e-10 else ('neutral' if mcm < 1e-10 else 'growing')

    return {
        'mat_max_entry': M,
        'max_cycle_mean': mcm,
        'initial_sup_norm': s0,
        'trajectory': trajectory,
        'coarse_bounds': coarse_bounds,
        'tight_bounds': tight_bounds,
        'regime': regime,
        'max_depth': max_depth,
    }


# ═══════════════════════════════════════════════════════════════════════
# Self-test
# ═══════════════════════════════════════════════════════════════════════
if __name__ == "__main__":
    print("Testing tropical algorithms...")
    print()

    # Test trop_mat_vec
    A = np.array([[1.0, 2.0], [3.0, 0.0]])
    x = np.array([1.0, -1.0])
    y = trop_mat_vec(A, x)
    assert np.allclose(y, [2.0, 4.0]), f"trop_mat_vec failed: {y}"
    print("✓ trop_mat_vec")

    # Test trop_mat_mul
    B = np.array([[0.0, 1.0], [2.0, -1.0]])
    C = trop_mat_mul(A, B)
    # A⊗B: C[0,0]=max(1+0,2+2)=4, C[0,1]=max(1+1,2+(-1))=2, C[1,0]=max(3+0,0+2)=3, C[1,1]=max(3+1,0+(-1))=4
    assert np.allclose(C, [[4.0, 2.0], [3.0, 4.0]]), f"trop_mat_mul failed: {C}"
    print("✓ trop_mat_mul")

    # Test max_cycle_mean_karp
    mcm = max_cycle_mean_karp(A)
    assert np.isclose(mcm, 2.5), f"max_cycle_mean_karp failed: {mcm}"
    print(f"✓ max_cycle_mean_karp: {mcm}")

    # Test vertical_iterate bound
    A2 = np.array([[1.0, -1.0], [-1.0, 1.0]])
    x0 = np.zeros(2)
    M = mat_max_entry(A2)
    for k in range(20):
        y = vertical_iterate(A2, k, x0)
        sn = sup_norm(y)
        bound = k * M
        assert sn <= bound + 1e-10, f"Bound violated at k={k}: {sn} > {bound}"
    print("✓ vertical_iterate_bound (20 steps)")

    # Test eigenvector
    A_diag = np.array([[3.0, -100.0], [-100.0, 3.0]])
    lam, v = tropical_eigenvector_howard(A_diag)
    assert np.isclose(lam, 3.0), f"Eigenvalue failed: {lam}"
    print(f"✓ tropical_eigenvector_howard: λ = {lam}")

    # Test depth stability certificate
    cert = depth_stability_certificate(
        np.array([[-1.0, -2.0], [-2.0, -1.0]]), 10, np.zeros(2))
    assert cert['regime'] == 'contracting'
    print(f"✓ depth_stability_certificate: regime = {cert['regime']}")

    print()
    print("All tests passed!")
