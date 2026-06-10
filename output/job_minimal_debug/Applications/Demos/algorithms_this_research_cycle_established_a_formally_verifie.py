"""
Algorithms for Phase Transitions in Constraint Satisfaction Problems.

This module implements the mathematical framework for analyzing phase transitions
in Latin square completion, including critical density computation, rook's graph
construction, constraint entropy calculation, and random Latin square sampling.
"""

from __future__ import annotations
import math
import random
from typing import Optional


def critical_density(n: int) -> float:
    """Compute the critical density d_c(n) = (n² - 1)/n² for n×n Latin squares.

    At this density, the system has exactly one degree of freedom remaining.

    Args:
        n: Board size (must be ≥ 1).

    Returns:
        The critical density as a float in (0, 1).

    >>> critical_density(9)
    0.9876543209876543
    >>> critical_density(100)
    0.9999
    """
    if n < 1:
        raise ValueError(f"Board size must be ≥ 1, got {n}")
    return (n * n - 1) / (n * n)


def structural_identity(n: int) -> float:
    """Verify the structural identity n²(1 - d_c(n)).

    Should return exactly 1.0 for all n ≥ 1.

    Args:
        n: Board size.

    Returns:
        n² * (1 - d_c(n)), which should equal 1.
    """
    dc = critical_density(n)
    return n * n * (1 - dc)


def constraint_entropy(total: int, filled: int, domain: int) -> float:
    """Compute the constraint entropy bound: (total - filled) * log(domain).

    This upper bounds the log of the number of valid completions.

    Args:
        total: Total number of cells.
        filled: Number of pre-filled cells.
        domain: Size of the value domain.

    Returns:
        The constraint entropy in nats.
    """
    if filled > total:
        raise ValueError(f"filled ({filled}) > total ({total})")
    if domain < 1:
        raise ValueError(f"domain must be ≥ 1, got {domain}")
    return (total - filled) * math.log(domain)


def rook_graph_degree(n: int) -> int:
    """Compute the degree of each vertex in the rook's graph R(n,n).

    Each cell (i,j) has n-1 neighbors in its row and n-1 in its column.

    Args:
        n: Board size.

    Returns:
        The degree 2(n-1).
    """
    return 2 * (n - 1)


def rook_graph_edges(n: int) -> int:
    """Compute the number of directed edges in the rook's graph R(n,n).

    Total = n² * 2(n-1) = 2n²(n-1).

    Args:
        n: Board size.

    Returns:
        Number of directed edges.
    """
    return 2 * n * n * (n - 1)


def rook_graph_adjacency(n: int) -> list[list[bool]]:
    """Construct the adjacency matrix of the rook's graph R(n,n).

    Vertices are indexed as (i*n + j) for cell (i,j).

    Args:
        n: Board size.

    Returns:
        n²×n² adjacency matrix.
    """
    size = n * n
    adj: list[list[bool]] = [[False] * size for _ in range(size)]
    for i1 in range(n):
        for j1 in range(n):
            v1 = i1 * n + j1
            for i2 in range(n):
                for j2 in range(n):
                    v2 = i2 * n + j2
                    if v1 != v2 and (i1 == i2 or j1 == j2):
                        adj[v1][v2] = True
    return adj


def is_valid_latin_square(grid: list[list[int]], n: int) -> bool:
    """Check if a completed grid is a valid n×n Latin square.

    Args:
        grid: n×n grid with values in {0, ..., n-1}.
        n: Board size.

    Returns:
        True if grid is a valid Latin square.
    """
    for i in range(n):
        if sorted(grid[i]) != list(range(n)):
            return False
    for j in range(n):
        col = [grid[i][j] for i in range(n)]
        if sorted(col) != list(range(n)):
            return False
    return True


def generate_random_latin_square(n: int) -> list[list[int]]:
    """Generate a random n×n Latin square using row-by-row construction.

    Uses a simple backtracking approach with random permutation attempts.

    Args:
        n: Board size.

    Returns:
        A valid n×n Latin square.
    """
    grid: list[list[int]] = []
    max_attempts = 1000

    for attempt in range(max_attempts):
        grid = []
        success = True
        for i in range(n):
            row_attempts = 0
            placed = False
            while row_attempts < 100 and not placed:
                perm = list(range(n))
                random.shuffle(perm)
                valid = True
                for j in range(n):
                    for prev_i in range(i):
                        if grid[prev_i][j] == perm[j]:
                            valid = False
                            break
                    if not valid:
                        break
                if valid:
                    grid.append(perm)
                    placed = True
                row_attempts += 1
            if not placed:
                success = False
                break
        if success:
            return grid

    # Fallback: return identity-based Latin square
    return [[(i + j) % n for j in range(n)] for i in range(n)]


