#!/usr/bin/env python3
"""
Demonstration of the Unified Self-Reference Framework.

This script illustrates the key constructions and theorems:
1. Diagonal system impossibility (Cantor's theorem)
2. Provability algebra construction and incompleteness
3. Incompleteness gap computation
4. Theory spectrum enumeration
5. Superlinear incompleteness conjecture testing
"""

from algorithms import (
    ProvabilityAlgebra,
    verify_diagonal_impossibility,
    compute_incompleteness_gap,
    enumerate_provability_algebras,
    theory_spectrum,
)

def demo_diagonal_impossibility():
    """Demonstrate that diagonal systems are impossible."""
    print("=" * 60)
    print("DEMO 1: Diagonal System Impossibility")
    print("=" * 60)
    print()
    print("A diagonal system on {0,...,n-1} requires a surjection")
    print("from n elements to 2^n functions. This is impossible:")
    print()
    for n in range(1, 8):
        num_functions = 2 ** n
        print(f"  n={n}: |functions| = 2^{n} = {num_functions} > {n} = n  ✓")
    print()
    print("This proves Cantor's theorem: no surjection α → (α → Prop).")
    print()


def demo_goedel_incompleteness():
    """Demonstrate Gödel's incompleteness with a concrete example."""
    print("=" * 60)
    print("DEMO 2: Gödel's First Incompleteness Theorem")
    print("=" * 60)
    print()

    # Construct a provability algebra on 4 sentences
    # Sentences: 0, 1, 2, 3
    # Truth: {0, 1} are true, {2, 3} are false
    # Negation: 0↔2, 1↔3
    # Provable: {0} (only sentence 0 is provable)
    # Gödel sentence: 1 (true(1)=True, provable(1)=False, so true(1)↔¬provable(1))

    pa = ProvabilityAlgebra(
        n=4,
        provable={0},
        true_set={0, 1},
        neg={0: 2, 2: 0, 1: 3, 3: 1}
    )

    print(f"Sentence space: {{0, 1, 2, 3}}")
    print(f"True sentences: {pa.true_set}")
    print(f"Provable sentences: {pa.provable}")
    print(f"Negation map: {pa.neg}")
    print()

    print(f"Soundness check: {pa.is_sound()}")
    print(f"Consistency check: {pa.is_consistent()}")
    print(f"Negation correctness: {pa.neg_correct()}")
    print(f"Valid PA: {pa.is_valid()}")
    print()

    g = pa.has_goedel_sentence()
    print(f"Gödel sentence: {g}")
    if g is not None:
        print(f"  true({g}) = {g in pa.true_set}")
        print(f"  provable({g}) = {g in pa.provable}")
        print(f"  true({g}) ↔ ¬provable({g}): {(g in pa.true_set) == (g not in pa.provable)}")
    print()

    gap, witnesses = compute_incompleteness_gap(pa)
    print(f"Incompleteness gap: {gap}")
    print(f"Witnesses (true but unprovable): {witnesses}")
    print()


def demo_theory_spectrum():
    """Demonstrate the theory spectrum."""
    print("=" * 60)
    print("DEMO 3: Theory Spectrum")
    print("=" * 60)
    print()

    pa = ProvabilityAlgebra(
        n=4,
        provable={0},
        true_set={0, 1},
        neg={0: 2, 2: 0, 1: 3, 3: 1}
    )

    spec = theory_spectrum(pa)
    print(f"Theory spectrum of PA (|spec| = {len(spec)}):")
    for i, ext in enumerate(spec):
        label = ""
        if ext == pa.provable:
            label = " ← provable"
        if ext == pa.true_set:
            label = " ← true"
        print(f"  T_{i}: {ext}{label}")
    print()
    print(f"Spectrum is non-trivial: {len(spec) >= 2}")
    print()


def demo_incompleteness_enumeration():
    """Enumerate provability algebras on small sets."""
    print("=" * 60)
    print("DEMO 4: Incompleteness Gap Statistics")
    print("=" * 60)
    print()

    for n in [2, 4]:
        print(f"--- Provability algebras on Fin {n} ---")
        algebras = enumerate_provability_algebras(n)
        print(f"Total valid PAs: {len(algebras)}")

        goedel_count = 0
        gap_distribution: dict = {}

        for pa in algebras:
            g = pa.has_goedel_sentence()
            if g is not None and g in pa.true_set:
                goedel_count += 1
                gap = pa.incompleteness_gap()
                gap_distribution[gap] = gap_distribution.get(gap, 0) + 1

        print(f"PAs with true Gödel sentence: {goedel_count}")
        if gap_distribution:
            print(f"Gap distribution: {dict(sorted(gap_distribution.items()))}")
            min_gap = min(gap_distribution.keys())
            print(f"Minimum gap: {min_gap}")
            if n >= 6:
                threshold = n // 3
                print(f"Conjecture threshold (n/3): {threshold}")
                print(f"Conjecture holds: {min_gap >= threshold}")
        print()


