#!/usr/bin/env python3
"""
Practical Applications of Bridge Theory

This module demonstrates real-world applications of bridge detection
in graphs, showing how the Tree-Bridge Equivalence theorem connects
to practical network analysis problems.

Applications:
1. Network redundancy assessment
2. Critical infrastructure analysis
3. Social network vulnerability
4. Circuit board trace analysis (planar graph decomposition)
"""

import networkx as nx
import matplotlib.pyplot as plt
import os
from collections import defaultdict


# ─────────────────────────────────────────────────────────────────────
# Application 1: Network Redundancy Scoring
# ─────────────────────────────────────────────────────────────────────

def network_redundancy_score(G):
    """
    Compute a redundancy score for a connected network.

    Score = 1 - (number of bridges / number of edges)

    By the Tree-Bridge Equivalence:
    - Score = 0  ⟺  G is a tree (maximally vulnerable)
    - Score = 1  ⟺  G is 2-edge-connected (no single points of failure)

    Returns:
        float: Redundancy score in [0, 1]
    """
    if not nx.is_connected(G) or G.number_of_edges() == 0:
        return 0.0
    bridges = list(nx.bridges(G))
    return 1.0 - len(bridges) / G.number_of_edges()


def demo_redundancy_scoring():
    """Compare redundancy scores of different network topologies."""
    print("=" * 70)
    print("APPLICATION 1: Network Redundancy Scoring")
    print("=" * 70)
    print("\n  Score = 1 - (bridges/edges)")
    print("  Score = 0 means tree (maximally vulnerable)")
    print("  Score = 1 means 2-edge-connected (no single failures)\n")

    topologies = {
        "Star (hub-and-spoke)": nx.star_graph(8),
        "Path (daisy chain)": nx.path_graph(9),
        "Ring": nx.cycle_graph(9),
        "Mesh (K₉)": nx.complete_graph(9),
        "Grid 3×3": nx.grid_2d_graph(3, 3),
        "Ladder (2×5)": nx.ladder_graph(5),
        "Hypercube Q₃": nx.hypercube_graph(3),
    }

    results = []
    for name, G in topologies.items():
        score = network_redundancy_score(G)
        n_bridges = len(list(nx.bridges(G)))
        n_edges = G.number_of_edges()
        is_tree = nx.is_tree(G)
        results.append((name, score, n_bridges, n_edges, is_tree))

    results.sort(key=lambda x: x[1])

    print(f"  {'Topology':<25} {'Score':>6} {'Bridges':>8} {'Edges':>6} {'Tree?':>6}")
    print(f"  {'-'*55}")
    for name, score, nb, ne, tree in results:
        tree_str = "Yes" if tree else "No"
        print(f"  {name:<25} {score:>6.2f} {nb:>8} {ne:>6} {tree_str:>6}")

    print(f"\n  Key insight from Tree-Bridge Equivalence:")
    print(f"    Trees (score=0) are the WORST case — every link is critical")
    print(f"    Adding ANY edge to a tree immediately improves redundancy\n")


# ─────────────────────────────────────────────────────────────────────
# Application 2: Bridge-Block Decomposition
# ─────────────────────────────────────────────────────────────────────

def bridge_block_decomposition(G):
    """
    Decompose a connected graph into 2-edge-connected components (blocks)
    connected by bridges.

    This is the edge-analogue of the block-cut tree decomposition.
    The Tree-Bridge Equivalence tells us: when we contract each block
    to a single vertex, the result is a tree (or forest).

    Returns:
        blocks: list of sets of vertices in each 2-edge-connected component
        bridges: list of bridge edges
    """
    bridges = set(tuple(sorted(e)) for e in nx.bridges(G))
    # Remove bridges to get blocks
    H = G.copy()
    for u, v in bridges:
        H.remove_edge(u, v)
    blocks = list(nx.connected_components(H))
    return blocks, bridges


