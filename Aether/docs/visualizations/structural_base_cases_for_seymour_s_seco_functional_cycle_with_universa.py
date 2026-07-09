# Visualization: a functional directed cycle, highlighting that every
# vertex is a Seymour vertex.
import matplotlib.pyplot as plt
import numpy as np

n = 7
theta = np.linspace(0, 2*np.pi, n, endpoint=False)
xs, ys = np.cos(theta), np.sin(theta)
fig, ax = plt.subplots(figsize=(5,5))
for i in range(n):
    j = (i+1) % n
    ax.annotate("", xy=(xs[j], ys[j]), xytext=(xs[i], ys[i]),
                arrowprops=dict(arrowstyle="->", color="teal", lw=2,
                                shrinkA=12, shrinkB=12))
ax.scatter(xs, ys, s=600, c="gold", edgecolors="black", zorder=3)
for i in range(n):
    ax.text(xs[i], ys[i], str(i), ha="center", va="center", zorder=4)
ax.set_title(f"Functional {n}-cycle: every vertex is a Seymour vertex")
ax.set_aspect("equal"); ax.axis("off")
plt.tight_layout(); plt.savefig("functional_cycle.png", dpi=150)
print("saved functional_cycle.png")
