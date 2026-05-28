"""
Applications of Sparse-Support Certificate Compression

Demonstrates real-world applications of the support compression theory:
1. Network reliability: counting spanning forests
2. Optimization: matroid intersection certificate sizing
3. Partition function analysis: Boltzmann weight compression
"""

from itertools import combinations
from math import comb, factorial, exp
from collections import defaultdict
from typing import List, Tuple, Set, FrozenSet


# ============================================================
# Application 1: Network Reliability
# ============================================================

def network_reliability_certificate_size(edges: List[Tuple[int, int]],
                                          num_vertices: int) -> dict:
    """Compute certification complexity for a network's reliability polynomial.

    The reliability polynomial of a graph G counts the probability that G
    remains connected when each edge fails independently with probability q.
    Its basis generating polynomial is the spanning tree polynomial.

    Returns:
        Dictionary with leaf counts, compression ratios, and timing estimates
    """
    ne = len(edges)
    rank = num_vertices - 1

    # Find spanning trees
    def is_forest_and_spans(subset):
        adj = defaultdict(set)
        vertices = set()
        for idx in subset:
            u, v = edges[idx]
            adj[u].add(v)
            adj[v].add(u)
            vertices.add(u)
            vertices.add(v)
        # Check acyclic
        visited = set()
        for start in vertices:
            if start in visited:
                continue
            stack = [(start, -1)]
            local_visited = set()
            while stack:
                node, parent = stack.pop()
                if node in local_visited:
                    return False
                local_visited.add(node)
                visited.add(node)
                for nb in adj[node]:
                    if nb != parent:
                        stack.append((nb, node))
        # Check spans
        if len(visited) < num_vertices:
            return False
        return True

    bases = set()
    for subset in combinations(range(ne), rank):
        if is_forest_and_spans(subset):
            bases.add(frozenset(subset))

    if not bases:
        return {"error": "No spanning trees found"}

    k = rank - 2
    if k < 0:
        return {"error": "Rank too small"}

    # Count independent sets
    leaves = 0
    for subset in combinations(range(ne), k):
        fs = frozenset(subset)
        if any(fs <= b for b in bases):
            leaves += 1

    active = set()
    for b in bases:
        active |= b
    omega = len(active)

    ambient = comb(ne, k)
    active_bound = comb(omega, k)

    return {
        "num_edges": ne,
        "num_vertices": num_vertices,
        "rank": rank,
        "num_spanning_trees": len(bases),
        "quadratic_leaves": leaves,
        "ambient_bound": ambient,
        "active_variable_bound": active_bound,
        "active_variables": omega,
        "compression_ratio": leaves / ambient if ambient > 0 else 0,
    }


# ============================================================
# Application 2: Combinatorial Optimization Certificate Sizing
# ============================================================

def optimization_certificate_analysis(n: int, r: int,
                                       num_bases: int) -> dict:
    """Analyze certification complexity for random matroid-like structures.

    Simulates a matroid with `num_bases` randomly chosen r-element subsets
    and computes the resulting compression metrics.
    """
    import random
    random.seed(42)

    ground = list(range(n))
    bases = set()
    attempts = 0
    while len(bases) < min(num_bases, comb(n, r)) and attempts < 10000:
        b = frozenset(random.sample(ground, r))
        bases.add(b)
        attempts += 1

    k = r - 2
    if k < 0:
        return {"error": "Rank too small"}

    leaves = 0
    for subset in combinations(range(n), k):
        fs = frozenset(subset)
        if any(fs <= b for b in bases):
            leaves += 1

    active = set()
    for b in bases:
        active |= b
    omega = len(active)

    ambient = comb(n, k)
    active_bound = comb(omega, k)

    return {
        "n": n,
        "r": r,
        "num_bases": len(bases),
        "quadratic_leaves": leaves,
        "ambient_bound": ambient,
        "active_variable_bound": active_bound,
        "active_variables": omega,
        "compression_ratio": leaves / ambient if ambient > 0 else 0,
        "active_compression": leaves / active_bound if active_bound > 0 else 0,
    }


