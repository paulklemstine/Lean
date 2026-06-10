#!/usr/bin/env python3
"""
Bridge Demo: Visualizing Graph Bridges and the Königsberg Problem

This script demonstrates the mathematical concepts formalized in our Lean proofs:
1. Graph bridges (cut edges) and their identification
2. Two-edge-connectivity
3. The Königsberg Bridge Problem
4. Euler's degree parity condition for Eulerian trails

Requirements: pip install networkx matplotlib numpy
"""

import networkx as nx
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np
from itertools import combinations


def find_bridges(G):
    """Find all bridges in a graph using DFS (Tarjan's algorithm)."""
    return list(nx.bridges(G))


def is_two_edge_connected(G):
    """Check if a graph is 2-edge-connected (connected with no bridges)."""
    if not nx.is_connected(G):
        return False
    return len(find_bridges(G)) == 0


def classify_edges(G):
    """Classify each edge as a bridge or non-bridge."""
    bridge_set = set(frozenset(e) for e in find_bridges(G))
    bridges = []
    non_bridges = []
    for e in G.edges():
        if frozenset(e) in bridge_set:
            bridges.append(e)
        else:
            non_bridges.append(e)
    return bridges, non_bridges


def draw_graph_with_bridges(G, pos, ax, title=""):
    """Draw a graph highlighting bridges in red and non-bridges in blue."""
    bridges, non_bridges = classify_edges(G)

    # Draw non-bridge edges
    if non_bridges:
        nx.draw_networkx_edges(G, pos, edgelist=non_bridges, edge_color='steelblue',
                               width=2.5, ax=ax, alpha=0.8)
    # Draw bridge edges
    if bridges:
        nx.draw_networkx_edges(G, pos, edgelist=bridges, edge_color='crimson',
                               width=3.5, ax=ax, style='solid', alpha=0.9)

    # Draw nodes
    degrees = dict(G.degree())
    node_colors = ['#FFD700' if degrees[n] % 2 == 1 else '#90EE90' for n in G.nodes()]
    nx.draw_networkx_nodes(G, pos, node_color=node_colors, node_size=600,
                           edgecolors='black', linewidths=1.5, ax=ax)

    # Draw labels with degree info
    labels = {n: f"{n}\n(d={degrees[n]})" for n in G.nodes()}
    nx.draw_networkx_labels(G, pos, labels, font_size=8, font_weight='bold', ax=ax)

    ax.set_title(title, fontsize=12, fontweight='bold')
    ax.axis('off')


# ============================================================
# DEMO 1: Bridge Identification in Various Graphs
# ============================================================

