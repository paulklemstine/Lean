"""
Applications of overlap class theory to graph classification,
network analysis, and coding theory.

Demonstrates real-world uses of the support interaction graph,
overlap classes, and overlap signatures as graph invariants.
"""

from algorithms import (
    Graph, find_cycle_supports, overlap_classes, overlap_class_count,
    overlap_degree, overlap_signature, total_overlap_complexity,
    pairwise_disjoint, support_overlap_graph, generate_connected_graphs
)
from collections import defaultdict
from itertools import combinations


# ─── Application 1: Graph Classification via Overlap Signature ───

def overlap_invariant(G: Graph, q: int) -> tuple:
    """
    Compute the overlap invariant of (G, q) as a tuple for classification.

    Returns (class_count, degree, signature_tuple) where:
    - class_count: number of overlap classes
    - degree: overlap degree
    - signature_tuple: sorted pairwise intersection sizes

    This invariant can distinguish some non-isomorphic graphs.
    """
    S = set(range(G.n)) - {q}
    supports = find_cycle_supports(G, S)
    if not supports:
        return (0, 0, ())
    return (
        overlap_class_count(supports),
        overlap_degree(supports),
        tuple(overlap_signature(supports))
    )


def classify_graphs_by_overlap(max_n: int = 6) -> dict:
    """
    Classify connected graphs by their overlap invariant.

    Returns a dict mapping invariant tuples to lists of (n, graph_index, q).
    Graphs with the same invariant for all basepoints are in the same class.
    """
    classification = defaultdict(list)

    for n in range(3, max_n + 1):
        graphs = generate_connected_graphs(n)
        for gi, G in enumerate(graphs):
            # Use canonical basepoint (vertex 0)
            inv = overlap_invariant(G, 0)
            classification[inv].append((n, gi, G.edges()))

    return classification


# ─── Application 2: Network Vulnerability Analysis ───

def cycle_redundancy_analysis(G: Graph) -> dict:
    """
    Analyze cycle-based redundancy in a network.

    Overlap classes represent independent groups of redundant paths.
    Within an overlap class, cycles share vertices (potential single
    points of failure). Across classes, cycles are independent.

    Returns a dict with:
    - 'total_cycles': number of fundamental cycles
    - 'overlap_classes': number of independent redundancy groups
    - 'max_overlap': maximum vertex sharing between cycles
    - 'vulnerability_score': ratio indicating how much cycles interact
    """
    S = set(range(G.n))
    supports = find_cycle_supports(G, S)

    if not supports:
        return {
            'total_cycles': 0,
            'overlap_classes': 0,
            'max_overlap': 0,
            'vulnerability_score': 0.0,
            'is_fully_redundant': False,
        }

    n_classes = overlap_class_count(supports)
    max_deg = overlap_degree(supports)
    total_complex = total_overlap_complexity(supports)
    max_possible = len(supports) * (len(supports) - 1) // 2

    vuln_score = total_complex / max(max_possible, 1)

    return {
        'total_cycles': len(supports),
        'overlap_classes': n_classes,
        'max_overlap': max_deg,
        'vulnerability_score': round(vuln_score, 3),
        'is_fully_redundant': n_classes == 1 and len(supports) > 1,
    }


# ─── Application 3: Coding-Theoretic Support Profiles ───

def support_profile_analysis(supports: list) -> dict:
    """
    Analyze a family of supports as if they were supports of codewords.

    In coding theory, the supports of minimum-weight codewords determine
    many properties of the code. Overlap classes partition these into
    interaction clusters.

    Returns analysis relevant to code properties.
    """
    if not supports:
        return {'n_codewords': 0}

    n = len(supports)
    classes = overlap_classes(supports)

    # Compute weight distribution within classes
    class_weights = []
    for cls in classes:
        weights = [len(supports[i]) for i in cls]
        class_weights.append({
            'indices': cls,
            'weights': weights,
            'min_weight': min(weights),
            'max_weight': max(weights),
            'total_support': len(set().union(*(supports[i] for i in cls))),
        })

    return {
        'n_codewords': n,
        'n_interaction_clusters': len(classes),
        'overlap_degree': overlap_degree(supports),
        'is_orthogonal': pairwise_disjoint(supports),
        'cluster_details': class_weights,
    }


# ─── Application 4: Matroid Circuit Analysis ───

def circuit_overlap_analysis(G: Graph) -> dict:
    """
    Analyze the circuit overlap structure of the graphic matroid.

    For a connected graph G, the circuits of the graphic matroid M(G)
    are exactly the edge sets of cycles. The vertex supports of these
    cycles form the support family whose overlap structure we study.

    This analysis bridges graph theory and matroid theory.
    """
    S = set(range(G.n))
    supports = find_cycle_supports(G, S)

    result = {
        'graph_info': {
            'vertices': G.n,
            'edges': len(G.edges()),
            'cycle_rank': len(G.edges()) - G.n + 1,  # β₁ for connected
        },
        'circuit_supports': [sorted(s) for s in supports],
        'overlap_analysis': {
            'classes': overlap_classes(supports),
            'class_count': overlap_class_count(supports),
            'degree': overlap_degree(supports),
            'signature': overlap_signature(supports),
        }
    }

    # Circuit elimination: for overlapping circuits, identify potential
    # eliminated circuits
    if len(supports) >= 2:
        eliminations = []
        for i, j in combinations(range(len(supports)), 2):
            inter = supports[i] & supports[j]
            if inter:
                sym_diff = supports[i] ^ supports[j]
                eliminations.append({
                    'circuits': (i, j),
                    'intersection': sorted(inter),
                    'symmetric_difference': sorted(sym_diff),
                    'potential_new_support': sorted(sym_diff),
                })
        result['circuit_eliminations'] = eliminations

    return result


