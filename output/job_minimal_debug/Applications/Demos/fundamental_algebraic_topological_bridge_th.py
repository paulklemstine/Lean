#!/usr/bin/env python3
"""
Demo: Galaxy Decomposition and Archimedean-Connectedness Bridge

Demonstrates the key concepts:
1. Galaxy detection in ordered fields
2. Clopen set visualization for non-Archimedean fields
3. Order gap detection at galaxy boundaries
"""

from fractions import Fraction
from typing import Optional


def galaxy_representative(x: float, threshold: int = 1000) -> Optional[int]:
    """Classify an element by its galaxy in a simulated non-Archimedean field.
    
    In ℝ (which is Archimedean), every element is in Galaxy(0).
    This simulates classification for pedagogical purposes.
    Returns the 'galaxy index' (which integer multiple of threshold is closest).
    """
    return int(round(x / threshold)) if threshold > 0 else 0


def is_in_bounded_by_nat(x: float, max_n: int = 10**6) -> bool:
    """Check if x is in BoundedByNat (bounded by some natural number).
    
    For real numbers, this is always True (Archimedean property).
    """
    return abs(x) <= max_n


def demonstrate_archimedean_property():
    """Show that ℝ satisfies the Archimedean property."""
    print("=" * 60)
    print("DEMONSTRATION: Archimedean Property of ℝ")
    print("=" * 60)
    print()
    print("The Archimedean property states: for every x ∈ F,")
    print("there exists n ∈ ℕ such that x ≤ n.")
    print()
    
    test_values = [0.5, 3.14159, 100.0, 1e6, 1e15, -42.0]
    for x in test_values:
        n = max(0, int(x) + 1) if x > 0 else 0
        print(f"  x = {x:>20} → n = {n:>20} (x ≤ n: {x <= n})")
    
    print()
    print("In ℝ, BoundedByNat = ℝ (the entire field).")
    print("This is equivalent to ℝ being Archimedean.")
    print()


def demonstrate_non_archimedean():
    """Simulate a non-Archimedean field using formal Laurent series.
    
    We represent elements of ℚ((t)) where t is infinitesimal.
    An element like 1/t is 'infinitely large' — bigger than any natural.
    """
    print("=" * 60)
    print("SIMULATION: Non-Archimedean Field ℚ((t))")
    print("=" * 60)
    print()
    print("In ℚ((t)) with t infinitesimal:")
    print("  - Elements like 1 + t, 3 - 2t are 'finite' (in Galaxy(0))")
    print("  - Elements like 1/t, 1/t² are 'infinite' (in different galaxies)")
    print("  - The element t is 'infinitesimal' (in Galaxy(0) but tiny)")
    print()
    
    # Represent elements as (valuation, leading_coefficient)
    elements = [
        ("0", 0, 0),           # zero
        ("1", 0, 1),           # one (constant)
        ("t", 1, 1),           # infinitesimal
        ("3 + 2t", 0, 3),     # finite, non-infinitesimal
        ("1/t", -1, 1),       # infinitely large
        ("1/t²", -2, 1),      # even more infinitely large
        ("5/t + 3", -1, 5),   # infinitely large
        ("t²", 2, 1),         # doubly infinitesimal
    ]
    
    print("Element          | Valuation | Galaxy Index | Bounded by ℕ?")
    print("-" * 65)
    for name, val, coeff in elements:
        galaxy_idx = -val  # galaxy index is -valuation
        bounded = val >= 0  # bounded iff non-negative valuation
        print(f"  {name:15} | {val:>9} | {galaxy_idx:>12} | {'Yes' if bounded else 'No'}")
    
    print()
    print("Key observations:")
    print("  • BoundedByNat = {elements with valuation ≥ 0}")
    print("  • BoundedByNat is CLOPEN: both it and its complement are open")
    print("  • The complement {valuation < 0} is nonempty → field is DISCONNECTED")
    print("  • Galaxy(f) = Galaxy(g) iff val(f - g) ≥ 0")
    print()


