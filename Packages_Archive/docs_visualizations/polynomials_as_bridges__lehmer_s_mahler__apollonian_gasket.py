"""Render an Apollonian gasket via the Descartes Circle Theorem.

The same four reflections whose Koopman action preserves polynomial degree
generate this fractal of mutually tangent circles. Requires matplotlib.
"""
from __future__ import annotations
import cmath
from typing import List, Tuple
import matplotlib.pyplot as plt

Circle = Tuple[complex, float]  # (curvature*center, curvature)  (b*z, b)

def descartes_curvatures(b1: float, b2: float, b3: float) -> Tuple[float, float]:
    s = b1 + b2 + b3
    root = 2 * (b1 * b2 + b2 * b3 + b3 * b1) ** 0.5
    return s + root, s - root

def gasket(depth: int = 5):
    # Outer circle (negative curvature) plus two inner tangent circles.
    circles: List[Tuple[float, complex]] = []
    b1, b2, b3 = -1.0, 2.0, 2.0
    c1, c2, c3 = 0 + 0j, -0.5 + 0j, 0.5 + 0j
    base = [(b1, c1), (b2, c2), (b3, c3)]

    def recurse(quad, n):
        for (bk, ck) in quad:
            circles.append((bk, ck))
        if n == 0:
            return
        b_list = [q[0] for q in quad]
        z_list = [q[1] for q in quad]
        for drop in range(4):
            kept = [i for i in range(4) if i != drop]
            bb = [b_list[i] for i in kept]
            zz = [z_list[i] for i in kept]
            b4 = bb[0] + bb[1] + bb[2] - 2 * (bb[0]*bb[1] + bb[1]*bb[2] + bb[2]*bb[0]) ** 0.5
            if abs(b4) < 1e-9:
                continue
            z4 = (bb[0]*zz[0] + bb[1]*zz[1] + bb[2]*zz[2]
                  - 2 * cmath.sqrt(bb[0]*bb[1]*zz[0]*zz[1]
                                   + bb[1]*bb[2]*zz[1]*zz[2]
                                   + bb[2]*bb[0]*zz[2]*zz[0])) / b4
            recurse([(bb[0], zz[0]), (bb[1], zz[1]), (bb[2], zz[2]), (b4, z4)], n - 1)

    b4p, _ = descartes_curvatures(b1, b2, b3)
    z4 = (b1*c1 + b2*c2 + b3*c3) / b4p if b4p else 0
    recurse(base + [(b4p, z4)], depth)
    return circles

fig, ax = plt.subplots(figsize=(7, 7))
for b, z in gasket(4):
    if abs(b) < 1e-9:
        continue
    r = 1 / abs(b)
    center = z if abs(b) < 1e-9 else (z)
    ax.add_patch(plt.Circle((center.real, center.imag), r, fill=False, lw=0.4))
ax.set_xlim(-1.1, 1.1); ax.set_ylim(-1.1, 1.1); ax.set_aspect("equal")
ax.set_title("Apollonian gasket (Descartes reflections)")
ax.axis("off")
plt.tight_layout()
plt.savefig("apollonian_gasket.png", dpi=150)
print("wrote apollonian_gasket.png")