def demo_bridge_identification():
    """Demonstrate bridge identification in several graph types."""
    fig, axes = plt.subplots(2, 3, figsize=(18, 12))
    fig.suptitle("Bridge Identification in Graphs\n"
                 "(Red edges = bridges, Yellow nodes = odd degree)",
                 fontsize=16, fontweight='bold')

    # 1. Path graph (all edges are bridges)
    G1 = nx.path_graph(5)
    pos1 = {i: (i, 0) for i in range(5)}
    bridges1, _ = classify_edges(G1)
    draw_graph_with_bridges(G1, pos1, axes[0, 0],
                           f"Path P₅: {len(bridges1)} bridges (all edges)")

    # 2. Cycle graph (no bridges — 2-edge-connected)
    G2 = nx.cycle_graph(6)
    pos2 = nx.circular_layout(G2)
    bridges2, _ = classify_edges(G2)
    draw_graph_with_bridges(G2, pos2, axes[0, 1],
                           f"Cycle C₆: {len(bridges2)} bridges (2-edge-connected)")

    # 3. Tree (all edges are bridges)
    G3 = nx.balanced_tree(2, 2)  # Binary tree of depth 2
    pos3 = nx.spring_layout(G3, seed=42)
    bridges3, _ = classify_edges(G3)
    draw_graph_with_bridges(G3, pos3, axes[0, 2],
                           f"Binary Tree: {len(bridges3)} bridges (all edges)")

    # 4. Graph with some bridges
    G4 = nx.Graph()
    G4.add_edges_from([(0,1), (1,2), (2,0),  # triangle
                       (2,3),                   # bridge!
                       (3,4), (4,5), (5,3)])    # another triangle
    pos4 = {0: (0,1), 1: (1,1), 2: (1,0), 3: (2,0), 4: (3,0), 5: (3,1)}
    bridges4, _ = classify_edges(G4)
    draw_graph_with_bridges(G4, pos4, axes[1, 0],
                           f"Two triangles + bridge: {len(bridges4)} bridge")

    # 5. Petersen graph (3-edge-connected, no bridges)
    G5 = nx.petersen_graph()
    pos5 = nx.shell_layout(G5, nlist=[range(5), range(5, 10)])
    bridges5, _ = classify_edges(G5)
    draw_graph_with_bridges(G5, pos5, axes[1, 1],
                           f"Petersen Graph: {len(bridges5)} bridges (3-edge-connected)")

    # 6. K₄ (the Königsberg model — no bridges but all odd degree)
    G6 = nx.complete_graph(4)
    pos6 = {0: (0,1), 1: (1,1), 2: (0,0), 3: (1,0)}
    bridges6, _ = classify_edges(G6)
    draw_graph_with_bridges(G6, pos6, axes[1, 2],
                           f"K₄ (Königsberg): {len(bridges6)} bridges, all odd degree")

    plt.tight_layout()
    plt.savefig("demos/bridge_identification.png", dpi=150, bbox_inches='tight')
    plt.close()
    print("✓ Saved: demos/bridge_identification.png")


# ============================================================
# DEMO 2: The Königsberg Bridge Problem
# ============================================================

def demo_konigsberg():
    """Visualize the Königsberg bridge problem."""
    fig, axes = plt.subplots(1, 3, figsize=(18, 6))
    fig.suptitle("The Königsberg Bridge Problem (1736)",
                 fontsize=16, fontweight='bold')

    # Original Königsberg layout (multigraph representation)
    ax = axes[0]
    ax.set_xlim(-0.5, 3.5)
    ax.set_ylim(-0.5, 2.5)

    # Draw landmasses
    positions = {'A': (1.5, 2.2), 'B': (1.5, -0.2), 'C': (0, 1), 'D': (3, 1)}
    colors = {'A': '#FFB347', 'B': '#87CEEB', 'C': '#98FB98', 'D': '#DDA0DD'}

    for name, (x, y) in positions.items():
        circle = plt.Circle((x, y), 0.25, color=colors[name], ec='black', lw=2, zorder=5)
        ax.add_patch(circle)
        ax.text(x, y, name, ha='center', va='center', fontsize=14, fontweight='bold', zorder=6)

    # Draw bridges (7 bridges of Königsberg)
    bridge_pairs = [
        ('A', 'C', -0.15), ('A', 'C', 0.15),  # 2 bridges A-C
        ('A', 'D', 0),                          # 1 bridge A-D
        ('B', 'C', -0.15), ('B', 'C', 0.15),  # 2 bridges B-C
        ('B', 'D', 0),                          # 1 bridge B-D
        ('C', 'D', 0),                          # 1 bridge C-D
    ]

    for src, dst, offset in bridge_pairs:
        x1, y1 = positions[src]
        x2, y2 = positions[dst]
        dx, dy = x2 - x1, y2 - y1
        length = np.sqrt(dx**2 + dy**2)
        nx_dir, ny_dir = -dy/length, dx/length
        ax.annotate('', xy=(x2 + nx_dir*offset, y2 + ny_dir*offset),
                    xytext=(x1 + nx_dir*offset, y1 + ny_dir*offset),
                    arrowprops=dict(arrowstyle='-', color='brown', lw=2.5))

    ax.set_title("The Seven Bridges\n(Multigraph)", fontsize=11)
    ax.axis('off')
    ax.set_aspect('equal')

    # Degree analysis
    ax = axes[1]
    vertices = ['A', 'B', 'C', 'D']
    degrees = [3, 3, 5, 3]  # Original Königsberg degrees
    bar_colors = ['#FF6B6B' if d % 2 == 1 else '#90EE90' for d in degrees]

    bars = ax.bar(vertices, degrees, color=bar_colors, edgecolor='black', linewidth=1.5)
    ax.axhline(y=2, color='gray', linestyle='--', alpha=0.5, label='Even threshold')
    ax.set_ylabel('Degree', fontsize=12)
    ax.set_title("Vertex Degrees (Original)\nAll vertices have ODD degree!", fontsize=11)
    ax.set_ylim(0, 6)

    for bar, d in zip(bars, degrees):
        ax.text(bar.get_x() + bar.get_width()/2, bar.get_height() + 0.1,
                f'd={d}\n({"odd" if d%2==1 else "even"})',
                ha='center', fontsize=10, fontweight='bold')

    # K₄ model and Euler's theorem
    ax = axes[2]
    G_k4 = nx.complete_graph(4)
    pos_k4 = {0: (0,1), 1: (1,1), 2: (0,0), 3: (1,0)}
    node_labels = {0: 'A', 1: 'B', 2: 'C', 3: 'D'}

    nx.draw_networkx_edges(G_k4, pos_k4, edge_color='steelblue', width=2.5, ax=ax)
    nx.draw_networkx_nodes(G_k4, pos_k4, node_color='#FFD700', node_size=600,
                           edgecolors='black', linewidths=1.5, ax=ax)
    labels = {n: f"{node_labels[n]}\n(d=3)" for n in G_k4.nodes()}
    nx.draw_networkx_labels(G_k4, pos_k4, labels, font_size=9, font_weight='bold', ax=ax)

    ax.set_title("K₄ Model (Simple Graph)\n4 odd-degree vertices > 2 ⟹ No Euler trail!",
                 fontsize=11)
    ax.axis('off')

    plt.tight_layout()
    plt.savefig("demos/konigsberg_problem.png", dpi=150, bbox_inches='tight')
    plt.close()
    print("✓ Saved: demos/konigsberg_problem.png")


