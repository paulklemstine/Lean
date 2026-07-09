"""Visualization: curvature profiles along the two coordinate axes."""
from __future__ import annotations
import math
import numpy as np
import matplotlib.pyplot as plt

def sech(t: float) -> float:
    return 1.0 / math.cosh(t)

ts = np.linspace(-2.5, 2.5, 500)
kx = [-math.tanh(t) ** 2 for t in ts]
ky = [-math.cosh(t) ** 2 + 2 * sech(t) ** 2 - 1 for t in ts]

plt.figure(figsize=(8, 5))
plt.plot(ts, kx, label="K(x, 0) = -tanh^2(x)")
plt.plot(ts, ky, label="K(0, y) = -cosh^2(y) + 2 sech^2(y) - 1")
plt.axhline(0.0, color="gray", lw=0.8)
plt.title("Curvature along the axes: both nonpositive, so no elliptic region")
plt.xlabel("parameter along axis"); plt.ylabel("curvature")
plt.legend(); plt.tight_layout()
plt.savefig("axis_curvature.png", dpi=150)
print("wrote axis_curvature.png")
