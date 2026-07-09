"""Visualization 2 -- Solvability heatmap over group orders and orbit sizes."""
import matplotlib.pyplot as plt
import numpy as np

def solvability_grid(max_order: int = 8) -> None:
    orders = np.arange(1, max_order + 1)
    grid = np.zeros((max_order, max_order))
    for i, g in enumerate(orders):        # group order (proxy for symmetry)
        for j, orbit in enumerate(orders):  # typical orbit size
            grid[i, j] = 1.0 if orbit == 1 else 0.0  # solvable iff singletons
    fig, ax = plt.subplots(figsize=(6, 5))
    im = ax.imshow(grid, origin="lower", cmap="RdYlGn",
                   extent=[0.5, max_order + 0.5, 0.5, max_order + 0.5])
    ax.set_xlabel("orbit size"); ax.set_ylabel("group order")
    ax.set_title("Task solvable (green) iff every orbit is a singleton")
    fig.colorbar(im, label="solvable")
    plt.tight_layout(); plt.savefig("viz_solvability.png", dpi=150)

if __name__ == "__main__":
    solvability_grid()
