#!/usr/bin/env python3
"""
Integrated Information Theory — Core Algorithms

Type-hinted implementations of IIT computational primitives,
corresponding to the Lean 4 formalization in Novelty/IIT/.
"""

from typing import Set, Tuple, List, Optional, Dict, FrozenSet
import itertools
from dataclasses import dataclass, field


# ============================================================
# Type Definitions
# ============================================================

Edge = Tuple[int, int]
Cut = Tuple[bool, ...]  # Assignment of nodes to {True, False}


@dataclass(frozen=True)
class CausalGraph:
    """A directed graph representing a causal system.

    Corresponds to `IIT.CausalGraph n` in Lean.
    """
    n: int
    edges: FrozenSet[Edge]

    @classmethod
    def from_edges(cls, n: int, edges: Set[Edge]) -> 'CausalGraph':
        return cls(n=n, edges=frozenset(edges))

    @classmethod
    def empty(cls, n: int) -> 'CausalGraph':
        """The empty graph (no edges). Corresponds to `IIT.empty n`."""
        return cls(n=n, edges=frozenset())

    @classmethod
    def complete(cls, n: int) -> 'CausalGraph':
        """Complete directed graph. Corresponds to `IIT.completeCG n`."""
        return cls(n=n, edges=frozenset((i, j) for i in range(n) for j in range(n)))

    def complement(self) -> 'CausalGraph':
        """Complement graph. Corresponds to `IIT.complement`."""
        all_edges = frozenset((i, j) for i in range(self.n) for j in range(self.n))
        return CausalGraph(n=self.n, edges=all_edges - self.edges)

    def is_subgraph_of(self, other: 'CausalGraph') -> bool:
        """Check if self is a subgraph of other."""
        return self.n == other.n and self.edges <= other.edges

    def add_edge(self, e: Edge) -> 'CausalGraph':
        """Add a single edge."""
        return CausalGraph(n=self.n, edges=self.edges | {e})


@dataclass(frozen=True)
class Subsystem:
    """A subsystem with associated integration value.

    Corresponds to `IIT.Subsystem n`.
    """
    nodes: FrozenSet[int]
    phi_val: int

    def overlaps(self, other: 'Subsystem') -> bool:
        """Check if two subsystems share nodes."""
        return bool(self.nodes & other.nodes)


# ============================================================
# Algorithm 1: Cut Value Computation
# ============================================================

def cut_value(graph: CausalGraph, cut: Cut) -> int:
    """Count edges crossing a cut.

    Corresponds to `IIT.cutValue`.

    Time complexity: O(|E|)
    Space complexity: O(1)
    """
    return sum(1 for (i, j) in graph.edges if cut[i] != cut[j])


def is_nontrivial(cut: Cut) -> bool:
    """Check if a cut is non-trivial (both sides non-empty).

    Corresponds to `IIT.Cut.nontrivial`.
    """
    return any(cut) and not all(cut)


# ============================================================
# Algorithm 2: Phi Computation (Exact, Exponential)
# ============================================================

def enumerate_nontrivial_cuts(n: int) -> List[Cut]:
    """Enumerate all non-trivial cuts on n nodes.

    Corresponds to `IIT.ntCuts`.

    Time complexity: O(2^n)
    Space complexity: O(2^n)
    """
    return [c for c in itertools.product([True, False], repeat=n)
            if is_nontrivial(c)]


def compute_phi(graph: CausalGraph) -> int:
    """Compute integrated information Phi exactly.

    Corresponds to `IIT.phi`.

    Pseudocode:
        Phi(G) = min over all non-trivial cuts c of cut_value(G, c)

    Time complexity: O(2^n * |E|)
    Space complexity: O(2^n)

    Note: This is NP-hard in general (graph min-cut for directed graphs).
    For small n, exhaustive enumeration is tractable.
    """
    if graph.n < 2:
        raise ValueError("Phi requires n >= 2")

    cuts = enumerate_nontrivial_cuts(graph.n)
    return min(cut_value(graph, c) for c in cuts)


# ============================================================
# Algorithm 3: Disconnection Detection
# ============================================================

