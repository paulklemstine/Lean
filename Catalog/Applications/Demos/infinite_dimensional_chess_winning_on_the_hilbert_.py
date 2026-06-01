#!/usr/bin/env python3
"""
Demo: Infinite Chess on the Hilbert Board

Demonstrates key results from the infinite chess formalization:
1. Chebyshev distance properties
2. Knight attack coverage and escape
3. Rook line avoidance
4. Bishop color invariant
5. Escape configuration analysis
6. Knight escape bound conjecture testing
"""

from algorithms import (
    chebyshev_dist, king_neighbors, knight_targets, attacked_set,
    escape_radius, find_nearest_safe, construct_king_path,
    rook_attack_lines, find_rook_safe, square_color,
    verify_knight_escape_conjecture, EscapeConfig
)


def demo_chebyshev_distance():
    """Demonstrate Chebyshev distance properties."""
    print("=" * 60)
    print("1. CHEBYSHEV DISTANCE (King Metric)")
    print("=" * 60)

    pairs = [((0, 0), (3, 5)), ((0, 0), (4, 4)), ((1, 1), (1, 1)),
             ((-2, 3), (5, -1))]

    for p, q in pairs:
        d = chebyshev_dist(p, q)
        path = construct_king_path(p, q)
        print(f"  d({p}, {q}) = {d}  (path length: {len(path)-1} moves)")

    # Triangle inequality
    print("\n  Triangle inequality verification:")
    p, q, r = (0, 0), (3, 1), (5, 5)
    dpq = chebyshev_dist(p, q)
    dqr = chebyshev_dist(q, r)
    dpr = chebyshev_dist(p, r)
    print(f"  d({p},{r}) = {dpr} ≤ d({p},{q}) + d({q},{r}) = {dpq} + {dqr} = {dpq+dqr}  ✓")
    print()


def demo_knight_attacks():
    """Demonstrate knight attack finiteness and escape."""
    print("=" * 60)
    print("2. KNIGHT ATTACKS AND ESCAPE")
    print("=" * 60)

    # Single knight
    knight = (0, 0)
    targets = knight_targets(knight)
    print(f"  Knight at {knight} attacks {len(targets)} squares:")
    print(f"    {sorted(targets)}")

    # Multiple knights
    for n_knights in [1, 3, 5, 8]:
        knights = [(i * 3, i * 2) for i in range(n_knights)]
        attacks = attacked_set(knights)
        print(f"\n  {n_knights} knight(s): {len(attacks)} total attacked squares")
        print(f"    Ratio: {len(attacks)}/{n_knights*8} = {len(attacks)/(n_knights*8):.2f} "
              f"(overlap factor)")

    # Escape analysis
    print("\n  Escape analysis:")
    king = (0, 0)
    knights = [(2, 1), (-1, 2), (1, -2)]
    attacks = attacked_set(knights)
    safe, dist = find_nearest_safe(king, knights)
    radius = escape_radius(king, knights)
    print(f"    King at {king}, {len(knights)} knights")
    print(f"    Attacked squares near king: "
          f"{sum(1 for n in king_neighbors(king) if n in attacks)}/8")
    print(f"    Nearest safe square: {safe} (distance {dist})")
    print(f"    Escape radius bound: {radius}")
    print()


def demo_rook_avoidance():
    """Demonstrate rook line avoidance."""
    print("=" * 60)
    print("3. ROOK LINE AVOIDANCE")
    print("=" * 60)

    for n_rooks in [1, 5, 10, 50]:
        rooks = [(i * 7 + 1, i * 11 + 3) for i in range(n_rooks)]
        rows, cols = rook_attack_lines(rooks)
        safe = find_rook_safe(rooks)
        print(f"  {n_rooks} rook(s): {len(rows)} rows + {len(cols)} cols covered")
        print(f"    Safe position: {safe}")

    print(f"\n  Key insight: n rooks cover only 2n lines, leaving ∞ safe positions")
    print()


