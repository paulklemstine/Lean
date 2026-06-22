"""Visualization: the EGF dictionary made visible.

Plots, side by side, the counting sequences of the species of sets (E) and of linear
orders (L), the coefficients of their exponential generating functions (1/n! and 1),
and the binomial-convolution coefficients of L.L (which equal (n+1)!), illustrating the
product law EGF(L.L) = EGF(L)*EGF(L) = 1/(1-X)^2.
"""

from __future__ import annotations

from math import factorial, comb
from typing import List

import matplotlib.pyplot as plt


def egf_coeff(a: List[float], n: int) -> float:
    return a[n] / factorial(n)


def main() -> None:
    N = 8
    sets = [1.0] * N                              # E:  a_n = 1
    orders = [float(factorial(n)) for n in range(N)]   # L:  a_n = n!
    ll = [sum(comb(n, i) * orders[i] * orders[n - i] for i in range(n + 1))
          for n in range(N)]                      # (L*L)_n = (n+1)!

    fig, axes = plt.subplots(1, 3, figsize=(15, 4.5))

    axes[0].bar(range(N), sets, color="#2a9d8f", alpha=.85, label="E (sets)")
    axes[0].bar(range(N), [egf_coeff(sets, n) for n in range(N)],
                color="#264653", alpha=.6, label="EGF coeff a_n/n!")
    axes[0].set_title("Species of sets  E  <->  exp")
    axes[0].set_xlabel("n"); axes[0].legend()

    axes[1].bar(range(N), [egf_coeff(orders, n) for n in range(N)],
                color="#e76f51", alpha=.85)
    axes[1].set_title("EGF(L) coeffs = 1  (i.e. 1/(1-X))")
    axes[1].set_xlabel("n"); axes[1].set_ylim(0, 2)

    axes[2].plot(range(N), [egf_coeff(ll, n) for n in range(N)], "o-",
                 color="#e9c46a", lw=2, label="EGF(L.L) = (n+1)")
    axes[2].plot(range(N), [n + 1 for n in range(N)], "k--", alpha=.4,
                 label="1/(1-X)^2 coeff")
    axes[2].set_title("Product law: EGF(L.L) = EGF(L)^2")
    axes[2].set_xlabel("n"); axes[2].legend()

    fig.suptitle("The EGF dictionary: counting sequences vs. series coefficients",
                 fontsize=13)
    fig.tight_layout()
    fig.savefig("species_bridge.png", dpi=140)
    print("wrote species_bridge.png")


if __name__ == "__main__":
    main()
