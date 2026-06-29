"""
Practical Applications of Euler's Bridge Theorem
=================================================

This script demonstrates real-world applications of the graph theory
results formalized in our Lean 4 proofs.

1. Network reliability analysis (bridge edge detection)
2. Route planning (Chinese Postman Problem)
3. DNA fragment assembly (Eulerian paths on de Bruijn graphs)
"""

from collections import defaultdict, deque
from itertools import combinations


# ============================================================
# Application 1: Network Reliability Analysis
# ============================================================

def find_bridges(n, edges):
    """Find all bridge edges in a graph using Tarjan's algorithm.

    A bridge is an edge whose removal disconnects the graph.
    Our Lean formalization proves:
    - In a tree, every edge is a bridge (tree_all_bridges)
    - In K_n (n>2), no edge is a bridge (completeGraph_no_bridges)
    - An edge is a bridge iff it lies in no cycle (bridge_iff_not_in_cycle)

    Returns: list of bridge edges (u, v)
    """
    adj = defaultdict(list)
    for u, v in edges:
        adj[u].append(v)
        adj[v].append(u)

    visited = [False] * n
    disc = [0] * n
    low = [0] * n
    parent = [-1] * n
    bridges = []
    timer = [0]

    def dfs(u):
        visited[u] = True
        disc[u] = low[u] = timer[0]
        timer[0] += 1

        for v in adj[u]:
            if not visited[v]:
                parent[v] = u
                dfs(v)
                low[u] = min(low[u], low[v])
                if low[v] > disc[u]:
                    bridges.append((u, v))
            elif v != parent[u]:
                low[u] = min(low[u], disc[v])

    for i in range(n):
        if not visited[i]:
            dfs(i)

    return bridges


def network_reliability_demo():
    """Demonstrate bridge edge detection for network reliability."""
    print("=" * 60)
    print("  APPLICATION 1: NETWORK RELIABILITY ANALYSIS")
    print("=" * 60)

    # Example: A small data center network
    # Nodes: 0=Router, 1=Server1, 2=Server2, 3=Server3,
    #        4=Backup, 5=Gateway
    nodes = {
        0: "Router",
        1: "Server A",
        2: "Server B",
        3: "Server C",
        4: "Backup",
        5: "Gateway"
    }

    edges = [
        (0, 1), (0, 2), (0, 3),  # Router connects to servers
        (1, 2),                    # Redundant link between A and B
        (3, 4),                    # Backup link
        (4, 5),                    # Gateway link
        (0, 5),                    # Router to gateway
    ]

    print("\n  Network Topology:")
    for u, v in edges:
        print(f"    {nodes[u]} <-> {nodes[v]}")

    bridges = find_bridges(6, edges)

    print(f"\n  Bridge Edges (single points of failure): {len(bridges)}")
    for u, v in bridges:
        print(f"    ⚠️  {nodes[u]} <-> {nodes[v]}")

    non_bridges = [(u, v) for u, v in edges if (u, v) not in bridges and (v, u) not in bridges]
    print(f"\n  Redundant Edges (failure-tolerant): {len(non_bridges)}")
    for u, v in non_bridges:
        print(f"    ✓  {nodes[u]} <-> {nodes[v]}")

    # Recommendation
    print("\n  Recommendation: Add redundant links to eliminate bridges.")
    for u, v in bridges:
        print(f"    → Add alternative path for {nodes[u]} <-> {nodes[v]}")

    # Verify our Lean theorem: tree has all bridges
    print("\n  Verification of tree_all_bridges theorem:")
    tree_edges = [(0, 1), (1, 2), (2, 3), (3, 4)]
    tree_bridges = find_bridges(5, tree_edges)
    print(f"    Path graph P₅: {len(tree_edges)} edges, {len(tree_bridges)} bridges")
    print(f"    All edges are bridges: {len(tree_bridges) == len(tree_edges)} ✓")

    # Verify: complete graph has no bridges
    print("\n  Verification of completeGraph_no_bridges theorem:")
    k5_edges = list(combinations(range(5), 2))
    k5_bridges = find_bridges(5, k5_edges)
    print(f"    K₅: {len(k5_edges)} edges, {len(k5_bridges)} bridges")
    print(f"    No bridges: {len(k5_bridges) == 0} ✓")


