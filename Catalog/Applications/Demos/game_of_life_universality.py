#!/usr/bin/env python3
"""
Game of Life Simulation Morphism Demo

Demonstrates key results from the formalization:
1. Block still life verification
2. Single cell extinction
3. Translation invariance
4. Non-monotonicity counterexample
5. Finite support preservation
6. Simulation morphism composition (dilation multiplication)
"""

import numpy as np
from typing import Dict, Tuple, Set, Callable

# Type aliases
Cell = Tuple[int, int]
Config = Set[Cell]

MOORE_OFFSETS = [(-1,-1), (-1,0), (-1,1), (0,-1), (0,1), (1,-1), (1,0), (1,1)]


def live_neighbors(cfg: Config, p: Cell) -> int:
    """Count live neighbors of cell p in configuration cfg."""
    return sum(1 for dx, dy in MOORE_OFFSETS if (p[0]+dx, p[1]+dy) in cfg)


def gol_step(cfg: Config) -> Config:
    """One step of Conway's Game of Life."""
    # Collect all cells to check (alive cells + their neighbors)
    candidates: Set[Cell] = set()
    for x, y in cfg:
        for dx, dy in MOORE_OFFSETS:
            candidates.add((x+dx, y+dy))
        candidates.add((x, y))

    new_cfg: Config = set()
    for p in candidates:
        n = live_neighbors(cfg, p)
        if p in cfg:
            if n in (2, 3):
                new_cfg.add(p)
        else:
            if n == 3:
                new_cfg.add(p)
    return new_cfg


def translate(cfg: Config, d: Cell) -> Config:
    """Translate configuration by offset d."""
    return {(x + d[0], y + d[1]) for x, y in cfg}


def print_config(cfg: Config, title: str = "", bounds: Tuple[int,int,int,int] = None):
    """Print a configuration as ASCII art."""
    if title:
        print(f"\n{'='*50}")
        print(f"  {title}")
        print(f"{'='*50}")
    if not cfg:
        print("  (empty)")
        return
    if bounds is None:
        xs = [p[0] for p in cfg]
        ys = [p[1] for p in cfg]
        bounds = (min(xs)-1, max(xs)+1, min(ys)-1, max(ys)+1)
    for y in range(bounds[2], bounds[3]+1):
        row = ""
        for x in range(bounds[0], bounds[1]+1):
            row += "█" if (x, y) in cfg else "·"
        print(f"  {row}")


# ============================================================
# Demo 1: Block Still Life
# ============================================================
print("\n" + "="*60)
print("DEMO 1: Block Still Life (Theorem: block_is_still_life)")
print("="*60)

block = {(0,0), (1,0), (0,1), (1,1)}
print_config(block, "Block (t=0)")
stepped = gol_step(block)
print_config(stepped, "Block (t=1)")
print(f"\n  Block is fixed point: {block == stepped}")

# Verify neighbor counts
for p in sorted(block):
    n = live_neighbors(block, p)
    print(f"  Cell {p}: {n} neighbors (survives with 2 or 3)")


# ============================================================
# Demo 2: Single Cell Extinction
# ============================================================
print("\n" + "="*60)
print("DEMO 2: Single Cell Dies (Theorem: singleCell_dies)")
print("="*60)

single = {(5, 5)}
print_config(single, "Single cell (t=0)", (3,7,3,7))
stepped = gol_step(single)
print_config(stepped, "After one step (t=1)", (3,7,3,7))
print(f"\n  Cell died (empty config): {len(stepped) == 0}")
print(f"  Neighbor count of single cell: {live_neighbors(single, (5,5))}")
print(f"  Dies because 0 neighbors < 2 (underpopulation)")


# ============================================================
# Demo 3: Translation Invariance
# ============================================================
print("\n" + "="*60)
print("DEMO 3: Translation Invariance (Theorem: golStep_translate_comm)")
print("="*60)

# Use a blinker (period-2 oscillator)
blinker_h = {(0,-1), (0,0), (0,1)}  # horizontal
d = (10, 20)

