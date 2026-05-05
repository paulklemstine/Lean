"""
Bridge Theory and Königsberg Bridge Problem — Interactive Demo

This script demonstrates the mathematical concepts formalized in our Lean proofs:
1. Bridge detection in graphs
2. Euler's degree parity condition for Eulerian circuits
3. The Königsberg Bridge Problem

Requirements: pip install networkx matplotlib
"""

import networkx as nx
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np


def find_bridges(G):
    """Find all bridges (cut edges) in graph G.
    
    A bridge is an edge whose removal disconnects the graph.
    This implements the definition formalized in Lean as SimpleGraph.IsBridge.
    """
    bridges = []
    for u, v in G.edges():
        H = G.copy()
        H.remove_edge(u, v)
        if not nx.is_connected(H):
            bridges.append((u, v))
    return bridges


def has_eulerian_circuit(G):
    """Check if G has an Eulerian circuit.
    
    By Euler's theorem (proven in Lean as Walk.IsEulerianCircuit.even_degree),
    a necessary condition is that every vertex has even degree.
    For connected graphs, this is also sufficient.
    """
    if not nx.is_connected(G):
        return False, "Graph is not connected"
    odd_vertices = [v for v in G.nodes() if G.degree(v) % 2 != 0]
    if odd_vertices:
        return False, f"Vertices {odd_vertices} have odd degree"
    return True, "All vertices have even degree"


def demo_bridges():
    """Demonstrate bridge detection on several example graphs."""
    print("=" * 60)
    print("DEMO 1: Bridge Detection in Graphs")
    print("=" * 60)
    print()
    print("A bridge (cut edge) is an edge whose removal disconnects")
    print("the graph. Our Lean proof shows:")
    print("  • Every edge in a tree is a bridge")
    print("  • A bridge cannot lie on any cycle")
    print()

    fig, axes = plt.subplots(2, 2, figsize=(14, 12))

    # Example 1: A tree (every edge is a bridge)
    T = nx.Graph()
    T.add_edges_from([(0, 1), (1, 2), (1, 3), (3, 4), (3, 5)])
    bridges_T = find_bridges(T)
    
    ax = axes[0, 0]
    pos = nx.spring_layout(T, seed=42)
    edge_colors = ['red' if (u, v) in bridges_T or (v, u) in bridges_T 
                   else 'gray' for u, v in T.edges()]
    nx.draw(T, pos, ax=ax, with_labels=True, node_color='lightblue',
            node_size=500, edge_color=edge_colors, width=2.5,
            font_size=12, font_weight='bold')
    ax.set_title(f"Tree: ALL {len(bridges_T)} edges are bridges", fontsize=13)
    red_patch = mpatches.Patch(color='red', label='Bridge')
    ax.legend(handles=[red_patch], loc='upper left')

    # Example 2: A cycle (no bridges)
    C = nx.cycle_graph(5)
    bridges_C = find_bridges(C)
    
    ax = axes[0, 1]
    pos = nx.spring_layout(C, seed=42)
    nx.draw(C, pos, ax=ax, with_labels=True, node_color='lightgreen',
            node_size=500, edge_color='gray', width=2.5,
            font_size=12, font_weight='bold')
    ax.set_title(f"Cycle: {len(bridges_C)} bridges (edges on a cycle)", fontsize=13)

    # Example 3: Graph with some bridges
    G3 = nx.Graph()
    G3.add_edges_from([(0, 1), (1, 2), (2, 0),  # triangle
                       (2, 3),                     # bridge!
                       (3, 4), (4, 5), (5, 3)])    # another triangle
    bridges_3 = find_bridges(G3)
    
    ax = axes[1, 0]
    pos = {0: (0, 1), 1: (1, 1), 2: (0.5, 0), 3: (2, 0), 4: (3, 1), 5: (2.5, 0)}
    edge_colors = ['red' if (u, v) in bridges_3 or (v, u) in bridges_3 
                   else 'gray' for u, v in G3.edges()]
    nx.draw(G3, pos, ax=ax, with_labels=True, node_color='lightyellow',
            node_size=500, edge_color=edge_colors, width=2.5,
            font_size=12, font_weight='bold')
    ax.set_title(f"Two triangles joined by a bridge ({len(bridges_3)} bridge)", fontsize=13)
    ax.legend(handles=[red_patch], loc='upper left')

    # Example 4: Complete graph K5 (no bridges)
    K5 = nx.complete_graph(5)
    bridges_K5 = find_bridges(K5)
    
    ax = axes[1, 1]
    pos = nx.spring_layout(K5, seed=42)
    nx.draw(K5, pos, ax=ax, with_labels=True, node_color='lightsalmon',
            node_size=500, edge_color='gray', width=2.5,
            font_size=12, font_weight='bold')
    ax.set_title(f"Complete K₅: {len(bridges_K5)} bridges (highly connected)", fontsize=13)

    plt.suptitle("Bridge Detection in Graphs\n(Red edges = bridges)", 
                 fontsize=15, fontweight='bold')
    plt.tight_layout()
    plt.savefig("demos/bridges_detection.png", dpi=150, bbox_inches='tight')
    plt.close()
    print("✓ Saved visualization to demos/bridges_detection.png")
    print()

    # Print summary
    for name, G, bridges in [("Tree", T, bridges_T), ("Cycle C₅", C, bridges_C),
                               ("Two triangles", G3, bridges_3), ("Complete K₅", K5, bridges_K5)]:
        print(f"  {name}: {len(list(G.edges()))} edges, {len(bridges)} bridges")
        degrees = dict(G.degree())
        print(f"    Degrees: {degrees}")
    print()


