def moebius_inversion(f, n: int) -> float:
    total = 0.0
    for d in range(1, n + 1):
        if n % d == 0:
            total += moebius(d) * f(n // d)
    return total