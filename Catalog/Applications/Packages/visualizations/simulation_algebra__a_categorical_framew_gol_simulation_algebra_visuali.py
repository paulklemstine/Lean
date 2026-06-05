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
