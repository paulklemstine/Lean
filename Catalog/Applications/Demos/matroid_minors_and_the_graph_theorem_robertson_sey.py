#!/usr/bin/env python3
"""
Matroid Minor Theory: Obstruction Spectrum Demo

Demonstrates the key concepts from the formalized theory:
1. Obstruction spectra for known minor-closed graph classes
2. Spectral duality pairs for self-dual classes
3. Growth-bounded obstruction systems
"""

from typing import Dict, List, Tuple
import math


class ObstructionSpectrum:
    """The obstruction spectrum for a minor-closed matroid class.
    
    Maps each rank r to the number of excluded minors of rank r.
    """
    def __init__(self, spectrum: Dict[int, int], total: int):
        self.spectrum = spectrum
        self.total = total
        self.max_rank = max((r for r, c in spectrum.items() if c > 0), default=0)
        self.width = sum(1 for c in spectrum.values() if c > 0)
    
    def __repr__(self):
        entries = [f"  rank {r}: {c} excluded minor(s)" 
                   for r, c in sorted(self.spectrum.items()) if c > 0]
        return (f"ObstructionSpectrum(total={self.total}, "
                f"max_rank={self.max_rank}, width={self.width})\n" + 
                "\n".join(entries))


class SpectralDualityPair:
    """Captures the duality relationship between primal and dual spectra."""
    def __init__(self, primal: ObstructionSpectrum, dual: ObstructionSpectrum, 
                 max_ground_rank: int):
        self.primal = primal
        self.dual = dual
        self.max_ground_rank = max_ground_rank
    
    def is_palindromic(self) -> bool:
        """Check if the spectrum is palindromic (self-dual class)."""
        for r in range(self.max_ground_rank + 1):
            p = self.primal.spectrum.get(r, 0)
            d = self.dual.spectrum.get(self.max_ground_rank - r, 0)
            if p != d:
                return False
        return True


def planar_graphs_spectrum() -> ObstructionSpectrum:
    """Obstruction spectrum for planar graphs.
    
    By the Kuratowski/Wagner theorem, the excluded minors are K_5 (rank 4)
    and K_{3,3} (rank 3). Both are rank-3 graphic matroids (cycle matroid).
    K_5 has cycle matroid of rank 4, K_{3,3} has cycle matroid of rank 4.
    """
    spectrum = {3: 0, 4: 2}  # K_5 and K_{3,3} both have matroid rank 4
    return ObstructionSpectrum(spectrum, total=2)


def outerplanar_spectrum() -> ObstructionSpectrum:
    """Obstruction spectrum for outerplanar graphs.
    
    Excluded minors: K_4 (rank 3) and K_{2,3} (rank 3).
    """
    spectrum = {3: 2}
    return ObstructionSpectrum(spectrum, total=2)


def series_parallel_spectrum() -> ObstructionSpectrum:
    """Obstruction spectrum for series-parallel graphs.
    
    Single excluded minor: K_4 (rank 3).
    """
    spectrum = {3: 1}
    return ObstructionSpectrum(spectrum, total=1)


def binary_matroids_spectrum() -> ObstructionSpectrum:
    """Obstruction spectrum for binary (GF(2)-representable) matroids.
    
    The unique excluded minor is U_{2,4} (uniform matroid of rank 2 on 4 elements).
    This is a classical result of Tutte.
    """
    spectrum = {2: 1}
    return ObstructionSpectrum(spectrum, total=1)


def ternary_matroids_spectrum() -> ObstructionSpectrum:
    """Obstruction spectrum for ternary (GF(3)-representable) matroids.
    
    Known excluded minors:
    - U_{2,5} (rank 2)
    - U_{3,5} (rank 3, dual of U_{2,5})
    - F_7 (Fano matroid, rank 3)
    - F_7* (dual Fano, rank 4)
    Total: 4 known excluded minors. Conjectured to be complete.
    """
    spectrum = {2: 1, 3: 2, 4: 1}
    return ObstructionSpectrum(spectrum, total=4)


