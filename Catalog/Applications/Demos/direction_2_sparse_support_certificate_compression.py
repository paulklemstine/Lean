"""
Applications of Support-Compressed Leaf Counting

Real-world applications of the support compression theory:
1. Network reliability polynomial certification
2. Optimization of Lorentzian recognition for specific matroid families
3. Comparison of compression across matroid families
"""

from itertools import combinations
from math import comb
from typing import FrozenSet, List, Tuple, Set, Dict


# ======== Core algorithms (self-contained) ========

def independent_sets_of_size(bases, n, k):
    result = []
    for subset in combinations(range(n), k):
        fs = frozenset(subset)
        if any(fs <= B for B in bases):
            result.append(fs)
    return result


def count_leaves(bases, n, r):
    if r < 2:
        return 1
    return len(independent_sets_of_size(bases, n, r - 2))


def active_vars(bases):
    return len(set().union(*bases)) if bases else 0


def uniform_bases(n, r):
    return [frozenset(s) for s in combinations(range(n), r)]


def graphic_bases(edges, nv):
    ne = len(edges)
    rank = nv - 1
    bases = []
    for subset in combinations(range(ne), rank):
        adj = {v: set() for v in range(nv)}
        for idx in subset:
            u, v = edges[idx]
            adj[u].add(v)
            adj[v].add(u)
        visited = set()
        queue = [0]
        visited.add(0)
        while queue:
            node = queue.pop(0)
            for nb in adj[node]:
                if nb not in visited:
                    visited.add(nb)
                    queue.append(nb)
        if len(visited) == nv:
            bases.append(frozenset(subset))
    return bases


# ======== Application 1: Network Reliability ========

def network_reliability_analysis(edges, nv, name="Graph"):
    """
    Analyze certification complexity for network reliability polynomial.

    The reliability polynomial R(G, p) = sum over spanning trees T of
    p^|E(T)| * (1-p)^(|E|-|E(T)|). Its basis generating polynomial
    is the matroid basis polynomial of the graphic matroid.

    The quadratic leaf count tells us how many spectral checks are needed
    to certify Lorentzian-type log-concavity properties.
    """
    ne = len(edges)
    rank = nv - 1
    bases = graphic_bases(edges, nv)

    if not bases or rank < 2:
        return None

    leaves = count_leaves(bases, ne, rank)
    ambient = comb(ne, rank - 2)
    active = active_vars(bases)
    compressed = comb(active, rank - 2)

    return {
        "name": name,
        "vertices": nv,
        "edges": ne,
        "rank": rank,
        "spanning_trees": len(bases),
        "quadratic_leaves": leaves,
        "ambient_bound": ambient,
        "compressed_bound": compressed,
        "active_variables": active,
        "compression_ratio": leaves / ambient if ambient > 0 else 1.0,
    }


def demo_network_reliability():
    """Show how support compression helps certify network reliability."""
    print("=" * 70)
    print("APPLICATION: Network Reliability Certification")
    print("=" * 70)
    print()
    print("The reliability polynomial of a graph measures the probability")
    print("that a network remains connected when edges fail independently.")
    print("Certifying log-concavity requires checking quadratic leaves.")
    print("Support compression reduces the number of checks needed.")
    print()

    graphs = [
        ("Path P_5", [(i, i+1) for i in range(4)], 5),
        ("Cycle C_5", [(i, (i+1)%5) for i in range(5)], 5),
        ("K_4", [(i,j) for i in range(4) for j in range(i+1,4)], 4),
        ("K_5", [(i,j) for i in range(5) for j in range(i+1,5)], 5),
        ("Petersen-like", [(0,1),(1,2),(2,3),(3,4),(4,0),(0,2),(1,3),(2,4),(3,0),(4,1)], 5),
        ("Grid 2x3", [(0,1),(1,2),(3,4),(4,5),(0,3),(1,4),(2,5)], 6),
    ]

    print(f"{'Graph':<16} {'|V|':>4} {'|E|':>4} {'rank':>5} {'trees':>7} "
          f"{'leaves':>7} {'ambient':>8} {'ratio':>7}")
    print("-" * 65)

    for name, edges, nv in graphs:
        result = network_reliability_analysis(edges, nv, name)
        if result:
            print(f"{result['name']:<16} {result['vertices']:>4} {result['edges']:>4} "
                  f"{result['rank']:>5} {result['spanning_trees']:>7} "
                  f"{result['quadratic_leaves']:>7} {result['ambient_bound']:>8} "
                  f"{result['compression_ratio']:>7.4f}")


# ======== Application 2: Matroid Family Comparison ========

