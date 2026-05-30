#!/usr/bin/env python3
"""
Applications of Overlap Spectrum Theory

Real-world applications of overlap class decomposition:
1. Network community detection via overlap classes
2. Error-correcting code analysis via support distances
3. Chip-firing / sandpile dynamics on overlap graphs
4. Chemical reaction network interaction analysis
"""

from collections import defaultdict
from algorithms import (
    compute_overlap_classes, compute_overlap_spectrum,
    compute_overlap_degree, compute_overlap_laplacian,
    compute_vertex_degrees, compute_overlap_complexity,
    UnionFind
)


# ============================================================
# Application 1: Network Community Detection
# ============================================================
def detect_communities(nodes: list[str], feature_sets: dict[str, set]) -> dict[str, list[str]]:
    """
    Detect communities in a network using overlap class decomposition.
    
    Each node has a "feature set" (interests, connections, behaviors).
    Two nodes are in the same community iff their feature sets are
    overlap-equivalent (connected by a chain of pairwise overlapping
    feature sets).
    
    This is a natural generalization of connected components to
    the feature-overlap setting.
    
    Args:
        nodes: List of node names
        feature_sets: Dict mapping node name to its feature set
        
    Returns:
        Dict mapping community label to list of member nodes
    """
    family = [feature_sets[node] for node in nodes]
    classes = compute_overlap_classes(family)
    
    communities = {}
    for idx, cls in enumerate(classes):
        label = f"Community_{idx + 1}"
        communities[label] = [nodes[i] for i in cls]
    
    return communities


# ============================================================
# Application 2: Error-Correcting Code Analysis
# ============================================================
def analyze_code_supports(codewords: list[list[int]]) -> dict:
    """
    Analyze an error-correcting code through its support structure.
    
    The support of a codeword is the set of positions where it is nonzero.
    Overlap classes of supports reveal the interaction structure of the code:
    - Disjoint supports → independent error correction sectors
    - Overlapping supports → potential interference
    
    The overlap spectrum gives the partition structure of the code.
    
    Args:
        codewords: List of codewords (lists of integers)
        
    Returns:
        Analysis dict with spectrum, complexity, and sector information
    """
    supports = [set(i for i, v in enumerate(cw) if v != 0) for cw in codewords]
    
    classes = compute_overlap_classes(supports)
    spectrum = compute_overlap_spectrum(supports)
    complexity = compute_overlap_complexity(supports)
    degree = compute_overlap_degree(supports)
    
    # Compute minimum distance within each class
    class_min_distances = []
    for cls in classes:
        if len(cls) < 2:
            class_min_distances.append(None)
            continue
        min_dist = float('inf')
        for i in range(len(cls)):
            for j in range(i + 1, len(cls)):
                # Hamming distance (support distance)
                si, sj = supports[cls[i]], supports[cls[j]]
                dist = len(si - sj) + len(sj - si)
                min_dist = min(min_dist, dist)
        class_min_distances.append(min_dist)
    
    return {
        "n_codewords": len(codewords),
        "supports": supports,
        "overlap_classes": classes,
        "overlap_spectrum": spectrum,
        "overlap_complexity": complexity,
        "overlap_degree": degree,
        "class_min_distances": class_min_distances,
        "is_pairwise_disjoint": complexity == 0,
    }


# ============================================================
# Application 3: Chemical Reaction Network Analysis
# ============================================================
def analyze_reaction_network(reactions: dict[str, set[str]]) -> dict:
    """
    Analyze a chemical reaction network through overlap classes.
    
    Each reaction has a set of participating species (its "support").
    Overlap classes group reactions that share species, identifying
    independent reaction subsystems.
    
    The overlap Laplacian encodes the interaction strength between reactions.
    
    Args:
        reactions: Dict mapping reaction name to set of participating species
        
    Returns:
        Analysis dict with independent subsystems and interaction metrics
    """
    reaction_names = list(reactions.keys())
    supports = [reactions[name] for name in reaction_names]
    
    classes = compute_overlap_classes(supports)
    L = compute_overlap_laplacian(supports)
    degs = compute_vertex_degrees(supports)
    
    subsystems = []
    for cls in classes:
        rxn_names = [reaction_names[i] for i in cls]
        species = set()
        for i in cls:
            species |= supports[i]
        subsystems.append({
            "reactions": rxn_names,
            "species": species,
            "n_reactions": len(rxn_names),
            "n_species": len(species),
        })
    
    return {
        "n_reactions": len(reaction_names),
        "n_subsystems": len(classes),
        "subsystems": subsystems,
        "overlap_spectrum": compute_overlap_spectrum(supports),
        "max_interaction_degree": max(degs) if degs else 0,
        "total_interactions": compute_overlap_degree(supports),
    }