# ============================================================
# Application 3: Partition Function Certification
# ============================================================

def partition_function_analysis(n: int, r: int,
                                 weights: List[float] = None) -> dict:
    """Analyze a weighted basis generating polynomial's certification cost.

    For a matroid with weighted bases, the certification cost is still
    determined by the (unweighted) support structure.
    """
    # Use uniform matroid for simplicity
    bases = list(combinations(range(n), r))

    if weights is None:
        weights = [1.0] * len(bases)

    # Support = bases with nonzero weight
    nonzero_bases = {frozenset(bases[i]) for i in range(len(bases))
                     if weights[i] != 0}

    k = r - 2
    if k < 0:
        return {"error": "Rank too small"}

    leaves = 0
    for subset in combinations(range(n), k):
        fs = frozenset(subset)
        if any(fs <= b for b in nonzero_bases):
            leaves += 1

    ambient = comb(n, k)
    full_leaves = comb(n, k)  # uniform would give this

    return {
        "n": n,
        "r": r,
        "total_bases": len(bases),
        "nonzero_bases": len(nonzero_bases),
        "quadratic_leaves": leaves,
        "ambient_bound": ambient,
        "compression_vs_full": leaves / full_leaves if full_leaves > 0 else 0,
        "weight_range": (min(weights), max(weights)) if weights else (0, 0),
    }


# ============================================================
# Main Demo
# ============================================================

def main():
    print("=" * 70)
    print("APPLICATION 1: Network Reliability")
    print("=" * 70)

    # Small networks
    networks = [
        ("Triangle", [(0,1), (1,2), (0,2)], 3),
        ("Square", [(0,1), (1,2), (2,3), (0,3)], 4),
        ("K4", [(0,1), (0,2), (0,3), (1,2), (1,3), (2,3)], 4),
        ("Petersen-like", [(0,1),(1,2),(2,3),(3,4),(4,0),
                          (0,2),(1,3),(2,4),(3,0),(4,1)], 5),
    ]

    for name, edges, nv in networks:
        result = network_reliability_certificate_size(edges, nv)
        if "error" in result:
            print(f"\n{name}: {result['error']}")
            continue
        print(f"\n{name}:")
        print(f"  Edges: {len(edges)}, Vertices: {nv}")
        print(f"  Spanning trees: {result['num_spanning_trees']}")
        print(f"  Quadratic leaves: {result['quadratic_leaves']}")
        print(f"  Ambient bound: {result['ambient_bound']}")
        print(f"  Compression ratio: {result['compression_ratio']:.4f}")

    print()
    print("=" * 70)
    print("APPLICATION 2: Optimization Certificate Sizing")
    print("=" * 70)

    configs = [
        (10, 4, 5),
        (10, 4, 20),
        (10, 4, 50),
        (15, 5, 10),
        (15, 5, 100),
        (20, 5, 50),
    ]

    print(f"\n{'n':>4} {'r':>3} {'|B|':>5} {'Leaves':>7} {'Ambient':>8} "
          f"{'ω':>3} {'C(ω,k)':>7} {'Ratio':>7}")
    print("-" * 50)

    for n, r, nb in configs:
        result = optimization_certificate_analysis(n, r, nb)
        if "error" in result:
            continue
        print(f"{result['n']:>4} {result['r']:>3} {result['num_bases']:>5} "
              f"{result['quadratic_leaves']:>7} {result['ambient_bound']:>8} "
              f"{result['active_variables']:>3} {result['active_variable_bound']:>7} "
              f"{result['compression_ratio']:>7.4f}")

    print()
    print("=" * 70)
    print("APPLICATION 3: Partition Function Sparsity")
    print("=" * 70)

    import random
    random.seed(123)

    for n, r in [(6, 3), (8, 4)]:
        total = comb(n, r)
        for frac in [1.0, 0.5, 0.2, 0.1]:
            num_nonzero = max(1, int(frac * total))
            weights = [0.0] * total
            chosen = random.sample(range(total), num_nonzero)
            for i in chosen:
                weights[i] = random.uniform(0.1, 10.0)

            result = partition_function_analysis(n, r, weights)
            if "error" in result:
                continue
            print(f"  n={n}, r={r}: {result['nonzero_bases']}/{total} bases → "
                  f"{result['quadratic_leaves']}/{result['ambient_bound']} leaves "
                  f"(ratio {result['compression_vs_full']:.4f})")