def demo_matroid_families():
    """Compare compression across matroid families."""
    print()
    print("=" * 70)
    print("APPLICATION: Compression Across Matroid Families")
    print("=" * 70)
    print()

    # Uniform matroids
    print("--- Uniform Matroids U_{r,n} ---")
    print("(Always ratio = 1.0 since every subset is independent)")
    print(f"{'(r,n)':<12} {'leaves':>8} {'ambient':>8}")
    print("-" * 30)
    for n, r in [(6,3), (8,4), (10,5), (12,4)]:
        bases = uniform_bases(n, r)
        leaves = count_leaves(bases, n, r)
        ambient = comb(n, r-2)
        label = f"U_{{{r},{n}}}"
        print(f"{label:<12} {leaves:>8} {ambient:>8}")

    # Graphic matroids of sparse graphs
    print()
    print("--- Graphic Matroids of Sparse Graphs ---")
    print("(Sparse graphs should show compression)")
    print(f"{'Graph':<16} {'leaves':>8} {'ambient':>8} {'ratio':>8}")
    print("-" * 45)

    sparse_graphs = [
        ("Star S_5", [(0,i) for i in range(1,6)], 6),
        ("Path P_6", [(i,i+1) for i in range(5)], 6),
        ("Binary tree", [(0,1),(0,2),(1,3),(1,4),(2,5),(2,6)], 7),
    ]

    for name, edges, nv in sparse_graphs:
        ne = len(edges)
        rank = nv - 1
        bases = graphic_bases(edges, nv)
        if bases and rank >= 2:
            leaves = count_leaves(bases, ne, rank)
            ambient = comb(ne, rank-2)
            ratio = leaves / ambient if ambient > 0 else 1
            print(f"{name:<16} {leaves:>8} {ambient:>8} {ratio:>8.4f}")


# ======== Application 3: Certified Lorentzian Recognition ========

def certified_lorentzian_check(bases, n, r):
    """
    Simulate a Lorentzian recognition check using support compression.

    Instead of checking all C(n, r-2) derivative leaves, we only check
    the independent (r-2)-sets. Each check verifies that the Hessian
    of the corresponding quadratic has at most one positive eigenvalue.

    Returns the list of leaves that need checking.
    """
    if r < 2:
        return [frozenset()]
    return independent_sets_of_size(bases, n, r - 2)


def demo_certified_recognition():
    """Demonstrate the certified recognition algorithm."""
    print()
    print("=" * 70)
    print("APPLICATION: Certified Lorentzian Recognition")
    print("=" * 70)
    print()
    print("The algorithm identifies exactly which derivative leaves survive,")
    print("avoiding unnecessary spectral checks on zero derivatives.")
    print()

    # Example: K_4 graphic matroid
    edges = [(i,j) for i in range(4) for j in range(i+1,4)]
    nv = 4
    ne = len(edges)
    rank = nv - 1
    bases = graphic_bases(edges, nv)

    print(f"Graph: K_4 ({nv} vertices, {ne} edges)")
    print(f"Rank: {rank}")
    print(f"Spanning trees: {len(bases)}")
    print()

    leaves = certified_lorentzian_check(bases, ne, rank)
    print(f"Surviving quadratic leaves ({len(leaves)} total):")
    for i, leaf in enumerate(sorted(leaves)):
        edge_names = [f"e{j}" for j in sorted(leaf)]
        print(f"  Leaf {i+1}: {{{', '.join(edge_names)}}}")

    print()
    ambient = comb(ne, rank - 2)
    print(f"Ambient leaf count: C({ne}, {rank-2}) = {ambient}")
    print(f"Actual leaf count: {len(leaves)}")
    print(f"Savings: {ambient - len(leaves)} unnecessary checks avoided")


if __name__ == "__main__":
    demo_network_reliability()
    demo_matroid_families()
    demo_certified_recognition()


"""
Demo: Support-Compressed Leaf Counting for Matroid Basis Polynomials

This script demonstrates the core theorems computationally:
1. Uniform matroid closed form: leaves = C(n, r-2)
2. Graphic matroid: leaves = number of forests of size r-2
3. Support compression ratios
4. Comparison of naive vs compressed leaf counts
"""

from itertools import combinations
from typing import FrozenSet, Set, List, Tuple, Dict
from math import comb
import time


# ======== Inline algorithm implementations ========

def independent_sets_of_size(bases, n, k):
    if k < 0:
        return []
    result = []
    for subset in combinations(range(n), k):
        fs = frozenset(subset)
        if any(fs <= B for B in bases):
            result.append(fs)
    return result


def count_nonzero_quadratic_leaves(bases, n, r):
    if r < 2:
        return 1
    return len(independent_sets_of_size(bases, n, r - 2))


def active_variable_count(bases):
    return len(set().union(*bases)) if bases else 0


def uniform_matroid_bases(n, r):
    return [frozenset(s) for s in combinations(range(n), r)]


