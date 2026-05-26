#!/usr/bin/env python3
"""
applications.py — Applications of Tropical Hodge Depth

Demonstrates real-world applications:
1. Matroid rank analysis via rank-defect functions
2. Entropy/information-theoretic set functions
3. Network reliability functions
4. Detecting geometry from depth values
"""

import math
from typing import Set, FrozenSet, List, Dict, Callable

SetFn = Callable[[FrozenSet[int]], float]


def powerset_list(ground: Set[int]) -> List[FrozenSet[int]]:
    elems = sorted(ground)
    n = len(elems)
    return [frozenset(elems[j] for j in range(n) if i & (1 << j))
            for i in range(1 << n)]


def supermod_defect(g: SetFn, s: FrozenSet[int], t: FrozenSet[int]) -> float:
    return g(s | t) + g(s & t) - g(s) - g(t)


def elem_diff(g: SetFn, a: int) -> SetFn:
    singleton = frozenset([a])
    return lambda s: g(s | singleton) - g(s)


def check_supermod_order(k, g, ground, subsets=None, tol=1e-12):
    if subsets is None:
        subsets = powerset_list(ground)
    if k == 0:
        return all(supermod_defect(g, s, t) >= -tol
                   for s in subsets for t in subsets)
    if not check_supermod_order(k - 1, g, ground, subsets, tol):
        return False
    return all(check_supermod_order(k - 1, elem_diff(g, a), ground, subsets, tol)
               for a in ground)


def compute_depth(g, ground, max_k=4):
    subsets = powerset_list(ground)
    depth = -1
    for k in range(max_k + 1):
        if check_supermod_order(k, g, ground, subsets):
            depth = k
        else:
            break
    return max(depth, 0) if depth == -1 else depth


# ============================================================
# APPLICATION 1: Matroid Rank Functions
# ============================================================

def uniform_matroid_rank(n: int, r: int) -> SetFn:
    """Rank function of uniform matroid U_{r,n}."""
    return lambda s: float(min(len(s), r))


def graphic_matroid_rank(edges: List, n_vertices: int) -> SetFn:
    """Rank function of graphic matroid: rank = |V(E')| - components(E')."""
    def rank(edge_set: FrozenSet[int]) -> float:
        if not edge_set:
            return 0.0
        # Union-find
        parent = list(range(n_vertices))
        def find(x):
            while parent[x] != x:
                parent[x] = parent[parent[x]]
                x = parent[x]
            return x
        def union(x, y):
            px, py = find(x), find(y)
            if px != py:
                parent[px] = py
                return True
            return False
        rank_val = 0
        for idx in edge_set:
            u, v = edges[idx]
            if union(u, v):
                rank_val += 1
        return float(rank_val)
    return rank


def app_matroid_analysis():
    """Analyze tropical Hodge depth of matroid rank-defect functions."""
    print("=" * 60)
    print("APPLICATION 1: Matroid Rank Analysis")
    print("=" * 60)

    ground = {0, 1, 2}
    print(f"\nGround set: {sorted(ground)}")
    print(f"\n{'Matroid':<20} {'Depth':>6} {'Notes':<30}")
    print("-" * 58)

    for r in range(0, 4):
        rank = uniform_matroid_rank(3, r)
        defect: SetFn = lambda s, r=rank: float(len(s)) - r(s)
        depth = compute_depth(defect, ground, max_k=3)
        is_free = (r == 3)
        notes = "(free matroid, modular)" if is_free else ""
        tag = f"≥3" if depth >= 3 else str(depth)
        print(f"  U({r},3){'':<13} {tag:>5}  {notes}")

    # Graphic matroid: triangle K3
    edges = [(0, 1), (1, 2), (0, 2)]
    ground_e = {0, 1, 2}  # edge indices
    rank = graphic_matroid_rank(edges, 3)
    defect: SetFn = lambda s, r=rank: float(len(s)) - r(s)
    depth = compute_depth(defect, ground_e, max_k=3)
    print(f"  K₃ graphic{'':<8} {depth:>5}  (cycle matroid of triangle)")


# ============================================================
# APPLICATION 2: Entropy Functions
# ============================================================

