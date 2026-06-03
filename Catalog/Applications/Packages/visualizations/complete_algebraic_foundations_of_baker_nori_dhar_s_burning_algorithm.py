def dhars_burning(D, adj, q):
    n = len(D)
    burnt = {q}
    changed = True
    while changed:
        changed = False
        for v in range(n):
            if v in burnt: continue
            bn = sum(1 for w in burnt if adj[v,w] > 0)
            if bn > D[v]:
                burnt.add(v)
                changed = True
    return len(burnt) == n, burnt