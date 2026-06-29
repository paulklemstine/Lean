#!/usr/bin/env python3
"""
Graph Bridges: Interactive Demonstrations

Demonstrates the formally verified theorems about bridge edges in graphs.
Each demo corresponds to a theorem proven in Lean 4 in Bridges/Basic.lean.

Requirements: pip install matplotlib networkx numpy
"""

import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import networkx as nx
import numpy as np
from itertools import combinations


# ──────────────────────────────────────────────────────────────────────
# Utility functions
# ──────────────────────────────────────────────────────────────────────

def find_bridges(G):
    """Find all bridge edges using DFS (Tarjan's algorithm)."""
    return list(nx.bridges(G))


def is_bridge(G, u, v):
    """Check if edge (u,v) is a bridge."""
    return (u, v) in find_bridges(G) or (v, u) in find_bridges(G)


def edge_colors(G, bridges):
    """Color edges: red for bridges, gray for non-bridges."""
    bridge_set = set()
    for u, v in bridges:
        bridge_set.add((u, v))
        bridge_set.add((v, u))
    return ['#e74c3c' if (u, v) in bridge_set else '#95a5a6'
            for u, v in G.edges()]


def edge_widths(G, bridges):
    bridge_set = set()
    for u, v in bridges:
        bridge_set.add((u, v))
        bridge_set.add((v, u))
    return [3.5 if (u, v) in bridge_set else 1.5 for u, v in G.edges()]


# ──────────────────────────────────────────────────────────────────────
# Demo 1: Tree ↔ Connected + Every Edge is a Bridge
# ──────────────────────────────────────────────────────────────────────

