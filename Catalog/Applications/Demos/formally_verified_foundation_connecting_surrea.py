#!/usr/bin/env python3
"""
Demo: Birthday-Stratified Surreal Arithmetic

Demonstrates the Birthday–Denomination Principle, the ultrametric birthday
distance, the filtered ring structure, and the multiplication defect conjecture.
"""

from fractions import Fraction
from typing import List, Tuple


def dyadic_val(q: Fraction) -> int:
    """Compute the dyadic valuation: 2-adic valuation of the denominator."""
    d = q.denominator
    v = 0
    while d % 2 == 0:
        d //= 2
        v += 1
    return v


def is_dyadic(q: Fraction) -> bool:
    """Check if a fraction is a dyadic rational (denominator is a power of 2)."""
    d = q.denominator
    while d % 2 == 0:
        d //= 2
    return d == 1


def birthday_dist(a: Fraction, b: Fraction) -> int:
    """Compute the birthday distance: dyadic valuation of the difference."""
    return dyadic_val(a - b)


def mul_defect(a: Fraction, b: Fraction) -> int:
    """Compute the multiplication defect."""
    return dyadic_val(a) + dyadic_val(b) - dyadic_val(a * b)


def predicted_defect(a: Fraction, b: Fraction) -> int:
    """Predicted defect: min(v2(|num_a * num_b|), v2(a) + v2(b))."""
    num_prod = a.numerator * b.numerator
    v2_num = v2_int(num_prod) if num_prod != 0 else 999
    return min(v2_num, dyadic_val(a) + dyadic_val(b))


def v2_int(n: int) -> int:
    """2-adic valuation of an integer."""
    if n == 0:
        return float('inf')
    n = abs(n)
    v = 0
    while n % 2 == 0:
        n //= 2
        v += 1
    return v


def demo_birthday_denomination():
    """Demonstrate the Birthday–Denomination Principle."""
    print("=" * 60)
    print("BIRTHDAY–DENOMINATION PRINCIPLE")
    print("For dyadic q = m/2^n (reduced), birthday = n = ν₂(den)")
    print("=" * 60)
    
    examples = [
        Fraction(0), Fraction(1), Fraction(-1),
        Fraction(1, 2), Fraction(3, 4), Fraction(7, 8),
        Fraction(5, 16), Fraction(3, 2), Fraction(-7, 4),
    ]
    
    for q in examples:
        v = dyadic_val(q)
        print(f"  q = {str(q):>8s}  den = {q.denominator:>4d}  "
              f"ν₂(den) = {v}  is_dyadic = {is_dyadic(q)}")
    print()


def demo_filtration():
    """Demonstrate the birthday filtration F_n = {q : den | 2^n}."""
    print("=" * 60)
    print("BIRTHDAY FILTRATION LEVELS")
    print("F_n = {q ∈ Q : q.den | 2^n}")
    print("=" * 60)
    
    for n in range(5):
        members = []
        for num in range(-8, 9):
            for den_pow in range(n + 1):
                q = Fraction(num, 2 ** den_pow)
                if -2 <= q <= 2 and q not in members:
                    members.append(q)
        members.sort()
        compact = [str(q) for q in members]
        print(f"  F_{n} ∩ [-2,2]: {compact}")
    print()


def demo_ultrametric():
    """Demonstrate the ultrametric triangle inequality."""
    print("=" * 60)
    print("ULTRAMETRIC TRIANGLE INEQUALITY")
    print("d(a,c) ≤ max(d(a,b), d(b,c))")
    print("=" * 60)
    
    triples = [
        (Fraction(0), Fraction(1, 2), Fraction(1)),
        (Fraction(1, 4), Fraction(3, 8), Fraction(1, 2)),
        (Fraction(1, 8), Fraction(1, 4), Fraction(3, 8)),
        (Fraction(0), Fraction(1, 4), Fraction(1, 2)),
        (Fraction(3, 16), Fraction(7, 8), Fraction(5, 4)),
    ]
    
    for a, b, c in triples:
        dac = birthday_dist(a, c)
        dab = birthday_dist(a, b)
        dbc = birthday_dist(b, c)
        max_d = max(dab, dbc)
        holds = "✓" if dac <= max_d else "✗"
        print(f"  a={str(a):>5s}  b={str(b):>5s}  c={str(c):>5s}  "
              f"d(a,c)={dac}  max(d(a,b),d(b,c))={max_d}  {holds}")
    print()


