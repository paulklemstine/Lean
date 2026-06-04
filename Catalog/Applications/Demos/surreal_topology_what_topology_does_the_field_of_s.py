#!/usr/bin/env python3
"""
Surreal Topology Demo: Numerical Exploration of Order Gaps and Connectedness

Demonstrates the key results:
1. The √2 Dedekind cut in ℚ (concrete order gap)
2. The "bounded ℕ" gap in non-Archimedean fields
3. Visualization of gap convergence sequences
"""

from fractions import Fraction
from typing import List, Tuple


def sqrt_two_cut(q: Fraction) -> bool:
    """Test if q is in the √2 Dedekind cut: q < 0 or (q >= 0 and q² < 2)."""
    return q < 0 or (q >= 0 and q * q < 2)


def sqrt_two_cut_no_max_witness(q: Fraction) -> Fraction:
    """Given q in the √2 cut with q >= 0, find q' > q still in the cut.
    
    Uses the formula q' = (2q + 2)/(q + 2).
    Then q'² = 4(q+1)²/(q+2)² < 2 iff 2(q+1)² < (q+2)² iff q² < 2.
    """
    if q < 0:
        return q / 2  # Closer to 0, still negative
    return (2 * q + 2) / (q + 2)


def sqrt_two_cut_no_min_witness(q: Fraction) -> Fraction:
    """Given q in the complement (q >= 0, q² >= 2), find q' < q still in complement.
    
    Uses the formula q' = (q² + 2)/(2q).
    Then q'² = (q² + 2)²/(4q²) >= 2 iff (q² + 2)² >= 8q² iff (q² - 2)² >= 0.
    """
    return (q * q + 2) / (2 * q)


def demonstrate_sqrt2_gap():
    """Demonstrate the √2 Dedekind cut gap in ℚ."""
    print("=" * 60)
    print("DEMO 1: The √2 Dedekind Gap in ℚ")
    print("=" * 60)
    print()
    
    # Starting from below
    q = Fraction(1)
    print("Approaching √2 from below (inside the cut):")
    for i in range(8):
        q_float = float(q)
        q_sq = float(q * q)
        print(f"  q = {q} ≈ {q_float:.10f}, q² = {q_sq:.10f}, in cut: {sqrt_two_cut(q)}")
        q = sqrt_two_cut_no_max_witness(q)
    
    print()
    
    # Starting from above
    q = Fraction(2)
    print("Approaching √2 from above (outside the cut):")
    for i in range(8):
        q_float = float(q)
        q_sq = float(q * q)
        print(f"  q = {q} ≈ {q_float:.10f}, q² = {q_sq:.10f}, in cut: {sqrt_two_cut(q)}")
        q = sqrt_two_cut_no_min_witness(q)
    
    print()
    print(f"  √2 ≈ {2**0.5:.10f}")
    print()
    print("Key observation: The sequences converge to √2 from both sides,")
    print("but √2 ∉ ℚ, so the gap is never filled. This disconnects ℚ.")


def demonstrate_bounded_nat_gap():
    """Demonstrate the gap created by bounded natural numbers."""
    print()
    print("=" * 60)
    print("DEMO 2: The Bounded-ℕ Gap (Non-Archimedean Field)")
    print("=" * 60)
    print()
    
    print("In a non-Archimedean field F, there exists ω > n for all n ∈ ℕ.")
    print("The set L = {x ∈ F | ∃ n, x < n} creates an order gap.")
    print()
    print("Simulating with a toy model: F = ℚ(ε) where ε is infinitesimal.")
    print()
    
    # Model: pairs (a, b) representing a + b·ω where ω is infinite
    # Order: lexicographic on (b, a) — ω dominates
    class InfElement:
        def __init__(self, real_part: Fraction, inf_part: Fraction):
            self.r = real_part
            self.i = inf_part
        
        def __repr__(self):
            if self.i == 0:
                return f"{self.r}"
            elif self.r == 0:
                return f"{self.i}·ω"
            else:
                return f"{self.r} + {self.i}·ω"
        
        def is_finite(self) -> bool:
            """Is this element bounded by some natural number?"""
            return self.i == 0 or self.i < 0
    
    examples = [
        InfElement(Fraction(0), Fraction(0)),
        InfElement(Fraction(42), Fraction(0)),
        InfElement(Fraction(1000000), Fraction(0)),
        InfElement(Fraction(0), Fraction(1)),       # ω
        InfElement(Fraction(-5), Fraction(1)),      # ω - 5
        InfElement(Fraction(0), Fraction(1, 2)),    # ω/2
        InfElement(Fraction(0), Fraction(2)),        # 2ω
    ]
    
    print("Elements and their classification:")
    for e in examples:
        side = "FINITE (in L)" if e.is_finite() else "INFINITE (in Lᶜ)"
        print(f"  {str(e):>20s}  →  {side}")
    
    print()
    print("The gap between L (finite) and Lᶜ (infinite) cannot be filled:")
    print("  - L has no maximum: if x is finite, so is x + 1")
    print("  - Lᶜ has no minimum: if x is infinite, so is x - 1")
    print("  - This gap disconnects the field!")


