def hypergeom_coeff_recurrence(a: float, b: float, c: float, n: int) -> float:
    result = 1.0
    for k in range(n):
        result *= (a + k) * (b + k) / ((c + k) * (k + 1))
    return result