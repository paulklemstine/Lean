from __future__ import annotations
import itertools
from typing import List, Tuple

def find_difference_set(q: int) -> List[int]:
    """Find a planar (Singer) difference set D of size q+1 in Z/n, n=q^2+q+1."""
    n: int = q * q + q + 1
    k: int = q + 1
    for combo in itertools.combinations(range(2, n), k - 2):
        d: List[int] = [0, 1] + list(combo)
        diffs = set()
        ok = True
        for a in d:
            for b in d:
                if a == b:
                    continue
                delta = (a - b) % n
                if delta in diffs:
                    ok = False
                    break
                diffs.add(delta)
            if not ok:
                break
        if ok and len(diffs) == k * (k - 1):
            return d
    raise RuntimeError(f"No difference set for q={q}")

def build_plane(q: int) -> Tuple[int, List[frozenset]]:
    """Return (n, lines): the n cyclic translates of a planar difference set."""
    n: int = q * q + q + 1
    d: List[int] = find_difference_set(q)
    lines = [frozenset((x + i) % n for x in d) for i in range(n)]
    return n, lines
