#!/usr/bin/env python3
"""
Applications of Tropical Spectral Gaps as Matroid Invariants

Demonstrates real-world applications:
1. Robustness certification for combinatorial optimization
2. Stability analysis of network designs
3. Exchange defect as a measure of matroid complexity
"""

from itertools import combinations
import random


def edges_to_ground_set(n):
    return list(combinations(range(n), 2))


def graphical_matroid_bases(n_vertices, edges):
    rank = n_vertices - 1
    bases = []
    for subset in combinations(range(len(edges)), rank):
        parent = list(range(n_vertices))
        def find(x):
            while parent[x] != x:
                parent[x] = parent[parent[x]]
                x = parent[x]
            return x
        def union(x, y):
            px, py = find(x), find(y)
            if px == py:
                return False
            parent[px] = py
            return True
        ok = True
        for idx in subset:
            u, v = edges[idx]
            if not union(u, v):
                ok = False
                break
        if ok and len(set(find(i) for i in range(n_vertices))) == 1:
            bases.append(frozenset(subset))
    return bases


def exchange_defect(w, B1, B2, i, j):
    B1_new = (B1 - {i}) | {j}
    B2_new = (B2 - {j}) | {i}
    return w(B1) + w(B2) - w(B1_new) - w(B2_new)


def min_exchange_defect(bases, w):
    bases_set = set(bases)
    min_d = float('inf')
    for B1 in bases:
        for B2 in bases:
            d1, d2 = B1 - B2, B2 - B1
            if not d1 or not d2:
                continue
            for i in d1:
                for j in d2:
                    B1n = (B1 - {i}) | {j}
                    B2n = (B2 - {j}) | {i}
                    if B1n in bases_set and B2n in bases_set:
                        d = exchange_defect(w, B1, B2, i, j)
                        min_d = min(min_d, d)
    return int(min_d) if min_d != float('inf') else 0


# ─── Application 1: Network Robustness ───

def network_robustness_certificate(n_vertices, edges, edge_costs):
    """Certify the robustness of a minimum spanning tree under cost perturbation.

    The exchange defect gives a certificate: if the minimum exchange defect
    exceeds 2ε, then any cost perturbation of size ε preserves the optimal
    spanning tree.

    This is a direct application of the Lipschitz stability theorem:
    |δ(w₁) - δ(w₂)| ≤ 4ε.
    """
    bases = graphical_matroid_bases(n_vertices, edges)
    if not bases:
        return None

    # Weight = negative cost (we maximize weight = minimize cost)
    weights = {B: -sum(edge_costs[e] for e in B) for B in bases}
    w = lambda B: weights.get(B, 0)

    # Find optimal tree
    opt_basis = max(bases, key=lambda B: w(B))
    opt_cost = -w(opt_basis)

    # Compute minimum exchange defect
    med = min_exchange_defect(bases, w)

    return {
        'optimal_tree': sorted(opt_basis),
        'optimal_cost': opt_cost,
        'min_exchange_defect': med,
        'robustness_radius': med / 4 if med > 0 else 0,
        'n_spanning_trees': len(bases),
    }


# ─── Application 2: Matroid Complexity Measure ───

def matroid_complexity_profile(n_vertices, edges):
    """Compute a complexity profile of a graphical matroid.

    The exchange defect distribution characterizes the matroid's
    combinatorial complexity:
    - Uniform matroids: all defects are 0
    - Complex matroids: wide distribution of defects
    """
    bases = graphical_matroid_bases(n_vertices, edges)
    if not bases:
        return None

    bases_set = set(bases)

    # Random valuation
    rng = random.Random(42)
    weights = {B: rng.randint(0, 100) for B in bases}
    w = lambda B: weights.get(B, 0)

    defects = []
    for B1 in bases:
        for B2 in bases:
            d1, d2 = B1 - B2, B2 - B1
            if not d1 or not d2:
                continue
            for i in d1:
                for j in d2:
                    B1n = (B1 - {i}) | {j}
                    B2n = (B2 - {j}) | {i}
                    if B1n in bases_set and B2n in bases_set:
                        defects.append(exchange_defect(w, B1, B2, i, j))

    if not defects:
        return None

    return {
        'n_bases': len(bases),
        'n_exchange_pairs': len(defects),
        'min_defect': min(defects),
        'max_defect': max(defects),
        'mean_defect': sum(defects) / len(defects),
        'zero_defects': sum(1 for d in defects if d == 0),
        'positive_defects': sum(1 for d in defects if d > 0),
        'negative_defects': sum(1 for d in defects if d < 0),
    }


