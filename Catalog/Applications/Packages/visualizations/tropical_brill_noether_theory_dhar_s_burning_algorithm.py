def dhars_burning(G, D, q):
    burned = {q}
    changed = True
    while changed:
        changed = False
        for v in range(G.n):
            if v in burned: continue
            edges_to_burned = sum(1 for w in G.adj[v] if w in burned)
            if D[v] < edges_to_burned:
                burned.add(v)
                changed = True
    return len(burned) == G.n, burned