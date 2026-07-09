"""Heatmap of the sign-indicator curvature K(x,y)=sech^2(x)-sech^2(y)
over the plane, with the diagonal phase boundary y=+/-x overlaid."""
import numpy as np
import matplotlib.pyplot as plt

def sech2(t):
    return 1.0 / np.cosh(t) ** 2

xs = np.linspace(-4, 4, 400)
ys = np.linspace(-4, 4, 400)
X, Y = np.meshgrid(xs, ys)
Kv = sech2(X) - sech2(Y)

plt.figure(figsize=(6, 5))
lim = np.max(np.abs(Kv))
plt.pcolormesh(X, Y, Kv, cmap="RdBu_r", vmin=-lim, vmax=lim, shading="auto")
plt.colorbar(label="K(x,y)")
plt.plot(xs, xs, "k--", lw=1)
plt.plot(xs, -xs, "k--", lw=1)
plt.title("Split Geometry: sign-indicator curvature and diagonal boundary")
plt.xlabel("x"); plt.ylabel("y"); plt.gca().set_aspect("equal")
plt.tight_layout()
plt.savefig("split_curvature_heatmap.png", dpi=150)
print("wrote split_curvature_heatmap.png")
