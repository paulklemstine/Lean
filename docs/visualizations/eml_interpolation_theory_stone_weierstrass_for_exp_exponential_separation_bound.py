import math
def exp_separation_bound(x, y):
    actual = abs(math.exp(x) - math.exp(y))
    bound = abs(x - y) * math.exp(min(x, y))
    return actual, bound, actual >= bound