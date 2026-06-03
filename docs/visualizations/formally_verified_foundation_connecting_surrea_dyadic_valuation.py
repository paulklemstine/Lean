def dyadic_valuation(q):
    d = q.denominator
    k = 0
    while d % 2 == 0:
        d //= 2
        k += 1
    return k