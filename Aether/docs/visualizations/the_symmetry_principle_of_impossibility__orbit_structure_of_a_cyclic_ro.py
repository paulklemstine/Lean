"""Visualization 1 -- Orbit structure of C_n acting on n points."""
import matplotlib.pyplot as plt
import numpy as np

def plot_orbits(n: int = 8, k: int = 1) -> None:
    theta = np.linspace(0, 2 * np.pi, n, endpoint=False)
    x, y = np.cos(theta), np.sin(theta)
    fig, ax = plt.subplots(figsize=(6, 6))
    ax.scatter(x, y, s=200, zorder=3)
    for i in range(n):
        j = (i + k) % n
        ax.annotate("", xy=(x[j], y[j]), xytext=(x[i], y[i]),
                    arrowprops=dict(arrowstyle="->", color="crimson", lw=2))
        ax.text(1.15 * x[i], 1.15 * y[i], str(i), ha="center", va="center")
    ax.set_title(f"C_{n} rotation by {k}: one orbit, no invariant injection")
    ax.set_aspect("equal"); ax.axis("off")
    plt.tight_layout(); plt.savefig("viz_orbits.png", dpi=150)

if __name__ == "__main__":
    plot_orbits()
