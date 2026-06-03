#!/usr/bin/env python3
"""
Phantom Chromatic Theory: Demonstrations

Demonstrates key results from the phantom chromatic theory:
1. The indiscrete topology's 2-observer decomposition
2. Observer disagreement set computation
3. Phantom spectrum analysis for small topologies
"""

from itertools import combinations, product
from typing import Set, FrozenSet, List, Tuple, Dict


def is_topology(opens: Set[FrozenSet], universe: FrozenSet) -> bool:
    """Check if a collection of sets forms a topology on a universe."""
    if frozenset() not in opens:
        return False
    if universe not in opens:
        return False
    # Closed under pairwise intersection
    for a, b in combinations(opens, 2):
        if a & b not in opens:
            return False
    # Closed under arbitrary union (for finite, pairwise suffices via induction,
    # but let's check all subsets)
    opens_list = list(opens)
    for r in range(1, len(opens_list) + 1):
        for combo in combinations(opens_list, r):
            union = frozenset().union(*combo)
            if union not in opens:
                return False
    return True


def generate_topologies(n: int) -> List[Set[FrozenSet]]:
    """Generate all topologies on {0, 1, ..., n-1}."""
    universe = frozenset(range(n))
    all_subsets = []
    for r in range(n + 1):
        for combo in combinations(range(n), r):
            all_subsets.append(frozenset(combo))

    topologies = []
    # Must include empty set and universe
    required = {frozenset(), universe}
    optional = [s for s in all_subsets if s not in required]

    for r in range(len(optional) + 1):
        for combo in combinations(optional, r):
            candidate = required | set(combo)
            if is_topology(candidate, universe):
                topologies.append(candidate)

    return topologies


def is_strictly_finer(tau1: Set[FrozenSet], tau2: Set[FrozenSet]) -> bool:
    """Check if tau1 is strictly finer than tau2 (more open sets)."""
    return tau1 > tau2  # strict superset


def consensus(topos: List[Set[FrozenSet]]) -> Set[FrozenSet]:
    """Compute consensus: intersection of open set families."""
    if not topos:
        return set()
    result = topos[0]
    for t in topos[1:]:
        result = result & t
    return result


def admits_k_decomp(tau: Set[FrozenSet], all_topos: List[Set[FrozenSet]], k: int) -> bool:
    """Check if tau admits a k-observer strict phantom decomposition."""
    finer = [t for t in all_topos if is_strictly_finer(t, tau)]
    for combo in combinations(finer, k):
        if consensus(list(combo)) == tau:
            return True
    return False


def phantom_chromatic_number(tau: Set[FrozenSet], all_topos: List[Set[FrozenSet]],
                              max_k: int = 10) -> int:
    """Compute the phantom chromatic number of a topology."""
    for k in range(2, max_k + 1):
        if admits_k_decomp(tau, all_topos, k):
            return k
    return -1  # irreducible (or exceeds max_k)


def demo_indiscrete_decomposition():
    """Demonstrate the 2-observer decomposition of the indiscrete topology."""
    print("=" * 60)
    print("Demo 1: Indiscrete Topology 2-Observer Decomposition")
    print("=" * 60)

    X = {0, 1, 2}
    universe = frozenset(X)
    empty = frozenset()

    # Indiscrete topology
    indiscrete = {empty, universe}

    # Observer 1: sees {0} as open
    obs1 = {empty, frozenset({0}), universe}
    # Observer 2: sees {1} as open
    obs2 = {empty, frozenset({1}), universe}

    print(f"Universe X = {set(universe)}")
    print(f"Indiscrete topology: {{{', '.join(str(set(s)) for s in sorted(indiscrete, key=len))}}}")
    print(f"Observer 1 opens:    {{{', '.join(str(set(s)) for s in sorted(obs1, key=len))}}}")
    print(f"Observer 2 opens:    {{{', '.join(str(set(s)) for s in sorted(obs2, key=len))}}}")

    cons = obs1 & obs2
    print(f"Consensus (∩):       {{{', '.join(str(set(s)) for s in sorted(cons, key=len))}}}")
    print(f"Consensus = Indiscrete? {cons == indiscrete}")
    print(f"Obs1 strictly finer? {is_strictly_finer(obs1, indiscrete)}")
    print(f"Obs2 strictly finer? {is_strictly_finer(obs2, indiscrete)}")
    print()


