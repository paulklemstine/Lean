from math import comb
from typing import List, Sequence, Tuple

Point = Tuple[int, int]

def paths_between(src: Point, dst: Point) -> int:
    """Number of E/N lattice paths from src to dst (0 if dst not NE of src)."""
    dx, dy = dst[0] - src[0], dst[1] - src[1]
    if dx < 0 or dy < 0:
        return 0
    return comb(dx + dy, dy)

def bareiss_det(matrix: List[List[int]]) -> int:
    """Exact integer determinant via fraction-free Bareiss elimination."""
    M = [row[:] for row in matrix]
    n = len(M)
    sign = 1
    prev = 1
    for k in range(n - 1):
        if M[k][k] == 0:
            swap = next((r for r in range(k + 1, n) if M[r][k] != 0), None)
            if swap is None:
                return 0
            M[k], M[swap] = M[swap], M[k]
            sign = -sign
        for i in range(k + 1, n):
            for j in range(k + 1, n):
                M[i][j] = (M[i][j] * M[k][k] - M[i][k] * M[k][j]) // prev
        prev = M[k][k]
    return sign * M[-1][-1]

def lgv_determinant(sources: Sequence[Point], sinks: Sequence[Point]) -> int:
    """LGV signed count of non-intersecting path families."""
    M = [[paths_between(s, t) for t in sinks] for s in sources]
    return bareiss_det(M)

# Adjacent 2x2 base case: always 1.
def lgv_2x2_adjacent(n: int) -> int:
    return lgv_determinant([(0, 0), (0, 1)], [(n, 0), (n, 1)])
