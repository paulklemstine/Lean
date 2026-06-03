#!/usr/bin/env python3
"""
Crystallographic Groups and Music: Demonstrations

This module demonstrates the key mathematical results connecting
wallpaper groups to periodic rhythm patterns.
"""

import math
from typing import List, Tuple, Dict

# --- Rhythm Representations ---

def create_rhythm(pattern: List[int]) -> List[int]:
    """Create a periodic rhythm from a pattern of 0s and 1s."""
    return pattern

def is_palindromic(rhythm: List[int]) -> bool:
    """Check if a rhythm is palindromic (time-reversal symmetric)."""
    n = len(rhythm)
    return all(rhythm[i] == rhythm[n - 1 - i] for i in range(n))

def reflect_rhythm(rhythm: List[int]) -> List[int]:
    """Reflect a rhythm (time reversal)."""
    return list(reversed(rhythm))

def cyclic_shift(rhythm: List[int], d: int) -> List[int]:
    """Shift a rhythm cyclically by d positions."""
    n = len(rhythm)
    return [rhythm[(i + d) % n] for i in range(n)]

# --- Drum Pattern Symmetry Analysis ---

def create_drum_pattern(grid: List[List[int]]) -> List[List[int]]:
    """Create a drum pattern from a 2D grid (time x pitch)."""
    return grid

def has_time_mirror(grid: List[List[int]]) -> bool:
    """Check if a drum pattern has time-mirror symmetry."""
    T = len(grid)
    if T == 0:
        return True
    P = len(grid[0])
    return all(
        grid[T - 1 - t][p] == grid[t][p]
        for t in range(T) for p in range(P)
    )

def has_pitch_mirror(grid: List[List[int]]) -> bool:
    """Check if a drum pattern has pitch-mirror symmetry."""
    T = len(grid)
    if T == 0:
        return True
    P = len(grid[0])
    return all(
        grid[t][P - 1 - p] == grid[t][p]
        for t in range(T) for p in range(P)
    )

def has_rotation2(grid: List[List[int]]) -> bool:
    """Check if a drum pattern has 2-fold rotational symmetry."""
    T = len(grid)
    if T == 0:
        return True
    P = len(grid[0])
    return all(
        grid[T - 1 - t][P - 1 - p] == grid[t][p]
        for t in range(T) for p in range(P)
    )

def has_glide_reflection(grid: List[List[int]], half_t: int) -> bool:
    """Check if a drum pattern has glide reflection symmetry."""
    T = len(grid)
    if T == 0:
        return True
    P = len(grid[0])
    return all(
        grid[(t + half_t) % T][P - 1 - p] == grid[t][p]
        for t in range(T) for p in range(P)
    )

# --- Wallpaper Type Classification ---

WALLPAPER_TYPES = [
    "p1", "p2", "pm", "pg", "cm", "pmm", "pmg", "pgg", "cmm",
    "p4", "p4m", "p4g", "p3", "p3m1", "p31m", "p6", "p6m"
]

MUSICAL_NAMES = {
    "p1": "Free rhythm", "p2": "Call-and-response",
    "pm": "Palindrome", "pg": "Canon", "cm": "Round",
    "pmm": "Bilateral palindrome", "pmg": "Inverted canon",
    "pgg": "Double canon", "cmm": "Round + palindrome",
    "p4": "4-bar cycle", "p4m": "Variations on a theme",
    "p4g": "Inverted variations", "p3": "3-bar blues",
    "p3m1": "3-fold + mirrors", "p31m": "3-fold + glides",
    "p6": "Whole-tone symmetry", "p6m": "Maximal symmetry"
}

ROTATION_ORDERS = {
    "p1": 1, "p2": 2, "pm": 1, "pg": 1, "cm": 1,
    "pmm": 2, "pmg": 2, "pgg": 2, "cmm": 2,
    "p4": 4, "p4m": 4, "p4g": 4,
    "p3": 3, "p3m1": 3, "p31m": 3,
    "p6": 6, "p6m": 6
}

