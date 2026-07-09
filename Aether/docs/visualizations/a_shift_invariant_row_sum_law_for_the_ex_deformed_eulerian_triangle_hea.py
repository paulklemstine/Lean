"""Heatmap of the extended Eulerian triangle A(n,k,s) as s varies."""
import numpy as np
import matplotlib.pyplot as plt
from math import comb

def A(n: int, k: int, s: float) -> float:
    return sum((-1) ** i * comb(n + 1, i) * (k + 1 - i - s) ** n for i in range(k + 1))

n = 6
shifts = np.linspace(-1.0, 1.0, 5)
fig, axes = plt.subplots(1, len(shifts), figsize=(4 * len(shifts), 3.2), squeeze=False)
for ax, s in zip(axes[0], shifts):
    M = np.array([[A(n, k, float(s)) for k in range(n + 1)] for _ in range(1)])
    ax.imshow(M, aspect="auto", cmap="coolwarm")
    ax.set_title(f"s = {s:.2f}\nrow sum = {sum(A(n,k,float(s)) for k in range(n+1)):.0f}")
    ax.set_xlabel("k"); ax.set_yticks([])
fig.suptitle(f"Extended Eulerian row n={n}: entries move, sum stays {np.math.factorial(n)}")
plt.tight_layout(); plt.savefig("eulerian_heatmap.png", dpi=150)
print("wrote eulerian_heatmap.png")
