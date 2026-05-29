"""
Applications of Phantom Topologies
====================================

Real-world applications of phantom topology concepts:
1. Multi-sensor fusion (different sensors = different observers)
2. Distributed consensus in networks
3. Quantum measurement analogy
"""

from itertools import combinations, chain
from typing import List, Set, FrozenSet, Dict, Tuple
import math

Subset = FrozenSet[int]
Topology = Set[Subset]


def powerset(s):
    s = list(s)
    return list(chain.from_iterable(combinations(s, r) for r in range(len(s) + 1)))


def to_frozensets(opens):
    return {frozenset(o) for o in opens}


def consensus_topology(topologies):
    if not topologies:
        return set()
    result = topologies[0].copy()
    for t in topologies[1:]:
        result &= t
    return result


# ============================================================
# Application 1: Multi-Sensor Fusion
# ============================================================
def sensor_fusion_demo():
    """
    Model multi-sensor perception as a phantom system.

    Each sensor (camera, lidar, radar) resolves different features
    of the environment. The "topology" represents which distinctions
    the sensor can make. Consensus = what ALL sensors agree on.
    """
    print("=" * 60)
    print("APPLICATION 1: Multi-Sensor Fusion")
    print("=" * 60)

    # Environment has 4 regions: {0, 1, 2, 3}
    # Each sensor can distinguish different groupings
    X = [0, 1, 2, 3]

    # Camera: good spatial resolution, groups by visual similarity
    camera_opens = [
        (), (0,), (1,), (0, 1), (2, 3), (0, 2, 3), (1, 2, 3), (0, 1, 2, 3)
    ]
    camera = to_frozensets(camera_opens)

    # Lidar: good depth resolution, groups by distance
    lidar_opens = [
        (), (0, 1), (2,), (3,), (2, 3), (0, 1, 2), (0, 1, 3), (0, 1, 2, 3)
    ]
    lidar = to_frozensets(lidar_opens)

    # Radar: coarse resolution, few distinctions
    radar_opens = [
        (), (0, 1, 2, 3)
    ]
    radar = to_frozensets(radar_opens)

    sensors = {"Camera": camera, "Lidar": lidar, "Radar": radar}

    print(f"\nEnvironment: {len(X)} regions")
    for name, top in sensors.items():
        print(f"  {name} distinguishes {len(top)} open sets")

    # Pairwise consensus
    for n1, n2 in combinations(sensors.keys(), 2):
        cons = consensus_topology([sensors[n1], sensors[n2]])
        print(f"\n  {n1} + {n2} consensus: {len(cons)} open sets")
        print(f"    Shared distinctions: {[set(s) for s in sorted(cons, key=len)]}")

    # Full consensus
    all_cons = consensus_topology(list(sensors.values()))
    print(f"\n  ALL sensors consensus: {len(all_cons)} open sets")
    print(f"    Universal agreement: {[set(s) for s in sorted(all_cons, key=len)]}")

    # Information gain from adding each sensor
    print("\n  Information gain (additional distinctions):")
    for name in sensors:
        others = [v for k, v in sensors.items() if k != name]
        without = consensus_topology(others)
        with_all = all_cons
        print(f"    Adding {name}: {len(without)} → {len(with_all)} "
              f"(Δ = {len(without) - len(with_all)} fewer shared opens)")