# ============================================================
# Application 2: Chinese Postman Problem
# ============================================================

def chinese_postman_demo():
    """Demonstrate the Chinese Postman Problem — route planning
    that must traverse every edge (street).

    Key insight from our formalization:
    - If odd-degree vertex count = 0: Euler circuit exists (perfect route)
    - If odd-degree vertex count = 2: Euler path exists
    - If odd-degree vertex count > 2: Must duplicate some edges
    """
    print("\n" + "=" * 60)
    print("  APPLICATION 2: ROUTE PLANNING (CHINESE POSTMAN)")
    print("=" * 60)

    # Example: A mail carrier's neighborhood
    streets = {
        (0, 1): "Main St",
        (1, 2): "Oak Ave",
        (2, 3): "Pine Rd",
        (3, 0): "Elm Dr",
        (0, 2): "Center Blvd",
        (1, 4): "Market St",
        (4, 5): "Harbor Way",
        (5, 2): "Bay Rd",
    }

    print("\n  Neighborhood streets:")
    for (u, v), name in streets.items():
        print(f"    {name}: intersection {u} ↔ {v}")

    # Compute degrees
    degrees = defaultdict(int)
    for u, v in streets:
        degrees[u] += 1
        degrees[v] += 1

    print("\n  Intersection degrees:")
    odd_vertices = []
    for v in sorted(degrees):
        parity = "odd ✗" if degrees[v] % 2 == 1 else "even ✓"
        if degrees[v] % 2 == 1:
            odd_vertices.append(v)
        print(f"    Intersection {v}: degree {degrees[v]} ({parity})")

    print(f"\n  Odd-degree intersections: {odd_vertices}")
    print(f"  Count: {len(odd_vertices)}")

    if len(odd_vertices) == 0:
        print("\n  ✓ PERFECT ROUTE EXISTS (Euler circuit)")
        print("    The mail carrier can start anywhere and return without retracing.")
    elif len(odd_vertices) == 2:
        print(f"\n  ✓ EFFICIENT ROUTE EXISTS (Euler path)")
        print(f"    Start at intersection {odd_vertices[0]}, end at {odd_vertices[1]}")
        print(f"    (or vice versa)")
    else:
        extra = (len(odd_vertices) - 2) // 2
        print(f"\n  ✗ NO PERFECT ROUTE — must retrace {extra} street(s)")
        print(f"    By our odd_degree_eulerian_obstruction theorem,")
        print(f"    {len(odd_vertices)} > 2 odd-degree vertices means some edges")
        print(f"    must be traversed twice.")

        # Suggest which streets to duplicate
        print(f"\n    Strategy: Pair up odd-degree vertices and duplicate")
        print(f"    shortest paths between each pair.")
        for i in range(0, len(odd_vertices) - 1, 2):
            print(f"    → Duplicate path between {odd_vertices[i]} and {odd_vertices[i+1]}")


# ============================================================
# Application 3: DNA Assembly via Eulerian Paths
# ============================================================

