def find_max_clique(adj, n):
    best = []
    def bk(R, P, X):
        nonlocal best
        if not P and not X:
            if len(R) > len(best): best = list(R)
            return
        pivot = max(P | X, key=lambda v: len(adj.get(v, set()) & P))
        for v in P - adj.get(pivot, set()):
            bk(R | {v}, P & adj[v], X & adj[v])
            P -= {v}; X |= {v}
    bk(set(), set(range(n)), set())
    return best