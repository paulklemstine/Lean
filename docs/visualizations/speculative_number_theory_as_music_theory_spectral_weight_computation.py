def spectral_weight(n):
    if n <= 0: return 0
    factors = prime_factorization(n)
    return sum(Fraction(exp, p) for p, exp in factors.items())