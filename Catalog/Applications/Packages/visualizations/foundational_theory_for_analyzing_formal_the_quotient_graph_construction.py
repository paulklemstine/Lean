def quotient(G, f, m):
    edges = set()
    for u in range(G.n):
        for v in G.adj[u]:
            edges.add((f[u], f[v]))
    return DiGraph(m, list(edges))