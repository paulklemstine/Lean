#!/usr/bin/env python3
"""
Infinite Chess: The Hilbert Board — Demonstrations

Numerical examples illustrating the main theorems on king escape
and threat barriers on the infinite board ℤ×ℤ.
"""

from typing import List, Tuple, Set


def cheb_dist(p: Tuple[int, int], q: Tuple[int, int]) -> int:
    """Chebyshev (L∞) distance between two positions."""
    return max(abs(p[0] - q[0]), abs(p[1] - q[1]))


def knight_threats(pos: Tuple[int, int]) -> Set[Tuple[int, int]]:
    """Squares threatened by a knight at the given position."""
    offsets = [(-2, -1), (-2, 1), (-1, -2), (-1, 2),
               (1, -2), (1, 2), (2, -1), (2, 1)]
    return {(pos[0] + dx, pos[1] + dy) for dx, dy in offsets}


def top_edge(center: Tuple[int, int], r: int) -> List[Tuple[int, int]]:
    """Top edge of Chebyshev sphere: points (x, center_y + r)."""
    return [(x, center[1] + r)
            for x in range(center[0] - r, center[0] + r + 1)]


def find_safe_square(threats: Set[Tuple[int, int]],
                     king: Tuple[int, int]) -> Tuple[int, int]:
    """Find the nearest safe square using the escape speed bound."""
    r = len(threats) // 2 + 1
    for x, y in top_edge(king, r):
        if (x, y) not in threats:
            return (x, y)
    # Should never reach here by the Fundamental Escape Inequality
    raise RuntimeError("Escape inequality violated!")


def demo_barrier_incompleteness():
    """Demonstrate that finite knight configurations cannot enclose a king."""
    print("=" * 60)
    print("DEMO 1: Barrier Incompleteness Theorem")
    print("=" * 60)
    print()

    king = (0, 0)

    for n_knights in [1, 4, 8, 16, 32]:
        # Place knights in a ring around the king
        knights = []
        import math
        for i in range(n_knights):
            angle = 2 * math.pi * i / n_knights
            x = round(3 * math.cos(angle))
            y = round(3 * math.sin(angle))
            knights.append((x, y))

        all_threats = set()
        for k in knights:
            all_threats |= knight_threats(k)

        # Check completeness at various radii
        max_complete_r = 0
        for r in range(1, 20):
            sphere = top_edge(king, r)
            if all(sq in all_threats for sq in sphere):
                max_complete_r = r
            else:
                safe = [sq for sq in sphere if sq not in all_threats]
                break

        threat_bound = n_knights * 8
        max_possible_r = (threat_bound - 1) // 2

        print(f"  {n_knights:2d} knights → {len(all_threats):3d} threats, "
              f"max complete radius: {max_complete_r}, "
              f"theoretical max: {max_possible_r}")

    print()
    print("  Key insight: max complete radius stays small even as")
    print("  knights increase, due to placement geometry.\n")


def demo_escape_speed():
    """Demonstrate the escape speed bound."""
    print("=" * 60)
    print("DEMO 2: Escape Speed Bound")
    print("=" * 60)
    print()

    king = (0, 0)

    for n_knights in [1, 2, 4, 8, 16]:
        knights = [(i, 0) for i in range(1, n_knights + 1)]
        all_threats = set()
        for k in knights:
            all_threats |= knight_threats(k)

        safe = find_safe_square(all_threats, king)
        dist = cheb_dist(king, safe)
        bound = len(all_threats) // 2 + 1

        print(f"  {n_knights:2d} knights, {len(all_threats):3d} threats: "
              f"safe at {safe}, dist={dist}, bound={bound}")
        assert dist <= bound, "Escape speed bound violated!"

    print()
    print("  All found within the ⌊T/2⌋+1 bound ✓\n")


