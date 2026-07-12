"""
Numerical demonstrations of the AllDifferent constraint-satisfaction threshold.

This module reproduces, with concrete numbers, the main results of
"The Constraint-Satisfaction Threshold of Sudoku: A Sharp Phase Transition":

  * The pigeonhole equivalence      SAT(m, k)  <=>  m <= k
  * The sharp transition            critical cell count m_c(k) = k + 1
  * The partition function          Z(m, k) = falling factorial k^{underline m}
  * The critical density            SAT(m, k) <=> m / k <= 1  (k > 0)
  * Sudoku at criticality           every order-n line has m = k = n^2
  * The colouring bridge            K_m is k-colourable <=> m <= k
  * The cyclic Latin square          L(i, j) = (i + j) mod N solves rows & columns

All functions are self-contained and use only the standard library.
"""

from __future__ import annotations

from itertools import permutations
from typing import Callable, Iterator, List, Optional, Tuple


# ---------------------------------------------------------------------------
# 1. The AllDifferent atom and the pigeonhole equivalence
# ---------------------------------------------------------------------------

def all_diff_sat(m: int, k: int) -> bool:
    """Return True iff a block of m cells is satisfiable over k symbols.

    By the pigeonhole equivalence this is exactly m <= k. We also verify the
    claim constructively for small inputs by exhibiting/searching an injection.
    """
    return m <= k


def witness_injection(m: int, k: int) -> Optional[List[int]]:
    """Return an explicit injective assignment [0..m) -> [0..k), or None.

    When m <= k the identity inclusion i |-> i is injective, matching the
    constructive direction of the pigeonhole equivalence.
    """
    if m <= k:
        return list(range(m))  # i |-> i is injective into [0, k)
    return None


def brute_force_sat(m: int, k: int) -> bool:
    """Independently confirm satisfiability by searching all assignments.

    Exponential; used only as a cross-check that all_diff_sat is correct.
    """
    if m == 0:
        return True
    for assignment in _all_assignments(m, k):
        if len(set(assignment)) == m:
            return True
    return False


def _all_assignments(m: int, k: int) -> Iterator[Tuple[int, ...]]:
    """Yield every function [0..m) -> [0..k) as an m-tuple of symbols."""
    if m == 0:
        yield ()
        return
    for head in range(k):
        for tail in _all_assignments(m - 1, k):
            yield (head, *tail)


# ---------------------------------------------------------------------------
# 2. The sharp phase transition
# ---------------------------------------------------------------------------

def critical_cell_count(k: int) -> int:
    """The first block size at which satisfiability fails: m_c(k) = k + 1."""
    return k + 1


def satisfiable_region(k: int) -> List[int]:
    """The down-set of satisfiable block sizes: exactly {0, 1, ..., k}."""
    return list(range(k + 1))


# ---------------------------------------------------------------------------
# 3. The partition function (falling factorial)
# ---------------------------------------------------------------------------

def num_proper(m: int, k: int) -> int:
    """Number of proper (injective) assignments: falling factorial k^{under m}.

    Equals k * (k-1) * ... * (k-m+1); zero as soon as m > k.
    """
    result = 1
    for i in range(m):
        result *= (k - i)
        if result <= 0:
            return 0
    return result


# ---------------------------------------------------------------------------
# 4. Constraint density
# ---------------------------------------------------------------------------

def density(m: int, k: int) -> float:
    """Constraint density m / k (requires k > 0)."""
    if k <= 0:
        raise ValueError("density requires a positive alphabet size k")
    return m / k


# ---------------------------------------------------------------------------
# 5. Sudoku specialisation
# ---------------------------------------------------------------------------

def sudoku_line_size(n: int) -> int:
    """An order-n Sudoku has n^2 cells per line drawn from n^2 symbols."""
    return n * n


def sudoku_line_at_criticality(n: int) -> bool:
    """Confirm every order-n Sudoku line sits at m = k = n^2 (critical)."""
    m = sudoku_line_size(n)
    k = sudoku_line_size(n)
    return all_diff_sat(m, k) and not all_diff_sat(m + 1, k)


def forced_collision(f: List[int], k: int) -> Optional[Tuple[int, int]]:
    """If len(f) > k, return a colliding pair of indices (pigeonhole)."""
    seen: dict[int, int] = {}
    for i, val in enumerate(f):
        if val in seen:
            return (seen[val], i)
        seen[val] = i
    return None


# ---------------------------------------------------------------------------
# 6. The colouring bridge: chromatic number of the complete graph
# ---------------------------------------------------------------------------

