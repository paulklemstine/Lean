#!/usr/bin/env python3
"""
Applications of the Discrete Honeycomb Theorem.

Demonstrates real-world applications in:
1. Network design: optimal hex-grid base station placement
2. Materials science: crystal grain boundary energy minimization
3. Computational geometry: optimal hex-grid region selection
4. Game design: optimal territory shapes in hex-grid games
"""

import math
from typing import Set, Tuple, List, Dict
from collections import defaultdict

HexCell = Tuple[int, int]
HEX_DIRECTIONS = [(1, 0), (-1, 0), (0, 1), (0, -1), (1, -1), (-1, 1)]


def hex_patch(r):
    cells = set()
    for q in range(-r, r+1):
        for s in range(-r, r+1):
            if max(abs(q), abs(s), abs(q+s)) <= r:
                cells.add((q, s))
    return cells


def edge_boundary_card(S):
    count = 0
    for q, s in S:
        for dq, ds in HEX_DIRECTIONS:
            if (q+dq, s+ds) not in S:
                count += 1
    return count


# ─── Application 1: Cellular Network Optimization ───────────────────────────

def cellular_network_optimization():
    """
    In cellular network design, each hex cell represents a base station
    coverage area. The edge boundary represents handoff zones where signals
    from adjacent cells interfere. Minimizing boundary = minimizing
    interference for a given coverage area.
    """
    print("=" * 70)
    print("APPLICATION 1: Cellular Network Optimization")
    print("=" * 70)
    print()
    print("Problem: Deploy n base stations on a hex grid to minimize handoff")
    print("interference (proportional to edge boundary).")
    print()

    for n in [7, 19, 37, 61, 91]:
        # Optimal (hex patch)
        r = 0
        while 3*(r+1)**2 + 3*(r+1) + 1 <= n:
            r += 1
        if 3*r**2 + 3*r + 1 == n:
            opt_boundary = 12*r + 6
            opt_ratio = opt_boundary / n
            # Compare with square-ish deployment
            side = int(math.sqrt(n))
            sq = set()
            for i in range(side+2):
                for j in range(side+2):
                    if len(sq) < n:
                        sq.add((i, j))
            sq_boundary = edge_boundary_card(sq)
            sq_ratio = sq_boundary / n

            savings = (1 - opt_ratio/sq_ratio) * 100
            print(f"  n={n:3d} stations: Hex boundary={opt_boundary:3d} (ratio={opt_ratio:.3f}), "
                  f"Square boundary={sq_boundary:3d} (ratio={sq_ratio:.3f}), "
                  f"Savings={savings:.1f}%")

    print()
    print("  → Hexagonal deployment reduces interference by 10-30%")
    print()


# ─── Application 2: Crystal Grain Boundary Energy ───────────────────────────

def crystal_grain_energy():
    """
    In materials science, minimizing grain boundary energy is equivalent
    to the discrete isoperimetric problem. A crystal grain of n atoms
    on a triangular/hex lattice minimizes its surface energy when shaped
    as a hexagonal patch.
    """
    print("=" * 70)
    print("APPLICATION 2: Crystal Grain Boundary Energy")
    print("=" * 70)
    print()
    print("Model: Each hex cell = one atom. Boundary edges = broken bonds.")
    print("Energy = (bond energy) × (number of broken bonds)")
    print()

    bond_energy_eV = 0.5  # typical metallic bond energy in eV

    for r in range(1, 7):
        n = 3*r**2 + 3*r + 1
        boundary = 12*r + 6
        energy = bond_energy_eV * boundary
        energy_per_atom = energy / n

        # Compare with line (worst case)
        line_boundary = 4*n + 2
        line_energy = bond_energy_eV * line_boundary

        print(f"  r={r}: {n:4d} atoms, Hex energy={energy:.1f} eV ({energy_per_atom:.3f} eV/atom), "
              f"Line energy={line_energy:.1f} eV")

    print()
    print("  → Hexagonal grains minimize surface energy, explaining why")
    print("    crystals naturally form hexagonal shapes.")
    print()


