#!/usr/bin/env python3
"""
Demonstration of the Isomorphisms of Meaning framework.

Numerical examples illustrating the core theorems:
1. Semantic Gap Theorem
2. Entropy-Rigidity Duality
3. Group Analogy Completion and Density
4. 2-Isomorphism Classes
"""

from algorithms import (
    SemanticStructure, identity_label, const_label,
    GroupAnalogy, entropy_rigidity_analysis,
    count_semantic_classes, orbit_size, count_2_iso_classes
)
from math import factorial


def demo_semantic_gap():
    """Demonstrate the Semantic Gap Theorem."""
    print("=" * 60)
    print("DEMO 1: The Semantic Gap Theorem")
    print("=" * 60)

    hom = SemanticStructure([True, True])  # homogeneous
    het = SemanticStructure([True, False])  # heterogeneous

    print(f"\nHomogeneous labeling: {hom.labels}")
    print(f"Heterogeneous labeling: {het.labels}")
    print(f"Structurally isomorphic (same size): {hom.n == het.n}")
    print(f"Semantically equivalent: {hom.is_semantically_equivalent(het)}")
    print(f"\nHomogeneous automorphisms: {hom.semantic_automorphisms()}")
    print(f"Heterogeneous automorphisms: {het.semantic_automorphisms()}")
    print(f"\n→ Same structure, different symmetry groups!")
    print(f"  Homogeneous: {len(hom.semantic_automorphisms())} automorphisms")
    print(f"  Heterogeneous: {len(het.semantic_automorphisms())} automorphism(s)")


def demo_entropy_rigidity():
    """Demonstrate the Entropy-Rigidity Duality."""
    print("\n" + "=" * 60)
    print("DEMO 2: Entropy-Rigidity Duality")
    print("=" * 60)

    for n in [3, 4, 5]:
        id_struct = identity_label(n)
        const_struct = const_label(n, 0)

        print(f"\nn = {n}:")
        print(f"  Identity labeling: entropy = {id_struct.semantic_entropy()}, "
              f"automorphisms = {len(id_struct.semantic_automorphisms())}")
        print(f"  Constant labeling: entropy = {const_struct.semantic_entropy()}, "
              f"automorphisms = {len(const_struct.semantic_automorphisms())} (= {n}!)")

    print("\n→ Maximum entropy ⟹ trivial automorphism group")
    print("→ Minimum entropy ⟹ full symmetric group")

    print("\nDetailed analysis for n=4 with 3 labels:")
    analysis = entropy_rigidity_analysis(4, 3)
    for ent, stats in sorted(analysis.items()):
        print(f"  Entropy {ent}: {stats['count']} labelings, "
              f"aut group sizes in [{stats['min_aut']}, {stats['max_aut']}], "
              f"avg = {stats['avg_aut']:.1f}")


def demo_analogy_completion():
    """Demonstrate the Analogy Completion Theorem."""
    print("\n" + "=" * 60)
    print("DEMO 3: Group Analogy Completion")
    print("=" * 60)

    n = 7  # Work in Z/7Z
    print(f"\nWorking in Z/{n}Z:")

    examples = [(1, 3, 2), (0, 4, 5), (3, 6, 1)]
    for a, b, c in examples:
        d = GroupAnalogy.complete(a, b, c, n)
        print(f"  {a}:{b} :: {c}:? → d = {d}")
        print(f"    Verification: ({b}-{a}) mod {n} = {(b-a)%n}, "
              f"({d}-{c}) mod {n} = {(d-c)%n} ✓")

    print(f"\nAnalogy Density Theorem verification:")
    for n in [2, 3, 4, 5, 6]:
        count = GroupAnalogy.count_valid_quadruples(n)
        expected = n ** 3
        print(f"  Z/{n}Z: valid quadruples = {count}, n³ = {expected}, "
              f"match = {count == expected} ✓")


def demo_2_isomorphisms():
    """Demonstrate 2-Isomorphism equivalence classes."""
    print("\n" + "=" * 60)
    print("DEMO 4: 2-Isomorphism Classes")
    print("=" * 60)

    for n in [1, 2, 3, 4]:
        classes = count_2_iso_classes(n)
        total = factorial(n)
        print(f"  n = {n}: {classes} 2-iso classes out of {total} bijections")

    print("\n→ The 2-iso classes correspond to conjugacy classes in Sₙ")
    print("  (since s = t for self-bijections, reducing to conjugation)")


def demo_semantic_classes():
    """Demonstrate counting semantic equivalence classes."""
    print("\n" + "=" * 60)
    print("DEMO 5: Semantic Equivalence Classes")
    print("=" * 60)

    print("\nNumber of semantic equivalence classes for Fin n with k labels:")
    header = 'n\\k'
    print(f"{header:<6}", end="")
    for k in range(1, 7):
        print(f"{k:<8}", end="")
    print()
    for n in range(1, 8):
        print(f"{n:<6}", end="")
        for k in range(1, 7):
            print(f"{count_semantic_classes(n, k):<8}", end="")
        print()

    print("\nOrbit sizes for n=4 with 2 labels:")
    for partition in [(4, 0), (3, 1), (2, 2), (1, 3), (0, 4)]:
        nz = tuple(c for c in partition if c > 0)
        size = orbit_size(nz)
        print(f"  Color classes {partition}: orbit size = {size}")

    total = sum(orbit_size(tuple(c for c in p if c > 0))
                for p in [(4, 0), (3, 1), (2, 2), (1, 3), (0, 4)])
    print(f"  Total: {total} = 2^4 = {2**4} ✓")


