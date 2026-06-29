"""
Bridge Theory in Graphs — Interactive Demonstrations

This script demonstrates the key theorems about bridge edges in graphs:

1. Even-degree bridge-free theorem: Connected graphs where every vertex has
   even degree contain no bridges.
2. Tree characterization: A connected graph is a tree iff every edge is a bridge.
3. Bridge detection and visualization.

Requirements: matplotlib, networkx
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import networkx as nx
import numpy as np
from itertools import combinations


def find_bridges(G):
    """Find all bridge edges using DFS (Tarjan's algorithm)."""
    return list(nx.bridges(G))


def demo_even_degree_bridge_free():
    """
    Demonstrate Theorem 1: Connected graphs with all even degrees have no bridges.
    """
    fig, axes = plt.subplots(2, 2, figsize=(14, 12))
    fig.suptitle("Even-Degree Bridge-Free Theorem\n"
                 "Connected graphs where every vertex has even degree have no bridges",
                 fontsize=14, fontweight='bold')

    # Example 1: Cycle graph C6 — all degree 2, no bridges
    ax = axes[0, 0]
    G1 = nx.cycle_graph(6)
    bridges1 = find_bridges(G1)
    degrees1 = dict(G1.degree())
    pos1 = nx.circular_layout(G1)

    edge_colors1 = ['red' if (u, v) in bridges1 or (v, u) in bridges1
                    else 'steelblue' for u, v in G1.edges()]
    node_colors1 = ['lightcoral' if degrees1[n] % 2 == 1
                    else 'lightgreen' for n in G1.nodes()]

    nx.draw(G1, pos1, ax=ax, with_labels=True, node_color=node_colors1,
            edge_color=edge_colors1, width=2.5, node_size=500, font_size=12)
    labels1 = {n: f"d={degrees1[n]}" for n in G1.nodes()}
    pos1_offset = {k: (v[0], v[1] - 0.15) for k, v in pos1.items()}
    nx.draw_networkx_labels(G1, pos1_offset, labels1, ax=ax, font_size=8, font_color='gray')
    ax.set_title(f"Cycle C₆: All even degrees\nBridges: {len(bridges1)} ✓", fontsize=11)

    # Example 2: Graph with all even degrees
    ax = axes[0, 1]
    G2 = nx.Graph()
    G2.add_edges_from([(0, 1), (1, 2), (2, 0),
                       (1, 3), (3, 2),
                       (0, 3)])
    bridges2 = find_bridges(G2)
    degrees2 = dict(G2.degree())
    pos2 = nx.spring_layout(G2, seed=42)

    node_colors2 = ['lightcoral' if degrees2[n] % 2 == 1
                    else 'lightgreen' for n in G2.nodes()]
    edge_colors2 = ['red' if (u, v) in bridges2 or (v, u) in bridges2
                    else 'steelblue' for u, v in G2.edges()]

    nx.draw(G2, pos2, ax=ax, with_labels=True, node_color=node_colors2,
            edge_color=edge_colors2, width=2.5, node_size=500, font_size=12)
    labels2 = {n: f"d={degrees2[n]}" for n in G2.nodes()}
    pos2_offset = {k: (v[0], v[1] - 0.12) for k, v in pos2.items()}
    nx.draw_networkx_labels(G2, pos2_offset, labels2, ax=ax, font_size=8, font_color='gray')
    all_even2 = all(d % 2 == 0 for d in degrees2.values())
    ax.set_title(f"K₄: All even degrees = {all_even2}\n"
                 f"Bridges: {len(bridges2)} {'✓' if len(bridges2) == 0 else '✗'}", fontsize=11)

    # Example 3: Graph WITH bridges — must have odd-degree vertices
    ax = axes[1, 0]
    G3 = nx.Graph()
    G3.add_edges_from([(0, 1), (1, 2), (2, 0),
                       (2, 3),
                       (3, 4), (4, 5), (5, 3)])
    bridges3 = find_bridges(G3)
    degrees3 = dict(G3.degree())
    pos3 = {0: (-1.5, 0.5), 1: (-1.5, -0.5), 2: (-0.5, 0),
            3: (0.5, 0), 4: (1.5, 0.5), 5: (1.5, -0.5)}

    node_colors3 = ['lightcoral' if degrees3[n] % 2 == 1
                    else 'lightgreen' for n in G3.nodes()]
    edge_colors3 = ['red' if (u, v) in bridges3 or (v, u) in bridges3
                    else 'steelblue' for u, v in G3.edges()]

    nx.draw(G3, pos3, ax=ax, with_labels=True, node_color=node_colors3,
            edge_color=edge_colors3, width=2.5, node_size=500, font_size=12)
    labels3 = {n: f"d={degrees3[n]}" for n in G3.nodes()}
    pos3_offset = {k: (v[0], v[1] - 0.15) for k, v in pos3.items()}
    nx.draw_networkx_labels(G3, pos3_offset, labels3, ax=ax, font_size=8, font_color='gray')
    odd_vertices3 = [n for n in G3.nodes() if degrees3[n] % 2 == 1]
    ax.set_title(f"Two triangles + bridge (2,3)\n"
                 f"Odd-degree vertices: {odd_vertices3} — Bridge forces odd degrees!", fontsize=11)

    # Example 4: Petersen graph
    ax = axes[1, 1]
    G4 = nx.petersen_graph()
    bridges4 = find_bridges(G4)
    degrees4 = dict(G4.degree())
    pos4 = nx.shell_layout(G4)

    node_colors4 = ['lightcoral' if degrees4[n] % 2 == 1
                    else 'lightgreen' for n in G4.nodes()]
    edge_colors4 = ['red' if (u, v) in bridges4 or (v, u) in bridges4
                    else 'steelblue' for u, v in G4.edges()]

    nx.draw(G4, pos4, ax=ax, with_labels=True, node_color=node_colors4,
            edge_color=edge_colors4, width=2.5, node_size=500, font_size=12)
    ax.set_title(f"Petersen graph: 3-regular (odd degrees)\n"
                 f"Bridges: {len(bridges4)} — Odd degrees don't guarantee bridges!", fontsize=11)

    green_patch = mpatches.Patch(color='lightgreen', label='Even degree vertex')
    red_patch = mpatches.Patch(color='lightcoral', label='Odd degree vertex')
    blue_line = mpatches.Patch(color='steelblue', label='Non-bridge edge')
    red_line = mpatches.Patch(color='red', label='Bridge edge')
    fig.legend(handles=[green_patch, red_patch, blue_line, red_line],
               loc='lower center', ncol=4, fontsize=10,
               bbox_to_anchor=(0.5, 0.02))

    plt.tight_layout(rect=[0, 0.06, 1, 0.95])
    plt.savefig('Bridges/demos/even_degree_bridge_free.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("✓ Saved: even_degree_bridge_free.png")


def demo_tree_characterization():
    """
    Demonstrate Theorem 2: A connected graph is a tree iff every edge is a bridge.
    """
    fig, axes = plt.subplots(1, 3, figsize=(16, 5))
    fig.suptitle("Tree Characterization: Connected + Every Edge is a Bridge ⟺ Tree",
                 fontsize=14, fontweight='bold')

    ax = axes[0]
    T = nx.Graph()
    T.add_edges_from([(0, 1), (0, 2), (1, 3), (1, 4), (2, 5), (2, 6)])
    bridges_T = find_bridges(T)
    pos_T = nx.spring_layout(T, seed=1)

    nx.draw(T, pos_T, ax=ax, with_labels=True, node_color='lightyellow',
            edge_color='red', width=2.5, node_size=500, font_size=12,
            edgecolors='black', linewidths=1)
    ax.set_title(f"Tree (7 vertices, 6 edges)\n"
                 f"All {len(bridges_T)} edges are bridges ✓", fontsize=10)

    ax = axes[1]
    G = nx.Graph()
    G.add_edges_from([(0, 1), (1, 2), (2, 3), (3, 0), (0, 2), (3, 4), (4, 5), (5, 3)])
    bridges_G = find_bridges(G)
    pos_G = nx.spring_layout(G, seed=3)

    edge_colors_G = ['red' if (u, v) in bridges_G or (v, u) in bridges_G
                     else 'steelblue' for u, v in G.edges()]
    nx.draw(G, pos_G, ax=ax, with_labels=True, node_color='lightblue',
            edge_color=edge_colors_G, width=2.5, node_size=500, font_size=12,
            edgecolors='black', linewidths=1)
    ax.set_title(f"Not a tree ({G.number_of_edges()} edges)\n"
                 f"Only {len(bridges_G)}/{G.number_of_edges()} edges are bridges", fontsize=10)

    ax = axes[2]
    P = nx.path_graph(6)
    bridges_P = find_bridges(P)
    pos_P = {i: (i, 0) for i in range(6)}

    nx.draw(P, pos_P, ax=ax, with_labels=True, node_color='lightyellow',
            edge_color='red', width=2.5, node_size=500, font_size=12,
            edgecolors='black', linewidths=1)
    ax.set_title(f"Path P₆ (a tree)\n"
                 f"All {len(bridges_P)} edges are bridges ✓", fontsize=10)

    plt.tight_layout(rect=[0, 0, 1, 0.9])
    plt.savefig('Bridges/demos/tree_characterization.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("✓ Saved: tree_characterization.png")


def demo_parity_proof():
    """
    Visualize the core proof technique: the handshaking parity argument.
    """
    fig, axes = plt.subplots(2, 2, figsize=(14, 12))
    fig.suptitle("Proof Visualization: Why Even Degrees Prevent Bridges\n"
                 "The Handshaking Parity Argument",
                 fontsize=14, fontweight='bold')

    # Step 1: Even-degree graph
    ax = axes[0, 0]
    G = nx.Graph()
    G.add_edges_from([(0, 1), (1, 2), (2, 3), (3, 0), (0, 2), (1, 3)])
    pos = {0: (0, 1), 1: (1, 1), 2: (1, 0), 3: (0, 0)}
    degrees = dict(G.degree())

    nx.draw(G, pos, ax=ax, with_labels=True, node_color='lightgreen',
            edge_color='steelblue', width=2.5, node_size=600, font_size=14)
    labels = {n: f"d={degrees[n]}" for n in G.nodes()}
    pos_offset = {k: (v[0], v[1] - 0.15) for k, v in pos.items()}
    nx.draw_networkx_labels(G, pos_offset, labels, ax=ax, font_size=10, font_color='darkgreen')

    sum_deg = sum(degrees.values())
    ax.set_title(f"Step 1: All vertices have even degree\n"
                 f"Σ degrees = {sum_deg} = 2 × {G.number_of_edges()} edges ✓", fontsize=11)

    # Step 2: Highlight supposed bridge
    ax = axes[0, 1]
    edge_colors = ['red' if set([u, v]) == {0, 1}
                   else 'steelblue' for u, v in G.edges()]
    edge_widths = [4 if set([u, v]) == {0, 1}
                   else 2 for u, v in G.edges()]
    nx.draw(G, pos, ax=ax, with_labels=True, node_color='lightgreen',
            edge_color=edge_colors, width=edge_widths, node_size=600, font_size=14)
    ax.set_title("Step 2: Suppose edge (0,1) were a bridge\n"
                 "(we show this leads to contradiction)", fontsize=11)

    # Step 3: After removing the edge
    ax = axes[1, 0]
    G_minus = G.copy()
    G_minus.remove_edge(0, 1)
    degrees_minus = dict(G_minus.degree())

    node_colors_minus = ['lightcoral' if degrees_minus[n] % 2 == 1
                         else 'lightgreen' for n in G_minus.nodes()]
    nx.draw(G_minus, pos, ax=ax, with_labels=True, node_color=node_colors_minus,
            edge_color='steelblue', width=2.5, node_size=600, font_size=14)
    labels_minus = {n: f"d={degrees_minus[n]}" for n in G_minus.nodes()}
    nx.draw_networkx_labels(G_minus, pos, labels_minus, ax=ax, font_size=10, font_color='darkred')
    ax.set_title(f"Step 3: After removing edge (0,1)\n"
                 f"Vertices 0,1 have ODD degree (red)\n"
                 f"But still connected! → Not a bridge", fontsize=11)

    # Step 4: The argument
    ax = axes[1, 1]
    ax.axis('off')
    proof_text = (
        "THE PARITY ARGUMENT\n\n"
        "Suppose {u, v} is a bridge in a connected\n"
        "graph where every vertex has even degree.\n\n"
        "After removing {u, v}:\n"
        "  • u's degree drops by 1 → ODD\n"
        "  • v's degree drops by 1 → ODD\n"
        "  • All other vertices keep EVEN degree\n\n"
        "If {u, v} is a bridge, u and v are in\n"
        "different components after removal.\n\n"
        "In u's component:\n"
        "  • Sum of degrees = 2 × edges = EVEN\n"
        "  • u has ODD degree, others EVEN\n"
        "  • Sum = ODD + EVEN + ... = ODD\n\n"
        "  CONTRADICTION! ⚡\n\n"
        "∴ {u, v} cannot be a bridge.  □"
    )
    ax.text(0.05, 0.95, proof_text, transform=ax.transAxes,
            fontsize=11, verticalalignment='top', fontfamily='monospace',
            bbox=dict(boxstyle='round', facecolor='lightyellow', alpha=0.8))
    ax.set_title("Step 4: The Contradiction", fontsize=11)

    plt.tight_layout(rect=[0, 0, 1, 0.93])
    plt.savefig('Bridges/demos/parity_proof.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("✓ Saved: parity_proof.png")


def demo_network_vulnerability():
    """
    Practical application: Network vulnerability analysis.
    Bridges = single points of failure in networks.
    """
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))
    fig.suptitle("Application: Network Vulnerability Analysis\n"
                 "Bridges = Single Points of Failure",
                 fontsize=14, fontweight='bold')

    ax = axes[0]
    G = nx.Graph()
    for i, j in combinations(range(5), 2):
        G.add_edge(f"A{i}", f"A{j}")
    for i, j in combinations(range(4), 2):
        G.add_edge(f"B{i}", f"B{j}")
    G.add_edge("A4", "B0")
    for i, j in combinations(range(3), 2):
        G.add_edge(f"C{i}", f"C{j}")
    G.add_edge("B3", "C0")

    bridges = find_bridges(G)
    pos = nx.spring_layout(G, seed=42, k=1.5)

    edge_colors = ['red' if (u, v) in bridges or (v, u) in bridges
                   else 'lightgray' for u, v in G.edges()]
    edge_widths = [3.5 if (u, v) in bridges or (v, u) in bridges
                   else 1.0 for u, v in G.edges()]

    nx.draw(G, pos, ax=ax, with_labels=True, node_color='lightskyblue',
            edge_color=edge_colors, width=edge_widths, node_size=400,
            font_size=8, edgecolors='black', linewidths=0.5)
    ax.set_title(f"Network with {len(bridges)} bridge(s) — VULNERABLE\n"
                 f"Red edges are single points of failure", fontsize=10)

    ax = axes[1]
    G2 = G.copy()
    G2.add_edge("A0", "B1")
    G2.add_edge("B1", "C1")
    G2.add_edge("A2", "C2")

    bridges2 = find_bridges(G2)
    pos2 = nx.spring_layout(G2, seed=42, k=1.5)

    new_edges = [("A0", "B1"), ("B1", "C1"), ("A2", "C2")]
    edge_colors2 = []
    edge_widths2 = []
    for u, v in G2.edges():
        if (u, v) in bridges2 or (v, u) in bridges2:
            edge_colors2.append('red')
            edge_widths2.append(3.5)
        elif (u, v) in new_edges or (v, u) in new_edges:
            edge_colors2.append('green')
            edge_widths2.append(2.5)
        else:
            edge_colors2.append('lightgray')
            edge_widths2.append(1.0)

    nx.draw(G2, pos2, ax=ax, with_labels=True, node_color='lightgreen',
            edge_color=edge_colors2, width=edge_widths2, node_size=400,
            font_size=8, edgecolors='black', linewidths=0.5)
    ax.set_title(f"Reinforced network: {len(bridges2)} bridges — ROBUST\n"
                 f"Green = added redundant links", fontsize=10)

    plt.tight_layout(rect=[0, 0, 1, 0.88])
    plt.savefig('Bridges/demos/network_vulnerability.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("✓ Saved: network_vulnerability.png")


def numerical_experiments():
    """Run numerical experiments validating the theorems."""
    print("\n" + "="*60)
    print("NUMERICAL EXPERIMENTS: Bridge Theory Validation")
    print("="*60)

    print("\n--- Experiment 1: Random Even-Degree Graphs ---")
    print("Testing: connected + all even degrees → no bridges\n")
    for n in [6, 8, 10, 12, 20]:
        count = 0
        for _ in range(500):
            G = nx.gnp_random_graph(n, 0.5)
            if not nx.is_connected(G):
                continue
            if all(d % 2 == 0 for _, d in G.degree()):
                bridges = list(nx.bridges(G))
                assert len(bridges) == 0, f"Counterexample! n={n}"
                count += 1
        print(f"  n={n:3d}: {count} even-degree connected graphs, all had 0 bridges ✓")

    print("\n--- Experiment 2: Random Trees ---")
    print("Testing: tree ↔ connected + every edge is a bridge\n")
    for n in [5, 10, 20, 50, 100]:
        T = nx.random_labeled_tree(n)
        bridges = list(nx.bridges(T))
        assert len(bridges) == T.number_of_edges()
        print(f"  n={n:3d}: {T.number_of_edges()} edges, {len(bridges)} bridges (all) ✓")

    print("\n--- Experiment 3: Bridge Count ≤ n - 1 ---")
    for n in [5, 10, 15, 20]:
        max_b = 0
        for _ in range(200):
            G = nx.gnp_random_graph(n, 0.3)
            if not nx.is_connected(G):
                continue
            max_b = max(max_b, len(list(nx.bridges(G))))
        assert max_b <= n - 1
        print(f"  n={n:3d}: max bridges = {max_b} ≤ {n-1} ✓")

    print("\n" + "="*60)
    print("All experiments passed! ✓")
    print("="*60)


if __name__ == "__main__":
    print("Bridge Theory in Graphs — Demonstrations")
    print("="*50)

    demo_even_degree_bridge_free()
    demo_tree_characterization()
    demo_parity_proof()
    demo_network_vulnerability()
    numerical_experiments()

    print("\nAll demos completed successfully!")
