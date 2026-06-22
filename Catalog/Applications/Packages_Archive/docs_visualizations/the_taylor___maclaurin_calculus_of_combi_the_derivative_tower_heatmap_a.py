"""
Visualization: The Taylor tower of a combinatorial species and the
factorial-cancelling Maclaurin reconstruction.

Produces a two-panel figure:

  (left)  The derivative tower table  F^(k)[n] = F[n+k]  as a heatmap of
          log-counts for the species of linear orders L (counts (n+k)!).
  (right) The Maclaurin reconstruction: constant term of D^k(EGF) plotted
          against the true species count F[k], showing exact agreement and
          the cancellation of the k! that an ordinary GF would introduce.

Run:  python visualization.py   (writes species_taylor_tower.png)
"""

from __future__ import annotations

from fractions import Fraction
from math import factorial, log10
from typing import Callable, List

import numpy as np
import matplotlib.pyplot as plt


def egf_coeffs(a: Callable[[int], Fraction], n_terms: int) -> List[Fraction]:
    return [a(n) / factorial(n) for n in range(n_terms)]


def formal_derivative(coeffs: List[Fraction]) -> List[Fraction]:
    return [(n + 1) * coeffs[n + 1] for n in range(len(coeffs) - 1)]


def iterate_derivative(coeffs: List[Fraction], k: int) -> List[Fraction]:
    out = list(coeffs)
    for _ in range(k):
        out = formal_derivative(out)
    return out


def L(n: int) -> Fraction:  # species of linear orders, L[n] = n!
    return Fraction(factorial(n))


def main() -> None:
    K, N = 7, 7
    # Left panel: tower heatmap of log10(F^(k)[n]) = log10((n+k)!)
    tower = np.array([[log10(float(L(n + k))) if (n + k) > 0 else 0.0
                       for n in range(N)] for k in range(K)])

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(13, 5.2))

    im = ax1.imshow(tower, cmap="viridis", aspect="auto", origin="lower")
    ax1.set_title(r"Derivative tower  $F^{(k)}[n]=F[n+k]=(n+k)!$"
                  "\n(log$_{10}$ counts, species L)")
    ax1.set_xlabel(r"honest labels $n$")
    ax1.set_ylabel(r"derivative order $k$ (ghost points)")
    for k in range(K):
        for n in range(N):
            ax1.text(n, k, f"{factorial(n + k)}", ha="center", va="center",
                     color="white", fontsize=7)
    fig.colorbar(im, ax=ax1, label=r"$\log_{10} F^{(k)}[n]$")

    # Right panel: Maclaurin reconstruction
    base = egf_coeffs(L, 2 * K)
    recovered = [int(iterate_derivative(base, k)[0]) for k in range(K)]
    truth = [factorial(k) for k in range(K)]
    naive = [factorial(k) * recovered[k] for k in range(K)]  # ordinary-GF artefact

    ks = list(range(K))
    ax2.semilogy(ks, truth, "o-", label=r"true count $F[k]=k!$", lw=2)
    ax2.semilogy(ks, recovered, "x--", ms=10,
                 label=r"coeff$_0(D^k\,$EGF$)$ (matches!)")
    ax2.semilogy(ks, naive, "s:", color="crimson", alpha=0.7,
                 label=r"$k!\cdot$coeff$_0$ (ordinary-GF artefact)")
    ax2.set_title("Maclaurin reconstruction\nthe EGF $1/n!$ cancels the $k!$")
    ax2.set_xlabel(r"derivative order $k$")
    ax2.set_ylabel("value (log scale)")
    ax2.legend()
    ax2.grid(True, which="both", alpha=0.3)

    fig.suptitle("The Taylor / Maclaurin Calculus of Combinatorial Species",
                 fontsize=14, fontweight="bold")
    fig.tight_layout(rect=(0, 0, 1, 0.95))
    fig.savefig("species_taylor_tower.png", dpi=150)
    print("wrote species_taylor_tower.png")


if __name__ == "__main__":
    main()
