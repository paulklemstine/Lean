def q_reduce(D, adj, q, max_iter=100000):
    n = len(D)
    current = D.copy()
    for _ in range(max_iter):
        is_red, burnt = dhars_burning(current, adj, q)
        if is_red: return current
        unburnt = set(range(n)) - burnt
        for v in unburnt:
            current = chip_fire(current, adj, v)
    return None