def demo_konigsberg():
    """Demonstrate the Königsberg Bridge Problem."""
    print("=" * 60)
    print("DEMO 2: The Königsberg Bridge Problem (1736)")
    print("=" * 60)
    print()
    print("The city of Königsberg had 4 landmasses connected by 7 bridges.")
    print("Euler proved it impossible to cross each bridge exactly once.")
    print()

    fig, axes = plt.subplots(1, 2, figsize=(14, 6))

    # The original Königsberg graph (multigraph)
    K = nx.MultiGraph()
    K.add_nodes_from(['North', 'South', 'Island', 'East'])
    K.add_edges_from([
        ('North', 'Island'), ('North', 'Island'),  # 2 bridges
        ('South', 'Island'), ('South', 'Island'),  # 2 bridges
        ('North', 'East'),                          # 1 bridge
        ('South', 'East'),                          # 1 bridge
        ('Island', 'East'),                         # 1 bridge
    ])

    ax = axes[0]
    pos = {'North': (0, 1), 'South': (0, -1), 'Island': (-1.5, 0), 'East': (1.5, 0)}
    
    # Draw the multigraph manually
    ax.set_xlim(-2.5, 2.5)
    ax.set_ylim(-2, 2)
    
    # Draw nodes
    for name, (x, y) in pos.items():
        circle = plt.Circle((x, y), 0.25, color='lightblue', ec='navy', lw=2, zorder=5)
        ax.add_patch(circle)
        ax.text(x, y, name[0], ha='center', va='center', fontsize=14, 
                fontweight='bold', zorder=6)
    
    # Draw edges (with curves for multi-edges)
    edges_drawn = {}
    for u, v in K.edges():
        key = (min(u, v), max(u, v))
        count = edges_drawn.get(key, 0)
        edges_drawn[key] = count + 1
        x1, y1 = pos[u]
        x2, y2 = pos[v]
        
        if count == 0:
            ax.annotate("", xy=(x2, y2), xytext=(x1, y1),
                       arrowprops=dict(arrowstyle="-", lw=2, color='darkred',
                                      connectionstyle=f"arc3,rad=0.2"))
        else:
            ax.annotate("", xy=(x2, y2), xytext=(x1, y1),
                       arrowprops=dict(arrowstyle="-", lw=2, color='darkred',
                                      connectionstyle=f"arc3,rad=-0.2"))
    
    # Add degree labels
    for name in K.nodes():
        deg = K.degree(name)
        x, y = pos[name]
        ax.text(x, y - 0.45, f"deg={deg}", ha='center', fontsize=10, color='red')
    
    ax.set_title("Original Königsberg Graph\n(7 bridges, all degrees odd)", fontsize=13)
    ax.set_aspect('equal')
    ax.axis('off')

    # The simplified simple graph (as in our Lean formalization)
    ax = axes[1]
    G_simple = nx.Graph()
    G_simple.add_edges_from([(0, 1), (0, 2), (0, 3), (1, 2), (1, 3)])
    
    pos_simple = {0: (0, 1), 1: (-1.5, 0), 2: (0, -1), 3: (1.5, 0)}
    labels = {0: 'N', 1: 'I', 2: 'S', 3: 'E'}
    
    node_colors = ['#ff9999' if G_simple.degree(v) % 2 != 0 else 'lightgreen' 
                   for v in G_simple.nodes()]
    
    nx.draw(G_simple, pos_simple, ax=ax, labels=labels, node_color=node_colors,
            node_size=600, edge_color='darkred', width=2.5,
            font_size=14, font_weight='bold')
    
    # Add degree labels
    for v in G_simple.nodes():
        x, y = pos_simple[v]
        deg = G_simple.degree(v)
        color = 'red' if deg % 2 != 0 else 'green'
        ax.text(x, y - 0.25, f"deg={deg}", ha='center', fontsize=10, color=color)
    
    ax.set_title("Lean Formalization Graph (Fin 5)\n(Red nodes = odd degree)", fontsize=13)
    
    plt.suptitle("The Königsberg Bridge Problem\nNo Eulerian circuit exists (proven in Lean)", 
                 fontsize=15, fontweight='bold')
    plt.tight_layout()
    plt.savefig("demos/konigsberg.png", dpi=150, bbox_inches='tight')
    plt.close()
    print("✓ Saved visualization to demos/konigsberg.png")
    print()

    # Analysis
    print("  Degree analysis (original Königsberg graph):")
    for name in ['North', 'South', 'Island', 'East']:
        deg = K.degree(name)
        parity = "ODD ✗" if deg % 2 != 0 else "even ✓"
        print(f"    {name}: degree {deg} ({parity})")
    
    print()
    print("  Euler's Theorem (proven in Lean):")
    print("    An Eulerian circuit requires ALL vertices to have even degree.")
    print("    Since ALL four vertices have odd degree, no Eulerian circuit exists. ∎")
    print()