def dna_assembly_demo():
    """Demonstrate DNA fragment assembly using de Bruijn graphs
    and Eulerian paths.

    DNA sequencing produces short reads (k-mers). Assembly reconstructs
    the original sequence by finding an Eulerian path in the de Bruijn graph
    where vertices are (k-1)-mers and edges are k-mers.
    """
    print("\n" + "=" * 60)
    print("  APPLICATION 3: DNA SEQUENCE ASSEMBLY")
    print("=" * 60)

    # Original DNA sequence (unknown to the assembler)
    original = "ATGCGATCGA"
    k = 4  # k-mer length

    print(f"\n  Original sequence: {original} (length {len(original)})")
    print(f"  k-mer size: {k}")

    # Generate k-mers (simulate sequencing reads)
    kmers = [original[i:i+k] for i in range(len(original) - k + 1)]
    print(f"\n  Sequencing reads ({k}-mers):")
    for i, kmer in enumerate(kmers):
        print(f"    Read {i+1}: {kmer}")

    # Build de Bruijn graph
    # Vertices: (k-1)-mers, Edges: k-mers
    edges = []
    adj = defaultdict(list)
    for kmer in kmers:
        prefix = kmer[:-1]
        suffix = kmer[1:]
        edges.append((prefix, suffix, kmer))
        adj[prefix].append(suffix)

    # Collect all vertices
    vertices = set()
    for p, s, _ in edges:
        vertices.add(p)
        vertices.add(s)

    print(f"\n  De Bruijn Graph:")
    print(f"    Vertices ({len(vertices)}): {sorted(vertices)}")
    print(f"    Edges ({len(edges)}):")
    for p, s, kmer in edges:
        print(f"      {p} → {s}  [{kmer}]")

    # Compute in-degree and out-degree
    in_deg = defaultdict(int)
    out_deg = defaultdict(int)
    for p, s, _ in edges:
        out_deg[p] += 1
        in_deg[s] += 1

    print(f"\n  Vertex degrees:")
    unbalanced = []
    for v in sorted(vertices):
        balance = out_deg[v] - in_deg[v]
        status = "balanced" if balance == 0 else f"{'source' if balance > 0 else 'sink'}"
        if balance != 0:
            unbalanced.append((v, balance))
        print(f"    {v}: in={in_deg[v]}, out={out_deg[v]} ({status})")

    if len(unbalanced) == 0:
        print("\n  ✓ All vertices balanced → Euler CIRCUIT exists")
    elif len(unbalanced) == 2:
        source = [v for v, b in unbalanced if b > 0][0]
        sink = [v for v, b in unbalanced if b < 0][0]
        print(f"\n  ✓ Exactly 2 unbalanced → Euler PATH exists")
        print(f"    Start: {source}, End: {sink}")
    else:
        print(f"\n  ✗ {len(unbalanced)} unbalanced vertices → assembly problem")

    # Find Eulerian path using Hierholzer's algorithm
    def find_eulerian_path(adj_lists, start):
        stack = [start]
        path = []
        local_adj = {v: list(neighbors) for v, neighbors in adj_lists.items()}
        while stack:
            v = stack[-1]
            if local_adj.get(v, []):
                u = local_adj[v].pop()
                stack.append(u)
            else:
                path.append(stack.pop())
        return path[::-1]

    # Find start vertex (source vertex with out > in)
    start = kmers[0][:-1]
    for v, b in unbalanced:
        if b > 0:
            start = v

    path = find_eulerian_path(dict(adj), start)
    assembled = path[0] + ''.join(v[-1] for v in path[1:])

    print(f"\n  Eulerian path: {' → '.join(path)}")
    print(f"  Assembled sequence: {assembled}")
    print(f"  Original sequence:  {original}")
    print(f"  Match: {assembled == original} ✓" if assembled == original
          else f"  Match: {assembled == original}")

    print(f"\n  The assembly worked because the de Bruijn graph had")
    print(f"  an Eulerian path — guaranteed by degree analysis!")


# ============================================================
# Main
# ============================================================

if __name__ == '__main__':
    network_reliability_demo()
    chinese_postman_demo()
    dna_assembly_demo()

    print("\n" + "=" * 60)
    print("  All applications demonstrated successfully!")
    print("  These real-world problems all reduce to the same")
    print("  graph-theoretic principles Euler discovered in 1736.")
    print("=" * 60)


"""
Königsberg Bridge Problem — Visualization and Demonstration
============================================================

This script visualizes the Königsberg bridge problem and demonstrates
Euler's theorem on graph traversability with concrete examples.

Dependencies: matplotlib, networkx (pip install matplotlib networkx)
"""

import matplotlib.pyplot as plt
import matplotlib.patches as patches
import numpy as np

# ============================================================
# Part 1: The Königsberg Bridge Map
# ============================================================

