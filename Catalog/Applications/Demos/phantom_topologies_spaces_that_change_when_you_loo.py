#!/usr/bin/env python3
"""
Phantom Topologies: Numerical Demonstrations

Demonstrates the key concepts of phantom topologies using finite sets,
where topologies can be explicitly enumerated and consensus computed.
"""

from itertools import combinations, product
from typing import FrozenSet, Set, Tuple


# A topology on a finite set X is represented as a frozenset of frozensets (open sets)
Topology = FrozenSet[FrozenSet[int]]


def is_topology(X: FrozenSet[int], opens: Set[FrozenSet[int]]) -> bool:
    """Check if a collection of subsets forms a topology on X."""
    # Must contain empty set and X
    if frozenset() not in opens or X not in opens:
        return False
    # Closed under pairwise intersection
    for A in opens:
        for B in opens:
            if A & B not in opens:
                return False
    # Closed under arbitrary union
    for r in range(len(opens) + 1):
        for subset in combinations(opens, r):
            union = frozenset().union(*subset) if subset else frozenset()
            if union not in opens:
                return False
    return True


def all_topologies(X: FrozenSet[int]) -> list:
    """Enumerate all topologies on a finite set X."""
    power_set = []
    elems = list(X)
    for mask in range(1 << len(elems)):
        power_set.append(frozenset(elems[i] for i in range(len(elems)) if mask & (1 << i)))

    topologies = []
    # A topology must contain {} and X; check all subsets of the power set
    required = {frozenset(), X}
    optional = [s for s in power_set if s not in required]

    for mask in range(1 << len(optional)):
        candidate = set(required)
        for i in range(len(optional)):
            if mask & (1 << i):
                candidate.add(optional[i])
        if is_topology(X, candidate):
            topologies.append(frozenset(candidate))
    return topologies


def consensus(topologies: list) -> Topology:
    """Compute consensus topology: intersection of open-set families."""
    if not topologies:
        return frozenset()
    result = set(topologies[0])
    for t in topologies[1:]:
        result &= set(t)
    return frozenset(result)


def is_strictly_finer(t1: Topology, t2: Topology) -> bool:
    """Check if t1 is strictly finer than t2 (t1 ⊃ t2 as open-set families)."""
    return set(t2) < set(t1)


def strict_phantom_number(X: FrozenSet[int], tau: Topology, all_tops: list) -> int:
    """Compute the strict phantom number of topology tau."""
    finer = [t for t in all_tops if is_strictly_finer(t, tau)]
    if not finer:
        return 0  # No strictly finer topology exists (tau is discrete)

    # Check n = 2, 3, ...
    for n in range(2, len(finer) + 1):
        for combo in combinations(finer, n):
            if consensus(list(combo)) == tau:
                return n
    return 0  # No strict representation found


def demo_three_element_set():
    """Demonstrate phantom topologies on {0, 1, 2}."""
    X = frozenset({0, 1, 2})
    print("=" * 60)
    print("PHANTOM TOPOLOGIES ON {0, 1, 2}")
    print("=" * 60)

    all_tops = all_topologies(X)
    print(f"\nTotal topologies on {{0, 1, 2}}: {len(all_tops)}")

    # Identify discrete and indiscrete
    discrete = frozenset(frozenset(s) for mask in range(1 << 3)
                         for s in [frozenset(i for i in range(3) if mask & (1 << i))])
    indiscrete = frozenset({frozenset(), X})

    print(f"Discrete topology has {len(discrete)} open sets")
    print(f"Indiscrete topology has {len(indiscrete)} open sets")

    # Compute strict phantom numbers
    print("\nStrict Phantom Numbers:")
    print("-" * 40)
    spn_counts = {}
    for tau in all_tops:
        spn = strict_phantom_number(X, tau, all_tops)
        spn_counts[spn] = spn_counts.get(spn, 0) + 1
        if len(tau) <= 6:  # Print small topologies
            opens_str = "{" + ", ".join(str(set(s)) for s in sorted(tau, key=len)) + "}"
            print(f"  |opens|={len(tau):2d}, spn={spn}")

    print(f"\nDistribution of phantom numbers:")
    for spn in sorted(spn_counts):
        print(f"  spn={spn}: {spn_counts[spn]} topologies")