stepped_then_translated = translate(gol_step(blinker_h), d)
translated_then_stepped = gol_step(translate(blinker_h, d))

print_config(blinker_h, "Blinker at origin")
print_config(gol_step(blinker_h), "After step")
print(f"\n  step(translate(cfg, d)) == translate(step(cfg), d): "
      f"{stepped_then_translated == translated_then_stepped}")
print(f"  Offset d = {d}")


# ============================================================
# Demo 4: Non-Monotonicity
# ============================================================
print("\n" + "="*60)
print("DEMO 4: GoL is NOT Monotone (Theorem: gol_not_monotone)")
print("="*60)

# Configuration a: cells within distance 1 of origin (disk)
a = {(x,y) for x in range(-1,2) for y in range(-1,2) if x*x + y*y <= 1}
# Configuration b: a plus an extra cell
b = a | {(1, 1)}

print(f"  Config a (disk): {sorted(a)}")
print(f"  Config b (a + extra): {sorted(b)}")
print(f"  a ⊆ b: {a.issubset(b)}")

stepped_a = gol_step(a)
stepped_b = gol_step(b)

print_config(a, "Config a (t=0)", (-3,3,-3,3))
print_config(stepped_a, "step(a) (t=1)", (-3,3,-3,3))
print_config(b, "Config b (t=0)", (-3,3,-3,3))
print_config(stepped_b, "step(b) (t=1)", (-3,3,-3,3))

print(f"\n  step(a) ⊆ step(b): {stepped_a.issubset(stepped_b)}")
print(f"  Monotonicity violated!")
# Find a witness
for p in stepped_a:
    if p not in stepped_b:
        print(f"  Witness: cell {p} alive in step(a) but dead in step(b)")


# ============================================================
# Demo 5: Finite Support Preservation
# ============================================================
print("\n" + "="*60)
print("DEMO 5: Finite Support (Theorem: golStep_preserves_finite_support)")
print("="*60)

# R-pentomino: famous for producing a large but still finite pattern
r_pentomino = {(0,0), (1,0), (-1,1), (0,1), (0,2)}
print_config(r_pentomino, "R-pentomino (t=0)")
print(f"  Population at t=0: {len(r_pentomino)}")

cfg = r_pentomino
pops = [len(cfg)]
for t in range(1, 20):
    cfg = gol_step(cfg)
    pops.append(len(cfg))

