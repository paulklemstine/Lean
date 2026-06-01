def classify_quadratic(p, b, c):
    disc = (b * b - 4 * c) % p
    if disc == 0:
        return 'ramified'
    legendre = pow(disc, (p - 1) // 2, p)
    return 'split' if legendre == 1 else 'inert'