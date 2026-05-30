"""
Visualization: Hyperbolic Tessellation and Prime Classification
================================================================

Shows the fundamental domain tessellation of the modular group PSL(2,Z)
and classifies group elements into hyperbolic "primes" (generators) and
"composites" (products of generators).
"""

import math
import matplotlib.pyplot as plt
import numpy as np


def mobius_uhp(a, b, c, d, z_re, z_im):
    """Apply Möbius transform (az+b)/(cz+d) in upper half-plane."""
    denom_re = c * z_re + d
    denom_im = c * z_im
    denom_sq = denom_re**2 + denom_im**2
    if denom_sq < 1e-15:
        return None, None
    num_re = a * z_re + b
    num_im = a * z_im
    w_re = (num_re * denom_re + num_im * denom_im) / denom_sq
    w_im = (num_im * denom_re - num_re * denom_im) / denom_sq
    return w_re, w_im


def cayley_to_disk(z_re, z_im):
    """Cayley transform: upper half-plane to disk."""
    plus_re, plus_im = z_re, z_im + 1
    minus_re, minus_im = z_re, z_im - 1
    d_sq = plus_re**2 + plus_im**2
    if d_sq < 1e-15:
        return None, None
    return ((minus_re*plus_re + minus_im*plus_im) / d_sq,
            (minus_im*plus_re - minus_re*plus_im) / d_sq)


def draw_geodesic_arc(ax, z1_re, z1_im, z2_re, z2_im, color='gray', alpha=0.3, lw=0.5):
    """Draw a hyperbolic geodesic between two points in the disk."""
    # Simple: just draw a straight line (approximation for nearby points)
    ax.plot([z1_re, z2_re], [z1_im, z2_im], color=color, alpha=alpha, linewidth=lw)


