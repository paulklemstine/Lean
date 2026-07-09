from __future__ import annotations
from typing import Dict, Iterator, List, Set, Tuple


def dyck_paths(n: int) -> List[Tuple[int, ...]]:
    """Return every Dyck path of semilength n as a tuple over {+1, -1}."""
    out: List[Tuple[int, ...]] = []
    path: List[int] = []

    def go(h: int, u: int, d: int) -> None:
        if u == 0 and d == 0:
            out.append(tuple(path)); return
        if u > 0:
            path.append(1); go(h + 1, u - 1, d); path.pop()
        if d > 0 and h > 0:
            path.append(-1); go(h - 1, u, d - 1); path.pop()

    go(0, n, n)
    return out


def valleys(path: Tuple[int, ...]) -> int:
    """Count occurrences of a down-step followed by an up-step."""
    return sum(1 for a, b in zip(path, path[1:]) if a == -1 and b == 1)


def valley_multiplicity_histogram(n: int,
                                  covers: Dict[Tuple[int, ...], Set[Tuple[int, ...]]]
                                  ) -> Dict[int, int]:
    """Histogram I[n, k] = sum over lower endpoints x with val(x)=k of the
    size of the up-set {y : x <= y} in the order whose covers are given.

    ``covers[x]`` lists the elements that cover x.  The up-set of each x is
    computed by transitive closure (breadth-first reachability), and its size
    is the interval multiplicity w(x).  Endpoints are then bucketed by valley
    count, giving the refined interval count I[n, k].
    """
    def upset_size(x: Tuple[int, ...]) -> int:
        seen: Set[Tuple[int, ...]] = {x}
        stack: List[Tuple[int, ...]] = [x]
        while stack:
            cur = stack.pop()
            for nxt in covers.get(cur, ()):  # type: ignore[arg-type]
                if nxt not in seen:
                    seen.add(nxt); stack.append(nxt)
        return len(seen)

    hist: Dict[int, int] = {}
    for x in dyck_paths(n):
        k = valleys(x)
        hist[k] = hist.get(k, 0) + upset_size(x)
    return hist