# ============================================================
# Application 2: Distributed Network Consensus
# ============================================================
def network_consensus_demo():
    """
    Model distributed network agreement as a phantom system.

    Nodes in a network have different views of which connections
    are "open" (active). Consensus = globally agreed-upon connectivity.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 2: Distributed Network Consensus")
    print("=" * 60)

    # 3 nodes, each sees different network partition
    X = [0, 1, 2]

    # Node 0: sees full connectivity
    node0 = to_frozensets([(), (0,), (1,), (2,), (0, 1), (0, 2), (1, 2), (0, 1, 2)])

    # Node 1: sees partial partition (0 isolated from {1,2})
    node1 = to_frozensets([(), (0,), (1, 2), (0, 1, 2)])

    # Node 2: sees different partition ({0,1} grouped, 2 separate)
    node2 = to_frozensets([(), (2,), (0, 1), (0, 1, 2)])

    nodes = [node0, node1, node2]

    print(f"\n  Node views:")
    for i, n in enumerate(nodes):
        print(f"    Node {i}: {len(n)} distinguishable sets")

    cons = consensus_topology(nodes)
    print(f"\n  Network consensus: {len(cons)} sets")
    print(f"    Agreed topology: {[set(s) for s in sorted(cons, key=len)]}")

    # Measure disagreement
    total_dis = 0
    pairs = 0
    for i in range(3):
        for j in range(i + 1, 3):
            dis = len(nodes[i].symmetric_difference(nodes[j]))
            total_dis += dis
            pairs += 1
            print(f"    Disagreement(Node {i}, Node {j}) = {dis}")

    avg_dis = total_dis / pairs
    print(f"\n    Average disagreement: {avg_dis:.1f}")
    print(f"    Phantom entropy: {avg_dis / (2**len(X)):.3f}")


# ============================================================
# Application 3: Quantum Measurement Analogy
# ============================================================
def quantum_analogy_demo():
    """
    Illustrate the quantum measurement analogy:
    Different measurement bases = different observer topologies.
    The "real" state = consensus of all measurement outcomes.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 3: Quantum Measurement Analogy")
    print("=" * 60)

    # A 4-state quantum system
    # States: |00⟩, |01⟩, |10⟩, |11⟩ → {0, 1, 2, 3}
    X = [0, 1, 2, 3]

    # Measurement in computational basis: distinguishes all states
    comp_basis = to_frozensets([
        (), (0,), (1,), (2,), (3,),
        (0, 1), (0, 2), (0, 3), (1, 2), (1, 3), (2, 3),
        (0, 1, 2), (0, 1, 3), (0, 2, 3), (1, 2, 3),
        (0, 1, 2, 3)
    ])

    # Measurement of first qubit only: distinguishes {|0x⟩} vs {|1x⟩}
    first_qubit = to_frozensets([
        (), (0, 1), (2, 3), (0, 1, 2, 3)
    ])

    # Measurement of second qubit only
    second_qubit = to_frozensets([
        (), (0, 2), (1, 3), (0, 1, 2, 3)
    ])

    bases = {
        "Computational": comp_basis,
        "First qubit": first_qubit,
        "Second qubit": second_qubit
    }

    print("\n  Measurement bases and their topologies:")
    for name, top in bases.items():
        print(f"    {name}: {len(top)} distinguishable sets")

    # Partial measurement consensus
    partial = consensus_topology([first_qubit, second_qubit])
    print(f"\n  Partial measurements consensus: {len(partial)} sets")
    print(f"    = {[set(s) for s in sorted(partial, key=len)]}")
    print(f"    (Only ∅ and X are shared — cannot recover full state)")

    full = consensus_topology([comp_basis, first_qubit, second_qubit])
    print(f"\n  Full + partial consensus: {len(full)} sets")
    print(f"    (Adding computational basis resolves everything)")

    print("\n  Key insight: Coarse measurements (few opens) lose information.")
    print("  The phantom system models how different measurements")
    print("  give complementary but incomplete views of reality.")


# ============================================================
# Run all applications
# ============================================================
if __name__ == "__main__":
    sensor_fusion_demo()
    network_consensus_demo()
    quantum_analogy_demo()

    print("\n" + "=" * 60)
    print("ALL APPLICATIONS COMPLETE")
    print("=" * 60)


"""
Phantom Topologies: Spaces That Change When You Look at Them
=============================================================
Demonstration of phantom topology concepts with concrete numerical examples.

A phantom system assigns different topologies to different observers.
The consensus topology is what ALL observers agree on.
"""

from itertools import combinations, chain


def powerset(s):
    """Generate all subsets of a set."""
    s = list(s)
    return list(chain.from_iterable(combinations(s, r) for r in range(len(s) + 1)))


