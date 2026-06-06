#!/usr/bin/env python3
"""
Semantic Fiber Theory — Demonstration Script

Demonstrates the core concepts: decorated types, opacity, automorphism
restriction, semantic coarsening, and Burnside enumeration.
"""

from itertools import permutations, product
from collections import Counter
from math import factorial


def compute_opacity_index(meaning: dict) -> int:
    """Compute the opacity index = |range(meaning)|."""
    return len(set(meaning.values()))


def is_meaning_preserving(meaning: dict, perm: dict) -> bool:
    """Check if a permutation preserves the meaning function."""
    return all(meaning[perm[x]] == meaning[x] for x in meaning)


def meaning_preserving_subgroup(elements: list, meaning: dict) -> list:
    """Compute all meaning-preserving permutations."""
    result = []
    for p in permutations(elements):
        perm = dict(zip(elements, p))
        if is_meaning_preserving(meaning, perm):
            result.append(perm)
    return result


def is_decorated_equiv(m1: dict, m2: dict, bijection: dict) -> bool:
    """Check if a bijection is a decorated equivalence."""
    return all(m2[bijection[x]] == m1[x] for x in m1)


def count_decoration_classes(n: int, k: int) -> int:
    """
    Count equivalence classes of decorations Fin(n) -> Fin(k)
    under the action of Sym(n), using Burnside's lemma.
    """
    elements = list(range(n))
    total_fixed = 0
    perm_count = 0

    for p in permutations(elements):
        perm_count += 1
        # Count decorations fixed by this permutation
        # A decoration f is fixed by p iff f(p(i)) = f(i) for all i
        # This means f is constant on each cycle of p
        cycles = find_cycles(elements, p)
        fixed = k ** len(cycles)
        total_fixed += fixed

    return total_fixed // perm_count


def find_cycles(elements: list, perm: tuple) -> list:
    """Find the cycle decomposition of a permutation."""
    visited = set()
    cycles = []
    for start in elements:
        if start not in visited:
            cycle = []
            x = start
            while x not in visited:
                visited.add(x)
                cycle.append(x)
                x = perm[x]
            cycles.append(cycle)
    return cycles


def demo_opacity_existence():
    """Demonstrate Theorem A: Opacity Existence."""
    print("=" * 60)
    print("DEMO 1: Opacity Existence Theorem")
    print("=" * 60)

    elements = ['a', 'b', 'c']
    D1 = {x: 'red' for x in elements}
    D2 = {x: 'blue' for x in elements}

    print(f"\nType: {elements}")
    print(f"D1 meanings: {D1}")
    print(f"D2 meanings: {D2}")
    print(f"\nIdentity equivalence is opaque:")
    for x in elements:
        same = D2[x] == D1[x]
        print(f"  D2(id({x})) = {D2[x]} {'==' if same else '!='} {D1[x]} = D1({x})")

    print(f"\n=> Opaque pair exists! (D2(a) = blue ≠ red = D1(a))")


def demo_range_invariance():
    """Demonstrate Theorem B: Range Invariance."""
    print("\n" + "=" * 60)
    print("DEMO 2: Range Invariance Theorem")
    print("=" * 60)

    D1 = {0: 'α', 1: 'β', 2: 'γ'}
    # Equivalence: 0↔1, 1↔2, 2↔0 (cyclic)
    e = {0: 1, 1: 2, 2: 0}
    D2 = {e[x]: D1[x] for x in D1}  # D2 that makes e a decorated equiv

    print(f"\nD1 meanings: {D1}")
    print(f"D2 meanings: {D2}")
    print(f"Equivalence: {e}")
    print(f"\nRange(D1) = {set(D1.values())}")
    print(f"Range(D2) = {set(D2.values())}")
    print(f"Ranges equal: {set(D1.values()) == set(D2.values())}")
    print(f"\nVerifying decorated equivalence:")
    for x in D1:
        print(f"  D2(e({x})) = D2({e[x]}) = {D2[e[x]]} == {D1[x]} = D1({x})")


