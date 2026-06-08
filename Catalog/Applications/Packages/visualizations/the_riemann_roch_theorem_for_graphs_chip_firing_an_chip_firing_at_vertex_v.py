def chip_fire(D, v):
    result = D.copy()
    result[v] -= G.degree(v)
    for w in G.adj[v]:
        result[w] += 1
    return result