def demo_disagreement_sets():
    """Demonstrate observer disagreement sets."""
    print("=" * 60)
    print("Demo 2: Observer Disagreement Sets")
    print("=" * 60)

    universe = frozenset({0, 1, 2})
    empty = frozenset()

    # 3 observers on {0, 1, 2}
    obs1 = {empty, frozenset({0}), universe}
    obs2 = {empty, frozenset({1}), universe}
    obs3 = {empty, frozenset({2}), universe}

    consensus_opens = obs1 & obs2 & obs3

    print(f"Consensus: {{{', '.join(str(set(s)) for s in sorted(consensus_opens, key=len))}}}")

    for i, obs in enumerate([obs1, obs2, obs3], 1):
        disagreement = obs - consensus_opens
        print(f"Observer {i} disagreement: {{{', '.join(str(set(s)) for s in disagreement)}}}")

    # Check independence
    for i, j in [(1, 2), (1, 3), (2, 3)]:
        obs_i = [obs1, obs2, obs3][i-1]
        obs_j = [obs1, obs2, obs3][j-1]
        dis_i = obs_i - consensus_opens
        dis_j = obs_j - consensus_opens
        independent = len(dis_i & dis_j) == 0
        print(f"Observers {i},{j} independent? {independent} "
              f"(disjoint disagreement: {dis_i & dis_j == set()})")
    print()


def demo_phantom_spectrum():
    """Compute phantom spectra for topologies on small sets."""
    print("=" * 60)
    print("Demo 3: Phantom Spectra on Fin 3")
    print("=" * 60)

    n = 3
    topos = generate_topologies(n)
    universe = frozenset(range(n))
    empty = frozenset()
    discrete = {frozenset(s) for r in range(n+1) for s in combinations(range(n), r)}
    indiscrete = {empty, universe}

    print(f"Number of topologies on {{0,1,2}}: {len(topos)}")
    print()

    for tau in sorted(topos, key=len):
        name = "discrete" if tau == discrete else ("indiscrete" if tau == indiscrete else "")
        pcn = phantom_chromatic_number(tau, topos, max_k=5)

        spectrum = []
        for k in range(2, 6):
            if admits_k_decomp(tau, topos, k):
                spectrum.append(k)

        label = f" ({name})" if name else ""
        opens_str = "{" + ", ".join(str(set(s)) for s in sorted(tau, key=lambda s: (len(s), sorted(s)))) + "}"
        if pcn == -1:
            print(f"τ = {opens_str}{label}")
            print(f"  Phantom-irreducible (χ_ph = ∞)")
        else:
            print(f"τ = {opens_str}{label}")
            print(f"  χ_ph = {pcn}, spectrum ⊇ {spectrum}")
        print()


def demo_composition():
    """Demonstrate phantom refinement composition."""
    print("=" * 60)
    print("Demo 4: Phantom Refinement Composition")
    print("=" * 60)

    universe = frozenset({0, 1, 2, 3})
    empty = frozenset()

    # Level 1: indiscrete = consensus of two observers
    indiscrete = {empty, universe}
    obs1_L1 = {empty, frozenset({0, 1}), universe}
    obs2_L1 = {empty, frozenset({2, 3}), universe}

    print("Level 1 decomposition of indiscrete on {0,1,2,3}:")
    print(f"  Observer 1: sees {{{0,1}}} as open")
    print(f"  Observer 2: sees {{{2,3}}} as open")
    cons_L1 = obs1_L1 & obs2_L1
    print(f"  Consensus = {{{', '.join(str(set(s)) for s in sorted(cons_L1, key=len))}}}")
    print(f"  Matches indiscrete? {cons_L1 == indiscrete}")
    print()

    # Level 2: decompose each observer
    # obs1_L1 has opens {∅, {0,1}, X}. Decompose:
    obs1a = {empty, frozenset({0}), frozenset({0, 1}), universe}
    obs1b = {empty, frozenset({1}), frozenset({0, 1}), universe}
    print("Level 2: decompose Observer 1's topology")
    print(f"  Sub-observer 1a: sees {{0}} and {{{0,1}}} as open")
    print(f"  Sub-observer 1b: sees {{1}} and {{{0,1}}} as open")
    cons_sub1 = obs1a & obs1b
    print(f"  Their consensus: {{{', '.join(str(set(s)) for s in sorted(cons_sub1, key=len))}}}")
    print(f"  Matches Observer 1? {cons_sub1 == obs1_L1}")
    print()

    # Flatten: all 4 sub-observers
    all_obs = [obs1a, obs1b,
               {empty, frozenset({2}), frozenset({2, 3}), universe},
               {empty, frozenset({3}), frozenset({2, 3}), universe}]

    flat_consensus = all_obs[0]
    for o in all_obs[1:]:
        flat_consensus = flat_consensus & o

    print("Flattened 4-observer decomposition:")
    for i, obs in enumerate(all_obs):
        extras = obs - indiscrete
        print(f"  Sub-observer {i+1}: extra opens = "
              f"{{{', '.join(str(set(s)) for s in extras)}}}")
    print(f"  Flat consensus: {{{', '.join(str(set(s)) for s in sorted(flat_consensus, key=len))}}}")
    print(f"  Matches indiscrete? {flat_consensus == indiscrete}")


if __name__ == "__main__":
    demo_indiscrete_decomposition()
    demo_disagreement_sets()
    demo_phantom_spectrum()
    demo_composition()


#!/usr/bin/env python3
"""
Visualization: Phantom Topology Lattice and Decompositions

Creates a visualization of the lattice of topologies on a small set,
highlighting phantom decompositions and the phantom spectrum.
"""

