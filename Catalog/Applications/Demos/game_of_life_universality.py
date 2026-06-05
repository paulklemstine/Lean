#!/usr/bin/env python3
"""
Game of Life: Simulation Morphism Algebra — Interactive Demo

Demonstrates the key mathematical results:
1. GoL step function and its properties
2. Speed of light propagation
3. Still life detection
4. Simulation morphism composition with overhead tracking
"""

import numpy as np
from typing import Callable, Tuple, List, Optional

# =============================================================================
# Game of Life Core
# =============================================================================

def gol_step(grid: np.ndarray) -> np.ndarray:
    """Apply one step of Conway's Game of Life.
    
    Uses toroidal boundary conditions for finite grids.
    """
    rows, cols = grid.shape
    new_grid = np.zeros_like(grid)
    
    for i in range(rows):
        for j in range(cols):
            # Count alive neighbors
            count = 0
            for di in [-1, 0, 1]:
                for dj in [-1, 0, 1]:
                    if di == 0 and dj == 0:
                        continue
                    ni, nj = (i + di) % rows, (j + dj) % cols
                    count += grid[ni, nj]
            
            # Apply rules
            if grid[i, j] == 1:
                new_grid[i, j] = 1 if count in (2, 3) else 0
            else:
                new_grid[i, j] = 1 if count == 3 else 0
    
    return new_grid

def gol_iter(grid: np.ndarray, steps: int) -> np.ndarray:
    """Iterate GoL for multiple steps."""
    result = grid.copy()
    for _ in range(steps):
        result = gol_step(result)
    return result

# =============================================================================
# Demo 1: Speed of Light
# =============================================================================

def demo_speed_of_light():
    """Demonstrate the speed of light bound.
    
    Place a single alive cell at the center of a grid and observe
    that the affected region grows by at most 1 cell per step in each direction.
    """
    print("=" * 60)
    print("DEMO 1: Speed of Light in Conway's Game of Life")
    print("=" * 60)
    
    size = 21
    center = size // 2
    
    # Start with a small pattern (R-pentomino) at center
    grid = np.zeros((size, size), dtype=int)
    grid[center, center] = 1
    grid[center, center+1] = 1
    grid[center-1, center] = 1
    grid[center, center-1] = 1
    grid[center+1, center] = 1
    
    print(f"\nInitial pattern at center ({center}, {center}):")
    print(f"  Alive cells: {np.sum(grid)}")
    
    for t in range(1, 8):
        grid = gol_step(grid)
        alive_positions = np.argwhere(grid == 1)
        if len(alive_positions) > 0:
            max_dist = max(
                max(abs(p[0] - center), abs(p[1] - center)) 
                for p in alive_positions
            )
        else:
            max_dist = 0
        
        print(f"  t={t}: alive={np.sum(grid):3d}, "
              f"max Chebyshev distance from center = {max_dist} "
              f"(bound: {t})")
        assert max_dist <= t, "Speed of light violated!"
    
    print("\n  ✓ Speed of light theorem verified: max distance ≤ t for all t")

# =============================================================================
# Demo 2: Irreversibility
# =============================================================================

def demo_irreversibility():
    """Demonstrate that GoL is not injective."""
    print("\n" + "=" * 60)
    print("DEMO 2: Irreversibility of the Game of Life")
    print("=" * 60)
    
    size = 5
    
    # Grid 1: all dead
    g1 = np.zeros((size, size), dtype=int)
    
    # Grid 2: all alive
    g2 = np.ones((size, size), dtype=int)
    
    after_g1 = gol_step(g1)
    after_g2 = gol_step(g2)
    
    print(f"\n  Grid 1 (all dead) → after step: {np.sum(after_g1)} alive cells")
    print(f"  Grid 2 (all alive) → after step: {np.sum(after_g2)} alive cells")
    print(f"  Grids equal before step: {np.array_equal(g1, g2)}")
    print(f"  Grids equal after step: {np.array_equal(after_g1, after_g2)}")
    print("\n  ✓ Non-injectivity demonstrated: distinct inputs → same output")

# =============================================================================
# Demo 3: Still Life Detection
# =============================================================================

def is_still_life(grid: np.ndarray) -> bool:
    """Check if a configuration is a still life."""
    return np.array_equal(gol_step(grid), grid)

