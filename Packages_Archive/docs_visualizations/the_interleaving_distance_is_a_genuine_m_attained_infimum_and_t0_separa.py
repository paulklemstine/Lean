"""Visualization: the attained infimum and T0 separation of the interleaving distance.

Generates two panels:
  (left)  the "interleaved?" indicator as a function of slack delta for a fixed
          pair of filtrations, showing the sharp threshold at delta = distance
          (the infimum is ATTAINED -- the threshold itself interleaves);
  (right) interleaving distance vs. a continuous perturbation parameter,
          showing distance = 0 exactly at the unperturbed (equal) filtration
          (T0 separation), and linear 1-Lipschitz growth thereafter.
"""
from __future__ import annotations
import numpy as np
import matplotlib.pyplot as plt


def interleaving_distance(a: float, b: float) -> float:
    # Single-edge filtrations with weights a and b: distance = |a - b| (attained).
    return abs(a - b)


def main() -> None:
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(12, 4.5))

    # Panel 1: threshold at the attained infimum.
    a, b = 1.0, 1.3
    dist = interleaving_distance(a, b)
    deltas = np.linspace(0.0, 0.6, 600)
    interleaved = (deltas >= dist - 1e-9).astype(float)
    ax1.step(deltas, interleaved, where="post", color="#2b6cb0", lw=2)
    ax1.axvline(dist, color="#e53e3e", ls="--", lw=1.5, label=f"distance = {dist:.2f}")
    ax1.scatter([dist], [1.0], color="#e53e3e", zorder=5)
    ax1.set_title("Infimum is ATTAINED: delta = distance interleaves")
    ax1.set_xlabel("interleaving slack  delta")
    ax1.set_ylabel("interleaved?  (1 = yes)")
    ax1.set_yticks([0, 1])
    ax1.legend()
    ax1.grid(alpha=0.3)

    # Panel 2: T0 separation + 1-Lipschitz growth.
    perturb = np.linspace(-0.5, 0.5, 600)
    dists = np.abs(perturb)  # distance from F to F perturbed by t
    ax2.plot(perturb, dists, color="#2b6cb0", lw=2)
    ax2.axvline(0.0, color="#38a169", ls="--", lw=1.5, label="equal filtration")
    ax2.scatter([0.0], [0.0], color="#38a169", zorder=5,
                label="distance 0  <=>  equality")
    ax2.set_title("T0 separation: distance 0 only at equality")
    ax2.set_xlabel("perturbation of one weight")
    ax2.set_ylabel("interleaving distance")
    ax2.legend()
    ax2.grid(alpha=0.3)

    fig.suptitle("Boltzmann Bridge VII: the interleaving distance is a genuine metric")
    fig.tight_layout()
    fig.savefig("interleaving_metric.png", dpi=150)
    print("wrote interleaving_metric.png")


if __name__ == "__main__":
    main()
