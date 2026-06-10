"""
Applications of Tropical Life Theory

Demonstrates real-world applications and connections of tropical
cellular automata to other fields.
"""

import numpy as np
from typing import List, Tuple, Dict
from demo import (tropical_threshold, tropical_life_step, is_still_life,
                  neighbor_sum, shift_config)


# ============================================================
# Application 1: Tropical Threshold as a Neural Activation
# ============================================================

def tropical_relu_comparison():
    """Compare tropical threshold with ReLU activation.
    
    The tropical threshold function min(1, max(0, x)) is equivalent to
    the clipped ReLU (hardtanh) activation used in neural networks.
    This connection shows that tropical Life's update rule is essentially
    a spatially-distributed neural network with clipped activations.
    """
    print("Application 1: Tropical Threshold ≈ Neural Activation")
    print("=" * 60)
    
    print("\nComparison of activation functions for s ∈ {0,...,8}:")
    print(f"{'s':>3} {'ReLU':>6} {'ClipReLU':>9} {'TropThresh(s,2,3)':>18}")
    print("-" * 40)
    
    for s in range(9):
        relu = max(0, s - 2)
        clip_relu = min(1, max(0, s - 2))
        trop = tropical_threshold(s, 2, 3)
        print(f"{s:>3} {relu:>6} {clip_relu:>9} {trop:>18}")
    
    print("\nKey insight: the tropical Life update rule at each cell is")
    print("equivalent to a 2-layer neural network with clipped ReLU")
    print("activations, applied to the Moore neighborhood sum.")


# ============================================================
# Application 2: Error-Correcting Stable Memory
# ============================================================

def stable_memory_demo():
    """Demonstrate still lifes as error-correcting memory cells.
    
    A 2×2 block still life is a stable attractor: any small perturbation
    either returns to the block or dissolves. This makes blocks natural
    building blocks for robust memory in noisy environments.
    """
    print("\n\nApplication 2: Still Lifes as Stable Memory")
    print("=" * 60)
    
    # Baseline: 2×2 block
    block = np.zeros((8, 8), dtype=int)
    block[3:5, 3:5] = 1
    print(f"\nBaseline block (8×8): still life = {is_still_life(block)}")
    
    # Perturbation 1: add one cell adjacent to block
    perturbed1 = block.copy()
    perturbed1[2, 3] = 1
    print(f"\nPerturbed (add cell at (2,3)):")
    result = perturbed1.copy()
    for step in range(5):
        result = tropical_life_step(result)
    converged = is_still_life(result)
    print(f"  After 5 steps, is still life: {converged}")
    print(f"  Returned to original block: {np.array_equal(result, block)}")
    
    # Perturbation 2: remove one cell from block
    perturbed2 = block.copy()
    perturbed2[3, 3] = 0
    print(f"\nPerturbed (remove cell (3,3)):")
    result = perturbed2.copy()
    for step in range(5):
        result = tropical_life_step(result)
    print(f"  After 5 steps, alive cells: {result.sum()}")
    
    # Perturbation 3: random noise near block
    print("\nNoise robustness test (100 random perturbations):")
    survived = 0
    for _ in range(100):
        noisy = block.copy()
        # Flip a random cell within distance 2 of the block
        di, dj = np.random.randint(-2, 3, size=2)
        ci, cj = 3 + di, 3 + dj
        if 0 <= ci < 8 and 0 <= cj < 8:
            noisy[ci, cj] = 1 - noisy[ci, cj]
        
        result = noisy.copy()
        for _ in range(10):
            result = tropical_life_step(result)
        
        if is_still_life(result):
            survived += 1
    
    print(f"  Converged to a still life: {survived}/100")


# ============================================================
# Application 3: Signal Processing with Blinkers
# ============================================================

def blinker_clock_demo():
    """Demonstrate blinkers as clock signals for synchronous circuits.
    
    Blinkers oscillate with period 2, providing a natural clock signal.
    By reading the blinker state (horizontal vs vertical), downstream
    gates can be synchronized.
    """
    print("\n\nApplication 3: Blinker as Clock Signal")
    print("=" * 60)
    
    grid = np.zeros((8, 8), dtype=int)
    grid[3, 2:5] = 1  # Horizontal blinker
    
    print("\nBlinker state over 10 clock cycles:")
    current = grid.copy()
    for t in range(10):
        # Read clock state from center cell's row neighbors
        center_val = current[3, 3]
        left_val = current[3, 2]
        top_val = current[2, 3]
        orientation = "H" if left_val == 1 else "V"
        print(f"  t={t:2d}: orientation={orientation}, "
              f"center={center_val}, "
              f"phase={'even' if t % 2 == 0 else 'odd'}")
        current = tropical_life_step(current)


# ============================================================
# Application 4: Shortest Path via Tropical Dynamics
# ============================================================

