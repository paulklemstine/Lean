#!/usr/bin/env python3
"""
Proof DAG Demo: Hub Emergence and Fragility Conservation

Demonstrates the key theorems from the Proof DAG theory:
1. Handshaking Lemma: sum of out-degrees = edge count
2. Hub Emergence: some node has out-degree >= edges/nodes
3. Fragility Conservation: fragilities sum to 1
4. Source and Sink existence

Run: python demo.py
"""

from __future__ import annotations
from typing import Dict, List, Set, Tuple
import random


class DepDAG:
    """A Dependency DAG: finite directed acyclic graph."""

    def __init__(self, nodes: List[str], edges: List[Tuple[str, str]]):
        """
        nodes: list of node names
        edges: list of (a, b) meaning "b depends on a"
        """
        self.nodes = list(nodes)
        self.edges = list(edges)
        self._validate()

    def _validate(self):
        """Check acyclicity using topological sort."""
        adj: Dict[str, List[str]] = {n: [] for n in self.nodes}
        for a, b in self.edges:
            assert a in adj and b in adj, f"Edge ({a},{b}) has unknown node"
            assert a != b, f"Self-loop ({a},{a}) violates irreflexivity"
            adj[a].append(b)

        # Kahn's algorithm for topological sort
        in_deg = {n: 0 for n in self.nodes}
        for _, b in self.edges:
            in_deg[b] += 1
        queue = [n for n in self.nodes if in_deg[n] == 0]
        visited = 0
        while queue:
            v = queue.pop(0)
            visited += 1
            for w in adj[v]:
                in_deg[w] -= 1
                if in_deg[w] == 0:
                    queue.append(w)
        assert visited == len(self.nodes), "DAG has a cycle!"

    @property
    def card(self) -> int:
        return len(self.nodes)

    @property
    def edge_count(self) -> int:
        return len(self.edges)

    def successors(self, v: str) -> Set[str]:
        return {b for a, b in self.edges if a == v}

    def predecessors(self, v: str) -> Set[str]:
        return {a for a, b in self.edges if b == v}

    def out_degree(self, v: str) -> int:
        return len(self.successors(v))

    def in_degree(self, v: str) -> int:
        return len(self.predecessors(v))

    def is_source(self, v: str) -> bool:
        return self.in_degree(v) == 0

    def is_sink(self, v: str) -> bool:
        return self.out_degree(v) == 0

    def hub_fragility(self, v: str) -> float:
        if self.edge_count == 0:
            return 0.0
        return self.out_degree(v) / self.edge_count

    def sources(self) -> List[str]:
        return [v for v in self.nodes if self.is_source(v)]

    def sinks(self) -> List[str]:
        return [v for v in self.nodes if self.is_sink(v)]


def demo_handshaking(G: DepDAG):
    """Demonstrate the Handshaking Lemma."""
    print("=" * 60)
    print("THEOREM: Handshaking Lemma for DAGs")
    print("=" * 60)
    sum_out = sum(G.out_degree(v) for v in G.nodes)
    sum_in = sum(G.in_degree(v) for v in G.nodes)
    print(f"  Sum of out-degrees: {sum_out}")
    print(f"  Sum of in-degrees:  {sum_in}")
    print(f"  Edge count:         {G.edge_count}")
    print(f"  ✓ All three equal:  {sum_out == sum_in == G.edge_count}")
    print()


def demo_hub_emergence(G: DepDAG):
    """Demonstrate the Hub Emergence Theorem."""
    print("=" * 60)
    print("THEOREM: Hub Emergence (Pigeonhole)")
    print("=" * 60)
    threshold = G.edge_count / G.card if G.card > 0 else 0
    max_hub = max(G.nodes, key=lambda v: G.out_degree(v))
    max_deg = G.out_degree(max_hub)
    print(f"  Nodes: {G.card}, Edges: {G.edge_count}")
    print(f"  Threshold (edges/nodes): {threshold:.2f}")
    print(f"  Hub node: '{max_hub}' with out-degree {max_deg}")
    print(f"  ✓ Hub degree × card ≥ edges: {max_deg * G.card} ≥ {G.edge_count}")
    print()


def demo_fragility_conservation(G: DepDAG):
    """Demonstrate the Fragility Conservation Law."""
    print("=" * 60)
    print("THEOREM: Fragility Conservation Law")
    print("=" * 60)
    total = sum(G.hub_fragility(v) for v in G.nodes)
    print("  Node fragilities:")
    for v in G.nodes:
        f = G.hub_fragility(v)
        bar = "█" * int(f * 40)
        print(f"    {v:20s}: {f:.4f} {bar}")
    print(f"  Sum of fragilities: {total:.6f}")
    print(f"  ✓ Sum equals 1:     {abs(total - 1.0) < 1e-10}")
    print()


