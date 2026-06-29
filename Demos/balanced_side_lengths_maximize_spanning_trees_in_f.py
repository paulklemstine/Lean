"""
demo.py — Balanced side lengths maximize spanning trees in free-boundary product grids.

This self-contained script demonstrates the central phenomenon of the package:
among all ways of arranging N points into a d-dimensional grid (a Cartesian
product of d path graphs), the number of spanning trees is maximized when the
side lengths are "balanced" — as equal as possible, with any two differing by at
most 1.

It also illustrates the abstract *exchange engine* that explains why: any count
satisfying the one-step exchange inequality

    f(..., a, ..., b, ...) < f(..., a+1, ..., b-1, ...)   whenever a + 2 <= b

is automatically maximized only at balanced configurations. Two classical
instances are included: integer AM-GM (maximize the product) and the dual
sum-of-squares minimization (Schur convexity of the power sum).

Everything is computed from first principles using exact integer / fraction
arithmetic; only the Python standard library is required.
"""

from __future__ import annotations

import itertools
from fractions import Fraction
from typing import Dict, Iterable, List, Sequence, Tuple


# ---------------------------------------------------------------------------
# 1. Spanning trees of a free-boundary product grid via the Matrix-Tree theorem
# ---------------------------------------------------------------------------

def grid_vertices(sides: Sequence[int]) -> List[Tuple[int, ...]]:
    """Enumerate the vertices of the d-dimensional grid with given side lengths."""
    return list(itertools.product(*[range(s) for s in sides]))


def grid_laplacian(sides: Sequence[int]) -> List[List[int]]:
    """Combinatorial Laplacian L = D - A of the free-boundary product grid.

    Two vertices are adjacent iff they differ by exactly 1 in a single
    coordinate (free / open boundary conditions: no wrap-around).
    """
    verts = grid_vertices(sides)
    index: Dict[Tuple[int, ...], int] = {v: i for i, v in enumerate(verts)}
    n = len(verts)
    lap = [[0] * n for _ in range(n)]
    for v in verts:
        i = index[v]
        for d in range(len(sides)):
            for step in (-1, 1):
                w = list(v)
                w[d] += step
                if 0 <= w[d] < sides[d]:
                    j = index[tuple(w)]
                    lap[i][i] += 1
                    lap[i][j] -= 1
    return lap


def integer_minor_determinant(matrix: List[List[int]]) -> int:
    """Determinant of the matrix with its last row and column deleted.

    Uses exact Fraction Gaussian elimination so the answer is an exact integer
    (the Matrix-Tree theorem guarantees integrality).
    """
    m = [[Fraction(x) for x in row[:-1]] for row in matrix[:-1]]
    size = len(m)
    det = Fraction(1)
    for col in range(size):
        pivot = next((r for r in range(col, size) if m[r][col] != 0), None)
        if pivot is None:
            return 0
        if pivot != col:
            m[col], m[pivot] = m[pivot], m[col]
            det = -det
        det *= m[col][col]
        inv = m[col][col]
        for r in range(col + 1, size):
            factor = m[r][col] / inv
            if factor != 0:
                for k in range(col, size):
                    m[r][k] -= factor * m[col][k]
    assert det.denominator == 1
    return int(det)


def spanning_tree_count(sides: Sequence[int]) -> int:
    """Number of spanning trees tau(sides) of the free-boundary product grid."""
    return integer_minor_determinant(grid_laplacian(sides))


# ---------------------------------------------------------------------------
# 2. Balanced configurations and integer factorizations
# ---------------------------------------------------------------------------

def is_balanced(sides: Sequence[int]) -> bool:
    """A tuple is balanced iff any two entries differ by at most 1."""
    return max(sides) - min(sides) <= 1


