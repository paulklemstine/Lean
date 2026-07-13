"""
Numerical demonstrations for
"The AllDifferent Satisfiability Threshold: An Enumerative-Order-Theoretic-Chromatic Chain."

The AllDifferent constraint asks that m "demands" (variables) receive pairwise-distinct
values from a pool of k "resources" (symbols). This script verifies, numerically and by
brute force, the sharp satisfiability threshold at the balance point m = k, its three
characterizations (enumerative, order-theoretic, chromatic), and the Sudoku facts:

  * the partition function equals the falling factorial and counts injective assignments;
  * it is positive iff m <= k and zero iff m > k (the sharp threshold);
  * satisfiability is monotone (down-closed) in the number of demands;
  * the complete graph K_m is k-colorable iff m <= k;
  * every Sudoku line sits exactly at the balance point m = k = n^2;
  * the cyclic square L(i,j) = i + j solves rows/columns but fails a box at order n = 2.

Self-contained: standard library only.
"""

from __future__ import annotations

from itertools import permutations, product
from math import factorial, prod
from typing import Callable, Iterable


# --------------------------------------------------------------------------- #
# The partition function (falling factorial)
# --------------------------------------------------------------------------- #
def partition_fn(k: int, m: int) -> int:
    """Number of injective assignments of m demands into k resources.

    Equals the falling factorial k^{underline m} = k (k-1) ... (k-m+1).
    Returns 0 when m > k (a factor of zero appears in the product).
    """
    if m == 0:
        return 1
    return prod(k - i for i in range(m))


def falling_factorial_via_factorials(k: int, m: int) -> int:
    """k!/(k-m)! for m <= k, else 0 -- an independent formula for cross-checking."""
    if m > k:
        return 0
    return factorial(k) // factorial(k - m)


def count_injections_bruteforce(k: int, m: int) -> int:
    """Brute-force count of injective maps {0,...,m-1} -> {0,...,k-1}."""
    total = 0
    for assignment in product(range(k), repeat=m):
        if len(set(assignment)) == m:
            total += 1
    return total


# --------------------------------------------------------------------------- #
# Threshold predicates
# --------------------------------------------------------------------------- #
def is_satisfiable(k: int, m: int) -> bool:
    """Sharp threshold: an AllDifferent block is satisfiable iff m <= k."""
    return partition_fn(k, m) > 0


def is_satisfiable_bruteforce(k: int, m: int) -> bool:
    """Existence of an injective assignment, checked by search."""
    for assignment in product(range(k), repeat=m):
        if len(set(assignment)) == m:
            return True
    return m == 0


# --------------------------------------------------------------------------- #
# Chromatic characterization
# --------------------------------------------------------------------------- #
def complete_graph_colorable(m: int, k: int) -> bool:
    """K_m is properly k-colorable iff m <= k (chromatic number of K_m is m)."""
    return m <= k


def complete_graph_colorable_bruteforce(m: int, k: int) -> bool:
    """Search for a proper k-coloring of K_m (all vertices mutually adjacent)."""
    for coloring in product(range(k), repeat=m):
        if len(set(coloring)) == m:  # all colors distinct == proper on K_m
            return True
    return m == 0


# --------------------------------------------------------------------------- #
# Cyclic square (Latin square) and Sudoku boxes
# --------------------------------------------------------------------------- #
def cyclic(n_mod: int, i: int, j: int) -> int:
    """The cyclic square L(i,j) = (i + j) mod N."""
    return (i + j) % n_mod


def is_all_different(values: Iterable[int]) -> bool:
    vals = list(values)
    return len(set(vals)) == len(vals)


def cyclic_rows_all_different(n_mod: int) -> bool:
    return all(is_all_different(cyclic(n_mod, i, j) for j in range(n_mod))
               for i in range(n_mod))


def cyclic_cols_all_different(n_mod: int) -> bool:
    return all(is_all_different(cyclic(n_mod, i, j) for i in range(n_mod))
               for j in range(n_mod))


def box_cells(n: int, box_row: int, box_col: int) -> list[tuple[int, int]]:
    """Cells of the (box_row, box_col) box in an order-n Sudoku (N = n^2)."""
    return [(box_row * n + r, box_col * n + c) for r in range(n) for c in range(n)]


