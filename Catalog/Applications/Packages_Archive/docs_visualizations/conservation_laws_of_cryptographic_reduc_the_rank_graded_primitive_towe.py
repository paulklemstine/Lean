"""Visualize the primitive tower as a rank-graded DAG: upgrades go strictly
upward in rank, so every downward arrow is a black-box separation."""
import matplotlib.pyplot as plt

names = ["OWF", "PRG", "PRF", "ENC"]
ranks = [0, 1, 2, 3]

fig, ax = plt.subplots(figsize=(4, 7))
for name, r in zip(names, ranks):
    ax.scatter(0, r, s=900, zorder=3)
    ax.annotate(f"{name}\n(rank {r})", (0, r), ha="center", va="center", zorder=4)
for r in range(3):
    ax.annotate("", xy=(0, r + 1), xytext=(0, r),
                arrowprops=dict(arrowstyle="-|>", lw=2))
ax.annotate("upgrades climb\nrank by +1", (0.15, 1.5), fontsize=9)
ax.set_xlim(-0.6, 0.7)
ax.set_ylim(-0.5, 3.5)
ax.set_ylabel("rank (conserved scalar)")
ax.set_title("The symmetric-key tower\nrank is monotone: no downward construction")
ax.set_xticks([])
plt.tight_layout()
plt.savefig("rank_tower.png", dpi=150)
print("wrote rank_tower.png")
