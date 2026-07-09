"""Visualization: the sharp constant c_k versus cycle length k.

Plots c_k for 4 <= k <= 60, marks the unique peak at k = 13, and draws the
proven envelope band [3/2, 3) together with the reference line y = 2.
"""
from __future__ import annotations

import math
import matplotlib.pyplot as plt


def threshold_const(k: int) -> float:
    log_c = (math.log(k - 1) + (k - 2) * math.log(2 * (k - 1) / k)) / (k - 1)
    return math.exp(log_c)


def main() -> None:
    ks = list(range(4, 61))
    cs = [threshold_const(k) for k in ks]
    peak_k = max(ks, key=threshold_const)

    fig, ax = plt.subplots(figsize=(9, 5.5))
    ax.axhspan(1.5, 3.0, color="#e8f0fe", label="proven envelope [3/2, 3)")
    ax.axhline(2.0, color="#d1495b", ls="--", lw=1, label="reference y = 2")
    ax.plot(ks, cs, "o-", color="#1b4965", ms=4, label=r"$c_k$")
    ax.plot([peak_k], [threshold_const(peak_k)], "*", color="#e09f3e",
            ms=18, label=f"peak k={peak_k}, c={threshold_const(peak_k):.4f}")
    ax.set_xlabel("cycle length k")
    ax.set_ylabel(r"sharp constant $c_k$")
    ax.set_title("Sharp threshold constant of the $C_k$-game")
    ax.set_ylim(1.4, 3.05)
    ax.legend()
    ax.grid(alpha=0.3)
    fig.tight_layout()
    fig.savefig("constant_curve.png", dpi=150)
    print("wrote constant_curve.png")


if __name__ == "__main__":
    main()
