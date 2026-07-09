from itertools import permutations
from typing import List, Tuple

def max_mols_bruteforce(n: int) -> int:
    """Exhaustively compute the maximum size of a pairwise-orthogonal family of
    Italian squares of order n (feasible only for very small n)."""
    perms = list(permutations(range(n)))
    squares: List[List[List[int]]] = []

    def backtrack(rows: List[Tuple[int, ...]]) -> None:
        if len(rows) == n:
            squares.append([list(r) for r in rows])
            return
        for p in perms:
            if all(p[j] not in {rows[i][j] for i in range(len(rows))} for j in range(n)):
                backtrack(rows + [p])

    backtrack([])

    def orth(a: int, b: int) -> bool:
        seen = set()
        for i in range(n):
            for j in range(n):
                seen.add((squares[a][i][j], squares[b][i][j]))
        return len(seen) == n * n

    m = len(squares)
    adj = [[orth(a, b) for b in range(m)] for a in range(m)]
    best = 1 if m else 0

    def extend(clique: List[int], start: int) -> None:
        nonlocal best
        best = max(best, len(clique))
        for c in range(start, m):
            if all(adj[c][x] for x in clique):
                extend(clique + [c], c + 1)

    for s in range(m):
        extend([s], s + 1)
    return best