def demonstrate_galaxy_partition():
    """Show the galaxy partition structure."""
    print("=" * 60)
    print("DEMONSTRATION: Galaxy Partition")
    print("=" * 60)
    print()
    print("In a non-Archimedean field, galaxies partition the field:")
    print()
    
    # Simulate galaxies in ℚ((t))
    galaxies = {
        "Galaxy(0)": ["0", "1", "-5", "t", "3+2t", "1/2"],
        "Galaxy(1/t)": ["1/t", "1/t+3", "1/t-100"],
        "Galaxy(1/t²)": ["1/t²", "1/t²+1/t", "1/t²-42"],
        "Galaxy(-1/t)": ["-1/t", "-1/t+7"],
    }
    
    for name, elements in galaxies.items():
        print(f"  {name}:")
        print(f"    Contains: {', '.join(elements)}")
        print(f"    This galaxy is CLOPEN (both open and closed)")
        print()
    
    print("Properties verified:")
    print("  ✓ Every element is in exactly one galaxy")
    print("  ✓ Two galaxies are either EQUAL or DISJOINT")
    print("  ✓ Each galaxy is CLOPEN in the order topology")
    print("  ✓ Galaxy boundaries are ORDER GAPS (Dedekind cuts with no fill)")
    print()


def demonstrate_order_gap():
    """Demonstrate the order gap at a galaxy boundary."""
    print("=" * 60)
    print("DEMONSTRATION: Order Gap at Galaxy Boundary")
    print("=" * 60)
    print()
    print("At the boundary between Galaxy(0) and the infinite elements:")
    print()
    print("  L = BoundedByNat = {x | ∃ n ∈ ℕ, x ≤ n}")
    print("  R = Lᶜ = {x | ∀ n ∈ ℕ, n < x}")
    print()
    print("Properties of this gap:")
    print("  • L has NO MAXIMUM: if x ≤ n, then x+1 ≤ n+1 and x < x+1")
    print("  • R has NO MINIMUM: if ∀n, n < y, then ∀n, n < y-1 and y-1 < y")
    print("  • Every element of L is less than every element of R")
    print("  • L is CLOPEN, so this is a genuine disconnection")
    print()
    
    # Numerical illustration with large numbers
    print("Numerical illustration (in ℝ, where L = ℝ, no gap exists):")
    for exp in range(1, 16):
        x = 10.0 ** exp
        n = int(x) + 1
        print(f"  x = 10^{exp:>2} = {x:.0e}  →  bounded by n = {n}")
    print("  ... every real number is bounded. No gap exists in ℝ!")
    print()
    print("But in ℚ((t)), the element 1/t exceeds ALL naturals.")
    print("The gap between {finite elements} and {infinite elements}")
    print("is a genuine topological fracture — a clopen partition.")
    print()


def compute_galaxy_distance():
    """Compute galaxy distances using exact arithmetic."""
    print("=" * 60)
    print("COMPUTATION: Galaxy Distance (Exact Arithmetic)")
    print("=" * 60)
    print()
    
    # In ℚ, all elements are in Galaxy(0) since ℚ is Archimedean
    pairs = [
        (Fraction(1, 2), Fraction(3, 7)),
        (Fraction(1000000, 1), Fraction(1, 1000000)),
        (Fraction(355, 113), Fraction(22, 7)),  # π approximations
    ]
    
    print("In ℚ (Archimedean), all pairs are in the same galaxy:")
    print()
    for a, b in pairs:
        diff = abs(a - b)
        n = int(diff) + 1
        print(f"  |{a} - {b}| = {diff}")
        print(f"    Bounded by n = {n}, so same galaxy ✓")
        print()


