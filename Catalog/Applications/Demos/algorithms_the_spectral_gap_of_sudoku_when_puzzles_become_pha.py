#!/usr/bin/env python3
"""
Algorithms for Sudoku Spectral Gap Analysis

Implements the core algorithms for computing spectral gaps, mixing times,
and phase transitions in constraint satisfaction problems.
"""

import numpy as np
from typing import List, Tuple, Optional, Dict
from dataclasses import dataclass


@dataclass
class SpectralGapResult:
    """Result of a spectral gap computation."""
    gap: float
    eigenvalues: np.ndarray
    mixing_time: float
    phase: str
    num_solutions: int


@dataclass
class PhaseTransitionPoint:
    """Data point in the phase transition curve."""
    num_clues: int
    density: float
    num_solutions: int
    spectral_gap: float
    mixing_time: float
    phase: str


def latin_square_solver(n: int, clues: Dict[Tuple[int, int], int] = None) -> List[np.ndarray]:
    """Enumerate all Latin squares of size n satisfying given clues.

    Algorithm: Backtracking with constraint propagation.
    Time complexity: O(n! ^ n) worst case, much better with pruning.
    Space complexity: O(n^2) per solution stored.

    Args:
        n: Size of the Latin square
        clues: Dictionary mapping (row, col) to required value

    Returns:
        List of all valid n×n Latin squares matching the clues
    """
    if clues is None:
        clues = {}

    solutions = []

    def is_valid(grid: np.ndarray, row: int, col: int, val: int) -> bool:
        """Check if placing val at (row, col) maintains Latin square property."""
        if val in grid[row, :col]:
            return False
        for r in range(row):
            if grid[r, col] == val:
                return False
        return True

    def solve(grid: np.ndarray, pos: int):
        """Backtracking solver."""
        if pos == n * n:
            solutions.append(grid.copy())
            return

        row, col = pos // n, pos % n

        if (row, col) in clues:
            val = clues[(row, col)]
            if is_valid(grid, row, col, val):
                grid[row, col] = val
                solve(grid, pos + 1)
                grid[row, col] = 0
            return

        for val in range(1, n + 1):
            if is_valid(grid, row, col, val):
                grid[row, col] = val
                solve(grid, pos + 1)
                grid[row, col] = 0

    grid = np.zeros((n, n), dtype=int)
    solve(grid, 0)
    return solutions


def build_adjacency_matrix(solutions: List[np.ndarray]) -> np.ndarray:
    """Build the adjacency matrix of the swap graph.

    Two solutions are adjacent if they differ by exactly one row-swap
    (two entries in the same row exchanged).

    Algorithm: Pairwise comparison with early termination.
    Time complexity: O(m^2 * n^2) where m = |solutions|
    Space complexity: O(m^2)

    Args:
        solutions: List of Latin squares

    Returns:
        Adjacency matrix
    """
    m = len(solutions)
    adj = np.zeros((m, m), dtype=int)

    for i in range(m):
        for j in range(i + 1, m):
            diff = solutions[i] != solutions[j]
            if np.sum(diff) == 2:
                positions = np.argwhere(diff)
                if positions[0][0] == positions[1][0]:
                    adj[i][j] = 1
                    adj[j][i] = 1

    return adj


def adjacency_to_stochastic(adj: np.ndarray) -> np.ndarray:
    """Convert adjacency matrix to row-stochastic transition matrix.

    Each row is normalized to sum to 1. Isolated vertices get self-loops.

    Args:
        adj: Adjacency matrix

    Returns:
        Row-stochastic transition matrix
    """
    m = adj.shape[0]
    P = np.zeros((m, m))

    for i in range(m):
        degree = np.sum(adj[i])
        if degree > 0:
            P[i] = adj[i] / degree
        else:
            P[i, i] = 1.0

    return P


def compute_spectral_data(P: np.ndarray) -> SpectralGapResult:
    """Compute full spectral data of a stochastic matrix.

    Algorithm: Direct eigenvalue computation via numpy.
    Time complexity: O(m^3) for m×m matrix
    Space complexity: O(m^2)

    Args:
        P: Row-stochastic matrix

    Returns:
        SpectralGapResult with gap, eigenvalues, mixing time, and phase
    """
    m = P.shape[0]

    if m <= 1:
        return SpectralGapResult(
            gap=0.0,
            eigenvalues=np.array([1.0]) if m == 1 else np.array([]),
            mixing_time=0.0,
            phase="trivial",
            num_solutions=m
        )

    eigenvalues = np.sort(np.abs(np.linalg.eigvals(P)))[::-1]
    gap = float(1.0 - eigenvalues[1]) if len(eigenvalues) >= 2 else 0.0
    gap = max(gap, 0.0)  # Numerical stability

    epsilon = 0.25
    if gap > 1e-10:
        mixing_time = (1.0 / gap) * (np.log(m) + np.log(1.0 / epsilon))
    else:
        mixing_time = float('inf')

    # Phase classification
    if gap > 0.1:
        phase = "underconstrained"
    elif gap > 1e-6:
        phase = "critical"
    else:
        phase = "overconstrained"

    return SpectralGapResult(
        gap=gap,
        eigenvalues=eigenvalues,
        mixing_time=mixing_time,
        phase=phase,
        num_solutions=m
    )


