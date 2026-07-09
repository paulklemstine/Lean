import numpy as np
import matplotlib.pyplot as plt

def total_log(u):
    return np.where(u > 0.0, np.log(np.where(u > 0.0, u, 1.0)), 0.0)

def rank_one(x, y):
    return np.exp(total_log(x) + total_log(y))

def polarization(x, y):
    return 0.25 * (x + y) ** 2 - 0.25 * (x - y) ** 2

grid = np.linspace(-2.0, 2.0, 400)
X, Y = np.meshgrid(grid, grid)
true = X * Y
err_rank_one = np.abs(rank_one(X, Y) - true)
err_polar = np.abs(polarization(X, Y) - true)

fig, axes = plt.subplots(1, 2, figsize=(12, 5))
for ax, err, title in (
    (axes[0], err_rank_one, "Rank-one exp/log: |error| (fails off positive quadrant)"),
    (axes[1], err_polar, "Polarization: |error| (zero everywhere)"),
):
    im = ax.pcolormesh(X, Y, np.log1p(err), shading="auto", cmap="magma")
    ax.axhline(0, color="white", lw=0.5)
    ax.axvline(0, color="white", lw=0.5)
    ax.set_title(title)
    ax.set_xlabel("x"); ax.set_ylabel("y")
    fig.colorbar(im, ax=ax, label="log(1 + |error|)")
plt.tight_layout()
plt.savefig("eml_ka_error_maps.png", dpi=150)
print("saved eml_ka_error_maps.png")