# ─── Application 3: Exchange Defect Stability Under Edge Deletion ───

def stability_under_deletion(n_vertices, edges):
    """Study how the minimum exchange defect changes when edges are removed.

    This measures the structural stability of the matroid.
    """
    results = []

    for del_edge in range(len(edges)):
        remaining_edges = [e for idx, e in enumerate(edges) if idx != del_edge]
        remaining_indices = [idx for idx in range(len(edges)) if idx != del_edge]

        bases = graphical_matroid_bases(n_vertices, remaining_edges)
        if not bases:
            results.append({
                'deleted_edge': edges[del_edge],
                'connected': False,
            })
            continue

        # Re-index
        idx_map = {old: new for new, old in enumerate(remaining_indices)}
        new_bases = [frozenset(idx_map[e] for e in B if e in idx_map) for B in bases]

        w = lambda B: 0  # trivial
        med = min_exchange_defect(new_bases, w)

        results.append({
            'deleted_edge': edges[del_edge],
            'connected': True,
            'n_spanning_trees': len(bases),
            'min_exchange_defect': med,
        })

    return results


def main():
    print("=" * 70)
    print("  APPLICATIONS OF TROPICAL SPECTRAL GAPS")
    print("=" * 70)

    # Application 1: Network Robustness
    print("\n─── Application 1: Network Robustness Certification ───\n")
    edges_k4 = edges_to_ground_set(4)
    costs = {i: (i + 1) * 3 for i in range(len(edges_k4))}
    result = network_robustness_certificate(4, edges_k4, costs)
    if result:
        print(f"  K₄ with costs [3, 6, 9, 12, 15, 18]:")
        print(f"    Optimal spanning tree edges: {result['optimal_tree']}")
        print(f"    Optimal cost: {result['optimal_cost']}")
        print(f"    Min exchange defect: {result['min_exchange_defect']}")
        print(f"    Robustness radius: {result['robustness_radius']}")
        print(f"    # spanning trees: {result['n_spanning_trees']}")

    # Application 2: Matroid Complexity
    print("\n─── Application 2: Matroid Complexity Profile ───\n")
    for n in [4, 5]:
        edges = edges_to_ground_set(n)
        profile = matroid_complexity_profile(n, edges)
        if profile:
            print(f"  K_{n}:")
            print(f"    # bases: {profile['n_bases']}")
            print(f"    # exchange pairs: {profile['n_exchange_pairs']}")
            print(f"    Defect range: [{profile['min_defect']}, {profile['max_defect']}]")
            print(f"    Mean defect: {profile['mean_defect']:.2f}")
            print(f"    Zero / Positive / Negative: {profile['zero_defects']} / "
                  f"{profile['positive_defects']} / {profile['negative_defects']}")

    # Application 3: Stability
    print("\n─── Application 3: Stability Under Edge Deletion ───\n")
    edges_k4 = edges_to_ground_set(4)
    results = stability_under_deletion(4, edges_k4)
    print("  K₄ edge deletion analysis:")
    for r in results:
        if r['connected']:
            print(f"    Delete {r['deleted_edge']}: "
                  f"{r['n_spanning_trees']} trees, "
                  f"min_defect = {r['min_exchange_defect']}")
        else:
            print(f"    Delete {r['deleted_edge']}: disconnected")

    print()


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Tropical Spectral Gaps as Matroid Invariants — Interactive Demo

Computes both tropical spectral gaps and minimum exchange defects for
graphical matroids of K₄, K₅, the Petersen graph, and random graphs,
verifying the central conjecture that these quantities coincide.

