def proof_ball(adj, S, k):
    current = set(S)
    for _ in range(k):
        new = set(current)
        for v in current:
            new.update(adj.get(v, set()))
        current = new
    return current