def random_partial_latin_square(
    n: int, density: float
) -> tuple[list[list[Optional[int]]], list[list[int]]]:
    """Create a random partial Latin square by removing cells from a complete one.

    Args:
        n: Board size.
        density: Fraction of cells to keep filled (0 to 1).

    Returns:
        Tuple of (partial grid with None for empty cells, original complete grid).
    """
    complete = generate_random_latin_square(n)
    total_cells = n * n
    filled_count = int(density * total_cells)
    filled_count = min(filled_count, total_cells)

    # Choose which cells to keep
    all_cells = [(i, j) for i in range(n) for j in range(n)]
    random.shuffle(all_cells)
    kept = set(tuple(c) for c in all_cells[:filled_count])

    partial: list[list[Optional[int]]] = [
        [complete[i][j] if (i, j) in kept else None for j in range(n)]
        for i in range(n)
    ]
    return partial, complete


def can_complete_latin_square(
    partial: list[list[Optional[int]]], n: int
) -> bool:
    """Check if a partial Latin square can be completed using backtracking.

    Args:
        partial: n×n grid with None for empty cells, values in {0,...,n-1}.
        n: Board size.

    Returns:
        True if the partial Latin square can be completed.
    """
    grid = [row[:] for row in partial]

    def find_empty() -> Optional[tuple[int, int]]:
        for i in range(n):
            for j in range(n):
                if grid[i][j] is None:
                    return (i, j)
        return None

    def is_valid_placement(row: int, col: int, val: int) -> bool:
        for j in range(n):
            if grid[row][j] == val:
                return False
        for i in range(n):
            if grid[i][col] == val:
                return False
        return True

    def solve() -> bool:
        pos = find_empty()
        if pos is None:
            return True
        row, col = pos
        values = list(range(n))
        random.shuffle(values)
        for val in values:
            if is_valid_placement(row, col, val):
                grid[row][col] = val
                if solve():
                    return True
                grid[row][col] = None
        return False

    return solve()


def estimate_completion_probability(
    n: int, density: float, trials: int = 100
) -> float:
    """Estimate the probability of completing a random partial Latin square.

    Args:
        n: Board size.
        density: Fraction of cells to keep filled.
        trials: Number of random trials.

    Returns:
        Estimated completion probability.
    """
    successes = 0
    for _ in range(trials):
        partial, _ = random_partial_latin_square(n, density)
        if can_complete_latin_square(partial, n):
            successes += 1
    return successes / trials


def phase_transition_scan(
    n: int, density_steps: int = 20, trials_per_step: int = 50
) -> list[tuple[float, float]]:
    """Scan the phase transition by varying density.

    Args:
        n: Board size.
        density_steps: Number of density values to test.
        trials_per_step: Number of random trials per density value.

    Returns:
        List of (density, completion_probability) pairs.
    """
    results: list[tuple[float, float]] = []
    for step in range(density_steps + 1):
        density = step / density_steps
        prob = estimate_completion_probability(n, density, trials_per_step)
        results.append((density, prob))
    return results


if __name__ == "__main__":
    print("=== Critical Density Analysis ===")
    for n in [3, 5, 9, 10, 20, 50, 100]:
        dc = critical_density(n)
        si = structural_identity(n)
        print(f"n={n:3d}: d_c = {dc:.6f}, n²(1-d_c) = {si:.6f}")

    print("\n=== Rook's Graph Properties ===")
    for n in [3, 5, 9]:
        print(
            f"R({n},{n}): vertices={n**2}, "
            f"degree={rook_graph_degree(n)}, "
            f"directed_edges={rook_graph_edges(n)}"
        )

    print("\n=== Constraint Entropy at Critical Density ===")
    for n in [3, 5, 9, 10]:
        entropy = constraint_entropy(n * n, n * n - 1, n)
        print(
            f"n={n}: H(n²,n²-1,n) = {entropy:.4f}, "
            f"log(n) = {math.log(n):.4f}"
        )