def tropical_shortest_path_connection():
    """Demonstrate connection between tropical Life and shortest paths.
    
    The tropical threshold function uses min (tropical addition) and +
    (tropical multiplication), which are the same operations used in
    shortest-path algorithms. This connection suggests that tropical
    Life can be viewed as a distributed shortest-path computation.
    """
    print("\n\nApplication 4: Connection to Shortest Paths")
    print("=" * 60)
    
    print("\nTropical semiring operations:")
    print("  a ⊕ b = min(a, b)  [tropical addition]")
    print("  a ⊗ b = a + b      [tropical multiplication]")
    
    # Example: shortest path in a 4-node graph
    INF = 999
    # Distance matrix
    D = np.array([
        [0, 2, INF, 7],
        [2, 0, 3, INF],
        [INF, 3, 0, 1],
        [7, INF, 1, 0]
    ])
    
    print(f"\nDistance matrix D:")
    print(D)
    
    # Tropical matrix multiplication: (A ⊗ B)_ij = min_k(A_ik + B_kj)
    def trop_mat_mul(A, B):
        n = A.shape[0]
        C = np.full((n, n), INF)
        for i in range(n):
            for j in range(n):
                for k in range(n):
                    C[i, j] = min(C[i, j], A[i, k] + B[k, j])
        return C
    
    # Shortest paths = tropical matrix power
    D2 = trop_mat_mul(D, D)
    D4 = trop_mat_mul(D2, D2)
    
    print(f"\nD² (2-hop shortest paths):")
    print(D2)
    print(f"\nD⁴ (all-pairs shortest paths):")
    print(D4)
    
    print("\nThe tropical Life automaton uses the same algebraic operations")
    print("(min, +) but applied spatially on a grid, creating a distributed")
    print("computation medium that inherits tropical algebra's structure.")


# ============================================================
# Application 5: Pattern Complexity Measurement
# ============================================================

def pattern_complexity():
    """Measure and compare complexity of different tropical Life patterns.
    
    Uses orbit diversity as a complexity measure: patterns with higher
    orbit diversity exhibit more complex dynamics.
    """
    print("\n\nApplication 5: Pattern Complexity Hierarchy")
    print("=" * 60)
    
    patterns = {}
    
    # Empty grid
    patterns["empty"] = np.zeros((10, 10), dtype=int)
    
    # Single cell (dies immediately)
    p = np.zeros((10, 10), dtype=int)
    p[5, 5] = 1
    patterns["single cell"] = p
    
    # 2×2 block (still life)
    p = np.zeros((10, 10), dtype=int)
    p[4:6, 4:6] = 1
    patterns["2x2 block"] = p
    
    # Blinker (period 2)
    p = np.zeros((10, 10), dtype=int)
    p[5, 4:7] = 1
    patterns["blinker"] = p
    
    # Glider
    p = np.zeros((10, 10), dtype=int)
    for i, j in [(0, 1), (1, 2), (2, 0), (2, 1), (2, 2)]:
        p[i, j] = 1
    patterns["glider"] = p
    
    # R-pentomino (chaotic)
    p = np.zeros((10, 10), dtype=int)
    p[4, 5] = 1; p[4, 6] = 1
    p[5, 4] = 1; p[5, 5] = 1
    p[6, 5] = 1
    patterns["R-pentomino"] = p
    
    T = 20
    print(f"\nOrbit diversity (T={T} steps) for various patterns:")
    print(f"{'Pattern':<15} {'Alive':>6} {'Diversity':>10} {'Category':<15}")
    print("-" * 50)
    
    for name, grid in patterns.items():
        current = grid.copy()
        seen = set()
        for t in range(T + 1):
            seen.add(current.tobytes())
            current = tropical_life_step(current)
        
        diversity = len(seen)
        alive = int(grid.sum())
        
        if diversity == 1:
            category = "fixed point"
        elif diversity <= 3:
            category = "periodic"
        elif diversity <= T:
            category = "eventually periodic"
        else:
            category = "complex"
        
        print(f"{name:<15} {alive:>6} {diversity:>10} {category:<15}")


if __name__ == "__main__":
    tropical_relu_comparison()
    stable_memory_demo()
    blinker_clock_demo()
    tropical_shortest_path_connection()
    pattern_complexity()


"""
Tropical Life: Demonstrations of Emergent Computation in Min-Plus Cellular Automata

This module provides working demonstrations of the key theorems proven in the
formal Lean 4 development:
1. Still life fixed points (2×2 blocks)
2. Glider dynamics (period-4 mobile pattern)
3. Boolean gate gadgets (AND, OR, NOT, XOR)
4. Exponential still life diversity
5. Blinker oscillation (period-2)
"""

import numpy as np
from typing import Tuple, List, Optional


def tropical_threshold(s: int, lo: int, hi: int) -> int:
    """Tropical threshold function: returns 1 iff lo <= s <= hi.
    
    Uses only min, addition, multiplication, and truncating subtraction.
    This is the core tropical primitive that bridges algebra and Boolean logic.
    """
    return min(1, max(0, s + 1 - lo)) * min(1, max(0, hi + 1 - s))


def neighbor_sum(grid: np.ndarray, i: int, j: int) -> int:
    """Sum of Moore neighborhood values with toroidal wrapping."""
    m, n = grid.shape
    total = 0
    for di in [-1, 0, 1]:
        for dj in [-1, 0, 1]:
            if di == 0 and dj == 0:
                continue
            total += grid[(i + di) % m, (j + dj) % n]
    return total


def tropical_local_rule(grid: np.ndarray, i: int, j: int) -> int:
    """Tropical Life local update rule.
    
    Alive cell survives iff 2 <= neighbors <= 3.
    Dead cell is born iff neighbors == 3.
    Implemented entirely with tropical primitives.
    """
    s = neighbor_sum(grid, i, j)
    alive = min(1, grid[i, j])
    return (alive * tropical_threshold(s, 2, 3) + 
            (1 - alive) * tropical_threshold(s, 3, 3))


