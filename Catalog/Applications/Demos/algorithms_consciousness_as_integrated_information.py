#!/usr/bin/env python3
"""
Integrated Information Theory: Core Algorithms

Type-hinted implementations of all key computational procedures.
"""

from __future__ import annotations
import numpy as np
from dataclasses import dataclass, field
from itertools import combinations
from typing import FrozenSet


@dataclass
class CausalCoupling:
    """A weighted undirected graph with non-negative symmetric weights and no self-loops."""
    n: int
    weights: np.ndarray

    def __post_init__(self) -> None:
        assert self.weights.shape == (self.n, self.n)
        assert np.allclose(self.weights, self.weights.T), "Weights must be symmetric"
        assert np.all(self.weights >= -1e-12), "Weights must be non-negative"
        assert np.allclose(np.diag(self.weights), 0), "No self-loops"

    @staticmethod
    def uniform_complete(n: int, w: float) -> CausalCoupling:
        """Create uniform complete coupling K_n(w)."""
        weights = w * (np.ones((n, n)) - np.eye(n))
        return CausalCoupling(n=n, weights=weights)

    @staticmethod
    def from_adjacency(adj: list[list[float]]) -> CausalCoupling:
        """Create coupling from adjacency matrix."""
        w = np.array(adj, dtype=float)
        return CausalCoupling(n=w.shape[0], weights=w)


@dataclass
class CutResult:
    """Result of a minimum cut computation."""
    phi: float
    optimal_partition: frozenset[int]
    all_cuts: dict[FrozenSet[int], float] = field(default_factory=dict)


def cut_value(coupling: CausalCoupling, S: frozenset[int]) -> float:
    """Compute cut value: sum of cross-partition weights.

    Algorithm: O(|S| · |Sᶜ|) direct summation.
    """
    complement = frozenset(range(coupling.n)) - S
    total = 0.0
    for i in S:
        for j in complement:
            total += coupling.weights[i, j]
    return total


def compute_phi(coupling: CausalCoupling) -> CutResult:
    """Compute Phi = minimum cut over all non-trivial bipartitions.

    Algorithm: Exhaustive enumeration over 2^n - 2 partitions.
    Complexity: O(2^n · n²) — exact but exponential.

    For large n, use Stoer-Wagner algorithm (O(mn + n² log n)).
    """
    n = coupling.n
    if n < 2:
        return CutResult(phi=0.0, optimal_partition=frozenset())

    best_cut = float('inf')
    best_S: frozenset[int] = frozenset()
    all_cuts: dict[FrozenSet[int], float] = {}

    for size in range(1, n):
        for subset in combinations(range(n), size):
            S = frozenset(subset)
            cv = cut_value(coupling, S)
            all_cuts[S] = cv
            if cv < best_cut:
                best_cut = cv
                best_S = S

    return CutResult(phi=best_cut, optimal_partition=best_S, all_cuts=all_cuts)


def weighted_degree(coupling: CausalCoupling, v: int) -> float:
    """Compute weighted degree of vertex v: sum of all edge weights incident to v."""
    return float(np.sum(coupling.weights[v, :]))


def total_coupling(coupling: CausalCoupling) -> float:
    """Compute total coupling: sum of all weights (each edge counted twice)."""
    return float(np.sum(coupling.weights))


@dataclass
class FiltrationLevel:
    """A single level of the Integration Filtration."""
    threshold: float
    members: list[frozenset[int]]
    count: int


def compute_integration_filtration(
    coupling: CausalCoupling,
    thresholds: list[float]
) -> tuple[list[FiltrationLevel], dict[FrozenSet[int], float]]:
    """Compute the Integration Filtration at multiple thresholds.

    Algorithm:
    1. For each subset S with |S| ≥ 2, compute Φ(induced subgraph on S)
    2. For each threshold τ, collect all S with Φ_S ≥ τ

    Complexity: O(2^n · 2^n) in the worst case (2^n subsets, each needing 2^|S| cut computations)

    Returns: (filtration_levels, subset_phi_values)
    """
    n = coupling.n
    subset_phis: dict[FrozenSet[int], float] = {}

    for size in range(2, n + 1):
        for subset in combinations(range(n), size):
            S = frozenset(subset)
            indices = sorted(S)
            sub_weights = coupling.weights[np.ix_(indices, indices)]
            sub_coupling = CausalCoupling(n=len(indices), weights=sub_weights)
            result = compute_phi(sub_coupling)
            subset_phis[S] = result.phi

    levels = []
    for tau in sorted(thresholds):
        members = [S for S, phi in subset_phis.items() if phi >= tau]
        levels.append(FiltrationLevel(
            threshold=tau,
            members=sorted(members, key=lambda s: (len(s), tuple(sorted(s)))),
            count=len(members)
        ))

    return levels, subset_phis