def graphic_matroid_bases(edges, num_vertices):
    n_edges = len(edges)
    rank = num_vertices - 1
    bases = []
    for subset in combinations(range(n_edges), rank):
        adj = {v: set() for v in range(num_vertices)}
        for idx in subset:
            u, v = edges[idx]
            adj[u].add(v)
            adj[v].add(u)
        visited = set()
        queue = [0]
        visited.add(0)
        while queue:
            node = queue.pop(0)
            for neighbor in adj[node]:
                if neighbor not in visited:
                    visited.add(neighbor)
                    queue.append(neighbor)
        if len(visited) == num_vertices:
            bases.append(frozenset(subset))
    return bases


def path_graph_edges(n):
    return [(i, i + 1) for i in range(n - 1)]


def cycle_graph_edges(n):
    return [(i, (i + 1) % n) for i in range(n)]


def complete_graph_edges(n):
    return [(i, j) for i in range(n) for j in range(i + 1, n)]


def transversal_matroid_bases(sets, ground_size):
    n = len(sets)
    bases = []
    def find_sdrs(idx, used, current):
        if idx == n:
            bases.append(frozenset(current))
            return
        for elem in sets[idx]:
            if elem not in used:
                used.add(elem)
                current.append(elem)
                find_sdrs(idx + 1, used, current)
                current.pop()
                used.remove(elem)
    find_sdrs(0, set(), [])
    return bases


# ======== Demo Functions ========

def demo_uniform_matroid():
    """Demonstrate Theorem 3: Uniform matroid closed form."""
    print("=" * 70)
    print("THEOREM 3: Uniform Matroid Closed Form")
    print("For U_{r,n}: #leaves = C(n, r-2)")
    print("=" * 70)

    test_cases = [
        (5, 3), (6, 3), (6, 4), (7, 4), (8, 5), (10, 4), (10, 5)
    ]

    print(f"\n{'n':>4} {'r':>4} {'C(n,r-2)':>10} {'Actual':>10} {'Match':>8}")
    print("-" * 40)

    for n, r in test_cases:
        bases = uniform_matroid_bases(n, r)
        actual = count_nonzero_quadratic_leaves(bases, n, r)
        expected = comb(n, r - 2)
        match = "✓" if actual == expected else "✗"
        print(f"{n:>4} {r:>4} {expected:>10} {actual:>10} {match:>8}")


def demo_graphic_matroid():
    """Demonstrate quadratic leaves for graphic matroids."""
    print("\n" + "=" * 70)
    print("GRAPHIC MATROIDS: Leaves = Independent (r-2)-sets")
    print("=" * 70)

    graphs = [
        ("Path P_4", path_graph_edges(4), 4),
        ("Path P_5", path_graph_edges(5), 5),
        ("Cycle C_4", cycle_graph_edges(4), 4),
        ("Cycle C_5", cycle_graph_edges(5), 5),
        ("K_4", complete_graph_edges(4), 4),
        ("K_5", complete_graph_edges(5), 5),
    ]

    print(f"\n{'Graph':>12} {'|E|':>5} {'rank':>5} {'#bases':>8} {'#leaves':>8} "
          f"{'ambient':>10} {'ratio':>8}")
    print("-" * 65)

    for name, edges, nv in graphs:
        ne = len(edges)
        rank = nv - 1
        bases = graphic_matroid_bases(edges, nv)
        if not bases:
            continue
        actual = count_nonzero_quadratic_leaves(bases, ne, rank)
        ambient = comb(ne, rank - 2)
        ratio = actual / ambient if ambient > 0 else 0
        print(f"{name:>12} {ne:>5} {rank:>5} {len(bases):>8} {actual:>8} "
              f"{ambient:>10} {ratio:>8.4f}")


def demo_compression_ratios():
    """Demonstrate support compression ratios."""
    print("\n" + "=" * 70)
    print("THEOREM 4: Support Compression Ratios")
    print("actual / C(n, r-2)  — smaller = more compression")
    print("=" * 70)

    print("\n--- Sparse Graphic Matroids (Path graphs) ---")
    print(f"{'n_vert':>8} {'|E|':>5} {'rank':>5} {'actual':>8} "
          f"{'C(|E|,r-2)':>12} {'C(active,r-2)':>14} {'ratio':>8}")
    print("-" * 65)

    for nv in [4, 5, 6, 7, 8]:
        edges = path_graph_edges(nv)
        ne = len(edges)
        rank = nv - 1
        bases = graphic_matroid_bases(edges, nv)
        if not bases or rank < 2:
            continue
        actual = count_nonzero_quadratic_leaves(bases, ne, rank)
        ambient = comb(ne, rank - 2)
        active = active_variable_count(bases)
        compressed = comb(active, rank - 2)
        ratio = actual / ambient if ambient > 0 else 0
        print(f"{nv:>8} {ne:>5} {rank:>5} {actual:>8} "
              f"{ambient:>12} {compressed:>14} {ratio:>8.4f}")

    print("\n--- Dense Graphic Matroids (Complete graphs) ---")
    print(f"{'n_vert':>8} {'|E|':>5} {'rank':>5} {'actual':>8} "
          f"{'C(|E|,r-2)':>12} {'ratio':>8}")
    print("-" * 55)

    for nv in [4, 5, 6]:
        edges = complete_graph_edges(nv)
        ne = len(edges)
        rank = nv - 1
        bases = graphic_matroid_bases(edges, nv)
        if not bases or rank < 2:
            continue
        actual = count_nonzero_quadratic_leaves(bases, ne, rank)
        ambient = comb(ne, rank - 2)
        ratio = actual / ambient if ambient > 0 else 0
        print(f"{nv:>8} {ne:>5} {rank:>5} {actual:>8} "
              f"{ambient:>12} {ratio:>8.4f}")


