from itertools import permutations
from typing import List, Tuple

Square = Tuple[Tuple[int, ...], ...]


def enumerate_latin_squares(n: int) -> List[Square]:
    """Return every Latin square of order n, each produced exactly once,
    by placing rows (permutations) that stay column-injective (backtracking)."""
    rows_all: List[Tuple[int, ...]] = list(permutations(range(n)))
    result: List[Square] = []
    current: List[Tuple[int, ...]] = []

    def column_compatible(row: Tuple[int, ...]) -> bool:
        for placed in current:
            for c in range(n):
                if placed[c] == row[c]:
                    return False
        return True

    def backtrack(depth: int) -> None:
        if depth == n:
            result.append(tuple(current))
            return
        for row in rows_all:
            if column_compatible(row):
                current.append(row)
                backtrack(depth + 1)
                current.pop()

    backtrack(0)
    return result
