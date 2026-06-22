from typing import FrozenSet, Iterable, List, Tuple
import itertools
from math import comb

Mat = Tuple[int, int, int, int]


def mat_mul(x: Mat, y: Mat, p: int) -> Mat:
    a, b, c, d = x
    e, f, g, h = y
    return ((a*e + b*g) % p, (a*f + b*h) % p,
            (c*e + d*g) % p, (c*f + d*h) % p)


def cayley_neighbors(S: List[Mat], A: FrozenSet[Mat], p: int) -> FrozenSet[Mat]:
    """Definition 4.1: N_S(A) = { a*s : a in A, s in S }."""
    return frozenset(mat_mul(a, s, p) for a in A for s in S)


def vertex_boundary(S: List[Mat], A: FrozenSet[Mat], p: int) -> FrozenSet[Mat]:
    """Definition 4.2: boundary = N_S(A) \\ A."""
    return cayley_neighbors(S, A, p) - A


def expansion_constant(group: FrozenSet[Mat], S: List[Mat], p: int) -> float:
    """Empirical vertex-expansion constant: min over nonempty A with
    2|A| <= |G| of |boundary(A)| / |A|  (Definition 4.3)."""
    elems = list(group)
    n = len(elems)
    best = float("inf")
    for k in range(1, n // 2 + 1):
        combos: Iterable
        if comb(n, k) <= 4000:
            combos = itertools.combinations(elems, k)
        else:
            import random
            combos = (tuple(random.sample(elems, k)) for _ in range(2000))
        for combo in combos:
            A = frozenset(combo)
            best = min(best, len(vertex_boundary(S, A, p)) / len(A))
    return best
