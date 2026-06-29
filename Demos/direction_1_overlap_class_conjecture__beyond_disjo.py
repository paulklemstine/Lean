#!/usr/bin/env python3
"""
Applications of Overlap Class Theory
=====================================
Shows real-world applications of the overlap class theory:
1. Graph cycle analysis: identifying independent cycle groups
2. Network community detection via support overlap
3. Error-correcting code distance analysis
4. Gene regulatory network module detection
"""

from typing import List, Set, Dict, Tuple
from itertools import combinations
from collections import defaultdict, deque


# ============= Core algorithms (self-contained) =============

def compute_overlap_classes(supports: List[Set[int]]) -> List[Set[int]]:
    n = len(supports)
    if n == 0:
        return []
    adj: Dict[int, Set[int]] = defaultdict(set)
    for i in range(n):
        adj[i]
    for i, j in combinations(range(n), 2):
        if supports[i] & supports[j]:
            adj[i].add(j)
            adj[j].add(i)
    visited = set()
    classes = []
    for start in range(n):
        if start in visited:
            continue
        component: Set[int] = set()
        queue = deque([start])
        while queue:
            node = queue.popleft()
            if node in visited:
                continue
            visited.add(node)
            component.add(node)
            for neighbor in adj.get(node, set()):
                if neighbor not in visited:
                    queue.append(neighbor)
        classes.append(component)
    return classes


def overlap_complexity(supports: List[Set[int]]) -> int:
    return sum(len(supports[i] & supports[j])
               for i, j in combinations(range(len(supports)), 2))


def interaction_matrix(supports: List[Set[int]]) -> List[List[int]]:
    n = len(supports)
    M = [[0]*n for _ in range(n)]
    for i in range(n):
        for j in range(n):
            M[i][j] = len(supports[i]) if i == j else len(supports[i] & supports[j])
    return M


# ============= APPLICATION 1: Graph Cycle Analysis =============

def find_fundamental_cycles(n_vertices: int,
                           edges: List[Tuple[int, int]]) -> List[Set[int]]:
    """
    Find fundamental cycles using a spanning tree.
    Returns cycles as sets of edge indices.
    """
    # Build adjacency
    adj: Dict[int, List[Tuple[int, int]]] = defaultdict(list)
    for idx, (u, v) in enumerate(edges):
        adj[u].append((v, idx))
        adj[v].append((u, idx))

    # BFS spanning tree
    tree_edges: Set[int] = set()
    visited = {0}
    queue = deque([0])
    parent: Dict[int, Tuple[int, int]] = {}  # vertex -> (parent, edge_idx)

    while queue:
        node = queue.popleft()
        for neighbor, edge_idx in adj[node]:
            if neighbor not in visited:
                visited.add(neighbor)
                parent[neighbor] = (node, edge_idx)
                tree_edges.add(edge_idx)
                queue.append(neighbor)

    # Each non-tree edge creates a fundamental cycle
    cycles = []
    for idx, (u, v) in enumerate(edges):
        if idx in tree_edges:
            continue
        # Find path from u to v in tree
        path_u = []
        node = u
        while node in parent:
            path_u.append((node, parent[node][1]))
            node = parent[node][0]
        path_u.append((node, -1))

        path_v = []
        node = v
        while node in parent:
            path_v.append((node, parent[node][1]))
            node = parent[node][0]
        path_v.append((node, -1))

        # Find LCA
        ancestors_u = {p[0] for p in path_u}
        lca = None
        for p in path_v:
            if p[0] in ancestors_u:
                lca = p[0]
                break

        cycle_edges = {idx}  # the non-tree edge itself
        for node, eidx in path_u:
            if node == lca:
                break
            cycle_edges.add(eidx)
        for node, eidx in path_v:
            if node == lca:
                break
            cycle_edges.add(eidx)

        cycles.append(cycle_edges)

    return cycles


print("=" * 60)
print("APPLICATION 1: Graph Cycle Analysis")
print("=" * 60)

# K4 graph
k4_edges = [(0,1), (0,2), (0,3), (1,2), (1,3), (2,3)]
print(f"K4 edges: {k4_edges}")