def demo_sources_sinks(G: DepDAG):
    """Demonstrate Source and Sink Existence."""
    print("=" * 60)
    print("THEOREM: Source and Sink Existence")
    print("=" * 60)
    print(f"  Sources (axioms):       {G.sources()}")
    print(f"  Sinks (leaf theorems):  {G.sinks()}")
    print(f"  ✓ At least one source:  {len(G.sources()) > 0}")
    print(f"  ✓ At least one sink:    {len(G.sinks()) > 0}")
    print()


def demo_asymmetry(G: DepDAG):
    """Demonstrate Asymmetry."""
    print("=" * 60)
    print("THEOREM: Asymmetry of Dependencies")
    print("=" * 60)
    violations = 0
    for a, b in G.edges:
        if (b, a) in G.edges:
            violations += 1
    print(f"  Edges checked: {G.edge_count}")
    print(f"  Symmetric pairs found: {violations}")
    print(f"  ✓ All dependencies asymmetric: {violations == 0}")
    print()


def build_math_example() -> DepDAG:
    """Build a DAG modeling a fragment of mathematical dependencies."""
    nodes = [
        "ZFC_Axioms",
        "Natural_Numbers",
        "Integers",
        "Rationals",
        "Reals",
        "Sequences",
        "Limits",
        "Continuity",
        "Derivatives",
        "Integrals",
        "FTC",  # Fundamental Theorem of Calculus
        "Groups",
        "Rings",
        "Fields",
        "Linear_Algebra",
        "Eigenvalues",
    ]
    edges = [
        ("ZFC_Axioms", "Natural_Numbers"),
        ("ZFC_Axioms", "Groups"),
        ("Natural_Numbers", "Integers"),
        ("Natural_Numbers", "Sequences"),
        ("Integers", "Rationals"),
        ("Rationals", "Reals"),
        ("Rationals", "Fields"),
        ("Reals", "Sequences"),
        ("Reals", "Continuity"),
        ("Reals", "Derivatives"),
        ("Reals", "Integrals"),
        ("Sequences", "Limits"),
        ("Limits", "Continuity"),
        ("Limits", "Derivatives"),
        ("Continuity", "Derivatives"),
        ("Continuity", "Integrals"),
        ("Derivatives", "FTC"),
        ("Integrals", "FTC"),
        ("Groups", "Rings"),
        ("Rings", "Fields"),
        ("Fields", "Linear_Algebra"),
        ("Reals", "Linear_Algebra"),
        ("Linear_Algebra", "Eigenvalues"),
        ("Derivatives", "Eigenvalues"),
    ]
    return DepDAG(nodes, edges)


def main():
    print()
    print("╔══════════════════════════════════════════════════════════╗")
    print("║     PROOF DAG THEORY — Numerical Demonstrations        ║")
    print("╚══════════════════════════════════════════════════════════╝")
    print()

    # Example 1: Mathematical theory fragment
    print("EXAMPLE: Fragment of Mathematical Theory")
    print("-" * 60)
    G = build_math_example()
    print(f"  {G.card} theorems, {G.edge_count} dependencies")
    print()

    demo_handshaking(G)
    demo_hub_emergence(G)
    demo_fragility_conservation(G)
    demo_sources_sinks(G)
    demo_asymmetry(G)

    # Example 2: Random DAG
    print("\n" + "=" * 60)
    print("EXAMPLE: Random DAG (50 nodes, ~100 edges)")
    print("=" * 60)
    random.seed(42)
    n = 50
    nodes2 = [f"T{i}" for i in range(n)]
    edges2 = []
    for i in range(n):
        for j in range(i + 1, n):
            if random.random() < 0.08:
                edges2.append((f"T{i}", f"T{j}"))
    G2 = DepDAG(nodes2, edges2)
    print(f"  {G2.card} nodes, {G2.edge_count} edges")
    print()
    demo_hub_emergence(G2)
    demo_fragility_conservation(G2)

    # Hub fragility analysis
    print("=" * 60)
    print("HUB FRAGILITY ANALYSIS — Top 5 Hubs")
    print("=" * 60)
    ranked = sorted(G.nodes, key=lambda v: G.hub_fragility(v), reverse=True)
    for i, v in enumerate(ranked[:5]):
        print(f"  {i+1}. {v:20s}  fragility={G.hub_fragility(v):.4f}  "
              f"out-degree={G.out_degree(v)}  in-degree={G.in_degree(v)}")
    print()


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: DAG Structure and Hub Identification