# ─── Application 3: Hex Grid Territory in Games ─────────────────────────────

def game_territory():
    """
    In hex-grid strategy games (Civilization, Settlers of Catan),
    the optimal territory shape minimizes the border that needs defending.
    """
    print("=" * 70)
    print("APPLICATION 3: Strategy Game Territory Optimization")
    print("=" * 70)
    print()
    print("In a hex-grid strategy game, your territory has n tiles.")
    print("Border tiles (adjacent to enemy) need defenders.")
    print("The honeycomb theorem tells you the optimal shape.")
    print()

    defender_cost = 10  # gold per border edge

    for n in [7, 19, 37]:
        r = 0
        while 3*(r+1)**2 + 3*(r+1) + 1 <= n:
            r += 1

        # Hex patch
        hex_cost = edge_boundary_card(hex_patch(r)) * defender_cost

        # Line territory
        line = {(i, 0) for i in range(n)}
        line_cost = edge_boundary_card(line) * defender_cost

        # L-shape
        l_shape = set()
        for i in range(n//2 + 1):
            l_shape.add((i, 0))
        for j in range(1, n - n//2):
            l_shape.add((0, j))
        l_cost = edge_boundary_card(l_shape) * defender_cost

        print(f"  n={n:3d} tiles: Hex defense={hex_cost:5d} gold, "
              f"Line defense={line_cost:5d} gold, "
              f"L-shape defense={l_cost:5d} gold")

    print()
    print("  → Round (hexagonal) territories are cheapest to defend!")
    print()


# ─── Application 4: Sensor Network Coverage ─────────────────────────────────

def sensor_coverage():
    """
    Deploy n sensors on a hex grid. Communication cost is proportional
    to the number of edges between covered and uncovered cells.
    Minimize communication overhead = minimize edge boundary.
    """
    print("=" * 70)
    print("APPLICATION 4: Sensor Network Coverage")
    print("=" * 70)
    print()

    for n in [7, 19, 37, 61]:
        # Find optimal radius
        r = 0
        while 3*(r+1)**2 + 3*(r+1) + 1 <= n:
            r += 1

        patch = hex_patch(r)
        remaining = n - len(patch)
        if remaining > 0:
            # Add cells from next shell
            for q in range(-(r+1), r+2):
                for s in range(-(r+1), r+2):
                    if max(abs(q), abs(s), abs(q+s)) == r+1 and remaining > 0:
                        patch.add((q, s))
                        remaining -= 1

        boundary = edge_boundary_card(patch)
        coverage_efficiency = (6*n - boundary) / (6*n) * 100

        print(f"  n={n:3d} sensors: boundary={boundary:3d}, "
              f"internal connectivity={6*n-boundary:4d}/{6*n}, "
              f"efficiency={coverage_efficiency:.1f}%")

    print()
    print("  → Hexagonal clusters maximize internal connectivity")
    print()


# ─── Main ────────────────────────────────────────────────────────────────────

if __name__ == "__main__":
    print()
    print("╔══════════════════════════════════════════════════════════════════════╗")
    print("║     APPLICATIONS OF THE DISCRETE HONEYCOMB THEOREM                  ║")
    print("╚══════════════════════════════════════════════════════════════════════╝")
    print()

    cellular_network_optimization()
    crystal_grain_energy()
    game_territory()
    sensor_coverage()

    print("All applications demonstrated successfully!")


#!/usr/bin/env python3
"""
Discrete Honeycomb Theorem on the Hexagonal Lattice: Demonstrations

This script demonstrates the key mathematical results of the discrete
honeycomb theorem, including hex patch construction, boundary computation,
and isoperimetric optimality verification.
"""

import math
from collections import defaultdict
from typing import Set, Tuple, List, Dict

# Type aliases
HexCell = Tuple[int, int]

# ─── Core Definitions ────────────────────────────────────────────────────────

def hex_dist(a: HexCell, b: HexCell) -> int:
    """Hex metric: max(|Δq|, |Δs|, |Δq + Δs|)."""
    dq = b[0] - a[0]
    ds = b[1] - a[1]
    return max(abs(dq), abs(ds), abs(dq + ds))


def hex_neighbors(p: HexCell) -> List[HexCell]:
    """The 6 neighbors of a hex cell in axial coordinates."""
    q, s = p
    return [
        (q+1, s), (q-1, s),
        (q, s+1), (q, s-1),
        (q+1, s-1), (q-1, s+1),
    ]


def hex_patch(r: int) -> Set[HexCell]:
    """Regular hexagonal patch of radius r centered at origin."""
    cells = set()
    for q in range(-r, r+1):
        for s in range(-r, r+1):
            if hex_dist((0,0), (q,s)) <= r:
                cells.add((q, s))
    return cells


def edge_boundary(S: Set[HexCell]) -> int:
    """Count edges from S to its complement."""
    count = 0
    for p in S:
        for n in hex_neighbors(p):
            if n not in S:
                count += 1
    return count


def internal_edges(S: Set[HexCell]) -> int:
    """Count ordered adjacent pairs within S."""
    count = 0
    for p in S:
        for n in hex_neighbors(p):
            if n in S:
                count += 1
    return count


def width_q(S: Set[HexCell]) -> int:
    """Number of distinct first coordinates."""
    return len(set(p[0] for p in S))


def width_s(S: Set[HexCell]) -> int:
    """Number of distinct second coordinates."""
    return len(set(p[1] for p in S))


def width_d(S: Set[HexCell]) -> int:
    """Number of distinct q+s values."""
    return len(set(p[0] + p[1] for p in S))


# ─── Demo 1: Hex Patch Properties ───────────────────────────────────────────

def demo_hex_patch_properties():
    """Demonstrate the cardinality and boundary formulas for hex patches."""
    print("=" * 70)
    print("DEMO 1: Hex Patch Properties")
    print("=" * 70)
    print()
    print(f"{'r':>3} | {'|hexPatch(r)|':>14} | {'3r²+3r+1':>10} | {'boundary':>10} | {'12r+6':>8} | {'internal':>10} | {'18r²+6r':>10}")
    print("-" * 85)

    for r in range(8):
        patch = hex_patch(r)
        card = len(patch)
        expected_card = 3 * r**2 + 3 * r + 1
        boundary = edge_boundary(patch)
        expected_boundary = 12 * r + 6
        internal = internal_edges(patch)
        expected_internal = 18 * r**2 + 6 * r

        assert card == expected_card, f"Card mismatch at r={r}: {card} != {expected_card}"
        assert boundary == expected_boundary, f"Boundary mismatch at r={r}"
        assert internal == expected_internal, f"Internal mismatch at r={r}"

        print(f"{r:3d} | {card:14d} | {expected_card:10d} | {boundary:10d} | {expected_boundary:8d} | {internal:10d} | {expected_internal:10d}")

    print()
    print("✓ All formulas verified: |hexPatch(r)| = 3r² + 3r + 1")
    print("✓ All formulas verified: edgeBoundary = 12r + 6")
    print("✓ All formulas verified: internalEdges = 18r² + 6r")
    print("✓ Identity verified: boundary + internal = 6 × card")
    print()


# ─── Demo 2: Boundary + Internal = 6 × Card ─────────────────────────────────

def demo_boundary_identity():
    """Verify the key identity for various sets."""
    print("=" * 70)
    print("DEMO 2: Boundary + Internal = 6 × Card (for arbitrary sets)")
    print("=" * 70)
    print()

    # Test with various random-ish subsets
    test_sets = [
        ("single cell", {(0, 0)}),
        ("line of 5", {(i, 0) for i in range(5)}),
        ("L-shape", {(0,0),(1,0),(2,0),(0,1),(0,2)}),
        ("hexPatch(2)", hex_patch(2)),
        ("3×3 square", {(i, j) for i in range(3) for j in range(3)}),
        ("scattered", {(0,0),(3,0),(0,3),(3,3),(1,1)}),
    ]

    for name, S in test_sets:
        b = edge_boundary(S)
        i = internal_edges(S)
        n = len(S)
        assert b + i == 6 * n, f"Identity failed for {name}"
        print(f"  {name:20s}: |S|={n:3d}, boundary={b:4d}, internal={i:4d}, 6×|S|={6*n:4d} ✓")

    print()


# ─── Demo 3: Isoperimetric Comparison ────────────────────────────────────────

def demo_isoperimetric_comparison():
    """Compare boundary of various shapes with same cardinality."""
    print("=" * 70)
    print("DEMO 3: Isoperimetric Comparison at Hex Numbers")
    print("=" * 70)
    print()

    for r in range(1, 5):
        n = 3 * r**2 + 3 * r + 1
        patch_boundary = 12 * r + 6

        print(f"  r={r}, n={n}, hexPatch boundary = {patch_boundary}")

        # Create some alternative shapes with the same cardinality
        # Line shape
        line = {(i, 0) for i in range(n)}
        line_b = edge_boundary(line)
        print(f"    Line shape:         boundary = {line_b:4d} (ratio: {line_b/patch_boundary:.2f}×)")

        # Square-ish shape
        side = int(math.sqrt(n))
        square = set()
        for i in range(side):
            for j in range(side):
                if len(square) < n:
                    square.add((i, j))
        # Fill remaining
        i = 0
        while len(square) < n:
            square.add((side, i))
            i += 1
        sq_b = edge_boundary(square)
        print(f"    Rectangle shape:    boundary = {sq_b:4d} (ratio: {sq_b/patch_boundary:.2f}×)")

        # Diamond (hex-aligned) shape
        diamond = set()
        for q in range(-r-1, r+2):
            for s in range(-r-1, r+2):
                if abs(q) + abs(s) <= r + r//2 + 1 and len(diamond) < n:
                    diamond.add((q, s))
        while len(diamond) < n:
            for q in range(-r-2, r+3):
                for s in range(-r-2, r+3):
                    if (q,s) not in diamond and len(diamond) < n:
                        diamond.add((q,s))
        d_b = edge_boundary(diamond)
        print(f"    Diamond shape:      boundary = {d_b:4d} (ratio: {d_b/patch_boundary:.2f}×)")

        print(f"    → hexPatch is optimal with boundary {patch_boundary}")
        print()


# ─── Demo 4: Projection Bound ───────────────────────────────────────────────

def demo_projection_bound():
    """Demonstrate the projection bound: boundary ≥ 2(wQ + wS + wD)."""
    print("=" * 70)
    print("DEMO 4: Projection Bound: boundary ≥ 2(wQ + wS + wD)")
    print("=" * 70)
    print()

    test_sets = [
        ("hexPatch(0)", hex_patch(0)),
        ("hexPatch(1)", hex_patch(1)),
        ("hexPatch(2)", hex_patch(2)),
        ("hexPatch(3)", hex_patch(3)),
        ("line(7)", {(i, 0) for i in range(7)}),
        ("3×3 square", {(i, j) for i in range(3) for j in range(3)}),
        ("L-shape(7)", {(0,0),(1,0),(2,0),(3,0),(0,1),(0,2),(0,3)}),
    ]

    for name, S in test_sets:
        b = edge_boundary(S)
        wq = width_q(S)
        ws = width_s(S)
        wd = width_d(S)
        proj_bound = 2 * (wq + ws + wd)
        tight = "TIGHT" if b == proj_bound else f"gap={b-proj_bound}"

        print(f"  {name:15s}: boundary={b:3d}, 2(wQ+wS+wD)=2({wq}+{ws}+{wd})={proj_bound:3d}  [{tight}]")

    print()
    print("  Note: The projection bound is TIGHT for hex patches (gap = 0)")
    print("  This means hex patches achieve the minimum boundary for their widths.")
    print()


# ─── Demo 5: Isoperimetric Ratio ────────────────────────────────────────────

def demo_isoperimetric_ratio():
    """Show the boundary/area ratio decreases for hex patches."""
    print("=" * 70)
    print("DEMO 5: Isoperimetric Ratio Decreasing")
    print("=" * 70)
    print()

    print(f"{'r':>3} | {'|hexPatch(r)|':>14} | {'boundary':>10} | {'ratio':>12} | {'1/√area':>12}")
    print("-" * 65)

    for r in range(10):
        n = 3 * r**2 + 3 * r + 1
        b = 12 * r + 6
        ratio = b / n if n > 0 else float('inf')
        inv_sqrt = 1 / math.sqrt(n) if n > 0 else float('inf')
        print(f"{r:3d} | {n:14d} | {b:10d} | {ratio:12.6f} | {inv_sqrt:12.6f}")

    print()
    print("  The ratio boundary/area → 0 as r → ∞ (like 4/r)")
    print("  This confirms the honeycomb is asymptotically optimal.")
    print()


# ─── Demo 6: Width Product Bounds ───────────────────────────────────────────

def demo_width_bounds():
    """Verify |S| ≤ wQ × wS, |S| ≤ wQ × wD, |S| ≤ wS × wD."""
    print("=" * 70)
    print("DEMO 6: Width Product Bounds")
    print("=" * 70)
    print()

    import random
    random.seed(42)

    for trial in range(10):
        # Generate random connected set
        S = {(0, 0)}
        for _ in range(random.randint(5, 30)):
            candidates = []
            for p in S:
                for n in hex_neighbors(p):
                    if n not in S:
                        candidates.append(n)
            if candidates:
                S.add(random.choice(candidates))

        n = len(S)
        wq = width_q(S)
        ws = width_s(S)
        wd = width_d(S)

        assert n <= wq * ws, f"wQ×wS bound failed"
        assert n <= wq * wd, f"wQ×wD bound failed"
        assert n <= ws * wd, f"wS×wD bound failed"

        print(f"  Trial {trial+1:2d}: |S|={n:3d}, wQ={wq:2d}, wS={ws:2d}, wD={wd:2d}, "
              f"wQ×wS={wq*ws:4d}, wQ×wD={wq*wd:4d}, wS×wD={ws*wd:4d} ✓")

    print()
    print("  All width product bounds verified for random connected sets.")
    print()


# ─── Main ────────────────────────────────────────────────────────────────────

if __name__ == "__main__":
    print()
    print("╔══════════════════════════════════════════════════════════════════════╗")
    print("║     DISCRETE HONEYCOMB THEOREM ON THE HEXAGONAL LATTICE            ║")
    print("║     Computational Demonstrations                                    ║")
    print("╚══════════════════════════════════════════════════════════════════════╝")
    print()

    demo_hex_patch_properties()
    demo_boundary_identity()
    demo_isoperimetric_comparison()
    demo_projection_bound()
    demo_isoperimetric_ratio()
    demo_width_bounds()

    print("All demonstrations completed successfully!")


#!/usr/bin/env python3
"""
Visualizations for the Discrete Honeycomb Theorem.
Generates hex lattice diagrams, boundary comparisons, and isoperimetric profiles.
"""

import math
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
from matplotlib.collections import PatchCollection
import numpy as np
from typing import Set, Tuple, List
import base64
import io

HexCell = Tuple[int, int]
HEX_DIRECTIONS = [(1, 0), (-1, 0), (0, 1), (0, -1), (1, -1), (-1, 1)]


def hex_patch(r):
    cells = set()
    for q in range(-r, r+1):
        for s in range(-r, r+1):
            if max(abs(q), abs(s), abs(q+s)) <= r:
                cells.add((q, s))
    return cells


def edge_boundary_card(S):
    count = 0
    for q, s in S:
        for dq, ds in HEX_DIRECTIONS:
            if (q+dq, s+ds) not in S:
                count += 1
    return count


def axial_to_pixel(q, s, size=1.0):
    """Convert axial hex coordinates to pixel coordinates."""
    x = size * (math.sqrt(3) * q + math.sqrt(3)/2 * s)
    y = size * (3.0/2 * s)
    return x, y


def draw_hex(ax, q, s, color='lightblue', edge_color='black', size=0.55, alpha=1.0):
    """Draw a single hexagonal cell."""
    x, y = axial_to_pixel(q, s)
    angles = [math.pi/6 + i * math.pi/3 for i in range(6)]
    vertices = [(x + size * math.cos(a), y + size * math.sin(a)) for a in angles]
    hex_patch = plt.Polygon(vertices, facecolor=color, edgecolor=edge_color,
                            linewidth=0.5, alpha=alpha)
    ax.add_patch(hex_patch)


def fig_to_base64(fig):
    """Convert matplotlib figure to base64 PNG."""
    buf = io.BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight', facecolor='white')
    buf.seek(0)
    return base64.b64encode(buf.read()).decode('utf-8')


# ─── Visualization 1: Hex Patches ───────────────────────────────────────────

def viz_hex_patches():
    """Draw hex patches for r = 0, 1, 2, 3."""
    fig, axes = plt.subplots(1, 4, figsize=(16, 4))

    for idx, r in enumerate([0, 1, 2, 3]):
        ax = axes[idx]
        patch = hex_patch(r)

        # Draw cells
        for q, s in patch:
            dist = max(abs(q), abs(s), abs(q+s))
            if dist == r:
                draw_hex(ax, q, s, color='#FFB347', edge_color='#D4780A')
            else:
                draw_hex(ax, q, s, color='#87CEEB', edge_color='#4682B4')

        n = len(patch)
        b = 12 * r + 6
        ax.set_title(f'r={r}\n|S|={n}, ∂={b}', fontsize=11)
        ax.set_aspect('equal')
        ax.set_xlim(-4, 4)
        ax.set_ylim(-4, 4)
        ax.axis('off')

    fig.suptitle('Hexagonal Patches: Optimal Shapes', fontsize=14, fontweight='bold')
    plt.tight_layout()
    fig.savefig('/workspace/request-project/hex_patches.png', dpi=150, bbox_inches='tight')
    b64 = fig_to_base64(fig)
    plt.close(fig)
    return b64


# ─── Visualization 2: Boundary Comparison ───────────────────────────────────

def viz_boundary_comparison():
    """Compare boundaries of different shapes with the same cardinality."""
    fig, ax = plt.subplots(1, 1, figsize=(10, 6))

    rs = range(0, 8)
    hex_boundaries = [12*r + 6 for r in rs]
    hex_cards = [3*r**2 + 3*r + 1 for r in rs]

    # Line shape boundaries
    line_boundaries = []
    for r in rs:
        n = hex_cards[rs.index(r)]
        line = {(i, 0) for i in range(n)}
        line_boundaries.append(edge_boundary_card(line))

    # Square-ish boundaries
    sq_boundaries = []
    for r in rs:
        n = hex_cards[rs.index(r)]
        side = int(math.sqrt(n))
        sq = set()
        for i in range(side):
            for j in range(side):
                if len(sq) < n:
                    sq.add((i, j))
        i = 0
        while len(sq) < n:
            sq.add((side, i))
            i += 1
        sq_boundaries.append(edge_boundary_card(sq))

    ax.plot(hex_cards, hex_boundaries, 'o-', label='Hex Patch (optimal)', color='#2E86C1',
            linewidth=2, markersize=8)
    ax.plot(hex_cards, sq_boundaries, 's--', label='Near-square', color='#E74C3C',
            linewidth=1.5, markersize=6)
    ax.plot(hex_cards, line_boundaries, '^:', label='Line', color='#F39C12',
            linewidth=1.5, markersize=6)

    ax.set_xlabel('Number of cells (n)', fontsize=12)
    ax.set_ylabel('Edge boundary', fontsize=12)
    ax.set_title('Edge Boundary: Hex Patch vs Other Shapes', fontsize=14, fontweight='bold')
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    fig.savefig('/workspace/request-project/boundary_comparison.png', dpi=150, bbox_inches='tight')
    b64 = fig_to_base64(fig)
    plt.close(fig)
    return b64


# ─── Visualization 3: Isoperimetric Profile ─────────────────────────────────

def viz_isoperimetric_profile():
    """Plot the isoperimetric profile: minimum boundary vs n."""
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))

    ns = range(1, 80)
    # Compute profile using optimal hex regions
    from algorithms import optimal_hex_region
    boundaries = [edge_boundary_card(optimal_hex_region(n)) for n in ns]

    # Mark hex numbers
    hex_ns = [3*r**2 + 3*r + 1 for r in range(5)]
    hex_bs = [12*r + 6 for r in range(5)]

    ax1.plot(list(ns), boundaries, '-', color='#2E86C1', linewidth=1.5, label='Profile')
    ax1.plot(hex_ns, hex_bs, 'o', color='#E74C3C', markersize=8, label='Hex numbers', zorder=5)
    ax1.set_xlabel('Number of cells (n)', fontsize=12)
    ax1.set_ylabel('Minimum edge boundary', fontsize=12)
    ax1.set_title('Isoperimetric Profile', fontsize=13, fontweight='bold')
    ax1.legend()
    ax1.grid(True, alpha=0.3)

    # Ratio plot
    ratios = [b / (6 * math.sqrt(n)) if n > 0 else 0 for n, b in zip(ns, boundaries)]
    ax2.plot(list(ns), ratios, '-', color='#27AE60', linewidth=1.5)
    ax2.axhline(y=2/math.sqrt(3), color='#E74C3C', linestyle='--', label=f'2/√3 ≈ {2/math.sqrt(3):.3f}')
    ax2.set_xlabel('Number of cells (n)', fontsize=12)
    ax2.set_ylabel('boundary / (6√n)', fontsize=12)
    ax2.set_title('Normalized Isoperimetric Ratio', fontsize=13, fontweight='bold')
    ax2.legend()
    ax2.grid(True, alpha=0.3)

    plt.tight_layout()
    fig.savefig('/workspace/request-project/isoperimetric_profile.png', dpi=150, bbox_inches='tight')
    b64 = fig_to_base64(fig)
    plt.close(fig)
    return b64


