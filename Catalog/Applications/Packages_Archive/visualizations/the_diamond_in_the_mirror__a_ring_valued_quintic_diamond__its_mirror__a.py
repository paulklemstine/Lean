"""Visualization: Hodge diamond, its mirror, and the Euler-sign parity dial."""
import matplotlib.pyplot as plt
import numpy as np


def euler_char(n, h):
    return sum((-1) ** (p + q) * h[p][q] for p in range(n + 1) for q in range(n + 1))


def diamond_grid(h, n):
    grid = np.zeros((n + 1, n + 1))
    for p in range(n + 1):
        for q in range(n + 1):
            grid[p][q] = h[p][q]
    return grid


# Quintic threefold diamond (n=3)
n = 3
h = [[0] * 4 for _ in range(4)]
h[0][0] = h[3][3] = h[0][3] = h[3][0] = 1
h[1][1] = h[2][2] = 1
h[2][1] = h[1][2] = 101
hm = [[h[n - p][q] for q in range(4)] for p in range(4)]

fig, axes = plt.subplots(1, 3, figsize=(15, 4.5))
for ax, grid, title in [
    (axes[0], diamond_grid(h, n), f"Quintic X  (chi={euler_char(n, h)})"),
    (axes[1], diamond_grid(hm, n), f"Mirror Y  (chi={euler_char(n, hm)})"),
]:
    im = ax.imshow(grid, cmap="viridis")
    for p in range(n + 1):
        for q in range(n + 1):
            ax.text(q, p, int(grid[p][q]), ha="center", va="center", color="white")
    ax.set_title(title)
    ax.set_xlabel("q"); ax.set_ylabel("p")
    fig.colorbar(im, ax=ax, fraction=0.046)

# Parity dial: euler sign (-1)^n vs functional-equation sign (-1)^{n+1}
ns = np.arange(0, 8)
axes[2].plot(ns, (-1.0) ** ns, "o-", label="mirror Euler sign (-1)^n")
axes[2].plot(ns, (-1.0) ** (ns + 1), "s--", label="Weil FE sign (-1)^{n+1}")
axes[2].axhline(0, color="gray", lw=0.5)
axes[2].set_xlabel("complex dimension n"); axes[2].set_ylabel("sign")
axes[2].set_title("Parity dial: odd n flips chi, even n fixes it")
axes[2].legend(); axes[2].set_yticks([-1, 0, 1])

plt.tight_layout()
plt.savefig("mirror_symmetry_diamonds.png", dpi=150)
print("saved mirror_symmetry_diamonds.png")
