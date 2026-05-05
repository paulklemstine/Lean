"""
Prime Congruence Spectrum — Concrete Examples and Visualizations

This demo illustrates the Lawvere–Stone representation theorem for proof semirings
by computing prime congruence spectra and the representation map for small semirings.

The key insight: in a commutative semiring, the prime congruences play the role that
prime ideals play for rings. The "spectrum" of all prime congruences carries a natural
topology, and the representation theorem says that the semiring embeds into (and under
completeness conditions, equals) the semiring of "compatible local sections" on this
spectrum.
"""

from itertools import product as cartesian_product
from collections import defaultdict
import json


# ============================================================
# Section 1: Congruences on Finite Semirings
# ============================================================

class FiniteSemiring:
    """A finite commutative semiring defined by explicit addition and multiplication tables."""
    
    def __init__(self, n, add_table, mul_table, zero=0, one=1, name="S"):
        self.n = n  # number of elements (labeled 0..n-1)
        self.add = add_table  # add[a][b] = a + b
        self.mul = mul_table  # mul[a][b] = a * b
        self.zero = zero
        self.one = one
        self.name = name
    
    def elements(self):
        return range(self.n)
    
    def __repr__(self):
        return f"{self.name}(|{self.n}|)"


class Congruence:
    """An equivalence relation on a finite semiring, stored as a partition."""
    
    def __init__(self, semiring, partition):
        """partition: list of frozensets, each a congruence class."""
        self.semiring = semiring
        self.partition = partition
        self._class_of = {}
        for i, cls in enumerate(partition):
            for elem in cls:
                self._class_of[elem] = i
    
    def class_of(self, x):
        return self._class_of[x]
    
    def are_congruent(self, x, y):
        return self._class_of[x] == self._class_of[y]
    
    def is_ring_congruence(self):
        """Check that the partition is compatible with + and *."""
        S = self.semiring
        for a in S.elements():
            for b in S.elements():
                for c in S.elements():
                    for d in S.elements():
                        if self.are_congruent(a, c) and self.are_congruent(b, d):
                            if not self.are_congruent(S.add[a][b], S.add[c][d]):
                                return False
                            if not self.are_congruent(S.mul[a][b], S.mul[c][d]):
                                return False
        return True
    
    def is_proper(self):
        """Not the total congruence (not all elements in one class)."""
        return len(self.partition) > 1
    
    def is_prime(self):
        """A congruence is prime if it is proper and a*b ≡ 0 implies a ≡ 0 or b ≡ 0."""
        if not self.is_proper():
            return False
        S = self.semiring
        z = S.zero
        for a in S.elements():
            for b in S.elements():
                if self.are_congruent(S.mul[a][b], z):
                    if not (self.are_congruent(a, z) or self.are_congruent(b, z)):
                        return False
        return True
    
    def num_classes(self):
        return len(self.partition)
    
    def __repr__(self):
        return "{" + ", ".join(str(set(cls)) for cls in self.partition) + "}"
    
    def __eq__(self, other):
        return set(self.partition) == set(other.partition)
    
    def __hash__(self):
        return hash(frozenset(self.partition))


def all_partitions(n):
    """Generate all partitions of {0, ..., n-1}."""
    if n == 0:
        yield []
        return
    if n == 1:
        yield [frozenset([0])]
        return
    for part in all_partitions(n - 1):
        # Add n-1 to each existing class
        for i in range(len(part)):
            new_part = list(part)
            new_part[i] = part[i] | {n - 1}
            yield new_part
        # Add n-1 as a new singleton class
        yield part + [frozenset([n - 1])]


def find_all_congruences(S):
    """Find all ring congruences on a finite semiring."""
    congruences = []
    for partition in all_partitions(S.n):
        c = Congruence(S, partition)
        if c.is_ring_congruence():
            congruences.append(c)
    return congruences


def find_prime_congruences(S):
    """Find all prime congruences on a finite semiring."""
    return [c for c in find_all_congruences(S) if c.is_prime()]


# ============================================================
# Section 2: The Representation Map
# ============================================================