# ============================================================
# DEMO 3: Two-Edge-Connectivity and Cycle Structure
# ============================================================

def demo_two_edge_connectivity():
    """Demonstrate the bridge-cycle duality theorem."""
    fig, axes = plt.subplots(1, 3, figsize=(18, 6))
    fig.suptitle("Two-Edge-Connectivity: Every Edge on a Cycle ⟺ No Bridges",
                 fontsize=16, fontweight='bold')

    # Graph 1: 2-edge-connected
    G1 = nx.Graph()
    G1.add_edges_from([(0,1), (1,2), (2,3), (3,0), (0,2)])
    pos1 = {0: (0,1), 1: (1,1), 2: (1,0), 3: (0,0)}

    ax = axes[0]
    cycle_edges = [(0,1), (1,2), (2,0)]
    other_edges = [(e[0],e[1]) for e in G1.edges()
                   if (e[0],e[1]) not in cycle_edges and (e[1],e[0]) not in cycle_edges]

    nx.draw_networkx_edges(G1, pos1, edgelist=other_edges, edge_color='gray',
                           width=2, ax=ax, alpha=0.5)
    nx.draw_networkx_edges(G1, pos1, edgelist=cycle_edges, edge_color='#FF6B6B',
                           width=3.5, ax=ax)
    nx.draw_networkx_nodes(G1, pos1, node_color='#90EE90', node_size=600,
                           edgecolors='black', linewidths=1.5, ax=ax)
    nx.draw_networkx_labels(G1, pos1, font_size=12, font_weight='bold', ax=ax)
    ax.set_title("2-Edge-Connected\nEdge (1,2) lies on cycle 0→1→2→0", fontsize=11)
    ax.axis('off')

    # Graph 2: Has a bridge
    G2 = nx.Graph()
    G2.add_edges_from([(0,1), (1,2), (2,0), (2,3), (3,4), (4,5), (5,3)])
    pos2 = {0: (0,1), 1: (1,1), 2: (1,0), 3: (2,0), 4: (3,0), 5: (3,1)}

    ax = axes[1]
    bridges2, non_bridges2 = classify_edges(G2)
    nx.draw_networkx_edges(G2, pos2, edgelist=non_bridges2, edge_color='steelblue',
                           width=2.5, ax=ax)
    nx.draw_networkx_edges(G2, pos2, edgelist=bridges2, edge_color='crimson',
                           width=3.5, ax=ax)
    nx.draw_networkx_nodes(G2, pos2, node_color='#FFD700', node_size=600,
                           edgecolors='black', linewidths=1.5, ax=ax)
    nx.draw_networkx_labels(G2, pos2, font_size=12, font_weight='bold', ax=ax)
    ax.set_title("NOT 2-Edge-Connected\nBridge (2,3) lies on NO cycle", fontsize=11)
    ax.axis('off')

    # Graph 3: Tree
    G3 = nx.Graph()
    G3.add_edges_from([(0,1), (0,2), (1,3), (1,4), (2,5)])
    pos3 = {0: (1,2), 1: (0,1), 2: (2,1), 3: (-0.5,0), 4: (0.5,0), 5: (2.5,0)}

    ax = axes[2]
    bridges3, _ = classify_edges(G3)
    nx.draw_networkx_edges(G3, pos3, edgelist=bridges3, edge_color='crimson',
                           width=3.5, ax=ax)
    nx.draw_networkx_nodes(G3, pos3, node_color='#FFD700', node_size=600,
                           edgecolors='black', linewidths=1.5, ax=ax)
    nx.draw_networkx_labels(G3, pos3, font_size=12, font_weight='bold', ax=ax)
    ax.set_title("Tree: ALL edges are bridges\n(Acyclic ⟺ every edge is a bridge)", fontsize=11)
    ax.axis('off')

    plt.tight_layout()
    plt.savefig("demos/two_edge_connectivity.png", dpi=150, bbox_inches='tight')
    plt.close()
    print("✓ Saved: demos/two_edge_connectivity.png")