def is_topology(X, opens):
    """Check if a collection of sets forms a topology on X."""
    opens_set = [set(o) for o in opens]
    # Must contain empty set and X
    if set() not in opens_set or set(X) not in opens_set:
        return False
    # Closed under finite intersections
    for a in opens_set:
        for b in opens_set:
            if a & b not in opens_set:
                return False
    # Closed under arbitrary unions
    for subset in powerset(range(len(opens_set))):
        union = set()
        for i in subset:
            union |= opens_set[i]
        if union not in opens_set:
            return False
    return True


def consensus_topology(X, topologies):
    """
    Compute the consensus topology: intersection of all observer topologies.
    A set is consensus-open iff it is open in EVERY observer's topology.
    """
    if not topologies:
        return [set(), set(X)]
    consensus = []
    all_subsets = [set(s) for s in powerset(X)]
    for s in all_subsets:
        if all(s in [set(o) for o in top] for top in topologies):
            consensus.append(tuple(sorted(s)))
    return consensus


def phantom_number(X, target_topology):
    """
    Compute the phantom number of a topology: minimum number of topologies
    whose consensus (intersection as families of open sets) equals the target.
    """
    all_tops = enumerate_topologies(X)
    target_set = {frozenset(s) for s in target_topology}

    # Check n=1: does the target equal itself? Always yes.
    for top in all_tops:
        top_frozen = {frozenset(s) for s in top}
        if top_frozen == target_set:
            return 1

    # Check n=2
    for i, t1 in enumerate(all_tops):
        for t2 in all_tops[i:]:
            t1_set = {frozenset(s) for s in t1}
            t2_set = {frozenset(s) for s in t2}
            intersection = t1_set & t2_set
            if intersection == target_set:
                return 2

    # Check n=3
    for i, t1 in enumerate(all_tops):
        for j, t2 in enumerate(all_tops[i:], i):
            for t3 in all_tops[j:]:
                t1_set = {frozenset(s) for s in t1}
                t2_set = {frozenset(s) for s in t2}
                t3_set = {frozenset(s) for s in t3}
                intersection = t1_set & t2_set & t3_set
                if intersection == target_set:
                    return 3

    return None  # Not found within 3


def enumerate_topologies(X):
    """Enumerate all topologies on a finite set X."""
    X_set = set(X)
    all_subsets = [tuple(sorted(s)) for s in powerset(X)]
    topologies = []

    # Check all subfamilies of the power set
    for r in range(len(all_subsets) + 1):
        for combo in combinations(all_subsets, r):
            candidate = list(combo)
            if is_topology(X, candidate):
                topologies.append(candidate)
    return topologies


def disagreement_sets(top1, top2):
    """Compute the symmetric difference of two topologies' open sets."""
    s1 = {frozenset(s) for s in top1}
    s2 = {frozenset(s) for s in top2}
    return s1.symmetric_difference(s2)


# ============================================================
# DEMONSTRATIONS
# ============================================================

print("=" * 60)
print("PHANTOM TOPOLOGIES: DEMONSTRATION")
print("=" * 60)

# Demo 1: All topologies on {0, 1}
print("\n--- Demo 1: Topologies on {0, 1} ---")
X2 = [0, 1]
tops_2 = enumerate_topologies(X2)
print(f"Number of topologies on {{0,1}}: {len(tops_2)}")
for i, top in enumerate(tops_2):
    opens_str = [set(s) for s in top]
    print(f"  τ_{i}: {opens_str}")

# Demo 2: Phantom numbers for topologies on {0, 1}
print("\n--- Demo 2: Phantom numbers on {0, 1} ---")
for i, top in enumerate(tops_2):
    pn = phantom_number(X2, top)
    print(f"  τ_{i} has phantom number {pn}")

# Demo 3: Two-observer consensus
print("\n--- Demo 3: Two-observer consensus ---")
# On {0, 1, 2}, show that two Sierpinski-like topologies can recover the discrete
X3 = [0, 1, 2]
top_a = [(), (0,), (0, 1), (0, 1, 2)]  # Sierpinski-like
top_b = [(), (1,), (1, 2), (0, 1, 2)]  # Another variant
cons = consensus_topology(X3, [top_a, top_b])
print(f"  Observer A opens: {[set(s) for s in top_a]}")
print(f"  Observer B opens: {[set(s) for s in top_b]}")
print(f"  Consensus opens:  {[set(s) for s in cons]}")

