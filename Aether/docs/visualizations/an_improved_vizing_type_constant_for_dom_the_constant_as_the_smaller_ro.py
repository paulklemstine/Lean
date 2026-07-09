"""Visualization 1: the quadratic 9x^2 - 19x + 8 and its roots, with the
Clark-Suen line x=1/2 and the Vizing line x=1 marked."""
import numpy as np
import matplotlib.pyplot as plt
from math import sqrt

x = np.linspace(0.2, 1.7, 400)
y = 9 * x**2 - 19 * x + 8
c = (19 - sqrt(73)) / 18
c_plus = (19 + sqrt(73)) / 18

fig, ax = plt.subplots(figsize=(8, 5))
ax.axhline(0, color="gray", lw=0.8)
ax.plot(x, y, lw=2, label=r"$9x^2 - 19x + 8$")
ax.scatter([c, c_plus], [0, 0], color="crimson", zorder=5)
ax.annotate(r"$c=\frac{19-\sqrt{73}}{18}\approx0.5809$", (c, 0),
            textcoords="offset points", xytext=(-10, 30),
            arrowprops=dict(arrowstyle="->"))
ax.axvline(0.5, ls="--", color="green", label="Clark-Suen $1/2$")
ax.axvline(1.0, ls="--", color="purple", label="Vizing $1$")
ax.set_xlabel("x")
ax.set_ylabel("value")
ax.set_title("The improved constant as the smaller root of $9x^2-19x+8$")
ax.legend()
plt.tight_layout()
plt.savefig("constant_quadratic.png", dpi=150)
print("saved constant_quadratic.png")
