"""
Visualization: The EGF mirror — counting sequences and their power-series shadows.

Generates a two-panel figure:
  (left)  bar chart of counting sequences for three classical species
          (sets E: n!->1's, linear orders L: n!, derangements D),
  (right) their EGF coefficients a_n/n!, showing how the factorial weighting
          tames factorial growth into the coefficients of exp, 1/(1-X), and e^{-X}/(1-X).

Self-contained: run `python _assets_viz.py` to produce `egf_mirror.png`.
"""

from __future__ import annotations

from math import factorial
from typing import List

import matplotlib.pyplot as plt


def derangements(n: int) -> List[int]:
    """Subfactorials !0.. !n  (number of fixed-point-free permutations)."""
    d = [1, 0]
    for k in range(2, n + 1):
        d.append((k - 1) * (d[k - 1] + d[k - 2]))
    return d[: n + 1]


def main() -> None:
    N = 7
    idx = list(range(N + 1))
    sets_counts = [1] * (N + 1)                       # species of sets E
    linord_counts = [factorial(k) for k in range(N + 1)]  # linear orders L
    der_counts = derangements(N)                      # derangements D

    def egf_coeffs(a: List[int]) -> List[float]:
        return [a[k] / factorial(k) for k in range(len(a))]

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(13, 5))

    w = 0.27
    ax1.bar([i - w for i in idx], sets_counts, w, label="sets E (1)", color="#4C72B0")
    ax1.bar(idx, linord_counts, w, label="linear orders L (n!)", color="#DD8452")
    ax1.bar([i + w for i in idx], der_counts, w, label="derangements D", color="#55A868")
    ax1.set_yscale("log")
    ax1.set_title("Counting sequences  a_n  (log scale)")
    ax1.set_xlabel("size n")
    ax1.set_ylabel("number of structures")
    ax1.legend()

    ax2.plot(idx, egf_coeffs(sets_counts), "o-", label="E -> exp(X):  1/n!", color="#4C72B0")
    ax2.plot(idx, egf_coeffs(linord_counts), "s-", label="L -> 1/(1-X):  1", color="#DD8452")
    ax2.plot(idx, egf_coeffs(der_counts), "^-", label="D -> e^{-X}/(1-X)", color="#55A868")
    ax2.set_title("EGF coefficients  a_n / n!")
    ax2.set_xlabel("degree n")
    ax2.set_ylabel("[X^n] egf(a)")
    ax2.legend()

    fig.suptitle("The EGF mirror: the 1/n! weighting turns counts into power-series shadows",
                 fontsize=13)
    fig.tight_layout()
    fig.savefig("egf_mirror.png", dpi=130)
    print("wrote egf_mirror.png")


if __name__ == "__main__":
    main()