# Demo 4: Disagreement
print("\n--- Demo 4: Disagreement between observers ---")
dis = disagreement_sets(top_a, top_b)
print(f"  Observer A opens: {[set(s) for s in top_a]}")
print(f"  Observer B opens: {[set(s) for s in top_b]}")
print(f"  Disagreement sets: {[set(s) for s in dis]}")
print(f"  Number of disagreements: {len(dis)}")

# Demo 5: All topologies on {0, 1, 2} and phantom numbers
print("\n--- Demo 5: Topologies on {0, 1, 2} ---")
tops_3 = enumerate_topologies(X3)
print(f"Number of topologies on {{0,1,2}}: {len(tops_3)}")

phantom_counts = {}
for top in tops_3:
    pn = phantom_number(X3, top)
    phantom_counts[pn] = phantom_counts.get(pn, 0) + 1

print("Phantom number distribution:")
for pn in sorted(phantom_counts.keys()):
    print(f"  Phantom number {pn}: {phantom_counts[pn]} topologies")

# Demo 6: Monotone phantom system
print("\n--- Demo 6: Monotone phantom system ---")
print("  Three observers with increasingly coarse topologies on {0,1}:")
t_fine = [(), (0,), (1,), (0, 1)]  # discrete
t_mid = [(), (0,), (0, 1)]  # Sierpinski
t_coarse = [(), (0, 1)]  # indiscrete
print(f"  Observer 0 (finest):   {[set(s) for s in t_fine]}")
print(f"  Observer 1 (middle):   {[set(s) for s in t_mid]}")
print(f"  Observer 2 (coarsest): {[set(s) for s in t_coarse]}")
cons_mono = consensus_topology(X2, [t_fine, t_mid, t_coarse])
print(f"  Consensus = Observer 2: {[set(s) for s in cons_mono]}")
print(f"  (Confirms: monotone consensus = coarsest observer)")

# Demo 7: Real line analogy
print("\n--- Demo 7: Real line phantom representation (conceptual) ---")
print("  The standard topology on ℝ can be represented as:")
print("  Observer 1: Lower-limit (Sorgenfrey) topology — basis [a,b)")
print("  Observer 2: Upper-limit topology — basis (a,b]")
print("  Consensus: U open iff open in BOTH")
print("  = standard topology (basis (a,b))")
print("  This gives phantom number ≤ 2 for the standard topology on ℝ")

print("\n" + "=" * 60)
print("ALL DEMONSTRATIONS COMPLETE")
print("=" * 60)


"""
Visualization: Observer Disagreement Heatmap
=============================================
Shows pairwise disagreement between all topologies on a 3-element set.
Each cell represents the symmetric difference (number of sets where two
topologies disagree on openness). Reveals the metric structure of the
space of all topologies — a key insight of phantom topology theory.
"""

import matplotlib.pyplot as plt
import numpy as np
from itertools import combinations, chain


def powerset(s):
    s = list(s)
    return list(chain.from_iterable(combinations(s, r) for r in range(len(s) + 1)))


def is_topology(X, opens):
    opens_set = {frozenset(o) for o in opens}
    X_frozen = frozenset(X)
    if frozenset() not in opens_set or X_frozen not in opens_set:
        return False
    for a in opens_set:
        for b in opens_set:
            if (a & b) not in opens_set:
                return False
    opens_list = list(opens_set)
    for subset_indices in powerset(list(range(len(opens_list)))):
        union = frozenset()
        for i in subset_indices:
            union = union | opens_list[i]
        if union not in opens_set:
            return False
    return True


def enumerate_topologies(X):
    all_subsets = [tuple(sorted(s)) for s in powerset(X)]
    topologies = []
    for r in range(len(all_subsets) + 1):
        for combo in combinations(all_subsets, r):
            candidate = list(combo)
            if is_topology(X, candidate):
                topologies.append({frozenset(o) for o in candidate})
    return topologies


# Enumerate all 29 topologies on {0, 1, 2}
X = [0, 1, 2]
tops = enumerate_topologies(X)
n = len(tops)

