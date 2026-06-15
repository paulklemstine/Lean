"""
Visualization: the Fisher information of the Bernoulli family and the
Cramer-Rao precision floor it implies.

Produces a two-panel figure:
  (left)  Fisher information G(theta) = 1/(theta(1-theta)) over (0,1);
  (right) the Cramer-Rao floor on the variance of an unbiased estimator,
          1/(N*G(theta)) = theta(1-theta)/N, for several sample sizes N.

Requires matplotlib.  Run:  python visualize.py
"""

from __future__ import annotations

from typing import List

import matplotlib.pyplot as plt


def bernoulli_fisher(theta: float) -> float:
    """Fisher information of the identity-link Bernoulli model."""
    return 1.0 / (theta * (1.0 - theta))


def main() -> None:
    thetas: List[float] = [i / 200.0 for i in range(1, 200)]
    G: List[float] = [bernoulli_fisher(t) for t in thetas]

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(12, 5))

    ax1.plot(thetas, G, color="crimson", lw=2)
    ax1.set_title("Fisher information of Bernoulli(theta)")
    ax1.set_xlabel("theta")
    ax1.set_ylabel("G(theta) = 1 / (theta(1-theta))")
    ax1.set_ylim(0, 50)
    ax1.grid(alpha=0.3)
    ax1.annotate("information is largest\nnear theta=0 or 1",
                 xy=(0.05, 21), xytext=(0.25, 38),
                 arrowprops=dict(arrowstyle="->"))

    for N in (1, 2, 5, 20):
        floor = [t * (1.0 - t) / N for t in thetas]
        ax2.plot(thetas, floor, lw=2, label=f"N = {N}")
    ax2.set_title("Cramer-Rao floor: min Var = theta(1-theta)/N")
    ax2.set_xlabel("theta")
    ax2.set_ylabel("minimum achievable variance")
    ax2.legend()
    ax2.grid(alpha=0.3)

    fig.suptitle("More data, more information, lower variance floor", fontsize=14)
    fig.tight_layout()
    fig.savefig("fisher_cramer_rao.png", dpi=140)
    print("Saved fisher_cramer_rao.png")


if __name__ == "__main__":
    main()
