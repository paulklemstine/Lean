#!/usr/bin/env python3
"""
Demo: p-adic Langlands Correspondence for GL₂(ℚ_p)
Numerical examples illustrating slope theory, weak admissibility,
and trianguline classification.
"""

from fractions import Fraction
from typing import Tuple, List, Optional

# ============================================================
# Rank 2 Slope Data
# ============================================================

class Rank2Slopes:
    """Slope data for a rank 2 Frobenius module: (s₁, s₂) with s₁ ≤ s₂."""

    def __init__(self, s1: Fraction, s2: Fraction):
        if s1 > s2:
            raise ValueError(f"Slopes must be ordered: {s1} > {s2}")
        self.s1 = s1
        self.s2 = s2

    def total_slope(self) -> Fraction:
        return self.s1 + self.s2

    def slope_gap(self) -> Fraction:
        return self.s2 - self.s1

    def is_etale(self) -> bool:
        return self.s1 == 0 and self.s2 == 0

    def is_ordinary(self) -> bool:
        return self.s1 == 0

    def is_supersingular(self) -> bool:
        return self.s1 == self.s2

    def dual(self) -> 'Rank2Slopes':
        return Rank2Slopes(-self.s2, -self.s1)

    def twist(self, t: Fraction) -> 'Rank2Slopes':
        return Rank2Slopes(self.s1 + t, self.s2 + t)

    def __repr__(self):
        return f"Rank2Slopes({self.s1}, {self.s2})"

    def __eq__(self, other):
        return self.s1 == other.s1 and self.s2 == other.s2

# ============================================================
# Weak Admissibility
# ============================================================

class Rank2WA:
    """Weakly admissible filtered φ-module data for rank 2."""

    def __init__(self, slopes: Rank2Slopes, ht1: int, ht2: int):
        if ht1 > ht2:
            raise ValueError("HT weights must be ordered")
        total_ht = Fraction(ht1 + ht2)
        if slopes.total_slope() != total_ht:
            raise ValueError(f"Total mismatch: {slopes.total_slope()} ≠ {total_ht}")
        if slopes.s1 < Fraction(ht1):
            raise ValueError(f"Subobject violation: {slopes.s1} < {ht1}")
        self.slopes = slopes
        self.ht1 = ht1
        self.ht2 = ht2

    def dual(self) -> 'Rank2WA':
        return Rank2WA(self.slopes.dual(), -self.ht2, -self.ht1)

    def twist(self, n: int) -> 'Rank2WA':
        return Rank2WA(self.slopes.twist(Fraction(n)), self.ht1 + n, self.ht2 + n)

    def __repr__(self):
        return (f"Rank2WA(slopes={self.slopes}, "
                f"HT=[{self.ht1},{self.ht2}])")

# ============================================================
# Trianguline Parameters
# ============================================================

class TriangulineParam:
    """Trianguline parameter: (δ₁_slope, δ₂_slope)."""

    def __init__(self, d1: Fraction, d2: Fraction):
        self.d1 = d1
        self.d2 = d2

    def to_slopes(self) -> Rank2Slopes:
        return Rank2Slopes(min(self.d1, self.d2), max(self.d1, self.d2))

    def refine(self) -> 'TriangulineParam':
        return TriangulineParam(self.d2, self.d1)

    def twist(self, t: Fraction) -> 'TriangulineParam':
        return TriangulineParam(self.d1 + t, self.d2 + t)

    def __repr__(self):
        return f"TriangulineParam({self.d1}, {self.d2})"

# ============================================================
# Breuil-Mézard Multiplicities
# ============================================================

def crystalline_multiplicity(k: int, a: int) -> int:
    """Conjectured multiplicity of crystalline lifts with slope a in weight k."""
    if a <= (k - 1) // 2:
        return max(0, k - 1 - 2 * a)
    return 0

# ============================================================
# Demonstrations
# ============================================================