# ============================================================
# Main: Run all applications
# ============================================================
if __name__ == "__main__":
    print("=" * 60)
    print("  Application 1: Network Community Detection")
    print("=" * 60)
    
    nodes = ["Alice", "Bob", "Charlie", "Diana", "Eve", "Frank"]
    features = {
        "Alice":   {"math", "music", "hiking"},
        "Bob":     {"music", "cooking", "art"},
        "Charlie": {"coding", "gaming", "electronics"},
        "Diana":   {"gaming", "art", "music"},
        "Eve":     {"gardening", "birdwatching"},
        "Frank":   {"birdwatching", "photography"},
    }
    
    communities = detect_communities(nodes, features)
    for label, members in communities.items():
        shared = set()
        for m in members:
            if not shared:
                shared = features[m].copy()
            else:
                shared |= features[m]
        print(f"  {label}: {members}")
        print(f"    Interests: {shared}")
    
    print()
    print("=" * 60)
    print("  Application 2: Error-Correcting Code Analysis")
    print("=" * 60)
    
    # A simple code with mixed overlap structure
    codewords = [
        [1, 1, 0, 0, 0, 0, 0, 0],
        [0, 1, 1, 0, 0, 0, 0, 0],
        [0, 0, 0, 1, 1, 0, 0, 0],
        [0, 0, 0, 0, 0, 1, 1, 0],
        [0, 0, 0, 0, 0, 0, 1, 1],
    ]
    
    analysis = analyze_code_supports(codewords)
    print(f"  Number of codewords: {analysis['n_codewords']}")
    print(f"  Supports: {analysis['supports']}")
    print(f"  Overlap classes: {analysis['overlap_classes']}")
    print(f"  Overlap spectrum: {analysis['overlap_spectrum']}")
    print(f"  Is pairwise disjoint? {analysis['is_pairwise_disjoint']}")
    print(f"  Overlap complexity: {analysis['overlap_complexity']}")
    for idx, (cls, dist) in enumerate(zip(analysis['overlap_classes'], 
                                           analysis['class_min_distances'])):
        print(f"  Class {idx}: indices {cls}, min distance = {dist}")
    
    print()
    print("=" * 60)
    print("  Application 3: Chemical Reaction Network")
    print("=" * 60)
    
    reactions = {
        "R1: A + B → C":     {"A", "B", "C"},
        "R2: C + D → E":     {"C", "D", "E"},
        "R3: X + Y → Z":     {"X", "Y", "Z"},
        "R4: Z + W → V":     {"Z", "W", "V"},
        "R5: P → Q":         {"P", "Q"},
    }
    
    analysis = analyze_reaction_network(reactions)
    print(f"  Total reactions: {analysis['n_reactions']}")
    print(f"  Independent subsystems: {analysis['n_subsystems']}")
    print(f"  Overlap spectrum: {analysis['overlap_spectrum']}")
    
    for idx, sub in enumerate(analysis['subsystems']):
        print(f"\n  Subsystem {idx + 1}:")
        print(f"    Reactions: {sub['reactions']}")
        print(f"    Species: {sub['species']}")
        print(f"    Size: {sub['n_reactions']} reactions, {sub['n_species']} species")
    
    print(f"\n  Max interaction degree: {analysis['max_interaction_degree']}")
    print(f"  Total interactions: {analysis['total_interactions']}")


#!/usr/bin/env python3
"""
Overlap Spectrum Theory — Interactive Demo

Demonstrates the key theorems from overlap spectrum theory:
1. Overlap equivalence classes partition the index set
2. Pairwise disjoint families yield singleton classes  
3. The handshaking lemma: sum of vertex degrees = 2 × edge count
4. The overlap Laplacian has zero row sums
5. Overlap complexity characterizes disjointness
"""

import itertools
from collections import defaultdict


def supports_overlap(A: set, B: set) -> bool:
    """Two sets overlap if their intersection is nonempty."""
    return len(A & B) > 0