Generates a visualization of a proof DAG with nodes sized by hub score
and colored by depth level.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
from collections import defaultdict


def topological_sort(nodes, edges):
    adj = defaultdict(list)
    in_deg = {n: 0 for n in nodes}
    for a, b in edges:
        adj[a].append(b)
        in_deg[b] += 1
    queue = [n for n in nodes if in_deg[n] == 0]
    result = []
    while queue:
        v = queue.pop(0)
        result.append(v)
        for w in adj[v]:
            in_deg[w] -= 1
            if in_deg[w] == 0:
                queue.append(w)
    return result


def compute_depths(nodes, edges):
    order = topological_sort(nodes, edges)
    depth = {v: 0 for v in nodes}
    adj = defaultdict(list)
    for a, b in edges:
        adj[a].append(b)
    for v in order:
        for w in adj[v]:
            depth[w] = max(depth[w], depth[v] + 1)
    return depth


def main():
    nodes = [
        "ZFC", "ℕ", "ℤ", "ℚ", "ℝ", "Seq", "Lim",
        "Cont", "Deriv", "Integ", "FTC", "Grp",
        "Ring", "Field", "LinAlg", "Eigen"
    ]
    edges = [
        ("ZFC", "ℕ"), ("ZFC", "Grp"),
        ("ℕ", "ℤ"), ("ℕ", "Seq"),
        ("ℤ", "ℚ"), ("ℚ", "ℝ"), ("ℚ", "Field"),
        ("ℝ", "Seq"), ("ℝ", "Cont"), ("ℝ", "Deriv"),
        ("ℝ", "Integ"), ("Seq", "Lim"),
        ("Lim", "Cont"), ("Lim", "Deriv"),
        ("Cont", "Deriv"), ("Cont", "Integ"),
        ("Deriv", "FTC"), ("Integ", "FTC"),
        ("Grp", "Ring"), ("Ring", "Field"),
        ("Field", "LinAlg"), ("ℝ", "LinAlg"),
        ("LinAlg", "Eigen"), ("Deriv", "Eigen"),
    ]

    depth = compute_depths(nodes, edges)
    out_deg = {v: sum(1 for a, b in edges if a == v) for v in nodes}
    m = len(edges)

    # Layout: x = depth, y = position within layer
    max_depth = max(depth.values())
    layers = defaultdict(list)
    for v in nodes:
        layers[depth[v]].append(v)

    pos = {}
    for d, layer_nodes in layers.items():
        for i, v in enumerate(layer_nodes):
            x = d * 2.5
            y = (i - (len(layer_nodes) - 1) / 2) * 1.5
            pos[v] = (x, y)

    fig, ax = plt.subplots(figsize=(16, 8))

    # Draw edges
    for a, b in edges:
        x1, y1 = pos[a]
        x2, y2 = pos[b]
        ax.annotate("", xy=(x2, y2), xytext=(x1, y1),
                     arrowprops=dict(arrowstyle="->", color="gray",
                                     alpha=0.5, connectionstyle="arc3,rad=0.1"))

    # Draw nodes
    cmap = plt.cm.viridis
    for v in nodes:
        x, y = pos[v]
        size = 200 + out_deg[v] * 300  # size by hub score
        frag = out_deg[v] / m if m > 0 else 0
        color = cmap(depth[v] / max(max_depth, 1))
        ax.scatter(x, y, s=size, c=[color], zorder=5, edgecolors='black',
                   linewidth=1.5, alpha=0.85)
        ax.annotate(v, (x, y), ha='center', va='center', fontsize=8,
                    fontweight='bold', zorder=6)
        # Show fragility below
        if frag > 0:
            ax.annotate(f'f={frag:.2f}', (x, y - 0.4), ha='center',
                        fontsize=7, color='darkred', alpha=0.8)

    ax.set_xlim(-1, max_depth * 2.5 + 1)
    ax.set_title('Proof DAG: Mathematical Theory Fragment\n'
                 'Node size ∝ hub score, color = depth level, f = fragility',
                 fontsize=14, fontweight='bold')
    ax.set_xlabel('Proof Depth (layers from axioms)', fontsize=12)
    ax.axis('off')

    # Legend
    for d in range(max_depth + 1):
        ax.scatter([], [], c=[cmap(d / max(max_depth, 1))], s=100,
                   label=f'Depth {d}')
    ax.legend(loc='upper left', fontsize=9, title='Proof Depth')

    plt.tight_layout()
    plt.savefig('dag_structure.png', dpi=150, bbox_inches='tight')
    print("Saved: dag_structure.png")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: Hub Fragility Distribution