def classify_simple(grid: List[List[int]]) -> str:
    """Simplified wallpaper type classification based on detected symmetries."""
    tm = has_time_mirror(grid)
    pm = has_pitch_mirror(grid)
    r2 = has_rotation2(grid)
    T = len(grid)
    gl = has_glide_reflection(grid, T // 2) if T >= 2 else False

    if tm and pm:
        return "pmm"
    elif tm and gl:
        return "pmg"
    elif r2 and gl:
        return "pgg"
    elif tm or pm:
        return "pm"
    elif gl:
        return "pg"
    elif r2:
        return "p2"
    else:
        return "p1"

# --- Burnside Counting ---

def count_necklaces(n: int) -> int:
    """Count distinct binary necklaces of length n using Burnside's lemma."""
    total = sum(2 ** math.gcd(d, n) for d in range(n))
    return total // n

def count_palindromic_necklaces(n: int) -> int:
    """Count palindromic binary necklaces of length n."""
    count = 0
    for pat_int in range(2**n):
        pat = [(pat_int >> i) & 1 for i in range(n)]
        if is_palindromic(pat):
            # Check if this is the lexicographically smallest rotation
            is_canonical = True
            for d in range(1, n):
                shifted = cyclic_shift(pat, d)
                if shifted < pat:
                    is_canonical = False
                    break
            if is_canonical:
                count += 1
    return count

def fixed_point_count(n: int, d: int) -> int:
    """Number of binary patterns of length n fixed by d-rotation = 2^gcd(d,n)."""
    return 2 ** math.gcd(d, n)

# --- Demonstrations ---

def demo_palindrome_parity():
    """Demonstrate the palindrome center parity theorem."""
    print("=" * 60)
    print("PALINDROME CENTER PARITY THEOREM")
    print("For palindromic rhythms of odd length 2k+1:")
    print("  weight mod 2 = center beat")
    print("=" * 60)

    for k in range(1, 5):
        n = 2 * k + 1
        print(f"\nLength {n} (k={k}):")
        count_verified = 0
        count_total = 0
        for pat_int in range(2**n):
            pat = [(pat_int >> i) & 1 for i in range(n)]
            if is_palindromic(pat):
                count_total += 1
                weight = sum(pat)
                center = pat[k]
                expected = 1 if center else 0
                if weight % 2 == expected:
                    count_verified += 1
                else:
                    print(f"  COUNTEREXAMPLE: {pat}, weight={weight}, center={center}")
        print(f"  Verified {count_verified}/{count_total} palindromic rhythms ✓")

def demo_double_mirror():
    """Demonstrate that double mirror implies rotation."""
    print("\n" + "=" * 60)
    print("DOUBLE MIRROR ⟹ ROTATION THEOREM")
    print("If a pattern has time-mirror AND pitch-mirror,")
    print("then it has 2-fold rotational symmetry.")
    print("=" * 60)

    # Test exhaustively for small grids
    for T in range(2, 5):
        for P in range(2, 5):
            counterexamples = 0
            total_both_mirror = 0
            for pat_int in range(2 ** (T * P)):
                grid = [[(pat_int >> (t * P + p)) & 1
                         for p in range(P)] for t in range(T)]
                if has_time_mirror(grid) and has_pitch_mirror(grid):
                    total_both_mirror += 1
                    if not has_rotation2(grid):
                        counterexamples += 1
            print(f"  Grid {T}×{P}: {total_both_mirror} patterns with both mirrors, "
                  f"{counterexamples} counterexamples {'✓' if counterexamples == 0 else '✗'}")

def demo_necklace_counting():
    """Demonstrate Burnside's necklace counting."""
    print("\n" + "=" * 60)
    print("BURNSIDE NECKLACE COUNTING")
    print("Distinct binary rhythms up to cyclic equivalence")
    print("=" * 60)

    print(f"\n{'Length':>6} | {'Necklaces':>10} | {'Formula check':>15}")
    print("-" * 40)
    for n in range(1, 17):
        count = count_necklaces(n)
        # Verify with Euler's formula
        euler_count = sum(
            euler_phi(d) * (2 ** (n // d))
            for d in range(1, n + 1) if n % d == 0
        ) // n
        status = "✓" if count == euler_count else "✗"
        print(f"{n:>6} | {count:>10} | {euler_count:>10}    {status}")

def demo_fixed_points():
    """Demonstrate fixed point count = 2^gcd(d,n)."""
    print("\n" + "=" * 60)
    print("FIXED POINT COUNT: |Fix(σ^d)| = 2^gcd(d,n)")
    print("=" * 60)

    for n in [4, 6, 8]:
        print(f"\nLength n = {n}:")
        for d in range(n):
            predicted = fixed_point_count(n, d)
            # Verify by enumeration
            actual = 0
            for pat_int in range(2**n):
                pat = [(pat_int >> i) & 1 for i in range(n)]
                shifted = cyclic_shift(pat, d)
                if shifted == pat:
                    actual += 1
            status = "✓" if predicted == actual else "✗"
            print(f"  d={d}: predicted 2^gcd({d},{n}) = 2^{math.gcd(d,n)} = {predicted}, "
                  f"actual = {actual} {status}")

def demo_wallpaper_classification():
    """Demonstrate wallpaper type classification of drum patterns."""
    print("\n" + "=" * 60)
    print("WALLPAPER TYPE CLASSIFICATION")
    print("=" * 60)

    examples = {
        "Free rhythm (p1)": [[1,0,0,0], [0,1,0,0], [0,0,1,0], [0,0,0,1]],
        "Palindrome (pm)": [[1,0,1,0], [0,1,1,0], [0,1,1,0], [1,0,1,0]],
        "Call-response (p2)": [[1,0,0,0], [0,0,1,0], [0,1,0,0], [0,0,0,1]],
        "Double mirror (pmm)": [[1,0,0,1], [0,1,1,0], [0,1,1,0], [1,0,0,1]],
    }

    for name, grid in examples.items():
        wtype = classify_simple(grid)
        print(f"\n  {name}:")
        for row in grid:
            print(f"    {''.join('█' if x else '·' for x in row)}")
        print(f"    → Classified as: {wtype} ({MUSICAL_NAMES[wtype]})")

def demo_crystallographic_restriction():
    """Demonstrate the crystallographic restriction."""
    print("\n" + "=" * 60)
    print("CRYSTALLOGRAPHIC RESTRICTION")
    print("Rotation orders in wallpaper groups ∈ {1, 2, 3, 4, 6}")
    print("=" * 60)

    for wtype in WALLPAPER_TYPES:
        rot = ROTATION_ORDERS[wtype]
        print(f"  {wtype:>5}: rotation order {rot} "
              f"{'✓' if rot in {1,2,3,4,6} else '✗'}")

    print(f"\n  Note: order 5 is IMPOSSIBLE (crystallographic restriction)")

def euler_phi(n: int) -> int:
    """Euler's totient function."""
    count = 0
    for k in range(1, n + 1):
        if math.gcd(k, n) == 1:
            count += 1
    return count


if __name__ == "__main__":
    demo_palindrome_parity()
    demo_double_mirror()
    demo_necklace_counting()
    demo_fixed_points()
    demo_wallpaper_classification()
    demo_crystallographic_restriction()
    print("\n" + "=" * 60)
    print("ALL DEMONSTRATIONS COMPLETE")
    print("=" * 60)


#!/usr/bin/env python3
"""
Visualization: Wallpaper Group Symmetry Lattice and Rhythm Properties

Generates a visualization of the 17 wallpaper groups organized by
symmetry level, with color coding for rotation order and markers
for mirror/glide presence.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np

def create_wallpaper_lattice():
    """Create a visualization of the wallpaper group hierarchy."""
    fig, axes = plt.subplots(1, 2, figsize=(16, 8))

    # --- Left panel: Symmetry lattice ---
    ax = axes[0]
    ax.set_title("Wallpaper Group Symmetry Lattice", fontsize=14, fontweight='bold')

    # Positions for each type (x, y)
    positions = {
        'p1': (3, 0),
        'p2': (1, 1), 'pm': (3, 1), 'pg': (5, 1),
        'cm': (0, 2), 'pmm': (2, 2), 'pmg': (4, 2), 'pgg': (6, 2),
        'cmm': (1, 3), 'p4': (3, 3), 'p3': (5, 3),
        'p4m': (1, 4), 'p4g': (3, 4), 'p3m1': (5, 4), 'p31m': (7, 4),
        'p6': (3, 5),
        'p6m': (3, 6),
    }

    rotation_orders = {
        'p1': 1, 'p2': 2, 'pm': 1, 'pg': 1, 'cm': 1,
        'pmm': 2, 'pmg': 2, 'pgg': 2, 'cmm': 2,
        'p4': 4, 'p4m': 4, 'p4g': 4,
        'p3': 3, 'p3m1': 3, 'p31m': 3,
        'p6': 6, 'p6m': 6
    }

    has_mirror = {
        'pm', 'cm', 'pmm', 'pmg', 'cmm', 'p4m', 'p4g', 'p3m1', 'p31m', 'p6m'
    }
    has_glide = {
        'pg', 'cm', 'pmg', 'pgg', 'cmm', 'p4g', 'p31m', 'p6m'
    }

    musical = {
        'p1': 'Free rhythm', 'p2': 'Call & response',
        'pm': 'Palindrome', 'pg': 'Canon', 'cm': 'Round',
        'pmm': 'Bilateral palindrome', 'pmg': 'Inverted canon',
        'pgg': 'Double canon', 'cmm': 'Round+palindrome',
        'p4': '4-bar cycle', 'p4m': 'Variations',
        'p4g': 'Inv. variations', 'p3': '3-bar blues',
        'p3m1': '3+mirrors', 'p31m': '3+glides',
        'p6': 'Whole-tone', 'p6m': 'Maximal'
    }

    rot_colors = {1: '#3498db', 2: '#2ecc71', 3: '#e74c3c', 4: '#9b59b6', 6: '#f39c12'}

    # Draw edges (containment)
    edges = [
        ('p1', 'p2'), ('p1', 'pm'), ('p1', 'pg'),
        ('p2', 'pmm'), ('p2', 'pgg'), ('p2', 'pmg'),
        ('pm', 'pmm'), ('pm', 'cm'),
        ('pg', 'pgg'), ('pg', 'cm'), ('pg', 'pmg'),
        ('pmm', 'cmm'), ('pgg', 'cmm'),
        ('cmm', 'p6'), ('p4', 'p4m'), ('p4', 'p4g'),
        ('p3', 'p3m1'), ('p3', 'p31m'),
        ('p4m', 'p6m'), ('p3m1', 'p6m'), ('p31m', 'p6m'),
        ('p6', 'p6m'),
    ]

    for e1, e2 in edges:
        x1, y1 = positions[e1]
        x2, y2 = positions[e2]
        ax.plot([x1, x2], [y1, y2], 'k-', alpha=0.3, linewidth=1)

    for name, (x, y) in positions.items():
        rot = rotation_orders[name]
        color = rot_colors[rot]
        marker = 's' if name in has_mirror else ('D' if name in has_glide else 'o')
        size = 200 + rot * 50

        ax.scatter(x, y, c=color, s=size, marker=marker, zorder=5,
                  edgecolors='black', linewidth=1.5)
        ax.annotate(name, (x, y), textcoords="offset points",
                   xytext=(0, 15), ha='center', fontsize=10, fontweight='bold')

    # Legend
    for rot, color in rot_colors.items():
        ax.scatter([], [], c=color, s=100, label=f'Rotation order {rot}')
    ax.scatter([], [], c='gray', s=100, marker='s', label='Has mirror')
    ax.scatter([], [], c='gray', s=100, marker='D', label='Has glide')
    ax.scatter([], [], c='gray', s=100, marker='o', label='Neither')
    ax.legend(loc='lower left', fontsize=8)
    ax.set_xlim(-1, 8)
    ax.set_ylim(-0.5, 7)
    ax.set_ylabel("Symmetry Level", fontsize=12)
    ax.set_xticks([])

    # --- Right panel: Musical names ---
    ax2 = axes[1]
    ax2.set_title("Musical Interpretations", fontsize=14, fontweight='bold')
    ax2.axis('off')

    y_pos = 0.95
    for name in ['p6m', 'p6', 'p4m', 'p4g', 'p3m1', 'p31m', 'p4', 'p3',
                  'cmm', 'pmm', 'pmg', 'pgg', 'cm', 'pm', 'pg', 'p2', 'p1']:
        rot = rotation_orders[name]
        color = rot_colors[rot]
        mirror_str = "M" if name in has_mirror else " "
        glide_str = "G" if name in has_glide else " "
        text = f"{name:>5}  rot={rot}  [{mirror_str}{glide_str}]  {musical[name]}"
        ax2.text(0.05, y_pos, text, transform=ax2.transAxes,
                fontsize=10, fontfamily='monospace',
                color=color, fontweight='bold',
                bbox=dict(boxstyle='round,pad=0.3', facecolor=color, alpha=0.1))
        y_pos -= 0.055

    plt.tight_layout()
    plt.savefig('wallpaper_lattice.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved wallpaper_lattice.png")


def create_palindrome_parity_plot():
    """Visualize the palindrome center parity theorem."""
    fig, ax = plt.subplots(figsize=(10, 6))
    ax.set_title("Palindrome Parity Theorem: Weight Distribution", fontsize=14, fontweight='bold')

    for k_idx, k in enumerate([2, 3, 4, 5]):
        n = 2 * k + 1
        weights_center0 = []
        weights_center1 = []

        for bits in range(2**k):
            wing = [(bits >> i) & 1 for i in range(k)]
            # center = 0
            weight0 = 2 * sum(wing)
            weights_center0.append(weight0)
            # center = 1
            weight1 = 2 * sum(wing) + 1
            weights_center1.append(weight1)

        max_w = n
        bins = np.arange(-0.5, max_w + 1.5, 1)
        offset = k_idx * 0.15

        ax.hist(weights_center0, bins=bins, alpha=0.5, color='blue',
               label=f'n={n}, center=0 (even weight)' if k_idx == 0 else None,
               density=True, bottom=offset * 3)
        ax.hist(weights_center1, bins=bins, alpha=0.5, color='red',
               label=f'n={n}, center=1 (odd weight)' if k_idx == 0 else None,
               density=True, bottom=offset * 3)

    ax.set_xlabel("Weight (number of onsets)", fontsize=12)
    ax.set_ylabel("Density + offset", fontsize=12)
    ax.legend()
    ax.set_xlim(-0.5, 12)

    plt.tight_layout()
    plt.savefig('palindrome_parity.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved palindrome_parity.png")


if __name__ == "__main__":
    create_wallpaper_lattice()
    create_palindrome_parity_plot()