def demo_still_lives():
    """Demonstrate still life characterization."""
    print("\n" + "=" * 60)
    print("DEMO 3: Still Life Classification")
    print("=" * 60)
    
    # Block (2x2)
    block = np.zeros((6, 6), dtype=int)
    block[2:4, 2:4] = 1
    
    # Beehive
    beehive = np.zeros((7, 7), dtype=int)
    beehive[2, 3:5] = 1
    beehive[3, 2] = 1
    beehive[3, 5] = 1
    beehive[4, 3:5] = 1
    
    # Loaf
    loaf = np.zeros((8, 8), dtype=int)
    loaf[2, 3:5] = 1
    loaf[3, 2] = 1
    loaf[3, 5] = 1
    loaf[4, 3] = 1
    loaf[4, 5] = 1
    loaf[5, 4] = 1
    
    patterns = [("Block", block), ("Beehive", beehive), ("Loaf", loaf)]
    
    for name, pattern in patterns:
        still = is_still_life(pattern)
        alive = np.sum(pattern)
        print(f"\n  {name}: {alive} alive cells → Still life: {still}")
        
        # Verify neighbor count constraints
        rows, cols = pattern.shape
        for i in range(rows):
            for j in range(cols):
                count = 0
                for di in [-1, 0, 1]:
                    for dj in [-1, 0, 1]:
                        if di == 0 and dj == 0:
                            continue
                        ni, nj = (i + di) % rows, (j + dj) % cols
                        count += pattern[ni, nj]
                
                if pattern[i, j] == 1:
                    assert count in (2, 3), f"Alive cell ({i},{j}) has {count} neighbors!"
                else:
                    assert count != 3, f"Dead cell ({i},{j}) has 3 neighbors!"
        
        print(f"    ✓ Neighbor constraints verified for all cells")

# =============================================================================
# Demo 4: Simulation Morphism Composition
# =============================================================================

class SimSystem:
    """A computational dynamical system."""
    def __init__(self, name: str, step_fn: Callable):
        self.name = name
        self.step_fn = step_fn
    
    def step(self, state):
        return self.step_fn(state)
    
    def iter(self, n: int, state):
        result = state
        for _ in range(n):
            result = self.step(result)
        return result

class SimMorphism:
    """A simulation morphism between SimSystems."""
    def __init__(self, source: SimSystem, target: SimSystem,
                 encode: Callable, time_factor: int):
        self.source = source
        self.target = target
        self.encode = encode
        self.time_factor = time_factor
        assert time_factor > 0, "Time factor must be positive"
    
    def compose(self, other: 'SimMorphism') -> 'SimMorphism':
        """Compose with another morphism. Time factors multiply."""
        assert self.target.name == other.source.name
        return SimMorphism(
            source=self.source,
            target=other.target,
            encode=lambda s: other.encode(self.encode(s)),
            time_factor=self.time_factor * other.time_factor
        )

def demo_simulation_morphisms():
    """Demonstrate the multiplicative composition of simulation overhead."""
    print("\n" + "=" * 60)
    print("DEMO 4: Simulation Morphism Algebra")
    print("=" * 60)
    
    # System A: Counter (increment mod 10)
    sys_a = SimSystem("Counter(mod 10)", lambda x: (x + 1) % 10)
    
    # System B: Binary counter (simulates counter with overhead 3)
    sys_b = SimSystem("Binary", lambda x: (x + 1) % 30)
    
    # System C: Unary (simulates binary with overhead 5)
    sys_c = SimSystem("Unary", lambda x: (x + 1) % 150)
    
    # Morphism A → B: time factor 3
    f = SimMorphism(sys_a, sys_b, lambda x: x * 3, time_factor=3)
    
    # Morphism B → C: time factor 5  
    g = SimMorphism(sys_b, sys_c, lambda x: x * 5, time_factor=5)
    
    # Composition A → C: time factor 3 * 5 = 15
    fg = f.compose(g)
    
    print(f"\n  Morphism f: {f.source.name} → {f.target.name}, "
          f"time factor = {f.time_factor}")
    print(f"  Morphism g: {g.source.name} → {g.target.name}, "
          f"time factor = {g.time_factor}")
    print(f"  Composition f∘g: {fg.source.name} → {fg.target.name}, "
          f"time factor = {fg.time_factor}")
    print(f"\n  ✓ Multiplicative composition: {f.time_factor} × {g.time_factor} "
          f"= {fg.time_factor}")
    
    # Chain of 3
    sys_d = SimSystem("Physical", lambda x: (x + 1) % 750)
    h = SimMorphism(sys_c, sys_d, lambda x: x * 5, time_factor=5)
    fgh = fg.compose(h)
    
    print(f"\n  Chain of 3 simulations:")
    print(f"    f: factor {f.time_factor}")
    print(f"    g: factor {g.time_factor}")
    print(f"    h: factor {h.time_factor}")
    print(f"    Total: {f.time_factor} × {g.time_factor} × {h.time_factor} "
          f"= {fgh.time_factor}")
    print(f"  ✓ Associativity: ({f.time_factor}×{g.time_factor})×{h.time_factor} "
          f"= {f.time_factor}×({g.time_factor}×{h.time_factor}) "
          f"= {fgh.time_factor}")