def representation_map(S, primes):
    """
    Compute the representation map: for each element a ∈ S,
    compute its image ([a]_p)_p in the stalk product.
    
    Returns a dict: element -> tuple of congruence classes.
    """
    result = {}
    for a in S.elements():
        image = tuple(p.class_of(a) for p in primes)
        result[a] = image
    return result


def check_injectivity(rep_map):
    """Check if the representation map is injective."""
    images = list(rep_map.values())
    return len(images) == len(set(images))


def check_separation(S, primes):
    """Check the prime separation property: distinct elements are separated by some prime."""
    for a in S.elements():
        for b in S.elements():
            if a != b:
                separated = any(not p.are_congruent(a, b) for p in primes)
                if not separated:
                    return False, (a, b)
    return True, None


# ============================================================
# Section 3: Concrete Examples
# ============================================================

def boolean_semiring():
    """The Boolean semiring B = {0, 1} with max/min (or standard +, *)."""
    add = [[0, 1], [1, 1]]  # a + b = max(a, b) in Boolean
    mul = [[0, 0], [0, 1]]  # a * b = min(a, b) in Boolean
    return FiniteSemiring(2, add, mul, zero=0, one=1, name="𝔹")


def tropical_three():
    """The tropical semiring T₃ = {0, 1, 2} with max and + mod 3 as multiplication."""
    # Actually, let's use the simpler: {0, 1, ∞} with min and +
    # Even simpler: Z/3 as a commutative semiring
    add = [[0, 1, 2], [1, 2, 0], [2, 0, 1]]
    mul = [[0, 0, 0], [0, 1, 2], [0, 2, 1]]
    return FiniteSemiring(3, add, mul, zero=0, one=1, name="ℤ/3")


def four_element_semiring():
    """The semiring {0, 1, a, b} where a² = a, b² = b, ab = 0."""
    # This is isomorphic to 𝔹 × 𝔹
    # Elements: 0=(0,0), 1=(1,1), a=(1,0), b=(0,1)
    # Addition: componentwise max; Multiplication: componentwise min
    add = [
        [0, 1, 2, 3],  # 0 + {0,1,a,b}
        [1, 1, 1, 1],  # 1 + {0,1,a,b} = {1,1,1,1}
        [2, 1, 2, 1],  # a + {0,1,a,b} = {a,1,a,1}
        [3, 1, 1, 3],  # b + {0,1,a,b} = {b,1,1,b}
    ]
    mul = [
        [0, 0, 0, 0],  # 0 * anything = 0
        [0, 1, 2, 3],  # 1 * anything = anything
        [0, 2, 2, 0],  # a * {0,1,a,b} = {0,a,a,0}
        [0, 3, 0, 3],  # b * {0,1,a,b} = {0,b,0,b}
    ]
    return FiniteSemiring(4, add, mul, zero=0, one=1, name="𝔹×𝔹")


def run_example(S):
    """Run the full analysis on a semiring."""
    print(f"\n{'='*60}")
    print(f"  Semiring: {S.name} with {S.n} elements")
    print(f"{'='*60}")
    
    # Find all congruences
    all_congs = find_all_congruences(S)
    print(f"\n  Total ring congruences: {len(all_congs)}")
    
    # Find prime congruences
    primes = find_prime_congruences(S)
    print(f"  Prime congruences: {len(primes)}")
    print(f"  → PrimeConSpec({S.name}) has {len(primes)} point(s)")
    
    for i, p in enumerate(primes):
        print(f"    p_{i}: {p}")
    
    # Check separation
    sep, witness = check_separation(S, primes)
    print(f"\n  Prime separation: {'✓ YES' if sep else f'✗ NO (witness: {witness})'}")
    
    # Compute representation map
    rep = representation_map(S, primes)
    inj = check_injectivity(rep)
    print(f"  Representation injective: {'✓ YES' if inj else '✗ NO'}")
    
    print(f"\n  Representation map (element → stalk product):")
    element_names = {0: '0', 1: '1', 2: 'a', 3: 'b'}
    for elem, image in rep.items():
        name = element_names.get(elem, str(elem))
        classes = ", ".join(f"[{c}]" for c in image)
        print(f"    {name} ↦ ({classes})")
    
    # Basic opens
    print(f"\n  Basic opens D(x,y) (non-trivial ones):")
    seen_opens = set()
    for x in S.elements():
        for y in S.elements():
            if x < y:
                D_xy = frozenset(i for i, p in enumerate(primes) if not p.are_congruent(x, y))
                if D_xy and D_xy != frozenset(range(len(primes))):
                    if D_xy not in seen_opens:
                        seen_opens.add(D_xy)
                        x_name = element_names.get(x, str(x))
                        y_name = element_names.get(y, str(y))
                        pts = ", ".join(f"p_{i}" for i in sorted(D_xy))
                        print(f"    D({x_name},{y_name}) = {{{pts}}}")
    
    if not seen_opens:
        print(f"    (all basic opens are either ∅ or the whole spectrum)")
    
    return primes, rep, inj


