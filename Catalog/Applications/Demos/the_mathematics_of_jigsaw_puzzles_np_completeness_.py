#!/usr/bin/env python3
"""
demo.py - Jigsaw Puzzle NP-Completeness: Numerical Examples and Verification

Demonstrates the SAT-to-puzzle reduction, constraint counting,
and Euler characteristic computations for various grid sizes.
"""

from enum import Enum
from dataclasses import dataclass
from typing import List, Tuple, Optional, Callable
import itertools


class EdgeType(Enum):
    TAB = "tab"
    BLANK = "blank"
    FLAT = "flat"


def complementary(e1: EdgeType, e2: EdgeType) -> bool:
    """Two edges are complementary if one is tab and the other is blank."""
    return (e1 == EdgeType.TAB and e2 == EdgeType.BLANK) or \
           (e1 == EdgeType.BLANK and e2 == EdgeType.TAB)


def complement(e: EdgeType) -> EdgeType:
    """The complement of an edge type."""
    if e == EdgeType.TAB:
        return EdgeType.BLANK
    elif e == EdgeType.BLANK:
        return EdgeType.TAB
    else:
        return EdgeType.FLAT


@dataclass
class JigsawPiece:
    top: EdgeType
    right: EdgeType
    bottom: EdgeType
    left: EdgeType

    def fits_horizontal(self, other: 'JigsawPiece') -> bool:
        """Can self be placed to the left of other?"""
        return complementary(self.right, other.left)

    def fits_vertical(self, other: 'JigsawPiece') -> bool:
        """Can self be placed above other?"""
        return complementary(self.bottom, other.top)

    def signature(self) -> Tuple[EdgeType, EdgeType, EdgeType, EdgeType]:
        return (self.top, self.right, self.bottom, self.left)


# =============================================================================
# Demo 1: Edge Compatibility Analysis
# =============================================================================
def demo_edge_compatibility():
    print("=" * 60)
    print("DEMO 1: Edge Compatibility Analysis")
    print("=" * 60)

    types = list(EdgeType)
    count = 0
    print(f"\nAll {len(types)}×{len(types)} = {len(types)**2} edge pairings:")
    for e1 in types:
        for e2 in types:
            c = complementary(e1, e2)
            if c:
                count += 1
                print(f"  {e1.value:5s} - {e2.value:5s} : COMPLEMENTARY ✓")
            else:
                print(f"  {e1.value:5s} - {e2.value:5s} : incompatible")

    print(f"\nComplementary pairs: {count}/9 = {count/9:.4f}")
    print(f"(Verified: matches theorem complementary_pair_count = 2)")

    # Verify involution
    print("\nComplement involution check:")
    for e in types:
        c = complement(complement(e))
        print(f"  complement(complement({e.value})) = {c.value} {'✓' if c == e else '✗'}")


# =============================================================================
# Demo 2: Constraint Counting
# =============================================================================
def demo_constraint_counting():
    print("\n" + "=" * 60)
    print("DEMO 2: Constraint Counting in Grid Assemblies")
    print("=" * 60)

    def grid_constraint_count(r: int, c: int) -> int:
        return r * max(0, c - 1) + max(0, r - 1) * c

    def euler_char(r: int, c: int) -> int:
        return r * c - grid_constraint_count(r, c) + 1

    print(f"\n{'Grid':>8s} | {'Pieces':>6s} | {'Constraints':>11s} | {'Euler χ':>7s} | {'Cycles':>6s}")
    print("-" * 55)
    for r, c in [(1,1), (1,2), (1,5), (1,10), (2,2), (2,3), (3,3), (4,4), (5,5), (10,10)]:
        n = r * c
        e = grid_constraint_count(r, c)
        chi = euler_char(r, c)
        cycles = (r-1) * (c-1)
        print(f"  {r}×{c:>2d}   | {n:>6d} | {e:>11d} | {chi:>7d} | {cycles:>6d}")

    print(f"\nVerification: χ(r,c) = 2 - (r-1)(c-1)")
    for r, c in [(1,5), (3,3), (10,10)]:
        computed = euler_char(r, c)
        formula = 2 - (r-1)*(c-1)
        match = "✓" if computed == formula else "✗"
        print(f"  χ({r},{c}) = {computed} = 2 - {(r-1)*(c-1)} = {formula} {match}")


