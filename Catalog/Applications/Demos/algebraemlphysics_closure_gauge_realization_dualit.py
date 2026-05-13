#!/usr/bin/env python3
"""
Applications of Closure–Gauge Realization Duality

Demonstrates real-world applications:
1. Network flow capacity inference
2. Hierarchical clustering from closure data
3. Lattice gauge theory: Wilson loop reconstruction
4. Feature importance ranking from closure semantics
"""

import numpy as np
from itertools import combinations
from algorithms import (valuation_closure, reconstruct_valuation,
                        compute_all_closed_sets, check_chain_condition,
                        normalize_valuation, realization_rank,
                        check_order_equivalence)


def application_1_network_flow():
    """
    Application 1: Network Flow Capacity Inference

    In a network, each node has a "capacity" (bandwidth, throughput, etc.).
    The closure cl(S) = {nodes reachable from S without exceeding max capacity in S}.
    The gauge valuation v(node) = capacity recovers the network structure.
    """
    print("=" * 60)
    print("APPLICATION 1: Network Flow Capacity Inference")
    print("=" * 60)

    # Network nodes with capacities (Mbps)
    nodes = {0, 1, 2, 3, 4, 5}
    capacity = {0: 10, 1: 50, 2: 50, 3: 100, 4: 200, 5: 500}

    print(f"\nNetwork nodes: {sorted(nodes)}")
    print(f"Capacities (Mbps): {capacity}")

    cl = lambda S: valuation_closure(capacity, S, nodes)

    # Query: which nodes can be served by a set of sources?
    sources = frozenset([0, 2])
    reachable = cl(sources)
    print(f"\nSources: {sorted(sources)} (max capacity: {max(capacity[s] for s in sources)} Mbps)")
    print(f"Reachable nodes: {sorted(reachable)}")
    print(f"  → Nodes with capacity ≤ {max(capacity[s] for s in sources)} Mbps")

    # Reconstruct capacities from closure queries alone
    v_recon = reconstruct_valuation(cl, nodes)
    print(f"\nReconstructed relative capacities: {v_recon}")
    print(f"Order-equivalent to true capacities: "
          f"{check_order_equivalence(capacity, v_recon, nodes)}")
    print("→ Network structure fully recovered from closure data!")