def complete_graph_colorable(m: int, k: int) -> bool:
    """K_m is k-colourable iff m <= k (chi(K_m) = m)."""
    return m <= k


# ---------------------------------------------------------------------------
# 7. The cyclic Latin square L(i, j) = (i + j) mod N
# ---------------------------------------------------------------------------

def cyclic_latin(n_size: int) -> List[List[int]]:
    """Build the N x N cyclic Latin square L(i, j) = (i + j) mod N."""
    return [[(i + j) % n_size for j in range(n_size)] for i in range(n_size)]


def is_latin_square(grid: List[List[int]]) -> bool:
    """Check that every row and every column is a permutation of 0..N-1."""
    n_size = len(grid)
    full = set(range(n_size))
    rows_ok = all(set(row) == full for row in grid)
    cols_ok = all({grid[i][j] for i in range(n_size)} == full for j in range(n_size))
    return rows_ok and cols_ok


def boxes_ok(grid: List[List[int]], n: int) -> bool:
    """Check the n^2 boxes of an order-n grid (side N = n^2) are all-different."""
    side = n * n
    if len(grid) != side:
        raise ValueError("grid side must be n^2")
    full = set(range(side))
    for br in range(0, side, n):
        for bc in range(0, side, n):
            box = {grid[br + di][bc + dj] for di in range(n) for dj in range(n)}
            if box != full:
                return False
    return True


# ---------------------------------------------------------------------------
# Driver
# ---------------------------------------------------------------------------

def main() -> None:
    print("=" * 68)
    print("The AllDifferent Constraint-Satisfaction Threshold")
    print("=" * 68)

    print("\n[1] Pigeonhole equivalence  SAT(m,k) <=> m <= k")
    for (m, k) in [(3, 5), (5, 5), (6, 5), (0, 4), (2, 0)]:
        fast = all_diff_sat(m, k)
        slow = brute_force_sat(m, k)
        assert fast == slow, "cross-check failed"
        print(f"    m={m:2d}, k={k:2d}:  SAT = {fast!s:5s}  (brute force agrees)")

    print("\n[2] Sharp transition: critical cell count and down-set")
    for k in [3, 5, 9]:
        print(f"    k={k}:  m_c = {critical_cell_count(k)},  "
              f"satisfiable region = {satisfiable_region(k)}")

    print("\n[3] Partition function Z(m,k) = falling factorial")
    for (m, k) in [(9, 9), (10, 9), (4, 4), (5, 4), (0, 7)]:
        print(f"    Z({m:2d},{k:2d}) = {num_proper(m, k)}")
    assert num_proper(9, 9) == 362880, "9! mismatch"
    assert num_proper(10, 9) == 0, "supercritical collapse mismatch"
    print("    -> Z(9,9) = 9! = 362880 at criticality; Z(10,9) = 0 collapse.")

    print("\n[4] Critical density = 1")
    for (m, k) in [(8, 9), (9, 9), (10, 9)]:
        d = density(m, k)
        print(f"    rho({m},{k}) = {d:.4f}  ->  SAT = {d <= 1.0}")

    print("\n[5] Sudoku sits exactly at criticality (m = k = n^2)")
    for n in [2, 3, 4]:
        s = sudoku_line_size(n)
        print(f"    order n={n}:  line size = {s},  "
              f"critical = {sudoku_line_at_criticality(n)}")

    print("\n[6] Forced collision above threshold (pigeonhole certificate)")
    bad = [0, 3, 1, 3, 2]  # 5 cells, symbols in {0..3}: must repeat
    pair = forced_collision(bad, 4)
    print(f"    assignment {bad} over k=4 symbols: collision at indices {pair}")

    print("\n[7] Colouring bridge: K_m is k-colourable iff m <= k")
    for (m, k) in [(4, 5), (5, 5), (6, 5)]:
        print(f"    K_{m} is {k}-colourable: {complete_graph_colorable(m, k)}")

    print("\n[8] Cyclic Latin square L(i,j) = (i+j) mod N solves rows & columns")
    grid = cyclic_latin(4)
    for row in grid:
        print("       ", row)
    print(f"    is a Latin square (rows & cols OK): {is_latin_square(grid)}")
    # For order n=2 (N=4) the cyclic square fails the box constraint:
    print(f"    order-2 boxes all-different: {boxes_ok(grid, 2)}  "
          "(boxes are independent demands)")

    print("\nAll numerical checks passed.")


if __name__ == "__main__":
    main()
