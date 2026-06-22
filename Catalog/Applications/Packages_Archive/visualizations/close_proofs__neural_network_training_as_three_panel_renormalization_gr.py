"""
Visualization: RG flow of NTK training modes.

Generates a figure with three panels illustrating the renormalization-group
picture of neural-network training:

  (1) Each spectral mode follows the geometric closed form g_i^k v_i.
  (2) Separation of scales: the amplitude ratio of a fast mode to a slow mode
      decays geometrically to zero (the "integrating out" of high-frequency modes).
  (3) The total residual norm flows to the IR fixed point (zero).

Self-contained: requires only numpy and matplotlib.
Run:  python _viz.py   (writes rg_flow.png)
"""

from __future__ import annotations

from typing import Sequence

import numpy as np
import matplotlib.pyplot as plt


def gain(eta: float, lam: float) -> float:
    return 1.0 - eta * lam


def closed_form(eta: float, lam: Sequence[float], v: Sequence[float], k: int) -> np.ndarray:
    g = np.array([gain(eta, l) for l in lam])
    return (g ** k) * np.array(v)


def main() -> None:
    eta = 0.1
    lam = [0.5, 2.0, 5.0, 9.0]        # NTK eigenvalues: slow -> fast
    v = [1.0, 1.0, 1.0, 1.0]
    ks = np.arange(0, 60)

    traj = np.array([closed_form(eta, lam, v, int(k)) for k in ks])  # (K, d)

    fig, axes = plt.subplots(1, 3, figsize=(16, 4.6))

    # Panel 1: per-mode geometric decay.
    ax = axes[0]
    for idx, l in enumerate(lam):
        ax.semilogy(ks, np.abs(traj[:, idx]) + 1e-30,
                    label=f"lam={l}, g={gain(eta, l):.2f}")
    ax.set_title("Per-mode RG flow:  $g_i^k v_i$")
    ax.set_xlabel("training step k")
    ax.set_ylabel("|mode amplitude|")
    ax.legend(fontsize=8)
    ax.grid(True, which="both", alpha=0.3)

    # Panel 2: separation of scales (fastest / slowest).
    ax = axes[1]
    ratio = np.abs(traj[:, -1]) / (np.abs(traj[:, 0]) + 1e-30)
    ax.semilogy(ks, ratio + 1e-30, color="crimson")
    ax.set_title("Separation of scales:  $|x_{fast}|/|x_{slow}| \\to 0$")
    ax.set_xlabel("training step k")
    ax.set_ylabel("amplitude ratio")
    ax.grid(True, which="both", alpha=0.3)

    # Panel 3: total residual norm -> IR fixed point.
    ax = axes[2]
    norm = np.linalg.norm(traj, axis=1)
    ax.semilogy(ks, norm + 1e-30, color="navy")
    ax.set_title("Flow to the IR fixed point:  $\\|x(k)\\| \\to 0$")
    ax.set_xlabel("training step k")
    ax.set_ylabel("residual norm")
    ax.grid(True, which="both", alpha=0.3)

    fig.suptitle("Neural-Network Training as Renormalization-Group Flow", fontsize=14)
    fig.tight_layout(rect=(0, 0, 1, 0.95))
    fig.savefig("rg_flow.png", dpi=130)
    print("wrote rg_flow.png")


if __name__ == "__main__":
    main()