def demo_applications():
    """Run all application demonstrations."""

    print("=" * 60)
    print("  APPLICATION 1: Graph Classification by Overlap Invariant")
    print("=" * 60)

    classification = classify_graphs_by_overlap(5)
    print(f"\nNumber of distinct overlap classes: {len(classification)}")
    for inv, graphs in sorted(classification.items()):
        print(f"\n  Invariant {inv}:")
        for n, gi, edges in graphs[:3]:
            print(f"    n={n}, graph #{gi}: edges={edges}")
        if len(graphs) > 3:
            print(f"    ... and {len(graphs) - 3} more")

    print("\n" + "=" * 60)
    print("  APPLICATION 2: Network Vulnerability Analysis")
    print("=" * 60)

    # Compare vulnerability of different network topologies
    networks = {
        'Ring (C₆)': Graph(6, [(i, (i+1) % 6) for i in range(6)]),
        'Complete (K₄)': Graph(4, list(combinations(range(4), 2))),
        'Grid (2×3)': Graph(6, [(0,1),(1,2),(3,4),(4,5),(0,3),(1,4),(2,5)]),
        'Star+cycle': Graph(5, [(0,1),(0,2),(0,3),(0,4),(1,2),(3,4)]),
    }

    for name, G in networks.items():
        analysis = cycle_redundancy_analysis(G)
        print(f"\n  {name}:")
        print(f"    Cycles: {analysis['total_cycles']}")
        print(f"    Independent groups: {analysis['overlap_classes']}")
        print(f"    Max overlap: {analysis['max_overlap']}")
        print(f"    Vulnerability: {analysis['vulnerability_score']}")

    print("\n" + "=" * 60)
    print("  APPLICATION 3: Coding-Theoretic Support Profiles")
    print("=" * 60)

    # Example: supports from a graph's cycle space
    G = Graph(6, [(0,1),(1,2),(2,0),(2,3),(3,4),(4,5),(5,3)])
    supports = find_cycle_supports(G, set(range(6)))
    profile = support_profile_analysis(supports)
    print(f"\n  Number of codewords: {profile['n_codewords']}")
    print(f"  Interaction clusters: {profile['n_interaction_clusters']}")
    print(f"  Orthogonal: {profile['is_orthogonal']}")
    for i, cd in enumerate(profile.get('cluster_details', [])):
        print(f"  Cluster {i}: weights={cd['weights']}, "
              f"total support size={cd['total_support']}")

    print("\n" + "=" * 60)
    print("  APPLICATION 4: Matroid Circuit Analysis")
    print("=" * 60)

    G = Graph(5, [(0,1),(1,2),(2,0),(1,3),(3,4),(4,2)])
    analysis = circuit_overlap_analysis(G)
    print(f"\n  Graph: {analysis['graph_info']}")
    print(f"  Circuit supports: {analysis['circuit_supports']}")
    print(f"  Overlap: {analysis['overlap_analysis']}")
    for elim in analysis.get('circuit_eliminations', []):
        print(f"  Elimination {elim['circuits']}: "
              f"∩={elim['intersection']}, "
              f"Δ={elim['symmetric_difference']}")


if __name__ == "__main__":
    demo_applications()


#!/usr/bin/env python3
"""
Interactive demonstration of the Overlap Class Conjecture.

This script:
1. Generates or accepts a graph
2. Visualizes cycle supports and their overlap graph
3. Displays overlap classes
4. Tests the conjecture on chosen instances
5. Allows batch search up to n = 7
6. Reports counterexamples or summarizes evidence
"""

from algorithms import (
    Graph, find_cycle_supports, support_overlap_graph,
    overlap_classes, overlap_class_count, overlap_degree,
    total_overlap_complexity, overlap_signature, pairwise_disjoint,
    test_overlap_conjecture, generate_connected_graphs, batch_test
)
from itertools import combinations
from collections import defaultdict


def print_header(title: str) -> None:
    print(f"\n{'=' * 60}")
    print(f"  {title}")
    print(f"{'=' * 60}")


def display_graph(G: Graph, name: str = "Graph") -> None:
    """Display a graph's structure."""
    print(f"\n{name}: {G.n} vertices, {len(G.edges())} edges")
    print(f"  Edges: {G.edges()}")
    for v in range(G.n):
        print(f"  Vertex {v}: degree {G.degree(v)}, neighbors {sorted(G.adj[v])}")


def display_supports(supports, label: str = "Cycle supports") -> None:
    """Display a list of supports."""
    print(f"\n{label}: {len(supports)} supports")
    for i, s in enumerate(supports):
        print(f"  Support {i}: {sorted(s)}")


