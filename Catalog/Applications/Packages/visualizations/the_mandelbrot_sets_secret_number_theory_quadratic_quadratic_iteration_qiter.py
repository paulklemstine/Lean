def qiter(c: complex, n: int) -> complex:
    z = 0
    for _ in range(n):
        z = z**2 + c
    return z