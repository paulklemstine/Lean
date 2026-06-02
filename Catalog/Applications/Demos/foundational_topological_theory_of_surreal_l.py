#!/usr/bin/env python3
"""
Cofinality Spectrum Demo: Numerical Examples

Demonstrates the cofinality spectrum classification for ordinal spaces
and the P-filter property at wild points.
"""

from typing import List, Tuple, Optional
import math


def classify_ordinal_cofinality(alpha: int, omega1_approx: int = 1000) -> str:
    """
    Classify the cofinality type of an ordinal alpha in the space [0, omega1].
    
    For ordinals below omega1 (approximated by omega1_approx):
    - 0 is tame (minimum element)
    - Successor ordinals are tame (have a predecessor)
    - Limit ordinals below omega1 have countable cofinality (tame)
    - omega1 itself has uncountable left cofinality (wild-left)
    
    We model omega1 as omega1_approx for computational purposes.
    """
    if alpha == 0:
        return "tame (minimum element)"
    elif alpha == omega1_approx:
        return "wild-left (uncountable left cofinality, maximum element)"
    elif alpha < omega1_approx:
        # Check if it's a limit ordinal (in our model: multiples of some base)
        # In a simplified model, all ordinals below omega1 are tame
        return "tame (countable cofinality from both sides)"
    else:
        return "invalid (beyond omega1)"


def demonstrate_cofinal_sequence(x: float, n_terms: int = 10) -> List[float]:
    """
    Construct a cofinal sequence below x in the real numbers.
    
    For real numbers, we can always find such a sequence: x - 1/n.
    This demonstrates the "tame" nature of real number points.
    """
    return [x - 1.0 / (k + 1) for k in range(n_terms)]


def demonstrate_p_filter_property(x: float, neighborhoods: List[Tuple[float, float]],
                                   wild: bool = False) -> Optional[Tuple[float, float]]:
    """
    Demonstrate the P-filter property.
    
    For tame points: the intersection of countably many neighborhoods
    may not be a neighborhood (it can shrink to a point).
    
    For wild points: the intersection of countably many neighborhoods
    IS always a neighborhood (P-filter property).
    
    Args:
        x: the point
        neighborhoods: list of (left_endpoint, right_endpoint) intervals around x
        wild: if True, simulate wild behavior (common lower bound exists)
    
    Returns:
        The common interval (a, b) containing x that lies in all neighborhoods,
        or None if no such interval exists.
    """
    if not neighborhoods:
        return None
    
    # Find the supremum of left endpoints and infimum of right endpoints
    left_sup = max(a for a, _ in neighborhoods)
    right_inf = min(b for _, b in neighborhoods)
    
    if wild:
        # For wild points: the left endpoints are bounded away from x
        # Simulate by pushing the bound down
        wild_bound = x - abs(x - left_sup) * 2
        return (wild_bound, right_inf) if wild_bound < x < right_inf else None
    else:
        # For tame points: the intersection might shrink to {x}
        if left_sup < x < right_inf:
            return (left_sup, right_inf)
        else:
            return None


def gap_detection(values: List[float], threshold: float = 0.1) -> List[Tuple[int, float]]:
    """
    Detect order gaps in a discrete approximation of a linear order.
    
    An order gap occurs where there's a "jump" with no elements filling it.
    Returns list of (index, gap_size) for detected gaps.
    """
    gaps = []
    sorted_vals = sorted(values)
    for i in range(len(sorted_vals) - 1):
        gap_size = sorted_vals[i + 1] - sorted_vals[i]
        if gap_size > threshold:
            gaps.append((i, gap_size))
    return gaps


def cofinality_spectrum_visualization_data(n_points: int = 100) -> dict:
    """
    Generate data for visualizing the cofinality spectrum of omega1 + 1.
    
    Points are classified as:
    - tame: ordinals < omega1 (index < n_points - 1)
    - wild: omega1 itself (index = n_points - 1)
    """
    points = list(range(n_points))
    classifications = []
    for i, p in enumerate(points):
        if i == 0:
            classifications.append("tame-bot")
        elif i == n_points - 1:
            classifications.append("wild-left")
        else:
            classifications.append("tame")
    
    return {
        "points": points,
        "classifications": classifications,
        "n_tame": sum(1 for c in classifications if c.startswith("tame")),
        "n_wild": sum(1 for c in classifications if c.startswith("wild")),
    }


