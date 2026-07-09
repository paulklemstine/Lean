from itertools import product
from typing import Callable, List, Optional, Tuple

Coloring = Callable[[int], int]

def find_schur_coloring(r: int, n: int) -> Optional[List[int]]:
    for tail in product(range(r), repeat=n - 1):
        assignment = (0,) + tail
        color = lambda k: assignment[k - 1]
        ok = all(
            not (color(x) == color(y) == color(x + y))
            for x in range(1, n + 1)
            for y in range(x, n + 1)
            if x + y <= n)
        if ok:
            return list(assignment)
    return None

def schur_number(r: int, upper_search: int = 20) -> int:
    best = 0
    for n in range(1, upper_search + 1):
        if find_schur_coloring(r, n) is not None:
            best = n
        else:
            break
    return best
