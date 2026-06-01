def ball(G, S, k):
    current = set(S)
    for _ in range(k):
        current |= {w for v in current for w in G.adj[v]}
    return current