print(f"\n  Population over 20 steps:")
for t, p in enumerate(pops):
    bar = "▓" * (p // 2)
    print(f"  t={t:2d}: {p:3d} {bar}")
print(f"\n  Support always finite ✓")


# ============================================================
# Demo 6: Simulation Morphism Composition
# ============================================================
print("\n" + "="*60)
print("DEMO 6: Simulation Morphism Composition")
print("="*60)

print("""
  SimMorphism composition theorem:
  
  If f: A → B has dilation d₁
  and g: B → C has dilation d₂
  then f∘g: A → C has dilation d₁ × d₂
  
  Example chain (Turing machine → GoL):
  
  Layer 1: TM → Two-counter machine
    dilation = 100 (polynomial in program size)
    
  Layer 2: Two-counter machine → Signal machine
    dilation = 50 (constant per instruction type)
    
  Layer 3: Signal machine → GoL
    dilation = 1000 (signal propagation time)
    
  Total dilation = 100 × 50 × 1000 = 5,000,000
  
  Complexity bound (Theorem: simulation_complexity_bound):
  T steps of TM require at most T × 5,000,000 steps of GoL
""")

# Verify dilation chain bound
dilations = [100, 50, 1000]
d_max = max(dilations)
n = len(dilations)
product = 1
for d in dilations:
    product *= d
bound = d_max ** n

print(f"  Individual dilations: {dilations}")
print(f"  Product of dilations: {product:,}")
print(f"  Max dilation d = {d_max}")
print(f"  d^n = {d_max}^{n} = {bound:,}")
print(f"  Product ≤ d^n: {product <= bound} ✓")


print("\n" + "="*60)
print("All demos completed successfully!")
print("="*60)


#!/usr/bin/env python3
"""
Visualization: Dilation Chain Bounds

Shows how simulation overhead grows with chain depth and maximum dilation.
Corresponds to theorem dilation_chain_bound.
"""

import matplotlib.pyplot as plt
import numpy as np


def plot_dilation_bounds():
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))

    # Plot 1: Overhead vs chain depth for different max dilations
    ax1 = axes[0]
    depths = np.arange(1, 8)
    for d in [2, 5, 10, 50]:
        bounds = d ** depths
        ax1.semilogy(depths, bounds, 'o-', label=f'd = {d}', markersize=6)

    ax1.set_xlabel('Chain Depth (n)', fontsize=13)
    ax1.set_ylabel('Total Dilation Bound (d^n)', fontsize=13)
    ax1.set_title('Simulation Overhead vs Chain Depth', fontsize=14)
    ax1.legend(title='Max single-layer\ndilation', fontsize=11)
    ax1.grid(True, alpha=0.3)
    ax1.set_xticks(depths)

    # Plot 2: Actual vs bound for random dilation chains
    ax2 = axes[1]
    np.random.seed(42)
    n = 5
    num_chains = 50
    actuals = []
    bounds = []
    for _ in range(num_chains):
        dilations = np.random.randint(1, 20, size=n)
        actual = int(np.prod(dilations))
        d_max = int(np.max(dilations))
        bound = d_max ** n
        actuals.append(actual)
        bounds.append(bound)

    ax2.scatter(bounds, actuals, alpha=0.6, s=40, c='steelblue', edgecolors='navy')
    max_val = max(max(bounds), max(actuals))
    ax2.plot([0, max_val], [0, max_val], 'r--', alpha=0.5, label='y = x (tight bound)')
    ax2.set_xlabel('Upper Bound (d^n)', fontsize=13)
    ax2.set_ylabel('Actual Product (∏ dᵢ)', fontsize=13)
    ax2.set_title(f'Actual vs Bound ({num_chains} random chains, depth {n})', fontsize=14)
    ax2.legend(fontsize=11)
    ax2.grid(True, alpha=0.3)
    ax2.set_xscale('log')
    ax2.set_yscale('log')

    plt.tight_layout()
    plt.savefig('dilation_bounds.png', dpi=150, bbox_inches='tight')
    plt.show()
    print("Saved: dilation_bounds.png")


if __name__ == "__main__":
    plot_dilation_bounds()


#!/usr/bin/env python3
"""
Visualization: Game of Life Pattern Evolution

Shows the evolution of key patterns: block (still life), blinker (oscillator),
glider (spaceship), and R-pentomino (complex evolution).
"""

import matplotlib.pyplot as plt
import matplotlib.colors as mcolors
import numpy as np
from typing import Set, Tuple, FrozenSet

Cell = Tuple[int, int]
Config = FrozenSet[Cell]

MOORE_OFFSETS = [(-1,-1), (-1,0), (-1,1), (0,-1), (0,1), (1,-1), (1,0), (1,1)]


def live_neighbors(cfg: Config, p: Cell) -> int:
    return sum(1 for dx, dy in MOORE_OFFSETS if (p[0]+dx, p[1]+dy) in cfg)


def gol_step(cfg: Config) -> Config:
    candidates: Set[Cell] = set()
    for x, y in cfg:
        candidates.add((x, y))
        for dx, dy in MOORE_OFFSETS:
            candidates.add((x+dx, y+dy))
    result = set()
    for p in candidates:
        n = live_neighbors(cfg, p)
        if p in cfg:
            if n in (2, 3):
                result.add(p)
        else:
            if n == 3:
                result.add(p)
    return frozenset(result)


