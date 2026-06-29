#!/usr/bin/env python3
"""
Tropical Barcode Decoder — Core Algorithms

Implements the algorithmic components of tropical-topological decoding theory:
1. Tropical Morse Barcode computation via Kruskal filtration
2. Edge vulnerability profile construction
3. Barcode-weighted scoring function
4. Free-energy functional for variational decoding
5. Logical corridor identification

All algorithms have explicit complexity analysis in docstrings.
"""

from typing import Dict, List, Set, Tuple, Optional, NamedTuple
from collections import defaultdict
import heapq


# ─── Data Structures ─────────────────────────────────────────────────────────

class BarcodeInterval(NamedTuple):
    """A persistence interval [birth, death] from a tropical Morse filtration."""
    birth: float
    death: float

    @property
    def persistence(self) -> float:
        """Lifetime of the interval: death - birth ≥ 0."""
        return self.death - self.birth

    @property
    def is_valid(self) -> bool:
        """Check birth ≤ death."""
        return self.birth <= self.death


class MorseEvent(NamedTuple):
    """A critical event in the weight filtration."""
    value: float
    event_type: str  # 'merge' or 'cycle'
    edge: Tuple[int, int]


class UnionFind:
    """
    Weighted Union-Find with path compression and union by rank.

    Time complexity:
        - find: O(α(n)) amortized (inverse Ackermann)
        - union: O(α(n)) amortized
    Space: O(n)
    """

    def __init__(self, elements):
        self.parent = {x: x for x in elements}
        self.rank = {x: 0 for x in elements}
        self.size = {x: 1 for x in elements}

    def find(self, x: int) -> int:
        """Find representative with path compression."""
        root = x
        while self.parent[root] != root:
            root = self.parent[root]
        while self.parent[x] != root:
            self.parent[x], x = root, self.parent[x]
        return root

    def union(self, x: int, y: int) -> bool:
        """Union by rank. Returns True if x and y were in different components."""
        rx, ry = self.find(x), self.find(y)
        if rx == ry:
            return False
        if self.rank[rx] < self.rank[ry]:
            rx, ry = ry, rx
        self.parent[ry] = rx
        self.size[rx] += self.size[ry]
        if self.rank[rx] == self.rank[ry]:
            self.rank[rx] += 1
        return True

    def connected(self, x: int, y: int) -> bool:
        """Check if x and y are in the same component."""
        return self.find(x) == self.find(y)


# ─── Algorithm 1: Tropical Morse Barcode ─────────────────────────────────────

def compute_tropical_morse_barcode(
    nodes: List[int],
    edges: List[Tuple[int, int]],
    weights: Dict[Tuple[int, int], float]
) -> Tuple[List[MorseEvent], Dict[Tuple[int, int], List[BarcodeInterval]]]:
    """
    Compute the tropical Morse barcode via Kruskal-style edge filtration.

    Algorithm:
        1. Sort edges by weight (ascending).
        2. Process edges in order using Union-Find.
        3. If an edge merges two components → merge event.
        4. If an edge connects within a component → cycle-death event.
        5. Record barcode intervals for cycle events.

    Pseudocode:
        SORT edges by weight
        INIT Union-Find on nodes
        FOR each edge (u,v) with weight w:
            IF find(u) ≠ find(v):
                RECORD merge event at value w
                UNION(u, v)
            ELSE:
                RECORD cycle-death event at value w
                ADD interval [0, w] to edge (u,v)
        RETURN events, edge_intervals

    Time complexity: O(m log m + m α(n)) where m = |edges|, n = |nodes|
    Space complexity: O(n + m)

    Args:
        nodes: List of node indices.
        edges: List of (u, v) edge pairs.
        weights: Dict mapping edges to their weights.

    Returns:
        events: Ordered list of MorseEvent objects.
        edge_intervals: Dict mapping each edge to its barcode intervals.
    """
    # Sort edges by weight
    sorted_edges = sorted(edges, key=lambda e: weights.get(e, weights.get((e[1], e[0]), 1.0)))

    uf = UnionFind(nodes)
    events: List[MorseEvent] = []
    edge_intervals: Dict[Tuple[int, int], List[BarcodeInterval]] = defaultdict(list)

    for edge in sorted_edges:
        u, v = edge
        w = weights.get(edge, weights.get((v, u), 1.0))

        if not uf.connected(u, v):
            events.append(MorseEvent(value=w, event_type='merge', edge=edge))
            uf.union(u, v)
        else:
            events.append(MorseEvent(value=w, event_type='cycle', edge=edge))
            edge_intervals[edge].append(BarcodeInterval(birth=0.0, death=w))

    return events, dict(edge_intervals)


# ─── Algorithm 2: Edge Vulnerability Profile ─────────────────────────────────