def demo_bridge_block():
    """Demonstrate bridge-block decomposition."""
    print("=" * 70)
    print("APPLICATION 2: Bridge-Block Decomposition")
    print("=" * 70)

    # Build a graph with interesting structure
    G = nx.Graph()
    # Block 1: triangle (vertices 0,1,2)
    G.add_edges_from([(0,1), (1,2), (0,2)])
    # Bridge: 2-3
    G.add_edge(2, 3)
    # Block 2: K₄ (vertices 3,4,5,6)
    for i in range(3, 7):
        for j in range(i+1, 7):
            G.add_edge(i, j)
    # Bridge: 6-7
    G.add_edge(6, 7)
    # Block 3: cycle (vertices 7,8,9,10)
    G.add_edges_from([(7,8), (8,9), (9,10), (10,7)])

    blocks, bridges = bridge_block_decomposition(G)

    print(f"\n  Graph: {G.number_of_nodes()} vertices, {G.number_of_edges()} edges")
    print(f"  Bridges: {len(bridges)}")
    for b in bridges:
        print(f"    {b[0]} ↔ {b[1]}")
    print(f"  2-edge-connected blocks: {len(blocks)}")
    for i, block in enumerate(blocks):
        subG = G.subgraph(block)
        print(f"    Block {i+1}: vertices {sorted(block)}, "
              f"{subG.number_of_edges()} edges")

    print(f"\n  By the Tree-Bridge Equivalence:")
    print(f"    The block tree has {len(blocks)} nodes and {len(bridges)} edges")
    print(f"    It is a tree (connected + every edge is a bridge)")
    print()

    # Visualization
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))
    fig.suptitle("Bridge-Block Decomposition", fontsize=14, fontweight='bold')

    pos = nx.spring_layout(G, seed=42)
    colors = ['#e74c3c', '#3498db', '#2ecc71', '#f39c12', '#9b59b6']
    node_colors = []
    for v in G.nodes():
        for i, block in enumerate(blocks):
            if v in block:
                node_colors.append(colors[i % len(colors)])
                break

    bridge_edges = [e for e in G.edges() if tuple(sorted(e)) in bridges]
    non_bridge = [e for e in G.edges() if tuple(sorted(e)) not in bridges]

    nx.draw_networkx_nodes(G, pos, ax=ax1, node_color=node_colors,
                          node_size=400, edgecolors='black')
    nx.draw_networkx_labels(G, pos, ax=ax1, font_size=9)
    nx.draw_networkx_edges(G, pos, edgelist=non_bridge, ax=ax1,
                          edge_color='gray', width=2)
    nx.draw_networkx_edges(G, pos, edgelist=bridge_edges, ax=ax1,
                          edge_color='red', width=3, style='dashed')
    ax1.set_title("Original Graph\n(bridges in red, blocks colored)")
    ax1.axis('off')

    # Block tree
    BT = nx.Graph()
    block_labels = {}
    for i, block in enumerate(blocks):
        BT.add_node(i)
        block_labels[i] = f"B{i+1}\n{sorted(block)}"
    for u, v in bridges:
        bu = bv = None
        for i, block in enumerate(blocks):
            if u in block: bu = i
            if v in block: bv = i
        if bu is not None and bv is not None and bu != bv:
            BT.add_edge(bu, bv)

    pos_bt = nx.spring_layout(BT, seed=42)
    bt_colors = [colors[i % len(colors)] for i in BT.nodes()]
    nx.draw_networkx_nodes(BT, pos_bt, ax=ax2, node_color=bt_colors,
                          node_size=800, edgecolors='black')
    nx.draw_networkx_labels(BT, pos_bt, labels=block_labels, ax=ax2, font_size=8)
    nx.draw_networkx_edges(BT, pos_bt, ax=ax2, edge_color='red', width=3)
    ax2.set_title("Block Tree\n(always a tree by Tree-Bridge Equivalence)")
    ax2.axis('off')

    plt.tight_layout()
    plt.savefig(os.path.join(os.path.dirname(__file__), "bridge_block_decomposition.png"),
                dpi=150, bbox_inches='tight')
    plt.close()
    print("  Saved: bridge_block_decomposition.png")


# ─────────────────────────────────────────────────────────────────────
# Application 3: Network Hardening Recommendations
# ─────────────────────────────────────────────────────────────────────

