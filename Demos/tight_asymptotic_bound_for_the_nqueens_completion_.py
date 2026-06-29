"""Numerical demonstrations for the n-queens completion results.

This module is fully self-contained (standard library only) and exercises the
three proved pillars of the n-queens completion framework:

  * Theorem `diagGraph_isFullSolution` / `exists_full_solution`:
        for gcd(n, 6) = 1 the toroidal slope-2 line  x |-> 2x + b  is a full,
        non-attacking n-queens solution for every offset b.
  * Theorem `single_queen_completable`:
        any single placed queen (r, c) is completed by choosing b = c - 2r.
  * Theorem `completion_relaxation` (bipartite Hall relaxation):
        a non-attacking arrangement Q with 5*|Q| <= n extends to a permutation
        placement with no new-old row/column/diagonal conflict.

Board model: cells are pairs (row, col) in (Z/nZ)^2.  Diagonals are the
ordinary, NON-wrapping chess diagonals, computed from the canonical
representatives 0..n-1 (matching the Lean definitions antiDiag/mainDiag).
"""

from __future__ import annotations

from itertools import combinations
from math import gcd
from typing import Dict, List, Optional, Set, Tuple

Cell = Tuple[int, int]  # (row, col), each in {0, ..., n-1}


# --------------------------------------------------------------------------- #
# Core board predicates (mirror the Lean definitions)
# --------------------------------------------------------------------------- #

def anti_diag(a: Cell) -> int:
    """Anti-diagonal index row + col (non-wrapping)."""
    return a[0] + a[1]


def main_diag(a: Cell) -> int:
    """Main-diagonal index row - col (non-wrapping)."""
    return a[0] - a[1]


def attacks(a: Cell, b: Cell) -> bool:
    """True iff two cells share a row, column, anti-diagonal or main-diagonal."""
    return (
        a[0] == b[0]
        or a[1] == b[1]
        or anti_diag(a) == anti_diag(b)
        or main_diag(a) == main_diag(b)
    )


def is_non_attacking(queens: Set[Cell]) -> bool:
    """True iff no two distinct queens attack each other."""
    return all(not attacks(a, b) for a, b in combinations(sorted(queens), 2))


def is_full_solution(queens: Set[Cell], n: int) -> bool:
    """True iff `queens` is a non-attacking set of exactly n cells."""
    return len(queens) == n and is_non_attacking(queens)


# --------------------------------------------------------------------------- #
# The toroidal slope-2 construction  (Algorithm A / B)
# --------------------------------------------------------------------------- #

def diag_graph(n: int, b: int) -> Set[Cell]:
    """The slope-2 toroidal line  { (x, (2x + b) mod n) : x in 0..n-1 }."""
    return {(x, (2 * x + b) % n) for x in range(n)}


def complete_single_queen(n: int, r: int, c: int) -> Set[Cell]:
    """A full solution through the prescribed queen (r, c): choose b = c - 2r."""
    b = (c - 2 * r) % n
    return diag_graph(n, b)


# --------------------------------------------------------------------------- #
# Hall-type repair of a sparse arrangement  (Algorithm C)
# --------------------------------------------------------------------------- #

def _augment(
    row: int,
    adj: Dict[int, List[int]],
    match_col: Dict[int, int],
    seen: Set[int],
) -> bool:
    """Kuhn's augmenting-path step for bipartite matching of rows to columns."""
    for col in adj[row]:
        if col in seen:
            continue
        seen.add(col)
        if col not in match_col or _augment(match_col[col], adj, match_col, seen):
            match_col[col] = row
            return True
    return False


def hall_repair(n: int, q: Set[Cell]) -> Optional[Set[Cell]]:
    """Extend a non-attacking Q (with 5|Q| <= n) to a permutation placement with
    no new-old row/column/diagonal conflict, via bipartite matching.

    Returns the full permutation placement, or None if the matching fails.
    """
    used_rows = {r for (r, _) in q}
    used_cols = {c for (_, c) in q}
    forbidden_anti = {anti_diag(p) for p in q}
    forbidden_main = {main_diag(p) for p in q}

    empty_rows = [r for r in range(n) if r not in used_rows]
    empty_cols = [c for c in range(n) if c not in used_cols]

    # An empty row may use an empty column iff the cell avoids every pre-placed
    # queen's diagonals (rows/columns are already disjoint from Q by construction).
    adj: Dict[int, List[int]] = {}
    for r in empty_rows:
        adj[r] = [
            c
            for c in empty_cols
            if (r + c) not in forbidden_anti and (r - c) not in forbidden_main
        ]

    match_col: Dict[int, int] = {}
    for r in empty_rows:
        if not _augment(r, adj, match_col, set()):
            return None

    placement: Set[Cell] = set(q)
    for c, r in match_col.items():
        placement.add((r, c))
    return placement


def no_new_old_conflict(placement: Set[Cell], q: Set[Cell]) -> bool:
    """Check the relaxation guarantee: no NEW queen attacks any OLD queen."""
    new = placement - q
    return all(not attacks(a, b) for a in new for b in q)


# --------------------------------------------------------------------------- #
# Demonstrations
# --------------------------------------------------------------------------- #

def demo_existence() -> None:
    print("=" * 70)
    print("1. Toroidal slope-2 solutions for gcd(n,6)=1  (exists_full_solution)")
    print("=" * 70)
    for n in range(1, 40):
        if gcd(n, 6) != 1:
            continue
        ok = all(is_full_solution(diag_graph(n, b), n) for b in range(n))
        flag = "OK" if ok else "FAIL"
        print(f"  n={n:2d}: diagGraph(b) is a full solution for all {n} offsets b -> {flag}")


