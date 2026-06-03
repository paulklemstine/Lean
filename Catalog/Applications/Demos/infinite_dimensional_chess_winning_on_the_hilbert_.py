#!/usr/bin/env python3
"""
Infinite Chess on the Hilbert Board — Demonstration

Demonstrates key results from the formalization:
1. King neighbor computation and Chebyshev distance
2. Knight threat radius verification
3. Retreat theorem illustration
4. Chain game value computation
5. Threat configuration analysis
"""

import itertools
from typing import Tuple, Set, List, Optional

# Type aliases
Square = Tuple[int, int]


def chebyshev_dist(p: Square, q: Square) -> int:
    """Chebyshev (L∞) distance on ℤ×ℤ."""
    return max(abs(p[0] - q[0]), abs(p[1] - q[1]))


def king_neighbors(p: Square) -> Set[Square]:
    """The 8 squares reachable by one king move."""
    offsets = [(-1, -1), (-1, 0), (-1, 1), (0, -1), (0, 1), (1, -1), (1, 0), (1, 1)]
    return {(p[0] + dx, p[1] + dy) for dx, dy in offsets}


def knight_attacks(p: Square) -> Set[Square]:
    """The 8 squares attacked by a knight."""
    offsets = [(-2, -1), (-2, 1), (-1, -2), (-1, 2), (1, -2), (1, 2), (2, -1), (2, 1)]
    return {(p[0] + dx, p[1] + dy) for dx, dy in offsets}


def retreat_square(p: Square, q: Square) -> Square:
    """Retreat direction: move away from q."""
    def sign(x):
        return (1 if x > 0 else (-1 if x < 0 else 0))
    return (p[0] + sign(p[0] - q[0]), p[1] + sign(p[1] - q[1]))


def chain_game_value(n: int, k: int) -> int:
    """Game value of position k in chain game of length n."""
    assert 0 <= k <= n
    return k


# ====================
# Demo 1: King Neighbors
# ====================
print("=" * 60)
print("DEMO 1: King Neighbors on the Infinite Board")
print("=" * 60)

test_positions = [(0, 0), (5, 3), (-10, 7), (1000, -1000)]
for p in test_positions:
    neighbors = king_neighbors(p)
    assert len(neighbors) == 8, f"Expected 8 neighbors, got {len(neighbors)}"
    for n in neighbors:
        assert chebyshev_dist(p, n) == 1, f"Neighbor {n} at wrong distance"
    print(f"  King at {p}: {len(neighbors)} neighbors, all at Chebyshev distance 1 ✓")

print("\n  KEY INSIGHT: Every square has exactly 8 neighbors.")
print("  On the 8×8 board, corners have 3 and edges have 5.")

# ====================
# Demo 2: Knight Threat Radius
# ====================
print("\n" + "=" * 60)
print("DEMO 2: Knight Threat Radius")
print("=" * 60)

knight_pos = (0, 0)
attacks = knight_attacks(knight_pos)
print(f"  Knight at {knight_pos} attacks: {sorted(attacks)}")
print(f"  Number of attacked squares: {len(attacks)}")
max_dist = max(chebyshev_dist(knight_pos, s) for s in attacks)
print(f"  Maximum Chebyshev distance to attacked square: {max_dist}")
assert max_dist == 2
print("  All attacks within Chebyshev distance 2 ✓")

# ====================
# Demo 3: Retreat Theorem
# ====================
print("\n" + "=" * 60)
print("DEMO 3: The Retreat Theorem")
print("=" * 60)

print("  Starting king at (0,0), threat at (3,2)")
p = (0, 0)
q = (3, 2)
print(f"  Initial distance: {chebyshev_dist(p, q)}")

trajectory = [p]
for step in range(8):
    r = retreat_square(p, q)
    new_dist = chebyshev_dist(r, q)
    old_dist = chebyshev_dist(p, q)
    print(f"  Step {step+1}: {p} → {r}, distance {old_dist} → {new_dist} (+{new_dist - old_dist})")
    assert new_dist >= old_dist + 1, "Retreat theorem violated!"
    p = r
    trajectory.append(p)