def display_overlap_analysis(supports) -> None:
    """Full overlap analysis of a support family."""
    print(f"\n--- Overlap Analysis ---")
    print(f"  Number of supports: {len(supports)}")
    print(f"  Overlap degree: {overlap_degree(supports)}")
    print(f"  Total complexity: {total_overlap_complexity(supports)}")
    print(f"  Overlap signature: {overlap_signature(supports)}")
    print(f"  Pairwise disjoint: {pairwise_disjoint(supports)}")

    classes = overlap_classes(supports)
    print(f"  Overlap classes ({len(classes)}):")
    for i, c in enumerate(classes):
        support_union = set()
        for idx in c:
            support_union |= supports[idx]
        print(f"    Class {i}: indices {c}, "
              f"union = {sorted(support_union)}")

    # Show pairwise intersections
    if len(supports) > 1:
        print(f"\n  Pairwise intersections:")
        for i, j in combinations(range(len(supports)), 2):
            inter = supports[i] & supports[j]
            if inter:
                print(f"    S_{i} ∩ S_{j} = {sorted(inter)} "
                      f"(size {len(inter)})")
            else:
                print(f"    S_{i} ∩ S_{j} = ∅")


def demo_specific_graph(G: Graph, name: str, q: int, S: set) -> None:
    """Run the full demo on a specific graph instance."""
    print_header(f"Demo: {name}")
    display_graph(G, name)
    print(f"\n  Basepoint q = {q}")
    print(f"  Subset S = {sorted(S)}")

    supports = find_cycle_supports(G, S)
    display_supports(supports)
    display_overlap_analysis(supports)


def demo_predefined_examples() -> None:
    """Run demos on several predefined interesting examples."""

    # Example 1: Triangle (simplest cycle)
    demo_specific_graph(
        Graph(3, [(0, 1), (1, 2), (0, 2)]),
        "Triangle K₃", q=0, S={1, 2}
    )

    # Example 2: Complete graph K₄ (overlapping cycles)
    demo_specific_graph(
        Graph(4, [(0, 1), (0, 2), (0, 3), (1, 2), (1, 3), (2, 3)]),
        "Complete K₄", q=0, S={1, 2, 3}
    )

    # Example 3: Two triangles sharing an edge (overlap degree 1)
    demo_specific_graph(
        Graph(5, [(0, 1), (1, 2), (0, 2), (2, 3), (3, 4), (2, 4)]),
        "Two triangles sharing edge (0,2)→(2)", q=0, S={1, 2, 3, 4}
    )

    # Example 4: Two disjoint triangles connected by path
    demo_specific_graph(
        Graph(7, [(0, 1), (1, 2), (0, 2),  # triangle 1
                  (2, 3),                    # bridge
                  (3, 4), (4, 5), (3, 5),   # triangle 2
                  (5, 6)]),                  # tail
        "Two triangles with bridge", q=6, S={0, 1, 2, 3, 4, 5}
    )

    # Example 5: Petersen-like structure (high overlap)
    demo_specific_graph(
        Graph(6, [(0, 1), (1, 2), (2, 3), (3, 4), (4, 5), (5, 0),
                  (0, 3), (1, 4), (2, 5)]),
        "Prism graph (3-prism)", q=0, S={1, 2, 3, 4, 5}
    )

    # Example 6: Path graph (no cycles, disjoint by vacuity)
    demo_specific_graph(
        Graph(5, [(0, 1), (1, 2), (2, 3), (3, 4)]),
        "Path P₅ (acyclic)", q=0, S={1, 2, 3, 4}
    )


def batch_search(max_n: int = 6) -> None:
    """
    Batch search over all connected graphs up to max_n vertices.
    Reports overlap statistics and any counterexamples to the conjecture.
    """
    print_header(f"Batch Search (n ≤ {max_n})")

    stats = {
        'total': 0,
        'with_cycles': 0,
        'disjoint': 0,
        'overlapping': 0,
        'degree_dist': defaultdict(int),
        'class_count_dist': defaultdict(int),
    }

    for n in range(2, max_n + 1):
        graphs = generate_connected_graphs(n)
        print(f"\nn = {n}: {len(graphs)} connected graphs")

        for gi, G in enumerate(graphs):
            for q in range(n):
                remaining = sorted(set(range(n)) - {q})
                # Test the full subset S = V \ {q}
                S = set(remaining)
                supports = find_cycle_supports(G, S)

                stats['total'] += 1
                if supports:
                    stats['with_cycles'] += 1
                    od = overlap_degree(supports)
                    oc = overlap_class_count(supports)
                    is_disj = pairwise_disjoint(supports)

                    stats['degree_dist'][od] += 1
                    stats['class_count_dist'][oc] += 1
                    if is_disj:
                        stats['disjoint'] += 1
                    else:
                        stats['overlapping'] += 1

    print(f"\n--- Batch Summary ---")
    print(f"  Total (G, q, S=V\\{{q}}) triples: {stats['total']}")
    print(f"  With cycles: {stats['with_cycles']}")
    print(f"  Disjoint supports: {stats['disjoint']}")
    print(f"  Overlapping supports: {stats['overlapping']}")
    print(f"  Overlap degree distribution: "
          f"{dict(sorted(stats['degree_dist'].items()))}")
    print(f"  Overlap class count distribution: "
          f"{dict(sorted(stats['class_count_dist'].items()))}")