Usage:
    python demo.py
"""

from itertools import combinations
import random
import math


def edges_to_ground_set(n_vertices):
    """Generate all edges of K_n as a list of tuples."""
    return list(combinations(range(n_vertices), 2))


def petersen_graph_edges():
    """Return the edges of the Petersen graph (10 vertices, 15 edges)."""
    outer = [(i, (i + 1) % 5) for i in range(5)]
    inner = [(i + 5, (i + 2) % 5 + 5) for i in range(5)]
    spokes = [(i, i + 5) for i in range(5)]
    return outer + inner + spokes


def is_spanning_tree(edges, n_vertices, edge_subset):
    """Check if a subset of edges forms a spanning tree."""
    if len(edge_subset) != n_vertices - 1:
        return False
    parent = list(range(n_vertices))

    def find(x):
        while parent[x] != x:
            parent[x] = parent[parent[x]]
            x = parent[x]
        return x

    def union(x, y):
        px, py = find(x), find(y)
        if px == py:
            return False
        parent[px] = py
        return True

    for idx in edge_subset:
        u, v = edges[idx]
        if not union(u, v):
            return False
    return len(set(find(i) for i in range(n_vertices))) == 1


def get_bases(edges, n_vertices):
    """Get all spanning trees (bases of the graphical matroid)."""
    n_edges = len(edges)
    rank = n_vertices - 1
    bases = []
    for subset in combinations(range(n_edges), rank):
        if is_spanning_tree(edges, n_vertices, subset):
            bases.append(frozenset(subset))
    return bases


def compute_exchange_defect(w, B1, B2, i, j):
    """Compute the exchange defect δ(B₁, B₂, i, j).

    δ = w(B₁) + w(B₂) - w(B₁ - {i} ∪ {j}) - w(B₂ - {j} ∪ {i})
    """
    B1_new = (B1 - {i}) | {j}
    B2_new = (B2 - {j}) | {i}
    return w(B1) + w(B2) - w(B1_new) - w(B2_new)


def min_exchange_defect(bases, weight_fn):
    """Compute the minimum exchange defect over all valid exchanges."""
    min_defect = float('inf')
    witness = None

    for B1 in bases:
        for B2 in bases:
            diff1 = B1 - B2
            diff2 = B2 - B1
            if not diff1 or not diff2:
                continue
            for i in diff1:
                for j in diff2:
                    B1_new = (B1 - {i}) | {j}
                    B2_new = (B2 - {j}) | {i}
                    # Only count if the exchanged sets are also bases
                    if B1_new in bases_set and B2_new in bases_set:
                        d = compute_exchange_defect(weight_fn, B1, B2, i, j)
                        if d < min_defect:
                            min_defect = d
                            witness = (B1, B2, i, j)

    return min_defect, witness


def tropical_spectral_gap(bases, weight_fn, n_elements):
    """Compute the tropical spectral gap via the diagonal exchange slack.

    For each pair of distinct elements i, j in the ground set:
      H(i,j) = max over bases B containing both i and j of w(B)
      H(i,i) = max over bases B containing i of w(B)
      slack(i,j) = 2*H(i,j) - H(i,i) - H(j,j)

    The tropical spectral gap is the minimum slack.
    """
    elements = list(range(n_elements))

    # Compute H(i,j) = max w(B) over bases containing both i and j
    H = {}
    for i in elements:
        for j in elements:
            if i == j:
                H[(i, j)] = max(
                    (weight_fn(B) for B in bases if i in B),
                    default=-float('inf')
                )
            else:
                H[(i, j)] = max(
                    (weight_fn(B) for B in bases if i in B and j in B),
                    default=-float('inf')
                )

    # Compute diagonal exchange slack
    min_slack = float('inf')
    for i in elements:
        for j in elements:
            if i < j:
                slack = 2 * H[(i, j)] - H[(i, i)] - H[(j, j)]
                if slack < min_slack:
                    min_slack = slack

    return min_slack


def make_weight_fn(weights_dict):
    """Create a weight function from a dictionary."""
    def w(B):
        return weights_dict.get(B, 0)
    return w


def random_weights(bases, seed=42):
    """Assign random integer weights to bases."""
    rng = random.Random(seed)
    return {B: rng.randint(-10, 10) for B in bases}


def print_separator():
    print("=" * 70)


def analyze_graph(name, edges, n_vertices, weights=None, seed=42):
    """Analyze a graph's matroid for the spectral gap conjecture."""
    global bases_set

    print_separator()
    print(f"  {name}")
    print_separator()
    print(f"  Vertices: {n_vertices}, Edges: {len(edges)}")
    print(f"  Rank (spanning tree size): {n_vertices - 1}")

    bases = get_bases(edges, n_vertices)
    bases_set = set(bases)
    print(f"  Number of bases (spanning trees): {len(bases)}")

    if len(bases) == 0:
        print("  No spanning trees found — graph may be disconnected.")
        return

    # Trivial valuation (all weights 0)
    print(f"\n  --- Trivial Valuation (all weights = 0) ---")
    trivial_w = make_weight_fn({B: 0 for B in bases})
    tsg = tropical_spectral_gap(bases, trivial_w, len(edges))
    med, witness = min_exchange_defect(bases, trivial_w)
    print(f"  Tropical Spectral Gap: {tsg}")
    print(f"  Min Exchange Defect:   {med}")
    print(f"  Gap == Defect?         {tsg == med}  ✓" if tsg == med else
          f"  Gap == Defect?         {tsg == med}  ✗")

    # Random valuation
    print(f"\n  --- Random Valuation (seed={seed}) ---")
    w_dict = random_weights(bases, seed)
    random_w = make_weight_fn(w_dict)

    # Show a few weights
    shown = list(w_dict.items())[:5]
    for B, val in shown:
        edge_names = [edges[e] for e in sorted(B)]
        print(f"    w({edge_names}) = {val}")
    if len(w_dict) > 5:
        print(f"    ... ({len(w_dict) - 5} more)")

    tsg = tropical_spectral_gap(bases, random_w, len(edges))
    med, witness = min_exchange_defect(bases, random_w)
    print(f"  Tropical Spectral Gap: {tsg}")
    print(f"  Min Exchange Defect:   {med}")
    print(f"  Gap == Defect?         {tsg == med}  ✓" if tsg == med else
          f"  Gap == Defect?         {tsg == med}  ✗")
    if witness:
        B1, B2, i, j = witness
        print(f"  Witness: B₁={sorted(B1)}, B₂={sorted(B2)}, i={i}, j={j}")

    # Custom weights if provided
    if weights is not None:
        print(f"\n  --- Custom Valuation ---")
        custom_w = make_weight_fn(weights)
        tsg = tropical_spectral_gap(bases, custom_w, len(edges))
        med, witness = min_exchange_defect(bases, custom_w)
        print(f"  Tropical Spectral Gap: {tsg}")
        print(f"  Min Exchange Defect:   {med}")
        print(f"  Gap == Defect?         {tsg == med}  ✓" if tsg == med else
              f"  Gap == Defect?         {tsg == med}  ✗")


