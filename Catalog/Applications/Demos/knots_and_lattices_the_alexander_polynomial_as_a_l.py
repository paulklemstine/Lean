#!/usr/bin/env python3
"""
Applications of Knot Lattice Theory
=====================================

Demonstrates real-world applications of the connection between
lattice paths and knot invariants.
"""

from itertools import combinations
from math import comb
from typing import List, Tuple, Dict, Set


def compute_path_area(path: List[bool], h: int = 0) -> int:
    """Area under lattice path starting from height h."""
    area = 0
    for step in path:
        if step:
            area += h
        else:
            h += 1
    return area


def complement(path: List[bool]) -> List[bool]:
    return [not s for s in path]


def all_lattice_paths(m: int, n: int) -> List[List[bool]]:
    paths = []
    for east_pos in combinations(range(m + n), m):
        p = [False] * (m + n)
        for pos in east_pos:
            p[pos] = True
        paths.append(p)
    return paths


def path_visits(path: List[bool], point: Tuple[int, int]) -> bool:
    x, y = 0, 0
    if (x, y) == point:
        return True
    for step in path:
        if step:
            x += 1
        else:
            y += 1
        if (x, y) == point:
            return True
    return False


def area_gf(paths: List[List[bool]]) -> Dict[int, int]:
    gf = {}
    for p in paths:
        a = compute_path_area(p)
        gf[a] = gf.get(a, 0) + 1
    return dict(sorted(gf.items()))


# ============================================================
# APPLICATION 1: Polymer Folding Entropy
# ============================================================

print("=" * 60)
print("APPLICATION 1: Polymer Folding Entropy")
print("=" * 60)
print()
print("Lattice paths model polymer chains on a 2D grid.")
print("The area under the path relates to the polymer's enclosed volume.")
print("The area complement theorem constrains the entropy of folding.")
print()

for n in [3, 4, 5, 6]:
    paths = all_lattice_paths(n, n)
    areas = [compute_path_area(p) for p in paths]
    mean_area = sum(areas) / len(areas)
    max_area = n * n
    
    # By palindromic_sum: 2 * sum(areas) = n^2 * C(2n, n)
    # So mean = n^2 / 2
    print(f"  n={n}: {len(paths)} paths, mean area = {mean_area:.2f}, "
          f"predicted (n²/2) = {n*n/2:.2f}, max = {max_area}")

print()
print("  The palindromic sum theorem guarantees mean area = n²/2,")
print("  providing an exact constraint on polymer configuration entropy.")

# ============================================================
# APPLICATION 2: Cryptographic Lattice Problems
# ============================================================

print()
print("=" * 60)
print("APPLICATION 2: Lattice Enumeration for Cryptography")
print("=" * 60)
print()
print("Counting lattice paths with area constraints models short")
print("vector problems in lattice-based cryptography.")
print()

for m, n in [(3, 3), (4, 4), (5, 5)]:
    gf = area_gf(all_lattice_paths(m, n))
    total = sum(gf.values())
    # Count paths with area below threshold
    threshold = m * n // 3
    below = sum(c for a, c in gf.items() if a <= threshold)
    above = sum(c for a, c in gf.items() if a > 2 * threshold)
    middle = total - below - above
    print(f"  ({m}×{n}) grid: total={total}, "
          f"area≤{threshold}: {below}, "
          f"area>{2*threshold}: {above}, "
          f"middle: {middle}")
    print(f"    By symmetry: low-area count = high-area count: "
          f"{below} {'=' if below == above else '≠'} {above}")

# ============================================================
# APPLICATION 3: Network Routing with Forbidden Zones
# ============================================================

print()
print("=" * 60)
print("APPLICATION 3: Network Routing with Forbidden Zones")
print("=" * 60)
print()
print("Lattice paths model network routes. Forbidden regions model")
print("congested or failed nodes. The GF tracks route quality.")
print()

grid_size = 5
forbidden_configs = [
    ("No obstacles", set()),
    ("Center blocked", {(2, 2)}),
    ("Diagonal blocked", {(1, 1), (2, 2), (3, 3)}),
    ("Corner blocked", {(1, 1), (1, 2), (2, 1)}),
]