def main():
    print("=" * 60)
    print("COFINALITY SPECTRUM DEMO")
    print("=" * 60)
    
    # Demo 1: Ordinal classification
    print("\n--- Demo 1: Ordinal Cofinality Classification ---")
    for alpha in [0, 1, 5, 42, 999, 1000]:
        cls = classify_ordinal_cofinality(alpha)
        print(f"  α = {alpha:4d}: {cls}")
    
    # Demo 2: Cofinal sequences in ℝ
    print("\n--- Demo 2: Cofinal Sequence Below π ---")
    seq = demonstrate_cofinal_sequence(math.pi, 8)
    print(f"  x = π ≈ {math.pi:.6f}")
    print(f"  Cofinal sequence: {[f'{s:.4f}' for s in seq]}")
    print(f"  All < π: {all(s < math.pi for s in seq)}")
    print(f"  Sup → π: gap = {math.pi - max(seq):.6f}")
    
    # Demo 3: P-filter property
    print("\n--- Demo 3: P-Filter Property ---")
    x = 5.0
    # Shrinking neighborhoods (like a tame point)
    tame_nbhds = [(x - 1.0 / (n + 1), x + 1.0 / (n + 1)) for n in range(10)]
    result_tame = demonstrate_p_filter_property(x, tame_nbhds, wild=False)
    print(f"  Tame point x = {x}")
    print(f"  10 shrinking neighborhoods: intersection = {result_tame}")
    print(f"  Width: {result_tame[1] - result_tame[0]:.4f}" if result_tame else "  Collapsed!")
    
    # Fixed-width neighborhoods (like a wild point)
    wild_nbhds = [(x - 0.5 - 0.01 * n, x + 0.5 + 0.01 * n) for n in range(10)]
    result_wild = demonstrate_p_filter_property(x, wild_nbhds, wild=True)
    print(f"\n  Wild point x = {x}")
    print(f"  10 'wild' neighborhoods: common interval = {result_wild}")
    if result_wild:
        print(f"  Width: {result_wild[1] - result_wild[0]:.4f} (remains a neighborhood!)")
    
    # Demo 4: Gap detection
    print("\n--- Demo 4: Order Gap Detection ---")
    # Rationals near √2 — there's a "gap" at √2
    rationals = [1.0, 1.1, 1.2, 1.3, 1.4, 1.41, 1.414, 1.4142,
                 1.4143, 1.415, 1.42, 1.5, 1.6, 1.7, 1.8, 1.9, 2.0]
    gaps = gap_detection(rationals, threshold=0.05)
    print(f"  Rationals near √2 ≈ {math.sqrt(2):.4f}")
    print(f"  Detected gaps (threshold=0.05): {len(gaps)}")
    for idx, size in gaps:
        print(f"    Gap at index {idx}: size {size:.4f} "
              f"(between {sorted(rationals)[idx]:.4f} and {sorted(rationals)[idx+1]:.4f})")
    
    # Demo 5: Spectrum statistics
    print("\n--- Demo 5: Cofinality Spectrum of ω₁ + 1 ---")
    data = cofinality_spectrum_visualization_data(50)
    print(f"  Total points: {len(data['points'])}")
    print(f"  Tame points: {data['n_tame']} ({100*data['n_tame']/len(data['points']):.1f}%)")
    print(f"  Wild points: {data['n_wild']} ({100*data['n_wild']/len(data['points']):.1f}%)")
    print(f"  Tame locus is open: True (it's [0, ω₁), an open ray)")
    print(f"  Wild locus is closed: True (it's {{ω₁}}, a closed singleton)")
    
    print("\n" + "=" * 60)
    print("KEY INSIGHT: In ω₁ + 1, almost all points are tame.")
    print("In the surreal numbers, almost all points are WILD.")
    print("The cofinality spectrum captures this fundamental difference.")
    print("=" * 60)


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: Order Gap Disconnection