def recommend_hardening(G, node_labels=None):
    """
    Given a network with bridges, recommend edges to add that would
    eliminate the most bridges.

    Strategy: For each bridge, find the two components it connects
    and suggest adding an edge between them that bypasses the bridge.
    """
    bridges = list(nx.bridges(G))
    if not bridges:
        return []

    recommendations = []
    for u, v in bridges:
        H = G.copy()
        H.remove_edge(u, v)
        comp_u = nx.node_connected_component(H, u)
        comp_v = nx.node_connected_component(H, v)

        # Find best edge to add: connect a vertex in comp_u to one in comp_v
        # that is different from the existing bridge
        best = None
        for a in comp_u:
            for b in comp_v:
                if (a, b) != (u, v) and (b, a) != (u, v) and not G.has_edge(a, b):
                    best = (a, b)
                    break
            if best:
                break

        if best:
            a_label = node_labels[best[0]] if node_labels else str(best[0])
            b_label = node_labels[best[1]] if node_labels else str(best[1])
            recommendations.append({
                'bridge': (u, v),
                'add_edge': best,
                'description': f"Add link {a_label} ↔ {b_label} to protect bridge {node_labels[u] if node_labels else u} ↔ {node_labels[v] if node_labels else v}"
            })

    return recommendations


def demo_hardening():
    """Demonstrate network hardening recommendations."""
    print("=" * 70)
    print("APPLICATION 3: Network Hardening Recommendations")
    print("=" * 70)

    G = nx.Graph()
    cities = ["NYC", "BOS", "CHI", "MIA", "DAL", "DEN", "SEA", "LAX", "ATL", "DC"]
    labels = {i: c for i, c in enumerate(cities)}
    G.add_nodes_from(range(len(cities)))
    G.add_edges_from([
        (0, 1), (0, 8), (0, 9), (1, 9), (2, 4), (2, 5),
        (3, 8), (4, 7), (5, 6), (5, 7), (6, 7), (8, 9), (8, 2),
    ])

    bridges = list(nx.bridges(G))
    print(f"\n  Current network: {len(cities)} cities, {G.number_of_edges()} links")
    print(f"  Bridges found: {len(bridges)}")
    for u, v in bridges:
        print(f"    {cities[u]} ↔ {cities[v]}")

    recs = recommend_hardening(G, labels)
    print(f"\n  Hardening recommendations:")
    for r in recs:
        print(f"    → {r['description']}")

    # Apply recommendations and verify
    G_hardened = G.copy()
    for r in recs:
        G_hardened.add_edge(*r['add_edge'])

    new_bridges = list(nx.bridges(G_hardened))
    print(f"\n  After hardening:")
    print(f"    Links: {G_hardened.number_of_edges()} (added {G_hardened.number_of_edges() - G.number_of_edges()})")
    print(f"    Bridges: {len(new_bridges)}")
    if not new_bridges:
        print(f"    ✓ Network is now 2-edge-connected (no single points of failure)")
    print()


# ─────────────────────────────────────────────────────────────────────
# Application 4: Social Network Analysis
# ─────────────────────────────────────────────────────────────────────