for name, forbidden in forbidden_configs:
    paths = all_lattice_paths(grid_size, grid_size)
    valid = [p for p in paths if all(not path_visits(p, f) for f in forbidden)]
    if valid:
        gf = area_gf(valid)
        mean = sum(a * c for a, c in gf.items()) / len(valid)
        print(f"  {name}: {len(valid)}/{len(paths)} routes valid, "
              f"mean area = {mean:.1f}")
    else:
        print(f"  {name}: no valid routes")

# ============================================================
# APPLICATION 4: Knot Classification via Lattice Signatures
# ============================================================

print()
print("=" * 60)
print("APPLICATION 4: Knot Classification via Lattice Signatures")
print("=" * 60)
print()
print("Different knots produce different forbidden regions,")
print("yielding distinct area GF signatures.")
print()

knots = [
    ("Unknot (0₁)", 2, {}, 0),
    ("Trefoil (3₁)", 3, {(1, 1)}, 3),
    ("Figure-8 (4₁)", 4, {(1, 1), (2, 2)}, 0),
    ("Cinquefoil (5₁)", 5, {(1, 1), (2, 2)}, 5),
    ("Solomon (5₂)", 5, {(1, 1), (3, 3)}, 3),
]

for name, n, forbidden, writhe in knots:
    paths = all_lattice_paths(n, n)
    valid = [p for p in paths if all(not path_visits(p, f) for f in forbidden)]
    gf = area_gf(valid)
    
    # Check palindromic symmetry
    max_a = n * n
    is_palindromic = all(gf.get(a, 0) == gf.get(max_a - a, 0) for a in range(max_a + 1))
    
    # Compute signature: (count, palindromic, writhe)
    terms = " + ".join(f"{c}q^{a}" for a, c in list(gf.items())[:6])
    if len(gf) > 6:
        terms += " + ..."
    
    print(f"  {name}:")
    print(f"    Writhe: {writhe}, Valid paths: {len(valid)}/{comb(2*n,n)}")
    print(f"    GF: {terms}")
    print(f"    Palindromic: {'✓' if is_palindromic else '✗'}")
    print()

print("All applications demonstrated.")


#!/usr/bin/env python3
"""
Knots and Lattices: The Alexander Polynomial as a Lattice Path Count
====================================================================

Demonstrates the Area Complement Theorem and lattice path enumeration.
Verifies that for any lattice path, area(path) + area(complement) = m * n.
"""

from itertools import combinations
from math import comb
from typing import List, Tuple


def encode_path(m: int, n: int, east_positions: Tuple[int, ...]) -> List[bool]:
    """Encode a lattice path from (0,0) to (m,n) as a list of bools.
    
    Args:
        m: Number of East steps
        n: Number of North steps
        east_positions: Sorted positions (0-indexed) where East steps occur
    
    Returns:
        List of bools: True = East, False = North
    """
    path = [False] * (m + n)
    for pos in east_positions:
        path[pos] = True
    return path


def path_area(path: List[bool], h: int = 0) -> int:
    """Compute the area under a lattice path starting from height h.
    
    At each East step, add current height to area.
    At each North step, increment height.
    """
    area = 0
    for step in path:
        if step:  # East
            area += h
        else:  # North
            h += 1
    return area


def complement(path: List[bool]) -> List[bool]:
    """Swap East and North steps."""
    return [not s for s in path]


def east_count(path: List[bool]) -> int:
    return sum(1 for s in path if s)


def north_count(path: List[bool]) -> int:
    return sum(1 for s in path if not s)


def all_lattice_paths(m: int, n: int) -> List[List[bool]]:
    """Generate all lattice paths from (0,0) to (m,n)."""
    paths = []
    for east_pos in combinations(range(m + n), m):
        paths.append(encode_path(m, n, east_pos))
    return paths


def area_generating_function(m: int, n: int) -> dict:
    """Compute the area generating function: GF(q) = sum q^area(p).
    
    Returns dict mapping area -> count of paths with that area.
    """
    gf = {}
    for path in all_lattice_paths(m, n):
        a = path_area(path)
        gf[a] = gf.get(a, 0) + 1
    return dict(sorted(gf.items()))


# ============================================================
# DEMO 1: Area Complement Theorem Verification
# ============================================================
print("=" * 60)
print("DEMO 1: Area Complement Theorem Verification")
print("=" * 60)
print()
print("Theorem: For any lattice path p from (0,0) to (m,n),")
print("  area(p) + area(complement(p)) = m * n")
print()

