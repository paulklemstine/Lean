from math import comb
from fractions import Fraction
from typing import List, Tuple, FrozenSet


def build_pg2(q: int) -> Tuple[List[Tuple[int, int, int]], List[FrozenSet[int]]]:
    """Construct the projective plane PG(2, q) for a prime q.

    Points are normalized 1-dimensional subspaces of F_q^3; lines are the
    self-dual sets of point-indices orthogonal to a normal vector. Returns
    (points, lines) with |points| = |lines| = q^2 + q + 1.
    """
    points: List[Tuple[int, int, int]] = []
    seen = set()
    for a in range(q):
        for b in range(q):
            for c in range(q):
                v = (a, b, c)
                if v == (0, 0, 0):
                    continue
                for i in range(3):
                    if v[i] % q != 0:
                        inv = pow(v[i], q - 2, q)
                        nv = tuple((x * inv) % q for x in v)
                        break
                if nv not in seen:
                    seen.add(nv)
                    points.append(nv)
    lines: List[FrozenSet[int]] = []
    for normal in points:
        members = frozenset(
            idx for idx, p in enumerate(points)
            if sum(a * b for a, b in zip(normal, p)) % q == 0
        )
        lines.append(members)
    return points, lines
