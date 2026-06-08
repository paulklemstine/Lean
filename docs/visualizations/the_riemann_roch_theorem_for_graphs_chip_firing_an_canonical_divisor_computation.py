def canonical_divisor(G):
    return {v: G.degree(v) - 2 for v in G.vertices}