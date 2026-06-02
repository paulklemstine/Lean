def moebius_transform(a: complex, b: complex, z: complex) -> complex:
    return (a * z + b) / (b.conjugate() * z + a.conjugate())