def app_entropy():
    """Analyze entropy-like set functions."""
    print("\n" + "=" * 60)
    print("APPLICATION 2: Entropy Set Functions")
    print("=" * 60)

    ground = {0, 1, 2}
    print(f"\nGround set: {sorted(ground)}")

    # Shannon entropy of uniform distribution on 2^|s| outcomes
    entropy_fn: SetFn = lambda s: float(len(s)) * math.log(2) if len(s) > 0 else 0.0
    depth = compute_depth(entropy_fn, ground, max_k=3)
    print(f"\n  H(s) = |s|·log(2) (uniform entropy)")
    print(f"  Depth = {'≥3' if depth >= 3 else depth} (modular → all orders)")

    # Rényi entropy with parameter alpha
    for alpha in [0.5, 1.0, 2.0]:
        def renyi(s, a=alpha):
            n = len(s)
            if n == 0:
                return 0.0
            # Rényi entropy of uniform dist on 2^n outcomes
            return float(n) * math.log(2)  # Same for uniform
        depth = compute_depth(renyi, ground, max_k=3)
        print(f"  Rényi(α={alpha}): depth = {'≥3' if depth >= 3 else depth}")

    # Subadditive but not modular
    def subadditive_fn(s):
        if len(s) == 0:
            return 0.0
        return math.log(1 + len(s))

    depth = compute_depth(subadditive_fn, ground, max_k=3)
    print(f"\n  g(s) = log(1+|s|) (concave of cardinality)")
    print(f"  Depth = {depth}")


# ============================================================
# APPLICATION 3: Network Reliability
# ============================================================

def app_network():
    """Analyze network reliability functions."""
    print("\n" + "=" * 60)
    print("APPLICATION 3: Connectivity / Network Functions")
    print("=" * 60)

    ground = {0, 1, 2}
    print(f"\nGround set: {sorted(ground)}")

    # Coverage function: f(s) = |∪ N(i) for i in s|
    # On a simple graph with edges 0-1, 1-2
    neighbors = {0: {0, 1}, 1: {0, 1, 2}, 2: {1, 2}}

    def coverage(s):
        covered = set()
        for i in s:
            covered |= neighbors[i]
        return float(len(covered))

    depth = compute_depth(coverage, ground, max_k=3)
    print(f"\n  Coverage (path 0-1-2): depth = {depth}")
    print(f"  (submodular → defect ≤ 0, hence NOT supermodular)")

    # Negative coverage = supermodular
    neg_coverage: SetFn = lambda s: -coverage(s)
    depth = compute_depth(neg_coverage, ground, max_k=3)
    print(f"  -Coverage: depth = {depth}")


# ============================================================
# APPLICATION 4: Detecting Geometry
# ============================================================

def app_detect_geometry():
    """Use depth as a geometric invariant."""
    print("\n" + "=" * 60)
    print("APPLICATION 4: Depth as Geometric Invariant")
    print("=" * 60)

    ground = {0, 1, 2}
    print(f"\nGround set: {sorted(ground)}")
    print(f"\nComparing function families by tropical Hodge depth:")

    families = [
        ("Modular (linear)", lambda w: lambda s: sum(w[i] for i in s),
         [{0: 1.0, 1: 2.0, 2: 3.0}]),
        ("Convex polynomial", None,
         [lambda s: float(len(s)**2),
          lambda s: float(len(s)**3)]),
    ]

    print(f"\n  {'Function':<30} {'Depth':>6}")
    print("  " + "-" * 38)

    # Modular
    for w in [{0: 1, 1: 2, 2: 3}, {0: 1, 1: 1, 2: 1}]:
        g: SetFn = lambda s, w=w: float(sum(w.get(i, 0) for i in s))
        d = compute_depth(g, ground, max_k=3)
        tag = f"≥3" if d >= 3 else str(d)
        print(f"  Σw_i (w={list(w.values())}){'':<10} {tag:>5}")

    # Polynomial in |s|
    for name, fn in [
        ("|s|", lambda s: float(len(s))),
        ("|s|²", lambda s: float(len(s)**2)),
        ("|s|³", lambda s: float(len(s)**3)),
        ("|s|⁴", lambda s: float(len(s)**4)),
    ]:
        d = compute_depth(fn, ground, max_k=3)
        tag = f"≥3" if d >= 3 else str(d)
        print(f"  {name:<28} {tag:>5}")

    # Exponential
    for c in [0.5, 1.0, 2.0]:
        g: SetFn = lambda s, c=c: c ** len(s)
        d = compute_depth(g, ground, max_k=3)
        tag = f"≥3" if d >= 3 else str(d)
        print(f"  {c}^|s|{'':<22} {tag:>5}")