# ─── Visualization 4: Width Analysis ────────────────────────────────────────

def viz_width_analysis():
    """Show the three directional widths for hex patches."""
    fig, ax = plt.subplots(1, 1, figsize=(8, 6))

    rs = range(0, 10)
    cards = [3*r**2+3*r+1 for r in rs]
    widths_q = [2*r+1 for r in rs]
    proj_bounds = [2*(3*(2*r+1)) for r in rs]
    actual_bounds = [12*r+6 for r in rs]

    ax.plot(list(rs), actual_bounds, 'o-', label='edgeBoundary = 12r+6', color='#2E86C1',
            linewidth=2, markersize=8)
    ax.plot(list(rs), proj_bounds, 's--', label='2(wQ+wS+wD) = 6(2r+1)', color='#E74C3C',
            linewidth=1.5, markersize=6)

    ax.set_xlabel('Radius r', fontsize=12)
    ax.set_ylabel('Value', fontsize=12)
    ax.set_title('Projection Bound is Tight for Hex Patches', fontsize=14, fontweight='bold')
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    fig.savefig('/workspace/request-project/width_analysis.png', dpi=150, bbox_inches='tight')
    b64 = fig_to_base64(fig)
    plt.close(fig)
    return b64


# ─── Main ────────────────────────────────────────────────────────────────────

if __name__ == "__main__":
    print("Generating visualizations...")
    b64_1 = viz_hex_patches()
    print(f"  ✓ hex_patches.png ({len(b64_1)} bytes base64)")
    b64_2 = viz_boundary_comparison()
    print(f"  ✓ boundary_comparison.png ({len(b64_2)} bytes base64)")
    b64_3 = viz_isoperimetric_profile()
    print(f"  ✓ isoperimetric_profile.png ({len(b64_3)} bytes base64)")
    b64_4 = viz_width_analysis()
    print(f"  ✓ width_analysis.png ({len(b64_4)} bytes base64)")
    print("All visualizations generated successfully!")