def demo_directional_escape():
    """Demonstrate directional escape along rays."""
    print("=" * 60)
    print("DEMO 3: Directional Escape Theorem")
    print("=" * 60)
    print()

    king = (0, 0)
    knights = [(3, 3), (-2, 4), (5, -1), (-3, -3), (1, 7)]
    all_threats = set()
    for k in knights:
        all_threats |= knight_threats(k)

    directions = {
        'NE': lambda n: (n, n),
        'NW': lambda n: (-n, n),
        'SE': lambda n: (n, -n),
        'SW': lambda n: (-n, -n),
    }

    for name, ray_fn in directions.items():
        # Find first n where ray is permanently safe
        last_hit = -1
        for n in range(100):
            if ray_fn(n) in all_threats:
                last_hit = n
        safe_from = last_hit + 1

        print(f"  Direction {name}: safe from n={safe_from} onward")
        # Verify
        for n in range(safe_from, safe_from + 20):
            assert ray_fn(n) not in all_threats

    print("\n  All directions eventually clear ✓\n")


def demo_game_values():
    """Demonstrate the barrier peeling game values."""
    print("=" * 60)
    print("DEMO 4: Barrier Peeling Game Values")
    print("=" * 60)
    print()

    def game_value(n: int) -> int:
        """Game value of position n in the barrier peeling game."""
        if n == 0:
            return 0  # Terminal: no moves
        else:
            return game_value(n - 1) + 1  # Unique move to n-1

    for n in range(11):
        v = game_value(n)
        print(f"  Position {n:2d}: game value = {v}")
        assert v == n, "Game value mismatch!"

    print("\n  All game values match ordinals ✓\n")


def demo_top_edge_growth():
    """Demonstrate the top edge size vs threat count."""
    print("=" * 60)
    print("DEMO 5: Top Edge Growth vs Fixed Threats")
    print("=" * 60)
    print()

    n_knights = 10
    threat_count = n_knights * 8  # Upper bound

    print(f"  {n_knights} knights → ≤{threat_count} threats")
    print(f"  {'Radius r':>10} | {'Top Edge |':>12} | {'Threats ≤':>10} | {'Safe?':>6}")
    print(f"  {'-'*10}-+-{'-'*12}-+-{'-'*10}-+-{'-'*6}")

    for r in range(1, 15):
        edge_size = 2 * r + 1
        has_safe = edge_size > threat_count
        print(f"  {r:>10} | {edge_size:>12} | {threat_count:>10} | "
              f"{'YES' if has_safe else 'no':>6}")

    print()
    print("  Beyond radius (threats-1)/2, safety is guaranteed ✓\n")


if __name__ == "__main__":
    demo_barrier_incompleteness()
    demo_escape_speed()
    demo_directional_escape()
    demo_game_values()
    demo_top_edge_growth()
    print("All demonstrations completed successfully.")


#!/usr/bin/env python3
"""
Visualization: King Escape on the Hilbert Board

Shows the Chebyshev sphere, threat zones, and escape paths
for various piece configurations on the infinite chessboard.
"""
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np
from typing import Set, Tuple, List

Pos = Tuple[int, int]


def cheb_dist(p: Pos, q: Pos) -> int:
    return max(abs(p[0] - q[0]), abs(p[1] - q[1]))


def knight_threats(pos: Pos) -> Set[Pos]:
    offsets = [(-2, -1), (-2, 1), (-1, -2), (-1, 2),
               (1, -2), (1, 2), (2, -1), (2, 1)]
    return {(pos[0] + dx, pos[1] + dy) for dx, dy in offsets}


def chebyshev_sphere(center: Pos, r: int) -> List[Pos]:
    if r == 0:
        return [center]
    result = []
    cx, cy = center
    for x in range(cx - r, cx + r + 1):
        result.append((x, cy + r))
        result.append((x, cy - r))
    for y in range(cy - r + 1, cy + r):
        result.append((cx - r, y))
        result.append((cx + r, y))
    return result