if __name__ == "__main__":
    app_matroid_analysis()
    app_entropy()
    app_network()
    app_detect_geometry()

    print("\n" + "=" * 60)
    print("All applications completed.")
    print("=" * 60)


#!/usr/bin/env python3
"""
demo.py — Tropical Hodge Depth: Interactive Demonstrations

Demonstrates the tropical Hodge depth invariant computed from iterated
supermodularity of set functions. Constructs small examples over finite
ground sets, computes depth values, and compares families of functions.

Usage:
    python demo.py
"""

from itertools import combinations
import math


def powerset(ground):
    """Generate all subsets of a ground set as frozensets."""
    elems = list(ground)
    n = len(elems)
    for i in range(1 << n):
        yield frozenset(elems[j] for j in range(n) if i & (1 << j))


def supermod_defect(g, s, t):
    """Compute g(s∪t) + g(s∩t) - g(s) - g(t)."""
    return g(s | t) + g(s & t) - g(s) - g(t)


def elem_diff(g, a):
    """Discrete difference: s ↦ g(s ∪ {a}) - g(s)."""
    def diff_fn(s):
        return g(s | frozenset([a])) - g(s)
    return diff_fn


def check_supermod_order_0(g, subsets):
    """Check order-0 supermodularity."""
    for s in subsets:
        for t in subsets:
            d = supermod_defect(g, s, t)
            if d < -1e-12:
                return False
    return True


def check_supermod_order(k, g, ground, subsets=None):
    """Check if g has SupermodularOrder k over the given ground set."""
    if subsets is None:
        subsets = list(powerset(ground))

    if k == 0:
        return check_supermod_order_0(g, subsets)
    else:
        if not check_supermod_order(k - 1, g, ground, subsets):
            return False
        for a in ground:
            diff_g = elem_diff(g, a)
            if not check_supermod_order(k - 1, diff_g, ground, subsets):
                return False
        return True


def compute_tropical_hodge_depth(g, ground, max_k=4):
    """Compute the tropical Hodge depth of g over ground, up to max_k."""
    subsets = list(powerset(ground))
    depth = -1
    for k in range(max_k + 1):
        if check_supermod_order(k, g, ground, subsets):
            depth = k
        else:
            break
    return depth


# ============================================================
# EXAMPLE FUNCTIONS
# ============================================================

def cardinality_fn(s):
    """g(s) = |s|."""
    return float(len(s))


def quadratic_fn(s):
    """g(s) = |s|^2."""
    return float(len(s) ** 2)


def modular_fn(weights):
    """g(s) = sum of weights[i] for i in s. Modular function."""
    def g(s):
        return sum(weights.get(a, 0) for a in s)
    return g


def rank_defect_fn(rank_fn, c=1.0):
    """g(s) = c * |s| - rank(s). Supermodular if rank is submodular."""
    def g(s):
        return c * len(s) - rank_fn(s)
    return g


def uniform_matroid_rank(n, r):
    """Rank function of uniform matroid U_{r,n}."""
    def rank(s):
        return float(min(len(s), r))
    return rank


def log_fn(f):
    """g(s) = log(f(s)), for positive f."""
    def g(s):
        v = f(s)
        if v <= 0:
            return float('-inf')
        return math.log(v)
    return g


# ============================================================
# DEMONSTRATIONS
# ============================================================

def demo_basic():
    """Demo 1: Basic depth computation for simple functions."""
    print("=" * 60)
    print("DEMO 1: Basic Tropical Hodge Depth")
    print("=" * 60)

    ground = {0, 1, 2}
    max_k = 4
    print(f"\nGround set: {sorted(ground)}, max depth checked: {max_k}")

    functions = [
        ("|s|", cardinality_fn),
        ("|s|²", quadratic_fn),
        ("const 42", lambda s: 42.0),
        ("zero", lambda s: 0.0),
    ]

    for name, g in functions:
        depth = compute_tropical_hodge_depth(g, ground, max_k=max_k)
        tag = f"≥{max_k}" if depth >= max_k else str(depth)
        print(f"  g(s) = {name:12s}  →  depth = {tag}")


