"""Heatmap of the sign of iterated discriminants (L^k a)(n) for the Catalan
totals: a wall of negatives at k=1 shows the failure of log-concavity."""
import matplotlib.pyplot as plt
import numpy as np
from fractions import Fraction

def catalan(L):
    out = [Fraction(1)]
    for n in range(L - 1): out.append(Fraction(2*(2*n+1), n+2) * out[-1])
    return out
def Lop(a): return [a[n+1]**2 - a[n]*a[n+2] for n in range(len(a)-2)]

depth, N = 4, 14
levels = [catalan(N)]
for _ in range(depth):
    if len(levels[-1]) < 3: break
    levels.append(Lop(levels[-1]))

W = max(len(l) for l in levels)
grid = np.full((len(levels), W), np.nan)
for k, lvl in enumerate(levels):
    for n, v in enumerate(lvl):
        grid[k, n] = float(np.sign(float(v)))

plt.imshow(grid, cmap="coolwarm", aspect="auto", vmin=-1, vmax=1)
plt.colorbar(label="sign of (L^k a)(n)")
plt.xlabel("index n"); plt.ylabel("iteration k")
plt.title("Iterated discriminant signs for Catalan totals")
plt.tight_layout(); plt.savefig("hoggatt_heatmap.png", dpi=150)
print("saved hoggatt_heatmap.png")