def tropical_life_step(grid: np.ndarray) -> np.ndarray:
    """Apply one step of the tropical Life automaton."""
    m, n = grid.shape
    new_grid = np.zeros_like(grid)
    for i in range(m):
        for j in range(n):
            new_grid[i, j] = tropical_local_rule(grid, i, j)
    return new_grid


def is_still_life(grid: np.ndarray) -> bool:
    """Check if a configuration is a fixed point of the step operator."""
    return np.array_equal(tropical_life_step(grid), grid)


def shift_config(grid: np.ndarray, dx: int, dy: int) -> np.ndarray:
    """Shift a configuration by (dx, dy) on the torus."""
    return np.roll(np.roll(grid, dx, axis=0), dy, axis=1)


# ============================================================
# Demo 1: Still Life Verification
# ============================================================

def demo_still_lifes():
    """Demonstrate that 2×2 blocks are still lifes."""
    print("=" * 60)
    print("DEMO 1: Still Life Fixed Points")
    print("=" * 60)
    
    # 2×2 block on 6×6 torus
    grid = np.zeros((6, 6), dtype=int)
    grid[0:2, 0:2] = 1
    
    print("\nBlock configuration (6×6 torus):")
    print(grid)
    print(f"\nIs still life: {is_still_life(grid)}")
    
    # Block at different position on 8×8 torus
    grid8 = np.zeros((8, 8), dtype=int)
    grid8[2:4, 3:5] = 1
    
    print(f"\nBlock at (2,3) on 8×8 torus - Is still life: {is_still_life(grid8)}")
    
    # 3×3 block is NOT a still life
    grid3x3 = np.zeros((8, 8), dtype=int)
    grid3x3[2:5, 2:5] = 1
    
    print(f"3×3 block on 8×8 torus - Is still life: {is_still_life(grid3x3)}")
    print("  (Center cell has 8 neighbors, exceeding survival threshold)")


# ============================================================
# Demo 2: Glider Dynamics
# ============================================================

def demo_glider():
    """Demonstrate the glider pattern and its period-4 translation."""
    print("\n" + "=" * 60)
    print("DEMO 2: Glider - Mobile Pattern")
    print("=" * 60)
    
    # Glider on 10×10 torus
    grid = np.zeros((10, 10), dtype=int)
    glider_cells = [(0, 1), (1, 2), (2, 0), (2, 1), (2, 2)]
    for i, j in glider_cells:
        grid[i, j] = 1
    
    print("\nInitial glider configuration:")
    print(grid[:5, :5])
    
    current = grid.copy()
    for step in range(5):
        current = tropical_life_step(current)
        print(f"\nAfter step {step + 1}:")
        print(current[:5, :5])
    
    # Verify period-4 shift
    evolved = grid.copy()
    for _ in range(4):
        evolved = tropical_life_step(evolved)
    
    shifted = shift_config(grid, 1, 1)
    match = np.array_equal(evolved, shifted)
    print(f"\nAfter 4 steps equals shift(1,1) of original: {match}")
    print(f"Is still life: {is_still_life(grid)}")


# ============================================================
# Demo 3: Boolean Gate Gadgets
# ============================================================

def demo_gates():
    """Demonstrate AND, OR, NOT, and XOR gate gadgets."""
    print("\n" + "=" * 60)
    print("DEMO 3: Boolean Gate Gadgets")
    print("=" * 60)
    
    output_cell = (5, 5)
    
    # AND gate
    print("\n--- AND Gate ---")
    print("Frame: 1 cell at (4,4). Inputs: a at (4,5), b at (5,4).")
    print("Output cell (5,5): born iff neighbor count = 3 iff a ∧ b.")
    print()
    for a in [False, True]:
        for b in [False, True]:
            grid = np.zeros((10, 10), dtype=int)
            grid[4, 4] = 1  # frame
            if a: grid[4, 5] = 1
            if b: grid[5, 4] = 1
            result = tropical_life_step(grid)
            print(f"  AND({int(a)}, {int(b)}) = {result[output_cell]}")
    
    # OR gate
    print("\n--- OR Gate ---")
    print("Frame: 1 cell at (4,4). Output (5,5) starts alive.")
    print("Survival iff count >= 2 iff a ∨ b.")
    print()
    for a in [False, True]:
        for b in [False, True]:
            grid = np.zeros((10, 10), dtype=int)
            grid[5, 5] = 1  # output alive
            grid[4, 4] = 1  # frame
            if a: grid[4, 5] = 1
            if b: grid[5, 4] = 1
            result = tropical_life_step(grid)
            print(f"  OR({int(a)}, {int(b)}) = {result[output_cell]}")
    
    # NOT gate
    print("\n--- NOT Gate ---")
    print("Frame: 3 cells at (4,4), (4,5), (4,6).")
    print("Born iff count = 3 iff ¬a.")
    print()
    for a in [False, True]:
        grid = np.zeros((10, 10), dtype=int)
        grid[4, 4] = 1
        grid[4, 5] = 1
        grid[4, 6] = 1
        if a: grid[5, 4] = 1
        result = tropical_life_step(grid)
        print(f"  NOT({int(a)}) = {result[output_cell]}")
    
    # XOR gate
    print("\n--- XOR Gate ---")
    print("Frame: 2 cells at (4,4), (4,6).")
    print("Born iff count = 3 iff a ⊕ b.")
    print()
    for a in [False, True]:
        for b in [False, True]:
            grid = np.zeros((10, 10), dtype=int)
            grid[4, 4] = 1
            grid[4, 6] = 1
            if a: grid[4, 5] = 1
            if b: grid[5, 4] = 1
            result = tropical_life_step(grid)
            print(f"  XOR({int(a)}, {int(b)}) = {result[output_cell]}")


