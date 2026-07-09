"""Visualize the Weil determinant pairing as the signed area of the
parallelogram spanned by two torsion points, and its value table on E[n]."""
from typing import Tuple
import numpy as np
import matplotlib.pyplot as plt

Point = Tuple[int, int]

def weil_pairing(p: Point, q: Point, n: int) -> int:
    return (p[0] * q[1] - p[1] * q[0]) % n

n = 11
fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(12, 5))

# Left: the pairing value table e(p, q) over a fixed p and varying q.
p = (3, 4)
grid = np.array([[weil_pairing(p, (c, d), n) for c in range(n)]
                 for d in range(n)])
im = ax1.imshow(grid, origin="lower", cmap="twilight")
ax1.set_title(f"e(p, q) = zeta^(ad-bc) for p={p} on E[{n}]")
ax1.set_xlabel("q first coordinate c")
ax1.set_ylabel("q second coordinate d")
fig.colorbar(im, ax=ax1, label="exponent of zeta (mod n)")

# Right: the determinant as signed area of the parallelogram (p, q).
q = (5, 1)
origin = np.zeros(2)
for vec, col, lab in [(p, "tab:blue", "p"), (q, "tab:red", "q")]:
    ax2.annotate("", xy=vec, xytext=origin,
                 arrowprops=dict(arrowcolor if False else None))
poly = np.array([origin, p, np.add(p, q), q])
ax2.fill(poly[:, 0], poly[:, 1], alpha=0.3, color="tab:green")
ax2.plot([0, p[0]], [0, p[1]], "tab:blue", lw=2, label=f"p={p}")
ax2.plot([0, q[0]], [0, q[1]], "tab:red", lw=2, label=f"q={q}")
area = p[0] * q[1] - p[1] * q[0]
ax2.set_title(f"det(p,q) = {area} = signed area  ->  e(p,q)=zeta^{area % n}")
ax2.legend(); ax2.set_aspect("equal"); ax2.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig("weil_pairing_visualization.png", dpi=150)
print("saved weil_pairing_visualization.png")