def demo_filtered_ring():
    """Demonstrate the filtered ring properties."""
    print("=" * 60)
    print("FILTERED RING PROPERTIES")
    print("F_m + F_n ⊆ F_{max(m,n)}  and  F_m · F_n ⊆ F_{m+n}")
    print("=" * 60)
    
    test_pairs = [
        (Fraction(1, 2), Fraction(3, 4)),   # val 1, val 2
        (Fraction(1, 4), Fraction(1, 8)),   # val 2, val 3
        (Fraction(7, 8), Fraction(5, 16)),  # val 3, val 4
        (Fraction(1, 2), Fraction(1, 2)),   # val 1, val 1
    ]
    
    print("\n  Addition (non-Archimedean):")
    for a, b in test_pairs:
        va, vb = dyadic_val(a), dyadic_val(b)
        vs = dyadic_val(a + b)
        print(f"    {a} + {b} = {a+b}  "
              f"ν₂={vs} ≤ max({va},{vb})={max(va,vb)}  "
              f"{'✓' if vs <= max(va,vb) else '✗'}")
    
    print("\n  Multiplication (subadditive):")
    for a, b in test_pairs:
        va, vb = dyadic_val(a), dyadic_val(b)
        vp = dyadic_val(a * b)
        print(f"    {a} × {b} = {a*b}  "
              f"ν₂={vp} ≤ {va}+{vb}={va+vb}  "
              f"{'✓' if vp <= va+vb else '✗'}")
    print()


def demo_mul_defect_conjecture():
    """Test the multiplication defect conjecture."""
    print("=" * 60)
    print("MULTIPLICATION DEFECT CONJECTURE TEST")
    print("δ(a,b) = min(ν₂(|a.num · b.num|), ν₂(a) + ν₂(b))")
    print("=" * 60)
    
    # Generate all dyadic rationals with den ≤ 2^4 and |num| ≤ 20
    dyadics: List[Fraction] = []
    for den_pow in range(5):
        den = 2 ** den_pow
        for num in range(-20, 21):
            if num == 0:
                continue
            q = Fraction(num, den)
            if is_dyadic(q) and q not in dyadics:
                dyadics.append(q)
    
    total = 0
    matches = 0
    failures: List[Tuple[Fraction, Fraction]] = []
    
    for a in dyadics:
        for b in dyadics:
            total += 1
            defect = mul_defect(a, b)
            expected = predicted_defect(a, b)
            if defect == expected:
                matches += 1
            else:
                failures.append((a, b))
    
    print(f"\n  Tested {total} pairs of dyadic rationals")
    print(f"  Matches: {matches}/{total}")
    if failures:
        print(f"  FAILURES: {len(failures)}")
        for a, b in failures[:5]:
            print(f"    a={a}, b={b}: defect={mul_defect(a,b)}, "
                  f"expected={v2_int(a.numerator * b.numerator)}")
    else:
        print("  All pairs match! Conjecture holds for this range.")
    print()


