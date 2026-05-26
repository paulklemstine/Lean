#!/usr/bin/env python3
"""
Applications of Support-Compressed Leaf Counting.

Shows how the support compression principle applies to:
1. Lorentzian polynomial certification cost estimation
2. Network reliability polynomial analysis
3. Partition function complexity for combinatorial ensembles
"""

from itertools import combinations
from math import comb, factorial, log2
from typing import Set, FrozenSet, List, Tuple


def uniform_matroid_bases(n, r):
    return {frozenset(B) for B in combinations(range(n), r)}


def graphic_matroid_bases(n_vertices, edges):
    def is_acyclic(edge_indices):
        parent = list(range(n_vertices))
        def find(x):
            while parent[x] != x:
                parent[x] = parent[parent[x]]
                x = parent[x]
            return x
        def union(x, y):
            rx, ry = find(x), find(y)
            if rx == ry: return False
            parent[rx] = ry
            return True
        for idx in edge_indices:
            u, v = edges[idx]
            if not union(u, v): return False
        return True

    def count_components(edge_indices):
        parent = list(range(n_vertices))
        def find(x):
            while parent[x] != x:
                parent[x] = parent[parent[x]]
                x = parent[x]
            return x
        def union(x, y):
            rx, ry = find(x), find(y)
            if rx != ry: parent[rx] = ry
        for idx in edge_indices:
            u, v = edges[idx]
            union(u, v)
        return len({find(i) for i in range(n_vertices)})

    m = len(edges)
    full_components = count_components(list(range(m)))
    rank = n_vertices - full_components
    bases = set()
    for subset in combinations(range(m), rank):
        if is_acyclic(list(subset)):
            bases.add(frozenset(subset))
    return bases, rank


def support_compressed_leaf_count(bases, n, k):
    count = 0
    for subset in combinations(range(n), k):
        fs = frozenset(subset)
        for B in bases:
            if fs <= B:
                count += 1
                break
    return count


def active_variable_set(bases):
    result = set()
    for B in bases:
        result |= B
    return result


# ===== APPLICATION 1: CERTIFICATION COST ESTIMATION =====

def certification_cost_analysis(name, bases, n, r):
    """Analyze the Lorentzian certification cost for a matroid polynomial.

    The Lorentzian recognition algorithm recursively differentiates and checks
    positive semidefiniteness of Hessians. The number of quadratic leaves
    (degree-2 derivatives to check) determines the certification cost.
    """
    k = r - 2
    if k < 0:
        return

    ambient = comb(n, k)
    compressed = support_compressed_leaf_count(bases, n, k)
    active = active_variable_set(bases)
    active_bound = comb(len(active), k)

    # Each quadratic leaf requires O(n^2) work for Hessian PSD check
    naive_work = ambient * n * n
    compressed_work = compressed * n * n

    print(f"\n  {name}:")
    print(f"    Parameters: n={n}, r={r}, k=r-2={k}")
    print(f"    Naive certification cost:      {ambient} leaves × O(n²) = O({naive_work})")
    print(f"    Compressed certification cost:  {compressed} leaves × O(n²) = O({compressed_work})")
    print(f"    Active variable bound:          {active_bound} leaves")
    if ambient > 0:
        savings_pct = 100 * (1 - compressed / ambient)
        print(f"    Work reduction:                 {savings_pct:.1f}%")
    if compressed > 0:
        print(f"    Bits to certify:                {log2(compressed):.1f} (vs {log2(ambient):.1f} ambient)")


def app_certification():
    """Application 1: Certification cost for various matroid families."""
    print("=" * 70)
    print("APPLICATION 1: Lorentzian Certification Cost")
    print("=" * 70)

    # Uniform matroid
    certification_cost_analysis(
        "Uniform U_{4,8}",
        uniform_matroid_bases(8, 4), 8, 4
    )

    # Path graph
    edges = [(i, i+1) for i in range(7)]
    bases, rank = graphic_matroid_bases(8, edges)
    certification_cost_analysis(
        "Path P_8 (graphic)",
        bases, len(edges), rank
    )

    # Cycle graph
    n_v = 8
    edges = [(i, (i+1) % n_v) for i in range(n_v)]
    bases, rank = graphic_matroid_bases(n_v, edges)
    certification_cost_analysis(
        f"Cycle C_{n_v} (graphic)",
        bases, len(edges), rank
    )

    # Complete graph K_5
    n_v = 5
    edges = [(i, j) for i in range(n_v) for j in range(i+1, n_v)]
    bases, rank = graphic_matroid_bases(n_v, edges)
    certification_cost_analysis(
        f"Complete K_{n_v} (graphic)",
        bases, len(edges), rank
    )
    print()


# ===== APPLICATION 2: NETWORK RELIABILITY =====

