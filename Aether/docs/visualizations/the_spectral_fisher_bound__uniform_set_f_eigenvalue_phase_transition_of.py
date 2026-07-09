"""
visualization.py -- Visualize the spectrum of the constant-pattern Gram matrix
(k - lam) I + lam J and the phase transition at lam = k.

Generates two panels:
  (left)  the two-point spectrum {k - lam, k + (m-1) lam} as lam sweeps 0..k,
          showing the smallest eigenvalue k - lam crossing zero exactly at lam = k;
  (right) a heatmap of a sample Gram matrix for a uniform family.

Requires matplotlib and numpy.
"""

from __future__ import annotations

import numpy as np
import matplotlib.pyplot as plt


def constant_pattern_spectrum(k: float, lam: float, m: int) -> tuple[float, float]:
    """Eigenvalues of (k - lam) I + lam J of size m: (k - lam, k + (m-1) lam)."""
    return (k - lam, k + (m - 1) * lam)


def main() -> None:
    k = 3.0
    m = 7
    lams = np.linspace(0.0, k, 200)
    small = np.array([constant_pattern_spectrum(k, l, m)[0] for l in lams])
    large = np.array([constant_pattern_spectrum(k, l, m)[1] for l in lams])

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(12, 5))

    ax1.plot(lams, small, label=r"$\lambda_{\min} = k - \lambda$", lw=2, color="crimson")
    ax1.plot(lams, large, label=r"$\lambda_{\max} = k + (m-1)\lambda$", lw=2, color="navy")
    ax1.axhline(0, color="black", lw=0.8, ls="--")
    ax1.axvline(k, color="gray", lw=0.8, ls=":")
    ax1.fill_between(lams, 0, small, where=(small > 0), alpha=0.15, color="green",
                     label="positive definite region")
    ax1.set_xlabel(r"intersection size $\lambda$")
    ax1.set_ylabel("eigenvalue")
    ax1.set_title(f"Spectrum of $(k-\\lambda)I + \\lambda J$  (k={k:.0f}, m={m})")
    ax1.legend()
    ax1.annotate("degeneracy at $\\lambda=k$", xy=(k, 0), xytext=(k - 1.4, 4),
                 arrowprops=dict(arrowstyle="->"))

    # Fano plane Gram matrix (k=3, lam=1, m=7)
    fano = [
        {0, 1, 2}, {0, 3, 4}, {0, 5, 6},
        {1, 3, 5}, {1, 4, 6}, {2, 3, 6}, {2, 4, 5},
    ]
    n = 7
    V = np.array([[1.0 if t in S else 0.0 for t in range(n)] for S in fano])
    G = V @ V.T
    im = ax2.imshow(G, cmap="viridis")
    ax2.set_title("Gram matrix of the Fano plane (k=3, λ=1)")
    ax2.set_xlabel("line index")
    ax2.set_ylabel("line index")
    for i in range(7):
        for j in range(7):
            ax2.text(j, i, int(G[i, j]), ha="center", va="center",
                     color="white" if G[i, j] < 2 else "black")
    fig.colorbar(im, ax=ax2, fraction=0.046)

    plt.tight_layout()
    plt.savefig("hegedus_spectrum.png", dpi=150)
    print("Saved hegedus_spectrum.png")


if __name__ == "__main__":
    main()