def demo_modular():
    """Demo 2: Modular functions have all orders."""
    print("\n" + "=" * 60)
    print("DEMO 2: Modular Functions (All Orders)")
    print("=" * 60)

    ground = {0, 1, 2}
    weights = {0: 1.0, 1: 2.0, 2: 3.0}
    g = modular_fn(weights)
    max_k = 4

    print(f"\nGround set: {sorted(ground)}")
    print(f"Weights: {weights}")
    depth = compute_tropical_hodge_depth(g, ground, max_k=max_k)
    tag = f"≥{max_k}" if depth >= max_k else str(depth)
    print(f"Depth = {tag} (modular → expected: all orders)")

    subsets = list(powerset(ground))
    max_defect = max(abs(supermod_defect(g, s, t))
                     for s in subsets for t in subsets)
    print(f"Max |defect|: {max_defect:.2e}")


def demo_matroid_rank():
    """Demo 3: Matroid rank-defect functions."""
    print("\n" + "=" * 60)
    print("DEMO 3: Matroid Rank-Defect Functions")
    print("=" * 60)

    ground = {0, 1, 2}
    max_k = 3
    print(f"\nGround set: {sorted(ground)}, max depth: {max_k}")

    for r in range(1, len(ground) + 1):
        rank = uniform_matroid_rank(len(ground), r)
        g = rank_defect_fn(rank)
        depth = compute_tropical_hodge_depth(g, ground, max_k=max_k)
        tag = f"≥{max_k}" if depth >= max_k else str(depth)
        print(f"  U({r},{len(ground)}):  g(s) = |s| - min(|s|,{r})  →  depth = {tag}")


def demo_tropical_bridge():
    """Demo 4: Tropical bridge — log-supermodularity ↔ supermodularity of log."""
    print("\n" + "=" * 60)
    print("DEMO 4: Tropical Bridge (log ↔ exp)")
    print("=" * 60)

    ground = {0, 1, 2}
    max_k = 3

    # f(s) = exp(|s|), so log(f) = |s| (modular → all orders)
    f1 = lambda s: math.exp(len(s))
    g1 = log_fn(f1)
    depth1 = compute_tropical_hodge_depth(g1, ground, max_k=max_k)

    # f(s) = exp(|s|²), so log(f) = |s|² (supermodular)
    f2 = lambda s: math.exp(len(s)**2)
    g2 = log_fn(f2)
    depth2 = compute_tropical_hodge_depth(g2, ground, max_k=max_k)

    print(f"\nGround set: {sorted(ground)}")
    print(f"  f(s) = exp(|s|)   → depth of log(f) = {depth1}")
    print(f"  f(s) = exp(|s|²)  → depth of log(f) = {depth2}")

    # Verify bridge: log-supermodularity check
    subsets = list(powerset(ground))
    bridge_ok = all(
        f1(s) * f1(t) <= f1(s | t) * f1(s & t) + 1e-10
        for s in subsets for t in subsets
    )
    print(f"  exp(|s|) is log-supermodular: {bridge_ok}")


def demo_cone_property():
    """Demo 5: Cone property — nonneg linear combinations preserve depth."""
    print("\n" + "=" * 60)
    print("DEMO 5: Cone Property (Nonneg Linear Combos)")
    print("=" * 60)

    ground = {0, 1, 2}
    max_k = 3

    g1 = cardinality_fn
    g2 = quadratic_fn

    depth1 = compute_tropical_hodge_depth(g1, ground, max_k=max_k)
    depth2 = compute_tropical_hodge_depth(g2, ground, max_k=max_k)

    print(f"\nGround set: {sorted(ground)}")
    print(f"  g₁ = |s|   depth = {depth1}")
    print(f"  g₂ = |s|²  depth = {depth2}")

    for a, b in [(1.0, 0.0), (0.0, 1.0), (0.5, 0.5), (2.0, 1.0)]:
        combo = lambda s, a=a, b=b: a * g1(s) + b * g2(s)
        depth = compute_tropical_hodge_depth(combo, ground, max_k=max_k)
        print(f"  {a}·g₁ + {b}·g₂  →  depth = {depth}  (min components = {min(depth1, depth2)})")


