def coarse_grain(n, adj, partition):
    node_to_block = {}
    for idx, block in enumerate(partition):
        for node in block:
            node_to_block[node] = idx
    m = len(partition)
    coarse_adj = {i: set() for i in range(m)}
    for u in range(n):
        for v in adj[u]:
            bu, bv = node_to_block[u], node_to_block[v]
            if bu != bv:
                coarse_adj[bu].add(bv)
    return m, coarse_adj