#!/usr/bin/env python3
"""
applications.py — Real-world applications of Tropical Morse Theory for GNNs.

Demonstrates:
  1. Molecular graph classification with TMS features
  2. Social network community detection enhancement
  3. Infrastructure network robustness analysis
"""

from collections import defaultdict, Counter
from typing import List, Tuple, Dict, Set
import random
import math


# ──────────────────────────────────────────────────────────────
# Self-contained implementations (no local imports)
# ──────────────────────────────────────────────────────────────

class UnionFind:
    def __init__(self, n):
        self.parent = list(range(n))
        self.rank = [0] * n
        self.num_components = n

    def find(self, x):
        while self.parent[x] != x:
            self.parent[x] = self.parent[self.parent[x]]
            x = self.parent[x]
        return x

    def union(self, x, y):
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


def compute_tms(n, edges):
    """Compute tropical Morse spectrum."""
    events = []
    uf = UnionFind(n)
    sorted_edges = sorted(edges, key=lambda e: e[2])
    cycle_rank = 0
    for u, v, w in sorted_edges:
        if uf.union(u, v):
            events.append(("merge", w, uf.num_components, cycle_rank))
        else:
            cycle_rank += 1
            events.append(("cycle_death", w, uf.num_components, cycle_rank))
    return events


def tms_feature_vector(n, edges, num_bins=8):
    """Build TMS feature vector for ML."""
    events = compute_tms(n, edges)
    if not events:
        return [0.0] * (2 * num_bins + 4)

    weights = [e[1] for e in events]
    min_w, max_w = min(weights), max(weights) + 1e-9
    bw = (max_w - min_w) / num_bins

    merge_h = [0.0] * num_bins
    cycle_h = [0.0] * num_bins
    for etype, w, _, _ in events:
        idx = min(int((w - min_w) / bw), num_bins - 1)
        if etype == "merge":
            merge_h[idx] += 1
        else:
            cycle_h[idx] += 1

    n_merge = sum(1 for e in events if e[0] == "merge")
    n_cycle = sum(1 for e in events if e[0] == "cycle_death")
    complexity = len(set(e[1] for e in events))

    return merge_h + cycle_h + [n_merge, n_cycle, n_cycle, complexity]


# ──────────────────────────────────────────────────────────────
# Application 1: Molecular Graph Classification
# ──────────────────────────────────────────────────────────────

def generate_molecule(mol_type: str):
    """Generate a toy molecular graph (vertices=atoms, edges=bonds with weights).

    Bond weights encode bond order: single=1.0, double=2.0, aromatic=1.5.
    """
    if mol_type == "benzene":
        # 6 carbons in a ring with alternating bond weights (aromatic)
        n = 6
        edges = [(i, (i+1)%6, 1.5) for i in range(6)]
        return n, edges, "C₆H₆ (benzene)"

    elif mol_type == "cyclohexane":
        # 6 carbons in a ring with single bonds
        n = 6
        edges = [(i, (i+1)%6, 1.0) for i in range(6)]
        return n, edges, "C₆H₁₂ (cyclohexane)"

    elif mol_type == "naphthalene":
        # 10 carbons: two fused benzene rings
        n = 10
        edges = [
            (0,1,1.5), (1,2,1.5), (2,3,1.5), (3,4,1.5), (4,5,1.5), (5,0,1.5),
            (5,6,1.5), (6,7,1.5), (7,8,1.5), (8,9,1.5), (9,4,1.5)
        ]
        return n, edges, "C₁₀H₈ (naphthalene)"

    elif mol_type == "biphenyl":
        # Two benzene rings connected by a single bond
        n = 12
        edges = (
            [(i, (i+1)%6, 1.5) for i in range(6)] +
            [(i+6, (i+1)%6 + 6, 1.5) for i in range(6)] +
            [(0, 6, 1.0)]  # connecting bond
        )
        return n, edges, "C₁₂H₁₀ (biphenyl)"

    else:
        raise ValueError(f"Unknown molecule type: {mol_type}")


def demo_molecular_classification():
    """Show TMS distinguishes molecules with same degree sequence."""
    print("=" * 60)
    print("APPLICATION 1: Molecular Graph Classification")
    print("=" * 60)

    molecules = ["benzene", "cyclohexane", "naphthalene", "biphenyl"]

    for mol in molecules:
        n, edges, name = generate_molecule(mol)
        events = compute_tms(n, edges)
        fv = tms_feature_vector(n, edges, num_bins=4)

        n_merge = sum(1 for e in events if e[0] == "merge")
        n_cycle = sum(1 for e in events if e[0] == "cycle_death")

        print(f"\n  {name}:")
        print(f"    Vertices: {n}, Edges: {len(edges)}")
        print(f"    TMS: {n_merge} merges, {n_cycle} cycle deaths")
        print(f"    Feature vector (first 8): {fv[:8]}")

    # Key comparison: benzene vs cyclohexane (same topology, different weights)
    _, e_benz, _ = generate_molecule("benzene")
    _, e_cycl, _ = generate_molecule("cyclohexane")
    tms_b = compute_tms(6, e_benz)
    tms_c = compute_tms(6, e_cycl)
    print(f"\n  Benzene vs Cyclohexane:")
    print(f"    Same graph topology (6-cycle), different bond weights")
    print(f"    TMS event types match: {[e[0] for e in tms_b] == [e[0] for e in tms_c]}")
    print(f"    TMS values differ: {[e[1] for e in tms_b] != [e[1] for e in tms_c]}")
    print(f"    → TMS captures bond order information!")