for m, n in [(2, 2), (2, 3), (3, 3), (3, 4), (4, 4)]:
    paths = all_lattice_paths(m, n)
    print(f"  (m,n) = ({m},{n}): {len(paths)} paths = C({m+n},{m}) = {comb(m+n,m)}")
    all_pass = True
    for path in paths:
        a = path_area(path)
        ac = path_area(complement(path))
        if a + ac != m * n:
            all_pass = False
            print(f"    FAIL: area={a}, complement_area={ac}, sum={a+ac}, m*n={m*n}")
    if all_pass:
        print(f"    ✓ All {len(paths)} paths satisfy area + complement_area = {m*n}")
    print()

# ============================================================
# DEMO 2: Area Generating Functions
# ============================================================
print("=" * 60)
print("DEMO 2: Area Generating Functions (q-binomial coefficients)")
print("=" * 60)
print()

for m, n in [(2, 2), (2, 3), (3, 3)]:
    gf = area_generating_function(m, n)
    print(f"  GF for ({m},{n})-paths:")
    terms = " + ".join(f"{count}·q^{area}" for area, count in gf.items())
    print(f"    GF(q) = {terms}")
    
    # Verify palindromic symmetry
    max_area = m * n
    symmetric = all(gf.get(a, 0) == gf.get(max_area - a, 0) for a in gf)
    print(f"    Palindromic (area ↔ {max_area}-area): {'✓ Yes' if symmetric else '✗ No'}")
    print()

# ============================================================
# DEMO 3: Knot Examples
# ============================================================
print("=" * 60)
print("DEMO 3: Knot Lattice Examples")
print("=" * 60)
print()

# Trefoil: 3 crossings, all positive, forbidden region = {(1,1)}
print("Trefoil Knot (3₁):")
print("  Crossings: 3 (all positive)")
print("  Writhe: +3")
print("  Forbidden region: {(1,1)}")
print(f"  Total 3×3 lattice paths: {comb(6,3)} = C(6,3)")

# Paths through (1,1): those that have exactly 1 East step in first 2 positions
# and 1 North step in first 2 positions (reaching (1,1) at step 2)
paths_3_3 = all_lattice_paths(3, 3)
forbidden = {(1, 1)}

def path_visits(path, point):
    """Check if a lattice path visits a given (x,y) point."""
    x, y = 0, 0
    if (x, y) == point:
        return True
    for step in path:
        if step:
            x += 1
        else:
            y += 1
        if (x, y) == point:
            return True
    return False

avoiding = [p for p in paths_3_3 if not path_visits(p, (1, 1))]
through = [p for p in paths_3_3 if path_visits(p, (1, 1))]
print(f"  Paths avoiding (1,1): {len(avoiding)}")
print(f"  Paths through (1,1): {len(through)}")

# Area distribution of avoiding paths
gf_avoid = {}
for p in avoiding:
    a = path_area(p)
    gf_avoid[a] = gf_avoid.get(a, 0) + 1
gf_avoid = dict(sorted(gf_avoid.items()))
terms = " + ".join(f"{c}·q^{a}" for a, c in gf_avoid.items())
print(f"  GF of avoiding paths: {terms}")
print()

# Figure-eight: 4 crossings, alternating, forbidden = {(1,1),(2,2)}
print("Figure-Eight Knot (4₁):")
print("  Crossings: 4 (alternating +,-,+,-)")
print("  Writhe: 0")
print("  Forbidden region: {(1,1), (2,2)}")
paths_4_4 = all_lattice_paths(4, 4)
avoiding_fe = [p for p in paths_4_4 
               if not path_visits(p, (1, 1)) and not path_visits(p, (2, 2))]
print(f"  Total 4×4 lattice paths: {comb(8,4)} = C(8,4)")
print(f"  Paths avoiding forbidden region: {len(avoiding_fe)}")

gf_fe = {}
for p in avoiding_fe:
    a = path_area(p)
    gf_fe[a] = gf_fe.get(a, 0) + 1
gf_fe = dict(sorted(gf_fe.items()))
terms = " + ".join(f"{c}·q^{a}" for a, c in gf_fe.items())
print(f"  GF of avoiding paths: {terms}")
print()