def demo_automorphism_restriction():
    """Demonstrate Theorem C: Automorphism Restriction."""
    print("\n" + "=" * 60)
    print("DEMO 3: Automorphism Restriction Theorem")
    print("=" * 60)

    elements = [0, 1, 2]
    meaning = {0: 'red', 1: 'red', 2: 'blue'}

    all_perms = list(permutations(elements))
    preserving = meaning_preserving_subgroup(elements, meaning)

    print(f"\nElements: {elements}")
    print(f"Meaning: {meaning}")
    print(f"\nTotal permutations: |Sym(3)| = {len(all_perms)}")
    print(f"Meaning-preserving: {len(preserving)}")
    print(f"\nMeaning-preserving permutations:")
    for p in preserving:
        perm_list = [p[x] for x in elements]
        print(f"  {elements} → {perm_list}")

    print(f"\nRestriction factor: {len(all_perms)}/{len(preserving)} = "
          f"{len(all_perms)/len(preserving):.0f}")
    print(f"(Only {len(preserving)}/{len(all_perms)} permutations preserve meaning)")


def demo_semantic_collapse():
    """Demonstrate Theorem G: Semantic Collapse."""
    print("\n" + "=" * 60)
    print("DEMO 4: Semantic Collapse Theorem")
    print("=" * 60)

    for n, k in [(5, 3), (4, 2), (10, 5)]:
        print(f"\n|α| = {n}, |S| = {k}: ", end="")
        if k < n:
            print(f"No faithful decoration exists ({k} < {n})")
            # Show pigeonhole
            print(f"  Any decoration must have at least "
                  f"{n - k} collisions (same meaning for different elements)")
        else:
            print(f"Faithful decorations exist ({k} >= {n})")


def demo_burnside_enumeration():
    """Demonstrate the Burnside enumeration conjecture."""
    print("\n" + "=" * 60)
    print("DEMO 5: Burnside Enumeration of Semantic Classes")
    print("=" * 60)

    for n in range(1, 6):
        for k in [2, 3]:
            classes = count_decoration_classes(n, k)
            total = k ** n
            print(f"  n={n}, k={k}: {total} decorations, "
                  f"{classes} equivalence classes")


def demo_coarsening():
    """Demonstrate Theorem H: Semantic Coarsening."""
    print("\n" + "=" * 60)
    print("DEMO 6: Semantic Coarsening Theorem")
    print("=" * 60)

    elements = list(range(6))

    # Original decoration with 4 distinct meanings
    D = {0: 'A', 1: 'B', 2: 'C', 3: 'D', 4: 'A', 5: 'B'}
    opacity_D = compute_opacity_index(D)

    # Coarsen: map A,B -> X and C,D -> Y
    coarsen = {'A': 'X', 'B': 'X', 'C': 'Y', 'D': 'Y'}
    D_coarse = {x: coarsen[D[x]] for x in elements}
    opacity_coarse = compute_opacity_index(D_coarse)

    print(f"\nOriginal decoration: {D}")
    print(f"Opacity index: {opacity_D}")
    print(f"\nCoarsening map: {coarsen}")
    print(f"Coarsened decoration: {D_coarse}")
    print(f"Opacity index: {opacity_coarse}")
    print(f"\nCoarsening reduced opacity: {opacity_D} → {opacity_coarse} "
          f"({'✓' if opacity_coarse <= opacity_D else '✗'} ≤)")

    # Further coarsen to constant
    D_const = {x: 'Z' for x in elements}
    opacity_const = compute_opacity_index(D_const)
    print(f"\nFurther coarsening to constant: {D_const}")
    print(f"Opacity index: {opacity_const}")
    print(f"Monotone chain: {opacity_D} ≥ {opacity_coarse} ≥ {opacity_const}")


if __name__ == "__main__":
    demo_opacity_existence()
    demo_range_invariance()
    demo_automorphism_restriction()
    demo_semantic_collapse()
    demo_burnside_enumeration()
    demo_coarsening()
    print("\n" + "=" * 60)
    print("All demonstrations complete.")
    print("=" * 60)


