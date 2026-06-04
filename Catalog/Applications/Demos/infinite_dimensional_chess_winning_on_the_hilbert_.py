#!/usr/bin/env python3
"""
Infinite-Dimensional Chess: The Hilbert Board
==============================================
Demonstrates key results from the formalization:
1. Knight attack coverage vs king neighborhood size across dimensions
2. Rook escape phase transition at d=2
3. Bishop parity preservation
4. Escape radius computation
"""

import itertools
from typing import List, Tuple, Set, Dict


def knight_attacks_2d(src: Tuple[int, int]) -> Set[Tuple[int, int]]:
    """Standard 2D knight attacks."""
    x, y = src
    offsets = [(1, 2), (2, 1), (-1, 2), (-2, 1),
               (1, -2), (2, -1), (-1, -2), (-2, -1)]
    return {(x + dx, y + dy) for dx, dy in offsets}


def knight_attacks_nd(src: Tuple[int, ...], d: int) -> Set[Tuple[int, ...]]:
    """Generalized knight attacks in d dimensions."""
    attacks = set()
    for i in range(d):
        for j in range(d):
            if i == j:
                continue
            for si in [1, -1]:
                for sj in [1, -1]:
                    tgt = list(src)
                    tgt[i] += si * 1
                    tgt[j] += sj * 2
                    attacks.add(tuple(tgt))
    return attacks


def knight_attack_count(d: int) -> int:
    """Number of squares attacked by a single knight in d dimensions."""
    origin = tuple([0] * d)
    return len(knight_attacks_nd(origin, d))


def king_neighborhood_size(d: int, r: int) -> int:
    """Number of positions within Chebyshev distance r in d dimensions."""
    return (2 * r + 1) ** d


def bishop_color(pos: Tuple[int, ...]) -> int:
    """Square color: parity of coordinate sum."""
    return sum(pos) % 2


def bishop_attacks_nd(src: Tuple[int, ...], d: int, max_dist: int = 3) -> Set[Tuple[int, ...]]:
    """Bishop attacks in d dimensions (diagonal moves)."""
    attacks = set()
    for i in range(d):
        for j in range(i + 1, d):
            for k in range(1, max_dist + 1):
                for si in [1, -1]:
                    for sj in [1, -1]:
                        tgt = list(src)
                        tgt[i] += si * k
                        tgt[j] += sj * k
                        attacks.add(tuple(tgt))
    return attacks


def compute_escape_radius(knights: List[Tuple[int, ...]], d: int, max_r: int = 20) -> int:
    """Compute minimum Chebyshev distance from origin to nearest safe square."""
    all_attacks = set()
    for k in knights:
        all_attacks |= knight_attacks_nd(k, d)

    for r in range(max_r + 1):
        # Check if there's a safe square at exactly distance r from origin
        for pos in itertools.product(range(-r, r + 1), repeat=d):
            if max(abs(c) for c in pos) == r:
                if tuple(pos) not in all_attacks:
                    return r
    return max_r + 1


def demo_knight_coverage():
    """Demo 1: Knight attack count grows quadratically, king neighborhood exponentially."""
    print("=" * 60)
    print("DEMO 1: Knight Coverage vs King Neighborhood")
    print("=" * 60)
    print(f"{'Dim d':>6} {'Knight attacks':>15} {'King r=1':>10} {'King r=2':>10} {'Ratio (r=2)':>12}")
    print("-" * 60)

    for d in range(2, 11):
        attacks = knight_attack_count(d)
        king_r1 = king_neighborhood_size(d, 1) - 1  # subtract king's own square
        king_r2 = king_neighborhood_size(d, 2) - 1
        ratio = attacks / king_r2 if king_r2 > 0 else float('inf')
        print(f"{d:>6} {attacks:>15} {king_r1:>10} {king_r2:>10} {ratio:>12.6f}")

    print("\nKey insight: ratio → 0 as d → ∞ (exponential vs quadratic)")