# ============================================================
# DEMO 4: Euler's Degree Condition — Analysis Table
# ============================================================

def demo_euler_condition():
    """Analyze various graphs for Eulerian trail/circuit existence."""
    graphs = [
        ("K₃ (Triangle)", nx.complete_graph(3)),
        ("K₄ (Königsberg)", nx.complete_graph(4)),
        ("K₅", nx.complete_graph(5)),
        ("C₆ (Hexagon)", nx.cycle_graph(6)),
        ("Petersen", nx.petersen_graph()),
        ("Path P₄", nx.path_graph(4)),
    ]

    print("\n" + "="*70)
    print("  EULER'S DEGREE CONDITION FOR EULERIAN TRAILS/CIRCUITS")
    print("="*70)
    print(f"{'Graph':<20} {'|V|':>4} {'|E|':>4} {'Odd deg':>8} {'Circuit?':>10} {'Trail?':>8}")
    print("-"*70)

    for name, G in graphs:
        n = G.number_of_nodes()
        m = G.number_of_edges()
        degrees = dict(G.degree())
        odd_count = sum(1 for d in degrees.values() if d % 2 == 1)
        has_circuit = odd_count == 0 and nx.is_connected(G)
        has_trail = odd_count <= 2 and nx.is_connected(G)

        circuit_str = "YES ✓" if has_circuit else "NO ✗"
        trail_str = "YES ✓" if has_trail else "NO ✗"
        print(f"{name:<20} {n:>4} {m:>4} {odd_count:>8} {circuit_str:>10} {trail_str:>8}")

    print("-"*70)
    print("Rule: Circuit exists ⟺ connected + 0 odd-degree vertices")
    print("      Trail exists   ⟺ connected + 0 or 2 odd-degree vertices")
    print("="*70)


# ============================================================
# DEMO 5: Bridge Removal Effect
# ============================================================

