import random
from collections import deque
from typing import Dict, List, Set, Tuple

def _derivable(edges: Set[Tuple[int, int]], a: int, b: int) -> bool:
    adj: Dict[int, List[int]] = {}
    for x, y in edges:
        adj.setdefault(x, []).append(y)
    seen = {a}; q = deque([a])
    while q:
        x = q.popleft()
        for y in adj.get(x, ()):
            if y not in seen:
                seen.add(y); q.append(y)
    return b in seen

def estimate_threshold(n: int, trials: int = 200, tol: float = 1e-3,
                       seed: int = 0) -> float:
    """Bisection estimate of the critical density p* where P[0 derives n-1] = 1/2.

    Valid because derivability is MONOTONE in the edge set (Theorem 3.2), so the
    empirical probability is increasing in p and the 1/2-crossover is unique."""
    rng = random.Random(seed)
    def prob(p: float) -> float:
        hits = 0
        for _ in range(trials):
            edges = {(a, b) for a in range(n) for b in range(n)
                     if a != b and rng.random() < p}
            if _derivable(edges, 0, n - 1):
                hits += 1
        return hits / trials
    lo, hi = 0.0, 1.0
    while hi - lo > tol:
        mid = (lo + hi) / 2
        if prob(mid) < 0.5:
            lo = mid
        else:
            hi = mid
    return (lo + hi) / 2