def is_disconnected(graph: CausalGraph) -> bool:
    """Check if graph has a zero-value non-trivial cut.

    Corresponds to `IIT.CausalGraph.disconnected`.

    By phi_eq_zero_iff_disconnected: returns True iff Phi = 0.
    """
    for cut in enumerate_nontrivial_cuts(graph.n):
        if cut_value(graph, cut) == 0:
            return True
    return False


# ============================================================
# Algorithm 4: Disjoint Union
# ============================================================

def disjoint_union(g1: CausalGraph, g2: CausalGraph) -> CausalGraph:
    """Construct the disjoint union of two causal graphs.

    Corresponds to `IIT.djUnion`.

    Nodes of g2 are shifted by g1.n.
    """
    shifted_edges = frozenset((i + g1.n, j + g1.n) for (i, j) in g2.edges)
    return CausalGraph(n=g1.n + g2.n, edges=g1.edges | shifted_edges)


# ============================================================
# Algorithm 5: Exclusion Postulate
# ============================================================

def find_maximal_subsystem(
    systems: List[Subsystem],
    target: Subsystem
) -> Optional[Subsystem]:
    """Find the subsystem with maximum Phi among those overlapping target.

    Implements the exclusion postulate search:
    returns the unique maximally-integrated overlapping subsystem.
    """
    overlapping = [s for s in systems if s.overlaps(target)]
    if not overlapping:
        return None
    return max(overlapping, key=lambda s: s.phi_val)


def verify_exclusion(systems: List[Subsystem]) -> Dict[str, any]:
    """Verify the exclusion postulate: overlapping maximal subsystems
    have equal Phi values.

    Returns a report of findings.
    """
    results: Dict[str, any] = {"violations": [], "verified_pairs": 0}

    for i, s1 in enumerate(systems):
        for j, s2 in enumerate(systems):
            if i >= j:
                continue
            if not s1.overlaps(s2):
                continue

            # Check if both are maximal among their overlapping neighbors
            is_max_1 = all(t.phi_val <= s1.phi_val
                          for t in systems if t.overlaps(s1))
            is_max_2 = all(t.phi_val <= s2.phi_val
                          for t in systems if t.overlaps(s2))

            if is_max_1 and is_max_2:
                results["verified_pairs"] += 1
                if s1.phi_val != s2.phi_val:
                    results["violations"].append((s1, s2))

    return results


# ============================================================
# Algorithm 6: Phi Per Node (Normalized Integration)
# ============================================================

def phi_per_node(graph: CausalGraph) -> float:
    """Compute normalized integration: Phi / n.

    Corresponds to `IIT.phiPerNode`.
    """
    return compute_phi(graph) / graph.n


# ============================================================
# Algorithm 7: Integration Landscape
# ============================================================

def integration_landscape(n: int, max_samples: int = 1000) -> Dict[int, int]:
    """Survey the distribution of Phi values across graphs on n nodes.

    Returns a histogram: phi_value -> count.
    """
    possible_edges = [(i, j) for i in range(n) for j in range(n) if i != j]
    histogram: Dict[int, int] = {}

    count = 0
    for num_edges in range(len(possible_edges) + 1):
        for edge_combo in itertools.combinations(possible_edges, num_edges):
            if count >= max_samples:
                break
            g = CausalGraph.from_edges(n, set(edge_combo))
            p = compute_phi(g)
            histogram[p] = histogram.get(p, 0) + 1
            count += 1
        if count >= max_samples:
            break

    return histogram


if __name__ == "__main__":
    # Quick test
    g = CausalGraph.from_edges(3, {(0, 1), (1, 2), (2, 0)})
    print(f"Triangle: Phi = {compute_phi(g)}")
    print(f"Disconnected: {is_disconnected(g)}")
    print(f"Phi per node: {phi_per_node(g):.2f}")

    g_empty = CausalGraph.empty(3)
    print(f"\nEmpty: Phi = {compute_phi(g_empty)}")
    print(f"Disconnected: {is_disconnected(g_empty)}")

    g1 = CausalGraph.from_edges(2, {(0, 1), (1, 0)})
    g2 = CausalGraph.from_edges(2, {(0, 1)})
    gu = disjoint_union(g1, g2)
    print(f"\nDisjoint union: Phi = {compute_phi(gu)}")