def gf4_matroids_spectrum() -> ObstructionSpectrum:
    """Obstruction spectrum for GF(4)-representable matroids.
    
    Known excluded minors include U_{2,6}, U_{4,6}, P_6, and others.
    Geelen, Gerards, and Kapoor (2000) proved there are exactly 7.
    """
    spectrum = {2: 1, 3: 3, 4: 2, 5: 1}
    return ObstructionSpectrum(spectrum, total=7)


def growth_rate_bound(q: int, r: int) -> int:
    """Growth rate bound for GF(q)-representable matroids.
    
    The maximum number of elements in a rank-r simple GF(q)-representable matroid
    is (q^r - 1)/(q - 1), the number of points in PG(r-1, q).
    """
    if q <= 1 or r <= 0:
        return 0
    return (q**r - 1) // (q - 1)


def demonstrate_hierarchy():
    """Demonstrate the Robertson-Seymour matroid hierarchy."""
    print("=" * 70)
    print("Robertson-Seymour Matroid Hierarchy: Obstruction Spectra")
    print("=" * 70)
    
    spectra = [
        ("Series-parallel graphs", series_parallel_spectrum()),
        ("Outerplanar graphs", outerplanar_spectrum()),
        ("Planar graphs", planar_graphs_spectrum()),
        ("Binary matroids (GF(2))", binary_matroids_spectrum()),
        ("Ternary matroids (GF(3))", ternary_matroids_spectrum()),
        ("GF(4)-representable", gf4_matroids_spectrum()),
    ]
    
    for name, spec in spectra:
        print(f"\n--- {name} ---")
        print(spec)
        print(f"  Width/Total ratio: {spec.width}/{spec.total} = {spec.width/max(spec.total,1):.2f}")
    
    print("\n" + "=" * 70)
    print("Growth Rate Bounds (max elements for rank-r simple matroid)")
    print("=" * 70)
    
    for q in [2, 3, 4, 5, 7]:
        print(f"\nGF({q})-representable:")
        for r in range(1, 7):
            bound = growth_rate_bound(q, r)
            print(f"  rank {r}: ≤ {bound} elements")


def demonstrate_duality():
    """Demonstrate spectral duality for ternary matroids."""
    print("\n" + "=" * 70)
    print("Spectral Duality: Ternary Matroids")
    print("=" * 70)
    
    # Ternary matroid spectrum
    primal = ternary_matroids_spectrum()
    # Dual: U_{2,5}* = U_{3,5}, F_7* is already in the list
    # The dual spectrum reflects ranks around the maximum ground rank
    # For ternary: rank 2 ↔ rank 4 (dual of U_{2,5} is U_{3,5} at rank 3)
    dual_spectrum = {2: 1, 3: 2, 4: 1}  # Same! Ternary is nearly self-dual
    dual = ObstructionSpectrum(dual_spectrum, total=4)
    
    pair = SpectralDualityPair(primal, dual, max_ground_rank=5)
    print(f"\nPrimal spectrum: {dict(sorted(primal.spectrum.items()))}")
    print(f"Dual spectrum:   {dict(sorted(dual.spectrum.items()))}")
    print(f"Is palindromic (self-dual): {pair.is_palindromic()}")
    print(f"Total preserved: {primal.total == dual.total}")


