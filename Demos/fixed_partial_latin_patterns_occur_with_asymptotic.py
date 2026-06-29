"""
Numerical demonstrations for:

    "Densities of Fixed Partial Latin Patterns in Uniformly Random Latin Squares"

We verify, by exact enumeration for small orders n, the theorems:

  * prob_single_cell        : Pr[L contains {(r,c,s)}]            = 1/n
  * prob_rowfiber           : Pr[L contains a single-row pattern] = 1/(n)_k
  * singleRow_pattern_density : n^k / (n)_k -> 1
  * rowpattern_prob_mul_tendsto : Pr[...] * n^k -> 1

Here (n)_k = n*(n-1)*...*(n-k+1) is the descending factorial, and a
single-row partial Latin pattern of size k is a set of k triples (r,c,s)
all sharing the same row r, with distinct columns and distinct symbols.

We also illustrate the failure of exactness for two-dimensional patterns
by counting intercalates (2x2 Latin subsquares), whose expected count is
asymptotically n^2/4.

All functions are inlined and type-hinted. Pure standard library.
"""

from __future__ import annotations

from fractions import Fraction
from itertools import permutations
from typing import Iterator


# ---------------------------------------------------------------------------
# Core combinatorics
# ---------------------------------------------------------------------------

def desc_factorial(n: int, k: int) -> int:
    """Descending factorial (n)_k = n*(n-1)*...*(n-k+1); (n)_0 = 1."""
    result = 1
    for i in range(k):
        result *= (n - i)
    return result


def latin_squares(n: int) -> Iterator[tuple[tuple[int, ...], ...]]:
    """Yield every Latin square of order n as a tuple of n row-tuples.

    Backtracking: each row is a permutation of {0,...,n-1} that does not
    repeat a symbol in any column already filled above it.
    """
    all_rows: list[tuple[int, ...]] = list(permutations(range(n)))

    def extend(rows: list[tuple[int, ...]]) -> Iterator[tuple[tuple[int, ...], ...]]:
        if len(rows) == n:
            yield tuple(rows)
            return
        for cand in all_rows:
            ok = True
            for c in range(n):
                for prev in rows:
                    if prev[c] == cand[c]:
                        ok = False
                        break
                if not ok:
                    break
            if ok:
                rows.append(cand)
                yield from extend(rows)
                rows.pop()

    yield from extend([])


def contains_pattern(
    square: tuple[tuple[int, ...], ...],
    pattern: frozenset[tuple[int, int, int]],
) -> bool:
    """True iff square[r][c] == s for every (r, c, s) in pattern."""
    return all(square[r][c] == s for (r, c, s) in pattern)


# Cache the (small) enumerations so each order is built at most once.
_SQUARE_CACHE: dict[int, list[tuple[tuple[int, ...], ...]]] = {}


def all_latin_squares(n: int) -> list[tuple[tuple[int, ...], ...]]:
    """Return (and memoize) the full list of Latin squares of order n."""
    if n not in _SQUARE_CACHE:
        _SQUARE_CACHE[n] = list(latin_squares(n))
    return _SQUARE_CACHE[n]


def occurrence_probability(
    n: int,
    pattern: frozenset[tuple[int, int, int]],
) -> Fraction:
    """Exact Pr[L contains pattern] over the uniform measure on order-n squares."""
    squares = all_latin_squares(n)
    hits = sum(1 for sq in squares if contains_pattern(sq, pattern))
    return Fraction(hits, len(squares))


def count_intercalates(square: tuple[tuple[int, ...], ...]) -> int:
    """Number of intercalates (2x2 Latin subsquares) in the given square."""
    n = len(square)
    count = 0
    for r1 in range(n):
        for r2 in range(r1 + 1, n):
            for c1 in range(n):
                for c2 in range(c1 + 1, n):
                    a = square[r1][c1]
                    b = square[r1][c2]
                    c = square[r2][c1]
                    d = square[r2][c2]
                    if a == d and b == c and a != b:
                        count += 1
    return count


# ---------------------------------------------------------------------------
# Demonstrations
# ---------------------------------------------------------------------------

def demo_single_cell() -> None:
    print("=" * 70)
    print("Theorem prob_single_cell :  Pr[L contains {(r,c,s)}] = 1/n")
    print("=" * 70)
    for n in range(2, 5):
        pattern = frozenset({(0, 0, 0)})
        p = occurrence_probability(n, pattern)
        print(f"  n={n}:  Pr = {p}   expected 1/{n} = {Fraction(1, n)}   "
              f"[{'OK' if p == Fraction(1, n) else 'MISMATCH'}]")
    print()


def demo_single_row() -> None:
    print("=" * 70)
    print("Theorem prob_rowfiber :  Pr[single-row size-k pattern] = 1/(n)_k")
    print("=" * 70)
    for n in range(2, 5):
        for k in range(1, n + 1):
            # Single-row pattern in row 0: columns 0..k-1 carry symbols 0..k-1.
            pattern = frozenset({(0, c, c) for c in range(k)})
            p = occurrence_probability(n, pattern)
            expected = Fraction(1, desc_factorial(n, k))
            tag = "OK" if p == expected else "MISMATCH"
            print(f"  n={n}, k={k}:  Pr = {p!s:>12}   "
                  f"1/(n)_k = {expected!s:>12}   [{tag}]")
    print()


def demo_density() -> None:
    print("=" * 70)
    print("Lemma singleRow_pattern_density :  n^k/(n)_k -> 1  (here k=3)")
    print("Theorem rowpattern_prob_mul_tendsto :  Pr * n^k -> 1")
    print("=" * 70)
    k = 3
    for n in [3, 5, 10, 50, 100, 1000, 10000]:
        ratio = Fraction(n ** k, desc_factorial(n, k))
        print(f"  n={n:>6}:  n^k/(n)_k = {float(ratio):.8f}")
    print()


def demo_intercalates() -> None:
    print("=" * 70)
    print("Two-dimensional patterns: exactness FAILS (intercalates).")
    print("Mean intercalate count ~ n^2/4; a fixed intercalate is Theta(n^-2).")
    print("=" * 70)
    for n in range(2, 5):
        squares = all_latin_squares(n)
        sumc = sum(count_intercalates(sq) for sq in squares)
        mean = Fraction(sumc, len(squares))
        print(f"  n={n}:  mean #intercalates = {float(mean):.4f}   "
              f"n^2/4 = {n * n / 4:.4f}")

    # Fixed-intercalate occurrence probability, scaled by n^2 -> 1/4.
    print("\n  Fixed canonical intercalate {(0,0,0),(0,1,1),(1,0,1),(1,1,0)}:")
    inter = frozenset({(0, 0, 0), (0, 1, 1), (1, 0, 1), (1, 1, 0)})
    for n in range(2, 5):
        p = occurrence_probability(n, inter)
        print(f"    n={n}:  Pr = {p!s:>12}   Pr * n^2 = {float(p * n * n):.4f}   "
              f"(target 0.25 as n grows)")
    print()


def main() -> None:
    demo_single_cell()
    demo_single_row()
    demo_density()
    demo_intercalates()


if __name__ == "__main__":
    main()