def demo_social_network():
    """Bridge detection in social networks reveals critical connectors."""
    print("=" * 70)
    print("APPLICATION 4: Social Network — Bridge People")
    print("=" * 70)

    # Create a social network with two communities connected by a bridge person
    G = nx.Graph()
    # Community A (tech team)
    tech = ["Alice", "Bob", "Carol", "Dave"]
    for i, a in enumerate(tech):
        for b in tech[i+1:]:
            G.add_edge(a, b)  # Fully connected team

    # Community B (marketing team)
    mktg = ["Eve", "Frank", "Grace", "Heidi"]
    for i, a in enumerate(mktg):
        for b in mktg[i+1:]:
            G.add_edge(a, b)  # Fully connected team

    # Bridge person: connects the two communities
    G.add_edge("Carol", "Eve")  # Carol knows Eve

    bridges = list(nx.bridges(G))
    print(f"\n  Social network: {G.number_of_nodes()} people, {G.number_of_edges()} connections")
    print(f"  Bridges: {len(bridges)}")
    for u, v in bridges:
        print(f"    {u} ↔ {v}  ← This relationship bridges two communities!")

    print(f"\n  Interpretation:")
    print(f"    If Carol and Eve stop communicating, the two teams become isolated.")
    print(f"    Carol and Eve are 'bridge people' — their relationship is the")
    print(f"    sole connection between the tech and marketing communities.")
    print(f"\n  By the Tree-Bridge Equivalence:")
    print(f"    The inter-community structure is tree-like (a single bridge),")
    print(f"    making it maximally vulnerable to relationship disruption.")
    print()

    # Visualization
    fig, ax = plt.subplots(figsize=(10, 7))

    pos = nx.spring_layout(G, seed=42)
    tech_nodes = tech
    mktg_nodes = mktg

    nx.draw_networkx_nodes(G, pos, nodelist=tech_nodes, ax=ax,
                          node_color='#3498db', node_size=500, label='Tech Team')
    nx.draw_networkx_nodes(G, pos, nodelist=mktg_nodes, ax=ax,
                          node_color='#e74c3c', node_size=500, label='Marketing Team')
    nx.draw_networkx_labels(G, pos, ax=ax, font_size=9, font_weight='bold')

    bridge_set = set(tuple(sorted(e)) for e in bridges)
    bridge_edges = [e for e in G.edges() if tuple(sorted(e)) in bridge_set]
    non_bridge = [e for e in G.edges() if tuple(sorted(e)) not in bridge_set]

    nx.draw_networkx_edges(G, pos, edgelist=non_bridge, ax=ax,
                          edge_color='gray', width=1.5)
    nx.draw_networkx_edges(G, pos, edgelist=bridge_edges, ax=ax,
                          edge_color='gold', width=4)

    ax.legend(fontsize=11, loc='upper right')
    ax.set_title("Social Network Bridge Analysis\nGold edge = Bridge (critical inter-community link)",
                fontsize=13, fontweight='bold')
    ax.axis('off')

    plt.tight_layout()
    plt.savefig(os.path.join(os.path.dirname(__file__), "social_network_bridges.png"),
                dpi=150, bbox_inches='tight')
    plt.close()
    print("  Saved: social_network_bridges.png\n")


# ─────────────────────────────────────────────────────────────────────
# Main
# ─────────────────────────────────────────────────────────────────────

if __name__ == "__main__":
    print("\n" + "━" * 70)
    print("  PRACTICAL APPLICATIONS OF BRIDGE THEORY")
    print("  Based on the Tree-Bridge Equivalence Theorem (Lean 4 verified)")
    print("━" * 70 + "\n")

    demo_redundancy_scoring()
    print()
    demo_bridge_block()
    print()
    demo_hardening()
    print()
    demo_social_network()

    print("━" * 70)
    print("  All applications demonstrated successfully!")
    print("━" * 70 + "\n")


#!/usr/bin/env python3
"""
Bridge Theory in Graphs — Interactive Demonstrations

This script demonstrates the key theorems formalized in Lean 4:
1. Tree-Bridge Equivalence: A connected graph is a tree ⟺ every edge is a bridge
2. Complete graphs on ≥3 vertices have no bridges
3. Path graphs have all bridges
4. The Königsberg bridge problem

Requirements: pip install networkx matplotlib
"""

import networkx as nx
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
from itertools import combinations
import os

# ─────────────────────────────────────────────────────────────────────
# Core algorithms
# ─────────────────────────────────────────────────────────────────────

def find_bridges(G):
    """Find all bridges in an undirected graph using Tarjan's algorithm."""
    return list(nx.bridges(G))

def is_bridge(G, u, v):
    """Check if edge (u,v) is a bridge by testing if its removal disconnects G."""
    H = G.copy()
    H.remove_edge(u, v)
    return not nx.is_connected(H)

def verify_tree_bridge_equivalence(G):
    """Verify the Tree-Bridge Equivalence Theorem on a given graph."""
    if not nx.is_connected(G):
        return None  # Theorem applies to connected graphs

    is_tree = nx.is_tree(G)
    bridges = find_bridges(G)
    all_bridges = len(bridges) == G.number_of_edges()

    # The theorem: is_tree ⟺ all_bridges (for connected graphs)
    assert is_tree == all_bridges, (
        f"Tree-Bridge Equivalence VIOLATED! "
        f"is_tree={is_tree}, all_bridges={all_bridges}"
    )
    return is_tree, all_bridges, bridges

# ─────────────────────────────────────────────────────────────────────
# Demo 1: Tree-Bridge Equivalence on various graphs
# ─────────────────────────────────────────────────────────────────────

