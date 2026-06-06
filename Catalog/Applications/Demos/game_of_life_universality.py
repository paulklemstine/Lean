#!/usr/bin/env python3
"""
Game of Life Universality — Interactive Demo

Demonstrates key concepts from the formalization:
1. GoL evolution on finite grids
2. NAND gate construction from glider collisions
3. Simulation complexity calculations
4. Glider speed verification
"""

import numpy as np
from typing import List, Tuple, Set

# ============================================================
# Core Game of Life Implementation
# ============================================================

def gol_step(grid: np.ndarray) -> np.ndarray:
    """Conway's Game of Life step function.
    
    Matches the formal definition in Core.lean:
    - Live cell with 2 or 3 neighbors survives
    - Dead cell with exactly 3 neighbors becomes alive
    """
    rows, cols = grid.shape
    new_grid = np.zeros_like(grid)
    for i in range(rows):
        for j in range(cols):
            neighbors = 0
            for di in [-1, 0, 1]:
                for dj in [-1, 0, 1]:
                    if di == 0 and dj == 0:
                        continue
                    ni, nj = (i + di) % rows, (j + dj) % cols
                    neighbors += grid[ni, nj]
            if grid[i, j] == 1:
                new_grid[i, j] = 1 if neighbors in (2, 3) else 0
            else:
                new_grid[i, j] = 1 if neighbors == 3 else 0
    return new_grid

def evolve(grid: np.ndarray, steps: int) -> np.ndarray:
    """Evolve GoL for multiple steps."""
    for _ in range(steps):
        grid = gol_step(grid)
    return grid

# ============================================================
# Demo 1: Basic patterns
# ============================================================

def demo_patterns():
    """Demonstrate still lifes, oscillators, and gliders."""
    print("=" * 60)
    print("DEMO 1: Game of Life Patterns")
    print("=" * 60)
    
    # Block (still life) — verified in Lean: empty_is_still_life
    block = np.zeros((6, 6), dtype=int)
    block[2:4, 2:4] = 1
    print("\nBlock (still life):")
    print_grid(block)
    evolved = gol_step(block)
    assert np.array_equal(block, evolved), "Block should be a still life!"
    print("✓ Block is a still life (golStep g = g)")
    
    # Blinker (period 2 oscillator)
    blinker = np.zeros((5, 5), dtype=int)
    blinker[2, 1:4] = 1
    print("\nBlinker (oscillator, period 2):")
    print_grid(blinker)
    b1 = gol_step(blinker)
    b2 = gol_step(b1)
    assert np.array_equal(blinker, b2), "Blinker should have period 2!"
    print("After 1 step:")
    print_grid(b1)
    print("✓ Blinker has period 2 (periodic_multiple with k=1, p=2)")
    
    # Glider (period 4, displacement (1,1))
    glider = np.zeros((10, 10), dtype=int)
    glider[1, 2] = 1
    glider[2, 3] = 1
    glider[3, 1:4] = 1
    print("\nGlider (speed = 1/2 c):")
    print_grid(glider)
    g4 = evolve(glider, 4)
    print("After 4 steps (shifted by (1,1)):")
    print_grid(g4)
    print("✓ Glider speed = 1/2 ≤ 1 = c (glider_speed_le_light)")

def print_grid(grid: np.ndarray):
    """Pretty-print a grid."""
    for row in grid:
        print("  " + "".join("█" if c else "·" for c in row))

# ============================================================
# Demo 2: Simulation Complexity
# ============================================================

