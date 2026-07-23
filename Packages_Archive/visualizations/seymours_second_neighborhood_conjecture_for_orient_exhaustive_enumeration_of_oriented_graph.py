from itertools import product
from typing import List, Set, Tuple

Matrix = List[List[bool]]

def verify_ssnc(n: int) -> Tuple[int, bool]:
    """Exhaustively verify SSNC on all oriented graphs with n vertices.

    Enumerates 3^{C(n,2)} oriented graphs; returns (#graphs, all_ok).
    """
    pairs: List[Tuple[int, int]] = [(i, j) for i in range(n)
                                    for j in range(i + 1, n)]
    total: int = 0
    for choice in product((0, 1, 2), repeat=len(pairs)):
        total += 1
        arcs: Set[Tuple[int, int]] = set()
        for (i, j), c in zip(pairs, choice):
            if c == 1: arcs.add((i, j))
            elif c == 2: arcs.add((j, i))
        adj: Matrix = [[(u, v) in arcs for v in range(n)] for u in range(n)]
        found = False
        for v in range(n):
            first = {w for w in range(n) if adj[v][w]}
            two = set()
            for x in first:
                for w in range(n):
                    if adj[x][w]: two.add(w)
            second = {w for w in two if w != v and w not in first}
            if len(first) <= len(second):
                found = True
                break
        if not found:
            return total, False
    return total, True
