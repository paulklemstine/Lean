"""Visualization: stereographic attention on the Riemann sphere and its sparsity.

Generates a 3-panel figure (saved to stereographic_attention.png):
  (a) the Cauchy kernel K(q,k) = 1/(1+||q-k||^2) as a 2D heatmap around a query;
  (b) the active-region radius rho(tau) = sqrt(1/tau - 1) vs threshold tau;
  (c) the 1D stereographic lift of the real line onto the unit circle, colored by
      the Cauchy score against the origin (= chordal distance to the north pole).
Requires numpy and matplotlib.
"""
from __future__ import annotations

import numpy as np
import matplotlib.pyplot as plt


def main() -> None:
    fig, axes = plt.subplots(1, 3, figsize=(16, 5))

    # (a) Cauchy kernel heatmap around query at origin.
    g = np.linspace(-4, 4, 400)
    X, Y = np.meshgrid(g, g)
    K = 1.0 / (1.0 + X ** 2 + Y ** 2)
    im = axes[0].contourf(X, Y, K, levels=30, cmap="magma")
    for tau in (0.5, 0.2, 0.1):
        rho = np.sqrt(1.0 / tau - 1.0)
        th = np.linspace(0, 2 * np.pi, 200)
        axes[0].plot(rho * np.cos(th), rho * np.sin(th), "c--", lw=1)
        axes[0].text(0, rho, f" tau={tau}", color="cyan", fontsize=8, va="bottom")
    axes[0].set_title("(a) Cauchy kernel K(q,k); dashed = active balls")
    axes[0].set_aspect("equal")
    fig.colorbar(im, ax=axes[0], fraction=0.046)

    # (b) active radius vs threshold.
    tau = np.linspace(0.01, 1.0, 300)
    axes[1].plot(tau, np.sqrt(1.0 / tau - 1.0), "b-")
    axes[1].set_xlabel("threshold tau")
    axes[1].set_ylabel("active radius sqrt(1/tau - 1)")
    axes[1].set_title("(b) active region shrinks as tau -> 1")
    axes[1].grid(True, alpha=0.3)

    # (c) stereographic lift of the real line onto the unit circle.
    x = np.linspace(-6, 6, 600)
    t = x ** 2
    Px = (2.0 / (1.0 + t)) * x          # horizontal part (1D)
    H = (t - 1.0) / (t + 1.0)           # height
    score = 1.0 / (1.0 + t)             # K(x, 0)
    sc = axes[2].scatter(Px, H, c=score, cmap="viridis", s=8)
    th = np.linspace(0, 2 * np.pi, 200)
    axes[2].plot(np.cos(th), np.sin(th), "k-", lw=0.5, alpha=0.4)
    axes[2].plot(0, 1, "r*", ms=14, label="north pole N")
    axes[2].set_title("(c) lift of R onto the circle, colored by K(x,0)")
    axes[2].set_aspect("equal")
    axes[2].legend()
    fig.colorbar(sc, ax=axes[2], fraction=0.046)

    fig.tight_layout()
    fig.savefig("stereographic_attention.png", dpi=130)
    print("saved stereographic_attention.png")


if __name__ == "__main__":
    main()
