"""Visualize a Hodge diamond and its mirror as heatmaps."""
import matplotlib.pyplot as plt
import numpy as np


def diamond_grid(n, h):
    return np.array([[h(p, q) for q in range(n + 1)] for p in range(n + 1)])


# Quintic Calabi-Yau threefold (n = 3)
quintic = [[1, 0, 0, 1],
           [0, 1, 101, 0],
           [0, 101, 1, 0],
           [1, 0, 0, 1]]
n = 3
h = lambda p, q: quintic[p][q]
hm = lambda p, q: quintic[n - p][q]

G = diamond_grid(n, h)
Gm = diamond_grid(n, hm)

fig, axes = plt.subplots(1, 2, figsize=(10, 4.5))
for ax, M, title in [(axes[0], G, "Hodge diamond  h^{p,q}"),
                     (axes[1], Gm, "Mirror  h^{n-p,q}")]:
    im = ax.imshow(M, cmap="viridis")
    ax.set_xlabel("q"); ax.set_ylabel("p"); ax.set_title(title)
    for p in range(n + 1):
        for q in range(n + 1):
            ax.text(q, p, str(M[p, q]), ha="center", va="center", color="white")
    fig.colorbar(im, ax=ax, fraction=0.046)

fig.suptitle("Mirror reflects the rows (p -> n - p); chi flips sign for odd n")
fig.tight_layout()
plt.savefig("hodge_mirror.png", dpi=150)
print("Saved hodge_mirror.png")