# Compute disagreement matrix
D = np.zeros((n, n), dtype=int)
for i in range(n):
    for j in range(n):
        D[i, j] = len(tops[i].symmetric_difference(tops[j]))

# Sort topologies by size (number of open sets)
sizes = [len(t) for t in tops]
order = np.argsort(sizes)
D_sorted = D[np.ix_(order, order)]
sizes_sorted = [sizes[o] for o in order]

fig, ax = plt.subplots(figsize=(10, 8))

im = ax.imshow(D_sorted, cmap='YlOrRd', interpolation='nearest')
ax.set_title(f'Disagreement Matrix: All {n} Topologies on {{0,1,2}}',
             fontsize=14, fontweight='bold')
ax.set_xlabel('Topology index (sorted by size)', fontsize=11)
ax.set_ylabel('Topology index (sorted by size)', fontsize=11)

# Add colorbar
cbar = plt.colorbar(im, ax=ax, shrink=0.8)
cbar.set_label('Symmetric difference |τ₁ △ τ₂|', fontsize=11)

# Add size annotations on axis
ax.set_xticks(range(n))
ax.set_yticks(range(n))
ax.set_xticklabels([f'{sizes_sorted[i]}' for i in range(n)], fontsize=6)
ax.set_yticklabels([f'{sizes_sorted[i]}' for i in range(n)], fontsize=6)

# Add text showing some interesting statistics
max_dis = D.max()
avg_dis = D[np.triu_indices(n, k=1)].mean()
ax.text(0.02, 0.98, f'Max disagreement: {max_dis}\nAvg disagreement: {avg_dis:.1f}\n'
        f'Tick labels = |τ| (# open sets)',
        transform=ax.transAxes, fontsize=9, verticalalignment='top',
        bbox=dict(boxstyle='round', facecolor='wheat', alpha=0.8))

plt.tight_layout()
plt.savefig('viz_disagreement_heatmap.png', dpi=150, bbox_inches='tight')
print(f"Saved viz_disagreement_heatmap.png")
print(f"Number of topologies on {{0,1,2}}: {n}")
print(f"Max disagreement: {max_dis}")
print(f"Average disagreement: {avg_dis:.1f}")


"""
Visualization: Phantom Entropy vs Number of Observers
======================================================
Shows how phantom entropy (average pairwise disagreement) changes as
we add observers to a phantom system. Illustrates the key theorem:
adding observers can only increase entropy (more disagreement to average)
but the consensus topology becomes coarser (more agreement required).
"""

import matplotlib.pyplot as plt
import numpy as np
from itertools import combinations, chain
import random

random.seed(42)


def powerset(s):
    s = list(s)
    return list(chain.from_iterable(combinations(s, r) for r in range(len(s) + 1)))


def is_topology(X, opens):
    opens_set = {frozenset(o) for o in opens}
    X_frozen = frozenset(X)
    if frozenset() not in opens_set or X_frozen not in opens_set:
        return False
    for a in opens_set:
        for b in opens_set:
            if (a & b) not in opens_set:
                return False
    opens_list = list(opens_set)
    for subset_indices in powerset(list(range(len(opens_list)))):
        union = frozenset()
        for i in subset_indices:
            union = union | opens_list[i]
        if union not in opens_set:
            return False
    return True


def enumerate_topologies(X):
    all_subsets = [tuple(sorted(s)) for s in powerset(X)]
    topologies = []
    for r in range(len(all_subsets) + 1):
        for combo in combinations(all_subsets, r):
            if is_topology(X, list(combo)):
                topologies.append({frozenset(o) for o in combo})
    return topologies


def consensus_size(topologies):
    if not topologies:
        return 0
    result = topologies[0].copy()
    for t in topologies[1:]:
        result &= t
    return len(result)


def phantom_entropy(topologies, total_subsets):
    n = len(topologies)
    if n <= 1:
        return 0.0
    total = 0
    pairs = 0
    for i in range(n):
        for j in range(i + 1, n):
            total += len(topologies[i].symmetric_difference(topologies[j]))
            pairs += 1
    return total / (pairs * total_subsets) if pairs > 0 else 0.0