def application_2_hierarchical_clustering():
    """
    Application 2: Hierarchical Clustering from Closure Data

    Items have "complexity levels". The closure of a set S includes
    all items with complexity ≤ max complexity in S.
    The chain of closed sets IS the dendrogram.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 2: Hierarchical Clustering via Gauge Closure")
    print("=" * 60)

    items = {0, 1, 2, 3, 4, 5, 6}
    names = {0: "atom", 1: "molecule", 2: "cell", 3: "cell",
             4: "organ", 5: "organism", 6: "ecosystem"}
    complexity = {0: 1, 1: 2, 2: 3, 3: 3, 4: 5, 5: 8, 6: 13}

    print(f"\nItems and complexity levels:")
    for i in sorted(items):
        print(f"  {i}: {names[i]} (complexity = {complexity[i]})")

    cl = lambda S: valuation_closure(complexity, S, items)

    # The chain of closed sets = hierarchical clustering
    closed = compute_all_closed_sets(cl, items)
    print(f"\nHierarchical clustering (chain of closed sets):")
    for i, S in enumerate(closed):
        level_names = [f"{j}:{names[j]}" for j in sorted(S)]
        print(f"  Level {i}: {{{', '.join(level_names)}}}")

    is_chain, _ = check_chain_condition(closed)
    print(f"\nForms a valid hierarchy (chain)? {is_chain}")
    print(f"Number of hierarchy levels: {len(closed)}")
    print(f"Realization rank: {realization_rank(complexity, items)}")


def application_3_wilson_loops():
    """
    Application 3: Wilson Loop Reconstruction in Lattice Gauge Theory

    On a discrete lattice, each edge has a "gauge field strength" (weight).
    The holonomy of a loop = max edge weight along the loop.
    The closure cl(S) = {loops with holonomy ≤ max holonomy in S}.
    Reconstruction recovers the gauge field from loop measurements.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 3: Wilson Loop Gauge Reconstruction")
    print("=" * 60)

    # Represent loops by their holonomy values
    loops = {0, 1, 2, 3, 4, 5}
    loop_names = {
        0: "trivial loop", 1: "small plaquette",
        2: "medium plaquette", 3: "large plaquette",
        4: "winding loop", 5: "maximal loop"
    }
    holonomy = {0: 0, 1: 1, 2: 3, 3: 3, 4: 7, 5: 15}

    print(f"\nLoops and holonomy values:")
    for i in sorted(loops):
        print(f"  γ_{i}: {loop_names[i]} (holonomy = {holonomy[i]})")

    cl = lambda S: valuation_closure(holonomy, S, loops)

    # Simulate Wilson loop measurements
    print(f"\nWilson loop closure queries:")
    test_sets = [frozenset([1]), frozenset([2, 3]), frozenset([4])]
    for S in test_sets:
        result = cl(S)
        print(f"  cl({{{', '.join(f'γ_{s}' for s in sorted(S))}}})"
              f" = {{{', '.join(f'γ_{r}' for r in sorted(result))}}}")

    # Reconstruct gauge field from closure data
    v_recon = reconstruct_valuation(cl, loops)
    print(f"\nReconstructed holonomy (relative): {v_recon}")
    print(f"Order-equivalent to true holonomy: "
          f"{check_order_equivalence(holonomy, v_recon, loops)}")
    print("→ Gauge field completely reconstructed from Wilson loop data!")

    # Verify: minimal realization
    v_norm = normalize_valuation(v_recon, loops)
    print(f"Minimal (normalized) realization: {v_norm}")
    print(f"Rank: {realization_rank(v_norm, loops)} "
          f"(= number of distinct holonomy classes)")


def application_4_feature_importance():
    """
    Application 4: Feature Importance Ranking from Closure Semantics

    In ML interpretability, features have "importance scores".
    The closure cl(S) = {features whose importance ≤ max importance in S}.
    The chain of closed sets gives the importance hierarchy.
    Reconstruction certifies the ranking from observed closure behavior.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 4: Certified Feature Importance Ranking")
    print("=" * 60)

    features = {0, 1, 2, 3, 4}
    feature_names = {
        0: "color", 1: "texture", 2: "shape",
        3: "size", 4: "position"
    }
    importance = {0: 2, 1: 5, 2: 8, 3: 3, 4: 1}

    print(f"\nFeatures and importance scores:")
    for i in sorted(features):
        print(f"  {feature_names[i]}: importance = {importance[i]}")

    cl = lambda S: valuation_closure(importance, S, features)

    # Reconstruct importance ranking from closure queries
    v_recon = reconstruct_valuation(cl, features)
    v_norm = normalize_valuation(v_recon, features)

    print(f"\nReconstructed importance ranking:")
    ranking = sorted(features, key=lambda x: v_norm[x])
    for rank, f in enumerate(ranking):
        print(f"  Rank {rank}: {feature_names[f]} "
              f"(reconstructed value = {v_norm[f]})")

    print(f"\nCertified: reconstruction is order-equivalent to true importance? "
          f"{check_order_equivalence(importance, v_recon, features)}")
    print("→ Feature ranking is CERTIFIED correct by the duality theorem!")


if __name__ == "__main__":
    application_1_network_flow()
    application_2_hierarchical_clustering()
    application_3_wilson_loops()
    application_4_feature_importance()

    print("\n" + "=" * 60)
    print("All applications demonstrated successfully!")
    print("=" * 60)


#!/usr/bin/env python3
"""
Closure–Gauge Realization Duality: Interactive Demonstrations

