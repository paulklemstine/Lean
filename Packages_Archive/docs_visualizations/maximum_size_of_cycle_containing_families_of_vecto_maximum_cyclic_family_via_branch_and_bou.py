from itertools import product
from typing import List, Tuple

Vector = Tuple[int, ...]


def max_cyclic_family(b: int, k: int,
                      good) -> Tuple[int, List[Vector]]:
    """Compute M_b(k) = max cyclic-family size, with a witness.

    `good(u, v) -> bool` is the goodness predicate (cycle-containing).  We build
    the goodness graph on all b^k vectors (edges = good pairs); a cyclic family
    is a clique, so M_b(k) is the clique number, found by branch-and-bound with
    a popcount upper-bound prune.  Exponential worst case; fine for small b, k.
    """
    vectors: List[Vector] = list(product(range(b), repeat=k))
    n = len(vectors)
    adj: List[int] = [0] * n
    for i in range(n):
        for j in range(i + 1, n):
            if good(vectors[i], vectors[j]):
                adj[i] |= 1 << j
                adj[j] |= 1 << i

    best: List[int] = []

    def expand(clique: List[int], cand: int) -> None:
        nonlocal best
        if cand == 0:
            if len(clique) > len(best):
                best = clique[:]
            return
        if len(clique) + bin(cand).count("1") <= len(best):
            return
        rem = cand
        while rem:
            low = rem & (-rem)
            v = low.bit_length() - 1
            rem ^= low
            cand ^= low
            expand(clique + [v], cand & adj[v])

    expand([], (1 << n) - 1)
    return len(best), [vectors[i] for i in best]
