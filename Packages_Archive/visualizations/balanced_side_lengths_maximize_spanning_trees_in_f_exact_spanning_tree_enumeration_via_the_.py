from fractions import Fraction
from typing import Dict, List, Sequence, Tuple
import itertools


def spanning_tree_count(sides: Sequence[int]) -> int:
    """Exact number of spanning trees of the free-boundary product grid
    P_{sides[0]} x ... x P_{sides[-1]} via the Matrix-Tree theorem."""
    verts: List[Tuple[int, ...]] = list(itertools.product(*[range(s) for s in sides]))
    index: Dict[Tuple[int, ...], int] = {v: i for i, v in enumerate(verts)}
    n: int = len(verts)
    lap: List[List[int]] = [[0] * n for _ in range(n)]
    for v in verts:
        i = index[v]
        for d in range(len(sides)):
            for step in (-1, 1):
                w = list(v)
                w[d] += step
                if 0 <= w[d] < sides[d]:
                    lap[i][i] += 1
                    lap[i][index[tuple(w)]] -= 1
    # delete last row/column, exact rational Gaussian elimination
    m: List[List[Fraction]] = [[Fraction(x) for x in row[:-1]] for row in lap[:-1]]
    size: int = len(m)
    det: Fraction = Fraction(1)
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
