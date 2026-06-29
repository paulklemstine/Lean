from typing import List, Optional, Tuple

Table = List[List[int]]
Move = Tuple[int, int, int, int]


def find_aligned_frame(u: Table, v: Table) -> Optional[Move]:
    """Three-stage sign-pattern pigeonhole; returns None iff u == v."""
    m, n = len(u), len(u[0])
    d = [[u[i][j] - v[i][j] for j in range(n)] for i in range(m)]
    pos = next(((i, j) for i in range(m) for j in range(n) if d[i][j] > 0), None)
    if pos is None:
        return None
    i, j = pos
    jp = next(jj for jj in range(n) if d[i][jj] < 0)
    ip = next(ii for ii in range(m) if d[ii][jp] > 0)
    assert i != ip and j != jp
    return (i, ip, j, jp)
