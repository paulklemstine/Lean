def mixing_time_upper_bound(gamma, n, eps=0.01):
    import math
    return math.ceil(math.log(math.sqrt(n)/eps) / math.log(1/(1-gamma)))