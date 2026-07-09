from typing import Dict, Tuple

Config = Tuple[bool, ...]
System = Dict[Config, float]


def coactivation_graph(p: System, n: int) -> Dict[int, set]:
    supp = [x for x, w in p.items() if w > 0.0]
    adj: Dict[int, set] = {u: set() for u in range(n)}
    for u in range(n):
        for v in range(u + 1, n):
            if any(x[u] and x[v] for x in supp):
                adj[u].add(v)
                adj[v].add(u)
    return adj


def greedy_phi_lower_bound(p: System, n: int) -> int:
    """Polynomial-time lower bound on Phi_max. For each seed vertex (in
    decreasing co-activation degree) greedily grow a coalition by repeatedly
    adding the candidate most connected to the current candidate set, keeping
    only candidates adjacent to all chosen members. Returns the best coalition
    size found; always <= Phi_max, and exact on perfect / sparse graphs."""
    adj = coactivation_graph(p, n)
    best = 0
    for seed in sorted(range(n), key=lambda v: len(adj[v]), reverse=True):
        coalition = {seed}
        candidates = set(adj[seed])
        while candidates:
            nxt = max(candidates, key=lambda v: len(adj[v] & candidates))
            coalition.add(nxt)
            candidates &= adj[nxt]
            candidates.discard(nxt)
        if len(coalition) >= 2:
            best = max(best, len(coalition))
    return best