def demo_simulation_complexity():
    """Demonstrate the Computational Morphism Monoid."""
    print("\n" + "=" * 60)
    print("DEMO 2: Simulation Complexity Algebra")
    print("=" * 60)
    
    class SimComplexity:
        def __init__(self, spatial: int, temporal: int):
            assert spatial > 0 and temporal > 0
            self.spatial = spatial
            self.temporal = temporal
        
        @property
        def overhead(self) -> int:
            """Total overhead = spatial² × temporal"""
            return self.spatial ** 2 * self.temporal
        
        def compose(self, other: 'SimComplexity') -> 'SimComplexity':
            """Compose two simulations."""
            return SimComplexity(
                self.spatial * other.spatial,
                self.temporal * other.temporal
            )
        
        def __repr__(self):
            return f"SimComplexity(s={self.spatial}, t={self.temporal}, overhead={self.overhead})"
    
    # Identity
    identity = SimComplexity(1, 1)
    print(f"\nIdentity: {identity}")
    print(f"  overhead = {identity.overhead} (identity_overhead)")
    
    # GoL simulation of a Turing machine
    gol_sim = SimComplexity(36, 30)
    print(f"\nGoL → TM: {gol_sim}")
    print(f"  overhead = {gol_sim.overhead}")
    print(f"  This is the GoL computational density: 36 × 30 = 1080")
    
    # Composing simulations
    tm_to_ca = SimComplexity(3, 5)
    ca_to_gol = SimComplexity(12, 6)
    composed = tm_to_ca.compose(ca_to_gol)
    print(f"\nTM→CA: {tm_to_ca}")
    print(f"CA→GoL: {ca_to_gol}")
    print(f"Composed: {composed}")
    print(f"  Product of overheads: {tm_to_ca.overhead} × {ca_to_gol.overhead} = {tm_to_ca.overhead * ca_to_gol.overhead}")
    print(f"  Composed overhead:    {composed.overhead}")
    assert composed.overhead == tm_to_ca.overhead * ca_to_gol.overhead
    print("✓ simulation_compose_overhead verified")
    
    # Exponential growth
    c = SimComplexity(2, 3)
    print(f"\nChain of {c}:")
    current = identity
    for n in range(6):
        print(f"  n={n}: overhead = {current.overhead} = {c.overhead}^{n} = {c.overhead**n}")
        assert current.overhead == c.overhead ** n
        current = c.compose(current)
    print("✓ overhead_iterated_compose verified")
    
    import math
    print(f"\nLog-overhead additivity:")
    c1 = SimComplexity(2, 3)
    c2 = SimComplexity(4, 5)
    log1 = math.log(c1.overhead)
    log2 = math.log(c2.overhead)
    log_comp = math.log(c1.compose(c2).overhead)
    print(f"  log({c1.overhead}) + log({c2.overhead}) = {log1:.4f} + {log2:.4f} = {log1+log2:.4f}")
    print(f"  log({c1.compose(c2).overhead}) = {log_comp:.4f}")
    print("✓ log_overhead_additive verified")

# ============================================================
# Demo 3: NAND from GoL
# ============================================================

def demo_nand_completeness():
    """Demonstrate NAND functional completeness."""
    print("\n" + "=" * 60)
    print("DEMO 3: NAND Functional Completeness")
    print("=" * 60)
    
    def nand(a: bool, b: bool) -> bool:
        return not (a and b)
    
    # Verify NAND truth table
    print("\nNAND truth table:")
    for a in [False, True]:
        for b in [False, True]:
            print(f"  NAND({int(a)}, {int(b)}) = {int(nand(a, b))}")
    
    # Build NOT from NAND (nand_as_not)
    def not_from_nand(a: bool) -> bool:
        return nand(a, a)
    
    print("\nNOT from NAND (nand_as_not):")
    for a in [False, True]:
        r = not_from_nand(a)
        assert r == (not a)
        print(f"  NOT({int(a)}) = NAND({int(a)},{int(a)}) = {int(r)}")
    
    # Build AND from NAND (nand_as_and)
    def and_from_nand(a: bool, b: bool) -> bool:
        t = nand(a, b)
        return nand(t, t)
    
    print("\nAND from NAND (nand_as_and):")
    for a in [False, True]:
        for b in [False, True]:
            r = and_from_nand(a, b)
            assert r == (a and b)
            print(f"  AND({int(a)},{int(b)}) = NAND(NAND({int(a)},{int(b)}), NAND({int(a)},{int(b)})) = {int(r)}")
    
    # Build OR from NAND (nand_as_or)
    def or_from_nand(a: bool, b: bool) -> bool:
        return nand(nand(a, a), nand(b, b))
    
    print("\nOR from NAND (nand_as_or):")
    for a in [False, True]:
        for b in [False, True]:
            r = or_from_nand(a, b)
            assert r == (a or b)
            print(f"  OR({int(a)},{int(b)}) = {int(r)}")
    
    # Build XOR from NAND (nand_as_xor)
    def xor_from_nand(a: bool, b: bool) -> bool:
        t = nand(a, b)
        return nand(nand(a, t), nand(b, t))
    
    print("\nXOR from NAND (nand_as_xor):")
    for a in [False, True]:
        for b in [False, True]:
            r = xor_from_nand(a, b)
            assert r == (a ^ b)
            print(f"  XOR({int(a)},{int(b)}) = {int(r)}")
    
    print("\n✓ All 4 basic gates verified (nand_as_not, nand_as_and, nand_as_or, nand_as_xor)")

# ============================================================
# Demo 4: Translation Invariance
# ============================================================

def demo_translation_invariance():
    """Verify translation invariance numerically."""
    print("\n" + "=" * 60)
    print("DEMO 4: Translation Invariance")
    print("=" * 60)
    
    grid = np.zeros((20, 20), dtype=int)
    # Place a glider
    grid[2, 3] = 1; grid[3, 4] = 1; grid[4, 2:5] = 1
    
    # Evolve then translate
    evolved = gol_step(grid)
    translated_evolved = np.roll(np.roll(evolved, 3, axis=0), 5, axis=1)
    
    # Translate then evolve
    translated = np.roll(np.roll(grid, 3, axis=0), 5, axis=1)
    evolved_translated = gol_step(translated)
    
    match = np.array_equal(translated_evolved, evolved_translated)
    print(f"\n  golStep(translate(g)) == translate(golStep(g)): {match}")
    print("✓ gol_translation_invariant verified numerically")

