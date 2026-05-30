"""
Applications of Phantom Topology Theory

Demonstrates real-world applications of phantom topologies:
1. Distributed consensus in networks
2. Multi-resolution signal analysis
3. Ensemble model diversity measurement
"""

from typing import List, Dict, Set, FrozenSet, Tuple
from itertools import combinations


class FiniteTopology:
    """Topology on a finite set (self-contained for this module)."""

    def __init__(self, X: FrozenSet, opens: FrozenSet[FrozenSet]):
        self.X = frozenset(X)
        self.opens = frozenset(opens)

    @classmethod
    def discrete(cls, X):
        X = frozenset(X)
        items = list(X)
        subs = []
        for r in range(len(items) + 1):
            for c in combinations(items, r):
                subs.append(frozenset(c))
        return cls(X, frozenset(subs))

    @classmethod
    def indiscrete(cls, X):
        X = frozenset(X)
        return cls(X, frozenset([frozenset(), X]))

    def __eq__(self, other):
        return isinstance(other, FiniteTopology) and self.opens == other.opens

    def __hash__(self):
        return hash(self.opens)

    def __le__(self, other):
        return other.opens.issubset(self.opens)


def consensus(*topologies):
    if not topologies:
        raise ValueError("Need at least one topology")
    X = topologies[0].X
    result = set(topologies[0].opens)
    for t in topologies[1:]:
        result &= set(t.opens)
    return FiniteTopology(X, frozenset(result))


# ============================================================
# Application 1: Distributed Consensus in Networks
# ============================================================

def distributed_consensus_demo():
    """
    Simulate a distributed system where 3 nodes maintain local views
    of a shared state space X = {A, B, C, D}.

    Each node's "topology" represents which states it considers
    distinguishable. The consensus topology captures the globally
    agreed notion of distinguishability.
    """
    print("=" * 60)
    print("APPLICATION 1: DISTRIBUTED CONSENSUS IN NETWORKS")
    print("=" * 60)

    X = frozenset({"A", "B", "C", "D"})

    # Node 1: Can distinguish {A} from the rest
    node1_opens = frozenset([
        frozenset(),
        frozenset({"A"}),
        frozenset({"B", "C", "D"}),
        X
    ])

    # Node 2: Can distinguish {A, B} from {C, D}
    node2_opens = frozenset([
        frozenset(),
        frozenset({"A", "B"}),
        frozenset({"C", "D"}),
        X
    ])

    # Node 3: Can distinguish {A, C} from {B, D}
    node3_opens = frozenset([
        frozenset(),
        frozenset({"A", "C"}),
        frozenset({"B", "D"}),
        X
    ])

    node1 = FiniteTopology(X, node1_opens)
    node2 = FiniteTopology(X, node2_opens)
    node3 = FiniteTopology(X, node3_opens)

    print(f"\nNetwork with {len(X)} states: {sorted(X)}")
    print(f"\nNode 1 distinguishes: {sorted([sorted(s) for s in node1_opens if s and s != X])}")
    print(f"Node 2 distinguishes: {sorted([sorted(s) for s in node2_opens if s and s != X])}")
    print(f"Node 3 distinguishes: {sorted([sorted(s) for s in node3_opens if s and s != X])}")

    # Consensus
    cons = consensus(node1, node2, node3)
    print(f"\nGlobal consensus (all nodes agree):")
    print(f"  Open sets: {sorted([sorted(s) for s in cons.opens])}")
    print(f"  Number of distinguishable regions: {len(cons.opens)}")

    # Sequential consensus (simulating rounds of communication)
    print(f"\nSequential consensus (communication rounds):")
    c1 = node1
    print(f"  After round 0 (Node 1 only): {len(c1.opens)} open sets")
    c2 = consensus(c1, node2)
    print(f"  After round 1 (+ Node 2): {len(c2.opens)} open sets")
    c3 = consensus(c2, node3)
    print(f"  After round 2 (+ Node 3): {len(c3.opens)} open sets")

    # Check: does adding Node 3 again change anything?
    c4 = consensus(c3, node3)
    print(f"  After round 3 (+ Node 3 again): {len(c4.opens)} open sets")
    if c4 == c3:
        print("  ✓ Consensus has stabilized!")


# ============================================================
# Application 2: Multi-Resolution Analysis
# ============================================================