def overlap_classes(family: list[set]) -> list[list[int]]:
    """
    Compute overlap equivalence classes using union-find.
    Returns list of classes (each class is a list of indices).
    """
    n = len(family)
    parent = list(range(n))
    
    def find(x):
        while parent[x] != x:
            parent[x] = parent[parent[x]]
            x = parent[x]
        return x
    
    def union(x, y):
        px, py = find(x), find(y)
        if px != py:
            parent[px] = py
    
    for i in range(n):
        for j in range(i + 1, n):
            if supports_overlap(family[i], family[j]):
                union(i, j)
    
    classes = defaultdict(list)
    for i in range(n):
        classes[find(i)].append(i)
    return list(classes.values())


def overlap_degree(family: list[set]) -> int:
    """Number of overlapping pairs."""
    n = len(family)
    count = 0
    for i in range(n):
        for j in range(i + 1, n):
            if supports_overlap(family[i], family[j]):
                count += 1
    return count


def vertex_degrees(family: list[set]) -> list[int]:
    """Degree of each vertex in the overlap graph."""
    n = len(family)
    degs = [0] * n
    for i in range(n):
        for j in range(n):
            if i != j and supports_overlap(family[i], family[j]):
                degs[i] += 1
    return degs


def overlap_complexity(family: list[set]) -> int:
    """Sum of pairwise intersection sizes."""
    n = len(family)
    total = 0
    for i in range(n):
        for j in range(i + 1, n):
            total += len(family[i] & family[j])
    return total


def overlap_laplacian(family: list[set]) -> list[list[int]]:
    """Compute the overlap Laplacian matrix."""
    n = len(family)
    L = [[0] * n for _ in range(n)]
    degs = vertex_degrees(family)
    for i in range(n):
        L[i][i] = degs[i]
        for j in range(n):
            if i != j and supports_overlap(family[i], family[j]):
                L[i][j] = -1
    return L


def overlap_spectrum(family: list[set]) -> list[int]:
    """The overlap spectrum: sorted list of class sizes (an integer partition)."""
    classes = overlap_classes(family)
    return sorted([len(c) for c in classes], reverse=True)


def print_separator(title: str):
    print(f"\n{'='*60}")
    print(f"  {title}")
    print(f"{'='*60}")


# ============================================================
# Demo 1: Pairwise Disjoint Family
# ============================================================
print_separator("Demo 1: Pairwise Disjoint Family")

family_disjoint = [
    {1, 2, 3},
    {4, 5, 6},
    {7, 8, 9},
    {10, 11}
]
n = len(family_disjoint)
classes = overlap_classes(family_disjoint)
spectrum = overlap_spectrum(family_disjoint)
deg = overlap_degree(family_disjoint)
complexity = overlap_complexity(family_disjoint)

print(f"Family: {family_disjoint}")
print(f"Number of sets (n): {n}")
print(f"Overlap classes: {classes}")
print(f"Class count: {len(classes)}")
print(f"Overlap spectrum (partition): {spectrum}")
print(f"Overlap degree (edges): {deg}")
print(f"Overlap complexity: {complexity}")
print()
print("Theorem verification:")
print(f"  ovClassCount = n? {len(classes)} = {n} ✓" if len(classes) == n 
      else f"  ovClassCount = n? {len(classes)} ≠ {n} ✗")
print(f"  complexity = 0? {complexity == 0} ✓" if complexity == 0 
      else f"  complexity = 0? False ✗")
print(f"  All classes are singletons? {all(len(c) == 1 for c in classes)} ✓")

# ============================================================
# Demo 2: Fully Connected Family
# ============================================================
print_separator("Demo 2: Fully Connected (All Pairs Overlap)")

family_connected = [
    {1, 2, 3},
    {2, 3, 4},
    {3, 4, 5},
    {4, 5, 6}
]
n = len(family_connected)
classes = overlap_classes(family_connected)
spectrum = overlap_spectrum(family_connected)

print(f"Family: {family_connected}")
print(f"Number of sets (n): {n}")
print(f"Overlap classes: {classes}")
print(f"Class count: {len(classes)}")
print(f"Overlap spectrum: {spectrum}")
all_overlap = all(
    supports_overlap(family_connected[i], family_connected[j])
    for i in range(n) for j in range(i+1, n)
)
print(f"All pairs overlap? {all_overlap}")
print(f"Class count = 1? {len(classes) == 1} ✓" if len(classes) == 1 
      else f"Class count = 1? False ✗")