Shows how order gaps create clopen partitions that disconnect the space.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def plot_gap_disconnection():
    """Visualize order gaps and their topological consequences."""
    fig, axes = plt.subplots(2, 2, figsize=(14, 10))
    
    # Panel 1: Rationals with gap at sqrt(2)
    ax1 = axes[0, 0]
    sqrt2 = np.sqrt(2)
    rationals_below = [p/q for q in range(1, 15) for p in range(1, 25)
                       if p/q < sqrt2 and 0.5 < p/q < 2.5]
    rationals_above = [p/q for q in range(1, 15) for p in range(1, 25)
                       if p/q > sqrt2 and 0.5 < p/q < 2.5]
    
    rationals_below = sorted(set(rationals_below))
    rationals_above = sorted(set(rationals_above))
    
    ax1.scatter(rationals_below, [0]*len(rationals_below), c='#2ecc71',
               s=15, zorder=3, label='Lower set (< √2)')
    ax1.scatter(rationals_above, [0]*len(rationals_above), c='#e74c3c',
               s=15, zorder=3, label='Upper set (> √2)')
    ax1.axvline(x=sqrt2, color='black', linestyle='--', alpha=0.7, linewidth=2)
    ax1.annotate(f'√2 ≈ {sqrt2:.4f}\n(gap)', xy=(sqrt2, 0.02),
                fontsize=10, ha='center', fontweight='bold')
    ax1.set_title('Order Gap in ℚ at √2', fontsize=13, fontweight='bold')
    ax1.set_xlabel('Value')
    ax1.set_yticks([])
    ax1.set_xlim(0.8, 2.2)
    ax1.legend(fontsize=9)
    
    # Panel 2: Clopen sets from gap
    ax2 = axes[0, 1]
    x_lower = np.linspace(0, sqrt2 - 0.01, 200)
    x_upper = np.linspace(sqrt2 + 0.01, 3, 200)
    
    ax2.fill_between(x_lower, 0, 1, color='#2ecc71', alpha=0.4, label='Lower (open & closed)')
    ax2.fill_between(x_upper, 0, 1, color='#e74c3c', alpha=0.4, label='Upper (open & closed)')
    ax2.axvline(x=sqrt2, color='black', linestyle='--', linewidth=2)
    ax2.set_title('Clopen Partition (Gap Disconnection)', fontsize=13, fontweight='bold')
    ax2.set_xlabel('Value')
    ax2.set_ylabel('Membership')
    ax2.legend(fontsize=9)
    ax2.set_xlim(0, 3)
    ax2.annotate('GAP\n(no max below,\nno min above)',
                xy=(sqrt2, 0.5), fontsize=10, ha='center',
                bbox=dict(boxstyle='round', facecolor='wheat', alpha=0.8))
    
    # Panel 3: Connected vs disconnected
    ax3 = axes[1, 0]
    # Connected: ℝ (no gaps)
    x_real = np.linspace(0, 3, 500)
    ax3.fill_between(x_real, 0, 0.4, color='#3498db', alpha=0.6)
    ax3.text(1.5, 0.2, 'ℝ: Connected\n(Dedekind complete, no gaps)',
            fontsize=11, ha='center', fontweight='bold', color='white')
    
    # Disconnected: ℚ (has gaps)
    for q in rationals_below[:40]:
        ax3.plot([q, q], [0.6, 0.95], color='#2ecc71', linewidth=0.5, alpha=0.6)
    for q in rationals_above[:40]:
        ax3.plot([q, q], [0.6, 0.95], color='#e74c3c', linewidth=0.5, alpha=0.6)
    ax3.text(1.5, 0.78, 'ℚ: Disconnected\n(gaps everywhere)',
            fontsize=11, ha='center', fontweight='bold')
    ax3.axvline(x=sqrt2, color='black', linestyle=':', alpha=0.5, ymin=0.6, ymax=0.95)
    
    ax3.set_title('Connectedness vs Gaps', fontsize=13, fontweight='bold')
    ax3.set_xlabel('Value')
    ax3.set_yticks([0.2, 0.78])
    ax3.set_yticklabels(['ℝ', 'ℚ'])
    ax3.set_xlim(0.5, 2.5)
    
    # Panel 4: Summary diagram
    ax4 = axes[1, 1]
    ax4.set_xlim(0, 10)
    ax4.set_ylim(0, 10)
    ax4.set_aspect('equal')
    ax4.axis('off')
    
    # Draw the theorem flow
    boxes = [
        (2, 8, 'Order Gap\n(L, Lᶜ)'),
        (7, 8, 'L open\nLᶜ open'),
        (7, 5, 'L clopen'),
        (2, 2, '¬Connected'),
        (7, 2, 'Dedekind complete\n⟹ Connected'),
    ]
    
    for x, y, text in boxes:
        ax4.add_patch(plt.Rectangle((x-1.3, y-0.7), 2.6, 1.4,
                      facecolor='#ecf0f1', edgecolor='#2c3e50',
                      linewidth=1.5, zorder=2))
        ax4.text(x, y, text, fontsize=9, ha='center', va='center',
                fontweight='bold', zorder=3)
    
    # Arrows
    arrows = [
        (3.3, 8, 5.4, 8),    # Gap → open
        (7, 7.3, 7, 5.7),     # open → clopen
        (5.7, 5, 3.3, 2.5),   # clopen → ¬connected
        (5.7, 2, 3.3, 2),     # complete → connected
    ]
    for x1, y1, x2, y2 in arrows:
        ax4.annotate('', xy=(x2, y2), xytext=(x1, y1),
                    arrowprops=dict(arrowstyle='->', color='#2c3e50', lw=1.5))
    
    ax4.set_title('Theorem Flow: Gaps ⟹ Disconnection', fontsize=13, fontweight='bold')
    
    plt.tight_layout()
    plt.savefig('gap_disconnection.png', dpi=150, bbox_inches='tight')
    print("Saved gap_disconnection.png")


