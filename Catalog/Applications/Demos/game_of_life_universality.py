#!/usr/bin/env python3
"""
Game of Life: Simulation Algebra Demo

Demonstrates the key mathematical structures from the formalization:
1. Game of Life evolution
2. Still life detection (block pattern)
3. Simulation morphism composition overhead
4. Translation invariance
"""

from typing import Set, Tuple, Dict, List, Callable
import itertools


# ============================================================
# Game of Life Engine
# ============================================================

def gol_neighbors(cell: tuple[int, int]) -> list[tuple[int, int]]:
    """Return the 8 Moore neighbors of a cell."""
    x, y = cell
    return [(x+dx, y+dy) for dx in (-1, 0, 1) for dy in (-1, 0, 1)
            if (dx, dy) != (0, 0)]


def gol_step(alive: set[tuple[int, int]]) -> set[tuple[int, int]]:
    """One step of Conway's Game of Life."""
    # Count neighbors for all relevant cells
    neighbor_counts: Dict[tuple[int, int], int] = {}
    for cell in alive:
        for nb in gol_neighbors(cell):
            neighbor_counts[nb] = neighbor_counts.get(nb, 0) + 1

    new_alive = set()
    for cell, count in neighbor_counts.items():
        if cell in alive:
            if count in (2, 3):
                new_alive.add(cell)
        else:
            if count == 3:
                new_alive.add(cell)
    return new_alive


def gol_evolve(alive: set[tuple[int, int]], steps: int) -> set[tuple[int, int]]:
    """Evolve the Game of Life for multiple steps."""
    for _ in range(steps):
        alive = gol_step(alive)
    return alive


def display_grid(alive: set[tuple[int, int]], margin: int = 2) -> str:
    """Render alive cells as ASCII art."""
    if not alive:
        return "(empty)"
    xs = [c[0] for c in alive]
    ys = [c[1] for c in alive]
    x_min, x_max = min(xs) - margin, max(xs) + margin
    y_min, y_max = min(ys) - margin, max(ys) + margin
    lines = []
    for y in range(y_min, y_max + 1):
        row = ""
        for x in range(x_min, x_max + 1):
            row += "█" if (x, y) in alive else "·"
        lines.append(row)
    return "\n".join(lines)


# ============================================================
# Demo 1: Block is a Still Life
# ============================================================

print("=" * 60)
print("DEMO 1: Block Still Life Verification")
print("=" * 60)

block = {(0, 0), (0, 1), (1, 0), (1, 1)}
print(f"\nInitial block pattern:")
print(display_grid(block, margin=1))

block_after = gol_step(block)
print(f"\nAfter 1 step:")
print(display_grid(block_after, margin=1))
print(f"\nIs still life: {block == block_after}")

# Verify neighbor counts
for cell in sorted(block):
    count = sum(1 for nb in gol_neighbors(cell) if nb in block)
    print(f"  Cell {cell}: {count} live neighbors")


# ============================================================
# Demo 2: Singleton Cell Death
# ============================================================

print("\n" + "=" * 60)
print("DEMO 2: Singleton Cell Dies (Isolation)")
print("=" * 60)

singleton = {(5, 5)}
print(f"\nInitial: single cell at (5,5)")
print(display_grid(singleton, margin=1))

after = gol_step(singleton)
print(f"\nAfter 1 step:")
print(display_grid(after, margin=1))
print(f"Cell died: {len(after) == 0}")


# ============================================================
# Demo 3: Blinker Oscillator
# ============================================================

print("\n" + "=" * 60)
print("DEMO 3: Blinker (Period-2 Oscillator)")
print("=" * 60)

blinker = {(0, -1), (0, 0), (0, 1)}
print(f"\nPhase 0:")
print(display_grid(blinker, margin=1))

blinker_1 = gol_step(blinker)
print(f"\nPhase 1:")
print(display_grid(blinker_1, margin=1))

