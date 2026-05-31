def entropy_power(p, d=1):
    import math
    h = shannon_entropy(p)
    return math.exp(2 * h / d)