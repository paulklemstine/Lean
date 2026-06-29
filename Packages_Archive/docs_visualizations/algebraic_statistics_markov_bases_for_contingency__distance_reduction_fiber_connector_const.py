from typing import List, Optional, Tuple

Table = List[List[int]]
Move = Tuple[int, int, int, int]


def l1_distance(u: Table, v: Table) -> int:
    m, n = len(u), len(u[0])
    return sum(abs(u[i][j] - v[i][j]) for i in range(m) for j in range(n))


def apply_move(u: Table, mv: Move) -> Table:
    i, ip, j, jp = mv
    w = [r[:] for r in u]
    w[i][jp] += 1; w[ip][j] += 1; w[i][j] -= 1; w[ip][jp] -= 1
    return w


def connect(u: Table, v: Table, find) -> List[Move]:
    """`find` is find_aligned_frame; returns the connecting list of basic moves."""
    moves: List[Move] = []
    cur = [r[:] for r in u]
    while cur != v:
        frame = find(cur, v)
        assert frame is not None
        cur = apply_move(cur, frame)
        moves.append(frame)
    return moves
