from typing import Dict

def collatz(n: int) -> int:
    return n // 2 if n % 2 == 0 else 3 * n + 1

def tropical_stopping_times(window: int) -> Dict[int, float]:
    """Min-plus Bellman-Ford sweep computing sigma on {1,...,window}.

    Relaxation:  sigma(n) <- min(sigma(n), 1 + sigma(T(n))),  sigma(1)=0.
    Complexity:  O(V * E) worst case = O(V^2) on the single-successor graph,
    where V is the number of nodes reachable from the window."""
    inf = float("inf")
    nodes = set()
    for start in range(1, window + 1):
        x = start
        while x not in nodes:
            nodes.add(x)
            if x == 1:
                break
            x = collatz(x)
    sigma: Dict[int, float] = {v: (0.0 if v == 1 else inf) for v in nodes}
    changed = True
    while changed:
        changed = False
        for v in nodes:
            if v == 1:
                continue
            cand = 1 + sigma[collatz(v)]
            if cand < sigma[v]:
                sigma[v] = cand
                changed = True
    return {v: sigma[v] for v in range(1, window + 1)}