def app_network_reliability():
    """Application 2: Network reliability polynomial complexity.

    The all-terminal reliability polynomial of a graph G counts spanning
    trees weighted by edge probabilities. Its basis generating polynomial
    is exactly the graphic matroid basis polynomial. Support compression
    determines the cost of certifying strong log-concavity of the
    reliability polynomial.
    """
    print("=" * 70)
    print("APPLICATION 2: Network Reliability Polynomial Complexity")
    print("=" * 70)

    networks = [
        ("Linear network (path)", 6, [(i, i+1) for i in range(5)]),
        ("Ring network (cycle)", 6, [(i, (i+1) % 6) for i in range(6)]),
        ("Star topology", 5, [(0, i) for i in range(1, 5)]),
        ("Grid 2×3", 6, [(0,1),(1,2),(3,4),(4,5),(0,3),(1,4),(2,5)]),
    ]

    for name, nv, edges in networks:
        bases, rank = graphic_matroid_bases(nv, edges)
        m = len(edges)
        k = rank - 2
        if k < 0:
            continue

        ambient = comb(m, k)
        compressed = support_compressed_leaf_count(bases, m, k)

        print(f"\n  {name} (V={nv}, E={m}):")
        print(f"    Matroid rank: {rank}")
        print(f"    Number of spanning trees: {len(bases)}")
        print(f"    Certification leaves (ambient):    {ambient}")
        print(f"    Certification leaves (compressed): {compressed}")
        if ambient > 0:
            print(f"    Compression ratio: {compressed/ambient:.4f}")
    print()


# ===== APPLICATION 3: PARTITION FUNCTION COMPLEXITY =====

def app_partition_function():
    """Application 3: Partition function certification.

    In statistical physics, the partition function of a hard-core model
    on a matroid is related to the basis generating polynomial. Support
    compression quantifies the cost of certifying thermodynamic properties
    like log-concavity of the partition function coefficients.
    """
    print("=" * 70)
    print("APPLICATION 3: Partition Function Certification Complexity")
    print("=" * 70)

    print("\n  Comparison across matroid families with similar parameters:")
    print(f"\n  {'Family':<30} {'n':>4} {'r':>4} {'|bases|':>8} {'ambient':>8} {'compressed':>10} {'ratio':>8}")
    print("  " + "-" * 78)

    # Uniform U_{3,6}
    bases = uniform_matroid_bases(6, 3)
    amb = comb(6, 1)
    comp = support_compressed_leaf_count(bases, 6, 1)
    print(f"  {'Uniform U_{3,6}':<30} {6:>4} {3:>4} {len(bases):>8} {amb:>8} {comp:>10} {comp/amb:>8.4f}")

    # Path P_7 (6 edges)
    edges = [(i, i+1) for i in range(6)]
    bases, r = graphic_matroid_bases(7, edges)
    m = len(edges)
    k = r - 2
    amb = comb(m, k)
    comp = support_compressed_leaf_count(bases, m, k)
    print(f"  {'Graphic (Path P_7)':<30} {m:>4} {r:>4} {len(bases):>8} {amb:>8} {comp:>10} {comp/amb:>8.4f}")

    # Cycle C_6
    edges = [(i, (i+1) % 6) for i in range(6)]
    bases, r = graphic_matroid_bases(6, edges)
    m = len(edges)
    k = r - 2
    amb = comb(m, k)
    comp = support_compressed_leaf_count(bases, m, k)
    print(f"  {'Graphic (Cycle C_6)':<30} {m:>4} {r:>4} {len(bases):>8} {amb:>8} {comp:>10} {comp/amb:>8.4f}")

    print()


if __name__ == "__main__":
    print()
    print("╔══════════════════════════════════════════════════════════════════════╗")
    print("║  APPLICATIONS OF SUPPORT-COMPRESSED LEAF COUNTING                 ║")
    print("╚══════════════════════════════════════════════════════════════════════╝")
    print()
    app_certification()
    app_network_reliability()
    app_partition_function()
    print("All applications completed.")


#!/usr/bin/env python3
"""
Demo: Support-Compressed Leaf Counting for Matroid Basis Polynomials.

Interactively computes and compares naive ambient leaf counts vs.
support-compressed leaf counts for various matroid families, verifying
the theorems from the formal development.

Demonstrates:
1. Uniform matroid: leaf count = C(n, r-2) (Theorem 3)
2. Graphic matroids: leaf count = number of independent (r-2)-sets
3. Compression ratios showing support geometry beats ambient counting
4. Active variable bound (Theorem 4)
"""

from itertools import combinations
from math import comb
from collections import defaultdict
import time


# ===== SELF-CONTAINED IMPLEMENTATIONS =====

