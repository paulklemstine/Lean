"""Plot y = x^2 - 1 over the reals and mark how the two roots merge at char 2."""
import numpy as np
import matplotlib.pyplot as plt

x = np.linspace(-2, 2, 400)
plt.figure(figsize=(8, 5))
plt.plot(x, x**2 - 1, label=r"$x^2-1=(x-1)(x+1)$ (char $\neq 2$)")
plt.plot(x, (x-1)**2, label=r"$(x-1)^2$ (char $2$ shape)", ls="--")
plt.scatter([1, -1], [0, 0], c="steelblue", zorder=5, label="two roots")
plt.scatter([1], [0], c="crimson", zorder=6, s=120, marker="o",
            facecolors="none", label="merged double root at x=1")
plt.axhline(0, c="gray", lw=0.8); plt.axvline(0, c="gray", lw=0.8)
plt.title("Root collapse: two simple roots become one double root")
plt.legend(); plt.tight_layout()
plt.savefig("root_collapse.png", dpi=150)
print("wrote root_collapse.png")