cycles = find_fundamental_cycles(4, k4_edges)
print(f"Fundamental cycles (edge sets): {cycles}")
print(f"Number of fundamental cycles: {len(cycles)}")

classes = compute_overlap_classes(cycles)
print(f"Overlap classes: {classes}")
print(f"Number of overlap classes: {len(classes)}")
print(f"Overlap complexity: {overlap_complexity(cycles)}")
print("→ All cycles share edges in K4, so there's 1 overlap class")
print("→ This means the tropical kernel has 1 class of generators\n")

# Theta graph: two vertices connected by 3 disjoint paths
theta_edges = [(0,1), (0,2), (1,3), (2,3), (0,4), (4,3)]
print(f"Theta graph edges: {theta_edges}")
cycles_theta = find_fundamental_cycles(5, theta_edges)
print(f"Fundamental cycles: {cycles_theta}")
classes_theta = compute_overlap_classes(cycles_theta)
print(f"Overlap classes: {classes_theta}")
print(f"Class count: {len(classes_theta)}")
print(f"Complexity: {overlap_complexity(cycles_theta)}")
print()

# ============= APPLICATION 2: Network Community Detection =============

print("=" * 60)
print("APPLICATION 2: Network Module Detection")
print("=" * 60)

# Model: genes in a regulatory network, each with a set of target genes
gene_targets = {
    "p53":    {1, 2, 3, 4, 5},
    "MDM2":   {3, 4, 5, 6, 7},
    "BRCA1":  {8, 9, 10, 11},
    "BRCA2":  {10, 11, 12, 13},
    "MYC":    {20, 21, 22, 23},
    "RAS":    {22, 23, 24, 25},
}

genes = list(gene_targets.keys())
supports = [gene_targets[g] for g in genes]

classes = compute_overlap_classes(supports)
print("Gene target sets:")
for g, s in gene_targets.items():
    print(f"  {g}: targets {s}")

print(f"\nOverlap classes (by index):")
for i, cls in enumerate(classes):
    gene_names = [genes[j] for j in cls]
    print(f"  Module {i+1}: {gene_names}")

print(f"\nNumber of independent modules: {len(classes)}")
print("→ Genes in the same overlap class share regulatory targets")
print("→ Different classes represent independent regulatory pathways\n")

# ============= APPLICATION 3: Error-Correcting Codes =============

print("=" * 60)
print("APPLICATION 3: Error-Correcting Code Analysis")
print("=" * 60)

# Codewords as support sets (nonzero positions)
codewords = [
    {0, 1, 2, 3},     # weight 4
    {2, 3, 4, 5},     # weight 4, overlaps with above
    {6, 7, 8, 9},     # weight 4, disjoint from above
    {8, 9, 10, 11},   # weight 4, overlaps with above
]

print("Codeword supports (nonzero positions):")
for i, c in enumerate(codewords):
    print(f"  c_{i}: {sorted(c)} (weight {len(c)})")

M = interaction_matrix(codewords)
print("\nSupport interaction matrix:")
for row in M:
    print(f"  {row}")

classes = compute_overlap_classes(codewords)
print(f"\nOverlap classes: {classes}")
print(f"Number of classes: {len(classes)}")

# Compute pairwise distances
print("\nPairwise Hamming distances:")
for i, j in combinations(range(len(codewords)), 2):
    d = len(codewords[i] - codewords[j]) + len(codewords[j] - codewords[i])
    intersect = len(codewords[i] & codewords[j])
    print(f"  d(c_{i}, c_{j}) = {d} (intersection size = {intersect})")

print("\n→ Overlap classes identify codeword groups that interact")
print("→ Disjoint classes can be decoded independently\n")

# ============= Summary =============

print("=" * 60)
print("SUMMARY")
print("=" * 60)
print("""
The overlap class theory provides a unified framework for:

1. GRAPH THEORY: Identifying independent cycle groups in graphs.
   The overlap class count determines the number of independent
   sectors for tropical kernel generators.

2. BIOLOGY: Detecting independent regulatory modules in gene
   networks. Overlap classes correspond to pathway independence.

3. CODING THEORY: Analyzing codeword interaction structure.
   Independent overlap classes can be decoded separately,
   potentially improving decoder performance.

4. TROPICAL GEOMETRY: The overlap class count is a TPE-invariant
   that determines the uniqueness structure of tropical kernel
   generators — extending the disjoint-support theorem to all
   connected graphs.
""")