def multi_resolution_demo():
    """
    Simulate multi-resolution analysis of a 1D signal space.

    The signal space is X = {0, 1, 2, 3, 4, 5} (discrete samples).
    Each resolution level defines a different topology by grouping
    nearby samples into neighborhoods.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 2: MULTI-RESOLUTION SIGNAL ANALYSIS")
    print("=" * 60)

    X = frozenset(range(6))

    # Resolution 1 (fine): groups of 2
    res1_opens = frozenset([
        frozenset(),
        frozenset({0, 1}),
        frozenset({2, 3}),
        frozenset({4, 5}),
        frozenset({0, 1, 2, 3}),
        frozenset({2, 3, 4, 5}),
        frozenset({0, 1, 4, 5}),
        X
    ])

    # Resolution 2 (coarse): groups of 3
    res2_opens = frozenset([
        frozenset(),
        frozenset({0, 1, 2}),
        frozenset({3, 4, 5}),
        X
    ])

    # Resolution 3 (medium): left/right split
    res3_opens = frozenset([
        frozenset(),
        frozenset({0, 1, 2, 3}),
        frozenset({4, 5}),
        X
    ])

    res1 = FiniteTopology(X, res1_opens)
    res2 = FiniteTopology(X, res2_opens)
    res3 = FiniteTopology(X, res3_opens)

    print(f"\nSignal space: {{0, 1, 2, 3, 4, 5}}")
    print(f"\nResolution 1 (fine, groups of 2): {len(res1.opens)} open sets")
    print(f"Resolution 2 (coarse, groups of 3): {len(res2.opens)} open sets")
    print(f"Resolution 3 (medium, left/right): {len(res3.opens)} open sets")

    # Multi-scale consensus
    cons_12 = consensus(res1, res2)
    cons_all = consensus(res1, res2, res3)

    print(f"\nConsensus (Res 1 + Res 2): {len(cons_12.opens)} open sets")
    print(f"  Features visible at both scales: {sorted([sorted(s) for s in cons_12.opens if s and s != X])}")

    print(f"\nConsensus (all resolutions): {len(cons_all.opens)} open sets")
    print(f"  Features visible at all scales: {sorted([sorted(s) for s in cons_all.opens if s and s != X])}")

    # Refinement analysis
    print(f"\nRefinement analysis:")
    print(f"  Res1 ≤ Res2 (Res1 finer)? {res1 <= res2}")
    print(f"  Res2 ≤ Res1 (Res2 finer)? {res2 <= res1}")
    print(f"  Res1 and Res2 independent? {not (res1 <= res2) and not (res2 <= res1)}")


# ============================================================
# Application 3: Ensemble Model Diversity
# ============================================================

def ensemble_diversity_demo():
    """
    Measure the diversity of an ensemble of classifiers using
    phantom entropy.

    Each classifier defines a topology on feature space by its
    decision boundaries (which features it considers "nearby").
    """
    print("\n" + "=" * 60)
    print("APPLICATION 3: ENSEMBLE MODEL DIVERSITY")
    print("=" * 60)

    # Feature space with 4 data points
    X = frozenset({"cat", "dog", "bird", "fish"})

    # Model 1: Groups by "has legs" vs "no legs"
    model1 = FiniteTopology(X, frozenset([
        frozenset(),
        frozenset({"cat", "dog", "bird"}),
        frozenset({"fish"}),
        X
    ]))

    # Model 2: Groups by "pet" vs "wild"
    model2 = FiniteTopology(X, frozenset([
        frozenset(),
        frozenset({"cat", "dog", "fish"}),
        frozenset({"bird"}),
        X
    ]))

    # Model 3: Same as Model 1 (redundant)
    model3 = FiniteTopology(X, frozenset([
        frozenset(),
        frozenset({"cat", "dog", "bird"}),
        frozenset({"fish"}),
        X
    ]))

    # Model 4: Groups by "warm-blooded" vs "cold-blooded"
    model4 = FiniteTopology(X, frozenset([
        frozenset(),
        frozenset({"cat", "dog", "bird"}),
        frozenset({"fish"}),
        X
    ]))

    print(f"\nEnsemble of 4 classifiers on {sorted(X)}")
    print(f"\nModel 1 (has legs?): groups {{cat,dog,bird}} vs {{fish}}")
    print(f"Model 2 (is pet?): groups {{cat,dog,fish}} vs {{bird}}")
    print(f"Model 3 (duplicate of Model 1)")
    print(f"Model 4 (warm-blooded?): groups {{cat,dog,bird}} vs {{fish}}")

    # Compute spectra
    def compute_spectrum(models):
        spec = {FiniteTopology.discrete(X)}
        for r in range(1, len(models) + 1):
            for combo in combinations(models, r):
                spec.add(consensus(*combo))
        return spec

    # Full ensemble
    full_spec = compute_spectrum([model1, model2, model3, model4])
    print(f"\nFull ensemble spectrum size: {len(full_spec)}")
    print(f"Full ensemble entropy: {len(full_spec) - 1}")

    # Diverse subset {Model 1, Model 2}
    diverse_spec = compute_spectrum([model1, model2])
    print(f"\nDiverse subset (Models 1,2) spectrum size: {len(diverse_spec)}")
    print(f"Diverse subset entropy: {len(diverse_spec) - 1}")

    # Redundant subset {Model 1, Model 3, Model 4}
    redundant_spec = compute_spectrum([model1, model3, model4])
    print(f"\nRedundant subset (Models 1,3,4) spectrum size: {len(redundant_spec)}")
    print(f"Redundant subset entropy: {len(redundant_spec) - 1}")

    # Independence analysis
    print(f"\nIndependence analysis:")
    independent_12 = not (model1 <= model2) and not (model2 <= model1)
    independent_13 = not (model1 <= model3) and not (model3 <= model1)
    print(f"  Models 1,2 independent? {independent_12}")
    print(f"  Models 1,3 independent? {independent_13}")
    print(f"\n  → Higher entropy indicates more diverse ensemble")
    print(f"  → Redundant models (1≡3≡4) contribute zero entropy")


if __name__ == "__main__":
    distributed_consensus_demo()
    multi_resolution_demo()
    ensemble_diversity_demo()


"""
Phantom Topologies: Interactive Demo