def demo_growth():
    """Demonstrate exponential growth of birthday levels."""
    print("=" * 60)
    print("EXPONENTIAL GROWTH OF BIRTHDAY LEVELS")
    print("Count of dyadic rationals in [0,1] with den | 2^n")
    print("=" * 60)
    
    for n in range(8):
        count = 2 ** n + 1
        new = 1 if n == 0 else 2 ** n
        bar = "█" * (count // 2)
        print(f"  Day {n}: {count:>5d} total, {new:>4d} new  {bar}")
    print()


if __name__ == "__main__":
    demo_birthday_denomination()
    demo_filtration()
    demo_ultrametric()
    demo_filtered_ring()
    demo_mul_defect_conjecture()
    demo_growth()


#!/usr/bin/env python3
"""
Visualization: Birthday Tree of Dyadic Rationals

Shows how dyadic rationals fill in the number line level by level,
with color indicating birthday (filtration level).
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
from fractions import Fraction


def generate_dyadics_by_level(max_level: int, x_range: tuple = (-2, 2)):
    """Generate dyadic rationals grouped by their birthday level."""
    levels = {}
    seen = set()
    for level in range(max_level + 1):
        levels[level] = []
        den = 2 ** level
        # Enumerate numerators that give values in range
        min_num = int(x_range[0] * den) - 1
        max_num = int(x_range[1] * den) + 1
        for num in range(min_num, max_num + 1):
            q = Fraction(num, den)
            if q not in seen and x_range[0] <= float(q) <= x_range[1]:
                # Check this is genuinely born at this level
                if q.denominator == den or (level == 0 and q.denominator == 1):
                    levels[level].append(float(q))
                    seen.add(q)
    return levels


def plot_birthday_tree():
    """Create a visualization of the birthday tree."""
    max_level = 6
    levels = generate_dyadics_by_level(max_level, (-2, 2))
    
    colors = plt.cm.viridis([i / max_level for i in range(max_level + 1)])
    
    fig, axes = plt.subplots(2, 1, figsize=(14, 10), height_ratios=[3, 1])
    
    # Top plot: Birthday tree
    ax = axes[0]
    for level, points in levels.items():
        y = max_level - level
        ax.scatter(points, [y] * len(points), 
                   c=[colors[level]], s=max(10, 80 - 10*level),
                   zorder=5, edgecolors='black', linewidth=0.3,
                   label=f'Day {level} ({len(points)} new)')
    
    ax.set_yticks(range(max_level + 1))
    ax.set_yticklabels([f'Day {max_level - i}' for i in range(max_level + 1)])
    ax.set_xlabel('Value on the number line', fontsize=12)
    ax.set_title('Birthday Tree of Surreal Numbers (Dyadic Rationals)', fontsize=14)
    ax.legend(loc='upper left', fontsize=8, ncol=2)
    ax.grid(True, alpha=0.3)
    ax.set_xlim(-2.1, 2.1)
    
    # Bottom plot: Cumulative density
    ax2 = axes[1]
    cum_counts = []
    cum = 0
    for level in range(max_level + 1):
        cum += len(levels[level])
        cum_counts.append(cum)
    
    ax2.bar(range(max_level + 1), cum_counts, color=colors, edgecolor='black')
    ax2.set_xlabel('Birthday Level', fontsize=12)
    ax2.set_ylabel('Cumulative Count\n(in [-2, 2])', fontsize=10)
    ax2.set_title('Exponential Growth of Birthday Levels', fontsize=12)
    ax2.set_xticks(range(max_level + 1))
    
    for i, count in enumerate(cum_counts):
        ax2.text(i, count + 1, str(count), ha='center', fontsize=9)
    
    plt.tight_layout()
    plt.savefig('viz_birthday_tree.png', dpi=150, bbox_inches='tight')
    print("Saved viz_birthday_tree.png")


if __name__ == "__main__":
    plot_birthday_tree()


#!/usr/bin/env python3
"""
Visualization: Ultrametric Birthday Distance Matrix

Shows the birthday distance d(a,b) = ν₂(den(a-b)) between dyadic rationals,
revealing the ultrametric (non-Archimedean) structure.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
from fractions import Fraction


def dyadic_val(q: Fraction) -> int:
    """2-adic valuation of denominator."""
    d = q.denominator
    v = 0
    while d % 2 == 0:
        d //= 2
        v += 1
    return v


def birthday_dist(a: Fraction, b: Fraction) -> int:
    """Birthday distance."""
    return dyadic_val(a - b)


def plot_ultrametric_matrix():
    """Create an ultrametric distance matrix visualization."""
    # Generate dyadic rationals in [0, 1] with birthday ≤ 4
    points = sorted(set(
        Fraction(k, 2**n)
        for n in range(5)
        for k in range(2**n + 1)
        if 0 <= Fraction(k, 2**n) <= 1
    ))
    
    n = len(points)
    dist_matrix = np.zeros((n, n))
    
    for i in range(n):
        for j in range(n):
            dist_matrix[i, j] = birthday_dist(points[i], points[j])
    
    fig, axes = plt.subplots(1, 2, figsize=(16, 7))
    
    # Left: Distance matrix
    ax = axes[0]
    im = ax.imshow(dist_matrix, cmap='YlOrRd', aspect='equal')
    
    # Label every 4th tick for readability
    tick_step = max(1, n // 12)
    tick_positions = range(0, n, tick_step)
    tick_labels = [str(points[i]) for i in tick_positions]
    ax.set_xticks(list(tick_positions))
    ax.set_xticklabels(tick_labels, rotation=45, ha='right', fontsize=8)
    ax.set_yticks(list(tick_positions))
    ax.set_yticklabels(tick_labels, fontsize=8)
    
    plt.colorbar(im, ax=ax, label='Birthday Distance d(a,b)')
    ax.set_title('Ultrametric Distance Matrix\nd(a,b) = ν₂(den(a-b))', fontsize=13)
    
    # Right: Histogram of distances + ultrametric verification
    ax2 = axes[1]
    
    # Collect all distances
    dists = []
    for i in range(n):
        for j in range(i+1, n):
            dists.append(dist_matrix[i, j])
    
    ax2.hist(dists, bins=range(int(max(dists)) + 2), 
             color='steelblue', edgecolor='black', alpha=0.8,
             align='left')
    ax2.set_xlabel('Birthday Distance', fontsize=12)
    ax2.set_ylabel('Count of Pairs', fontsize=12)
    ax2.set_title('Distribution of Birthday Distances\n'
                  '(Ultrametric: every triangle is isosceles)', fontsize=13)
    
    # Verify ultrametric property
    violations = 0
    total = 0
    for i in range(n):
        for j in range(i+1, n):
            for k in range(j+1, n):
                total += 1
                dij = dist_matrix[i, j]
                djk = dist_matrix[j, k]
                dik = dist_matrix[i, k]
                if dik > max(dij, djk):
                    violations += 1
    
    ax2.text(0.95, 0.95, 
             f'Ultrametric check:\n{total} triples tested\n{violations} violations',
             transform=ax2.transAxes, ha='right', va='top',
             fontsize=11, bbox=dict(boxstyle='round', facecolor='lightgreen', alpha=0.8))
    
    plt.tight_layout()
    plt.savefig('viz_ultrametric.png', dpi=150, bbox_inches='tight')
    print("Saved viz_ultrametric.png")


if __name__ == "__main__":
    plot_ultrametric_matrix()