blinker_2 = gol_step(blinker_1)
print(f"\nPhase 2 (= Phase 0):")
print(display_grid(blinker_2, margin=1))
print(f"Period 2 verified: {blinker == blinker_2}")


# ============================================================
# Demo 4: Simulation Chain Overhead
# ============================================================

print("\n" + "=" * 60)
print("DEMO 4: Simulation Chain Overhead (Multiplicative)")
print("=" * 60)

def simulation_chain_overhead(factors: list[int]) -> int:
    result = 1
    for k in factors:
        result *= k
    return result

chains = [
    [2, 3],
    [2, 2, 2, 2],
    [5, 10, 3],
    [2, 2, 2, 2, 2, 2, 2, 2],  # 8 doublings
]

for chain in chains:
    overhead = simulation_chain_overhead(chain)
    lower_bound = 2 ** len(chain)
    print(f"\n  Chain {chain}")
    print(f"    Total overhead: {overhead}")
    print(f"    Lower bound (2^{len(chain)}): {lower_bound}")
    print(f"    Overhead ≥ lower bound: {overhead >= lower_bound}")


# ============================================================
# Demo 5: Translation Invariance
# ============================================================

print("\n" + "=" * 60)
print("DEMO 5: GoL Commutes with Translation")
print("=" * 60)

def translate(alive: set[tuple[int, int]], dx: int, dy: int) -> set[tuple[int, int]]:
    return {(x + dx, y + dy) for x, y in alive}

pattern = {(0, 0), (0, 1), (1, 0), (1, 1), (2, 0)}  # Block + extra cell
dx, dy = 3, -7

# Method 1: translate then step
method1 = gol_step(translate(pattern, dx, dy))

# Method 2: step then translate
method2 = translate(gol_step(pattern), dx, dy)

print(f"\nPattern: {sorted(pattern)}")
print(f"Translation: ({dx}, {dy})")
print(f"Translate-then-step == Step-then-translate: {method1 == method2}")


# ============================================================
# Demo 6: Glider (spaceship)
# ============================================================

print("\n" + "=" * 60)
print("DEMO 6: Glider (Lightest Spaceship)")
print("=" * 60)

glider = {(0, 0), (1, 0), (2, 0), (2, 1), (1, 2)}
print(f"\nInitial glider:")
print(display_grid(glider))

for gen in range(1, 5):
    glider = gol_step(glider)
    print(f"\nGeneration {gen}:")
    print(display_grid(glider))

print(f"\nAfter 4 generations, glider has translated by (1, -1)")
print(f"This demonstrates GoL's computational potential:")
print(f"  Gliders carry information across the grid.")


print("\n" + "=" * 60)
print("All demos completed successfully!")
print("=" * 60)


