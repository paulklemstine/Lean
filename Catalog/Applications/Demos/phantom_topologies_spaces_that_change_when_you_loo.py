#!/usr/bin/env python3
"""
Phantom Topology: Numerical Demonstrations

Demonstrates the key results of the phantom topology framework on finite sets.
"""

from algorithms import (
    generate_topology, consensus_topology, is_phantom_decomposition,
    sierpinski_decomposition, is_strictly_finer, enumerate_topologies_on,
    phantom_number, find_phantom_decomposition
)
from typing import FrozenSet


def demo_sierpinski_decomposition():
    """Demonstrate the Sierpiński-style decomposition of the indiscrete topology."""
    print("=" * 60)
    print("DEMO 1: Sierpiński Decomposition of the Indiscrete Topology")
    print("=" * 60)
    
    X = frozenset({0, 1, 2})
    indiscrete = frozenset({frozenset(), X})
    
    print(f"\nX = {set(X)}")
    print(f"Indiscrete topology: {{{', '.join(str(set(s)) for s in sorted(indiscrete, key=len))}}}")
    
    # Create two observers: one sees {0}, the other sees {1}
    t1, t2 = sierpinski_decomposition(X, 0, 1)
    
    print(f"\nObserver 1 (sees {{0}}): {{{', '.join(str(set(s)) for s in sorted(t1, key=len))}}}")
    print(f"Observer 2 (sees {{1}}): {{{', '.join(str(set(s)) for s in sorted(t2, key=len))}}}")
    
    # Compute consensus
    cons = consensus_topology(X, [t1, t2])
    print(f"\nConsensus (intersection): {{{', '.join(str(set(s)) for s in sorted(cons, key=len))}}}")
    print(f"Equals indiscrete: {cons == indiscrete}")
    
    # Verify strict decomposition
    print(f"\nObserver 1 strictly finer than indiscrete: {is_strictly_finer(t1, indiscrete)}")
    print(f"Observer 2 strictly finer than indiscrete: {is_strictly_finer(t2, indiscrete)}")
    print(f"Valid strict decomposition: {is_phantom_decomposition(indiscrete, [t1, t2])}")


def demo_discrete_irreducibility():
    """Demonstrate that the discrete topology is phantom-irreducible."""
    print("\n" + "=" * 60)
    print("DEMO 2: Phantom Irreducibility of the Discrete Topology")
    print("=" * 60)
    
    X = frozenset({0, 1, 2})
    discrete = generate_topology(X, {frozenset({x}) for x in X})
    
    print(f"\nX = {set(X)}")
    print(f"Discrete topology has {len(discrete)} open sets (all {2**len(X)} subsets)")
    
    # Try to find any strictly finer topology
    # Since discrete has ALL subsets open, nothing can have more.
    all_subsets = frozenset(frozenset(s) for k in range(len(X) + 1) 
                           for s in __import__('itertools').combinations(X, k))
    
    print(f"Number of subsets of X: {len(all_subsets)}")
    print(f"Discrete has all subsets: {set(discrete) == set(all_subsets)}")
    print(f"No strictly finer topology exists → phantom-irreducible ✓")


def demo_phantom_numbers_on_3_element_set():
    """Compute phantom numbers for all topologies on a 3-element set."""
    print("\n" + "=" * 60)
    print("DEMO 3: Phantom Numbers on {0, 1, 2}")
    print("=" * 60)
    
    X = frozenset({0, 1, 2})
    
    # Enumerate topologies on {0, 1, 2}
    # There are 29 topologies on a 3-element set
    print(f"\nEnumerating topologies on {set(X)}...")
    all_topos = enumerate_topologies_on(3)
    print(f"Found {len(all_topos)} topologies")
    
    # Classify by phantom number
    irreducible = []
    decomposable = {2: [], 3: [], 4: []}
    
    for tau in all_topos:
        pn = phantom_number(X, tau, all_topos)
        if pn == 0:
            irreducible.append(tau)
        elif pn in decomposable:
            decomposable[pn].append(tau)
    
    print(f"\nPhantom-irreducible topologies: {len(irreducible)}")
    for tau in irreducible:
        print(f"  {len(tau)} open sets: {{{', '.join(str(set(s)) for s in sorted(tau, key=len))}}}")
    
    for k, topos in decomposable.items():
        if topos:
            print(f"\nPhantom number {k}: {len(topos)} topologies")
            for tau in topos[:3]:  # Show first 3
                print(f"  {len(tau)} open sets")


