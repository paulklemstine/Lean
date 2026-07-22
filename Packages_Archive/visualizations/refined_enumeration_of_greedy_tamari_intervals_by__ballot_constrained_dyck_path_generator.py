from __future__ import annotations
from typing import Iterator, List, Tuple


def generate_dyck_paths(n: int) -> Iterator[Tuple[int, ...]]:
    """Lazily enumerate all Catalan-many Dyck paths of semilength n.

    Each path is a tuple over {+1, -1} with n up-steps and n down-steps whose
    prefix sums are all nonnegative.  The generator performs a depth-first
    prefix extension: at each position it may append an up-step (if any remain)
    or a down-step (if any remain and the current height is positive), which
    exactly enforces the ballot / nonnegativity condition.  Time is linear in
    the output size (Catalan_n paths, each of length 2n); space is O(n).
    """
    path: List[int] = []

    def extend(height: int, ups: int, downs: int) -> Iterator[Tuple[int, ...]]:
        if ups == 0 and downs == 0:
            yield tuple(path); return
        if ups > 0:
            path.append(1); yield from extend(height + 1, ups - 1, downs); path.pop()
        if downs > 0 and height > 0:
            path.append(-1); yield from extend(height - 1, ups, downs - 1); path.pop()

    yield from extend(0, n, n)