def demo_bishop_coloring():
    """Demonstrate bishop color invariant."""
    print("=" * 60)
    print("4. BISHOP COLOR INVARIANT")
    print("=" * 60)

    bishop = (3, 4)
    bishop_color = square_color(bishop)
    print(f"  Bishop at {bishop}, color = {bishop_color} "
          f"({'dark' if bishop_color else 'light'})")

    # Check that all diagonal squares have the same color
    diag_squares = [(3+d, 4+d) for d in range(-5, 6) if d != 0]
    anti_diag = [(3+d, 4-d) for d in range(-5, 6) if d != 0]
    all_diag = diag_squares + anti_diag

    same = sum(1 for s in all_diag if square_color(s) == bishop_color)
    print(f"  Diagonal squares with same color: {same}/{len(all_diag)} "
          f"({'all match!' if same == len(all_diag) else 'MISMATCH!'})")

    # Count safe squares in a region
    region_size = 10
    total = 0
    safe = 0
    for x in range(-region_size, region_size + 1):
        for y in range(-region_size, region_size + 1):
            total += 1
            if square_color((x, y)) != bishop_color:
                safe += 1
    print(f"  In {2*region_size+1}×{2*region_size+1} region: "
          f"{safe}/{total} squares safe by color alone "
          f"({safe/total*100:.1f}%)")
    print()


def demo_escape_config():
    """Demonstrate the Escape Configuration structure."""
    print("=" * 60)
    print("5. ESCAPE CONFIGURATION")
    print("=" * 60)

    configs = [
        ("Single knight", (0, 0), [(2, 1)]),
        ("Ring of knights", (0, 0), [(2, 1), (-2, 1), (2, -1), (-2, -1)]),
        ("Dense cluster", (0, 0), [(1, 2), (2, 1), (-1, 2), (-2, 1),
                                    (1, -2), (2, -1), (-1, -2), (-2, -1)]),
    ]

    for name, king, knights in configs:
        cfg = EscapeConfig(king, knights)
        print(f"\n  [{name}]")
        print(f"  {cfg.summary()}")
    print()


def demo_conjecture_test():
    """Test the knight escape bound conjecture."""
    print("=" * 60)
    print("6. KNIGHT ESCAPE BOUND CONJECTURE")
    print("=" * 60)

    print("  Conjecture: ≤6 knights → safe square within distance 3")
    print("  Testing with 10,000 random configurations...")

    result = verify_knight_escape_conjecture(max_knights=6, escape_bound=3)
    status = "HOLDS" if result else "DISPROVED"
    print(f"  Result: Conjecture {status} for all tested configurations")

    # Test scaling
    print("\n  Scaling analysis (how escape distance grows with # knights):")
    import random
    random.seed(42)
    for n in [1, 2, 4, 8, 16, 32, 64]:
        max_escape = 0
        for _ in range(1000):
            knights = [(random.randint(-10, 10), random.randint(-10, 10))
                       for _ in range(n)]
            _, dist = find_nearest_safe((0, 0), knights)
            max_escape = max(max_escape, dist)
        print(f"    {n:3d} knights: max escape distance = {max_escape}")
    print()


def main():
    print("\n" + "=" * 60)
    print("  INFINITE CHESS ON THE HILBERT BOARD — DEMO")
    print("=" * 60 + "\n")

    demo_chebyshev_distance()
    demo_knight_attacks()
    demo_rook_avoidance()
    demo_bishop_coloring()
    demo_escape_config()
    demo_conjecture_test()

    print("=" * 60)
    print("  All demos completed successfully.")
    print("=" * 60)


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: Infinite Chess Attack Patterns