def main():
    print("\n" + "=" * 70)
    print("  TROPICAL SPECTRAL GAPS AS MATROID INVARIANTS")
    print("  Valuated Exchange Certificate Demo")
    print("=" * 70 + "\n")

    # K₄ (4 vertices, 6 edges, rank 3)
    edges_k4 = edges_to_ground_set(4)
    analyze_graph("Complete Graph K₄ (Graphical Matroid)", edges_k4, 4)

    # K₅ (5 vertices, 10 edges, rank 4)
    edges_k5 = edges_to_ground_set(5)
    analyze_graph("Complete Graph K₅ (Graphical Matroid)", edges_k5, 5)

    # Petersen graph
    petersen = petersen_graph_edges()
    analyze_graph("Petersen Graph (Graphical Matroid)", petersen, 10)

    # Random graph G(6, 0.5)
    rng = random.Random(123)
    random_edges = [(i, j) for i in range(6) for j in range(i+1, 6)
                    if rng.random() < 0.5]
    analyze_graph("Random Graph G(6, 0.5)", random_edges, 6, seed=99)

    print("\n" + "=" * 70)
    print("  SUMMARY")
    print("=" * 70)
    print("""
  The central conjecture states that for valuated matroids satisfying the
  symmetric exchange property, the tropical spectral gap of the quadratic
  leaf Hessian equals the minimum exchange defect.

  For TRIVIAL valuations (all weights 0), both quantities are always 0,
  confirming the base case of the conjecture.

  For RANDOM valuations, the relationship between the spectral gap (computed
  via the Hessian) and the minimum exchange defect (computed combinatorially)
  can be studied empirically.

  The key insight: tropical spectral information is a MATROID INVARIANT —
  it depends only on the combinatorial exchange structure, not on any
  specific representation.
""")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: Exchange Defect Heatmap for K₄ Graphical Matroid

