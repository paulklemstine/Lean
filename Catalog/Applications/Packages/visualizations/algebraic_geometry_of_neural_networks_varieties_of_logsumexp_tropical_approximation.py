def logsumexp_bounds(x, beta):
    M = max(x)
    shifted = [beta*(xi - M) for xi in x]
    import math
    lse = M + (1/beta)*math.log(sum(math.exp(s) for s in shifted))
    return M, lse, M + math.log(len(x))/beta