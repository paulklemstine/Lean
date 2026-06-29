"""Visualization: tropical min-cut entropy and its sharp bond-dimension threshold."""
from __future__ import annotations
import numpy as np
import matplotlib.pyplot as plt


def mincut_entropy(area, slope, t):
    return np.min([a + c * t for a, c in zip(area, slope)], axis=0)


def main() -> None:
    area, slope = [4.0, 0.0], [1.0, 3.0]
    t = np.linspace(0.0, 4.0, 600)
    S = mincut_entropy(area, slope, t)
    t_c = (area[0] - area[1]) / (slope[1] - slope[0])
    D_c = np.exp(t_c)

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(12, 4.5))
    for a, c, name in zip(area, slope, ["cut 0 (size 1)", "cut 1 (size 3)"]):
        ax1.plot(t, a + c * t, "--", alpha=0.6, label=name)
    ax1.plot(t, S, "k", lw=2.5, label="S(t) = min envelope")
    ax1.axvline(t_c, color="red", ls=":", label=f"t_c = log D_c = {t_c:.2f}")
    ax1.set_xlabel("t = log D"); ax1.set_ylabel("entanglement entropy S(t)")
    ax1.set_title("Tropical min-cut entropy"); ax1.legend()

    dSdt = np.gradient(S, t)
    ax2.plot(t, dSdt, "b", lw=2)
    ax2.axvline(t_c, color="red", ls=":")
    ax2.set_xlabel("t = log D"); ax2.set_ylabel("scaling exponent dS/dt")
    ax2.set_title(f"First-order jump at D_c = {D_c:.3f}")
    fig.tight_layout(); fig.savefig("threshold.png", dpi=150)
    print("saved threshold.png")


if __name__ == "__main__":
    main()