def demo_tree_bridge_equivalence():
    """Demonstrate the Tree-Bridge Equivalence on multiple graph families."""
    print("=" * 70)
    print("DEMO 1: Tree-Bridge Equivalence Theorem")
    print("A connected graph is a tree ⟺ every edge is a bridge")
    print("=" * 70)

    graphs = {
        "Path P₅ (5 vertices)": nx.path_graph(5),
        "Star S₄ (center + 4 leaves)": nx.star_graph(4),
        "Binary tree (depth 3)": nx.balanced_tree(2, 3),
        "Cycle C₅": nx.cycle_graph(5),
        "Complete K₅": nx.complete_graph(5),
        "Petersen graph": nx.petersen_graph(),
        "Grid 3×3": nx.grid_2d_graph(3, 3),
        "Barbell (K₃—K₃)": nx.barbell_graph(3, 1),
    }

    for name, G in graphs.items():
        result = verify_tree_bridge_equivalence(G)
        if result is None:
            print(f"  {name}: Not connected (skipped)")
            continue
        is_tree, all_bridges, bridges = result
        n_bridges = len(bridges)
        n_edges = G.number_of_edges()
        status = "✓ TREE (all edges are bridges)" if is_tree else f"✗ Not a tree ({n_bridges}/{n_edges} edges are bridges)"
        print(f"  {name}: {status}")

    print("\n  ✓ Tree-Bridge Equivalence verified on all test graphs!\n")

# ─────────────────────────────────────────────────────────────────────
# Demo 2: Visualizing bridges in graphs
# ─────────────────────────────────────────────────────────────────────

def demo_visualize_bridges():
    """Create visualizations showing bridges highlighted in various graphs."""
    fig, axes = plt.subplots(2, 3, figsize=(15, 10))
    fig.suptitle("Bridge Detection in Graphs\n(Red = Bridge, Blue = Non-bridge)",
                 fontsize=14, fontweight='bold')

    graphs = [
        ("Path P₆", nx.path_graph(6)),
        ("Cycle C₆", nx.cycle_graph(6)),
        ("Complete K₅", nx.complete_graph(5)),
        ("Barbell K₃—K₃", nx.barbell_graph(3, 1)),
        ("Tree (depth 2)", nx.balanced_tree(2, 2)),
        ("Grid 3×3", nx.grid_2d_graph(3, 3)),
    ]

    for ax, (name, G) in zip(axes.flat, graphs):
        bridges = set(tuple(sorted(e)) for e in find_bridges(G))
        pos = nx.spring_layout(G, seed=42)

        # Draw non-bridge edges
        non_bridge_edges = [e for e in G.edges() if tuple(sorted(e)) not in bridges]
        bridge_edges = [e for e in G.edges() if tuple(sorted(e)) in bridges]

        nx.draw_networkx_nodes(G, pos, ax=ax, node_color='lightblue',
                              node_size=300, edgecolors='black')
        nx.draw_networkx_labels(G, pos, ax=ax, font_size=8)
        nx.draw_networkx_edges(G, pos, edgelist=non_bridge_edges, ax=ax,
                              edge_color='steelblue', width=2)
        nx.draw_networkx_edges(G, pos, edgelist=bridge_edges, ax=ax,
                              edge_color='red', width=3, style='solid')

        n_bridges = len(bridges)
        n_edges = G.number_of_edges()
        is_tree = nx.is_tree(G)
        tree_label = " [TREE]" if is_tree else ""
        ax.set_title(f"{name}{tree_label}\n{n_bridges}/{n_edges} bridges", fontsize=10)
        ax.axis('off')

    plt.tight_layout()
    plt.savefig(os.path.join(os.path.dirname(__file__), "bridges_visualization.png"),
                dpi=150, bbox_inches='tight')
    plt.close()
    print("  Saved: bridges_visualization.png")

# ─────────────────────────────────────────────────────────────────────
# Demo 3: The Königsberg Bridge Problem
# ─────────────────────────────────────────────────────────────────────