# ============================================================
# DEMO 4: Palindromic Sum Identity
# ============================================================
print("=" * 60)
print("DEMO 4: Palindromic Sum (2 * Σ area = m*n * #paths)")
print("=" * 60)
print()

for m, n in [(2, 2), (3, 3), (4, 4), (5, 5)]:
    paths = all_lattice_paths(m, n)
    total_area = sum(path_area(p) for p in paths)
    num_paths = len(paths)
    expected = m * n * num_paths
    print(f"  ({m},{n}): 2 * Σ area = 2 * {total_area} = {2*total_area}, "
          f"m*n*#paths = {m}*{n}*{num_paths} = {expected}, "
          f"{'✓' if 2*total_area == expected else '✗'}")

print()
print("All demonstrations complete.")


#!/usr/bin/env python3
"""
Visualization: Area Complement Theorem
========================================
Visualizes the Area Complement Theorem for lattice paths.
Shows a lattice path and its complement side by side, with shaded areas
demonstrating that area(path) + area(complement) = m * n.
"""

import matplotlib.pyplot as plt
import matplotlib.patches as patches
import numpy as np
from itertools import combinations


def path_from_east_positions(m, n, east_pos):
    """Create a lattice path from East step positions."""
    path = [False] * (m + n)
    for pos in east_pos:
        path[pos] = True
    return path


def compute_path_area(path):
    area, h = 0, 0
    for step in path:
        if step:
            area += h
        else:
            h += 1
    return area


def path_coordinates(path):
    """Get the (x, y) coordinates of a lattice path."""
    coords = [(0, 0)]
    x, y = 0, 0
    for step in path:
        if step:
            x += 1
        else:
            y += 1
        coords.append((x, y))
    return coords


def draw_lattice_path(ax, path, m, n, title, color='#2196F3', fill_color='#BBDEFB'):
    """Draw a lattice path with shaded area."""
    coords = path_coordinates(path)
    xs, ys = zip(*coords)
    
    # Draw grid
    for i in range(m + 1):
        ax.plot([i, i], [0, n], 'lightgray', linewidth=0.5)
    for j in range(n + 1):
        ax.plot([0, m], [j, j], 'lightgray', linewidth=0.5)
    
    # Shade area under the path
    # For each East step at height h, shade the rectangle below
    x_pos, y_pos = 0, 0
    for step in path:
        if step:  # East step
            if y_pos > 0:
                rect = patches.Rectangle((x_pos, 0), 1, y_pos,
                                         facecolor=fill_color, edgecolor='none', alpha=0.7)
                ax.add_patch(rect)
            x_pos += 1
        else:
            y_pos += 1
    
    # Draw the path
    ax.plot(xs, ys, color=color, linewidth=3, marker='o', markersize=6, zorder=5)
    
    # Draw diagonal reference
    ax.plot([0, min(m, n)], [0, min(m, n)], '--', color='gray', alpha=0.4, linewidth=1)
    
    area = compute_path_area(path)
    ax.set_title(f'{title}\nArea = {area}', fontsize=13, fontweight='bold')
    ax.set_xlim(-0.3, m + 0.3)
    ax.set_ylim(-0.3, n + 0.3)
    ax.set_aspect('equal')
    ax.set_xlabel('East →', fontsize=10)
    ax.set_ylabel('North →', fontsize=10)


# Generate example paths for m=3, n=3
m, n = 3, 3
example_paths = [
    ([True, False, True, False, True, False], "ENENENE"),
    ([True, True, True, False, False, False], "EEENNN"),
    ([False, True, False, True, False, True], "NENENE"),
    ([True, False, False, True, True, False], "ENNEEN"),
]

fig, axes = plt.subplots(len(example_paths), 2, figsize=(12, 4 * len(example_paths)))
fig.suptitle('Area Complement Theorem: area(p) + area(complement) = m × n = 9',
             fontsize=16, fontweight='bold', y=0.98)

