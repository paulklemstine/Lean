def lipschitz_approx_width(K, epsilon):
    import math
    return math.ceil(K / epsilon) + 1