#!/usr/bin/env python3
"""
Visualization: Game of Life Evolution and Simulation Overhead

Creates a multi-panel figure showing:
1. GoL block still life neighborhood analysis
2. Glider evolution across generations
3. Simulation chain overhead growth (exponential bound)
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as patches
import numpy as np
from typing import Set, Tuple, Dict, List


# ---- GoL Engine (inlined) ----

Cell = Tuple[int, int]
Grid = Set[Cell]

MOORE_OFFSETS = [(-1,-1),(-1,0),(-1,1),(0,-1),(0,1),(1,-1),(1,0),(1,1)]

def neighbor_count(grid: Grid, cell: Cell) -> int:
    x, y = cell
    return sum(1 for dx, dy in MOORE_OFFSETS if (x+dx, y+dy) in grid)

def gol_step(grid: Grid) -> Grid:
    counts: Dict[Cell, int] = {}
    for cell in grid:
        for dx, dy in MOORE_OFFSETS:
            nb = (cell[0]+dx, cell[1]+dy)
            counts[nb] = counts.get(nb, 0) + 1
    new = set()
    for cell, count in counts.items():
        if cell in grid:
            if count in (2, 3): new.add(cell)
        else:
            if count == 3: new.add(cell)
    return new

def simulation_chain_overhead(factors: List[int]) -> int:
    r = 1
    for k in factors: r *= k
    return r


# ---- Figure ----

fig, axes = plt.subplots(1, 3, figsize=(16, 5))

# Panel 1: Block Still Life Analysis
ax1 = axes[0]
block = {(0,0), (0,1), (1,0), (1,1)}
# Draw grid
for x in range(-1, 4):
    for y in range(-1, 4):
        cell = (x, y)
        nc = neighbor_count(block, cell)
        if cell in block:
            color = '#2ecc71'  # green for alive
            ax1.add_patch(patches.Rectangle((x-0.4, y-0.4), 0.8, 0.8,
                          facecolor=color, edgecolor='black', linewidth=1.5))
            ax1.text(x, y, f'{nc}', ha='center', va='center',
                    fontsize=14, fontweight='bold', color='white')
        else:
            if nc > 0:
                alpha = nc / 8.0
                ax1.add_patch(patches.Rectangle((x-0.4, y-0.4), 0.8, 0.8,
                              facecolor='lightblue', alpha=alpha,
                              edgecolor='gray', linewidth=0.5, linestyle='--'))
                ax1.text(x, y, f'{nc}', ha='center', va='center',
                        fontsize=10, color='gray')

ax1.set_xlim(-1.5, 3.5)
ax1.set_ylim(-1.5, 3.5)
ax1.set_aspect('equal')
ax1.set_title('Block Still Life\n(numbers = neighbor count)', fontsize=12, fontweight='bold')
ax1.grid(True, alpha=0.3)

# Panel 2: Glider Evolution
ax2 = axes[1]
glider = {(0,0), (1,0), (2,0), (2,1), (1,2)}
colors_gen = ['#e74c3c', '#e67e22', '#f1c40f', '#2ecc71', '#3498db']

for gen in range(5):
    for x, y in glider:
        ax2.add_patch(patches.Rectangle(
            (x - 0.35, y - 0.35 + gen * 5), 0.7, 0.7,
            facecolor=colors_gen[gen], edgecolor='black', linewidth=0.5, alpha=0.8))
    ax2.text(-1.5, gen * 5 + 1, f'Gen {gen}', fontsize=9, va='center', fontweight='bold')
    glider = gol_step(glider)

ax2.set_xlim(-2, 6)
ax2.set_ylim(-1, 25)
ax2.set_aspect('equal')
ax2.set_title('Glider Spaceship\n(5 generations)', fontsize=12, fontweight='bold')
ax2.axis('off')

# Panel 3: Simulation Chain Overhead
ax3 = axes[2]
chain_lengths = list(range(1, 13))
overhead_2 = [2**n for n in chain_lengths]
overhead_3 = [3**n for n in chain_lengths]
overhead_mixed = []
for n in chain_lengths:
    factors = [2 + (i % 3) for i in range(n)]
    overhead_mixed.append(simulation_chain_overhead(factors))
lower_bound = [2**n for n in chain_lengths]

ax3.semilogy(chain_lengths, overhead_2, 'o-', label='All factors = 2', color='#3498db', linewidth=2)
ax3.semilogy(chain_lengths, overhead_3, 's-', label='All factors = 3', color='#e74c3c', linewidth=2)
ax3.semilogy(chain_lengths, overhead_mixed, '^-', label='Mixed (2,3,4,...)', color='#2ecc71', linewidth=2)
ax3.semilogy(chain_lengths, lower_bound, 'k--', label='Lower bound 2ⁿ', linewidth=1.5, alpha=0.7)
ax3.set_xlabel('Chain Length n', fontsize=11)
ax3.set_ylabel('Total Overhead', fontsize=11)
ax3.set_title('Simulation Chain Overhead\n(Multiplicative Composition)', fontsize=12, fontweight='bold')
ax3.legend(fontsize=9)
ax3.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('gol_simulation_algebra.png', dpi=150, bbox_inches='tight')
print("Saved: gol_simulation_algebra.png")
