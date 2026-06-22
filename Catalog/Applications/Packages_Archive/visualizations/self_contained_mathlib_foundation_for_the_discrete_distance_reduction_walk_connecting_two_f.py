from typing import List, Tuple

Table = List[List[int]]

def basic_move(m: int, n: int, i: int, ip: int, j: int, jp: int) -> Table:
    B = [[0] * n for _ in range(m)]
    B[i][jp] += 1; B[ip][j] += 1; B[i][j] -= 1; B[ip][jp] -= 1
    return B

def add(u: Table, B: Table) -> Table:
    return [[u[i][j] + B[i][j] for j in range(len(u[0]))]
            for i in range(len(u))]

def distance(u: Table, v: Table) -> int:
    return sum(abs(u[i][j] - v[i][j])
               for i in range(len(u)) for j in range(len(u[0])))

def connect_fibers(u: Table, v: Table) -> List[Table]:
    walk: List[Table] = [u]
    cur = [row[:] for row in u]
    while cur != v:
        idx = find_aligned_move(cur, v)   # from the pigeonhole algorithm
        assert idx is not None
        i, ip, j, jp = idx
        cur = add(cur, basic_move(len(cur), len(cur[0]), i, ip, j, jp))
        assert all(x >= 0 for r in cur for x in r)
        walk.append(cur)
    return walk
