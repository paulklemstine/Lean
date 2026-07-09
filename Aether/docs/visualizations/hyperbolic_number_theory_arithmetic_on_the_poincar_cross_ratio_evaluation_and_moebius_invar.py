def cross_ratio(z1: complex, z2: complex,
                z3: complex, z4: complex) -> complex:
    return ((z1 - z3) * (z2 - z4)) / ((z1 - z4) * (z2 - z3))

def verify_invariance(a: complex, b: complex, c: complex, d: complex,
                      z1: complex, z2: complex, z3: complex, z4: complex,
                      tol: float = 1e-9) -> bool:
    assert abs(a * d - b * c) > tol, "Moebius map must be non-degenerate"
    mu = lambda z: (a * z + b) / (c * z + d)
    before = cross_ratio(z1, z2, z3, z4)
    after = cross_ratio(mu(z1), mu(z2), mu(z3), mu(z4))
    return abs(before - after) < tol