def demo_konigsberg():
    """Demonstrate the Königsberg bridge problem."""
    print("=" * 70)
    print("DEMO 3: The Königsberg Bridge Problem (1736)")
    print("=" * 70)

    # The original Königsberg problem uses a multigraph with 7 edges
    K = nx.MultiGraph()
    K.add_nodes_from([
        ("North", {"label": "Northern Bank"}),
        ("South", {"label": "Southern Bank"}),
        ("Kneiphof", {"label": "Kneiphof Island"}),
        ("Lomse", {"label": "Lomse Island"}),
    ])
    # 7 bridges of Königsberg
    K.add_edges_from([
        ("North", "Kneiphof"),      # Bridge 1
        ("North", "Kneiphof"),      # Bridge 2
        ("South", "Kneiphof"),      # Bridge 3
        ("South", "Kneiphof"),      # Bridge 4
        ("North", "Lomse"),         # Bridge 5
        ("South", "Lomse"),         # Bridge 6
        ("Kneiphof", "Lomse"),      # Bridge 7
    ])

    print(f"\n  Königsberg multigraph:")
    print(f"    Vertices: {K.number_of_nodes()} (4 landmasses)")
    print(f"    Edges:    {K.number_of_edges()} (7 bridges)")
    print(f"\n  Vertex degrees:")
    for node in K.nodes():
        print(f"    {node}: degree {K.degree(node)}")

    # Euler's criterion: Eulerian circuit exists iff all degrees are even
    odd_degree_vertices = [v for v in K.nodes() if K.degree(v) % 2 != 0]
    print(f"\n  Odd-degree vertices: {odd_degree_vertices}")
    print(f"  Number of odd-degree vertices: {len(odd_degree_vertices)}")
    print(f"\n  Euler's Theorem: A connected graph has an Eulerian circuit")
    print(f"  iff every vertex has even degree.")
    print(f"\n  Since ALL 4 vertices have odd degree, NO Eulerian circuit exists!")
    print(f"  → It is impossible to cross all 7 bridges exactly once")
    print(f"    and return to the starting point.")

    # Simple graph version (as formalized in Lean)
    print(f"\n  In our Lean formalization:")
    print(f"    We model the 4 landmasses as Fin 4")
    print(f"    The simple graph K₄ (complete graph) captures the adjacency structure")
    print(f"    We prove K₄ is connected and has NO bridges (being complete)")
    print()

    # Visualization
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))
    fig.suptitle("The Königsberg Bridge Problem", fontsize=14, fontweight='bold')

    # Multigraph version
    pos = {"North": (0, 1), "South": (0, -1), "Kneiphof": (-1.5, 0), "Lomse": (1.5, 0)}

    nx.draw_networkx_nodes(K, pos, ax=ax1, node_color='sandybrown',
                          node_size=800, edgecolors='black')
    nx.draw_networkx_labels(K, pos, ax=ax1, font_size=8, font_weight='bold')

    # Draw multi-edges with curves
    edge_colors = ['#e74c3c', '#3498db', '#2ecc71', '#f39c12', '#9b59b6', '#1abc9c', '#e67e22']
    for i, (u, v, _) in enumerate(K.edges(data=True)):
        rad = 0.2 * (i % 3 - 1)
        ax1.annotate("", xy=pos[v], xytext=pos[u],
                     arrowprops=dict(arrowstyle="-", color=edge_colors[i % len(edge_colors)],
                                    lw=2.5, connectionstyle=f"arc3,rad={rad}"))

    for node in K.nodes():
        deg = K.degree(node)
        ax1.annotate(f"deg={deg}", xy=pos[node], xytext=(0, -25),
                    textcoords="offset points", ha='center', fontsize=8, color='red')

    ax1.set_title("Original Multigraph (7 bridges)\nAll vertices have odd degree → No Eulerian circuit")
    ax1.axis('off')

    # Simple graph version (K₄)
    G_simple = nx.complete_graph(4)
    labels = {0: "North", 1: "South", 2: "Kneiphof", 3: "Lomse"}
    pos_simple = {0: (0, 1), 1: (0, -1), 2: (-1.5, 0), 3: (1.5, 0)}
    bridges_simple = find_bridges(G_simple)

    nx.draw_networkx_nodes(G_simple, pos_simple, ax=ax2, node_color='lightgreen',
                          node_size=800, edgecolors='black')
    nx.draw_networkx_labels(G_simple, pos_simple, labels=labels, ax=ax2,
                           font_size=8, font_weight='bold')
    nx.draw_networkx_edges(G_simple, pos_simple, ax=ax2, edge_color='steelblue', width=2.5)

    ax2.set_title(f"Simple Graph K₄ (Lean formalization)\n{len(bridges_simple)} bridges — fully 2-edge-connected")
    ax2.axis('off')

    plt.tight_layout()
    plt.savefig(os.path.join(os.path.dirname(__file__), "konigsberg.png"),
                dpi=150, bbox_inches='tight')
    plt.close()
    print("  Saved: konigsberg.png")

