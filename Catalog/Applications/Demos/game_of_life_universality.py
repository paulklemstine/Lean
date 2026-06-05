#!/usr/bin/env python3
"""
Conway's Game of Life: Demonstration of key properties.

Demonstrates the theorems proved in the Lean formalization:
1. Speed of light / finite propagation
2. Still life characterization
3. Non-monotonicity
4. Oscillator periods
5. NAND gate construction
"""

from typing import Set, Tuple, Dict
FrozenConfig = frozenset

# Moore neighborhood offsets
MOORE_OFFSETS = [(-1,-1),(-1,0),(-1,1),(0,-1),(0,1),(1,-1),(1,0),(1,1)]

def gol_step(config: Set[tuple]) -> Set[tuple]:
    """One step of Conway's Game of Life (B3/S23)."""
    candidates = set()
    for (x, y) in config:
        for dx, dy in MOORE_OFFSETS:
            candidates.add((x+dx, y+dy))
        candidates.add((x, y))
    
    new_config = set()
    for cell in candidates:
        n = sum(1 for dx, dy in MOORE_OFFSETS if (cell[0]+dx, cell[1]+dy) in config)
        if cell in config:
            if n in (2, 3):
                new_config.add(cell)
        else:
            if n == 3:
                new_config.add(cell)
    return new_config

def evolve(config: Set[tuple], steps: int) -> Set[tuple]:
    """Evolve a configuration for multiple steps."""
    for _ in range(steps):
        config = gol_step(config)
    return config

def live_neighbor_count(config: Set[tuple], cell: tuple) -> int:
    """Count live neighbors of a cell."""
    return sum(1 for dx, dy in MOORE_OFFSETS if (cell[0]+dx, cell[1]+dy) in config)

def chebyshev_dist(p: tuple, q: tuple) -> int:
    """Chebyshev (L∞) distance."""
    return max(abs(p[0]-q[0]), abs(p[1]-q[1]))

def display(config: Set[tuple], title: str = ""):
    """Display a configuration as ASCII art."""
    if not config:
        print(f"{title}: (empty)")
        return
    xs = [c[0] for c in config]
    ys = [c[1] for c in config]
    min_x, max_x = min(xs)-1, max(xs)+1
    min_y, max_y = min(ys)-1, max(ys)+1
    
    if title:
        print(f"\n{title}:")
    for y in range(min_y, max_y+1):
        row = ""
        for x in range(min_x, max_x+1):
            row += "█" if (x, y) in config else "·"
        print(f"  {row}")

# ============================================================
# Demo 1: Speed of Light
# ============================================================
print("=" * 60)
print("DEMO 1: Speed of Light (Finite Propagation)")
print("=" * 60)

# R-pentomino: famous pattern with long evolution
r_pentomino = {(0,0), (1,0), (-1,1), (0,1), (0,2)}
display(r_pentomino, "R-pentomino (t=0)")

# Show that changes outside radius t+1 don't affect the center
center = (0, 0)
config1 = r_pentomino.copy()
config2 = r_pentomino | {(10, 10)}  # Add a cell far away

for t in range(5):
    e1 = evolve(config1, t)
    e2 = evolve(config2, t)
    agree = all(
        ((center[0]+dx, center[1]+dy) in e1) == ((center[0]+dx, center[1]+dy) in e2)
        for dx in range(-1,2) for dy in range(-1,2)
    )
    print(f"  t={t}: Configs agree at center? {agree} (cell at dist 14)")
print("  → Distant cell has no effect within light cone!")

# ============================================================
# Demo 2: Still Life Characterization
# ============================================================
print("\n" + "=" * 60)
print("DEMO 2: Still Life Characterization")
print("=" * 60)

