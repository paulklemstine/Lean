"""
Visualization: RG training flow as exponential relaxation onto the relevant
manifold, with universality of the limit.

Generates two panels:
  (left)  3D trajectories of several initializations sharing the same coarse-
          grained class P x0; all glide onto the same fixed point on the
          relevant manifold (the x-y plane).
  (right) Exact exponential decay  ||theta(t) - P x0|| = exp(-t) ||x0 - P x0||
          on a log scale (a straight line of slope -1 = the critical exponent).

Requires: numpy, matplotlib.  Run:  python visualize.py
"""

from __future__ import annotations

import math
from typing import List

import numpy as np
import matplotlib.pyplot as plt
from mpl_toolkits.mplot3d import Axes3D  # noqa: F401


def orthogonal_projector(basis: List[List[float]]) -> np.ndarray:
    """Orthogonal projector P = Q Q^T onto span(basis); idempotent & symmetric."""
    Q, _ = np.linalg.qr(np.array(basis, dtype=float).T)
    return Q @ Q.T


def rg_flow(P: np.ndarray, x0: np.ndarray, t: float) -> np.ndarray:
    """theta(t) = P x0 + exp(-t)(x0 - P x0)."""
    Px0 = P @ x0
    return Px0 + math.exp(-t) * (x0 - Px0)


def main() -> None:
    # Coarse-grain onto the x-y plane (the relevant manifold); z is irrelevant.
    P = orthogonal_projector([[1, 0, 0], [0, 1, 0]])

    # Several initializations in the SAME coarse-grained class (same x,y).
    inits = [
        np.array([1.0, 2.0, 4.0]),
        np.array([1.0, 2.0, -3.0]),
        np.array([1.0, 2.0, 6.0]),
        np.array([1.0, 2.0, -6.0]),
    ]
    Px0 = P @ inits[0]
    ts = np.linspace(0.0, 6.0, 200)

    fig = plt.figure(figsize=(13, 5.5))

    # ---- Left: 3D trajectories -------------------------------------------
    ax = fig.add_subplot(1, 2, 1, projection="3d")
    # the relevant manifold (x-y plane) as a translucent surface
    xx, yy = np.meshgrid(np.linspace(-1, 3, 2), np.linspace(0, 4, 2))
    ax.plot_surface(xx, yy, np.zeros_like(xx), alpha=0.15, color="gray")
    for x0 in inits:
        traj = np.array([rg_flow(P, x0, t) for t in ts])
        ax.plot(traj[:, 0], traj[:, 1], traj[:, 2], lw=2)
        ax.scatter(*x0, s=30)
    ax.scatter(*Px0, color="red", s=80, marker="*", label="fixed point P x0")
    ax.set_title("RG training flow: all classes glide to the same fixed point")
    ax.set_xlabel("relevant 1"); ax.set_ylabel("relevant 2"); ax.set_zlabel("irrelevant")
    ax.legend()

    # ---- Right: exponential relaxation -----------------------------------
    ax2 = fig.add_subplot(1, 2, 2)
    for x0 in inits:
        dist = [np.linalg.norm(rg_flow(P, x0, t) - Px0) for t in ts]
        ax2.semilogy(ts, dist, lw=2, label=f"x0={x0.tolist()}")
    # reference line exp(-t)*d0 (slope -1 in log scale)
    d0 = np.linalg.norm(inits[0] - Px0)
    ax2.semilogy(ts, d0 * np.exp(-ts), "k--", lw=1, label="exp(-t)·d0 (theory)")
    ax2.set_title("Exact exponential decay (critical exponent = 1)")
    ax2.set_xlabel("training time t")
    ax2.set_ylabel("||theta(t) - P x0||  (log scale)")
    ax2.legend(fontsize=8)
    ax2.grid(True, which="both", alpha=0.3)

    fig.tight_layout()
    fig.savefig("rg_flow_visualization.png", dpi=150)
    print("Saved rg_flow_visualization.png")


if __name__ == "__main__":
    main()
