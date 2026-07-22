from typing import List, Tuple

Vertex = Tuple[int, int]
Edge = Tuple[Vertex, Vertex]

def build_extremal_witness(c: int, d: int) -> Tuple[List[Vertex], List[Edge], int]:
    """
    Construct the calibrated balanced complete bipartite witness K_{t,t}
    with t = 2(1+2c)d and return (vertices, edges, deletion_bound=c*d*n).
    """
    t: int = 2 * (1 + 2 * c) * d
    n: int = 2 * t
    side_a: List[Vertex] = [(0, i) for i in range(t)]
    side_b: List[Vertex] = [(1, j) for j in range(t)]
    edges: List[Edge] = [(a, b) for a in side_a for b in side_b]
    deletion_bound: int = c * d * n
    return side_a + side_b, edges, deletion_bound