def uniform_matroid_bases(n, r):
    """All r-element subsets of {0,...,n-1}."""
    return {frozenset(B) for B in combinations(range(n), r)}


def graphic_matroid_bases(n_vertices, edges):
    """Spanning forests of a graph."""
    def is_acyclic(edge_indices):
        parent = list(range(n_vertices))
        def find(x):
            while parent[x] != x:
                parent[x] = parent[parent[x]]
                x = parent[x]
            return x
        def union(x, y):
            rx, ry = find(x), find(y)
            if rx == ry:
                return False
            parent[rx] = ry
            return True
        for idx in edge_indices:
            u, v = edges[idx]
            if not union(u, v):
                return False
        return True

    def count_components(edge_indices):
        parent = list(range(n_vertices))
        def find(x):
            while parent[x] != x:
                parent[x] = parent[parent[x]]
                x = parent[x]
            return x
        def union(x, y):
            rx, ry = find(x), find(y)
            if rx != ry:
                parent[rx] = ry
        for idx in edge_indices:
            u, v = edges[idx]
            union(u, v)
        return len({find(i) for i in range(n_vertices)})

    m = len(edges)
    full_components = count_components(list(range(m)))
    rank = n_vertices - full_components
    bases = set()
    for subset in combinations(range(m), rank):
        if is_acyclic(list(subset)):
            bases.add(frozenset(subset))
    return bases, rank


def support_compressed_leaf_count(bases, n, k):
    """Count k-element subsets contained in some basis."""
    count = 0
    for subset in combinations(range(n), k):
        fs = frozenset(subset)
        for B in bases:
            if fs <= B:
                count += 1
                break
    return count


def active_variable_set(bases):
    result = set()
    for B in bases:
        result |= B
    return result


def transversal_matroid_bases(n, sets):
    """Bases of transversal matroid via SDR enumeration."""
    m = len(sets)
    def find_sdrs(idx, used, current):
        if idx == m:
            return [frozenset(current)]
        results = []
        for elem in sets[idx]:
            if elem not in used:
                used.add(elem)
                current.append(elem)
                results.extend(find_sdrs(idx + 1, used, current))
                current.pop()
                used.remove(elem)
        results.extend(find_sdrs(idx + 1, used, current))
        return results
    all_sdrs = find_sdrs(0, set(), [])
    if not all_sdrs:
        return set(), 0
    max_size = max(len(s) for s in all_sdrs)
    return {s for s in all_sdrs if len(s) == max_size}, max_size


# ===== DEMO FUNCTIONS =====

def demo_uniform_matroid():
    """Verify Theorem 3: leaf count for U_{r,n} = C(n, r-2)."""
    print("=" * 70)
    print("THEOREM 3: Uniform Matroid Closed Form")
    print("  For U_{r,n}, #nonzero quadratic leaves = C(n, r-2)")
    print("=" * 70)
    print()
    print(f"{'n':>4} {'r':>4} {'C(n,r-2)':>10} {'Computed':>10} {'Match':>6}")
    print("-" * 40)

    for n in range(4, 10):
        for r in range(2, n + 1):
            expected = comb(n, r - 2)
            bases = uniform_matroid_bases(n, r)
            actual = support_compressed_leaf_count(bases, n, r - 2)
            match = "✓" if actual == expected else "✗"
            print(f"{n:>4} {r:>4} {expected:>10} {actual:>10} {match:>6}")

    print()


def demo_graphic_matroid():
    """Demonstrate leaf counting for graphic matroids."""
    print("=" * 70)
    print("GRAPHIC MATROIDS: Leaf Count = Independent (r-2)-sets")
    print("=" * 70)
    print()

    examples = [
        ("Path P_4", 4, [(0, 1), (1, 2), (2, 3)]),
        ("Cycle C_4", 4, [(0, 1), (1, 2), (2, 3), (3, 0)]),
        ("Complete K_4", 4, [(0, 1), (0, 2), (0, 3), (1, 2), (1, 3), (2, 3)]),
        ("Star S_4", 5, [(0, 1), (0, 2), (0, 3), (0, 4)]),
        ("Petersen-like", 5, [(0,1),(0,2),(0,3),(1,2),(1,4),(2,3),(3,4)]),
    ]

    for name, nv, edges in examples:
        bases, rank = graphic_matroid_bases(nv, edges)
        m = len(edges)
        k = rank - 2
        if k < 0:
            continue
        actual = support_compressed_leaf_count(bases, m, k)
        ambient = comb(m, k)
        active = active_variable_set(bases)
        active_bound = comb(len(active), k)
        ratio = actual / ambient if ambient > 0 else 0

        print(f"  {name}:")
        print(f"    Vertices={nv}, Edges={m}, Rank={rank}")
        print(f"    k = r-2 = {k}")
        print(f"    Ambient leaf count C({m},{k}) = {ambient}")
        print(f"    Compressed leaf count      = {actual}")
        print(f"    Active variable bound      = {active_bound}")
        print(f"    Compression ratio          = {ratio:.4f}")
        print()


