"""Visualise sign patterns of lambda_{sym^j f}(n) over sums of m squares.

Requires matplotlib. Uses the weight-12 form Delta (Ramanujan tau).
"""
from __future__ import annotations
import math
from typing import List
import matplotlib.pyplot as plt


def ramanujan_tau(N: int) -> List[int]:
    prod = [0] * (N + 1); prod[0] = 1
    for n in range(1, N + 1):
        binom = [math.comb(24, k) * (-1) ** k for k in range(25)]
        new = [0] * (N + 1)
        for i in range(N + 1):
            if prod[i] == 0:
                continue
            for k in range(25):
                j = i + n * k
                if j > N:
                    break
                new[j] += prod[i] * binom[k]
        prod = new
    tau = [0] * (N + 1)
    for n in range(1, N + 1):
        tau[n] = prod[n - 1]
    return tau


def is_sum_of_two_squares(n: int) -> bool:
    if n <= 0:
        return n == 0
    m, p = n, 2
    while p * p <= m:
        if m % p == 0:
            e = 0
            while m % p == 0:
                m //= p; e += 1
            if p % 4 == 3 and e % 2 == 1:
                return False
        p += 1
    return not (m > 1 and m % 4 == 3)


def main() -> None:
    N = 400
    tau = ramanujan_tau(N)
    lam = [0.0] * (N + 1)
    for n in range(1, N + 1):
        lam[n] = tau[n] / (n ** 5.5)   # lambda_f(n) (j = 1)
    xs_all = list(range(1, N + 1))
    ys_all = [lam[n] for n in xs_all]
    xs_two = [n for n in xs_all if is_sum_of_two_squares(n)]
    ys_two = [lam[n] for n in xs_two]

    fig, (ax1, ax2) = plt.subplots(2, 1, figsize=(11, 7), sharex=True)
    ax1.axhline(0, color="k", lw=0.8)
    ax1.bar(xs_all, ys_all, color=["#2a7" if v > 0 else "#c33" for v in ys_all])
    ax1.set_title(r"$\lambda_f(n)$ over all $n$  (= sums of $m$ squares, $m\geq 4$)")
    ax2.axhline(0, color="k", lw=0.8)
    ax2.bar(xs_two, ys_two, color=["#2a7" if v > 0 else "#c33" for v in ys_two])
    ax2.set_title(r"$\lambda_f(n)$ over sums of two squares (thin, density zero)")
    ax2.set_xlabel("n")
    fig.tight_layout()
    fig.savefig("sign_changes.png", dpi=140)
    print("wrote sign_changes.png")


if __name__ == "__main__":
    main()
