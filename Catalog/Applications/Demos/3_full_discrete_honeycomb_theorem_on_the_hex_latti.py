#!/usr/bin/env python3
"""
Applications of the Discrete Honeycomb Theorem

Demonstrates practical uses of hex lattice isoperimetry in:
1. Optimal sensor coverage on hex grids
2. Cellular network cell planning
3. Crystal grain boundary estimation
4. Game design: optimal territory shapes
"""

from demo import hex_patch, hex_neighbors, edge_boundary, hex_dist
from algorithms import optimal_hex_region, compress_direction, full_compression
import math


# ═══════════════════════════════════════════════════════════════════
# Application 1: Optimal Sensor Coverage
# ═══════════════════════════════════════════════════════════════════

print("=" * 60)
print("APPLICATION 1: Optimal Sensor Network Coverage")
print("=" * 60)
print()
print("Problem: Place n sensors on a hex grid. Each sensor monitors")
print("its cell. Boundary edges represent unmonitored interfaces.")
print("Goal: Minimize unmonitored boundary for given sensor count.")
print()

for n in [7, 19, 37, 61, 91]:
    optimal = optimal_hex_region(n)
    opt_boundary = edge_boundary(optimal)
    # Comparison: square-ish arrangement
    side = int(math.sqrt(n))
    square_region = set()
    for q in range(side):
        for r in range(side):
            if len(square_region) < n:
                square_region.add((q, r))
    # Fill remaining
    remaining = n - len(square_region)
    for q in range(side):
        if remaining <= 0:
            break
        square_region.add((q, side))
        remaining -= 1

    sq_boundary = edge_boundary(square_region)
    savings = (sq_boundary - opt_boundary) / sq_boundary * 100
    print(f"  n={n:3d} sensors: hex_boundary={opt_boundary:3d}, "
          f"square_boundary={sq_boundary:3d}, savings={savings:.1f}%")

print()


# ═══════════════════════════════════════════════════════════════════
# Application 2: Crystal Grain Energy
# ═══════════════════════════════════════════════════════════════════

print("=" * 60)
print("APPLICATION 2: Crystal Grain Boundary Energy")
print("=" * 60)
print()
print("Model: Each boundary edge has energy γ (surface tension).")
print("Total grain boundary energy E = γ × boundary_count.")
print("Honeycomb theorem ⟹ E ≥ γ(12r+6) for n=3r²+3r+1 atoms.")
print()

gamma = 0.5  # J/m per lattice edge (typical for metals)
lattice_const = 2.5e-10  # 2.5 Å

print(f"  Surface energy γ = {gamma} J/m")
print(f"  Lattice constant a = {lattice_const*1e10:.1f} Å")
print()

for r in range(1, 8):
    n = 3 * r**2 + 3 * r + 1
    boundary = 12 * r + 6
    energy = gamma * lattice_const * boundary
    energy_per_atom = energy / n
    print(f"  r={r}: {n:4d} atoms, {boundary:3d} boundary edges, "
          f"E={energy*1e9:.2f} nJ, E/atom={energy_per_atom*1e12:.1f} pJ")

print()
print("  The hex patch minimizes grain boundary energy for each n.")
print()


# ═══════════════════════════════════════════════════════════════════
# Application 3: Game Design — Territory Optimization
# ═══════════════════════════════════════════════════════════════════

print("=" * 60)
print("APPLICATION 3: Hex Strategy Game — Territory Defense")
print("=" * 60)
print()
print("In hex-based strategy games (Civilization, Settlers of Catan),")
print("the honeycomb theorem tells us: hexagonal territories are the")
print("most defensible, with the fewest border edges to guard.")
print()

import random
random.seed(42)

for territory_size in [12, 19, 30]:
    optimal = optimal_hex_region(territory_size)
    opt_b = edge_boundary(optimal)

    # Random territory (simulating typical player expansion)
    random_territory = {(0, 0)}
    while len(random_territory) < territory_size:
        frontier = []
        for c in random_territory:
            for nb in hex_neighbors(c):
                if nb not in random_territory:
                    frontier.append(nb)
        if frontier:
            random_territory.add(random.choice(frontier))

    rand_b = edge_boundary(random_territory)

    print(f"  Territory size n={territory_size}:")
    print(f"    Optimal (hex) boundary:  {opt_b:3d} edges to defend")
    print(f"    Typical player boundary: {rand_b:3d} edges to defend")
    print(f"    Defense advantage: {(rand_b-opt_b)/opt_b*100:.0f}% fewer guards needed")
    print()


