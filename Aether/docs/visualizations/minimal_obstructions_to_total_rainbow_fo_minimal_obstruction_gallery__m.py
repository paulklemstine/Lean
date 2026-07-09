import math
import matplotlib.pyplot as plt

def cycle_pos(n):
    return {i: (math.cos(2*math.pi*i/n), math.sin(2*math.pi*i/n)) for i in range(n)}

PALETTE = ["#e6194B", "#3cb44b", "#4363d8", "#f58231", "#911eb4"]

def draw(ax, pos, edges, title):
    for (u, v), k in edges.items():
        (x1, y1), (x2, y2) = pos[u], pos[v]
        ax.plot([x1, x2], [y1, y2], color=PALETTE[k % len(PALETTE)], lw=3)
    for v, (x, y) in pos.items():
        ax.plot(x, y, "o", color="black", ms=8)
    ax.set_title(title, fontsize=10); ax.axis("equal"); ax.axis("off")

fig, axes = plt.subplots(2, 3, figsize=(11, 7))
# C3, C4, C5 monochromatic (minimal obstructions)
for ax, n in zip(axes[0], (3, 4, 5)):
    pos = cycle_pos(n)
    edges = {(i, (i+1) % n): 0 for i in range(n)}
    draw(ax, pos, edges, f"C_{n} (minimal obstruction)")
# theta graph (non-minimal)
theta_pos = {0:(-1,0), 2:(1,0), 1:(0,1), 3:(0,0), 4:(0,-1)}
theta_edges = {(0,1):0,(1,2):0,(0,3):0,(3,2):0,(0,4):0,(4,2):0}
draw(axes[1][0], theta_pos, theta_edges, "theta (NOT minimal)")
# rainbow triangle (admits TRF)
draw(axes[1][1], cycle_pos(3), {(0,1):0,(1,2):1,(2,0):2}, "rainbow C_3 (admits TRF)")
# two mono triangles different colors (not minimal)
tp = {0:(-1.4,.6),1:(-1.4,-.6),2:(-.6,0),3:(1.4,.6),4:(1.4,-.6),5:(.6,0)}
te = {(0,1):0,(1,2):0,(0,2):0,(3,4):1,(4,5):1,(3,5):1}
draw(axes[1][2], tp, te, "two mono triangles (NOT minimal)")

fig.suptitle("Minimal Obstructions Are Single Monochromatic Cycles", fontsize=13)
plt.tight_layout(); plt.savefig("obstruction_gallery.png", dpi=150)
print("saved obstruction_gallery.png")