def demonstrate_wqo_antichain():
    """Demonstrate the WQO ↔ finite antichains connection."""
    print("\n" + "=" * 70)
    print("WQO and Antichains: The Core Theorem")
    print("=" * 70)
    
    print("""
Theorem (Formalized): For a matroid minor system S,
  WQO(S, ≤_minor) ⟹ ∀ minor-closed P, |ExcludedMinors(P)| < ∞

Conversely:
  (∀ minor-closed P, |ExcludedMinors(P)| < ∞) ⟹ No infinite antichains

Known instances:
  - Graphs (Robertson-Seymour, 2004): WQO ✓
  - Binary matroids (GF(2)): Equivalent to graphs, WQO ✓
  - Ternary matroids (GF(3)): OPEN (conjectured WQO)
  - GF(4)-representable: OPEN (conjectured WQO)
  - General matroids: WQO FAILS (infinite antichains exist)
""")
    
    # Demonstrate the antichain obstruction for general matroids
    print("Example of infinite antichain in general matroids:")
    print("  The family {U_{2,n} : n ≥ 4} forms an infinite antichain.")
    print("  U_{2,n} is NOT a minor of U_{2,m} for n > m (rank 2 uniform matroids).")
    print("  This shows general matroids are NOT WQO under minors.")


if __name__ == "__main__":
    demonstrate_hierarchy()
    demonstrate_duality()
    demonstrate_wqo_antichain()
    
    print("\n" + "=" * 70)
    print("Key Results Formalized in Lean 4")
    print("=" * 70)
    print("""
1. excluded_minors_antichain: Excluded minors form an antichain
2. contains_excluded_minor: Every non-member contains an excluded minor
3. wqo_implies_finite_excluded_minors_set: WQO → finite excluded minors
4. finite_excluded_minors_implies_no_infinite_antichain: Converse direction
5. exists_of_wqo: WQO → every class has an obstruction spectrum
6. total_ge_width: Width ≤ Total (spectrum density bound)
7. dual_excluded_minors: Duality preserves excluded minor structure
8. self_dual_palindromic: Self-dual classes have palindromic spectra
9. palindromic_center: Center symmetry for odd-rank palindromic spectra
10. bot_excluded_minors_characterization: Minimal elements characterization
""")


