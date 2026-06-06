#!/usr/bin/env python3
"""
Demo: The Topology of Argumentation
====================================

Demonstrates the key theorems about argumentation frameworks and their
topological structure (the argumentation complex).
"""

from algorithms import ArgFramework, verify_semantic_hierarchy, verify_symmetric_bridge


def demo_basic_framework():
    """Demo 1: A simple 3-argument framework with a cycle."""
    print("=" * 60)
    print("Demo 1: Three-Argument Cycle (a → b → c → a)")
    print("=" * 60)

    af = ArgFramework(
        {"a", "b", "c"},
        {("a", "b"), ("b", "c"), ("c", "a")}
    )

    cf_sets = af.all_conflict_free_sets()
    print(f"\nConflict-free sets (faces of K(AF)):")
    for s in sorted(cf_sets, key=lambda x: (len(x), sorted(x))):
        print(f"  {set(s) if s else '{}'}")

    print(f"\nf-vector: {af.f_vector()}")
    print(f"Euler characteristic: χ = {af.euler_characteristic()}")

    preferred = af.preferred_extensions()
    print(f"\nPreferred extensions:")
    for p in preferred:
        print(f"  {set(p)}")

    grounded = af.grounded_extension()
    print(f"Grounded extension: {set(grounded)}")

    hierarchy = verify_semantic_hierarchy(af)
    print(f"\nSemantic hierarchy check: {hierarchy}")


def demo_symmetric_framework():
    """Demo 2: A symmetric (undirected) attack graph."""
    print("\n" + "=" * 60)
    print("Demo 2: Symmetric Framework (undirected graph)")
    print("  a -- b -- c (mutual attacks)")
    print("=" * 60)

    af = ArgFramework(
        {"a", "b", "c"},
        {("a", "b"), ("b", "a"), ("b", "c"), ("c", "b")}
    )

    bridge = verify_symmetric_bridge(af)
    print(f"\nSymmetric bridge verification: {bridge}")

    cf_sets = af.all_conflict_free_sets()
    print(f"\nConflict-free sets:")
    for s in sorted(cf_sets, key=lambda x: (len(x), sorted(x))):
        adm = af.is_admissible(s)
        label = str(set(s)) if s else '{}'
        print(f"  {label:20s} admissible={adm}")

    preferred = af.preferred_extensions()
    print(f"\nPreferred extensions (= maximal independent sets):")
    for p in sorted(preferred, key=lambda x: sorted(x)):
        print(f"  {set(p)}")


def demo_stable_implies_preferred():
    """Demo 3: Verify stable ⊂ preferred hierarchy."""
    print("\n" + "=" * 60)
    print("Demo 3: Stable → Preferred Hierarchy")
    print("  Framework: a → b, c → b (two arguments attack b)")
    print("=" * 60)

    af = ArgFramework(
        {"a", "b", "c"},
        {("a", "b"), ("c", "b")}
    )

    stable = af.stable_extensions()
    preferred = af.preferred_extensions()
    print(f"\nStable extensions: {[set(s) for s in stable]}")
    print(f"Preferred extensions: {[set(s) for s in preferred]}")

    hierarchy = verify_semantic_hierarchy(af)
    print(f"Stable ⊂ Preferred: {hierarchy}")


def demo_argumentation_complex():
    """Demo 4: Full complex analysis of a debate-like framework."""
    print("\n" + "=" * 60)
    print("Demo 4: Argumentation Complex of a Debate")
    print("  a1 → a2, a2 → a3, a3 → a1, a4 → a2, a5 (unattacked)")
    print("=" * 60)

    af = ArgFramework(
        {"a1", "a2", "a3", "a4", "a5"},
        {("a1", "a2"), ("a2", "a3"), ("a3", "a1"), ("a4", "a2")}
    )

    fvec = af.f_vector()
    chi = af.euler_characteristic()
    print(f"\nf-vector: {fvec}")
    print(f"  f₀ = {fvec[0]} (vertices/non-self-attacking args)")
    if len(fvec) > 1:
        print(f"  f₁ = {fvec[1]} (edges/compatible pairs)")
    if len(fvec) > 2:
        print(f"  f₂ = {fvec[2]} (triangles/compatible triples)")
    print(f"Euler characteristic: χ = {chi}")

    preferred = af.preferred_extensions()
    grounded = af.grounded_extension()
    print(f"\nPreferred extensions: {[set(s) for s in preferred]}")
    print(f"Grounded extension: {set(grounded)}")
    print(f"|preferred| = {len(preferred)}, |grounded| = {len(grounded)}")


