from fractions import Fraction
from itertools import permutations
from typing import Iterator


def desc_factorial(n: int, k: int) -> int:
    """Descending factorial (n)_k = n*(n-1)*...*(n-k+1); (n)_0 = 1."""
    result: int = 1
    for i in range(k):
        result *= (n - i)
    return result


def latin_squares(n: int) -> Iterator[tuple[tuple[int, ...], ...]]:
    """Backtracking enumeration of all Latin squares of order n."""
    all_rows: list[tuple[int, ...]] = list(permutations(range(n)))

    def extend(rows: list[tuple[int, ...]]) -> Iterator[tuple[tuple[int, ...], ...]]:
        if len(rows) == n:
            yield tuple(rows)
            return
        for cand in all_rows:
            if all(prev[c] != cand[c] for c in range(n) for prev in rows):
                rows.append(cand)
                yield from extend(rows)
                rows.pop()

    yield from extend([])


def single_row_probability(n: int, k: int) -> Fraction:
    """Exact Pr[L contains the size-k single-row pattern {(0,c,c): c<k}].

    Returns a Fraction that provably equals 1/(n)_k (Theorem prob_rowfiber).
    """
    pattern: frozenset[tuple[int, int, int]] = frozenset((0, c, c) for c in range(k))
    squares = list(latin_squares(n))
    hits: int = sum(
        1 for sq in squares if all(sq[r][c] == s for (r, c, s) in pattern)
    )
    return Fraction(hits, len(squares))
