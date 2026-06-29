#!/usr/bin/env python3
"""
Algorithms for Sudoku phase transition analysis.

Provides type-hinted implementations of:
1. Constraint degree computation
2. Phase transition parameter estimation
3. Backtracking solver with tree size measurement
4. Solution space sampling
"""

from typing import List, Tuple, Optional, Set
import random
import math


# ============================================================================
# Constraint Graph Analysis
# ============================================================================

def compute_sudoku_neighbors(n: int, cell: Tuple[int, int]) -> Set[Tuple[int, int]]:
    """Compute all Sudoku-adjacent cells for a given cell in an n^2 x n^2 grid.

    Args:
        n: Block size (standard Sudoku has n=3).
        cell: (row, col) coordinates in the n^2 x n^2 grid.

    Returns:
        Set of (row, col) pairs that conflict with the given cell.
    """
    row, col = cell
    N = n * n
    neighbors: Set[Tuple[int, int]] = set()

    # Row neighbors
    for j in range(N):
        if j != col:
            neighbors.add((row, j))

    # Column neighbors
    for i in range(N):
        if i != row:
            neighbors.add((i, col))

    # Box neighbors
    box_row, box_col = (row // n) * n, (col // n) * n
    for i in range(box_row, box_row + n):
        for j in range(box_col, box_col + n):
            if (i, j) != (row, col):
                neighbors.add((i, j))

    return neighbors


def verify_degree_formula(n: int) -> Tuple[int, int, bool]:
    """Verify the constraint degree formula for an n^2 x n^2 Sudoku grid.

    Returns:
        (actual_degree, predicted_degree, match)
    """
    cell = (0, 0)  # Any cell will do by symmetry
    actual = len(compute_sudoku_neighbors(n, cell))
    predicted = (3 * n + 1) * (n - 1)
    return actual, predicted, actual == predicted


def classify_neighbors(n: int, cell: Tuple[int, int]) -> dict:
    """Classify a cell's neighbors by constraint type.

    Returns dict with keys:
        'row_only': neighbors sharing only row
        'col_only': neighbors sharing only column
        'box_only': neighbors sharing only box
        'row_and_box': neighbors sharing row and box
        'col_and_box': neighbors sharing column and box
    """
    row, col = cell
    N = n * n
    result = {
        'row_only': set(), 'col_only': set(),
        'box_only': set(), 'row_and_box': set(), 'col_and_box': set()
    }

    box_row, box_col = (row // n) * n, (col // n) * n

    for i in range(N):
        for j in range(N):
            if (i, j) == (row, col):
                continue
            same_row = (i == row)
            same_col = (j == col)
            same_box = (box_row <= i < box_row + n and box_col <= j < box_col + n)

            if same_row and same_box:
                result['row_and_box'].add((i, j))
            elif same_col and same_box:
                result['col_and_box'].add((i, j))
            elif same_row:
                result['row_only'].add((i, j))
            elif same_col:
                result['col_only'].add((i, j))
            elif same_box:
                result['box_only'].add((i, j))

    return result


# ============================================================================
# Backtracking Solver with Tree Size Measurement
# ============================================================================

class SudokuSolver:
    """Backtracking Sudoku solver that measures search tree size."""

    def __init__(self, n: int):
        self.n = n
        self.N = n * n
        self.grid: List[List[int]] = [[0] * self.N for _ in range(self.N)]
        self.tree_size: int = 0
        self.solutions_found: int = 0

    def set_grid(self, grid: List[List[int]]) -> None:
        """Set the grid state."""
        self.grid = [row[:] for row in grid]

    def is_valid(self, row: int, col: int, val: int) -> bool:
        """Check if placing val at (row, col) is valid."""
        # Check row
        if val in self.grid[row]:
            return False
        # Check column
        if any(self.grid[i][col] == val for i in range(self.N)):
            return False
        # Check box
        br, bc = (row // self.n) * self.n, (col // self.n) * self.n
        for i in range(br, br + self.n):
            for j in range(bc, bc + self.n):
                if self.grid[i][j] == val:
                    return False
        return True

    def get_candidates(self, row: int, col: int) -> List[int]:
        """Get valid candidates for a cell."""
        return [v for v in range(1, self.N + 1) if self.is_valid(row, col, v)]

    def find_empty(self) -> Optional[Tuple[int, int]]:
        """Find the most constrained empty cell (MRV heuristic)."""
        best: Optional[Tuple[int, int]] = None
        best_count = self.N + 1
        for i in range(self.N):
            for j in range(self.N):
                if self.grid[i][j] == 0:
                    count = len(self.get_candidates(i, j))
                    if count < best_count:
                        best = (i, j)
                        best_count = count
        return best

    def solve(self, count_all: bool = False, max_tree: int = 10**6) -> bool:
        """Solve using backtracking. Returns True if solution found.

        Args:
            count_all: If True, count all solutions (don't stop at first).
            max_tree: Maximum tree nodes to explore before giving up.
        """
        self.tree_size += 1
        if self.tree_size > max_tree:
            return False

        empty = self.find_empty()
        if empty is None:
            self.solutions_found += 1
            return not count_all  # Stop at first solution unless counting all

        row, col = empty
        candidates = self.get_candidates(row, col)

        for val in candidates:
            self.grid[row][col] = val
            if self.solve(count_all, max_tree):
                return True
            self.grid[row][col] = 0

        return False


def generate_random_partial(n: int, density: float, seed: int = 42) -> List[List[int]]:
    """Generate a random partial Sudoku grid at given density.

    First generates a complete valid grid, then removes cells to reach
    the target density.

    Args:
        n: Block size.
        density: Fraction of cells to keep filled.
        seed: Random seed for reproducibility.

    Returns:
        Partial grid as list of lists (0 = empty).
    """
    rng = random.Random(seed)
    N = n * n

    # Simple complete grid generation for small n
    grid = [[0] * N for _ in range(N)]

    # Fill with a simple valid pattern
    for i in range(N):
        for j in range(N):
            grid[i][j] = (i * n + i // n + j) % N + 1

    # Remove cells to reach target density
    total_cells = N * N
    cells_to_keep = int(total_cells * density)
    all_cells = [(i, j) for i in range(N) for j in range(N)]
    rng.shuffle(all_cells)

    cells_to_remove = all_cells[cells_to_keep:]
    for i, j in cells_to_remove:
        grid[i][j] = 0

    return grid


# ============================================================================
# Phase Transition Estimation
# ============================================================================

def estimate_phase_transition(n: int, num_samples: int = 100,
                               density_steps: int = 20) -> List[Tuple[float, float]]:
    """Estimate the phase transition curve for n^2 x n^2 Sudoku.

    Args:
        n: Block size.
        num_samples: Number of random instances per density.
        density_steps: Number of density values to test.

    Returns:
        List of (density, satisfiability_probability) pairs.
    """
    results: List[Tuple[float, float]] = []
    dc = 1 - 1 / n**2

    for step in range(density_steps + 1):
        d = max(0.5, dc - 0.1) + step * 0.2 / density_steps
        d = min(d, 1.0)

        solvable = 0
        for seed in range(num_samples):
            grid = generate_random_partial(n, d, seed=seed)
            solver = SudokuSolver(n)
            solver.set_grid(grid)
            if solver.solve(max_tree=10000):
                solvable += 1

        prob = solvable / num_samples
        results.append((d, prob))

    return results


# ============================================================================
# Hamming Distance Computation
# ============================================================================

def hamming_distance(grid1: List[List[int]], grid2: List[List[int]]) -> int:
    """Compute Hamming distance between two grids."""
    dist = 0
    for i in range(len(grid1)):
        for j in range(len(grid1[0])):
            if grid1[i][j] != grid2[i][j]:
                dist += 1
    return dist


# ============================================================================
# Main demonstration
# ============================================================================

if __name__ == "__main__":
    print("=== Constraint Degree Verification ===")
    for n in range(2, 6):
        actual, predicted, match = verify_degree_formula(n)
        print(f"n={n}: actual={actual}, predicted={predicted}, match={match}")
        assert match

    print("\n=== Neighbor Classification (n=3, cell (0,0)) ===")
    classes = classify_neighbors(3, (0, 0))
    for key, cells in classes.items():
        print(f"  {key}: {len(cells)} neighbors")

    total = sum(len(v) for v in classes.values())
    print(f"  Total: {total} (expected {(3*3+1)*(3-1)})")

    print("\n=== Phase Transition Estimation (n=2, 4x4 grid) ===")
    results = estimate_phase_transition(2, num_samples=50, density_steps=10)
    for d, p in results:
        bar = "█" * int(p * 30)
        print(f"  d={d:.3f}: P(sat)={p:.2f} {bar}")
