"""Visualization: approximate-Lipschitz depth budget.

Plots the accumulated additive error c*(K^n - 1)/(K - 1) versus depth n for
several expansion factors K, and marks the depth at which a target novelty
margin eps is exhausted (transported threshold (eps - error)/K reaches 0).
Requires matplotlib and numpy.
"""
from __future__ import annotations
import numpy as np
import matplotlib.pyplot as plt


def accumulated_error(K: float, c: float, n: np.ndarray) -> np.ndarray:
    if abs(K - 1.0) < 1e-12:
        return c * n
    return c * (K ** n - 1.0) / (K - 1.0)


def main() -> None:
    c, eps = 0.4, 5.0
    ns = np.arange(0, 12)
    fig, ax = plt.subplots(figsize=(7, 5))
    for K in (1.1, 1.3, 1.6):
        err = accumulated_error(K, c, ns)
        ax.plot(ns, err, marker="o", label=f"K = {K}")
    ax.axhline(eps, color="black", ls="--", label=f"margin eps = {eps}")
    ax.set_xlabel("pipeline depth n")
    ax.set_ylabel("accumulated additive error  c*(K^n - 1)/(K - 1)")
    ax.set_title("Depth budget: when does a certified margin run out?")
    ax.legend()
    ax.grid(alpha=0.3)
    plt.tight_layout()
    plt.savefig("depth_budget.png", dpi=150)
    print("wrote depth_budget.png")


if __name__ == "__main__":
    main()
