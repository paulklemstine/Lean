UNITS = [(1, 0), (-1, 0), (0, 1), (0, -1)]

def _mul(z: tuple[int, int], w: tuple[int, int]) -> tuple[int, int]:
    a, b = z; c, d = w
    return (a*c - b*d, a*d + b*c)

def same_image(z: tuple[int, int], w: tuple[int, int]) -> bool:
    """True iff P(z) = P(w), i.e. w lies in the symmetry orbit of z."""
    orbit = set()
    for u in UNITS:
        orbit.add(_mul(u, z))
        orbit.add(_mul(u, (z[0], -z[1])))
    return w in orbit