def config_to_grid(cfg: Config, bounds: Tuple[int,int,int,int]) -> np.ndarray:
    xmin, xmax, ymin, ymax = bounds
    grid = np.zeros((ymax - ymin + 1, xmax - xmin + 1))
    for x, y in cfg:
        if xmin <= x <= xmax and ymin <= y <= ymax:
            grid[y - ymin, x - xmin] = 1
    return grid


def plot_pattern_evolution():
    patterns = {
        'Block (still life)': frozenset({(0,0),(1,0),(0,1),(1,1)}),
        'Blinker (period 2)': frozenset({(-1,0),(0,0),(1,0)}),
        'Glider (spaceship)': frozenset({(1,0),(2,1),(0,2),(1,2),(2,2)}),
        'R-pentomino': frozenset({(0,0),(1,0),(-1,1),(0,1),(0,2)}),
    }

    bounds_map = {
        'Block (still life)': (-2, 3, -2, 3),
        'Blinker (period 2)': (-3, 3, -3, 3),
        'Glider (spaceship)': (-2, 8, -2, 8),
        'R-pentomino': (-8, 12, -8, 12),
    }

    steps_map = {
        'Block (still life)': 4,
        'Blinker (period 2)': 4,
        'Glider (spaceship)': 8,
        'R-pentomino': 8,
    }

    cmap = mcolors.ListedColormap(['#1a1a2e', '#e94560'])

    fig, axes = plt.subplots(4, 5, figsize=(16, 13))

    for row_idx, (name, initial) in enumerate(patterns.items()):
        cfg = initial
        bounds = bounds_map[name]
        n_steps = steps_map[name]
        step_size = max(1, n_steps // 4)

        for col_idx in range(5):
            t = col_idx * step_size
            ax = axes[row_idx, col_idx]

            # Evolve to step t
            current = initial
            for _ in range(t):
                current = gol_step(current)

            grid = config_to_grid(current, bounds)
            ax.imshow(grid, cmap=cmap, interpolation='nearest', aspect='equal')
            ax.set_title(f't={t}', fontsize=11)
            ax.set_xticks([])
            ax.set_yticks([])

            if col_idx == 0:
                ax.set_ylabel(name, fontsize=11, fontweight='bold')

    plt.suptitle('Game of Life: Pattern Evolution', fontsize=16, fontweight='bold', y=0.98)
    plt.tight_layout(rect=[0, 0, 1, 0.96])
    plt.savefig('gol_patterns.png', dpi=150, bbox_inches='tight')
    plt.show()
    print("Saved: gol_patterns.png")


if __name__ == "__main__":
    plot_pattern_evolution()


#!/usr/bin/env python3
"""
Visualization: Non-Monotonicity of the Game of Life

Demonstrates that adding cells can cause other cells to die,
proving GoL is not monotone. This property is essential for
computational universality.
"""

import matplotlib.pyplot as plt
import matplotlib.colors as mcolors
import matplotlib.patches as mpatches
import numpy as np
from typing import Set, Tuple, FrozenSet

Cell = Tuple[int, int]
Config = FrozenSet[Cell]

MOORE_OFFSETS = [(-1,-1), (-1,0), (-1,1), (0,-1), (0,1), (1,-1), (1,0), (1,1)]


def live_neighbors(cfg: Config, p: Cell) -> int:
    return sum(1 for dx, dy in MOORE_OFFSETS if (p[0]+dx, p[1]+dy) in cfg)


def gol_step(cfg: Config) -> Config:
    candidates: Set[Cell] = set()
    for x, y in cfg:
        candidates.add((x, y))
        for dx, dy in MOORE_OFFSETS:
            candidates.add((x+dx, y+dy))
    result = set()
    for p in candidates:
        n = live_neighbors(cfg, p)
        if p in cfg:
            if n in (2, 3): result.add(p)
        else:
            if n == 3: result.add(p)
    return frozenset(result)


def plot_non_monotonicity():
    # Configuration a: disk of radius 1
    a = frozenset((x,y) for x in range(-1,2) for y in range(-1,2) if x*x+y*y <= 1)
    # Configuration b: a + extra cell
    b = a | frozenset({(1, 1)})

    stepped_a = gol_step(a)
    stepped_b = gol_step(b)

    # Find witness cells
    lost_cells = stepped_a - stepped_b  # Alive in step(a), dead in step(b)
    extra_cells = b - a  # Added cells

    bounds = (-3, 3, -3, 3)

    fig, axes = plt.subplots(2, 2, figsize=(12, 12))

    cmap3 = mcolors.ListedColormap(['#1a1a2e', '#16c79a', '#ff6b6b'])

    for ax_idx, (ax, cfg, title) in enumerate([
        (axes[0,0], a, 'Config a (t=0)'),
        (axes[0,1], b, 'Config b = a ∪ {(1,1)} (t=0)'),
        (axes[1,0], stepped_a, 'step(a) (t=1)'),
        (axes[1,1], stepped_b, 'step(b) (t=1)'),
    ]):
        xmin, xmax, ymin, ymax = bounds
        grid = np.zeros((ymax-ymin+1, xmax-xmin+1))
        for x, y in cfg:
            if xmin <= x <= xmax and ymin <= y <= ymax:
                grid[y-ymin, x-xmin] = 1

        # Mark special cells
        if ax_idx == 1:  # Config b: mark extra cells
            for x, y in extra_cells:
                if xmin <= x <= xmax and ymin <= y <= ymax:
                    grid[y-ymin, x-xmin] = 2
        if ax_idx == 2:  # step(a): mark cells that will be lost
            for x, y in lost_cells:
                if xmin <= x <= xmax and ymin <= y <= ymax:
                    grid[y-ymin, x-xmin] = 2

        ax.imshow(grid, cmap=cmap3, interpolation='nearest', aspect='equal',
                  vmin=0, vmax=2)
        ax.set_title(title, fontsize=13, fontweight='bold')
        ax.set_xticks(range(xmax-xmin+1))
        ax.set_xticklabels(range(xmin, xmax+1))
        ax.set_yticks(range(ymax-ymin+1))
        ax.set_yticklabels(range(ymin, ymax+1))
        ax.grid(True, alpha=0.2)

        # Add cell coordinate labels
        for x in range(xmin, xmax+1):
            for y in range(ymin, ymax+1):
                if (x, y) in cfg:
                    n = live_neighbors(cfg, (x, y))
                    ax.text(x-xmin, y-ymin, str(n), ha='center', va='center',
                            fontsize=9, color='white', fontweight='bold')

    # Add legend
    legend_elements = [
        mpatches.Patch(facecolor='#1a1a2e', label='Dead'),
        mpatches.Patch(facecolor='#16c79a', label='Alive'),
        mpatches.Patch(facecolor='#ff6b6b', label='Key cell (added/lost)'),
    ]
    fig.legend(handles=legend_elements, loc='lower center', ncol=3,
               fontsize=12, bbox_to_anchor=(0.5, 0.02))

    plt.suptitle('Game of Life is NOT Monotone\n'
                 'Adding a cell (red) to config a creates config b,\n'
                 'but step(a) has cells that step(b) lacks',
                 fontsize=15, fontweight='bold', y=1.02)

    plt.tight_layout(rect=[0, 0.06, 1, 0.98])
    plt.savefig('non_monotonicity.png', dpi=150, bbox_inches='tight')
    plt.show()
    print("Saved: non_monotonicity.png")

    print(f"\nConfig a: {sorted(a)}")
    print(f"Config b: {sorted(b)}")
    print(f"step(a): {sorted(stepped_a)}")
    print(f"step(b): {sorted(stepped_b)}")
    print(f"Lost cells (in step(a) but not step(b)): {sorted(lost_cells)}")
    print(f"a ⊆ b: {a.issubset(b)}")
    print(f"step(a) ⊆ step(b): {stepped_a.issubset(stepped_b)}")
    print(f"Monotonicity violated: {not stepped_a.issubset(stepped_b)}")


if __name__ == "__main__":
    plot_non_monotonicity()
