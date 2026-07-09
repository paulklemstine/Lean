from itertools import product
from typing import Callable, Dict, List, Tuple

Vector = Tuple[float, ...]
Lattice = Tuple[int, ...]

def _lattice_points(n: int, m: int) -> List[Lattice]:
    return [c for c in product(range(m + 1), repeat=n + 1) if sum(c) == m]

def _vertex(m: int, k: Lattice) -> Vector:
    return tuple(ki / m for ki in k)

def _descent(f: Callable[[Vector], Vector], v: Vector) -> int:
    fv = f(v)
    for i, vi in enumerate(v):
        if vi > 1e-15 and fv[i] <= vi + 1e-12:
            return i
    return max(range(len(v)), key=lambda i: v[i])

def _upward_cells_2d(m: int):
    cells = []
    for a in range(m + 1):
        for b in range(m + 1 - a):
            c = m - a - b
            if c >= 1:
                cells.append(((a + 1, b, c - 1), (a, b + 1, c - 1), (a, b, c)))
    return cells

def simplicial_fixed_point(f: Callable[[Vector], Vector], m: int) -> Tuple[Vector, float]:
    """Descent-coloring search for a fixed point of f on the 2-simplex at mesh 1/m."""
    pts = _lattice_points(2, m)
    color: Dict[Lattice, int] = {k: _descent(f, _vertex(m, k)) for k in pts}
    best, best_res = _vertex(m, pts[0]), float("inf")
    for cell in _upward_cells_2d(m):
        if {color[v] for v in cell} != {0, 1, 2}:
            continue
        center = tuple(sum(_vertex(m, v)[i] for v in cell) / 3 for i in range(3))
        fc = f(center)
        res = max(abs(fc[i] - center[i]) for i in range(3))
        if res < best_res:
            best_res, best = res, center
    return best, best_res

def fixed_point(f: Callable[[Vector], Vector], eps: float = 1e-3) -> Vector:
    m = 8
    while True:
        x, res = simplicial_fixed_point(f, m)
        if res <= eps or m > 8192:
            return x
        m *= 2
