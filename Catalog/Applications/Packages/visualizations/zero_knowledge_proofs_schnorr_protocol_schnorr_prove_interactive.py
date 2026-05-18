def schnorr_prove(p, q, g, x, c):
    import secrets
    r = secrets.randbelow(q)
    a = pow(g, r, p)
    z = (r + c * x) % q
    return a, c, z