def demo_compression_ratios():
    """Show how compression ratios vary across matroid families."""
    print("=" * 70)
    print("COMPRESSION RATIOS: Support Geometry vs. Ambient Counting")
    print("=" * 70)
    print()

    # Cycle graphs C_n
    print("Cycle Graphs C_n (graphic matroid):")
    print(f"{'n':>6} {'edges':>6} {'rank':>6} {'k':>4} {'ambient':>10} {'compressed':>10} {'ratio':>10}")
    print("-" * 60)
    for nv in range(4, 12):
        edges = [(i, (i + 1) % nv) for i in range(nv)]
        bases, rank = graphic_matroid_bases(nv, edges)
        m = len(edges)
        k = rank - 2
        if k < 0:
            continue
        actual = support_compressed_leaf_count(bases, m, k)
        ambient = comb(m, k)
        ratio = actual / ambient if ambient > 0 else 0
        print(f"{nv:>6} {m:>6} {rank:>6} {k:>4} {ambient:>10} {actual:>10} {ratio:>10.4f}")
    print()

    # Complete graphs K_n
    print("Complete Graphs K_n (graphic matroid):")
    print(f"{'n':>6} {'edges':>6} {'rank':>6} {'k':>4} {'ambient':>10} {'compressed':>10} {'ratio':>10}")
    print("-" * 60)
    for nv in range(3, 8):
        edges = [(i, j) for i in range(nv) for j in range(i + 1, nv)]
        bases, rank = graphic_matroid_bases(nv, edges)
        m = len(edges)
        k = rank - 2
        if k < 0:
            continue
        actual = support_compressed_leaf_count(bases, m, k)
        ambient = comb(m, k)
        ratio = actual / ambient if ambient > 0 else 0
        print(f"{nv:>6} {m:>6} {rank:>6} {k:>4} {ambient:>10} {actual:>10} {ratio:>10.4f}")
    print()


def demo_transversal_matroid():
    """Demonstrate leaf counting for transversal matroids."""
    print("=" * 70)
    print("TRANSVERSAL MATROIDS")
    print("=" * 70)
    print()

    # Example: bipartite graph with partial matchings
    sets = [{0, 1, 2}, {1, 2, 3}, {2, 3, 4}]
    n = 5
    bases, rank = transversal_matroid_bases(n, sets)
    k = rank - 2
    if k >= 0:
        actual = support_compressed_leaf_count(bases, n, k)
        ambient = comb(n, k)
        print(f"  Sets: {sets}")
        print(f"  Ground set size: {n}, Rank: {rank}")
        print(f"  Number of bases: {len(bases)}")
        print(f"  k = r-2 = {k}")
        print(f"  Ambient count C({n},{k}) = {ambient}")
        print(f"  Compressed count = {actual}")
        print(f"  Compression ratio = {actual / ambient:.4f}" if ambient > 0 else "")
    print()

    # Sparse transversal
    sets2 = [{0, 1}, {2, 3}, {4, 5}, {6, 7}]
    n2 = 8
    bases2, rank2 = transversal_matroid_bases(n2, sets2)
    k2 = rank2 - 2
    if k2 >= 0:
        actual2 = support_compressed_leaf_count(bases2, n2, k2)
        ambient2 = comb(n2, k2)
        active2 = active_variable_set(bases2)
        active_bound2 = comb(len(active2), k2)
        print(f"  Sets: {sets2}")
        print(f"  Ground set size: {n2}, Rank: {rank2}")
        print(f"  Number of bases: {len(bases2)}")
        print(f"  k = r-2 = {k2}")
        print(f"  Ambient count C({n2},{k2}) = {ambient2}")
        print(f"  Active variable bound C({len(active2)},{k2}) = {active_bound2}")
        print(f"  Compressed count = {actual2}")
        print(f"  Compression ratio = {actual2 / ambient2:.4f}" if ambient2 > 0 else "")
    print()


