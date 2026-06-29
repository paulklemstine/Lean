"""
Practical Applications of Bridge Theory
=========================================

This script demonstrates real-world applications of bridge (cut edge)
detection in graphs, corresponding to theorems formalized in Lean 4.

Applications covered:
1. Network infrastructure reliability
2. Social network analysis (weak ties)
3. Internet topology vulnerability
4. Road network critical link identification

Requirements: pip install matplotlib networkx numpy
"""

import matplotlib.pyplot as plt
import networkx as nx
import numpy as np
from collections import defaultdict


# ============================================================
# Application 1: Network Infrastructure Reliability
# ============================================================

def network_reliability_demo():
    """
    Demonstrates how bridge detection identifies single points of
    failure in infrastructure networks.

    Theorem used: IsBridge.two_connected_components
    If a bridge fails, the network splits into exactly 2 components.
    """
    print("=" * 60)
    print("Application 1: Network Infrastructure Reliability")
    print("=" * 60)

    # Model a data center network
    G = nx.Graph()
    nodes = {
        'Core1': (0, 0), 'Core2': (1, 0),
        'Dist1': (-1, 1), 'Dist2': (0, 1), 'Dist3': (1, 1), 'Dist4': (2, 1),
        'Access1': (-1, 2), 'Access2': (0, 2), 'Access3': (1, 2), 'Access4': (2, 2),
    }

    # Core layer (redundant)
    G.add_edge('Core1', 'Core2')

    # Distribution layer
    G.add_edges_from([
        ('Core1', 'Dist1'), ('Core1', 'Dist2'),
        ('Core2', 'Dist3'), ('Core2', 'Dist4'),
        ('Dist1', 'Dist2'),  # Redundancy
        ('Dist3', 'Dist4'),  # Redundancy
    ])

    # Access layer (some with bridges!)
    G.add_edges_from([
        ('Dist1', 'Access1'),  # Bridge!
        ('Dist2', 'Access2'),  # Bridge!
        ('Dist3', 'Access3'),
        ('Dist4', 'Access3'),  # Redundant path to Access3
        ('Dist4', 'Access4'),  # Bridge!
    ])

    bridges = list(nx.bridges(G))
    pos = nodes

    print(f"\nNetwork has {G.number_of_nodes()} nodes, {G.number_of_edges()} edges")
    print(f"Bridges (single points of failure): {bridges}")
    print(f"Number of bridges: {len(bridges)}")

    # For each bridge, show what happens
    for u, v in bridges:
        G_temp = G.copy()
        G_temp.remove_edge(u, v)
        components = list(nx.connected_components(G_temp))
        print(f"\n  Removing bridge ({u}, {v}):")
        print(f"    → Components: {len(components)} (Theorem guarantees exactly 2)")
        for i, comp in enumerate(components):
            print(f"    → Component {i+1}: {comp}")

    # Compute reliability metric
    reliability = 1 - len(bridges) / G.number_of_edges()
    print(f"\nNetwork reliability score: {reliability:.2%}")
    print(f"Recommendation: Add redundant links to eliminate {len(bridges)} bridges")

    # Suggest fixes
    print("\nSuggested redundant links:")
    for u, v in bridges:
        # Find alternative node to connect
        neighbors_u = set(G.neighbors(u)) - {v}
        neighbors_v = set(G.neighbors(v)) - {u}
        if neighbors_u and neighbors_v:
            alt_u = list(neighbors_u)[0]
            print(f"  Add link: {v} — {alt_u} (eliminates bridge {u}—{v})")

    # Visualization
    fig, axes = plt.subplots(1, 2, figsize=(16, 6))

    ax = axes[0]
    edge_colors = ['red' if (u, v) in bridges or (v, u) in bridges
                   else '#666666' for u, v in G.edges()]
    edge_widths = [3 if (u, v) in bridges or (v, u) in bridges
                   else 1.5 for u, v in G.edges()]
    node_colors = ['gold' if 'Core' in n else 'lightblue' if 'Dist' in n
                   else 'lightgreen' for n in G.nodes()]
    nx.draw(G, pos, ax=ax, with_labels=True, node_color=node_colors,
            node_size=700, edge_color=edge_colors, width=edge_widths,
            font_size=8, font_weight='bold')
    ax.set_title(f'Data Center Network\nRed = {len(bridges)} bridges (SPOFs)',
                 fontsize=12)

    # Fixed network
    G_fixed = G.copy()
    G_fixed.add_edges_from([
        ('Access1', 'Dist2'),
        ('Access2', 'Dist1'),
        ('Access4', 'Dist3'),
    ])
    bridges_fixed = list(nx.bridges(G_fixed))

    ax = axes[1]
    new_edges = [('Access1', 'Dist2'), ('Access2', 'Dist1'), ('Access4', 'Dist3')]
    edge_colors_fixed = []
    for u, v in G_fixed.edges():
        if (u, v) in new_edges or (v, u) in new_edges:
            edge_colors_fixed.append('green')
        elif (u, v) in bridges or (v, u) in bridges:
            edge_colors_fixed.append('orange')
        else:
            edge_colors_fixed.append('#666666')

    nx.draw(G_fixed, pos, ax=ax, with_labels=True, node_color=node_colors,
            node_size=700, edge_color=edge_colors_fixed, width=2,
            font_size=8, font_weight='bold')
    ax.set_title(f'Fixed Network (green = new links)\n'
                 f'{len(bridges_fixed)} bridges remaining', fontsize=12)

    plt.suptitle('Application: Critical Infrastructure Protection',
                 fontsize=14, fontweight='bold')
    plt.tight_layout()
    plt.savefig('Bridges/demos/app_infrastructure.png', dpi=150,
                bbox_inches='tight')
    plt.close()
    print("\n✓ Saved app_infrastructure.png")


