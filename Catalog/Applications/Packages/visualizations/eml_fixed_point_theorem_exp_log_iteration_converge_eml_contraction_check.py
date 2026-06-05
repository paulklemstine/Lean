def check_contraction(a, c, L=0.0):
    import math
    K = math.exp(a) / (L + c)
    return K < 1, K