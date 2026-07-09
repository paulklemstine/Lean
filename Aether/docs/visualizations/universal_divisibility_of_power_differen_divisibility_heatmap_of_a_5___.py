"""Heatmap of (a^5 - a) mod m showing the all-zero column at m dividing 30."""
from __future__ import annotations
import numpy as np
import matplotlib.pyplot as plt

a_vals = np.arange(0, 20)
m_vals = np.arange(2, 33)
grid = np.array([[(a ** 5 - a) % m for m in m_vals] for a in a_vals])
plt.figure(figsize=(11, 5))
plt.imshow(grid == 0, aspect="auto", cmap="Greens",
           extent=[m_vals[0], m_vals[-1], a_vals[-1], a_vals[0]])
plt.colorbar(label="(a^5 - a) ≡ 0 (mod m)")
plt.xlabel("modulus m")
plt.ylabel("integer a")
plt.title("Where m divides a^5 - a  (full green column = universal divisor)")
plt.tight_layout()
plt.savefig("divisibility_heatmap.png", dpi=150)
print("saved divisibility_heatmap.png")
