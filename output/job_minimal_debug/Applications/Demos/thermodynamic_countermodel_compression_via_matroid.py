#!/usr/bin/env python3
"""
Bridge Theory Demonstration
============================

This script demonstrates the key theorems about graph bridges that we
formally proved in Lean 4:

1. Bridge-Cycle Theorem: An edge is a bridge iff it lies on no cycle
2. Tree Bridge Theorem: Every edge of a tree is a bridge
3. Bridge Splitting: Removing a bridge yields exactly 2 components
4. 2-Edge-Connectivity: Connected + no bridges ↔ survives any edge removal

Requires: matplotlib, networkx
"""

import networkx as nx
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
from itertools import combinations
import os

# ─── Color palette ───
BRIDGE_COLOR = "#e74c3c"      # Red
CYCLE_EDGE_COLOR = "#2ecc71"  # Green
NORMAL_EDGE = "#95a5a6"       # Gray
NODE_COLOR = "#3498db"        # Blue
COMP_COLORS = ["#f39c12", "#9b59b6", "#1abc9c", "#e67e22"]


def find_bridges(G):
    """Find all bridges in a graph using DFS (Tarjan's algorithm)."""
    return list(nx.bridges(G))


def find_edge_cycles(G, edge):
    """Check if an edge lies on any cycle. Returns a cycle if found."""
    u, v = edge
    H = G.copy()
    H.remove_edge(u, v)
    try:
        path = nx.shortest_path(H, u, v)
        return path + [u]  # Close the cycle
    except nx.NetworkXNoPath:
        return None


def demo_bridge_cycle_theorem():
    """
    Demonstrate: An edge is a bridge ⟺ it does not lie on any cycle.

    We build a graph with both bridges and non-bridges, then verify the
    characterization for every edge.
    """
    print("=" * 70)
    print("THEOREM 1: Bridge-Cycle Characterization")
    print("  An edge is a bridge iff it lies on no cycle.")
    print("=" * 70)

    # Build a graph: two triangles connected by a bridge
    G = nx.Graph()
    # Left triangle
    G.add_edges_from([(0, 1), (1, 2), (2, 0)])
    # Right triangle
    G.add_edges_from([(4, 5), (5, 6), (6, 4)])
    # Bridge connecting them
    G.add_edge(2, 3)
    G.add_edge(3, 4)
    # Extra edge creating a cycle on the right
    G.add_edge(3, 6)

    bridges = find_bridges(G)

    print(f"\nGraph edges: {list(G.edges())}")
    print(f"Bridges found: {bridges}")
    print()

    # Verify the theorem for each edge
    for u, v in G.edges():
        is_bridge = (u, v) in bridges or (v, u) in bridges
        cycle = find_edge_cycles(G, (u, v))
        on_cycle = cycle is not None

        status = "✓" if (is_bridge == (not on_cycle)) else "✗"
        bridge_str = "BRIDGE" if is_bridge else "      "
        cycle_str = f"cycle: {cycle}" if on_cycle else "no cycle"
        print(f"  {status} Edge ({u},{v}): {bridge_str} | {cycle_str}")

    # Visualize
    fig, axes = plt.subplots(1, 2, figsize=(14, 5))

    pos = nx.spring_layout(G, seed=42)

    # Left: highlight bridges
    ax = axes[0]
    ax.set_title("Bridges (red) vs Non-bridges (green)", fontsize=13, fontweight='bold')
    edge_colors = []
    edge_widths = []
    for u, v in G.edges():
        if (u, v) in bridges or (v, u) in bridges:
            edge_colors.append(BRIDGE_COLOR)
            edge_widths.append(3.5)
        else:
            edge_colors.append(CYCLE_EDGE_COLOR)
            edge_widths.append(2.0)
    nx.draw(G, pos, ax=ax, with_labels=True, node_color=NODE_COLOR,
            edge_color=edge_colors, width=edge_widths, node_size=500,
            font_color='white', font_weight='bold')
    bridge_patch = mpatches.Patch(color=BRIDGE_COLOR, label='Bridge (no cycle)')
    cycle_patch = mpatches.Patch(color=CYCLE_EDGE_COLOR, label='Non-bridge (on cycle)')
    ax.legend(handles=[bridge_patch, cycle_patch], loc='lower left', fontsize=10)

    # Right: show a cycle containing a non-bridge edge
    ax = axes[1]
    ax.set_title("Example cycle containing edge (0,1)", fontsize=13, fontweight='bold')
    cycle = find_edge_cycles(G, (0, 1))
    cycle_edges = set()
    if cycle:
        for i in range(len(cycle) - 1):
            cycle_edges.add((min(cycle[i], cycle[i+1]), max(cycle[i], cycle[i+1])))

    edge_colors2 = []
    edge_widths2 = []
    for u, v in G.edges():
        key = (min(u, v), max(u, v))
        if key in cycle_edges:
            edge_colors2.append("#e74c3c")
            edge_widths2.append(3.5)
        else:
            edge_colors2.append(NORMAL_EDGE)
            edge_widths2.append(1.5)
    nx.draw(G, pos, ax=ax, with_labels=True, node_color=NODE_COLOR,
            edge_color=edge_colors2, width=edge_widths2, node_size=500,
            font_color='white', font_weight='bold')
    if cycle:
        ax.text(0.5, -0.05, f"Cycle: {' → '.join(map(str, cycle))}",
                transform=ax.transAxes, ha='center', fontsize=11)

    plt.tight_layout()
    plt.savefig(os.path.join(os.path.dirname(__file__), "fig1_bridge_cycle.png"), dpi=150)
    plt.close()
    print("\n  → Saved fig1_bridge_cycle.png\n")