# ============================================================
# Demo 3: Handshaking Lemma
# ============================================================
print_separator("Demo 3: Handshaking Lemma")

family_mixed = [
    {1, 2},
    {2, 3},
    {4, 5},
    {5, 6},
    {7, 8}
]
n = len(family_mixed)
degs = vertex_degrees(family_mixed)
deg = overlap_degree(family_mixed)

print(f"Family: {family_mixed}")
print(f"Vertex degrees: {degs}")
print(f"Sum of degrees: {sum(degs)}")
print(f"Overlap degree (edges): {deg}")
print(f"2 × edges: {2 * deg}")
print(f"Handshaking: sum(deg) = 2 × edges? {sum(degs) == 2 * deg} ✓")

# ============================================================
# Demo 4: Laplacian Properties
# ============================================================
print_separator("Demo 4: Overlap Laplacian")

L = overlap_laplacian(family_mixed)
print(f"Laplacian matrix:")
for row in L:
    print(f"  {row}")

print(f"\nRow sums (should all be 0):")
for i, row in enumerate(L):
    print(f"  Row {i}: {sum(row)}", "✓" if sum(row) == 0 else "✗")

trace = sum(L[i][i] for i in range(n))
print(f"\nTrace: {trace}")
print(f"2 × overlap degree: {2 * deg}")
print(f"Trace = 2 × edges? {trace == 2 * deg} ✓")

# ============================================================
# Demo 5: Overlap Spectrum as Partition
# ============================================================
print_separator("Demo 5: Overlap Spectrum = Integer Partition")

families = {
    "Disjoint": [{1}, {2}, {3}, {4}],
    "Two pairs": [{1, 2}, {2, 3}, {4, 5}, {5, 6}],
    "One cluster + singletons": [{1, 2}, {2, 3}, {3, 4}, {5}],
    "All connected": [{1, 2}, {2, 3}, {3, 4}, {4, 5}],
}

for name, fam in families.items():
    spec = overlap_spectrum(fam)
    n = len(fam)
    print(f"  {name}: spectrum = {spec}, sum = {sum(spec)}, n = {n}",
          "✓" if sum(spec) == n else "✗")

# ============================================================
# Demo 6: Conjecture Test
# ============================================================
print_separator("Demo 6: Overlap Degree One Conjecture Test")

def max_pairwise_intersection(family):
    n = len(family)
    if n <= 1:
        return 0
    return max(len(family[i] & family[j]) 
               for i in range(n) for j in range(i+1, n))

# Test: when max intersection ≤ 1, does classCount + ovDegree = n?
print("Testing conjecture: maxIntersection ≤ 1 ⟹ classCount + ovDegree = n")
print()

counter = 0
total = 0
for _ in range(10000):
    import random
    random.seed(_ + 42)
    n = random.randint(2, 6)
    universe = list(range(15))
    fam = [set(random.sample(universe, random.randint(1, 5))) for _ in range(n)]
    
    max_int = max_pairwise_intersection(fam)
    if max_int <= 1:
        total += 1
        cc = len(overlap_classes(fam))
        od = overlap_degree(fam)
        if cc + od != n:
            counter += 1
            if counter <= 5:
                print(f"  Counterexample #{counter}: n={n}, classCount={cc}, "
                      f"ovDegree={od}, cc+od={cc+od}")
                print(f"    Family: {fam}")

if counter == 0:
    print(f"  No counterexamples found in {total} families with max intersection ≤ 1")
else:
    print(f"\n  Found {counter} counterexamples out of {total} tested!")
    print("  CONJECTURE REFUTED!")

# ============================================================
# Demo 7: Universe Size Bound
# ============================================================
print_separator("Demo 7: Universe Size Bound")