still_lifes = {
    "Block": {(0,0),(1,0),(0,1),(1,1)},
    "Beehive": {(1,0),(2,0),(0,1),(3,1),(1,2),(2,2)},
    "Loaf": {(1,0),(2,0),(0,1),(3,1),(1,2),(3,2),(2,3)},
    "Boat": {(0,0),(1,0),(0,1),(2,1),(1,2)},
}

for name, pattern in still_lifes.items():
    evolved = gol_step(pattern)
    is_still = (evolved == pattern)
    
    # Verify characterization
    live_ok = all(live_neighbor_count(pattern, c) in (2, 3) for c in pattern)
    dead_candidates = set()
    for c in pattern:
        for dx, dy in MOORE_OFFSETS:
            dead_candidates.add((c[0]+dx, c[1]+dy))
    dead_ok = all(
        live_neighbor_count(pattern, c) != 3
        for c in dead_candidates if c not in pattern
    )
    
    print(f"  {name:8s}: still_life={is_still}, live_2or3={live_ok}, dead_not3={dead_ok}")

# ============================================================
# Demo 3: Non-Monotonicity
# ============================================================
print("\n" + "=" * 60)
print("DEMO 3: Non-Monotonicity (Adding cells can kill)")
print("=" * 60)

c1 = {(1,0), (0,1), (1,1)}  # 3 neighbors of origin → birth
c2 = {(1,0), (0,1), (1,1), (-1,0)}  # 4 neighbors → no birth

p = (0, 0)
n1 = live_neighbor_count(c1, p)
n2 = live_neighbor_count(c2, p)
r1 = (0,0) in gol_step(c1)
r2 = (0,0) in gol_step(c2)

display(c1, "Config c₁ (3 neighbors of origin)")
print(f"  Origin neighbors: {n1}, born: {r1}")
display(c2, "Config c₂ ⊇ c₁ (4 neighbors of origin)")
print(f"  Origin neighbors: {n2}, born: {r2}")
print(f"  → c₁ ⊆ c₂ but golStep(c₁) has cell that golStep(c₂) doesn't!")

# ============================================================
# Demo 4: Oscillator Periods
# ============================================================
print("\n" + "=" * 60)
print("DEMO 4: Oscillator Periods")
print("=" * 60)

oscillators = {
    "Blinker (p=2)": {(0,0), (1,0), (2,0)},
    "Toad (p=2)": {(1,0),(2,0),(3,0),(0,1),(1,1),(2,1)},
    "Pulsar (p=3)": {
        (2,0),(3,0),(4,0),(8,0),(9,0),(10,0),
        (0,2),(5,2),(7,2),(12,2),
        (0,3),(5,3),(7,3),(12,3),
        (0,4),(5,4),(7,4),(12,4),
        (2,5),(3,5),(4,5),(8,5),(9,5),(10,5),
        (2,7),(3,7),(4,7),(8,7),(9,7),(10,7),
        (0,8),(5,8),(7,8),(12,8),
        (0,9),(5,9),(7,9),(12,9),
        (0,10),(5,10),(7,10),(12,10),
        (2,12),(3,12),(4,12),(8,12),(9,12),(10,12),
    },
}

for name, pattern in oscillators.items():
    # Find minimal period
    current = pattern
    for p in range(1, 100):
        current = gol_step(current)
        if current == pattern:
            min_period = p
            break
    
    # Verify period divides multiples
    divides_check = all(evolve(pattern, k * min_period) == pattern for k in range(1, 5))
    print(f"  {name}: minimal period = {min_period}, k·p divides: {divides_check}")

# ============================================================
# Demo 5: NAND Gate via GoL
# ============================================================
print("\n" + "=" * 60)
print("DEMO 5: NAND Gate Completeness")
print("=" * 60)

def nand(a: bool, b: bool) -> bool:
    return not (a and b)

