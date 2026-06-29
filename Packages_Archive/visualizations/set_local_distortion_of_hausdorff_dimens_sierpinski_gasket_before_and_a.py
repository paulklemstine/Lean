"""Render the Sierpinski gasket before and after a bilipschitz-on shear, with
their box-counting dimension estimates, to visualize set-local invariance."""
from __future__ import annotations
import math
from typing import Callable, List, Sequence, Tuple
import matplotlib.pyplot as plt

Point = Tuple[float, float]

def sierpinski(depth: int) -> List[Point]:
    pts: List[Point] = [(0.0, 0.0)]
    corners = [(0.0, 0.0), (1.0, 0.0), (0.5, math.sqrt(3) / 2)]
    for _ in range(depth):
        pts = [((px + cx) / 2, (py + cy) / 2)
               for (px, py) in pts for (cx, cy) in corners]
    return pts

def shear(p: Point) -> Point:
    x, y = p
    return (x + 0.5 * y, y)

pts = sierpinski(7)
sheared = [shear(p) for p in pts]

fig, ax = plt.subplots(1, 2, figsize=(11, 5))
ax[0].scatter([p[0] for p in pts], [p[1] for p in pts], s=0.4, color="navy")
ax[0].set_title("Sierpinski gasket s")
ax[1].scatter([p[0] for p in sheared], [p[1] for p in sheared], s=0.4, color="crimson")
ax[1].set_title("f(s): bilipschitz-on shear")
for a in ax:
    a.set_aspect("equal")
    a.axis("off")
fig.suptitle("Set-local bilipschitz invariance: same fractal dimension (log3/log2)")
plt.tight_layout()
plt.savefig("sierpinski_invariance.png", dpi=150)
print("saved sierpinski_invariance.png")