#!/usr/bin/env python3
"""
Visualization: Opacity Index Distribution and Automorphism Restriction

Shows how the opacity index distributes across decorations,
and how the meaning-preserving subgroup shrinks with more varied meanings.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
from itertools import permutations, product as cartprod
from math import factorial


def find_cycles(n, perm):
    visited = set()
    cycles = []
    for start in range(n):
        if start not in visited:
            cycle = []
            x = start
            while x not in visited:
                visited.add(x)
                cycle.append(x)
                x = perm[x]
            cycles.append(cycle)
    return cycles


def burnside_count(n, k):
    total = 0
    for p in permutations(range(n)):
        total += k ** len(find_cycles(n, p))
    return total // factorial(n)


def opacity_spectrum(n, k):
    spectrum = {}
    for dec in cartprod(range(k), repeat=n):
        oi = len(set(dec))
        spectrum[oi] = spectrum.get(oi, 0) + 1
    return spectrum


def meaning_preserving_count(n, meaning):
    count = 0
    elems = list(range(n))
    for p in permutations(elems):
        if all(meaning[p[x]] == meaning[x] for x in elems):
            count += 1
    return count


def plot_opacity_spectrum():
    fig, axes = plt.subplots(1, 3, figsize=(14, 4))

    for idx, (n, k) in enumerate([(4, 4), (5, 3), (6, 2)]):
        spec = opacity_spectrum(n, k)
        ois = sorted(spec.keys())
        counts = [spec[oi] for oi in ois]

        axes[idx].bar(ois, counts, color=plt.cm.viridis(np.linspace(0.2, 0.8, len(ois))),
                      edgecolor='black', linewidth=0.5)
        axes[idx].set_xlabel('Opacity Index', fontsize=11)
        axes[idx].set_ylabel('Number of Decorations', fontsize=11)
        axes[idx].set_title(f'n={n}, k={k} (total={k**n})', fontsize=12)
        axes[idx].set_xticks(ois)

        # Add Burnside class count
        bc = burnside_count(n, k)
        axes[idx].text(0.95, 0.95, f'{bc} equiv classes',
                       transform=axes[idx].transAxes, ha='right', va='top',
                       fontsize=9, bbox=dict(boxstyle='round', facecolor='wheat', alpha=0.5))

    fig.suptitle('Opacity Index Distribution Across Decorations', fontsize=14, y=1.02)
    plt.tight_layout()
    plt.savefig('opacity_spectrum.png', dpi=150, bbox_inches='tight')
    print("Saved opacity_spectrum.png")


def plot_automorphism_restriction():
    fig, ax = plt.subplots(figsize=(8, 5))

    n = 4
    k_values = range(1, 5)

    for k in k_values:
        # For each possible opacity index, compute average |Aut_m|
        opacity_to_aut = {}
        for dec in cartprod(range(k), repeat=n):
            meaning = {i: dec[i] for i in range(n)}
            oi = len(set(dec))
            aut_size = meaning_preserving_count(n, meaning)
            if oi not in opacity_to_aut:
                opacity_to_aut[oi] = []
            opacity_to_aut[oi].append(aut_size)

        ois = sorted(opacity_to_aut.keys())
        avg_auts = [np.mean(opacity_to_aut[oi]) for oi in ois]

        ax.plot(ois, avg_auts, 'o-', label=f'k={k}', markersize=6)

    ax.axhline(y=factorial(n), color='red', linestyle='--', alpha=0.5,
               label=f'|Sym({n})| = {factorial(n)}')
    ax.set_xlabel('Opacity Index', fontsize=12)
    ax.set_ylabel('Average |Aut_meaning|', fontsize=12)
    ax.set_title(f'Automorphism Restriction (n={n}): Higher Opacity → Smaller Aut Group',
                 fontsize=13)
    ax.legend()
    ax.set_yscale('log')
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('automorphism_restriction.png', dpi=150, bbox_inches='tight')
    print("Saved automorphism_restriction.png")


def plot_coarsening_chains():
    fig, ax = plt.subplots(figsize=(8, 5))

    n = 5
    np.random.seed(42)

    for trial in range(8):
        # Random decoration with k=5
        k = 5
        dec = [np.random.randint(0, k) for _ in range(n)]
        chain = [len(set(dec))]

        # Repeatedly coarsen by merging two random values
        current_dec = list(dec)
        while len(set(current_dec)) > 1:
            vals = list(set(current_dec))
            if len(vals) < 2:
                break
            # Merge first two values
            merge_from = vals[0]
            merge_to = vals[1]
            current_dec = [merge_to if x == merge_from else x for x in current_dec]
            chain.append(len(set(current_dec)))

        ax.plot(range(len(chain)), chain, 'o-', alpha=0.7, markersize=5)

    ax.set_xlabel('Coarsening Step', fontsize=12)
    ax.set_ylabel('Opacity Index', fontsize=12)
    ax.set_title('Semantic Coarsening: Opacity Index is Monotonically Non-Increasing',
                 fontsize=13)
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('coarsening_chains.png', dpi=150, bbox_inches='tight')
    print("Saved coarsening_chains.png")


if __name__ == "__main__":
    plot_opacity_spectrum()
    plot_automorphism_restriction()
    plot_coarsening_chains()
    print("\nAll visualizations generated.")