Demonstrates the core concepts of phantom topology theory using concrete
examples on small finite sets.

A topology on a set X is represented as a frozenset of frozensets (the open sets).
The consensus of two topologies is their intersection (sets open in BOTH).
In the lattice ordering, this intersection corresponds to the supremum (⊔).
"""

from itertools import combinations, chain


def powerset(s):
    """Generate all subsets of a set."""
    s = list(s)
    return list(chain.from_iterable(
        frozenset(c) for c in combinations(s, r)
        for _ in [None]  # dummy
    )) + [frozenset(s)]


def all_subsets(s):
    """Generate all subsets of a set as frozensets."""
    s = list(s)
    result = []
    for r in range(len(s) + 1):
        for c in combinations(s, r):
            result.append(frozenset(c))
    return result


def is_topology(X, opens):
    """Check if a collection of sets forms a topology on X."""
    opens_set = set(opens)
    # Must contain empty set and X
    if frozenset() not in opens_set or frozenset(X) not in opens_set:
        return False
    # Closed under finite intersection
    for U in opens:
        for V in opens:
            if U & V not in opens_set:
                return False
    # Closed under arbitrary union
    for r in range(len(opens) + 1):
        for combo in combinations(list(opens), r):
            union = frozenset().union(*combo) if combo else frozenset()
            if union not in opens_set:
                return False
    return True


def all_topologies(X):
    """Enumerate all topologies on a finite set X."""
    X = frozenset(X)
    subsets = all_subsets(X)
    topologies = []
    # Check all subsets of the power set
    for r in range(len(subsets) + 1):
        for combo in combinations(subsets, r):
            opens = frozenset(combo)
            if is_topology(X, opens):
                topologies.append(opens)
    return topologies


def consensus(*topologies):
    """
    Compute the consensus (supremum) of topologies.
    In the Mathlib convention, a set is consensus-open iff it's open in ALL topologies.
    This is the intersection of the open-set collections.
    """
    if not topologies:
        # Empty consensus = all subsets = discrete topology
        return None  # Handled specially
    result = set(topologies[0])
    for t in topologies[1:]:
        result &= set(t)
    return frozenset(result)


def topology_name(X, top):
    """Give a human-readable name to a topology on {0, 1}."""
    X = frozenset(X)
    opens = set(top)
    if len(opens) == 2:  # {∅, X}
        return "indiscrete (⊤)"
    if len(opens) == len(all_subsets(X)):
        return "discrete (⊥)"
    # Sierpinski-type
    singletons_open = [x for x in X if frozenset({x}) in opens]
    if singletons_open:
        return f"Sierpinski-{singletons_open}"
    return f"|opens|={len(opens)}"


def phantom_number(X, target_top, all_tops):
    """
    Compute the phantom number: minimum k such that target_top
    is the consensus of k topologies.
    """
    # Check k=0: consensus of empty = discrete
    X_set = frozenset(X)
    discrete = frozenset(all_subsets(X_set))
    if target_top == discrete:
        return 0

    for k in range(1, len(all_tops) + 1):
        for combo in combinations(all_tops, k):
            if consensus(*combo) == target_top:
                return k
    return float('inf')


def phantom_spectrum(X, observers):
    """
    Compute the phantom spectrum: all consensus topologies achievable
    from subsets of observers.
    """
    X_set = frozenset(X)
    discrete = frozenset(all_subsets(X_set))
    spec = {discrete}  # Empty subset gives discrete
    for r in range(1, len(observers) + 1):
        for combo in combinations(observers, r):
            c = consensus(*combo)
            spec.add(c)
    return spec


def phantom_filtration(X, observer_seq):
    """
    Compute the phantom filtration: consensus at each stage.
    Returns list of (stage, consensus_topology).
    """
    X_set = frozenset(X)
    discrete = frozenset(all_subsets(X_set))
    stages = [(0, discrete)]
    for n in range(1, len(observer_seq) + 1):
        c = consensus(*observer_seq[:n])
        stages.append((n, c))
    return stages


def demo_two_element_set():
    """Demonstrate phantom topology on {0, 1}."""
    X = {0, 1}
    print("=" * 60)
    print("PHANTOM TOPOLOGIES ON X = {0, 1}")
    print("=" * 60)

    # Enumerate all topologies
    tops = all_topologies(X)
    print(f"\nNumber of topologies on {{0, 1}}: {len(tops)}")

    for i, t in enumerate(tops):
        name = topology_name(X, t)
        print(f"  τ_{i+1} = {name}")
        print(f"    Open sets: {sorted([sorted(s) for s in t])}")

    # Compute phantom numbers
    print("\nPhantom numbers:")
    for i, t in enumerate(tops):
        pn = phantom_number(X, t, tops)
        name = topology_name(X, t)
        print(f"  phantom(τ_{i+1}) = {pn}  ({name})")

    # Two-observer example
    print("\n" + "-" * 40)
    print("TWO-OBSERVER PHANTOM SYSTEM")
    print("-" * 40)

    # Find Sierpinski topologies
    sierp = [t for t in tops if len(t) == 3]
    if len(sierp) >= 2:
        obs1, obs2 = sierp[0], sierp[1]
        print(f"\nObserver 1 sees: {topology_name(X, obs1)}")
        print(f"  Open sets: {sorted([sorted(s) for s in obs1])}")
        print(f"\nObserver 2 sees: {topology_name(X, obs2)}")
        print(f"  Open sets: {sorted([sorted(s) for s in obs2])}")

        cons = consensus(obs1, obs2)
        print(f"\nConsensus: {topology_name(X, cons)}")
        print(f"  Open sets: {sorted([sorted(s) for s in cons])}")

        # Phantom spectrum
        spec = phantom_spectrum(X, [obs1, obs2])
        print(f"\nPhantom spectrum (|Spec| = {len(spec)}):")
        for s in sorted(spec, key=lambda t: len(t)):
            print(f"  {topology_name(X, s)} ({len(s)} open sets)")

        print(f"\nPhantom entropy = {len(spec) - 1}")

    # Filtration example
    print("\n" + "-" * 40)
    print("PHANTOM FILTRATION")
    print("-" * 40)

    if len(sierp) >= 2:
        obs_seq = [sierp[0], sierp[1]]
        stages = phantom_filtration(X, obs_seq)

        print(f"\nObserver sequence: {[topology_name(X, o) for o in obs_seq]}")
        print("\nFiltration stages:")
        for stage, c in stages:
            print(f"  Stage {stage}: {topology_name(X, c)} ({len(c)} open sets)")

        # Check stabilization
        stabilized = False
        for i in range(1, len(stages)):
            if stages[i][1] == stages[i-1][1]:
                print(f"\n✓ Filtration stabilizes at stage {stages[i-1][0]}")
                stabilized = True
                break
        if not stabilized:
            print(f"\n→ Filtration has not stabilized after {len(stages)-1} stages")


def demo_three_element_set():
    """Demonstrate phantom topology on {0, 1, 2}."""
    X = {0, 1, 2}
    print("\n" + "=" * 60)
    print("PHANTOM TOPOLOGIES ON X = {0, 1, 2}")
    print("=" * 60)

    tops = all_topologies(X)
    print(f"\nNumber of topologies on {{0, 1, 2}}: {len(tops)}")

    # Compute phantom numbers for all
    print("\nPhantom number distribution:")
    pn_counts = {}
    for t in tops:
        pn = phantom_number(X, t, tops)
        pn_counts[pn] = pn_counts.get(pn, 0) + 1

    for pn in sorted(pn_counts):
        print(f"  phantom number {pn}: {pn_counts[pn]} topologies")

    # Verify finite phantom bound conjecture for n=3
    max_pn = max(pn_counts.keys())
    if max_pn <= 3:
        print(f"\n✓ Finite Phantom Bound Conjecture holds for n=3: max phantom number = {max_pn} ≤ 3")
    else:
        print(f"\n✗ Finite Phantom Bound Conjecture FAILS for n=3: max phantom number = {max_pn} > 3")


def demo_independence():
    """Demonstrate observer independence."""
    X = {0, 1}
    print("\n" + "=" * 60)
    print("OBSERVER INDEPENDENCE")
    print("=" * 60)

    tops = all_topologies(X)

    print("\nTopology lattice ordering (τ_i ≤ τ_j means τ_i is finer):")
    for i, ti in enumerate(tops):
        for j, tj in enumerate(tops):
            if i < j:
                if set(tj).issubset(set(ti)):
                    print(f"  τ_{i+1} ≤ τ_{j+1} ({topology_name(X, ti)} ≤ {topology_name(X, tj)})")

    print("\nIndependent pairs (neither refines the other):")
    for i, ti in enumerate(tops):
        for j, tj in enumerate(tops):
            if i < j:
                ti_le_tj = set(tj).issubset(set(ti))
                tj_le_ti = set(ti).issubset(set(tj))
                if not ti_le_tj and not tj_le_ti:
                    print(f"  τ_{i+1} ⊥ τ_{j+1} ({topology_name(X, ti)} ⊥ {topology_name(X, tj)})")


if __name__ == "__main__":
    demo_two_element_set()
    demo_three_element_set()
    demo_independence()


"""
Visualization: Phantom Filtration Heatmap

