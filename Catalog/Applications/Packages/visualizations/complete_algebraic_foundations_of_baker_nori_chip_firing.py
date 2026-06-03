def chip_fire(D, adj, v):
    result = D.copy()
    deg = int(adj[v].sum())
    result[v] -= deg
    for w in range(len(D)):
        if adj[v,w] > 0:
            result[w] += 1
    return result