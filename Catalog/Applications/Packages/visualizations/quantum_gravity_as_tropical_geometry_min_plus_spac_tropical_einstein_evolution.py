#!/usr/bin/env python3
"""
Tropical Gravitational Dynamics — Algorithms

Efficient implementations of the core tropical operators with full
docstrings, type hints, and complexity analysis.
"""

import numpy as np
from typing import Optional


def tropical_superposition(a: float, b: float) -> float:
    """
    Tropical superposition (min-plus addition).

    In the tropical semiring (ℝ, min, +), this is the additive operation.

    Properties (all formally verified):
    - Idempotent: trop_sup(a, a) = a
    - Commutative: trop_sup(a, b) = trop_sup(b, a)
    - Associative: trop_sup(trop_sup(a, b), c) = trop_sup(a, trop_sup(b, c))
    - Monotone: a ≤ b ⟹ trop_sup(a, c) ≤ trop_sup(b, c)

    Time: O(1), Space: O(1)

    Args:
        a: First tropical amplitude
        b: Second tropical amplitude

    Returns:
        min(a, b)
    """
    return min(a, b)


def radial_cost(w: list[float], i: int, j: int) -> float:
    """
    Cumulative cost on a weighted radial lattice.

    Computes the sum of edge weights between positions i and j.
    When weights are nonnegative, this satisfies:
    - radial_cost(w, i, i) = 0
    - radial_cost(w, i, j) = radial_cost(w, j, i)
    - radial_cost(w, i, k) ≤ radial_cost(w, i, j) + radial_cost(w, j, k)
    - radial_cost(w, i, j) ≥ 0

    Time: O(|i - j|), Space: O(1)

    Args:
        w: Edge weight function (as list, index k = weight of edge k→k+1)
        i: Start position
        j: End position

    Returns:
        Sum of weights between i and j
    """
    if i <= j:
        return sum(w[k] for k in range(i, j))
    else:
        return sum(w[k] for k in range(j, i))


def tropical_einstein_step(
    V: list[float], phi: list[float]
) -> list[float]:
    """
    One step of tropical Einstein evolution.

    Implements the min-plus update:
        ψ(n) = min(φ(n), V(n) + φ(n+1))

    This is the tropical analogue of a discrete Hamilton-Jacobi step,
    and simultaneously a Bellman equation update.

    Properties (all formally verified):
    - Well-posed: unique output for any input
    - Monotone: φ ≤ ψ ⟹ T(φ) ≤ T(ψ)
    - Nonexpansive: |T(φ) - T(ψ)| ≤ max|φ - ψ|

    Time: O(N), Space: O(N)

    Args:
        V: Potential function (length N)
        phi: Initial data (length N)

    Returns:
        Evolved data (length N)
    """
    N = len(phi)
    result = [0.0] * N
    for n in range(N - 1):
        result[n] = min(phi[n], V[n] + phi[n + 1])
    result[N - 1] = phi[N - 1]
    return result


def tropical_evolve(
    V: list[float], phi: list[float], t: int
) -> list[float]:
    """
    Multi-step tropical Einstein evolution.

    Iterates tropical_einstein_step t times.
    Preserves monotonicity at each step (formally verified).

    Time: O(t · N), Space: O(N)

    Args:
        V: Potential function
        phi: Initial data
        t: Number of time steps

    Returns:
        Evolved data after t steps
    """
    psi = phi[:]
    for _ in range(t):
        psi = tropical_einstein_step(V, psi)
    return psi


def tropical_radius_update(m: float, r: float) -> float:
    """
    Tropical radial update operator.

    Models the tropical Schwarzschild geometry:
        tropRadiusUpdate(m, r) = min(r, 2m)

    Properties (all formally verified):
    - Fixed point: tropRadiusUpdate(m, 2m) = 2m
    - Absorbing: r ≥ 2m ⟹ tropRadiusUpdate(m, r) = 2m
    - Least fixed point: tropRadiusUpdate(m, r) = r ⟹ r ≤ 2m
    - Classification: tropRadiusUpdate(m, r) = r ↔ r ≤ 2m

    Time: O(1), Space: O(1)

    Args:
        m: Mass parameter (≥ 0)
        r: Radial coordinate

    Returns:
        min(r, 2m)
    """
    return min(r, 2 * m)


