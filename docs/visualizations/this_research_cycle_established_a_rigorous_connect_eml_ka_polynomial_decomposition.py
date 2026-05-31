def eml_ka_poly(terms, x, y):
    import math
    return sum(c * math.exp(a * math.log(x) + b * math.log(y)) for c, a, b in terms)