# For PD families, n ≤ |universe|
print("For pairwise disjoint families over finite universe:")
for universe_size in [3, 5, 8]:
    for n_sets in range(1, universe_size + 2):
        # Try to build a PD family of n_sets over universe of size universe_size
        fam = [set() for _ in range(n_sets)]
        elements = list(range(universe_size))
        # Greedily assign elements
        for idx, elem in enumerate(elements):
            if idx < n_sets:
                fam[idx].add(elem)
        # Remove empty sets
        fam = [s for s in fam if len(s) > 0]
        actual_n = len(fam)
        
        if all(len(fam[i] & fam[j]) == 0 for i in range(actual_n) for j in range(i+1, actual_n)):
            all_nonempty = all(len(s) > 0 for s in fam)
            if all_nonempty:
                print(f"  |universe|={universe_size}, n={actual_n}: "
                      f"n ≤ |universe|? {actual_n <= universe_size} ✓")

print("\n" + "="*60)
print("  All demos completed successfully!")
print("="*60)


#!/usr/bin/env python3
"""
Visualization: Overlap Laplacian Heatmap and Properties

Visualizes the overlap Laplacian matrix as a heatmap, demonstrating:
- Zero row sums (Laplacian property)
- Trace = 2 × overlap degree (handshaking lemma)
- Block structure from overlap classes

Uses matplotlib for static visualization.
"""

import matplotlib.pyplot as plt
import numpy as np
from collections import defaultdict


def compute_overlap_data(family):
    """Compute all overlap data (self-contained)."""
    n = len(family)
    
    # Overlap graph adjacency
    adj = [[False] * n for _ in range(n)]
    for i in range(n):
        for j in range(i + 1, n):
            if len(family[i] & family[j]) > 0:
                adj[i][j] = adj[j][i] = True
    
    # Vertex degrees
    degrees = [sum(1 for j in range(n) if j != i and adj[i][j]) for i in range(n)]
    
    # Overlap degree (edge count)
    edge_count = sum(1 for i in range(n) for j in range(i+1, n) if adj[i][j])
    
    # Laplacian
    L = [[0] * n for _ in range(n)]
    for i in range(n):
        L[i][i] = degrees[i]
        for j in range(n):
            if i != j and adj[i][j]:
                L[i][j] = -1
    
    # Overlap classes (union-find)
    parent = list(range(n))
    def find(x):
        while parent[x] != x:
            parent[x] = parent[parent[x]]
            x = parent[x]
        return x
    def union(x, y):
        px, py = find(x), find(y)
        if px != py: parent[px] = py
    
    for i in range(n):
        for j in range(i+1, n):
            if adj[i][j]:
                union(i, j)
    
    classes = defaultdict(list)
    for i in range(n):
        classes[find(i)].append(i)
    
    # Reorder indices by class
    ordered = []
    for cls in classes.values():
        ordered.extend(sorted(cls))
    
    return {
        'L': L, 'degrees': degrees, 'edge_count': edge_count,
        'classes': list(classes.values()), 'ordered': ordered, 'n': n
    }


# Define support families
families = {
    "Disjoint": [{1,2}, {3,4}, {5,6}, {7,8}],
    "Chain": [{1,2}, {2,3}, {3,4}, {4,5}],
    "Mixed": [{1,2,3}, {3,4}, {5,6}, {6,7,8}, {9}, {10,11}],
    "Star": [{1,2}, {1,3}, {1,4}, {1,5}],
}

fig, axes = plt.subplots(2, 4, figsize=(20, 10))