def demo_depth_table():
    """Demo 6: Compare depths across function families."""
    print("\n" + "=" * 60)
    print("DEMO 6: Depth Comparison Table")
    print("=" * 60)

    ground = {0, 1, 2}
    max_k = 3

    functions = [
        ("|s|", cardinality_fn),
        ("|s|²", quadratic_fn),
        ("2|s|+1", lambda s: 2 * len(s) + 1),
        ("|s|³", lambda s: float(len(s) ** 3)),
        ("2^|s|", lambda s: float(2 ** len(s))),
    ]

    print(f"\nGround set: {sorted(ground)}, max depth: {max_k}")
    print(f"\n{'Function':<12} {'Depth':>6}")
    print("-" * 20)
    for name, g in functions:
        depth = compute_tropical_hodge_depth(g, ground, max_k=max_k)
        tag = f"≥{max_k}" if depth >= max_k else str(depth)
        print(f"  {name:<10} {tag:>5}")


if __name__ == "__main__":
    demo_basic()
    demo_modular()
    demo_matroid_rank()
    demo_tropical_bridge()
    demo_cone_property()
    demo_depth_table()

    print("\n" + "=" * 60)
    print("All demos completed successfully.")
    print("=" * 60)


#!/usr/bin/env python3
"""
Visualization 1: Tropical Hodge Depth Heatmap

Visualizes the supermodularity defect landscape for different set functions
on a ground set of size 3. Shows how the defect pattern changes across
function families, with depth indicated by color intensity.

The heatmap shows defect values Δ(g; S, T) for all pairs (S, T) of subsets,
revealing the structure that determines tropical Hodge depth.
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.colors as mcolors
import math


def powerset(n):
    """Generate all subsets of {0,...,n-1} as frozensets, sorted by size."""
    result = []
    for i in range(1 << n):
        s = frozenset(j for j in range(n) if i & (1 << j))
        result.append(s)
    return sorted(result, key=lambda s: (len(s), sorted(s)))


def supermod_defect(g, s, t):
    return g(s | t) + g(s & t) - g(s) - g(t)


def elem_diff(g, a):
    singleton = frozenset([a])
    return lambda s: g(s | singleton) - g(s)


def check_order(k, g, subsets, ground):
    if k == 0:
        return all(supermod_defect(g, s, t) >= -1e-12
                   for s in subsets for t in subsets)
    if not check_order(k - 1, g, subsets, ground):
        return False
    return all(check_order(k - 1, elem_diff(g, a), subsets, ground)
               for a in ground)


def compute_depth(g, n, max_k=4):
    ground = set(range(n))
    subsets = powerset(n)
    depth = -1
    for k in range(max_k + 1):
        if check_order(k, g, subsets, ground):
            depth = k
        else:
            break
    return depth


def set_label(s):
    if not s:
        return "∅"
    return "{" + ",".join(str(x) for x in sorted(s)) + "}"


n = 3
subsets = powerset(n)
labels = [set_label(s) for s in subsets]

functions = {
    "|S| (cardinality)": lambda s: float(len(s)),
    "|S|² (quadratic)": lambda s: float(len(s)**2),
    "2^|S| (exponential)": lambda s: float(2**len(s)),
    "Σwᵢ (modular)": lambda s: float(sum(i + 1 for i in s)),
}

fig, axes = plt.subplots(2, 2, figsize=(14, 12))
fig.suptitle("Supermodularity Defect Heatmaps\n"
             "Δ(g; S, T) = g(S∪T) + g(S∩T) − g(S) − g(T)",
             fontsize=14, fontweight='bold')

for idx, (name, g) in enumerate(functions.items()):
    ax = axes[idx // 2][idx % 2]

    matrix = np.zeros((len(subsets), len(subsets)))
    for i, s in enumerate(subsets):
        for j, t in enumerate(subsets):
            matrix[i, j] = supermod_defect(g, s, t)

    depth = compute_depth(g, n, max_k=4)
    depth_str = f"≥4" if depth >= 4 else str(depth)

    vmax = max(abs(matrix.max()), abs(matrix.min()), 0.1)
    cmap = plt.cm.RdYlGn
    norm = mcolors.TwoSlopeNorm(vmin=-vmax, vcenter=0, vmax=vmax)

    im = ax.imshow(matrix, cmap=cmap, norm=norm, aspect='equal')
    ax.set_xticks(range(len(labels)))
    ax.set_xticklabels(labels, rotation=45, ha='right', fontsize=8)
    ax.set_yticks(range(len(labels)))
    ax.set_yticklabels(labels, fontsize=8)
    ax.set_title(f"{name}\nDepth = {depth_str}", fontsize=11)
    ax.set_xlabel("T")
    ax.set_ylabel("S")

    plt.colorbar(im, ax=ax, shrink=0.8, label="Defect Δ(g; S, T)")

    for i in range(len(subsets)):
        for j in range(len(subsets)):
            val = matrix[i, j]
            color = 'black' if abs(val) < vmax * 0.6 else 'white'
            if abs(val) > 0.01:
                ax.text(j, i, f"{val:.1f}", ha='center', va='center',
                        fontsize=6, color=color)

plt.tight_layout()
plt.savefig("viz_depth_heatmap.png", dpi=150, bbox_inches='tight')
print("Saved viz_depth_heatmap.png")


#!/usr/bin/env python3
"""
Visualization 2: Nested Cones of the Tropical Hodge Hierarchy