if __name__ == "__main__":
    main()


"""
Demo: Sparse-Support Certificate Compression for Matroid Basis Polynomials

Demonstrates the core theorems with concrete numerical examples:
1. Uniform matroid leaf counts match C(n, r-2)
2. Compressed vs. naive leaf counts for various matroid families
3. Active variable compression bounds
4. Compression ratios across families
"""

from itertools import combinations
from math import comb
from collections import defaultdict
import time


def is_forest(edges, edge_indices):
    """Check if selected edges form a forest (acyclic) using union-find."""
    parent = {}
    def find(x):
        while parent.get(x, x) != x:
            parent[x] = parent.get(parent[x], parent[x])
            x = parent[x]
        return x
    def union(x, y):
        rx, ry = find(x), find(y)
        if rx == ry:
            return False  # cycle
        parent[rx] = ry
        return True
    for idx in edge_indices:
        u, v = edges[idx]
        if not union(u, v):
            return False
    return True


def spans_all_vertices(edges, edge_indices, num_vertices):
    """Check if edges connect all vertices."""
    if num_vertices <= 1:
        return True
    if not edge_indices:
        return False
    adj = defaultdict(set)
    for idx in edge_indices:
        u, v = edges[idx]
        adj[u].add(v)
        adj[v].add(u)
    visited = set()
    queue = [0]
    while queue:
        node = queue.pop()
        if node in visited:
            continue
        visited.add(node)
        for nb in adj[node]:
            if nb not in visited:
                queue.append(nb)
    return len(visited) == num_vertices


def find_spanning_trees(edges, num_vertices):
    """Find all spanning trees of a graph."""
    n = len(edges)
    rank = num_vertices - 1
    trees = set()
    for subset in combinations(range(n), rank):
        if is_forest(edges, subset) and spans_all_vertices(edges, subset, num_vertices):
            trees.add(frozenset(subset))
    return trees


def count_independent_sets(bases, n, r, k):
    """Count k-element subsets contained in some basis."""
    count = 0
    for subset in combinations(range(n), k):
        fs = frozenset(subset)
        if any(fs <= b for b in bases):
            count += 1
    return count


def active_vars(bases):
    """Union of all bases."""
    result = set()
    for b in bases:
        result |= b
    return result


def print_separator():
    print("=" * 70)


def demo_uniform_matroids():
    """Theorem 3: Uniform matroid gives C(n, r-2)."""
    print_separator()
    print("THEOREM 3: Uniform Matroid Closed Form")
    print("For U_{r,n}, quadratic leaf count = C(n, r-2)")
    print_separator()

    cases = [(6, 3), (8, 4), (10, 5), (7, 3), (9, 4), (12, 5)]

    print(f"{'n':>4} {'r':>4} {'C(n,r-2)':>10} {'Computed':>10} {'Match':>6}")
    print("-" * 40)

    for n, r in cases:
        bases = {frozenset(c) for c in combinations(range(n), r)}
        k = r - 2
        computed = count_independent_sets(bases, n, r, k)
        expected = comb(n, k)
        match = "✓" if computed == expected else "✗"
        print(f"{n:>4} {r:>4} {expected:>10} {computed:>10} {match:>6}")

    print()