def demonstrate_rigidity():
    """Demonstrate the uniqueness of ℝ among ordered fields."""
    print()
    print("=" * 60)
    print("DEMO 3: Archimedean Rigidity — Why ℝ Is Unique")
    print("=" * 60)
    print()
    
    fields = [
        ("ℚ (rationals)", True, False, False, "Gap at √2 (and every irrational)"),
        ("ℝ (reals)", True, True, True, "THE unique connected ordered field"),
        ("ℚ(√2)", True, False, False, "Gap at ∛2, π, etc."),
        ("Algebraic reals", True, False, False, "Gap at π, e, etc."),
        ("Hyperreals *ℝ", False, True, False, "Gap between finite and infinite"),
        ("Surreals No", False, True, False, "Gaps at every ordinal birthday"),
        ("Levi-Civita field", False, True, False, "Gap between finite and infinite"),
        ("Laurent series ℝ((x))", False, True, False, "Gap between finite and infinite"),
    ]
    
    print(f"{'Field':<25s} {'Arch?':>6s} {'Complete?':>10s} {'Connected?':>11s}  Reason")
    print("-" * 85)
    for name, arch, complete, connected, reason in fields:
        a = "✓" if arch else "✗"
        c = "✓" if complete else "✗"
        conn = "✓" if connected else "✗"
        print(f"  {name:<23s} {a:>6s} {c:>10s} {conn:>11s}  {reason}")
    
    print()
    print("Theorem (proved): Connected → Archimedean")
    print("Theorem (classical): Archimedean + Dedekind complete ↔ ≅ ℝ")
    print("Therefore: ℝ is the UNIQUE connected ordered field.")


if __name__ == "__main__":
    demonstrate_sqrt2_gap()
    demonstrate_bounded_nat_gap()
    demonstrate_rigidity()


#!/usr/bin/env python3
"""Visualization: Topology of ordered fields — connected vs disconnected."""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as patches
import numpy as np


def draw_number_line(ax, y, label, gaps=None, color='steelblue', label_fontsize=11):
    """Draw a number line with optional gaps."""
    x_range = (-3, 3)
    
    if gaps is None:
        gaps = []
    
    # Sort gaps
    gaps = sorted(gaps)
    
    # Draw segments between gaps
    segments = []
    prev = x_range[0]
    for g in gaps:
        if prev < g - 0.02:
            segments.append((prev, g - 0.02))
        prev = g + 0.02
    if prev < x_range[1]:
        segments.append((prev, x_range[1]))
    
    for (a, b) in segments:
        ax.plot([a, b], [y, y], color=color, linewidth=4, solid_capstyle='round')
    
    # Draw gap markers
    for g in gaps:
        ax.plot(g, y, 'o', color='red', markersize=8, markerfacecolor='white',
                markeredgewidth=2, zorder=5)
    
    # Label
    ax.text(-3.8, y, label, fontsize=label_fontsize, ha='right', va='center',
            fontweight='bold')


