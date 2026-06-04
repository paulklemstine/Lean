def bottleneck_path(adj, fitness, src, tgt):
    import math
    bn = {v: -math.inf for v in adj}
    bn[src] = fitness[src]
    visited = set()
    for _ in range(len(adj)):
        v = max((u for u in adj if u not in visited), key=lambda u: bn[u])
        if v == tgt: break
        visited.add(v)
        for u in adj[v]:
            bn[u] = max(bn[u], min(bn[v], fitness[u]))
    return bn[tgt]