def demo_compression_ratios():
    """Theorem 4: Support compression bounds."""
    print_separator()
    print("THEOREM 4: Support Compression")
    print("Compressed leaf count ≤ C(|active vars|, r-2)")
    print_separator()

    results = []

    # Uniform matroids (no compression)
    for n, r in [(6, 3), (8, 4), (10, 5)]:
        bases = {frozenset(c) for c in combinations(range(n), r)}
        k = r - 2
        leaves = count_independent_sets(bases, n, r, k)
        omega = len(active_vars(bases))
        ambient = comb(n, k)
        active_bound = comb(omega, k)
        ratio = leaves / ambient if ambient > 0 else 0
        results.append(("Uniform", n, r, len(bases), leaves, ambient,
                        omega, active_bound, ratio))

    # Single-basis families (maximum compression)
    for n, r in [(8, 4), (12, 4), (15, 5), (20, 5)]:
        basis = frozenset(range(r))
        bases = {basis}
        k = r - 2
        leaves = count_independent_sets(bases, n, r, k)
        omega = len(active_vars(bases))
        ambient = comb(n, k)
        active_bound = comb(omega, k)
        ratio = leaves / ambient if ambient > 0 else 0
        results.append(("Single", n, r, 1, leaves, ambient,
                        omega, active_bound, ratio))

    # Two disjoint bases
    for n, r in [(10, 4), (14, 5)]:
        b1 = frozenset(range(r))
        b2 = frozenset(range(r, 2*r))
        bases = {b1, b2}
        k = r - 2
        leaves = count_independent_sets(bases, n, r, k)
        omega = len(active_vars(bases))
        ambient = comb(n, k)
        active_bound = comb(omega, k)
        ratio = leaves / ambient if ambient > 0 else 0
        results.append(("2-Disjoint", n, r, 2, leaves, ambient,
                        omega, active_bound, ratio))

    print(f"{'Family':<12} {'n':>3} {'r':>3} {'|B|':>5} {'Leaves':>7} "
          f"{'Ambient':>8} {'ω':>3} {'C(ω,k)':>7} {'Ratio':>7}")
    print("-" * 65)
    for (fam, n, r, nb, leaves, amb, omega, ab, ratio) in results:
        print(f"{fam:<12} {n:>3} {r:>3} {nb:>5} {leaves:>7} "
              f"{amb:>8} {omega:>3} {ab:>7} {ratio:>7.4f}")

    print()


def demo_graphic_matroids():
    """Graphic matroid examples."""
    print_separator()
    print("GRAPHIC MATROIDS: Leaves as Forest Counts")
    print_separator()

    examples = [
        ("Path P4", [(0,1), (1,2), (2,3)], 4),
        ("Path P5", [(0,1), (1,2), (2,3), (3,4)], 5),
        ("Cycle C4", [(0,1), (1,2), (2,3), (3,0)], 4),
        ("Cycle C5", [(0,1), (1,2), (2,3), (3,4), (4,0)], 5),
        ("K4", [(0,1), (0,2), (0,3), (1,2), (1,3), (2,3)], 4),
        ("Diamond", [(0,1), (0,2), (1,2), (1,3), (2,3)], 4),
    ]

    print(f"{'Graph':<10} {'|E|':>4} {'|V|':>4} {'r':>3} {'Trees':>6} "
          f"{'Leaves':>7} {'C(|E|,r-2)':>10} {'Ratio':>7}")
    print("-" * 58)

    for name, edges, nv in examples:
        ne = len(edges)
        trees = find_spanning_trees(edges, nv)
        if not trees:
            print(f"{name:<10} {ne:>4} {nv:>4}  -- No spanning trees")
            continue
        r = len(next(iter(trees)))
        bases = trees
        k = r - 2
        if k < 0:
            continue
        leaves = count_independent_sets(bases, ne, r, k)
        ambient = comb(ne, k)
        ratio = leaves / ambient if ambient > 0 else 0
        print(f"{name:<10} {ne:>4} {nv:>4} {r:>3} {len(trees):>6} "
              f"{leaves:>7} {ambient:>10} {ratio:>7.4f}")

    print()