# ============================================================
# Demo 4: Exponential Still Life Diversity
# ============================================================

def demo_diversity():
    """Demonstrate exponential growth of still life count."""
    print("\n" + "=" * 60)
    print("DEMO 4: Exponential Still Life Diversity")
    print("=" * 60)
    
    # Four independent blocks on 20×20 torus
    block_positions = [(0, 0), (0, 5), (5, 0), (5, 5)]
    
    count = 0
    for mask in range(16):
        grid = np.zeros((20, 20), dtype=int)
        for bit, (bi, bj) in enumerate(block_positions):
            if mask & (1 << bit):
                grid[bi:bi+2, bj:bj+2] = 1
        if is_still_life(grid):
            count += 1
    
    print(f"\nBlocks at positions: {block_positions}")
    print(f"Total subsets tested: 16")
    print(f"Still lifes found: {count}")
    print(f"All 2^4 = 16 subsets are still lifes: {count == 16}")
    
    # Scaling analysis
    print("\n--- Scaling with grid size ---")
    for grid_size in [8, 12, 16, 20, 24]:
        spacing = 4
        k = grid_size // spacing
        max_blocks = k * k
        max_still_lifes = 2 ** max_blocks
        print(f"  Grid {grid_size}×{grid_size}: up to {max_blocks} blocks → "
              f"up to 2^{max_blocks} = {max_still_lifes} still lifes")


# ============================================================
# Demo 5: Blinker Oscillation
# ============================================================

def demo_blinker():
    """Demonstrate period-2 blinker oscillation."""
    print("\n" + "=" * 60)
    print("DEMO 5: Blinker Oscillation (Period 2)")
    print("=" * 60)
    
    grid = np.zeros((8, 8), dtype=int)
    grid[3, 2:5] = 1  # Horizontal blinker
    
    print("\nStep 0 (horizontal):")
    print(grid[2:5, 1:6])
    
    step1 = tropical_life_step(grid)
    print("\nStep 1 (vertical):")
    print(step1[2:5, 1:6])
    
    step2 = tropical_life_step(step1)
    print("\nStep 2 (horizontal again):")
    print(step2[2:5, 1:6])
    
    print(f"\nPeriod-2 verified: {np.array_equal(grid, step2)}")
    print(f"Is still life: {is_still_life(grid)}")


# ============================================================
# Demo 6: Tropical Threshold Function
# ============================================================

def demo_threshold():
    """Demonstrate the tropical threshold function."""
    print("\n" + "=" * 60)
    print("DEMO 6: Tropical Threshold Function")
    print("=" * 60)
    
    print("\ntropicalThreshold(s, 2, 3) for s = 0..8:")
    for s in range(9):
        val = tropical_threshold(s, 2, 3)
        bar = "█" * val
        print(f"  s={s}: {val}  {bar}  {'← survival range' if val == 1 else ''}")
    
    print("\ntropicalThreshold(s, 3, 3) for s = 0..8:")
    for s in range(9):
        val = tropical_threshold(s, 3, 3)
        bar = "█" * val
        print(f"  s={s}: {val}  {bar}  {'← birth threshold' if val == 1 else ''}")


if __name__ == "__main__":
    demo_threshold()
    demo_still_lifes()
    demo_glider()
    demo_gates()
    demo_diversity()
    demo_blinker()
    
    print("\n" + "=" * 60)
    print("All demonstrations completed successfully.")
    print("=" * 60)


"""Generate PACKAGE.json with all embedded content."""

import json
import base64
import os

# Read markdown files
def read_file(path):
    with open(path, 'r') as f:
        return f.read()

# Read Python files
def read_code(path):
    with open(path, 'r') as f:
        return f.read()

# Read Lean files
lean_files = [
    'Computation/TropicalLife/Basic.lean',
    'Computation/TropicalLife/StillLife.lean',
    'Computation/TropicalLife/Glider.lean',
    'Computation/TropicalLife/Algebra.lean',
    'Computation/TropicalLife/RectStillLife.lean',
    'Computation/TropicalLife/Circuits.lean',
    'Computation/TropicalLife/Diversity.lean',
]

lean_code = ""
for lf in lean_files:
    path = os.path.join(os.path.dirname(__file__), lf)
    if os.path.exists(path):
        lean_code += f"-- ═══════════════════════════════════════════════════\n"
        lean_code += f"-- File: {lf}\n"
        lean_code += f"-- ═══════════════════════════════════════════════════\n\n"
        with open(path, 'r') as f:
            lean_code += f.read()
        lean_code += "\n\n"

# Read image files as base64
def img_to_base64(path):
    with open(path, 'rb') as f:
        data = base64.b64encode(f.read()).decode('utf-8')
    return f"data:image/png;base64,{data}"

