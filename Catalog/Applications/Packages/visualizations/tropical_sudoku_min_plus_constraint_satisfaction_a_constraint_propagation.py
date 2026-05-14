#!/usr/bin/env python3
"""
Tropical Sudoku: Algorithms

Implements the core algorithms from the tropical Sudoku framework:
  1. Tropical violation cost computation
  2. Naked-single constraint propagation
  3. Phase transition analysis
  4. Propagation-based solver with backtracking

All algorithms correspond to formally verified theorems in the Lean formalization.
"""

from typing import Optional
import itertools


# ─── Algorithm 1: Tropical Violation Cost ─────────────────────────────────────

def tropical_violation_cost(
    n: int,
    grid: list[list[int]],
    assignment: list[list[int]]
) -> dict[str, int]:
    """
    Compute the tropical violation cost of an assignment.

    The violation cost is the sum of four components:
      - Row violations: pairs of distinct cells in the same row with the same digit
      - Column violations: pairs of distinct cells in the same column with same digit
      - Box violations: pairs of distinct cells in the same box with the same digit
      - Given violations: cells where the assignment disagrees with a given clue

    By Theorem A, the total cost is 0 if and only if the assignment is a
    valid Sudoku solution.

    Parameters:
        n: Box size (standard Sudoku has n=3)
        grid: n²×n² grid with 0 for empty cells
        assignment: n²×n² grid with all cells filled

    Returns:
        Dictionary with 'row', 'col', 'box', 'given', 'total' violation counts

    Complexity: O(n^8) worst case, O(n^6) with optimized pair counting
    """
    N = n * n
    row_cost = 0
    col_cost = 0
    box_cost = 0
    given_cost = 0

    # Row violations (ordered pairs)
    for r in range(N):
        for c1 in range(N):
            for c2 in range(N):
                if c1 != c2 and assignment[r][c1] == assignment[r][c2]:
                    row_cost += 1

    # Column violations (ordered pairs)
    for c in range(N):
        for r1 in range(N):
            for r2 in range(N):
                if r1 != r2 and assignment[r1][c] == assignment[r2][c]:
                    col_cost += 1

    # Box violations (ordered pairs)
    for r1 in range(N):
        for c1 in range(N):
            for r2 in range(N):
                for c2 in range(N):
                    if (r1, c1) != (r2, c2):
                        if r1 // n == r2 // n and c1 // n == c2 // n:
                            if assignment[r1][c1] == assignment[r2][c2]:
                                box_cost += 1

    # Given violations
    for r in range(N):
        for c in range(N):
            if grid[r][c] != 0 and assignment[r][c] != grid[r][c]:
                given_cost += 1

    return {
        'row': row_cost,
        'col': col_cost,
        'box': box_cost,
        'given': given_cost,
        'total': row_cost + col_cost + box_cost + given_cost
    }


# ─── Algorithm 2: Constraint Propagation ─────────────────────────────────────

