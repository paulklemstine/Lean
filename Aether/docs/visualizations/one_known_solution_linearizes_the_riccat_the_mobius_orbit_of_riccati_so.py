"""Visualize a Mobius family of Riccati solutions v = 1 + 1/(C e^{2x} - 1/2)."""
from __future__ import annotations
import numpy as np
import matplotlib.pyplot as plt

def riccati_solution(x: np.ndarray, C: float) -> np.ndarray:
    return 1.0 + 1.0 / (C * np.exp(2.0 * x) - 0.5)

x = np.linspace(-1.0, 2.0, 800)
fig, ax = plt.subplots(figsize=(8, 5))
for C in [0.5, 1.0, 2.0, 4.0, 8.0, -1.0, -2.0]:
    y = riccati_solution(x, C)
    y[np.abs(np.gradient(y)) > 5] = np.nan  # mask vertical asymptotes
    ax.plot(x, y, label=f"C = {C}")
ax.axhline(1.0, color="black", lw=2, ls="--", label="v0 = 1 (known)")
ax.set_title(r"Riccati solutions $v=1+\frac{1}{Ce^{2x}-1/2}$ of $v'+v^2-1=0$")
ax.set_xlabel("x"); ax.set_ylabel("v(x)")
ax.set_ylim(-4, 6); ax.legend(loc="upper right", fontsize=8)
ax.grid(alpha=0.3)
plt.tight_layout()
plt.savefig("riccati_family.png", dpi=150)
print("saved riccati_family.png")