Shows how the open-set structure evolves across filtration stages.
Each row is a potential open set, each column is a filtration stage.
Color indicates whether the set is open (green) or closed (red) at
that stage.

Demonstrates the monotone coarsening: green cells can only turn red
as we move right (adding observers removes consensus-open sets).
"""

import matplotlib.pyplot as plt
import numpy as np

# Topologies on X = {0, 1, 2}
X = {0, 1, 2}

# All subsets of X
subsets = [
    frozenset(),
    frozenset({0}),
    frozenset({1}),
    frozenset({2}),
    frozenset({0, 1}),
    frozenset({0, 2}),
    frozenset({1, 2}),
    frozenset({0, 1, 2}),
]
subset_labels = ["∅", "{0}", "{1}", "{2}", "{0,1}", "{0,2}", "{1,2}", "{0,1,2}"]

# Observer topologies (each must be a valid topology)
# Observer 1: distinguishes {0} from {1,2}
obs1_opens = {frozenset(), frozenset({0}), frozenset({1, 2}), frozenset({0, 1, 2})}

# Observer 2: distinguishes {1} from {0,2}
obs2_opens = {frozenset(), frozenset({1}), frozenset({0, 2}), frozenset({0, 1, 2})}

# Observer 3: distinguishes {0,1} from {2}
obs3_opens = {frozenset(), frozenset({2}), frozenset({0, 1}), frozenset({0, 1, 2})}

# Observer 4: same as observer 1 (redundant - should cause stabilization)
obs4_opens = obs1_opens.copy()

observers = [obs1_opens, obs2_opens, obs3_opens, obs4_opens]
observer_names = ["Observer 1\n{0}|{1,2}", "Observer 2\n{1}|{0,2}",
                  "Observer 3\n{0,1}|{2}", "Observer 4\n(=Obs 1)"]

# Compute filtration stages
# Stage 0: discrete (all subsets open)
# Stage k: intersection of observers 1..k
n_stages = len(observers) + 1
n_subsets = len(subsets)

# Build the heatmap matrix
# 1 = open, 0 = closed
heatmap = np.zeros((n_subsets, n_stages))

# Stage 0: discrete
for i in range(n_subsets):
    heatmap[i, 0] = 1

# Stage k: consensus of first k observers
for k in range(1, n_stages):
    consensus_opens = set(subsets)  # Start with all
    for j in range(k):
        consensus_opens &= observers[j]
    for i, s in enumerate(subsets):
        heatmap[i, k] = 1 if s in consensus_opens else 0

fig, axes = plt.subplots(1, 2, figsize=(14, 6), gridspec_kw={'width_ratios': [3, 1]})

# --- Panel 1: Heatmap ---
ax = axes[0]
cmap = plt.cm.colors.ListedColormap(['#E74C3C', '#2ECC71'])

im = ax.imshow(heatmap, cmap=cmap, aspect='auto', interpolation='nearest')

ax.set_xticks(range(n_stages))
stage_labels = ["Stage 0\n(discrete)"] + [f"Stage {k}\n(+{observer_names[k-1]})" for k in range(1, n_stages)]
ax.set_xticklabels(stage_labels, fontsize=8)
ax.set_yticks(range(n_subsets))
ax.set_yticklabels(subset_labels, fontsize=10)

ax.set_xlabel("Filtration Stage", fontsize=12, fontweight='bold')
ax.set_ylabel("Subset of X = {0, 1, 2}", fontsize=12, fontweight='bold')
ax.set_title("Phantom Filtration Heatmap\nGreen = Open, Red = Closed", fontsize=14, fontweight='bold')

# Add text labels
for i in range(n_subsets):
    for j in range(n_stages):
        text = "✓" if heatmap[i, j] == 1 else "✗"
        color = 'white'
        ax.text(j, i, text, ha='center', va='center', fontsize=12,
                color=color, fontweight='bold')

# Highlight stabilization
for k in range(1, n_stages):
    col_k = heatmap[:, k]
    col_prev = heatmap[:, k-1]
    if np.array_equal(col_k, col_prev):
        ax.axvline(x=k - 0.5, color='gold', linewidth=3, linestyle='--', alpha=0.7)
        ax.text(k, -0.8, "STABILIZED", ha='center', fontsize=8,
                color='goldenrod', fontweight='bold')
        break

# --- Panel 2: Open set count ---
ax2 = axes[1]
counts = [int(heatmap[:, k].sum()) for k in range(n_stages)]
colors = ['#2ECC71' if k == 0 else '#3498DB' for k in range(n_stages)]

bars = ax2.barh(range(n_stages), counts, color=colors, edgecolor='#2C3E50', height=0.6)
ax2.set_yticks(range(n_stages))
ax2.set_yticklabels([f"Stage {k}" for k in range(n_stages)], fontsize=10)
ax2.set_xlabel("Number of Open Sets", fontsize=12, fontweight='bold')
ax2.set_title("Open Set Count\n(monotone decreasing)", fontsize=13, fontweight='bold')
ax2.invert_yaxis()

for i, (count, bar) in enumerate(zip(counts, bars)):
    ax2.text(count + 0.1, i, str(count), va='center', fontsize=11, fontweight='bold')

ax2.set_xlim(0, max(counts) + 1)

plt.tight_layout()
plt.savefig('filtration_heatmap.png', dpi=150, bbox_inches='tight',
            facecolor='white', edgecolor='none')
plt.close()
print("Saved: filtration_heatmap.png")


"""
Visualization: Phantom Entropy vs. Observer Count