for idx, (path, name) in enumerate(example_paths):
    comp = [not s for s in path]
    area_p = compute_path_area(path)
    area_c = compute_path_area(comp)
    
    draw_lattice_path(axes[idx, 0], path, m, n, 
                      f'Path: {name}', '#2196F3', '#BBDEFB')
    
    comp_name = ''.join('N' if s else 'E' for s in path)
    draw_lattice_path(axes[idx, 1], comp, n, m,
                      f'Complement: {comp_name}', '#F44336', '#FFCDD2')
    
    # Add verification text
    axes[idx, 1].text(m + 0.1, n/2, f'{area_p} + {area_c} = {area_p + area_c}',
                      fontsize=12, color='green', fontweight='bold',
                      transform=axes[idx, 1].transData,
                      verticalalignment='center')

plt.tight_layout(rect=[0, 0, 1, 0.96])
plt.savefig('viz_area_complement.png', dpi=150, bbox_inches='tight')
print("Saved viz_area_complement.png")


#!/usr/bin/env python3
"""
Visualization: Area Generating Functions and Palindromic Symmetry
==================================================================
Shows the area distribution of lattice paths and demonstrates the
palindromic symmetry predicted by the Area Complement Theorem.
"""

import matplotlib.pyplot as plt
import numpy as np
from itertools import combinations


def all_lattice_paths(m, n):
    paths = []
    for east_pos in combinations(range(m + n), m):
        p = [False] * (m + n)
        for pos in east_pos:
            p[pos] = True
        paths.append(p)
    return paths


def compute_path_area(path):
    area, h = 0, 0
    for step in path:
        if step:
            area += h
        else:
            h += 1
    return area


def area_distribution(m, n):
    gf = {}
    for p in all_lattice_paths(m, n):
        a = compute_path_area(p)
        gf[a] = gf.get(a, 0) + 1
    return gf


fig, axes = plt.subplots(2, 3, figsize=(15, 10))
fig.suptitle('Area Generating Functions: Palindromic Symmetry',
             fontsize=16, fontweight='bold')

configs = [(2, 2), (2, 3), (3, 3), (3, 4), (4, 4), (4, 5)]
colors_left = '#2196F3'
colors_right = '#F44336'

