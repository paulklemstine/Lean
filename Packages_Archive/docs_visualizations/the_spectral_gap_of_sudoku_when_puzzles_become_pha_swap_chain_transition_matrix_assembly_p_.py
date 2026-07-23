from typing import Dict, List

Matrix = List[List[float]]
Graph = Dict[int, List[int]]


def swap_matrix(graph: Graph, c: float) -> Matrix:
    """Assemble the swap-chain transition matrix P = I - c*L on a move graph.

    P(x,x) = 1 - c*deg(x); P(x,y) = c if x~y; 0 otherwise.
    Choosing c <= 1/max_degree guarantees P is (doubly) stochastic.
    """
    verts = sorted(graph)
    idx = {v: i for i, v in enumerate(verts)}
    n = len(verts)
    P = [[0.0] * n for _ in range(n)]
    for v in verts:
        i = idx[v]
        P[i][i] = 1.0 - c * len(graph[v])
        for w in graph[v]:
            P[i][idx[w]] = c
    return P