def demo_consensus():
    """Demonstrate consensus computation."""
    print("\n" + "=" * 60)
    print("CONSENSUS DEMONSTRATION")
    print("=" * 60)

    X = frozenset({0, 1, 2})

    # Two observers with different topologies
    # Observer 1: {∅, {0}, {0,1,2}}
    t1 = frozenset({frozenset(), frozenset({0}), X})
    # Observer 2: {∅, {1}, {0,1,2}}
    t2 = frozenset({frozenset(), frozenset({1}), X})

    cons = consensus([t1, t2])

    print(f"\nObserver 1 opens: {[set(s) for s in sorted(t1, key=len)]}")
    print(f"Observer 2 opens: {[set(s) for s in sorted(t2, key=len)]}")
    print(f"Consensus opens:  {[set(s) for s in sorted(cons, key=len)]}")
    print(f"Consensus = indiscrete: {cons == frozenset({frozenset(), X})}")


def demo_sorgenfrey_approximation():
    """Approximate the Sorgenfrey decomposition of ℝ on a finite grid."""
    print("\n" + "=" * 60)
    print("SORGENFREY DECOMPOSITION (FINITE APPROXIMATION)")
    print("=" * 60)

    # Approximate ℝ with {0, 1, 2, 3, 4} and intervals
    # Standard topology basis: (a,b) open intervals
    # Lower-limit basis: [a,b) half-open intervals
    # Upper-limit basis: (a,b] half-open intervals
    n = 5
    X = frozenset(range(n))

    # On a finite linearly ordered set, the "standard" order topology
    # has basis: singletons and intervals
    # The "lower-limit" topology adds sets of the form {a, a+1, ..., b-1}
    # The "upper-limit" topology adds sets of the form {a+1, ..., b}

    # For demonstration, let's use:
    # Standard: all intervals (a, b) = {x : a < x < b}
    # Lower-limit: add [a, b) = {x : a ≤ x < b}
    # Upper-limit: add (a, b] = {x : a < x ≤ b}

    def generate_topology(generators, X):
        """Generate a topology from a set of generators."""
        opens = {frozenset(), X}
        opens.update(generators)
        changed = True
        while changed:
            changed = False
            new_opens = set(opens)
            # Close under finite intersection
            for A in list(opens):
                for B in list(opens):
                    inter = A & B
                    if inter not in new_opens:
                        new_opens.add(inter)
                        changed = True
            # Close under arbitrary union
            for r in range(2, len(new_opens) + 1):
                for combo in combinations(list(new_opens), r):
                    union = frozenset().union(*combo)
                    if union not in new_opens:
                        new_opens.add(union)
                        changed = True
            opens = new_opens
        return frozenset(opens)

    # Standard open intervals (a,b) for 0 ≤ a < b ≤ n
    std_gens = set()
    for a in range(n):
        for b in range(a + 2, n + 1):
            interval = frozenset(x for x in range(n) if a < x < b)
            if interval:
                std_gens.add(interval)

    # Lower-limit: [a, b) for 0 ≤ a < b ≤ n
    lower_gens = set(std_gens)
    for a in range(n):
        for b in range(a + 1, n + 1):
            interval = frozenset(x for x in range(n) if a <= x < b)
            if interval:
                lower_gens.add(interval)

    # Upper-limit: (a, b] for 0 ≤ a < b ≤ n
    upper_gens = set(std_gens)
    for a in range(n):
        for b in range(a + 1, n + 1):
            interval = frozenset(x for x in range(n) if a < x <= b)
            if interval:
                upper_gens.add(interval)

    std_top = generate_topology(std_gens, X)
    lower_top = generate_topology(lower_gens, X)
    upper_top = generate_topology(upper_gens, X)
    cons = consensus([lower_top, upper_top])

    print(f"\nFinite set: {{0, 1, 2, 3, 4}}")
    print(f"Standard topology:    {len(std_top):3d} open sets")
    print(f"Lower-limit topology: {len(lower_top):3d} open sets")
    print(f"Upper-limit topology: {len(upper_top):3d} open sets")
    print(f"Consensus:            {len(cons):3d} open sets")
    print(f"Consensus ⊆ Standard: {set(cons) <= set(std_top)}")
    print(f"Standard ⊆ Consensus: {set(std_top) <= set(cons)}")
    print(f"Consensus = Standard:  {cons == std_top}")

    # Check strict finiteness
    print(f"\nLower-limit strictly finer than consensus: {is_strictly_finer(lower_top, cons)}")
    print(f"Upper-limit strictly finer than consensus: {is_strictly_finer(upper_top, cons)}")

    if cons == std_top and is_strictly_finer(lower_top, cons) and is_strictly_finer(upper_top, cons):
        print("\n✓ Sorgenfrey decomposition verified on finite approximation!")
        print("  The standard topology = consensus of lower-limit and upper-limit")
    else:
        print("\n(Finite approximation may not perfectly match continuous case)")