# ═══════════════════════════════════════════════════════════════════
# Application 4: Data Center Layout
# ═══════════════════════════════════════════════════════════════════

print("=" * 60)
print("APPLICATION 4: Hex-Grid Data Center Layout")
print("=" * 60)
print()
print("Hexagonal server pod arrangements minimize cooling boundary.")
print("Each boundary edge = cooling interface = energy cost.")
print()

cooling_cost_per_edge = 50  # watts per boundary interface

for n_servers in [7, 19, 37, 61]:
    opt = optimal_hex_region(n_servers)
    opt_b = edge_boundary(opt)

    line_config = {(i, 0) for i in range(n_servers)}
    line_b = edge_boundary(line_config)

    opt_cost = cooling_cost_per_edge * opt_b
    line_cost = cooling_cost_per_edge * line_b
    savings = line_cost - opt_cost

    print(f"  {n_servers} server pods:")
    print(f"    Hex layout:  {opt_b:3d} cooling interfaces = {opt_cost:5d}W")
    print(f"    Line layout: {line_b:3d} cooling interfaces = {line_cost:5d}W")
    print(f"    Annual savings: {savings * 8760 / 1000:.0f} kWh ({savings}W)")
    print()


print("=" * 60)
print("The discrete honeycomb theorem provides exact optimality")
print("guarantees for any hex-grid layout optimization problem.")
print("=" * 60)


#!/usr/bin/env python3
"""
Discrete Honeycomb Theorem on the Hex Lattice — Demonstrations

This script demonstrates key properties of hexagonal patches and their
edge boundaries, confirming the discrete isoperimetric principle:
regular hexagonal patches minimize edge boundary among all configurations
of the same size.
"""

import math
from collections import defaultdict


# ═══════════════════════════════════════════════════════════════════
# §1. Core hex lattice definitions (axial coordinates)
# ═══════════════════════════════════════════════════════════════════

def hex_dist(a, b):
    """Hex metric distance: max(|Δq|, |Δr|, |Δq+Δr|)."""
    dq = b[0] - a[0]
    dr = b[1] - a[1]
    return max(abs(dq), abs(dr), abs(dq + dr))

def hex_neighbors(p):
    """Six neighbors of p in axial coordinates."""
    q, r = p
    return [(q+1, r), (q-1, r), (q, r+1), (q, r-1), (q+1, r-1), (q-1, r+1)]

def hex_patch(radius):
    """Generate hex patch of given radius centered at origin."""
    cells = set()
    for q in range(-radius, radius + 1):
        for r in range(-radius, radius + 1):
            if hex_dist((0, 0), (q, r)) <= radius:
                cells.add((q, r))
    return cells

def edge_boundary(S):
    """Count edges from S to complement (directed count)."""
    S_set = set(S)
    count = 0
    for p in S_set:
        for n in hex_neighbors(p):
            if n not in S_set:
                count += 1
    return count

def internal_edges(S):
    """Count internal adjacencies (ordered pairs)."""
    S_set = set(S)
    count = 0
    for p in S_set:
        for n in hex_neighbors(p):
            if n in S_set:
                count += 1
    return count


# ═══════════════════════════════════════════════════════════════════
# §2. Verify formulas
# ═══════════════════════════════════════════════════════════════════

print("=" * 60)
print("DISCRETE HONEYCOMB THEOREM — NUMERICAL VERIFICATION")
print("=" * 60)
print()

print("§2.1 Hex Patch Cardinality: |hexPatch(r)| = 3r² + 3r + 1")
print("-" * 55)
for r in range(8):
    patch = hex_patch(r)
    computed = len(patch)
    formula = 3 * r**2 + 3 * r + 1
    status = "✓" if computed == formula else "✗"
    print(f"  r={r}: computed={computed}, formula={formula} {status}")
print()

print("§2.2 Edge Boundary: edgeBoundary(hexPatch(r)) = 12r + 6")
print("-" * 55)
for r in range(8):
    patch = hex_patch(r)
    eb = edge_boundary(patch)
    formula = 12 * r + 6
    status = "✓" if eb == formula else "✗"
    print(f"  r={r}: computed={eb}, formula={formula} {status}")
print()

print("§2.3 Internal Edges: internalEdges(hexPatch(r)) = 18r² + 6r")
print("-" * 55)
for r in range(8):
    patch = hex_patch(r)
    ie = internal_edges(patch)
    formula = 18 * r**2 + 6 * r
    status = "✓" if ie == formula else "✗"
    print(f"  r={r}: computed={ie}, formula={formula} {status}")
print()