def demo_tree_bridges():
    """
    Demonstrate: In a tree, every edge is a bridge.

    Trees are connected acyclic graphs — since no cycles exist,
    the bridge-cycle theorem implies every edge is a bridge.
    """
    print("=" * 70)
    print("THEOREM 2: Tree Bridge Theorem")
    print("  Every edge of a tree is a bridge.")
    print("=" * 70)

    # Create several trees
    trees = {
        "Path P₅": nx.path_graph(5),
        "Star K₁,₄": nx.star_graph(4),
        "Binary tree (depth 3)": nx.balanced_tree(2, 3),
        "Random tree (10 nodes)": nx.random_labeled_tree(10, seed=42),
    }

    fig, axes = plt.subplots(1, 4, figsize=(18, 4))

    for idx, (name, T) in enumerate(trees.items()):
        bridges = find_bridges(T)
        total_edges = T.number_of_edges()
        all_bridges = len(bridges) == total_edges

        print(f"\n  {name}: {total_edges} edges, {len(bridges)} bridges → "
              f"{'ALL bridges ✓' if all_bridges else 'NOT all bridges ✗'}")

        ax = axes[idx]
        ax.set_title(f"{name}\n({total_edges} edges, all bridges)", fontsize=10, fontweight='bold')
        pos = nx.spring_layout(T, seed=idx+1)
        nx.draw(T, pos, ax=ax, with_labels=True, node_color=NODE_COLOR,
                edge_color=BRIDGE_COLOR, width=2.5, node_size=350,
                font_color='white', font_size=8, font_weight='bold')

    plt.suptitle("Tree Bridge Theorem: Every edge is a bridge (shown in red)",
                 fontsize=14, fontweight='bold', y=1.02)
    plt.tight_layout()
    plt.savefig(os.path.join(os.path.dirname(__file__), "fig2_tree_bridges.png"),
                dpi=150, bbox_inches='tight')
    plt.close()
    print("\n  → Saved fig2_tree_bridges.png\n")