Generates a matplotlib visualization of knight attack patterns,
escape radii, and safe squares on the infinite board.
"""

import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np
from typing import List, Tuple, Set

Pos = Tuple[int, int]


def knight_targets(p: Pos) -> List[Pos]:
    x, y = p
    offsets = [(-2, -1), (-2, 1), (-1, -2), (-1, 2),
               (1, -2), (1, 2), (2, -1), (2, 1)]
    return [(x + dx, y + dy) for dx, dy in offsets]


def attacked_set(knights: List[Pos]) -> Set[Pos]:
    result: Set[Pos] = set()
    for k in knights:
        result.update(knight_targets(k))
    return result


def chebyshev_dist(p: Pos, q: Pos) -> int:
    return max(abs(p[0] - q[0]), abs(p[1] - q[1]))


def plot_knight_escape(knights: List[Pos], king: Pos = (0, 0),
                        radius: int = 8, title: str = "Knight Escape Analysis"):
    fig, ax = plt.subplots(1, 1, figsize=(10, 10))

    attacks = attacked_set(knights)

    # Draw board squares
    for x in range(-radius, radius + 1):
        for y in range(-radius, radius + 1):
            color = '#f0d9b5' if (x + y) % 2 == 0 else '#b58863'
            if (x, y) in attacks:
                color = '#ff6b6b'
            elif (x, y) in set(knights):
                color = '#4a4a4a'
            elif (x, y) == king:
                color = '#4ecdc4'
            rect = plt.Rectangle((x - 0.5, y - 0.5), 1, 1,
                                  facecolor=color, edgecolor='#333', linewidth=0.3)
            ax.add_patch(rect)

    # Draw escape radius circle
    max_dist = max((chebyshev_dist(king, a) for a in attacks), default=0)
    esc_radius = max_dist + 1
    for d in [esc_radius]:
        rect = plt.Rectangle((king[0] - d - 0.5, king[1] - d - 0.5),
                              2 * d + 1, 2 * d + 1,
                              facecolor='none', edgecolor='blue',
                              linewidth=2, linestyle='--')
        ax.add_patch(rect)

    # Mark pieces
    for k in knights:
        if -radius <= k[0] <= radius and -radius <= k[1] <= radius:
            ax.text(k[0], k[1], '♞', fontsize=20, ha='center', va='center',
                    color='white', fontweight='bold')

    ax.text(king[0], king[1], '♚', fontsize=22, ha='center', va='center',
            color='#2c3e50', fontweight='bold')

    # Legend
    legend_elements = [
        mpatches.Patch(facecolor='#ff6b6b', label='Attacked'),
        mpatches.Patch(facecolor='#4ecdc4', label='King'),
        mpatches.Patch(facecolor='#4a4a4a', label='Knight'),
        mpatches.Patch(facecolor='#f0d9b5', label='Safe (light)'),
        mpatches.Patch(facecolor='#b58863', label='Safe (dark)'),
        mpatches.Patch(facecolor='none', edgecolor='blue',
                       linestyle='--', label=f'Escape radius = {esc_radius}'),
    ]
    ax.legend(handles=legend_elements, loc='upper right', fontsize=9)

    ax.set_xlim(-radius - 1, radius + 1)
    ax.set_ylim(-radius - 1, radius + 1)
    ax.set_aspect('equal')
    ax.set_title(title, fontsize=14, fontweight='bold')
    ax.set_xlabel('File (x)')
    ax.set_ylabel('Rank (y)')

    plt.tight_layout()
    plt.savefig('knight_escape.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: knight_escape.png")


def plot_attack_density():
    """Plot how attack density scales with number of knights."""
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

    # Left: attack count vs number of knights
    ns = list(range(1, 51))
    import random
    random.seed(42)

    actual_attacks = []
    theoretical_max = []
    for n in ns:
        counts = []
        for _ in range(100):
            knights = [(random.randint(-20, 20), random.randint(-20, 20))
                       for _ in range(n)]
            counts.append(len(attacked_set(knights)))
        actual_attacks.append(np.mean(counts))
        theoretical_max.append(8 * n)

    ax1.plot(ns, actual_attacks, 'b-', linewidth=2, label='Average attacked squares')
    ax1.plot(ns, theoretical_max, 'r--', linewidth=1.5, label='Theoretical max (8n)')
    ax1.fill_between(ns, actual_attacks, theoretical_max, alpha=0.2, color='green',
                     label='Overlap savings')
    ax1.set_xlabel('Number of Knights', fontsize=12)
    ax1.set_ylabel('Attacked Squares', fontsize=12)
    ax1.set_title('Knight Attack Coverage Scaling', fontsize=13, fontweight='bold')
    ax1.legend(fontsize=10)
    ax1.grid(True, alpha=0.3)

    # Right: escape distance vs number of knights
    escape_dists_max = []
    escape_dists_mean = []
    for n in ns:
        dists = []
        for _ in range(200):
            knights = [(random.randint(-10, 10), random.randint(-10, 10))
                       for _ in range(n)]
            attacks = attacked_set(knights)
            # BFS from origin
            from collections import deque
            if (0, 0) not in attacks:
                dists.append(0)
                continue
            visited = {(0, 0)}
            queue = deque([((0, 0), 0)])
            found = False
            while queue:
                pos, d = queue.popleft()
                if pos not in attacks:
                    dists.append(d)
                    found = True
                    break
                for dx in [-1, 0, 1]:
                    for dy in [-1, 0, 1]:
                        if (dx, dy) == (0, 0):
                            continue
                        nb = (pos[0] + dx, pos[1] + dy)
                        if nb not in visited:
                            visited.add(nb)
                            queue.append((nb, d + 1))
            if not found:
                dists.append(0)

        escape_dists_max.append(max(dists) if dists else 0)
        escape_dists_mean.append(np.mean(dists) if dists else 0)

    ax2.plot(ns, escape_dists_max, 'r-', linewidth=2, label='Max escape distance')
    ax2.plot(ns, escape_dists_mean, 'b-', linewidth=2, label='Mean escape distance')
    ax2.axhline(y=3, color='green', linestyle='--', alpha=0.7,
                label='Conjectured bound (≤6 knights)')
    ax2.set_xlabel('Number of Knights', fontsize=12)
    ax2.set_ylabel('Escape Distance', fontsize=12)
    ax2.set_title('Escape Distance Scaling', fontsize=13, fontweight='bold')
    ax2.legend(fontsize=10)
    ax2.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('attack_density.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: attack_density.png")


def plot_bishop_coloring():
    """Visualize the bishop color invariant."""
    fig, ax = plt.subplots(1, 1, figsize=(8, 8))

    bishop = (3, 3)
    radius = 6

    for x in range(-radius, radius + 1):
        for y in range(-radius, radius + 1):
            base_color = '#f0d9b5' if (x + y) % 2 == 0 else '#b58863'
            # Highlight bishop diagonals
            if abs(x - bishop[0]) == abs(y - bishop[1]) and (x, y) != bishop:
                base_color = '#ff9999' if (x + y) % 2 == (bishop[0] + bishop[1]) % 2 else base_color
            # Highlight opposite color squares as safe
            if (x + y) % 2 != (bishop[0] + bishop[1]) % 2:
                base_color = '#99ff99' if (x + y) % 2 != 0 else '#ccffcc'

            rect = plt.Rectangle((x - 0.5, y - 0.5), 1, 1,
                                  facecolor=base_color, edgecolor='#333', linewidth=0.3)
            ax.add_patch(rect)

    ax.text(bishop[0], bishop[1], '♝', fontsize=24, ha='center', va='center',
            color='#2c3e50')

    legend_elements = [
        mpatches.Patch(facecolor='#ff9999', label='Bishop attacks (same color)'),
        mpatches.Patch(facecolor='#99ff99', label='Safe (opposite color)'),
        mpatches.Patch(facecolor='#f0d9b5', label='Same color, not on diagonal'),
    ]
    ax.legend(handles=legend_elements, loc='upper right', fontsize=9)

    ax.set_xlim(-radius - 1, radius + 1)
    ax.set_ylim(-radius - 1, radius + 1)
    ax.set_aspect('equal')
    ax.set_title('Bishop Color Invariant: Half the Board is Always Safe',
                 fontsize=13, fontweight='bold')
    ax.set_xlabel('File (x)')
    ax.set_ylabel('Rank (y)')

    plt.tight_layout()
    plt.savefig('bishop_coloring.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: bishop_coloring.png")


if __name__ == "__main__":
    # Demo 1: Knight escape from specific configuration
    plot_knight_escape(
        knights=[(2, 1), (-1, 2), (1, -2), (-2, -1)],
        king=(0, 0),
        radius=7,
        title="Knight Escape: 4 Knights vs Lone King"
    )

    # Demo 2: Attack density scaling
    plot_attack_density()

    # Demo 3: Bishop coloring
    plot_bishop_coloring()

    print("\nAll visualizations generated.")
