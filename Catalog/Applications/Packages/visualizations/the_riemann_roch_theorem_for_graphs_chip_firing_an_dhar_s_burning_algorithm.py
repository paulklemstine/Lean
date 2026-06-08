def dhars_burning(G, q, D):
    unburnt = set(G.vertices) - {q}
    changed = True
    while changed:
        changed = False
        for v in list(unburnt):
            outdeg = sum(1 for w in G.adj[v] if w not in unburnt)
            if D[v] < outdeg:
                unburnt.discard(v)
                changed = True
    return len(unburnt) == 0