def demo_bridge_splitting():
    """
    Demonstrate: Removing a bridge creates exactly 2 connected components.

    This is the Bridge Splitting Theorem — after deleting a bridge,
    the graph splits into precisely two parts.
    """
    print("=" * 70)
    print("THEOREM 3: Bridge Splitting Theorem")
    print("  Removing a bridge yields exactly 2 connected components.")
    print("=" * 70)

    # Build a graph with a clear bridge
    G = nx.Graph()
    # Left cluster (K4 minus an edge)
    G.add_edges_from([(0, 1), (0, 2), (0, 3), (1, 2), (2, 3)])
    # Right cluster (cycle C4)
    G.add_edges_from([(5, 6), (6, 7), (7, 8), (8, 5)])
    # Bridge
    G.add_edge(3, 5)

    bridges = find_bridges(G)
    print(f"\n  Graph: {G.number_of_nodes()} nodes, {G.number_of_edges()} edges")
    print(f"  Bridges: {bridges}")
    print(f"  Connected components before removal: {nx.number_connected_components(G)}")

    fig, axes = plt.subplots(1, 3, figsize=(16, 5))

    pos = {0: (-2, 1), 1: (-3, 0), 2: (-1, 0), 3: (-2, -1),
           5: (1, -1), 6: (1, 1), 7: (2, 1), 8: (2, -1)}

    # Original graph
    ax = axes[0]
    ax.set_title("Original connected graph", fontsize=12, fontweight='bold')
    edge_colors = [BRIDGE_COLOR if (u, v) in bridges or (v, u) in bridges
                   else NORMAL_EDGE for u, v in G.edges()]
    edge_widths = [3.5 if (u, v) in bridges or (v, u) in bridges
                   else 2.0 for u, v in G.edges()]
    nx.draw(G, pos, ax=ax, with_labels=True, node_color=NODE_COLOR,
            edge_color=edge_colors, width=edge_widths, node_size=500,
            font_color='white', font_weight='bold')

    # Remove bridge
    for bridge in bridges:
        H = G.copy()
        H.remove_edge(*bridge)
        n_comp = nx.number_connected_components(H)
        components = list(nx.connected_components(H))

        print(f"\n  After removing bridge {bridge}:")
        print(f"    Components: {n_comp} (theorem predicts: 2) {'✓' if n_comp == 2 else '✗'}")
        for i, comp in enumerate(components):
            print(f"    Component {i+1}: {sorted(comp)}")

        # After removal
        ax = axes[1]
        ax.set_title(f"Bridge ({bridge[0]},{bridge[1]}) removed", fontsize=12, fontweight='bold')
        node_colors = []
        for node in H.nodes():
            for i, comp in enumerate(components):
                if node in comp:
                    node_colors.append(COMP_COLORS[i % len(COMP_COLORS)])
                    break
        nx.draw(H, pos, ax=ax, with_labels=True, node_color=node_colors,
                edge_color=NORMAL_EDGE, width=2.0, node_size=500,
                font_color='white', font_weight='bold')
        # Draw the removed edge as dashed
        nx.draw_networkx_edges(G, pos, edgelist=[bridge], ax=ax,
                               style='dashed', edge_color=BRIDGE_COLOR, width=2.0)

        # Component visualization
        ax = axes[2]
        ax.set_title(f"Exactly 2 components", fontsize=12, fontweight='bold')
        for i, comp in enumerate(components):
            sub = H.subgraph(comp)
            sub_pos = {n: pos[n] for n in comp}
            nx.draw(sub, sub_pos, ax=ax, with_labels=True,
                    node_color=COMP_COLORS[i % len(COMP_COLORS)],
                    edge_color=COMP_COLORS[i % len(COMP_COLORS)],
                    width=2.5, node_size=500,
                    font_color='white', font_weight='bold')

    plt.suptitle("Bridge Splitting Theorem", fontsize=14, fontweight='bold', y=1.02)
    plt.tight_layout()
    plt.savefig(os.path.join(os.path.dirname(__file__), "fig3_bridge_splitting.png"),
                dpi=150, bbox_inches='tight')
    plt.close()
    print("\n  → Saved fig3_bridge_splitting.png\n")