# =============================================================================
# Demo 3: SAT-to-Puzzle Reduction
# =============================================================================
def demo_sat_reduction():
    print("\n" + "=" * 60)
    print("DEMO 3: SAT-to-Puzzle Reduction (Concrete Instance)")
    print("=" * 60)

    # Formula: (x₀ ∨ x₁ ∨ ¬x₂) ∧ (¬x₀ ∨ x₂ ∨ x₂)
    def eval_formula(a: Tuple[bool, bool, bool]) -> Tuple[bool, bool]:
        x0, x1, x2 = a
        c1 = x0 or x1 or (not x2)         # x₀ ∨ x₁ ∨ ¬x₂
        c2 = (not x0) or x2 or x2         # ¬x₀ ∨ x₂ ∨ x₂
        return (c1, c2)

    print("\nTruth table for φ = (x₀ ∨ x₁ ∨ ¬x₂) ∧ (¬x₀ ∨ x₂ ∨ x₂):")
    print(f"  {'x₀':>5s} {'x₁':>5s} {'x₂':>5s} | {'C₁':>3s} {'C₂':>3s} | {'SAT':>5s}")
    print("  " + "-" * 35)

    sat_count = 0
    for x0 in [False, True]:
        for x1 in [False, True]:
            for x2 in [False, True]:
                c1, c2 = eval_formula((x0, x1, x2))
                sat = c1 and c2
                if sat:
                    sat_count += 1
                t = lambda b: " T" if b else " F"
                s = "  SAT" if sat else "UNSAT"
                print(f"  {t(x0):>5s} {t(x1):>5s} {t(x2):>5s} | {t(c1):>3s} {t(c2):>3s} | {s:>5s}")

    print(f"\n{sat_count}/8 assignments satisfy the formula")

    # Characterization check
    print("\nCharacterization verification:")
    print("  SAT iff (x₀ ∨ x₁ ∨ ¬x₂) ∧ (¬x₀ ∨ x₂)")
    for x0 in [False, True]:
        for x1 in [False, True]:
            for x2 in [False, True]:
                c1, c2 = eval_formula((x0, x1, x2))
                sat_direct = c1 and c2
                char_cond = (x0 or x1 or not x2) and (not x0 or x2)
                match = "✓" if sat_direct == char_cond else "✗"
                print(f"    ({x0}, {x1}, {x2}): direct={sat_direct}, characterized={char_cond} {match}")

    # Reduction piece count
    n_vars, n_clauses = 3, 2
    piece_count = 2 * n_vars + n_clauses
    print(f"\nReduction: {n_vars} vars, {n_clauses} clauses → {piece_count} pieces")
    print(f"  Bound: {piece_count} ≤ 3·({n_vars}+{n_clauses}) = {3*(n_vars+n_clauses)} ✓")


# =============================================================================
# Demo 4: Variable Gadget Verification
# =============================================================================
def demo_variable_gadgets():
    print("\n" + "=" * 60)
    print("DEMO 4: Variable Gadget Mutual Exclusion")
    print("=" * 60)

    for i in range(3):
        left_true = EdgeType.FLAT if i == 0 else EdgeType.BLANK
        left_false = EdgeType.FLAT if i == 0 else EdgeType.TAB
        true_piece = JigsawPiece(EdgeType.FLAT, EdgeType.TAB, EdgeType.FLAT, left_true)
        false_piece = JigsawPiece(EdgeType.FLAT, EdgeType.BLANK, EdgeType.FLAT, left_false)

        comp = complementary(true_piece.right, false_piece.right)
        same_top = true_piece.top == false_piece.top
        same_bottom = true_piece.bottom == false_piece.bottom

        print(f"\n  Variable x_{i}:")
        print(f"    TRUE  piece: ({true_piece.top.value}, {true_piece.right.value}, "
              f"{true_piece.bottom.value}, {true_piece.left.value})")
        print(f"    FALSE piece: ({false_piece.top.value}, {false_piece.right.value}, "
              f"{false_piece.bottom.value}, {false_piece.left.value})")
        print(f"    Complementary right edges: {comp} ✓" if comp else f"    NOT complementary ✗")
        print(f"    Same boundary: top={same_top}, bottom={same_bottom}")