def demo_timing():
    """Compare timing of compressed vs. naive enumeration."""
    print_separator()
    print("TIMING: Compressed vs. Naive Enumeration")
    print_separator()

    print(f"{'Family':<15} {'n':>4} {'r':>3} {'Compressed':>12} {'Ambient':>10} "
          f"{'Time(ms)':>10}")
    print("-" * 58)

    for n, r in [(10, 4), (12, 5), (14, 5), (8, 3)]:
        # Single basis
        basis = frozenset(range(r))
        bases = {basis}
        k = r - 2

        t0 = time.perf_counter()
        leaves = count_independent_sets(bases, n, r, k)
        t1 = time.perf_counter()

        ambient = comb(n, k)
        elapsed_ms = (t1 - t0) * 1000

        print(f"{'Single basis':<15} {n:>4} {r:>3} {leaves:>12} {ambient:>10} "
              f"{elapsed_ms:>10.2f}")

    for n, r in [(8, 4), (10, 5), (12, 5)]:
        bases = {frozenset(c) for c in combinations(range(n), r)}
        k = r - 2

        t0 = time.perf_counter()
        leaves = count_independent_sets(bases, n, r, k)
        t1 = time.perf_counter()

        ambient = comb(n, k)
        elapsed_ms = (t1 - t0) * 1000

        print(f"{'Uniform':<15} {n:>4} {r:>3} {leaves:>12} {ambient:>10} "
              f"{elapsed_ms:>10.2f}")

    print()


def demo_theorem1():
    """Theorem 1: Support criterion demonstration."""
    print_separator()
    print("THEOREM 1: Derivative Survival = Support Containment")
    print("For multiaffine polynomials, ∂^α p ≠ 0 ⟺ supp(α) ⊆ supp(β) for some β")
    print_separator()

    # Example: support = {{0,1,2}, {1,2,3}}
    support = [frozenset({0, 1, 2}), frozenset({1, 2, 3})]
    n = 4
    r = 3

    print(f"Support (bases): {[set(s) for s in support]}")
    print(f"Ground set: {{0, 1, 2, 3}}, rank = {r}")
    print()

    k = r - 2  # = 1
    print(f"Checking all {k}-element subsets for containment in some basis:")
    for i in range(n):
        subset = frozenset({i})
        contained = any(subset <= b for b in support)
        status = "✓ SURVIVES" if contained else "✗ vanishes"
        containing = [set(b) for b in support if subset <= b]
        print(f"  {{{i}}} → {status}"
              + (f"  (contained in {containing})" if contained else ""))

    print(f"\nLeaf count: {count_independent_sets(set(support), n, r, k)}")
    print(f"Ambient:    {comb(n, k)}")
    print()


def main():
    print()
    print("╔══════════════════════════════════════════════════════════════════╗")
    print("║  SPARSE-SUPPORT CERTIFICATE COMPRESSION                        ║")
    print("║  For Matroid Basis Polynomials                                  ║")
    print("║                                                                ║")
    print("║  Demonstrating: The recursion tree for Lorentzian              ║")
    print("║  certification is the independent-set complex in disguise.     ║")
    print("╚══════════════════════════════════════════════════════════════════╝")
    print()

    demo_theorem1()
    demo_uniform_matroids()
    demo_compression_ratios()
    demo_graphic_matroids()
    demo_timing()

    print_separator()
    print("KEY TAKEAWAYS:")
    print("• Uniform matroids achieve C(n, r-2) leaves (maximum, no compression)")
    print("• Single-basis families achieve C(r, 2) leaves (maximum compression)")
    print("• Active variable bound C(ω, r-2) captures intermediate cases")
    print("• Graphic matroid leaves correspond to forests of size r-2")
    print_separator()


if __name__ == "__main__":
    main()


"""
Visualization: Compression Ratio Heatmap

Visualizes the compression ratio (actual leaves / ambient bound) as a
heatmap across different values of n (ground set size) and number of
bases. Shows how support sparsity controls certification complexity.

The key insight: as the number of bases decreases relative to the
maximum (uniform matroid), the compression ratio drops dramatically,
demonstrating that support geometry compresses certification.
"""

import numpy as np
import matplotlib.pyplot as plt
from itertools import combinations
from math import comb
import random

random.seed(42)