def demo_transversal_matroid():
    """Demonstrate with transversal matroids."""
    print("\n" + "=" * 70)
    print("TRANSVERSAL MATROIDS")
    print("=" * 70)

    # Example: bipartite graph with 3 sets on ground set {0,...,4}
    sets = [{0, 1, 2}, {1, 2, 3}, {2, 3, 4}]
    ground = 5
    bases = transversal_matroid_bases(sets, ground)
    r = len(sets)  # rank = number of sets

    print(f"\nSets: {sets}")
    print(f"Ground size: {ground}, Rank: {r}")
    print(f"Bases: {[sorted(b) for b in bases]}")
    print(f"Number of bases: {len(bases)}")

    if r >= 2:
        actual = count_nonzero_quadratic_leaves(bases, ground, r)
        ambient = comb(ground, r - 2)
        active = active_variable_count(bases)
        compressed = comb(active, r - 2)
        print(f"Quadratic leaves: {actual}")
        print(f"Ambient C({ground}, {r-2}): {ambient}")
        print(f"Active variables: {active}")
        print(f"Compressed bound C({active}, {r-2}): {compressed}")
        print(f"Compression ratio: {actual/ambient:.4f}" if ambient > 0 else "")


def demo_timing():
    """Compare timing of compressed vs naive enumeration."""
    print("\n" + "=" * 70)
    print("TIMING COMPARISON: Compressed vs Naive")
    print("=" * 70)

    for n, r in [(8, 4), (10, 4), (12, 5)]:
        bases = uniform_matroid_bases(n, r)

        t0 = time.time()
        actual = count_nonzero_quadratic_leaves(bases, n, r)
        t_compressed = time.time() - t0

        t0 = time.time()
        ambient = comb(n, r - 2)
        t_ambient = time.time() - t0

        print(f"\nU_{{{r},{n}}}: leaves={actual}, ambient={ambient}")
        print(f"  Compressed enumeration: {t_compressed:.4f}s")
        print(f"  Ambient computation:    {t_ambient:.6f}s")
        print(f"  (Both give {actual} for uniform matroid)")


if __name__ == "__main__":
    demo_uniform_matroid()
    demo_graphic_matroid()
    demo_compression_ratios()
    demo_transversal_matroid()
    demo_timing()

    print("\n" + "=" * 70)
    print("All demonstrations completed successfully.")
    print("=" * 70)


"""
Visualization: Compression Ratios Across Matroid Families

This script creates a heatmap showing how the compression ratio
(actual quadratic leaves / ambient leaf count) varies across different
matroid families and parameters. The key insight is that sparse matroids
achieve significant compression, while uniform matroids show no compression.

Requires: numpy, matplotlib
"""

import numpy as np
import matplotlib.pyplot as plt
from itertools import combinations
from math import comb


# ======== Self-contained algorithm implementations ========

def independent_sets_of_size(bases, n, k):
    result = []
    for subset in combinations(range(n), k):
        fs = frozenset(subset)
        if any(fs <= B for B in bases):
            result.append(fs)
    return result


def count_leaves(bases, n, r):
    if r < 2:
        return 1
    return len(independent_sets_of_size(bases, n, r - 2))


def uniform_bases(n, r):
    return [frozenset(s) for s in combinations(range(n), r)]


def graphic_bases(edges, nv):
    ne = len(edges)
    rank = nv - 1
    bases = []
    for subset in combinations(range(ne), rank):
        adj = {v: set() for v in range(nv)}
        for idx in subset:
            u, v = edges[idx]
            adj[u].add(v)
            adj[v].add(u)
        visited = set()
        queue = [0]
        visited.add(0)
        while queue:
            node = queue.pop(0)
            for nb in adj[node]:
                if nb not in visited:
                    visited.add(nb)
                    queue.append(nb)
        if len(visited) == nv:
            bases.append(frozenset(subset))
    return bases


# ======== Generate data ========

