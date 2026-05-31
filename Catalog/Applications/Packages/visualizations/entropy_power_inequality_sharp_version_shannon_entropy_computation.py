def shannon_entropy(p):
    import math
    return -sum(pi * math.log(pi) for pi in p if pi > 0)