Shows the nested cone structure of the supermodularity hierarchy
in a 2D projection. For a ground set of size 2 (so the function
is determined by g(∅), g({0}), g({1}), g({0,1})), we fix g(∅)=0
and g({0,1})=c (parameterized), then visualize the feasible region
for g({0}), g({1}) at each depth level.

This creates a diagram showing how higher depths restrict the
function space to smaller and smaller sub-cones.
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches


def check_supermod_order_2d(k, vals):
    """
    Check SupermodularOrder k for g on ground set {0,1}.
    vals = (g_empty, g_0, g_1, g_01) = (g(∅), g({0}), g({1}), g({0,1}))
    """
    g_e, g_0, g_1, g_01 = vals

    # All subsets: ∅, {0}, {1}, {0,1}
    # Defects to check for order 0:
    # (∅,∅): 0  (∅,{0}): 0  (∅,{1}): 0  (∅,{0,1}): 0
    # ({0},{0}): 0  ({0},{1}): g_01 + g_e - g_0 - g_1
    # ({0},{0,1}): 0  ({1},{0,1}): 0
    # ({1},{1}): 0  ({0,1},{0,1}): 0

    defect_01 = g_01 + g_e - g_0 - g_1  # The only non-trivial defect

    if k == 0:
        return defect_01 >= -1e-12

    if k >= 1:
        if defect_01 < -1e-12:
            return False
        # elemDiff with 0: Δ₀g(s) = g(s∪{0}) - g(s)
        # Δ₀g(∅) = g_0 - g_e, Δ₀g({0}) = 0, Δ₀g({1}) = g_01 - g_1, Δ₀g({0,1}) = 0
        d0_e = g_0 - g_e
        d0_1 = g_01 - g_1
        # defect of Δ₀g at ({1}, ∅): actually for order 0 of Δ₀g, all pairs
        # The only non-trivial: sets {1} and ∅ (or {1} and {0}, etc.)
        # Δ₀g on subsets of {0,1}: value at ∅=d0_e, {0}=0, {1}=d0_1, {0,1}=0
        # defect({0},{1}) = 0 + d0_e - 0 - d0_1 = d0_e - d0_1 = (g_0-g_e)-(g_01-g_1)
        defect_d0 = (g_0 - g_e) - (g_01 - g_1)  # = g_0 + g_1 - g_e - g_01 = -defect_01
        # Also defect(∅, {0,1}) of Δ₀g = 0 + 0 - d0_e - 0 = -d0_e ... wait
        # More carefully: subsets are ∅,{0},{1},{0,1}
        # Δ₀g: ∅→d0_e, {0}→0, {1}→d0_1, {0,1}→0
        # defect(s,t) for Δ₀g:
        # ({0},{1}): Δ₀g({0,1}) + Δ₀g(∅) - Δ₀g({0}) - Δ₀g({1}) = 0+d0_e-0-d0_1
        # This is (g_0-g_e)-(g_01-g_1) = -(g_01+g_e-g_0-g_1) = -defect_01
        # For this to be ≥ 0, need defect_01 ≤ 0.
        # Combined with defect_01 ≥ 0, need defect_01 = 0.

        # elemDiff with 1: symmetric
        # defect of Δ₁g at ({0},{∅}) is also -defect_01

        if k >= 1:
            return abs(defect_01) < 1e-12  # need defect = 0 for order 1

    return abs(defect_01) < 1e-12


fig, ax = plt.subplots(1, 1, figsize=(10, 8))

# Fix g(∅) = 0
g_e = 0.0

# We'll plot g({0}) on x-axis, g({1}) on y-axis
# and color points by the maximum depth they achieve

x_range = np.linspace(-3, 3, 300)
y_range = np.linspace(-3, 3, 300)
X, Y = np.meshgrid(x_range, y_range)