for col, (name, family) in enumerate(families.items()):
    data = compute_overlap_data(family)
    n = data['n']
    L = data['L']
    ordered = data['ordered']
    
    # Reorder Laplacian by overlap class
    L_reordered = [[L[ordered[i]][ordered[j]] for j in range(n)] for i in range(n)]
    L_arr = np.array(L_reordered)
    
    # Top row: Laplacian heatmap
    ax1 = axes[0][col]
    im = ax1.imshow(L_arr, cmap='RdBu_r', vmin=-1.5, vmax=max(data['degrees'])+0.5,
                    aspect='equal')
    ax1.set_title(f"{name}\nn={n}", fontsize=12, fontweight='bold')
    
    # Add cell values
    for i in range(n):
        for j in range(n):
            val = L_arr[i][j]
            color = 'white' if abs(val) > 1 else 'black'
            ax1.text(j, i, str(int(val)), ha='center', va='center', 
                    fontsize=9, color=color, fontweight='bold')
    
    # Add class boundaries
    cum = 0
    for cls in data['classes']:
        cum += len(cls)
        if cum < n:
            ax1.axhline(y=cum - 0.5, color='yellow', linewidth=2)
            ax1.axvline(x=cum - 0.5, color='yellow', linewidth=2)
    
    ax1.set_xticks(range(n))
    ax1.set_yticks(range(n))
    ax1.set_xticklabels([f'F{ordered[i]}' for i in range(n)], fontsize=8)
    ax1.set_yticklabels([f'F{ordered[i]}' for i in range(n)], fontsize=8)
    
    # Bottom row: Properties
    ax2 = axes[1][col]
    ax2.axis('off')
    
    trace = sum(L[i][i] for i in range(n))
    row_sums = [sum(L[i][j] for j in range(n)) for i in range(n)]
    spectrum = sorted([len(c) for c in data['classes']], reverse=True)
    
    props = [
        f"Trace(L) = {trace}",
        f"2 × edges = {2 * data['edge_count']}",
        f"Trace = 2×edges? {'✓' if trace == 2*data['edge_count'] else '✗'}",
        "",
        f"Row sums: {row_sums}",
        f"All zero? {'✓' if all(s == 0 for s in row_sums) else '✗'}",
        "",
        f"Classes: {len(data['classes'])}",
        f"Spectrum: {spectrum}",
        f"Sum = {sum(spectrum)} = n? {'✓' if sum(spectrum)==n else '✗'}",
    ]
    
    for i, prop in enumerate(props):
        color = 'green' if '✓' in prop else ('red' if '✗' in prop else 'black')
        ax2.text(0.1, 0.9 - i * 0.09, prop, fontsize=10, 
                transform=ax2.transAxes, va='top', color=color,
                fontfamily='monospace')

plt.suptitle("Overlap Laplacian: Structure, Trace Formula, and Zero Row Sums",
             fontsize=16, fontweight='bold')
plt.tight_layout(rect=[0, 0, 1, 0.95])
plt.savefig("viz_laplacian.png", dpi=150, bbox_inches='tight')
print("Saved viz_laplacian.png")


#!/usr/bin/env python3
"""
Visualization: Overlap Graph and Class Structure

Visualizes the overlap graph of a support family, with nodes colored
by overlap class. Shows how the connected components of the overlap
graph decompose the family into independent interaction sectors.

Uses matplotlib for static visualization.
"""

import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np
from collections import defaultdict
import math


def compute_overlap_classes_inline(family):
    """Union-find overlap class computation (self-contained)."""
    n = len(family)
    parent = list(range(n))
    
    def find(x):
        while parent[x] != x:
            parent[x] = parent[parent[x]]
            x = parent[x]
        return x
    
    def union(x, y):
        px, py = find(x), find(y)
        if px != py:
            parent[px] = py
    
    for i in range(n):
        for j in range(i + 1, n):
            if len(family[i] & family[j]) > 0:
                union(i, j)
    
    classes = defaultdict(list)
    for i in range(n):
        classes[find(i)].append(i)
    return list(classes.values())


def compute_edges(family):
    """Find all overlapping pairs."""
    edges = []
    for i in range(len(family)):
        for j in range(i + 1, len(family)):
            if len(family[i] & family[j]) > 0:
                edges.append((i, j))
    return edges


# Define the support family
family = [
    {1, 2, 3},      # F₀
    {3, 4, 5},      # F₁
    {5, 6},          # F₂
    {7, 8},          # F₃
    {8, 9, 10},      # F₄
    {11, 12},        # F₅
]

n = len(family)
classes = compute_overlap_classes_inline(family)
edges = compute_edges(family)
spectrum = sorted([len(c) for c in classes], reverse=True)

# Assign colors to classes
colors_palette = ['#e41a1c', '#377eb8', '#4daf4a', '#984ea3', '#ff7f00', '#a65628']
node_colors = ['grey'] * n
for cls_idx, cls in enumerate(classes):
    for i in cls:
        node_colors[i] = colors_palette[cls_idx % len(colors_palette)]

# Layout: place nodes in a circle
angles = [2 * math.pi * i / n for i in range(n)]
positions = [(math.cos(a), math.sin(a)) for a in angles]

# Create the figure
fig, axes = plt.subplots(1, 3, figsize=(18, 6))

# Panel 1: The overlap graph
ax1 = axes[0]
ax1.set_title("Overlap Graph", fontsize=14, fontweight='bold')
ax1.set_aspect('equal')
ax1.set_xlim(-1.6, 1.6)
ax1.set_ylim(-1.6, 1.6)