# ─────────────────────────────────────────────────────────────────────
# Demo 4: Bridge counting statistics
# ─────────────────────────────────────────────────────────────────────

def demo_bridge_statistics():
    """Show how bridge density varies across graph families."""
    print("=" * 70)
    print("DEMO 4: Bridge Density Across Graph Families")
    print("=" * 70)

    results = []

    # Generate graphs of various sizes
    for n in range(4, 15):
        # Path graph (tree) — all edges are bridges
        G_path = nx.path_graph(n)
        b_path = len(find_bridges(G_path))
        results.append(("Path", n, G_path.number_of_edges(), b_path))

        # Cycle — no bridges
        G_cycle = nx.cycle_graph(n)
        b_cycle = len(find_bridges(G_cycle))
        results.append(("Cycle", n, G_cycle.number_of_edges(), b_cycle))

        # Complete — no bridges (for n ≥ 3)
        G_complete = nx.complete_graph(n)
        b_complete = len(find_bridges(G_complete))
        results.append(("Complete", n, G_complete.number_of_edges(), b_complete))

        # Random tree — all bridges
        G_tree = nx.random_labeled_tree(n, seed=42)
        b_tree = len(find_bridges(G_tree))
        results.append(("Random Tree", n, G_tree.number_of_edges(), b_tree))

    print(f"\n  {'Family':<15} {'n':>3} {'Edges':>6} {'Bridges':>8} {'Ratio':>8}")
    print(f"  {'-'*45}")
    for family, n, edges, bridges in results:
        if n in [5, 10, 14]:
            ratio = bridges / edges if edges > 0 else 0
            print(f"  {family:<15} {n:>3} {edges:>6} {bridges:>8} {ratio:>8.2%}")

    print(f"\n  Key observations:")
    print(f"    • Trees: 100% bridge ratio (Tree-Bridge Equivalence)")
    print(f"    • Cycles: 0% bridge ratio (every edge lies on a cycle)")
    print(f"    • Complete graphs (n≥3): 0% bridge ratio (2-edge-connected)")
    print()

    # Plot
    fig, ax = plt.subplots(figsize=(10, 6))
    ns = list(range(4, 15))

    for family, color, marker in [("Path", "red", "o"), ("Cycle", "blue", "s"),
                                   ("Complete", "green", "^"), ("Random Tree", "orange", "D")]:
        ratios = []
        for n in ns:
            for f, nn, edges, bridges in results:
                if f == family and nn == n:
                    ratios.append(bridges / edges if edges > 0 else 0)
                    break
        ax.plot(ns, ratios, f'-{marker}', color=color, label=family, linewidth=2, markersize=8)

    ax.set_xlabel("Number of vertices (n)", fontsize=12)
    ax.set_ylabel("Bridge ratio (bridges / edges)", fontsize=12)
    ax.set_title("Bridge Density Across Graph Families\n(Tree-Bridge Equivalence in Action)", fontsize=14)
    ax.legend(fontsize=11)
    ax.set_ylim(-0.05, 1.1)
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig(os.path.join(os.path.dirname(__file__), "bridge_density.png"),
                dpi=150, bbox_inches='tight')
    plt.close()
    print("  Saved: bridge_density.png")

# ─────────────────────────────────────────────────────────────────────
# Demo 5: Network vulnerability analysis
# ─────────────────────────────────────────────────────────────────────

