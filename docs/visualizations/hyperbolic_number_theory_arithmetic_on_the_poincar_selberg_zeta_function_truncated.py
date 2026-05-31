import cmath
def selberg_zeta(spectrum, s, K=10):
    result = 1+0j
    for l in spectrum:
        for k in range(K):
            result *= (1 - cmath.exp(-(s+k)*l))
    return result