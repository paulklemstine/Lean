def mobius_add(z: complex, w: complex) -> complex:
    return (z + w) / (1.0 + z.conjugate() * w)