#!/usr/bin/env python3
"""
Overlap Class Conjecture — Demo
================================
Demonstrates the key mathematical concepts from the overlap class theory:
1. Computing overlap graphs from support families
2. Finding overlap equivalence classes
3. Computing overlap complexity
4. Verifying the peeling lemma numerically
5. Testing the fully-connected ⟹ one-class theorem
"""

from typing import List, Set, Dict, Tuple
from itertools import combinations
from collections import defaultdict


def support_overlap(A: Set[int], B: Set[int]) -> bool:
    """Check if two sets overlap (have nonempty intersection)."""
    return len(A & B) > 0


def overlap_graph(F: List[Set[int]]) -> Dict[int, Set[int]]:
    """
    Build the overlap graph: vertices are indices, edges connect
    overlapping supports.
    """
    n = len(F)
    adj = defaultdict(set)
    for i, j in combinations(range(n), 2):
        if support_overlap(F[i], F[j]):
            adj[i].add(j)
            adj[j].add(i)
    return adj


def overlap_classes(F: List[Set[int]]) -> List[Set[int]]:
    """
    Find connected components of the overlap graph.
    These are the overlap equivalence classes.
    """
    n = len(F)
    adj = overlap_graph(F)
    visited = set()
    classes = []

    for start in range(n):
        if start in visited:
            continue
        # BFS
        component = set()
        queue = [start]
        while queue:
            node = queue.pop(0)
            if node in visited:
                continue
            visited.add(node)
            component.add(node)
            for neighbor in adj[node]:
                if neighbor not in visited:
                    queue.append(neighbor)
        classes.append(component)
    return classes


def overlap_complexity(F: List[Set[int]]) -> int:
    """Compute the overlap complexity: sum of all pairwise intersection sizes."""
    total = 0
    n = len(F)
    for i, j in combinations(range(n), 2):
        total += len(F[i] & F[j])
    return total


def support_interaction_matrix(F: List[Set[int]]) -> List[List[int]]:
    """Build the support interaction matrix."""
    n = len(F)
    M = [[0] * n for _ in range(n)]
    for i in range(n):
        for j in range(n):
            if i == j:
                M[i][j] = len(F[i])
            else:
                M[i][j] = len(F[i] & F[j])
    return M


def peel_element(F: List[Set[int]], i: int, x: int) -> List[Set[int]]:
    """Remove element x from support F[i], keeping other supports unchanged."""
    result = [s.copy() for s in F]
    result[i] = result[i] - {x}
    return result


def support_distance(F: List[Set[int]], i: int, j: int) -> int:
    """Hamming distance between supports i and j."""
    return len(F[i] - F[j]) + len(F[j] - F[i])


# ============================================================
# DEMO 1: Disjoint supports → maximal class count
# ============================================================
print("=" * 60)
print("DEMO 1: Disjoint supports → class count = n")
print("=" * 60)

F_disjoint = [
    {1, 2, 3},
    {4, 5, 6},
    {7, 8, 9},
    {10, 11}
]

classes = overlap_classes(F_disjoint)
print(f"Supports: {F_disjoint}")
print(f"Number of supports: {len(F_disjoint)}")
print(f"Overlap classes: {classes}")
print(f"Number of classes: {len(classes)}")
print(f"Overlap complexity: {overlap_complexity(F_disjoint)}")
assert len(classes) == len(F_disjoint), "THEOREM: class count = n for disjoint!"
print("✓ Verified: class count = n for pairwise disjoint nonempty supports\n")

# ============================================================
# DEMO 2: Fully connected → one class
# ============================================================
print("=" * 60)
print("DEMO 2: Fully connected → one overlap class")
print("=" * 60)

F_connected = [
    {1, 2, 3, 4},
    {3, 4, 5, 6},
    {5, 6, 7, 1},
]

classes = overlap_classes(F_connected)
print(f"Supports: {F_connected}")
print(f"Overlap classes: {classes}")
print(f"Number of classes: {len(classes)}")
print(f"Overlap complexity: {overlap_complexity(F_connected)}")
assert len(classes) == 1, "THEOREM: one class when fully connected!"
print("✓ Verified: 1 class when every pair overlaps\n")