def count_leaves(bases, n, r):
    """Count independent (r-2)-sets."""
    k = r - 2
    if k < 0:
        return 0
    count = 0
    for subset in combinations(range(n), k):
        fs = frozenset(subset)
        if any(fs <= b for b in bases):
            count += 1
    return count

# Parameters
r = 4  # Fixed rank
n_values = list(range(6, 13))  # Ground set sizes
num_bases_fracs = [0.05, 0.1, 0.2, 0.3, 0.5, 0.7, 1.0]

# Compute compression ratios
ratios = np.zeros((len(num_bases_fracs), len(n_values)))

for j, n in enumerate(n_values):
    max_bases = comb(n, r)
    all_bases = list(combinations(range(n), r))
    ambient = comb(n, r - 2)

    for i, frac in enumerate(num_bases_fracs):
        num_b = max(1, int(frac * max_bases))
        # Sample bases
        chosen = random.sample(all_bases, min(num_b, len(all_bases)))
        bases = {frozenset(c) for c in chosen}
        leaves = count_leaves(bases, n, r)
        ratios[i, j] = leaves / ambient if ambient > 0 else 0

# Plot
fig, ax = plt.subplots(figsize=(10, 7))

im = ax.imshow(ratios, cmap='YlOrRd', aspect='auto', vmin=0, vmax=1)
ax.set_xticks(range(len(n_values)))
ax.set_xticklabels(n_values, fontsize=12)
ax.set_yticks(range(len(num_bases_fracs)))
ax.set_yticklabels([f"{f:.0%}" for f in num_bases_fracs], fontsize=12)

ax.set_xlabel('Ground Set Size (n)', fontsize=14)
ax.set_ylabel('Fraction of Maximum Bases', fontsize=14)
ax.set_title(f'Certificate Compression Ratio (rank r={r})\n'
             f'Ratio = Actual Leaves / Ambient C(n, r−2)', fontsize=15)

# Add text annotations
for i in range(len(num_bases_fracs)):
    for j in range(len(n_values)):
        text = f'{ratios[i, j]:.2f}'
        color = 'white' if ratios[i, j] > 0.6 else 'black'
        ax.text(j, i, text, ha='center', va='center',
                fontsize=10, color=color, fontweight='bold')

cbar = plt.colorbar(im, ax=ax, shrink=0.8)
cbar.set_label('Compression Ratio', fontsize=13)

plt.tight_layout()
plt.savefig('compression_heatmap.png', dpi=150, bbox_inches='tight')
print("Saved compression_heatmap.png")


"""
Visualization: Leaf Count Growth Curves

Plots the growth of quadratic leaf counts as a function of ground set
size n for different matroid families:
- Uniform matroid (worst case): C(n, r-2)
- Single-basis family (best case): C(r, 2)
- Active-variable bound: C(omega, r-2)

Demonstrates the separation between ambient and compressed complexity.
"""

import numpy as np
import matplotlib.pyplot as plt
from math import comb

# Parameters
r = 5  # Fixed rank
n_range = list(range(r, 26))

# Compute leaf counts for each family
uniform_leaves = [comb(n, r - 2) for n in n_range]
single_leaves = [comb(r, 2)] * len(n_range)  # Always C(r, 2) = 10

# Two-basis (disjoint): active vars = 2r, so bound = C(2r, r-2)
two_basis_bound = [comb(min(2*r, n), r - 2) for n in n_range]

# Sparse matroid: active vars ~ sqrt(n) * r
sparse_leaves = [comb(min(int(np.sqrt(n) * r / 2), n), r - 2) for n in n_range]

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

# Linear scale
ax1.plot(n_range, uniform_leaves, 'o-', color='#e74c3c', linewidth=2.5,
         markersize=5, label=f'Uniform U(r,n): C(n, {r-2})')
ax1.plot(n_range, two_basis_bound, 's-', color='#3498db', linewidth=2,
         markersize=5, label=f'2 Disjoint Bases: C(min(2r,n), {r-2})')
ax1.plot(n_range, sparse_leaves, '^-', color='#2ecc71', linewidth=2,
         markersize=5, label=f'Sparse: C(√n·r/2, {r-2})')
