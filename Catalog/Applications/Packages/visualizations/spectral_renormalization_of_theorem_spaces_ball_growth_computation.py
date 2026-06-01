def ball(adj, v, k):
    current = {v}
    for _ in range(k):
        expansion = set()
        for u in current:
            expansion |= adj[u]
        current = current | expansion
    return current