def demo_network_vulnerability():
    """Apply bridge detection to network vulnerability analysis."""
    print("=" * 70)
    print("DEMO 5: Network Vulnerability Analysis")
    print("=" * 70)

    # Create a sample network topology (e.g., a small ISP backbone)
    G = nx.Graph()
    cities = ["NYC", "BOS", "CHI", "MIA", "DAL", "DEN", "SEA", "LAX", "ATL", "DC"]
    G.add_nodes_from(range(len(cities)))

    # Add backbone links (some redundant, some not)
    edges = [
        (0, 1),  # NYC - BOS
        (0, 8),  # NYC - ATL
        (0, 9),  # NYC - DC
        (1, 9),  # BOS - DC
        (2, 4),  # CHI - DAL
        (2, 5),  # CHI - DEN
        (3, 8),  # MIA - ATL
        (4, 7),  # DAL - LAX
        (5, 6),  # DEN - SEA
        (5, 7),  # DEN - LAX
        (6, 7),  # SEA - LAX
        (8, 9),  # ATL - DC
        (8, 3),  # ATL - MIA
        (8, 2),  # ATL - CHI  (critical link!)
    ]
    G.add_edges_from(edges)

    bridges = find_bridges(G)
    print(f"\n  Network: {len(cities)} cities, {G.number_of_edges()} links")
    print(f"\n  Bridges (single points of failure):")
    for u, v in bridges:
        print(f"    {cities[u]} ↔ {cities[v]}  ← CRITICAL LINK")

    if not bridges:
        print("    None! Network is 2-edge-connected (resilient)")

    print(f"\n  Non-bridge links (have redundant paths):")
    for u, v in G.edges():
        if (u, v) not in bridges and (v, u) not in bridges:
            print(f"    {cities[u]} ↔ {cities[v]}")

    # Visualize
    fig, ax = plt.subplots(figsize=(12, 8))

    pos = {
        0: (4, 3), 1: (5, 4), 2: (2, 3.5), 3: (4, 0.5),
        4: (1.5, 1.5), 5: (0, 3), 6: (-1, 4.5), 7: (-1, 1.5),
        8: (3.5, 1.5), 9: (4.5, 3.5)
    }

    bridges_set = set(tuple(sorted(e)) for e in bridges)
    bridge_edges = [e for e in G.edges() if tuple(sorted(e)) in bridges_set]
    safe_edges = [e for e in G.edges() if tuple(sorted(e)) not in bridges_set]

    nx.draw_networkx_nodes(G, pos, ax=ax, node_color='lightblue',
                          node_size=600, edgecolors='black', linewidths=2)
    labels = {i: c for i, c in enumerate(cities)}
    nx.draw_networkx_labels(G, pos, labels=labels, ax=ax, font_size=9, font_weight='bold')
    nx.draw_networkx_edges(G, pos, edgelist=safe_edges, ax=ax,
                          edge_color='steelblue', width=2)
    nx.draw_networkx_edges(G, pos, edgelist=bridge_edges, ax=ax,
                          edge_color='red', width=4, style='dashed')

    red_patch = mpatches.Patch(color='red', label='Bridges (critical links)')
    blue_patch = mpatches.Patch(color='steelblue', label='Non-bridges (redundant)')
    ax.legend(handles=[red_patch, blue_patch], fontsize=11, loc='lower right')
    ax.set_title("Network Backbone — Vulnerability Analysis\nBridges = Single Points of Failure",
                fontsize=14, fontweight='bold')
    ax.axis('off')

    plt.tight_layout()
    plt.savefig(os.path.join(os.path.dirname(__file__), "network_vulnerability.png"),
                dpi=150, bbox_inches='tight')
    plt.close()
    print("\n  Saved: network_vulnerability.png")

# ─────────────────────────────────────────────────────────────────────
# Main
# ─────────────────────────────────────────────────────────────────────

if __name__ == "__main__":
    print("\n" + "━" * 70)
    print("  BRIDGE THEORY IN GRAPHS — INTERACTIVE DEMONSTRATIONS")
    print("  Companion to Lean 4 formalization of the Tree-Bridge Equivalence")
    print("━" * 70 + "\n")

    demo_tree_bridge_equivalence()
    demo_visualize_bridges()
    print()
    demo_konigsberg()
    print()
    demo_bridge_statistics()
    print()
    demo_network_vulnerability()

    print("\n" + "━" * 70)
    print("  All demonstrations complete!")
    print("  Generated images: bridges_visualization.png, konigsberg.png,")
    print("                    bridge_density.png, network_vulnerability.png")
    print("━" * 70 + "\n")
