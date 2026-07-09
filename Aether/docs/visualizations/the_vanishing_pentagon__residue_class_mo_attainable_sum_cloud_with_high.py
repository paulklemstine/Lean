"""Scatter of attainable sums for a fixed budget, highlighting the minimizer."""
import cmath, math
import matplotlib.pyplot as plt
from itertools import product

ZETA = cmath.exp(2j * math.pi / 5)
N = 6

pts, best, arg = [], math.inf, None
for c in product(range(N + 1), repeat=5):
    if sum(c) != N:
        continue
    s = sum(a * ZETA ** r for r, a in enumerate(c))
    pts.append(s)
    if abs(s) < best:
        best, arg = abs(s), s

xs = [p.real for p in pts]
ys = [p.imag for p in pts]
plt.figure(figsize=(6, 6))
plt.scatter(xs, ys, s=12, alpha=0.5, label=f"attainable sums (n={N})")
plt.scatter([arg.real], [arg.imag], color="red", s=80,
            label=f"minimizer |S|={best:.4f}")
plt.scatter([0], [0], color="black", marker="+", s=120, label="origin")
plt.gca().set_aspect("equal")
plt.legend(); plt.title(f"Sums of {N} fifth roots of unity")
plt.savefig("scatter_sums.png", dpi=150)
