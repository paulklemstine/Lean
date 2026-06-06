#!/usr/bin/env python3
"""
Causal Integration Algebra — Core Algorithms

Type-hinted implementations of the key algorithms from the
Causal Integration framework for Integrated Information Theory.
"""

from typing import List, Tuple, Set, Optional, Dict
from itertools import combinations
import numpy as np


class CausalNetwork:
    """A weighted directed graph representing a causal system.

    Attributes:
        n: Number of nodes (components)
        weights: n×n non-negative weight matrix (w[i][j] = causal influence i→j)
    """

    def __init__(self, weights: np.ndarray) -> None:
        assert weights.ndim == 2
        assert weights.shape[0] == weights.shape[1]
        assert np.all(weights >= 0), "Weights must be non-negative"
        self.n: int = weights.shape[0]
        self.weights: np.ndarray = weights.copy()

    @classmethod
    def complete(cls, n: int, weight: float = 1.0) -> "CausalNetwork":
        """Create a complete graph with uniform weight (no self-loops)."""
        W = np.full((n, n), weight) - weight * np.eye(n)
        return cls(W)

    @classmethod
    def zero(cls, n: int) -> "CausalNetwork":
        """Create the zero network (no connections)."""
        return cls(np.zeros((n, n)))

    @classmethod
    def block_diagonal(cls, blocks: List[np.ndarray]) -> "CausalNetwork":
        """Create a block-diagonal network from component weight matrices."""
        n = sum(b.shape[0] for b in blocks)
        W = np.zeros((n, n))
        offset = 0
        for block in blocks:
            k = block.shape[0]
            W[offset:offset+k, offset:offset+k] = block
            offset += k
        return cls(W)

    def is_symmetric(self) -> bool:
        """Check if the network has symmetric weights."""
        return np.allclose(self.weights, self.weights.T)


def cross_weight(net: CausalNetwork, S: Set[int]) -> float:
    """Compute the total directed weight from S to its complement.

    Algorithm: Sum w[i][j] for all i ∈ S, j ∉ S.
    Time complexity: O(n²)

    Args:
        net: The causal network
        S: A subset of nodes {0, ..., n-1}

    Returns:
        The cross-weight from S to Sᶜ
    """
    S_comp = set(range(net.n)) - S
    return sum(net.weights[i, j] for i in S for j in S_comp)


def cut_value(net: CausalNetwork, S: Set[int]) -> float:
    """Compute the bidirectional cut value of partition (S, Sᶜ).

    cut(S) = cross(S → Sᶜ) + cross(Sᶜ → S)

    This measures the total causal flow disrupted by partitioning at S.

    Args:
        net: The causal network
        S: A subset of nodes

    Returns:
        The bidirectional cut value
    """
    return cross_weight(net, S) + cross_weight(net, set(range(net.n)) - S)


def total_weight(net: CausalNetwork) -> float:
    """Sum of all edge weights in the network.

    Returns:
        Total weight ∑_{i,j} w[i][j]
    """
    return float(np.sum(net.weights))


def compute_phi(net: CausalNetwork) -> Tuple[float, Optional[Set[int]]]:
    """Compute integrated information Φ (minimum non-trivial cut).

    Algorithm: Exhaustive enumeration over all 2^n - 2 non-trivial subsets.
    Time complexity: O(2^n · n²)

    For large n, use approximate algorithms (e.g., spectral methods).

    Args:
        net: The causal network (n ≥ 2)

    Returns:
        Tuple of (Φ value, minimizing partition set)
    """
    assert net.n >= 2, "Need at least 2 nodes for Φ"
    best_cut = float('inf')
    best_S: Optional[Set[int]] = None

    for size in range(1, net.n):
        for combo in combinations(range(net.n), size):
            S = set(combo)
            cv = cut_value(net, S)
            if cv < best_cut:
                best_cut = cv
                best_S = S

    return best_cut, best_S


def is_block_diagonal(net: CausalNetwork, S: Set[int]) -> bool:
    """Check if network is block-diagonal w.r.t. partition (S, Sᶜ).

    Returns True iff no edges cross between S and Sᶜ in either direction.
    """
    S_comp = set(range(net.n)) - S
    for i in S:
        for j in S_comp:
            if net.weights[i, j] != 0 or net.weights[j, i] != 0:
                return False
    return True


def weight_decomposition(net: CausalNetwork, S: Set[int]) -> Dict[str, float]:
    """Decompose total weight into cut + internal components.

    Theorem: totalWeight = cutValue(S) + internal(S) + internal(Sᶜ)

    Returns:
        Dictionary with 'total', 'cut', 'internal_S', 'internal_Sc'
    """
    S_comp = set(range(net.n)) - S
    tw = total_weight(net)
    cv = cut_value(net, S)
    iw_S = sum(net.weights[i, j] for i in S for j in S)
    iw_Sc = sum(net.weights[i, j] for i in S_comp for j in S_comp)

    return {
        'total': tw,
        'cut': cv,
        'internal_S': iw_S,
        'internal_Sc': iw_Sc,
        'decomposition_holds': abs(tw - (cv + iw_S + iw_Sc)) < 1e-10
    }


def find_decomposition(net: CausalNetwork) -> Optional[Set[int]]:
    """Find a non-trivial partition with zero cut (if exists).

    If Φ = 0, such a partition exists by the Disconnected theorem.

    Returns:
        A set S with cutValue(S) = 0, or None if network is integrated.
    """
    for size in range(1, net.n):
        for combo in combinations(range(net.n), size):
            S = set(combo)
            if cut_value(net, S) == 0:
                return S
    return None


def phi_spectrum(net: CausalNetwork) -> List[Tuple[Set[int], float]]:
    """Compute cut values for ALL non-trivial partitions, sorted.

    Returns the full "integration spectrum" — useful for understanding
    the landscape of possible decompositions.

    Returns:
        List of (partition, cut_value) sorted by cut value ascending.
    """
    results: List[Tuple[Set[int], float]] = []
    for size in range(1, net.n):
        for combo in combinations(range(net.n), size):
            S = set(combo)
            results.append((S, cut_value(net, S)))

    results.sort(key=lambda x: x[1])
    return results


if __name__ == "__main__":
    # Example usage
    print("=== Causal Integration Algebra ===\n")

    # Example 1: Complete graph
    G = CausalNetwork.complete(4)
    phi_val, phi_cut = compute_phi(G)
    print(f"Complete K₄: Φ = {phi_val}, cut = {phi_cut}")

    # Example 2: Disconnected
    G2 = CausalNetwork.block_diagonal([
        np.array([[0, 1], [1, 0]]),
        np.array([[0, 2], [2, 0]])
    ])
    phi_val2, _ = compute_phi(G2)
    print(f"Block-diagonal: Φ = {phi_val2}")
    dec = find_decomposition(G2)
    print(f"  Disconnection at: {dec}")

    # Example 3: Integration spectrum
    G3 = CausalNetwork(np.array([
        [0, 3, 1, 0],
        [2, 0, 0, 1],
        [0, 1, 0, 5],
        [1, 0, 4, 0]
    ], dtype=float))
    print(f"\nIntegration spectrum for 4-node network:")
    for S, cv in phi_spectrum(G3)[:5]:
        print(f"  {S}: cut = {cv:.1f}")
