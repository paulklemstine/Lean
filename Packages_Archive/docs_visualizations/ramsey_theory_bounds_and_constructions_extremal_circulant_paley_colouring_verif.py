from itertools import combinations
from typing import List, Set, Tuple

def circulant_adj(n: int, diffs: Set[int]) -> List[List[bool]]:
    """Adjacency matrix of the circulant graph on Z/n with difference set diffs."""
    adj = [[False] * n for _ in range(n)]
    for a in range(n):
        for b in range(n):
            if a != b and ((a - b) % n in diffs or (b - a) % n in diffs):
                adj[a][b] = True
    return adj

def has_clique(adj: List[List[bool]], size: int) -> bool:
    """True iff the graph given by adj contains a clique of the given size."""
    n = len(adj)
    for verts in combinations(range(n), size):
        if all(adj[u][v] for u, v in combinations(verts, 2)):
            return True
    return False

def verify_extremal(n: int, diffs: Set[int], clique_size: int) -> bool:
    """
    Certify that the circulant colouring on Z/n (red = diffs) has no red and
    no blue clique of clique_size, i.e. it witnesses R(clique_size,clique_size) > n.
    """
    red = circulant_adj(n, diffs)
    blue = [[(i != j) and not red[i][j] for j in range(n)] for i in range(n)]
    return not has_clique(red, clique_size) and not has_clique(blue, clique_size)
