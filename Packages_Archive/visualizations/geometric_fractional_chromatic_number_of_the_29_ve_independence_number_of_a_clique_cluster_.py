from fractions import Fraction
from typing import List, Tuple


def clique_cluster_independence(sizes: List[int]) -> Tuple[int, int, Fraction]:
    """For a disjoint union of cliques with the given sizes, the independence
    number equals the number of cliques (one vertex per clique). Returns
    (n, alpha, inverse_independence_ratio = n/alpha)."""
    n: int = sum(sizes)
    alpha: int = len(sizes)
    return n, alpha, Fraction(n, alpha)
