#!/usr/bin/env python3
"""
Integrated Information Theory (IIT) — Algorithms

Type-hinted implementations of:
1. Brute-force Φ computation
2. MIP (Minimum Information Partition) search
3. Causal system construction utilities
4. Monotonicity verification
5. Spectral bound estimation (Cheeger-based)
"""

from typing import List, Set, Tuple, Optional
from itertools import combinations
import math


class CausalSystem:
    """A causal system with finite state space and Boolean adjacency."""

    def __init__(self, n: int, adj: List[List[bool]], transition: List[int]):
        """
        Args:
            n: Number of states
            adj: Adjacency matrix (adj[i][j] = True iff i causes j)
            transition: Transition function (transition[i] = next state of i)
        """
        self.n = n
        self.adj = adj
        self.transition = transition
        # Verify coherence
        for s in range(n):
            assert adj[s][transition[s]], f"Transition {s}->{transition[s]} not in adjacency"

    def cut_size(self, subset: Set[int]) -> int:
        """Compute the cut size of a partition given by subset A."""
        complement: Set[int] = set(range(self.n)) - subset
        forward: int = sum(1 for s in subset for t in complement if self.adj[s][t])
        backward: int = sum(1 for s in complement for t in subset if self.adj[s][t])
        return forward + backward

    def nontrivial_subsets(self) -> List[Set[int]]:
        """Generate all non-trivial subsets."""
        result: List[Set[int]] = []
        for size in range(1, self.n):
            for combo in combinations(range(self.n), size):
                result.append(set(combo))
        return result

    def phi(self) -> int:
        """Compute Φ = minimum cut over all non-trivial subsets."""
        subsets: List[Set[int]] = self.nontrivial_subsets()
        if not subsets:
            return 0
        return min(self.cut_size(s) for s in subsets)

    def mip(self) -> Optional[Set[int]]:
        """Find the Minimum Information Partition."""
        subsets: List[Set[int]] = self.nontrivial_subsets()
        if not subsets:
            return None
        return min(subsets, key=lambda s: self.cut_size(s))

    def is_causally_connected(self) -> bool:
        """Check causal connectivity."""
        return all(self.cut_size(s) > 0 for s in self.nontrivial_subsets())

    def is_extension_of(self, other: 'CausalSystem') -> bool:
        """Check if self extends other (has all edges of other)."""
        assert self.n == other.n
        return all(
            not other.adj[i][j] or self.adj[i][j]
            for i in range(self.n) for j in range(self.n)
        )


def verify_monotonicity(cs1: CausalSystem, cs2: CausalSystem) -> bool:
    """Verify that if cs2 extends cs1, then phi(cs1) <= phi(cs2)."""
    if not cs2.is_extension_of(cs1):
        return True  # vacuously true
    return cs1.phi() <= cs2.phi()


def verify_cut_symmetry(cs: CausalSystem) -> bool:
    """Verify cut symmetry: cutSize(A) = cutSize(complement(A)) for all A."""
    for s in cs.nontrivial_subsets():
        comp: Set[int] = set(range(cs.n)) - s
        if cs.cut_size(s) != cs.cut_size(comp):
            return False
    return True


def verify_fundamental_theorem(cs: CausalSystem) -> bool:
    """Verify Φ > 0 ⟺ causally connected."""
    return (cs.phi() > 0) == cs.is_causally_connected()


def estimate_cheeger_constant(cs: CausalSystem) -> float:
    """Estimate the Cheeger constant h(G) = min cutSize(A) / min(|A|, |S\A|)."""
    subsets: List[Set[int]] = cs.nontrivial_subsets()
    if not subsets:
        return 0.0
    return min(
        cs.cut_size(s) / min(len(s), cs.n - len(s))
        for s in subsets
    )


def build_ring(n: int) -> CausalSystem:
    """Build a ring causal system."""
    adj: List[List[bool]] = [[False] * n for _ in range(n)]
    transition: List[int] = [(i + 1) % n for i in range(n)]
    for i in range(n):
        adj[i][(i + 1) % n] = True
        adj[(i + 1) % n][i] = True
    return CausalSystem(n, adj, transition)


def build_complete(n: int) -> CausalSystem:
    """Build a complete causal system."""
    adj: List[List[bool]] = [[True] * n for _ in range(n)]
    transition: List[int] = [(i + 1) % n for i in range(n)]
    return CausalSystem(n, adj, transition)


def build_path(n: int) -> CausalSystem:
    """Build a path causal system (not causally connected for n >= 3)."""
    adj: List[List[bool]] = [[False] * n for _ in range(n)]
    transition: List[int] = [min(i + 1, n - 1) for i in range(n)]
    for i in range(n - 1):
        adj[i][i + 1] = True
        adj[i + 1][i] = True
    # Self-loop for last node
    adj[n - 1][n - 1] = True
    return CausalSystem(n, adj, transition)


def build_barbell(k: int) -> CausalSystem:
    """Build a barbell: two k-cliques connected by a single bridge."""
    n: int = 2 * k
    adj: List[List[bool]] = [[False] * n for _ in range(n)]
    transition: List[int] = [(i + 1) % n for i in range(n)]

    # Clique 1
    for i in range(k):
        for j in range(k):
            adj[i][j] = True

    # Clique 2
    for i in range(k, n):
        for j in range(k, n):
            adj[i][j] = True

    # Bridge
    adj[k - 1][k] = True
    adj[k][k - 1] = True

    return CausalSystem(n, adj, transition)


if __name__ == "__main__":
    print("=== Algorithm Verification ===\n")

    for n in [3, 4, 5, 6]:
        ring = build_ring(n)
        complete = build_complete(n)
        barbell = build_barbell(n // 2) if n >= 4 and n % 2 == 0 else None

        print(f"Ring({n}): Φ={ring.phi()}, connected={ring.is_causally_connected()}, "
              f"fundamental_thm={verify_fundamental_theorem(ring)}, "
              f"cut_sym={verify_cut_symmetry(ring)}")

        print(f"Complete({n}): Φ={complete.phi()}, connected={complete.is_causally_connected()}, "
              f"Cheeger={estimate_cheeger_constant(complete):.2f}")

        if barbell:
            print(f"Barbell({n}): Φ={barbell.phi()}, MIP={barbell.mip()}, "
                  f"Cheeger={estimate_cheeger_constant(barbell):.2f}")

        # Verify monotonicity: ring ⊆ complete
        print(f"Monotonicity (ring ⊆ complete): {verify_monotonicity(ring, complete)}")
        print()