def analyze_phase_transition(n: int, max_clues: Optional[int] = None) -> List[PhaseTransitionPoint]:
    """Analyze the phase transition by varying the number of clues.

    For each number of clues k = 0, 1, ..., max_clues:
    1. Generate random clue configurations
    2. Count solutions
    3. Compute spectral gap of the swap chain
    4. Classify the phase

    Algorithm: Exhaustive enumeration for small n, sampling for larger n.
    Time complexity: O(n! ^ n * C(n^2, k)) per clue count k
    Space complexity: O(n! ^ n)

    Args:
        n: Size of the Latin square
        max_clues: Maximum number of clues to try (default: n^2)

    Returns:
        List of PhaseTransitionPoint for each clue count
    """
    if max_clues is None:
        max_clues = n * n

    total_cells = n * n
    all_solutions = latin_square_solver(n)
    results = []

    # For k=0 (no clues)
    P = adjacency_to_stochastic(build_adjacency_matrix(all_solutions))
    spec = compute_spectral_data(P)
    results.append(PhaseTransitionPoint(
        num_clues=0,
        density=0.0,
        num_solutions=len(all_solutions),
        spectral_gap=spec.gap,
        mixing_time=spec.mixing_time,
        phase=spec.phase
    ))

    # For k > 0, use the first solution as the "answer" and add clues from it
    if len(all_solutions) > 0:
        answer = all_solutions[0]

        for k in range(1, min(max_clues + 1, total_cells + 1)):
            # Place clues at the first k positions
            clues = {}
            for pos in range(k):
                r, c = pos // n, pos % n
                clues[(r, c)] = int(answer[r, c])

            compatible = latin_square_solver(n, clues)
            density = k / total_cells

            if len(compatible) > 1:
                P = adjacency_to_stochastic(build_adjacency_matrix(compatible))
                spec = compute_spectral_data(P)
            elif len(compatible) == 1:
                spec = SpectralGapResult(0.0, np.array([1.0]), 0.0, "overconstrained", 1)
            else:
                spec = SpectralGapResult(0.0, np.array([]), float('inf'), "infeasible", 0)

            # Phase classification by density
            if density < 17 / 81:
                phase = "underconstrained"
            elif density < 30 / 81:
                phase = "critical"
            else:
                phase = "overconstrained"

            results.append(PhaseTransitionPoint(
                num_clues=k,
                density=density,
                num_solutions=len(compatible),
                spectral_gap=spec.gap,
                mixing_time=spec.mixing_time,
                phase=phase
            ))

    return results


def contraction_sequence(gap: float, steps: int, initial_error: float = 1.0) -> List[float]:
    """Compute the L2 contraction sequence for given spectral gap.

    Theorem: After t steps, error ≤ (1-γ)^t × initial_error.

    Args:
        gap: Spectral gap value
        steps: Number of steps to compute
        initial_error: Initial L2 error

    Returns:
        List of error bounds at each step
    """
    factor = 1.0 - gap
    return [factor ** t * initial_error for t in range(steps + 1)]


def shannon_entropy(probs: np.ndarray) -> float:
    """Compute Shannon entropy of a probability distribution.

    H(p) = -Σ p_i log(p_i)

    Args:
        probs: Probability distribution (non-negative, sums to 1)

    Returns:
        Shannon entropy in nats
    """
    probs = probs[probs > 0]  # Filter out zeros
    return -np.sum(probs * np.log(probs))


if __name__ == "__main__":
    print("Spectral Gap Phase Transition Analysis")
    print("=" * 50)

    for n in [3, 4]:
        print(f"\n--- {n}×{n} Latin Squares ---")
        results = analyze_phase_transition(n, max_clues=n*n)

        for pt in results:
            gap_str = f"{pt.spectral_gap:.4f}" if pt.spectral_gap > 0 else "0.0000"
            mt_str = f"{pt.mixing_time:.1f}" if pt.mixing_time < float('inf') else "∞"
            print(f"  k={pt.num_clues:>2}, d={pt.density:.3f}, "
                  f"|S|={pt.num_solutions:>4}, γ={gap_str}, "
                  f"T_mix={mt_str:>8}, phase={pt.phase}")
