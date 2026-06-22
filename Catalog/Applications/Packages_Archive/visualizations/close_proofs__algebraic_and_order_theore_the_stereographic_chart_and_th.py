"""Visualization: the stereographic chart and the addition law on S^1.

Generates a figure showing the unit circle, several projected points sigma(t),
the projection rays from the north pole, and a rotation realized via stereoAdd.
Requires matplotlib.
"""
import math
import matplotlib.pyplot as plt


def inv_stereo(t: float) -> tuple[float, float]:
    d = 1 + t * t
    return (2 * t / d, (1 - t * t) / d)


def stereo_add(t: float, s: float) -> float:
    return (t + s) / (1 - t * s)


fig, ax = plt.subplots(figsize=(7, 7))
theta = [i * 2 * math.pi / 400 for i in range(401)]
ax.plot([math.cos(a) for a in theta], [math.sin(a) for a in theta],
        "k-", lw=1, label="unit circle S^1")

pole = (0.0, -1.0)
for t in [-2.0, -0.5, 0.5, 1.0, 2.0]:
    x, y = inv_stereo(t)
    ax.plot([pole[0], x], [pole[1], y], "c--", lw=0.7)
    ax.plot(x, y, "bo")
    ax.annotate(f"t={t}", (x, y), textcoords="offset points", xytext=(6, 6))

# Demonstrate rotation: take t=0.5, rotate by s=0.5 -> address stereo_add(0.5,0.5)
t, s = 0.5, 0.5
p = inv_stereo(t)
pr = inv_stereo(stereo_add(t, s))
ax.annotate("", xy=pr, xytext=p,
            arrowprops=dict(arrowstyle="->", color="red", lw=2))
ax.plot(*pr, "rs", label="rotated via stereoAdd")

ax.plot(*pole, "k^", label="north pole (point at infinity)")
ax.set_aspect("equal")
ax.set_title("Stereographic chart and the addition law")
ax.legend(loc="upper right")
ax.grid(alpha=0.3)
plt.savefig("stereographic_chart.png", dpi=150, bbox_inches="tight")
print("saved stereographic_chart.png")