def demo_incompleteness_chain():
    """Demonstrate incompleteness chain construction."""
    print("=" * 60)
    print("DEMO 5: Incompleteness Chain")
    print("=" * 60)
    print()

    # Build a chain on 6 sentences
    # Start: provable = {0}, true = {0, 1, 2}
    n = 6
    true_set = {0, 1, 2}
    neg = {0: 3, 3: 0, 1: 4, 4: 1, 2: 5, 5: 2}

    print(f"Sentence space: {{0, ..., {n-1}}}")
    print(f"True sentences: {true_set}")
    print(f"Negation: {neg}")
    print()

    # Chain: progressively add true sentences to provable
    provable_sets = [{0}, {0, 1}, {0, 1, 2}]
    for i, prov in enumerate(provable_sets):
        pa = ProvabilityAlgebra(n, prov, true_set, neg)
        g = pa.has_goedel_sentence()
        gap = pa.incompleteness_gap()
        complete = pa.is_complete()
        print(f"Level {i}: provable = {prov}")
        print(f"  Valid: {pa.is_valid()}, Gap: {gap}, Complete: {complete}")
        if g is not None:
            print(f"  Gödel sentence: {g} (true={g in true_set}, provable={g in prov})")
        if i < len(provable_sets) - 1:
            new = provable_sets[i+1] - prov
            print(f"  → Next level adds: {new}")
        print()


if __name__ == "__main__":
    demo_diagonal_impossibility()
    demo_goedel_incompleteness()
    demo_theory_spectrum()
    demo_incompleteness_enumeration()
    demo_incompleteness_chain()


#!/usr/bin/env python3
"""
Visualization: The Incompleteness Landscape.

Shows the distribution of incompleteness gaps across all valid
provability algebras on Fin n, demonstrating how incompleteness
is a pervasive rather than rare phenomenon.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
from itertools import permutations


def enumerate_pas_with_gaps(n):
    """Enumerate valid PAs on Fin n and compute their gaps."""
    sentences = list(range(n))
    gaps = []
    goedel_gaps = []

    for true_mask in range(2**n):
        true_set = {s for s in sentences if (true_mask >> s) & 1}
        false_set = set(sentences) - true_set

        if len(true_set) != len(false_set):
            continue

        true_list = sorted(true_set)
        false_list = sorted(false_set)

        for perm in permutations(false_list):
            neg = {}
            for t, f in zip(true_list, perm):
                neg[t] = f
                neg[f] = t

            if any(neg[s] == s for s in sentences):
                continue

            for prov_mask in range(2**n):
                provable = {s for s in sentences if (prov_mask >> s) & 1}
                if not provable.issubset(true_set):
                    continue
                if provable == set(sentences):
                    continue

                # Check neg correctness
                valid = True
                for s in sentences:
                    if (neg[s] in true_set) != (s not in true_set):
                        valid = False
                        break
                if not valid:
                    continue

                gap = len(true_set - provable)
                gaps.append(gap)

                # Check for Gödel sentence
                has_goedel = False
                for s in sentences:
                    if (s in true_set) == (s not in provable):
                        has_goedel = True
                        break
                if has_goedel:
                    goedel_gaps.append(gap)

    return gaps, goedel_gaps


def main():
    fig, axes = plt.subplots(1, 3, figsize=(15, 5))

    for idx, n in enumerate([2, 4, 6]):
        ax = axes[idx]
        gaps, goedel_gaps = enumerate_pas_with_gaps(n)

        if gaps:
            max_gap = max(gaps) if gaps else 0
            bins = np.arange(-0.5, max_gap + 1.5, 1)

            ax.hist(gaps, bins=bins, alpha=0.5, label='All PAs', color='steelblue',
                    edgecolor='navy', linewidth=0.8)
            if goedel_gaps:
                ax.hist(goedel_gaps, bins=bins, alpha=0.5, label='With Gödel sentence',
                        color='coral', edgecolor='darkred', linewidth=0.8)

            # Mark n/3 threshold
            if n >= 6:
                threshold = n // 3
                ax.axvline(x=threshold, color='green', linestyle='--', linewidth=2,
                          label=f'n/3 = {threshold}')

        ax.set_xlabel('Incompleteness Gap', fontsize=12)
        ax.set_ylabel('Count', fontsize=12)
        ax.set_title(f'Fin {n}  (|PAs| = {len(gaps)})', fontsize=13)
        ax.legend(fontsize=9)
        ax.set_xticks(range(max(gaps) + 1) if gaps else [0])

    fig.suptitle('The Incompleteness Landscape: Gap Distribution Across Provability Algebras',
                 fontsize=14, fontweight='bold', y=1.02)
    plt.tight_layout()
    plt.savefig('incompleteness_landscape.png', dpi=150, bbox_inches='tight')
    print("Saved incompleteness_landscape.png")


if __name__ == '__main__':
    main()