# For various values of g({0,1})
g_01 = 2.0  # Fix g({0,1}) = 2

depth_map = np.full(X.shape, -1.0)

for i in range(X.shape[0]):
    for j in range(X.shape[1]):
        g_0 = X[i, j]
        g_1 = Y[i, j]
        vals = (g_e, g_0, g_1, g_01)

        # Check orders
        if check_supermod_order_2d(0, vals):
            depth_map[i, j] = 0
            if check_supermod_order_2d(1, vals):
                depth_map[i, j] = 1
        # Depth ≥ 1 means modular (defect = 0)

# Create a custom colormap
colors = ['#f0f0f0', '#4CAF50', '#1565C0']
bounds = [-0.5, -0.01, 0.5, 1.5]
cmap = plt.cm.colors.ListedColormap(colors)
norm = plt.cm.colors.BoundaryNorm(bounds, cmap.N)

im = ax.pcolormesh(X, Y, depth_map, cmap=cmap, norm=norm, shading='auto')

# Draw the boundary: defect = 0 line
# defect = g_01 + g_e - g_0 - g_1 = 2 - x - y ≥ 0
# i.e., x + y ≤ 2
ax.plot(x_range, 2 - x_range, 'k-', linewidth=2, label='Depth 0 boundary: x+y=2')

# The modular line is where defect = 0: x + y = 2
# Depth ≥ 1 region is the LINE x + y = 2

ax.set_xlabel("g({0})", fontsize=12)
ax.set_ylabel("g({1})", fontsize=12)
ax.set_title(
    "Nested Cones of the Tropical Hodge Hierarchy\n"
    f"Ground set {{0,1}}, g(∅)={g_e}, g({{0,1}})={g_01}",
    fontsize=13, fontweight='bold'
)

# Legend
legend_patches = [
    mpatches.Patch(color=colors[0], label='Not supermodular (depth < 0)'),
    mpatches.Patch(color=colors[1], label='Depth 0 (supermodular)'),
    mpatches.Patch(color=colors[2], label='Depth ≥ 1 (modular, on line x+y=2)'),
]
ax.legend(handles=legend_patches, loc='upper right', fontsize=10)

ax.set_xlim(-3, 3)
ax.set_ylim(-3, 3)
ax.set_aspect('equal')
ax.grid(True, alpha=0.3)

# Annotate the modular line
ax.annotate('Modular line\n(infinite depth)',
            xy=(0, 2), xytext=(-2.5, 0.5),
            fontsize=10, color='#1565C0',
            arrowprops=dict(arrowstyle='->', color='#1565C0'))

# Annotate the supermodular cone
ax.annotate('Supermodular cone\n(depth ≥ 0)',
            xy=(-1, 1), xytext=(-2.5, -1.5),
            fontsize=10, color='#4CAF50',
            arrowprops=dict(arrowstyle='->', color='#4CAF50'))

plt.tight_layout()
plt.savefig("viz_hierarchy_cones.png", dpi=150, bbox_inches='tight')
print("Saved viz_hierarchy_cones.png")


#!/usr/bin/env python3
"""
Visualization 3: Matroid Rank-Defect Depth Comparison

Bar chart comparing the tropical Hodge depth of rank-defect functions
for different matroids on a ground set of size 3. Illustrates how
depth detects matroid structure.
"""

import numpy as np
import matplotlib.pyplot as plt
import math


def powerset(n):
    elems = list(range(n))
    result = []
    for i in range(1 << n):
        s = frozenset(j for j in range(n) if i & (1 << j))
        result.append(s)
    return result


def supermod_defect(g, s, t):
    return g(s | t) + g(s & t) - g(s) - g(t)


def elem_diff(g, a):
    singleton = frozenset([a])
    return lambda s: g(s | singleton) - g(s)


def check_order(k, g, subsets, ground):
    if k == 0:
        return all(supermod_defect(g, s, t) >= -1e-12
                   for s in subsets for t in subsets)
    if not check_order(k - 1, g, subsets, ground):
        return False
    return all(check_order(k - 1, elem_diff(g, a), subsets, ground)
               for a in ground)


def compute_depth(g, n, max_k=4):
    ground = set(range(n))
    subsets = powerset(n)
    depth = -1
    for k in range(max_k + 1):
        if check_order(k, g, subsets, ground):
            depth = k
        else:
            break
    return depth


