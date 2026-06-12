"""Visualization: Solovay-Kitaev doubly-exponential convergence and
topological error suppression. Saves 'convergence.png'.
"""
from __future__ import annotations
import math
import numpy as np
import matplotlib.pyplot as plt


def sk_error(eps0: float, n: int) -> float:
    return eps0 ** ((3.0 / 2.0) ** n)


def main() -> None:
    fig, axes = plt.subplots(1, 2, figsize=(11, 4.6))

    ns = list(range(7))
    for eps0 in (0.3, 0.2, 0.1):
        axes[0].semilogy(ns, [sk_error(eps0, n) for n in ns],
                         marker="o", label=f"eps0={eps0}")
    axes[0].set_xlabel("SK level n")
    axes[0].set_ylabel("approximation error (log scale)")
    axes[0].set_title("SK error  eps0 ** (3/2)^n")
    axes[0].legend()
    axes[0].grid(True, which="both", alpha=0.3)

    L = np.linspace(0, 10, 200)
    for delta in (0.5, 1.0, 2.0):
        axes[1].semilogy(L, np.exp(-delta * L), label=f"Delta={delta}")
    axes[1].set_xlabel("system size L")
    axes[1].set_ylabel("error prob exp(-Delta L) (log scale)")
    axes[1].set_title("Topological error suppression")
    axes[1].legend()
    axes[1].grid(True, which="both", alpha=0.3)

    fig.tight_layout()
    fig.savefig("convergence.png", dpi=130)
    print("wrote convergence.png")


if __name__ == "__main__":
    main()