def main():
    fig, ax = plt.subplots(1, 1, figsize=(14, 7))
    
    sqrt2 = np.sqrt(2)
    sqrt3 = np.sqrt(3)
    pi_val = np.pi - 3  # Shifted for visibility
    
    # ℝ: connected, no gaps
    draw_number_line(ax, 5, 'ℝ (reals)', gaps=[], color='#2196F3')
    ax.text(3.3, 5, '✓ Connected', fontsize=10, color='green', fontweight='bold', va='center')
    
    # ℚ: many gaps (at irrationals)
    irrational_gaps = [sqrt2 - 1.5, sqrt3 - 1.5, np.e - 2.5, 0.3, -0.7, 1.8, -1.5, 2.3]
    draw_number_line(ax, 3.5, 'ℚ (rationals)', gaps=irrational_gaps, color='#FF9800')
    ax.text(3.3, 3.5, '✗ Disconnected', fontsize=10, color='red', fontweight='bold', va='center')
    ax.annotate('√2 gap', xy=(sqrt2 - 1.5, 3.5), xytext=(sqrt2 - 1.5, 4.2),
               fontsize=8, ha='center', arrowprops=dict(arrowstyle='->', color='red'))
    
    # Hyperreals: gap at infinity boundary
    draw_number_line(ax, 2, '*ℝ (hyperreals)', gaps=[1.5], color='#9C27B0')
    ax.text(3.3, 2, '✗ Disconnected', fontsize=10, color='red', fontweight='bold', va='center')
    ax.annotate('finite/infinite\nboundary', xy=(1.5, 2), xytext=(1.5, 1.0),
               fontsize=8, ha='center', arrowprops=dict(arrowstyle='->', color='red'))
    ax.text(-1, 2.3, 'finite', fontsize=8, ha='center', color='#9C27B0', style='italic')
    ax.text(2.3, 2.3, 'infinite', fontsize=8, ha='center', color='#9C27B0', style='italic')
    
    # Surreals: many gaps
    surreal_gaps = [-2, -1, 0, 0.7, 1.5, 2.2, -0.5, 0.3]
    draw_number_line(ax, 0.5, 'No (surreals)', gaps=surreal_gaps, color='#F44336')
    ax.text(3.3, 0.5, '✗ Disconnected', fontsize=10, color='red', fontweight='bold', va='center')
    ax.text(0, -0.3, 'gaps at every ordinal birthday', fontsize=8, ha='center',
            color='#F44336', style='italic')
    
    # Title and formatting
    ax.set_title('Topology of Ordered Fields: Only ℝ Is Connected',
                fontsize=16, fontweight='bold', pad=20)
    ax.set_xlim(-4.5, 5.5)
    ax.set_ylim(-1, 6.5)
    ax.set_axis_off()
    
    # Legend box
    legend_text = (
        "Theorem: An ordered field is connected\n"
        "in its order topology iff it is Archimedean\n"
        "and Dedekind complete — i.e., iff it is ℝ."
    )
    ax.text(0, 6.2, legend_text, fontsize=10, ha='center', va='top',
            bbox=dict(boxstyle='round,pad=0.5', facecolor='lightyellow',
                     edgecolor='gray', alpha=0.9))
    
    # Gap legend
    ax.plot([], [], 'o', color='red', markersize=8, markerfacecolor='white',
            markeredgewidth=2, label='Order gap (Dedekind cut)')
    ax.legend(loc='lower right', fontsize=9)
    
    plt.tight_layout()
    plt.savefig('field_topology_comparison.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: field_topology_comparison.png")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""Visualization: The √2 Dedekind Gap in ℚ — converging sequences."""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as patches
import numpy as np
from fractions import Fraction


def lower_cut_iterate(q: Fraction) -> Fraction:
    return (2 * q + 2) / (q + 2)

def upper_cut_iterate(q: Fraction) -> Fraction:
    return (q * q + 2) / (2 * q)

def main():
    # Generate convergence sequences
    n_steps = 12
    lower = [Fraction(1)]
    upper = [Fraction(2)]
    for _ in range(n_steps):
        lower.append(lower_cut_iterate(lower[-1]))
        upper.append(upper_cut_iterate(upper[-1]))
    
    lower_f = [float(q) for q in lower]
    upper_f = [float(q) for q in upper]
    sqrt2 = np.sqrt(2)
    
    fig, axes = plt.subplots(2, 1, figsize=(12, 8), gridspec_kw={'height_ratios': [2, 1]})
    
    # Top plot: convergence to √2
    ax1 = axes[0]
    steps = list(range(len(lower_f)))
    ax1.plot(steps, lower_f, 'b.-', markersize=8, label='Lower sequence (q² < 2)', linewidth=1.5)
    ax1.plot(steps, upper_f, 'r.-', markersize=8, label='Upper sequence (q² ≥ 2)', linewidth=1.5)
    ax1.axhline(y=sqrt2, color='green', linestyle='--', linewidth=2, alpha=0.7, label=f'√2 ≈ {sqrt2:.6f}')
    
    # Shade the gap region
    ax1.fill_between(steps, lower_f, upper_f, alpha=0.15, color='purple', label='Gap (unfilled in ℚ)')
    
    ax1.set_xlabel('Iteration', fontsize=12)
    ax1.set_ylabel('Value', fontsize=12)
    ax1.set_title('The √2 Dedekind Gap: Sequences Converging to an Irrational', fontsize=14, fontweight='bold')
    ax1.legend(fontsize=10, loc='upper right')
    ax1.grid(True, alpha=0.3)
    
    # Bottom plot: gap width (log scale)
    ax2 = axes[1]
    gaps = [upper_f[i] - lower_f[i] for i in range(len(lower_f))]
    ax2.semilogy(steps, gaps, 'purple', marker='s', markersize=6, linewidth=1.5, label='Gap width')
    ax2.set_xlabel('Iteration', fontsize=12)
    ax2.set_ylabel('Gap Width (log scale)', fontsize=12)
    ax2.set_title('Quadratic Convergence: The Gap Shrinks but Never Closes in ℚ', fontsize=13)
    ax2.legend(fontsize=10)
    ax2.grid(True, alpha=0.3)
    
    # Add annotation
    ax2.annotate('Gap → 0 but √2 ∉ ℚ\n⟹ ℚ is disconnected',
                xy=(8, gaps[8]), xytext=(4, gaps[2]),
                fontsize=10, ha='center',
                arrowprops=dict(arrowstyle='->', color='purple'),
                bbox=dict(boxstyle='round,pad=0.3', facecolor='lightyellow'))
    
    plt.tight_layout()
    plt.savefig('sqrt2_gap_visualization.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: sqrt2_gap_visualization.png")


if __name__ == "__main__":
    main()