def demo_euler_criterion():
    """Demonstrate Euler's criterion on various graphs."""
    print("=" * 60)
    print("DEMO 3: Euler's Degree Parity Criterion")
    print("=" * 60)
    print()
    print("Our Lean theorem proves: Eulerian circuit ⟹ all degrees even")
    print("(For connected graphs, the converse also holds.)")
    print()

    graphs = {
        "Triangle (K₃)": nx.cycle_graph(3),
        "Square (C₄)": nx.cycle_graph(4),
        "Petersen": nx.petersen_graph(),
        "Complete K₄": nx.complete_graph(4),
        "Complete K₅": nx.complete_graph(5),
        "Cube Q₃": nx.hypercube_graph(3),
    }

    fig, axes = plt.subplots(2, 3, figsize=(16, 10))
    axes_flat = axes.flatten()

    for idx, (name, G) in enumerate(graphs.items()):
        ax = axes_flat[idx]
        has_euler, reason = has_eulerian_circuit(G)
        
        degrees = [G.degree(v) for v in G.nodes()]
        odd_count = sum(1 for d in degrees if d % 2 != 0)
        
        color = 'lightgreen' if has_euler else '#ffcccc'
        node_colors = [color if G.degree(v) % 2 == 0 else '#ff6666' for v in G.nodes()]
        
        pos = nx.spring_layout(G, seed=42)
        nx.draw(G, pos, ax=ax, with_labels=True, node_color=node_colors,
                node_size=400, edge_color='gray', width=1.5, font_size=9)
        
        status = "✓ Eulerian" if has_euler else "✗ No Eulerian"
        deg_str = f"Degrees: {sorted(set(degrees))}"
        ax.set_title(f"{name}\n{status}\n{deg_str}", fontsize=11)
        
        print(f"  {name}: {status}")
        print(f"    {reason}")
        print(f"    Vertices with odd degree: {odd_count}")
        print()

    plt.suptitle("Euler's Degree Parity Criterion\n"
                 "Green = even degree, Red = odd degree", 
                 fontsize=14, fontweight='bold')
    plt.tight_layout()
    plt.savefig("demos/euler_criterion.png", dpi=150, bbox_inches='tight')
    plt.close()
    print("✓ Saved visualization to demos/euler_criterion.png")
    print()


