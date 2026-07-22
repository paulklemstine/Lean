from typing import List, Optional, Tuple

Table = List[List[int]]
Frame = Tuple[int, int, int, int]


def basic_move(m: int, n: int, frame: Frame) -> Table:
    """B(i,i',j,j') = e(i,j') + e(i',j) - e(i,j) - e(i',j')."""
    i, ip, j, jp = frame
    B = [[0] * n for _ in range(m)]
    B[i][jp] += 1
    B[ip][j] += 1
    B[i][j] -= 1
    B[ip][jp] -= 1
    return B


def find_good_frame(u: Table, v: Table) -> Optional[Frame]:
    """Three-stage sign-pattern pigeonhole; None iff u == v."""
    m, n = len(u), len(u[0])
    d = [[u[i][j] - v[i][j] for j in range(n)] for i in range(m)]
    cell = next(((i, j) for i in range(m) for j in range(n) if d[i][j] > 0), None)
    if cell is None:
        return None
    i, j = cell
    jp = next(jj for jj in range(n) if d[i][jj] < 0)
    ip = next(ii for ii in range(m) if d[ii][jp] > 0)
    return (i, ip, j, jp)


def connect(u: Table, v: Table) -> List[Table]:
    """Constructive Fundamental Theorem of Markov Bases: a non-negative walk
    of basic 2x2 moves from u to v (equal-margin, non-negative tables)."""
    m, n = len(u), len(u[0])
    path: List[Table] = [u]
    cur = [row[:] for row in u]
    while cur != v:
        frame = find_good_frame(cur, v)
        assert frame is not None
        B = basic_move(m, n, frame)
        cur = [[cur[i][j] + B[i][j] for j in range(n)] for i in range(m)]
        path.append(cur)
    return path