def demo_rook_phase_transition():
    """Demo 2: Rook escape phase transition at d=2."""
    print("\n" + "=" * 60)
    print("DEMO 2: Rook Escape Phase Transition")
    print("=" * 60)

    print("\nd=1: Rook at origin attacks ALL other positions")
    print("  Position (1,): attacked? True (only 1 axis, agreement vacuous)")
    print("  Position (5,): attacked? True")
    print("  Position (-3,): attacked? True")
    print("  → NO safe squares exist (proved: rook_1d_attacks_all)")

    print("\nd=2: Rook at (0,0)")
    rook_2d = (0, 0)
    test_positions = [(1, 1), (0, 5), (3, 0), (2, 7)]
    for pos in test_positions:
        # A rook attacks if they agree on all but one coordinate
        same_x = (pos[0] == rook_2d[0])
        same_y = (pos[1] == rook_2d[1])
        attacked = same_x or same_y
        safe_reason = "differs on both axes" if not attacked else f"shares {'x' if same_x else 'y'}-axis"
        print(f"  Position {pos}: {'ATTACKED' if attacked else 'SAFE'} ({safe_reason})")

    print("\n  → Safe squares exist for d≥2 (proved: rooks_leave_safe)")
    print("  → Phase transition: d=1 → no escape; d=2 → guaranteed escape")


def demo_bishop_parity():
    """Demo 3: Bishop parity preservation in multiple dimensions."""
    print("\n" + "=" * 60)
    print("DEMO 3: Bishop Parity Preservation")
    print("=" * 60)

    for d in [2, 3, 4]:
        origin = tuple([0] * d)
        attacks = bishop_attacks_nd(origin, d)
        colors = {bishop_color(a) for a in attacks}
        origin_color = bishop_color(origin)
        all_same = all(bishop_color(a) == origin_color for a in attacks)
        print(f"\n  d={d}: Origin {origin} has color {origin_color}")
        print(f"    Bishop attacks {len(attacks)} squares")
        print(f"    All attacked squares have same color as origin? {all_same}")
        if attacks:
            sample = list(attacks)[:5]
            for s in sample:
                print(f"      {s} → color {bishop_color(s)}")
    print("\n  → Bishop preserves parity in ALL dimensions (proved: bishop_preserves_parity)")


def demo_escape_radius():
    """Demo 4: Escape radius computation."""
    print("\n" + "=" * 60)
    print("DEMO 4: Knight Escape Radius")
    print("=" * 60)

    # 2D examples
    print("\n  2D board with increasing numbers of knights at origin:")
    for n in range(1, 7):
        knights = [(0, 0)] * n  # n knights at the same position
        r = compute_escape_radius(knights, 2)
        print(f"    {n} knight(s) at origin: escape radius = {r}")

    # Varying dimension with 1 knight
    print("\n  1 knight at origin in varying dimensions:")
    for d in range(2, 7):
        origin = tuple([0] * d)
        r = compute_escape_radius([origin], d, max_r=5)
        print(f"    d={d}: escape radius = {r}")


def demo_dimensional_comparison():
    """Demo 5: Escape gets easier in higher dimensions."""
    print("\n" + "=" * 60)
    print("DEMO 5: Dimensional Comparison")
    print("=" * 60)

    print(f"\n{'Dim':>5} {'Knight attacks':>15} {'Fraction of r=3 ball':>22}")
    print("-" * 45)
    for d in range(2, 9):
        attacks = knight_attack_count(d)
        ball_size = king_neighborhood_size(d, 3)
        fraction = attacks / ball_size
        print(f"{d:>5} {attacks:>15} {fraction:>22.8f}")

    print("\n  The fraction of the Chebyshev ball attacked by one knight")
    print("  decays exponentially with dimension.")
    print("  → In high dimensions, the knight is negligible.")