def interactive_mode() -> None:
    """Interactive mode: let user specify graphs and subsets."""
    print_header("Interactive Mode")
    print("Commands:")
    print("  'examples' - Run predefined examples")
    print("  'batch N'  - Batch search up to N vertices")
    print("  'graph'    - Enter a custom graph")
    print("  'quit'     - Exit")

    while True:
        try:
            cmd = input("\n> ").strip().lower()
        except (EOFError, KeyboardInterrupt):
            break

        if cmd == 'quit' or cmd == 'q':
            break
        elif cmd == 'examples':
            demo_predefined_examples()
        elif cmd.startswith('batch'):
            parts = cmd.split()
            n = int(parts[1]) if len(parts) > 1 else 6
            batch_search(min(n, 8))
        elif cmd == 'graph':
            try:
                n = int(input("  Number of vertices: "))
                edges_str = input("  Edges (comma-separated pairs, e.g. '0-1,1-2,2-0'): ")
                edges = []
                for e in edges_str.split(','):
                    u, v = e.strip().split('-')
                    edges.append((int(u), int(v)))
                G = Graph(n, edges)
                q = int(input("  Basepoint q: "))
                S_str = input("  Subset S (comma-separated, or 'all' for V\\{q}): ")
                if S_str.strip() == 'all':
                    S = set(range(n)) - {q}
                else:
                    S = {int(x) for x in S_str.split(',')}
                demo_specific_graph(G, "Custom graph", q, S)
            except Exception as e:
                print(f"  Error: {e}")
        else:
            print(f"  Unknown command: {cmd}")


if __name__ == "__main__":
    print_header("Overlap Class Conjecture — Interactive Demo")
    print("""
This demo explores the Overlap Class Conjecture:

  "For every connected finite graph G, basepoint q, and S ⊆ V \\ {q},
   the number of tropical projective equivalence classes of minimal
   generating families of the tropical kernel equals the number of
   overlap classes of cycle supports in G[S]."

The key definitions:
  • Cycle supports: vertex sets of fundamental cycles in G[S]
  • Overlap graph: supports are adjacent if they share a vertex
  • Overlap classes: connected components of the overlap graph
  • Overlap degree: max intersection size among distinct supports
""")

    # Run predefined examples
    demo_predefined_examples()

    # Batch search
    batch_search(max_n=5)

    # Interactive mode if running in a terminal
    import sys
    if sys.stdin.isatty():
        interactive_mode()


"""
Visualize Overlap Degree Distribution Across Graph Families

This script shows how overlap degree varies across all connected graphs
of different sizes, illustrating the transition from the disjoint regime
(degree 0) to increasingly entangled cycle supports.

The visualization produces a heatmap/histogram showing:
- x-axis: overlap degree (0, 1, 2, ...)
- y-axis: number of vertices n
- color/height: number of (G, q) pairs achieving that overlap degree
"""

import matplotlib.pyplot as plt
import numpy as np
from collections import defaultdict, deque
from itertools import combinations


# ──────── Inline implementations (self-contained) ────────

class Graph:
    def __init__(self, n, edges=None):
        self.n = n
        self.adj = defaultdict(set)
        if edges:
            for u, v in edges:
                self.adj[u].add(v)
                self.adj[v].add(u)

    def edges(self):
        return [(u, v) for u in range(self.n) for v in self.adj[u] if u < v]

    def is_connected(self):
        if self.n == 0:
            return True
        visited = {0}
        queue = deque([0])
        while queue:
            u = queue.popleft()
            for v in self.adj[u]:
                if v not in visited:
                    visited.add(v)
                    queue.append(v)
        return len(visited) == self.n


def find_cycle_supports(G, S):
    vertices = sorted(S)
    adj_in_S = defaultdict(set)
    for u in vertices:
        for v in G.adj[u]:
            if v in S:
                adj_in_S[u].add(v)
    parent, visited, tree_edges, non_tree = {}, set(), set(), []
    for root in vertices:
        if root in visited:
            continue
        visited.add(root)
        parent[root] = -1
        queue = deque([root])
        while queue:
            u = queue.popleft()
            for v in adj_in_S[u]:
                if v not in visited:
                    visited.add(v)
                    parent[v] = u
                    tree_edges.add((min(u,v), max(u,v)))
                    queue.append(v)
                elif (min(u,v), max(u,v)) not in tree_edges:
                    non_tree.append((u, v))
    supports = []
    for u, v in non_tree:
        pu, x = [], u
        while x != -1: pu.append(x); x = parent[x]
        pv, x = [], v
        while x != -1: pv.append(x); x = parent[x]
        su = set(pu)
        lca = next((x for x in pv if x in su), None)
        if lca is None: continue
        cycle = set()
        for x in pu:
            cycle.add(x)
            if x == lca: break
        for x in pv:
            cycle.add(x)
            if x == lca: break
        supports.append(frozenset(cycle))
    return supports