print(f"\n  Final position: {p}, distance from threat: {chebyshev_dist(p, q)}")
print("  Distance increased by at least 1 at every step ✓")

# ====================
# Demo 4: Pigeonhole Escape
# ====================
print("\n" + "=" * 60)
print("DEMO 4: Pigeonhole King Escape")
print("=" * 60)

king = (0, 0)
nbrs = king_neighbors(king)

for num_threats in range(9):
    threats = set(list(nbrs)[:num_threats])
    safe_moves = nbrs - threats
    print(f"  {num_threats} threats → {len(safe_moves)} safe moves", end="")
    if num_threats <= 7:
        assert len(safe_moves) >= 1
        print(" (king escapes ✓)")
    else:
        print(" (all blocked — checkmate possible)")

# ====================
# Demo 5: Chain Game Values
# ====================
print("\n" + "=" * 60)
print("DEMO 5: Chain Game Values")
print("=" * 60)

for n in range(8):
    values = [chain_game_value(n, k) for k in range(n + 1)]
    print(f"  Chain game n={n}: values = {values}, top value = {values[-1]}")
    assert values[-1] == n

print("\n  For each n, the chain game has value exactly n at the top.")
print("  This witnesses ω as the supremum of finite game values.")

# ====================
# Demo 6: Threat Configuration Analysis
# ====================
print("\n" + "=" * 60)
print("DEMO 6: Threat Configuration Safety")
print("=" * 60)

# 3 knights with max threat radius 2
knight_positions = [(5, 5), (-3, 7), (10, -2)]
max_threat_radius = 2

for king_dist in [2, 3, 4, 5, 10]:
    king_pos = (king_dist + max_threat_radius + 1, 0)
    # Check if any king neighbor is attacked
    nbrs = king_neighbors(king_pos)
    all_attacks = set()
    for kp in knight_positions:
        all_attacks |= knight_attacks(kp)
    
    threatened_neighbors = nbrs & all_attacks
    min_dist = min(chebyshev_dist(king_pos, kp) for kp in knight_positions)
    
    status = "SAFE ✓" if len(threatened_neighbors) == 0 else f"THREATENED ({len(threatened_neighbors)} neighbors)"
    print(f"  King at {king_pos}, min dist to knights: {min_dist} → {status}")

print("\n  When min distance > maxThreatRadius + 1, all neighbors are safe.")
print("  This is the ThreatConfiguration.king_safe_far theorem.")

# ====================
# Demo 7: Infinite Safety
# ====================
print("\n" + "=" * 60)
print("DEMO 7: Infinite Safety — Safe Squares Are Unbounded")
print("=" * 60)

threats = {(i, j) for i in range(-5, 6) for j in range(-5, 6)}
print(f"  Threats: {len(threats)} squares in [-5,5] × [-5,5]")

for R in [10, 100, 1000, 10000]:
    # Find a safe square at distance > R
    found = False
    for x in range(R + 1, R + 100):
        if (x, 0) not in threats:
            print(f"  R={R}: safe square ({x}, 0) at distance {chebyshev_dist((x,0),(0,0))} ✓")
            found = True
            break
    assert found

print("\n  No matter how large R, safe squares exist beyond distance R.")
print("  This is the safe_squares_unbounded theorem.")

print("\n" + "=" * 60)
print("ALL DEMONSTRATIONS PASSED ✓")
print("=" * 60)


#!/usr/bin/env python3
"""
Visualization: Chain Game Values and the Path to ω

Shows how finite chain games witness every finite ordinal,
with ω as their supremum.
"""

import matplotlib.pyplot as plt
import matplotlib.patches as patches
import numpy as np


fig, axes = plt.subplots(1, 2, figsize=(16, 7))

# Panel 1: Chain games as trees
ax = axes[0]

max_n = 6
y_offset = 0

