def dhars_burning(G, D, q):
    burned = {q}
    changed = True
    while changed:
        changed = False
        for v in range(G.n):
            if v in burned: continue
            if D[v] < len(G.adj[v] & burned):
                burned.add(v)
                changed = True
    return (len(burned)==G.n, set(range(G.n))-burned)