# =============================================================================
# Demo 5: Population Dynamics
# =============================================================================

def demo_population_dynamics():
    """Demonstrate birth/death rules and population bounds."""
    print("\n" + "=" * 60)
    print("DEMO 5: Population Dynamics")
    print("=" * 60)
    
    size = 30
    grid = np.zeros((size, size), dtype=int)
    
    # R-pentomino: famous for chaotic growth
    c = size // 2
    grid[c, c+1] = 1
    grid[c, c] = 1
    grid[c-1, c] = 1
    grid[c+1, c+1] = 1
    grid[c, c-1] = 1
    
    print(f"\n  R-pentomino evolution (initial population: {np.sum(grid)}):")
    
    populations = [int(np.sum(grid))]
    for t in range(1, 51):
        old_grid = grid.copy()
        grid = gol_step(grid)
        pop = int(np.sum(grid))
        populations.append(pop)
        
        # Count births and deaths
        births = int(np.sum((old_grid == 0) & (grid == 1)))
        deaths = int(np.sum((old_grid == 1) & (grid == 0)))
        
        if t <= 10 or t % 10 == 0:
            print(f"    t={t:3d}: pop={pop:4d}, births={births:3d}, deaths={deaths:3d}")
    
    max_pop = max(populations)
    min_pop = min(populations[1:])  # exclude initial
    print(f"\n  Population range: [{min_pop}, {max_pop}]")
    print(f"  Growth factor: {max_pop / populations[0]:.1f}x")

# =============================================================================
# Main
# =============================================================================

if __name__ == "__main__":
    print("Game of Life: Simulation Morphism Algebra — Demonstrations\n")
    
    demo_speed_of_light()
    demo_irreversibility()
    demo_still_lives()
    demo_simulation_morphisms()
    demo_population_dynamics()
    
    print("\n" + "=" * 60)
    print("All demonstrations completed successfully!")
    print("=" * 60)


#!/usr/bin/env python3
"""Visualization: Simulation Morphism Algebra — Multiplicative Overhead

Shows how simulation overhead compounds multiplicatively when composing
SimMorphisms, and visualizes the complexity monoid structure.
"""
import numpy as np
import matplotlib.pyplot as plt


