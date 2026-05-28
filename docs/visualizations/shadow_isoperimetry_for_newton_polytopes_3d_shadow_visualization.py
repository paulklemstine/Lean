"""
Visualization: 3D Shadow Structure

Shows the shadow of a 3D box and degree simplex using matplotlib's
3D scatter plots. Self-contained — no local imports.
"""

import matplotlib.pyplot as plt
from mpl_toolkits.mplot3d import Axes3D
import numpy as np
from itertools import product as cartesian_product


def one_shadow(S, n):
    shadow = set()
    for x in S:
        for i in range(n):
            if x[i] > 0:
                y = list(x)
                y[i] -= 1
                shadow.add(tuple(y))
    return shadow

def box(n, a):
    return set(cartesian_product(*(range(a[i] + 1) for i in range(n))))

def degree_simplex(n, d):
    result = set()
    def gen(dim, deg, cur):
        if dim == 0:
            result.add(tuple(cur))
            return
        for v in range(deg + 1):
            cur.append(v)
            gen(dim - 1, deg - v, cur)
            cur.pop()
    gen(n, d, [])
    return result


fig = plt.figure(figsize=(14, 6))
fig.suptitle("3D Shadow Structure", fontsize=14, fontweight='bold')

# ── Panel 1: Box shadow ──
ax1 = fig.add_subplot(121, projection='3d')
a = (3, 2, 2)
B = box(3, a)
sh = one_shadow(B, 3)
not_in_shadow = B - sh

pts_sh = np.array(list(sh & B))
pts_corner = np.array(list(not_in_shadow))

ax1.scatter(pts_sh[:, 0], pts_sh[:, 1], pts_sh[:, 2],
            c='steelblue', alpha=0.4, s=40, label='In shadow')
if len(pts_corner) > 0:
    ax1.scatter(pts_corner[:, 0], pts_corner[:, 1], pts_corner[:, 2],
                c='crimson', s=100, marker='*', label='Not in shadow')

ax1.set_title(f"Box ({a[0]},{a[1]},{a[2]})\n"
              f"|Box|={len(B)}, |Sh₁|={len(sh)}")
ax1.set_xlabel("x₁")
ax1.set_ylabel("x₂")
ax1.set_zlabel("x₃")
ax1.legend(fontsize=8)

# ── Panel 2: Simplex shadow ──
ax2 = fig.add_subplot(122, projection='3d')
d = 4
S_d = degree_simplex(3, d)
S_prev = degree_simplex(3, d - 1)
sh_d = one_shadow(S_d, 3)

# Color by degree
pts_prev = np.array(list(S_prev))
pts_top = np.array(list(S_d - S_prev))  # Degree exactly d

if len(pts_prev) > 0:
    ax2.scatter(pts_prev[:, 0], pts_prev[:, 1], pts_prev[:, 2],
                c='steelblue', alpha=0.4, s=30, label=f'Δ(3,{d-1}) = Sh₁')
if len(pts_top) > 0:
    ax2.scatter(pts_top[:, 0], pts_top[:, 1], pts_top[:, 2],
                c='orange', alpha=0.5, s=30, label=f'Degree {d} layer')

ax2.set_title(f"Δ(3,{d}): |Δ|={len(S_d)}\n"
              f"|Sh₁|={len(sh_d)} = |Δ(3,{d-1})|={len(S_prev)}")
ax2.set_xlabel("x₁")
ax2.set_ylabel("x₂")
ax2.set_zlabel("x₃")
ax2.legend(fontsize=8)

plt.tight_layout()
plt.savefig("shadow_3d.png", dpi=150, bbox_inches='tight')
print("Saved shadow_3d.png")