def direct_sum(c1: CausalCoupling, c2: CausalCoupling) -> CausalCoupling:
    """Construct direct sum C₁ ⊕ C₂: block diagonal, no cross-coupling.

    Pseudocode:
        w(i,j) = C₁(i,j)     if i,j < m
        w(i,j) = C₂(i-m,j-m) if i,j ≥ m
        w(i,j) = 0            otherwise
    """
    m, n = c1.n, c2.n
    weights = np.zeros((m + n, m + n))
    weights[:m, :m] = c1.weights
    weights[m:, m:] = c2.weights
    return CausalCoupling(n=m + n, weights=weights)


def uniform_interaction(
    c1: CausalCoupling,
    c2: CausalCoupling,
    epsilon: float
) -> CausalCoupling:
    """Construct uniform interaction C₁ ⊗_ε C₂: direct sum + cross-coupling ε.

    Pseudocode:
        w(i,j) = C₁(i,j)     if i,j < m
        w(i,j) = C₂(i-m,j-m) if i,j ≥ m
        w(i,j) = ε            if i < m, j ≥ m (or vice versa), i ≠ j
    """
    m, n = c1.n, c2.n
    weights = np.zeros((m + n, m + n))
    weights[:m, :m] = c1.weights
    weights[m:, m:] = c2.weights
    weights[:m, m:] = epsilon
    weights[m:, :m] = epsilon
    np.fill_diagonal(weights, 0)
    return CausalCoupling(n=m + n, weights=weights)


# Stoer-Wagner minimum cut (polynomial time)
def stoer_wagner_min_cut(coupling: CausalCoupling) -> CutResult:
    """Stoer-Wagner minimum cut algorithm.

    Complexity: O(n³) with adjacency matrix representation.

    The algorithm repeatedly performs "minimum cut phases":
    1. Start with arbitrary vertex
    2. Greedily add the most tightly connected vertex
    3. The last two vertices give a candidate cut
    4. Merge the last two vertices and repeat
    """
    n = coupling.n
    if n < 2:
        return CutResult(phi=0.0, optimal_partition=frozenset())

    # Work with a mutable copy
    w = coupling.weights.copy()
    # Track which original vertices are merged into each supervertex
    groups: list[list[int]] = [[i] for i in range(n)]
    active = list(range(n))

    best_cut = float('inf')
    best_partition: frozenset[int] = frozenset()

    for _ in range(n - 1):
        # Minimum cut phase
        k = len(active)
        if k < 2:
            break

        in_A = [False] * n
        key = [0.0] * n
        order = []

        # Start with first active vertex
        start = active[0]
        in_A[start] = True
        order.append(start)

        for j in active:
            if j != start:
                key[j] = w[start, j]

        for _ in range(1, k):
            # Find most tightly connected vertex not in A
            best_v = -1
            best_key = -1.0
            for j in active:
                if not in_A[j] and key[j] > best_key:
                    best_key = key[j]
                    best_v = j

            if best_v == -1:
                break

            in_A[best_v] = True
            order.append(best_v)

            # Update keys
            for j in active:
                if not in_A[j]:
                    key[j] += w[best_v, j]

        if len(order) < 2:
            break

        # The cut of the phase: weight of edges from last vertex to rest
        t = order[-1]
        s = order[-2]
        cut_of_phase = sum(w[t, j] for j in active if j != t)

        if cut_of_phase < best_cut:
            best_cut = cut_of_phase
            best_partition = frozenset(groups[t])

        # Merge s and t
        for j in active:
            if j != s and j != t:
                w[s, j] += w[t, j]
                w[j, s] += w[j, t]

        groups[s].extend(groups[t])
        active.remove(t)

    return CutResult(phi=best_cut, optimal_partition=best_partition)


if __name__ == "__main__":
    # Quick test
    K4 = CausalCoupling.uniform_complete(4, 1.0)
    result = compute_phi(K4)
    print(f"Φ(K_4(1)) = {result.phi} (expected 3.0)")

    sw_result = stoer_wagner_min_cut(K4)
    print(f"Stoer-Wagner: Φ(K_4(1)) = {sw_result.phi} (expected 3.0)")

    # Test direct sum
    K3a = CausalCoupling.uniform_complete(3, 2.0)
    K3b = CausalCoupling.uniform_complete(3, 3.0)
    ds = direct_sum(K3a, K3b)
    ds_result = compute_phi(ds)
    print(f"Φ(K_3(2) ⊕ K_3(3)) = {ds_result.phi} (expected 0.0)")
