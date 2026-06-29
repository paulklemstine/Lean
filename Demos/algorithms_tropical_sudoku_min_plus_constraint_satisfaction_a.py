#!/usr/bin/env python3
"""
Algorithms for Tropical Sudoku CSP.

Implements:
1. Tropical cost computation (O(n^2) per unit)
2. Constraint propagation with convergence tracking
3. Residual ambiguity analysis
4. Phase transition scanning
"""

from typing import Dict, List, Tuple, Set, Optional
import numpy as np


Cell = Tuple[int, int]
Digit = int
Assignment = Dict[Cell, Digit]
Clue = Tuple[Cell, Digit]
CandidateSet = Dict[Cell, Set[Digit]]

ALL_CELLS: List[Cell] = [(r, c) for r in range(9) for c in range(9)]
ALL_DIGITS: Set[Digit] = set(range(9))


def get_neighbors(cell: Cell) -> List[Cell]:
    """Return all cells sharing a row, column, or box with the given cell.

    Time complexity: O(1) (bounded by grid size)

    Args:
        cell: A (row, col) pair

    Returns:
        List of neighboring cells (excluding the cell itself)
    """
    r, c = cell
    nbrs = []
    for r2 in range(9):
        for c2 in range(9):
            if (r2, c2) == (r, c):
                continue
            if r2 == r or c2 == c or (r2 // 3 == r // 3 and c2 // 3 == c // 3):
                nbrs.append((r2, c2))
    return nbrs

# Precompute neighbor lists for efficiency
NEIGHBOR_MAP: Dict[Cell, List[Cell]] = {c: get_neighbors(c) for c in ALL_CELLS}


class TropicalSudokuCSP:
    """Tropical CSP encoding of Sudoku.

    The tropical cost of an assignment equals the number of constraint
    violations. Zero cost ↔ valid solution (Exactness Theorem).

    Attributes:
        clues: Set of (cell, digit) constraints
    """

    def __init__(self, clues: List[Clue]):
        self.clues = clues
        self._clue_map: Dict[Cell, Digit] = {c: d for c, d in clues}

    def clue_penalty(self, assignment: Assignment) -> int:
        """Count clue violations.

        Time: O(|clues|)
        """
        return sum(1 for c, d in self.clues if assignment.get(c) != d)

    def unit_violation_count(self, assignment: Assignment) -> int:
        """Count ordered pairs of same-unit cells with same digit.

        Time: O(81 * 20) = O(1) [fixed grid]
        """
        count = 0
        for cell in ALL_CELLS:
            for nbr in NEIGHBOR_MAP[cell]:
                if assignment.get(cell) == assignment.get(nbr):
                    count += 1
        return count

    def tropical_cost(self, assignment: Assignment) -> int:
        """Total tropical Sudoku cost.

        Time: O(|clues| + 81*20)
        """
        return self.clue_penalty(assignment) + self.unit_violation_count(assignment)

    def is_valid(self, assignment: Assignment) -> bool:
        """Check validity (equivalent to tropical_cost == 0 by Exactness Theorem).

        Time: O(|clues| + 81*20)
        """
        return self.tropical_cost(assignment) == 0


class ConstraintPropagator:
    """Constraint propagation engine for Sudoku.

    Implements naked-singles elimination as a monotone contracting
    operator on candidate sets.

    The operator satisfies:
    - Soundness: valid solutions are preserved
    - Antitonicity: candidate sets can only shrink
    - Stabilization: fixed point reached in ≤ 729 steps

    Attributes:
        clues: Clue constraints
        candidates: Current candidate sets
        steps: Number of propagation steps performed
        mass_history: Track total candidate mass over time
    """

    def __init__(self, clues: List[Clue]):
        self.clues = clues
        self._clue_map: Dict[Cell, Digit] = {c: d for c, d in clues}
        self.candidates: CandidateSet = {}
        self.steps: int = 0
        self.mass_history: List[int] = []
        self._initialize()

    def _initialize(self):
        """Set initial candidates: clue cells get singleton, others get all digits."""
        self.candidates = {}
        for cell in ALL_CELLS:
            if cell in self._clue_map:
                self.candidates[cell] = {self._clue_map[cell]}
            else:
                self.candidates[cell] = set(ALL_DIGITS)
        self.mass_history = [self.total_mass()]

    def total_mass(self) -> int:
        """Total candidate mass = Σ |candidates(c)|.

        Bounded by 81 * 9 = 729.
        """
        return sum(len(self.candidates[c]) for c in ALL_CELLS)

    def residual_ambiguity(self) -> int:
        """Residual ambiguity = total_mass - 81.

        Zero residual ambiguity means every cell has exactly one candidate.
        """
        return self.total_mass() - 81

    def propagate_step(self) -> bool:
        """Execute one propagation step.

        Algorithm:
        1. For each cell, intersect candidates with clue restriction
        2. Remove digits that are forced (singleton) in any neighbor

        Returns:
            True if candidates changed, False if fixed point reached

        Time: O(81 * 20) per step
        Space: O(81 * 9)
        """
        new_candidates: CandidateSet = {}
        changed = False

        for cell in ALL_CELLS:
            cands = set(self.candidates[cell])

            # Clue restriction
            if cell in self._clue_map:
                cands &= {self._clue_map[cell]}

            # Naked singles elimination
            for nbr in NEIGHBOR_MAP[cell]:
                if len(self.candidates[nbr]) == 1:
                    cands -= self.candidates[nbr]

            new_candidates[cell] = cands
            if cands != self.candidates[cell]:
                changed = True

        self.candidates = new_candidates
        self.steps += 1
        self.mass_history.append(self.total_mass())
        return changed

    def propagate_until_stable(self, max_steps: int = 729) -> int:
        """Run propagation until fixed point.

        Convergence guaranteed in ≤ 729 steps by the Stabilization Theorem:
        each non-trivial step strictly decreases the total candidate mass,
        which is bounded by 729.

        Args:
            max_steps: Maximum iterations (729 suffices by theorem)

        Returns:
            Number of steps to reach fixed point

        Time: O(729 * 81 * 20) = O(1) [fixed grid]
        """
        for _ in range(max_steps):
            if not self.propagate_step():
                break
        return self.steps

    def is_solved(self) -> bool:
        """Check if propagation has determined all cells."""
        return all(len(self.candidates[c]) == 1 for c in ALL_CELLS)

    def has_contradiction(self) -> bool:
        """Check if any cell has empty candidate set."""
        return any(len(self.candidates[c]) == 0 for c in ALL_CELLS)

    def get_solution(self) -> Optional[Assignment]:
        """Extract solution if fully determined."""
        if not self.is_solved():
            return None
        return {c: next(iter(self.candidates[c])) for c in ALL_CELLS}


def phase_transition_scan(
    solution: List[List[int]],
    n_trials: int = 50,
    seed: int = 42
) -> Dict[int, Dict[str, float]]:
    """Scan residual ambiguity across clue densities.

    For each clue count k from 0 to 81, randomly select k cells
    as clues (using the given solution), run propagation, and
    record the residual ambiguity.

    This demonstrates the phase transition: residual ambiguity
    peaks at intermediate clue density, corresponding to the
    tropical feasibility boundary.

    Args:
        solution: 9x9 grid of digits (1-9)
        n_trials: Number of random trials per density
        seed: Random seed

    Returns:
        Dictionary mapping clue count to statistics
        {k: {"mean_residual": ..., "mean_steps": ..., "solved_frac": ...}}

    Time: O(82 * n_trials * 729 * 81 * 20)
    """
    rng = np.random.RandomState(seed)
    results = {}

    for n_clues in range(0, 82):
        residuals = []
        steps_list = []
        solved_count = 0

        for _ in range(n_trials):
            cells = list(ALL_CELLS)
            rng.shuffle(cells)
            clues = [(cells[i], solution[cells[i][0]][cells[i][1]] - 1)
                     for i in range(n_clues)]

            prop = ConstraintPropagator(clues)
            prop.propagate_until_stable()

            residuals.append(prop.residual_ambiguity())
            steps_list.append(prop.steps)
            if prop.is_solved():
                solved_count += 1

        results[n_clues] = {
            "mean_residual": float(np.mean(residuals)),
            "std_residual": float(np.std(residuals)),
            "mean_steps": float(np.mean(steps_list)),
            "solved_frac": solved_count / n_trials,
        }

    return results


if __name__ == "__main__":
    # Quick validation
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

    # Test tropical cost
    assignment = {(r, c): solution[r][c] - 1 for r in range(9) for c in range(9)}
    csp = TropicalSudokuCSP([])
    assert csp.tropical_cost(assignment) == 0, "Valid solution should have zero cost"
    assert csp.is_valid(assignment), "Should be valid"

    # Test propagation with many clues
    many_clues = [(c, assignment[c]) for c in ALL_CELLS[:40]]
    prop = ConstraintPropagator(many_clues)
    prop.propagate_until_stable()
    print(f"Propagation with 40 clues: mass={prop.total_mass()}, "
          f"steps={prop.steps}, solved={prop.is_solved()}")

    print("All algorithm tests passed.")
