#!/usr/bin/env python3
"""
Algorithms for Tropical Ecosystem Dynamics
===========================================

Implements the core algorithms for min-plus predator-prey dynamics,
tropical eigenvalue computation, and stability analysis.
"""

from typing import Tuple, List, Optional
import numpy as np


def trop_pred_prey_step(
    params: Tuple[float, float, float, float],
    state: Tuple[float, float]
) -> Tuple[float, float]:
    """
    One step of the tropical predator-prey update.

    Args:
        params: (a, b, c, d) interaction parameters
        state: (x, y) current population state in tropical coordinates

    Returns:
        (x', y') next state

    Time complexity: O(1)
    Space complexity: O(1)
    """
    a, b, c, d = params
    x, y = state
    return (min(a + x, b + y), min(c + x, d + y))


def trop_pred_prey_trajectory(
    params: Tuple[float, float, float, float],
    initial: Tuple[float, float],
    steps: int
) -> List[Tuple[float, float]]:
    """
    Compute the full trajectory of the tropical predator-prey system.

    Args:
        params: (a, b, c, d) interaction parameters
        initial: (x0, y0) initial state
        steps: number of iterations

    Returns:
        List of (n+1) states from time 0 to time n

    Time complexity: O(steps)
    Space complexity: O(steps)
    """
    trajectory = [initial]
    state = initial
    for _ in range(steps):
        state = trop_pred_prey_step(params, state)
        trajectory.append(state)
    return trajectory


def trop_eigenvalue_2x2(a: float, b: float, c: float, d: float) -> float:
    """
    Compute the tropical eigenvalue (minimum cycle mean) for a 2x2 min-plus system.

    The eigenvalue is:
        μ = min(a, d, (b+c)/2)

    This equals the minimum over:
    - Self-loop at node 1 (prey): weight a
    - Self-loop at node 2 (predator): weight d
    - 2-cycle through both nodes: average weight (b+c)/2

    Args:
        a, b, c, d: entries of the 2x2 min-plus matrix

    Returns:
        The tropical eigenvalue μ

    Time complexity: O(1)
    """
    return min(a, d, (b + c) / 2)


def find_trop_eigenvector(
    a: float, b: float, c: float, d: float
) -> Optional[Tuple[float, float]]:
    """
    Find a tropical eigenvector for the 2x2 min-plus system.

    A tropical eigenvector v = (v1, v2) satisfies:
        min(a + v1, b + v2) = μ + v1
        min(c + v1, d + v2) = μ + v2

    where μ = min(a, d, (b+c)/2).

    Strategy: set v1 = 0 and solve for v2. The eigenvector equation becomes:
        min(a, b + v2) = μ
        min(c, d + v2) = μ + v2

    Args:
        a, b, c, d: min-plus matrix entries

    Returns:
        Eigenvector (v1, v2) or None if no solution found

    Time complexity: O(1)
    """
    mu = trop_eigenvalue_2x2(a, b, c, d)

    # Case analysis on which cycle achieves the minimum
    if mu == a:
        # Self-loop at prey achieves minimum
        # Need: a + v1 ≤ b + v2 and min(c + v1, d + v2) = a + v2
        # Try v1 = 0
        v1 = 0.0
        # From first eq: a ≤ b + v2, so v2 ≥ a - b
        # From second eq: min(c, d + v2) = a + v2
        # If d + v2 ≤ c: d + v2 = a + v2, so d = a → v2 can be anything ≥ a - b
        # If c ≤ d + v2: c = a + v2, so v2 = c - a
        v2 = c - a
        # Verify
        if (abs(min(a + v1, b + v2) - (mu + v1)) < 1e-10 and
            abs(min(c + v1, d + v2) - (mu + v2)) < 1e-10):
            return (v1, v2)
        # Try other v2 values
        for v2_candidate in [a - b, 0.0, d - a, (c - a + d - b) / 2]:
            if (abs(min(a + v1, b + v2_candidate) - (mu + v1)) < 1e-10 and
                abs(min(c + v1, d + v2_candidate) - (mu + v2_candidate)) < 1e-10):
                return (v1, v2_candidate)

    if mu == d:
        v2 = 0.0
        v1 = b - d
        if (abs(min(a + v1, b + v2) - (mu + v1)) < 1e-10 and
            abs(min(c + v1, d + v2) - (mu + v2)) < 1e-10):
            return (v1, v2)
        for v1_candidate in [d - c, 0.0, (b - d + a - c) / 2]:
            if (abs(min(a + v1_candidate, b + v2) - (mu + v1_candidate)) < 1e-10 and
                abs(min(c + v1_candidate, d + v2) - (mu + v2)) < 1e-10):
                return (v1_candidate, v2)

    if abs(mu - (b + c) / 2) < 1e-10:
        # 2-cycle achieves minimum
        v1 = 0.0
        v2 = (c - b) / 2
        if (abs(min(a + v1, b + v2) - (mu + v1)) < 1e-10 and
            abs(min(c + v1, d + v2) - (mu + v2)) < 1e-10):
            return (v1, v2)

    # Brute force search over a grid
    for v2 in np.linspace(-10, 10, 10001):
        v1 = 0.0
        if (abs(min(a + v1, b + v2) - (mu + v1)) < 1e-6 and
            abs(min(c + v1, d + v2) - (mu + v2)) < 1e-6):
            return (v1, float(v2))

    return None


def sup_dist(p: Tuple[float, float], q: Tuple[float, float]) -> float:
    """L-infinity distance between two points."""
    return max(abs(p[0] - q[0]), abs(p[1] - q[1]))


