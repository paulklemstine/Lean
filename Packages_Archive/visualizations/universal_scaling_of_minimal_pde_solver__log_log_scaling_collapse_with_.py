"""Log-log visualization of the universal g^-1 scaling law and its acceleration.

Generates a figure showing the minimal solver size Nmin vs the spectral gap g on
log-log axes, for the plain contraction (slope -1) and the sqrt-accelerated
contraction (slope -1/2), with the theoretical sandwich band shaded.
"""

from __future__ import annotations

import math
from typing import List

import matplotlib.pyplot as plt
import numpy as np


def Nmin(rho: float, eps: float) -> int:
    n, p = 0, 1.0
    while p > eps:
        p *= rho
        n += 1
    return n


def main() -> None:
    eps = 1e-3
    gaps: np.ndarray = np.logspace(-4, -0.7, 30)
    plain: List[int] = [Nmin(1.0 - g, eps) for g in gaps]
    accel: List[int] = [Nmin(1.0 - math.sqrt(g), eps) for g in gaps]

    lower = [(1 - eps) / g for g in gaps]
    upper = [math.log(1 / eps) / g + 1 for g in gaps]

    fig, ax = plt.subplots(figsize=(8, 6))
    ax.fill_between(gaps, lower, upper, color="tab:blue", alpha=0.15,
                    label=r"sandwich band $[(1-\epsilon)/g,\ \log(1/\epsilon)/g+1]$")
    ax.loglog(gaps, plain, "o-", color="tab:blue",
              label=r"plain  $N_{\min}\sim g^{-1}$")
    ax.loglog(gaps, accel, "s-", color="tab:red",
              label=r"accelerated  $N_{\min}\sim g^{-1/2}$")
    ax.set_xlabel("spectral gap  $g$")
    ax.set_ylabel(r"minimal solver size  $N_{\min}$")
    ax.set_title("Universal scaling of minimal solver size at a spectral phase transition")
    ax.legend()
    ax.grid(True, which="both", ls=":", alpha=0.5)
    fig.tight_layout()
    fig.savefig("solver_scaling.png", dpi=150)
    print("wrote solver_scaling.png")


if __name__ == "__main__":
    main()
