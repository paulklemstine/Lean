from itertools import combinations
from typing import FrozenSet, List, Tuple

Vertex = Tuple[int, ...]
Semicube = Tuple[int, int]


def harmonic_even_test(pc: List[Vertex]) -> bool:
    """Decide harmonic-evenness (= opposite-semicube Helly property) via the
    triple condition.  Runs in O(n^3 * N) for N vertices and n coordinates."""
    n: int = len(pc[0])
    used: List[int] = [i for i in range(n) if len({v[i] for v in pc}) == 2]
    scs: List[Semicube] = [(i, b) for i in used for b in (0, 1)]
    S: dict = {s: frozenset(v for v in pc if v[s[0]] == s[1]) for s in scs}
    for a, b, c in combinations(scs, 3):
        if len({a[0], b[0], c[0]}) < 3:      # compatibility: distinct coords
            continue
        if not (S[a] & S[b]) or not (S[b] & S[c]) or not (S[a] & S[c]):
            continue                          # not pairwise-intersecting
        if not (S[a] & S[b] & S[c]):
            return False                      # bad triple -> not harmonic-even
    return True