fig, axes = plt.subplots(1, 3, figsize=(16, 5))

# Panel 1: Uniform matroid leaf counts vs C(n, r-2)
ns = range(4, 13)
rs = [3, 4, 5]
colors = ['#2196F3', '#FF5722', '#4CAF50']

ax1 = axes[0]
for r, color in zip(rs, colors):
    actual_vals = []
    expected_vals = []
    valid_ns = []
    for n in ns:
        if r <= n:
            bases = uniform_bases(n, r)
            actual = count_leaves(bases, n, r)
            expected = comb(n, r - 2)
            actual_vals.append(actual)
            expected_vals.append(expected)
            valid_ns.append(n)

    ax1.plot(valid_ns, expected_vals, 'o-', color=color, label=f'r={r}', linewidth=2)
    ax1.plot(valid_ns, actual_vals, 'x', color=color, markersize=10, markeredgewidth=2)

ax1.set_xlabel('n (ground set size)', fontsize=12)
ax1.set_ylabel('Quadratic leaf count', fontsize=12)
ax1.set_title('Uniform Matroid: Leaves = C(n, r−2)', fontsize=13)
ax1.legend(fontsize=11)
ax1.set_yscale('log')
ax1.grid(True, alpha=0.3)

# Panel 2: Compression ratios for graphic matroids
ax2 = axes[1]
graph_data = []

# Complete graphs K_n
for nv in range(4, 7):
    edges = [(i,j) for i in range(nv) for j in range(i+1,nv)]
    ne = len(edges)
    rank = nv - 1
    if rank < 2:
        continue
    bases = graphic_bases(edges, nv)
    if bases:
        actual = count_leaves(bases, ne, rank)
        ambient = comb(ne, rank - 2)
        ratio = actual / ambient if ambient > 0 else 1
        graph_data.append((f'K_{nv}', ratio, 'Complete'))

# Cycle graphs C_n
for nv in range(4, 9):
    edges = [(i, (i+1)%nv) for i in range(nv)]
    ne = len(edges)
    rank = nv - 1
    if rank < 2:
        continue
    bases = graphic_bases(edges, nv)
    if bases:
        actual = count_leaves(bases, ne, rank)
        ambient = comb(ne, rank - 2)
        ratio = actual / ambient if ambient > 0 else 1
        graph_data.append((f'C_{nv}', ratio, 'Cycle'))

# Path graphs P_n
for nv in range(4, 9):
    edges = [(i, i+1) for i in range(nv-1)]
    ne = len(edges)
    rank = nv - 1
    if rank < 2:
        continue
    bases = graphic_bases(edges, nv)
    if bases:
        actual = count_leaves(bases, ne, rank)
        ambient = comb(ne, rank - 2)
        ratio = actual / ambient if ambient > 0 else 1
        graph_data.append((f'P_{nv}', ratio, 'Path'))

# Sort and plot
categories = {'Complete': '#E53935', 'Cycle': '#1E88E5', 'Path': '#43A047'}
for cat, color in categories.items():
    items = [(name, ratio) for name, ratio, c in graph_data if c == cat]
    if items:
        names, ratios = zip(*items)
        ax2.barh(list(names), list(ratios), color=color, alpha=0.8, label=cat, height=0.6)

ax2.set_xlabel('Compression ratio (actual / ambient)', fontsize=12)
ax2.set_title('Graphic Matroid Compression', fontsize=13)
ax2.legend(fontsize=11)
ax2.axvline(x=1.0, color='gray', linestyle='--', alpha=0.5)
ax2.set_xlim(0, 1.15)
ax2.grid(True, alpha=0.3, axis='x')

# Panel 3: Active variables vs compression
ax3 = axes[2]
n_total = 10
r_val = 4

# Create different matroids with varying numbers of active variables
data_points = []

# Single basis with k elements
for k in range(r_val, n_total + 1):
    single_basis = [frozenset(range(k))]
    actual = count_leaves(single_basis, n_total, r_val)
    active = len(set().union(*single_basis))
    data_points.append((active, actual))

# Multiple bases
for num_bases in range(1, 6):
    bases = []
    for start in range(num_bases):
        b = frozenset(range(start, start + r_val))
        if max(b) < n_total:
            bases.append(b)
    if bases:
        actual = count_leaves(bases, n_total, r_val)
        active = len(set().union(*bases))
        data_points.append((active, actual))

actives, actuals = zip(*sorted(set(data_points)))
ambient_val = comb(n_total, r_val - 2)

ax3.plot(actives, actuals, 'o-', color='#7B1FA2', linewidth=2, markersize=8,
         label='Actual leaves')
ax3.axhline(y=ambient_val, color='gray', linestyle='--', alpha=0.7,
            label=f'Ambient C({n_total},{r_val-2})={ambient_val}')