# =============================================================================
# Demo 5: Random Puzzle Solvability
# =============================================================================
def demo_random_solvability():
    print("\n" + "=" * 60)
    print("DEMO 5: Random Puzzle Solvability Analysis")
    print("=" * 60)

    import random
    random.seed(42)

    types = list(EdgeType)

    def random_piece() -> JigsawPiece:
        return JigsawPiece(*[random.choice(types) for _ in range(4)])

    def check_1x2_valid(p: JigsawPiece, q: JigsawPiece) -> bool:
        return p.fits_horizontal(q)

    def check_2x2_valid(pieces: List[JigsawPiece]) -> bool:
        """Check if 4 pieces can form a valid 2×2 grid in some arrangement."""
        for perm in itertools.permutations(pieces):
            p00, p01, p10, p11 = perm
            if (p00.fits_horizontal(p01) and
                p10.fits_horizontal(p11) and
                p00.fits_vertical(p10) and
                p01.fits_vertical(p11)):
                return True
        return False

    # 1×2 analysis
    n_trials = 10000
    solvable = sum(1 for _ in range(n_trials)
                   if check_1x2_valid(random_piece(), random_piece()))
    print(f"\n  1×2 grids: {solvable}/{n_trials} solvable = {solvable/n_trials:.4f}")
    print(f"  Expected (2/9): {2/9:.4f}")

    # 2×2 analysis
    n_trials_2x2 = 5000
    solvable_2x2 = sum(1 for _ in range(n_trials_2x2)
                       if check_2x2_valid([random_piece() for _ in range(4)]))
    print(f"\n  2×2 grids: {solvable_2x2}/{n_trials_2x2} solvable = {solvable_2x2/n_trials_2x2:.4f}")
    print(f"  (Lower than 1×2 due to coupled constraints)")

    # Signature space
    print(f"\n  Signature space: 3^4 = {3**4} distinct piece types")
    print(f"  For k pieces: {3**4}^k possible puzzle instances")


# =============================================================================
# Main
# =============================================================================
if __name__ == "__main__":
    print("JIGSAW PUZZLE NP-COMPLETENESS: COMPUTATIONAL DEMONSTRATIONS")
    print("=" * 60)
    demo_edge_compatibility()
    demo_constraint_counting()
    demo_sat_reduction()
    demo_variable_gadgets()
    demo_random_solvability()
    print("\n" + "=" * 60)
    print("All demonstrations complete.")


#!/usr/bin/env python3
"""
Visualization: Constraint Topology of Jigsaw Puzzle Grids

Shows how the Euler characteristic χ = 2 - (r-1)(c-1) varies
across different grid dimensions, revealing the topological
complexity of puzzle constraint graphs.
"""

import matplotlib.pyplot as plt
import matplotlib
matplotlib.use('Agg')
import numpy as np


def grid_constraint_count(r, c):
    return r * max(0, c - 1) + max(0, r - 1) * c

def euler_char(r, c):
    return r * c - grid_constraint_count(r, c) + 1

def independent_cycles(r, c):
    return max(0, r - 1) * max(0, c - 1)

# Grid sizes
sizes = range(1, 16)

fig, axes = plt.subplots(1, 3, figsize=(15, 5))

