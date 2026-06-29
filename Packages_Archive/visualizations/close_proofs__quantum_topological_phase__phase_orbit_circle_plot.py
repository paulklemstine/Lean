"""Visualization: irrational vs rational phase orbits on the circle."""
from __future__ import annotations
import math
import matplotlib.pyplot as plt


def orbit_points(alpha: float, steps: int):
    """Cartesian coordinates of { n * alpha mod 1 } on the unit circle."""
    xs, ys = [], []
    for n in range(steps):
        theta = 2 * math.pi * ((n * alpha) % 1.0)
        xs.append(math.cos(theta))
        ys.append(math.sin(theta))
    return xs, ys


def main() -> None:
    fig, axes = plt.subplots(1, 2, figsize=(10, 5))
    circle_t = [2 * math.pi * i / 400 for i in range(401)]

    for ax, (alpha, label, steps) in zip(
        axes,
        [(math.sqrt(2), "irrational sqrt(2): dense", 400),
         (4 / 5, "rational 4/5: finite (order 5)", 400)],
    ):
        ax.plot([math.cos(t) for t in circle_t],
                [math.sin(t) for t in circle_t], lw=0.5, color="lightgray")
        xs, ys = orbit_points(alpha, steps)
        ax.scatter(xs, ys, s=8)
        ax.set_aspect("equal")
        ax.set_title(label)
        ax.axis("off")

    fig.suptitle("Phase-gate orbits on the torus R/Z (density dichotomy)")
    fig.tight_layout()
    fig.savefig("phase_orbits.png", dpi=150)
    print("wrote phase_orbits.png")


if __name__ == "__main__":
    main()
