from __future__ import annotations

def fib(n: int) -> int:
    a, b = 0, 1
    for _ in range(n):
        a, b = b, a + b
    return a

def fib_two_basis(n: int, k: int) -> int:
    return fib(k) * fib(n) + fib(k + 1) * fib(n + 1)

def check_two_basis(n: int, k: int) -> bool:
    return fib(n + (k + 1)) == fib_two_basis(n, k)

def check_cassini(n: int) -> bool:
    return fib(n + 2) * fib(n) - fib(n + 1) ** 2 == (-1) ** (n + 1)