def demo_two_edge_connectivity():
    """
    Demonstrate: A connected graph is 2-edge-connected ⟺ no bridges
    ⟺ every edge lies on a cycle ⟺ survives any single edge removal.
    """
    print("=" * 70)
    print("THEOREM 4: 2-Edge-Connectivity Characterization")
    print("  Connected + no bridges ↔ every edge on a cycle")
    print("  ↔ remains connected after removing any single edge")
    print("=" * 70)

    # 2-edge-connected graph (Petersen graph)
    G_2ec = nx.petersen_graph()
    # Non-2-edge-connected graph
    G_not = nx.Graph()
    G_not.add_edges_from([(0, 1), (1, 2), (2, 0), (2, 3), (3, 4), (4, 5), (5, 3)])

    for name, G in [("Petersen graph", G_2ec), ("Graph with bridge", G_not)]:
        bridges = find_bridges(G)
        is_2ec = len(bridges) == 0 and nx.is_connected(G)
        print(f"\n  {name}:")
        print(f"    Edges: {G.number_of_edges()}, Bridges: {bridges}")
        print(f"    2-edge-connected: {'Yes ✓' if is_2ec else 'No ✗'}")

        # Test fault tolerance
        survives_all = True
        for u, v in G.edges():
            H = G.copy()
            H.remove_edge(u, v)
            if not nx.is_connected(H):
                survives_all = False
                print(f"    Removing ({u},{v}) disconnects! → NOT 2-edge-connected")
                break
        if survives_all:
            print(f"    Survives all single edge removals ✓")

        # Check every edge on cycle
        all_on_cycle = True
        for u, v in G.edges():
            if find_edge_cycles(G, (u, v)) is None:
                all_on_cycle = False
                print(f"    Edge ({u},{v}) not on any cycle!")
                break
        if all_on_cycle:
            print(f"    Every edge lies on a cycle ✓")

    # Visualize
    fig, axes = plt.subplots(1, 2, figsize=(12, 5))

    ax = axes[0]
    ax.set_title("Petersen Graph\n(2-edge-connected: no bridges)", fontsize=11, fontweight='bold')
    pos = nx.shell_layout(G_2ec)
    nx.draw(G_2ec, pos, ax=ax, with_labels=True, node_color=NODE_COLOR,
            edge_color=CYCLE_EDGE_COLOR, width=2.0, node_size=400,
            font_color='white', font_weight='bold')

    ax = axes[1]
    ax.set_title("Graph with bridge\n(NOT 2-edge-connected)", fontsize=11, fontweight='bold')
    pos2 = nx.spring_layout(G_not, seed=42)
    bridges_not = find_bridges(G_not)
    ec2 = [BRIDGE_COLOR if (u, v) in bridges_not or (v, u) in bridges_not
           else CYCLE_EDGE_COLOR for u, v in G_not.edges()]
    ew2 = [3.5 if (u, v) in bridges_not or (v, u) in bridges_not
           else 2.0 for u, v in G_not.edges()]
    nx.draw(G_not, pos2, ax=ax, with_labels=True, node_color=NODE_COLOR,
            edge_color=ec2, width=ew2, node_size=400,
            font_color='white', font_weight='bold')

    plt.suptitle("2-Edge-Connectivity: Bridges vs Bridgeless Graphs",
                 fontsize=14, fontweight='bold', y=1.02)
    plt.tight_layout()
    plt.savefig(os.path.join(os.path.dirname(__file__), "fig4_two_edge_connected.png"),
                dpi=150, bbox_inches='tight')
    plt.close()
    print("\n  → Saved fig4_two_edge_connected.png\n")


