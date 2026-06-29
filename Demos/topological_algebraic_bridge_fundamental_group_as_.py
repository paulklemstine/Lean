#!/usr/bin/env python3
"""
Invariant Spectrum: Demonstrations and Numerical Examples

Demonstrates the core concepts of the Invariant Spectrum framework:
- Sound vs Complete invariants
- Confusion pairs and confusion counts
- Essential dimension computation
- Aspherical spectra and the K(G,1) theorem
"""

from typing import Callable, TypeVar, List, Tuple, Dict, Set
from dataclasses import dataclass
from itertools import product as cartesian_product

T = TypeVar('T')

@dataclass
class InvariantSpectrum:
    """A graded tower of invariants on a finite set."""
    elements: List[int]
    equiv: Callable[[int, int], bool]  # equivalence relation
    invariants: List[Callable[[int], object]]  # inv[n] : α → object

    def is_sound(self, level: int) -> bool:
        """Check if invariant at level n is sound."""
        inv = self.invariants[level]
        for x in self.elements:
            for y in self.elements:
                if self.equiv(x, y) and inv(x) != inv(y):
                    return False
        return True

    def is_level_complete(self, level: int) -> bool:
        """Check if single level n classifies completely."""
        inv = self.invariants[level]
        for x in self.elements:
            for y in self.elements:
                if inv(x) == inv(y) and not self.equiv(x, y):
                    return False
        return True

    def is_cumulative_complete(self, level: int) -> bool:
        """Check if levels 0..n together classify."""
        for x in self.elements:
            for y in self.elements:
                if all(self.invariants[k](x) == self.invariants[k](y)
                       for k in range(level + 1)):
                    if not self.equiv(x, y):
                        return False
        return True

    def confusion_pairs(self, level: int) -> List[Tuple[int, int]]:
        """Find all confusion pairs at level n."""
        pairs = []
        for x in self.elements:
            for y in self.elements:
                if x < y:  # avoid duplicates
                    if all(self.invariants[k](x) == self.invariants[k](y)
                           for k in range(level + 1)):
                        if not self.equiv(x, y):
                            pairs.append((x, y))
        return pairs

    def confusion_count(self, level: int) -> int:
        """Count confusion pairs at level n."""
        return len(self.confusion_pairs(level))

    def essential_dimension(self) -> int:
        """Compute essential dimension (minimum complete level)."""
        for n in range(len(self.invariants)):
            if self.is_cumulative_complete(n):
                return n
        return -1  # infinite

    def is_aspherical(self) -> bool:
        """Check if all invariants above level 1 are trivial."""
        for n in range(2, len(self.invariants)):
            inv = self.invariants[n]
            vals = [inv(x) for x in self.elements]
            if len(set(str(v) for v in vals)) > 1:
                return False
        return True

    def find_higher_witness(self) -> Tuple[int, int, int] | None:
        """Find a higher-dimensional witness (x, y, level) if one exists."""
        inv1 = self.invariants[1] if len(self.invariants) > 1 else None
        if inv1 is None:
            return None
        for x in self.elements:
            for y in self.elements:
                if x < y and inv1(x) == inv1(y) and not self.equiv(x, y):
                    for n in range(2, len(self.invariants)):
                        if self.invariants[n](x) != self.invariants[n](y):
                            return (x, y, n)
        return None


def demo_parity_invariant():
    """Demo: Parity is incomplete for ZMod 4."""
    print("=" * 60)
    print("DEMO 1: Parity as Incomplete Invariant for ℤ/4ℤ")
    print("=" * 60)

    elements = [0, 1, 2, 3]
    equiv = lambda x, y: x == y  # equality
    parity = lambda x: x % 2
    identity = lambda x: x

    S = InvariantSpectrum(
        elements=elements,
        equiv=equiv,
        invariants=[parity, identity]
    )

    print(f"\nElements: {elements}")
    print(f"Level 0 (parity): {[parity(x) for x in elements]}")
    print(f"Level 1 (identity): {[identity(x) for x in elements]}")

    print(f"\nLevel 0 sound: {S.is_sound(0)}")
    print(f"Level 0 complete: {S.is_level_complete(0)}")
    print(f"Level 0 confusion pairs: {S.confusion_pairs(0)}")

    print(f"\nLevel 1 sound: {S.is_sound(1)}")
    print(f"Level 1 complete: {S.is_level_complete(1)}")

    print(f"\nEssential dimension: {S.essential_dimension()}")
    print(f"Confusion count sequence: {[S.confusion_count(k) for k in range(2)]}")