def demo_counterexample_when_not_coprime() -> None:
    print()
    print("=" * 70)
    print("2. The gcd(n,6)=1 hypothesis is necessary for the slope-2 line")
    print("=" * 70)
    for n in [4, 6, 8, 9, 10]:
        good = [b for b in range(n) if is_full_solution(diag_graph(n, b), n)]
        print(f"  n={n:2d} (gcd(n,6)={gcd(n,6)}): offsets giving a full slope-2 solution = {good}")


def demo_single_queen() -> None:
    print()
    print("=" * 70)
    print("3. Single-queen completion  (single_queen_completable)")
    print("=" * 70)
    for n in [7, 11, 13, 25]:
        all_ok = True
        for r in range(n):
            for c in range(n):
                sol = complete_single_queen(n, r, c)
                if not (is_full_solution(sol, n) and (r, c) in sol):
                    all_ok = False
        print(f"  n={n:2d}: every one of the {n*n} cells completes to a full solution -> "
              f"{'OK' if all_ok else 'FAIL'}")


def demo_hall_repair() -> None:
    print()
    print("=" * 70)
    print("4. Hall repair of sparse arrangements  (completion_relaxation, 5|Q|<=n)")
    print("=" * 70)
    # Build a genuine non-attacking Q from a slope-2 line, then keep <= n/5 of it.
    for n in [25, 31, 37]:
        full = sorted(diag_graph(n, 0))
        k = n // 5
        q = set(full[:k])
        assert is_non_attacking(q) and 5 * len(q) <= n
        placement = hall_repair(n, q)
        if placement is None:
            print(f"  n={n:2d}: |Q|={k} -> matching FAILED")
            continue
        rows = {r for (r, _) in placement}
        cols = {c for (_, c) in placement}
        ok = (
            len(placement) == n
            and len(rows) == n
            and len(cols) == n
            and q <= placement
            and no_new_old_conflict(placement, q)
        )
        print(f"  n={n:2d}: |Q|={k:2d} extends to a permutation of {len(placement)} queens; "
              f"no new-old conflict -> {'OK' if ok else 'FAIL'}")


def demo_threshold_constants() -> None:
    print()
    print("=" * 70)
    print("5. The threshold landscape: 0.2 (proved) < 0.216 (conjectured) < 1/3")
    print("=" * 70)
    proved = 1 / 5
    conjectured = 27 / 125
    reachability = 1 / 3
    print(f"  proved Hall-repair density      = 1/5   = {proved:.6f}")
    print(f"  conjectured completion density  = 27/125= {conjectured:.6f}")
    print(f"  greedy reachability ceiling     = 1/3   = {reachability:.6f}")
    print(f"  ordering holds: {proved < conjectured < reachability}")


if __name__ == "__main__":
    demo_existence()
    demo_counterexample_when_not_coprime()
    demo_single_queen()
    demo_hall_repair()
    demo_threshold_constants()


"""Visualization: the toroidal slope-2 n-queens solution and the threshold landscape.

Generates two figures with matplotlib:
  (1) the board for n=13 with the slope-2 line x |-> (2x mod 13), shading the
      diagonals to show that no two queens share a row, column, or diagonal;
  (2) a bar chart of the three density constants 0.2 (proved Hall repair),
      0.216 (conjectured threshold), and 1/3 (greedy reachability ceiling).
"""

from __future__ import annotations

from math import gcd
from typing import List, Tuple

import matplotlib.pyplot as plt
import numpy as np


def diag_graph(n: int, b: int) -> List[Tuple[int, int]]:
    """Slope-2 toroidal solution { (x, (2x + b) mod n) }."""
    return [(x, (2 * x + b) % n) for x in range(n)]


def plot_board(n: int = 13, b: int = 0) -> None:
    assert gcd(n, 6) == 1, "slope-2 line is a solution only when gcd(n,6)=1"
    queens = diag_graph(n, b)
    fig, ax = plt.subplots(figsize=(6, 6))
    board = np.indices((n, n)).sum(axis=0) % 2
    ax.imshow(board, cmap="binary", alpha=0.15, origin="lower")
    rs, cs = zip(*queens)
    ax.scatter(cs, rs, s=320, marker="*", color="crimson", zorder=3,
               edgecolors="black", linewidths=0.5)
    ax.set_xticks(range(n))
    ax.set_yticks(range(n))
    ax.set_xlabel("column")
    ax.set_ylabel("row")
    ax.set_title(f"Toroidal slope-2 solution: n={n}, queen at (x, 2x+{b} mod {n})")
    ax.grid(True, color="gray", linewidth=0.3)
    fig.tight_layout()
    fig.savefig("nqueens_board.png", dpi=150)
    print("wrote nqueens_board.png")


def plot_threshold_landscape() -> None:
    labels = ["Proved Hall repair\n1/5 = 0.200",
              "Conjectured threshold\n27/125 = 0.216",
              "Reachability ceiling\n1/3 = 0.333"]
    values = [1 / 5, 27 / 125, 1 / 3]
    colors = ["#2a9d8f", "#e9c46a", "#e76f51"]
    fig, ax = plt.subplots(figsize=(7, 4))
    ax.bar(labels, values, color=colors, edgecolor="black")
    for i, v in enumerate(values):
        ax.text(i, v + 0.005, f"{v:.3f}", ha="center", fontweight="bold")
    ax.set_ylabel("density  qc(n)/n")
    ax.set_ylim(0, 0.40)
    ax.set_title("The n-queens completion threshold landscape")
    fig.tight_layout()
    fig.savefig("nqueens_threshold.png", dpi=150)
    print("wrote nqueens_threshold.png")


if __name__ == "__main__":
    plot_board()
    plot_threshold_landscape()
