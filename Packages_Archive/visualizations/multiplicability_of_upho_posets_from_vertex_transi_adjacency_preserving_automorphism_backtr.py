from typing import Dict, List, Set, Tuple

Graph = Dict[int, Set[int]]
Perm = Tuple[int, ...]

def automorphisms(g: Graph) -> List[Perm]:
    """Enumerate all graph automorphisms by adjacency-preserving backtracking.

    Builds a candidate bijection vertex-by-vertex, pruning by (i) degree match and
    (ii) consistency of all adjacencies to already-assigned vertices.
    """
    n = len(g)
    verts = list(range(n))
    deg = {v: len(g[v]) for v in verts}
    result: List[Perm] = []
    image: List[int] = [-1] * n
    used = [False] * n

    def consistent(v: int, w: int) -> bool:
        if deg[v] != deg[w]:
            return False
        for u in range(v):
            if (u in g[v]) != (image[u] in g[w]):
                return False
        return True

    def backtrack(v: int) -> None:
        if v == n:
            result.append(tuple(image)); return
        for w in verts:
            if not used[w] and consistent(v, w):
                image[v] = w; used[w] = True
                backtrack(v + 1)
                used[w] = False; image[v] = -1

    backtrack(0)
    return result