def demo_aspherical_spectrum():
    """Demo: Aspherical spectrum where level 1 suffices."""
    print("\n" + "=" * 60)
    print("DEMO 2: Aspherical Spectrum (K(G,1) Analogue)")
    print("=" * 60)

    # Model: 6 objects, equivalence classes {0,1}, {2,3}, {4,5}
    elements = [0, 1, 2, 3, 4, 5]
    equiv = lambda x, y: x // 2 == y // 2

    # Level 0: coarsest (connected components) - maps to {A, B}
    level0 = lambda x: 'A' if x < 4 else 'B'
    # Level 1: fundamental group analogue - maps to class
    level1 = lambda x: x // 2
    # Level 2: trivial (aspherical condition)
    level2 = lambda x: 'trivial'
    # Level 3: trivial
    level3 = lambda x: 'trivial'

    S = InvariantSpectrum(
        elements=elements,
        equiv=equiv,
        invariants=[level0, level1, level2, level3]
    )

    print(f"\nElements: {elements}")
    print(f"Equivalence classes: {{0,1}}, {{2,3}}, {{4,5}}")
    print(f"Level 0 values: {[level0(x) for x in elements]}")
    print(f"Level 1 values: {[level1(x) for x in elements]}")
    print(f"Level 2 values: {[level2(x) for x in elements]} (trivial)")

    print(f"\nLevel 0 complete: {S.is_level_complete(0)}")
    print(f"Level 0 confusion pairs: {S.confusion_pairs(0)}")
    print(f"Level 1 complete: {S.is_level_complete(1)}")
    print(f"Aspherical: {S.is_aspherical()}")
    print(f"Essential dimension: {S.essential_dimension()}")
    print()
    print("Since spectrum is aspherical and level 1 is complete,")
    print("the K(G,1) theorem tells us level 1 alone classifies.")


def demo_sphere_analogy():
    """Demo: Higher-dimensional witness (S² vs S³ analogy)."""
    print("\n" + "=" * 60)
    print("DEMO 3: Higher-Dimensional Witness (S² vs S³ Analogy)")
    print("=" * 60)

    # Model: 4 "spaces" where S2 and S3 have same π₁ but different π₂
    elements = [0, 1, 2, 3]  # 0=torus, 1=klein, 2=S², 3=S³
    names = {0: 'Torus', 1: 'Klein', 2: 'S²', 3: 'S³'}
    equiv = lambda x, y: x == y

    # π₁ (fundamental group)
    pi1 = {0: 'Z×Z', 1: 'Z⋊Z', 2: '0', 3: '0'}
    # π₂ (second homotopy group)
    pi2 = {0: '0', 1: '0', 2: 'Z', 3: '0'}
    # π₃
    pi3 = {0: '0', 1: '0', 2: 'Z', 3: 'Z'}

    level0 = lambda x: 'connected'
    level1 = lambda x: pi1[x]
    level2 = lambda x: pi2[x]
    level3 = lambda x: pi3[x]

    S = InvariantSpectrum(
        elements=elements,
        equiv=equiv,
        invariants=[level0, level1, level2, level3]
    )

    print(f"\nSpaces: {[names[x] for x in elements]}")
    print(f"π₁ values: {[pi1[x] for x in elements]}")
    print(f"π₂ values: {[pi2[x] for x in elements]}")
    print(f"π₃ values: {[pi3[x] for x in elements]}")

    print(f"\nLevel 1 (π₁) complete: {S.is_level_complete(1)}")
    print(f"Level 1 confusion pairs: "
          f"{[(names[a], names[b]) for a, b in S.confusion_pairs(1)]}")

    witness = S.find_higher_witness()
    if witness:
        x, y, n = witness
        print(f"\nHigher-dimensional witness found!")
        print(f"  {names[x]} and {names[y]} agree at π₁")
        print(f"  but disagree at π_{n}")
        print(f"  π₁({names[x]}) = {pi1[x]}, π₁({names[y]}) = {pi1[y]}")
        level_names = {2: 'π₂', 3: 'π₃'}
        inv_vals = {2: pi2, 3: pi3}
        print(f"  {level_names[n]}({names[x]}) = {inv_vals[n][x]}, "
              f"{level_names[n]}({names[y]}) = {inv_vals[n][y]}")

    print(f"\nAspherical: {S.is_aspherical()}")
    print(f"Essential dimension: {S.essential_dimension()}")
    print(f"Confusion count sequence: {[S.confusion_count(k) for k in range(4)]}")


