"""
Algorithms for Tropical Life Cellular Automata

Implements the core algorithms from the research paper with full
documentation, type hints, and complexity analysis.
"""

import numpy as np
from typing import Tuple, List, Set, Dict, Optional
from dataclasses import dataclass


# ============================================================
# Algorithm 1: Tropical Life Step
# ============================================================

def tropical_threshold(s: int, lo: int, hi: int) -> int:
    """Tropical threshold indicator.
    
    Returns 1 if lo <= s <= hi, 0 otherwise.
    Implemented using only min, max (truncating subtraction), addition,
    and multiplication — the natural operations of the tropical semiring.
    
    Time complexity: O(1)
    Space complexity: O(1)
    
    Args:
        s: Signal value (neighbor count)
        lo: Lower threshold bound
        hi: Upper threshold bound
    
    Returns:
        1 if lo <= s <= hi, 0 otherwise
        
    Examples:
        >>> tropical_threshold(3, 2, 3)
        1
        >>> tropical_threshold(1, 2, 3)
        0
        >>> tropical_threshold(4, 2, 3)
        0
    """
    return min(1, max(0, s + 1 - lo)) * min(1, max(0, hi + 1 - s))


def tropical_life_step(grid: np.ndarray) -> np.ndarray:
    """Apply one step of the tropical Life automaton.
    
    The update rule for each cell uses tropical primitives:
    - alive := min(1, cell_value)
    - s := sum of Moore neighbors
    - next := alive * tropThresh(s, 2, 3) + (1-alive) * tropThresh(s, 3, 3)
    
    Time complexity: O(m*n) where grid is m×n
    Space complexity: O(m*n) for the output grid
    
    Args:
        grid: m×n numpy array of natural numbers
    
    Returns:
        m×n numpy array after one tropical Life step
    """
    m, n = grid.shape
    new_grid = np.zeros_like(grid)
    
    for i in range(m):
        for j in range(n):
            # Compute Moore neighborhood sum with toroidal wrapping
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


# ============================================================
# Algorithm 2: Still Life Detection
# ============================================================

def is_still_life(grid: np.ndarray) -> bool:
    """Check if a configuration is a fixed point of the tropical Life operator.
    
    Time complexity: O(m*n)
    Space complexity: O(m*n)
    
    Args:
        grid: Configuration to test
    
    Returns:
        True if grid is a still life (fixed point)
    """
    return np.array_equal(tropical_life_step(grid), grid)