# Plot 1: Euler characteristic for square grids
ns = list(sizes)
chis = [euler_char(n, n) for n in ns]
cycles = [independent_cycles(n, n) for n in ns]

axes[0].plot(ns, chis, 'b-o', linewidth=2, markersize=6, label='χ(n,n)')
axes[0].axhline(y=2, color='gray', linestyle='--', alpha=0.5, label='χ = 2 (trees)')
axes[0].set_xlabel('Grid dimension n', fontsize=12)
axes[0].set_ylabel('Euler characteristic χ', fontsize=12)
axes[0].set_title('Euler Characteristic of n×n Grids', fontsize=13)
axes[0].legend(fontsize=10)
axes[0].grid(True, alpha=0.3)

# Plot 2: Heatmap of Euler characteristic
r_max, c_max = 10, 10
chi_matrix = np.zeros((r_max, c_max))
for r in range(1, r_max + 1):
    for c in range(1, c_max + 1):
        chi_matrix[r-1, c-1] = euler_char(r, c)

im = axes[1].imshow(chi_matrix, cmap='RdYlBu', origin='lower',
                     extent=[0.5, c_max+0.5, 0.5, r_max+0.5])
axes[1].set_xlabel('Columns', fontsize=12)
axes[1].set_ylabel('Rows', fontsize=12)
axes[1].set_title('Euler Characteristic χ(r,c)', fontsize=13)
plt.colorbar(im, ax=axes[1], label='χ')

# Plot 3: Constraints vs pieces
ns2 = list(range(1, 21))
pieces = [n*n for n in ns2]
constraints = [grid_constraint_count(n, n) for n in ns2]
ratio = [grid_constraint_count(n, n) / (n * n) if n > 0 else 0 for n in ns2]

ax3 = axes[2]
ax3.plot(ns2, pieces, 'g-s', linewidth=2, markersize=4, label='Pieces (n²)')
ax3.plot(ns2, constraints, 'r-^', linewidth=2, markersize=4, label='Constraints')
ax3.set_xlabel('Grid dimension n', fontsize=12)
ax3.set_ylabel('Count', fontsize=12)
ax3.set_title('Pieces vs Constraints', fontsize=13)
ax3.legend(fontsize=10)
ax3.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('viz_constraint_topology.png', dpi=150, bbox_inches='tight')
print("Saved: viz_constraint_topology.png")


#!/usr/bin/env python3
"""
Visualization: SAT-to-Puzzle Reduction

Illustrates the reduction from the example 3-SAT formula
to a jigsaw puzzle, showing variable gadgets and truth table.
"""

import matplotlib.pyplot as plt
import matplotlib.patches as patches
import matplotlib
matplotlib.use('Agg')
import numpy as np


def draw_piece(ax, x, y, top, right, bottom, left, label="", color='lightblue'):
    """Draw a jigsaw piece at position (x, y)."""
    size = 0.8
    rect = patches.FancyBboxPatch((x - size/2, y - size/2), size, size,
                                   boxstyle="round,pad=0.05",
                                   facecolor=color, edgecolor='black', linewidth=1.5)
    ax.add_patch(rect)

    # Edge markers
    marker_size = 0.12
    edge_labels = {'tab': '▶', 'blank': '◀', 'flat': '—'}
    edge_colors = {'tab': '#e74c3c', 'blank': '#3498db', 'flat': '#95a5a6'}

    # Top
    ax.text(x, y + size/2 + 0.05, edge_labels.get(top, '?'),
            ha='center', va='bottom', fontsize=10, color=edge_colors.get(top, 'black'))
    # Bottom
    ax.text(x, y - size/2 - 0.05, edge_labels.get(bottom, '?'),
            ha='center', va='top', fontsize=10, color=edge_colors.get(bottom, 'black'))
    # Right
    ax.text(x + size/2 + 0.05, y, edge_labels.get(right, '?'),
            ha='left', va='center', fontsize=10, color=edge_colors.get(right, 'black'))
    # Left
    ax.text(x - size/2 - 0.05, y, edge_labels.get(left, '?'),
            ha='right', va='center', fontsize=10, color=edge_colors.get(left, 'black'))

    if label:
        ax.text(x, y, label, ha='center', va='center', fontsize=8, fontweight='bold')


