"""Heatmap of the 2-adic parity obstruction over coprime pairs (a, b)."""
import numpy as np
import matplotlib.pyplot as plt
from math import gcd

def v2(m: int) -> int:
    c = 0
    while m % 2 == 0:
        m //= 2
        c += 1
    return c

L = 60
grid = np.full((L, L), np.nan)
for a in range(2, L):
    for b in range(a + 1, L):
        if gcd(a, b) == 1:
            grid[b, a] = (v2(a + 1) + v2(b + 1)) % 2

plt.figure(figsize=(7, 6))
plt.imshow(grid, origin="lower", cmap="coolwarm", interpolation="nearest")
plt.colorbar(label="parity of v2(a+1)+v2(b+1)  (1 = forbidden)")
plt.xlabel("a"); plt.ylabel("b")
plt.title("2-adic parity obstruction for (a^n+1)(b^n+1)")
plt.tight_layout()
plt.savefig("parity_heatmap.png", dpi=150)
print("saved parity_heatmap.png")