for idx, (m, n) in enumerate(configs):
    ax = axes[idx // 3, idx % 3]
    gf = area_distribution(m, n)
    max_area = m * n
    
    areas = list(range(max_area + 1))
    counts = [gf.get(a, 0) for a in areas]
    
    # Color bars: blue for left half, red for right half (palindromic pairs)
    bar_colors = []
    for a in areas:
        if a < max_area / 2:
            bar_colors.append('#2196F3')
        elif a > max_area / 2:
            bar_colors.append('#F44336')
        else:
            bar_colors.append('#9C27B0')
    
    ax.bar(areas, counts, color=bar_colors, alpha=0.8, edgecolor='white')
    
    # Mark the symmetry axis
    ax.axvline(x=max_area / 2, color='green', linestyle='--', linewidth=2, alpha=0.7)
    
    # Verify palindromy
    is_palindromic = all(gf.get(a, 0) == gf.get(max_area - a, 0) for a in areas)
    symbol = '✓' if is_palindromic else '✗'
    
    total = sum(counts)
    from math import comb
    ax.set_title(f'({m},{n})-paths: C({m+n},{m})={comb(m+n,m)}\n'
                 f'Palindromic: {symbol}  |  m·n = {max_area}',
                 fontsize=11)
    ax.set_xlabel('Area', fontsize=10)
    ax.set_ylabel('# Paths', fontsize=10)
    
    # Add GF text
    terms = []
    for a in sorted(gf.keys()):
        if gf[a] == 1:
            terms.append(f'q^{a}')
        else:
            terms.append(f'{gf[a]}q^{a}')
    gf_str = ' + '.join(terms[:5])
    if len(terms) > 5:
        gf_str += ' + ...'

plt.tight_layout()
plt.savefig('viz_generating_function.png', dpi=150, bbox_inches='tight')
print("Saved viz_generating_function.png")


#!/usr/bin/env python3
"""
Visualization: Knot Lattice Forbidden Regions
===============================================
Shows lattice paths for different knots with their forbidden regions
highlighted, demonstrating how knot topology constrains path combinatorics.
"""

import matplotlib.pyplot as plt
import matplotlib.patches as patches
import numpy as np
from itertools import combinations
from math import comb


def all_lattice_paths(m, n):
    paths = []
    for east_pos in combinations(range(m + n), m):
        p = [False] * (m + n)
        for pos in east_pos:
            p[pos] = True
        paths.append(p)
    return paths


def path_visits(path, point):
    x, y = 0, 0
    if (x, y) == point:
        return True
    for step in path:
        if step:
            x += 1
        else:
            y += 1
        if (x, y) == point:
            return True
    return False


def compute_path_area(path):
    area, h = 0, 0
    for step in path:
        if step:
            area += h
        else:
            h += 1
    return area


def path_coordinates(path):
    coords = [(0, 0)]
    x, y = 0, 0
    for step in path:
        if step:
            x += 1
        else:
            y += 1
        coords.append((x, y))
    return coords


def draw_knot_lattice(ax, n, forbidden, title, writhe):
    """Draw a knot lattice with forbidden region and valid paths."""
    # Draw grid
    for i in range(n + 1):
        ax.plot([i, i], [0, n], 'lightgray', linewidth=0.5)
        ax.plot([0, n], [i, i], 'lightgray', linewidth=0.5)
    
    # Draw forbidden region
    for fx, fy in forbidden:
        rect = patches.Rectangle((fx - 0.4, fy - 0.4), 0.8, 0.8,
                                  facecolor='#F44336', alpha=0.4,
                                  edgecolor='#F44336', linewidth=2)
        ax.add_patch(rect)
        ax.plot(fx, fy, 'x', color='#B71C1C', markersize=12, 
                markeredgewidth=3, zorder=10)
    
    # Get all paths and classify
    all_paths = all_lattice_paths(n, n)
    valid_paths = [p for p in all_paths 
                   if all(not path_visits(p, f) for f in forbidden)]
    
    # Draw a sample of valid paths (up to 8)
    cmap = plt.cm.Blues
    sample = valid_paths[:min(8, len(valid_paths))]
    for idx, path in enumerate(sample):
        coords = path_coordinates(path)
        xs, ys = zip(*coords)
        alpha = 0.3 + 0.5 * (idx / max(len(sample) - 1, 1))
        color = cmap(0.3 + 0.5 * idx / max(len(sample) - 1, 1))
        ax.plot(xs, ys, color=color, linewidth=1.5, alpha=0.6)
    
    # Draw start and end
    ax.plot(0, 0, 'go', markersize=10, zorder=15, label='Start')
    ax.plot(n, n, 's', color='purple', markersize=10, zorder=15, label='End')
    
    # Area distribution
    gf = {}
    for p in valid_paths:
        a = compute_path_area(p)
        gf[a] = gf.get(a, 0) + 1
    
    # Check palindromic
    max_a = n * n
    is_pal = all(gf.get(a, 0) == gf.get(max_a - a, 0) for a in range(max_a + 1))
    
    total = comb(2*n, n)
    ax.set_title(f'{title}\nWrithe={writhe}, Valid: {len(valid_paths)}/{total}, '
                 f'Palindromic: {"✓" if is_pal else "✗"}',
                 fontsize=11, fontweight='bold')
    ax.set_xlim(-0.5, n + 0.5)
    ax.set_ylim(-0.5, n + 0.5)
    ax.set_aspect('equal')
    ax.set_xlabel('East →')
    ax.set_ylabel('North →')


knots = [
    (2, set(), "Unknot (0₁)", 0),
    (3, {(1, 1)}, "Trefoil (3₁)", 3),
    (4, {(1, 1), (2, 2)}, "Figure-Eight (4₁)", 0),
    (5, {(1, 1), (2, 2)}, "Cinquefoil (5₁)", 5),
    (5, {(1, 1), (3, 3)}, "Solomon's Seal (5₂)", 3),
    (6, {(1, 1), (2, 3), (3, 2)}, "Knot 6₁", 0),
]

fig, axes = plt.subplots(2, 3, figsize=(16, 11))
fig.suptitle('Knot Lattices: Forbidden Regions and Valid Paths',
             fontsize=16, fontweight='bold')

for idx, (n, forbidden, title, writhe) in enumerate(knots):
    ax = axes[idx // 3, idx % 3]
    draw_knot_lattice(ax, n, forbidden, title, writhe)

plt.tight_layout(rect=[0, 0, 1, 0.95])
plt.savefig('viz_knot_lattice.png', dpi=150, bbox_inches='tight')
print("Saved viz_knot_lattice.png")