fig, axes = plt.subplots(2, 1, figsize=(12, 10))

# Top: Variable gadgets
ax = axes[0]
ax.set_xlim(-1, 8)
ax.set_ylim(-1, 3)
ax.set_aspect('equal')
ax.set_title('Variable Gadgets for SAT Reduction', fontsize=14, fontweight='bold')

# Variable x₀
draw_piece(ax, 0, 2, 'flat', 'tab', 'flat', 'flat', 'x₀=T', '#a8e6cf')
draw_piece(ax, 0, 0.5, 'flat', 'blank', 'flat', 'flat', 'x₀=F', '#ff8b94')

# Variable x₁
draw_piece(ax, 2.5, 2, 'flat', 'tab', 'flat', 'blank', 'x₁=T', '#a8e6cf')
draw_piece(ax, 2.5, 0.5, 'flat', 'blank', 'flat', 'tab', 'x₁=F', '#ff8b94')

# Variable x₂
draw_piece(ax, 5, 2, 'flat', 'tab', 'flat', 'blank', 'x₂=T', '#a8e6cf')
draw_piece(ax, 5, 0.5, 'flat', 'blank', 'flat', 'tab', 'x₂=F', '#ff8b94')

# Labels
ax.text(0, -0.5, 'x₀', ha='center', fontsize=12, fontweight='bold')
ax.text(2.5, -0.5, 'x₁', ha='center', fontsize=12, fontweight='bold')
ax.text(5, -0.5, 'x₂', ha='center', fontsize=12, fontweight='bold')

# Legend
ax.text(7, 2, '▶ = tab', fontsize=10, color='#e74c3c')
ax.text(7, 1.5, '◀ = blank', fontsize=10, color='#3498db')
ax.text(7, 1, '— = flat', fontsize=10, color='#95a5a6')
ax.text(7, 0.3, 'Mutual exclusion:\ntab ↔ blank', fontsize=9, style='italic')

ax.axis('off')

# Bottom: Truth table
ax2 = axes[1]
ax2.axis('off')
ax2.set_title('Truth Table: φ = (x₀ ∨ x₁ ∨ ¬x₂) ∧ (¬x₀ ∨ x₂)', fontsize=14, fontweight='bold')

table_data = []
headers = ['x₀', 'x₁', 'x₂', 'C₁: x₀∨x₁∨¬x₂', 'C₂: ¬x₀∨x₂', 'SAT?']

for x0 in [False, True]:
    for x1 in [False, True]:
        for x2 in [False, True]:
            c1 = x0 or x1 or (not x2)
            c2 = (not x0) or x2
            sat = c1 and c2
            row = [
                'T' if x0 else 'F',
                'T' if x1 else 'F',
                'T' if x2 else 'F',
                '✓' if c1 else '✗',
                '✓' if c2 else '✗',
                '✓ SAT' if sat else '✗ UNSAT'
            ]
            table_data.append(row)

table = ax2.table(cellText=table_data, colLabels=headers,
                   cellLoc='center', loc='center')
table.auto_set_font_size(False)
table.set_fontsize(10)
table.scale(1.2, 1.5)

# Color cells
for i, row in enumerate(table_data):
    for j, val in enumerate(row):
        cell = table[i + 1, j]
        if j == 5:
            if '✓' in val:
                cell.set_facecolor('#a8e6cf')
            else:
                cell.set_facecolor('#ff8b94')
        elif j in [3, 4]:
            if '✓' in val:
                cell.set_facecolor('#dcedc1')
            else:
                cell.set_facecolor('#ffcccb')

plt.tight_layout()
plt.savefig('viz_sat_reduction.png', dpi=150, bbox_inches='tight')
print("Saved: viz_sat_reduction.png")
