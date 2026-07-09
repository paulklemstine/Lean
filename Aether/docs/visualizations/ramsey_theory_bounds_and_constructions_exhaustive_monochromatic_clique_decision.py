from itertools import combinations
from typing import Callable


def has_mono_clique(n: int, adj: Callable[[int, int], bool], s: int, t: int) -> bool:
    """
    Decide whether a fixed 2-colouring `adj` of K_n contains a red K_s or a
    blue K_t. `adj(i, j)` is True for red edges, False for blue edges.

    Iterates over all C(n, s) candidate red cliques and all C(n, t) candidate
    blue cliques; worst case O(C(n, max(s,t)) * max(s,t)^2). This is the
    decision procedure that certifies the arrow relation n -> (s, t) for an
    explicit colouring, and (run over all colourings) the exhaustive verifier.
    """
    for subset in combinations(range(n), s):
        if all(adj(a, b) for a, b in combinations(subset, 2)):
            return True
    for subset in combinations(range(n), t):
        if all(not adj(a, b) for a, b in combinations(subset, 2)):
            return True
    return False
