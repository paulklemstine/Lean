# Visualization: the two-vertex digon with NO Seymour vertex,
# contrasted with the oriented 3-cycle which has three.
import matplotlib.pyplot as plt

fig, axes = plt.subplots(1, 2, figsize=(9, 4))

# digon a <-> b
ax = axes[0]
ax.annotate("", xy=(1,0.1), xytext=(0,0.1),
            arrowprops=dict(arrowstyle="->", color="crimson", lw=2))
ax.annotate("", xy=(0,-0.1), xytext=(1,-0.1),
            arrowprops=dict(arrowstyle="->", color="crimson", lw=2))
ax.scatter([0,1],[0,0], s=500, c="lightgray", edgecolors="black", zorder=3)
ax.text(0,0,"a",ha="center",va="center"); ax.text(1,0,"b",ha="center",va="center")
ax.set_title("Digon (not oriented): NO Seymour vertex")
ax.set_xlim(-0.5,1.5); ax.set_ylim(-1,1); ax.axis("off")

# oriented 3-cycle
ax = axes[1]
import numpy as np
th = np.linspace(0,2*np.pi,3,endpoint=False)+np.pi/2
xs,ys = np.cos(th),np.sin(th)
for i in range(3):
    j=(i+1)%3
    ax.annotate("", xy=(xs[j],ys[j]), xytext=(xs[i],ys[i]),
                arrowprops=dict(arrowstyle="->", color="teal", lw=2,
                                shrinkA=14, shrinkB=14))
ax.scatter(xs,ys,s=500,c="gold",edgecolors="black",zorder=3)
ax.set_title("Oriented 3-cycle: all 3 are Seymour vertices")
ax.set_aspect("equal"); ax.axis("off")

plt.tight_layout(); plt.savefig("digon_vs_cycle.png", dpi=150)
print("saved digon_vs_cycle.png")
