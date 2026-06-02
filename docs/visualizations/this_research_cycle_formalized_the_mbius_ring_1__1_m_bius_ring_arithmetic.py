def mobius_mul(a, b, c, d):
    return (a*c + b*d, a*d + b*c)

def mobius_norm(a, b):
    return a*a - b*b

def mobius_conj(a, b):
    return (a, -b)