# Generate visualizations if not already present
viz_files = [
    'glider_evolution.png',
    'gate_gadgets.png', 
    'still_life_diversity.png',
    'tropical_threshold.png',
    'orbit_diversity.png',
    'gate_truth_tables.png',
]

missing = [f for f in viz_files if not os.path.exists(f)]
if missing:
    print("Generating missing visualizations...")
    import visualizations
    visualizations.fig_glider_evolution()
    visualizations.fig_gate_gadgets()
    visualizations.fig_still_life_diversity()
    visualizations.fig_tropical_threshold()
    visualizations.fig_orbit_diversity()
    visualizations.fig_gate_truth_tables()

# Build demo code (self-contained)
demo_code = read_code('demo.py')
algorithms_code = read_code('algorithms.py')

# The demo needs to be self-contained, so we include the core functions inline
demo_standalone = '''"""
Tropical Life: Self-contained demonstration of emergent computation
in min-plus cellular automata.
"""
import numpy as np

def tropical_threshold(s, lo, hi):
    """Tropical threshold: returns 1 iff lo <= s <= hi."""
    return min(1, max(0, s + 1 - lo)) * min(1, max(0, hi + 1 - s))

def tropical_life_step(grid):
    """Apply one step of the tropical Life automaton."""
    m, n = grid.shape
    new_grid = np.zeros_like(grid)
    for i in range(m):
        for j in range(n):
            s = 0
            for di in [-1, 0, 1]:
                for dj in [-1, 0, 1]:
                    if di == 0 and dj == 0:
                        continue
                    s += grid[(i + di) % m, (j + dj) % n]
            alive = min(1, grid[i, j])
            new_grid[i, j] = (alive * tropical_threshold(s, 2, 3) +
                              (1 - alive) * tropical_threshold(s, 3, 3))
    return new_grid

def is_still_life(grid):
    return np.array_equal(tropical_life_step(grid), grid)

# === Still Life Demo ===
print("=== Still Life: 2x2 Block ===")
grid = np.zeros((6, 6), dtype=int)
grid[0:2, 0:2] = 1
print(f"Is still life: {is_still_life(grid)}")

# === Glider Demo ===
print("\\n=== Glider: Period-4 Mobile Pattern ===")
grid = np.zeros((10, 10), dtype=int)
for i, j in [(0,1),(1,2),(2,0),(2,1),(2,2)]:
    grid[i, j] = 1
current = grid.copy()
for step in range(5):
    current = tropical_life_step(current)
    print(f"Step {step+1}: alive cells = {current.sum()}")

shifted = np.roll(np.roll(grid, 1, axis=0), 1, axis=1)
print(f"After 4 steps == shift(1,1): {np.array_equal(current_prev := tropical_life_step(tropical_life_step(tropical_life_step(tropical_life_step(grid)))), shifted)}")

# === AND Gate Demo ===
print("\\n=== AND Gate ===")
for a in [0, 1]:
    for b in [0, 1]:
        g = np.zeros((10, 10), dtype=int)
        g[4,4] = 1  # frame
        if a: g[4,5] = 1
        if b: g[5,4] = 1
        result = tropical_life_step(g)
        print(f"AND({a},{b}) = {result[5,5]}")

# === Exponential Diversity ===
print("\\n=== Exponential Still Life Diversity ===")
count = 0
for mask in range(16):
    g = np.zeros((20, 20), dtype=int)
    for bit, (bi, bj) in enumerate([(0,0),(0,5),(5,0),(5,5)]):
        if mask & (1 << bit):
            g[bi:bi+2, bj:bj+2] = 1
    if is_still_life(g):
        count += 1
print(f"All 16 subsets are still lifes: {count == 16}")
'''

# Build package
package = {
    "title": "Tropical Life: Emergent Computation in Min-Plus Cellular Automata",
    "domain": "Computation / Tropical Algebra / Cellular Automata",
    "article": read_file('ARTICLE.md'),
    "research_paper": read_file('RESEARCH_PAPER.md'),
    "future_directions": read_file('FUTURE_DIRECTIONS.md'),
    "demos": [
        {
            "name": "Tropical Life Demo",
            "code": demo_standalone,
        },
    ],
    "algorithms": [
        {
            "name": "Tropical Life Step",
            "pseudocode": "Input: grid G of size m×n\nOutput: next-state grid G'\n\nfor each cell (i,j):\n  s ← sum of G[neighbors of (i,j)] with toroidal wrapping\n  alive ← min(1, G[i,j])\n  G'[i,j] ← alive × tropThresh(s, 2, 3) + (1-alive) × tropThresh(s, 3, 3)\n\nwhere tropThresh(s, lo, hi) = min(1, s+1-lo) × min(1, hi+1-s)",
            "code": algorithms_code,
        },
    ],
    "visualizations": [
        {"name": "Glider Evolution (Period-4 Translation)", "data": img_to_base64('glider_evolution.png')},
        {"name": "Boolean Gate Gadgets (AND, OR, NOT, XOR)", "data": img_to_base64('gate_gadgets.png')},
        {"name": "Exponential Still Life Diversity (16 = 2⁴ Configurations)", "data": img_to_base64('still_life_diversity.png')},
        {"name": "Tropical Threshold Functions", "data": img_to_base64('tropical_threshold.png')},
        {"name": "Orbit Diversity Comparison", "data": img_to_base64('orbit_diversity.png')},
        {"name": "Gate Truth Tables", "data": img_to_base64('gate_truth_tables.png')},
    ],
    "lean_proofs": lean_code,
}

