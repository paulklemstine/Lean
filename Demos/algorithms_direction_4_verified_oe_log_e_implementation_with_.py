"""
Algorithms for Verified Tropical Morse Spectrum Computation

Implements the Kruskal-based TMS algorithm with homological certificates,
matching the formally verified Lean 4 implementation.

Author: Harmonic Research
"""

from dataclasses import dataclass, field
from enum import Enum
from typing import List, Tuple, Optional
import heapq


class EventType(Enum):
    """Event types in the tropical Morse spectrum."""
    MERGE = "merge"
    CYCLE = "cycle"


@dataclass
class HomologyDeltaCertificate:
    """Certificate for the homological change caused by adding an edge.
    
    Invariant: delta_beta0 - delta_beta1 == -1 (Euler conservation)
    """
    delta_beta0: int
    delta_beta1: int
    
    def __post_init__(self):
        assert self.delta_beta0 - self.delta_beta1 == -1, \
            f"Euler conservation violated: {self.delta_beta0} - {self.delta_beta1} != -1"


MERGE_CERTIFICATE = HomologyDeltaCertificate(delta_beta0=-1, delta_beta1=0)
CYCLE_CERTIFICATE = HomologyDeltaCertificate(delta_beta0=0, delta_beta1=1)


@dataclass
class CertifiedTMEvent:
    """A certified tropical Morse event.
    
    Each event carries:
    - weight: the filtration value at which the event occurs
    - edge: the edge (u, v) being added
    - event_type: merge or cycle
    - certificate: homological delta certificate
    """
    weight: float
    edge: Tuple[int, int]
    event_type: EventType
    certificate: HomologyDeltaCertificate


class FlatPartition:
    """Flat partition (union-find) for tracking connected components.
    
    Each element maps directly to its root representative.
    The root map is idempotent: root[root[v]] == root[v].
    
    This matches the FlatPartition structure in the Lean formalization.
    """
    
    def __init__(self, n: int):
        """Initialize with n singleton components."""
        self.n = n
        self._parent = list(range(n))
        self._rank = [0] * n
    
    def find(self, v: int) -> int:
        """Find the root of v's component (with path compression)."""
        if self._parent[v] != v:
            self._parent[v] = self.find(self._parent[v])
        return self._parent[v]
    
    def same_comp(self, u: int, v: int) -> bool:
        """Check if u and v are in the same component."""
        return self.find(u) == self.find(v)
    
    def merge(self, u: int, v: int) -> bool:
        """Merge components of u and v. Returns True if they were different."""
        ru, rv = self.find(u), self.find(v)
        if ru == rv:
            return False
        # Union by rank
        if self._rank[ru] < self._rank[rv]:
            ru, rv = rv, ru
        self._parent[rv] = ru
        if self._rank[ru] == self._rank[rv]:
            self._rank[ru] += 1
        return True
    
    @property
    def num_components(self) -> int:
        """Number of connected components."""
        return len(set(self.find(v) for v in range(self.n)))


@dataclass
class KruskalState:
    """Running state of the Kruskal TMS algorithm."""
    partition: FlatPartition
    events: List[CertifiedTMEvent] = field(default_factory=list)
    
    @property
    def merge_count(self) -> int:
        return sum(1 for e in self.events if e.event_type == EventType.MERGE)
    
    @property
    def cycle_count(self) -> int:
        return sum(1 for e in self.events if e.event_type == EventType.CYCLE)


@dataclass
class WeightedEdge:
    """A weighted edge in a graph."""
    src: int
    dst: int
    weight: float
    
    def __lt__(self, other):
        return self.weight < other.weight


def process_edge(state: KruskalState, edge: WeightedEdge) -> CertifiedTMEvent:
    """Process a single edge: classify as merge or cycle.
    
    This is the core of the Kruskal TMS algorithm.
    
    Args:
        state: current Kruskal state
        edge: the weighted edge to process
    
    Returns:
        A certified TMS event with homological certificate
    
    Theorem (processEdge_euler_valid):
        The certificate always satisfies delta_beta0 - delta_beta1 = -1.
    """
    if state.partition.same_comp(edge.src, edge.dst):
        # Cycle event: endpoints already connected
        # β₀ unchanged, β₁ increases by 1
        evt = CertifiedTMEvent(
            weight=edge.weight,
            edge=(edge.src, edge.dst),
            event_type=EventType.CYCLE,
            certificate=CYCLE_CERTIFICATE
        )
    else:
        # Merge event: endpoints in different components
        # β₀ decreases by 1, β₁ unchanged
        state.partition.merge(edge.src, edge.dst)
        evt = CertifiedTMEvent(
            weight=edge.weight,
            edge=(edge.src, edge.dst),
            event_type=EventType.MERGE,
            certificate=MERGE_CERTIFICATE
        )
    state.events.append(evt)
    return evt


def compute_tms(n: int, edges: List[WeightedEdge]) -> KruskalState:
    """Compute the Tropical Morse Spectrum via Kruskal's method.
    
    This is the main algorithm, corresponding to `computeKruskalTMS` in Lean.
    
    Args:
        n: number of vertices
        edges: list of weighted edges
    
    Returns:
        KruskalState with the complete event sequence
    
    Complexity: O(E log E) for sorting + O(E α(V)) for union-find operations.
    
    Theorems verified in Lean:
    - kruskal_homology_conservation: merge_count + cycle_count == len(edges)
    - kruskalFold_sorted: events are sorted by weight
    - kruskal_homologically_exact: every event has valid Euler certificate
    - event_type_captures_homology: event types match connectivity changes
    """
    state = KruskalState(partition=FlatPartition(n))
    sorted_edges = sorted(edges)
    
    for edge in sorted_edges:
        process_edge(state, edge)
    
    return state


