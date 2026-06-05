def exp_shift(g):
    return GrowthLevel(g.depth + 1, g.exponent)

def log_shift(g):
    return GrowthLevel(g.depth - 1, g.exponent)

def iter_exp_shift(n, g):
    for _ in range(n): g = exp_shift(g)
    return g