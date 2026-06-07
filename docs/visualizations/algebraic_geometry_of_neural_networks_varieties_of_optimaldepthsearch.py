def optimal_depth(W):
    best = (1, [W], W)
    for L in range(1, W+1):
        w = W // L
        if w < 2: break
        d = w**L
        if d > best[2]: best = (L, [w]*L, d)
    return best