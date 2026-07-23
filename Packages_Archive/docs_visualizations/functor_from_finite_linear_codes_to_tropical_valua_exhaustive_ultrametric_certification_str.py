from itertools import product
from typing import List, Tuple

Vec = Tuple[int, ...]


def add2(x: Vec, y: Vec) -> Vec:
    return tuple((a + b) % 2 for a, b in zip(x, y))


def tprof(x: Vec) -> int:
    return max((i + 1 for i, a in enumerate(x) if a != 0), default=0)


def verify_ultrametric(n: int) -> Tuple[bool, bool]:
    """Exhaustively verify the strong triangle inequality and isosceles law
    for tprof over all binary vectors of length n. Complexity O(4^n * n)."""
    vs: List[Vec] = [tuple(b) for b in product((0, 1), repeat=n)]
    triangle = all(
        tprof(add2(x, y)) <= max(tprof(x), tprof(y)) for x in vs for y in vs
    )
    isosceles = all(
        tprof(add2(x, y)) == max(tprof(x), tprof(y))
        for x in vs for y in vs if tprof(x) != tprof(y)
    )
    return triangle, isosceles