def demo_bridge_network():
    """Real-world application: network reliability analysis."""
    print("=" * 60)
    print("DEMO 4: Application — Network Reliability Analysis")
    print("=" * 60)
    print()
    print("Bridges in a network represent single points of failure.")
    print("If a bridge fails, the network becomes disconnected.")
    print()

    # Create a realistic network topology
    G = nx.Graph()
    
    cities = {
        'Downtown': (0, 0),
        'Airport': (3, 2),
        'University': (-2, 1.5),
        'Hospital': (1, -2),
        'Stadium': (-1, -1.5),
        'Mall': (2, -0.5),
        'Park': (-2.5, -0.5),
        'Harbor': (3, -1.5),
    }
    
    roads = [
        ('Downtown', 'Airport'),
        ('Downtown', 'University'),
        ('Downtown', 'Mall'),
        ('Downtown', 'Stadium'),
        ('University', 'Park'),
        ('Park', 'Stadium'),
        ('Stadium', 'Hospital'),
        ('Hospital', 'Mall'),
        ('Mall', 'Airport'),
        ('Mall', 'Harbor'),
        ('Airport', 'Harbor'),
    ]
    
    for city, pos in cities.items():
        G.add_node(city)
    G.add_edges_from(roads)
    
    bridges = find_bridges(G)
    
    fig, ax = plt.subplots(1, 1, figsize=(12, 8))
    
    edge_colors = ['red' if (u, v) in bridges or (v, u) in bridges 
                   else '#888888' for u, v in G.edges()]
    edge_widths = [3.5 if (u, v) in bridges or (v, u) in bridges 
                   else 1.5 for u, v in G.edges()]
    
    node_colors = []
    for v in G.nodes():
        is_bridge_endpoint = any((v == u1 or v == u2) for u1, u2 in bridges)
        node_colors.append('#ff9999' if is_bridge_endpoint else 'lightblue')
    
    nx.draw(G, cities, ax=ax, with_labels=True, node_color=node_colors,
            node_size=800, edge_color=edge_colors, width=edge_widths,
            font_size=9, font_weight='bold', style='solid')
    
    ax.set_title("City Transportation Network\n"
                 "Red edges = bridges (single points of failure)",
                 fontsize=14, fontweight='bold')
    
    red_patch = mpatches.Patch(color='red', label=f'Bridge ({len(bridges)} found)')
    gray_patch = mpatches.Patch(color='gray', label='Redundant road')
    ax.legend(handles=[red_patch, gray_patch], loc='upper left', fontsize=11)
    
    plt.tight_layout()
    plt.savefig("demos/network_reliability.png", dpi=150, bbox_inches='tight')
    plt.close()
    print("✓ Saved visualization to demos/network_reliability.png")
    print()
    
    print(f"  Network has {len(G.edges())} roads and {len(bridges)} bridge(s)")
    for u, v in bridges:
        print(f"    ⚠ Bridge: {u} — {v}")
        print(f"      If this road fails, parts of the network become unreachable!")
    
    print()
    print("  Recommendation: Add redundant roads to eliminate bridges")
    print("  (This is equivalent to making every edge part of a cycle,")
    print("   which our Lean proof shows is exactly the non-bridge condition)")
    print()


if __name__ == "__main__":
    print()
    print("╔══════════════════════════════════════════════════════════╗")
    print("║  Bridge Theory & Königsberg Bridge Problem — Demos      ║")
    print("║  Formally verified in Lean 4 with Mathlib               ║")
    print("╚══════════════════════════════════════════════════════════╝")
    print()
    
    demo_bridges()
    demo_konigsberg()
    demo_euler_criterion()
    demo_bridge_network()
    
    print("=" * 60)
    print("All demos complete! Check the demos/ folder for PNG files.")
    print("=" * 60)