def main():
    print("╔════════════════════════════════════════════════════════════╗")
    print("║  PRIME CONGRUENCE SPECTRUM — CONCRETE EXAMPLES            ║")
    print("║  Lawvere–Stone Representation for Proof Semirings         ║")
    print("╚════════════════════════════════════════════════════════════╝")
    
    # Example 1: Boolean semiring
    B = boolean_semiring()
    run_example(B)
    
    # Example 2: Z/3
    Z3 = tropical_three()
    run_example(Z3)
    
    # Example 3: B × B (4 elements)
    BB = four_element_semiring()
    primes_BB, rep_BB, inj_BB = run_example(BB)
    
    # Summary
    print(f"\n{'='*60}")
    print("  SUMMARY: Lawvere–Stone Representation")
    print(f"{'='*60}")
    print()
    print("  The representation theorem states:")
    print("    P  ↪  BasisGlobalSections(P)")
    print("       ≅  { locally representable sections on PrimeConSpec(P) }")
    print()
    print("  For each semiring above:")
    print("    • Prime separation holds (injectivity of the embedding)")
    print("    • The stalk product ∏_p P/p faithfully represents P")
    print("    • Basic opens D(x,y) generate the Zariski topology")
    print()
    print("  Key insight: two proof values x,y are equal iff")
    print("    [x]_p = [y]_p for ALL prime congruences p.")
    print("  This is the semantic completeness principle.")


if __name__ == "__main__":
    main()


"""
Visualization of Prime Congruence Spectra and the Representation Map

Creates matplotlib figures showing:
1. The spectrum as a topological space with basic opens
2. The representation map from a semiring to its stalk product
3. The lattice of congruences colored by primality
"""

import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
from matplotlib.patches import FancyBboxPatch
import numpy as np