def compute_edge_vulnerability(
    edges: List[Tuple[int, int]],
    edge_intervals: Dict[Tuple[int, int], List[BarcodeInterval]],
    propagation_factor: float = 0.5
) -> Dict[Tuple[int, int], float]:
    """
    Compute the vulnerability profile for each edge.

    Algorithm:
        1. For each edge, sum persistence of directly assigned intervals.
        2. Optionally propagate vulnerability to adjacent edges with decay.

    Pseudocode:
        FOR each edge e:
            V(e) = Σ_{I ∈ B(e)} persistence(I)
        FOR each edge e with V(e) > 0:
            FOR each adjacent edge e':
                V(e') += propagation_factor × V(e)
        RETURN V

    Time complexity: O(m × max_degree) where m = |edges|
    Space complexity: O(m)

    The vulnerability V(e) satisfies:
        - V(e) ≥ 0 (nonnegativity, proved in Lean as edgeVulnerability_nonneg)
        - If B₁(e) ⊆ B₂(e) then V₁(e) ≤ V₂(e) (monotonicity, edgeVulnerability_mono)
    """
    # Direct vulnerability
    vulnerability = {}
    for e in edges:
        intervals = edge_intervals.get(e, [])
        vulnerability[e] = sum(I.persistence for I in intervals)

    # Propagation to adjacent edges
    if propagation_factor > 0:
        adj_vuln = defaultdict(float)
        for e in edges:
            if vulnerability[e] > 0:
                u, v = e
                for e2 in edges:
                    if e2 != e and (u in e2 or v in e2):
                        adj_vuln[e2] += propagation_factor * vulnerability[e]

        for e in edges:
            vulnerability[e] += adj_vuln.get(e, 0.0)

    return vulnerability


# ─── Algorithm 3: Barcode-Weighted Scoring ────────────────────────────────────

def barcode_weight(
    correction: Set[Tuple[int, int]],
    base_weights: Dict[Tuple[int, int], float],
    vulnerability: Dict[Tuple[int, int], float],
    lam: float = 1.0
) -> float:
    """
    Compute the barcode-weighted cost of a correction chain.

    W(C) = Σ_{e ∈ C} base_weight(e) + λ × Σ_{e ∈ C} vulnerability(e)

    This is the free-energy functional F(C) = E(C) + λ·Φ(C) from the paper.

    Properties (proved in Lean):
        - W(C) ≥ 0 when base weights and vulnerabilities are nonneg (barcodeWeight_nonneg)
        - If base(c₁) ≤ base(c₂) and vuln(c₁) < vuln(c₂) then W(c₁) < W(c₂)
          (barcodeWeight_strict_sep)
        - Invariant under barcode refinement preserving total persistence
          (pathWeight_refinement_invariant)

    Time complexity: O(|C|)
    """
    base = sum(base_weights.get(e, 1.0) for e in correction)
    vuln = sum(vulnerability.get(e, 0.0) for e in correction)
    return base + lam * vuln


# ─── Algorithm 4: Free-Energy Functional ─────────────────────────────────────

def free_energy(
    energy: float,
    entropy_like: float,
    lam: float
) -> float:
    """
    Discrete free-energy functional: F = E + λ·Φ.

    Connects decoding to statistical mechanics:
    - E: base chain weight (energy)
    - Φ: barcode vulnerability (entropy-like penalty)
    - λ: coupling parameter (temperature inverse)

    Properties (proved in Lean):
        - F ≥ 0 when E ≥ 0, Φ ≥ 0, λ ≥ 0 (free_energy_nonneg)
        - If E(c₁) < E(c₂) and Φ(c₁) ≤ Φ(c₂) then F(c₁) < F(c₂)
          for all λ ≥ 0 (zero_temperature_selection)
        - F is monotone in λ when Φ ≥ 0 (free_energy_lambda_mono)
    """
    return energy + lam * entropy_like


# ─── Algorithm 5: Logical Corridor Detection ─────────────────────────────────

def identify_logical_corridors(
    edges: List[Tuple[int, int]],
    vulnerability: Dict[Tuple[int, int], float],
    tau: float
) -> Set[Tuple[int, int]]:
    """
    Identify edges in the logical corridor at threshold τ.

    An edge e is in the corridor if vulnerability(e) ≥ τ.

    Properties (proved in Lean):
        - Corridor is antitone in τ: lower threshold → larger corridor
          (logicalCorridor_antitone)
        - At τ=0, contains all edges with positive vulnerability
          (logicalCorridor_zero_pos)
        - Corridor grows under barcode enrichment
          (logicalCorridor_mono_barcode)

    Time complexity: O(m)
    """
    return {e for e in edges if vulnerability.get(e, 0.0) >= tau}


# ─── Algorithm 6: Tropical Barcode Decoder ────────────────────────────────────