def demo_active_variable_bound():
    """Verify Theorem 4: compressed count ≤ C(|active vars|, k)."""
    print("=" * 70)
    print("THEOREM 4: Active Variable Bound")
    print("  compressed_count ≤ C(|active_vars|, k)")
    print("=" * 70)
    print()

    # Create sparse bases: only some variables are active
    n = 10
    # Bases that only use variables {0,1,2,3,4}
    bases = {frozenset({0, 1, 2}), frozenset({1, 2, 3}), frozenset({2, 3, 4})}
    r = 3
    k = r - 2

    active = active_variable_set(bases)
    ambient = comb(n, k)
    active_bound = comb(len(active), k)
    compressed = support_compressed_leaf_count(bases, n, k)

    print(f"  n = {n}, r = {r}, k = {k}")
    print(f"  Bases: {[set(B) for B in bases]}")
    print(f"  Active variables: {active} (count = {len(active)})")
    print(f"  Ambient count C({n},{k})           = {ambient}")
    print(f"  Active bound C({len(active)},{k})          = {active_bound}")
    print(f"  Compressed count                = {compressed}")
    print(f"  compressed ≤ active_bound?      {compressed <= active_bound} ✓")
    print(f"  Savings: {ambient - compressed} branches eliminated ({100*(1-compressed/ambient):.1f}% reduction)")
    print()


def demo_timing():
    """Compare timings for compressed vs. naive approaches."""
    print("=" * 70)
    print("TIMING COMPARISON")
    print("=" * 70)
    print()

    for n in [8, 10, 12]:
        r = n // 2
        k = r - 2
        if k < 0:
            continue

        bases = uniform_matroid_bases(n, r)

        t0 = time.time()
        compressed = support_compressed_leaf_count(bases, n, k)
        t_compressed = time.time() - t0

        t0 = time.time()
        ambient = comb(n, k)
        t_ambient = time.time() - t0

        print(f"  U_{{{r},{n}}}:  k={k}")
        print(f"    Ambient C({n},{k}) = {ambient}  (time: {t_ambient*1000:.3f} ms)")
        print(f"    Compressed   = {compressed}  (time: {t_compressed*1000:.1f} ms)")
        print()


if __name__ == "__main__":
    print()
    print("╔══════════════════════════════════════════════════════════════════════╗")
    print("║  SUPPORT-COMPRESSED LEAF COUNTING FOR MATROID BASIS POLYNOMIALS    ║")
    print("║  Demonstrating the theorems from the formal development            ║")
    print("╚══════════════════════════════════════════════════════════════════════╝")
    print()

    demo_uniform_matroid()
    demo_graphic_matroid()
    demo_compression_ratios()
    demo_transversal_matroid()
    demo_active_variable_bound()
    demo_timing()

    print("All demos completed successfully.")


"""
Visualization: Compression Ratio Heatmap for Uniform Matroids.

Shows how the ratio compressed_count / ambient_count varies as a function
of n (ground set size) and r (rank) for uniform matroids U_{r,n}.
For uniform matroids the ratio is always 1 (every subset extends to a basis),
but we compare with graphic matroids (cycle graphs) to show compression.

This heatmap visualizes the core insight: support geometry compresses
the Lorentzian certification tree for sparse matroids.
"""

import numpy as np
import matplotlib.pyplot as plt
from math import comb
from itertools import combinations


def graphic_matroid_bases_cycle(nv):
    """Bases of the graphic matroid of the cycle graph C_nv."""
    edges = [(i, (i + 1) % nv) for i in range(nv)]
    m = len(edges)

    def is_acyclic(edge_indices):
        parent = list(range(nv))
        def find(x):
            while parent[x] != x:
                parent[x] = parent[parent[x]]
                x = parent[x]
            return x
        def union(x, y):
            rx, ry = find(x), find(y)
            if rx == ry: return False
            parent[rx] = ry
            return True
        for idx in edge_indices:
            u, v = edges[idx]
            if not union(u, v): return False
        return True

    rank = nv - 1
    bases = set()
    for subset in combinations(range(m), rank):
        if is_acyclic(list(subset)):
            bases.add(frozenset(subset))
    return bases, rank, m


def support_compressed_leaf_count(bases, n, k):
    count = 0
    for subset in combinations(range(n), k):
        fs = frozenset(subset)
        for B in bases:
            if fs <= B:
                count += 1
                break
    return count


# --- Complete graph graphic matroids ---
def graphic_matroid_bases_complete(nv):
    edges = [(i, j) for i in range(nv) for j in range(i + 1, nv)]
    m = len(edges)

    def is_acyclic(edge_indices):
        parent = list(range(nv))
        def find(x):
            while parent[x] != x:
                parent[x] = parent[parent[x]]
                x = parent[x]
            return x
        def union(x, y):
            rx, ry = find(x), find(y)
            if rx == ry: return False
            parent[rx] = ry
            return True
        for idx in edge_indices:
            u, v = edges[idx]
            if not union(u, v): return False
        return True

    rank = nv - 1
    bases = set()
    for subset in combinations(range(m), rank):
        if is_acyclic(list(subset)):
            bases.add(frozenset(subset))
    return bases, rank, m


# Build data for heatmap: complete graphs K_3 through K_8
fig, axes = plt.subplots(1, 2, figsize=(14, 5))