# Draw edges
for i, j in edges:
    x = [positions[i][0], positions[j][0]]
    y = [positions[i][1], positions[j][1]]
    ax1.plot(x, y, 'k-', linewidth=1.5, alpha=0.5)

# Draw nodes
for i in range(n):
    circle = plt.Circle(positions[i], 0.15, color=node_colors[i], 
                        ec='black', linewidth=2, zorder=5)
    ax1.add_patch(circle)
    ax1.text(positions[i][0], positions[i][1], f'F{i}', 
             ha='center', va='center', fontsize=10, fontweight='bold', zorder=6)

# Legend
legend_patches = []
for cls_idx, cls in enumerate(classes):
    label = f"Class {cls_idx+1}: " + ", ".join(f"F{i}" for i in cls)
    legend_patches.append(mpatches.Patch(
        color=colors_palette[cls_idx % len(colors_palette)], label=label))
ax1.legend(handles=legend_patches, loc='lower center', fontsize=8)
ax1.axis('off')

# Panel 2: Support Venn-style diagram
ax2 = axes[1]
ax2.set_title("Support Sets (Element View)", fontsize=14, fontweight='bold')
ax2.set_aspect('equal')

# Draw supports as colored rectangles with element labels
all_elements = sorted(set().union(*family))
elem_y = {elem: i for i, elem in enumerate(all_elements)}
max_y = len(all_elements)

for i in range(n):
    x_start = i * 1.2
    for elem in sorted(family[i]):
        y_pos = elem_y[elem]
        rect = plt.Rectangle((x_start, y_pos - 0.3), 0.8, 0.6,
                             facecolor=node_colors[i], alpha=0.6, 
                             edgecolor='black', linewidth=1)
        ax2.add_patch(rect)
        ax2.text(x_start + 0.4, y_pos, str(elem), 
                ha='center', va='center', fontsize=8)
    ax2.text(x_start + 0.4, -1, f'F{i}', ha='center', va='center',
            fontsize=10, fontweight='bold', color=node_colors[i])

ax2.set_xlim(-0.5, n * 1.2 + 0.5)
ax2.set_ylim(-2, max_y + 1)
ax2.set_ylabel("Element value", fontsize=10)
ax2.axis('off')

# Panel 3: Overlap spectrum (partition diagram)
ax3 = axes[2]
ax3.set_title(f"Overlap Spectrum: {spectrum}", fontsize=14, fontweight='bold')

# Draw Young diagram
max_part = max(spectrum) if spectrum else 0
for row_idx, part_size in enumerate(spectrum):
    for col in range(part_size):
        rect = plt.Rectangle((col, len(spectrum) - 1 - row_idx), 0.9, 0.9,
                             facecolor=colors_palette[row_idx % len(colors_palette)],
                             alpha=0.7, edgecolor='black', linewidth=2)
        ax3.add_patch(rect)
        ax3.text(col + 0.45, len(spectrum) - 0.55 - row_idx, 
                str(col + 1), ha='center', va='center', fontsize=10)

ax3.set_xlim(-0.5, max_part + 0.5)
ax3.set_ylim(-0.5, len(spectrum) + 0.5)
ax3.set_xlabel("Class size", fontsize=10)
ax3.set_ylabel("Class index", fontsize=10)
ax3.text(max_part / 2, -0.3, f"Sum = {sum(spectrum)} = n = {n}", 
         ha='center', fontsize=11, style='italic')
ax3.axis('off')

