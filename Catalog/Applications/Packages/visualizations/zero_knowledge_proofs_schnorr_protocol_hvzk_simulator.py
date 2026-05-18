def simulate(p, q, g, y):
    import secrets
    z = secrets.randbelow(q)
    c = secrets.randbelow(q)
    gz = pow(g, z, p)
    y_neg_c = pow(y, q - c, p)
    a = (gz * y_neg_c) % p
    return a, c, z