def cyclic_box_all_different(n: int, box_row: int, box_col: int) -> bool:
    n_mod = n * n
    return is_all_different(cyclic(n_mod, i, j) for (i, j) in box_cells(n, box_row, box_col))


# --------------------------------------------------------------------------- #
# Demonstrations
# --------------------------------------------------------------------------- #
def demo_enumerative_identity() -> None:
    print("=" * 70)
    print("1. Enumerative identity: partition function counts injections")
    print("=" * 70)
    print(f"{'k':>3} {'m':>3} {'formula':>10} {'k!/(k-m)!':>12} {'bruteforce':>12}")
    for k in range(6):
        for m in range(k + 3):
            pf = partition_fn(k, m)
            ff = falling_factorial_via_factorials(k, m)
            bf = count_injections_bruteforce(k, m)
            assert pf == ff == bf, (k, m, pf, ff, bf)
            print(f"{k:>3} {m:>3} {pf:>10} {ff:>12} {bf:>12}")
    print("All three agree.\n")


def demo_sharp_threshold() -> None:
    print("=" * 70)
    print("2. Sharp threshold and order parameter: positive iff m <= k")
    print("=" * 70)
    for k in [3, 4, 5]:
        print(f"k = {k}:")
        for m in range(k + 3):
            pf = partition_fn(k, m)
            sat = is_satisfiable(k, m)
            assert sat == is_satisfiable_bruteforce(k, m)
            assert (pf > 0) == (m <= k)
            marker = "  <-- balance point" if m == k else ""
            print(f"   m={m:>2}: Z={pf:>6}  satisfiable={sat}{marker}")
        print()


def demo_downclosure() -> None:
    print("=" * 70)
    print("3. Order-theoretic skeleton: satisfiability is monotone (down-closed)")
    print("=" * 70)
    k = 5
    for m in range(k + 3):
        if is_satisfiable(k, m):
            ok = all(is_satisfiable(k, mp) for mp in range(m + 1))
            assert ok
            print(f"   k={k}, m={m} satisfiable  =>  all m' <= {m} satisfiable: {ok}")
    print()


def demo_chromatic() -> None:
    print("=" * 70)
    print("4. Chromatic bridge: K_m is k-colorable iff m <= k")
    print("=" * 70)
    print(f"{'m':>3} {'k':>3} {'closed-form':>12} {'bruteforce':>12}")
    for m in range(5):
        for k in range(5):
            cf = complete_graph_colorable(m, k)
            bf = complete_graph_colorable_bruteforce(m, k)
            assert cf == bf, (m, k, cf, bf)
            print(f"{m:>3} {k:>3} {str(cf):>12} {str(bf):>12}")
    print("Chromatic number of K_m equals m in every case above.\n")


def demo_sudoku_line() -> None:
    print("=" * 70)
    print("5. Sudoku line sits exactly at the balance point m = k = n^2")
    print("=" * 70)
    for n in [2, 3]:
        k = n * n
        at = partition_fn(k, k)
        above = partition_fn(k, k + 1)
        assert at == factorial(k) and at > 0 and above == 0
        print(f"   order n={n}: line has m=k={k};  Z={at} (= {k}!),  Z(k,k+1)={above}")
    print()


def demo_cyclic_box_failure() -> None:
    print("=" * 70)
    print("6. Cyclic square solves rows/columns but fails a box (order n = 2)")
    print("=" * 70)
    n = 2
    n_mod = n * n
    print(f"   rows all-different:    {cyclic_rows_all_different(n_mod)}")
    print(f"   columns all-different: {cyclic_cols_all_different(n_mod)}")
    assert cyclic_rows_all_different(n_mod) and cyclic_cols_all_different(n_mod)
    box_ok = cyclic_box_all_different(n, 0, 0)
    print(f"   top-left box all-different: {box_ok}")
    assert not box_ok
    print(f"   witness: L(0,1) = {cyclic(n_mod, 0, 1)}, "
          f"L(1,0) = {cyclic(n_mod, 1, 0)}  (same symbol, distinct cells)")
    print("   => box constraints are genuinely new.\n")


def main() -> None:
    demo_enumerative_identity()
    demo_sharp_threshold()
    demo_downclosure()
    demo_chromatic()
    demo_sudoku_line()
    demo_cyclic_box_failure()
    print("All demonstrations passed.")


if __name__ == "__main__":
    main()