def demo_slope_theory():
    """Demonstrate slope theory: duality, twisting, invariants."""
    print("=" * 60)
    print("DEMO 1: Rank 2 Slope Theory")
    print("=" * 60)

    # Ordinary case: elliptic curve with good ordinary reduction
    s_ord = Rank2Slopes(Fraction(0), Fraction(1))
    print(f"\nOrdinary slopes: {s_ord}")
    print(f"  Total slope: {s_ord.total_slope()}")
    print(f"  Slope gap: {s_ord.slope_gap()}")
    print(f"  Is ordinary: {s_ord.is_ordinary()}")
    print(f"  Is supersingular: {s_ord.is_supersingular()}")

    # Supersingular case
    s_ss = Rank2Slopes(Fraction(1, 2), Fraction(1, 2))
    print(f"\nSupersingular slopes: {s_ss}")
    print(f"  Total slope: {s_ss.total_slope()}")
    print(f"  Slope gap: {s_ss.slope_gap()}")
    print(f"  Is supersingular: {s_ss.is_supersingular()}")

    # Duality
    s_dual = s_ord.dual()
    print(f"\nDual of ordinary: {s_dual}")
    print(f"  Dual of dual: {s_dual.dual()} (= original: {s_dual.dual() == s_ord})")
    print(f"  Total slope negates: {s_dual.total_slope()} = -{s_ord.total_slope()}")
    print(f"  Slope gap preserved: {s_dual.slope_gap()} = {s_ord.slope_gap()}")

    # Twisting
    t = Fraction(3)
    s_tw = s_ord.twist(t)
    print(f"\nTwist by {t}: {s_tw}")
    print(f"  Total shifts by 2t: {s_tw.total_slope()} = {s_ord.total_slope()} + {2*t}")
    print(f"  Gap preserved: {s_tw.slope_gap()} = {s_ord.slope_gap()}")

    # Duality-twist interaction
    print(f"\n  dual(twist(t)) = {s_ord.twist(t).dual()}")
    print(f"  twist(-t)(dual) = {s_ord.dual().twist(-t)}")
    print(f"  Equal: {s_ord.twist(t).dual() == s_ord.dual().twist(-t)}")

def demo_weak_admissibility():
    """Demonstrate weak admissibility for weight 2 and weight 12."""
    print("\n" + "=" * 60)
    print("DEMO 2: Weak Admissibility")
    print("=" * 60)

    # Weight 2: elliptic curves
    print("\n--- Weight 2 (Elliptic Curves) ---")
    for a_num in range(3):
        s1 = Fraction(a_num, 2)
        s2 = Fraction(1) - s1
        if s1 <= s2:
            slopes = Rank2Slopes(s1, s2)
            try:
                wa = Rank2WA(slopes, 0, 1)
                print(f"  Slopes ({s1}, {s2}): WA ✓  gap={slopes.slope_gap()}")
                print(f"    Dual: {wa.dual()}")
            except ValueError as e:
                print(f"  Slopes ({s1}, {s2}): WA ✗  ({e})")

    # Weight 12: Ramanujan's Δ function
    print("\n--- Weight 12 (Ramanujan Δ) ---")
    for a in range(6):
        s1 = Fraction(a)
        s2 = Fraction(11 - a)
        slopes = Rank2Slopes(s1, s2)
        wa = Rank2WA(slopes, 0, 11)
        mult = crystalline_multiplicity(12, a)
        print(f"  Slopes ({s1}, {s2}): gap={slopes.slope_gap()}, "
              f"BM multiplicity={mult}")

    # Newton above Hodge
    print("\n--- Newton above Hodge Inequality ---")
    wa = Rank2WA(Rank2Slopes(Fraction(2), Fraction(9)), 0, 11)
    print(f"  Slopes: ({wa.slopes.s1}, {wa.slopes.s2})")
    print(f"  Slope gap: {wa.slopes.slope_gap()} ≤ HT gap: {wa.ht2 - wa.ht1} ✓")

def demo_trianguline():
    """Demonstrate trianguline classification."""
    print("\n" + "=" * 60)
    print("DEMO 3: Trianguline Classification")
    print("=" * 60)

    # Various trianguline parameters
    params = [
        TriangulineParam(Fraction(0), Fraction(1)),
        TriangulineParam(Fraction(1, 2), Fraction(1, 2)),
        TriangulineParam(Fraction(1, 3), Fraction(2, 3)),
        TriangulineParam(Fraction(-1), Fraction(2)),
    ]

    for tau in params:
        s = tau.to_slopes()
        print(f"\n  τ = {tau}")
        print(f"    Slopes: {s}")
        print(f"    Total: {s.total_slope()}, Gap: {s.slope_gap()}")
        print(f"    Ordinary: {s.is_ordinary()}, SS: {s.is_supersingular()}")
        print(f"    Refined: {tau.refine()} → same slopes: "
              f"{tau.refine().to_slopes() == s}")

