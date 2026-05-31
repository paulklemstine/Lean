from fractions import Fraction
def rational_approx(weights, eps):
    n = len(weights)
    eps_per = eps / (n + 1)
    return [Fraction(w).limit_denominator(int(1/eps_per)+1) for w in weights]