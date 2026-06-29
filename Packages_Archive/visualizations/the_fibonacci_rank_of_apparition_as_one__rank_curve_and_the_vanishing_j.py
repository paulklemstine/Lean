"""Heatmap of fibRank(m) and the join-law residual over a grid.

Generates two panels:
  (1) the rank-of-apparition curve fibRank(m) vs m;
  (2) a heatmap of |fibRank(lcm(a,b)) - lcm(fibRank(a),fibRank(b))| over a grid,
      which is identically zero (the join law), shown as a flat field.
Requires matplotlib + numpy.
"""
from math import gcd
import numpy as np
import matplotlib.pyplot as plt


def lcm(a, b):
    return 0 if a == 0 or b == 0 else a // gcd(a, b) * b


def fib_rank(m):
    if m <= 1:
        return m
    a, b, k = 0, 1, 0
    while True:
        a, b = b, (a + b) % m
        k += 1
        if a == 0:
            return k


N = 60
ranks = [fib_rank(m) for m in range(1, N + 1)]
resid = np.zeros((N, N), dtype=int)
for a in range(1, N + 1):
    for b in range(1, N + 1):
        resid[a - 1, b - 1] = abs(fib_rank(lcm(a, b)) - lcm(fib_rank(a), fib_rank(b)))

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(13, 5))
ax1.plot(range(1, N + 1), ranks, "o-", ms=3, color="#b8860b")
ax1.set_title("Rank of apparition  fibRank(m)")
ax1.set_xlabel("m"); ax1.set_ylabel("fibRank(m)"); ax1.grid(alpha=0.3)

im = ax2.imshow(resid, origin="lower", cmap="viridis", extent=[1, N, 1, N])
ax2.set_title("Join-law residual |fibRank(lcm) - lcm(fibRank)|  (= 0)")
ax2.set_xlabel("a"); ax2.set_ylabel("b")
fig.colorbar(im, ax=ax2)
plt.tight_layout()
plt.savefig("fibrank_adjunction.png", dpi=130)
print("Saved fibrank_adjunction.png; max residual =", resid.max())
