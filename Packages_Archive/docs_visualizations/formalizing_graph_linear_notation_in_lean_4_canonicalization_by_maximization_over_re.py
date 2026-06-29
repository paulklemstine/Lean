from itertools import permutations
from typing import Tuple

Matrix = Tuple[Tuple[int, ...], ...]
Perm = Tuple[int, ...]

def adj_code(g: Matrix) -> int:
    n = len(g)
    return sum((1 << (i * n + j))
               for i in range(n) for j in range(n) if g[i][j])

def permute_graph(sigma: Perm, g: Matrix) -> Matrix:
    n = len(g)
    return tuple(tuple(g[sigma[i]][sigma[j]] for j in range(n)) for i in range(n))

def gln(g: Matrix) -> Tuple[int, Perm]:
    """Graph linear notation: maximum adjCode over all n! relabelings.
       Returns (gln value, a maximizing permutation). O(n! * n^2)."""
    n = len(g)
    best_code, best_perm = -1, tuple(range(n))
    for sigma in permutations(range(n)):
        c = adj_code(permute_graph(sigma, g))
        if c > best_code:
            best_code, best_perm = c, sigma
    return best_code, best_perm