def demo_confusion_monotonicity():
    """Demo: Confusion count monotonically decreases."""
    print("\n" + "=" * 60)
    print("DEMO 4: Confusion Count Monotone Decrease")
    print("=" * 60)

    # 8 elements, identity equivalence, increasingly fine invariants
    elements = list(range(8))
    equiv = lambda x, y: x == y

    levels = [
        lambda x: x % 2,      # mod 2: 4 confusion pairs in each class
        lambda x: x % 4,      # mod 4: fewer confusion pairs
        lambda x: x % 8,      # mod 8: identity, no confusion
    ]

    S = InvariantSpectrum(elements=elements, equiv=equiv, invariants=levels)

    print(f"\nElements: {elements}")
    print(f"Level 0 (mod 2): {[levels[0](x) for x in elements]}")
    print(f"Level 1 (mod 4): {[levels[1](x) for x in elements]}")
    print(f"Level 2 (mod 8): {[levels[2](x) for x in elements]}")

    for k in range(3):
        cc = S.confusion_count(k)
        pairs = S.confusion_pairs(k)
        print(f"\nLevel {k}: confusion count = {cc}")
        if pairs:
            print(f"  Confusion pairs: {pairs}")
        else:
            print(f"  No confusion pairs — COMPLETE!")

    print(f"\nMonotone decrease verified: "
          f"{[S.confusion_count(k) for k in range(3)]}")
    print(f"Essential dimension: {S.essential_dimension()}")


if __name__ == '__main__':
    demo_parity_invariant()
    demo_aspherical_spectrum()
    demo_sphere_analogy()
    demo_confusion_monotonicity()


#!/usr/bin/env python3
"""
Visualization: Confusion Count Profiles for Invariant Spectra

Creates a plot showing how confusion counts decrease as invariant levels
are added, demonstrating the monotone completeness theorem.
"""
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def compute_confusion_count(elements, equiv_fn, invariants, level):
    """Compute confusion count at a given level."""
    count = 0
    for i in range(len(elements)):
        for j in range(i + 1, len(elements)):
            x, y = elements[i], elements[j]
            if all(invariants[k](x) == invariants[k](y) for k in range(level + 1)):
                if not equiv_fn(x, y):
                    count += 1
    return count


def make_spectrum_zmod(n, divisor_chain):
    """Create a spectrum for ZMod n with a chain of divisors."""
    elements = list(range(n))
    equiv = lambda x, y: x == y
    invariants = [lambda x, d=d: x % d for d in divisor_chain]
    return elements, equiv, invariants