if __name__ == "__main__":
    demo_knight_coverage()
    demo_rook_phase_transition()
    demo_bishop_parity()
    demo_escape_radius()
    demo_dimensional_comparison()
    print("\n" + "=" * 60)
    print("All demos completed successfully.")
    print("=" * 60)


#!/usr/bin/env python3
"""
Visualization: Knight Attack Coverage vs Dimension
Shows how knight coverage becomes negligible in high dimensions.
"""
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np

def knight_attack_count(d: int) -> int:
    """Number of squares attacked by a single knight in d dimensions."""
    return 4 * d * (d - 1)

def king_ball_size(d: int, r: int) -> int:
    """Number of positions in Chebyshev ball of radius r in d dimensions."""
    return (2 * r + 1) ** d

dims = list(range(2, 16))
knight_counts = [knight_attack_count(d) for d in dims]
ball_r2 = [king_ball_size(d, 2) for d in dims]
ball_r3 = [king_ball_size(d, 3) for d in dims]
ratios_r2 = [knight_attack_count(d) / king_ball_size(d, 2) for d in dims]
ratios_r3 = [knight_attack_count(d) / king_ball_size(d, 3) for d in dims]

fig, axes = plt.subplots(1, 3, figsize=(18, 5))

# Plot 1: Attack count vs ball size (log scale)
ax1 = axes[0]
ax1.semilogy(dims, knight_counts, 'ro-', linewidth=2, markersize=6, label='Knight attacks')
ax1.semilogy(dims, ball_r2, 'bs-', linewidth=2, markersize=6, label='King ball (r=2)')
ax1.semilogy(dims, ball_r3, 'g^-', linewidth=2, markersize=6, label='King ball (r=3)')
ax1.set_xlabel('Dimension d', fontsize=12)
ax1.set_ylabel('Count (log scale)', fontsize=12)
ax1.set_title('Knight Attacks vs King Neighborhood', fontsize=13)
ax1.legend(fontsize=10)
ax1.grid(True, alpha=0.3)

# Plot 2: Attack density ratio
ax2 = axes[1]
ax2.semilogy(dims, ratios_r2, 'bs-', linewidth=2, markersize=6, label='Ratio (r=2)')
ax2.semilogy(dims, ratios_r3, 'g^-', linewidth=2, markersize=6, label='Ratio (r=3)')
ax2.set_xlabel('Dimension d', fontsize=12)
ax2.set_ylabel('Attack Density Ratio', fontsize=12)
ax2.set_title('Attack Density: knight/ball → 0 as d→∞', fontsize=13)
ax2.legend(fontsize=10)
ax2.grid(True, alpha=0.3)
ax2.axhline(y=0.01, color='gray', linestyle='--', alpha=0.5, label='1% threshold')

# Plot 3: Rook phase transition
ax3 = axes[2]
d_vals = [1, 2, 3, 4, 5]
rook_escape_possible = [0, 1, 1, 1, 1]  # 0 = no escape, 1 = escape possible
colors = ['red' if x == 0 else 'green' for x in rook_escape_possible]
bars = ax3.bar(d_vals, rook_escape_possible, color=colors, alpha=0.7, edgecolor='black')
ax3.set_xlabel('Dimension d', fontsize=12)
ax3.set_ylabel('Escape Possible', fontsize=12)
ax3.set_title('Rook Escape: Phase Transition at d=2', fontsize=13)
ax3.set_xticks(d_vals)
ax3.set_yticks([0, 1])
ax3.set_yticklabels(['No', 'Yes'])
ax3.annotate('Phase\nTransition', xy=(1.5, 0.5), fontsize=11,
            ha='center', color='purple', fontweight='bold',
            arrowprops=dict(arrowstyle='->', color='purple'),
            xytext=(1.5, 0.8))

plt.tight_layout()
plt.savefig('hilbert_board_analysis.png', dpi=150, bbox_inches='tight')
print("Saved: hilbert_board_analysis.png")
