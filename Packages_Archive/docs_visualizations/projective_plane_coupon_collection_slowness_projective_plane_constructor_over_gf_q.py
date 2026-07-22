from itertools import combinations
from typing import List, Set, Tuple


def projective_points(q: int) -> List[Tuple[int, int, int]]:
    """Normalized representatives of the 1-d subspaces of GF(q)^3 (q prime)."""
    pts: List[Tuple[int, int, int]] = []
    for x in range(q):
        for y in range(q):
            for z in range(q):
                if (x, y, z) == (0, 0, 0):
                    continue
                v = (x, y, z)
                inv = 1
                for c in v:
                    if c % q != 0:
                        inv = pow(c, q - 2, q) if q > 2 else 1
                        break
                nv = tuple((inv * a) % q for a in v)
                if nv not in pts:
                    pts.append(nv)  # type: ignore[arg-type]
    return pts


def projective_lines(q: int) -> Tuple[List[Set[int]], int]:
    """Return (lines, n) for the projective plane of order q (q prime)."""
    pts = projective_points(q)
    index = {p: i for i, p in enumerate(pts)}
    lines = set()
    for (a, b, c) in pts:
        line = frozenset(
            i for p, i in index.items()
            if (a * p[0] + b * p[1] + c * p[2]) % q == 0
        )
        lines.add(line)
    return [set(l) for l in lines], len(pts)