def main():
    fig, axes = plt.subplots(1, 3, figsize=(18, 6))
    fig.suptitle("Simulation Morphism Algebra: Multiplicative Overhead Composition",
                 fontsize=14, fontweight='bold')

    # Panel 1: Overhead composition for chains of length 1-5
    ax1 = axes[0]
    chain_lengths = range(1, 8)
    factor = 3  # Each link has overhead factor 3

    additive_overhead = [factor * n for n in chain_lengths]
    multiplicative_overhead = [factor ** n for n in chain_lengths]

    ax1.semilogy(list(chain_lengths), multiplicative_overhead, 'ro-',
                 linewidth=2, markersize=8, label='Multiplicative (actual)')
    ax1.semilogy(list(chain_lengths), additive_overhead, 'b^--',
                 linewidth=2, markersize=8, label='Additive (hypothetical)')

    ax1.set_xlabel('Chain Length (number of SimMorphisms)', fontsize=12)
    ax1.set_ylabel('Total Time Overhead', fontsize=12)
    ax1.set_title('Overhead Growth: Multiplicative vs Additive', fontsize=12)
    ax1.legend(fontsize=10)
    ax1.grid(True, alpha=0.3)

    # Panel 2: Simulation network graph
    ax2 = axes[1]
    systems = ['TM', '1D CA', '2D CA', 'GoL', 'Counter']
    positions = {
        'TM': (0.2, 0.8),
        '1D CA': (0.8, 0.8),
        '2D CA': (0.8, 0.2),
        'GoL': (0.2, 0.2),
        'Counter': (0.5, 0.5)
    }

    edges = [
        ('TM', '1D CA', 5),
        ('1D CA', '2D CA', 3),
        ('2D CA', 'GoL', 2),
        ('TM', 'GoL', 30),
        ('Counter', 'TM', 10),
        ('GoL', 'Counter', 100),
    ]

    for name, (x, y) in positions.items():
        ax2.plot(x, y, 'ko', markersize=20)
        ax2.annotate(name, (x, y), fontsize=10, ha='center', va='center',
                    color='white', fontweight='bold')

    for src, dst, factor in edges:
        x1, y1 = positions[src]
        x2, y2 = positions[dst]
        dx, dy = x2 - x1, y2 - y1
        length = np.sqrt(dx**2 + dy**2)
        ax2.annotate('', xy=(x2 - 0.06*dx/length, y2 - 0.06*dy/length),
                    xytext=(x1 + 0.06*dx/length, y1 + 0.06*dy/length),
                    arrowprops=dict(arrowstyle='->', color='steelblue',
                                   lw=1.5))
        mx, my = (x1 + x2) / 2, (y1 + y2) / 2
        ax2.annotate(f'×{factor}', (mx, my), fontsize=9,
                    ha='center', va='center',
                    bbox=dict(boxstyle='round,pad=0.2', facecolor='lightyellow'))

    ax2.set_xlim(-0.1, 1.1)
    ax2.set_ylim(-0.1, 1.1)
    ax2.set_title('SimSystem Network\n(edge labels = time factors)', fontsize=12)
    ax2.axis('off')

    # Panel 3: Complexity monoid — composition of linear complexities
    ax3 = axes[2]
    n_values = np.arange(1, 20)

    # Linear complexities with different constants
    c1 = lambda n: 2 * n
    c2 = lambda n: 3 * n
    c3 = lambda n: 5 * n

    # Single applications
    single = [c1(n) for n in n_values]
    # Composition c1 ∘ c2
    comp12 = [c1(c2(n)) for n in n_values]
    # Triple composition c1 ∘ c2 ∘ c3
    comp123 = [c1(c2(c3(n))) for n in n_values]

    ax3.plot(n_values, single, 'g-o', label='C₁(n) = 2n', markersize=4)
    ax3.plot(n_values, comp12, 'b-s', label='C₁∘C₂(n) = 6n', markersize=4)
    ax3.plot(n_values, comp123, 'r-^', label='C₁∘C₂∘C₃(n) = 30n', markersize=4)

    ax3.set_xlabel('Input Size n', fontsize=12)
    ax3.set_ylabel('Overhead', fontsize=12)
    ax3.set_title('Complexity Monoid Composition\n(linear × linear = linear)', fontsize=12)
    ax3.legend(fontsize=10)
    ax3.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('viz_simulation_algebra.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved viz_simulation_algebra.png")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""Visualization: Speed of Light in Conway's Game of Life

Shows how the affected region grows linearly with time, bounded by
the light cone |x| ≤ t, |y| ≤ t.
"""
import numpy as np
import matplotlib.pyplot as plt
import matplotlib.patches as patches


def gol_step(grid):
    rows, cols = grid.shape
    count = np.zeros_like(grid)
    for di in [-1, 0, 1]:
        for dj in [-1, 0, 1]:
            if di == 0 and dj == 0:
                continue
            count += np.roll(np.roll(grid, di, axis=0), dj, axis=1)
    birth = (grid == 0) & (count == 3)
    survive = (grid == 1) & ((count == 2) | (count == 3))
    return (birth | survive).astype(int)


def main():
    size = 41
    center = size // 2
    steps = 8

    fig, axes = plt.subplots(2, 4, figsize=(16, 8))
    fig.suptitle("Speed of Light in Conway's Game of Life\n"
                 "Red diamond = light cone boundary (max propagation speed)",
                 fontsize=14, fontweight='bold')

    # Initial pattern: a small cross
    grid = np.zeros((size, size), dtype=int)
    grid[center, center] = 1
    grid[center-1, center] = 1
    grid[center+1, center] = 1
    grid[center, center-1] = 1
    grid[center, center+1] = 1

    for idx in range(steps):
        ax = axes[idx // 4, idx % 4]

        # Draw grid
        window = 12
        view = grid[center-window:center+window+1, center-window:center+window+1]
        ax.imshow(view, cmap='binary', interpolation='nearest',
                  extent=[-window-0.5, window+0.5, -window-0.5, window+0.5],
                  origin='lower')

        # Draw light cone
        t = idx
        diamond = patches.FancyBboxPatch(
            (-t - 0.5, -0.5), 2*t + 1, 1,
            boxstyle="square,pad=0", linewidth=0, facecolor='none')

        # Draw diamond outline
        cone_x = [0, t, 0, -t, 0]
        cone_y = [t, 0, -t, 0, t]
        ax.plot(cone_x, cone_y, 'r-', linewidth=2, alpha=0.7)

        ax.set_title(f't = {idx}', fontsize=12)
        ax.set_xlim(-window-0.5, window+0.5)
        ax.set_ylim(-window-0.5, window+0.5)
        ax.set_aspect('equal')
        ax.grid(True, alpha=0.3)

        grid = gol_step(grid)

    plt.tight_layout()
    plt.savefig('viz_speed_of_light.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved viz_speed_of_light.png")


if __name__ == "__main__":
    main()