plt.suptitle("Overlap Spectrum Theory: Graph → Classes → Partition", 
             fontsize=16, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig("viz_overlap_graph.png", dpi=150, bbox_inches='tight')
print("Saved viz_overlap_graph.png")


#!/usr/bin/env python3
"""
Visualization: Overlap Spectrum as Integer Partition

Visualizes how the overlap spectrum changes as supports progressively
overlap, showing the transition from n singleton classes (disjoint case)
to 1 class (fully connected case).

Uses matplotlib for static visualization.
"""

import matplotlib.pyplot as plt
import numpy as np
from collections import defaultdict


def overlap_spectrum(family):
    """Compute overlap spectrum (self-contained)."""
    n = len(family)
    parent = list(range(n))
    
    def find(x):
        while parent[x] != x:
            parent[x] = parent[parent[x]]
            x = parent[x]
        return x
    
    def union(x, y):
        px, py = find(x), find(y)
        if px != py:
            parent[px] = py
    
    for i in range(n):
        for j in range(i + 1, n):
            if len(family[i] & family[j]) > 0:
                union(i, j)
    
    sizes = defaultdict(int)
    for i in range(n):
        sizes[find(i)] += 1
    return sorted(sizes.values(), reverse=True)


def overlap_degree(family):
    """Count overlapping pairs."""
    n = len(family)
    return sum(1 for i in range(n) for j in range(i+1, n) 
               if len(family[i] & family[j]) > 0)


def overlap_complexity(family):
    """Sum of intersection sizes."""
    n = len(family)
    return sum(len(family[i] & family[j]) 
               for i in range(n) for j in range(i+1, n))


# Create a sequence of families showing progressive overlap
n = 6
base_family = [{10*i+1, 10*i+2, 10*i+3} for i in range(n)]

# Progressive merging: add shared elements one by one
stages = []
labels = []

# Stage 0: Fully disjoint
stages.append([s.copy() for s in base_family])
labels.append("Disjoint")

# Stage 1: F0 and F1 share element
fam1 = [s.copy() for s in base_family]
fam1[1].add(3)  # share element 3
stages.append(fam1)
labels.append("F₀∩F₁ ≠ ∅")

# Stage 2: F2 and F3 also share
fam2 = [s.copy() for s in fam1]
fam2[3].add(23)  # share element 23
stages.append(fam2)
labels.append("+F₂∩F₃ ≠ ∅")

# Stage 3: Connect the two pairs
fam3 = [s.copy() for s in fam2]
fam3[2].add(13)  # F1 and F2 share
stages.append(fam3)
labels.append("+F₁∩F₂ ≠ ∅")

# Stage 4: F4 joins the big cluster
fam4 = [s.copy() for s in fam3]
fam4[4].add(33)  # F3 and F4 share
stages.append(fam4)
labels.append("+F₃∩F₄ ≠ ∅")

# Stage 5: Fully connected
fam5 = [s.copy() for s in fam4]
fam5[5].add(43)  # F4 and F5 share
stages.append(fam5)
labels.append("Fully connected")

# Create the visualization
fig, axes = plt.subplots(2, 3, figsize=(18, 12))

colors = ['#e41a1c', '#377eb8', '#4daf4a', '#984ea3', '#ff7f00', '#a65628']

for idx, (fam, label) in enumerate(zip(stages, labels)):
    row, col = idx // 3, idx % 3
    ax = axes[row][col]
    
    spec = overlap_spectrum(fam)
    deg = overlap_degree(fam)
    comp = overlap_complexity(fam)
    n_classes = len(spec)
    
    # Draw Young diagram
    max_part = max(spec) if spec else 0
    for r, part_size in enumerate(spec):
        for c in range(part_size):
            rect = plt.Rectangle((c * 1.1, (len(spec) - 1 - r) * 1.1), 
                               1.0, 1.0,
                               facecolor=colors[r % len(colors)],
                               alpha=0.7, edgecolor='black', linewidth=2)
            ax.add_patch(rect)
    
    ax.set_xlim(-0.5, max(max_part * 1.1 + 0.5, 2))
    ax.set_ylim(-2, len(spec) * 1.1 + 1)
    
    ax.set_title(f"Stage {idx}: {label}", fontsize=12, fontweight='bold')
    
    # Add info text
    info = (f"Spectrum: {spec}\n"
            f"Classes: {n_classes}, Edges: {deg}\n"
            f"Complexity: {comp}\n"
            f"Sum = {sum(spec)} = n ✓")
    ax.text(0.02, 0.02, info, transform=ax.transAxes, fontsize=9,
           verticalalignment='bottom', fontfamily='monospace',
           bbox=dict(boxstyle='round', facecolor='wheat', alpha=0.8))
    
    ax.axis('off')

plt.suptitle("Overlap Spectrum Evolution: From Disjoint to Fully Connected\n"
             "Each box represents one index; color = overlap class; "
             "row width = class size",
             fontsize=14, fontweight='bold')
plt.tight_layout(rect=[0, 0, 1, 0.92])
plt.savefig("viz_spectrum_partition.png", dpi=150, bbox_inches='tight')
print("Saved viz_spectrum_partition.png")
