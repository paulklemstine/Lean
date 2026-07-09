"""Visualization: the threshold bias q_k(n) = c_k * n^{(k-2)/(k-1)}.

Left panel: q_k(n) versus board size n (log-log) for several k, showing the
power-law scaling and strict monotonicity in n.
Right panel: the sharp-threshold window ((1-eps)q, (1+eps)q) around q_k(n).
"""
from __future__ import annotations

import math
import matplotlib.pyplot as plt


def threshold_const(k: int) -> float:
    return math.exp((math.log(k - 1) + (k - 2) * math.log(2 * (k - 1) / k)) / (k - 1))


def game_exponent(k: int) -> float:
    return (k - 2) / (k - 1)


def bias(k: int, n: float) -> float:
    return threshold_const(k) * n ** game_exponent(k)


def main() -> None:
    ns = [10 ** e for e in range(1, 8)]
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(13, 5.5))

    for k in (4, 5, 7, 13):
        ys = [bias(k, n) for n in ns]
        ax1.loglog(ns, ys, "o-", label=f"k={k}  (exp {game_exponent(k):.3f})")
    ax1.set_xlabel("board size n")
    ax1.set_ylabel(r"threshold bias $q_k(n)$")
    ax1.set_title("Power-law scaling of the threshold bias")
    ax1.legend()
    ax1.grid(alpha=0.3, which="both")

    k, n, eps = 4, 10_000, 0.15
    q = bias(k, n)
    ax2.axvspan((1 - eps) * q, (1 + eps) * q, color="#e8f0fe",
                label=f"sharp window (eps={eps})")
    ax2.axvline(q, color="#1b4965", lw=2, label=f"q_k(n)={q:.1f}")
    ax2.axvline((1 - eps) * q, color="#43aa8b", ls="--", label="Maker wins region")
    ax2.axvline((1 + eps) * q, color="#d1495b", ls="--", label="Breaker wins region")
    ax2.set_xlim((1 - 2 * eps) * q, (1 + 2 * eps) * q)
    ax2.set_yticks([])
    ax2.set_xlabel("bias q")
    ax2.set_title(f"Sharp window at k={k}, n={n}")
    ax2.legend()

    fig.tight_layout()
    fig.savefig("bias_surface.png", dpi=150)
    print("wrote bias_surface.png")


if __name__ == "__main__":
    main()
