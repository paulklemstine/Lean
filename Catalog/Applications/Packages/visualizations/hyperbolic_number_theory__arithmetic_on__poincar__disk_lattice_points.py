"""
Visualization: Poincaré Disk with Hyperbolic Lattice Points
============================================================

Visualizes the orbit of the origin under PSL(2,Z) in the Poincaré disk model,
showing how "hyperbolic integers" tile the hyperbolic plane. Points are colored
by their classification (hyperbolic/elliptic/parabolic).
"""

import math
import matplotlib.pyplot as plt
import matplotlib.patches as patches
import numpy as np


class SL2R:
    """Minimal SL(2,R) for visualization."""
    def __init__(self, a, b, c, d):
        self.a, self.b, self.c, self.d = float(a), float(b), float(c), float(d)

    @staticmethod
    def identity():
        return SL2R(1, 0, 0, 1)

    def mul(self, other):
        return SL2R(
            self.a*other.a + self.b*other.c, self.a*other.b + self.b*other.d,
            self.c*other.a + self.d*other.c, self.c*other.b + self.d*other.d)

    def inv(self):
        return SL2R(self.d, -self.b, -self.c, self.a)

    def trace(self):
        return self.a + self.d

    def classify(self):
        t = abs(self.trace())
        if t > 2.01: return "hyperbolic"
        elif t < 1.99: return "elliptic"
        return "parabolic"


def mobius_to_disk(M, z_re=0.0, z_im=1.0):
    """
    Apply Möbius transformation M to z = z_re + i*z_im in the upper half-plane,
    then map to the Poincaré disk via the Cayley transform w = (z-i)/(z+i).
    """
    # M acts on upper half-plane: z -> (az+b)/(cz+d)
    denom_re = M.c * z_re + M.d
    denom_im = M.c * z_im
    denom_sq = denom_re**2 + denom_im**2

    if denom_sq < 1e-15:
        return None, None

    num_re = M.a * z_re + M.b
    num_im = M.a * z_im

    w_re = (num_re * denom_re + num_im * denom_im) / denom_sq
    w_im = (num_im * denom_re - num_re * denom_im) / denom_sq

    # Cayley transform: disk_z = (w - i) / (w + i)
    # w - i = (w_re, w_im - 1), w + i = (w_re, w_im + 1)
    plus_re = w_re
    plus_im = w_im + 1
    minus_re = w_re
    minus_im = w_im - 1

    d_sq = plus_re**2 + plus_im**2
    if d_sq < 1e-15:
        return None, None

    disk_re = (minus_re * plus_re + minus_im * plus_im) / d_sq
    disk_im = (minus_im * plus_re - minus_re * plus_im) / d_sq

    return disk_re, disk_im


def main():
    # Generate PSL(2,Z) elements
    S = SL2R(0, -1, 1, 0)
    T = SL2R(1, 1, 0, 1)
    Ti = SL2R(1, -1, 0, 1)

    elements = []
    seen = set()

    def key(M):
        return (round(M.a, 4), round(M.b, 4), round(M.c, 4), round(M.d, 4))

    queue = [SL2R.identity()]
    seen.add(key(SL2R.identity()))
    elements.append(SL2R.identity())

    for _ in range(7):
        next_q = []
        for M in queue:
            for g in [S, T, Ti, S.inv()]:
                N = M.mul(g)
                k = key(N)
                if k not in seen:
                    seen.add(k)
                    elements.append(N)
                    next_q.append(N)
        queue = next_q

    # Map to disk
    hyp_x, hyp_y = [], []
    ell_x, ell_y = [], []
    par_x, par_y = [], []

    for M in elements:
        x, y = mobius_to_disk(M)
        if x is None:
            continue
        r = math.sqrt(x**2 + y**2)
        if r >= 0.99:
            continue

        cls = M.classify()
        if cls == "hyperbolic":
            hyp_x.append(x); hyp_y.append(y)
        elif cls == "elliptic":
            ell_x.append(x); ell_y.append(y)
        else:
            par_x.append(x); par_y.append(y)

    # Plot
    fig, ax = plt.subplots(1, 1, figsize=(10, 10))

    # Draw disk boundary
    circle = plt.Circle((0, 0), 1, fill=False, color='black', linewidth=2)
    ax.add_patch(circle)

    # Draw geodesics (arcs) connecting some nearby points
    all_pts = list(zip(hyp_x + ell_x + par_x, hyp_y + ell_y + par_y))
    for i in range(len(all_pts)):
        for j in range(i+1, min(i+3, len(all_pts))):
            x1, y1 = all_pts[i]
            x2, y2 = all_pts[j]
            dist = math.sqrt((x1-x2)**2 + (y1-y2)**2)
            if dist < 0.3:
                ax.plot([x1, x2], [y1, y2], color='lightgray', linewidth=0.3, alpha=0.5)

    # Plot points
    ax.scatter(hyp_x, hyp_y, c='#e74c3c', s=15, alpha=0.7, label=f'Hyperbolic ({len(hyp_x)})', zorder=5)
    ax.scatter(ell_x, ell_y, c='#3498db', s=20, alpha=0.8, label=f'Elliptic ({len(ell_x)})', zorder=5)
    ax.scatter(par_x, par_y, c='#2ecc71', s=25, alpha=0.8, label=f'Parabolic ({len(par_x)})', zorder=5)

    # Origin
    ax.scatter([0], [0], c='gold', s=100, marker='*', zorder=10, label='Origin (i)')

    ax.set_xlim(-1.15, 1.15)
    ax.set_ylim(-1.15, 1.15)
    ax.set_aspect('equal')
    ax.legend(loc='upper right', fontsize=11)
    ax.set_title('Hyperbolic Integers: PSL(2,ℤ) Orbit in the Poincaré Disk',
                 fontsize=14, fontweight='bold')
    ax.set_xlabel('Re(z)')
    ax.set_ylabel('Im(z)')

    # Add annotation
    ax.text(0.02, -1.08, 'Points are images of i under PSL(2,ℤ) — the "integers" of the hyperbolic plane',
            fontsize=9, style='italic', color='gray')

    plt.tight_layout()
    plt.savefig('poincare_disk_lattice.png', dpi=150, bbox_inches='tight')
    print("Saved poincare_disk_lattice.png")


if __name__ == "__main__":
    main()