Shows how phantom entropy grows as observers are added to a system.
Compares: (a) independent observers (each contributes new information),
(b) redundant observers (duplicates contribute nothing).

The key insight: entropy grows linearly with independent observers
but plateaus with redundant ones, providing a diversity measure.
"""

import matplotlib.pyplot as plt
import numpy as np
from itertools import combinations

# Work with topologies on X = {0, 1}
# 4 topologies: discrete, Sierp-0, Sierp-1, indiscrete
X = frozenset({0, 1})

discrete = frozenset([frozenset(), frozenset({0}), frozenset({1}), frozenset({0, 1})])
sierp0 = frozenset([frozenset(), frozenset({0}), frozenset({0, 1})])
sierp1 = frozenset([frozenset(), frozenset({1}), frozenset({0, 1})])
indiscrete = frozenset([frozenset(), frozenset({0, 1})])


def consensus_of(*tops):
    """Consensus = intersection of open-set families."""
    if not tops:
        return discrete
    result = set(tops[0])
    for t in tops[1:]:
        result &= set(t)
    return frozenset(result)


def spectrum_size(observers):
    """Compute |spectrum| for a list of observers."""
    spec = {discrete}  # Empty subset
    for r in range(1, len(observers) + 1):
        for combo in combinations(observers, r):
            spec.add(consensus_of(*combo))
    return len(spec)


# Scenario 1: Independent observers (alternating Sierp-0, Sierp-1)
independent_observers = [sierp0, sierp1, sierp0, sierp1, sierp0, sierp1]
independent_entropies = []
for k in range(len(independent_observers) + 1):
    obs = independent_observers[:k]
    spec = spectrum_size(obs)
    independent_entropies.append(spec - 1)

# Scenario 2: Redundant observers (all Sierp-0)
redundant_observers = [sierp0, sierp0, sierp0, sierp0, sierp0, sierp0]
redundant_entropies = []
for k in range(len(redundant_observers) + 1):
    obs = redundant_observers[:k]
    spec = spectrum_size(obs)
    redundant_entropies.append(spec - 1)

# Scenario 3: Mixed (some independent, some redundant)
mixed_observers = [sierp0, sierp1, sierp0, indiscrete, sierp1, sierp0]
mixed_entropies = []
for k in range(len(mixed_observers) + 1):
    obs = mixed_observers[:k]
    spec = spectrum_size(obs)
    mixed_entropies.append(spec - 1)

fig, axes = plt.subplots(1, 2, figsize=(14, 6))

# --- Panel 1: Entropy Growth ---
ax = axes[0]
x = np.arange(len(independent_entropies))

ax.plot(x, independent_entropies, 'o-', color='#2ECC71', linewidth=2.5,
        markersize=8, label='Independent (Sierp-0, Sierp-1, ...)', zorder=5)
ax.plot(x, redundant_entropies, 's-', color='#E74C3C', linewidth=2.5,
        markersize=8, label='Redundant (all Sierp-0)', zorder=5)
ax.plot(x, mixed_entropies, '^-', color='#3498DB', linewidth=2.5,
        markersize=8, label='Mixed', zorder=5)

ax.fill_between(x, independent_entropies, alpha=0.1, color='#2ECC71')
ax.fill_between(x, redundant_entropies, alpha=0.1, color='#E74C3C')

ax.set_xlabel("Number of Observers", fontsize=13, fontweight='bold')
ax.set_ylabel("Phantom Entropy", fontsize=13, fontweight='bold')
ax.set_title("Phantom Entropy vs. Observer Count\n(X = {0, 1})", fontsize=14, fontweight='bold')
ax.legend(fontsize=10, loc='upper left')
ax.grid(True, alpha=0.3)
ax.set_xticks(x)
ax.set_ylim(-0.5, max(independent_entropies) + 1)

# Annotate key points
ax.annotate("Redundancy →\nno entropy gain",
            xy=(2, redundant_entropies[2]),
            xytext=(3.5, 0.5),
            fontsize=9,
            arrowprops=dict(arrowstyle='->', color='#E74C3C'),
            color='#E74C3C')

ax.annotate("Each new independent\nobserver adds entropy",
            xy=(3, independent_entropies[3]),
            xytext=(4, independent_entropies[3] - 0.8),
            fontsize=9,
            arrowprops=dict(arrowstyle='->', color='#2ECC71'),
            color='#2ECC71')

# --- Panel 2: Spectrum Structure ---
ax2 = axes[1]

# Show spectrum structure for 2 independent observers
obs_list = [sierp0, sierp1]
spec_elements = set()
spec_elements.add(("∅→discrete", discrete))

all_combos = []
for r in range(1, len(obs_list) + 1):
    for combo in combinations(range(len(obs_list)), r):
        obs = tuple(obs_list[i] for i in combo)
        c = consensus_of(*obs)
        label = "{" + ",".join(f"obs{i+1}" for i in combo) + "}"
        all_combos.append((label, c, combo))

# Create bar chart of spectrum
labels = ["S=∅\n(discrete)"]
sizes = [4]  # discrete has 4 open sets
colors_bar = ['#E74C3C']

for label, c, combo in all_combos:
    labels.append(f"S={label}")
    sizes.append(len(c))
    if len(combo) == 1:
        colors_bar.append('#3498DB' if combo[0] == 0 else '#F39C12')
    else:
        colors_bar.append('#9B59B6')

bars = ax2.bar(range(len(labels)), sizes, color=colors_bar,
               edgecolor='#2C3E50', linewidth=1.5)

ax2.set_xticks(range(len(labels)))
ax2.set_xticklabels(labels, fontsize=9, rotation=15, ha='right')
ax2.set_ylabel("|Open Sets|", fontsize=13, fontweight='bold')
ax2.set_title("Phantom Spectrum Structure\n(2 Independent Observers)", fontsize=14, fontweight='bold')
ax2.grid(True, alpha=0.3, axis='y')

# Add value labels on bars
for bar, size in zip(bars, sizes):
    ax2.text(bar.get_x() + bar.get_width()/2, bar.get_height() + 0.1,
             str(size), ha='center', va='bottom', fontsize=11, fontweight='bold')

# Add topology names
topology_names = {4: "discrete", 3: "Sierp", 2: "indiscrete"}
for bar, size in zip(bars, sizes):
    if size in topology_names:
        ax2.text(bar.get_x() + bar.get_width()/2, bar.get_height()/2,
                 topology_names[size], ha='center', va='center',
                 fontsize=8, color='white', fontweight='bold')

ax2.set_ylim(0, 5.5)

plt.tight_layout()
plt.savefig('phantom_entropy.png', dpi=150, bbox_inches='tight',
            facecolor='white', edgecolor='none')
plt.close()
print("Saved: phantom_entropy.png")


"""
Visualization: Topology Lattice and Phantom Spectrum

