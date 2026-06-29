"""
Visualization: the energy line wrapped onto S^1 and the RG flow toward the IR pole.
Generates 'inverse_stereo_rg_flow.png'. Requires matplotlib + numpy.
"""
from __future__ import annotations
from typing import Tuple
import numpy as np
import matplotlib.pyplot as plt


def inv_stereo(t: np.ndarray) -> Tuple[np.ndarray, np.ndarray]:
    d = 1.0 + t * t
    return 2.0 * t / d, (1.0 - t * t) / d


def main() -> None:
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(13, 6))

    # Left: the wrapping map sigma : R -> S^1
    theta = np.linspace(0, 2 * np.pi, 400)
    ax1.plot(np.cos(theta), np.sin(theta), color="#cccccc", lw=1)
    ts = np.linspace(-6, 6, 25)
    xs, ys = inv_stereo(ts)
    sc = ax1.scatter(xs, ys, c=ts, cmap="viridis", s=40, zorder=3)
    ax1.scatter([0], [1], color="crimson", s=90, zorder=5, label="UV pole (0,1)=σ(0)")
    ax1.scatter([0], [-1], color="navy", s=90, marker="s", zorder=5,
                label="IR pole (0,−1) = lim σ(t)")
    ax1.set_aspect("equal")
    ax1.set_title("Energy line ℝ wrapped onto the energy sphere S¹  (σ)")
    ax1.legend(loc="lower center", fontsize=8)
    fig.colorbar(sc, ax=ax1, label="energy scale t")

    # Right: RG orbit streaming UV -> IR
    ax2.plot(np.cos(theta), np.sin(theta), color="#cccccc", lw=1)
    lam, t0 = 1.6, 0.15
    ns = np.arange(0, 22)
    ox, oy = inv_stereo((lam ** ns) * t0)
    ax2.plot(ox, oy, "-o", color="#1f77b4", ms=5, lw=1.2, zorder=3)
    for n in [0, 4, 8, 12, 18]:
        ax2.annotate(f"n={n}", (ox[n], oy[n]), fontsize=8,
                     xytext=(6, 6), textcoords="offset points")
    ax2.scatter([0], [1], color="crimson", s=90, zorder=5)
    ax2.scatter([0], [-1], color="navy", s=90, marker="s", zorder=5)
    ax2.set_aspect("equal")
    ax2.set_title(f"RG orbit (RG_λ)ⁿσ(t₀) = σ(λⁿt₀),  λ={lam}, t₀={t0}")

    fig.suptitle("Inverse Stereographic Renormalization: flow from UV to IR pole",
                 fontsize=13)
    fig.tight_layout()
    fig.savefig("inverse_stereo_rg_flow.png", dpi=140)
    print("wrote inverse_stereo_rg_flow.png")


if __name__ == "__main__":
    main()
