import math
def valley_min(alpha):
    if alpha <= 4: return None
    d = 1 - 3/alpha
    r = (1 + math.sqrt(d))/3
    return r, r - alpha*r**2*(1-r)