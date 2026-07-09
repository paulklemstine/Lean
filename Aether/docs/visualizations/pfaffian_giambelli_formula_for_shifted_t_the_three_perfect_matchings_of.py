"""Visualize the three perfect matchings of {0,1,2,3} that make up the
4x4 Pfaffian, with their signs +,-,+. Requires matplotlib."""
import matplotlib.pyplot as plt
import numpy as np

matchings = [([(0, 1), (2, 3)], "+"), ([(0, 2), (1, 3)], "-"), ([(0, 3), (1, 2)], "+")]
labels = ["A01*A23", "A02*A13", "A03*A12"]
pos = {k: (np.cos(np.pi / 2 - k * np.pi / 2), np.sin(np.pi / 2 - k * np.pi / 2)) for k in range(4)}

fig, axes = plt.subplots(1, 3, figsize=(12, 4))
for ax, (pairs, sign), lab in zip(axes, matchings, labels):
    for k, (x, y) in pos.items():
        ax.scatter([x], [y], s=600, color="#2c3e50", zorder=3)
        ax.text(x, y, str(k), color="white", ha="center", va="center", fontsize=14, zorder=4)
    for (i, j) in pairs:
        xi, yi = pos[i]; xj, yj = pos[j]
        ax.plot([xi, xj], [yi, yj], lw=3, color="#e74c3c" if sign == "-" else "#27ae60")
    ax.set_title(f"{sign} {lab}", fontsize=14)
    ax.set_xlim(-1.5, 1.5); ax.set_ylim(-1.5, 1.5); ax.axis("off")

fig.suptitle("Pf4(A) = A01*A23 - A02*A13 + A03*A12  (the three perfect matchings)", fontsize=13)
plt.tight_layout()
plt.savefig("pfaffian_matchings.png", dpi=150)
print("saved pfaffian_matchings.png")
