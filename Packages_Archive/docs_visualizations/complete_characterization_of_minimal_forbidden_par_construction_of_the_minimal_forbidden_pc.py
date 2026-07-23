from itertools import combinations, product
from typing import List, Tuple

GridVertex = Tuple[Tuple[int, ...], Tuple[int, ...]]


def forbidden_minor(r: int, s: int) -> Tuple[List[GridVertex],
                                             List[Tuple[GridVertex, GridVertex]]]:
    """Construct the minimal forbidden pc-minor G_{r,s} = (P3^r [] Q_s) \\ {u,v}.

    P3^r has vertex set {0,1,2}^r (an r-dimensional grid of 3-position dials);
    Q_s has vertex set {0,1}^s. We delete the two antipodal P3^r-corners
    (all-0 and all-2) inside the same Q_s copy (w = all-0). Edges join vertices at
    grid-or-cube distance one. Requires r >= 2, s >= 1.
    Complexity: O(|V|^2) for the naive edge scan, |V| = 3^r * 2^s - 2.
    """
    grid = list(product(range(3), repeat=r))
    cube = list(product(range(2), repeat=s))
    w0 = tuple([0] * s)
    removed = {(tuple([0] * r), w0), (tuple([2] * r), w0)}
    verts: List[GridVertex] = [(g, w) for g in grid for w in cube
                               if (g, w) not in removed]

    def adj(p: GridVertex, q: GridVertex) -> bool:
        (g1, w1), (g2, w2) = p, q
        if w1 == w2:
            d = [i for i in range(r) if g1[i] != g2[i]]
            return len(d) == 1 and abs(g1[d[0]] - g2[d[0]]) == 1
        if g1 == g2:
            return sum(1 for i in range(s) if w1[i] != w2[i]) == 1
        return False

    edges = [(p, q) for p, q in combinations(verts, 2) if adj(p, q)]
    return verts, edges
