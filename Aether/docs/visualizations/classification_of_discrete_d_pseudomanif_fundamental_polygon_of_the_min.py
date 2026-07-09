"""Visualization: the minimal RP^2 as a hexagon with antipodal identification.

Draws the standard fundamental-polygon picture of the real projective plane:
a hexagon whose opposite boundary points are identified, overlaid with the
labels of the six-vertex minimal triangulation.
"""
import matplotlib.pyplot as plt
import numpy as np

fig, ax = plt.subplots(figsize=(6, 6))
n = 6
angles = np.linspace(np.pi / 2, np.pi / 2 + 2 * np.pi, n, endpoint=False)
pts = np.c_[np.cos(angles), np.sin(angles)]
labels = [0, 1, 2, 3, 4, 5]

# boundary hexagon with antipodal edge identification arrows
for i in range(n):
    j = (i + 1) % n
    ax.plot([pts[i, 0], pts[j, 0]], [pts[i, 1], pts[j, 1]], "k-", lw=2)
for i in range(n // 2):
    mid1 = (pts[i] + pts[(i + 1) % n]) / 2
    mid2 = (pts[i + 3] + pts[(i + 4) % n]) / 2
    ax.annotate("", xy=mid1 * 1.12, xytext=(0, 0),
                arrowprops=dict(arrowstyle="->", color="crimson"))
    ax.annotate("", xy=mid2 * 1.12, xytext=(0, 0),
                arrowprops=dict(arrowstyle="->", color="crimson"))

for p, lab in zip(pts, labels):
    ax.plot(*p, "o", color="navy", ms=12)
    ax.annotate(str(lab), p * 1.18, ha="center", va="center", fontsize=13)

ax.set_title("Real projective plane $\\mathbb{RP}^2$\n"
             "(hexagon with antipodal identification; f-vector (6,15,10))")
ax.set_aspect("equal"); ax.axis("off")
plt.tight_layout()
plt.savefig("rp2_fundamental_polygon.png", dpi=150)
print("saved rp2_fundamental_polygon.png")