def overlap_degree(supports):
    mx = 0
    for i, j in combinations(range(len(supports)), 2):
        mx = max(mx, len(supports[i] & supports[j]))
    return mx


def overlap_class_count(supports):
    n = len(supports)
    if n == 0: return 0
    adj = defaultdict(set)
    for i, j in combinations(range(n), 2):
        if supports[i] & supports[j]:
            adj[i].add(j); adj[j].add(i)
    visited, count = set(), 0
    for s in range(n):
        if s in visited: continue
        count += 1
        queue = deque([s]); visited.add(s)
        while queue:
            u = queue.popleft()
            for v in adj[u]:
                if v not in visited:
                    visited.add(v); queue.append(v)
    return count


def generate_connected_graphs(n):
    if n <= 1: return [Graph(n)] if n == 1 else []
    all_edges = list(combinations(range(n), 2))
    m = len(all_edges)
    graphs = []
    for mask in range(1, 1 << m):
        edges = [all_edges[i] for i in range(m) if mask & (1 << i)]
        g = Graph(n, edges)
        if g.is_connected():
            graphs.append(g)
    return graphs


# ──────── Data collection ────────

max_n = 6
degree_data = defaultdict(lambda: defaultdict(int))
class_data = defaultdict(lambda: defaultdict(int))

for n in range(3, max_n + 1):
    print(f"Processing n = {n}...")
    graphs = generate_connected_graphs(n)
    for G in graphs:
        for q in range(n):
            S = set(range(n)) - {q}
            supports = find_cycle_supports(G, S)
            if supports:
                od = overlap_degree(supports)
                oc = overlap_class_count(supports)
                degree_data[n][od] += 1
                class_data[n][oc] += 1

# ──────── Visualization ────────

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(16, 7))

# Plot 1: Overlap degree distribution
colors = ['#2ecc71', '#3498db', '#e74c3c', '#f39c12', '#9b59b6',
          '#1abc9c', '#e67e22', '#34495e', '#c0392b']

max_deg = max(max(d.keys()) for d in degree_data.values() if d)
x_labels = list(range(max_deg + 1))

bar_width = 0.15
for idx, n in enumerate(sorted(degree_data.keys())):
    offsets = [x + idx * bar_width for x in x_labels]
    heights = [degree_data[n].get(d, 0) for d in x_labels]
    ax1.bar(offsets, heights, bar_width, label=f'n={n}',
            color=colors[idx % len(colors)], alpha=0.8,
            edgecolor='white', linewidth=0.5)

ax1.set_xlabel('Overlap Degree', fontsize=13)
ax1.set_ylabel('Number of (G, q) pairs', fontsize=13)
ax1.set_title('Distribution of Overlap Degree\n'
              'by Graph Size', fontsize=14, fontweight='bold')
ax1.set_xticks([x + bar_width * len(degree_data) / 2 for x in x_labels])
ax1.set_xticklabels(x_labels)
ax1.legend(fontsize=11)
ax1.grid(axis='y', alpha=0.3)

# Annotate key finding
total_zero = sum(degree_data[n].get(0, 0) for n in degree_data)
total_all = sum(sum(d.values()) for d in degree_data.values())
pct_disjoint = 100 * total_zero / max(total_all, 1)
ax1.annotate(f'{pct_disjoint:.1f}% have\noverlap degree 0\n(disjoint regime)',
             xy=(0, max(degree_data[max_n].get(0, 0),
                        degree_data[max_n - 1].get(0, 0))),
             xytext=(2, max(max(d.values()) for d in degree_data.values()) * 0.7),
             fontsize=10, ha='center',
             arrowprops=dict(arrowstyle='->', color='#e74c3c'),
             bbox=dict(boxstyle='round,pad=0.3', facecolor='#fff3cd',
                       edgecolor='#e74c3c'))

# Plot 2: Overlap class count distribution
max_cls = max(max(d.keys()) for d in class_data.values() if d)
x_labels2 = list(range(1, max_cls + 1))

for idx, n in enumerate(sorted(class_data.keys())):
    offsets = [x + idx * bar_width for x in x_labels2]
    heights = [class_data[n].get(c, 0) for c in x_labels2]
    ax2.bar(offsets, heights, bar_width, label=f'n={n}',
            color=colors[idx % len(colors)], alpha=0.8,
            edgecolor='white', linewidth=0.5)

ax2.set_xlabel('Number of Overlap Classes', fontsize=13)
ax2.set_ylabel('Number of (G, q) pairs', fontsize=13)
ax2.set_title('Distribution of Overlap Class Count\n'
              'by Graph Size', fontsize=14, fontweight='bold')
ax2.set_xticks([x + bar_width * len(class_data) / 2 for x in x_labels2])
ax2.set_xticklabels(x_labels2)
ax2.legend(fontsize=11)
ax2.grid(axis='y', alpha=0.3)

plt.tight_layout()
plt.savefig("overlap_degree_distribution.png", dpi=150, bbox_inches='tight')
print("Saved: overlap_degree_distribution.png")


