"""Visualization: the 1-Wasserstein distance as the area between two CDFs.

Generates a figure showing two distributions on the grid {0,...,n-1}, their
cumulative distribution functions, and the shaded region whose total area equals
W1(p, q) = sum_k |F_p(k) - F_q(k)|.

Run:  python _viz.py   (writes w1_cdf_area.png)
"""

from __future__ import annotations

from typing import List, Sequence

import matplotlib.pyplot as plt
import numpy as np


def cdf(p: Sequence[float]) -> List[float]:
    out, running = [], 0.0
    for v in p:
        running += v
        out.append(running)
    return out


def w1(p: Sequence[float], q: Sequence[float]) -> float:
    fp, fq = cdf(p), cdf(q)
    return sum(abs(a - b) for a, b in zip(fp[:-1], fq[:-1]))


def main() -> None:
    p = [0.45, 0.30, 0.15, 0.07, 0.03]
    q = [0.05, 0.15, 0.30, 0.30, 0.20]
    n = len(p)
    x = np.arange(n)
    fp, fq = cdf(p), cdf(q)

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(12, 4.5))

    width = 0.38
    ax1.bar(x - width / 2, p, width, label="p", color="#3b7dd8")
    ax1.bar(x + width / 2, q, width, label="q", color="#d8703b")
    ax1.set_title("Two distributions on the grid")
    ax1.set_xlabel("position k")
    ax1.set_ylabel("probability mass")
    ax1.legend()

    ax2.step(x, fp, where="post", label="$F_p$", color="#3b7dd8", linewidth=2)
    ax2.step(x, fq, where="post", label="$F_q$", color="#d8703b", linewidth=2)
    ax2.fill_between(x, fp, fq, step="post", alpha=0.3, color="#888888",
                     label="area = $W_1$")
    ax2.set_title(f"CDFs and their gap:  $W_1(p,q)$ = {w1(p, q):.3f}")
    ax2.set_xlabel("position k")
    ax2.set_ylabel("cumulative mass")
    ax2.legend()

    fig.tight_layout()
    fig.savefig("w1_cdf_area.png", dpi=150)
    print("wrote w1_cdf_area.png ;  W1 =", round(w1(p, q), 4))


if __name__ == "__main__":
    main()