def tropical_barcode_decode(
    nodes: List[int],
    edges: List[Tuple[int, int]],
    base_weights: Dict[Tuple[int, int], float],
    vulnerability: Dict[Tuple[int, int], float],
    syndrome_nodes: Set[int],
    lam: float = 1.0
) -> Set[Tuple[int, int]]:
    """
    Full tropical barcode decoder.

    Input:
        - Graph (nodes, edges) with base weights
        - Vulnerability profile from tropical Morse barcode
        - Syndrome nodes (defects to be paired)
        - Penalty parameter λ

    Output:
        - Correction chain minimizing barcode-weighted cost

    Algorithm:
        1. Compute barcode-weighted edge costs: w(e) = base(e) + λ·V(e)
        2. For each pair of syndrome nodes, compute shortest path under w
        3. Greedily match syndrome nodes by nearest-neighbor pairing
        4. Return union of correction paths

    Pseudocode:
        COMPUTE edge_costs[e] = base[e] + λ × V[e]
        WHILE unmatched syndrome nodes exist:
            FIND nearest pair (s₁, s₂) under edge_costs
            PATH ← shortest path from s₁ to s₂
            ADD PATH to correction
            MARK s₁, s₂ as matched
        RETURN correction

    Time complexity: O(k × (m + n log n)) where k = |syndrome|
    Space complexity: O(n + m)
    """
    if not syndrome_nodes:
        return set()

    # Build adjacency with barcode-weighted costs
    adj: Dict[int, List[Tuple[int, float, Tuple[int, int]]]] = defaultdict(list)
    for e in edges:
        u, v = e
        cost = base_weights.get(e, 1.0) + lam * vulnerability.get(e, 0.0)
        adj[u].append((v, cost, e))
        adj[v].append((u, cost, e))

    def shortest_path(src: int, targets: Set[int]) -> Optional[Tuple[int, float, List[Tuple[int, int]]]]:
        """Dijkstra from src to nearest target."""
        dist = {src: 0.0}
        prev: Dict[int, Tuple[int, Tuple[int, int]]] = {}
        pq = [(0.0, src)]

        while pq:
            d, u = heapq.heappop(pq)
            if d > dist.get(u, float('inf')):
                continue
            if u in targets and u != src:
                # Trace path
                path = []
                cur = u
                while cur != src:
                    p, e = prev[cur]
                    path.append(e)
                    cur = p
                return u, d, path

            for v, cost, e in adj.get(u, []):
                nd = d + cost
                if nd < dist.get(v, float('inf')):
                    dist[v] = nd
                    prev[v] = (u, e)
                    heapq.heappush(pq, (nd, v))

        return None

    # Greedy nearest-neighbor matching
    remaining = set(syndrome_nodes)
    correction: Set[Tuple[int, int]] = set()

    while len(remaining) >= 2:
        best_result = None
        best_src = None
        best_dist = float('inf')

        for s in remaining:
            others = remaining - {s}
            result = shortest_path(s, others)
            if result and result[1] < best_dist:
                best_result = result
                best_src = s
                best_dist = result[1]

        if best_result is None:
            break

        target, _, path = best_result
        correction.update(path)
        remaining.discard(best_src)
        remaining.discard(target)

    return correction


# ─── Example Usage ────────────────────────────────────────────────────────────

if __name__ == "__main__":
    # Example: 3×3 grid graph
    L = 3
    nodes = list(range(L * L))
    edges = []
    for r in range(L):
        for c in range(L):
            idx = r * L + c
            if c + 1 < L:
                edges.append((idx, idx + 1))
            if r + 1 < L:
                edges.append((idx, idx + L))

    weights = {e: 1.0 for e in edges}

    print("=== Tropical Morse Barcode ===")
    events, intervals = compute_tropical_morse_barcode(nodes, edges, weights)
    print(f"Events: {len(events)}")
    print(f"  Merges: {sum(1 for e in events if e.event_type == 'merge')}")
    print(f"  Cycles: {sum(1 for e in events if e.event_type == 'cycle')}")

    print("\n=== Edge Vulnerability ===")
    vuln = compute_edge_vulnerability(edges, intervals)
    for e in sorted(edges):
        v = vuln.get(e, 0.0)
        if v > 0:
            print(f"  Edge {e}: V = {v:.3f}")

    print("\n=== Logical Corridors ===")
    for tau in [0.5, 1.0, 2.0]:
        corridor = identify_logical_corridors(edges, vuln, tau)
        print(f"  τ = {tau}: {len(corridor)} edges in corridor")

    print("\n=== Barcode-Weighted Decoding ===")
    syndrome = {0, 8}  # Example syndrome
    correction = tropical_barcode_decode(nodes, edges, weights, vuln, syndrome, lam=1.0)
    cost = barcode_weight(correction, weights, vuln, lam=1.0)
    print(f"  Syndrome: {syndrome}")
    print(f"  Correction: {correction}")
    print(f"  Barcode weight: {cost:.3f}")
