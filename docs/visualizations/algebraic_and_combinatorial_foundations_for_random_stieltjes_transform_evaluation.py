def stieltjes(z: complex) -> complex:
    import cmath
    disc = z**2 - 4
    G = (z - cmath.sqrt(disc)) / 2
    if z.imag > 0 and G.imag > 0:
        G = (z + cmath.sqrt(disc)) / 2
    return G