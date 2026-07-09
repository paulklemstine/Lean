"""Scatter plot of v2(R_m - 1) against m, colored by residue class mod 28."""
from __future__ import annotations
import matplotlib.pyplot as plt


def perrin(n_max: int) -> list[int]:
    R = [3, 0, 2]
    for i in range(3, n_max + 1):
        R.append(R[i - 2] + R[i - 3])
    return R


def v2(x: int) -> int:
    x = abs(x); k = 0
    while x % 2 == 0:
        x //= 2; k += 1
    return k


def main() -> None:
    N = 600
    R = perrin(N)
    xs, ys, cs = [], [], []
    for m in range(1, N):
        xs.append(m); ys.append(v2(R[m] - 1))
        cs.append("crimson" if m % 28 in {10, 19, 26} else "steelblue")
    plt.figure(figsize=(11, 4))
    plt.scatter(xs, ys, c=cs, s=10)
    plt.xlabel("m"); plt.ylabel(r"$\nu_2(R_m - 1)$")
    plt.title("2-adic valuation of shifted Perrin numbers "
              "(red = exceptional classes)")
    plt.tight_layout(); plt.savefig("perrin_valuation_scatter.png", dpi=150)


if __name__ == "__main__":
    main()