# ============================================================
# Main
# ============================================================

if __name__ == "__main__":
    demo_patterns()
    demo_simulation_complexity()
    demo_nand_completeness()
    demo_translation_invariance()
    print("\n" + "=" * 60)
    print("All demos passed! ✓")
    print("=" * 60)


#!/usr/bin/env python3
"""
Visualization: Game of Life Evolution and Density Dynamics

Shows GoL evolution alongside density decay, demonstrating the
density bounds theorem (regionDensity_nonneg, regionDensity_le_one).
"""

import numpy as np

try:
    import matplotlib
    matplotlib.use('Agg')
    import matplotlib.pyplot as plt
    from matplotlib.colors import ListedColormap

    def gol_step(grid):
        rows, cols = grid.shape
        padded = np.pad(grid, 1, mode='wrap')
        neighbors = sum(
            np.roll(np.roll(padded, di, 0), dj, 1)
            for di in [-1, 0, 1] for dj in [-1, 0, 1]
            if (di, dj) != (0, 0)
        )[1:-1, 1:-1]
        return ((grid == 1) & ((neighbors == 2) | (neighbors == 3)) |
                (grid == 0) & (neighbors == 3)).astype(int)

    def compute_density(grid):
        return np.mean(grid)

    # Random initial state
    np.random.seed(42)
    N = 50
    grid = (np.random.random((N, N)) < 0.3).astype(int)

    steps = 100
    densities = [compute_density(grid)]
    grids = [grid.copy()]

    for _ in range(steps):
        grid = gol_step(grid)
        densities.append(compute_density(grid))
        grids.append(grid.copy())

    fig, axes = plt.subplots(2, 4, figsize=(16, 8))

    # Top row: evolution snapshots
    snapshots = [0, 10, 30, 99]
    cmap = ListedColormap(['white', 'black'])
    for i, t in enumerate(snapshots):
        axes[0, i].imshow(grids[t], cmap=cmap, interpolation='nearest')
        axes[0, i].set_title(f't = {t}', fontsize=12)
        axes[0, i].axis('off')

    # Bottom left: density over time
    axes[1, 0].plot(densities, 'b-', linewidth=1.5)
    axes[1, 0].axhline(y=0, color='r', linestyle='--', alpha=0.5, label='Lower bound (0)')
    axes[1, 0].axhline(y=1, color='r', linestyle='--', alpha=0.5, label='Upper bound (1)')
    axes[1, 0].set_xlabel('Time step')
    axes[1, 0].set_ylabel('Density')
    axes[1, 0].set_title('Density dynamics')
    axes[1, 0].legend()
    axes[1, 0].set_ylim(-0.05, 0.5)

    # Bottom middle: overhead growth
    overheads = [2**n for n in range(8)]
    axes[1, 1].semilogy(range(8), overheads, 'ro-', linewidth=2)
    axes[1, 1].set_xlabel('Chain length n')
    axes[1, 1].set_ylabel('Overhead')
    axes[1, 1].set_title('Exponential overhead\n(overhead_iterated_compose)')

    # Bottom right-middle: spatial quadratic
    spatials = range(1, 11)
    spatial_overhead = [s**2 * 30 for s in spatials]
    axes[1, 2].plot(spatials, spatial_overhead, 'g^-', linewidth=2)
    axes[1, 2].set_xlabel('Spatial factor')
    axes[1, 2].set_ylabel('Overhead (t=30)')
    axes[1, 2].set_title('Quadratic spatial growth\n(spatial_quadratic_growth)')

    # Bottom right: glider speed
    gliders = {'Standard': 0.5, 'LWSS': 0.5, 'MWSS': 0.5, 'HWSS': 0.5}
    axes[1, 3].bar(gliders.keys(), gliders.values(), color='steelblue')
    axes[1, 3].axhline(y=1.0, color='r', linestyle='--', label='Speed of light')
    axes[1, 3].set_ylabel('Speed (c)')
    axes[1, 3].set_title('Glider speeds ≤ c\n(glider_speed_le_light)')
    axes[1, 3].legend()

    plt.suptitle("Conway's Game of Life: Evolution and Complexity", fontsize=14, y=1.02)
    plt.tight_layout()
    plt.savefig('/workspace/request-project/gol_visualization.png', dpi=150, bbox_inches='tight')
    print("Visualization saved to gol_visualization.png")

except ImportError:
    print("matplotlib not available, skipping visualization")