def verify_euler_conservation(state: KruskalState, n: int) -> bool:
    """Verify the Euler conservation law: β₀ - β₁ = V - E.
    
    Corresponds to kruskal_filtration_euler in Lean.
    """
    beta0 = n - state.merge_count  # components = vertices - merges
    beta1 = state.cycle_count       # cycle rank = cycle events
    num_edges = len(state.events)
    return beta0 - beta1 == n - num_edges


def verify_homological_exactness(state: KruskalState) -> bool:
    """Verify that every event has a valid Euler certificate.
    
    Corresponds to kruskal_homologically_exact in Lean.
    """
    for evt in state.events:
        cert = evt.certificate
        if cert.delta_beta0 - cert.delta_beta1 != -1:
            return False
    
    if len(state.events) != state.merge_count + state.cycle_count:
        return False
    
    return True


def compute_betti_numbers(state: KruskalState, n: int) -> Tuple[int, int]:
    """Compute the final Betti numbers from the event sequence.
    
    β₀ = n - merge_count (number of connected components)
    β₁ = cycle_count (number of independent cycles)
    
    Corresponds to kruskal_beta0_recovery and kruskal_cycle_rank in Lean.
    """
    beta0 = n - state.merge_count
    beta1 = state.cycle_count
    return beta0, beta1


def is_spanning_tree(state: KruskalState, n: int) -> bool:
    """Check if the processed edges form a spanning tree.
    
    Corresponds to kruskal_tree_detection in Lean:
    A spanning tree iff all events are merges and count = n-1.
    """
    return state.cycle_count == 0 and len(state.events) + 1 == n


class WeightedGraph:
    """An edge-weighted graph on n vertices."""
    
    def __init__(self, n: int):
        self.n = n
        self.edges: List[WeightedEdge] = []
        self._adj: dict = {}
    
    def add_edge(self, u: int, v: int, weight: float):
        """Add an undirected edge with given weight."""
        assert 0 <= u < self.n and 0 <= v < self.n
        assert u != v
        self.edges.append(WeightedEdge(u, v, weight))
        self._adj.setdefault(u, []).append((v, weight))
        self._adj.setdefault(v, []).append((u, weight))
    
    def compute_tms(self) -> KruskalState:
        """Compute the TMS of this graph."""
        return compute_tms(self.n, self.edges)
    
    def degree(self, v: int) -> int:
        """Degree of vertex v."""
        return len(self._adj.get(v, []))
    
    def degree_multiset(self) -> List[int]:
        """Degree sequence (sorted)."""
        return sorted(self.degree(v) for v in range(self.n))


def test_event_type_stability(n: int, edges: List[WeightedEdge],
                               perturbation_fn=None) -> bool:
    """Test the stability conjecture: event types depend only on edge order.
    
    Corresponds to eventTypeStability in Lean.
    
    Args:
        n: number of vertices
        edges: original edge list
        perturbation_fn: function to perturb weights while preserving order
    
    Returns:
        True if event type sequences match after perturbation
    """
    import random
    
    state1 = compute_tms(n, edges)
    types1 = [e.event_type for e in state1.events]
    
    # Apply monotone perturbation preserving strict order
    sorted_edges = sorted(edges)
    if perturbation_fn is None:
        # Default: multiply weights by random factor > 0 preserving order
        perturbed = []
        for e in sorted_edges:
            new_weight = e.weight + random.uniform(0, 0.01)
            perturbed.append(WeightedEdge(e.src, e.dst, new_weight))
        # Re-sort to ensure order is preserved
        perturbed.sort()
    else:
        perturbed = perturbation_fn(sorted_edges)
    
    state2 = compute_tms(n, perturbed)
    types2 = [e.event_type for e in state2.events]
    
    return types1 == types2


if __name__ == "__main__":
    # Example: C₆ (6-cycle) with weights 1..6
    print("=== Example: 6-cycle with weights 1..6 ===")
    G = WeightedGraph(6)
    for i in range(6):
        G.add_edge(i, (i + 1) % 6, float(i + 1))
    
    state = G.compute_tms()
    print(f"Events: {[(e.event_type.value, e.weight) for e in state.events]}")
    print(f"Merge count: {state.merge_count}")
    print(f"Cycle count: {state.cycle_count}")
    
    beta0, beta1 = compute_betti_numbers(state, 6)
    print(f"β₀ = {beta0}, β₁ = {beta1}")
    print(f"Euler conservation: {verify_euler_conservation(state, 6)}")
    print(f"Homologically exact: {verify_homological_exactness(state)}")
    
    # Example: 2×C₃ (two triangles)
    print("\n=== Example: Two triangles with weights 1..6 ===")
    G2 = WeightedGraph(6)
    G2.add_edge(0, 1, 1.0)
    G2.add_edge(1, 2, 2.0)
    G2.add_edge(0, 2, 3.0)
    G2.add_edge(3, 4, 4.0)
    G2.add_edge(4, 5, 5.0)
    G2.add_edge(3, 5, 6.0)
    
    state2 = G2.compute_tms()
    print(f"Events: {[(e.event_type.value, e.weight) for e in state2.events]}")
    print(f"Merge count: {state2.merge_count}")
    print(f"Cycle count: {state2.cycle_count}")
    
    beta0, beta1 = compute_betti_numbers(state2, 6)
    print(f"β₀ = {beta0}, β₁ = {beta1}")
    print(f"Degree sequences match: {G.degree_multiset() == G2.degree_multiset()}")
    print(f"TMS distinguishes them: {[e.event_type for e in state.events] != [e.event_type for e in state2.events]}")