def demo_agreement_properties():
    """Demonstrate that phantom agreement satisfies topology axioms."""
    print("\n" + "=" * 60)
    print("DEMO 4: Agreement Closure Properties")
    print("=" * 60)
    
    X = frozenset({0, 1, 2, 3})
    
    # Create 3 observers with different topologies
    t1 = generate_topology(X, {frozenset({0, 1})})
    t2 = generate_topology(X, {frozenset({0, 2})})
    t3 = generate_topology(X, {frozenset({0, 3})})
    
    observers = [t1, t2, t3]
    
    print(f"\nX = {set(X)}")
    print(f"Observer 1 sees {{0,1}} as open")
    print(f"Observer 2 sees {{0,2}} as open")
    print(f"Observer 3 sees {{0,3}} as open")
    
    # Compute consensus
    cons = consensus_topology(X, observers)
    print(f"\nConsensus topology ({len(cons)} open sets):")
    for s in sorted(cons, key=lambda x: (len(x), sorted(x))):
        print(f"  {set(s)}")
    
    # Verify: empty and univ are in agreement
    print(f"\n∅ in consensus: {frozenset() in cons}")
    print(f"X in consensus: {X in cons}")
    
    # Check what each observer sees that others don't
    for i, obs in enumerate(observers):
        extra = set(obs) - set(cons)
        print(f"Observer {i+1} sees {len(extra)} extra open sets beyond consensus")


def demo_observer_stability():
    """Demonstrate that adding a finer observer doesn't change consensus."""
    print("\n" + "=" * 60)
    print("DEMO 5: Observer Stability")
    print("=" * 60)
    
    X = frozenset({0, 1, 2})
    
    # Two initial observers
    t1 = generate_topology(X, {frozenset({0})})
    t2 = generate_topology(X, {frozenset({1})})
    
    cons_initial = consensus_topology(X, [t1, t2])
    print(f"\nInitial consensus with 2 observers: {len(cons_initial)} open sets")
    
    # Add a finer observer (discrete topology, which is finer than everything)
    t_discrete = generate_topology(X, {frozenset({x}) for x in X})
    
    cons_with_finer = consensus_topology(X, [t1, t2, t_discrete])
    print(f"Consensus after adding discrete observer: {len(cons_with_finer)} open sets")
    print(f"Consensus unchanged: {cons_initial == cons_with_finer}")
    
    # Add a coarser observer (indiscrete, which makes consensus coarser)
    t_indiscrete = frozenset({frozenset(), X})
    
    cons_with_coarser = consensus_topology(X, [t1, t2, t_indiscrete])
    print(f"Consensus after adding indiscrete observer: {len(cons_with_coarser)} open sets")
    print(f"Consensus changed: {cons_initial != cons_with_coarser}")
    print(f"New consensus is coarser (fewer opens): {len(cons_with_coarser) < len(cons_initial)}")


if __name__ == "__main__":
    demo_sierpinski_decomposition()
    demo_discrete_irreducibility()
    demo_agreement_properties()
    demo_observer_stability()
    
    # The full enumeration is slow, only run if desired
    print("\n" + "=" * 60)
    print("DEMO 3: Phantom Numbers (computing...)")
    print("=" * 60)
    try:
        demo_phantom_numbers_on_3_element_set()
    except Exception as e:
        print(f"  (Enumeration too slow or error: {e})")
    
    print("\n" + "=" * 60)
    print("All demos complete.")
    print("=" * 60)


