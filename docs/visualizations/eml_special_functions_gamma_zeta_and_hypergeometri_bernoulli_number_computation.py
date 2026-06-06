def bernoulli_numbers(N):
    from fractions import Fraction
    import math
    B = [Fraction(0)] * (N + 1)
    B[0] = Fraction(1)
    for m in range(1, N + 1):
        for k in range(m): B[m] -= Fraction(math.comb(m+1,k)) * B[k]
        B[m] /= Fraction(m + 1)
    return B