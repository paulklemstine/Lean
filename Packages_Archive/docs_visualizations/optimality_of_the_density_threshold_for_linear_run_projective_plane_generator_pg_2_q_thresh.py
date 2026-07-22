from __future__ import annotations

from itertools import product
from typing import FrozenSet, List, Tuple

Point = int
Line = FrozenSet[Point]


def projective_plane(q: int) -> Tuple[List[Line], int]:
    """
    Generate the projective plane PG(2, q) over the prime field GF(q) (q prime),
    a Steiner system S(2, q+1, q^2+q+1) that SATURATES the density threshold
    m * C(q+1, 2) = C(q^2+q+1, 2).

    Points are 1-dimensional subspaces of GF(q)^3, represented by their
    normalized nonzero coordinate vectors (first nonzero entry equal to 1).
    Lines are the duals: a line is the set of points orthogonal to a fixed
    normalized vector. Each line contains exactly q+1 points, there are
    q^2+q+1 lines, and every pair of points lies on a unique line.

    Complexity: O(q^4) to test all point/line incidences; output has
    q^2 + q + 1 lines each of size q + 1.

    Returns (lines, number_of_points).
    """
    def normalize(v: Tuple[int, int, int]) -> Tuple[int, int, int]:
        for c in v:
            if c % q != 0:
                inv: int = pow(c % q, q - 2, q)  # Fermat inverse in GF(q)
                return tuple((inv * x) % q for x in v)  # type: ignore[return-value]
        return v

    reps: List[Tuple[int, int, int]] = []
    seen: set[Tuple[int, int, int]] = set()
    for v in product(range(q), repeat=3):
        if v == (0, 0, 0):
            continue
        nv = normalize(v)
        if nv not in seen:
            seen.add(nv)
            reps.append(nv)

    index = {v: i for i, v in enumerate(reps)}

    def dot(a: Tuple[int, int, int], b: Tuple[int, int, int]) -> int:
        return (a[0] * b[0] + a[1] * b[1] + a[2] * b[2]) % q

    lines: List[Line] = []
    for a in reps:
        line = frozenset(index[p] for p in reps if dot(a, p) == 0)
        lines.append(line)

    return lines, len(reps)