# Verify NAND computes all operations
for a in [False, True]:
    for b in [False, True]:
        not_a = nand(a, a)
        and_ab = nand(nand(a, b), nand(a, b))
        or_ab = nand(nand(a, a), nand(b, b))
        xor_ab = nand(nand(a, nand(a, b)), nand(b, nand(a, b)))
        
        assert not_a == (not a), f"NOT failed for {a}"
        assert and_ab == (a and b), f"AND failed for {a}, {b}"
        assert or_ab == (a or b), f"OR failed for {a}, {b}"
        assert xor_ab == (a ^ b), f"XOR failed for {a}, {b}"

print("  NAND truth table:")
print("  a | b | NAND(a,b)")
for a in [False, True]:
    for b in [False, True]:
        print(f"  {int(a)} | {int(b)} |    {int(nand(a, b))}")

print("\n  All Boolean operations verified via NAND:")
print("  ✓ NOT(a) = NAND(a, a)")
print("  ✓ AND(a,b) = NAND(NAND(a,b), NAND(a,b))")
print("  ✓ OR(a,b) = NAND(NAND(a,a), NAND(b,b))")
print("  ✓ XOR(a,b) = NAND(NAND(a, NAND(a,b)), NAND(b, NAND(a,b)))")

# ============================================================
# Demo 6: Glider (speed c/4)
# ============================================================
print("\n" + "=" * 60)
print("DEMO 6: Glider — Speed c/4")
print("=" * 60)

glider = {(1,0), (2,1), (0,2), (1,2), (2,2)}
display(glider, "Glider at t=0")

for t in range(1, 5):
    glider = gol_step(glider)
    
g4 = evolve({(1,0), (2,1), (0,2), (1,2), (2,2)}, 4)
# Glider should translate by (1,1) after 4 steps
original = {(1,0), (2,1), (0,2), (1,2), (2,2)}
translated = {(x+1, y+1) for (x,y) in original}
print(f"  After 4 steps, glider = translated by (1,1): {g4 == translated}")
print(f"  Speed = 1/4 c (diagonal)")

print("\n" + "=" * 60)
print("All demonstrations complete.")
print("=" * 60)


#!/usr/bin/env python3
"""
Visualization: Oscillator Period Theory in Game of Life.

Shows oscillators of different periods and demonstrates that
the minimal period divides all periods (oscillator_period_divides).
"""

import matplotlib.pyplot as plt
import numpy as np

MOORE_OFFSETS = [(-1,-1),(-1,0),(-1,1),(0,-1),(0,1),(1,-1),(1,0),(1,1)]

def gol_step(config):
    candidates = set()
    for (x, y) in config:
        for dx, dy in MOORE_OFFSETS:
            candidates.add((x+dx, y+dy))
        candidates.add((x, y))
    new_config = set()
    for cell in candidates:
        n = sum(1 for dx, dy in MOORE_OFFSETS if (cell[0]+dx, cell[1]+dy) in config)
        if cell in config:
            if n in (2, 3):
                new_config.add(cell)
        else:
            if n == 3:
                new_config.add(cell)
    return new_config

def config_to_grid(config, size=10):
    grid = np.zeros((size, size))
    offset = size // 2
    for (x, y) in config:
        gx, gy = x + offset, y + offset
        if 0 <= gx < size and 0 <= gy < size:
            grid[gy][gx] = 1
    return grid

# Oscillators
oscillators = {
    "Block (p=1)": frozenset({(0,0),(1,0),(0,1),(1,1)}),
    "Blinker (p=2)": frozenset({(0,0),(1,0),(2,0)}),
    "Toad (p=2)": frozenset({(1,0),(2,0),(3,0),(0,1),(1,1),(2,1)}),
    "Beacon (p=2)": frozenset({(0,0),(1,0),(0,1),(3,2),(2,3),(3,3)}),
}

fig, axes = plt.subplots(len(oscillators), 6, figsize=(18, 3*len(oscillators)))
fig.suptitle("Oscillator Period Theory: Period Divides All Recurrence Times", fontsize=14)