# Ground set size
n = 3
max_k = 4

# Define various matroid-like functions
matroids = []

# Uniform matroids U(r,3)
for r in range(4):
    name = f"U({r},{n})"
    rank_fn = lambda s, r=r: float(min(len(s), r))
    defect_fn = lambda s, rf=rank_fn: float(len(s)) - rf(s)
    depth = compute_depth(defect_fn, n, max_k=max_k)
    matroids.append((name, depth, f"|S|-min(|S|,{r})"))

# Cardinality (free matroid rank defect = 0)
card_fn = lambda s: float(len(s))
depth = compute_depth(card_fn, n, max_k=max_k)
matroids.append(("|S| (card)", depth, "modular"))

# Quadratic
sq_fn = lambda s: float(len(s)**2)
depth = compute_depth(sq_fn, n, max_k=max_k)
matroids.append(("|S|²", depth, "convex"))

# Modular with weights
mod_fn = lambda s: float(sum(i + 1 for i in s))
depth = compute_depth(mod_fn, n, max_k=max_k)
matroids.append(("Σ(i+1)", depth, "modular"))

# Constant
const_fn = lambda s: 5.0
depth = compute_depth(const_fn, n, max_k=max_k)
matroids.append(("const 5", depth, "constant"))

# Create the bar chart
fig, ax = plt.subplots(figsize=(12, 7))

names = [m[0] for m in matroids]
depths = [m[1] for m in matroids]
descs = [m[2] for m in matroids]

# Color by depth
colors = []
for d in depths:
    if d >= max_k:
        colors.append('#1565C0')  # Deep blue for infinite depth
    elif d == 0:
        colors.append('#E53935')  # Red for depth 0
    else:
        colors.append('#FFA726')  # Orange for intermediate

bars = ax.bar(range(len(names)), depths, color=colors, edgecolor='black',
              linewidth=0.5, alpha=0.85)

# Add value labels
for i, (bar, d, desc) in enumerate(zip(bars, depths, descs)):
    label = f"≥{max_k}" if d >= max_k else str(d)
    ax.text(bar.get_x() + bar.get_width()/2., bar.get_height() + 0.1,
            label, ha='center', va='bottom', fontweight='bold', fontsize=11)
    ax.text(bar.get_x() + bar.get_width()/2., -0.35,
            desc, ha='center', va='top', fontsize=8, color='gray',
            fontstyle='italic')

ax.set_xticks(range(len(names)))
ax.set_xticklabels(names, rotation=30, ha='right', fontsize=10)
ax.set_ylabel("Tropical Hodge Depth", fontsize=12)
ax.set_title(
    "Tropical Hodge Depth of Set Functions\n"
    f"Ground set size n={n}",
    fontsize=14, fontweight='bold'
)
ax.set_ylim(-0.5, max_k + 1)
ax.axhline(y=0, color='gray', linewidth=0.5)

# Add a legend for colors
from matplotlib.patches import Patch
legend_elements = [
    Patch(facecolor='#E53935', edgecolor='black', label='Depth 0 (barely supermodular)'),
    Patch(facecolor='#FFA726', edgecolor='black', label='Intermediate depth'),
    Patch(facecolor='#1565C0', edgecolor='black', label=f'Depth ≥{max_k} (all orders)'),
]
ax.legend(handles=legend_elements, loc='upper right', fontsize=10)

# Add annotation
ax.annotate(
    'Free/modular functions achieve\nmaximum depth (all orders)',
    xy=(4, max_k), xytext=(2, max_k - 0.8),
    fontsize=9, color='#1565C0',
    arrowprops=dict(arrowstyle='->', color='#1565C0', lw=1.5),
    bbox=dict(boxstyle='round,pad=0.3', facecolor='#E3F2FD', edgecolor='#1565C0')
)

ax.annotate(
    'Constrained matroids have\ndepth 0 — structure detected!',
    xy=(1, 0), xytext=(3.5, 1.5),
    fontsize=9, color='#E53935',
    arrowprops=dict(arrowstyle='->', color='#E53935', lw=1.5),
    bbox=dict(boxstyle='round,pad=0.3', facecolor='#FFEBEE', edgecolor='#E53935')
)

plt.tight_layout()
plt.savefig("viz_matroid_depths.png", dpi=150, bbox_inches='tight')
print("Saved viz_matroid_depths.png")