def demo_bridge_removal():
    """Show what happens when you remove a bridge vs a non-bridge."""
    fig, axes = plt.subplots(1, 3, figsize=(18, 5))
    fig.suptitle("Effect of Edge Removal: Bridges vs Non-Bridges",
                 fontsize=16, fontweight='bold')

    # Original graph
    G = nx.Graph()
    G.add_edges_from([(0,1), (1,2), (2,0), (2,3), (3,4), (4,5), (5,3)])
    pos = {0: (0,1), 1: (1,1), 2: (1,0), 3: (2,0), 4: (3,0), 5: (3,1)}

    ax = axes[0]
    draw_graph_with_bridges(G, pos, ax, "Original Graph\n(bridge (2,3) in red)")

    # Remove non-bridge edge (0,1) — graph stays connected
    G_no_nonbridge = G.copy()
    G_no_nonbridge.remove_edge(0, 1)
    ax = axes[1]
    components = list(nx.connected_components(G_no_nonbridge))
    draw_graph_with_bridges(G_no_nonbridge, pos, ax,
                           f"Remove non-bridge (0,1)\n→ Still connected ({len(components)} component)")

    # Remove bridge edge (2,3) — graph disconnects
    G_no_bridge = G.copy()
    G_no_bridge.remove_edge(2, 3)
    ax = axes[2]
    components = list(nx.connected_components(G_no_bridge))
    palette = ['#FF9999', '#99CCFF']

    nx.draw_networkx_edges(G_no_bridge, pos, edge_color='gray', width=2, ax=ax)
    for i, comp in enumerate(components):
        nx.draw_networkx_nodes(G_no_bridge, pos, nodelist=list(comp),
                               node_color=palette[i % 2], node_size=600,
                               edgecolors='black', linewidths=1.5, ax=ax)
    # Draw removed edge as dashed
    ax.plot([pos[2][0], pos[3][0]], [pos[2][1], pos[3][1]],
            'r--', linewidth=2, alpha=0.5)
    nx.draw_networkx_labels(G_no_bridge, pos, font_size=12, font_weight='bold', ax=ax)
    ax.set_title(f"Remove bridge (2,3)\n→ Disconnected! ({len(components)} components)",
                 fontsize=11)
    ax.axis('off')

    plt.tight_layout()
    plt.savefig("demos/bridge_removal.png", dpi=150, bbox_inches='tight')
    plt.close()
    print("✓ Saved: demos/bridge_removal.png")


# ============================================================
# MAIN
# ============================================================

if __name__ == "__main__":
    print("╔══════════════════════════════════════════════════════════════╗")
    print("║       Graph Bridges & Königsberg Problem — Demo Suite      ║")
    print("║                                                            ║")
    print("║  Companion to Lean 4 formal proofs in Bridges/             ║")
    print("╚══════════════════════════════════════════════════════════════╝")
    print()

    demo_bridge_identification()
    demo_konigsberg()
    demo_two_edge_connectivity()
    demo_euler_condition()
    demo_bridge_removal()

    print("\n✓ All demos complete! Check the generated PNG files in demos/.")


#!/usr/bin/env python3
"""
Network Resilience Analysis Using Bridge Theory

This script demonstrates practical applications of bridge theory
to real-world network design and reliability assessment.

The key insight from our formal proofs:
  - A network is 2-edge-connected ⟺ every link participates in a cycle
  - Bridges are single points of failure
  - Eulerian traversal requires ≤ 2 odd-degree nodes

Requirements: pip install networkx matplotlib
"""

import networkx as nx
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import random


