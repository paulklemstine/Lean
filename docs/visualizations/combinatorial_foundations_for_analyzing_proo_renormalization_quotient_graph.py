def quotient_graph(adj, partition):
    blocks = set(partition.values())
    quot = {b: set() for b in blocks}
    for u, nbrs in adj.items():
        b1 = partition[u]
        for v in nbrs:
            b2 = partition[v]
            quot[b1].add(b2)
    return quot