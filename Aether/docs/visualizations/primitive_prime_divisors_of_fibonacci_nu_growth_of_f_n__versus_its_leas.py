import matplotlib.pyplot as plt
from math import gcd, log10
from typing import Dict, List, Tuple


def fib(n: int) -> int:
    def _fd(k: int) -> Tuple[int, int]:
        if k == 0:
            return (0, 1)
        a, b = _fd(k >> 1)
        c = a * (2 * b - a)
        d = a * a + b * b
        return (d, c + d) if k & 1 else (c, d)
    return _fd(n)[0]


def factorize(m: int) -> Dict[int, int]:
    f: Dict[int, int] = {}
    d = 2
    while d * d <= m:
        while m % d == 0:
            f[d] = f.get(d, 0) + 1
            m //= d
        d += 1 if d == 2 else 2
    if m > 1:
        f[m] = f.get(m, 0) + 1
    return f


def least_primitive_divisor(n: int) -> int:
    earlier = set()
    for k in range(1, n):
        earlier |= set(factorize(fib(k)))
    prims = [p for p in factorize(fib(n)) if p not in earlier]
    return min(prims) if prims else 0


if __name__ == "__main__":
    ns = list(range(13, 41))
    sizes = [log10(fib(n)) for n in ns]
    least = [log10(least_primitive_divisor(n)) for n in ns]
    plt.figure(figsize=(10, 6))
    plt.plot(ns, sizes, "o-", label="log10 F(n)")
    plt.plot(ns, least, "s-", label="log10(least primitive prime)")
    plt.xlabel("index n")
    plt.ylabel("base-10 digits")
    plt.title("Fibonacci numbers and their least primitive prime divisor")
    plt.legend()
    plt.grid(True, alpha=0.3)
    plt.tight_layout()
    plt.savefig("fib_primitive_divisors.png", dpi=150)
    print("saved fib_primitive_divisors.png")
