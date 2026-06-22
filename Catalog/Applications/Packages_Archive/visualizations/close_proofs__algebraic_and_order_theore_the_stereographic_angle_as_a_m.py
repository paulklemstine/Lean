"""Visualization: the stereographic angle Theta(t) = 2*arctan(t).

Plots Theta and highlights its strict monotonicity, the horizontal asymptotes at
+-pi, and the inflection at t=0 separating the convex (t<0) and concave (t>0)
branches. Requires matplotlib.
"""
import math
import matplotlib.pyplot as plt


def theta(t: float) -> float:
    return 2 * math.atan(t)


ts = [(-60 + i) / 10 for i in range(121)]
fig, ax = plt.subplots(figsize=(8, 5))
ax.plot(ts, [theta(t) for t in ts], "b-", lw=2, label=r"$\Theta(t)=2\arctan t$")
ax.axhline(math.pi, color="gray", ls="--", lw=0.8)
ax.axhline(-math.pi, color="gray", ls="--", lw=0.8)
ax.axvline(0, color="red", ls=":", lw=1, label="inflection at t=0")
ax.annotate(r"$+\pi$", (5.5, math.pi - 0.15))
ax.annotate(r"$-\pi$", (5.5, -math.pi + 0.05))
ax.set_xlabel("stereographic address t")
ax.set_ylabel(r"angle $\Theta(t)$")
ax.set_title("Stereographic angle: monotone order embedding with half-line concavity")
ax.legend()
ax.grid(alpha=0.3)
plt.savefig("stereographic_angle.png", dpi=150, bbox_inches="tight")
print("saved stereographic_angle.png")