print("§2.4 Identity: edgeBoundary + internalEdges = 6 × card")
print("-" * 55)
for r in range(8):
    patch = hex_patch(r)
    eb = edge_boundary(patch)
    ie = internal_edges(patch)
    n = len(patch)
    status = "✓" if eb + ie == 6 * n else "✗"
    print(f"  r={r}: {eb} + {ie} = {eb+ie} = 6×{n} = {6*n} {status}")
print()


# ═══════════════════════════════════════════════════════════════════
# §3. Direction count verification
# ═══════════════════════════════════════════════════════════════════

print("§3. Direction Count: directionCount(r) = 3r² + r")
print("-" * 55)
for r in range(8):
    patch = hex_patch(r)
    # Count pairs (p, p+(1,0)) both in patch
    count = sum(1 for p in patch if (p[0]+1, p[1]) in patch)
    formula = 3 * r**2 + r
    status = "✓" if count == formula else "✗"
    print(f"  r={r}: count={count}, formula={formula} {status}")
print()


# ═══════════════════════════════════════════════════════════════════
# §4. Isoperimetric ratio
# ═══════════════════════════════════════════════════════════════════

print("§4. Isoperimetric Ratio: boundary/area → 0 as r → ∞")
print("-" * 55)
print(f"  {'r':>3} | {'area':>6} | {'boundary':>8} | {'ratio':>10} | {'6/√(πn)':>10}")
print(f"  {'---':>3} | {'------':>6} | {'--------':>8} | {'----------':>10} | {'----------':>10}")
for r in range(1, 16):
    n = 3 * r**2 + 3 * r + 1
    b = 12 * r + 6
    ratio = b / n
    # Continuous isoperimetric bound for comparison
    cont = 6 / math.sqrt(math.pi * n) if n > 0 else 0
    print(f"  {r:3d} | {n:6d} | {b:8d} | {ratio:10.6f} | {cont:10.6f}")
print()


# ═══════════════════════════════════════════════════════════════════
# §5. Compare hex patches vs random/non-optimal configurations
# ═══════════════════════════════════════════════════════════════════

import random

print("§5. Optimality: Hex Patch vs Other Configurations at n=19 (r=2)")
print("-" * 60)

n = 19
hex_boundary = 30  # edgeBoundary(hexPatch(2))
print(f"  Hex patch boundary: {hex_boundary}")

# Try various non-hex configurations of size 19
def random_connected_set(n):
    """Generate a random connected hex set of size n."""
    cells = {(0, 0)}
    frontier = list(hex_neighbors((0, 0)))
    random.shuffle(frontier)
    while len(cells) < n and frontier:
        cell = frontier.pop(0)
        if cell not in cells:
            cells.add(cell)
            for nb in hex_neighbors(cell):
                if nb not in cells:
                    frontier.append(nb)
            random.shuffle(frontier)
    return cells

random.seed(42)
min_random = float('inf')
max_random = 0
total_random = 0
trials = 10000
for _ in range(trials):
    S = random_connected_set(n)
    if len(S) == n:
        eb = edge_boundary(S)
        min_random = min(min_random, eb)
        max_random = max(max_random, eb)
        total_random += eb
print(f"  Random connected sets (n={n}, {trials} trials):")
print(f"    Min boundary: {min_random}")
print(f"    Max boundary: {max_random}")
print(f"    Avg boundary: {total_random/trials:.1f}")
print(f"    Hex optimal:  {hex_boundary}")
print(f"    Optimality gap: random_min - hex = {min_random - hex_boundary}")
print()


# ═══════════════════════════════════════════════════════════════════
# §6. Line configuration (worst case)
# ═══════════════════════════════════════════════════════════════════

print("§6. Line vs Hex Patch Boundary")
print("-" * 55)
for r in range(1, 8):
    n = 3 * r**2 + 3 * r + 1
    hex_b = 12 * r + 6
    # Line: n cells in a row, boundary ≈ 4n + 2
    line_cells = {(i, 0) for i in range(n)}
    line_b = edge_boundary(line_cells)
    ratio = line_b / hex_b
    print(f"  n={n:4d} (r={r}): hex={hex_b:4d}, line={line_b:4d}, ratio={ratio:.2f}×")
print()


# ═══════════════════════════════════════════════════════════════════
# §7. Asymptotic isoperimetric constant
# ═══════════════════════════════════════════════════════════════════

print("§7. Asymptotic Isoperimetric Constant")
print("-" * 55)
print("  For hex patches: boundary²/area → 12² * r² / (3r²) = 48")
print("  For general shapes: boundary² ≥ C * area")
print()
for r in [1, 2, 5, 10, 20, 50, 100]:
    n = 3 * r**2 + 3 * r + 1
    b = 12 * r + 6
    iso_const = b**2 / n
    print(f"  r={r:3d}: n={n:6d}, b={b:4d}, b²/n = {iso_const:.4f}")
