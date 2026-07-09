"""Visualize the descent of the Collapse Principle: k observers -> 2."""
import matplotlib.pyplot as plt

k = 6  # start with 6 genuine observers
stages = list(range(k, 1, -1))  # 6,5,4,3,2 : peel until two remain
fig, ax = plt.subplots(figsize=(8, 4))
for i, n in enumerate(stages):
    ax.scatter([i] * n, range(n), s=140, color="tab:purple", zorder=3)
    ax.scatter([i], [-1.2], s=260, marker="s", color="tab:green", zorder=3)  # consensus
    ax.text(i, -2.1, "τ", ha="center", color="tab:green")
    if i + 1 < len(stages):
        ax.annotate("", xy=(i + 1, 0), xytext=(i, 0),
                    arrowprops=dict(arrowstyle="->", color="gray"))
ax.set_xticks(range(len(stages)))
ax.set_xticklabels([f"{n} obs." for n in stages])
ax.set_title("Grouping observers preserves the consensus τ until exactly two remain")
ax.set_yticks([]); ax.set_ylim(-2.6, k)
plt.tight_layout(); plt.savefig("collapse.png", dpi=150); print("wrote collapse.png")
