"""
Algorithms for CSP Phase Transition Analysis in Sudoku

Type-hinted implementations of the core algorithms for studying
phase transitions in constraint satisfaction problems.
"""

from typing import List, Optional, Tuple, Set
import random
import math


def sudoku_constraint_degree(n: int) -> int:
    """
    Compute the constraint degree of a cell in an n²×n² Sudoku grid.

    Each cell conflicts with:
    - (n² - 1) cells in the same row
    - (n² - 1) cells in the same column
    - (n² - 1) cells in the same box, minus overlaps

    Row-box overlap: (n - 1) cells, column-box overlap: (n - 1) cells.
    Total = 3(n² - 1) - 2(n - 1) = 3n² - 2n - 1

    Args:
        n: Box size (the full grid is n² × n²)

    Returns:
        Number of cells each cell conflicts with
    """
    return 3 * n**2 - 2 * n - 1


def latin_square_constraint_degree(n: int) -> int:
    """Constraint degree for plain Latin square (no box constraints)."""
    return 2 * (n**2 - 1)


def box_additional_constraints(n: int) -> int:
    """Additional constraints from box structure: (n-1)²."""
    return (n - 1) ** 2


def critical_density(n: int) -> float:
    """
    Critical density for n×n Latin square completion: (n²-1)/n².

    At this density, the expected number of valid completions crosses 1.
    """
    return (n**2 - 1) / n**2


def constraint_interaction_strength(n: int) -> float:
    """
    Constraint interaction strength for Sudoku: (2n+1)/(3n).

    Measures overlap between row, column, and box constraints.
    Converges to 2/3 as n → ∞.
    """
    return (2 * n + 1) / (3 * n)


def cluster_ratio(n: int, d: float) -> float:
    """
    Cluster ratio at density d on an n×n grid.

    Measures expected fraction of cells where two random solutions differ.
    At critical density, equals 1/n.
    """
    return (1 - d) * n


def hardness_function(n: int, d: float) -> float:
    """
    Hardness function: d * (1 - d) * n⁴.

    Models computational difficulty as constraint_pressure × freedom.
    Maximum at d = 1/2, but relevant maximum in feasible range is at transition.
    """
    return d * (1 - d) * n**4


def generate_random_partial_latin_square(
    n: int, num_filled: int, max_attempts: int = 10000
) -> Optional[List[Tuple[int, int, int]]]:
    """
    Generate a random consistent partial Latin square of size n×n
    with the given number of filled cells.

    Uses rejection sampling: randomly place values ensuring no conflicts.

    Args:
        n: Grid size
        num_filled: Number of cells to fill
        max_attempts: Maximum placement attempts before giving up

    Returns:
        List of (row, col, value) triples, or None if generation fails
    """
    grid: List[List[int]] = [[-1] * n for _ in range(n)]
    filled: List[Tuple[int, int, int]] = []

    cells = [(i, j) for i in range(n) for j in range(n)]
    random.shuffle(cells)

    attempts = 0
    for i, j in cells:
        if len(filled) >= num_filled:
            break

        # Find valid values for this cell
        used_in_row: Set[int] = {grid[i][k] for k in range(n) if grid[i][k] >= 0}
        used_in_col: Set[int] = {grid[k][j] for k in range(n) if grid[k][j] >= 0}
        available = [v for v in range(n) if v not in used_in_row and v not in used_in_col]

        if available:
            val = random.choice(available)
            grid[i][j] = val
            filled.append((i, j, val))
        else:
            attempts += 1
            if attempts > max_attempts:
                return None

    return filled if len(filled) >= num_filled else None


def is_latin_square_completable(grid: List[List[int]], n: int) -> bool:
    """
    Check if a partial Latin square can be completed using backtracking.

    Args:
        grid: n×n grid, -1 for empty cells
        n: Grid size

    Returns:
        True if completable
    """
    # Find first empty cell
    for i in range(n):
        for j in range(n):
            if grid[i][j] == -1:
                used_row = {grid[i][k] for k in range(n) if grid[i][k] >= 0}
                used_col = {grid[k][j] for k in range(n) if grid[k][j] >= 0}
                for val in range(n):
                    if val not in used_row and val not in used_col:
                        grid[i][j] = val
                        if is_latin_square_completable(grid, n):
                            grid[i][j] = -1
                            return True
                        grid[i][j] = -1
                return False
    return True


def measure_phase_transition(
    n: int, num_samples: int = 100, density_steps: int = 20
) -> List[Tuple[float, float, float]]:
    """
    Measure the phase transition by sampling random partial Latin squares
    at various densities and measuring satisfiability probability.

    Args:
        n: Grid size
        num_samples: Number of samples per density
        density_steps: Number of density points to sample

    Returns:
        List of (density, sat_probability, avg_solve_time_ms) triples
    """
    import time

    results: List[Tuple[float, float, float]] = []
    total_cells = n * n

    for step in range(density_steps + 1):
        d = step / density_steps
        num_filled = int(d * total_cells)
        num_filled = min(num_filled, total_cells)

        sat_count = 0
        total_time = 0.0

        for _ in range(num_samples):
            partial = generate_random_partial_latin_square(n, num_filled)
            if partial is None:
                continue

            grid = [[-1] * n for _ in range(n)]
            for r, c, v in partial:
                grid[r][c] = v

            start = time.time()
            if is_latin_square_completable(grid, n):
                sat_count += 1
            elapsed = (time.time() - start) * 1000
            total_time += elapsed

        sat_prob = sat_count / max(num_samples, 1)
        avg_time = total_time / max(num_samples, 1)
        results.append((d, sat_prob, avg_time))

    return results


def backtracking_tree_size(
    branching_factor: float, depth: int, pruning_rate: float
) -> float:
    """
    Expected backtracking tree size.

    Args:
        branching_factor: Average branching at each node
        depth: Search tree depth
        pruning_rate: Fraction of branches pruned (0 to 1)

    Returns:
        Expected number of nodes explored
    """
    effective = branching_factor * (1 - pruning_rate)
    return effective ** depth


def constraint_degree_ratio(n: int) -> float:
    """
    Ratio of Sudoku to Latin square constraint degrees.

    Converges to 3/2 as n → ∞.
    """
    if n < 2:
        return float('inf')
    sudoku = sudoku_constraint_degree(n)
    latin = latin_square_constraint_degree(n)
    return sudoku / latin if latin > 0 else float('inf')


if __name__ == "__main__":
    print("=== Sudoku CSP Phase Transition Analysis ===\n")

    # Demonstrate constraint degree decomposition
    print("--- Constraint Degree Decomposition ---")
    for n in range(2, 8):
        sd = sudoku_constraint_degree(n)
        ld = latin_square_constraint_degree(n)
        ba = box_additional_constraints(n)
        ratio = constraint_degree_ratio(n)
        print(f"  n={n}: Sudoku={sd}, Latin={ld}, Box_extra={ba}, "
              f"Sum={ld+ba}, Ratio={ratio:.4f}")

    print(f"\n--- Critical Densities ---")
    for n in range(2, 8):
        dc = critical_density(n)
        cis = constraint_interaction_strength(n)
        cr = cluster_ratio(n, dc)
        print(f"  n={n}: d_c={dc:.6f}, interaction={cis:.4f}, cluster_ratio={cr:.4f}")

    print(f"\n--- Degree Ratio Convergence to 3/2 ---")
    for n in [2, 3, 5, 10, 20, 50, 100, 1000]:
        r = constraint_degree_ratio(n)
        print(f"  n={n}: ratio={r:.6f}, gap={abs(r - 1.5):.6f}")