def draw_spectrum_BB():
    """
    Visualize PrimeConSpec(𝔹×𝔹) with its basic open structure.
    
    𝔹×𝔹 = {0, 1, a, b} with a=(1,0), b=(0,1).
    PrimeConSpec has exactly 2 points: p₀ and p₁.
    """
    fig, axes = plt.subplots(1, 3, figsize=(16, 5))
    fig.suptitle("Prime Congruence Spectrum of 𝔹×𝔹", fontsize=14, fontweight='bold')
    
    # Panel 1: The spectrum as a topological space
    ax = axes[0]
    ax.set_xlim(-0.5, 3.5)
    ax.set_ylim(-0.5, 2.5)
    ax.set_aspect('equal')
    ax.set_title("PrimeConSpec(𝔹×𝔹)", fontsize=12)
    
    # Draw the two prime points
    ax.plot(1, 1, 'ko', markersize=15, zorder=5)
    ax.plot(2.5, 1, 'ko', markersize=15, zorder=5)
    ax.annotate('p₀', (1, 1), fontsize=14, ha='center', va='center', color='white',
                fontweight='bold', zorder=6)
    ax.annotate('p₁', (2.5, 1), fontsize=14, ha='center', va='center', color='white',
                fontweight='bold', zorder=6)
    
    # Draw basic opens
    # D(0,1) = {p₀, p₁} = whole spectrum
    rect_full = FancyBboxPatch((0.2, 0.2), 3, 1.6, boxstyle="round,pad=0.1",
                                facecolor='lightblue', edgecolor='blue', alpha=0.3, linewidth=2)
    ax.add_patch(rect_full)
    ax.annotate('D(0,1) = whole spectrum', (1.75, 2.1), fontsize=9, ha='center', color='blue')
    
    # D(0,b) = {p₀}
    circ_p0 = plt.Circle((1, 1), 0.5, facecolor='lightgreen', edgecolor='green',
                          alpha=0.4, linewidth=2)
    ax.add_patch(circ_p0)
    ax.annotate('D(0,b)', (0.3, 0.3), fontsize=9, color='green')
    
    # D(0,a) = {p₁}
    circ_p1 = plt.Circle((2.5, 1), 0.5, facecolor='lightyellow', edgecolor='orange',
                          alpha=0.4, linewidth=2)
    ax.add_patch(circ_p1)
    ax.annotate('D(0,a)', (2.9, 0.3), fontsize=9, color='orange')
    
    ax.axis('off')
    
    # Panel 2: The representation map
    ax = axes[1]
    ax.set_xlim(-1, 5)
    ax.set_ylim(-0.5, 4.5)
    ax.set_title("Representation Map\nP → ∏ P/p", fontsize=12)
    
    elements = ['0', '1', 'a', 'b']
    images = ['([0],[0])', '([1],[1])', '([0],[1])', '([1],[0])']
    colors = ['#d9534f', '#5cb85c', '#428bca', '#f0ad4e']
    
    for i, (elem, img, color) in enumerate(zip(elements, images, colors)):
        y = 3.5 - i
        # Element on the left
        ax.add_patch(FancyBboxPatch((0, y - 0.25), 0.8, 0.5,
                                     boxstyle="round,pad=0.05",
                                     facecolor=color, alpha=0.7, edgecolor='black'))
        ax.text(0.4, y, elem, ha='center', va='center', fontsize=14, fontweight='bold')
        
        # Arrow
        ax.annotate('', xy=(2.5, y), xytext=(1.0, y),
                    arrowprops=dict(arrowstyle='->', lw=1.5, color='gray'))
        
        # Image on the right
        ax.add_patch(FancyBboxPatch((2.5, y - 0.25), 2, 0.5,
                                     boxstyle="round,pad=0.05",
                                     facecolor=color, alpha=0.3, edgecolor='black'))
        ax.text(3.5, y, img, ha='center', va='center', fontsize=11)
    
    ax.text(0.4, 4.2, 'P', ha='center', fontsize=13, fontweight='bold')
    ax.text(3.5, 4.2, '∏ₚ P/p', ha='center', fontsize=13, fontweight='bold')
    ax.axis('off')
    
    # Panel 3: Congruence lattice
    ax = axes[2]
    ax.set_xlim(-1, 5)
    ax.set_ylim(-0.5, 4.5)
    ax.set_title("Congruence Lattice\n(primes in red)", fontsize=12)
    
    # Lattice structure:
    # ⊤ (total) at top
    # p₀, p₁ (primes) in middle
    # ⊥ (diagonal) at bottom
    
    positions = {
        '⊤': (2, 3.5),
        'p₀': (0.5, 2),
        'p₁': (3.5, 2),
        '⊥': (2, 0.5),
    }
    
    labels = {
        '⊤': '⊤\n{0,1,a,b}',
        'p₀': 'p₀\n{0,a}|{1,b}',
        'p₁': 'p₁\n{0,b}|{1,a}',
        '⊥': '⊥\n{0}|{1}|{a}|{b}',
    }
    
    # Draw edges
    for start, end in [('⊥', 'p₀'), ('⊥', 'p₁'), ('p₀', '⊤'), ('p₁', '⊤')]:
        x0, y0 = positions[start]
        x1, y1 = positions[end]
        ax.plot([x0, x1], [y0, y1], 'k-', linewidth=1.5, alpha=0.5)
    
    # Draw nodes
    for name, (x, y) in positions.items():
        is_prime = name.startswith('p')
        color = '#ff6b6b' if is_prime else '#e0e0e0'
        edge_color = '#cc0000' if is_prime else '#666666'
        ax.add_patch(FancyBboxPatch((x - 0.8, y - 0.4), 1.6, 0.8,
                                     boxstyle="round,pad=0.05",
                                     facecolor=color, edgecolor=edge_color, linewidth=2))
        ax.text(x, y, labels[name], ha='center', va='center', fontsize=8)
    
    ax.axis('off')
    
    plt.tight_layout()
    plt.savefig('demos/spectrum_BB.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("  Saved: demos/spectrum_BB.png")


def draw_representation_theorem():
    """
    Visualize the representation theorem conceptually:
    P ≃ BasisGlobalSections(P) for spectrally complete P.
    """
    fig, ax = plt.subplots(1, 1, figsize=(12, 7))
    ax.set_xlim(-0.5, 10.5)
    ax.set_ylim(-0.5, 8)
    ax.set_title("Lawvere–Stone Representation Theorem\nfor Proof Semirings",
                 fontsize=16, fontweight='bold', pad=20)
    
    # Left: the semiring P
    ax.add_patch(FancyBboxPatch((0.5, 3), 3, 3,
                                 boxstyle="round,pad=0.2",
                                 facecolor='#e8f4fd', edgecolor='#2196F3', linewidth=3))
    ax.text(2, 5.5, 'P', fontsize=28, ha='center', va='center', fontweight='bold',
            color='#1565C0')
    ax.text(2, 4.3, 'Proof\nSemiring', fontsize=12, ha='center', va='center',
            color='#1565C0')
    ax.text(2, 3.3, '(closure-generated)', fontsize=9, ha='center', va='center',
            color='#1565C0', style='italic')
    
    # Arrow
    ax.annotate('', xy=(6.5, 4.5), xytext=(4, 4.5),
                arrowprops=dict(arrowstyle='->', lw=3, color='#4CAF50',
                               connectionstyle='arc3,rad=0'))
    ax.text(5.25, 5.3, '≃', fontsize=32, ha='center', va='center',
            color='#4CAF50', fontweight='bold')
    ax.text(5.25, 4.0, 'toBasisGlobalSections', fontsize=9, ha='center',
            color='#666', style='italic')
    
    # Right: BasisGlobalSections
    ax.add_patch(FancyBboxPatch((6.5, 2), 3.5, 5,
                                 boxstyle="round,pad=0.2",
                                 facecolor='#fce4ec', edgecolor='#E91E63', linewidth=3))
    ax.text(8.25, 6.3, 'BasisGlobalSections(P)', fontsize=13, ha='center',
            fontweight='bold', color='#880E4F')
    ax.text(8.25, 5.3, 'Locally representable', fontsize=10, ha='center',
            color='#880E4F')
    ax.text(8.25, 4.8, 'sections on', fontsize=10, ha='center', color='#880E4F')
    ax.text(8.25, 4.2, 'PrimeConSpec(P)', fontsize=14, ha='center',
            fontweight='bold', color='#880E4F')
    
    # Draw a small spectrum inside
    for i, x in enumerate([7.3, 8.0, 8.7, 9.3]):
        ax.plot(x, 3.0, 'o', color='#E91E63', markersize=8)
        ax.text(x, 2.6, f'p{i}', fontsize=8, ha='center', color='#880E4F')
    
    # Conditions
    conditions = [
        ("Injectivity", "Prime Separation", "#FF9800"),
        ("Surjectivity", "Spectral Completeness", "#9C27B0"),
    ]
    
    for i, (result, condition, color) in enumerate(conditions):
        y = 1.5 - i * 0.8
        ax.add_patch(FancyBboxPatch((1, y - 0.15), 8.5, 0.6,
                                     boxstyle="round,pad=0.05",
                                     facecolor=color, alpha=0.15, edgecolor=color, linewidth=1.5))
        ax.text(3, y + 0.15, f"{result}:", fontsize=11, fontweight='bold', color=color)
        ax.text(6, y + 0.15, f"from {condition}", fontsize=11, color=color)
    
    ax.axis('off')
    plt.tight_layout()
    plt.savefig('demos/representation_theorem.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("  Saved: demos/representation_theorem.png")


def draw_separation_principle():
    """
    Visualize the separation principle: x ≠ y ⟹ ∃ p, ¬(x ≡ y mod p).
    """
    fig, axes = plt.subplots(1, 2, figsize=(14, 5))
    fig.suptitle("Prime Separation Principle", fontsize=14, fontweight='bold')
    
    # Left panel: two elements being separated
    ax = axes[0]
    ax.set_xlim(-1, 6)
    ax.set_ylim(-0.5, 4)
    ax.set_title("If x ≠ y, some prime separates them", fontsize=11)
    
    # Elements x and y
    ax.add_patch(plt.Circle((1, 2), 0.4, facecolor='#4CAF50', edgecolor='black', linewidth=2))
    ax.text(1, 2, 'x', fontsize=16, ha='center', va='center', fontweight='bold')
    
    ax.add_patch(plt.Circle((4, 2), 0.4, facecolor='#F44336', edgecolor='black', linewidth=2))
    ax.text(4, 2, 'y', fontsize=16, ha='center', va='center', fontweight='bold')
    
    ax.annotate('≠', xy=(2.5, 2), fontsize=24, ha='center', va='center', fontweight='bold')
    
    # Arrow down to spectrum
    ax.annotate('', xy=(2.5, 0.3), xytext=(2.5, 1.3),
                arrowprops=dict(arrowstyle='->', lw=2, color='gray'))
    ax.text(3.5, 0.8, '∃ prime p:', fontsize=11, color='gray')
    
    # At prime p: different classes
    ax.add_patch(FancyBboxPatch((0.5, -0.3), 1, 0.5,
                                 boxstyle="round,pad=0.05",
                                 facecolor='#4CAF50', alpha=0.3, edgecolor='black'))
    ax.text(1, -0.05, '[x]ₚ', fontsize=12, ha='center', va='center')
    
    ax.add_patch(FancyBboxPatch((3.5, -0.3), 1, 0.5,
                                 boxstyle="round,pad=0.05",
                                 facecolor='#F44336', alpha=0.3, edgecolor='black'))
    ax.text(4, -0.05, '[y]ₚ', fontsize=12, ha='center', va='center')
    
    ax.annotate('≠', xy=(2.5, -0.05), fontsize=20, ha='center', va='center', fontweight='bold')
    
    ax.axis('off')
    
    # Right panel: the contrapositive
    ax = axes[1]
    ax.set_xlim(-1, 6)
    ax.set_ylim(-0.5, 4)
    ax.set_title("Contrapositive: agreement at all primes ⟹ equality", fontsize=11)
    
    # All primes agree
    for i, xp in enumerate([0.5, 1.5, 2.5, 3.5, 4.5]):
        y = 3
        ax.add_patch(plt.Circle((xp, y), 0.25, facecolor='#2196F3', edgecolor='black'))
        ax.text(xp, y, f'p{i}', fontsize=8, ha='center', va='center', color='white',
                fontweight='bold')
        ax.text(xp, y - 0.6, '[x]=[y]', fontsize=7, ha='center', color='#1565C0')
    
    ax.text(2.5, 1.8, '∀ p: [x]ₚ = [y]ₚ', fontsize=14, ha='center', fontweight='bold',
            color='#1565C0')
    
    ax.annotate('', xy=(2.5, 0.5), xytext=(2.5, 1.3),
                arrowprops=dict(arrowstyle='->', lw=3, color='#4CAF50'))
    ax.text(3.5, 0.9, '⟹', fontsize=20, color='#4CAF50', fontweight='bold')
    
    ax.text(2.5, 0.1, 'x = y', fontsize=20, ha='center', fontweight='bold', color='#4CAF50')
    
    ax.axis('off')
    
    plt.tight_layout()
    plt.savefig('demos/separation_principle.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("  Saved: demos/separation_principle.png")


if __name__ == "__main__":
    print("Generating visualizations...")
    draw_spectrum_BB()
    draw_representation_theorem()
    draw_separation_principle()
    print("Done!")