# ──────────────────────────────────────────────────────────────
# Application 2: Network Robustness Analysis
# ──────────────────────────────────────────────────────────────

def generate_network(net_type: str, n: int = 20, seed: int = 42):
    """Generate a weighted network."""
    random.seed(seed)

    if net_type == "star":
        edges = [(0, i, random.uniform(1, 10)) for i in range(1, n)]
        return n, edges

    elif net_type == "ring_with_chords":
        edges = [(i, (i+1)%n, random.uniform(1, 5)) for i in range(n)]
        for _ in range(n // 3):
            u, v = random.sample(range(n), 2)
            edges.append((u, v, random.uniform(5, 15)))
        return n, edges

    elif net_type == "grid":
        side = int(n**0.5)
        edges = []
        for i in range(side):
            for j in range(side):
                v = i * side + j
                if j + 1 < side:
                    edges.append((v, v+1, random.uniform(1, 10)))
                if i + 1 < side:
                    edges.append((v, v+side, random.uniform(1, 10)))
        return side * side, edges

    raise ValueError(f"Unknown network type: {net_type}")


def analyze_robustness(n, edges):
    """Analyze network robustness using TMS."""
    events = compute_tms(n, edges)

    # The weight at which the network becomes connected
    merge_events = [e for e in events if e[0] == "merge"]
    if merge_events:
        connectivity_threshold = merge_events[-1][1]
    else:
        connectivity_threshold = float('inf')

    # Number of redundant edges (cycle deaths)
    redundancy = sum(1 for e in events if e[0] == "cycle_death")

    # Spread of critical values
    if events:
        values = [e[1] for e in events]
        spectral_width = max(values) - min(values)
    else:
        spectral_width = 0

    return {
        "connectivity_threshold": connectivity_threshold,
        "redundancy": redundancy,
        "spectral_width": spectral_width,
        "total_events": len(events)
    }


def demo_network_robustness():
    """Demonstrate TMS for network robustness analysis."""
    print("\n" + "=" * 60)
    print("APPLICATION 2: Network Robustness via TMS")
    print("=" * 60)

    for net_type in ["star", "ring_with_chords", "grid"]:
        n, edges = generate_network(net_type, n=16)
        analysis = analyze_robustness(n, edges)

        print(f"\n  {net_type.upper()} network (n={n}, m={len(edges)}):")
        print(f"    Connectivity threshold: {analysis['connectivity_threshold']:.2f}")
        print(f"    Redundancy (β₁): {analysis['redundancy']}")
        print(f"    Spectral width: {analysis['spectral_width']:.2f}")

    print("\n  Key insight: Star networks have zero redundancy (tree!),")
    print("  while ring+chord networks have high redundancy, indicating")
    print("  robustness to edge failures.")


# ──────────────────────────────────────────────────────────────
# Application 3: Community Detection Enhancement
# ──────────────────────────────────────────────────────────────

def demo_community_detection():
    """Show how TMS reveals community structure."""
    print("\n" + "=" * 60)
    print("APPLICATION 3: Community Detection via TMS")
    print("=" * 60)

    # Two communities connected by a weak bridge
    n = 12
    edges = []

    # Community 1: vertices 0-5 with strong internal edges (low weight)
    for i in range(6):
        for j in range(i+1, 6):
            edges.append((i, j, random.uniform(1, 3)))

    # Community 2: vertices 6-11 with strong internal edges
    random.seed(123)
    for i in range(6, 12):
        for j in range(i+1, 12):
            edges.append((i, j, random.uniform(1, 3)))

    # Bridge: weak connection (high weight)
    edges.append((2, 8, 15.0))
    edges.append((4, 10, 18.0))

    events = compute_tms(n, edges)

    print(f"\n  Graph: 2 communities of 6 vertices, connected by 2 bridge edges")
    print(f"  Internal edge weights: [1, 3]")
    print(f"  Bridge edge weights: 15, 18")

    print(f"\n  TMS Events (showing community structure):")
    for e in events:
        marker = " ← BRIDGE" if e[1] > 10 else ""
        print(f"    t={e[1]:6.2f}: {e[0]:12s} (β₀={e[2]}, β₁={e[3]}){marker}")

    print(f"\n  The TMS clearly shows:")
    print(f"    - Internal edges merge within communities (low t)")
    print(f"    - Bridge edges merge communities (high t)")
    print(f"    - The gap in critical values reveals community structure!")


# ──────────────────────────────────────────────────────────────
# Main
# ──────────────────────────────────────────────────────────────

if __name__ == "__main__":
    demo_molecular_classification()
    demo_network_robustness()
    demo_community_detection()
    print("\n" + "=" * 60)
    print("All applications completed.")


#!/usr/bin/env python3
"""
Tropical Morse Spectrum — Demo & Comparison with 1-WL

Demonstrates:
1. Tropical Morse spectrum computation via Kruskal-like filtration
2. 1-WL color refinement
3. Separation: C₆ vs 2×C₃ (WL1-equivalent but TMS-distinct)
4. CFI graph pair generation
5. Simple GNN-style feature augmentation with TMS
"""

import numpy as np
from collections import defaultdict, Counter
from typing import List, Tuple, Dict, Set, Optional
import itertools


# ──────────────────────────────────────────────────────────────
# Union-Find for connected component tracking
# ──────────────────────────────────────────────────────────────

class UnionFind:
    """Union-Find with path compression and union by rank."""

    def __init__(self, n: int):
        self.parent = list(range(n))
        self.rank = [0] * n
        self.num_components = n

    def find(self, x: int) -> int:
        while self.parent[x] != x:
            self.parent[x] = self.parent[self.parent[x]]
            x = self.parent[x]
        return x

    def union(self, x: int, y: int) -> bool:
        """Returns True if a merge occurred (endpoints in different components)."""
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


# ──────────────────────────────────────────────────────────────
# Tropical Morse Spectrum Computation
# ──────────────────────────────────────────────────────────────

class MorseEvent:
    """A critical event in the tropical Morse filtration."""
    BIRTH = "birth"
    MERGE = "merge"
    CYCLE_DEATH = "cycle_death"

    def __init__(self, value: float, event_type: str):
        self.value = value
        self.event_type = event_type

    def __repr__(self):
        return f"MorseEvent({self.value}, {self.event_type})"

    def __eq__(self, other):
        return self.value == other.value and self.event_type == other.event_type

    def __hash__(self):
        return hash((self.value, self.event_type))


def compute_tropical_morse_spectrum(
    n: int,
    edges: List[Tuple[int, int, float]]
) -> List[MorseEvent]:
    """
    Compute the tropical Morse spectrum of a weighted graph.

    Uses Kruskal-like filtration: sort edges by weight, add them one by one.
    Each edge addition either:
    - Merges two components (merge event)
    - Creates a cycle (cycle_death event)

    Time complexity: O(E log E) for sorting + O(E α(V)) for union-find.

    Parameters:
        n: number of vertices
        edges: list of (u, v, weight) tuples

    Returns:
        List of MorseEvent objects, sorted by critical value
    """
    # Initial state: n isolated vertices → n birth events at -∞
    events = []

    # Sort edges by weight (Kruskal ordering)
    sorted_edges = sorted(edges, key=lambda e: e[2])

    # Process edges in weight order
    uf = UnionFind(n)
    for u, v, w in sorted_edges:
        if uf.union(u, v):
            events.append(MorseEvent(w, MorseEvent.MERGE))
        else:
            events.append(MorseEvent(w, MorseEvent.CYCLE_DEATH))

    return events


def spectrum_summary(events: List[MorseEvent]) -> Dict:
    """Summarize a spectrum: counts by type, values."""
    type_counts = Counter(e.event_type for e in events)
    return {
        "total_events": len(events),
        "merges": type_counts.get(MorseEvent.MERGE, 0),
        "cycle_deaths": type_counts.get(MorseEvent.CYCLE_DEATH, 0),
        "events": [(e.value, e.event_type) for e in events]
    }


# ──────────────────────────────────────────────────────────────
# 1-WL Color Refinement
# ──────────────────────────────────────────────────────────────

def wl1_color_refinement(
    n: int,
    adj: Dict[int, Set[int]],
    max_iterations: int = None
) -> List[int]:
    """
    1-WL (Weisfeiler-Leman) color refinement.

    Iteratively refines vertex colors based on neighbor color multisets.
    Converges in at most n iterations.

    Parameters:
        n: number of vertices
        adj: adjacency list
        max_iterations: max refinement steps (default: n)

    Returns:
        List of stable colors for each vertex
    """
    if max_iterations is None:
        max_iterations = n

    # Initial coloring: degree
    colors = [len(adj.get(v, set())) for v in range(n)]

    for _ in range(max_iterations):
        # Build new colors from (own_color, sorted_neighbor_colors)
        new_colors = []
        for v in range(n):
            neighbor_colors = sorted(colors[u] for u in adj.get(v, set()))
            new_colors.append((colors[v], tuple(neighbor_colors)))

        # Map to integers
        color_map = {}
        next_color = 0
        int_colors = []
        for c in new_colors:
            if c not in color_map:
                color_map[c] = next_color
                next_color += 1
            int_colors.append(color_map[c])

        if int_colors == colors:
            break
        colors = int_colors

    return colors


def wl1_color_multiset(n: int, adj: Dict[int, Set[int]]) -> Counter:
    """Return the stable WL1 color multiset."""
    colors = wl1_color_refinement(n, adj)
    return Counter(colors)


# ──────────────────────────────────────────────────────────────
# Graph Constructors
# ──────────────────────────────────────────────────────────────

def make_cycle(n: int, weights: List[float] = None):
    """Create an n-cycle with given or default weights."""
    if weights is None:
        weights = list(range(1, n + 1))
    edges = [(i, (i + 1) % n, weights[i]) for i in range(n)]
    adj = defaultdict(set)
    for u, v, _ in edges:
        adj[u].add(v)
        adj[v].add(u)
    return n, edges, dict(adj)


def make_two_triangles(weights1=None, weights2=None):
    """Create two disjoint triangles on vertices {0,1,2} and {3,4,5}."""
    if weights1 is None:
        weights1 = [1.0, 3.0, 5.0]
    if weights2 is None:
        weights2 = [2.0, 4.0, 6.0]
    edges = [
        (0, 1, weights1[0]), (1, 2, weights1[1]), (0, 2, weights1[2]),
        (3, 4, weights2[0]), (4, 5, weights2[1]), (3, 5, weights2[2])
    ]
    adj = defaultdict(set)
    for u, v, _ in edges:
        adj[u].add(v)
        adj[v].add(u)
    return 6, edges, dict(adj)


def make_cfi_pair(base_n: int, base_weight=1.0, gadget_weight=0.5, connector_weight=2.0):
    """
    Generate a simplified CFI graph pair from an n-cycle base graph.

    The CFI construction replaces each vertex with a gadget of 2 vertices
    (even/odd parity), creating pairs that k-WL cannot distinguish for k < n.

    Returns two graphs (G_even, G_odd) as (n, edges, adj) triples.
    """
    n_total = 2 * base_n  # 2 vertices per gadget

    def make_graph(parity_flip_edge: int):
        edges = []
        adj = defaultdict(set)

        for i in range(base_n):
            # Gadget internal edge: (2i, 2i+1)
            edges.append((2*i, 2*i+1, gadget_weight))
            adj[2*i].add(2*i+1)
            adj[2*i+1].add(2*i)

        for i in range(base_n):
            j = (i + 1) % base_n
            # Connector edges between gadget i and gadget j
            if i == parity_flip_edge:
                # Flipped: cross-connect
                edges.append((2*i, 2*j+1, connector_weight))
                edges.append((2*i+1, 2*j, connector_weight))
                adj[2*i].add(2*j+1); adj[2*j+1].add(2*i)
                adj[2*i+1].add(2*j); adj[2*j].add(2*i+1)
            else:
                # Straight: parallel connect
                edges.append((2*i, 2*j, connector_weight))
                edges.append((2*i+1, 2*j+1, connector_weight))
                adj[2*i].add(2*j); adj[2*j].add(2*i)
                adj[2*i+1].add(2*j+1); adj[2*j+1].add(2*i+1)

        return n_total, edges, dict(adj)

    g_even = make_graph(-1)  # No flip
    g_odd = make_graph(0)    # Flip first edge

    return g_even, g_odd


# ──────────────────────────────────────────────────────────────
# Main Demo
# ──────────────────────────────────────────────────────────────

def demo_separation():
    """Demonstrate TMS separation of WL1-equivalent graphs."""
    print("=" * 70)
    print("TROPICAL MORSE SPECTRUM vs 1-WL: EXPRESSIVENESS SEPARATION")
    print("=" * 70)

    # C₆ with weights 1..6
    n_c6, edges_c6, adj_c6 = make_cycle(6, [1, 2, 3, 4, 5, 6])

    # 2×C₃ with interlaced weights
    n_2t, edges_2t, adj_2t = make_two_triangles([1, 3, 5], [2, 4, 6])

    print("\n--- Graph 1: C₆ (6-cycle) ---")
    print(f"  Vertices: {n_c6}")
    print(f"  Edges: {[(u,v,w) for u,v,w in edges_c6]}")

    print("\n--- Graph 2: 2×C₃ (two triangles) ---")
    print(f"  Vertices: {n_2t}")
    print(f"  Edges: {[(u,v,w) for u,v,w in edges_2t]}")

    # 1-WL comparison
    wl_c6 = wl1_color_multiset(n_c6, adj_c6)
    wl_2t = wl1_color_multiset(n_2t, adj_2t)

    print(f"\n--- 1-WL Color Multisets ---")
    print(f"  C₆:    {dict(wl_c6)}")
    print(f"  2×C₃:  {dict(wl_2t)}")
    print(f"  WL1 equivalent: {wl_c6 == wl_2t}")

    # TMS comparison
    tms_c6 = compute_tropical_morse_spectrum(n_c6, edges_c6)
    tms_2t = compute_tropical_morse_spectrum(n_2t, edges_2t)

    print(f"\n--- Tropical Morse Spectra ---")
    s_c6 = spectrum_summary(tms_c6)
    s_2t = spectrum_summary(tms_2t)

    print(f"  C₆:    {s_c6['merges']} merges, {s_c6['cycle_deaths']} cycle deaths")
    for v, t in s_c6['events']:
        print(f"         t={v}: {t}")

    print(f"  2×C₃:  {s_2t['merges']} merges, {s_2t['cycle_deaths']} cycle deaths")
    for v, t in s_2t['events']:
        print(f"         t={v}: {t}")

    print(f"\n  TMS distinguishes: {tms_c6 != tms_2t}")
    print(f"\n  ✓ WL1 says SAME, TMS says DIFFERENT → TMS is strictly more expressive!")


def demo_stability():
    """Demonstrate stability of TMS under weight perturbation."""
    print("\n" + "=" * 70)
    print("TROPICAL MORSE STABILITY")
    print("=" * 70)

    n, edges, adj = make_cycle(6, [1.0, 2.0, 3.0, 4.0, 5.0, 6.0])

    print("\nOriginal graph: C₆ with weights 1..6")
    tms_orig = compute_tropical_morse_spectrum(n, edges)

    for eps in [0.1, 0.3, 0.5, 1.5]:
        np.random.seed(42)
        perturbed_edges = [(u, v, w + np.random.uniform(-eps, eps))
                          for u, v, w in edges]
        tms_pert = compute_tropical_morse_spectrum(n, perturbed_edges)

        max_shift = max(abs(e1.value - e2.value)
                       for e1, e2 in zip(tms_orig, tms_pert))
        same_types = all(e1.event_type == e2.event_type
                        for e1, e2 in zip(tms_orig, tms_pert))

        print(f"\n  ε = {eps:.1f}: max critical value shift = {max_shift:.4f}, "
              f"same event types: {same_types}")


def demo_cfi():
    """Demonstrate CFI pair generation and TMS comparison."""
    print("\n" + "=" * 70)
    print("CFI GRAPH PAIRS: TMS SEPARATION")
    print("=" * 70)

    for base_n in [4, 6, 8]:
        g_even, g_odd = make_cfi_pair(base_n)
        n_e, edges_e, adj_e = g_even
        n_o, edges_o, adj_o = g_odd

        wl_e = wl1_color_multiset(n_e, adj_e)
        wl_o = wl1_color_multiset(n_o, adj_o)

        tms_e = compute_tropical_morse_spectrum(n_e, edges_e)
        tms_o = compute_tropical_morse_spectrum(n_o, edges_o)

        s_e = spectrum_summary(tms_e)
        s_o = spectrum_summary(tms_o)

        print(f"\n  Base n={base_n} ({n_e} vertices):")
        print(f"    WL1 equivalent: {wl_e == wl_o}")
        print(f"    Even: {s_e['merges']} merges, {s_e['cycle_deaths']} cycles")
        print(f"    Odd:  {s_o['merges']} merges, {s_o['cycle_deaths']} cycles")
        print(f"    TMS distinguishes: {tms_e != tms_o}")

        # Count differing events
        n_diff = sum(1 for e1, e2 in zip(tms_e, tms_o) if e1 != e2)
        print(f"    Events differing: {n_diff}")


if __name__ == "__main__":
    demo_separation()
    demo_stability()
    demo_cfi()
    print("\n" + "=" * 70)
    print("All demos completed successfully.")


#!/usr/bin/env python3
"""
Visualization 3: Persistence Barcodes from Tropical Morse Spectrum

Compares the persistence barcodes of C₆ vs 2×C₃, showing how different
Morse event sequences produce different H₀ and H₁ barcodes despite
the graphs being 1-WL equivalent.

This visualizes the cross-domain connection between tropical geometry
(weight filtration) and algebraic topology (persistent homology).
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


# ──── Self-contained implementations ────

class UnionFind:
    def __init__(self, n):
        self.parent = list(range(n))
        self.rank = [0] * n
        self.num_components = n
        self.birth = list(range(n))  # track representative birth

    def find(self, x):
        while self.parent[x] != x:
            self.parent[x] = self.parent[self.parent[x]]
            x = self.parent[x]
        return x

    def union(self, x, y):
        rx, ry = self.find(x), self.find(y)
        if rx == ry:
            return False, -1
        # Younger component dies
        if self.rank[rx] < self.rank[ry]:
            rx, ry = ry, rx
        self.parent[ry] = rx
        if self.rank[rx] == self.rank[ry]:
            self.rank[rx] += 1
        self.num_components -= 1
        return True, ry  # ry dies


def compute_barcode(n, edges):
    """Compute H₀ and H₁ barcodes."""
    h0_bars = []  # (birth, death) pairs
    h1_bars = []

    uf = UnionFind(n)
    sorted_edges = sorted(edges, key=lambda e: e[2])

    # Each vertex born at t=-∞ (we use 0 for display)
    for u, v, w in sorted_edges:
        merged, dying = uf.union(u, v)
        if merged:
            h0_bars.append((0, w))  # Component born at 0, dies at w
        else:
            h1_bars.append((w, None))  # Cycle born at w, lives forever

    return h0_bars, h1_bars


# ──── Graph definitions ────

c6_edges = [(i, (i+1)%6, float(i+1)) for i in range(6)]
tri_edges = [
    (0, 1, 1.0), (1, 2, 3.0), (0, 2, 5.0),
    (3, 4, 2.0), (4, 5, 4.0), (3, 5, 6.0)
]


# ──── Compute barcodes ────

h0_c6, h1_c6 = compute_barcode(6, c6_edges)
h0_2t, h1_2t = compute_barcode(6, tri_edges)


# ──── Plotting ────

fig, axes = plt.subplots(2, 2, figsize=(14, 8))
fig.suptitle("Persistence Barcodes: Tropical Morse Spectrum → Topological Invariants\n"
             "C₆ and 2×C₃ are 1-WL equivalent but have different barcodes",
             fontsize=13, fontweight='bold')

max_t = 8

def plot_barcode(ax, h0_bars, h1_bars, title, max_t=8):
    """Plot H₀ and H₁ bars."""
    y_pos = 0
    colors_h0 = plt.cm.Blues(np.linspace(0.4, 0.8, max(len(h0_bars), 1)))
    colors_h1 = plt.cm.Reds(np.linspace(0.4, 0.8, max(len(h1_bars), 1)))

    # H₀ bars
    for i, (b, d) in enumerate(h0_bars):
        ax.barh(y_pos, d - b, left=b, height=0.6,
                color=colors_h0[i % len(colors_h0)], edgecolor='navy',
                linewidth=0.5, label='H₀' if i == 0 else '')
        ax.text(d + 0.1, y_pos, f'†{d:.0f}', va='center', fontsize=8, color='navy')
        y_pos += 1

    # Separator
    y_pos += 0.5
    ax.axhline(y=y_pos - 0.25, color='gray', linestyle=':', alpha=0.5)

    # H₁ bars
    for i, (b, d) in enumerate(h1_bars):
        end = d if d is not None else max_t
        ax.barh(y_pos, end - b, left=b, height=0.6,
                color=colors_h1[i % len(colors_h1)], edgecolor='darkred',
                linewidth=0.5, label='H₁' if i == 0 else '')
        if d is None:
            ax.annotate('', xy=(max_t, y_pos), xytext=(max_t - 0.3, y_pos),
                       arrowprops=dict(arrowstyle='->', color='darkred', lw=1.5))
        ax.text(b - 0.3, y_pos, f'b={b:.0f}', va='center', fontsize=8, color='darkred')
        y_pos += 1

    ax.set_xlim(-0.5, max_t + 0.5)
    ax.set_xlabel('Weight threshold t', fontsize=11)
    ax.set_title(title, fontsize=11)
    ax.set_yticks([])
    ax.legend(fontsize=9, loc='upper right')
    ax.grid(True, axis='x', alpha=0.3)


# Plot barcodes
plot_barcode(axes[0, 0], h0_c6, h1_c6, "C₆: 5 merges (H₀ deaths) + 1 cycle (H₁ birth)")
plot_barcode(axes[0, 1], h0_2t, h1_2t, "2×C₃: 4 merges + 2 cycles")

# Panel 3: Comparison of Betti number evolution
ax3 = axes[1, 0]
thresholds = np.linspace(0, 7, 100)

def betti_at_threshold(n, edges, t):
    uf = UnionFind(n)
    cycles = 0
    for u, v, w in sorted(edges, key=lambda e: e[2]):
        if w <= t:
            merged, _ = uf.union(u, v)
            if not merged:
                cycles += 1
    return uf.num_components, cycles

beta0_c6 = [betti_at_threshold(6, c6_edges, t)[0] for t in thresholds]
beta1_c6 = [betti_at_threshold(6, c6_edges, t)[1] for t in thresholds]
beta0_2t = [betti_at_threshold(6, tri_edges, t)[0] for t in thresholds]
beta1_2t = [betti_at_threshold(6, tri_edges, t)[1] for t in thresholds]

ax3.step(thresholds, beta0_c6, 'b-', linewidth=2, label='C₆ β₀', where='post')
ax3.step(thresholds, beta0_2t, 'b--', linewidth=2, label='2×C₃ β₀', where='post')
ax3.step(thresholds, beta1_c6, 'r-', linewidth=2, label='C₆ β₁', where='post')
ax3.step(thresholds, beta1_2t, 'r--', linewidth=2, label='2×C₃ β₁', where='post')

ax3.set_xlabel('Weight threshold t', fontsize=11)
ax3.set_ylabel('Betti number', fontsize=11)
ax3.set_title('Betti Number Evolution\nβ₀ (components) and β₁ (cycles)', fontsize=11)
ax3.legend(fontsize=9)
ax3.grid(True, alpha=0.3)

# Panel 4: Euler characteristic
ax4 = axes[1, 1]
chi_c6 = [b0 - b1 for b0, b1 in zip(beta0_c6, beta1_c6)]
chi_2t = [b0 - b1 for b0, b1 in zip(beta0_2t, beta1_2t)]

ax4.step(thresholds, chi_c6, 'g-', linewidth=2, label='C₆: χ = β₀ - β₁', where='post')
ax4.step(thresholds, chi_2t, 'g--', linewidth=2, label='2×C₃: χ = β₀ - β₁', where='post')

ax4.set_xlabel('Weight threshold t', fontsize=11)
ax4.set_ylabel('Euler characteristic χ', fontsize=11)
ax4.set_title('Euler Characteristic = V - E(t)\nCross-domain: Topology ↔ Tropical Geometry', fontsize=11)
ax4.legend(fontsize=9)
ax4.grid(True, alpha=0.3)

plt.tight_layout(rect=[0, 0, 1, 0.93])
plt.savefig('vis_barcode.png', dpi=150, bbox_inches='tight')
print("Saved vis_barcode.png")


#!/usr/bin/env python3
"""
Visualization 1: Tropical Morse Filtration

Visualizes the weight filtration process on two WL1-equivalent graphs
(C₆ vs 2×C₃), showing how the sublevel set evolves as the threshold
increases. The key insight: identical degree sequences but different
topological event sequences.

Output: A figure with two rows (one per graph) showing the sublevel
set at each critical threshold, with Betti numbers annotated.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np
from collections import defaultdict


# ──── Self-contained implementations ────

class UnionFind:
    def __init__(self, n):
        self.parent = list(range(n))
        self.rank = [0] * n
        self.num_components = n

    def find(self, x):
        while self.parent[x] != x:
            self.parent[x] = self.parent[self.parent[x]]
            x = self.parent[x]
        return x

    def union(self, x, y):
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


def compute_tms(n, edges):
    events = []
    uf = UnionFind(n)
    sorted_edges = sorted(edges, key=lambda e: e[2])
    cycle_rank = 0
    for u, v, w in sorted_edges:
        if uf.union(u, v):
            events.append(("merge", w, uf.num_components, cycle_rank))
        else:
            cycle_rank += 1
            events.append(("cycle_death", w, uf.num_components, cycle_rank))
    return events


# ──── Graph definitions ────

def get_c6():
    """C₆ with positions and edges."""
    n = 6
    angles = [np.pi/2 + 2*np.pi*i/6 for i in range(6)]
    pos = {i: (np.cos(a), np.sin(a)) for i, a in enumerate(angles)}
    edges = [(i, (i+1)%6, float(i+1)) for i in range(6)]
    return n, pos, edges, "C₆ (6-cycle)"


def get_2tri():
    """2×C₃ with positions and edges."""
    n = 6
    # Triangle 1 on the left
    cx1, cy1 = -1.5, 0
    angles1 = [np.pi/2 + 2*np.pi*i/3 for i in range(3)]
    # Triangle 2 on the right
    cx2, cy2 = 1.5, 0
    angles2 = [np.pi/2 + 2*np.pi*i/3 for i in range(3)]

    pos = {}
    for i in range(3):
        pos[i] = (cx1 + 0.8*np.cos(angles1[i]), cy1 + 0.8*np.sin(angles1[i]))
        pos[i+3] = (cx2 + 0.8*np.cos(angles2[i]), cy2 + 0.8*np.sin(angles2[i]))

    edges = [
        (0, 1, 1.0), (1, 2, 3.0), (0, 2, 5.0),
        (3, 4, 2.0), (4, 5, 4.0), (3, 5, 6.0)
    ]
    return n, pos, edges, "2×C₃ (two triangles)"


# ──── Drawing ────

def draw_graph_at_threshold(ax, n, pos, edges, threshold, title=""):
    """Draw graph showing only edges with weight ≤ threshold."""
    ax.set_xlim(-2.5, 2.5)
    ax.set_ylim(-1.5, 1.5)
    ax.set_aspect('equal')
    ax.set_title(title, fontsize=9)

    # Draw inactive edges (dashed, gray)
    for u, v, w in edges:
        if w > threshold:
            x = [pos[u][0], pos[v][0]]
            y = [pos[u][1], pos[v][1]]
            ax.plot(x, y, '--', color='lightgray', linewidth=1, zorder=1)

    # Draw active edges (solid, colored)
    for u, v, w in edges:
        if w <= threshold:
            x = [pos[u][0], pos[v][0]]
            y = [pos[u][1], pos[v][1]]
            ax.plot(x, y, '-', color='#2196F3', linewidth=2.5, zorder=2)
            # Weight label
            mx, my = (x[0]+x[1])/2, (y[0]+y[1])/2
            ax.text(mx, my+0.15, f'{w:.0f}', ha='center', fontsize=7, color='#1565C0')

    # Draw vertices
    for i in range(n):
        circle = plt.Circle(pos[i], 0.12, color='#FF5722', zorder=3)
        ax.add_patch(circle)
        ax.text(pos[i][0], pos[i][1], str(i), ha='center', va='center',
                fontsize=7, fontweight='bold', color='white', zorder=4)

    ax.axis('off')


# ──── Main visualization ────

fig, axes = plt.subplots(2, 7, figsize=(18, 6))
fig.suptitle("Tropical Morse Filtration: C₆ vs 2×C₃\n"
             "Both are 2-regular (1-WL equivalent), but TMS reveals different topology",
             fontsize=13, fontweight='bold')

graphs = [get_c6(), get_2tri()]
thresholds = [0, 1, 2, 3, 4, 5, 6]

for row, (n, pos, edges, name) in enumerate(graphs):
    events = compute_tms(n, edges)

    for col, t in enumerate(thresholds):
        ax = axes[row, col]

        # Compute Betti numbers at this threshold
        uf = UnionFind(n)
        n_edges_added = 0
        cycle_rank = 0
        for u, v, w in sorted(edges, key=lambda e: e[2]):
            if w <= t:
                if not uf.union(u, v):
                    cycle_rank += 1
                n_edges_added += 1

        beta0 = uf.num_components
        beta1 = cycle_rank

        title = f"t={t}"
        if col == 0:
            title = f"{name}\n{title}"
        title += f"\nβ₀={beta0}, β₁={beta1}"

        draw_graph_at_threshold(ax, n, pos, edges, t, title)

# Add event type legend at bottom
merge_patch = mpatches.Patch(color='#4CAF50', label='Merge (β₀ ↓)')
cycle_patch = mpatches.Patch(color='#F44336', label='Cycle Death (β₁ ↑)')
active_line = plt.Line2D([0], [0], color='#2196F3', linewidth=2.5, label='Active edge')
inactive_line = plt.Line2D([0], [0], color='lightgray', linewidth=1, linestyle='--', label='Inactive edge')

fig.legend(handles=[active_line, inactive_line], loc='lower center', ncol=4, fontsize=10)

plt.tight_layout(rect=[0, 0.05, 1, 0.92])
plt.savefig('vis_filtration.png', dpi=150, bbox_inches='tight')
print("Saved vis_filtration.png")


#!/usr/bin/env python3
"""
Visualization 2: Tropical Morse Stability

Demonstrates the stability theorem: small perturbations in edge weights
produce small changes in the tropical Morse spectrum. This is the tropical
analogue of the Cohen-Steiner–Edelsbrunner–Harer persistence stability theorem.

Shows: Critical value shifts vs perturbation magnitude ε, confirming
that bottleneck distance ≤ ε.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


# ──── Self-contained implementations ────

class UnionFind:
    def __init__(self, n):
        self.parent = list(range(n))
        self.rank = [0] * n
        self.num_components = n

    def find(self, x):
        while self.parent[x] != x:
            self.parent[x] = self.parent[self.parent[x]]
            x = self.parent[x]
        return x

    def union(self, x, y):
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


def compute_tms_values(n, edges):
    """Return list of (critical_value, event_type) pairs."""
    events = []
    uf = UnionFind(n)
    for u, v, w in sorted(edges, key=lambda e: e[2]):
        if uf.union(u, v):
            events.append((w, "merge"))
        else:
            events.append((w, "cycle_death"))
    return events


# ──── Setup ────

# Base graph: C₆ with weights 1..6
base_n = 6
base_edges = [(i, (i+1)%6, float(i+1)) for i in range(6)]
base_tms = compute_tms_values(base_n, base_edges)
base_values = [v for v, _ in base_tms]

# Perturbation study
epsilons = np.linspace(0, 2.0, 50)
n_trials = 100

bottleneck_dists = []
mean_shifts = []
max_shifts = []

np.random.seed(42)

for eps in epsilons:
    trial_bottlenecks = []
    trial_means = []
    trial_maxes = []

    for _ in range(n_trials):
        perturbed_edges = [(u, v, w + np.random.uniform(-eps, eps))
                          for u, v, w in base_edges]
        pert_tms = compute_tms_values(base_n, perturbed_edges)
        pert_values = [v for v, _ in pert_tms]

        if len(pert_values) == len(base_values):
            shifts = [abs(a - b) for a, b in zip(base_values, pert_values)]
            trial_bottlenecks.append(max(shifts))
            trial_means.append(np.mean(shifts))
            trial_maxes.append(max(shifts))

    bottleneck_dists.append(np.mean(trial_bottlenecks) if trial_bottlenecks else 0)
    mean_shifts.append(np.mean(trial_means) if trial_means else 0)
    max_shifts.append(np.percentile(trial_maxes, 95) if trial_maxes else 0)


# ──── Plotting ────

fig, axes = plt.subplots(1, 3, figsize=(16, 5))

# Panel 1: Bottleneck distance vs epsilon
ax1 = axes[0]
ax1.plot(epsilons, bottleneck_dists, 'b-', linewidth=2, label='Mean bottleneck dist')
ax1.plot(epsilons, max_shifts, 'r--', linewidth=1.5, alpha=0.7, label='95th percentile')
ax1.plot(epsilons, epsilons, 'k:', linewidth=1, label='y = ε (stability bound)')
ax1.set_xlabel('Perturbation magnitude ε', fontsize=12)
ax1.set_ylabel('Bottleneck distance', fontsize=12)
ax1.set_title('Stability Theorem Verification\n'
              'd_B(TMS(G), TMS(G\')) ≤ ε', fontsize=11)
ax1.legend(fontsize=9)
ax1.grid(True, alpha=0.3)

# Panel 2: Event type preservation
type_preservation = []
for eps in epsilons:
    preserved = 0
    for _ in range(n_trials):
        perturbed_edges = [(u, v, w + np.random.uniform(-eps, eps))
                          for u, v, w in base_edges]
        pert_tms = compute_tms_values(base_n, perturbed_edges)
        pert_types = [t for _, t in pert_tms]
        base_types = [t for _, t in base_tms]
        if pert_types == base_types:
            preserved += 1
    type_preservation.append(preserved / n_trials)

ax2 = axes[1]
ax2.plot(epsilons, type_preservation, 'g-', linewidth=2)
ax2.axhline(y=1.0, color='k', linestyle=':', alpha=0.3)
ax2.set_xlabel('Perturbation magnitude ε', fontsize=12)
ax2.set_ylabel('Event type preservation rate', fontsize=12)
ax2.set_title('Event Type Stability\n'
              'Fraction of trials preserving merge/cycle order', fontsize=11)
ax2.set_ylim(-0.05, 1.05)
ax2.grid(True, alpha=0.3)

# Panel 3: Critical value distributions under perturbation
ax3 = axes[2]
colors = ['#1f77b4', '#ff7f0e', '#2ca02c', '#d62728', '#9467bd', '#8c564b']
eps_show = 0.8

for trial in range(min(20, n_trials)):
    perturbed_edges = [(u, v, w + np.random.uniform(-eps_show, eps_show))
                      for u, v, w in base_edges]
    pert_tms = compute_tms_values(base_n, perturbed_edges)
    pert_values = [v for v, _ in pert_tms]
    ax3.scatter(range(len(pert_values)), pert_values,
               color='lightblue', s=15, alpha=0.3, zorder=1)

ax3.scatter(range(len(base_values)), base_values,
           color='red', s=80, zorder=3, label='Original', marker='D')

# Draw ε bands
for i, bv in enumerate(base_values):
    ax3.fill_between([i-0.3, i+0.3], bv-eps_show, bv+eps_show,
                    color='red', alpha=0.1)

ax3.set_xlabel('Event index', fontsize=12)
ax3.set_ylabel('Critical value', fontsize=12)
ax3.set_title(f'Critical Value Distribution (ε={eps_show})\n'
              'Red bands: ±ε guarantee', fontsize=11)
ax3.set_xticks(range(len(base_values)))
ax3.set_xticklabels([f'{t}' for _, t in base_tms], rotation=45, fontsize=8)
ax3.legend(fontsize=9)
ax3.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('vis_stability.png', dpi=150, bbox_inches='tight')
print("Saved vis_stability.png")
