"""Draw a co-activation graph and highlight the optimal Phi-cut."""
import itertools
import matplotlib.pyplot as plt
import numpy as np

# Complete co-activation on n=6 variables: every distinct pair is an edge.
n = 6
angles = np.linspace(0, 2 * np.pi, n, endpoint=False)
pos = {i: (np.cos(a), np.sin(a)) for i, a in zip(range(n), angles)}

# Balanced optimal cut A={0,1,2}, B={3,4,5} realizing Phi = floor(36/4) = 9.
A, B = {0, 1, 2}, {3, 4, 5}

fig, ax = plt.subplots(figsize=(6, 6))
for i, j in itertools.combinations(range(n), 2):
    crossing = (i in A) != (j in A)
    ax.plot([pos[i][0], pos[j][0]], [pos[i][1], pos[j][1]],
            color="crimson" if crossing else "lightgray",
            lw=2.0 if crossing else 0.8, zorder=1)
for i in range(n):
    ax.scatter(*pos[i], s=600, color="tomato" if i in A else "cornflowerblue",
               zorder=2, edgecolors="black")
    ax.annotate(str(i), pos[i], ha="center", va="center", zorder=3, fontweight="bold")
ax.set_title("Optimal $\\Phi$-cut of complete co-activation (n=6): "
             "9 crossing edges")
ax.set_aspect("equal")
ax.axis("off")
plt.tight_layout()
plt.savefig("coactivation_cut.png", dpi=150)
print("wrote coactivation_cut.png")
