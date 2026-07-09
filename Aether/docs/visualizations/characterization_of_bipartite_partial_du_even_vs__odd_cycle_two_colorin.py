"""Visualize the parity obstruction: alternating 2-coloring succeeds on an
even cycle and clashes on an odd cycle."""
import math
import matplotlib.pyplot as plt

def draw_cycle(ax, n, title):
    pts = [(math.cos(2 * math.pi * k / n), math.sin(2 * math.pi * k / n))
           for k in range(n)]
    colors = ["#d62728" if k % 2 else "#1f77b4" for k in range(n)]
    for k in range(n):
        a, b = pts[k], pts[(k + 1) % n]
        clash = colors[k] == colors[(k + 1) % n]
        ax.plot([a[0], b[0]], [a[1], b[1]],
                color="black" if not clash else "orange",
                lw=3 if clash else 1.5, zorder=1)
    for (x, y), c in zip(pts, colors):
        ax.scatter([x], [y], s=400, c=c, edgecolors="k", zorder=2)
    ax.set_title(title)
    ax.set_aspect("equal"); ax.axis("off")

fig, axes = plt.subplots(1, 2, figsize=(10, 5))
draw_cycle(axes[0], 6, "C_6 (even): consistent 2-coloring")
draw_cycle(axes[1], 5, "C_5 (odd): forced clash")
plt.tight_layout(); plt.savefig("parity_dichotomy.png", dpi=150)
print("wrote parity_dichotomy.png")