ax1.plot(n_range, single_leaves, 'D-', color='#9b59b6', linewidth=2,
         markersize=5, label=f'Single Basis: C(r, 2) = {comb(r, 2)}')

ax1.set_xlabel('Ground Set Size (n)', fontsize=13)
ax1.set_ylabel('Quadratic Leaf Count', fontsize=13)
ax1.set_title(f'Leaf Count Growth (rank r = {r})', fontsize=14)
ax1.legend(fontsize=10, loc='upper left')
ax1.grid(True, alpha=0.3)

# Log scale
ax2.semilogy(n_range, uniform_leaves, 'o-', color='#e74c3c', linewidth=2.5,
             markersize=5, label=f'Uniform: C(n, {r-2})')
ax2.semilogy(n_range, two_basis_bound, 's-', color='#3498db', linewidth=2,
             markersize=5, label=f'2 Disjoint Bases')
ax2.semilogy(n_range, sparse_leaves, '^-', color='#2ecc71', linewidth=2,
             markersize=5, label=f'Sparse')
ax2.semilogy(n_range, single_leaves, 'D-', color='#9b59b6', linewidth=2,
             markersize=5, label=f'Single Basis: {comb(r, 2)}')

# Shade the compression gap
ax2.fill_between(n_range, single_leaves, uniform_leaves,
                  alpha=0.1, color='gray', label='Compression gap')

ax2.set_xlabel('Ground Set Size (n)', fontsize=13)
ax2.set_ylabel('Quadratic Leaf Count (log scale)', fontsize=13)
ax2.set_title(f'Compression Gap (rank r = {r})', fontsize=14)
ax2.legend(fontsize=10, loc='upper left')
ax2.grid(True, alpha=0.3)

plt.suptitle('Support-Compressed Certificate Complexity\n'
             'Gap between ambient worst case and support-controlled cost',
             fontsize=15, y=1.02)

plt.tight_layout()
plt.savefig('leaf_growth.png', dpi=150, bbox_inches='tight')
print("Saved leaf_growth.png")


"""
Visualization: Matroid Family Comparison

Bar chart comparing quadratic leaf counts across different matroid families
for fixed parameters, showing how support structure controls complexity.
Includes ambient bound, active-variable bound, and actual leaf count.
"""

import numpy as np
import matplotlib.pyplot as plt
from itertools import combinations
from math import comb
from collections import defaultdict
import random

random.seed(42)

def count_leaves(bases, n, r):
    k = r - 2
    if k < 0:
        return 0
    count = 0
    for subset in combinations(range(n), k):
        fs = frozenset(subset)
        if any(fs <= b for b in bases):
            count += 1
    return count

def active_count(bases):
    s = set()
    for b in bases:
        s |= b
    return len(s)

def is_forest(edges, indices):
    adj = defaultdict(set)
    verts = set()
    for idx in indices:
        u, v = edges[idx]
        adj[u].add(v)
        adj[v].add(u)
        verts.add(u)
        verts.add(v)
    visited = set()
    for start in verts:
        if start in visited:
            continue
        stack = [(start, -1)]
        lv = set()
        while stack:
            node, parent = stack.pop()
            if node in lv:
                return False
            lv.add(node)
            visited.add(node)
            for nb in adj[node]:
                if nb != parent:
                    stack.append((nb, node))
    return True

def spans(edges, indices, nv):
    if not indices:
        return nv <= 1
    adj = defaultdict(set)
    for idx in indices:
        u, v = edges[idx]
        adj[u].add(v)
        adj[v].add(u)
    visited = set()
    queue = [0]
    while queue:
        node = queue.pop()
        if node in visited:
            continue
        visited.add(node)
        for nb in adj[node]:
            if nb not in visited:
                queue.append(nb)
    return len(visited) == nv

# Fixed parameters
n = 10
r = 4
k = r - 2

families = []