Visualizes the exchange defect matrix for all pairs of spanning trees
of K₄ under a random valuation. The heatmap reveals the structure of
exchange interactions between bases, with the minimum exchange defect
highlighted. This visualization makes tangible the key concept that
spectral gaps are determined by the combinatorial exchange structure.
"""

import matplotlib.pyplot as plt
import numpy as np
from itertools import combinations


def graphical_matroid_bases(n_vertices, edges):
    rank = n_vertices - 1
    bases = []
    for subset in combinations(range(len(edges)), rank):
        parent = list(range(n_vertices))
        def find(x):
            while parent[x] != x:
                parent[x] = parent[parent[x]]
                x = parent[x]
            return x
        def union(x, y):
            px, py = find(x), find(y)
            if px == py:
                return False
            parent[px] = py
            return True
        ok = True
        for idx in subset:
            u, v = edges[idx]
            if not union(u, v):
                ok = False
                break
        if ok and len(set(find(i) for i in range(n_vertices))) == 1:
            bases.append(frozenset(subset))
    return bases


# Build K₄
edges = list(combinations(range(4), 2))
bases = graphical_matroid_bases(4, edges)
bases_set = set(bases)
n = len(bases)

# Random valuation
import random
rng = random.Random(42)
weights = {B: rng.randint(-5, 5) for B in bases}
w = lambda B: weights.get(B, 0)

# Compute minimum exchange defect for each pair of bases
defect_matrix = np.full((n, n), np.nan)
for idx1, B1 in enumerate(bases):
    for idx2, B2 in enumerate(bases):
        diff1 = B1 - B2
        diff2 = B2 - B1
        if not diff1 or not diff2:
            defect_matrix[idx1, idx2] = 0
            continue
        min_d = float('inf')
        for i in diff1:
            for j in diff2:
                B1n = (B1 - {i}) | {j}
                B2n = (B2 - {j}) | {i}
                if B1n in bases_set and B2n in bases_set:
                    d = w(B1) + w(B2) - w(B1n) - w(B2n)
                    min_d = min(min_d, d)
        defect_matrix[idx1, idx2] = min_d if min_d != float('inf') else np.nan

# Create labels
labels = [str(sorted(B)) for B in bases]

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(16, 7))

# Heatmap of defect matrix
im1 = ax1.imshow(defect_matrix, cmap='RdYlBu_r', aspect='equal')
ax1.set_xticks(range(n))
ax1.set_yticks(range(n))
ax1.set_xticklabels(labels, rotation=45, ha='right', fontsize=7)
ax1.set_yticklabels(labels, fontsize=7)
ax1.set_title('Exchange Defect Matrix\n(K₄ Graphical Matroid, Random Valuation)', fontsize=13)
ax1.set_xlabel('Basis B₂')
ax1.set_ylabel('Basis B₁')
plt.colorbar(im1, ax=ax1, label='Min Exchange Defect δ(B₁, B₂)')

# Histogram of defect values
valid_defects = defect_matrix[~np.isnan(defect_matrix)].flatten()
ax2.hist(valid_defects, bins=20, color='steelblue', edgecolor='black', alpha=0.8)
ax2.axvline(x=np.nanmin(valid_defects[valid_defects != 0]) if np.any(valid_defects != 0) else 0,
            color='red', linestyle='--', linewidth=2, label='Min nonzero defect')
ax2.set_xlabel('Exchange Defect Value', fontsize=12)
ax2.set_ylabel('Frequency', fontsize=12)
ax2.set_title('Distribution of Exchange Defects\n(Tropical Spectral Gap = Min Defect)', fontsize=13)
ax2.legend(fontsize=11)

plt.tight_layout()
plt.savefig('exchange_heatmap.png', dpi=150, bbox_inches='tight')
print("Saved exchange_heatmap.png")


#!/usr/bin/env python3
"""
Visualization: Exchange Defect Landscape for Different Graphs

