def compute_rank(G, D):
    if not has_effective_equivalent(G, D): return -1
    r = 0
    while r <= D.degree():
        for combo in compositions(r+1, G.n):
            E = list(combo)
            diff = [D[i] - E[i] for i in range(G.n)]
            if not has_effective_equivalent_vals(G, diff): return r
        r += 1
    return r