# 1. Uniform matroid
bases_unif = {frozenset(c) for c in combinations(range(n), r)}
leaves_unif = count_leaves(bases_unif, n, r)
omega_unif = active_count(bases_unif)
families.append(("Uniform\nU(4,10)", leaves_unif, comb(omega_unif, k),
                 comb(n, k), len(bases_unif)))

# 2. Single basis
bases_single = {frozenset({0, 1, 2, 3})}
leaves_single = count_leaves(bases_single, n, r)
omega_single = active_count(bases_single)
families.append(("Single\nBasis", leaves_single, comb(omega_single, k),
                 comb(n, k), 1))

# 3. Two disjoint bases
bases_two = {frozenset({0,1,2,3}), frozenset({4,5,6,7})}
leaves_two = count_leaves(bases_two, n, r)
omega_two = active_count(bases_two)
families.append(("2 Disjoint\nBases", leaves_two, comb(omega_two, k),
                 comb(n, k), 2))

# 4. Three overlapping bases
bases_three = {frozenset({0,1,2,3}), frozenset({2,3,4,5}), frozenset({4,5,6,7})}
leaves_three = count_leaves(bases_three, n, r)
omega_three = active_count(bases_three)
families.append(("3 Overlap\nBases", leaves_three, comb(omega_three, k),
                 comb(n, k), 3))

# 5. Random 10 bases
all_combs = list(combinations(range(n), r))
chosen = random.sample(all_combs, 10)
bases_rand = {frozenset(c) for c in chosen}
leaves_rand = count_leaves(bases_rand, n, r)
omega_rand = active_count(bases_rand)
families.append(("Random\n10 Bases", leaves_rand, comb(omega_rand, k),
                 comb(n, k), 10))

# 6. Random 50 bases
chosen50 = random.sample(all_combs, 50)
bases_r50 = {frozenset(c) for c in chosen50}
leaves_r50 = count_leaves(bases_r50, n, r)
omega_r50 = active_count(bases_r50)
families.append(("Random\n50 Bases", leaves_r50, comb(omega_r50, k),
                 comb(n, k), 50))

# Extract data
names = [f[0] for f in families]
actual = [f[1] for f in families]
active_bd = [f[2] for f in families]
ambient = [f[3] for f in families]
num_bases = [f[4] for f in families]

x = np.arange(len(names))
width = 0.25

fig, ax = plt.subplots(figsize=(12, 7))

bars1 = ax.bar(x - width, ambient, width, label='Ambient C(n, r−2)',
               color='#e74c3c', alpha=0.8, edgecolor='black', linewidth=0.5)
bars2 = ax.bar(x, active_bd, width, label='Active C(ω, r−2)',
               color='#f39c12', alpha=0.8, edgecolor='black', linewidth=0.5)
bars3 = ax.bar(x + width, actual, width, label='Actual Leaves',
               color='#2ecc71', alpha=0.8, edgecolor='black', linewidth=0.5)

# Add value labels
for bar_group in [bars1, bars2, bars3]:
    for bar in bar_group:
        height = bar.get_height()
        ax.text(bar.get_x() + bar.get_width()/2., height + 0.5,
                f'{int(height)}', ha='center', va='bottom', fontsize=9,
                fontweight='bold')

# Add basis count annotations
for i, nb in enumerate(num_bases):
    ax.text(i, -3, f'{nb} bases', ha='center', fontsize=9,
            style='italic', color='gray')

ax.set_xlabel('Matroid Family', fontsize=13)
ax.set_ylabel('Leaf Count', fontsize=13)
ax.set_title(f'Certificate Compression by Support Geometry\n'
             f'n = {n}, r = {r}, ambient bound C({n}, {k}) = {comb(n, k)}',
             fontsize=14)
ax.set_xticks(x)
ax.set_xticklabels(names, fontsize=11)
ax.legend(fontsize=11, loc='upper right')
ax.grid(True, alpha=0.2, axis='y')
ax.set_ylim(bottom=-5)

plt.tight_layout()
plt.savefig('matroid_comparison.png', dpi=150, bbox_inches='tight')
print("Saved matroid_comparison.png")