def demo_phantom_spectrum():
    """Demonstrate the phantom spectrum concept."""
    print("\n" + "=" * 60)
    print("PHANTOM SPECTRUM DEMONSTRATION")
    print("=" * 60)

    X = frozenset({0, 1, 2, 3})

    # Two observers
    # Observer 0: standard + sees {0} as open
    t0 = frozenset({frozenset(), frozenset({0}), frozenset({0, 1}),
                     frozenset({0, 1, 2}), X})
    # Observer 1: standard + sees {3} as open
    t1 = frozenset({frozenset(), frozenset({3}), frozenset({2, 3}),
                     frozenset({1, 2, 3}), X})

    cons = consensus([t0, t1])

    print(f"\nObserver 0 opens: {sorted([set(s) for s in t0], key=len)}")
    print(f"Observer 1 opens: {sorted([set(s) for s in t1], key=len)}")
    print(f"Consensus opens:  {sorted([set(s) for s in cons], key=len)}")

    # Compute spectrum for each point
    for x in sorted(X):
        spec = []
        for i, t in enumerate([t0, t1]):
            for U in t:
                if x in U and U not in cons:
                    spec.append(i)
                    break
        print(f"  Spectrum at {x}: observers {spec}")


if __name__ == "__main__":
    demo_three_element_set()
    demo_consensus()
    demo_sorgenfrey_approximation()
    demo_phantom_spectrum()

    print("\n" + "=" * 60)
    print("ALL DEMONSTRATIONS COMPLETE")
    print("=" * 60)


#!/usr/bin/env python3
"""
Visualization: Phantom Topology Lattice and Consensus

Visualizes the lattice of topologies on a small finite set,
highlighting phantom decompositions and consensus.
"""

import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np
from itertools import combinations
from typing import FrozenSet, Set, List, Dict, Tuple

Element = int
Subset = FrozenSet[Element]
Topology = FrozenSet[Subset]


def enumerate_topologies_3() -> List[Topology]:
    """Enumerate all 29 topologies on {0, 1, 2}."""
    X = frozenset({0, 1, 2})
    power_set = []
    for mask in range(1 << 3):
        power_set.append(frozenset(i for i in range(3) if mask & (1 << i)))

    required = {frozenset(), X}
    optional = [s for s in power_set if s not in required]
    topologies = []

    for mask in range(1 << len(optional)):
        candidate = set(required)
        for i in range(len(optional)):
            if mask & (1 << i):
                candidate.add(optional[i])

        valid = True
        clist = list(candidate)
        for i in range(len(clist)):
            for j in range(i, len(clist)):
                if clist[i] & clist[j] not in candidate:
                    valid = False
                    break
                if clist[i] | clist[j] not in candidate:
                    valid = False
                    break
            if not valid:
                break
        if valid:
            topologies.append(frozenset(candidate))

    return topologies