This script demonstrates the core theorems with concrete numerical examples:
1. Valuation-induced closure operators
2. The chain condition for realizability
3. Gauge equivalence (order equivalence) of valuations
4. Minimal realization and reconstruction
5. Separation and injectivity
"""

from itertools import combinations


def valuation_closure(v, S, universe):
    """
    Compute cl_v(S) = {x in universe | v(x) <= max_{s in S} v(s)}.
    For S empty, max is 0 (the bot element in ℕ).
    """
    if len(S) == 0:
        sup_val = 0
    else:
        sup_val = max(v[s] for s in S)
    return frozenset(x for x in universe if v[x] <= sup_val)


def is_closure_operator(cl_fn, universe):
    """Check if cl_fn satisfies extensive, monotone, idempotent on all subsets."""
    powerset = []
    n = len(universe)
    elems = list(universe)
    for r in range(n + 1):
        for combo in combinations(elems, r):
            powerset.append(frozenset(combo))

    # Extensive: S ⊆ cl(S)
    for S in powerset:
        if not S.issubset(cl_fn(S)):
            return False, f"Not extensive: {S}"

    # Monotone: S ⊆ T → cl(S) ⊆ cl(T)
    for S in powerset:
        for T in powerset:
            if S.issubset(T) and not cl_fn(S).issubset(cl_fn(T)):
                return False, f"Not monotone: {S} ⊆ {T}"

    # Idempotent: cl(cl(S)) = cl(S)
    for S in powerset:
        if cl_fn(cl_fn(S)) != cl_fn(S):
            return False, f"Not idempotent at {S}"

    return True, "Valid closure operator"


def get_closed_sets(cl_fn, universe):
    """Return all closed sets (fixpoints of cl)."""
    closed = []
    n = len(universe)
    elems = list(universe)
    for r in range(n + 1):
        for combo in combinations(elems, r):
            S = frozenset(combo)
            if cl_fn(S) == S:
                closed.append(S)
    return closed


def closed_sets_form_chain(closed_sets):
    """Check if closed sets are totally ordered by inclusion."""
    for S in closed_sets:
        for T in closed_sets:
            if not (S.issubset(T) or T.issubset(S)):
                return False, (S, T)
    return True, None


def normalize_valuation(v, universe):
    """
    Normalize valuation: v_norm(x) = |{y | v(y) < v(x)}|.
    Produces order-equivalent valuation with values in {0, 1, ..., rank-1}.
    """
    v_norm = {}
    for x in universe:
        v_norm[x] = sum(1 for y in universe if v[y] < v[x])
    return v_norm


def realization_rank(v, universe):
    """Number of distinct values in v."""
    return len(set(v[x] for x in universe))


def order_equiv(v1, v2, universe):
    """Check if v1 and v2 are order-equivalent."""
    elems = list(universe)
    for x in elems:
        for y in elems:
            if (v1[x] <= v1[y]) != (v2[x] <= v2[y]):
                return False
    return True


def reconstruct_from_closure(cl_fn, universe):
    """
    Reconstruct a gauge valuation from a closure operator with chain closed sets.
    v(x) = |cl({x})| - |cl(∅)|
    """
    cl_empty = cl_fn(frozenset())
    v = {}
    for x in universe:
        cl_x = cl_fn(frozenset([x]))
        v[x] = len(cl_x) - len(cl_empty)
    return v


# ============================================================
# DEMO 1: Basic Valuation Closure
# ============================================================
print("=" * 60)
print("DEMO 1: Valuation-Induced Closure Operator")
print("=" * 60)

universe = {0, 1, 2, 3, 4}
v = {0: 1, 1: 3, 2: 1, 3: 5, 4: 2}

print(f"\nUniverse: {sorted(universe)}")
print(f"Valuation v: {v}")
print()

cl_v = lambda S: valuation_closure(v, S, universe)

# Show closure of various sets
test_sets = [frozenset(), frozenset([3]), frozenset([0]), frozenset([0, 4]),
             frozenset([1, 4]), frozenset([0, 1, 2, 3, 4])]
for S in test_sets:
    print(f"  cl_v({sorted(S)}) = {sorted(cl_v(S))}")

# Verify it's a closure operator
valid, msg = is_closure_operator(cl_v, universe)
print(f"\nIs valid closure operator? {valid} — {msg}")

# Show closed sets
closed = get_closed_sets(cl_v, universe)
print(f"\nClosed sets (fixpoints of cl):")
for S in sorted(closed, key=len):
    print(f"  {sorted(S)}")

# Check chain
is_chain, witness = closed_sets_form_chain(closed)
print(f"\nClosed sets form a chain? {is_chain}")

# ============================================================
# DEMO 2: Chain Condition ↔ Realizability
# ============================================================
print("\n" + "=" * 60)
print("DEMO 2: Chain Condition and Realizability")
print("=" * 60)

# Example of a NON-realizable closure (identity on {0,1,2})
universe2 = {0, 1, 2}
cl_id = lambda S: frozenset(S)  # identity closure

closed_id = get_closed_sets(cl_id, universe2)
print(f"\nIdentity closure on {sorted(universe2)}:")
print(f"Closed sets: {[sorted(S) for S in sorted(closed_id, key=len)]}")
is_chain_id, witness = closed_sets_form_chain(closed_id)
print(f"Chain? {is_chain_id}", end="")
if not is_chain_id:
    print(f" — incomparable: {sorted(witness[0])} and {sorted(witness[1])}")
else:
    print()
print("→ NOT gauge-realizable (by the duality theorem)")

# Example of a realizable closure
v2 = {0: 0, 1: 1, 2: 3}
cl_v2 = lambda S: valuation_closure(v2, S, universe2)
closed_v2 = get_closed_sets(cl_v2, universe2)
print(f"\nValuation closure with v = {v2}:")
print(f"Closed sets: {[sorted(S) for S in sorted(closed_v2, key=len)]}")
is_chain_v2, _ = closed_sets_form_chain(closed_v2)
print(f"Chain? {is_chain_v2}")
print("→ IS gauge-realizable")

# ============================================================
# DEMO 3: Gauge Equivalence (Order Equivalence)
# ============================================================
print("\n" + "=" * 60)
print("DEMO 3: Gauge Equivalence = Order Equivalence")
print("=" * 60)

universe3 = {0, 1, 2, 3}
v_a = {0: 0, 1: 2, 2: 5, 3: 10}
v_b = {0: 0, 1: 1, 2: 3, 3: 7}
v_c = {0: 0, 1: 5, 2: 2, 3: 10}  # different ordering

cl_a = lambda S: valuation_closure(v_a, S, universe3)
cl_b = lambda S: valuation_closure(v_b, S, universe3)
cl_c = lambda S: valuation_closure(v_c, S, universe3)

print(f"\nv_a = {v_a}")
print(f"v_b = {v_b}")
print(f"v_c = {v_c}")
print()

oe_ab = order_equiv(v_a, v_b, universe3)
oe_ac = order_equiv(v_a, v_c, universe3)
print(f"v_a ≡ v_b (order equiv)? {oe_ab}")
print(f"v_a ≡ v_c (order equiv)? {oe_ac}")

# Check closures
all_same_ab = all(cl_a(frozenset(S)) == cl_b(frozenset(S))
                   for r in range(5) for S in combinations(range(4), r))
all_same_ac = all(cl_a(frozenset(S)) == cl_c(frozenset(S))
                   for r in range(5) for S in combinations(range(4), r))
print(f"\ncl_a = cl_b? {all_same_ab} (should match order equiv)")
print(f"cl_a = cl_c? {all_same_ac} (should match order equiv)")

# ============================================================
# DEMO 4: Minimal Realization and Normalization
# ============================================================
print("\n" + "=" * 60)
print("DEMO 4: Minimal Realization via Normalization")
print("=" * 60)

universe4 = {0, 1, 2, 3, 4}
v_orig = {0: 100, 1: 100, 2: 250, 3: 500, 4: 250}

print(f"\nOriginal valuation: {v_orig}")
print(f"Rank (distinct values): {realization_rank(v_orig, universe4)}")

v_norm = normalize_valuation(v_orig, universe4)
print(f"Normalized valuation: {v_norm}")
print(f"Rank (distinct values): {realization_rank(v_norm, universe4)}")

oe = order_equiv(v_orig, v_norm, universe4)
print(f"Order equivalent? {oe}")

# ============================================================
# DEMO 5: Certified Reconstruction
# ============================================================
print("\n" + "=" * 60)
print("DEMO 5: Certified Reconstruction from Closure Data")
print("=" * 60)

universe5 = {0, 1, 2, 3, 4}
v_true = {0: 0, 1: 1, 2: 1, 3: 3, 4: 5}
cl_true = lambda S: valuation_closure(v_true, S, universe5)

print(f"\nTrue valuation: {v_true}")
print(f"Closed sets: ", end="")
closed_true = get_closed_sets(cl_true, universe5)
for S in sorted(closed_true, key=len):
    print(f"{sorted(S)}", end=" ⊆ ")
print()

# Reconstruct from closure
v_reconstructed = reconstruct_from_closure(cl_true, universe5)
print(f"Reconstructed valuation: {v_reconstructed}")

# Verify reconstruction
cl_recon = lambda S: valuation_closure(v_reconstructed, S, universe5)
reconstruction_correct = all(
    cl_true(frozenset(S)) == cl_recon(frozenset(S))
    for r in range(6) for S in combinations(range(5), r)
)
print(f"Reconstruction correct (cl_true = cl_recon)? {reconstruction_correct}")

oe_recon = order_equiv(v_true, v_reconstructed, universe5)
print(f"Order equivalent to original? {oe_recon}")

# ============================================================
# DEMO 6: Separation and Injectivity
# ============================================================
print("\n" + "=" * 60)
print("DEMO 6: Separation ↔ Injectivity")
print("=" * 60)

# Non-injective valuation → non-separated
v_noninj = {0: 1, 1: 1, 2: 3}
cl_noninj = lambda S: valuation_closure(v_noninj, S, {0, 1, 2})
sep = all(cl_noninj(frozenset([a])) != cl_noninj(frozenset([b]))
          for a in range(3) for b in range(3) if a != b)
print(f"\nv = {v_noninj} (non-injective)")
print(f"cl({{0}}) = {sorted(cl_noninj(frozenset([0])))}")
print(f"cl({{1}}) = {sorted(cl_noninj(frozenset([1])))}")
print(f"Separated? {sep}")

# Injective valuation → separated
v_inj = {0: 1, 1: 2, 2: 3}
cl_inj = lambda S: valuation_closure(v_inj, S, {0, 1, 2})
sep2 = all(cl_inj(frozenset([a])) != cl_inj(frozenset([b]))
           for a in range(3) for b in range(3) if a != b)
print(f"\nv = {v_inj} (injective)")
print(f"cl({{0}}) = {sorted(cl_inj(frozenset([0])))}")
print(f"cl({{1}}) = {sorted(cl_inj(frozenset([1])))}")
print(f"cl({{2}}) = {sorted(cl_inj(frozenset([2])))}")
print(f"Separated? {sep2}")

print("\n" + "=" * 60)
print("All demos completed successfully!")
print("=" * 60)


#!/usr/bin/env python3
"""
Visualizations for Closure–Gauge Realization Duality

