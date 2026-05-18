def schnorr_keygen(p, q, g):
    import secrets
    x = secrets.randbelow(q - 1) + 1
    y = pow(g, x, p)
    return x, y