"""Visualization: the residue torus as a clock (cyclic group Z/(p^f-1)Z)."""
import numpy as np
import matplotlib.pyplot as plt

def draw_clock(ax, m: int, title: str) -> None:
    ax.set_aspect("equal")
    ax.axis("off")
    ax.set_title(title, fontsize=10)
    if m == 0:
        ax.plot(0, 0, "o", color="crimson", ms=10)
        ax.text(0, -0.3, "trivial group", ha="center", fontsize=8)
        return
    ang = np.linspace(0, 2 * np.pi, m, endpoint=False)
    xs, ys = np.cos(ang), np.sin(ang)
    circ = plt.Circle((0, 0), 1, fill=False, color="gray", lw=0.8)
    ax.add_patch(circ)
    ax.plot(xs, ys, "o", color="steelblue", ms=8)
    for k, (x, y) in enumerate(zip(xs, ys)):
        ax.text(1.18 * x, 1.18 * y, f"g^{k}", ha="center", va="center",
                fontsize=7)
    ax.set_xlim(-1.4, 1.4); ax.set_ylim(-1.4, 1.4)

fig, axes = plt.subplots(1, 3, figsize=(12, 4))
draw_clock(axes[0], 2 ** 2 - 1, "(p,f)=(2,2): Z/3")
draw_clock(axes[1], 2 ** 1 - 1, "(p,f)=(2,1): trivial")
draw_clock(axes[2], 5 ** 2 - 1, "(p,f)=(5,2): Z/24")
plt.suptitle("Residue tori as cyclic clocks of order p^f - 1")
plt.tight_layout()
plt.savefig("residue_torus_clocks.png", dpi=150)
print("wrote residue_torus_clocks.png")