Visualizes the complete lattice of topologies on {0,1} and highlights
the phantom spectrum of a two-observer system. Shows how different
observer combinations produce different consensus topologies.

Uses matplotlib to create a Hasse diagram of the topology lattice
with the phantom spectrum highlighted in color.
"""

import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np

# The 4 topologies on {0, 1}
# In Mathlib's ordering: ≤ means "finer" (more open sets)
# ⊥ = discrete (finest), ⊤ = indiscrete (coarsest)
topologies = {
    "discrete": {"∅", "{0}", "{1}", "{0,1}"},       # ⊥, 4 open sets
    "Sierpinski-0": {"∅", "{0}", "{0,1}"},           # 3 open sets
    "Sierpinski-1": {"∅", "{1}", "{0,1}"},           # 3 open sets
    "indiscrete": {"∅", "{0,1}"},                     # ⊤, 2 open sets
}

# Positions in the Hasse diagram (x, y)
positions = {
    "discrete": (0, 0),
    "Sierpinski-0": (-1.2, 1.5),
    "Sierpinski-1": (1.2, 1.5),
    "indiscrete": (0, 3),
}

# Edges in the Hasse diagram (finer → coarser)
edges = [
    ("discrete", "Sierpinski-0"),
    ("discrete", "Sierpinski-1"),
    ("Sierpinski-0", "indiscrete"),
    ("Sierpinski-1", "indiscrete"),
]

fig, axes = plt.subplots(1, 3, figsize=(16, 6))

# --- Panel 1: Full Topology Lattice ---
ax = axes[0]
ax.set_title("Topology Lattice on {0, 1}", fontsize=13, fontweight='bold')

for name, (x, y) in positions.items():
    circle = plt.Circle((x, y), 0.4, fill=True, color='#4ECDC4',
                         edgecolor='#2C3E50', linewidth=2, zorder=5)
    ax.add_patch(circle)
    ax.text(x, y + 0.05, name.replace("-", "-\n") if "Sierpinski" in name else name,
            ha='center', va='center', fontsize=8, fontweight='bold', zorder=6)
    ax.text(x, y - 0.25, f"|opens|={len(topologies[name])}",
            ha='center', va='center', fontsize=7, color='#2C3E50', zorder=6)

for a, b in edges:
    xa, ya = positions[a]
    xb, yb = positions[b]
    ax.annotate("", xy=(xb, yb - 0.4), xytext=(xa, ya + 0.4),
                arrowprops=dict(arrowstyle='->', color='#7F8C8D', lw=1.5))

ax.text(0, -0.9, "⊥ = discrete (finest)", ha='center', fontsize=9, style='italic')
ax.text(0, 3.8, "⊤ = indiscrete (coarsest)", ha='center', fontsize=9, style='italic')
ax.set_xlim(-2.5, 2.5)
ax.set_ylim(-1.5, 4.5)
ax.set_aspect('equal')
ax.axis('off')

# --- Panel 2: Phantom Spectrum ---
ax = axes[1]
ax.set_title("Phantom Spectrum\n(Observers: Sierp-0, Sierp-1)", fontsize=13, fontweight='bold')

# Spectrum = {discrete, Sierp-0, Sierp-1, indiscrete}
# S=∅ → discrete, S={0} → Sierp-0, S={1} → Sierp-1, S={0,1} → indiscrete
spectrum_labels = {
    "discrete": "S = ∅",
    "Sierpinski-0": "S = {obs₁}",
    "Sierpinski-1": "S = {obs₂}",
    "indiscrete": "S = {obs₁, obs₂}",
}

spectrum_colors = {
    "discrete": '#E74C3C',
    "Sierpinski-0": '#3498DB',
    "Sierpinski-1": '#F39C12',
    "indiscrete": '#9B59B6',
}

for name, (x, y) in positions.items():
    color = spectrum_colors[name]
    circle = plt.Circle((x, y), 0.4, fill=True, color=color,
                         edgecolor='#2C3E50', linewidth=2, zorder=5, alpha=0.85)
    ax.add_patch(circle)
    ax.text(x, y + 0.08, name.replace("-", "-\n") if "Sierpinski" in name else name,
            ha='center', va='center', fontsize=8, fontweight='bold', zorder=6, color='white')
    ax.text(x, y - 0.55, spectrum_labels[name],
            ha='center', va='center', fontsize=8, zorder=6,
            bbox=dict(boxstyle='round,pad=0.2', facecolor=color, alpha=0.3))

for a, b in edges:
    xa, ya = positions[a]
    xb, yb = positions[b]
    ax.annotate("", xy=(xb, yb - 0.4), xytext=(xa, ya + 0.4),
                arrowprops=dict(arrowstyle='->', color='#7F8C8D', lw=1.5))

ax.text(0, -1.2, "Phantom Entropy = 4 - 1 = 3", ha='center', fontsize=10,
        fontweight='bold', color='#2C3E50')
ax.set_xlim(-2.5, 2.5)
ax.set_ylim(-1.8, 4.5)
ax.set_aspect('equal')
ax.axis('off')

# --- Panel 3: Filtration Timeline ---
ax = axes[2]
ax.set_title("Phantom Filtration\n(Sequential Observer Addition)", fontsize=13, fontweight='bold')

# Filtration: Stage 0 = discrete, Stage 1 = Sierp-0, Stage 2 = indiscrete
stages = [
    (0, "discrete", '#E74C3C', 4),
    (1, "Sierpinski-0", '#3498DB', 3),
    (2, "indiscrete", '#9B59B6', 2),
]

x_pos = [0, 1.5, 3]
y_pos = [2, 2, 2]

for i, (stage, name, color, nopen) in enumerate(stages):
    circle = plt.Circle((x_pos[i], y_pos[i]), 0.5, fill=True, color=color,
                         edgecolor='#2C3E50', linewidth=2, zorder=5, alpha=0.85)
    ax.add_patch(circle)
    ax.text(x_pos[i], y_pos[i] + 0.1, f"Stage {stage}", ha='center', va='center',
            fontsize=9, fontweight='bold', color='white', zorder=6)
    ax.text(x_pos[i], y_pos[i] - 0.15, name.replace("Sierpinski-0", "Sierp-0"),
            ha='center', va='center', fontsize=7, color='white', zorder=6)
    ax.text(x_pos[i], y_pos[i] - 0.7, f"|opens|={nopen}", ha='center',
            fontsize=8, color='#2C3E50')

# Arrows between stages
for i in range(len(stages) - 1):
    ax.annotate("", xy=(x_pos[i+1] - 0.5, y_pos[i+1]),
                xytext=(x_pos[i] + 0.5, y_pos[i]),
                arrowprops=dict(arrowstyle='->', color='#2C3E50', lw=2))
    label = f"+obs{i+1}" if i == 0 else f"+obs{i+1}"
    ax.text((x_pos[i] + x_pos[i+1]) / 2, y_pos[i] + 0.4, f"+observer {i+1}",
            ha='center', fontsize=8, color='#7F8C8D')

# Monotonicity arrow
ax.annotate("", xy=(3.5, 0.5), xytext=(-0.5, 0.5),
            arrowprops=dict(arrowstyle='->', color='#95A5A6', lw=1, linestyle='dashed'))
ax.text(1.5, 0.2, "consensus gets coarser →", ha='center', fontsize=9,
        color='#95A5A6', style='italic')

ax.set_xlim(-1, 4)
ax.set_ylim(-0.5, 3.5)
ax.set_aspect('equal')
ax.axis('off')

plt.tight_layout()
plt.savefig('topology_lattice.png', dpi=150, bbox_inches='tight',
            facecolor='white', edgecolor='none')
plt.close()
print("Saved: topology_lattice.png")
