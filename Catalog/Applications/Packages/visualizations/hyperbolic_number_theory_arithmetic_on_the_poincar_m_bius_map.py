def mobius_map(a: complex, z: complex) -> complex:
    return (z - a) / (1 - a.conjugate() * z)