# Left: Uniform matroid ratios (always 1.0)
ns = list(range(3, 10))
data_uniform = []
for n in ns:
    row = []
    for r in range(2, n + 1):
        k = r - 2
        ratio = 1.0  # For uniform matroids, all subsets extend
        row.append(ratio)
    # Pad with NaN for alignment
    while len(row) < max(ns) - 1:
        row.append(np.nan)
    data_uniform.append(row)

ax = axes[0]
data_arr = np.array(data_uniform)
im = ax.imshow(data_arr, cmap='RdYlGn', vmin=0, vmax=1, aspect='auto')
ax.set_xlabel('Rank r (starting from 2)')
ax.set_ylabel('Ground set size n')
ax.set_yticks(range(len(ns)))
ax.set_yticklabels(ns)
ax.set_xticks(range(data_arr.shape[1]))
ax.set_xticklabels(range(2, 2 + data_arr.shape[1]))
ax.set_title('Uniform Matroid: Compression Ratio\n(always 1.0 — no compression)')
for i in range(data_arr.shape[0]):
    for j in range(data_arr.shape[1]):
        if not np.isnan(data_arr[i, j]):
            ax.text(j, i, f'{data_arr[i,j]:.2f}', ha='center', va='center', fontsize=7)

# Right: Complete graph graphic matroid ratios
data_graphic = []
graph_ns = list(range(3, 8))
for nv in graph_ns:
    bases, rank, m = graphic_matroid_bases_complete(nv)
    row = []
    for k in range(0, rank - 1):
        amb = comb(m, k)
        if amb == 0:
            row.append(np.nan)
        else:
            comp = support_compressed_leaf_count(bases, m, k)
            row.append(comp / amb)
    while len(row) < 6:
        row.append(np.nan)
    data_graphic.append(row)

ax = axes[1]
data_arr2 = np.array(data_graphic)
im2 = ax.imshow(data_arr2, cmap='RdYlGn', vmin=0, vmax=1, aspect='auto')
ax.set_xlabel('Derivative depth k')
ax.set_ylabel('Complete graph K_n')
ax.set_yticks(range(len(graph_ns)))
ax.set_yticklabels([f'K_{nv}' for nv in graph_ns])
ax.set_xticks(range(data_arr2.shape[1]))
ax.set_xticklabels(range(data_arr2.shape[1]))
ax.set_title('Graphic Matroid (K_n): Compression Ratio\n(< 1 shows support compression)')
for i in range(data_arr2.shape[0]):
    for j in range(data_arr2.shape[1]):
        if not np.isnan(data_arr2[i, j]):
            ax.text(j, i, f'{data_arr2[i,j]:.2f}', ha='center', va='center', fontsize=7)

fig.colorbar(im2, ax=axes, shrink=0.8, label='Compression Ratio (actual / ambient)')
plt.suptitle('Support Compression in Lorentzian Recognition Trees', fontsize=14, fontweight='bold')
plt.tight_layout()
plt.savefig('viz_compression_heatmap.png', dpi=150, bbox_inches='tight')
print("Saved viz_compression_heatmap.png")


"""
Visualization: Leaf Count Growth Curves.

Compares the growth of nonzero quadratic leaf counts across matroid families
as the ground set size increases, showing how support geometry constrains
growth relative to the ambient worst case.

This plot demonstrates the fundamental compression principle: for sparse
matroids, the leaf count grows much slower than the ambient C(n, r-2).
"""

import numpy as np
import matplotlib.pyplot as plt
from math import comb
from itertools import combinations


def graphic_matroid_bases(n_vertices, edges):
    """Spanning forests (bases of graphic matroid)."""
    m = len(edges)
    def is_acyclic(edge_indices):
        parent = list(range(n_vertices))
        def find(x):
            while parent[x] != x:
                parent[x] = parent[parent[x]]
                x = parent[x]
            return x
        def union(x, y):
            rx, ry = find(x), find(y)
            if rx == ry: return False
            parent[rx] = ry
            return True
        for idx in edge_indices:
            u, v = edges[idx]
            if not union(u, v): return False
        return True

    def count_components(edge_indices):
        parent = list(range(n_vertices))
        def find(x):
            while parent[x] != x:
                parent[x] = parent[parent[x]]
                x = parent[x]
            return x
        def union(x, y):
            rx, ry = find(x), find(y)
            if rx != ry: parent[rx] = ry
        for idx in edge_indices:
            u, v = edges[idx]
            union(u, v)
        return len({find(i) for i in range(n_vertices)})

    full_comp = count_components(list(range(m)))
    rank = n_vertices - full_comp
    bases = set()
    for subset in combinations(range(m), rank):
        if is_acyclic(list(subset)):
            bases.add(frozenset(subset))
    return bases, rank


