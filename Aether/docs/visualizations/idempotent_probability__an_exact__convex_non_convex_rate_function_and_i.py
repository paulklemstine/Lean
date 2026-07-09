"""Visualize the non-convex rate function gapMeasure and its convex
Legendre-Fenchel envelope, exhibiting the exact duality gap of 2.

Requires matplotlib. Saves duality_gap.png."""
from typing import Callable, Dict, Hashable, List
import numpy as np
import matplotlib.pyplot as plt

weight: Dict[int, float] = {0: 0.0, 1: -2.0, 2: 0.0}   # gapMeasure
val: Callable[[Hashable], float] = lambda i: float(i)   # gapVal
I = {x: -w for x, w in weight.items()}                  # rate (0,2,0)

def cgf(lam: float) -> float:
    return max(lam * val(x) + weight[x] for x in weight)

def biconj(a: float, grid: List[float]) -> float:
    return max(lam * a - cgf(lam) for lam in grid)

grid = list(np.linspace(-6, 6, 4001))
xs = list(np.linspace(0, 2, 201))
rate_pts_x = [0, 1, 2]
rate_pts_y = [I[0], I[1], I[2]]
envelope = [biconj(a, grid) for a in xs]

fig, ax = plt.subplots(figsize=(8, 5))
ax.plot(rate_pts_x, rate_pts_y, "o-", color="crimson", lw=2, ms=9,
        label="rate function I (non-convex spike)")
ax.plot(xs, envelope, "--", color="navy", lw=2,
        label="convex envelope I** = sup (lam a - Lambda(lam))")
ax.annotate("", xy=(1, I[1]), xytext=(1, biconj(1, grid)),
            arrowprops=dict(arrowstyle="<->", color="black", lw=1.5))
ax.text(1.05, 1.0, "duality gap = 2", fontsize=12)
ax.set_xlabel("observable value  val(x)")
ax.set_ylabel("deviation cost")
ax.set_title("Idempotent Cramer duality gap: convex envelope flattens the spike")
ax.legend()
ax.grid(alpha=0.3)
fig.tight_layout()
fig.savefig("duality_gap.png", dpi=150)
print("saved duality_gap.png")