def horizon_classify(m: float, r: float) -> str:
    """
    Classify a radius relative to the tropical horizon.

    Args:
        m: Mass parameter
        r: Radial coordinate

    Returns:
        "interior" if r < 2m, "horizon" if r = 2m, "exterior" if r > 2m
    """
    schwarzschild = 2 * m
    if r < schwarzschild:
        return "interior"
    elif r == schwarzschild:
        return "horizon"
    else:
        return "exterior"


def tropical_transfer(W: np.ndarray, phi: np.ndarray) -> np.ndarray:
    """
    Min-plus matrix-vector product (tropical transfer operator).

    Computes:
        (T φ)(i) = min_j (W[i,j] + φ[j])

    This is the fundamental operation of tropical linear algebra.

    Properties (all formally verified):
    - Monotone: φ ≤ ψ ⟹ T(φ) ≤ T(ψ)
    - Tropical homogeneous: T(φ + c) = T(φ) + c
    - On constants: T(c·1) = (row-min of W) + c

    Time: O(n²), Space: O(n)

    Args:
        W: Weight matrix (n × n)
        phi: Input vector (length n)

    Returns:
        Output vector (length n)
    """
    n = len(phi)
    result = np.zeros(n)
    for i in range(n):
        result[i] = min(W[i, j] + phi[j] for j in range(n))
    return result


def graph_evolve(
    W: np.ndarray, phi: np.ndarray, t: int
) -> np.ndarray:
    """
    Multi-step tropical graph evolution.

    Iterates the tropical transfer operator t times.
    Computing shortest paths of length ≤ t.

    Time: O(t · n²), Space: O(n)

    Args:
        W: Weight matrix
        phi: Initial data
        t: Number of steps

    Returns:
        Evolved data after t steps
    """
    psi = phi.copy()
    for _ in range(t):
        psi = tropical_transfer(W, psi)
    return psi


def bellman_ford_tropical(
    W: np.ndarray, source: int
) -> np.ndarray:
    """
    Shortest paths from source via tropical transfer iteration.

    Equivalent to Bellman-Ford algorithm, implemented as
    iterated tropical transfer on the indicator of the source.

    Time: O(n³), Space: O(n)

    Args:
        W: Weight matrix (n × n), W[i][j] = cost of edge i→j
        source: Source node index

    Returns:
        Array of shortest distances from source to all nodes
    """
    n = W.shape[0]
    # Indicator of source: 0 at source, +inf elsewhere
    phi = np.full(n, np.inf)
    phi[source] = 0.0

    # Iterate n-1 times (sufficient for shortest paths without negative cycles)
    for _ in range(n - 1):
        phi = tropical_transfer(W, phi)

    return phi


def tropical_evaporation(
    m_initial: float, dm: float, steps: int
) -> list[tuple[float, float, float]]:
    """
    Simulate tropical black hole evaporation.

    The mass decreases by dm each step, shifting the horizon inward.
    Points in the released region [2(m-dm), 2m] escape.

    Args:
        m_initial: Initial mass
        dm: Mass loss per step
        steps: Number of evaporation steps

    Returns:
        List of (time, mass, horizon_radius) tuples
    """
    history = []
    m = m_initial
    for t in range(steps + 1):
        horizon = 2 * m
        history.append((t, m, horizon))
        m = max(0, m - dm)
    return history


# ─── Example usage ───

if __name__ == "__main__":
    print("=== Tropical Transfer: Shortest Paths ===")
    W = np.array([
        [0, 1, 5, 10],
        [1, 0, 2,  8],
        [5, 2, 0,  1],
        [10, 8, 1, 0],
    ], dtype=float)

    for src in range(4):
        dists = bellman_ford_tropical(W, src)
        print(f"  Shortest paths from node {src}: {dists}")

    print("\n=== Tropical Evaporation ===")
    history = tropical_evaporation(5.0, 0.5, 10)
    for t, m, r_h in history:
        print(f"  t={t:2d}: m={m:.1f}, horizon={r_h:.1f}")

    print("\n=== Multi-step Evolution ===")
    V = [0.5, 0.3, 0.1, -0.2, -0.5, 0.0, 0.2, 0.4]
    phi = [10, 8, 6, 4, 2, 0, 2, 4]
    phi = [float(x) for x in phi]
    print(f"  V = {V}")
    print(f"  φ₀ = {phi}")
    for t in range(1, 6):
        phi = tropical_einstein_step(V, phi)
        print(f"  φ_{t} = {[round(x, 2) for x in phi]}")