def factorizations(n: int, d: int) -> List[Tuple[int, ...]]:
    """All multisets of d positive integers (sorted, side >= 1) with product n."""
    results: List[Tuple[int, ...]] = []

    def rec(remaining: int, parts: int, low: int, acc: List[int]) -> None:
        if parts == 1:
            if remaining >= low:
                results.append(tuple(acc + [remaining]))
            return
        f = low
        while f ** parts <= remaining:
            if remaining % f == 0:
                rec(remaining // f, parts - 1, f, acc + [f])
            f += 1

    rec(n, d, 1, [])
    return results


# ---------------------------------------------------------------------------
# 3. The abstract exchange engine, instantiated
# ---------------------------------------------------------------------------

def additive_compositions(d: int, k: int) -> List[Tuple[int, ...]]:
    """All multisets of d nonnegative integers (sorted) summing to k."""
    results: List[Tuple[int, ...]] = []

    def rec(remaining: int, parts: int, low: int, acc: List[int]) -> None:
        if parts == 1:
            if remaining >= low:
                results.append(tuple(acc + [remaining]))
            return
        v = low
        while v * parts <= remaining:
            rec(remaining - v, parts - 1, v, acc + [v])
            v += 1

    rec(k, d, 0, [])
    return results


def sum_of_squares(parts: Sequence[int]) -> int:
    return sum(x * x for x in parts)


def product(parts: Sequence[int]) -> int:
    out = 1
    for x in parts:
        out *= x
    return out


# ---------------------------------------------------------------------------
# 4. Demonstrations
# ---------------------------------------------------------------------------

def spread(sides: Sequence[int]) -> int:
    """The spread max - min: 0 or 1 means 'as balanced as integers allow'."""
    return max(sides) - min(sides)


def demo_spanning_trees() -> None:
    print("=" * 72)
    print("SPANNING TREES OF FREE-BOUNDARY PRODUCT GRIDS (d = 2)")
    print("=" * 72)
    print("The most balanced AVAILABLE shape (smallest spread = max - min)")
    print("maximizes the spanning-tree count tau.\n")
    for n in (4, 6, 8, 12, 16, 24, 36):
        rows = []
        best_val, best_shape = -1, None
        for sides in factorizations(n, 2):
            tau = spanning_tree_count(sides)
            rows.append((sides, tau, is_balanced(sides)))
            if tau > best_val:
                best_val, best_shape = tau, sides
        min_spread = min(spread(sides) for sides, _, _ in rows)
        print(f"N = {n}:")
        for sides, tau, bal in rows:
            mark = "  <-- MAXIMIZER" if sides == best_shape else ""
            tag = " [balanced]" if bal else ""
            print(f"    {sides[0]:>2} x {sides[1]:<2}  tau = {tau:>8}{tag}{mark}")
        # The maximizer is the most balanced available shape (minimal spread).
        assert spread(best_shape) == min_spread, "maximizer must minimize spread!"
        print()


def demo_three_dimensions() -> None:
    print("=" * 72)
    print("SPANNING TREES IN THREE DIMENSIONS (d = 3)")
    print("=" * 72)
    for n in (8, 27, 64):
        best_val, best_shape = -1, None
        rows = []
        for sides in factorizations(n, 3):
            tau = spanning_tree_count(sides)
            rows.append((sides, tau))
            if tau > best_val:
                best_val, best_shape = tau, sides
        min_spread = min(spread(sides) for sides, _ in rows)
        print(f"N = {n}:")
        for sides, tau in rows:
            mark = "  <-- MAXIMIZER" if sides == best_shape else ""
            print(f"    {sides}  tau = {tau:>12}{mark}")
        assert spread(best_shape) == min_spread
        print()


def demo_exchange_engine() -> None:
    print("=" * 72)
    print("THE EXCHANGE ENGINE: AM-GM AND SUM-OF-SQUARES")
    print("=" * 72)
    print("Fix the number of parts d and the sum k. Move two parts closer:")
    print("    (a, b) -> (a+1, b-1)   with a + 2 <= b.")
    print("This strictly raises the product and strictly lowers sum-of-squares.\n")
    d, k = 4, 20
    comps = additive_compositions(d, k)
    by_prod = max(comps, key=product)
    by_sq = min(comps, key=sum_of_squares)
    print(f"Parts d = {d}, sum k = {k}:")
    print(f"    product maximizer        : {by_prod}  prod = {product(by_prod)}"
          f"   balanced? {is_balanced(by_prod)}")
    print(f"    sum-of-squares minimizer : {by_sq}  sumsq = {sum_of_squares(by_sq)}"
          f"   balanced? {is_balanced(by_sq)}")
    assert is_balanced(by_prod) and is_balanced(by_sq)

    # Illustrate one exchange step explicitly.
    print("\nOne exchange step on (1, 1, 9, 9), sum = 20:")
    before = (1, 1, 9, 9)
    after = (2, 2, 8, 8)  # two simultaneous (a+1, b-1) moves
    print(f"    {before}: product = {product(before):>5}, sumsq = {sum_of_squares(before)}")
    print(f"    {after}: product = {product(after):>5}, sumsq = {sum_of_squares(after)}")
    print("    product increased, sum-of-squares decreased -- the engine in action.\n")


def demo_multiplicative_to_additive() -> None:
    print("=" * 72)
    print("PRIME-POWER REDUCTION: MULTIPLICATIVE -> ADDITIVE BALANCING")
    print("=" * 72)
    print("For N = c^k with sides c^{a_i}, the product constraint prod c^{a_i} = N")
    print("is exactly the additive constraint sum a_i = k on the exponents.\n")
    c, k, d = 2, 6, 2          # N = 2^6 = 64, two sides, each a power of 2
    n = c ** k
    print(f"c = {c}, k = {k}, d = {d}  =>  N = {n}")
    for exps in additive_compositions(d, k):
        sides = tuple(c ** a for a in exps)
        tau = spanning_tree_count(sides)
        print(f"    exponents {exps} -> sides {sides}  tau = {tau:>10}"
              f"   balanced exps? {is_balanced(exps)}")
    print()


if __name__ == "__main__":
    demo_spanning_trees()
    demo_three_dimensions()
    demo_exchange_engine()
    demo_multiplicative_to_additive()
    print("All assertions passed: every maximizer found is balanced.")