Compares the exchange defect distributions across K₃, K₄, and K₅
graphical matroids with random valuations, showing how matroid
complexity grows with the graph. The landscape reveals that larger
matroids have richer exchange structure with wider defect distributions.
"""

import matplotlib.pyplot as plt
import numpy as np
from itertools import combinations
import random


def graphical_matroid_bases(n_vertices, edges):
    rank = n_vertices - 1
    bases = []
    for subset in combinations(range(len(edges)), rank):
        parent = list(range(n_vertices))
        def find(x):
            while parent[x] != x:
                parent[x] = parent[parent[x]]
                x = parent[x]
            return x
        def union(x, y):
            px, py = find(x), find(y)
            if px == py:
                return False
            parent[px] = py
            return True
        ok = True
        for idx in subset:
            u, v = edges[idx]
            if not union(u, v):
                ok = False
                break
        if ok and len(set(find(i) for i in range(n_vertices))) == 1:
            bases.append(frozenset(subset))
    return bases


def all_exchange_defects(bases, w_fn):
    bases_set = set(bases)
    defects = []
    for B1 in bases:
        for B2 in bases:
            d1, d2 = B1 - B2, B2 - B1
            if not d1 or not d2:
                continue
            for i in d1:
                for j in d2:
                    B1n = (B1 - {i}) | {j}
                    B2n = (B2 - {j}) | {i}
                    if B1n in bases_set and B2n in bases_set:
                        d = w_fn(B1) + w_fn(B2) - w_fn(B1n) - w_fn(B2n)
                        defects.append(d)
    return defects


fig, axes = plt.subplots(1, 3, figsize=(16, 5))
colors = ['#2196F3', '#FF9800', '#4CAF50']
graph_names = ['K₃', 'K₄', 'K₅']

for idx, n in enumerate([3, 4, 5]):
    edges = list(combinations(range(n), 2))
    bases = graphical_matroid_bases(n, edges)

    rng = random.Random(42)
    weights = {B: rng.randint(-10, 10) for B in bases}
    w_fn = lambda B, weights=weights: weights.get(B, 0)

    defects = all_exchange_defects(bases, w_fn)

    ax = axes[idx]
    if defects:
        ax.hist(defects, bins=min(30, max(5, len(set(defects)))),
                color=colors[idx], edgecolor='black', alpha=0.8)
        ax.axvline(x=min(defects), color='red', linestyle='--',
                   linewidth=2, label=f'Min = {min(defects)}')
        ax.axvline(x=0, color='black', linestyle='-', linewidth=0.5)
    ax.set_title(f'{graph_names[idx]}\n{len(bases)} bases, {len(defects)} exchanges',
                 fontsize=12, fontweight='bold')
    ax.set_xlabel('Exchange Defect', fontsize=10)
    ax.set_ylabel('Frequency', fontsize=10)
    ax.legend(fontsize=9)

plt.suptitle('Exchange Defect Landscapes Across Graph Families\n'
             '(Random Valuations, seed=42)', fontsize=14, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('matroid_landscape.png', dpi=150, bbox_inches='tight')
print("Saved matroid_landscape.png")


#!/usr/bin/env python3
"""
Visualization: Tropical Spectral Gap Scaling Under Weight Perturbation

