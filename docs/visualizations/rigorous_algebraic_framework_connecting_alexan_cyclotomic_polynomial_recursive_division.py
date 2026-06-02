def cyclotomic_poly(n, cache={}):
    if n in cache: return cache[n]
    if n == 1:
        cache[1] = [-1, 1]
        return [-1, 1]
    xn = [-1] + [0]*(n-1) + [1]
    for d in range(1, n):
        if n % d == 0:
            xn = poly_exact_div(xn, cyclotomic_poly(d, cache))
    cache[n] = xn
    return xn