def main():
    fig, axes = plt.subplots(1, 2, figsize=(16, 7))

    # ──────────────────────────────────────────
    # Panel 1: Fundamental domain in upper half-plane
    # ──────────────────────────────────────────
    ax = axes[0]

    # Draw fundamental domain of PSL(2,Z)
    # Boundaries: Re(z) = -1/2, Re(z) = 1/2, |z| = 1
    theta = np.linspace(np.pi/3, 2*np.pi/3, 100)
    arc_x = np.cos(theta)
    arc_y = np.sin(theta)
    ax.plot(arc_x, arc_y, 'k-', linewidth=2)
    ax.plot([-0.5, -0.5], [np.sin(np.pi/3), 3], 'k-', linewidth=2)
    ax.plot([0.5, 0.5], [np.sin(np.pi/3), 3], 'k-', linewidth=2)

    # Fill fundamental domain
    fill_x = list(arc_x) + [0.5, 0.5, -0.5, -0.5] + [arc_x[0]]
    fill_y = list(arc_y) + [arc_y[-1], 3, 3, arc_y[0]] + [arc_y[0]]
    ax.fill(fill_x, fill_y, alpha=0.15, color='gold')

    # Draw translated copies
    for n in range(-3, 4):
        if n == 0:
            continue
        theta_t = np.linspace(0, np.pi, 100)
        cx = np.cos(theta_t) + n
        cy = np.sin(theta_t)
        ax.plot(cx, cy, 'gray', linewidth=0.5, alpha=0.5)
        ax.plot([n - 0.5, n - 0.5], [0, 3], 'gray', linewidth=0.3, alpha=0.3)
        ax.plot([n + 0.5, n + 0.5], [0, 3], 'gray', linewidth=0.3, alpha=0.3)

    # Mark special points
    ax.plot(0, 1, 'r*', markersize=15, zorder=10, label='i (origin)')
    ax.plot(-0.5, math.sqrt(3)/2, 'bs', markersize=8, zorder=10, label='ρ = e^{2πi/3}')
    ax.plot(0.5, math.sqrt(3)/2, 'bs', markersize=8, zorder=10)

    # Draw some images under S and T
    special_pts = [(0, 1)]  # Start at i
    # T(i) = i+1
    special_pts.append((1, 1))
    # S(i) = -1/i = i (fixed!)
    # T^{-1}(i) = i-1
    special_pts.append((-1, 1))
    # ST(i) = S(i+1) = -1/(i+1) = (-1+i)/2... compute properly
    z_re, z_im = 1, 1  # i+1
    w_re, w_im = mobius_uhp(0, -1, 1, 0, z_re, z_im)
    if w_re is not None:
        special_pts.append((w_re, w_im))

    for x, y in special_pts[1:]:
        ax.plot(x, y, 'go', markersize=6, zorder=8)

    ax.set_xlim(-3.5, 3.5)
    ax.set_ylim(0, 3.5)
    ax.set_aspect('equal')
    ax.set_title('Upper Half-Plane: Fundamental Domain of PSL(2,ℤ)', fontsize=12)
    ax.set_xlabel('Re(z)')
    ax.set_ylabel('Im(z)')
    ax.legend(loc='upper right', fontsize=9)

    # ──────────────────────────────────────────
    # Panel 2: Orbit in Poincaré disk with word length coloring
    # ──────────────────────────────────────────
    ax = axes[1]

    # Draw disk boundary
    circle = plt.Circle((0, 0), 1, fill=False, color='black', linewidth=2)
    ax.add_patch(circle)

    # Generate orbit with word length tracking
    class M:
        def __init__(self, a, b, c, d, wl=0):
            self.a, self.b, self.c, self.d = a, b, c, d
            self.wl = wl
        def mul(self, other):
            return M(self.a*other.a+self.b*other.c, self.a*other.b+self.b*other.d,
                     self.c*other.a+self.d*other.c, self.c*other.b+self.d*other.d,
                     self.wl + 1)
        def key(self):
            return (round(self.a,3), round(self.b,3), round(self.c,3), round(self.d,3))

    S_g = M(0, -1, 1, 0, 0)
    T_g = M(1, 1, 0, 1, 0)
    Ti_g = M(1, -1, 0, 1, 0)

    orbit = {}
    queue = [M(1, 0, 0, 1, 0)]
    orbit[queue[0].key()] = 0

    for _ in range(6):
        next_q = []
        for m in queue:
            for g in [S_g, T_g, Ti_g]:
                n = m.mul(g)
                k = n.key()
                if k not in orbit:
                    orbit[k] = n.wl
                    next_q.append(n)
        queue = next_q

    # Convert to disk coordinates
    pts_by_wl = {}
    for (a, b, c, d), wl in orbit.items():
        w_re, w_im = mobius_uhp(a, b, c, d, 0, 1)
        if w_re is None:
            continue
        dx, dy = cayley_to_disk(w_re, w_im)
        if dx is None:
            continue
        r = math.sqrt(dx**2 + dy**2)
        if r >= 0.99:
            continue
        if wl not in pts_by_wl:
            pts_by_wl[wl] = ([], [])
        pts_by_wl[wl][0].append(dx)
        pts_by_wl[wl][1].append(dy)

    colors = ['gold', '#e74c3c', '#3498db', '#2ecc71', '#9b59b6', '#e67e22', '#1abc9c']
    for wl in sorted(pts_by_wl.keys()):
        xs, ys = pts_by_wl[wl]
        c = colors[min(wl, len(colors)-1)]
        s = max(5, 30 - 4 * wl)
        label = f'Word length {wl}' if wl <= 5 else None
        ax.scatter(xs, ys, c=c, s=s, alpha=0.8, label=label, zorder=5+wl)

    ax.set_xlim(-1.15, 1.15)
    ax.set_ylim(-1.15, 1.15)
    ax.set_aspect('equal')
    ax.set_title('Poincaré Disk: Hyperbolic Integers by Word Length', fontsize=12)
    ax.set_xlabel('Re(z)')
    ax.set_ylabel('Im(z)')
    ax.legend(loc='upper right', fontsize=8)

    fig.suptitle('Hyperbolic Number Theory: The Modular Tessellation',
                 fontsize=14, fontweight='bold')
    plt.tight_layout()
    plt.savefig('tessellation.png', dpi=150, bbox_inches='tight')
    print("Saved tessellation.png")


if __name__ == "__main__":
    main()