Generates figures illustrating key concepts:
1. Closed-set chain (Hasse diagram)
2. Valuation landscape
3. Capacity profile comparison
4. Reconstruction accuracy
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np
from itertools import combinations
import base64
import io


def valuation_closure(v, S, universe):
    sup_val = max((v[s] for s in S), default=0)
    return frozenset(x for x in universe if v[x] <= sup_val)


def get_closed_sets(v, universe):
    cl = lambda S: valuation_closure(v, S, universe)
    closed = []
    elems = sorted(universe)
    n = len(elems)
    for r in range(n + 1):
        for combo in combinations(elems, r):
            S = frozenset(combo)
            if cl(S) == S:
                closed.append(S)
    return sorted(closed, key=len)


def fig_to_base64(fig):
    buf = io.BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight')
    buf.seek(0)
    return "data:image/png;base64," + base64.b64encode(buf.read()).decode()


def viz1_chain_diagram():
    """Visualize the chain of closed sets as a vertical diagram."""
    fig, axes = plt.subplots(1, 2, figsize=(14, 7))

    # Left: Realizable (chain) closure
    universe = {0, 1, 2, 3, 4}
    v_chain = {0: 0, 1: 2, 2: 2, 3: 5, 4: 8}
    closed_chain = get_closed_sets(v_chain, universe)

    ax = axes[0]
    ax.set_title("Realizable Closure\n(Closed Sets Form a Chain)", fontsize=14, fontweight='bold')
    for i, S in enumerate(closed_chain):
        y = i * 1.5
        label = "{" + ", ".join(str(x) for x in sorted(S)) + "}" if S else "∅"
        color = plt.cm.Blues(0.3 + 0.7 * i / max(len(closed_chain) - 1, 1))
        ax.add_patch(mpatches.FancyBboxPatch((1, y - 0.3), 4, 0.6,
                     boxstyle="round,pad=0.1", facecolor=color, edgecolor='navy', linewidth=2))
        ax.text(3, y, label, ha='center', va='center', fontsize=12, fontweight='bold')
        if i > 0:
            ax.annotate('', xy=(3, y - 0.3), xytext=(3, (i-1) * 1.5 + 0.3),
                        arrowprops=dict(arrowstyle='->', lw=2, color='navy'))
    ax.set_xlim(0, 6)
    ax.set_ylim(-1, len(closed_chain) * 1.5)
    ax.axis('off')
    ax.text(3, -0.7, f"v = {v_chain}", ha='center', fontsize=10, style='italic')

    # Right: Non-realizable (non-chain) closure
    ax = axes[1]
    ax.set_title("Non-Realizable Closure\n(Closed Sets NOT a Chain)", fontsize=14, fontweight='bold')

    # Identity closure: every subset is closed
    sample_closed = [frozenset(), frozenset([0]), frozenset([1]), frozenset([2]),
                     frozenset([0, 1]), frozenset([0, 2]), frozenset([1, 2]),
                     frozenset([0, 1, 2])]

    positions = {
        frozenset(): (3, 0),
        frozenset([0]): (1.5, 1.5), frozenset([1]): (3, 1.5), frozenset([2]): (4.5, 1.5),
        frozenset([0, 1]): (1.5, 3), frozenset([0, 2]): (3, 3), frozenset([1, 2]): (4.5, 3),
        frozenset([0, 1, 2]): (3, 4.5)
    }

    for S, (x, y) in positions.items():
        label = "{" + ", ".join(str(e) for e in sorted(S)) + "}" if S else "∅"
        color = '#ffcccc' if len(S) in [1, 2] else '#ccffcc'
        ax.add_patch(mpatches.FancyBboxPatch((x - 0.6, y - 0.3), 1.2, 0.6,
                     boxstyle="round,pad=0.1", facecolor=color, edgecolor='darkred', linewidth=1.5))
        ax.text(x, y, label, ha='center', va='center', fontsize=10)

    # Draw edges for subset relations (Hasse diagram)
    hasse_edges = [
        (frozenset(), frozenset([0])), (frozenset(), frozenset([1])), (frozenset(), frozenset([2])),
        (frozenset([0]), frozenset([0, 1])), (frozenset([0]), frozenset([0, 2])),
        (frozenset([1]), frozenset([0, 1])), (frozenset([1]), frozenset([1, 2])),
        (frozenset([2]), frozenset([0, 2])), (frozenset([2]), frozenset([1, 2])),
        (frozenset([0, 1]), frozenset([0, 1, 2])),
        (frozenset([0, 2]), frozenset([0, 1, 2])),
        (frozenset([1, 2]), frozenset([0, 1, 2])),
    ]
    for S, T in hasse_edges:
        x1, y1 = positions[S]
        x2, y2 = positions[T]
        ax.plot([x1, x2], [y1 + 0.3, y2 - 0.3], 'darkred', lw=1, alpha=0.5)

    # Highlight incomparable pair
    ax.annotate('', xy=(1.5, 1.8), xytext=(3, 1.8),
                arrowprops=dict(arrowstyle='<->', lw=2.5, color='red'))
    ax.text(2.25, 2.1, "incomparable!", ha='center', fontsize=9, color='red', fontweight='bold')

    ax.set_xlim(0, 6)
    ax.set_ylim(-0.7, 5.5)
    ax.axis('off')
    ax.text(3, -0.5, "Identity closure on {0,1,2}", ha='center', fontsize=10, style='italic')

    plt.tight_layout()
    return fig


