def disc_fiber(d: int, p: int) -> list:
    inv4 = pow(4, p - 2, p)
    return [(b, (b * b - d) * inv4 % p) for b in range(p)]