# ============================================================
# DEMO 3: Peeling reduces complexity
# ============================================================
print("=" * 60)
print("DEMO 3: Peeling Lemma — removing shared elements")
print("=" * 60)

F_overlap = [
    {1, 2, 3, 4},
    {3, 4, 5, 6},
    {5, 6, 7, 8},
]

print(f"Original supports: {F_overlap}")
c_before = overlap_complexity(F_overlap)
print(f"Overlap complexity before: {c_before}")

# Element 3 is shared between supports 0 and 1
F_peeled = peel_element(F_overlap, 0, 3)
c_after = overlap_complexity(F_peeled)
print(f"After peeling 3 from F[0]: {F_peeled}")
print(f"Overlap complexity after:  {c_after}")
assert c_after < c_before, "THEOREM: peeling reduces complexity!"
print(f"✓ Verified: {c_after} < {c_before} (strictly reduced)\n")

# ============================================================
# DEMO 4: Support interaction matrix
# ============================================================
print("=" * 60)
print("DEMO 4: Support Interaction Matrix")
print("=" * 60)

F_matrix = [
    {1, 2, 3},
    {2, 3, 4},
    {4, 5, 6},
]

M = support_interaction_matrix(F_matrix)
print(f"Supports: {F_matrix}")
print("Interaction Matrix:")
for row in M:
    print(f"  {row}")

# Verify symmetry
for i in range(len(F_matrix)):
    for j in range(len(F_matrix)):
        assert M[i][j] == M[j][i], f"Matrix not symmetric at ({i},{j})!"
print("✓ Verified: interaction matrix is symmetric\n")

# ============================================================
# DEMO 5: Chain of overlaps
# ============================================================
print("=" * 60)
print("DEMO 5: Chain topology — A∩B≠∅, B∩C≠∅, but A∩C=∅")
print("=" * 60)

F_chain = [
    {1, 2, 3},     # A
    {3, 4, 5},     # B: overlaps A
    {5, 6, 7},     # C: overlaps B but not A
    {10, 11, 12},  # D: isolated
]

classes = overlap_classes(F_chain)
print(f"Supports: {F_chain}")
print(f"A∩B = {F_chain[0] & F_chain[1]} (nonempty: overlap)")
print(f"B∩C = {F_chain[1] & F_chain[2]} (nonempty: overlap)")
print(f"A∩C = {F_chain[0] & F_chain[2]} (empty: no direct overlap)")
print(f"Overlap classes: {classes}")
print(f"Class count: {len(classes)}")
print("✓ A, B, C are in same class via transitive closure")
print("✓ D is isolated → separate class")
assert len(classes) == 2
print(f"✓ Verified: 2 classes (chain {{{0,1,2}}} and singleton {{{3}}})\n")

# ============================================================
# DEMO 6: Hamming distance (coding theory bridge)
# ============================================================
print("=" * 60)
print("DEMO 6: Support Distance (Coding Theory Bridge)")
print("=" * 60)

F_code = [
    {1, 2, 3, 4, 5},
    {4, 5, 6, 7},
    {8, 9, 10},
]

for i, j in combinations(range(len(F_code)), 2):
    d = support_distance(F_code, i, j)
    intersection = len(F_code[i] & F_code[j])
    sum_sizes = len(F_code[i]) + len(F_code[j])
    print(f"d(F[{i}], F[{j}]) = {d}, |F[{i}]|+|F[{j}]| = {sum_sizes}, "
          f"|F[{i}]∩F[{j}]| = {intersection}")
    if intersection == 0:
        assert d == sum_sizes, "THEOREM: distance = sum for disjoint!"
        print(f"  ✓ Disjoint: distance = sum of sizes")

print("\n" + "=" * 60)
print("All demos completed successfully!")
print("=" * 60)


#!/usr/bin/env python3
"""
Visualization 3: Support Interaction Matrix Heatmap
====================================================
Visualizes the support interaction matrix as a heatmap,
showing how the matrix structure reflects overlap classes.
Compares a fully connected family vs a block-diagonal one.
"""

