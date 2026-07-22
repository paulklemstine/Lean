from math import isqrt

def factor(n: int) -> tuple[int, list[int]]:
    if n == 0:
        raise ValueError("zero has no finite nonzero prime factorization")
    sign, m, factors = (-1 if n < 0 else 1), abs(n), []
    d = 2
    while d <= isqrt(m):
        while m % d == 0:
            factors.append(d); m //= d
        d = 3 if d == 2 else d + 2
    if m > 1: factors.append(m)
    return sign, factors

for n in [6, -6]: print(n, factor(n))
print("(-2)(-3) =", (-2)*(-3))
