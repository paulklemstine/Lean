def schnorr_verify(p, q, g, y, a, c, z):
    lhs = pow(g, z, p)
    rhs = (a * pow(y, c, p)) % p
    return lhs == rhs