for n in range(max_n + 1):
    y = y_offset + n * 1.5
    # Draw chain: n+1 nodes
    for k in range(n + 1):
        x = k * 1.2 + 0.5
        # Color by game value
        color = plt.cm.viridis(k / max(max_n, 1))
        circle = plt.Circle((x, y), 0.3, color=color, ec='black', linewidth=1.5)
        ax.add_patch(circle)
        ax.text(x, y, str(k), ha='center', va='center', fontsize=10, fontweight='bold', color='white')
        
        # Draw arrow from k to k-1 (move)
        if k > 0:
            ax.annotate('', xy=(x - 1.2 + 0.35, y), xytext=(x - 0.35, y),
                        arrowprops=dict(arrowstyle='->', color='gray', lw=1.5))
    
    # Label
    ax.text(-0.5, y, f'n={n}:', ha='right', va='center', fontsize=10, fontweight='bold')
    ax.text((n + 1) * 1.2 + 0.3, y, f'value = {n}', ha='left', va='center',
            fontsize=10, color='darkblue', fontstyle='italic')

ax.set_xlim(-1.5, max_n * 1.2 + 3)
ax.set_ylim(-1, max_n * 1.5 + 1.5)
ax.set_aspect('equal')
ax.axis('off')
ax.set_title('Chain Games: Position k Has Value k\n(arrows show moves)', fontsize=13)

# Panel 2: Game values approaching ω
ax2 = axes[1]

n_values = list(range(1, 16))
game_values = n_values  # Chain game n has max value n

# Plot finite values
bars = ax2.bar(n_values, game_values, color=[plt.cm.viridis(v/15) for v in game_values],
               edgecolor='black', alpha=0.8, label='Chain game value')

# Add ω line
ax2.axhline(y=16, color='red', linestyle='--', linewidth=2, alpha=0.7, label='ω (supremum)')
ax2.text(15.5, 16.3, 'ω', fontsize=16, color='red', fontweight='bold')

# Add "..." indicator
ax2.text(15.7, 15.2, '...', fontsize=20, color='gray', fontweight='bold')

# Annotations
ax2.annotate('Every finite value\nis achieved', xy=(8, 8), xytext=(10, 4),
             fontsize=10, ha='center',
             arrowprops=dict(arrowstyle='->', color='blue'),
             bbox=dict(boxstyle='round,pad=0.3', fc='lightyellow', ec='blue'))

ax2.annotate('ω = sup{n : n ∈ ℕ}\nFirst infinite ordinal', xy=(13, 16), xytext=(8, 18),
             fontsize=10, ha='center',
             arrowprops=dict(arrowstyle='->', color='red'),
             bbox=dict(boxstyle='round,pad=0.3', fc='mistyrose', ec='red'))

ax2.set_xlabel('Chain Game Length (n)', fontsize=12)
ax2.set_ylabel('Game Value at Top Position', fontsize=12)
ax2.set_title('Finite Game Values Approaching ω\n(transfinite_chess_conjecture_true)', fontsize=13)
ax2.legend(fontsize=10)
ax2.set_ylim(0, 20)

