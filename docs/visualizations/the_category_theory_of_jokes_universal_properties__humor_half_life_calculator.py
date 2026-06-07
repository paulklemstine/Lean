def humor_half_life(h0, r, epsilon):
    import math
    return max(0, math.ceil(math.log(epsilon / h0) / math.log(r)))