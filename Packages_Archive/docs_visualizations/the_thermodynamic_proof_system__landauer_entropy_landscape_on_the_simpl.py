"""Visualization: entropy on the 3-outcome simplex and the Landauer bound.

Generates two panels:
  (left)  H(p) over the 2-simplex (p1,p2,p3>=0, sum=1), peaking log 3 at the
          uniform centre -- the maximum-entropy theorem made visible.
  (right) Landauer cost T*log n vs n at T=1, in nats and bits, showing the
          finite information capacity of an n-state world.
Saves tps_visualization.png. Requires matplotlib + numpy.
"""
from __future__ import annotations
import math
import numpy as np
import matplotlib.pyplot as plt

def neg_mul_log(x: float) -> float:
    return 0.0 if x <= 0.0 else -x * math.log(x)

def entropy(p) -> float:
    return sum(neg_mul_log(px) for px in p)

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(13, 5))

# --- left: entropy over the 2-simplex (barycentric) ---
N = 300
xs, ys, Hs = [], [], []
for i in range(N + 1):
    for j in range(N + 1 - i):
        p1 = i / N
        p2 = j / N
        p3 = 1.0 - p1 - p2
        if p3 < -1e-9:
            continue
        # project barycentric -> 2D
        x = p2 + 0.5 * p3
        y = (math.sqrt(3) / 2.0) * p3
        xs.append(x); ys.append(y); Hs.append(entropy([p1, p2, max(p3, 0.0)]))
sc = ax1.scatter(xs, ys, c=Hs, s=4, cmap="viridis")
ax1.set_title("Shannon entropy on the 3-outcome simplex\n(max = log 3 at the uniform centre)")
ax1.set_aspect("equal"); ax1.axis("off")
fig.colorbar(sc, ax=ax1, label="H(p)  (nats)")
ax1.text(0.5, math.sqrt(3)/6, "uniform", ha="center", va="center", color="white", fontsize=9)

# --- right: Landauer capacity ---
ns = np.arange(2, 65)
ax2.plot(ns, np.log(ns), label="cost = log n  (nats)", lw=2)
ax2.plot(ns, np.log2(ns), label="cost = log2 n  (bits)", lw=2, ls="--")
ax2.set_xlabel("number of epistemic microstates  n")
ax2.set_ylabel("Landauer cost of resolving the uniform prior  (T=1)")
ax2.set_title("Fundamental Landauer bound: finite information capacity")
ax2.legend(); ax2.grid(alpha=0.3)

plt.tight_layout()
plt.savefig("tps_visualization.png", dpi=130)
print("wrote tps_visualization.png")