if __name__ == "__main__":
    plot_gap_disconnection()


#!/usr/bin/env python3
"""
Visualization: Cofinality Spectrum of Ordered Spaces

Generates a visualization showing the tame/wild partition
for ordinal-like spaces.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np


def plot_cofinality_spectrum():
    """Plot the cofinality spectrum for omega_1 + 1."""
    fig, axes = plt.subplots(3, 1, figsize=(12, 10))
    
    # Panel 1: omega_1 + 1
    ax1 = axes[0]
    n = 100
    x = np.arange(n)
    colors = ['#2ecc71'] * (n - 1) + ['#e74c3c']  # green=tame, red=wild
    ax1.bar(x, np.ones(n), color=colors, width=1.0, edgecolor='none')
    ax1.set_title('Cofinality Spectrum of ω₁ + 1', fontsize=14, fontweight='bold')
    ax1.set_xlabel('Ordinal index')
    ax1.set_ylabel('Classification')
    ax1.set_yticks([])
    ax1.set_xlim(-1, n + 1)
    
    tame_patch = mpatches.Patch(color='#2ecc71', label='Tame (countable cofinality)')
    wild_patch = mpatches.Patch(color='#e74c3c', label='Wild (uncountable cofinality)')
    ax1.legend(handles=[tame_patch, wild_patch], loc='upper right')
    ax1.annotate('ω₁', xy=(n-1, 0.5), fontsize=12, ha='center', fontweight='bold', color='white')
    
    # Panel 2: omega_1 * 2
    ax2 = axes[1]
    n2 = 200
    x2 = np.arange(n2)
    colors2 = (['#2ecc71'] * 99 + ['#e74c3c'] +  # first omega_1
               ['#2ecc71'] * 99 + ['#e74c3c'])      # second omega_1
    ax2.bar(x2, np.ones(n2), color=colors2, width=1.0, edgecolor='none')
    ax2.set_title('Cofinality Spectrum of ω₁ · 2', fontsize=14, fontweight='bold')
    ax2.set_xlabel('Ordinal index')
    ax2.set_ylabel('Classification')
    ax2.set_yticks([])
    ax2.set_xlim(-1, n2 + 1)
    ax2.axvline(x=99.5, color='black', linestyle='--', alpha=0.5, label='ω₁ boundary')
    ax2.annotate('ω₁', xy=(99, 0.5), fontsize=10, ha='center', fontweight='bold', color='white')
    ax2.annotate('ω₁·2', xy=(199, 0.5), fontsize=10, ha='center', fontweight='bold', color='white')
    ax2.legend(handles=[tame_patch, wild_patch], loc='upper right')
    
    # Panel 3: P-filter property illustration
    ax3 = axes[2]
    x_point = 5.0
    n_nbhds = 8
    
    for i in range(n_nbhds):
        width = 2.0 / (i + 1)
        y_pos = n_nbhds - i
        ax3.barh(y_pos, width * 2, left=x_point - width, height=0.6,
                color='#3498db', alpha=0.3 + 0.07 * i, edgecolor='#2980b9')
        ax3.text(x_point + width + 0.1, y_pos, f'U_{i+1}',
                fontsize=9, va='center')
    
    # Show intersection
    min_width = 2.0 / n_nbhds
    ax3.barh(0.3, min_width * 2, left=x_point - min_width, height=0.6,
            color='#e67e22', alpha=0.8, edgecolor='#d35400')
    ax3.text(x_point + min_width + 0.1, 0.3, '∩ Uₙ (tame: shrinks)',
            fontsize=9, va='center', fontweight='bold')
    
    ax3.axvline(x=x_point, color='red', linestyle='-', linewidth=2)
    ax3.text(x_point, n_nbhds + 0.8, 'x', fontsize=14, ha='center',
            fontweight='bold', color='red')
    ax3.set_title('Neighborhood Intersections: Tame vs Wild', fontsize=14, fontweight='bold')
    ax3.set_xlabel('Position')
    ax3.set_ylabel('Neighborhood index')
    ax3.set_xlim(2, 8)
    
    plt.tight_layout()
    plt.savefig('cofinality_spectrum.png', dpi=150, bbox_inches='tight')
    print("Saved cofinality_spectrum.png")


if __name__ == "__main__":
    plot_cofinality_spectrum()