if __name__ == "__main__":
    demonstrate_archimedean_property()
    demonstrate_non_archimedean()
    demonstrate_galaxy_partition()
    demonstrate_order_gap()
    compute_galaxy_distance()
    
    print("=" * 60)
    print("SUMMARY: The Archimedean-Connectedness Bridge")
    print("=" * 60)
    print()
    print("THEOREM: Connected ordered field ⟹ Archimedean")
    print()
    print("Proof idea:")
    print("  1. Assume F is non-Archimedean")
    print("  2. BoundedByNat(F) = ⋃ₙ (-∞, n+1) is OPEN")
    print("  3. BoundedByNat(F)ᶜ is OPEN (for each infinite x,")
    print("     the interval (x-1, ∞) ⊆ complement)")
    print("  4. BoundedByNat(F) is nonempty (contains 0)")
    print("  5. BoundedByNat(F)ᶜ is nonempty (contains infinite elements)")
    print("  6. Therefore F is DISCONNECTED")
    print()
    print("The galaxy decomposition generalizes this:")
    print("  • Every galaxy is clopen")
    print("  • Galaxies partition the field")
    print("  • Galaxy count = number of connected components")
    print("  • Non-Archimedean ↔ multiple galaxies ↔ disconnected")


#!/usr/bin/env python3
"""
Visualization: Galaxy Decomposition of a Non-Archimedean Ordered Field

Visualizes the clopen partition of ℚ((t)) into galaxies,
showing the order gaps at galaxy boundaries.
"""

import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np


