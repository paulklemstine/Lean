"""Visualization: the ultrametric ball structure of the 2-adic integers.

Plots the p-adic norm landscape and the nested/disjoint ball structure that
the strong triangle inequality forces. Requires matplotlib + numpy.
"""
import numpy as np
import matplotlib.pyplot as plt


def v_p(n: int, p: int) -> int:
    if n == 0:
        return 12
    k = 0
    while n % p == 0:
        n //= p
        k += 1
    return k


def main() -> None:
    p = 2
    xs = np.arange(0, 64)
    norms = np.array([p ** (-v_p(int(n), p)) if n != 0 else 0.0 for n in xs])

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(13, 5))

    ax1.stem(xs, norms, basefmt=" ")
    ax1.set_title(r"$|n|_2 = 2^{-v_2(n)}$  (high divisibility $\to$ small norm)")
    ax1.set_xlabel("integer n")
    ax1.set_ylabel(r"$|n|_2$")

    # Nested ball structure: color integers by residue mod 2^k
    for k in range(1, 5):
        groups = xs % (2 ** k)
        ax2.scatter(xs, np.full_like(xs, k, dtype=float),
                    c=groups, cmap="tab20", s=40)
    ax2.set_title("Ultrametric balls: residues mod $2^k$ are nested or disjoint")
    ax2.set_xlabel("integer n")
    ax2.set_ylabel("ball level k")
    ax2.set_yticks(range(1, 5))

    plt.tight_layout()
    plt.savefig("tropical_ultrametric_balls.png", dpi=140)
    print("saved tropical_ultrametric_balls.png")


if __name__ == "__main__":
    main()
