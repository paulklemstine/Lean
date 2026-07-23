from typing import Callable, List

Dissimilarity = Callable[[int, int], float]


def candidate_scales(n: int, d: Dissimilarity) -> List[float]:
    """The finite candidate set {0} cup {d(a,b)}, sorted ascending."""
    scales = {0.0}
    for a in range(n):
        for b in range(n):
            scales.add(float(d(a, b)))
    return sorted(scales)


def connected_at(n: int, d: Dissimilarity, eps: float, x: int, y: int) -> bool:
    """Reachability in the Rips graph at scale eps via BFS."""
    if x == y:
        return True
    seen = {x}
    frontier = [x]
    while frontier:
        u = frontier.pop()
        for v in range(n):
            adj = u != v and (d(u, v) <= eps or d(v, u) <= eps)
            if adj and v not in seen:
                if v == y:
                    return True
                seen.add(v)
                frontier.append(v)
    return y in seen


def conn_threshold(n: int, d: Dissimilarity, x: int, y: int) -> float:
    """Least candidate scale at which x and y are connected."""
    for eps in candidate_scales(n, d):
        if connected_at(n, d, eps, x, y):
            return eps
    raise RuntimeError("unreachable: d(x,y) is always a connecting candidate")
