from math import isqrt
def fibonacci(n: int) -> int:
    a, b = 0, 1
    for _ in range(n): a, b = b, a + b
    return a
def factors(n: int) -> list[int]:
    out: list[int] = []; d = 2
    while d <= isqrt(n):
        if n % d == 0:
            out.append(d)
            while n % d == 0: n //= d
        d = 3 if d == 2 else d + 2
    return out + ([n] if n > 1 else [])
def first_zero(p: int, limit: int) -> int | None:
    a, b = 0, 1
    for k in range(1, limit + 1):
        a, b = b, (a + b) % p
        if a == 0: return k
    return None
def primitive_divisors(n: int) -> list[int]:
    return [p for p in factors(fibonacci(n)) if first_zero(p, n) == n]
