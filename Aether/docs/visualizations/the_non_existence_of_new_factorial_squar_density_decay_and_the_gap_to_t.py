"""Visualization: Brocard density terms and the gap between n!+1 and nearest square.

Generates two panels:
  (left)  log-scale plot of the density terms 1/sqrt(n!) showing super-exponential
          decay (why sum_n 1/sqrt(n!) converges).
  (right) the normalized distance from n!+1 to the nearest perfect square,
          highlighting the three Brown numbers where the distance is exactly 0.
"""
from math import factorial, sqrt, isqrt
import matplotlib.pyplot as plt


def nearest_square_gap(N: int) -> int:
    r = isqrt(N)
    return min(N - r * r, (r + 1) * (r + 1) - N)


ns = list(range(2, 16))
terms = [1.0 / sqrt(float(factorial(n))) for n in ns]
gaps = []
for n in ns:
    val = factorial(n) + 1
    gaps.append(nearest_square_gap(val) / sqrt(float(val)))

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(12, 5))

ax1.semilogy(ns, terms, "o-", color="#2b6cb0")
ax1.set_title(r"Brocard density terms $1/\sqrt{n!}$")
ax1.set_xlabel("n")
ax1.set_ylabel(r"$1/\sqrt{n!}$ (log scale)")
ax1.grid(True, which="both", alpha=0.3)

ax2.plot(ns, gaps, "s-", color="#c53030")
for n in (4, 5, 7):
    ax2.plot(n, 0.0, "*", color="gold", markersize=18, markeredgecolor="black")
ax2.set_title(r"Normalized gap from $n!+1$ to nearest square")
ax2.set_xlabel("n")
ax2.set_ylabel(r"gap $/\sqrt{n!+1}$")
ax2.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig("brocard_visualization.png", dpi=150)
print("Saved brocard_visualization.png")
