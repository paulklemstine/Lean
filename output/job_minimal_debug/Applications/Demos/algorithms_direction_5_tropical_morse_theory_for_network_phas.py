#!/usr/bin/env python3
"""
Tropical Morse Theory — Core Algorithms

Implements verified algorithms for computing tropical critical values,
edge event types, and Betti number evolution in weighted graph filtrations.

All algorithms correspond to formally verified Lean 4 counterparts in
Catalog/Pythagorean/TropicalBridge/TropicalMorseGraphs.lean.
"""

from typing import List, Tuple, Dict, Optional, Set, NamedTuple
from enum import Enum
from dataclasses import dataclass, field


class EventType(Enum):
    """Edge event type in a graph filtration."""
    MERGE = "merge"   # Bridge: connects two components, β₀ drops by 1
    CYCLE = "cycle"   # Cycle: closes a loop, β₁ rises by 1


@dataclass
class EdgeEvent:
    """Record of a single edge insertion event."""
    step: int
    weight: float
    u: int
    v: int
    event_type: EventType
    betti0_before: int
    betti0_after: int
    betti1_before: int
    betti1_after: int


@dataclass
class FiltrationOutput:
    """Complete output of the tropical Morse filtration algorithm.

    Attributes:
        events: List of edge insertion events in filtration order
        betti0_seq: β₀ at each step (length = n_edges + 1)
        betti1_seq: β₁ at each step (length = n_edges + 1)
        cycle_critical_weights: Weights at which cycle events occur
        merge_critical_weights: Weights at which merge events occur
        persistence_births: Birth times of degree-1 persistence classes
    """
    events: List[EdgeEvent] = field(default_factory=list)
    betti0_seq: List[int] = field(default_factory=list)
    betti1_seq: List[int] = field(default_factory=list)
    cycle_critical_weights: List[float] = field(default_factory=list)
    merge_critical_weights: List[float] = field(default_factory=list)
    persistence_births: List[float] = field(default_factory=list)

    def verify_morse_equalities(self, n_vertices: int) -> Dict[str, bool]:
        """Verify the tropical Morse equalities.

        These correspond to the formally proved theorems:
        - filtration_betti1_eq_cycleCount
        - filtration_rank_eq_mergeCount
        - filtration_merge_plus_cycle
        """
        n_cycle = len(self.cycle_critical_weights)
        n_merge = len(self.merge_critical_weights)
        n_edges = len(self.events)
        final_b0 = self.betti0_seq[-1] if self.betti0_seq else n_vertices
        final_b1 = self.betti1_seq[-1] if self.betti1_seq else 0

        return {
            '|CycleCrit| = β₁': n_cycle == final_b1,
            '|MergeCrit| = |V| - β₀': n_merge == n_vertices - final_b0,
            '|CycleCrit| + |MergeCrit| = |E|': n_cycle + n_merge == n_edges,
            'Euler: β₁ = |E| - |V| + β₀': final_b1 == n_edges - n_vertices + final_b0,
        }

    def tropical_persistent_rank1(self, s: int) -> int:
        """Tropical persistent rank in degree 1 at step s.

        This equals the classical persistent rank β₁(G_s),
        as proved in tropical_persistence_eq_classical.

        Complexity: O(1) with precomputed betti1_seq.
        """
        if s < 0:
            return 0
        if s >= len(self.betti1_seq):
            return self.betti1_seq[-1] if self.betti1_seq else 0
        return self.betti1_seq[s]


class UnionFind:
    """Weighted Union-Find with path compression and union by rank.

    Time complexity: O(α(n)) amortized per operation,
    where α is the inverse Ackermann function.

    Space complexity: O(n).
    """

    def __init__(self, n: int):
        self.parent = list(range(n))
        self.rank = [0] * n
        self.num_components = n

    def find(self, x: int) -> int:
        """Find root with path compression. Amortized O(α(n))."""
        while self.parent[x] != x:
            self.parent[x] = self.parent[self.parent[x]]  # Path halving
            x = self.parent[x]
        return x

    def union(self, x: int, y: int) -> bool:
        """Union by rank. Returns True if merge occurred. Amortized O(α(n))."""
        rx, ry = self.find(x), self.find(y)
        if rx == ry:
            return False
        if self.rank[rx] < self.rank[ry]:
            rx, ry = ry, rx
        self.parent[ry] = rx
        if self.rank[rx] == self.rank[ry]:
            self.rank[rx] += 1
        self.num_components -= 1
        return True

    def connected(self, x: int, y: int) -> bool:
        """Check if x and y are in the same component. Amortized O(α(n))."""
        return self.find(x) == self.find(y)