def analyze_network(G, name="Network"):
    """Comprehensive bridge-theoretic analysis of a network."""
    print(f"\n{'='*60}")
    print(f"  Network Analysis: {name}")
    print(f"{'='*60}")

    n = G.number_of_nodes()
    m = G.number_of_edges()
    print(f"  Vertices: {n}, Edges: {m}")

    if not nx.is_connected(G):
        components = list(nx.connected_components(G))
        print(f"  ⚠ DISCONNECTED: {len(components)} components")
        return

    bridges = list(nx.bridges(G))
    print(f"  Bridges (single points of failure): {len(bridges)}")
    if bridges:
        for b in bridges:
            print(f"    - Edge {b}")

    is_2ec = len(bridges) == 0
    print(f"  2-Edge-Connected: {'YES ✓' if is_2ec else 'NO ✗'}")

    if is_2ec:
        print(f"  → Every link participates in a redundant cycle.")
        print(f"  → No single link failure can disconnect the network.")
    else:
        # Compute 2-edge-connected components
        components_2ec = list(nx.biconnected_components(G))
        print(f"  2-Edge-Connected Components: {len(components_2ec)}")
        print(f"  → Removing any bridge disconnects the network!")

    # Degree analysis
    degrees = dict(G.degree())
    odd_degree = [v for v, d in degrees.items() if d % 2 == 1]
    even_degree = [v for v, d in degrees.items() if d % 2 == 0]

    print(f"\n  Degree Analysis:")
    print(f"    Odd-degree vertices:  {len(odd_degree)}")
    print(f"    Even-degree vertices: {len(even_degree)}")

    if len(odd_degree) == 0:
        print(f"    → Eulerian CIRCUIT exists (can traverse all edges in a loop)")
    elif len(odd_degree) == 2:
        print(f"    → Eulerian TRAIL exists (start at {odd_degree[0]}, end at {odd_degree[1]})")
    else:
        print(f"    → NO Eulerian trail possible ({len(odd_degree)} > 2 odd-degree vertices)")

    # Vulnerability score
    vulnerability = len(bridges) / m if m > 0 else 0
    print(f"\n  Vulnerability Score: {vulnerability:.1%} of edges are bridges")
    if vulnerability == 0:
        print(f"    Rating: ★★★★★ EXCELLENT - Fully redundant")
    elif vulnerability < 0.1:
        print(f"    Rating: ★★★★☆ GOOD - Few vulnerabilities")
    elif vulnerability < 0.3:
        print(f"    Rating: ★★★☆☆ MODERATE - Some risk")
    elif vulnerability < 0.5:
        print(f"    Rating: ★★☆☆☆ POOR - Significant risk")
    else:
        print(f"    Rating: ★☆☆☆☆ CRITICAL - Most edges are bridges")


