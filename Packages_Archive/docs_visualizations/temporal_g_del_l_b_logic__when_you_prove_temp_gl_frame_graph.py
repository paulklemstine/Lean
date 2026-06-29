import matplotlib.pyplot as plt
from typing import Dict, Tuple

pos: Dict[int, Tuple[float, float]] = {0: (0, 1), 1: (2, 1), 2: (1, 0)}
R = [(0, 2)]                       # today (0) sees counterexample stage 2
T = [(0, 1)]                       # today precedes tomorrow (1)

fig, ax = plt.subplots(figsize=(6, 5))
for w, (x, y) in pos.items():
    label = {0: "today", 1: "tomorrow", 2: "ctrex stage"}[w]
    ax.scatter([x], [y], s=1400, color="#cfe8ff", edgecolors="k", zorder=3)
    ax.text(x, y, f"{w}\n{label}", ha="center", va="center", zorder=4,
            fontsize=9)

for (a, b) in R:
    ax.annotate("", xy=pos[b], xytext=pos[a],
                arrowprops=dict(arrowstyle="-|>", lw=2, color="#1f77b4"))
for (a, b) in T:
    ax.annotate("", xy=pos[b], xytext=pos[a],
                arrowprops=dict(arrowstyle="-|>", lw=2, ls="--",
                                color="#d62728"))
ax.plot([], [], color="#1f77b4", lw=2, label="R (proof accessibility)")
ax.plot([], [], color="#d62728", lw=2, ls="--", label="T (time)")
ax.legend(loc="upper center")
ax.set_title("A temporal GL frame (Theorem 4.4 witness)")
ax.axis("off")
plt.tight_layout()
plt.savefig("temp_gl_frame_graph.png", dpi=150)
print("wrote temp_gl_frame_graph.png")