def demo_applications():
    """
    Demonstrate real-world applications of bridge theory.
    """
    print("=" * 70)
    print("APPLICATION: Network Vulnerability Analysis")
    print("=" * 70)

    # Model a small network (e.g., internet backbone)
    G = nx.Graph()
    cities = {
        0: ("New York", (-74.0, 40.7)),
        1: ("Boston", (-71.1, 42.4)),
        2: ("Philadelphia", (-75.2, 40.0)),
        3: ("Washington DC", (-77.0, 38.9)),
        4: ("Pittsburgh", (-80.0, 40.4)),
        5: ("Chicago", (-87.6, 41.9)),
        6: ("Detroit", (-83.0, 42.3)),
        7: ("Atlanta", (-84.4, 33.7)),
    }

    # Network links (some redundant, some critical)
    links = [
        (0, 1), (0, 2), (1, 2),     # NE triangle (redundant)
        (2, 3), (3, 4),             # Mid-Atlantic chain
        (4, 5), (4, 6), (5, 6),     # Midwest triangle
        (3, 7),                      # Single link to Atlanta (bridge!)
        (0, 4),                      # Cross link
    ]
    G.add_edges_from(links)

    bridges = find_bridges(G)
    print(f"\n  Network: {len(cities)} cities, {len(links)} links")
    print(f"\n  Critical links (bridges):")
    for u, v in bridges:
        print(f"    {cities[u][0]} ↔ {cities[v][0]}  ⚠️  Single point of failure!")

    print(f"\n  Redundant links (on cycles):")
    for u, v in G.edges():
        if (u, v) not in bridges and (v, u) not in bridges:
            cycle = find_edge_cycles(G, (u, v))
            if cycle:
                cycle_names = [cities[n][0] for n in cycle]
                print(f"    {cities[u][0]} ↔ {cities[v][0]}  ✓  "
                      f"Backup via: {' → '.join(cycle_names)}")

    # Recommendation
    print(f"\n  RECOMMENDATION: Add redundant links for bridges to achieve")
    print(f"  2-edge-connectivity (fault tolerance against any single link failure).")
    for u, v in bridges:
        # Find an alternative path suggestion
        H = G.copy()
        H.remove_edge(u, v)
        comps = list(nx.connected_components(H))
        if len(comps) == 2:
            # Suggest connecting components through another pair
            c1, c2 = sorted(comps[0]), sorted(comps[1])
            alt_u = [n for n in c1 if n != u][0] if len(c1) > 1 else u
            alt_v = [n for n in c2 if n != v][0] if len(c2) > 1 else v
            print(f"    → Add link: {cities[alt_u][0]} ↔ {cities[alt_v][0]}")

    # Visualize
    fig, ax = plt.subplots(1, 1, figsize=(10, 7))
    ax.set_title("Network Vulnerability Analysis\nBridges = Single Points of Failure",
                 fontsize=14, fontweight='bold')

    pos = {k: v[1] for k, v in cities.items()}
    labels = {k: v[0] for k, v in cities.items()}

    edge_colors = []
    edge_widths = []
    for u, v in G.edges():
        if (u, v) in bridges or (v, u) in bridges:
            edge_colors.append(BRIDGE_COLOR)
            edge_widths.append(4.0)
        else:
            edge_colors.append(CYCLE_EDGE_COLOR)
            edge_widths.append(2.0)

    nx.draw(G, pos, ax=ax, labels=labels, node_color=NODE_COLOR,
            edge_color=edge_colors, width=edge_widths, node_size=700,
            font_color='white', font_size=7, font_weight='bold')

    bridge_patch = mpatches.Patch(color=BRIDGE_COLOR, label='Bridge (vulnerability)')
    safe_patch = mpatches.Patch(color=CYCLE_EDGE_COLOR, label='Redundant (on cycle)')
    ax.legend(handles=[bridge_patch, safe_patch], loc='lower right', fontsize=11)

    plt.tight_layout()
    plt.savefig(os.path.join(os.path.dirname(__file__), "fig5_network_vulnerability.png"),
                dpi=150, bbox_inches='tight')
    plt.close()
    print("\n  → Saved fig5_network_vulnerability.png\n")


if __name__ == "__main__":
    print()
    print("╔══════════════════════════════════════════════════════════════════════╗")
    print("║          GRAPH BRIDGES: Formal Theory Made Tangible                 ║")
    print("║     Demonstrations of formally verified theorems (Lean 4)           ║")
    print("╚══════════════════════════════════════════════════════════════════════╝")
    print()

    demo_bridge_cycle_theorem()
    demo_tree_bridges()
    demo_bridge_splitting()
    demo_two_edge_connectivity()
    demo_applications()

    print("=" * 70)
    print("All demonstrations complete.")
    print("=" * 70)