def demo_no_attacks():
    """Demo 5: Framework with no attacks — full simplex."""
    print("\n" + "=" * 60)
    print("Demo 5: Attack-Free Framework (full simplex)")
    print("  {a, b, c} with no attacks")
    print("=" * 60)

    af = ArgFramework(
        {"a", "b", "c"},
        set()
    )

    cf_sets = af.all_conflict_free_sets()
    print(f"\nAll subsets are conflict-free: {len(cf_sets)} sets")
    print(f"  (2^3 = {2**3}, matches: {len(cf_sets) == 2**3})")

    preferred = af.preferred_extensions()
    print(f"Unique preferred extension: {set(preferred[0])}")
    print(f"  (= entire argument set, as theorem predicts)")

    fvec = af.f_vector()
    print(f"f-vector: {fvec}")
    print(f"Euler characteristic: χ = {af.euler_characteristic()}")


def demo_euler_characteristic_survey():
    """Demo 6: Survey of Euler characteristics across framework families."""
    print("\n" + "=" * 60)
    print("Demo 6: Euler Characteristic Survey")
    print("=" * 60)

    # Linear chains: a1 → a2 → ... → an
    print("\nLinear chains (a1 → a2 → ... → an):")
    for n in range(2, 7):
        args = {f"a{i}" for i in range(1, n + 1)}
        attacks = {(f"a{i}", f"a{i+1}") for i in range(1, n)}
        af = ArgFramework(args, attacks)
        chi = af.euler_characteristic()
        pref = af.preferred_extensions()
        print(f"  n={n}: χ={chi}, |preferred|={len(pref)}, "
              f"preferred={[sorted(set(p)) for p in pref]}")

    # Cycles: a1 → a2 → ... → an → a1
    print("\nCycles (a1 → a2 → ... → an → a1):")
    for n in range(3, 8):
        args = {f"a{i}" for i in range(1, n + 1)}
        attacks = {(f"a{i}", f"a{i%n + 1}") for i in range(1, n + 1)}
        af = ArgFramework(args, attacks)
        chi = af.euler_characteristic()
        pref = af.preferred_extensions()
        print(f"  n={n}: χ={chi}, |preferred|={len(pref)}")


if __name__ == "__main__":
    demo_basic_framework()
    demo_symmetric_framework()
    demo_stable_implies_preferred()
    demo_argumentation_complex()
    demo_no_attacks()
    demo_euler_characteristic_survey()


#!/usr/bin/env python3
"""
Visualization: Argumentation Complex Structure
Plots the f-vector, Euler characteristic, and semantic hierarchy
for families of argumentation frameworks.
"""

import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np
from itertools import combinations
from typing import Set, FrozenSet, List, Dict, Tuple


class ArgFramework:
    def __init__(self, arguments, attacks):
        self.arguments = set(arguments)
        self.attacks = set(attacks)

    def is_conflict_free(self, s):
        for a in s:
            for b in s:
                if (a, b) in self.attacks:
                    return False
        return True

    def attackers_of(self, arg):
        return {a for a, t in self.attacks if t == arg}

    def is_acceptable(self, arg, s):
        for attacker in self.attackers_of(arg):
            if not any((c, attacker) in self.attacks for c in s):
                return False
        return True

    def is_admissible(self, s):
        if not self.is_conflict_free(s):
            return False
        return all(self.is_acceptable(a, s) for a in s)

    def all_conflict_free_sets(self):
        result = [frozenset()]
        args = list(self.arguments)
        for r in range(1, len(args) + 1):
            for combo in combinations(args, r):
                s = frozenset(combo)
                if self.is_conflict_free(s):
                    result.append(s)
        return result

    def preferred_extensions(self):
        admissible = [s for s in self.all_conflict_free_sets() if self.is_admissible(s)]
        return [s for s in admissible if not any(s < t for t in admissible)]

    def f_vector(self):
        cf = self.all_conflict_free_sets()
        mx = max((len(s) for s in cf), default=0)
        fv = [0] * mx
        for s in cf:
            if len(s) > 0:
                fv[len(s) - 1] += 1
        return fv

    def euler_characteristic(self):
        return sum((-1)**k * f for k, f in enumerate(self.f_vector()))


def make_cycle(n):
    args = set(range(n))
    attacks = {(i, (i + 1) % n) for i in range(n)}
    return ArgFramework(args, attacks)


def make_chain(n):
    args = set(range(n))
    attacks = {(i, i + 1) for i in range(n - 1)}
    return ArgFramework(args, attacks)