# Setup
X = [0, 1, 2]
all_tops = enumerate_topologies(X)
total_subsets = 2 ** len(X)

# Run multiple trials of adding random observers
num_trials = 50
max_observers = min(len(all_tops), 15)

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))

# ---- Left: Entropy vs observers ----
all_entropies = []
all_consensus_sizes = []

for trial in range(num_trials):
    shuffled = random.sample(all_tops, min(max_observers, len(all_tops)))
    entropies = []
    con_sizes = []
    for k in range(1, len(shuffled) + 1):
        subset = shuffled[:k]
        ent = phantom_entropy(subset, total_subsets)
        cs = consensus_size(subset)
        entropies.append(ent)
        con_sizes.append(cs)
    all_entropies.append(entropies)
    all_consensus_sizes.append(con_sizes)

# Plot individual trials (faint)
for entropies in all_entropies:
    ax1.plot(range(1, len(entropies) + 1), entropies,
             color='#2196F3', alpha=0.1, linewidth=0.5)

# Plot average
max_len = max(len(e) for e in all_entropies)
avg_ent = []
for k in range(max_len):
    vals = [e[k] for e in all_entropies if k < len(e)]
    avg_ent.append(np.mean(vals))

ax1.plot(range(1, len(avg_ent) + 1), avg_ent,
         color='#1565C0', linewidth=2.5, label='Average', zorder=10)

ax1.set_xlabel('Number of Observers', fontsize=12)
ax1.set_ylabel('Phantom Entropy', fontsize=12)
ax1.set_title('Phantom Entropy vs Observers', fontsize=13, fontweight='bold')
ax1.legend(fontsize=10)
ax1.grid(True, alpha=0.3)

# ---- Right: Consensus size vs observers ----
for con_sizes in all_consensus_sizes:
    ax2.plot(range(1, len(con_sizes) + 1), con_sizes,
             color='#FF9800', alpha=0.1, linewidth=0.5)

avg_con = []
for k in range(max_len):
    vals = [c[k] for c in all_consensus_sizes if k < len(c)]
    avg_con.append(np.mean(vals))

ax2.plot(range(1, len(avg_con) + 1), avg_con,
         color='#E65100', linewidth=2.5, label='Average', zorder=10)

ax2.set_xlabel('Number of Observers', fontsize=12)
ax2.set_ylabel('Consensus Size (# open sets)', fontsize=12)
ax2.set_title('Consensus Size vs Observers', fontsize=13, fontweight='bold')
ax2.legend(fontsize=10)
ax2.grid(True, alpha=0.3)

# Add annotation
ax2.axhline(y=2, color='red', linestyle='--', alpha=0.5)
ax2.text(max_len * 0.6, 2.3, 'Indiscrete (minimum)',
         fontsize=9, color='red', alpha=0.7)

plt.tight_layout()
plt.savefig('viz_phantom_entropy.png', dpi=150, bbox_inches='tight')
print("Saved viz_phantom_entropy.png")


"""
Visualization: Topology Lattice and Phantom Decomposition
==========================================================
Visualizes the lattice of all topologies on a 2-element set {0,1},
showing refinement relationships and phantom decompositions.
The indiscrete topology (top) decomposes as the consensus of the
two Sierpiński topologies (middle layer).
"""

import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np

fig, axes = plt.subplots(1, 2, figsize=(14, 6))

# ---- Left panel: Topology lattice on {0,1} ----
ax = axes[0]
ax.set_xlim(-1.5, 1.5)
ax.set_ylim(-0.5, 3.5)
ax.set_aspect('equal')
ax.axis('off')
ax.set_title('Topology Lattice on {0, 1}', fontsize=14, fontweight='bold')

# Positions: bottom=discrete, top=indiscrete
positions = {
    'discrete': (0, 0),
    'sierp_0': (-0.8, 1.5),
    'sierp_1': (0.8, 1.5),
    'indiscrete': (0, 3),
}