import matplotlib.pyplot as plt
import numpy as np
from itertools import combinations
from collections import defaultdict, deque
from typing import List, Set, Dict


def compute_overlap_classes(supports: List[Set[int]]) -> List[Set[int]]:
    n = len(supports)
    if n == 0:
        return []
    adj: Dict[int, Set[int]] = defaultdict(set)
    for i in range(n):
        adj[i]
    for i, j in combinations(range(n), 2):
        if supports[i] & supports[j]:
            adj[i].add(j)
            adj[j].add(i)
    visited = set()
    classes = []
    for start in range(n):
        if start in visited:
            continue
        component: Set[int] = set()
        queue = deque([start])
        while queue:
            node = queue.popleft()
            if node in visited:
                continue
            visited.add(node)
            component.add(node)
            for neighbor in adj.get(node, set()):
                if neighbor not in visited:
                    queue.append(neighbor)
        classes.append(component)
    return classes


def interaction_matrix(supports: List[Set[int]]) -> np.ndarray:
    n = len(supports)
    M = np.zeros((n, n), dtype=int)
    for i in range(n):
        for j in range(n):
            M[i][j] = len(supports[i]) if i == j else len(supports[i] & supports[j])
    return M


# Create figure
fig, axes = plt.subplots(1, 3, figsize=(18, 5.5))

examples = [
    ("Block-Diagonal\n(3 overlap classes)",
     [{1, 2, 3, 4}, {3, 4, 5},
      {10, 11, 12}, {11, 12, 13},
      {20, 21}, {21, 22, 23}]),
    ("Single Block\n(1 overlap class)",
     [{1, 2, 3, 4}, {3, 4, 5, 6}, {5, 6, 7, 1},
      {2, 7, 8}, {8, 9, 1}, {6, 9, 10}]),
    ("Fully Disjoint\n(6 overlap classes)",
     [{1, 2}, {3, 4}, {5, 6}, {7, 8}, {9, 10}, {11, 12}]),
]

for ax_idx, (title, supports) in enumerate(examples):
    ax = axes[ax_idx]
    M = interaction_matrix(supports)
    classes = compute_overlap_classes(supports)

    # Reorder by overlap class for visual clarity
    order = []
    for cls in classes:
        order.extend(sorted(cls))
    M_reordered = M[np.ix_(order, order)]

    # Plot heatmap
    im = ax.imshow(M_reordered, cmap='YlOrRd', interpolation='nearest',
                   aspect='equal')

    # Add text annotations
    n = len(supports)
    for i in range(n):
        for j in range(n):
            val = M_reordered[i, j]
            text_color = 'white' if val > M.max() * 0.6 else 'black'
            ax.text(j, i, str(val), ha='center', va='center',
                   fontsize=10, fontweight='bold', color=text_color)

    # Draw class boundaries
    pos = 0
    for cls in classes:
        size = len(cls)
        if pos > 0:
            ax.axhline(y=pos - 0.5, color='blue', linewidth=2, alpha=0.7)
            ax.axvline(x=pos - 0.5, color='blue', linewidth=2, alpha=0.7)
        pos += size

    ax.set_xticks(range(n))
    ax.set_yticks(range(n))
    ax.set_xticklabels([f'F{order[i]}' for i in range(n)], fontsize=8)
    ax.set_yticklabels([f'F{order[i]}' for i in range(n)], fontsize=8)
    ax.set_title(f'{title}\n{len(classes)} class{"es" if len(classes) > 1 else ""}',
                fontsize=12, fontweight='bold')

    # Add colorbar
    cbar = fig.colorbar(im, ax=ax, fraction=0.046, pad=0.04)
    cbar.set_label('Intersection Size', fontsize=9)

