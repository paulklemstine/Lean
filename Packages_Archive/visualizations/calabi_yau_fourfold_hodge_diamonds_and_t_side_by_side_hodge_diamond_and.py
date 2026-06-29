"""Visualization: the Calabi-Yau fourfold Hodge diamond and its mirror,
side by side, with the h11 <-> h31 exchange highlighted."""
import matplotlib.pyplot as plt
import numpy as np

def diamond_entry(h11, h21, h31, h22, p, q):
    table = {(0,0):1,(4,4):1,(0,4):1,(4,0):1,(1,1):h11,(3,3):h11,
             (3,1):h31,(1,3):h31,(2,2):h22,(2,1):h21,(1,2):h21,
             (2,3):h21,(3,2):h21}
    return table.get((p, q), 0)

def draw(ax, h11, h21, h31, h22, title):
    for p in range(5):
        for q in range(5):
            v = diamond_entry(h11, h21, h31, h22, p, q)
            # rotate (p,q) into the rhombus layout
            x = (q - p)
            y = -(p + q)
            color = "#ffd166" if (p, q) in [(1,1),(3,3),(3,1),(1,3)] else "#90caf9"
            if v == 0:
                color = "#eeeeee"
            ax.scatter(x, y, s=620, c=color, edgecolors="k", zorder=2)
            ax.text(x, y, str(v), ha="center", va="center", fontsize=9, zorder=3)
    ax.set_title(title)
    ax.set_aspect("equal")
    ax.axis("off")

fig, axes = plt.subplots(1, 2, figsize=(11, 6))
draw(axes[0], 3, 2, 5, 100, "X:  (h11=3, h21=2, h31=5, h22=100)")
draw(axes[1], 5, 2, 3, 100, "mirror X = swap:  (h11=5, h21=2, h31=3, h22=100)")
chi = 4 + 2*3 + 2*5 + 100 - 4*2
fig.suptitle(f"Calabi-Yau fourfold mirror: h11 <-> h31, chi = {chi} preserved",
             fontsize=13)
plt.tight_layout()
plt.savefig("cy4_mirror_diamond.png", dpi=150)
print("saved cy4_mirror_diamond.png")
