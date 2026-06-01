def enumerate_fiber(p, d):
    inv4 = pow(4, p - 2, p)
    return [(b, ((b*b - d) * inv4) % p) for b in range(p)]