labels = {
    'discrete': '{∅, {0}, {1}, {0,1}}',
    'sierp_0': '{∅, {0}, {0,1}}',
    'sierp_1': '{∅, {1}, {0,1}}',
    'indiscrete': '{∅, {0,1}}',
}

colors = {
    'discrete': '#2196F3',
    'sierp_0': '#FF9800',
    'sierp_1': '#FF9800',
    'indiscrete': '#F44336',
}

# Draw edges (refinement: finer → coarser = bottom → top)
edges = [
    ('discrete', 'sierp_0'),
    ('discrete', 'sierp_1'),
    ('sierp_0', 'indiscrete'),
    ('sierp_1', 'indiscrete'),
]

for a, b in edges:
    ax.annotate('', xy=positions[b], xytext=positions[a],
                arrowprops=dict(arrowstyle='->', color='gray', lw=1.5))

# Draw nodes
for key, (x, y) in positions.items():
    circle = plt.Circle((x, y), 0.15, color=colors[key], zorder=5)
    ax.add_patch(circle)
    ax.text(x, y - 0.35, labels[key], ha='center', va='top', fontsize=8)

# Annotations
ax.text(0, 3.4, '⊤ (coarsest)', ha='center', fontsize=9, color='#F44336')
ax.text(0, -0.4, '⊥ (finest)', ha='center', fontsize=9, color='#2196F3')
ax.text(-1.3, 1.5, 'Sierpiński\ntopologies', ha='center', fontsize=8,
        style='italic', color='#FF9800')

# ---- Right panel: Phantom decomposition ----
ax2 = axes[1]
ax2.set_xlim(-2, 2)
ax2.set_ylim(-0.5, 3.5)
ax2.set_aspect('equal')
ax2.axis('off')
ax2.set_title('Phantom Decomposition', fontsize=14, fontweight='bold')

# Show indiscrete = consensus of two Sierpinski
obs_positions = {
    'obs1': (-1, 2),
    'obs2': (1, 2),
    'consensus': (0, 0.5),
}

# Observer 1 (Sierpinski {0})
circle1 = plt.Circle(obs_positions['obs1'], 0.3, color='#FF9800',
                      alpha=0.8, zorder=5)
ax2.add_patch(circle1)
ax2.text(-1, 2, 'Observer 1', ha='center', va='center', fontsize=9,
         fontweight='bold', color='white')
ax2.text(-1, 1.55, '{∅, {0}, {0,1}}', ha='center', fontsize=8)

# Observer 2 (Sierpinski {1})
circle2 = plt.Circle(obs_positions['obs2'], 0.3, color='#FF9800',
                      alpha=0.8, zorder=5)
ax2.add_patch(circle2)
ax2.text(1, 2, 'Observer 2', ha='center', va='center', fontsize=9,
         fontweight='bold', color='white')
ax2.text(1, 1.55, '{∅, {1}, {0,1}}', ha='center', fontsize=8)

# Consensus
circle_c = plt.Circle(obs_positions['consensus'], 0.3, color='#F44336',
                       alpha=0.8, zorder=5)
ax2.add_patch(circle_c)
ax2.text(0, 0.5, 'Consensus', ha='center', va='center', fontsize=9,
         fontweight='bold', color='white')
ax2.text(0, 0.05, '{∅, {0,1}} = Indiscrete', ha='center', fontsize=8,
         color='#F44336')

# Arrows
for obs in ['obs1', 'obs2']:
    ax2.annotate('', xy=obs_positions['consensus'],
                 xytext=obs_positions[obs],
                 arrowprops=dict(arrowstyle='->', color='#666', lw=2))

# Labels
ax2.text(0, 3.2, 'Phantom Number = 2', ha='center', fontsize=12,
         fontweight='bold', color='#333',
         bbox=dict(boxstyle='round,pad=0.3', facecolor='#FFF9C4', alpha=0.8))
ax2.text(0, 2.7, 'The indiscrete topology is the consensus\n'
         'of two Sierpiński observers', ha='center', fontsize=9, color='#666')

plt.tight_layout()
plt.savefig('viz_topology_lattice.png', dpi=150, bbox_inches='tight')
print("Saved viz_topology_lattice.png")