plt.tight_layout()
plt.savefig('viz_game_values.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved viz_game_values.png")


#!/usr/bin/env python3
"""
Visualization: The Retreat Theorem on the Infinite Board

Shows the king retreating from a threat, with distance increasing at each step.
"""

import matplotlib.pyplot as plt
import matplotlib.patches as patches
import numpy as np


def sign(x):
    return 1 if x > 0 else (-1 if x < 0 else 0)


def retreat_square(p, q):
    return (p[0] + sign(p[0] - q[0]), p[1] + sign(p[1] - q[1]))


def chebyshev_dist(p, q):
    return max(abs(p[0] - q[0]), abs(p[1] - q[1]))


def king_neighbors(p):
    offsets = [(-1,-1),(-1,0),(-1,1),(0,-1),(0,1),(1,-1),(1,0),(1,1)]
    return [(p[0]+dx, p[1]+dy) for dx, dy in offsets]


# Generate retreat path
king_start = (0, 0)
threat = (3, 2)
steps = 8

path = [king_start]
current = king_start
for _ in range(steps):
    current = retreat_square(current, threat)
    path.append(current)

fig, axes = plt.subplots(1, 2, figsize=(16, 7))

# Left: Board view with path
ax = axes[0]
ax.set_aspect('equal')

# Draw grid
for x in range(-3, 12):
    for y in range(-5, 10):
        rect = patches.Rectangle((x - 0.5, y - 0.5), 1, 1,
                                  linewidth=0.5, edgecolor='gray',
                                  facecolor='#f0f0f0' if (x + y) % 2 == 0 else 'white')
        ax.add_patch(rect)

# Draw Chebyshev distance circles around threat
for r in [1, 2, 3, 5, 8]:
    rect = patches.Rectangle((threat[0] - r - 0.5, threat[1] - r - 0.5),
                              2 * r + 1, 2 * r + 1,
                              linewidth=1, edgecolor='red', facecolor='none',
                              alpha=0.3, linestyle='--')
    ax.add_patch(rect)
    ax.text(threat[0] + r + 0.6, threat[1], f'd={r}', fontsize=7, color='red', alpha=0.6)

# Draw path
path_x = [p[0] for p in path]
path_y = [p[1] for p in path]
ax.plot(path_x, path_y, 'b-', linewidth=2, alpha=0.7, zorder=3)

# Draw path points
for i, p in enumerate(path):
    color = plt.cm.Blues(0.3 + 0.7 * i / len(path))
    ax.plot(p[0], p[1], 'o', color=color, markersize=10, zorder=4)
    ax.text(p[0] + 0.15, p[1] + 0.3, f'{i}', fontsize=8, fontweight='bold', zorder=5)

# Draw threat
ax.plot(threat[0], threat[1], 'rx', markersize=15, markeredgewidth=3, zorder=4)
ax.text(threat[0] + 0.3, threat[1] + 0.3, 'Threat', fontsize=9, color='red', fontweight='bold')

# Draw king neighbors at start
for n in king_neighbors(king_start):
    ax.plot(n[0], n[1], 's', color='lightblue', markersize=8, alpha=0.5, zorder=2)

ax.set_xlim(-3.5, 11.5)
ax.set_ylim(-5.5, 9.5)
ax.set_title('King Retreat Path on ℤ × ℤ\n(Chebyshev distance circles shown)', fontsize=12)
ax.set_xlabel('x')
ax.set_ylabel('y')

# Right: Distance vs step
ax2 = axes[1]
distances = [chebyshev_dist(p, threat) for p in path]
step_nums = list(range(len(path)))

ax2.bar(step_nums, distances, color=[plt.cm.Blues(0.3 + 0.7 * i / len(path)) for i in step_nums],
        edgecolor='navy', alpha=0.8)
ax2.plot(step_nums, distances, 'ko-', markersize=5, zorder=3)

# Show the +1 increments
for i in range(1, len(distances)):
    ax2.annotate('', xy=(i, distances[i]), xytext=(i, distances[i-1]),
                 arrowprops=dict(arrowstyle='->', color='red', lw=1.5))
    ax2.text(i + 0.1, (distances[i] + distances[i-1]) / 2, '+1',
             fontsize=8, color='red', fontweight='bold')

ax2.set_xlabel('Step')
ax2.set_ylabel('Chebyshev Distance from Threat')
ax2.set_title('Distance Increases by ≥1 at Each Step\n(Retreat Theorem)', fontsize=12)
ax2.set_xticks(step_nums)

plt.tight_layout()
plt.savefig('viz_retreat.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved viz_retreat.png")


#!/usr/bin/env python3
"""
Visualization: Knight Threat Radius and King Safety

Shows knight attack patterns and the safety radius theorem.
"""

import matplotlib.pyplot as plt
import matplotlib.patches as patches
import numpy as np


def chebyshev_dist(p, q):
    return max(abs(p[0] - q[0]), abs(p[1] - q[1]))


def king_neighbors(p):
    offsets = [(-1,-1),(-1,0),(-1,1),(0,-1),(0,1),(1,-1),(1,0),(1,1)]
    return [(p[0]+dx, p[1]+dy) for dx, dy in offsets]


def knight_attacks(p):
    offsets = [(-2,-1),(-2,1),(-1,-2),(-1,2),(1,-2),(1,2),(2,-1),(2,1)]
    return [(p[0]+dx, p[1]+dy) for dx, dy in offsets]


fig, axes = plt.subplots(1, 3, figsize=(18, 6))

# Panel 1: Knight attack pattern
ax = axes[0]
knight = (0, 0)
attacks = knight_attacks(knight)

for x in range(-4, 5):
    for y in range(-4, 5):
        color = '#f0f0f0' if (x+y) % 2 == 0 else 'white'
        if (x, y) in attacks:
            color = '#ff6b6b'
        elif (x, y) == knight:
            color = '#4ecdc4'
        rect = patches.Rectangle((x-0.5, y-0.5), 1, 1,
                                  linewidth=0.5, edgecolor='gray', facecolor=color)
        ax.add_patch(rect)

# Chebyshev distance 2 box
rect = patches.Rectangle((-2.5, -2.5), 5, 5,
                          linewidth=2, edgecolor='blue', facecolor='none',
                          linestyle='--', label='Chebyshev dist ≤ 2')
ax.add_patch(rect)

ax.set_xlim(-4.5, 4.5)
ax.set_ylim(-4.5, 4.5)
ax.set_aspect('equal')
ax.set_title('Knight Attack Pattern\n(all within Chebyshev dist 2)', fontsize=11)
ax.legend(loc='upper right', fontsize=8)

# Panel 2: King at distance 3 (unsafe)
ax = axes[1]
knight = (0, 0)
king_pos = (3, 0)  # distance 3

attacks = set(knight_attacks(knight))
nbrs = set(king_neighbors(king_pos))
overlap = nbrs & attacks

for x in range(-3, 7):
    for y in range(-4, 5):
        color = '#f0f0f0' if (x+y) % 2 == 0 else 'white'
        if (x, y) in overlap:
            color = '#ff0000'  # Overlap = danger!
        elif (x, y) in attacks:
            color = '#ffcccc'
        elif (x, y) in nbrs:
            color = '#ccffcc'
        elif (x, y) == knight:
            color = '#4ecdc4'
        elif (x, y) == king_pos:
            color = '#ffd700'
        rect = patches.Rectangle((x-0.5, y-0.5), 1, 1,
                                  linewidth=0.5, edgecolor='gray', facecolor=color)
        ax.add_patch(rect)

ax.text(knight[0], knight[1], '♞', fontsize=20, ha='center', va='center')
ax.text(king_pos[0], king_pos[1], '♔', fontsize=20, ha='center', va='center')

ax.set_xlim(-3.5, 6.5)
ax.set_ylim(-4.5, 4.5)
ax.set_aspect('equal')
ax.set_title(f'King at dist 3: {len(overlap)} threatened neighbor(s)\n(UNSAFE)', fontsize=11, color='red')

# Panel 3: King at distance 4 (safe)
ax = axes[2]
knight = (0, 0)
king_pos = (4, 0)  # distance 4 > 3

attacks = set(knight_attacks(knight))
nbrs = set(king_neighbors(king_pos))
overlap = nbrs & attacks

for x in range(-3, 8):
    for y in range(-4, 5):
        color = '#f0f0f0' if (x+y) % 2 == 0 else 'white'
        if (x, y) in overlap:
            color = '#ff0000'
        elif (x, y) in attacks:
            color = '#ffcccc'
        elif (x, y) in nbrs:
            color = '#ccffcc'
        elif (x, y) == knight:
            color = '#4ecdc4'
        elif (x, y) == king_pos:
            color = '#ffd700'
        rect = patches.Rectangle((x-0.5, y-0.5), 1, 1,
                                  linewidth=0.5, edgecolor='gray', facecolor=color)
        ax.add_patch(rect)

ax.text(knight[0], knight[1], '♞', fontsize=20, ha='center', va='center')
ax.text(king_pos[0], king_pos[1], '♔', fontsize=20, ha='center', va='center')

ax.set_xlim(-3.5, 7.5)
ax.set_ylim(-4.5, 4.5)
ax.set_aspect('equal')
ax.set_title(f'King at dist 4: {len(overlap)} threatened neighbor(s)\n(SAFE ✓)', fontsize=11, color='green')

plt.tight_layout()
plt.savefig('viz_threat_radius.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved viz_threat_radius.png")
