"""Visualization: the torus as a glued square and as a product of two circles.

Renders (1) the unit square with its opposite-edge identifications marked, and
(2) a 3D doughnut whose surface is colored by the two circle coordinates
(longitude and meridian), making the equivalence T^2 ~= S^1 x S^1 visible.
"""
import numpy as np
import matplotlib.pyplot as plt
from mpl_toolkits.mplot3d import Axes3D  # noqa: F401

fig = plt.figure(figsize=(12, 5))

# (1) The glued square.
ax1 = fig.add_subplot(1, 2, 1)
ax1.add_patch(plt.Rectangle((0, 0), 1, 1, fill=False, lw=2))
ax1.annotate("", xy=(1, 0), xytext=(0, 0), arrowprops=dict(arrowstyle="->", color="C0", lw=3))
ax1.annotate("", xy=(1, 1), xytext=(0, 1), arrowprops=dict(arrowstyle="->", color="C0", lw=3))
ax1.annotate("", xy=(0, 1), xytext=(0, 0), arrowprops=dict(arrowstyle="->", color="C3", lw=3))
ax1.annotate("", xy=(1, 1), xytext=(1, 0), arrowprops=dict(arrowstyle="->", color="C3", lw=3))
ax1.text(0.5, -0.08, "bottom ~ top  (mk_horiz)", ha="center", color="C0")
ax1.text(-0.08, 0.5, "left ~ right  (mk_vert)", va="center", rotation=90, color="C3")
ax1.set_xlim(-0.2, 1.2); ax1.set_ylim(-0.2, 1.2); ax1.set_aspect("equal")
ax1.set_title("Square with opposite edges glued -> Torus")
ax1.axis("off")

# (2) The doughnut colored by (longitude, meridian).
ax2 = fig.add_subplot(1, 2, 2, projection="3d")
R, r = 2.0, 0.8
u = np.linspace(0, 2 * np.pi, 80)   # longitude  = first circle
v = np.linspace(0, 2 * np.pi, 40)   # meridian   = second circle
U, V = np.meshgrid(u, v)
Xc = (R + r * np.cos(V)) * np.cos(U)
Yc = (R + r * np.cos(V)) * np.sin(U)
Zc = r * np.sin(V)
ax2.plot_surface(Xc, Yc, Zc, facecolors=plt.cm.twilight((U) / (2 * np.pi)),
                 rstride=1, cstride=1, antialiased=True, linewidth=0)
ax2.set_title("T^2 = S^1 (longitude) x S^1 (meridian)")
ax2.set_box_aspect((1, 1, 0.5))
ax2.axis("off")

plt.tight_layout()
plt.savefig("torus_equivalence.png", dpi=130)
print("wrote torus_equivalence.png")