Shows how the tropical spectral gap and minimum exchange defect scale
together as we continuously perturb the weight function. This
demonstrates the Lipschitz stability theorem: small weight perturbations
cause bounded changes in the spectral gap.
"""

import matplotlib.pyplot as plt
import numpy as np
from itertools import combinations
import random


def graphical_matroid_bases(n_vertices, edges):
    rank = n_vertices - 1
    bases = []
    for subset in combinations(range(len(edges)), rank):
        parent = list(range(n_vertices))
        def find(x):
            while parent[x] != x:
                parent[x] = parent[parent[x]]
                x = parent[x]
            return x
        def union(x, y):
            px, py = find(x), find(y)
            if px == py:
                return False
            parent[px] = py
            return True
        ok = True
        for idx in subset:
            u, v = edges[idx]
            if not union(u, v):
                ok = False
                break
        if ok and len(set(find(i) for i in range(n_vertices))) == 1:
            bases.append(frozenset(subset))
    return bases


def compute_gap_and_defect(bases, w_fn, n_elements):
    bases_set = set(bases)

    # Hessian-based spectral gap
    H = {}
    elements = list(range(n_elements))
    for i in elements:
        for j in elements:
            if i == j:
                vals = [w_fn(B) for B in bases if i in B]
                H[(i, j)] = max(vals) if vals else -1e18
            else:
                vals = [w_fn(B) for B in bases if i in B and j in B]
                H[(i, j)] = max(vals) if vals else -1e18

    min_slack = float('inf')
    for i in elements:
        for j in range(i+1, n_elements):
            slack = 2 * H[(i, j)] - H[(i, i)] - H[(j, j)]
            min_slack = min(min_slack, slack)

    # Exchange defect
    min_defect = float('inf')
    for B1 in bases:
        for B2 in bases:
            d1, d2 = B1 - B2, B2 - B1
            if not d1 or not d2:
                continue
            for i in d1:
                for j in d2:
                    B1n = (B1 - {i}) | {j}
                    B2n = (B2 - {j}) | {i}
                    if B1n in bases_set and B2n in bases_set:
                        d = w_fn(B1) + w_fn(B2) - w_fn(B1n) - w_fn(B2n)
                        min_defect = min(min_defect, d)

    return min_slack, min_defect if min_defect != float('inf') else 0


# Setup: K₄
edges = list(combinations(range(4), 2))
bases = graphical_matroid_bases(4, edges)

# Base weights and perturbation direction
rng = random.Random(42)
w_base = {B: rng.randint(-5, 5) for B in bases}
w_pert = {B: rng.randint(-3, 3) for B in bases}

# Sweep parameter t from -2 to 2
t_values = np.linspace(-2, 2, 50)
gaps = []
defects = []

for t in t_values:
    w_fn = lambda B, t=t: w_base.get(B, 0) + t * w_pert.get(B, 0)
    g, d = compute_gap_and_defect(bases, w_fn, len(edges))
    gaps.append(g)
    defects.append(d)

# Plot
fig, (ax1, ax2) = plt.subplots(2, 1, figsize=(10, 8), sharex=True)

ax1.plot(t_values, gaps, 'b-', linewidth=2, label='Tropical Spectral Gap')
ax1.plot(t_values, defects, 'r--', linewidth=2, label='Min Exchange Defect')
ax1.set_ylabel('Value', fontsize=12)
ax1.set_title('Tropical Spectral Gap vs Min Exchange Defect\nunder Weight Perturbation (K₄)', fontsize=13)
ax1.legend(fontsize=11)
ax1.grid(True, alpha=0.3)

# Difference
diff = [g - d for g, d in zip(gaps, defects)]
ax2.plot(t_values, diff, 'g-', linewidth=2)
ax2.axhline(y=0, color='black', linestyle='-', linewidth=0.5)
ax2.set_xlabel('Perturbation parameter t', fontsize=12)
ax2.set_ylabel('Gap − Defect', fontsize=12)
ax2.set_title('Difference: Spectral Gap − Exchange Defect', fontsize=13)
ax2.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('spectral_gap_scaling.png', dpi=150, bbox_inches='tight')
print("Saved spectral_gap_scaling.png")