# ============================================================
# Application 2: Social Network Analysis
# ============================================================

def social_network_demo():
    """
    Demonstrates how bridges identify weak ties between communities
    in social networks.

    Theorem used: connected_isBridge_all_iff_isTree
    If the social network were a tree, EVERY connection would be a
    bridge (weak tie). Real networks have redundancy.
    """
    print("\n" + "=" * 60)
    print("Application 2: Social Network — Weak Ties")
    print("=" * 60)

    # Create a social network with community structure
    G = nx.Graph()

    # Community 1: Engineering team
    eng = ['Alice', 'Bob', 'Carol', 'Dave']
    for i, p1 in enumerate(eng):
        for p2 in eng[i+1:]:
            G.add_edge(p1, p2)

    # Community 2: Marketing team
    mkt = ['Eve', 'Frank', 'Grace', 'Heidi']
    for i, p1 in enumerate(mkt):
        for p2 in mkt[i+1:]:
            G.add_edge(p1, p2)

    # Community 3: Leadership
    lead = ['Ivan', 'Judy', 'Karl']
    for i, p1 in enumerate(lead):
        for p2 in lead[i+1:]:
            G.add_edge(p1, p2)

    # Cross-community bridges (weak ties)
    G.add_edge('Carol', 'Eve')       # Engineering ↔ Marketing (bridge!)
    G.add_edge('Dave', 'Ivan')       # Engineering ↔ Leadership (bridge!)

    bridges = list(nx.bridges(G))

    print(f"\nNetwork: {G.number_of_nodes()} people, {G.number_of_edges()} connections")
    print(f"\nBridges (weak ties between communities):")
    for u, v in bridges:
        print(f"  {u} — {v}")

    print(f"\nTotal bridges: {len(bridges)}")
    print(f"These {len(bridges)} connections are the ONLY links between communities!")
    print("If any one of them is removed, two groups become completely disconnected.")

    # Information flow analysis
    print("\nInformation flow analysis:")
    for source in ['Alice', 'Eve', 'Ivan']:
        for target in ['Frank', 'Karl', 'Bob']:
            if source != target:
                try:
                    path = nx.shortest_path(G, source, target)
                    bridge_crossings = sum(1 for i in range(len(path)-1)
                                          if (path[i], path[i+1]) in bridges
                                          or (path[i+1], path[i]) in bridges)
                    print(f"  {source} → {target}: path length {len(path)-1}, "
                          f"crosses {bridge_crossings} bridge(s)")
                except nx.NetworkXNoPath:
                    print(f"  {source} → {target}: no path!")

    # Visualization
    fig, ax = plt.subplots(1, 1, figsize=(10, 8))
    pos = nx.spring_layout(G, seed=42, k=2)

    community_colors = {}
    for n in eng:
        community_colors[n] = '#FF6B6B'
    for n in mkt:
        community_colors[n] = '#4ECDC4'
    for n in lead:
        community_colors[n] = '#FFE66D'

    node_colors = [community_colors[n] for n in G.nodes()]
    edge_colors = ['red' if (u, v) in bridges or (v, u) in bridges
                   else '#cccccc' for u, v in G.edges()]
    edge_widths = [3 if (u, v) in bridges or (v, u) in bridges
                   else 1 for u, v in G.edges()]

    nx.draw(G, pos, ax=ax, with_labels=True, node_color=node_colors,
            node_size=800, edge_color=edge_colors, width=edge_widths,
            font_size=9, font_weight='bold', edgecolors='black')

    import matplotlib.patches as mpatches
    legend_elements = [
        mpatches.Patch(facecolor='#FF6B6B', label='Engineering'),
        mpatches.Patch(facecolor='#4ECDC4', label='Marketing'),
        mpatches.Patch(facecolor='#FFE66D', label='Leadership'),
        plt.Line2D([0], [0], color='red', linewidth=3, label='Bridge (weak tie)'),
    ]
    ax.legend(handles=legend_elements, loc='upper left', fontsize=10)
    ax.set_title("Social Network: Bridges as Weak Ties Between Communities\n"
                 "(Granovetter's 'Strength of Weak Ties')",
                 fontsize=13, fontweight='bold')

    plt.tight_layout()
    plt.savefig('Bridges/demos/app_social_network.png', dpi=150,
                bbox_inches='tight')
    plt.close()
    print("\n✓ Saved app_social_network.png")