def support_compressed_leaf_count(bases, n, k):
    count = 0
    for subset in combinations(range(n), k):
        fs = frozenset(subset)
        for B in bases:
            if fs <= B:
                count += 1
                break
    return count


fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

# --- Left plot: Cycle graphs ---
nvs_cycle = list(range(4, 12))
ambient_cycle = []
compressed_cycle = []

for nv in nvs_cycle:
    edges = [(i, (i + 1) % nv) for i in range(nv)]
    bases, rank = graphic_matroid_bases(nv, edges)
    m = len(edges)
    k = rank - 2
    if k < 0:
        ambient_cycle.append(0)
        compressed_cycle.append(0)
        continue
    ambient_cycle.append(comb(m, k))
    compressed_cycle.append(support_compressed_leaf_count(bases, m, k))

ax1.plot(nvs_cycle, ambient_cycle, 'o-', color='red', label='Ambient C(n, r-2)', linewidth=2)
ax1.plot(nvs_cycle, compressed_cycle, 's-', color='blue', label='Compressed (actual)', linewidth=2)
ax1.fill_between(nvs_cycle, compressed_cycle, ambient_cycle, alpha=0.15, color='green',
                  label='Savings')
ax1.set_xlabel('Number of vertices', fontsize=12)
ax1.set_ylabel('Leaf count', fontsize=12)
ax1.set_title('Cycle Graphs $C_n$\n(n edges, rank n-1)', fontsize=13)
ax1.legend(fontsize=10)
ax1.grid(True, alpha=0.3)
ax1.set_yscale('log')

# --- Right plot: Complete graphs ---
nvs_complete = list(range(3, 8))
ambient_complete = []
compressed_complete = []
uniform_count = []

for nv in nvs_complete:
    edges = [(i, j) for i in range(nv) for j in range(i + 1, nv)]
    bases, rank = graphic_matroid_bases(nv, edges)
    m = len(edges)
    k = rank - 2
    if k < 0:
        ambient_complete.append(0)
        compressed_complete.append(0)
        uniform_count.append(0)
        continue
    amb = comb(m, k)
    comp = support_compressed_leaf_count(bases, m, k)
    unif = comb(m, k)  # Uniform would be the same as ambient
    ambient_complete.append(amb)
    compressed_complete.append(comp)
    uniform_count.append(unif)

ax2.bar(np.array(range(len(nvs_complete))) - 0.15, ambient_complete, 0.3,
        color='red', alpha=0.7, label='Ambient C(m, r-2)')
ax2.bar(np.array(range(len(nvs_complete))) + 0.15, compressed_complete, 0.3,
        color='blue', alpha=0.7, label='Compressed (actual)')
ax2.set_xlabel('Complete graph $K_n$', fontsize=12)
ax2.set_ylabel('Leaf count', fontsize=12)
ax2.set_title('Complete Graphs $K_n$\n(m=C(n,2) edges, rank n-1)', fontsize=13)
ax2.set_xticks(range(len(nvs_complete)))
ax2.set_xticklabels([f'$K_{nv}$' for nv in nvs_complete])
ax2.legend(fontsize=10)
ax2.grid(True, alpha=0.3, axis='y')

# Add ratio annotations
for i, nv in enumerate(nvs_complete):
    if ambient_complete[i] > 0:
        ratio = compressed_complete[i] / ambient_complete[i]
        ax2.annotate(f'{ratio:.2f}', (i + 0.15, compressed_complete[i]),
                     ha='center', va='bottom', fontsize=8, fontweight='bold')

plt.suptitle('Leaf Count Growth: Ambient vs. Support-Compressed',
             fontsize=14, fontweight='bold')
plt.tight_layout()
plt.savefig('viz_leaf_growth.png', dpi=150, bbox_inches='tight')
print("Saved viz_leaf_growth.png")


"""
Visualization: Matroid Compression Landscape.

A scatter plot showing the relationship between structural parameters
(number of bases, ground set size, rank) and the compression ratio
across different matroid families. Each point represents a specific
matroid, colored by family type.

This visualization reveals the structural pattern: sparser matroids
achieve more compression.
"""

import numpy as np
import matplotlib.pyplot as plt
from math import comb
from itertools import combinations


