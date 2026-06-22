"""Heatmap of the LP connective tables (conj=min, disj=max) and the
negation involution, rendered with matplotlib."""
import matplotlib.pyplot as plt
import numpy as np

NAMES = ["ff", "bb", "tt"]  # indices 0,1,2 in truth order

def conj(a: int, b: int) -> int:
    return min(a, b)

def disj(a: int, b: int) -> int:
    return max(a, b)

def neg(a: int) -> int:
    return {2: 0, 1: 1, 0: 2}[a]

fig, axes = plt.subplots(1, 3, figsize=(13, 4))

for ax, (title, op) in zip(
        axes[:2], [("conjunction  (min)", conj), ("disjunction  (max)", disj)]):
    M = np.array([[op(a, b) for b in range(3)] for a in range(3)])
    ax.imshow(M, cmap="viridis", vmin=0, vmax=2)
    ax.set_xticks(range(3)); ax.set_xticklabels(NAMES)
    ax.set_yticks(range(3)); ax.set_yticklabels(NAMES)
    for i in range(3):
        for j in range(3):
            ax.text(j, i, NAMES[M[i, j]], ha="center", va="center",
                    color="white", fontsize=13, fontweight="bold")
    ax.set_title(title)

ax = axes[2]
N = np.array([[neg(a)] for a in range(3)])
ax.imshow(N, cmap="plasma", vmin=0, vmax=2)
ax.set_xticks([0]); ax.set_xticklabels(["~a"])
ax.set_yticks(range(3)); ax.set_yticklabels(NAMES)
for i in range(3):
    ax.text(0, i, NAMES[neg(i)], ha="center", va="center",
            color="white", fontsize=13, fontweight="bold")
ax.set_title("negation  (bb is a fixpoint)")

plt.suptitle("The De Morgan algebra of LP  (ff < bb < tt)", fontsize=15)
plt.tight_layout()
plt.savefig("lp_tables.png", dpi=150)
print("wrote lp_tables.png")