def demo_tree_characterization():
    """
    Theorem: isTree_iff_connected_and_forall_edge_isBridge
    A graph is a tree ⟺ it is connected and every edge is a bridge.
    """
    fig, axes = plt.subplots(1, 3, figsize=(16, 5))
    fig.suptitle('Theorem 1: Tree ⟺ Connected + Every Edge is a Bridge',
                 fontsize=14, fontweight='bold')

    # Example 1: A tree (path graph)
    T = nx.path_graph(6)
    bridges_T = find_bridges(T)
    pos = nx.spring_layout(T, seed=42)

    ax = axes[0]
    nx.draw(T, pos, ax=ax, with_labels=True, node_color='#3498db',
            edge_color=edge_colors(T, bridges_T),
            width=edge_widths(T, bridges_T),
            node_size=500, font_color='white', font_weight='bold')
    ax.set_title(f'Tree (Path P₆)\n{len(bridges_T)} bridges = {T.number_of_edges()} edges ✓',
                 fontsize=11)

    # Example 2: A tree (star graph)
    S = nx.star_graph(5)
    bridges_S = find_bridges(S)
    pos = nx.spring_layout(S, seed=123)

    ax = axes[1]
    nx.draw(S, pos, ax=ax, with_labels=True, node_color='#3498db',
            edge_color=edge_colors(S, bridges_S),
            width=edge_widths(S, bridges_S),
            node_size=500, font_color='white', font_weight='bold')
    ax.set_title(f'Tree (Star K₁,₅)\n{len(bridges_S)} bridges = {S.number_of_edges()} edges ✓',
                 fontsize=11)

    # Example 3: Not a tree (has a cycle) — some edges are NOT bridges
    G = nx.Graph()
    G.add_edges_from([(0,1),(1,2),(2,3),(3,0),(3,4),(4,5)])
    bridges_G = find_bridges(G)
    pos = nx.spring_layout(G, seed=42)

    ax = axes[2]
    nx.draw(G, pos, ax=ax, with_labels=True, node_color='#e67e22',
            edge_color=edge_colors(G, bridges_G),
            width=edge_widths(G, bridges_G),
            node_size=500, font_color='white', font_weight='bold')
    ax.set_title(f'Not a tree (has cycle)\nOnly {len(bridges_G)}/{G.number_of_edges()} edges are bridges',
                 fontsize=11)

    red_patch = mpatches.Patch(color='#e74c3c', label='Bridge edge')
    gray_patch = mpatches.Patch(color='#95a5a6', label='Non-bridge edge')
    fig.legend(handles=[red_patch, gray_patch], loc='lower center', ncol=2, fontsize=11)

    plt.tight_layout(rect=[0, 0.06, 1, 0.95])
    plt.savefig('demo1_tree_characterization.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("✓ Demo 1 saved: demo1_tree_characterization.png")


# ──────────────────────────────────────────────────────────────────────
# Demo 2: Bridge Removal Disconnects
# ──────────────────────────────────────────────────────────────────────

def demo_bridge_removal():
    """
    Theorem: IsBridge.not_connected_deleteEdge
    Removing a bridge from a connected graph disconnects it.

    Theorem: IsBridge.reachable_xor_of_connected
    After removing a bridge {u,v}, every vertex is reachable from
    exactly one of u or v (partition into two components).
    """
    fig, axes = plt.subplots(1, 3, figsize=(16, 5))
    fig.suptitle('Theorem 2: Bridge Removal Disconnects & Partitions Vertices',
                 fontsize=14, fontweight='bold')

    # Build a graph with a clear bridge
    G = nx.Graph()
    G.add_edges_from([(0,1),(1,2),(2,0),  # triangle on left
                      (2,3),               # BRIDGE
                      (3,4),(4,5),(5,3)])   # triangle on right
    pos = {0: (-2, 1), 1: (-2, -1), 2: (-0.5, 0),
           3: (0.5, 0), 4: (2, 1), 5: (2, -1)}
    bridges = find_bridges(G)

    # Panel 1: Original graph with bridge highlighted
    ax = axes[0]
    nx.draw(G, pos, ax=ax, with_labels=True, node_color='#3498db',
            edge_color=edge_colors(G, bridges),
            width=edge_widths(G, bridges),
            node_size=600, font_color='white', font_weight='bold')
    ax.set_title('Original graph\nBridge: {2, 3}', fontsize=11)

    # Panel 2: After removing the bridge — two components
    G2 = G.copy()
    G2.remove_edge(2, 3)
    components = list(nx.connected_components(G2))

    colors = []
    for node in G2.nodes():
        if node in components[0]:
            colors.append('#2ecc71')  # green component
        else:
            colors.append('#9b59b6')  # purple component

    ax = axes[1]
    nx.draw(G2, pos, ax=ax, with_labels=True, node_color=colors,
            edge_color='#7f8c8d', width=2,
            node_size=600, font_color='white', font_weight='bold')
    ax.set_title(f'After removing bridge {{2,3}}\n{len(components)} disconnected components', fontsize=11)

    # Panel 3: Verify XOR reachability
    ax = axes[2]
    u, v = 2, 3  # bridge endpoints
    data = []
    for w in G2.nodes():
        reach_u = nx.has_path(G2, u, w) if u in G2 and w in G2 else False
        reach_v = nx.has_path(G2, v, w) if v in G2 and w in G2 else False
        data.append((w, reach_u, reach_v, reach_u != reach_v))

    cell_text = [[str(d[0]), '✓' if d[1] else '✗', '✓' if d[2] else '✗',
                  '✓' if d[3] else '✗'] for d in data]
    table = ax.table(cellText=cell_text,
                     colLabels=['Vertex w', f'Reach from {u}', f'Reach from {v}', 'XOR'],
                     cellLoc='center', loc='center')
    table.auto_set_font_size(False)
    table.set_fontsize(11)
    table.scale(1.2, 1.8)
    ax.axis('off')
    ax.set_title('XOR Reachability (Thm 3)\nExactly one endpoint reaches each vertex', fontsize=11)

    plt.tight_layout(rect=[0, 0, 1, 0.93])
    plt.savefig('demo2_bridge_removal.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("✓ Demo 2 saved: demo2_bridge_removal.png")


# ──────────────────────────────────────────────────────────────────────
# Demo 3: Bridgeless ⟺ Every Edge on a Cycle
# ──────────────────────────────────────────────────────────────────────

def demo_bridgeless_cycles():
    """
    Theorem: connected_no_bridges_iff_forall_edge_on_cycle
    A connected graph is bridgeless ⟺ every edge lies on a cycle.
    """
    fig, axes = plt.subplots(1, 3, figsize=(16, 5))
    fig.suptitle('Theorem 4: Bridgeless ⟺ Every Edge Lies on a Cycle',
                 fontsize=14, fontweight='bold')

    # Example 1: Complete graph K5 — bridgeless, every edge on a cycle
    G1 = nx.complete_graph(5)
    bridges1 = find_bridges(G1)
    pos1 = nx.circular_layout(G1)

    ax = axes[0]
    nx.draw(G1, pos1, ax=ax, with_labels=True, node_color='#2ecc71',
            edge_color='#27ae60', width=2,
            node_size=500, font_color='white', font_weight='bold')
    ax.set_title(f'K₅: Bridgeless ✓\n{len(bridges1)} bridges, every edge on a cycle', fontsize=11)

    # Example 2: Petersen graph — bridgeless
    G2 = nx.petersen_graph()
    bridges2 = find_bridges(G2)
    pos2 = nx.shell_layout(G2)

    ax = axes[1]
    nx.draw(G2, pos2, ax=ax, with_labels=True, node_color='#2ecc71',
            edge_color='#27ae60', width=2,
            node_size=400, font_color='white', font_weight='bold', font_size=9)
    ax.set_title(f'Petersen graph: Bridgeless ✓\n{len(bridges2)} bridges', fontsize=11)

    # Example 3: Graph with bridges — some edges NOT on any cycle
    G3 = nx.Graph()
    G3.add_edges_from([(0,1),(1,2),(2,0),(2,3),(3,4),(4,5),(5,3),(5,6)])
    bridges3 = find_bridges(G3)
    pos3 = nx.spring_layout(G3, seed=42)

    ax = axes[2]
    nx.draw(G3, pos3, ax=ax, with_labels=True, node_color='#e67e22',
            edge_color=edge_colors(G3, bridges3),
            width=edge_widths(G3, bridges3),
            node_size=500, font_color='white', font_weight='bold')
    ax.set_title(f'Has bridges ✗\n{len(bridges3)} bridge(s) not on any cycle', fontsize=11)

    red_patch = mpatches.Patch(color='#e74c3c', label='Bridge (not on cycle)')
    green_patch = mpatches.Patch(color='#27ae60', label='Non-bridge (on a cycle)')
    fig.legend(handles=[green_patch, red_patch], loc='lower center', ncol=2, fontsize=11)

    plt.tight_layout(rect=[0, 0.06, 1, 0.95])
    plt.savefig('demo3_bridgeless_cycles.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("✓ Demo 3 saved: demo3_bridgeless_cycles.png")


# ──────────────────────────────────────────────────────────────────────
# Demo 4: Bridge Counting in Trees
# ──────────────────────────────────────────────────────────────────────

def demo_bridge_counting():
    """
    Theorem: IsTree.card_bridges
    A tree on n vertices has exactly n-1 bridges.
    """
    fig, axes = plt.subplots(2, 3, figsize=(16, 10))
    fig.suptitle('Theorem 5: Trees on n Vertices Have Exactly n−1 Bridges',
                 fontsize=14, fontweight='bold')

    trees = [
        ("Path P₃", nx.path_graph(3)),
        ("Star K₁,₃", nx.star_graph(3)),
        ("Path P₅", nx.path_graph(5)),
        ("Binary tree", nx.balanced_tree(2, 2)),
        ("Caterpillar", None),  # custom
        ("Random tree (n=10)", nx.random_labeled_tree(10, seed=42)),
    ]

    # Build caterpillar
    cat = nx.path_graph(5)
    cat.add_edges_from([(0,5),(1,6),(2,7),(3,8)])
    trees[4] = ("Caterpillar", cat)

    for idx, (name, T) in enumerate(trees):
        ax = axes[idx // 3][idx % 3]
        n = T.number_of_nodes()
        bridges = find_bridges(T)
        pos = nx.spring_layout(T, seed=42)

        nx.draw(T, pos, ax=ax, with_labels=True, node_color='#3498db',
                edge_color='#e74c3c', width=2.5,
                node_size=400, font_color='white', font_weight='bold', font_size=9)

        verified = "✓" if len(bridges) == n - 1 else "✗"
        ax.set_title(f'{name}\nn={n}, bridges={len(bridges)}={n}−1 {verified}', fontsize=10)

    plt.tight_layout(rect=[0, 0, 1, 0.95])
    plt.savefig('demo4_bridge_counting.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("✓ Demo 4 saved: demo4_bridge_counting.png")


# ──────────────────────────────────────────────────────────────────────
# Demo 5: Network Reliability Application
# ──────────────────────────────────────────────────────────────────────

def demo_network_reliability():
    """
    Application: Identifying bridges reveals single points of failure
    in communication networks.
    """
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))
    fig.suptitle('Application: Network Reliability — Bridges as Single Points of Failure',
                 fontsize=14, fontweight='bold')

    # Build a network topology
    G = nx.Graph()
    # Core network (well-connected)
    G.add_edges_from([(0,1),(1,2),(2,3),(3,0),(0,2)])
    # Branch offices connected by single links (bridges!)
    G.add_edges_from([(1,4),(3,5),(5,6)])
    # Labels
    labels = {0: 'HQ', 1: 'DC-1', 2: 'DC-2', 3: 'DC-3',
              4: 'Branch-A', 5: 'Branch-B', 6: 'Branch-C'}

    pos = {0: (0, 0), 1: (2, 1), 2: (2, -1), 3: (0, -2),
           4: (4, 2), 5: (-2, -2), 6: (-2, -4)}

    bridges = find_bridges(G)

    # Panel 1: Network with bridges highlighted
    ax = axes[0]
    nx.draw(G, pos, ax=ax, labels=labels, node_color='#3498db',
            edge_color=edge_colors(G, bridges),
            width=edge_widths(G, bridges),
            node_size=800, font_color='white', font_weight='bold', font_size=8)
    ax.set_title(f'Corporate Network\n{len(bridges)} bridge links (single points of failure)', fontsize=11)

    red_patch = mpatches.Patch(color='#e74c3c', label=f'Bridge ({len(bridges)} links)')
    gray_patch = mpatches.Patch(color='#95a5a6', label='Redundant link')
    ax.legend(handles=[red_patch, gray_patch], loc='upper left', fontsize=9)

    # Panel 2: Reliability analysis — what disconnects if each bridge fails?
    ax = axes[1]
    analysis = []
    for u, v in bridges:
        G_temp = G.copy()
        G_temp.remove_edge(u, v)
        components = list(nx.connected_components(G_temp))
        isolated = [c for c in components if len(c) < len(G.nodes())]
        isolated_nodes = []
        for c in isolated:
            isolated_nodes.extend([labels.get(n, str(n)) for n in c])
        analysis.append((f'{labels[u]}—{labels[v]}',
                         len(components),
                         ', '.join(isolated_nodes) if isolated_nodes else 'None'))

    cell_text = [[a[0], str(a[1]), a[2]] for a in analysis]
    table = ax.table(cellText=cell_text,
                     colLabels=['Bridge Link', 'Components\nAfter Failure', 'Isolated Nodes'],
                     cellLoc='center', loc='center')
    table.auto_set_font_size(False)
    table.set_fontsize(10)
    table.scale(1.2, 2.0)

    # Color header row
    for j in range(3):
        table[0, j].set_facecolor('#3498db')
        table[0, j].set_text_props(color='white', fontweight='bold')
    for i in range(1, len(analysis) + 1):
        for j in range(3):
            table[i, j].set_facecolor('#ffeaea')

    ax.axis('off')
    ax.set_title('Impact Analysis: What Breaks?', fontsize=11)

    plt.tight_layout(rect=[0, 0, 1, 0.93])
    plt.savefig('demo5_network_reliability.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("✓ Demo 5 saved: demo5_network_reliability.png")


# ──────────────────────────────────────────────────────────────────────
# Demo 6: Königsberg Bridge Problem
# ──────────────────────────────────────────────────────────────────────

def demo_konigsberg():
    """
    Historical application: The Königsberg Bridge Problem (Euler, 1736).
    Every edge in the Königsberg multigraph is a bridge-like critical link;
    this demo shows the connection between Euler's foundational work and
    modern bridge theory.
    """
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))
    fig.suptitle('Historical Context: From Königsberg Bridges to Graph Theory',
                 fontsize=14, fontweight='bold')

    # Simplified Königsberg graph (simple graph version)
    # 4 landmasses: A (north), B (south), C (west island), D (east)
    G = nx.MultiGraph()
    G.add_edges_from([
        ('North', 'Island'), ('North', 'Island'),  # 2 bridges
        ('South', 'Island'), ('South', 'Island'),  # 2 bridges
        ('North', 'East'),                          # 1 bridge
        ('South', 'East'),                          # 1 bridge
        ('Island', 'East'),                         # 1 bridge
    ])

    pos = {'North': (0, 1.5), 'South': (0, -1.5),
           'Island': (-2, 0), 'East': (2, 0)}

    ax = axes[0]
    nx.draw(G, pos, ax=ax, with_labels=True, node_color='#e67e22',
            edge_color='#2c3e50', width=2.5, connectionstyle='arc3,rad=0.15',
            node_size=1200, font_color='white', font_weight='bold', font_size=9)
    ax.set_title('Königsberg Bridges (1736)\n7 bridges, all vertices have odd degree\n→ No Euler circuit exists',
                 fontsize=11)

    # Simple graph version with bridge analysis
    G_simple = nx.Graph()
    G_simple.add_edges_from([
        ('N', 'I'), ('S', 'I'), ('N', 'E'), ('S', 'E'), ('I', 'E')
    ])
    bridges_simple = find_bridges(G_simple)
    pos2 = {'N': (0, 1.5), 'S': (0, -1.5), 'I': (-2, 0), 'E': (2, 0)}

    ax = axes[1]
    nx.draw(G_simple, pos2, ax=ax, with_labels=True, node_color='#3498db',
            edge_color=edge_colors(G_simple, bridges_simple),
            width=edge_widths(G_simple, bridges_simple),
            node_size=1000, font_color='white', font_weight='bold', font_size=10)

    labels = {('N','I'): 'bridge?' , ('S','I'): 'bridge?'}
    ax.set_title(f'Simple graph version\n{len(bridges_simple)} bridge(s) found\n'
                 f'Removing any bridge disconnects the graph (Thm 2)',
                 fontsize=11)

    plt.tight_layout(rect=[0, 0, 1, 0.93])
    plt.savefig('demo6_konigsberg.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("✓ Demo 6 saved: demo6_konigsberg.png")


# ──────────────────────────────────────────────────────────────────────
# Main
# ──────────────────────────────────────────────────────────────────────

if __name__ == '__main__':
    print("=" * 60)
    print("Graph Bridges: Demonstrations of Formally Verified Theorems")
    print("=" * 60)
    print()

    demo_tree_characterization()
    demo_bridge_removal()
    demo_bridgeless_cycles()
    demo_bridge_counting()
    demo_network_reliability()
    demo_konigsberg()

    print()
    print("All demos generated successfully!")
    print()
    print("Theorems demonstrated:")
    print("  1. Tree ⟺ Connected + Every Edge is a Bridge")
    print("  2. Bridge Removal Disconnects a Connected Graph")
    print("  3. Bridge Removal Partitions Vertices (XOR Reachability)")
    print("  4. Bridgeless ⟺ Every Edge on a Cycle")
    print("  5. Trees on n Vertices Have Exactly n−1 Bridges")
    print()
    print("Applications demonstrated:")
    print("  • Network Reliability Analysis")
    print("  • Historical: Königsberg Bridge Problem")
