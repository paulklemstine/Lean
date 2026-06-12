"""Visualization: Bernoulli Fisher information and the Cramer-Rao floor.

Plots G(sigma) = 1/(sigma(1-sigma)) (natural parametrization) and the
corresponding inverse-Fisher variance floor 1/G = sigma(1-sigma).
Requires matplotlib. Saves 'bernoulli_fisher.png'.
"""
from typing import List
import matplotlib.pyplot as plt


def bernoulli_fisher(sigma: float, dsigma: float = 1.0) -> float:
    return dsigma ** 2 / (sigma * (1.0 - sigma))


def main() -> None:
    xs: List[float] = [0.001 + 0.001 * k for k in range(999)]
    G: List[float] = [bernoulli_fisher(s) for s in xs]
    invG: List[float] = [1.0 / g for g in G]
    fig, ax = plt.subplots(1, 2, figsize=(11, 4))
    ax[0].plot(xs, G, color="crimson")
    ax[0].set_title("Bernoulli Fisher information  G(sigma)")
    ax[0].set_xlabel("sigma"); ax[0].set_ylabel("G")
    ax[0].set_ylim(0, 40); ax[0].grid(True, alpha=0.3)
    ax[1].plot(xs, invG, color="navy")
    ax[1].set_title("Cramer-Rao variance floor  1/G = sigma(1-sigma)")
    ax[1].set_xlabel("sigma"); ax[1].set_ylabel("1 / G")
    ax[1].grid(True, alpha=0.3)
    fig.tight_layout()
    fig.savefig("bernoulli_fisher.png", dpi=150)
    print("saved bernoulli_fisher.png")


if __name__ == "__main__":
    main()
