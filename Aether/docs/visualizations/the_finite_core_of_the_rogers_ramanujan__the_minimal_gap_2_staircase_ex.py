"""Visualize the minimal difference->=2 staircase 1+3+5+...+(2k-1)=k^2
that explains the q^{k^2} weights. Requires matplotlib."""
import matplotlib.pyplot as plt

fig, axes = plt.subplots(1, 4, figsize=(12, 3.2))
for ax, k in zip(axes, [1, 2, 3, 4]):
    parts = [2*i - 1 for i in range(1, k + 1)]  # 1,3,5,...
    y = 0
    for p in reversed(parts):          # draw as a Young-like staircase
        for x in range(p):
            ax.add_patch(plt.Rectangle((x, y), 1, 1, edgecolor="black",
                                       facecolor="#DD8452"))
        y += 1
    total = sum(parts)
    ax.set_xlim(0, max(parts) + 1)
    ax.set_ylim(0, k + 1)
    ax.set_aspect("equal")
    ax.set_title(f"k={k}:  {'+'.join(map(str,parts))} = {total} = {k}^2")
    ax.axis("off")
plt.suptitle("Why q^{k^2}: the minimal gap-2 staircase has weight k^2")
plt.tight_layout()
plt.savefig("staircase.png", dpi=150)
print("wrote staircase.png")