def compute_consensus(observers: List[Topology]) -> Topology:
    if not observers:
        return frozenset()
    result = set(observers[0])
    for t in observers[1:]:
        result &= set(t)
    return frozenset(result)


def is_strictly_finer(t1: Topology, t2: Topology) -> bool:
    return set(t2) < set(t1)


def compute_spn(tau: Topology, all_tops: List[Topology]) -> int:
    finer = [t for t in all_tops if is_strictly_finer(t, tau)]
    if not finer:
        return 0
    for n in range(2, len(finer) + 1):
        for combo in combinations(finer, n):
            if compute_consensus(list(combo)) == tau:
                return n
    return 0


def plot_phantom_lattice():
    """Plot the topology lattice with phantom number coloring."""
    tops = enumerate_topologies_3()
    X = frozenset({0, 1, 2})

    # Compute phantom numbers
    spn_map = {}
    for tau in tops:
        spn_map[tau] = compute_spn(tau, tops)

    # Sort by number of open sets (proxy for lattice level)
    tops_sorted = sorted(tops, key=lambda t: len(t))

    # Group by size for y-coordinate
    size_groups: Dict[int, List[int]] = {}
    for i, t in enumerate(tops_sorted):
        s = len(t)
        if s not in size_groups:
            size_groups[s] = []
        size_groups[s].append(i)

    # Assign positions
    positions: Dict[int, Tuple[float, float]] = {}
    for size, indices in size_groups.items():
        n = len(indices)
        for j, idx in enumerate(indices):
            x = (j - (n - 1) / 2) * 1.5
            y = size
            positions[idx] = (x, y)

    # Color by phantom number
    color_map = {0: '#e74c3c', 2: '#3498db', 3: '#2ecc71', 4: '#f39c12'}

    fig, ax = plt.subplots(1, 1, figsize=(14, 10))

    # Draw edges (refinement relations)
    for i in range(len(tops_sorted)):
        for j in range(i + 1, len(tops_sorted)):
            if set(tops_sorted[i]) < set(tops_sorted[j]):
                # Check if it's a cover (no intermediate topology)
                is_cover = True
                for k in range(len(tops_sorted)):
                    if k != i and k != j:
                        if set(tops_sorted[i]) < set(tops_sorted[k]) < set(tops_sorted[j]):
                            is_cover = False
                            break
                if is_cover:
                    xi, yi = positions[i]
                    xj, yj = positions[j]
                    ax.plot([xi, xj], [yi, yj], 'k-', alpha=0.2, linewidth=0.5)

    # Draw nodes
    for i, t in enumerate(tops_sorted):
        x, y = positions[i]
        spn = spn_map[t]
        color = color_map.get(spn, '#95a5a6')
        ax.scatter(x, y, s=200, c=color, zorder=5, edgecolors='black', linewidth=0.5)
        ax.annotate(f'{len(t)}', (x, y), ha='center', va='center',
                    fontsize=7, fontweight='bold', zorder=6)

    # Legend
    legend_elements = [
        mpatches.Patch(color='#e74c3c', label='spn = 0 (discrete/irreducible)'),
        mpatches.Patch(color='#3498db', label='spn = 2'),
        mpatches.Patch(color='#2ecc71', label='spn = 3'),
        mpatches.Patch(color='#f39c12', label='spn = 4+'),
    ]
    ax.legend(handles=legend_elements, loc='upper left', fontsize=9)

    ax.set_xlabel('Position (arbitrary)', fontsize=12)
    ax.set_ylabel('Number of Open Sets', fontsize=12)
    ax.set_title('Topology Lattice on {0, 1, 2}\nColored by Strict Phantom Number',
                 fontsize=14, fontweight='bold')

    plt.tight_layout()
    plt.savefig('phantom_lattice.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved phantom_lattice.png")


def plot_phantom_spectrum():
    """Visualize the phantom spectrum for a 2-observer decomposition."""
    fig, axes = plt.subplots(1, 3, figsize=(15, 5))

    # Simulate the Sorgenfrey decomposition on [0, 1]
    x = np.linspace(0, 1, 200)

    # Observer 1 (lower-limit): neighborhoods are [a, a+ε)
    # Observer 2 (upper-limit): neighborhoods are (a-ε, a]
    # Both see standard open sets, plus their respective half-opens

    # Visualize: for a "bump" function, show what each observer sees
    bump = np.exp(-((x - 0.5) ** 2) / 0.01)

    # Observer 1's view: sees right-continuous version
    bump1 = np.copy(bump)
    # Add a right-discontinuity effect
    mask1 = (x >= 0.3) & (x < 0.7)
    bump1[mask1] *= 1.2

    # Observer 2's view: sees left-continuous version
    bump2 = np.copy(bump)
    mask2 = (x > 0.3) & (x <= 0.7)
    bump2[mask2] *= 1.2

    # Consensus: what both agree on
    consensus_bump = bump

    axes[0].fill_between(x, 0, bump1, alpha=0.3, color='blue')
    axes[0].plot(x, bump1, 'b-', linewidth=2)
    axes[0].set_title('Observer 1\n(Lower-limit topology)', fontsize=12)
    axes[0].set_xlabel('x')
    axes[0].set_ylabel('Neighborhood strength')
    axes[0].set_ylim(0, 1.5)

    axes[1].fill_between(x, 0, bump2, alpha=0.3, color='red')
    axes[1].plot(x, bump2, 'r-', linewidth=2)
    axes[1].set_title('Observer 2\n(Upper-limit topology)', fontsize=12)
    axes[1].set_xlabel('x')
    axes[1].set_ylim(0, 1.5)

    axes[2].fill_between(x, 0, consensus_bump, alpha=0.3, color='green')
    axes[2].plot(x, consensus_bump, 'g-', linewidth=2)
    axes[2].set_title('Consensus\n(Standard topology)', fontsize=12)
    axes[2].set_xlabel('x')
    axes[2].set_ylim(0, 1.5)

    plt.suptitle('Phantom Decomposition: Two Observers Recover Reality',
                 fontsize=14, fontweight='bold', y=1.02)
    plt.tight_layout()
    plt.savefig('phantom_spectrum.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved phantom_spectrum.png")


def plot_spn_distribution():
    """Plot the distribution of phantom numbers on small sets."""
    fig, ax = plt.subplots(figsize=(10, 6))

    # Data for {0,1,2} (29 topologies)
    tops = enumerate_topologies_3()
    spn_counts: Dict[int, int] = {}
    for tau in tops:
        spn = compute_spn(tau, tops)
        spn_counts[spn] = spn_counts.get(spn, 0) + 1

    labels = [f'spn = {k}' for k in sorted(spn_counts.keys())]
    values = [spn_counts[k] for k in sorted(spn_counts.keys())]
    colors = ['#e74c3c', '#3498db', '#2ecc71', '#f39c12', '#9b59b6'][:len(labels)]

    bars = ax.bar(labels, values, color=colors, edgecolor='black', linewidth=0.5)

    # Add value labels
    for bar, val in zip(bars, values):
        ax.text(bar.get_x() + bar.get_width() / 2, bar.get_height() + 0.3,
                str(val), ha='center', va='bottom', fontweight='bold')

    ax.set_xlabel('Strict Phantom Number', fontsize=12)
    ax.set_ylabel('Number of Topologies', fontsize=12)
    ax.set_title('Distribution of Strict Phantom Numbers\non {0, 1, 2} (29 topologies)',
                 fontsize=14, fontweight='bold')

    plt.tight_layout()
    plt.savefig('spn_distribution.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved spn_distribution.png")


if __name__ == "__main__":
    plot_phantom_lattice()
    plot_phantom_spectrum()
    plot_spn_distribution()
    print("\nAll visualizations generated!")
