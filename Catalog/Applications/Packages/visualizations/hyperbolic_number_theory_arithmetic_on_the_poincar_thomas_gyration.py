def gyration(a: complex, b: complex, c: complex) -> complex:
    num = 1.0 + a.conjugate() * b
    den = 1.0 + b.conjugate() * a
    return (num / den) * c