fig.suptitle('Support Interaction Matrix — Block Structure Reflects Overlap Classes',
            fontsize=15, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('viz_interaction_matrix.png', dpi=150, bbox_inches='tight')
print("Saved viz_interaction_matrix.png")


#!/usr/bin/env python3
"""
Visualization 1: Overlap Graph and Classes
===========================================
Visualizes the overlap graph of a support family, coloring
vertices by their overlap class. Shows how supports that share
elements form connected components in the overlap graph.
"""

import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np
from itertools import combinations
from collections import defaultdict, deque
from typing import List, Set, Dict


def compute_overlap_classes(supports: List[Set[int]]) -> List[Set[int]]:
    n = len(supports)
    if n == 0:
        return []
    adj: Dict[int, Set[int]] = defaultdict(set)
    for i in range(n):
        adj[i]
    for i, j in combinations(range(n), 2):
        if supports[i] & supports[j]:
            adj[i].add(j)
            adj[j].add(i)
    visited = set()
    classes = []
    for start in range(n):
        if start in visited:
            continue
        component: Set[int] = set()
        queue = deque([start])
        while queue:
            node = queue.popleft()
            if node in visited:
                continue
            visited.add(node)
            component.add(node)
            for neighbor in adj.get(node, set()):
                if neighbor not in visited:
                    queue.append(neighbor)
        classes.append(component)
    return classes


def overlap_graph_edges(supports: List[Set[int]]) -> List[tuple]:
    edges = []
    for i, j in combinations(range(len(supports)), 2):
        if supports[i] & supports[j]:
            edges.append((i, j, len(supports[i] & supports[j])))
    return edges


# Create figure with 3 subplots
fig, axes = plt.subplots(1, 3, figsize=(18, 6))

# Color palette
colors = ['#E74C3C', '#3498DB', '#2ECC71', '#F39C12', '#9B59B6', '#1ABC9C']

examples = [
    ("Fully Disjoint (3 classes)",
     [{1, 2, 3}, {4, 5, 6}, {7, 8, 9}]),
    ("Chain Overlap (2 classes)",
     [{1, 2, 3}, {3, 4, 5}, {5, 6, 7}, {10, 11}]),
    ("Fully Connected (1 class)",
     [{1, 2, 3, 4}, {3, 4, 5, 6}, {5, 6, 7, 1}]),
]

for ax_idx, (title, supports) in enumerate(examples):
    ax = axes[ax_idx]
    n = len(supports)
    classes = compute_overlap_classes(supports)
    edges = overlap_graph_edges(supports)

    # Layout: circle
    angles = np.linspace(0, 2 * np.pi, n, endpoint=False)
    angles = angles - np.pi / 2  # start from top
    radius = 1.5
    positions = [(radius * np.cos(a), radius * np.sin(a)) for a in angles]

    # Assign colors by class
    vertex_colors = ['gray'] * n
    for cls_idx, cls in enumerate(classes):
        for v in cls:
            vertex_colors[v] = colors[cls_idx % len(colors)]

    # Draw edges
    for i, j, weight in edges:
        x1, y1 = positions[i]
        x2, y2 = positions[j]
        lw = 1 + weight * 0.8
        ax.plot([x1, x2], [y1, y2], 'k-', linewidth=lw, alpha=0.4, zorder=1)
        # Label with intersection size
        mx, my = (x1 + x2) / 2, (y1 + y2) / 2
        ax.text(mx, my, str(weight), fontsize=8, ha='center', va='center',
                bbox=dict(boxstyle='round,pad=0.2', facecolor='white', alpha=0.8),
                zorder=3)

    # Draw vertices
    for i in range(n):
        x, y = positions[i]
        circle = plt.Circle((x, y), 0.35, color=vertex_colors[i],
                           ec='black', linewidth=2, zorder=2)
        ax.add_patch(circle)
        ax.text(x, y, f'F{i}', fontsize=11, ha='center', va='center',
                fontweight='bold', color='white', zorder=4)
        # Show support below
        support_str = str(sorted(supports[i]))
        ax.text(x, y - 0.55, support_str, fontsize=7, ha='center', va='top',
                color='gray')

    ax.set_xlim(-2.5, 2.5)
    ax.set_ylim(-2.5, 2.5)
    ax.set_aspect('equal')
    ax.set_title(title, fontsize=13, fontweight='bold')
    ax.axis('off')

    # Legend
    legend_patches = []
    for cls_idx, cls in enumerate(classes):
        patch = mpatches.Patch(color=colors[cls_idx % len(colors)],
                              label=f'Class {cls_idx + 1}: {sorted(cls)}')
        legend_patches.append(patch)
    ax.legend(handles=legend_patches, loc='lower center', fontsize=8,
             framealpha=0.9, ncol=1)

fig.suptitle('Overlap Graphs and Equivalence Classes',
            fontsize=16, fontweight='bold', y=0.98)
plt.tight_layout(rect=[0, 0, 1, 0.95])
plt.savefig('viz_overlap_graph.png', dpi=150, bbox_inches='tight')
print("Saved viz_overlap_graph.png")


#!/usr/bin/env python3
"""
Visualization 2: Peeling Lemma — Complexity Descent
====================================================
Visualizes how the peeling operation (removing shared elements)
strictly reduces overlap complexity at each step, demonstrating
the well-founded descent that drives the inductive argument.
"""

import matplotlib.pyplot as plt
import numpy as np
from itertools import combinations
from typing import List, Set


def overlap_complexity(supports: List[Set[int]]) -> int:
    return sum(len(supports[i] & supports[j])
               for i, j in combinations(range(len(supports)), 2))


def peel_step(supports: List[Set[int]]) -> tuple:
    """Find and remove one shared element. Returns (new_supports, element, index) or None."""
    for i, j in combinations(range(len(supports)), 2):
        shared = supports[i] & supports[j]
        if shared:
            elem = min(shared)
            new_supports = [s.copy() for s in supports]
            new_supports[i].discard(elem)
            return new_supports, elem, i
    return None


def full_peeling(supports: List[Set[int]]) -> List[tuple]:
    """Peel until disjoint, recording each step."""
    history = [(supports, overlap_complexity(supports), None, None)]
    current = [s.copy() for s in supports]
    while True:
        result = peel_step(current)
        if result is None:
            break
        current, elem, idx = result
        c = overlap_complexity(current)
        history.append(([s.copy() for s in current], c, elem, idx))
    return history


# Two examples
examples = [
    ("Dense Overlap",
     [{1, 2, 3, 4, 5}, {3, 4, 5, 6, 7}, {5, 6, 7, 8, 9}]),
    ("Light Overlap",
     [{1, 2, 3}, {3, 4, 5}, {6, 7, 8}, {8, 9, 10}]),
]

fig, axes = plt.subplots(1, 2, figsize=(14, 6))

for ax_idx, (title, initial_supports) in enumerate(examples):
    ax = axes[ax_idx]
    history = full_peeling(initial_supports)

    steps = list(range(len(history)))
    complexities = [h[1] for h in history]

    # Main plot: complexity descent
    ax.plot(steps, complexities, 'o-', color='#E74C3C', linewidth=2.5,
            markersize=10, markerfacecolor='white', markeredgewidth=2.5,
            zorder=3)

    # Fill area under curve
    ax.fill_between(steps, complexities, alpha=0.15, color='#E74C3C')

    # Annotate each step
    for i, (supp, c, elem, idx) in enumerate(history):
        if i == 0:
            label = "Initial"
        else:
            label = f"Peel {elem} from F{idx}"
        ax.annotate(label, (i, c), textcoords="offset points",
                   xytext=(0, 15), ha='center', fontsize=7,
                   color='#2C3E50', fontweight='bold')

    # Mark the zero line
    ax.axhline(y=0, color='#2ECC71', linewidth=2, linestyle='--',
               label='Disjoint (complexity = 0)')

    ax.set_xlabel('Peeling Step', fontsize=12)
    ax.set_ylabel('Overlap Complexity', fontsize=12)
    ax.set_title(f'{title}\n{len(initial_supports)} supports',
                fontsize=13, fontweight='bold')
    ax.set_xticks(steps)
    ax.set_ylim(-0.5, max(complexities) * 1.3)
    ax.grid(True, alpha=0.3)
    ax.legend(fontsize=9)

    # Show initial and final states
    text_y = max(complexities) * 1.15
    initial_str = ', '.join(str(sorted(s)) for s in initial_supports)
    ax.text(0, text_y, f'Start: {initial_str}', fontsize=7,
            color='#7F8C8D', va='top')

fig.suptitle('Peeling Lemma: Strict Complexity Descent',
            fontsize=16, fontweight='bold', y=0.98)
plt.tight_layout(rect=[0, 0, 1, 0.93])
plt.savefig('viz_peeling.png', dpi=150, bbox_inches='tight')
print("Saved viz_peeling.png")