#!/usr/bin/env python3
"""
Visualization: Obstruction Spectra for Minor-Closed Matroid Classes

Generates bar charts showing the obstruction spectrum for various
well-known minor-closed classes, illustrating the growth pattern
as field size increases.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def plot_obstruction_spectra():
    """Plot obstruction spectra for known minor-closed classes."""
    fig, axes = plt.subplots(2, 3, figsize=(15, 10))
    fig.suptitle('Obstruction Spectra for Minor-Closed Matroid Classes', 
                 fontsize=16, fontweight='bold')
    
    classes = [
        ("Series-Parallel\n(1 excl. minor)", {3: 1}, '#2ecc71'),
        ("Outerplanar\n(2 excl. minors)", {3: 2}, '#3498db'),
        ("Planar Graphs\n(2 excl. minors)", {4: 2}, '#e74c3c'),
        ("Binary GF(2)\n(1 excl. minor)", {2: 1}, '#9b59b6'),
        ("Ternary GF(3)\n(4 excl. minors)", {2: 1, 3: 2, 4: 1}, '#f39c12'),
        ("GF(4)-representable\n(7 excl. minors)", {2: 1, 3: 3, 4: 2, 5: 1}, '#1abc9c'),
    ]
    
    for idx, (name, spectrum, color) in enumerate(classes):
        ax = axes[idx // 3][idx % 3]
        max_rank = max(spectrum.keys(), default=0)
        ranks = list(range(max_rank + 2))
        counts = [spectrum.get(r, 0) for r in ranks]
        
        bars = ax.bar(ranks, counts, color=color, alpha=0.8, edgecolor='white', linewidth=1.5)
        ax.set_title(name, fontsize=11, fontweight='bold')
        ax.set_xlabel('Rank', fontsize=10)
        ax.set_ylabel('# Excluded Minors', fontsize=10)
        ax.set_xticks(ranks)
        ax.set_ylim(0, max(counts) + 1)
        ax.grid(axis='y', alpha=0.3)
        
        # Annotate bars
        for bar, count in zip(bars, counts):
            if count > 0:
                ax.text(bar.get_x() + bar.get_width()/2., bar.get_height() + 0.1,
                       str(count), ha='center', va='bottom', fontweight='bold', fontsize=12)
    
    plt.tight_layout()
    plt.savefig('obstruction_spectra.png', dpi=150, bbox_inches='tight')
    print("Saved: obstruction_spectra.png")


def plot_growth_rates():
    """Plot growth rate functions for different finite fields."""
    fig, ax = plt.subplots(figsize=(10, 7))
    
    ranks = np.arange(1, 8)
    
    for q, color, label in [(2, '#e74c3c', 'GF(2) — Graphs'), 
                             (3, '#3498db', 'GF(3) — Ternary'),
                             (4, '#2ecc71', 'GF(4)'),
                             (5, '#f39c12', 'GF(5)'),
                             (7, '#9b59b6', 'GF(7)')]:
        growth = [(q**r - 1) // (q - 1) for r in ranks]
        ax.plot(ranks, growth, 'o-', color=color, label=label, 
                linewidth=2, markersize=8)
    
    ax.set_xlabel('Rank r', fontsize=13)
    ax.set_ylabel('Max elements in rank-r simple matroid', fontsize=13)
    ax.set_title('Growth Rate Functions for GF(q)-Representable Matroids', 
                fontsize=14, fontweight='bold')
    ax.legend(fontsize=11)
    ax.set_yscale('log')
    ax.grid(True, alpha=0.3)
    
    plt.tight_layout()
    plt.savefig('growth_rates.png', dpi=150, bbox_inches='tight')
    print("Saved: growth_rates.png")


def plot_hierarchy():
    """Plot the hierarchy of matroid classes."""
    fig, ax = plt.subplots(figsize=(10, 8))
    
    # Hierarchy levels (field size, total excluded minors, label)
    levels = [
        (2, 1, 'GF(2)\n(Binary)'),
        (3, 4, 'GF(3)\n(Ternary)'),
        (4, 7, 'GF(4)'),
        (5, '?', 'GF(5)'),
        (7, '?', 'GF(7)'),
    ]
    
    # Draw hierarchy
    y_positions = [4, 3, 2, 1, 0]
    x_center = 0.5
    
    for i, (q, total, label) in enumerate(levels):
        y = y_positions[i]
        width = 0.3 + 0.05 * q
        
        color = '#3498db' if isinstance(total, int) else '#bdc3c7'
        rect = plt.Rectangle((x_center - width/2, y - 0.3), width, 0.6,
                             facecolor=color, edgecolor='black', 
                             linewidth=2, alpha=0.7)
        ax.add_patch(rect)
        
        total_str = str(total) if isinstance(total, int) else '?'
        ax.text(x_center, y, f'{label}\nExcl. minors: {total_str}',
               ha='center', va='center', fontsize=11, fontweight='bold')
        
        # Draw arrow to next level
        if i < len(levels) - 1:
            ax.annotate('', xy=(x_center, y_positions[i+1] + 0.35),
                       xytext=(x_center, y - 0.35),
                       arrowprops=dict(arrowstyle='->', color='gray', lw=2))
    
    # Add Robertson-Seymour annotation
    ax.text(x_center + 0.35, 4, '← Robertson-Seymour\n    (PROVED)', 
           fontsize=10, color='green', fontweight='bold')
    ax.text(x_center + 0.35, 2.5, '← GGW Conjecture\n    (OPEN)', 
           fontsize=10, color='red', fontweight='bold')
    
    ax.set_xlim(-0.2, 1.2)
    ax.set_ylim(-0.8, 5)
    ax.set_title('Robertson-Seymour Matroid Hierarchy', fontsize=14, fontweight='bold')
    ax.axis('off')
    
    plt.tight_layout()
    plt.savefig('hierarchy.png', dpi=150, bbox_inches='tight')
    print("Saved: hierarchy.png")


if __name__ == "__main__":
    plot_obstruction_spectra()
    plot_growth_rates()
    plot_hierarchy()