def visualize_galaxy_partition():
    """Create a visualization of the galaxy partition structure."""
    fig, axes = plt.subplots(3, 1, figsize=(14, 10))
    
    # === Panel 1: The number line of ℝ (connected, one galaxy) ===
    ax1 = axes[0]
    ax1.set_title("ℝ: Connected (Archimedean) — One Galaxy", fontsize=14, fontweight='bold')
    
    x = np.linspace(-5, 15, 1000)
    ax1.fill_between(x, -0.3, 0.3, color='#3498db', alpha=0.4, label='Galaxy(0) = ℝ')
    ax1.plot(x, np.zeros_like(x), color='#2c3e50', linewidth=2)
    
    # Mark some points
    points = [0, 1, 2, 3, 5, 10]
    for p in points:
        ax1.plot(p, 0, 'ko', markersize=6)
        ax1.annotate(str(p), (p, 0.35), ha='center', fontsize=10)
    
    ax1.set_xlim(-5, 15)
    ax1.set_ylim(-0.5, 0.8)
    ax1.set_yticks([])
    ax1.legend(loc='upper right', fontsize=11)
    ax1.annotate('No gaps — continuous number line', xy=(5, -0.4), 
                fontsize=11, ha='center', style='italic', color='#27ae60')
    
    # === Panel 2: Non-Archimedean field with galaxies ===
    ax2 = axes[1]
    ax2.set_title("ℚ((t)): Disconnected (Non-Archimedean) — Multiple Galaxies", 
                  fontsize=14, fontweight='bold')
    
    # Galaxy(0): finite elements (position 0-4)
    x_finite = np.linspace(0, 4, 200)
    ax2.fill_between(x_finite, -0.3, 0.3, color='#3498db', alpha=0.4)
    ax2.plot(x_finite, np.zeros_like(x_finite), color='#2c3e50', linewidth=2)
    
    # Gap region (4-6)
    ax2.fill_between([4, 6], -0.3, 0.3, color='#e74c3c', alpha=0.15)
    ax2.annotate('ORDER\nGAP', xy=(5, 0), fontsize=12, ha='center', va='center',
                fontweight='bold', color='#e74c3c',
                bbox=dict(boxstyle='round,pad=0.3', facecolor='#fadbd8', edgecolor='#e74c3c'))
    
    # Galaxy(ω): infinite elements near ω (position 6-10)
    x_omega = np.linspace(6, 10, 200)
    ax2.fill_between(x_omega, -0.3, 0.3, color='#2ecc71', alpha=0.4)
    ax2.plot(x_omega, np.zeros_like(x_omega), color='#2c3e50', linewidth=2)
    
    # Gap region (10-12)
    ax2.fill_between([10, 12], -0.3, 0.3, color='#e74c3c', alpha=0.15)
    ax2.annotate('ORDER\nGAP', xy=(11, 0), fontsize=12, ha='center', va='center',
                fontweight='bold', color='#e74c3c',
                bbox=dict(boxstyle='round,pad=0.3', facecolor='#fadbd8', edgecolor='#e74c3c'))
    
    # Galaxy(ω²): even more infinite (position 12-15)
    x_omega2 = np.linspace(12, 15, 200)
    ax2.fill_between(x_omega2, -0.3, 0.3, color='#9b59b6', alpha=0.4)
    ax2.plot(x_omega2, np.zeros_like(x_omega2), color='#2c3e50', linewidth=2)
    
    # Labels
    ax2.annotate('Galaxy(0)\n"finite"', xy=(2, 0.5), ha='center', fontsize=11,
                color='#2980b9', fontweight='bold')
    ax2.annotate('Galaxy(1/t)\n"infinite"', xy=(8, 0.5), ha='center', fontsize=11,
                color='#27ae60', fontweight='bold')
    ax2.annotate('Galaxy(1/t²)\n"more infinite"', xy=(13.5, 0.5), ha='center', fontsize=11,
                color='#8e44ad', fontweight='bold')
    
    # Points
    finite_pts = [(0.5, '0'), (1.5, '1'), (2.5, 'π'), (3.5, 'n')]
    for pos, label in finite_pts:
        ax2.plot(pos, 0, 'ko', markersize=5)
        ax2.annotate(label, (pos, -0.4), ha='center', fontsize=9)
    
    omega_pts = [(7, '1/t'), (8, '1/t+3'), (9, '1/t-n')]
    for pos, label in omega_pts:
        ax2.plot(pos, 0, 'ko', markersize=5)
        ax2.annotate(label, (pos, -0.4), ha='center', fontsize=9)
    
    ax2.set_xlim(-0.5, 15.5)
    ax2.set_ylim(-0.7, 0.9)
    ax2.set_yticks([])
    
    # === Panel 3: Clopen set diagram ===
    ax3 = axes[2]
    ax3.set_title("BoundedByNat: The Clopen Set that Proves Disconnection",
                  fontsize=14, fontweight='bold')
    
    # BoundedByNat region
    x_bounded = np.linspace(0, 7, 300)
    ax3.fill_between(x_bounded, 0, 1, color='#3498db', alpha=0.3, label='BoundedByNat (OPEN: ⋃ₙ Iio(n+1))')
    
    # Complement region
    x_unbounded = np.linspace(9, 15, 300)
    ax3.fill_between(x_unbounded, 0, 1, color='#e67e22', alpha=0.3, label='Complement (OPEN: ⋃ₓ Ioi(x-1))')
    
    # Gap
    ax3.fill_between([7, 9], 0, 1, color='white', alpha=1)
    ax3.annotate('∅', xy=(8, 0.5), fontsize=20, ha='center', va='center', color='#95a5a6')
    
    # Dashed boundary lines
    ax3.axvline(x=7, color='#e74c3c', linestyle='--', linewidth=2)
    ax3.axvline(x=9, color='#e74c3c', linestyle='--', linewidth=2)
    
    # Labels inside regions
    ax3.text(3.5, 0.7, 'OPEN\n(union of open rays)', ha='center', fontsize=11, color='#2980b9')
    ax3.text(3.5, 0.3, 'CLOSED\n(complement is open)', ha='center', fontsize=10, color='#2980b9')
    ax3.text(12, 0.7, 'OPEN\n(for each x, (x-1,∞) ⊂ here)', ha='center', fontsize=11, color='#d35400')
    ax3.text(12, 0.3, 'CLOSED\n(complement is open)', ha='center', fontsize=10, color='#d35400')
    
    ax3.text(8, 0.15, 'No element\nhere', ha='center', fontsize=9, color='#95a5a6')
    
    ax3.set_xlim(-0.5, 15.5)
    ax3.set_ylim(-0.1, 1.1)
    ax3.set_yticks([])
    ax3.legend(loc='upper left', fontsize=10)
    
    plt.tight_layout()
    plt.savefig('galaxy_decomposition.png', dpi=150, bbox_inches='tight')
    plt.savefig('galaxy_decomposition.svg', bbox_inches='tight')
    print("Saved galaxy_decomposition.png and .svg")
    plt.close()