#!/usr/bin/env python3
"""
Visualization: Phantom Topology Decompositions

Generates a visualization of the topology lattice on a 3-element set,
colored by phantom number.
"""

import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np
from algorithms import (
    generate_topology, enumerate_topologies_on,
    phantom_number, consensus_topology
)


def topology_to_label(tau, X):
    """Create a compact label for a topology."""
    opens = sorted(tau, key=lambda s: (len(s), sorted(s)))
    # Skip empty and full
    interesting = [s for s in opens if s != frozenset() and s != X]
    if not interesting:
        return "indiscrete"
    if len(tau) == 2**len(X):
        return "discrete"
    parts = []
    for s in interesting:
        parts.append("{" + ",".join(str(x) for x in sorted(s)) + "}")
    return " ".join(parts)


def main():
    X = frozenset({0, 1, 2})
    all_topos = enumerate_topologies_on(3)
    
    # Compute phantom numbers
    pn_data = []
    for tau in all_topos:
        pn = phantom_number(X, tau, all_topos)
        pn_data.append({
            'topology': tau,
            'num_opens': len(tau),
            'phantom_number': pn,
            'label': topology_to_label(tau, X)
        })
    
    # Sort by number of open sets (inverse of lattice position)
    pn_data.sort(key=lambda d: d['num_opens'])
    
    # Group by num_opens for y-coordinate
    groups = {}
    for d in pn_data:
        n = d['num_opens']
        if n not in groups:
            groups[n] = []
        groups[n].append(d)
    
    # Color by phantom number
    colors = {0: '#e74c3c', 2: '#3498db', 3: '#2ecc71', 4: '#f39c12'}
    color_labels = {0: 'Irreducible (PN=0)', 2: 'PN=2', 3: 'PN=3', 4: 'PN≥4'}
    
    fig, ax = plt.subplots(1, 1, figsize=(14, 8))
    
    for num_opens, group in groups.items():
        y = num_opens
        n = len(group)
        for i, d in enumerate(group):
            x = (i - (n - 1) / 2) * 1.5
            color = colors.get(d['phantom_number'], '#95a5a6')
            circle = plt.Circle((x, y), 0.4, color=color, alpha=0.8, ec='black', lw=1)
            ax.add_patch(circle)
            ax.text(x, y, str(d['phantom_number']), ha='center', va='center',
                    fontsize=10, fontweight='bold', color='white')
    
    # Labels
    ax.set_xlabel('Topology Index (within level)', fontsize=12)
    ax.set_ylabel('Number of Open Sets', fontsize=12)
    ax.set_title('Phantom Numbers of Topologies on {0, 1, 2}\n'
                 'Each circle = one topology, number = phantom number',
                 fontsize=14, fontweight='bold')
    
    # Legend
    legend_patches = [mpatches.Patch(color=colors[k], label=v) 
                      for k, v in color_labels.items() if k in {d['phantom_number'] for d in pn_data}]
    ax.legend(handles=legend_patches, loc='upper left', fontsize=11)
    
    # Axis limits
    ax.set_xlim(-8, 8)
    ax.set_ylim(1, 9)
    ax.set_yticks(range(2, 9))
    ax.set_aspect('equal')
    ax.grid(True, alpha=0.3)
    
    plt.tight_layout()
    plt.savefig('phantom_numbers.png', dpi=150, bbox_inches='tight')
    print("Saved phantom_numbers.png")
    
    # Print summary
    print(f"\nTotal topologies on {{0,1,2}}: {len(all_topos)}")
    pn_counts = {}
    for d in pn_data:
        pn_counts[d['phantom_number']] = pn_counts.get(d['phantom_number'], 0) + 1
    for pn in sorted(pn_counts):
        print(f"  Phantom number {pn}: {pn_counts[pn]} topologies")


if __name__ == "__main__":
    main()