"""
Visualize the Support Interaction Graph (Overlap Graph)

This script illustrates the core concept of the overlap class theory:
given a graph G and a subset S of its vertices, the cycle supports in
G[S] form a support family. The overlap graph connects supports that
share at least one vertex. Connected components of this overlap graph
are the "overlap classes" — independent interaction sectors.

The visualization shows:
1. The original graph G with highlighted subset S
2. The cycle supports found in G[S]
3. The support interaction graph (overlap graph)
4. Overlap classes color-coded
"""

import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np
from collections import defaultdict, deque
from itertools import combinations


# ──────── Inline implementations (self-contained) ────────

class Graph:
    def __init__(self, n, edges=None):
        self.n = n
        self.adj = defaultdict(set)
        if edges:
            for u, v in edges:
                self.adj[u].add(v)
                self.adj[v].add(u)

    def edges(self):
        result = []
        for u in range(self.n):
            for v in self.adj[u]:
                if u < v:
                    result.append((u, v))
        return result

    def degree(self, v):
        return len(self.adj[v])


def find_cycle_supports(G, S):
    vertices = sorted(S)
    adj_in_S = defaultdict(set)
    for u in vertices:
        for v in G.adj[u]:
            if v in S:
                adj_in_S[u].add(v)

    parent = {}
    visited = set()
    tree_edges = set()
    non_tree_edges = []

    for root in vertices:
        if root in visited:
            continue
        visited.add(root)
        parent[root] = -1
        queue = deque([root])
        while queue:
            u = queue.popleft()
            for v in adj_in_S[u]:
                if v not in visited:
                    visited.add(v)
                    parent[v] = u
                    tree_edges.add((min(u, v), max(u, v)))
                    queue.append(v)
                elif (min(u, v), max(u, v)) not in tree_edges:
                    non_tree_edges.append((u, v))

    supports = []
    for u, v in non_tree_edges:
        path_u, x = [], u
        while x != -1:
            path_u.append(x)
            x = parent[x]
        path_v, x = [], v
        while x != -1:
            path_v.append(x)
            x = parent[x]
        set_u = set(path_u)
        lca = next((x for x in path_v if x in set_u), None)
        if lca is None:
            continue
        cycle = set()
        for x in path_u:
            cycle.add(x)
            if x == lca:
                break
        for x in path_v:
            cycle.add(x)
            if x == lca:
                break
        supports.append(frozenset(cycle))
    return supports


def overlap_classes(supports):
    n = len(supports)
    if n == 0:
        return []
    adj = defaultdict(set)
    for i, j in combinations(range(n), 2):
        if supports[i] & supports[j]:
            adj[i].add(j)
            adj[j].add(i)
    visited = set()
    components = []
    for start in range(n):
        if start in visited:
            continue
        comp = []
        queue = deque([start])
        visited.add(start)
        while queue:
            u = queue.popleft()
            comp.append(u)
            for v in adj[u]:
                if v not in visited:
                    visited.add(v)
                    queue.append(v)
        components.append(sorted(comp))
    return components


def overlap_degree(supports):
    mx = 0
    for i, j in combinations(range(len(supports)), 2):
        mx = max(mx, len(supports[i] & supports[j]))
    return mx


# ──────── Layout helpers ────────

def circular_layout(n, center=(0, 0), radius=1.0):
    positions = {}
    for i in range(n):
        angle = 2 * np.pi * i / n - np.pi / 2
        positions[i] = (center[0] + radius * np.cos(angle),
                        center[1] + radius * np.sin(angle))
    return positions


def draw_graph(ax, G, pos, S=None, title="", supports=None, classes=None):
    """Draw graph with optional highlighting."""
    # Colors for overlap classes
    class_colors = ['#e74c3c', '#3498db', '#2ecc71', '#f39c12',
                    '#9b59b6', '#1abc9c', '#e67e22', '#34495e']

    # Draw edges
    for u, v in G.edges():
        x = [pos[u][0], pos[v][0]]
        y = [pos[u][1], pos[v][1]]
        ax.plot(x, y, 'k-', linewidth=1, alpha=0.4, zorder=1)

    # Draw vertices
    for v in range(G.n):
        color = '#cccccc'
        size = 300
        if S and v in S:
            color = '#3498db'
            size = 400
        ax.scatter(pos[v][0], pos[v][1], s=size, c=color,
                   edgecolors='black', linewidth=1.5, zorder=3)
        ax.annotate(str(v), pos[v], ha='center', va='center',
                    fontsize=10, fontweight='bold', zorder=4)

    ax.set_title(title, fontsize=12, fontweight='bold')
    ax.set_aspect('equal')
    ax.axis('off')