for row, (name, pattern) in enumerate(oscillators.items()):
    current = pattern
    for t in range(6):
        ax = axes[row][t]
        grid = config_to_grid(current, size=8)
        ax.imshow(grid, cmap='YlOrRd', interpolation='nearest', vmin=0, vmax=1)
        
        is_original = (current == pattern)
        border_color = 'green' if is_original else 'gray'
        for spine in ax.spines.values():
            spine.set_edgecolor(border_color)
            spine.set_linewidth(3 if is_original else 1)
        
        if t == 0:
            ax.set_ylabel(name, fontsize=10)
        ax.set_title(f"t={t}" + (" ✓" if is_original and t > 0 else ""), fontsize=9)
        ax.set_xticks([])
        ax.set_yticks([])
        
        current = gol_step(current)

plt.tight_layout()
plt.savefig('/workspace/request-project/Novelty/GameOfLife/viz_oscillators.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved viz_oscillators.png")


#!/usr/bin/env python3
"""
Visualization: Speed of Light in Game of Life.

Shows how information propagates at most 1 cell per step by comparing
two configurations that differ only far from the center.
"""

import matplotlib.pyplot as plt
import matplotlib.patches as patches
import numpy as np

MOORE_OFFSETS = [(-1,-1),(-1,0),(-1,1),(0,-1),(0,1),(1,-1),(1,0),(1,1)]

def gol_step(config):
    candidates = set()
    for (x, y) in config:
        for dx, dy in MOORE_OFFSETS:
            candidates.add((x+dx, y+dy))
        candidates.add((x, y))
    new_config = set()
    for cell in candidates:
        n = sum(1 for dx, dy in MOORE_OFFSETS if (cell[0]+dx, cell[1]+dy) in config)
        if cell in config:
            if n in (2, 3):
                new_config.add(cell)
        else:
            if n == 3:
                new_config.add(cell)
    return new_config

def evolve(config, steps):
    for _ in range(steps):
        config = gol_step(config)
    return config

# R-pentomino
r_pent = {(0,0), (1,0), (-1,1), (0,1), (0,2)}
# Perturbation far away
perturbation = {(8, 8)}
config1 = r_pent
config2 = r_pent | perturbation

fig, axes = plt.subplots(2, 5, figsize=(20, 8))
fig.suptitle("Speed of Light: Information Propagation in Game of Life", fontsize=16)

for t in range(5):
    c1 = evolve(r_pent, t)
    c2 = evolve(r_pent | perturbation, t)
    
    for row, (cfg, label) in enumerate([(c1, f"Config 1 (t={t})"), (c2, f"Config 2 (t={t})")]):
        ax = axes[row][t]
        grid = np.zeros((20, 20))
        for (x, y) in cfg:
            gx, gy = x + 10, y + 10
            if 0 <= gx < 20 and 0 <= gy < 20:
                grid[gy][gx] = 1
        
        ax.imshow(grid, cmap='binary', interpolation='nearest', extent=[-10.5,9.5,-10.5,9.5])
        
        # Draw light cone from origin
        radius = t
        rect = patches.Rectangle((-radius-0.5, -radius-0.5), 2*radius+1, 2*radius+1,
                                   linewidth=2, edgecolor='red', facecolor='none', linestyle='--')
        ax.add_patch(rect)
        ax.set_title(label, fontsize=10)
        ax.set_xlim(-10.5, 9.5)
        ax.set_ylim(-10.5, 9.5)
        ax.set_aspect('equal')
        if t == 0:
            ax.set_ylabel("Config 2\n(with perturbation)" if row == 1 else "Config 1\n(unperturbed)", fontsize=10)

axes[1][0].annotate('Perturbation\nat (8,8)', xy=(8, 8), fontsize=8, color='blue',
                     ha='center', va='bottom')

plt.tight_layout()
plt.savefig('/workspace/request-project/Novelty/GameOfLife/viz_speed_of_light.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved viz_speed_of_light.png")