if __name__ == "__main__":
    demo_semantic_gap()
    demo_entropy_rigidity()
    demo_analogy_completion()
    demo_2_isomorphisms()
    demo_semantic_classes()
    print("\n" + "=" * 60)
    print("All demonstrations complete.")
    print("=" * 60)


#!/usr/bin/env python3
"""
Visualization: Analogy Density in Finite Groups

Verifies the Analogy Density Theorem: in Z/nZ, the number of valid
analogy quadruples (a,b,c,d) with b-a ≡ d-c (mod n) is exactly n³.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def count_analogies(n: int) -> int:
    """Count valid analogy quadruples in Z/nZ."""
    count = 0
    for a in range(n):
        for b in range(n):
            for c in range(n):
                for d in range(n):
                    if (b - a) % n == (d - c) % n:
                        count += 1
    return count


def main():
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(12, 5))

    # Plot 1: Analogy count vs n³
    ns = list(range(2, 11))
    counts = [count_analogies(n) for n in ns]
    cubes = [n ** 3 for n in ns]

    ax1.bar(np.array(ns) - 0.15, counts, 0.3, label='Counted', color='steelblue', alpha=0.8)
    ax1.bar(np.array(ns) + 0.15, cubes, 0.3, label='n³', color='coral', alpha=0.8)
    ax1.set_xlabel('Group order n', fontsize=12)
    ax1.set_ylabel('Number of valid analogies', fontsize=12)
    ax1.set_title('Analogy Density: Counted vs Predicted (n³)', fontsize=13)
    ax1.legend(fontsize=11)
    ax1.set_yscale('log')
    ax1.grid(True, alpha=0.3)

    # Plot 2: Analogy fraction = 1/n
    fractions = [c / n**4 for c, n in zip(counts, ns)]
    theoretical = [1/n for n in ns]

    ax2.plot(ns, fractions, 'bo-', markersize=8, linewidth=2, label='Measured')
    ax2.plot(ns, theoretical, 'r--', linewidth=2, label='1/n (predicted)')
    ax2.set_xlabel('Group order n', fontsize=12)
    ax2.set_ylabel('Fraction of valid analogies', fontsize=12)
    ax2.set_title('Fraction of Quadruples that are Analogies', fontsize=13)
    ax2.legend(fontsize=11)
    ax2.grid(True, alpha=0.3)

    fig.suptitle('Analogy Density Theorem: |{(a,b,c,d) : a:b :: c:d}| = n³',
                 fontsize=15, fontweight='bold')
    plt.tight_layout()
    plt.savefig('viz_analogy_density.png', dpi=150, bbox_inches='tight')
    print("Saved viz_analogy_density.png")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: Entropy-Rigidity Duality

Shows the inverse relationship between semantic entropy (distinct labels)
and the size of the semantic automorphism group.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
from itertools import permutations, product as cart_product
from math import factorial


def compute_entropy_vs_aut(n: int, k: int):
    """Compute (entropy, aut_count) pairs for all labelings of Fin n with k labels."""
    entropies = []
    aut_counts = []

    for labels in cart_product(range(k), repeat=n):
        labels_list = list(labels)
        ent = len(set(labels_list))

        count = 0
        for perm in permutations(range(n)):
            if all(labels_list[perm[i]] == labels_list[i] for i in range(n)):
                count += 1

        entropies.append(ent)
        aut_counts.append(count)

    return entropies, aut_counts


def main():
    fig, axes = plt.subplots(1, 3, figsize=(15, 5))

    for idx, (n, k) in enumerate([(3, 3), (4, 3), (4, 4)]):
        ax = axes[idx]
        entropies, aut_counts = compute_entropy_vs_aut(n, k)

        # Add jitter for visibility
        jitter_e = np.random.normal(0, 0.05, len(entropies))
        jitter_a = np.random.normal(0, 0.3, len(aut_counts))

        ax.scatter(
            np.array(entropies) + jitter_e,
            np.log2(np.array(aut_counts) + jitter_a + 0.1),
            alpha=0.3, s=10, c='steelblue'
        )

        # Theoretical bounds
        unique_ents = sorted(set(entropies))
        max_auts = []
        min_auts = []
        for e in unique_ents:
            auts_at_e = [aut_counts[i] for i in range(len(entropies)) if entropies[i] == e]
            max_auts.append(max(auts_at_e))
            min_auts.append(min(auts_at_e))

        ax.plot(unique_ents, np.log2(np.array(max_auts)), 'r-o',
                linewidth=2, markersize=6, label='Max |Aut|')
        ax.plot(unique_ents, np.log2(np.array(min_auts)), 'g-s',
                linewidth=2, markersize=6, label='Min |Aut|')

        ax.set_xlabel('Semantic Entropy H(S)', fontsize=12)
        ax.set_ylabel('log₂ |Aut(S)|', fontsize=12)
        ax.set_title(f'n={n}, k={k} labels', fontsize=13)
        ax.legend(fontsize=9)
        ax.grid(True, alpha=0.3)

    fig.suptitle('Entropy-Rigidity Duality: More Meaning ⟹ Less Symmetry',
                 fontsize=15, fontweight='bold')
    plt.tight_layout()
    plt.savefig('viz_entropy_rigidity.png', dpi=150, bbox_inches='tight')
    print("Saved viz_entropy_rigidity.png")


if __name__ == "__main__":
    main()