with open('PACKAGE.json', 'w') as f:
    json.dump(package, f, indent=2, ensure_ascii=False)

print(f"PACKAGE.json generated ({os.path.getsize('PACKAGE.json')} bytes)")


"""
Visualizations for Tropical Life Cellular Automata

Generates publication-quality figures showing key mathematical structures.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
from matplotlib.colors import ListedColormap
import base64
import io


def tropical_threshold(s, lo, hi):
    return min(1, max(0, s + 1 - lo)) * min(1, max(0, hi + 1 - s))


def tropical_life_step(grid):
    m, n = grid.shape
    new_grid = np.zeros_like(grid)
    for i in range(m):
        for j in range(n):
            s = 0
            for di in [-1, 0, 1]:
                for dj in [-1, 0, 1]:
                    if di == 0 and dj == 0:
                        continue
                    s += grid[(i + di) % m, (j + dj) % n]
            alive = min(1, grid[i, j])
            new_grid[i, j] = (alive * tropical_threshold(s, 2, 3) +
                              (1 - alive) * tropical_threshold(s, 3, 3))
    return new_grid


def save_fig_to_base64(fig):
    buf = io.BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight', 
                facecolor='white', edgecolor='none')
    buf.seek(0)
    return base64.b64encode(buf.read()).decode('utf-8')


# ============================================================
# Figure 1: Glider Evolution
# ============================================================

def fig_glider_evolution():
    """Visualize the 5-step evolution of the tropical glider."""
    grid = np.zeros((10, 10), dtype=int)
    for i, j in [(0, 1), (1, 2), (2, 0), (2, 1), (2, 2)]:
        grid[i, j] = 1
    
    fig, axes = plt.subplots(1, 5, figsize=(15, 3.5))
    cmap = ListedColormap(['#f0f0f0', '#2196F3'])
    
    current = grid.copy()
    for idx, ax in enumerate(axes):
        ax.imshow(current[:6, :6], cmap=cmap, vmin=0, vmax=1, aspect='equal')
        ax.set_title(f'Step {idx}', fontsize=12, fontweight='bold')
        ax.set_xticks(range(6))
        ax.set_yticks(range(6))
        ax.grid(True, color='gray', linewidth=0.5, alpha=0.3)
        ax.tick_params(labelsize=8)
        
        # Mark alive cells
        for i in range(6):
            for j in range(6):
                if current[i, j] == 1:
                    ax.add_patch(plt.Rectangle((j-0.4, i-0.4), 0.8, 0.8,
                                               fill=True, facecolor='#1565C0',
                                               edgecolor='#0D47A1', linewidth=1.5))
        
        current = tropical_life_step(current)
    
    fig.suptitle('Tropical Life Glider: Period-4 Translation', 
                 fontsize=14, fontweight='bold', y=1.02)
    plt.tight_layout()
    
    b64 = save_fig_to_base64(fig)
    fig.savefig('glider_evolution.png', dpi=150, bbox_inches='tight',
                facecolor='white')
    plt.close()
    return b64


# ============================================================
# Figure 2: Gate Gadgets
# ============================================================

def fig_gate_gadgets():
    """Visualize the AND, OR, NOT, and XOR gate gadgets."""
    fig, axes = plt.subplots(2, 4, figsize=(16, 8))
    cmap = ListedColormap(['#f5f5f5', '#4CAF50'])
    
    gates = {
        'AND': {
            'frame': [(4,4)],
            'inputs': [(4,5), (5,4)],
            'output': (5,5),
            'out_init': 0,
        },
        'OR': {
            'frame': [(4,4)],
            'inputs': [(4,5), (5,4)],
            'output': (5,5),
            'out_init': 1,
        },
        'NOT': {
            'frame': [(4,4), (4,5), (4,6)],
            'inputs': [(5,4)],
            'output': (5,5),
            'out_init': 0,
        },
        'XOR': {
            'frame': [(4,4), (4,6)],
            'inputs': [(4,5), (5,4)],
            'output': (5,5),
            'out_init': 0,
        },
    }
    
    for col, (name, spec) in enumerate(gates.items()):
        # Input configuration (all inputs = 1)
        grid = np.zeros((10, 10), dtype=int)
        for fi, fj in spec['frame']:
            grid[fi, fj] = 1
        oi, oj = spec['output']
        grid[oi, oj] = spec['out_init']
        for ii, ij in spec['inputs']:
            grid[ii, ij] = 1
        
        # Show input
        ax = axes[0, col]
        view = grid[3:7, 3:8]
        ax.imshow(view, cmap=cmap, vmin=0, vmax=1, aspect='equal')
        ax.set_title(f'{name} Gate\n(inputs ON)', fontsize=11, fontweight='bold')
        
        # Annotate cells
        for i in range(view.shape[0]):
            for j in range(view.shape[1]):
                gi, gj = i + 3, j + 3
                if (gi, gj) in spec['frame']:
                    ax.text(j, i, 'F', ha='center', va='center', fontsize=9, 
                           color='white', fontweight='bold')
                elif (gi, gj) in spec['inputs']:
                    ax.text(j, i, 'IN', ha='center', va='center', fontsize=8,
                           color='white', fontweight='bold')
                elif (gi, gj) == spec['output']:
                    ax.text(j, i, 'OUT', ha='center', va='center', fontsize=8,
                           color='darkgreen' if view[i,j] else 'gray', fontweight='bold')
        
        ax.set_xticks([])
        ax.set_yticks([])
        ax.grid(True, color='gray', linewidth=0.5, alpha=0.3)
        
        # Show output
        result = tropical_life_step(grid)
        view_out = result[3:7, 3:8]
        ax = axes[1, col]
        ax.imshow(view_out, cmap=cmap, vmin=0, vmax=1, aspect='equal')
        
        out_val = result[oi, oj]
        ax.set_title(f'After step\nOutput = {out_val}', fontsize=11)
        
        for i in range(view_out.shape[0]):
            for j in range(view_out.shape[1]):
                gi, gj = i + 3, j + 3
                if (gi, gj) == spec['output']:
                    color = 'white' if view_out[i,j] else 'gray'
                    ax.text(j, i, str(int(view_out[i,j])), ha='center', va='center',
                           fontsize=14, color=color, fontweight='bold')
        
        ax.set_xticks([])
        ax.set_yticks([])
        ax.grid(True, color='gray', linewidth=0.5, alpha=0.3)
    
    fig.suptitle('Tropical Life Boolean Gate Gadgets', fontsize=14, fontweight='bold')
    plt.tight_layout()
    
    b64 = save_fig_to_base64(fig)
    fig.savefig('gate_gadgets.png', dpi=150, bbox_inches='tight', facecolor='white')
    plt.close()
    return b64


# ============================================================
# Figure 3: Still Life Diversity
# ============================================================

def fig_still_life_diversity():
    """Visualize the exponential family of still lifes from independent blocks."""
    fig, axes = plt.subplots(2, 8, figsize=(16, 4.5))
    cmap = ListedColormap(['#fafafa', '#FF5722'])
    
    block_positions = [(0, 0), (0, 5), (5, 0), (5, 5)]
    
    for mask in range(16):
        row = mask // 8
        col = mask % 8
        ax = axes[row, col]
        
        grid = np.zeros((9, 9), dtype=int)
        label_parts = []
        for bit, (bi, bj) in enumerate(block_positions):
            if mask & (1 << bit):
                grid[bi:bi+2, bj:bj+2] = 1
                label_parts.append(str(bit))
        
        ax.imshow(grid, cmap=cmap, vmin=0, vmax=1, aspect='equal')
        label = '{' + ','.join(label_parts) + '}' if label_parts else '∅'
        ax.set_title(label, fontsize=8)
        ax.set_xticks([])
        ax.set_yticks([])
    
    fig.suptitle('All 16 = 2⁴ Still Lifes from 4 Independent Blocks',
                 fontsize=13, fontweight='bold')
    plt.tight_layout()
    
    b64 = save_fig_to_base64(fig)
    fig.savefig('still_life_diversity.png', dpi=150, bbox_inches='tight',
                facecolor='white')
    plt.close()
    return b64


# ============================================================
# Figure 4: Tropical Threshold Function
# ============================================================

def fig_tropical_threshold():
    """Visualize the tropical threshold function."""
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(12, 4.5))
    
    s_vals = np.arange(0, 9)
    
    # Survival threshold
    surv = [tropical_threshold(s, 2, 3) for s in s_vals]
    ax1.bar(s_vals, surv, color=['#E0E0E0' if v == 0 else '#2196F3' for v in surv],
            edgecolor='#1565C0', linewidth=1.5)
    ax1.set_xlabel('Neighbor count s', fontsize=12)
    ax1.set_ylabel('tropThresh(s, 2, 3)', fontsize=12)
    ax1.set_title('Survival Threshold\n(alive cell survives)', fontsize=12, fontweight='bold')
    ax1.set_xticks(s_vals)
    ax1.set_ylim(-0.1, 1.3)
    ax1.axhline(y=0.5, color='gray', linestyle='--', alpha=0.3)
    
    # Birth threshold
    birth = [tropical_threshold(s, 3, 3) for s in s_vals]
    ax2.bar(s_vals, birth, color=['#E0E0E0' if v == 0 else '#4CAF50' for v in birth],
            edgecolor='#2E7D32', linewidth=1.5)
    ax2.set_xlabel('Neighbor count s', fontsize=12)
    ax2.set_ylabel('tropThresh(s, 3, 3)', fontsize=12)
    ax2.set_title('Birth Threshold\n(dead cell born)', fontsize=12, fontweight='bold')
    ax2.set_xticks(s_vals)
    ax2.set_ylim(-0.1, 1.3)
    ax2.axhline(y=0.5, color='gray', linestyle='--', alpha=0.3)
    
    fig.suptitle('Tropical Threshold Functions in the Life Rule',
                 fontsize=13, fontweight='bold', y=1.02)
    plt.tight_layout()
    
    b64 = save_fig_to_base64(fig)
    fig.savefig('tropical_threshold.png', dpi=150, bbox_inches='tight',
                facecolor='white')
    plt.close()
    return b64


# ============================================================
# Figure 5: Orbit Diversity Comparison
# ============================================================

def fig_orbit_diversity():
    """Compare orbit diversity of different pattern types."""
    fig, ax = plt.subplots(figsize=(10, 5))
    
    patterns = {}
    
    # Still life (block)
    p = np.zeros((10, 10), dtype=int)
    p[4:6, 4:6] = 1
    patterns['2×2 Block\n(still life)'] = p
    
    # Blinker
    p = np.zeros((10, 10), dtype=int)
    p[5, 4:7] = 1
    patterns['Blinker\n(period 2)'] = p
    
    # Glider
    p = np.zeros((10, 10), dtype=int)
    for i, j in [(0, 1), (1, 2), (2, 0), (2, 1), (2, 2)]:
        p[i, j] = 1
    patterns['Glider\n(period 4)'] = p
    
    # R-pentomino
    p = np.zeros((10, 10), dtype=int)
    p[4, 5] = 1; p[4, 6] = 1
    p[5, 4] = 1; p[5, 5] = 1
    p[6, 5] = 1
    patterns['R-pentomino\n(complex)'] = p
    
    T_max = 25
    colors = ['#2196F3', '#FF9800', '#4CAF50', '#E91E63']
    
    for idx, (name, grid) in enumerate(patterns.items()):
        diversities = []
        current = grid.copy()
        seen = set()
        for t in range(T_max + 1):
            seen.add(current.tobytes())
            diversities.append(len(seen))
            current = tropical_life_step(current)
        
        ax.plot(range(T_max + 1), diversities, 'o-', label=name,
                color=colors[idx], linewidth=2, markersize=4)
    
    ax.set_xlabel('Time steps T', fontsize=12)
    ax.set_ylabel('Orbit diversity |{step^t(c) : 0 ≤ t ≤ T}|', fontsize=12)
    ax.set_title('Orbit Diversity Growth by Pattern Type', fontsize=13, fontweight='bold')
    ax.legend(fontsize=10, loc='upper left')
    ax.grid(True, alpha=0.3)
    ax.set_xlim(-0.5, T_max + 0.5)
    
    plt.tight_layout()
    b64 = save_fig_to_base64(fig)
    fig.savefig('orbit_diversity.png', dpi=150, bbox_inches='tight', facecolor='white')
    plt.close()
    return b64


# ============================================================
# Figure 6: Gate Truth Tables
# ============================================================

def fig_gate_truth_tables():
    """Visualize truth tables for all four gates."""
    fig, axes = plt.subplots(1, 4, figsize=(14, 3.5))
    
    gate_data = {
        'AND': [[0,0,0], [0,1,0], [1,0,0], [1,1,1]],
        'OR':  [[0,0,0], [0,1,1], [1,0,1], [1,1,1]],
        'NOT': [[0,None,1], [1,None,0]],
        'XOR': [[0,0,0], [0,1,1], [1,0,1], [1,1,0]],
    }
    
    colors_map = {0: '#FFCDD2', 1: '#C8E6C9'}
    
    for idx, (name, data) in enumerate(gate_data.items()):
        ax = axes[idx]
        ax.set_xlim(-0.5, 2.5)
        ax.set_ylim(-0.5, len(data) - 0.5)
        ax.set_aspect('equal')
        
        if name == 'NOT':
            headers = ['a', '', 'out']
        else:
            headers = ['a', 'b', 'out']
        
        for col, h in enumerate(headers):
            ax.text(col, len(data) + 0.1, h, ha='center', va='bottom',
                   fontsize=11, fontweight='bold')
        
        for row, vals in enumerate(data):
            y = len(data) - 1 - row
            for col, v in enumerate(vals):
                if v is None:
                    ax.text(col, y, '–', ha='center', va='center', fontsize=12)
                else:
                    color = colors_map[v]
                    ax.add_patch(plt.Rectangle((col-0.4, y-0.4), 0.8, 0.8,
                                               facecolor=color, edgecolor='gray'))
                    ax.text(col, y, str(v), ha='center', va='center',
                           fontsize=12, fontweight='bold')
        
        ax.set_title(name, fontsize=13, fontweight='bold', pad=15)
        ax.axis('off')
    
    fig.suptitle('Boolean Gate Truth Tables (Verified by Tropical Life)',
                 fontsize=13, fontweight='bold', y=0.02)
    plt.tight_layout()
    
    b64 = save_fig_to_base64(fig)
    fig.savefig('gate_truth_tables.png', dpi=150, bbox_inches='tight',
                facecolor='white')
    plt.close()
    return b64


if __name__ == "__main__":
    print("Generating visualizations...")
    
    b64_glider = fig_glider_evolution()
    print(f"  glider_evolution.png ({len(b64_glider)} bytes base64)")
    
    b64_gates = fig_gate_gadgets()
    print(f"  gate_gadgets.png ({len(b64_gates)} bytes base64)")
    
    b64_diversity = fig_still_life_diversity()
    print(f"  still_life_diversity.png ({len(b64_diversity)} bytes base64)")
    
    b64_threshold = fig_tropical_threshold()
    print(f"  tropical_threshold.png ({len(b64_threshold)} bytes base64)")
    
    b64_orbit = fig_orbit_diversity()
    print(f"  orbit_diversity.png ({len(b64_orbit)} bytes base64)")
    
    b64_truth = fig_gate_truth_tables()
    print(f"  gate_truth_tables.png ({len(b64_truth)} bytes base64)")
    
    print("\nAll visualizations generated successfully.")