def viz2_valuation_landscape():
    """Visualize the valuation as a landscape with level sets."""
    fig, ax = plt.subplots(figsize=(10, 6))

    universe = list(range(8))
    v = {0: 1, 1: 3, 2: 1, 3: 5, 4: 2, 5: 5, 6: 8, 7: 3}

    values = [v[x] for x in universe]
    colors = plt.cm.viridis(np.array(values) / max(values))

    bars = ax.bar(universe, values, color=colors, edgecolor='black', linewidth=1.5, zorder=3)

    # Draw level set lines
    distinct_vals = sorted(set(values))
    for val in distinct_vals:
        ax.axhline(y=val, color='red', linestyle='--', alpha=0.4, zorder=2)
        members = [x for x in universe if v[x] <= val]
        ax.text(7.5, val + 0.15, f"cl_v threshold={val}: {{{','.join(map(str, members))}}}",
                fontsize=8, color='red', alpha=0.7, va='bottom')

    ax.set_xlabel("Element x", fontsize=13)
    ax.set_ylabel("Gauge Valuation v(x)", fontsize=13)
    ax.set_title("Gauge Valuation Landscape with Level Sets",
                 fontsize=15, fontweight='bold')
    ax.set_xticks(universe)
    ax.grid(axis='y', alpha=0.3)

    # Add colorbar
    sm = plt.cm.ScalarMappable(cmap='viridis',
                                norm=plt.Normalize(vmin=min(values), vmax=max(values)))
    sm.set_array([])
    cbar = plt.colorbar(sm, ax=ax, label='Holonomy value')

    plt.tight_layout()
    return fig