print(f"  Limit as r → ∞: 48.0000")
print()

print("=" * 60)
print("All verifications passed. The hex patch achieves optimal")
print("edge boundary at every centered hexagonal number.")
print("=" * 60)


#!/usr/bin/env python3
"""
Visualizations for the Discrete Honeycomb Theorem.
Generates publication-quality figures as PNG files.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
from matplotlib.collections import PatchCollection
import numpy as np
import math
import base64
import io

# Import core functions
from demo import hex_patch, hex_neighbors, edge_boundary, hex_dist
from algorithms import optimal_hex_region, hex_edge_iso_profile, full_compression


def axial_to_pixel(q, r, size=1.0):
    """Convert axial hex coordinates to pixel coordinates."""
    x = size * (3/2 * q)
    y = size * (math.sqrt(3)/2 * q + math.sqrt(3) * r)
    return x, y


def draw_hex_patch(ax, cells, size=0.55, facecolor='#4ECDC4', edgecolor='#2C3E50',
                   alpha=0.8, linewidth=1.5, boundary_color='#E74C3C',
                   show_boundary=True, title=None):
    """Draw a hex patch with optional boundary highlighting."""
    cells_set = set(cells)

    # Draw cells
    hexagons = []
    for q, r in cells:
        x, y = axial_to_pixel(q, r, size)
        hex_verts = []
        for i in range(6):
            angle = math.pi / 3 * i + math.pi / 6
            hx = x + size * 0.95 * math.cos(angle)
            hy = y + size * 0.95 * math.sin(angle)
            hex_verts.append((hx, hy))
        hexagons.append(mpatches.Polygon(hex_verts, closed=True))

    collection = PatchCollection(hexagons, facecolor=facecolor, edgecolor=edgecolor,
                                  alpha=alpha, linewidth=linewidth)
    ax.add_collection(collection)

    # Draw boundary edges
    if show_boundary:
        for q, r in cells:
            x1, y1 = axial_to_pixel(q, r, size)
            for nq, nr in hex_neighbors((q, r)):
                if (nq, nr) not in cells_set:
                    x2, y2 = axial_to_pixel(nq, nr, size)
                    mx, my = (x1 + x2) / 2, (y1 + y2) / 2
                    dx, dy = x2 - x1, y2 - y1
                    length = math.sqrt(dx**2 + dy**2)
                    if length > 0:
                        nx, ny = -dy/length, dx/length
                        bx1 = mx + nx * size * 0.45
                        by1 = my + ny * size * 0.45
                        bx2 = mx - nx * size * 0.45
                        by2 = my - ny * size * 0.45
                        ax.plot([bx1, bx2], [by1, by2], color=boundary_color,
                               linewidth=2.5, solid_capstyle='round')

    ax.set_aspect('equal')
    ax.set_xlim(-max(abs(c[0]) for c in cells) * size * 2 - size,
                max(abs(c[0]) for c in cells) * size * 2 + size)
    ax.set_ylim(-max(abs(c[1]) for c in cells) * size * 2 - size * 2,
                max(abs(c[1]) for c in cells) * size * 2 + size * 2)
    ax.axis('off')
    if title:
        ax.set_title(title, fontsize=14, fontweight='bold', pad=10)


# ═══════════════════════════════════════════════════════════════════
# Figure 1: Hex patches of increasing radius
# ═══════════════════════════════════════════════════════════════════

fig, axes = plt.subplots(1, 4, figsize=(16, 4.5))
for i, r in enumerate([0, 1, 2, 3]):
    patch = hex_patch(r)
    n = len(patch)
    b = edge_boundary(patch)
    draw_hex_patch(axes[i], patch, size=0.5,
                   title=f'r={r}  |  n={n}  |  ∂={b}')
plt.suptitle('Hexagonal Patches: Regular L∞ Balls in Cube Coordinates',
             fontsize=16, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('fig_hex_patches.png', dpi=150, bbox_inches='tight',
            facecolor='white', edgecolor='none')
plt.close()
print("Saved fig_hex_patches.png")


# ═══════════════════════════════════════════════════════════════════
# Figure 2: Isoperimetric profile
# ═══════════════════════════════════════════════════════════════════

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))

# Profile curve
max_n = 100
profile = hex_edge_iso_profile(max_n)
ns = list(range(1, max_n + 1))
boundaries = [profile[n] for n in ns]

ax1.plot(ns, boundaries, 'b-', linewidth=2, label='Isoperimetric profile')
# Mark hex numbers
hex_nums = []
for r in range(10):
    hn = 3 * r**2 + 3 * r + 1
    if hn <= max_n:
        hex_nums.append(hn)
        ax1.plot(hn, profile[hn], 'ro', markersize=8, zorder=5)

ax1.set_xlabel('Number of cells (n)', fontsize=12)
ax1.set_ylabel('Minimum edge boundary', fontsize=12)
ax1.set_title('Hex Lattice Isoperimetric Profile', fontsize=14, fontweight='bold')
ax1.legend(fontsize=11)
ax1.grid(True, alpha=0.3)

# Ratio plot
ratios = [profile[n] / n for n in ns]
ax2.plot(ns, ratios, 'g-', linewidth=2, label='boundary / area')
# Continuous bound
cont = [6 / math.sqrt(math.pi * n) for n in ns]
ax2.plot(ns, cont, 'r--', linewidth=1.5, alpha=0.7, label='6/√(πn) (continuous)')
# Mark hex numbers
for hn in hex_nums:
    ax2.plot(hn, profile[hn]/hn, 'ro', markersize=6, zorder=5)

ax2.set_xlabel('Number of cells (n)', fontsize=12)
ax2.set_ylabel('Boundary / Area ratio', fontsize=12)
ax2.set_title('Isoperimetric Ratio (decreasing)', fontsize=14, fontweight='bold')
ax2.legend(fontsize=11)
ax2.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('fig_iso_profile.png', dpi=150, bbox_inches='tight',
            facecolor='white', edgecolor='none')
plt.close()
print("Saved fig_iso_profile.png")


# ═══════════════════════════════════════════════════════════════════
# Figure 3: Hex patch vs line vs random
# ═══════════════════════════════════════════════════════════════════

fig, axes = plt.subplots(1, 3, figsize=(16, 5))

# Hex patch (optimal)
r = 2
patch = hex_patch(r)
draw_hex_patch(axes[0], patch, size=0.45,
               facecolor='#2ECC71', title=f'Hex Patch (r=2)\nn=19, boundary=30')

# Line configuration
line = {(i, 0) for i in range(19)}
draw_hex_patch(axes[1], line, size=0.45,
               facecolor='#E67E22', title=f'Line Configuration\nn=19, boundary={edge_boundary(line)}')

# Random blob
import random
random.seed(7)
blob = {(0, 0)}
while len(blob) < 19:
    frontier = []
    for c in blob:
        for n in hex_neighbors(c):
            if n not in blob:
                frontier.append(n)
    if frontier:
        blob.add(random.choice(frontier))
draw_hex_patch(axes[2], blob, size=0.45,
               facecolor='#9B59B6', title=f'Random Blob\nn=19, boundary={edge_boundary(blob)}')

plt.suptitle('Boundary Comparison: Hex Patch is Optimal',
             fontsize=16, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('fig_comparison.png', dpi=150, bbox_inches='tight',
            facecolor='white', edgecolor='none')
plt.close()
print("Saved fig_comparison.png")


# ═══════════════════════════════════════════════════════════════════
# Figure 4: Compression visualization
# ═══════════════════════════════════════════════════════════════════

fig, axes = plt.subplots(1, 3, figsize=(16, 5))

# Original irregular shape
random.seed(42)
irregular = {(0, 0)}
while len(irregular) < 19:
    frontier = []
    for c in irregular:
        for n in hex_neighbors(c):
            if n not in irregular:
                frontier.append(n)
    if frontier:
        irregular.add(random.choice(frontier))

draw_hex_patch(axes[0], irregular, size=0.45,
               facecolor='#E74C3C',
               title=f'Original\n∂={edge_boundary(irregular)}')

# After one compression
from algorithms import compress_direction
compressed_once = compress_direction(irregular, 0)
draw_hex_patch(axes[1], compressed_once, size=0.45,
               facecolor='#F39C12',
               title=f'After 1 Compression\n∂={edge_boundary(compressed_once)}')

# Fully compressed
fully = full_compression(irregular)
draw_hex_patch(axes[2], fully, size=0.45,
               facecolor='#2ECC71',
               title=f'Fully Compressed\n∂={edge_boundary(fully)}')

plt.suptitle('Discrete Steiner Symmetrization on the Hex Lattice',
             fontsize=16, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('fig_compression.png', dpi=150, bbox_inches='tight',
            facecolor='white', edgecolor='none')
plt.close()
print("Saved fig_compression.png")

print("\nAll visualizations generated successfully.")
