"""
Visualization: the apparition divisibility lattice and stalk reconstruction.
Generates two panels:
  (left) a heatmap of  m | F(n)  showing the periodic column structure,
         the visual signature of the law of apparition;
  (right) a bar chart comparing direct rank(n) with the lcm of prime-power
          stalk ranks, the local-to-global reconstruction.
Requires: matplotlib, numpy.
"""
from __future__ import annotations
from math import gcd
from functools import reduce
from typing import Dict, List
import numpy as np
import matplotlib.pyplot as plt


def fib(n: int) -> int:
    a, b = 0, 1
    for _ in range(n):
        a, b = b, a + b
    return a


def lcm(a: int, b: int) -> int:
    return 0 if a == 0 or b == 0 else a // gcd(a, b) * b


def fib_rank(m: int) -> int:
    if m == 1:
        return 1
    a, b, k = 0, 1 % m, 0
    while True:
        a, b = b, (a + b) % m
        k += 1
        if a == 0:
            return k


def factorize(n: int) -> Dict[int, int]:
    f: Dict[int, int] = {}
    d = 2
    while d * d <= n:
        while n % d == 0:
            f[d] = f.get(d, 0) + 1
            n //= d
        d += 1 if d == 2 else 2
    if n > 1:
        f[n] = f.get(n, 0) + 1
    return f


def main() -> None:
    M, N = 20, 40
    grid = np.array([[1 if (m > 0 and fib(n) % m == 0) else 0
                      for n in range(1, N + 1)] for m in range(1, M + 1)])

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))
    ax1.imshow(grid, aspect="auto", cmap="viridis",
               extent=[1, N, M, 1])
    ax1.set_title("Divisibility lattice:  m | F(n)\n(periodic columns = law of apparition)")
    ax1.set_xlabel("index n");  ax1.set_ylabel("modulus m")

    nums = [36, 60, 100, 360, 1000, 144, 210]
    direct = [fib_rank(n) for n in nums]
    recon = [reduce(lcm, [fib_rank(p ** e) for p, e in factorize(n).items()], 1)
             for n in nums]
    x = np.arange(len(nums))
    ax2.bar(x - 0.2, direct, 0.4, label="direct rank(n)")
    ax2.bar(x + 0.2, recon, 0.4, label="lcm of stalk ranks")
    ax2.set_xticks(x);  ax2.set_xticklabels([str(n) for n in nums])
    ax2.set_title("Local-to-global reconstruction\nrank(n) = lcm rank(p^e)")
    ax2.set_xlabel("n");  ax2.set_ylabel("rank");  ax2.legend()
    plt.tight_layout()
    plt.savefig("apparition_visualization.png", dpi=130)
    print("saved apparition_visualization.png")


if __name__ == "__main__":
    main()