def top_edge(center: Pos, r: int) -> List[Pos]:
    return [(x, center[1] + r)
            for x in range(center[0] - r, center[0] + r + 1)]


def plot_escape_scenario():
    """Plot a king escape scenario with knights on the infinite board."""
    fig, axes = plt.subplots(1, 2, figsize=(16, 8))

    king = (0, 0)
    knights = [(3, 1), (-2, 3), (4, -2), (-3, -2), (1, 5)]

    all_threats: Set[Pos] = set()
    for k in knights:
        all_threats |= knight_threats(k)

    # Find escape radius
    T = len(all_threats)
    escape_r = T // 2 + 1

    # Panel 1: Threat map
    ax = axes[0]
    ax.set_title(f'Knight Threats on the Hilbert Board\n'
                 f'{len(knights)} knights, {T} threatened squares',
                 fontsize=12, fontweight='bold')

    view = 10
    # Draw grid
    for x in range(-view, view + 1):
        ax.axvline(x, color='lightgray', linewidth=0.3)
    for y in range(-view, view + 1):
        ax.axhline(y, color='lightgray', linewidth=0.3)

    # Draw threats
    for sq in all_threats:
        if -view <= sq[0] <= view and -view <= sq[1] <= view:
            ax.add_patch(plt.Rectangle((sq[0] - 0.4, sq[1] - 0.4),
                                        0.8, 0.8, color='red', alpha=0.3))

    # Draw knights
    for k in knights:
        ax.plot(k[0], k[1], 'kx', markersize=12, markeredgewidth=2)
        ax.annotate('♞', (k[0], k[1]), fontsize=16, ha='center', va='center')

    # Draw king
    ax.plot(king[0], king[1], 'bo', markersize=12)
    ax.annotate('♔', (king[0], king[1]), fontsize=18, ha='center', va='center',
                color='blue')

    # Draw Chebyshev spheres
    for r in [3, 5, 7]:
        sphere = chebyshev_sphere(king, r)
        xs = [p[0] for p in sphere]
        ys = [p[1] for p in sphere]
        # Draw as diamond
        corners = [(king[0], king[1] + r), (king[0] + r, king[1]),
                   (king[0], king[1] - r), (king[0] - r, king[1]),
                   (king[0], king[1] + r)]
        cx = [c[0] for c in corners]
        cy = [c[1] for c in corners]
        ax.plot(cx, cy, '--', alpha=0.4, linewidth=1, label=f'r={r}')

    ax.set_xlim(-view - 0.5, view + 0.5)
    ax.set_ylim(-view - 0.5, view + 0.5)
    ax.set_aspect('equal')
    ax.legend(loc='upper right', fontsize=8)

    # Panel 2: Top edge analysis
    ax = axes[1]
    radii = list(range(1, 16))
    top_edge_sizes = [2 * r + 1 for r in radii]
    safe_counts = []

    for r in radii:
        edge = top_edge(king, r)
        safe = sum(1 for sq in edge if sq not in all_threats)
        safe_counts.append(safe)

    ax.bar([r - 0.2 for r in radii], top_edge_sizes, 0.4,
           label='Top edge size (2r+1)', color='steelblue', alpha=0.7)
    ax.bar([r + 0.2 for r in radii], safe_counts, 0.4,
           label='Safe on top edge', color='green', alpha=0.7)
    ax.axhline(T, color='red', linestyle='--', alpha=0.7,
               label=f'Total threats ({T})')

    ax.set_xlabel('Radius r', fontsize=12)
    ax.set_ylabel('Count', fontsize=12)
    ax.set_title('Fundamental Escape Inequality\n'
                 'When 2r+1 > threats, safe squares exist',
                 fontsize=12, fontweight='bold')
    ax.legend(fontsize=9)

    plt.tight_layout()
    plt.savefig('escape_visualization.png', dpi=150, bbox_inches='tight')
    print("Saved escape_visualization.png")


if __name__ == "__main__":
    plot_escape_scenario()
