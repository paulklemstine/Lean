#!/usr/bin/env python3
"""Exact numerical demonstrations for generalized Sudoku.

The program constructs the arithmetic completion, validates every unit, builds
small constraint graphs, demonstrates the canonical row clique, and checks that
restrictions of a completed grid remain solvable at every clue count.
It uses only the Python standard library.
"""

from __future__ import annotations

import argparse
import random
from dataclasses import dataclass
from itertools import combinations
from typing import Iterable, Optional, Sequence

Cell = tuple[int, int]
Grid = list[list[int]]
ClueGrid = list[list[Optional[int]]]


def sudoku_value(n: int, row: int, col: int) -> int:
    """Return (n*(row mod n) + floor(row/n) + col) mod n^2."""
    if n <= 0:
        raise ValueError("block size n must be positive")
    size = n * n
    if not (0 <= row < size and 0 <= col < size):
        raise IndexError("cell coordinates are outside the grid")
    return (n * (row % n) + row // n + col) % size


def arithmetic_completion(n: int) -> Grid:
    """Construct the explicit order-n Sudoku completion in O(n^4) time."""
    if n <= 0:
        raise ValueError("block size n must be positive")
    size = n * n
    return [[sudoku_value(n, r, c) for c in range(size)] for r in range(size)]


def units(n: int, grid: Sequence[Sequence[int]]) -> Iterable[list[int]]:
    """Yield all rows, columns, and blocks of a square grid."""
    size = n * n
    if len(grid) != size or any(len(row) != size for row in grid):
        raise ValueError(f"expected a {size} by {size} grid")
    for r in range(size):
        yield list(grid[r])
    for c in range(size):
        yield [grid[r][c] for r in range(size)]
    for br in range(n):
        for bc in range(n):
            yield [
                grid[br * n + dr][bc * n + dc]
                for dr in range(n)
                for dc in range(n)
            ]


def is_valid_solution(n: int, grid: Sequence[Sequence[int]]) -> bool:
    """Check that each row, column, and block contains every symbol once."""
    target = set(range(n * n))
    try:
        return all(set(unit) == target and len(unit) == len(target) for unit in units(n, grid))
    except ValueError:
        return False


def are_peers(n: int, p: Cell, q: Cell) -> bool:
    """Decide adjacency in the Sudoku constraint graph."""
    if p == q:
        return False
    return (
        p[0] == q[0]
        or p[1] == q[1]
        or (p[0] // n == q[0] // n and p[1] // n == q[1] // n)
    )


def constraint_graph(n: int) -> dict[Cell, set[Cell]]:
    """Build the constraint graph directly; intended for modest n."""
    if n <= 0:
        raise ValueError("block size n must be positive")
    size = n * n
    cells = [(r, c) for r in range(size) for c in range(size)]
    graph = {cell: set() for cell in cells}
    for p, q in combinations(cells, 2):
        if are_peers(n, p, q):
            graph[p].add(q)
            graph[q].add(p)
    return graph


def is_proper_coloring(graph: dict[Cell, set[Cell]], grid: Sequence[Sequence[int]]) -> bool:
    """Check that every graph edge has differently colored endpoints."""
    return all(grid[p[0]][p[1]] != grid[q[0]][q[1]] for p in graph for q in graph[p])


def clues_from_solution(grid: Sequence[Sequence[int]], chosen: set[Cell]) -> ClueGrid:
    """Reveal exactly the chosen cells of a completed grid."""
    return [
        [value if (r, c) in chosen else None for c, value in enumerate(row)]
        for r, row in enumerate(grid)
    ]


def extends(clues: Sequence[Sequence[Optional[int]]], grid: Sequence[Sequence[int]]) -> bool:
    """Return whether the completed grid agrees with every displayed clue."""
    return all(
        clue is None or clue == grid[r][c]
        for r, row in enumerate(clues)
        for c, clue in enumerate(row)
    )


def clue_count(clues: Sequence[Sequence[Optional[int]]]) -> int:
    """Count displayed entries."""
    return sum(value is not None for row in clues for value in row)


def sample_restriction(n: int, k: int, seed: int = 0) -> tuple[ClueGrid, Grid]:
    """Sample k cells and reveal their values from the arithmetic completion."""
    size = n * n
    total = size * size
    if not (0 <= k <= total):
        raise ValueError(f"clue count must lie between 0 and {total}")
    rng = random.Random(seed)
    cells = [(r, c) for r in range(size) for c in range(size)]
    selected = set(rng.sample(cells, k))
    solution = arithmetic_completion(n)
    return clues_from_solution(solution, selected), solution


def format_grid(grid: Sequence[Sequence[Optional[int]]], n: int) -> str:
    """Format a completed or partial grid with block separators."""
    width = len(str(n * n - 1))
    horizontal = "+".join("-" * ((width + 1) * n - 1) for _ in range(n))
    lines: list[str] = []
    for r, row in enumerate(grid):
        if r and r % n == 0:
            lines.append(horizontal)
        groups = []
        for start in range(0, n * n, n):
            groups.append(" ".join(
                ("." if value is None else str(value)).rjust(width)
                for value in row[start:start + n]
            ))
        lines.append(" | ".join(groups))
    return "\n".join(lines)


@dataclass(frozen=True)
class Demonstration:
    n: int
    vertices: int
    edges: int
    row_clique_size: int
    all_units_valid: bool
    coloring_proper: bool


def demonstrate_structure(n: int) -> Demonstration:
    """Compute graph and coloring statistics for an order-n instance."""
    grid = arithmetic_completion(n)
    graph = constraint_graph(n)
    first_row = [(0, c) for c in range(n * n)]
    row_is_clique = all(q in graph[p] for p, q in combinations(first_row, 2))
    if not row_is_clique:
        raise AssertionError("the first row should be a clique")
    return Demonstration(
        n=n,
        vertices=len(graph),
        edges=sum(map(len, graph.values())) // 2,
        row_clique_size=len(first_row),
        all_units_valid=is_valid_solution(n, grid),
        coloring_proper=is_proper_coloring(graph, grid),
    )


def verify_every_clue_count(n: int) -> bool:
    """For every k, exhibit a k-clue restriction with the known completion."""
    solution = arithmetic_completion(n)
    size = n * n
    cells = [(r, c) for r in range(size) for c in range(size)]
    for k in range(size * size + 1):
        clues = clues_from_solution(solution, set(cells[:k]))
        if clue_count(clues) != k or not extends(clues, solution):
            return False
    return True


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("-n", type=int, default=3, help="positive block size (default: 3)")
    parser.add_argument("-k", type=int, default=None, help="number of clues to reveal")
    parser.add_argument("--seed", type=int, default=2026, help="sampling seed")
    parser.add_argument("--skip-graph", action="store_true", help="skip graph construction")
    args = parser.parse_args()

    n = args.n
    grid = arithmetic_completion(n)
    total = n ** 4
    k = total // 2 if args.k is None else args.k
    clues, witness = sample_restriction(n, k, args.seed)

    print(f"Order-{n} arithmetic completion ({n*n} x {n*n}):")
    print(format_grid(grid, n))
    print(f"\nValid solution: {is_valid_solution(n, grid)}")
    print(f"\nRestriction with {clue_count(clues)} of {total} cells revealed:")
    print(format_grid(clues, n))
    print(f"Known completion extends all clues: {extends(clues, witness)}")
    print(f"All clue counts 0..{total} have a witnessed solvable restriction: "
          f"{verify_every_clue_count(n)}")

    if not args.skip_graph:
        stats = demonstrate_structure(n)
        print("\nConstraint-graph statistics:")
        print(f"  vertices: {stats.vertices}")
        print(f"  edges: {stats.edges}")
        print(f"  canonical row clique: {stats.row_clique_size}")
        print(f"  arithmetic coloring proper: {stats.coloring_proper}")
        print(f"  chromatic number certificate: lower bound {n*n}, upper bound {n*n}")


if __name__ == "__main__":
    main()
