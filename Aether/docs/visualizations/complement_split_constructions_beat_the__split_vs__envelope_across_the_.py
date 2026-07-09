"""
Visualization: split value vs. the quasi-clique/quasi-star envelope for
semi-induced stars S_{k,1}, showing the separation on the golden interval
(0, (sqrt(5)-1)/2).

Produces 'separation.png': for several k, the split value (1-β)(1-sqrt(1-β))^k
plotted against cliqueTerm = β^k(1-β), starTerm = β(1-β)^k, and their envelope,
with the golden-ratio threshold marked.

Run:  python3 visualize.py
"""

from __future__ import annotations

import math
from typing import List

import numpy as np
import matplotlib.pyplot as plt

GOLDEN: float = (math.sqrt(5.0) - 1.0) / 2.0


def split_value(k: int, beta: np.ndarray) -> np.ndarray:
    s = np.sqrt(1.0 - beta)
    return (1.0 - beta) * (1.0 - s) ** k


def clique_term(k: int, beta: np.ndarray) -> np.ndarray:
    return beta ** k * (1.0 - beta)


def star_term(k: int, beta: np.ndarray) -> np.ndarray:
    return beta * (1.0 - beta) ** k


def main() -> None:
    ks: List[int] = [2, 3, 4, 6]
    beta = np.linspace(1e-4, 1.0 - 1e-4, 1000)

    fig, axes = plt.subplots(2, 2, figsize=(12, 9))
    for ax, k in zip(axes.ravel(), ks):
        ct = clique_term(k, beta)
        st = star_term(k, beta)
        env = np.minimum(ct, st)
        sv = split_value(k, beta)

        ax.plot(beta, ct, "--", color="tab:blue", lw=1.2, label=r"quasi-clique $\beta^k(1-\beta)$")
        ax.plot(beta, st, "--", color="tab:green", lw=1.2, label=r"quasi-star $\beta(1-\beta)^k$")
        ax.plot(beta, env, color="black", lw=2.0, label="envelope")
        ax.plot(beta, sv, color="tab:red", lw=2.2, label=r"split $(1-\beta)(1-\sqrt{1-\beta})^k$")

        ax.axvline(GOLDEN, color="goldenrod", ls=":", lw=1.8,
                   label=r"$\beta^\star=\frac{\sqrt5-1}{2}$")
        ax.axvspan(0, GOLDEN, color="gold", alpha=0.10)
        ax.set_title(f"$k = {k}$")
        ax.set_xlabel(r"$\beta$")
        ax.set_ylabel("value")
        ax.set_xlim(0, 1)
        ax.set_ylim(bottom=0)
        ax.legend(fontsize=8, loc="upper right")

    fig.suptitle("Split construction beats the envelope on the golden interval "
                 r"$(0,\,\frac{\sqrt5-1}{2})$", fontsize=14)
    fig.tight_layout(rect=(0, 0, 1, 0.97))
    fig.savefig("separation.png", dpi=140)
    print("Wrote separation.png")


if __name__ == "__main__":
    main()