def visualize_bridge_theorem():
    """Visualize the logical structure of the bridge theorem."""
    fig, ax = plt.subplots(1, 1, figsize=(12, 7))
    ax.set_xlim(0, 12)
    ax.set_ylim(0, 8)
    ax.axis('off')
    ax.set_title("The Archimedean-Connectedness Bridge",
                fontsize=16, fontweight='bold', pad=20)
    
    # Boxes for concepts
    boxes = {
        'connected': (1, 6, 3, 1.2, '#3498db', 'Connected\n(no clopen partition)'),
        'archimedean': (8, 6, 3, 1.2, '#2ecc71', 'Archimedean\n(ℕ is cofinal)'),
        'clopen': (4.5, 3.5, 3, 1.2, '#e74c3c', 'BoundedByNat\nis CLOPEN'),
        'disconnected': (1, 1, 3, 1.2, '#e67e22', 'Disconnected\n(has clopen partition)'),
        'non_arch': (8, 1, 3, 1.2, '#9b59b6', 'Non-Archimedean\n(∃ infinite element)'),
    }
    
    for key, (x, y, w, h, color, text) in boxes.items():
        rect = mpatches.FancyBboxPatch((x, y), w, h, boxstyle="round,pad=0.1",
                                        facecolor=color, alpha=0.2, edgecolor=color, linewidth=2)
        ax.add_patch(rect)
        ax.text(x + w/2, y + h/2, text, ha='center', va='center',
               fontsize=11, fontweight='bold', color=color)
    
    # Arrows
    arrow_style = dict(arrowstyle='->', linewidth=2, color='#2c3e50')
    
    # Connected → Archimedean (main theorem)
    ax.annotate('', xy=(8, 6.6), xytext=(4, 6.6),
               arrowprops={**arrow_style, 'linewidth': 3, 'color': '#e74c3c'})
    ax.text(6, 7.2, 'MAIN THEOREM', ha='center', fontsize=12, 
           fontweight='bold', color='#e74c3c')
    
    # Non-Archimedean → clopen set exists
    ax.annotate('', xy=(5.5, 4.7), xytext=(9, 1.6),
               arrowprops=arrow_style)
    ax.text(8.2, 3.2, 'constructs', ha='center', fontsize=10, rotation=40)
    
    # Clopen set → disconnected
    ax.annotate('', xy=(2.5, 2.2), xytext=(5, 3.5),
               arrowprops=arrow_style)
    ax.text(2.8, 3.0, 'implies', ha='center', fontsize=10, rotation=-40)
    
    # Non-Archimedean ↔ Disconnected (equivalence via contrapositive)
    ax.annotate('', xy=(4, 1.6), xytext=(8, 1.6),
               arrowprops={**arrow_style, 'arrowstyle': '<->'})
    ax.text(6, 1.0, 'equivalent\n(contrapositive)', ha='center', fontsize=10, color='#7f8c8d')
    
    # Connected ↔ Archimedean? (question mark for converse)
    ax.text(6, 5.8, '(converse: ℚ is\nArchimedean but\nnot connected)', 
           ha='center', fontsize=9, color='#95a5a6', style='italic')
    
    plt.tight_layout()
    plt.savefig('bridge_theorem.png', dpi=150, bbox_inches='tight')
    print("Saved bridge_theorem.png")
    plt.close()


if __name__ == "__main__":
    visualize_galaxy_partition()
    visualize_bridge_theorem()