# Plot C(active, r-2) bound
act_range = range(r_val - 2, n_total + 1)
bounds = [comb(a, r_val - 2) for a in act_range]
ax3.plot(list(act_range), bounds, 's--', color='#FF9800', alpha=0.7,
         label=f'Bound C(active, {r_val-2})')

ax3.set_xlabel('Number of active variables', fontsize=12)
ax3.set_ylabel('Quadratic leaf count', fontsize=12)
ax3.set_title(f'Active Variables vs Leaves (n={n_total}, r={r_val})', fontsize=13)
ax3.legend(fontsize=10)
ax3.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('compression_analysis.png', dpi=150, bbox_inches='tight')
print("Saved visualization to compression_analysis.png")


"""
Visualization: Scaling Behavior of Support-Compressed Leaf Counts

This script shows how compressed leaf counts scale compared to naive
ambient counts across different matroid families, demonstrating the
practical impact of support geometry on Lorentzian certification complexity.

Requires: numpy, matplotlib
"""

import numpy as np
import matplotlib.pyplot as plt
from itertools import combinations
from math import comb, factorial


def independent_sets_of_size(bases, n, k):
    result = []
    for subset in combinations(range(n), k):
        fs = frozenset(subset)
        if any(fs <= B for B in bases):
            result.append(fs)
    return result


def count_leaves(bases, n, r):
    if r < 2:
        return 1
    return len(independent_sets_of_size(bases, n, r - 2))


def uniform_bases(n, r):
    return [frozenset(s) for s in combinations(range(n), r)]


def graphic_bases(edges, nv):
    ne = len(edges)
    rank = nv - 1
    bases = []
    for subset in combinations(range(ne), rank):
        adj = {v: set() for v in range(nv)}
        for idx in subset:
            u, v = edges[idx]
            adj[u].add(v)
            adj[v].add(u)
        visited = set()
        queue = [0]
        visited.add(0)
        while queue:
            node = queue.pop(0)
            for nb in adj[node]:
                if nb not in visited:
                    visited.add(nb)
                    queue.append(nb)
        if len(visited) == nv:
            bases.append(frozenset(subset))
    return bases


fig, axes = plt.subplots(2, 2, figsize=(14, 10))

# Panel 1: Uniform matroid - exact match with C(n, r-2)
ax1 = axes[0, 0]
for r, color, marker in [(3, '#2196F3', 'o'), (4, '#FF5722', 's'), (5, '#4CAF50', '^')]:
    ns = list(range(r, 14))
    leaves = [comb(n, r - 2) for n in ns]
    ax1.plot(ns, leaves, f'{marker}-', color=color, label=f'r = {r}', linewidth=2, markersize=6)

ax1.set_xlabel('n (ground set size)', fontsize=12)
ax1.set_ylabel('Quadratic leaf count', fontsize=12)
ax1.set_title('Uniform Matroid U_{r,n}: Leaves = C(n, r−2)', fontsize=13)
ax1.legend(fontsize=11)
ax1.set_yscale('log')
ax1.grid(True, alpha=0.3)

# Panel 2: Single basis compression
ax2 = axes[0, 1]
n_val = 12
for r, color in [(4, '#2196F3'), (5, '#FF5722'), (6, '#4CAF50')]:
    basis_sizes = list(range(r, n_val + 1))
    leaf_counts = [comb(k, r - 2) for k in basis_sizes]
    ambient = comb(n_val, r - 2)
    ax2.plot(basis_sizes, leaf_counts, 'o-', color=color, linewidth=2,
             label=f'r={r}, ambient={ambient}')
    ax2.axhline(y=ambient, color=color, linestyle='--', alpha=0.3)

ax2.set_xlabel('Basis size (|B|)', fontsize=12)
ax2.set_ylabel('Leaf count C(|B|, r−2)', fontsize=12)
ax2.set_title(f'Single-Basis Compression (n={n_val})', fontsize=13)
ax2.legend(fontsize=10)
ax2.grid(True, alpha=0.3)

# Panel 3: Graphic matroid compression for complete graphs
ax3 = axes[1, 0]
complete_data = []
for nv in range(4, 7):
    edges = [(i,j) for i in range(nv) for j in range(i+1,nv)]
    ne = len(edges)
    rank = nv - 1
    if rank < 2:
        continue
    bases = graphic_bases(edges, nv)
    if bases:
        actual = count_leaves(bases, ne, rank)
        ambient = comb(ne, rank - 2)
        complete_data.append((nv, ne, actual, ambient))

