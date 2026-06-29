import matplotlib.pyplot as plt
from math import gcd
from typing import Callable, Optional


def fib(n: int) -> int:
    a, b = 0, 1
    for _ in range(n):
        a, b = b, a + b
    return a


def mersenne(n: int) -> int:
    return 2 ** n - 1


def rank(u: Callable[[int], int], m: int, limit: int = 100000) -> Optional[int]:
    for k in range(1, limit + 1):
        if u(k) % m == 0:
            return k
    return None


def main() -> None:
    ms = list(range(2, 31))
    rf = [rank(fib, m) for m in ms]
    mm = list(range(3, 64, 2))
    rm = [rank(mersenne, m) for m in mm]
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(13, 5))
    ax1.stem(ms, rf)
    ax1.set_title("Fibonacci ranks (Pisano entry points)")
    ax1.set_xlabel("modulus m"); ax1.set_ylabel("rank(m)")
    ax2.stem(mm, rm)
    ax2.set_title("Mersenne ranks rank(2^n - 1)")
    ax2.set_xlabel("modulus m"); ax2.set_ylabel("rank(m)")
    plt.tight_layout()
    plt.savefig("rank_spectrum.png", dpi=150)
    print("Saved rank_spectrum.png")


if __name__ == "__main__":
    main()
