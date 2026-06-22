"""Visualization: the elementary Gauss-Bonnet floor vs. the true Willmore floor.

Plots b(g) = 4*pi*(1 - g) (the elementary, Gauss-Bonnet-derived lower bound),
the trivial floor 0, and the known/conjectured sharp floors (4*pi for the
sphere, 2*pi^2 for the torus).  Visually demonstrates how the elementary bound
goes vacuous for genus >= 1.
"""
from __future__ import annotations
import math
import matplotlib.pyplot as plt

def main() -> None:
    genera = list(range(0, 6))
    elementary = [4.0 * math.pi * (1 - g) for g in genera]
    trivial = [0.0 for _ in genera]

    fig, ax = plt.subplots(figsize=(9, 6))
    ax.plot(genera, elementary, "o-", color="#c0392b",
            label=r"elementary floor $b(g)=4\pi(1-g)$")
    ax.plot(genera, trivial, "--", color="#7f8c8d", label="trivial floor 0")
    ax.scatter([0], [4 * math.pi], s=120, color="#27ae60", zorder=5,
               label=r"sharp sphere floor $4\pi$")
    ax.scatter([1], [2 * math.pi ** 2], s=120, color="#2980b9", zorder=5,
               label=r"sharp torus floor $2\pi^2$ (Marques-Neves)")
    ax.axhspan(-40, 0, color="#bdc3c7", alpha=0.25)
    ax.annotate("elementary method vacuous here",
                xy=(3, -10), color="#555", fontsize=11)
    ax.set_xlabel("genus g")
    ax.set_ylabel("Willmore energy lower bound")
    ax.set_title("Where the elementary Willmore bound stops working")
    ax.legend()
    ax.grid(alpha=0.3)
    plt.tight_layout()
    plt.savefig("willmore_floors.png", dpi=150)
    print("wrote willmore_floors.png")

if __name__ == "__main__":
    main()