def graphic_matroid_bases(n_vertices, edges):
    m = len(edges)
    def is_acyclic(edge_indices):
        parent = list(range(n_vertices))
        def find(x):
            while parent[x] != x:
                parent[x] = parent[parent[x]]
                x = parent[x]
            return x
        def union(x, y):
            rx, ry = find(x), find(y)
            if rx == ry: return False
            parent[rx] = ry
            return True
        for idx in edge_indices:
            u, v = edges[idx]
            if not union(u, v): return False
        return True

    def count_components(edge_indices):
        parent = list(range(n_vertices))
        def find(x):
            while parent[x] != x:
                parent[x] = parent[parent[x]]
                x = parent[x]
            return x
        def union(x, y):
            rx, ry = find(x), find(y)
            if rx != ry: parent[rx] = ry
        for idx in edge_indices:
            u, v = edges[idx]
            union(u, v)
        return len({find(i) for i in range(n_vertices)})

    full_comp = count_components(list(range(m)))
    rank = n_vertices - full_comp
    bases = set()
    for subset in combinations(range(m), rank):
        if is_acyclic(list(subset)):
            bases.add(frozenset(subset))
    return bases, rank


def support_compressed_leaf_count(bases, n, k):
    count = 0
    for subset in combinations(range(n), k):
        fs = frozenset(subset)
        for B in bases:
            if fs <= B:
                count += 1
                break
    return count


fig, ax = plt.subplots(1, 1, figsize=(10, 7))

# Collect data points
data_points = []  # (num_bases, compression_ratio, family, label)

# Uniform matroids
for n in range(4, 9):
    for r in range(3, n):
        k = r - 2
        bases = {frozenset(B) for B in combinations(range(n), r)}
        nb = len(bases)
        amb = comb(n, k)
        comp = support_compressed_leaf_count(bases, n, k)
        ratio = comp / amb if amb > 0 else 1.0
        data_points.append((nb, ratio, 'Uniform', f'U_{{{r},{n}}}'))

# Graphic matroids (cycles)
for nv in range(4, 10):
    edges = [(i, (i + 1) % nv) for i in range(nv)]
    bases, rank = graphic_matroid_bases(nv, edges)
    m = len(edges)
    k = rank - 2
    if k < 0: continue
    nb = len(bases)
    amb = comb(m, k)
    comp = support_compressed_leaf_count(bases, m, k)
    ratio = comp / amb if amb > 0 else 1.0
    data_points.append((nb, ratio, 'Cycle', f'C_{nv}'))

# Graphic matroids (complete)
for nv in range(3, 8):
    edges = [(i, j) for i in range(nv) for j in range(i + 1, nv)]
    bases, rank = graphic_matroid_bases(nv, edges)
    m = len(edges)
    k = rank - 2
    if k < 0: continue
    nb = len(bases)
    amb = comb(m, k)
    comp = support_compressed_leaf_count(bases, m, k)
    ratio = comp / amb if amb > 0 else 1.0
    data_points.append((nb, ratio, 'Complete', f'K_{nv}'))

# Graphic matroids (paths)
for nv in range(4, 10):
    edges = [(i, i + 1) for i in range(nv - 1)]
    bases, rank = graphic_matroid_bases(nv, edges)
    m = len(edges)
    k = rank - 2
    if k < 0: continue
    nb = len(bases)
    amb = comb(m, k)
    comp = support_compressed_leaf_count(bases, m, k)
    ratio = comp / amb if amb > 0 else 1.0
    data_points.append((nb, ratio, 'Path', f'P_{nv}'))

# Plot by family
colors = {'Uniform': '#e74c3c', 'Cycle': '#3498db', 'Complete': '#2ecc71', 'Path': '#9b59b6'}
markers = {'Uniform': 'o', 'Cycle': 's', 'Complete': 'D', 'Path': '^'}

for family in ['Uniform', 'Cycle', 'Complete', 'Path']:
    pts = [(nb, r, label) for nb, r, f, label in data_points if f == family]
    if pts:
        xs = [p[0] for p in pts]
        ys = [p[1] for p in pts]
        labels = [p[2] for p in pts]
        ax.scatter(xs, ys, c=colors[family], marker=markers[family],
                  s=80, label=family, alpha=0.8, edgecolors='black', linewidth=0.5)
        # Label a few key points
        for x, y, label in pts:
            if y < 0.98 or family == 'Uniform':
                ax.annotate(label, (x, y), fontsize=7, alpha=0.7,
                           textcoords='offset points', xytext=(5, 5))

ax.axhline(y=1.0, color='gray', linestyle='--', alpha=0.5, label='No compression')
ax.set_xlabel('Number of Bases', fontsize=12)
ax.set_ylabel('Compression Ratio (actual / ambient)', fontsize=12)
ax.set_title('Matroid Compression Landscape\nEach point = one matroid, showing support compression efficiency',
             fontsize=13, fontweight='bold')
ax.legend(fontsize=10, loc='lower left')
ax.grid(True, alpha=0.2)
ax.set_xscale('log')
ax.set_ylim(0.4, 1.05)

plt.tight_layout()
plt.savefig('viz_matroid_landscape.png', dpi=150, bbox_inches='tight')
print("Saved viz_matroid_landscape.png")
