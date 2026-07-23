from itertools import combinations
from math import comb
from typing import List, Tuple

Matrix = List[List[float]]

def is_rips_clique(dmat: Matrix, subset: Tuple[int, ...], eps: float) -> bool:
    return all(dmat[i][j] <= eps for i, j in combinations(subset, 2))

def clique_count(dmat: Matrix, m: int, eps: float) -> int:
    """Number of m-element Rips cliques at scale eps."""
    n: int = len(dmat)
    return sum(1 for s in combinations(range(n), m)
               if is_rips_clique(dmat, s, eps))

def saturated(dmat: Matrix, m: int, eps: float) -> bool:
    """True iff cliqueCount(m, eps) = C(n, m) (= tropBirthSum <= eps)."""
    return clique_count(dmat, m, eps) == comb(len(dmat), m)