def draw_overlap_graph(ax, supports, classes, title="Overlap Graph"):
    """Draw the support interaction graph with overlap classes colored."""
    n = len(supports)
    if n == 0:
        ax.text(0.5, 0.5, "No supports", ha='center', va='center',
                transform=ax.transAxes, fontsize=14)
        ax.set_title(title, fontsize=12, fontweight='bold')
        ax.axis('off')
        return

    class_colors = ['#e74c3c', '#3498db', '#2ecc71', '#f39c12',
                    '#9b59b6', '#1abc9c', '#e67e22', '#34495e']

    # Assign colors
    node_color = {}
    for ci, cls in enumerate(classes):
        for idx in cls:
            node_color[idx] = class_colors[ci % len(class_colors)]

    pos = circular_layout(n, radius=1.0)

    # Draw edges (overlapping pairs)
    for i, j in combinations(range(n), 2):
        if supports[i] & supports[j]:
            x = [pos[i][0], pos[j][0]]
            y = [pos[i][1], pos[j][1]]
            inter_size = len(supports[i] & supports[j])
            ax.plot(x, y, '-', color='#e74c3c', linewidth=1 + inter_size,
                    alpha=0.5, zorder=1)
            mx, my = (x[0] + x[1]) / 2, (y[0] + y[1]) / 2
            ax.annotate(str(inter_size), (mx, my), ha='center', va='center',
                        fontsize=8, color='red', fontweight='bold',
                        bbox=dict(boxstyle='round,pad=0.2', facecolor='white',
                                  edgecolor='red', alpha=0.8), zorder=5)

    # Draw nodes
    for i in range(n):
        ax.scatter(pos[i][0], pos[i][1], s=500,
                   c=node_color.get(i, '#cccccc'),
                   edgecolors='black', linewidth=2, zorder=3)
        ax.annotate(f"S{i}", pos[i], ha='center', va='center',
                    fontsize=9, fontweight='bold', color='white', zorder=4)

    # Legend
    handles = []
    for ci, cls in enumerate(classes):
        color = class_colors[ci % len(class_colors)]
        handles.append(mpatches.Patch(color=color,
                                       label=f'Class {ci}: {cls}'))
    if handles:
        ax.legend(handles=handles, loc='upper right', fontsize=8)

    ax.set_title(title, fontsize=12, fontweight='bold')
    ax.set_aspect('equal')
    ax.axis('off')


# ──────── Main visualization ────────

# Example 1: Two triangles sharing a vertex (overlap degree 1)
G1 = Graph(5, [(0, 1), (1, 2), (0, 2), (2, 3), (3, 4), (2, 4)])
S1 = {0, 1, 2, 3, 4}
supports1 = find_cycle_supports(G1, S1)
classes1 = overlap_classes(supports1)

# Example 2: Complete graph K4 (high overlap)
G2 = Graph(4, list(combinations(range(4), 2)))
S2 = {0, 1, 2, 3}
supports2 = find_cycle_supports(G2, S2)
classes2 = overlap_classes(supports2)

# Example 3: Two disjoint triangles
G3 = Graph(6, [(0, 1), (1, 2), (0, 2), (3, 4), (4, 5), (3, 5)])
S3 = {0, 1, 2, 3, 4, 5}
supports3 = find_cycle_supports(G3, S3)
classes3 = overlap_classes(supports3)

fig, axes = plt.subplots(3, 2, figsize=(14, 18))
fig.suptitle("Support Interaction Graphs and Overlap Classes",
             fontsize=16, fontweight='bold', y=0.98)

# Row 1: Two triangles sharing vertex
pos1 = {0: (-1, 0.5), 1: (0, 1.5), 2: (1, 0.5), 3: (2, 1.5), 4: (3, 0.5)}
draw_graph(axes[0, 0], G1, pos1, S1,
           title=f"Two triangles sharing vertex 2\n"
                 f"Supports: {[sorted(s) for s in supports1]}")
draw_overlap_graph(axes[0, 1], supports1, classes1,
                   title=f"Overlap Graph (degree={overlap_degree(supports1)})")

# Row 2: Complete K4
pos2 = circular_layout(4, radius=1.0)
draw_graph(axes[1, 0], G2, pos2, S2,
           title=f"Complete graph K₄\n"
                 f"Supports: {[sorted(s) for s in supports2]}")
draw_overlap_graph(axes[1, 1], supports2, classes2,
                   title=f"Overlap Graph (degree={overlap_degree(supports2)})")

# Row 3: Two disjoint triangles
pos3 = {0: (-1.5, 0), 1: (-0.5, 1), 2: (-0.5, -1),
        3: (1.5, 0), 4: (0.5, 1), 5: (0.5, -1)}
draw_graph(axes[2, 0], G3, pos3, S3,
           title=f"Two disjoint triangles\n"
                 f"Supports: {[sorted(s) for s in supports3]}")
draw_overlap_graph(axes[2, 1], supports3, classes3,
                   title=f"Overlap Graph (degree={overlap_degree(supports3)})")

plt.tight_layout(rect=[0, 0, 1, 0.96])
plt.savefig("overlap_graph_visualization.png", dpi=150, bbox_inches='tight')
print("Saved: overlap_graph_visualization.png")


"""
Visualize the Support Nerve as a Heatmap

Shows the pairwise intersection structure of cycle supports as a
symmetric heatmap. Each cell (i,j) shows the size of the intersection
between support i and support j. The diagonal shows support sizes.

This reveals the "interaction matrix" that governs how tropical
kernel generators entangle across overlapping cycle supports.
"""

import matplotlib.pyplot as plt
import numpy as np
from collections import defaultdict, deque
from itertools import combinations


# ──────── Inline implementations (self-contained) ────────

class Graph:
    def __init__(self, n, edges=None):
        self.n = n
        self.adj = defaultdict(set)
        if edges:
            for u, v in edges:
                self.adj[u].add(v)
                self.adj[v].add(u)