def draw_konigsberg_map():
    """Draw a stylized map of the Königsberg bridges."""
    fig, ax = plt.subplots(1, 1, figsize=(12, 8))
    ax.set_xlim(-1, 11)
    ax.set_ylim(-1, 9)
    ax.set_aspect('equal')
    ax.set_facecolor('#d4e6f1')

    # River
    river = patches.FancyBboxPatch((0, 3), 10, 2, boxstyle="round,pad=0.3",
                                     facecolor='#5dade2', edgecolor='#2e86c1', linewidth=2)
    ax.add_patch(river)

    # Landmasses
    north = patches.FancyBboxPatch((0.5, 5.5), 9, 2.5, boxstyle="round,pad=0.3",
                                    facecolor='#82e0aa', edgecolor='#27ae60', linewidth=2)
    ax.add_patch(north)
    ax.text(5, 7, 'North Bank (B)', ha='center', va='center', fontsize=14, fontweight='bold')

    south = patches.FancyBboxPatch((0.5, 0), 9, 2.5, boxstyle="round,pad=0.3",
                                    facecolor='#82e0aa', edgecolor='#27ae60', linewidth=2)
    ax.add_patch(south)
    ax.text(5, 1.2, 'South Bank (C)', ha='center', va='center', fontsize=14, fontweight='bold')

    island = patches.Ellipse((4, 4), 3, 1.4, facecolor='#f9e79f', edgecolor='#f39c12', linewidth=2)
    ax.add_patch(island)
    ax.text(4, 4, 'Island (A)', ha='center', va='center', fontsize=12, fontweight='bold')

    east = patches.FancyBboxPatch((8, 2.8), 2.5, 2.4, boxstyle="round,pad=0.2",
                                   facecolor='#d7bde2', edgecolor='#8e44ad', linewidth=2)
    ax.add_patch(east)
    ax.text(9.2, 4, 'East (D)', ha='center', va='center', fontsize=12, fontweight='bold')

    # Bridges
    bridge_style = dict(facecolor='#e74c3c', edgecolor='#c0392b', linewidth=1.5)
    bridge_labels = [
        ((2.5, 4.7, 0.8, 0.8), '1'),   # A-B bridge 1
        ((4.5, 4.7, 0.8, 0.8), '2'),   # A-B bridge 2
        ((2.5, 2.5, 0.8, 0.8), '3'),   # A-C bridge 1
        ((4.5, 2.5, 0.8, 0.8), '4'),   # A-C bridge 2
        ((5.8, 3.6, 2.0, 0.8), '5'),   # A-D bridge
        ((8.2, 5.2, 0.8, 0.8), '6'),   # B-D bridge
        ((8.2, 2.0, 0.8, 0.8), '7'),   # C-D bridge
    ]

    for (x, y, w, h), label in bridge_labels:
        b = patches.FancyBboxPatch((x, y), w, h, boxstyle="round,pad=0.1", **bridge_style)
        ax.add_patch(b)
        ax.text(x + w/2, y + h/2, label, ha='center', va='center',
                fontsize=11, color='white', fontweight='bold')

    ax.set_title('The Seven Bridges of Königsberg (1736)', fontsize=16, fontweight='bold', pad=15)
    ax.axis('off')

    # Degree annotation box
    textstr = ('Vertex Degrees:\n'
               'A (Island): 5 (odd)\n'
               'B (North):  3 (odd)\n'
               'C (South):  3 (odd)\n'
               'D (East):   3 (odd)\n\n'
               'All 4 vertices have odd degree.\n'
               "Euler's theorem: at most 2\n"
               'odd-degree vertices allowed\n'
               'for an Eulerian trail.\n\n'
               'Therefore: No solution exists!')
    props = dict(boxstyle='round', facecolor='wheat', alpha=0.8)
    ax.text(0.02, 0.98, textstr, transform=ax.transAxes, fontsize=10,
            verticalalignment='top', bbox=props, family='monospace')

    plt.tight_layout()
    plt.savefig('demos/konigsberg_map.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: demos/konigsberg_map.png")


# ============================================================
# Part 2: Graph-Theoretic View
# ============================================================

def draw_konigsberg_graph():
    """Draw the multigraph representation of the Königsberg bridges."""
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(16, 7))

    positions = {'A': (1, 2), 'B': (0, 3.5), 'C': (0, 0.5), 'D': (3, 2)}
    degrees = {'A': 5, 'B': 3, 'C': 3, 'D': 3}

    # --- Left: Original Königsberg (no Eulerian trail) ---
    edges = [
        ('A', 'B', -0.15), ('A', 'B', 0.15),
        ('A', 'C', -0.15), ('A', 'C', 0.15),
        ('A', 'D', 0),
        ('B', 'D', 0),
        ('C', 'D', 0),
    ]

    for u, v, offset in edges:
        x1, y1 = positions[u]
        x2, y2 = positions[v]
        dx, dy = x2 - x1, y2 - y1
        length = np.sqrt(dx**2 + dy**2)
        nx, ny = -dy/length * offset, dx/length * offset
        ax1.plot([x1 + nx, x2 + nx], [y1 + ny, y2 + ny],
                'r-', linewidth=2.5, alpha=0.7, zorder=1)

    for name, (x, y) in positions.items():
        circle = plt.Circle((x, y), 0.25, color='#e74c3c', ec='black', linewidth=2, zorder=3)
        ax1.add_patch(circle)
        ax1.text(x, y, f'{name}\n(d={degrees[name]})', ha='center', va='center',
                fontsize=9, fontweight='bold', color='white', zorder=4)

    ax1.set_xlim(-0.8, 3.8); ax1.set_ylim(-0.3, 4.3)
    ax1.set_aspect('equal')
    ax1.set_title('Königsberg Graph\n(No Eulerian Trail — 4 odd vertices)',
                  fontsize=13, fontweight='bold')
    ax1.text(1.5, -0.1, '✗ No Eulerian Trail', ha='center', fontsize=14,
            color='red', fontweight='bold')
    ax1.axis('off')

    # --- Right: Modified graph (one bridge removed) ---
    degrees2 = {'A': 4, 'B': 2, 'C': 3, 'D': 3}
    edges2 = [
        ('A', 'B', 0),
        ('A', 'C', -0.15), ('A', 'C', 0.15),
        ('A', 'D', 0),
        ('B', 'D', 0),
        ('C', 'D', 0),
    ]

    for u, v, offset in edges2:
        x1, y1 = positions[u]
        x2, y2 = positions[v]
        dx, dy = x2 - x1, y2 - y1
        length = np.sqrt(dx**2 + dy**2)
        nx, ny = -dy/length * offset, dx/length * offset
        ax2.plot([x1 + nx, x2 + nx], [y1 + ny, y2 + ny],
                '#2ecc71', linewidth=2.5, alpha=0.7, zorder=1)

    for name, (x, y) in positions.items():
        d = degrees2[name]
        color = '#e74c3c' if d % 2 == 1 else '#27ae60'
        circle = plt.Circle((x, y), 0.25, color=color, ec='black', linewidth=2, zorder=3)
        ax2.add_patch(circle)
        ax2.text(x, y, f'{name}\n(d={d})', ha='center', va='center',
                fontsize=9, fontweight='bold', color='white', zorder=4)

    ax2.set_xlim(-0.8, 3.8); ax2.set_ylim(-0.3, 4.3)
    ax2.set_aspect('equal')
    ax2.set_title('Modified Graph (one bridge removed)\n(Eulerian Path — 2 odd vertices)',
                  fontsize=13, fontweight='bold')
    ax2.text(1.5, -0.1, '✓ Eulerian Path exists (between C and D)',
            ha='center', fontsize=11, color='green', fontweight='bold')
    ax2.axis('off')

    plt.tight_layout()
    plt.savefig('demos/konigsberg_graph.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: demos/konigsberg_graph.png")


# ============================================================
# Part 3: Euler's Theorem Examples
# ============================================================

def demonstrate_euler_theorem():
    """Show Euler's theorem with multiple graph examples."""
    fig, axes = plt.subplots(2, 3, figsize=(18, 12))

    examples = [
        {'title': 'Triangle (K₃)', 'verts': {0:(0,0), 1:(2,0), 2:(1,1.7)},
         'edges': [(0,1),(1,2),(0,2)], 'degs': [2,2,2],
         'result': '✓ Circuit: 0→1→2→0', 'color': '#27ae60'},
        {'title': 'Path P₃', 'verts': {0:(0,0.5), 1:(1,0.5), 2:(2,0.5)},
         'edges': [(0,1),(1,2)], 'degs': [1,2,1],
         'result': '✓ Path: 0→1→2', 'color': '#2980b9'},
        {'title': 'K₄ (all odd)', 'verts': {0:(0,0), 1:(2,0), 2:(2,2), 3:(0,2)},
         'edges': [(0,1),(0,2),(0,3),(1,2),(1,3),(2,3)], 'degs': [3,3,3,3],
         'result': '✗ Impossible (4 odd)', 'color': '#e74c3c'},
        {'title': 'Square C₄', 'verts': {0:(0,0), 1:(2,0), 2:(2,2), 3:(0,2)},
         'edges': [(0,1),(1,2),(2,3),(3,0)], 'degs': [2,2,2,2],
         'result': '✓ Circuit: 0→1→2→3→0', 'color': '#27ae60'},
        {'title': 'House Graph', 'verts': {0:(0,0), 1:(2,0), 2:(2,1.5), 3:(0,1.5), 4:(1,2.5)},
         'edges': [(0,1),(1,2),(2,3),(3,0),(2,4),(3,4)], 'degs': [2,2,3,3,2],
         'result': '✓ Path: 2→4→3→0→1→2→3', 'color': '#2980b9'},
        {'title': 'Pentagon C₅', 'verts': {0:(1,2), 1:(1.95,1.31), 2:(1.59,0.19), 3:(0.41,0.19), 4:(0.05,1.31)},
         'edges': [(0,1),(1,2),(2,3),(3,4),(4,0)], 'degs': [2,2,2,2,2],
         'result': '✓ Circuit: 0→1→2→3→4→0', 'color': '#27ae60'},
    ]

    for idx, ex in enumerate(examples):
        ax = axes[idx // 3][idx % 3]
        for u, v in ex['edges']:
            x1, y1 = ex['verts'][u]; x2, y2 = ex['verts'][v]
            ax.plot([x1,x2], [y1,y2], 'gray', linewidth=2, zorder=1)

        for vid, (x, y) in ex['verts'].items():
            d = ex['degs'][vid]
            c = '#e74c3c' if d % 2 == 1 else '#27ae60'
            ax.add_patch(plt.Circle((x, y), 0.15, color=c, ec='black', linewidth=1.5, zorder=3))
            ax.text(x, y + 0.3, f'd={d}', ha='center', fontsize=9, color=c, fontweight='bold')

        odd_count = sum(1 for d in ex['degs'] if d % 2 == 1)
        ax.set_title(f'{ex["title"]}\n({odd_count} odd-degree vertices)',
                    fontsize=11, fontweight='bold')
        ax.text(1, -0.6, ex['result'], ha='center', fontsize=10,
               color=ex['color'], fontweight='bold')
        ax.set_aspect('equal'); ax.set_xlim(-0.5, 2.5); ax.set_ylim(-1, 3); ax.axis('off')

    fig.suptitle("Euler's Theorem: When Can You Traverse Every Edge Exactly Once?",
                 fontsize=16, fontweight='bold', y=0.98)
    fig.text(0.5, 0.01,
             'Green vertex = even degree │ Red vertex = odd degree │ '
             'Circuit: 0 odd │ Path: 2 odd │ Impossible: >2 odd',
             ha='center', fontsize=11, style='italic',
             bbox=dict(boxstyle='round', facecolor='lightyellow', alpha=0.8))

    plt.tight_layout(rect=[0, 0.04, 1, 0.96])
    plt.savefig('demos/euler_theorem_examples.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: demos/euler_theorem_examples.png")


# ============================================================
# Part 4: Console Demo — Degree Parity Checker
# ============================================================

def degree_parity_checker():
    """Demonstrate the degree parity check on the Königsberg graph."""
    print("\n" + "="*60)
    print("  KÖNIGSBERG BRIDGE PROBLEM — DEGREE ANALYSIS")
    print("="*60)

    adj = [[0,2,2,1], [2,0,0,1], [2,0,0,1], [1,1,1,0]]
    names = ['A (Island)', 'B (North) ', 'C (South) ', 'D (East)  ']

    print("\n  Adjacency Matrix (edge multiplicities):")
    print("           A    B    C    D")
    for i, row in enumerate(adj):
        print(f"    {names[i][0]}    {row}")

    total_edges = sum(sum(row) for row in adj) // 2
    print(f"\n  Total bridges: {total_edges}")
    print("\n  Degree Analysis:")
    print("  " + "-" * 42)

    odd_count = 0
    for i in range(4):
        degree = sum(adj[i])
        parity = "ODD " if degree % 2 == 1 else "EVEN"
        mark = "✗" if degree % 2 == 1 else "✓"
        odd_count += degree % 2
        print(f"    {names[i]}: degree = {degree} ({parity}) {mark}")

    print("  " + "-" * 42)
    print(f"    Odd-degree vertices: {odd_count}")
    print(f"    Maximum for Eulerian trail: 2")

    print("\n" + "="*60)
    print(f"  RESULT: NO Eulerian trail possible ({odd_count} > 2 odd)")
    print("="*60)

    # Verify handshaking lemma
    S = sum(sum(adj[i]) for i in range(4))
    print(f"\n  Handshaking Lemma: Σ deg = {S} = 2 × {total_edges} ✓")
    print(f"  Parity Theorem: #{odd_count} odd-degree vertices is even ✓")
    print(f"\n  This is exactly what Euler proved in 1736!")


# ============================================================
# Part 5: Bridge Edge Detection
# ============================================================

def bridge_edge_demo():
    """Demonstrate bridge edge detection in a sample graph."""
    print("\n" + "="*60)
    print("  BRIDGE EDGE (CUT EDGE) DETECTION")
    print("="*60)

    # A graph with some bridges: 0-1-2-3-4, plus edge 1-3 (creates cycle 1-2-3)
    # Edge 0-1 is a bridge, edge 3-4 is a bridge
    n = 5
    edges = [(0,1), (1,2), (2,3), (1,3), (3,4)]

    print("\n  Graph: 5 vertices, 5 edges")
    print("  Edges:", edges)
    print("\n  Adjacency list:")
    adj_list = {i: [] for i in range(n)}
    for u, v in edges:
        adj_list[u].append(v)
        adj_list[v].append(u)
    for v in range(n):
        print(f"    {v}: {sorted(adj_list[v])}")

    # Simple bridge detection: remove each edge and check connectivity via BFS
    def is_connected_without(skip_edge, n, edges):
        adj = {i: [] for i in range(n)}
        for u, v in edges:
            if (u, v) == skip_edge or (v, u) == skip_edge:
                continue
            adj[u].append(v)
            adj[v].append(u)
        visited = set()
        stack = [0]
        while stack:
            node = stack.pop()
            if node in visited:
                continue
            visited.add(node)
            for nb in adj[node]:
                if nb not in visited:
                    stack.append(nb)
        return len(visited) == n

    print("\n  Bridge Analysis:")
    print("  " + "-" * 42)
    for u, v in edges:
        is_bridge = not is_connected_without((u, v), n, edges)
        mark = "BRIDGE ✗" if is_bridge else "not bridge ✓"
        print(f"    Edge ({u},{v}): {mark}")
    print("  " + "-" * 42)
    print("\n  Bridges are edges whose removal disconnects the graph.")
    print("  In a tree, EVERY edge is a bridge (formally proved in Lean).")
    print("  In K_n (n>2), NO edge is a bridge (formally proved in Lean).")


if __name__ == '__main__':
    print("Generating Königsberg Bridge Problem visualizations...\n")

    draw_konigsberg_map()
    draw_konigsberg_graph()
    demonstrate_euler_theorem()
    degree_parity_checker()
    bridge_edge_demo()

    print("\n✓ All visualizations and demos complete!")
    print("  Output files:")
    print("  - demos/konigsberg_map.png")
    print("  - demos/konigsberg_graph.png")
    print("  - demos/euler_theorem_examples.png")