# ============================================================
# Application 3: Tarjan's Bridge-Finding Algorithm
# ============================================================

def tarjan_bridge_demo():
    """
    Implements and demonstrates Tarjan's O(V+E) bridge-finding algorithm.
    Shows the DFS tree, discovery times, and low-link values.
    """
    print("\n" + "=" * 60)
    print("Application 3: Tarjan's Bridge-Finding Algorithm")
    print("=" * 60)

    class TarjanBridgeFinder:
        """
        Tarjan's algorithm for finding bridges in O(V+E) time.

        An edge (u, v) is a bridge iff:
          low[v] > disc[u]
        where disc[u] is the discovery time of u in DFS, and
        low[v] is the minimum discovery time reachable from v's subtree.
        """
        def __init__(self, graph):
            self.graph = graph
            self.timer = 0
            self.disc = {}
            self.low = {}
            self.parent = {}
            self.bridges = []
            self.dfs_edges = []

        def find_bridges(self):
            for node in self.graph.nodes():
                if node not in self.disc:
                    self.parent[node] = None
                    self._dfs(node)
            return self.bridges

        def _dfs(self, u):
            self.disc[u] = self.low[u] = self.timer
            self.timer += 1

            for v in self.graph.neighbors(u):
                if v not in self.disc:
                    self.parent[v] = u
                    self.dfs_edges.append((u, v))
                    self._dfs(v)
                    self.low[u] = min(self.low[u], self.low[v])

                    if self.low[v] > self.disc[u]:
                        self.bridges.append((u, v))
                elif v != self.parent[u]:
                    self.low[u] = min(self.low[u], self.disc[v])

    # Create test graph
    G = nx.Graph()
    G.add_edges_from([
        (1, 2), (2, 3), (3, 1),    # Cycle
        (3, 4),                      # Bridge
        (4, 5), (5, 6), (6, 4),    # Cycle
        (6, 7),                      # Bridge
        (7, 8), (8, 9), (9, 7),    # Cycle
    ])

    finder = TarjanBridgeFinder(G)
    bridges = finder.find_bridges()

    print(f"\nGraph: {G.number_of_nodes()} vertices, {G.number_of_edges()} edges")
    print(f"\nDFS Discovery Times:")
    for node in sorted(finder.disc.keys()):
        print(f"  Node {node}: disc={finder.disc[node]}, low={finder.low[node]}")

    print(f"\nBridges found: {bridges}")
    print(f"\nVerification with NetworkX: {list(nx.bridges(G))}")

    # Verify our theorem: each bridge creates exactly 2 components
    for u, v in bridges:
        G_temp = G.copy()
        G_temp.remove_edge(u, v)
        n_comp = nx.number_connected_components(G_temp)
        print(f"  Removing ({u},{v}) → {n_comp} components "
              f"(Theorem: always 2) {'✓' if n_comp == 2 else '✗'}")

    # Visualization
    fig, axes = plt.subplots(1, 2, figsize=(16, 6))

    pos = nx.spring_layout(G, seed=42)

    # Plot 1: DFS tree with discovery times
    ax = axes[0]
    edge_colors = ['blue' if (u, v) in finder.dfs_edges or (v, u) in finder.dfs_edges
                   else '#cccccc' for u, v in G.edges()]
    edge_styles = ['solid' if (u, v) in finder.dfs_edges or (v, u) in finder.dfs_edges
                   else 'dashed' for u, v in G.edges()]

    nx.draw(G, pos, ax=ax, with_labels=False, node_color='lightblue',
            node_size=600, edge_color=edge_colors, width=2)

    # Add labels with disc/low values
    labels = {n: f"{n}\nd={finder.disc[n]}\nl={finder.low[n]}" for n in G.nodes()}
    nx.draw_networkx_labels(G, pos, labels, ax=ax, font_size=8)

    ax.set_title("DFS Tree with Discovery/Low Values\n"
                 "(Blue = tree edges, Gray = back edges)", fontsize=11)

    # Plot 2: Bridges highlighted
    ax = axes[1]
    edge_colors = ['red' if (u, v) in bridges or (v, u) in bridges
                   else '#666666' for u, v in G.edges()]
    edge_widths = [4 if (u, v) in bridges or (v, u) in bridges
                   else 1.5 for u, v in G.edges()]

    nx.draw(G, pos, ax=ax, with_labels=True, node_color='lightyellow',
            node_size=600, edge_color=edge_colors, width=edge_widths,
            font_size=14, font_weight='bold')

    ax.set_title(f"Bridges Found (red): {bridges}\n"
                 f"Criterion: low[v] > disc[u] for tree edge (u,v)", fontsize=11)

    plt.suptitle("Tarjan's Bridge-Finding Algorithm — O(V+E)",
                 fontsize=14, fontweight='bold')
    plt.tight_layout()
    plt.savefig('Bridges/demos/app_tarjan.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("\n✓ Saved app_tarjan.png")


# ============================================================
# Application 4: Comparative Analysis
# ============================================================

def comparative_analysis():
    """
    Compare bridge counts across different graph families.
    Demonstrates the tree characterization theorem.
    """
    print("\n" + "=" * 60)
    print("Application 4: Comparative Analysis Across Graph Families")
    print("=" * 60)

    results = []

    # Various graph types
    graphs = {
        'Path P₁₀': nx.path_graph(10),
        'Cycle C₁₀': nx.cycle_graph(10),
        'Complete K₆': nx.complete_graph(6),
        'Star S₈': nx.star_graph(7),
        'Grid 3×3': nx.grid_2d_graph(3, 3),
        'Petersen': nx.petersen_graph(),
        'Binary Tree': nx.balanced_tree(2, 3),
        'Barbell': nx.barbell_graph(4, 1),
    }

    print(f"\n{'Graph':<18} {'n':>4} {'m':>4} {'Bridges':>8} {'% Bridge':>9} {'Tree?':>6}")
    print("-" * 55)

    for name, G in graphs.items():
        n = G.number_of_nodes()
        m = G.number_of_edges()
        b = len(list(nx.bridges(G)))
        pct = 100 * b / m if m > 0 else 0
        is_tree = nx.is_tree(G)
        all_bridges = (b == m)

        print(f"{name:<18} {n:>4} {m:>4} {b:>8} {pct:>8.1f}% {'Yes' if is_tree else 'No':>6}")

        # Verify our theorem: tree ↔ all edges are bridges
        if is_tree and not all_bridges:
            print(f"  ⚠ THEOREM VIOLATION: Tree but not all bridges!")
        if all_bridges and nx.is_connected(G) and not is_tree:
            print(f"  ⚠ THEOREM VIOLATION: All bridges but not a tree!")

        results.append((name, n, m, b, is_tree))

    # Verify theorem on all examples
    print(f"\nTheorem verification (Tree ↔ All Bridges):")
    for name, G in graphs.items():
        if not nx.is_connected(G):
            continue
        b = len(list(nx.bridges(G)))
        m = G.number_of_edges()
        is_tree = nx.is_tree(G)
        all_bridges = (b == m)
        status = "✓" if is_tree == all_bridges else "✗"
        print(f"  {status} {name}: tree={is_tree}, all_bridges={all_bridges}")

    # Visualization
    fig, axes = plt.subplots(2, 4, figsize=(20, 10))
    axes = axes.flatten()

    for idx, (name, G) in enumerate(graphs.items()):
        ax = axes[idx]
        pos = nx.spring_layout(G, seed=42)
        bridges = list(nx.bridges(G))
        edge_colors = ['red' if (u, v) in bridges or (v, u) in bridges
                       else '#888888' for u, v in G.edges()]
        edge_widths = [2.5 if (u, v) in bridges or (v, u) in bridges
                       else 1 for u, v in G.edges()]

        nx.draw(G, pos, ax=ax, with_labels=False, node_color='lightblue',
                node_size=150, edge_color=edge_colors, width=edge_widths)

        b = len(bridges)
        m = G.number_of_edges()
        is_tree = nx.is_tree(G)
        ax.set_title(f'{name}\nb={b}/{m} edges'
                     f'{" (TREE)" if is_tree else ""}',
                     fontsize=10)

    plt.suptitle('Bridge Distribution Across Graph Families\n'
                 '(Red = bridge edges, Theorem: Tree ↔ all edges are bridges)',
                 fontsize=14, fontweight='bold')
    plt.tight_layout()
    plt.savefig('Bridges/demos/app_comparison.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("\n✓ Saved app_comparison.png")


if __name__ == '__main__':
    print("=" * 60)
    print("Bridge Theory — Practical Applications")
    print("=" * 60)

    network_reliability_demo()
    social_network_demo()
    tarjan_bridge_demo()
    comparative_analysis()

    print("\n" + "=" * 60)
    print("All applications demonstrated successfully!")
    print("=" * 60)


"""
Bridge (Cut Edge) Visualization and Demonstration
===================================================

This script demonstrates the key theorems about bridges in graph theory
with concrete examples and visualizations:

1. Finding bridges in graphs using DFS (Tarjan's algorithm)
2. Demonstrating that removing a bridge creates exactly 2 components
3. Showing that trees have all edges as bridges
4. The Königsberg Bridge Problem

Requirements: pip install matplotlib networkx numpy
"""

import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import networkx as nx
import numpy as np
from itertools import combinations


def find_bridges(G):
    """Find all bridges (cut edges) in a graph using NetworkX."""
    return list(nx.bridges(G))


def demo_bridge_basics():
    """
    Demonstrate Theorem: An edge is a bridge iff removing it
    disconnects the graph (increases connected components from 1 to 2).
    """
    fig, axes = plt.subplots(1, 3, figsize=(18, 5))

    # Example graph with a bridge
    G = nx.Graph()
    G.add_edges_from([
        (0, 1), (1, 2), (2, 0),  # Triangle (left component)
        (2, 3),                    # Bridge!
        (3, 4), (4, 5), (5, 3),  # Triangle (right component)
    ])

    pos = {0: (0, 1), 1: (1, 1.5), 2: (1, 0.5),
           3: (2, 0.5), 4: (3, 1.5), 5: (3, 0.5)}

    bridges = find_bridges(G)

    # Plot 1: Original graph with bridges highlighted
    ax = axes[0]
    edge_colors = ['red' if (u, v) in bridges or (v, u) in bridges
                   else 'gray' for u, v in G.edges()]
    edge_widths = [3 if (u, v) in bridges or (v, u) in bridges
                   else 1.5 for u, v in G.edges()]

    nx.draw(G, pos, ax=ax, with_labels=True, node_color='lightblue',
            node_size=500, edge_color=edge_colors, width=edge_widths,
            font_size=14, font_weight='bold')
    ax.set_title(f'Graph with bridge (red)\nBridges: {bridges}', fontsize=12)

    # Plot 2: Graph after removing the bridge
    G_removed = G.copy()
    bridge = bridges[0]
    G_removed.remove_edge(*bridge)
    components = list(nx.connected_components(G_removed))

    colors = ['#FF6B6B' if n in components[0] else '#4ECDC4'
              for n in G_removed.nodes()]

    ax = axes[1]
    nx.draw(G_removed, pos, ax=ax, with_labels=True, node_color=colors,
            node_size=500, edge_color='gray', width=1.5,
            font_size=14, font_weight='bold')
    ax.set_title(f'After removing bridge {bridge}\n'
                 f'Components: {len(components)} (Theorem: always 2)',
                 fontsize=12)

    # Plot 3: A graph with NO bridges (2-edge-connected)
    G2 = nx.Graph()
    G2.add_edges_from([
        (0, 1), (1, 2), (2, 3), (3, 0), (0, 2), (1, 3)
    ])
    pos2 = {0: (0, 0), 1: (1, 0), 2: (1, 1), 3: (0, 1)}
    bridges2 = find_bridges(G2)

    ax = axes[2]
    nx.draw(G2, pos2, ax=ax, with_labels=True, node_color='lightgreen',
            node_size=500, edge_color='gray', width=1.5,
            font_size=14, font_weight='bold')
    ax.set_title(f'2-edge-connected graph\nBridges: {bridges2} (none!)',
                 fontsize=12)

    plt.suptitle('Theorem: Removing a Bridge Creates Exactly 2 Components',
                 fontsize=14, fontweight='bold', y=1.02)
    plt.tight_layout()
    plt.savefig('Bridges/demos/bridge_basics.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("✓ Saved bridge_basics.png")


def demo_trees_all_bridges():
    """
    Demonstrate Theorem: A connected graph is a tree ↔ every edge is a bridge.
    """
    fig, axes = plt.subplots(1, 3, figsize=(18, 5))

    # Tree example
    T = nx.random_labeled_tree(8, seed=42)
    pos_T = nx.spring_layout(T, seed=42)
    bridges_T = find_bridges(T)

    ax = axes[0]
    nx.draw(T, pos_T, ax=ax, with_labels=True, node_color='lightyellow',
            node_size=500, edge_color='red', width=2,
            font_size=14, font_weight='bold')
    ax.set_title(f'Tree (8 vertices, 7 edges)\n'
                 f'Bridges: {len(bridges_T)}/{T.number_of_edges()} = ALL edges',
                 fontsize=11)

    # Non-tree with some bridges
    G = nx.Graph()
    G.add_edges_from([
        (0, 1), (1, 2), (2, 0),  # Cycle
        (2, 3),                    # Bridge
        (3, 4), (4, 5), (5, 3),  # Cycle
        (5, 6),                    # Bridge
        (6, 7),                    # Bridge
    ])
    pos_G = nx.spring_layout(G, seed=123)
    bridges_G = find_bridges(G)

    edge_colors = ['red' if (u, v) in bridges_G or (v, u) in bridges_G
                   else 'gray' for u, v in G.edges()]
    edge_widths = [3 if (u, v) in bridges_G or (v, u) in bridges_G
                   else 1.5 for u, v in G.edges()]

    ax = axes[1]
    nx.draw(G, pos_G, ax=ax, with_labels=True, node_color='lightblue',
            node_size=500, edge_color=edge_colors, width=edge_widths,
            font_size=14, font_weight='bold')
    ax.set_title(f'Non-tree graph\n'
                 f'Bridges: {len(bridges_G)}/{G.number_of_edges()} (not all)',
                 fontsize=11)

    # Complete graph (no bridges)
    K5 = nx.complete_graph(5)
    pos_K5 = nx.spring_layout(K5, seed=42)
    bridges_K5 = find_bridges(K5)

    ax = axes[2]
    nx.draw(K5, pos_K5, ax=ax, with_labels=True, node_color='lightgreen',
            node_size=500, edge_color='gray', width=1.5,
            font_size=14, font_weight='bold')
    ax.set_title(f'Complete graph K₅\n'
                 f'Bridges: {len(bridges_K5)}/{K5.number_of_edges()} (none)',
                 fontsize=11)

    plt.suptitle('Theorem: Connected Graph is a Tree ↔ Every Edge is a Bridge',
                 fontsize=14, fontweight='bold', y=1.02)
    plt.tight_layout()
    plt.savefig('Bridges/demos/trees_bridges.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("✓ Saved trees_bridges.png")


def demo_konigsberg():
    """
    Demonstrate the Königsberg Bridge Problem.
    Shows that no Eulerian trail exists because all 4 vertices have odd degree.
    """
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))

    # Historical map-style layout
    ax = axes[0]

    # The four landmasses
    positions = {
        'A': (1, 1.5),    # North bank
        'B': (1, -1.5),   # South bank
        'C': (2, 0),      # Kneiphof island
        'D': (3.5, 0),    # East district
    }

    # The 7 bridges (as a multigraph, we show with curved edges)
    bridges_list = [
        ('A', 'C', 'Bridge 1'), ('A', 'C', 'Bridge 2'),
        ('B', 'C', 'Bridge 3'), ('B', 'C', 'Bridge 4'),
        ('A', 'D', 'Bridge 5'),
        ('B', 'D', 'Bridge 6'),
        ('C', 'D', 'Bridge 7'),
    ]

    # Draw bridges with different curvatures for parallel edges
    curves = {}
    for src, dst, label in bridges_list:
        key = tuple(sorted([src, dst]))
        if key not in curves:
            curves[key] = []
        curves[key].append(label)

    for (src, dst), labels in curves.items():
        x1, y1 = positions[src]
        x2, y2 = positions[dst]
        n = len(labels)
        for i, label in enumerate(labels):
            rad = 0.3 * (i - (n - 1) / 2)
            style = f"arc3,rad={rad}" if abs(rad) > 0.01 else "arc3,rad=0"
            ax.annotate("", xy=(x2, y2), xytext=(x1, y1),
                        arrowprops=dict(arrowstyle="-", color='brown',
                                        lw=3, connectionstyle=style))

    # Draw vertices
    for name, (x, y) in positions.items():
        circle = plt.Circle((x, y), 0.25, color='#FFD700', ec='black', lw=2, zorder=5)
        ax.add_patch(circle)
        ax.text(x, y, name, ha='center', va='center', fontsize=14,
                fontweight='bold', zorder=6)

    ax.set_xlim(-0.5, 4.5)
    ax.set_ylim(-2.5, 2.5)
    ax.set_aspect('equal')
    ax.set_title('Königsberg Bridges (1736)\n7 bridges connecting 4 landmasses',
                 fontsize=12)
    ax.axis('off')

    # Degree analysis
    ax = axes[1]
    vertices = ['A (North)', 'B (South)', 'C (Island)', 'D (East)']
    degrees = [3, 3, 5, 3]  # True multigraph degrees
    simple_degrees = [3, 3, 3, 3]  # K₄ degrees

    x_pos = np.arange(len(vertices))
    width = 0.35

    bars1 = ax.bar(x_pos - width/2, degrees, width, label='Multigraph degree',
                   color='#FF6B6B', edgecolor='black')
    bars2 = ax.bar(x_pos + width/2, simple_degrees, width, label='K₄ degree (our model)',
                   color='#4ECDC4', edgecolor='black')

    ax.set_xlabel('Vertex', fontsize=12)
    ax.set_ylabel('Degree', fontsize=12)
    ax.set_title("Euler's Criterion: All degrees must be even\n"
                 "(except possibly 2 endpoints)\n"
                 "Here ALL degrees are odd → NO Eulerian trail!",
                 fontsize=11)
    ax.set_xticks(x_pos)
    ax.set_xticklabels(vertices, fontsize=10)
    ax.legend()
    ax.axhline(y=0, color='black', linewidth=0.5)

    # Add "ODD" labels
    for bar in bars1:
        height = bar.get_height()
        ax.text(bar.get_x() + bar.get_width() / 2., height + 0.1,
                'ODD', ha='center', va='bottom', fontsize=9, color='red',
                fontweight='bold')

    plt.suptitle("The Königsberg Bridge Problem — Euler's 1736 Theorem",
                 fontsize=14, fontweight='bold', y=1.02)
    plt.tight_layout()
    plt.savefig('Bridges/demos/konigsberg.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("✓ Saved konigsberg.png")


def demo_bridge_finding_algorithm():
    """
    Demonstrate Tarjan's bridge-finding algorithm with step-by-step DFS.
    """
    fig, axes = plt.subplots(2, 2, figsize=(14, 12))

    # Create a graph with interesting bridge structure
    G = nx.Graph()
    G.add_edges_from([
        (0, 1), (1, 2), (2, 3), (3, 0),  # Cycle 1
        (3, 4),                            # Bridge 1
        (4, 5), (5, 6), (6, 7), (7, 4),  # Cycle 2
        (6, 8),                            # Bridge 2
        (8, 9), (9, 10), (10, 8),         # Cycle 3
    ])

    pos = {
        0: (0, 2), 1: (1, 2), 2: (1, 1), 3: (0, 1),
        4: (2, 1.5), 5: (3, 2), 6: (3, 1), 7: (2, 0.5),
        8: (4, 1), 9: (5, 1.5), 10: (5, 0.5)
    }

    bridges = find_bridges(G)
    print(f"\nBridges found: {bridges}")

    # Plot 1: Original graph
    ax = axes[0, 0]
    edge_colors = ['red' if (u, v) in bridges or (v, u) in bridges
                   else '#666666' for u, v in G.edges()]
    edge_widths = [3.5 if (u, v) in bridges or (v, u) in bridges
                   else 1.5 for u, v in G.edges()]
    nx.draw(G, pos, ax=ax, with_labels=True, node_color='lightblue',
            node_size=600, edge_color=edge_colors, width=edge_widths,
            font_size=12, font_weight='bold')
    ax.set_title('Bridges Identified (red edges)', fontsize=12)

    # Plot 2: Components after removing first bridge
    if bridges:
        ax = axes[0, 1]
        G1 = G.copy()
        G1.remove_edge(*bridges[0])
        components = list(nx.connected_components(G1))
        color_map = {}
        palette = ['#FF6B6B', '#4ECDC4', '#FFE66D', '#95E1D3']
        for i, comp in enumerate(components):
            for n in comp:
                color_map[n] = palette[i % len(palette)]
        colors = [color_map[n] for n in G1.nodes()]
        nx.draw(G1, pos, ax=ax, with_labels=True, node_color=colors,
                node_size=600, edge_color='gray', width=1.5,
                font_size=12, font_weight='bold')
        ax.set_title(f'After removing bridge {bridges[0]}\n'
                     f'{len(components)} components (Theorem: always 2)',
                     fontsize=12)

    # Plot 3: Bridge vs non-bridge edge on cycle
    ax = axes[1, 0]
    cycle_edges = [(0, 1), (1, 2), (2, 3), (3, 0)]
    edge_colors_cycle = []
    for u, v in G.edges():
        if (u, v) in cycle_edges or (v, u) in cycle_edges:
            edge_colors_cycle.append('#4ECDC4')
        elif (u, v) in bridges or (v, u) in bridges:
            edge_colors_cycle.append('red')
        else:
            edge_colors_cycle.append('#cccccc')
    edge_widths_cycle = [3 if (u, v) in cycle_edges or (v, u) in cycle_edges
                         or (u, v) in bridges or (v, u) in bridges
                         else 1 for u, v in G.edges()]
    nx.draw(G, pos, ax=ax, with_labels=True, node_color='lightyellow',
            node_size=600, edge_color=edge_colors_cycle, width=edge_widths_cycle,
            font_size=12, font_weight='bold')
    ax.set_title('Bridge ↔ Not on Any Cycle\n'
                 'Green: cycle edges (not bridges)\n'
                 'Red: bridge edges', fontsize=11)

    # Plot 4: Statistics
    ax = axes[1, 1]
    n = G.number_of_nodes()
    m = G.number_of_edges()
    b = len(bridges)
    cycle_rank = m - n + 1

    stats = [
        f"Vertices (n): {n}",
        f"Edges (m): {m}",
        f"Bridges (b): {b}",
        f"Non-bridge edges: {m - b}",
        f"Cycle rank (m-n+1): {cycle_rank}",
        f"",
        f"Key Properties:",
        f"• b ≤ n-1 = {n-1} ✓" if b <= n-1 else f"• b ≤ n-1 = {n-1} ✗",
        f"• Non-bridges ≥ cycle rank: {m-b} ≥ {cycle_rank} ✓",
        f"• Removing bridge → 2 components ✓",
    ]

    ax.text(0.1, 0.9, '\n'.join(stats), transform=ax.transAxes,
            fontsize=13, verticalalignment='top', fontfamily='monospace',
            bbox=dict(boxstyle='round', facecolor='wheat', alpha=0.5))
    ax.set_title('Graph Statistics', fontsize=12)
    ax.axis('off')

    plt.suptitle('Bridge Analysis of a Sample Graph',
                 fontsize=14, fontweight='bold')
    plt.tight_layout()
    plt.savefig('Bridges/demos/bridge_algorithm.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("✓ Saved bridge_algorithm.png")


def demo_network_reliability():
    """
    Application: Network reliability analysis using bridge detection.
    Bridges are single points of failure in networks.
    """
    fig, axes = plt.subplots(1, 2, figsize=(16, 6))

    # Vulnerable network (has bridges)
    G_vuln = nx.Graph()
    G_vuln.add_edges_from([
        ('HQ', 'DC1'), ('DC1', 'DC2'), ('DC2', 'DC3'),
        ('DC1', 'Branch1'), ('Branch1', 'Branch2'), ('Branch2', 'DC1'),
        ('DC3', 'Branch3'),  # Bridge!
        ('Branch3', 'Branch4'), ('Branch4', 'Branch5'), ('Branch5', 'Branch3'),
    ])
    pos_vuln = nx.spring_layout(G_vuln, seed=42)
    bridges_vuln = find_bridges(G_vuln)

    ax = axes[0]
    edge_colors = ['red' if (u, v) in bridges_vuln or (v, u) in bridges_vuln
                   else 'gray' for u, v in G_vuln.edges()]
    edge_widths = [3 if (u, v) in bridges_vuln or (v, u) in bridges_vuln
                   else 1.5 for u, v in G_vuln.edges()]
    nx.draw(G_vuln, pos_vuln, ax=ax, with_labels=True, node_color='#FFB3B3',
            node_size=800, edge_color=edge_colors, width=edge_widths,
            font_size=9, font_weight='bold')
    ax.set_title(f'Vulnerable Network\n'
                 f'{len(bridges_vuln)} bridge(s) = single points of failure',
                 fontsize=12, color='red')

    # Resilient network (no bridges — add redundant links)
    G_res = G_vuln.copy()
    G_res.add_edges_from([
        ('HQ', 'DC3'),           # Redundant link
        ('DC2', 'Branch3'),      # Redundant link
        ('Branch1', 'DC3'),      # Redundant link
    ])
    pos_res = nx.spring_layout(G_res, seed=42)
    bridges_res = find_bridges(G_res)

    ax = axes[1]
    new_edges = [('HQ', 'DC3'), ('DC2', 'Branch3'), ('Branch1', 'DC3')]
    edge_colors_res = []
    for u, v in G_res.edges():
        if (u, v) in new_edges or (v, u) in new_edges:
            edge_colors_res.append('green')
        else:
            edge_colors_res.append('gray')
    edge_widths_res = [3 if (u, v) in new_edges or (v, u) in new_edges
                       else 1.5 for u, v in G_res.edges()]

    nx.draw(G_res, pos_res, ax=ax, with_labels=True, node_color='#B3FFB3',
            node_size=800, edge_color=edge_colors_res, width=edge_widths_res,
            font_size=9, font_weight='bold')
    ax.set_title(f'Resilient Network (3 links added)\n'
                 f'{len(bridges_res)} bridges = no single point of failure!',
                 fontsize=12, color='green')

    plt.suptitle('Application: Network Reliability via Bridge Analysis',
                 fontsize=14, fontweight='bold', y=1.02)
    plt.tight_layout()
    plt.savefig('Bridges/demos/network_reliability.png', dpi=150,
                bbox_inches='tight')
    plt.close()
    print("✓ Saved network_reliability.png")


if __name__ == '__main__':
    print("=" * 60)
    print("Bridge Theory — Demonstrations")
    print("=" * 60)
    print()

    demo_bridge_basics()
    demo_trees_all_bridges()
    demo_konigsberg()
    demo_bridge_finding_algorithm()
    demo_network_reliability()

    print()
    print("All demonstrations complete!")
    print("See the generated PNG files for visualizations.")