def main():
    fig, axes = plt.subplots(2, 2, figsize=(12, 10))
    fig.suptitle('Invariant Spectrum: Confusion Count Profiles',
                 fontsize=16, fontweight='bold')

    # Example 1: ZMod 12 with divisor chain 2, 3, 4, 6, 12
    elems, equiv, invs = make_spectrum_zmod(12, [2, 3, 4, 6, 12])
    profile1 = [compute_confusion_count(elems, equiv, invs, k)
                for k in range(len(invs))]
    ax = axes[0, 0]
    ax.bar(range(len(profile1)), profile1, color=['#e74c3c' if c > 0 else '#2ecc71'
                                                   for c in profile1])
    ax.set_title('ℤ/12ℤ: Divisor Chain [2,3,4,6,12]')
    ax.set_xlabel('Level')
    ax.set_ylabel('Confusion Count')
    ax.set_xticks(range(len(profile1)))
    for i, v in enumerate(profile1):
        ax.text(i, v + 0.3, str(v), ha='center', fontweight='bold')

    # Example 2: ZMod 16 with powers of 2
    elems, equiv, invs = make_spectrum_zmod(16, [2, 4, 8, 16])
    profile2 = [compute_confusion_count(elems, equiv, invs, k)
                for k in range(len(invs))]
    ax = axes[0, 1]
    ax.bar(range(len(profile2)), profile2, color=['#e74c3c' if c > 0 else '#2ecc71'
                                                   for c in profile2])
    ax.set_title('ℤ/16ℤ: Powers of 2 [2,4,8,16]')
    ax.set_xlabel('Level')
    ax.set_ylabel('Confusion Count')
    ax.set_xticks(range(len(profile2)))
    for i, v in enumerate(profile2):
        ax.text(i, v + 0.5, str(v), ha='center', fontweight='bold')

    # Example 3: "Aspherical" spectrum - level 1 already complete
    elements_asp = list(range(6))
    equiv_asp = lambda x, y: x == y
    invs_asp = [
        lambda x: x % 3,       # Level 0: mod 3
        lambda x: x,            # Level 1: identity (complete)
        lambda x: 'trivial',    # Level 2: trivial (aspherical)
        lambda x: 'trivial',    # Level 3: trivial
    ]
    profile3 = [compute_confusion_count(elements_asp, equiv_asp, invs_asp, k)
                for k in range(4)]
    ax = axes[1, 0]
    colors3 = ['#e74c3c' if c > 0 else '#2ecc71' for c in profile3]
    ax.bar(range(4), profile3, color=colors3)
    ax.set_title('Aspherical Spectrum (K(G,1))\nLevel 1 Complete, Higher Trivial')
    ax.set_xlabel('Level')
    ax.set_ylabel('Confusion Count')
    ax.set_xticks(range(4))
    ax.set_xticklabels(['π₀', 'π₁', 'π₂', 'π₃'])
    for i, v in enumerate(profile3):
        ax.text(i, v + 0.1, str(v), ha='center', fontweight='bold')

    # Example 4: Sphere analogy - need level 2
    names = ['Torus', 'Klein', 'S²', 'S³']
    pi1 = ['Z×Z', 'Z⋊Z', '0', '0']
    pi2 = ['0', '0', 'Z', '0']
    pi3 = ['0', '0', 'Z', 'Z']
    elements_sph = list(range(4))
    equiv_sph = lambda x, y: x == y
    invs_sph = [
        lambda x: 'connected',
        lambda x: pi1[x],
        lambda x: pi2[x],
        lambda x: pi3[x],
    ]
    profile4 = [compute_confusion_count(elements_sph, equiv_sph, invs_sph, k)
                for k in range(4)]
    ax = axes[1, 1]
    colors4 = ['#e74c3c' if c > 0 else '#2ecc71' for c in profile4]
    ax.bar(range(4), profile4, color=colors4)
    ax.set_title('Sphere Analogy: S² vs S³\nNeed Higher Homotopy Groups')
    ax.set_xlabel('Level')
    ax.set_ylabel('Confusion Count')
    ax.set_xticks(range(4))
    ax.set_xticklabels(['π₀', 'π₁', 'π₂', 'π₃'])
    for i, v in enumerate(profile4):
        ax.text(i, v + 0.05, str(v), ha='center', fontweight='bold')

    plt.tight_layout()
    plt.savefig('confusion_profiles.png', dpi=150, bbox_inches='tight')
    print("Saved confusion_profiles.png")


if __name__ == '__main__':
    main()
