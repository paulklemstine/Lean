"""Heatmap-style visualization of the contragredient sign (-1)^{b(F,n)}.

Produces, for fixed parity classes of (r1, r2), a grid showing the sign as a
function of n (columns) and the field-parity class (rows), making the n mod 4
trichotomy visually obvious.  Saves 'contra_sign_grid.png'.
"""
from __future__ import annotations
import numpy as np
import matplotlib.pyplot as plt


def bottom_degree(n: int, r1: int, r2: int) -> int:
    return r1 * (n * n // 4) + r2 * (n * (n - 1) // 2)


def sign(n: int, r1: int, r2: int) -> int:
    return -1 if bottom_degree(n, r1, r2) % 2 else 1


n_vals = list(range(2, 26))
# Four field-parity classes (r1%2, r2%2).
classes = [(0, 0), (1, 0), (0, 1), (1, 1)]
labels = [f"(r1,r2)≡{c} (mod 2)" for c in classes]

grid = np.array([[sign(n, r1, r2) for n in n_vals] for (r1, r2) in classes])

fig, ax = plt.subplots(figsize=(12, 3.5))
im = ax.imshow(grid, cmap="RdBu", vmin=-1, vmax=1, aspect="auto")
ax.set_xticks(range(len(n_vals)))
ax.set_xticklabels(n_vals)
ax.set_yticks(range(len(classes)))
ax.set_yticklabels(labels)
ax.set_xlabel("n")
ax.set_title("Contragredient sign  (-1)^{b(F,n)}   (blue = +1, red = -1)")
for i in range(len(classes)):
    for j, n in enumerate(n_vals):
        ax.text(j, i, "+" if grid[i, j] == 1 else "-",
                ha="center", va="center", fontsize=8)
plt.colorbar(im, ax=ax, ticks=[-1, 1], label="sign")
plt.tight_layout()
plt.savefig("contra_sign_grid.png", dpi=150)
print("Saved contra_sign_grid.png")