import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np
from itertools import combinations
from typing import FrozenSet, Set, List, Tuple


def generate_topologies(n: int) -> List[Set[FrozenSet]]:
    """Generate all topologies on {0, ..., n-1}."""
    universe = frozenset(range(n))
    all_subsets = []
    for r in range(n + 1):
        for combo in combinations(range(n), r):
            all_subsets.append(frozenset(combo))

    topologies = []
    required = {frozenset(), universe}
    optional = [s for s in all_subsets if s not in required]

    for r in range(len(optional) + 1):
        for combo in combinations(optional, r):
            candidate = required | set(combo)
            if is_valid_topology(candidate, universe):
                topologies.append(candidate)

    return topologies


def is_valid_topology(opens: Set[FrozenSet], universe: FrozenSet) -> bool:
    if frozenset() not in opens or universe not in opens:
        return False
    for a, b in combinations(opens, 2):
        if a & b not in opens:
            return False
    opens_list = list(opens)
    for r in range(2, len(opens_list) + 1):
        for combo in combinations(opens_list, r):
            if frozenset().union(*combo) not in opens:
                return False
    return True


def phantom_chromatic_number(tau: Set[FrozenSet],
                              all_topos: List[Set[FrozenSet]]) -> int:
    finer = [t for t in all_topos if t > tau]
    for k in range(2, 6):
        for combo in combinations(finer, k):
            consensus = combo[0]
            for t in combo[1:]:
                consensus = consensus & t
            if consensus == tau:
                return k
    return -1


def main():
    n = 3
    topos = generate_topologies(n)
    universe = frozenset(range(n))
    discrete = {frozenset(s) for r in range(n+1)
                for s in combinations(range(n), r)}

    # Compute phantom chromatic numbers
    pcns = []
    sizes = []
    for tau in topos:
        pcn = phantom_chromatic_number(tau, topos)
        pcns.append(pcn)
        sizes.append(len(tau))

    # Sort by size for visualization
    data = sorted(zip(sizes, pcns, topos), key=lambda x: x[0])

    fig, axes = plt.subplots(1, 2, figsize=(14, 6))

    # Plot 1: Phantom chromatic number distribution
    ax1 = axes[0]
    irreducible = sum(1 for p in pcns if p == -1)
    decomposable_2 = sum(1 for p in pcns if p == 2)
    decomposable_other = sum(1 for p in pcns if p > 2)

    labels = ['Irreducible\n(χ_ph = ∞)', 'χ_ph = 2', 'χ_ph > 2']
    counts = [irreducible, decomposable_2, decomposable_other]
    colors = ['#e74c3c', '#2ecc71', '#3498db']

    bars = ax1.bar(labels, counts, color=colors, edgecolor='black', linewidth=1.2)
    for bar, count in zip(bars, counts):
        ax1.text(bar.get_x() + bar.get_width()/2., bar.get_height() + 0.3,
                str(count), ha='center', va='bottom', fontsize=14, fontweight='bold')

    ax1.set_title(f'Phantom Chromatic Numbers on Fin {n}\n({len(topos)} topologies)',
                  fontsize=14, fontweight='bold')
    ax1.set_ylabel('Count', fontsize=12)
    ax1.set_ylim(0, max(counts) + 3)

    # Plot 2: Phantom chromatic number vs topology size
    ax2 = axes[1]
    color_map = {-1: '#e74c3c', 2: '#2ecc71', 3: '#3498db', 4: '#9b59b6'}

    for size, pcn, tau in data:
        color = color_map.get(pcn, '#95a5a6')
        label_str = 'irred' if pcn == -1 else f'χ={pcn}'
        ax2.scatter(size, pcn if pcn > 0 else 0, color=color, s=100,
                   edgecolor='black', linewidth=0.5, zorder=5)

    ax2.set_xlabel('Number of Open Sets', fontsize=12)
    ax2.set_ylabel('Phantom Chromatic Number', fontsize=12)
    ax2.set_title('χ_ph vs Topology Size', fontsize=14, fontweight='bold')
    ax2.set_yticks([0, 2, 3, 4, 5])
    ax2.set_yticklabels(['irred', '2', '3', '4', '5'])

    legend_elements = [
        mpatches.Patch(facecolor='#e74c3c', edgecolor='black', label='Irreducible'),
        mpatches.Patch(facecolor='#2ecc71', edgecolor='black', label='χ_ph = 2'),
        mpatches.Patch(facecolor='#3498db', edgecolor='black', label='χ_ph = 3+'),
    ]
    ax2.legend(handles=legend_elements, loc='upper right')

    plt.tight_layout()
    plt.savefig('phantom_chromatic_analysis.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved phantom_chromatic_analysis.png")

    # Print summary
    print(f"\nPhantom Chromatic Analysis on Fin {n}:")
    print(f"  Total topologies: {len(topos)}")
    print(f"  Irreducible: {irreducible}")
    print(f"  χ_ph = 2: {decomposable_2}")
    print(f"  χ_ph > 2: {decomposable_other}")


if __name__ == "__main__":
    main()