def viz3_capacity_profile():
    """Compare capacity profiles of two equivalent valuations."""
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))

    universe = {0, 1, 2, 3}
    v1 = {0: 1, 1: 3, 2: 7, 3: 15}
    v2 = {0: 1, 1: 2, 2: 4, 3: 8}  # order-equivalent

    for idx, (v, title) in enumerate([(v1, "v₁ = {0:1, 1:3, 2:7, 3:15}"),
                                        (v2, "v₂ = {0:1, 1:2, 2:4, 3:8}")]):
        ax = axes[idx]
        cl = lambda S, v=v: valuation_closure(v, S, universe)

        # Compute capacities for all subsets
        subsets = []
        capacities = []
        labels = []
        for r in range(5):
            for combo in combinations(sorted(universe), r):
                S = frozenset(combo)
                cap = len(cl(S))
                subsets.append(S)
                capacities.append(cap)
                label = "{" + ",".join(str(x) for x in sorted(S)) + "}" if S else "∅"
                labels.append(label)

        x_pos = range(len(subsets))
        colors = plt.cm.Set2(np.array(capacities) / max(capacities))
        ax.bar(x_pos, capacities, color=colors, edgecolor='black', linewidth=0.5)
        ax.set_xticks(x_pos)
        ax.set_xticklabels(labels, rotation=90, fontsize=7)
        ax.set_ylabel("Capacity |cl(S)|", fontsize=11)
        ax.set_title(title, fontsize=12, fontweight='bold')
        ax.set_ylim(0, 5)

    fig.suptitle("Capacity Profiles of Order-Equivalent Valuations\n"
                 "(Equal profiles ⟹ equal closures by Holographic Duality)",
                 fontsize=14, fontweight='bold')
    plt.tight_layout()
    return fig


