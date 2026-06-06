def canonical_complement(G, D):
    return [G.degree(v)-2-D[v] for v in range(G.n)]