def find_cycle_supports(G, S):
    vertices = sorted(S)
    adj_in_S = defaultdict(set)
    for u in vertices:
        for v in G.adj[u]:
            if v in S:
                adj_in_S[u].add(v)
    parent, visited, tree_edges, non_tree = {}, set(), set(), []
    for root in vertices:
        if root in visited:
            continue
        visited.add(root)
        parent[root] = -1
        queue = deque([root])
        while queue:
            u = queue.popleft()
            for v in adj_in_S[u]:
                if v not in visited:
                    visited.add(v)
                    parent[v] = u
                    tree_edges.add((min(u,v), max(u,v)))
                    queue.append(v)
                elif (min(u,v), max(u,v)) not in tree_edges:
                    non_tree.append((u, v))
    supports = []
    for u, v in non_tree:
        pu, x = [], u
        while x != -1: pu.append(x); x = parent[x]
        pv, x = [], v
        while x != -1: pv.append(x); x = parent[x]
        su = set(pu)
        lca = next((x for x in pv if x in su), None)
        if lca is None: continue
        cycle = set()
        for x in pu:
            cycle.add(x)
            if x == lca: break
        for x in pv:
            cycle.add(x)
            if x == lca: break
        supports.append(frozenset(cycle))
    return supports


def overlap_classes(supports):
    n = len(supports)
    if n == 0: return []
    adj = defaultdict(set)
    for i, j in combinations(range(n), 2):
        if supports[i] & supports[j]:
            adj[i].add(j); adj[j].add(i)
    visited, comps = set(), []
    for s in range(n):
        if s in visited: continue
        comp = []
        queue = deque([s]); visited.add(s)
        while queue:
            u = queue.popleft(); comp.append(u)
            for v in adj[u]:
                if v not in visited:
                    visited.add(v); queue.append(v)
        comps.append(sorted(comp))
    return comps


# ──────── Create examples ────────

examples = [
    {
        'name': 'Prism Graph (3-prism)',
        'graph': Graph(6, [(0,1),(1,2),(2,3),(3,4),(4,5),(5,0),
                           (0,3),(1,4),(2,5)]),
        'S': {0, 1, 2, 3, 4, 5},
    },
    {
        'name': 'Complete K₅ (minus vertex 0)',
        'graph': Graph(5, list(combinations(range(5), 2))),
        'S': {1, 2, 3, 4},
    },
    {
        'name': 'Petersen-like (wheel W₅)',
        'graph': Graph(6, [(0,1),(0,2),(0,3),(0,4),(0,5),
                           (1,2),(2,3),(3,4),(4,5),(5,1)]),
        'S': {1, 2, 3, 4, 5},
    },
]


fig, axes = plt.subplots(1, 3, figsize=(18, 6))
fig.suptitle('Support Nerve Heatmaps: Pairwise Intersection Structure',
             fontsize=15, fontweight='bold', y=1.02)

for idx, ex in enumerate(examples):
    ax = axes[idx]
    G = ex['graph']
    S = ex['S']
    supports = find_cycle_supports(G, S)
    n = len(supports)

    if n == 0:
        ax.text(0.5, 0.5, 'No cycles found', ha='center', va='center',
                transform=ax.transAxes, fontsize=14)
        ax.set_title(ex['name'])
        continue

    # Build intersection matrix
    matrix = np.zeros((n, n), dtype=int)
    for i in range(n):
        matrix[i, i] = len(supports[i])
        for j in range(i + 1, n):
            inter = len(supports[i] & supports[j])
            matrix[i, j] = inter
            matrix[j, i] = inter

    # Get overlap classes for ordering
    classes = overlap_classes(supports)

    # Reorder by class
    order = []
    for cls in classes:
        order.extend(cls)
    reordered = matrix[np.ix_(order, order)]

    # Plot heatmap
    im = ax.imshow(reordered, cmap='YlOrRd', interpolation='nearest',
                   aspect='equal')

    # Annotate cells
    for i in range(n):
        for j in range(n):
            val = reordered[i, j]
            color = 'white' if val > matrix.max() * 0.6 else 'black'
            ax.text(j, i, str(val), ha='center', va='center',
                    fontsize=10, fontweight='bold', color=color)

    # Draw class boundaries
    pos = 0
    for cls in classes:
        if pos > 0:
            ax.axhline(y=pos - 0.5, color='blue', linewidth=2)
            ax.axvline(x=pos - 0.5, color='blue', linewidth=2)
        pos += len(cls)

    ax.set_xticks(range(n))
    ax.set_yticks(range(n))
    ax.set_xticklabels([f'S{order[i]}' for i in range(n)], fontsize=9)
    ax.set_yticklabels([f'S{order[i]}' for i in range(n)], fontsize=9)

    cls_str = ', '.join([str(c) for c in classes])
    ax.set_title(f'{ex["name"]}\n{n} supports, classes: {cls_str}',
                 fontsize=11, fontweight='bold')

    plt.colorbar(im, ax=ax, fraction=0.046, pad=0.04, label='|Sᵢ ∩ Sⱼ|')

plt.tight_layout()
plt.savefig("overlap_heatmap.png", dpi=150, bbox_inches='tight')
print("Saved: overlap_heatmap.png")