def demo_breuil_mezard():
    """Demonstrate Breuil-Mézard multiplicities."""
    print("\n" + "=" * 60)
    print("DEMO 4: Breuil-Mézard Multiplicities")
    print("=" * 60)

    for k in [2, 4, 6, 8, 10, 12]:
        mults = [crystalline_multiplicity(k, a)
                 for a in range((k - 1) // 2 + 1)]
        total = sum(mults)
        print(f"  Weight {k:2d}: multiplicities = {mults}, "
              f"total = {total}")

    # Testable prediction
    print("\n  Conjecture check for k=12:")
    expected = [11, 9, 7, 5, 3, 1]
    actual = [crystalline_multiplicity(12, a) for a in range(6)]
    print(f"    Expected: {expected}")
    print(f"    Actual:   {actual}")
    print(f"    Match: {expected == actual}")

if __name__ == "__main__":
    demo_slope_theory()
    demo_weak_admissibility()
    demo_trianguline()
    demo_breuil_mezard()
    print("\n" + "=" * 60)
    print("All demonstrations completed successfully.")
    print("=" * 60)


#!/usr/bin/env python3
"""
Visualization: Newton and Hodge Polygons for the p-adic Langlands Correspondence.
Shows how the Newton polygon (from Frobenius slopes) lies above the Hodge polygon
(from Hodge-Tate weights) for weakly admissible filtered φ-modules.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np
from fractions import Fraction


def newton_polygon_vertices(s1: float, s2: float):
    """Newton polygon vertices for rank 2 with slopes (s1, s2)."""
    return [(0, 0), (1, s1), (2, s1 + s2)]


def hodge_polygon_vertices(h1: float, h2: float):
    """Hodge polygon vertices for rank 2 with HT weights (h1, h2)."""
    return [(0, 0), (1, h1), (2, h1 + h2)]


def plot_polygons(ax, s1, s2, h1, h2, title=""):
    """Plot Newton and Hodge polygons on given axes."""
    newton = newton_polygon_vertices(s1, s2)
    hodge = hodge_polygon_vertices(h1, h2)

    nx, ny = zip(*newton)
    hx, hy = zip(*hodge)

    # Shade region between
    ax.fill_between(
        [0, 1, 2],
        [ny[0], ny[1], ny[2]],
        [hy[0], hy[1], hy[2]],
        alpha=0.15, color='blue', label='Newton ≥ Hodge'
    )

    ax.plot(nx, ny, 'b-o', linewidth=2, markersize=8, label='Newton polygon', zorder=5)
    ax.plot(hx, hy, 'r--s', linewidth=2, markersize=8, label='Hodge polygon', zorder=5)

    # Annotate slopes
    mid_n = ((nx[0]+nx[1])/2, (ny[0]+ny[1])/2)
    mid_n2 = ((nx[1]+nx[2])/2, (ny[1]+ny[2])/2)
    ax.annotate(f's₁={s1}', mid_n, textcoords="offset points",
                xytext=(15, 5), fontsize=10, color='blue')
    ax.annotate(f's₂={s2}', mid_n2, textcoords="offset points",
                xytext=(15, 5), fontsize=10, color='blue')

    ax.set_xlabel('Rank', fontsize=12)
    ax.set_ylabel('Valuation', fontsize=12)
    ax.set_title(title, fontsize=13, fontweight='bold')
    ax.legend(fontsize=9)
    ax.grid(True, alpha=0.3)
    ax.set_xticks([0, 1, 2])


def main():
    fig, axes = plt.subplots(2, 3, figsize=(16, 10))
    fig.suptitle('Newton vs Hodge Polygons in the p-adic Langlands Correspondence',
                 fontsize=15, fontweight='bold', y=0.98)

    # Weight 2 examples (elliptic curves)
    plot_polygons(axes[0, 0], 0, 1, 0, 1,
                  'Weight 2: Ordinary\n(slopes 0, 1)')
    plot_polygons(axes[0, 1], 0.5, 0.5, 0, 1,
                  'Weight 2: Supersingular\n(slopes 1/2, 1/2)')

    # Weight 12 examples (Ramanujan Δ)
    plot_polygons(axes[0, 2], 0, 11, 0, 11,
                  'Weight 12: Ordinary\n(slopes 0, 11)')
    plot_polygons(axes[1, 0], 3, 8, 0, 11,
                  'Weight 12: Intermediate\n(slopes 3, 8)')
    plot_polygons(axes[1, 1], 5.5, 5.5, 0, 11,
                  'Weight 12: Supersingular\n(slopes 11/2, 11/2)')

    # Duality example
    plot_polygons(axes[1, 2], -1, 0, -1, 0,
                  'Dual of Ordinary\n(slopes -1, 0)')

    plt.tight_layout(rect=[0, 0, 1, 0.95])
    plt.savefig('viz_newton_hodge.png', dpi=150, bbox_inches='tight')
    print("Saved viz_newton_hodge.png")


if __name__ == "__main__":
    main()