def demo_network_design():
    """Show how adding edges to eliminate bridges improves resilience."""
    fig, axes = plt.subplots(1, 3, figsize=(18, 6))
    fig.suptitle("Network Resilience: Eliminating Bridges Through Redundancy",
                 fontsize=16, fontweight='bold')

    # Stage 1: Tree network (all bridges)
    G1 = nx.Graph()
    G1.add_edges_from([(0,1), (1,2), (1,3), (3,4), (3,5), (0,6), (6,7)])
    pos = {0:(2,2), 1:(1,1), 2:(0,0), 3:(2,0), 4:(1,-1), 5:(3,-1), 6:(3,1), 7:(4,0)}

    bridges1 = list(nx.bridges(G1))
    ax = axes[0]
    nx.draw_networkx_edges(G1, pos, edge_color='crimson', width=3, ax=ax)
    nx.draw_networkx_nodes(G1, pos, node_color='#FFD700', node_size=500,
                           edgecolors='black', linewidths=1.5, ax=ax)
    nx.draw_networkx_labels(G1, pos, font_size=10, font_weight='bold', ax=ax)
    ax.set_title(f"Tree Network\n{len(bridges1)}/{G1.number_of_edges()} edges are bridges (100%)\n"
                 f"Rating: ★☆☆☆☆ CRITICAL", fontsize=11, color='red')
    ax.axis('off')

    # Stage 2: Add some redundancy
    G2 = G1.copy()
    G2.add_edges_from([(2,3), (4,5)])  # Add two cycle-creating edges
    bridges2 = list(nx.bridges(G2))

    ax = axes[1]
    bridge_set2 = set(frozenset(e) for e in bridges2)
    bridge_edges2 = [e for e in G2.edges() if frozenset(e) in bridge_set2]
    non_bridge_edges2 = [e for e in G2.edges() if frozenset(e) not in bridge_set2]

    nx.draw_networkx_edges(G2, pos, edgelist=non_bridge_edges2, edge_color='steelblue',
                           width=2.5, ax=ax)
    nx.draw_networkx_edges(G2, pos, edgelist=bridge_edges2, edge_color='crimson',
                           width=3, ax=ax)
    # Highlight new edges
    nx.draw_networkx_edges(G2, pos, edgelist=[(2,3), (4,5)], edge_color='green',
                           width=3, style='dashed', ax=ax)
    nx.draw_networkx_nodes(G2, pos, node_color='#FFD700', node_size=500,
                           edgecolors='black', linewidths=1.5, ax=ax)
    nx.draw_networkx_labels(G2, pos, font_size=10, font_weight='bold', ax=ax)
    ax.set_title(f"Add 2 redundant links (green dashed)\n"
                 f"{len(bridges2)}/{G2.number_of_edges()} edges are bridges "
                 f"({100*len(bridges2)/G2.number_of_edges():.0f}%)\n"
                 f"Rating: ★★★☆☆ MODERATE", fontsize=11, color='orange')
    ax.axis('off')

    # Stage 3: Fully 2-edge-connected
    G3 = G2.copy()
    G3.add_edges_from([(0,3), (6,1), (7,5)])
    bridges3 = list(nx.bridges(G3))

    ax = axes[2]
    nx.draw_networkx_edges(G3, pos, edge_color='steelblue', width=2.5, ax=ax)
    nx.draw_networkx_edges(G3, pos, edgelist=[(0,3), (6,1), (7,5)],
                           edge_color='green', width=3, style='dashed', ax=ax)
    nx.draw_networkx_nodes(G3, pos, node_color='#90EE90', node_size=500,
                           edgecolors='black', linewidths=1.5, ax=ax)
    nx.draw_networkx_labels(G3, pos, font_size=10, font_weight='bold', ax=ax)
    ax.set_title(f"Fully 2-Edge-Connected\n"
                 f"{len(bridges3)}/{G3.number_of_edges()} bridges (0%)\n"
                 f"Rating: ★★★★★ EXCELLENT", fontsize=11, color='green')
    ax.axis('off')

    plt.tight_layout()
    plt.savefig("demos/network_resilience.png", dpi=150, bbox_inches='tight')
    plt.close()
    print("✓ Saved: demos/network_resilience.png")


def demo_real_world_networks():
    """Analyze bridge structure of well-known graph families."""
    print("\n" + "="*60)
    print("  REAL-WORLD NETWORK ARCHETYPES")
    print("="*60)

    # Star network (hub-and-spoke)
    G_star = nx.star_graph(5)
    analyze_network(G_star, "Star (Hub-and-Spoke, 6 nodes)")

    # Ring network
    G_ring = nx.cycle_graph(8)
    analyze_network(G_ring, "Ring (8 nodes)")

    # Mesh network
    G_mesh = nx.grid_2d_graph(3, 3)
    analyze_network(G_mesh, "Grid Mesh (3×3)")

    # Small-world network
    G_sw = nx.watts_strogatz_graph(20, 4, 0.3, seed=42)
    analyze_network(G_sw, "Small-World (20 nodes, k=4, p=0.3)")

    # Internet-like topology (Barabási–Albert)
    G_ba = nx.barabasi_albert_graph(30, 2, seed=42)
    analyze_network(G_ba, "Scale-Free / Internet-like (30 nodes)")


if __name__ == "__main__":
    print("╔══════════════════════════════════════════════════════════════╗")
    print("║      Network Resilience Analysis Using Bridge Theory       ║")
    print("║                                                            ║")
    print("║  Practical applications of formally verified mathematics   ║")
    print("╚══════════════════════════════════════════════════════════════╝")

    demo_real_world_networks()
    demo_network_design()

    print("\n✓ Analysis complete!")