if complete_data:
    nvs = [d[0] for d in complete_data]
    actuals = [d[2] for d in complete_data]
    ambients = [d[3] for d in complete_data]

    x_pos = np.arange(len(nvs))
    width = 0.35

    bars1 = ax3.bar(x_pos - width/2, actuals, width, label='Actual leaves',
                    color='#4CAF50', alpha=0.8)
    bars2 = ax3.bar(x_pos + width/2, ambients, width, label='Ambient C(|E|, r−2)',
                    color='#FF9800', alpha=0.8)

    ax3.set_xlabel('Graph', fontsize=12)
    ax3.set_ylabel('Leaf count', fontsize=12)
    ax3.set_title('Complete Graph Compression', fontsize=13)
    ax3.set_xticks(x_pos)
    ax3.set_xticklabels([f'K_{nv}' for nv in nvs])
    ax3.legend(fontsize=11)
    ax3.grid(True, alpha=0.3, axis='y')

    # Add ratio labels
    for i, (a, b) in enumerate(zip(actuals, ambients)):
        ratio = a / b if b > 0 else 1
        ax3.text(i, max(a, b) + 2, f'{ratio:.3f}', ha='center',
                 fontsize=10, fontweight='bold')

# Panel 4: Theoretical bounds comparison
ax4 = axes[1, 1]
ns_theory = np.arange(5, 20)
r_theory = 4

ambient_bounds = [comb(int(n), r_theory - 2) for n in ns_theory]
# For a matroid with k active variables
for k_frac, color, label in [
    (1.0, '#9E9E9E', 'Ambient C(n, r−2)'),
    (0.7, '#FF9800', 'C(0.7n, r−2)'),
    (0.5, '#2196F3', 'C(0.5n, r−2)'),
    (0.3, '#4CAF50', 'C(0.3n, r−2)'),
]:
    vals = [comb(max(r_theory - 2, int(n * k_frac)), r_theory - 2) for n in ns_theory]
    ax4.plot(ns_theory, vals, '-', color=color, linewidth=2, label=label)

ax4.set_xlabel('n (ground set size)', fontsize=12)
ax4.set_ylabel('Leaf count bound', fontsize=12)
ax4.set_title(f'Compression by Active Variable Fraction (r={r_theory})', fontsize=13)
ax4.legend(fontsize=10)
ax4.set_yscale('log')
ax4.grid(True, alpha=0.3)

plt.suptitle('Support-Compressed Leaf Counting: Scaling Analysis', fontsize=15, y=1.02)
plt.tight_layout()
plt.savefig('scaling_analysis.png', dpi=150, bbox_inches='tight')
print("Saved visualization to scaling_analysis.png")


