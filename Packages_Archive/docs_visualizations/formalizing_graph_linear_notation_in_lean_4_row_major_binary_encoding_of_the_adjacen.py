from itertools import product, combinations
from typing import List, Tuple

Matrix = Tuple[Tuple[int, ...], ...]

def adj_code(g: Matrix) -> int:
    """Read the adjacency matrix row-major as a base-2 integer:
       adjCode(G) = sum_{i,j} a_{ij} * 2^(i*n + j).  O(n^2) bit ops."""
    n = len(g)
    code = 0
    for i in range(n):
        for j in range(n):
            if g[i][j]:
                code += 1 << (i * n + j)
    return code
