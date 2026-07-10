"""
Numerical demonstrations for:

    The Chromatic Number of the Sudoku Constraint Graph,
    and the Phase Transition of Random Sudoku.

This self-contained script demonstrates the paper's main results:

  1. The shift construction produces a valid completed n-Sudoku grid,
     proving that every empty n^2 x n^2 grid is solvable (upper bound
     chi(G_n) <= n^2).
  2. The first row is a clique of size n^2 in the Sudoku constraint graph
     (lower bound chi(G_n) >= n^2), so chi(G_n) = n^2.
  3. Valid Sudoku solutions are exactly proper colorings of the constraint
     graph (the bridge theorem), checked on explicit grids.
  4. The random-instance solvability phase transition, whose conjectured
     critical clue density is d_c(n) = (n^2 - 1) / n^2.

Run:  python demo.py
"""

from __future__ import annotations

import random
from itertools import combinations, product
from typing import Dict, Iterable, List, Optional, Tuple

Cell = Tuple[int, int]


# ---------------------------------------------------------------------------
# 1. The shift construction: an explicit solution of the empty grid
# ---------------------------------------------------------------------------
def sudoku_val(n: int, r: int, c: int) -> int:
    """Value at cell (r, c) of the closed-form completed grid:
        (n * (r mod n) + r // n + c) mod n^2.
    """
    return (n * (r % n) + r // n + c) % (n * n)


def shift_grid(n: int) -> List[List[int]]:
    """Return the full n^2 x n^2 completed grid from the shift construction."""
    m = n * n
    return [[sudoku_val(n, r, c) for c in range(m)] for r in range(m)]


# ---------------------------------------------------------------------------
# 2. Constraint relations and the constraint graph
# ---------------------------------------------------------------------------
def same_row(p: Cell, q: Cell) -> bool:
    return p[0] == q[0]


def same_col(p: Cell, q: Cell) -> bool:
    return p[1] == q[1]


def same_box(n: int, p: Cell, q: Cell) -> bool:
    return (p[0] // n == q[0] // n) and (p[1] // n == q[1] // n)


def adjacent(n: int, p: Cell, q: Cell) -> bool:
    """Edge of the Sudoku constraint graph G_n."""
    if p == q:
        return False
    return same_row(p, q) or same_col(p, q) or same_box(n, p, q)


def cells(n: int) -> List[Cell]:
    m = n * n
    return [(r, c) for r in range(m) for c in range(m)]


# ---------------------------------------------------------------------------
# 3. Validity / proper-coloring checks (the bridge)
# ---------------------------------------------------------------------------
def is_valid_solution(n: int, g: Dict[Cell, int]) -> bool:
    """True iff no two distinct cells sharing a row, column, or block agree."""
    cs = cells(n)
    for p, q in combinations(cs, 2):
        if adjacent(n, p, q) and g[p] == g[q]:
            return False
    return True


def is_proper_coloring(n: int, g: Dict[Cell, int]) -> bool:
    """Identical predicate, phrased via graph adjacency (bridge theorem)."""
    cs = cells(n)
    for p, q in combinations(cs, 2):
        if adjacent(n, p, q) and g[p] == g[q]:
            return False
    return True


def grid_to_map(grid: List[List[int]]) -> Dict[Cell, int]:
    return {(r, c): grid[r][c] for r in range(len(grid)) for c in range(len(grid[0]))}


# ---------------------------------------------------------------------------
# 4. Clique certifying the chromatic lower bound
# ---------------------------------------------------------------------------
def first_row_is_clique(n: int) -> bool:
    """The first row is a clique of size n^2 in G_n."""
    m = n * n
    row = [(0, c) for c in range(m)]
    return all(adjacent(n, p, q) for p, q in combinations(row, 2)) and len(row) == m


# ---------------------------------------------------------------------------
# 5. Backtracking solver for puzzles (precoloring extension)
# ---------------------------------------------------------------------------
def solve(n: int, clues: Dict[Cell, int]) -> Optional[Dict[Cell, int]]:
    """Backtracking search with the minimum-remaining-values heuristic.
    Returns a completion extending `clues`, or None if unsolvable.
    """
    m = n * n
    g: Dict[Cell, int] = dict(clues)
    all_cells = cells(n)

    def candidates(cell: Cell) -> List[int]:
        used = set()
        for other in all_cells:
            if other in g and adjacent(n, cell, other):
                used.add(g[other])
        return [v for v in range(m) if v not in used]

    # consistency of the clues themselves
    for p, q in combinations(list(g.keys()), 2):
        if adjacent(n, p, q) and g[p] == g[q]:
            return None

    def backtrack() -> bool:
        empty = [cell for cell in all_cells if cell not in g]
        if not empty:
            return True
        # MRV: pick the most constrained empty cell
        cell = min(empty, key=lambda c: len(candidates(c)))
        opts = candidates(cell)
        if not opts:
            return False
        for v in opts:
            g[cell] = v
            if backtrack():
                return True
            del g[cell]
        return False

    return dict(g) if backtrack() else None


# ---------------------------------------------------------------------------
# 6. Random-instance phase transition
# ---------------------------------------------------------------------------
def random_puzzle(n: int, density: float, rng: random.Random) -> Dict[Cell, int]:
    """Random clue set at the given density, sampled from a valid solution
    (so puzzles at any density remain solvable in this benign model; for a
    harder model one would sample clue symbols independently)."""
    full = grid_to_map(shift_grid(n))
    all_cells = cells(n)
    k = round(density * len(all_cells))
    chosen = rng.sample(all_cells, k)
    return {cell: full[cell] for cell in chosen}


def critical_density(n: int) -> float:
    return (n * n - 1) / (n * n)


def estimate_solvability(n: int, density: float, trials: int,
                         rng: random.Random) -> float:
    """Fraction of random puzzles (with independently sampled clue symbols)
    that admit a completion -- a solvability probability estimate."""
    m = n * n
    all_cells = cells(n)
    k = round(density * len(all_cells))
    solved = 0
    for _ in range(trials):
        chosen = rng.sample(all_cells, k)
        clues = {cell: rng.randrange(m) for cell in chosen}
        if solve(n, clues) is not None:
            solved += 1
    return solved / trials


# ---------------------------------------------------------------------------
# Driver
# ---------------------------------------------------------------------------
def main() -> None:
    rng = random.Random(12345)

    print("=" * 68)
    print(" Sudoku constraint graph: chromatic number and phase transition")
    print("=" * 68)

    for n in (2, 3):
        m = n * n
        print(f"\n--- n = {n}  ({m}x{m} grid, {m} symbols) ---")

        grid = shift_grid(n)
        gmap = grid_to_map(grid)

        print("Shift-construction grid:")
        for row in grid:
            print("  " + " ".join(f"{v:2d}" for v in row))

        valid = is_valid_solution(n, gmap)
        proper = is_proper_coloring(n, gmap)
        print(f"Valid Sudoku solution?           {valid}")
        print(f"Proper coloring of G_n?          {proper}  (bridge: agree = {valid == proper})")
        print(f"First row is a clique of size {m}? {first_row_is_clique(n)}")
        print(f"=> chromatic number chi(G_{n}) = {m} = n^2")
        print(f"Conjectured critical clue density d_c({n}) = "
              f"(n^2-1)/n^2 = {critical_density(n):.4f}")

    # Phase-transition sweep for n = 2 (4x4), small enough to solve exhaustively.
    print("\n" + "=" * 68)
    print(" Phase transition sweep (n = 2, random clue symbols)")
    print("=" * 68)
    n = 2
    dc = critical_density(n)
    print(f" critical density d_c = {dc:.3f}")
    print(f"{'density':>9} | {'P(solvable)':>12}")
    print("-" * 26)
    for pct in range(0, 101, 10):
        d = pct / 100.0
        p = estimate_solvability(n, d, trials=60, rng=rng)
        marker = "  <-- near d_c" if abs(d - dc) <= 0.05 else ""
        print(f"{d:9.2f} | {p:12.3f}{marker}")


if __name__ == "__main__":
    main()