Generates a bar chart of fragility indices for a mathematical theory DAG,
demonstrating the Fragility Conservation Law (sum = 1).
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def compute_fragility(nodes, edges):
    """Compute fragility for each node."""
    m = len(edges)
    out_deg = {v: 0 for v in nodes}
    for a, b in edges:
        out_deg[a] += 1
    return {v: out_deg[v] / m if m > 0 else 0.0 for v in nodes}


def main():
    nodes = [
        "ZFC", "ℕ", "ℤ", "ℚ", "ℝ", "Seq", "Lim",
        "Cont", "Deriv", "Integ", "FTC", "Grp",
        "Ring", "Field", "LinAlg", "Eigen"
    ]
    edges = [
        ("ZFC", "ℕ"), ("ZFC", "Grp"),
        ("ℕ", "ℤ"), ("ℕ", "Seq"),
        ("ℤ", "ℚ"), ("ℚ", "ℝ"), ("ℚ", "Field"),
        ("ℝ", "Seq"), ("ℝ", "Cont"), ("ℝ", "Deriv"),
        ("ℝ", "Integ"), ("Seq", "Lim"),
        ("Lim", "Cont"), ("Lim", "Deriv"),
        ("Cont", "Deriv"), ("Cont", "Integ"),
        ("Deriv", "FTC"), ("Integ", "FTC"),
        ("Grp", "Ring"), ("Ring", "Field"),
        ("Field", "LinAlg"), ("ℝ", "LinAlg"),
        ("LinAlg", "Eigen"), ("Deriv", "Eigen"),
    ]

    frag = compute_fragility(nodes, edges)

    # Sort by fragility
    sorted_nodes = sorted(nodes, key=lambda v: frag[v], reverse=True)
    values = [frag[v] for v in sorted_nodes]

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

    # Bar chart
    colors = plt.cm.YlOrRd(np.linspace(0.3, 0.9, len(sorted_nodes)))
    bars = ax1.barh(range(len(sorted_nodes)), values, color=colors)
    ax1.set_yticks(range(len(sorted_nodes)))
    ax1.set_yticklabels(sorted_nodes, fontsize=10)
    ax1.set_xlabel('Hub Fragility Index', fontsize=12)
    ax1.set_title('Hub Fragility Distribution\n(Conservation Law: Sum = 1)',
                   fontsize=13, fontweight='bold')
    ax1.invert_yaxis()

    # Add sum annotation
    total = sum(values)
    ax1.axvline(x=0, color='black', linewidth=0.5)
    ax1.text(0.95, 0.95, f'∑ fragility = {total:.4f}',
             transform=ax1.transAxes, ha='right', va='top',
             fontsize=11, bbox=dict(boxstyle='round', facecolor='lightgreen', alpha=0.8))

    # Cumulative fragility
    cumulative = np.cumsum(values)
    ax2.plot(range(1, len(sorted_nodes) + 1), cumulative, 'o-',
             color='darkred', linewidth=2, markersize=6)
    ax2.axhline(y=1.0, color='green', linestyle='--', linewidth=1.5, label='Total = 1')
    ax2.set_xlabel('Number of Top Hubs', fontsize=12)
    ax2.set_ylabel('Cumulative Fragility', fontsize=12)
    ax2.set_title('Cumulative Hub Fragility\n(How many hubs capture most importance?)',
                   fontsize=13, fontweight='bold')
    ax2.legend(fontsize=11)
    ax2.set_ylim(0, 1.1)

    # Add 80% line
    ax2.axhline(y=0.8, color='orange', linestyle=':', linewidth=1, alpha=0.7)
    idx_80 = next((i for i, c in enumerate(cumulative) if c >= 0.8), len(cumulative) - 1)
    ax2.annotate(f'Top {idx_80 + 1} hubs capture 80%',
                 xy=(idx_80 + 1, 0.8), xytext=(idx_80 + 3, 0.6),
                 arrowprops=dict(arrowstyle='->', color='orange'),
                 fontsize=10, color='orange')

    plt.tight_layout()
    plt.savefig('fragility_distribution.png', dpi=150, bbox_inches='tight')
    print("Saved: fragility_distribution.png")


if __name__ == "__main__":
    main()
