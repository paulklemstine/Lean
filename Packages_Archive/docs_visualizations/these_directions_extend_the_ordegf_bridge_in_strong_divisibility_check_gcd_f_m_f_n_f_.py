from math import gcd


def fib(n: int) -> int:
    a, b = 0, 1
    for _ in range(n):
        a, b = b, a + b
    return a


def check_strong_divisibility(m: int, n: int) -> bool:
    """Verify the foundational identity gcd(F(m), F(n)) = F(gcd(m, n))."""
    return gcd(fib(m), fib(n)) == fib(gcd(m, n))