def verify_nonexpansiveness(
    params: Tuple[float, float, float, float],
    num_trials: int = 10000,
    seed: int = 42
) -> Tuple[bool, float]:
    """
    Numerically verify nonexpansiveness of TropPredPrey.

    Args:
        params: (a, b, c, d) interaction parameters
        num_trials: number of random pairs to test
        seed: random seed

    Returns:
        (is_nonexpansive, max_expansion_ratio)

    Time complexity: O(num_trials)
    """
    rng = np.random.RandomState(seed)
    max_ratio = 0.0

    for _ in range(num_trials):
        p = tuple(rng.randn(2) * 10)
        q = tuple(rng.randn(2) * 10)
        fp = trop_pred_prey_step(params, p)
        fq = trop_pred_prey_step(params, q)
        d_in = sup_dist(p, q)
        d_out = sup_dist(fp, fq)
        if d_in > 1e-12:
            max_ratio = max(max_ratio, d_out / d_in)

    return max_ratio <= 1.0 + 1e-10, max_ratio


def trop_matrix_power(
    a: float, b: float, c: float, d: float, n: int
) -> Tuple[float, float, float, float]:
    """
    Compute the n-th min-plus power of the 2x2 matrix [[a,b],[c,d]].

    Min-plus matrix multiplication: (A ⊗ B)_{ij} = min_k (A_{ik} + B_{kj})

    Args:
        a, b, c, d: matrix entries
        n: power (non-negative integer)

    Returns:
        (a', b', c', d') entries of A^n in min-plus algebra

    Time complexity: O(n) (could be O(log n) with repeated squaring)
    """
    if n == 0:
        return (0.0, float('inf'), float('inf'), 0.0)  # min-plus identity

    ra, rb, rc, rd = a, b, c, d
    for _ in range(n - 1):
        new_a = min(a + ra, b + rc)
        new_b = min(a + rb, b + rd)
        new_c = min(c + ra, d + rc)
        new_d = min(c + rb, d + rd)
        ra, rb, rc, rd = new_a, new_b, new_c, new_d

    return (ra, rb, rc, rd)


def karp_cycle_mean_2x2(a: float, b: float, c: float, d: float) -> float:
    """
    Compute the minimum cycle mean using Karp's algorithm for a 2-node graph.

    For a 2x2 system, this is equivalent to:
        μ = min(a, d, (b+c)/2)

    but computed via Karp's general algorithm (specialized to 2 nodes).

    Karp's formula:
        μ = min_j min_{0 ≤ k < n} (F^n(0)_j - F^k(0)_j) / (n - k)

    where n = number of nodes = 2.

    Time complexity: O(n^2) = O(4) for n=2
    """
    n = 2
    # Compute F^k(0,0) for k = 0, 1, 2
    iterates = [(0.0, 0.0)]
    state = (0.0, 0.0)
    for _ in range(n):
        state = trop_pred_prey_step((a, b, c, d), state)
        iterates.append(state)

    # Karp's formula
    mu = float('inf')
    for j in range(n):
        vals = [iterates[k][j] for k in range(n + 1)]
        for k in range(n):
            candidate = (vals[n] - vals[k]) / (n - k)
            mu = min(mu, candidate)

    return mu


# ─── Main demo ─────────────────────────────────────────────────────────────
if __name__ == "__main__":
    print("Tropical Ecosystem Dynamics — Algorithm Demonstrations")
    print("=" * 60)

    # Example 1: Eigenvector computation
    print("\n--- Eigenvector Computation ---")
    a, b, c, d = 1, 3, 1, 5
    mu = trop_eigenvalue_2x2(a, b, c, d)
    ev = find_trop_eigenvector(a, b, c, d)
    print(f"Matrix: [[{a},{b}],[{c},{d}]]")
    print(f"Eigenvalue μ = {mu}")
    print(f"Eigenvector v = {ev}")
    if ev:
        fv = trop_pred_prey_step((a, b, c, d), ev)
        print(f"F(v) = {fv}")
        print(f"μ + v = ({mu + ev[0]}, {mu + ev[1]})")

    # Example 2: Matrix powers
    print("\n--- Min-Plus Matrix Powers ---")
    for n in range(1, 6):
        An = trop_matrix_power(a, b, c, d, n)
        print(f"A^{n} = [[{An[0]:.1f}, {An[1]:.1f}], [{An[2]:.1f}, {An[3]:.1f}]]")

    # Example 3: Karp's algorithm
    print("\n--- Karp's Cycle Mean Algorithm ---")
    test_cases = [(1, 3, 1, 5), (0, -1, -1, 0), (2, 1, 3, 4)]
    for a, b, c, d in test_cases:
        mu_direct = trop_eigenvalue_2x2(a, b, c, d)
        mu_karp = karp_cycle_mean_2x2(a, b, c, d)
        print(f"[[{a},{b}],[{c},{d}]]: direct={mu_direct:.2f}, Karp={mu_karp:.2f}, "
              f"match={abs(mu_direct - mu_karp) < 1e-10}")

    # Example 4: Nonexpansiveness verification
    print("\n--- Nonexpansiveness Verification ---")
    for params in [(1, 3, 1, 5), (0, -1, -1, 0), (-2, 3, 1, -1)]:
        ok, ratio = verify_nonexpansiveness(params)
        print(f"params={params}: nonexpansive={ok}, max_ratio={ratio:.8f}")
