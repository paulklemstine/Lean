"""Visualize the prime factors of n^2+1, colored by residue class mod 4.

Confirms visually that every prime factor is 2 or congruent to 1 (mod 4):
no point ever lands in the p%4==3 band (the Great Filter).
Requires matplotlib. Run: python visualization.py
"""
from math import isqrt
from typing import List
import matplotlib.pyplot as plt


def factorize(m: int) -> List[int]:
    facs: List[int] = []
    d = 2
    while d * d <= m:
        while m % d == 0:
            facs.append(d)
            m //= d
        d += 1
    if m > 1:
        facs.append(m)
    return facs


def main(N: int = 400) -> None:
    xs1, ys1 = [], []   # factors == 1 mod 4
    xs2, ys2 = [], []   # factor == 2
    xs3, ys3 = [], []   # forbidden: 3 mod 4 (should stay empty)
    for n in range(1, N + 1):
        for p in set(factorize(n * n + 1)):
            if p == 2:
                xs2.append(n); ys2.append(p)
            elif p % 4 == 1:
                xs1.append(n); ys1.append(p)
            else:
                xs3.append(n); ys3.append(p)
    plt.figure(figsize=(11, 7))
    plt.scatter(xs1, ys1, s=8, c="#2166ac", label="prime factor p ≡ 1 (mod 4)")
    plt.scatter(xs2, ys2, s=14, c="#1a9850", marker="s", label="prime factor p = 2")
    plt.scatter(xs3, ys3, s=40, c="#d73027", marker="x",
                label="prime factor p ≡ 3 (mod 4)  [FORBIDDEN — none appear]")
    plt.yscale("log")
    plt.xlabel("n")
    plt.ylabel("prime factor of n² + 1 (log scale)")
    plt.title("Prime factors of n² + 1: the Great Filter excludes p ≡ 3 (mod 4)")
    plt.legend(loc="upper left")
    plt.tight_layout()
    plt.savefig("nsq_plus_one_factors.png", dpi=150)
    print("Saved nsq_plus_one_factors.png; forbidden-band points:", len(xs3))


if __name__ == "__main__":
    main()