"""
Visualization: Derivative Recursion Tree Pruning

This script visualizes how the derivative recursion tree for Lorentzian
recognition gets pruned when the polynomial has matroid basis support.
Surviving branches (independent sets) are highlighted; pruned branches
(non-independent sets) are shown as dead ends.

Requires: numpy, matplotlib
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.patches as patches
from itertools import combinations
from math import comb


def graphic_bases(edges, nv):
    ne = len(edges)
    rank = nv - 1
    bases = []
    for subset in combinations(range(ne), rank):
        adj = {v: set() for v in range(nv)}
        for idx in subset:
            u, v = edges[idx]
            adj[u].add(v)
            adj[v].add(u)
        visited = set()
        queue = [0]
        visited.add(0)
        while queue:
            node = queue.pop(0)
            for nb in adj[node]:
                if nb not in visited:
                    visited.add(nb)
                    queue.append(nb)
        if len(visited) == nv:
            bases.append(frozenset(subset))
    return bases


fig, axes = plt.subplots(1, 2, figsize=(14, 7))

# Left panel: Schematic of derivative tree for K_4 graphic matroid
ax1 = axes[0]
ax1.set_xlim(-1, 7)
ax1.set_ylim(-0.5, 4.5)
ax1.set_aspect('equal')
ax1.axis('off')
ax1.set_title('Derivative Tree: K₄ Graphic Matroid\n(6 edges, rank 3)', fontsize=13)

# K_4 has edges e0,...,e5, rank 3, so we look at (3-2)=1-subsets
# All 1-subsets {e_i} are independent (contained in some spanning tree)
# So all 6 leaves survive

# Draw root
ax1.add_patch(plt.Circle((3, 4), 0.3, color='#1565C0', zorder=5))
ax1.text(3, 4, 'B(x)', ha='center', va='center', color='white', fontsize=9, fontweight='bold')

# Draw level 1: differentiate by each variable
positions = [(0.5, 2), (1.5, 2), (2.5, 2), (3.5, 2), (4.5, 2), (5.5, 2)]
edge_labels = ['e₀', 'e₁', 'e₂', 'e₃', 'e₄', 'e₅']

for i, (x, y) in enumerate(positions):
    # All survive for K_4
    color = '#4CAF50'  # green = surviving
    ax1.plot([3, x], [3.7, y + 0.3], '-', color=color, linewidth=2, alpha=0.7)
    ax1.add_patch(plt.Circle((x, y), 0.3, color=color, zorder=5))
    ax1.text(x, y, f'∂{edge_labels[i]}', ha='center', va='center',
             color='white', fontsize=8, fontweight='bold')
    ax1.text(x, y - 0.6, '✓ indep', ha='center', va='center',
             color=color, fontsize=8)

ax1.text(3, -0.2, 'All 6 leaves survive (ratio = 1.0)',
         ha='center', fontsize=11, style='italic')

# Right panel: A sparse graph where pruning occurs
ax2 = axes[1]
ax2.set_xlim(-1, 9)
ax2.set_ylim(-1, 5)
ax2.set_aspect('equal')
ax2.axis('off')
ax2.set_title('Derivative Tree: Path + Extra Edge\n(5 edges, rank 3)', fontsize=13)

# Graph: path 0-1-2-3 plus edge 1-3
# Edges: e0=(0,1), e1=(1,2), e2=(2,3), e3=(1,3)
# Total: 5 edges (add e4=(0,3))
# Actually let's use: 0-1, 1-2, 2-3, 0-2 (4 edges, rank 3)
# Spanning trees: {0,1,2}, {0,1,3}, {0,2,3}, {1,2,3} -> need to check
# Wait, with 4 vertices and edges (0,1),(1,2),(2,3),(0,2):
# rank = 3, need 3-edge spanning trees from 4 edges
# So leaves = 1-subsets of {0,1,2,3} that are independent
# All 1-subsets are independent (each edge is in some spanning tree)

# Let me use a better example: 5 vertices, specific edges
# K_4 minus an edge: 5 edges on 4 vertices
# edges: (0,1),(0,2),(0,3),(1,2),(1,3)  -- missing (2,3)
# rank = 3, spanning trees from 5 edges choosing 3
edges = [(0,1),(0,2),(0,3),(1,2),(1,3)]
nv = 4
bases = graphic_bases(edges, nv)

# r-2 = 1, so look at 1-subsets
# All {e_i} are independent
# Actually for r-2=1, it's trivial. Let me try rank 4

# Better: use 5 vertices, 7 edges, rank 4
# So r-2 = 2, look at 2-subsets
edges2 = [(0,1),(1,2),(2,3),(3,4),(0,4),(0,2),(2,4)]
nv2 = 5
bases2 = graphic_bases(edges2, nv2)
ne2 = len(edges2)
rank2 = nv2 - 1  # 4

# Count 2-subsets that are independent
all_pairs = list(combinations(range(ne2), 2))
independent_pairs = [frozenset(p) for p in all_pairs if any(frozenset(p) <= B for B in bases2)]
non_independent_pairs = [frozenset(p) for p in all_pairs if not any(frozenset(p) <= B for B in bases2)]

# Draw root
ax2.add_patch(plt.Circle((4, 4.2), 0.3, color='#1565C0', zorder=5))
ax2.text(4, 4.2, 'B(x)', ha='center', va='center', color='white', fontsize=9, fontweight='bold')

# Show some surviving and pruned leaves
n_show = min(10, len(all_pairs))
y_pos = 1.5
survived = 0
pruned = 0

for i, pair in enumerate(all_pairs[:15]):
    fs = frozenset(pair)
    is_indep = any(fs <= B for B in bases2)
    x = 0.5 + i * 0.55

    if x > 8.5:
        break

    if is_indep:
        color = '#4CAF50'
        survived += 1
        label = '✓'
    else:
        color = '#E53935'
        pruned += 1
        label = '✗'

    ax2.plot([4, x], [3.9, y_pos + 0.25], '-', color=color, linewidth=1, alpha=0.4)
    ax2.add_patch(plt.Circle((x, y_pos), 0.2, color=color, zorder=5, alpha=0.8))
    e1, e2 = sorted(pair)
    ax2.text(x, y_pos, label, ha='center', va='center', color='white',
             fontsize=7, fontweight='bold')
    ax2.text(x, y_pos - 0.45, f'{e1},{e2}', ha='center', fontsize=6, color='gray')

total_pairs = len(all_pairs)
total_indep = len(independent_pairs)
total_pruned = len(non_independent_pairs)

ax2.text(4, -0.5,
         f'{total_indep} survive / {total_pairs} total '
         f'(ratio = {total_indep/total_pairs:.3f})',
         ha='center', fontsize=11, style='italic')

# Legend
legend_elements = [
    patches.Patch(facecolor='#4CAF50', label=f'Surviving ({total_indep})'),
    patches.Patch(facecolor='#E53935', label=f'Pruned ({total_pruned})'),
]
ax2.legend(handles=legend_elements, loc='upper right', fontsize=10)

plt.tight_layout()
plt.savefig('derivative_tree_pruning.png', dpi=150, bbox_inches='tight')
print("Saved visualization to derivative_tree_pruning.png")