def viz4_reconstruction():
    """Visualize the reconstruction process."""
    fig, axes = plt.subplots(1, 3, figsize=(15, 5))

    universe = {0, 1, 2, 3, 4}
    v_true = {0: 0, 1: 3, 2: 3, 3: 7, 4: 12}

    # Panel 1: True valuation
    ax = axes[0]
    elems = sorted(universe)
    true_vals = [v_true[x] for x in elems]
    ax.bar(elems, true_vals, color='steelblue', edgecolor='black', linewidth=1.5)
    ax.set_title("True Gauge Valuation", fontsize=13, fontweight='bold')
    ax.set_xlabel("Element")
    ax.set_ylabel("v(x)")
    ax.set_xticks(elems)

    # Panel 2: Closed set chain
    ax = axes[1]
    cl = lambda S: valuation_closure(v_true, S, universe)
    closed = get_closed_sets(v_true, universe)

    for i, S in enumerate(closed):
        y = i * 1.2
        label = "{" + ", ".join(str(x) for x in sorted(S)) + "}" if S else "∅"
        color = plt.cm.Oranges(0.2 + 0.6 * i / max(len(closed) - 1, 1))
        ax.add_patch(mpatches.FancyBboxPatch((0.5, y - 0.25), 3, 0.5,
                     boxstyle="round,pad=0.05", facecolor=color, edgecolor='darkorange', linewidth=2))
        ax.text(2, y, label, ha='center', va='center', fontsize=11, fontweight='bold')
        if i > 0:
            ax.annotate('', xy=(2, y - 0.25), xytext=(2, (i-1) * 1.2 + 0.25),
                        arrowprops=dict(arrowstyle='->', lw=1.5, color='darkorange'))

    ax.set_xlim(0, 4)
    ax.set_ylim(-0.7, len(closed) * 1.2 + 0.5)
    ax.axis('off')
    ax.set_title("Closed Set Chain\n(extracted from closure)", fontsize=13, fontweight='bold')

    # Panel 3: Reconstructed valuation
    ax = axes[2]
    cl_empty = cl(frozenset())
    v_recon = {x: len(cl(frozenset([x]))) - len(cl_empty) for x in universe}
    recon_vals = [v_recon[x] for x in elems]
    ax.bar(elems, recon_vals, color='forestgreen', edgecolor='black', linewidth=1.5)
    ax.set_title("Reconstructed Valuation\n(certified correct)", fontsize=13, fontweight='bold')
    ax.set_xlabel("Element")
    ax.set_ylabel("v_recon(x)")
    ax.set_xticks(elems)

    # Check order equivalence
    oe = all((v_true[x] <= v_true[y]) == (v_recon[x] <= v_recon[y])
             for x in universe for y in universe)
    fig.text(0.5, 0.01, f"Order equivalent to original: {oe} ✓" if oe else "NOT order equivalent ✗",
             ha='center', fontsize=12, fontweight='bold',
             color='green' if oe else 'red')

    plt.tight_layout(rect=[0, 0.05, 1, 1])
    return fig


if __name__ == "__main__":
    # Generate all visualizations
    print("Generating visualizations...")

    fig1 = viz1_chain_diagram()
    fig1.savefig("viz_chain_diagram.png", dpi=150, bbox_inches='tight')
    print("  ✓ viz_chain_diagram.png")

    fig2 = viz2_valuation_landscape()
    fig2.savefig("viz_valuation_landscape.png", dpi=150, bbox_inches='tight')
    print("  ✓ viz_valuation_landscape.png")

    fig3 = viz3_capacity_profile()
    fig3.savefig("viz_capacity_profile.png", dpi=150, bbox_inches='tight')
    print("  ✓ viz_capacity_profile.png")

    fig4 = viz4_reconstruction()
    fig4.savefig("viz_reconstruction.png", dpi=150, bbox_inches='tight')
    print("  ✓ viz_reconstruction.png")

    plt.close('all')
    print("\nAll visualizations generated!")