def compute_tropical_filtration(
    n_vertices: int,
    edges: List[Tuple[float, int, int]]
) -> FiltrationOutput:
    """Compute the complete tropical Morse filtration of a weighted graph.

    This is the main algorithm, corresponding to `computeFiltration` in the
    Lean formalization. It sorts edges by weight and processes them in order,
    classifying each as a merge or cycle event.

    Args:
        n_vertices: Number of vertices (labeled 0..n-1)
        edges: List of (weight, u, v) tuples representing weighted edges

    Returns:
        FiltrationOutput with complete Morse data

    Complexity:
        Time: O(|E| log |E| + |E| · α(|V|)) ≈ O(|E| log |E|)
        Space: O(|V| + |E|)

    Algorithm:
        1. Sort edges by weight              — O(|E| log |E|)
        2. Initialize Union-Find on V        — O(|V|)
        3. For each edge in sorted order:    — O(|E| · α(|V|))
           a. Find(u), Find(v)
           b. If same component → CYCLE event, β₁ += 1
           c. If different → MERGE event, Union(u,v), β₀ -= 1
        4. Record event type, Betti numbers, critical weights
    """
    sorted_edges = sorted(edges, key=lambda e: e[0])

    uf = UnionFind(n_vertices)
    output = FiltrationOutput()
    output.betti0_seq = [n_vertices]
    output.betti1_seq = [0]

    for idx, (w, u, v) in enumerate(sorted_edges):
        b0_before = output.betti0_seq[-1]
        b1_before = output.betti1_seq[-1]

        if uf.connected(u, v):
            # Cycle event: endpoints already in same component
            event_type = EventType.CYCLE
            b0_after = b0_before
            b1_after = b1_before + 1
            output.cycle_critical_weights.append(w)
            output.persistence_births.append(w)
        else:
            # Merge event: connecting two components
            event_type = EventType.MERGE
            uf.union(u, v)
            b0_after = b0_before - 1
            b1_after = b1_before
            output.merge_critical_weights.append(w)

        event = EdgeEvent(
            step=idx, weight=w, u=u, v=v,
            event_type=event_type,
            betti0_before=b0_before, betti0_after=b0_after,
            betti1_before=b1_before, betti1_after=b1_after,
        )
        output.events.append(event)
        output.betti0_seq.append(b0_after)
        output.betti1_seq.append(b1_after)

    return output


def compute_threshold_betti(
    n_vertices: int,
    edges: List[Tuple[float, int, int]],
    threshold: float
) -> Tuple[int, int]:
    """Compute Betti numbers of the threshold subgraph at level t.

    The threshold subgraph G_t contains all edges with weight ≤ t.

    Args:
        n_vertices: Number of vertices
        edges: List of (weight, u, v) tuples
        threshold: Weight threshold t

    Returns:
        (β₀, β₁) of the threshold subgraph

    Complexity: O(|E| · α(|V|))
    """
    uf = UnionFind(n_vertices)
    edge_count = 0

    for w, u, v in edges:
        if w <= threshold:
            uf.union(u, v)
            edge_count += 1

    beta0 = uf.num_components
    beta1 = edge_count + beta0 - n_vertices
    return beta0, beta1


def compute_persistence_barcode(
    n_vertices: int,
    edges: List[Tuple[float, int, int]]
) -> List[Tuple[float, Optional[float], int]]:
    """Compute the persistence barcode of the graph filtration.

    For graph filtrations in degree 1, all bars are of the form [birth, ∞):
    cycle classes are born when a cycle-closing edge is inserted and never die.

    In degree 0, bars are [0, death) for merged components and [0, ∞) for
    the final connected components.

    Returns:
        List of (birth, death, degree) tuples.
        death=None means the bar extends to infinity.
    """
    output = compute_tropical_filtration(n_vertices, edges)

    barcode = []

    # Degree 0 bars: components that merge
    # Each merge event kills one component born at time 0
    for w in output.merge_critical_weights:
        barcode.append((0.0, w, 0))

    # Surviving components in degree 0
    n_surviving = output.betti0_seq[-1]
    for _ in range(n_surviving):
        barcode.append((0.0, None, 0))

    # Degree 1 bars: each cycle event creates a class that lives forever
    for w in output.cycle_critical_weights:
        barcode.append((w, None, 1))

    return barcode


if __name__ == "__main__":
    import random

    print("Tropical Morse Theory — Algorithm Demo")
    print("=" * 50)

    # Example: K₄ with random weights
    random.seed(42)
    n = 4
    edges = []
    for i in range(n):
        for j in range(i + 1, n):
            edges.append((random.random(), i, j))

    print(f"\nGraph: K₄ with {len(edges)} edges")
    output = compute_tropical_filtration(n, edges)

    print("\nFiltration Events:")
    for e in output.events:
        print(f"  Step {e.step}: edge ({e.u},{e.v}) w={e.weight:.4f} "
              f"→ {e.event_type.value} "
              f"β₀: {e.betti0_before}→{e.betti0_after}, "
              f"β₁: {e.betti1_before}→{e.betti1_after}")

    print("\nMorse Equalities:")
    for name, ok in output.verify_morse_equalities(n).items():
        print(f"  {'✓' if ok else '✗'} {name}")

    print("\nPersistence Barcode:")
    barcode = compute_persistence_barcode(n, edges)
    for birth, death, deg in sorted(barcode, key=lambda x: (x[2], x[0])):
        death_str = f"{death:.4f}" if death is not None else "∞"
        print(f"  H_{deg}: [{birth:.4f}, {death_str})")

    print("\nTropical Persistent Rank₁:")
    for s in range(len(output.betti1_seq)):
        print(f"  Step {s}: tropical = classical = {output.tropical_persistent_rank1(s)}")
