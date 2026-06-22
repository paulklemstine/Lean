from typing import List, Optional, Tuple

Table = List[List[int]]

def find_aligned_move(u: Table, v: Table) -> Optional[Tuple[int, int, int, int]]:
    """Return (i, i', j, j') aligned with sign(u - v); None iff u == v."""
    m, n = len(u), len(u[0])
    d = [[u[i][j] - v[i][j] for j in range(n)] for i in range(m)]
    surplus = next(((i, j) for i in range(m) for j in range(n)
                    if d[i][j] > 0), None)
    if surplus is None:
        return None
    i, j = surplus
    jp = next(jj for jj in range(n) if d[i][jj] < 0)
    ip = next(ii for ii in range(m) if d[ii][jp] > 0)
    return (i, ip, j, jp)