def find_all_still_lifes(m: int, n: int, max_alive: int = None) -> List[np.ndarray]:
    """Enumerate all still lifes on an m×n torus.
    
    Brute-force search over all binary configurations. Optionally limited
    to configurations with at most max_alive cells.
    
    Time complexity: O(2^(m*n) * m * n) without max_alive constraint
    Space complexity: O(k * m * n) where k is the number of still lifes found
    
    Warning: Exponential in grid size. Only practical for small grids (m*n <= 16).
    
    Args:
        m, n: Grid dimensions
        max_alive: Maximum number of alive cells (None for no limit)
    
    Returns:
        List of still life configurations
    """
    still_lifes = []
    total_cells = m * n
    
    if max_alive is None:
        max_alive = total_cells
    
    for mask in range(2 ** total_cells):
        # Count alive cells
        alive_count = bin(mask).count('1')
        if alive_count > max_alive:
            continue
        
        # Construct grid
        grid = np.zeros((m, n), dtype=int)
        for k in range(total_cells):
            if mask & (1 << k):
                grid[k // n, k % n] = 1
        
        if is_still_life(grid):
            still_lifes.append(grid.copy())
    
    return still_lifes


# ============================================================
# Algorithm 3: Glider Detection
# ============================================================

@dataclass
class GliderInfo:
    """Information about a detected glider pattern."""
    config: np.ndarray
    period: int
    dx: int  # Row displacement
    dy: int  # Column displacement
    alive_count: int


def detect_glider(grid: np.ndarray, max_period: int = 20) -> Optional[GliderInfo]:
    """Detect if a configuration is a glider (periodic orbit with translation).
    
    Iterates the tropical Life step up to max_period times, checking at each
    step whether the result equals a translation of the original.
    
    Time complexity: O(max_period * m * n * m * n) — for each step, check all translations
    Space complexity: O(m * n)
    
    Args:
        grid: Configuration to test
        max_period: Maximum period to search
    
    Returns:
        GliderInfo if a glider is detected, None otherwise
    """
    m, n = grid.shape
    
    if is_still_life(grid):
        return None
    
    current = grid.copy()
    for t in range(1, max_period + 1):
        current = tropical_life_step(current)
        
        # Check all possible translations
        for dx in range(m):
            for dy in range(n):
                if dx == 0 and dy == 0:
                    continue  # Skip identity (would be a period, not a glider)
                
                shifted = np.roll(np.roll(grid, dx, axis=0), dy, axis=1)
                if np.array_equal(current, shifted):
                    return GliderInfo(
                        config=grid.copy(),
                        period=t,
                        dx=dx,
                        dy=dy,
                        alive_count=int(grid.sum())
                    )
    
    return None


def search_gliders(m: int, n: int, max_alive: int = 6, 
                   max_period: int = 10) -> List[GliderInfo]:
    """Search for glider patterns by brute force.
    
    Time complexity: O(C(m*n, max_alive) * max_period * m^2 * n^2)
    Space complexity: O(m * n)
    
    Warning: Only practical for small grids and small max_alive.
    
    Args:
        m, n: Grid dimensions
        max_alive: Maximum number of alive cells to try
        max_period: Maximum glider period to detect
    
    Returns:
        List of detected gliders (may contain duplicates up to translation)
    """
    from itertools import combinations
    
    gliders = []
    cells = [(i, j) for i in range(m) for j in range(n)]
    
    for k in range(1, max_alive + 1):
        for combo in combinations(cells, k):
            grid = np.zeros((m, n), dtype=int)
            for i, j in combo:
                grid[i, j] = 1
            
            info = detect_glider(grid, max_period)
            if info is not None:
                gliders.append(info)
    
    return gliders


# ============================================================
# Algorithm 4: Orbit Computation
# ============================================================

def compute_orbit(grid: np.ndarray, steps: int) -> List[np.ndarray]:
    """Compute the orbit of a configuration for a given number of steps.
    
    Time complexity: O(steps * m * n)
    Space complexity: O(steps * m * n)
    
    Args:
        grid: Initial configuration
        steps: Number of steps to compute
    
    Returns:
        List of configurations [grid, step(grid), step²(grid), ...]
    """
    orbit = [grid.copy()]
    current = grid.copy()
    for _ in range(steps):
        current = tropical_life_step(current)
        orbit.append(current.copy())
    return orbit


def orbit_diversity(grid: np.ndarray, steps: int) -> int:
    """Count the number of distinct configurations in the orbit prefix.
    
    Time complexity: O(steps * m * n)
    Space complexity: O(steps * m * n)
    
    Args:
        grid: Initial configuration
        steps: Number of steps
    
    Returns:
        Number of distinct configurations seen in steps 0..steps
    """
    orbit = compute_orbit(grid, steps)
    seen = set()
    for config in orbit:
        seen.add(config.tobytes())
    return len(seen)


# ============================================================
# Algorithm 5: Gate Evaluation
# ============================================================

@dataclass 
class GateSpec:
    """Specification of a Boolean gate gadget."""
    name: str
    grid_size: int
    frame_cells: List[Tuple[int, int]]
    input_a_cell: Optional[Tuple[int, int]]
    input_b_cell: Optional[Tuple[int, int]]
    output_cell: Tuple[int, int]
    output_init: int  # Initial value of output cell (0=dead, 1=alive)


def evaluate_gate(spec: GateSpec, a: bool, b: bool = False) -> int:
    """Evaluate a gate gadget for given inputs.
    
    Time complexity: O(grid_size²)
    Space complexity: O(grid_size²)
    
    Args:
        spec: Gate specification
        a: First input
        b: Second input (ignored for NOT gate)
    
    Returns:
        Output value (0 or 1)
    """
    n = spec.grid_size
    grid = np.zeros((n, n), dtype=int)
    
    # Place frame cells
    for i, j in spec.frame_cells:
        grid[i, j] = 1
    
    # Place output cell initial value
    oi, oj = spec.output_cell
    grid[oi, oj] = spec.output_init
    
    # Place input cells
    if a and spec.input_a_cell:
        ai, aj = spec.input_a_cell
        grid[ai, aj] = 1
    if b and spec.input_b_cell:
        bi, bj = spec.input_b_cell
        grid[bi, bj] = 1
    
    result = tropical_life_step(grid)
    return result[spec.output_cell]


# Standard gate definitions
AND_GATE = GateSpec(
    name="AND",
    grid_size=10,
    frame_cells=[(4, 4)],
    input_a_cell=(4, 5),
    input_b_cell=(5, 4),
    output_cell=(5, 5),
    output_init=0,
)

OR_GATE = GateSpec(
    name="OR",
    grid_size=10,
    frame_cells=[(4, 4)],
    input_a_cell=(4, 5),
    input_b_cell=(5, 4),
    output_cell=(5, 5),
    output_init=1,
)

NOT_GATE = GateSpec(
    name="NOT",
    grid_size=10,
    frame_cells=[(4, 4), (4, 5), (4, 6)],
    input_a_cell=(5, 4),
    input_b_cell=None,
    output_cell=(5, 5),
    output_init=0,
)

XOR_GATE = GateSpec(
    name="XOR",
    grid_size=10,
    frame_cells=[(4, 4), (4, 6)],
    input_a_cell=(4, 5),
    input_b_cell=(5, 4),
    output_cell=(5, 5),
    output_init=0,
)


def verify_gate(spec: GateSpec) -> bool:
    """Verify a gate gadget against its expected truth table.
    
    Args:
        spec: Gate specification
    
    Returns:
        True if the gate produces correct outputs for all inputs
    """
    if spec.name == "AND":
        expected = {(0, 0): 0, (0, 1): 0, (1, 0): 0, (1, 1): 1}
    elif spec.name == "OR":
        expected = {(0, 0): 0, (0, 1): 1, (1, 0): 1, (1, 1): 1}
    elif spec.name == "NOT":
        expected = {(0, 0): 1, (1, 0): 0}
    elif spec.name == "XOR":
        expected = {(0, 0): 0, (0, 1): 1, (1, 0): 1, (1, 1): 0}
    else:
        return False
    
    for (a, b), exp in expected.items():
        result = evaluate_gate(spec, bool(a), bool(b))
        if result != exp:
            return False
    return True


# ============================================================
# Algorithm 6: Block-Based Still Life Construction
# ============================================================

def construct_block_still_lifes(grid_size: int, 
                                 block_spacing: int = 4) -> List[np.ndarray]:
    """Construct exponentially many still lifes via independent 2×2 blocks.
    
    Places non-interacting 2×2 blocks on a grid, generating 2^k still lifes
    where k is the number of block positions.
    
    Time complexity: O(2^k * m * n) for verification
    Space complexity: O(2^k * m * n)
    
    Args:
        grid_size: Size of the square torus
        block_spacing: Minimum spacing between block centers
    
    Returns:
        List of all still life configurations from block subsets
    """
    # Compute block positions
    positions = []
    for i in range(0, grid_size - 1, block_spacing):
        for j in range(0, grid_size - 1, block_spacing):
            positions.append((i, j))
    
    k = len(positions)
    still_lifes = []
    
    for mask in range(2 ** k):
        grid = np.zeros((grid_size, grid_size), dtype=int)
        for bit, (bi, bj) in enumerate(positions):
            if mask & (1 << bit):
                grid[bi:bi+2, bj:bj+2] = 1
        
        if is_still_life(grid):
            still_lifes.append(grid.copy())
    
    return still_lifes


# ============================================================
# Main: Run all algorithm demonstrations
# ============================================================

if __name__ == "__main__":
    print("Tropical Life Algorithms")
    print("=" * 60)
    
    # Verify gates
    print("\nGate verification:")
    for gate in [AND_GATE, OR_GATE, NOT_GATE, XOR_GATE]:
        ok = verify_gate(gate)
        print(f"  {gate.name}: {'PASS' if ok else 'FAIL'}")
    
    # Count still lifes on small grids
    print("\nStill life census (small grids):")
    for m, n in [(3, 3), (4, 4)]:
        sl = find_all_still_lifes(m, n, max_alive=4)
        print(f"  {m}×{n} torus, ≤4 alive: {len(sl)} still lifes")
    
    # Block still lifes
    print("\nBlock-based still life construction:")
    for size in [8, 12, 16]:
        sl = construct_block_still_lifes(size)
        print(f"  {size}×{size} torus: {len(sl)} block-based still lifes")
    
    # Glider detection
    print("\nGlider detection on 10×10 torus:")
    grid = np.zeros((10, 10), dtype=int)
    for i, j in [(0, 1), (1, 2), (2, 0), (2, 1), (2, 2)]:
        grid[i, j] = 1
    info = detect_glider(grid)
    if info:
        print(f"  Period: {info.period}, Displacement: ({info.dx}, {info.dy})")
        print(f"  Alive cells: {info.alive_count}")
    
    # Orbit diversity
    print("\nOrbit diversity:")
    div = orbit_diversity(grid, 4)
    print(f"  Glider (10×10), T=4: {div} distinct configs")
    
    block = np.zeros((6, 6), dtype=int)
    block[0:2, 0:2] = 1
    div_block = orbit_diversity(block, 10)
    print(f"  Block (6×6), T=10: {div_block} distinct configs (still life)")