def plot_euler_characteristic():
    fig, axes = plt.subplots(1, 2, figsize=(14, 5))

    # Cycles
    ns = list(range(3, 12))
    chis = [make_cycle(n).euler_characteristic() for n in ns]
    prefs = [len(make_cycle(n).preferred_extensions()) for n in ns]

    ax = axes[0]
    ax.bar(np.array(ns) - 0.2, chis, 0.4, label='χ(K(AF))', color='steelblue', alpha=0.8)
    ax.bar(np.array(ns) + 0.2, prefs, 0.4, label='|Preferred|', color='coral', alpha=0.8)
    ax.set_xlabel('Cycle length n', fontsize=12)
    ax.set_ylabel('Value', fontsize=12)
    ax.set_title('Cycles: a₁→a₂→...→aₙ→a₁', fontsize=13)
    ax.legend(fontsize=10)
    ax.axhline(y=0, color='gray', linestyle='--', alpha=0.5)
    ax.set_xticks(ns)

    # Chains
    ns2 = list(range(2, 10))
    chis2 = [make_chain(n).euler_characteristic() for n in ns2]
    prefs2 = [len(make_chain(n).preferred_extensions()) for n in ns2]

    ax = axes[1]
    ax.bar(np.array(ns2) - 0.2, chis2, 0.4, label='χ(K(AF))', color='steelblue', alpha=0.8)
    ax.bar(np.array(ns2) + 0.2, prefs2, 0.4, label='|Preferred|', color='coral', alpha=0.8)
    ax.set_xlabel('Chain length n', fontsize=12)
    ax.set_ylabel('Value', fontsize=12)
    ax.set_title('Chains: a₁→a₂→...→aₙ', fontsize=13)
    ax.legend(fontsize=10)
    ax.axhline(y=0, color='gray', linestyle='--', alpha=0.5)
    ax.set_xticks(ns2)

    plt.suptitle('Euler Characteristic of the Argumentation Complex', fontsize=15, fontweight='bold')
    plt.tight_layout()
    plt.savefig('euler_characteristic.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved euler_characteristic.png")


def plot_f_vectors():
    fig, axes = plt.subplots(2, 3, figsize=(15, 9))

    frameworks = [
        ("3-Cycle", make_cycle(3)),
        ("4-Cycle", make_cycle(4)),
        ("5-Cycle", make_cycle(5)),
        ("Chain-4", make_chain(4)),
        ("Chain-6", make_chain(6)),
        ("No attacks (4)", ArgFramework(set(range(4)), set())),
    ]

    for ax, (name, af) in zip(axes.flat, frameworks):
        fv = af.f_vector()
        dims = list(range(len(fv)))
        colors = ['#2ecc71', '#3498db', '#9b59b6', '#e74c3c', '#f39c12']
        ax.bar(dims, fv, color=[colors[i % len(colors)] for i in dims], alpha=0.85)
        ax.set_xlabel('Dimension k')
        ax.set_ylabel('f_k (# of k-faces)')
        chi = af.euler_characteristic()
        pref = len(af.preferred_extensions())
        ax.set_title(f'{name}\nχ={chi}, |Pref|={pref}', fontsize=11)
        ax.set_xticks(dims)

    plt.suptitle('f-Vectors of Argumentation Complexes', fontsize=15, fontweight='bold')
    plt.tight_layout()
    plt.savefig('f_vectors.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved f_vectors.png")


def plot_semantic_hierarchy():
    fig, ax = plt.subplots(figsize=(10, 6))

    ns = list(range(3, 10))
    stable_counts = []
    preferred_counts = []
    cf_counts = []

    for n in ns:
        af = make_cycle(n)
        cf = len([s for s in af.all_conflict_free_sets() if len(s) > 0])
        pref = len(af.preferred_extensions())
        # Count stable extensions
        stable = 0
        for s in af.all_conflict_free_sets():
            if len(s) > 0:
                is_stable = all(
                    any((b, a) in af.attacks for b in s)
                    for a in af.arguments - s
                )
                if is_stable and af.is_conflict_free(s):
                    stable += 1
        stable_counts.append(stable)
        preferred_counts.append(pref)
        cf_counts.append(cf)

    x = np.array(ns)
    ax.plot(x, cf_counts, 'o-', color='#2ecc71', linewidth=2, markersize=8, label='Conflict-free (non-empty)')
    ax.plot(x, preferred_counts, 's-', color='#3498db', linewidth=2, markersize=8, label='Preferred')
    ax.plot(x, stable_counts, '^-', color='#e74c3c', linewidth=2, markersize=8, label='Stable')

    ax.set_xlabel('Cycle length n', fontsize=12)
    ax.set_ylabel('Count', fontsize=12)
    ax.set_title('Semantic Hierarchy for n-Cycles\nStable ⊆ Preferred ⊆ Conflict-Free', fontsize=14)
    ax.legend(fontsize=11)
    ax.set_xticks(ns)
    ax.grid(alpha=0.3)

    plt.tight_layout()
    plt.savefig('semantic_hierarchy.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved semantic_hierarchy.png")


if __name__ == "__main__":
    plot_euler_characteristic()
    plot_f_vectors()
    plot_semantic_hierarchy()
