import numpy as np
import matplotlib.pyplot as plt

fig, axes = plt.subplots(1, 2, figsize=(11, 5))

# Left: anisotropic circle over R
th = np.linspace(0, 2 * np.pi, 400)
axes[0].plot(np.cos(th), np.sin(th), "b", lw=2)
axes[0].set_title(r"Over $\mathbb{R}$: $x^2+y^2=1$ is a circle (anisotropic)")
axes[0].set_aspect("equal"); axes[0].grid(True, alpha=0.3)
axes[0].set_xlim(-2, 2); axes[0].set_ylim(-2, 2)

# Right: split conic / cross when -1 is a square (I plays the role of i on a
# real (u, v) chart u = x, v = I y -> u v parametrization of (x+Iy)(x-Iy)=1)
u = np.linspace(-2, 2, 400)
with np.errstate(divide="ignore"):
    axes[1].plot(u, 1.0 / np.where(u == 0, np.nan, u), "r", lw=2,
                 label=r"$(x+Iy)(x-Iy)=1$")
axes[1].plot(u, -1.0 / np.where(u == 0, np.nan, u), "r", lw=2)
axes[1].plot(u, u, "k--", lw=1, label=r"isotropic lines $x\pm Iy=0$")
axes[1].plot(u, -u, "k--", lw=1)
axes[1].set_title(r"With $I^2=-1$: conic splits into a cross (isotropic)")
axes[1].set_aspect("equal"); axes[1].grid(True, alpha=0.3)
axes[1].set_xlim(-2, 2); axes[1].set_ylim(-2, 2); axes[1].legend(loc="upper right")

plt.tight_layout()
plt.savefig("circle_to_cross.png", dpi=150)
print("wrote circle_to_cross.png")