class SudokuPropagator:
    """
    Constraint propagation engine for Sudoku.

    Implements naked-single elimination, the simplest form of constraint
    propagation. Formally verified properties:
      - Soundness: valid solutions are preserved (Theorem B1)
      - Deflationary: candidates only decrease (Theorem B3)
      - Termination: fixed point reached in ≤ n⁶ steps (Theorem B3)
      - Contradiction detection: empty cells → unsatisfiable (Theorem C)

    Pseudocode:
        PROPAGATE(grid, state):
          for each cell c:
            if grid[c] has a given value v:
              state[c] ← state[c] ∩ {v}
            for each cell c' in same row/col/box as c:
              if |state[c']| = 1 and c' ≠ c:
                state[c] ← state[c] \ state[c']
          return state

    Complexity: O(n⁶) per step, O(n¹²) total for full closure
    """

    def __init__(self, n: int):
        self.n = n
        self.N = n * n
        self.state: list[list[set[int]]] = []
        self.history: list[int] = []

    def initialize(self, grid: list[list[int]]):
        """Initialize with full candidate sets."""
        N = self.N
        self.state = [[set(range(1, N + 1)) for _ in range(N)] for _ in range(N)]
        self.history = [self.volume()]

    def volume(self) -> int:
        """Total candidate volume across all cells."""
        return sum(len(s) for row in self.state for s in row)

    def propagate_step(self, grid: list[list[int]]) -> bool:
        """
        One propagation step. Returns True if state changed.

        This is the core algorithm: for each cell, restrict by givens
        and eliminate singleton-determined digits from the same unit.
        """
        N = self.N
        n = self.n
        changed = False
        new_state = [[set(s) for s in row] for row in self.state]

        for r in range(N):
            for c in range(N):
                old = new_state[r][c]

                # Given constraint
                if grid[r][c] != 0:
                    new_state[r][c] &= {grid[r][c]}

                # Singleton elimination — row
                for c2 in range(N):
                    if c2 != c and len(self.state[r][c2]) == 1:
                        new_state[r][c] -= self.state[r][c2]

                # Singleton elimination — column
                for r2 in range(N):
                    if r2 != r and len(self.state[r2][c]) == 1:
                        new_state[r][c] -= self.state[r2][c]

                # Singleton elimination — box
                br, bc = (r // n) * n, (c // n) * n
                for dr in range(n):
                    for dc in range(n):
                        r2, c2 = br + dr, bc + dc
                        if (r2, c2) != (r, c) and len(self.state[r2][c2]) == 1:
                            new_state[r][c] -= self.state[r2][c2]

                if new_state[r][c] != old:
                    changed = True

        self.state = new_state
        self.history.append(self.volume())
        return changed

    def propagate_to_closure(self, grid: list[list[int]], max_steps: int = 10000) -> int:
        """
        Iterate propagation to fixed point. Returns number of steps.

        By Theorem B3, this always terminates in at most n⁶ steps.
        """
        self.initialize(grid)
        for step in range(1, max_steps + 1):
            if not self.propagate_step(grid):
                return step
        return max_steps

    def is_contradictory(self) -> bool:
        """Check if any cell has empty candidate set."""
        return any(len(s) == 0 for row in self.state for s in row)

    def is_solved(self) -> bool:
        """Check if all cells are determined (singleton candidates)."""
        return all(len(s) == 1 for row in self.state for s in row)

    def get_solution(self) -> Optional[list[list[int]]]:
        """Extract solution if fully determined."""
        if not self.is_solved():
            return None
        return [[list(self.state[r][c])[0] for c in range(self.N)]
                for r in range(self.N)]

    def undecided_cells(self) -> list[tuple[int, int, set[int]]]:
        """Return list of (row, col, candidates) for undecided cells."""
        result = []
        for r in range(self.N):
            for c in range(self.N):
                if len(self.state[r][c]) > 1:
                    result.append((r, c, set(self.state[r][c])))
        return result


# ─── Algorithm 3: Propagation-Based Solver with Backtracking ─────────────────

def solve_sudoku(n: int, grid: list[list[int]]) -> Optional[list[list[int]]]:
    """
    Solve a Sudoku puzzle using propagation + backtracking.

    Strategy:
      1. Propagate to closure (Theorem B1 guarantees soundness)
      2. If contradictory → unsatisfiable (Theorem C)
      3. If solved → return solution
      4. Otherwise, pick cell with fewest candidates, branch

    This is a complete solver: it finds a solution if one exists.

    Parameters:
        n: Box size
        grid: Puzzle grid (0 for empty)

    Returns:
        Solution grid, or None if unsatisfiable
    """
    N = n * n
    prop = SudokuPropagator(n)
    prop.propagate_to_closure(grid)

    if prop.is_contradictory():
        return None

    if prop.is_solved():
        return prop.get_solution()

    # Find cell with fewest candidates > 1 (MRV heuristic)
    undecided = prop.undecided_cells()
    undecided.sort(key=lambda x: len(x[2]))
    r, c, candidates = undecided[0]

    # Branch on each candidate
    for d in sorted(candidates):
        new_grid = [row[:] for row in grid]
        new_grid[r][c] = d
        result = solve_sudoku(n, new_grid)
        if result is not None:
            return result

    return None


# ─── Algorithm 4: Phase Transition Analysis ──────────────────────────────────

def analyze_phase_transition(
    n: int,
    solution: list[list[int]],
    num_trials: int = 50,
    clue_counts: Optional[list[int]] = None
) -> dict[str, list]:
    """
    Analyze the phase transition in propagation effectiveness as a function
    of clue density.

    For each clue count k, randomly select k cells to reveal from the given
    solution, propagate to closure, and measure:
      - Average residual volume (candidates remaining)
      - Average number of undecided cells
      - Proportion of instances fully solved by propagation
      - Proportion of instances with contradiction detected

    By Theorem D, residual volume is monotonically non-increasing in k.

    Parameters:
        n: Box size
        solution: A complete valid Sudoku grid
        num_trials: Number of random trials per clue count
        clue_counts: List of clue counts to test

    Returns:
        Dictionary with arrays for each metric
    """
    import random

    N = n * n
    cells = [(r, c) for r in range(N) for c in range(N)]

    if clue_counts is None:
        clue_counts = list(range(0, N * N + 1, max(1, N * N // 30)))
        if N * N not in clue_counts:
            clue_counts.append(N * N)

    results = {
        'clue_counts': clue_counts,
        'avg_volume': [],
        'avg_undecided': [],
        'solved_rate': [],
        'steps_to_closure': [],
    }

    prop = SudokuPropagator(n)

    for k in clue_counts:
        total_vol = 0
        total_und = 0
        solved_count = 0
        total_steps = 0

        for trial in range(num_trials):
            random.seed(trial * 10000 + k)
            order = list(cells)
            random.shuffle(order)

            grid = [[0] * N for _ in range(N)]
            for i in range(min(k, N * N)):
                r, c = order[i]
                grid[r][c] = solution[r][c]

            steps = prop.propagate_to_closure(grid)
            total_vol += prop.volume()
            total_und += len(prop.undecided_cells())
            total_steps += steps
            if prop.is_solved():
                solved_count += 1

        results['avg_volume'].append(total_vol / num_trials)
        results['avg_undecided'].append(total_und / num_trials)
        results['solved_rate'].append(solved_count / num_trials)
        results['steps_to_closure'].append(total_steps / num_trials)

    return results


# ─── Main ─────────────────────────────────────────────────────────────────────

if __name__ == "__main__":
    print("Tropical Sudoku — Algorithm Demonstrations\n")

    # Demo 1: Solve a puzzle
    puzzle = [
        [5, 3, 0,  0, 7, 0,  0, 0, 0],
        [6, 0, 0,  1, 9, 5,  0, 0, 0],
        [0, 9, 8,  0, 0, 0,  0, 6, 0],
        [8, 0, 0,  0, 6, 0,  0, 0, 3],
        [4, 0, 0,  8, 0, 3,  0, 0, 1],
        [7, 0, 0,  0, 2, 0,  0, 0, 6],
        [0, 6, 0,  0, 0, 0,  2, 8, 0],
        [0, 0, 0,  4, 1, 9,  0, 0, 5],
        [0, 0, 0,  0, 8, 0,  0, 7, 9],
    ]

    print("Solving puzzle with propagation + backtracking...")
    sol = solve_sudoku(3, puzzle)
    if sol:
        print("Solution found:")
        for row in sol:
            print("  ", row)

        # Verify with tropical cost
        cost = tropical_violation_cost(3, puzzle, sol)
        print(f"\nTropical violation cost: {cost['total']}")
        print(f"  (Theorem A: cost=0 confirms valid solution)")
    else:
        print("No solution exists.")

    # Demo 2: Phase transition analysis
    print("\n\nPhase Transition Analysis:")
    solution = [
        [5, 3, 4, 6, 7, 8, 9, 1, 2],
        [6, 7, 2, 1, 9, 5, 3, 4, 8],
        [1, 9, 8, 3, 4, 2, 5, 6, 7],
        [8, 5, 9, 7, 6, 1, 4, 2, 3],
        [4, 2, 6, 8, 5, 3, 7, 9, 1],
        [7, 1, 3, 9, 2, 4, 8, 5, 6],
        [9, 6, 1, 5, 3, 7, 2, 8, 4],
        [2, 8, 7, 4, 1, 9, 6, 3, 5],
        [3, 4, 5, 2, 8, 6, 1, 7, 9],
    ]

    results = analyze_phase_transition(3, solution, num_trials=20)
    print(f"  {'Clues':>6} | {'Avg Vol':>10} | {'Undecided':>10} | {'Solved':>8}")
    print("  " + "-" * 45)
    for i, k in enumerate(results['clue_counts']):
        print(f"  {k:>6} | {results['avg_volume'][i]:>10.1f} | "
              f"{results['avg_undecided'][i]:>10.1f} | "
              f"{results['solved_rate'][i]:>7.0%}")
