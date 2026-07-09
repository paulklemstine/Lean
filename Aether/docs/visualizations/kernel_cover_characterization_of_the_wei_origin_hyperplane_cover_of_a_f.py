"""Draw the hyperplanes (lines through the origin) that cover F_p^2 in the
finite-field instance with weight set F_p^*."""
import matplotlib.pyplot as plt

p = 5
pts = [(a, b) for a in range(p) for b in range(p)]
fig, ax = plt.subplots(figsize=(6, 6))
# Each non-zero functional (c1, c2) has kernel { x : c1 x1 + c2 x2 = 0 }.
functionals = [(c1, c2) for c1 in range(p) for c2 in range(p)
               if (c1, c2) != (0, 0)]
colors = plt.cm.tab10.colors
for idx, (c1, c2) in enumerate(functionals[:p + 1]):
    ker = [(a, b) for (a, b) in pts if (c1 * a + c2 * b) % p == 0]
    xs, ys = zip(*ker)
    ax.scatter(xs, ys, s=140, alpha=0.35, color=colors[idx % len(colors)],
               label=f"ker({c1},{c2})")
ax.scatter(*zip(*pts), s=10, color="black")
ax.set_title(f"Origin-hyperplanes covering F_{p}^2")
ax.set_xlabel("x1"); ax.set_ylabel("x2")
ax.legend(fontsize=7, loc="upper right"); ax.set_aspect("equal")
plt.tight_layout(); plt.savefig("hyperplane_cover.png", dpi=150)
print("wrote hyperplane_cover.png")
