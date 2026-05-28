#!/usr/bin/env python3
"""
Visualization: Singer-Like Action on the Projective Line ℙ¹(𝔽_q)

Shows how a Singer-like matrix acts on the projective line without
any fixed points — the geometric mechanism behind spectral expansion.
Contrasts with a non-Singer element that fixes projective points.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from itertools import product as cartesian_product

# ── Self-contained code ──

def inverse_mod(a, q): return pow(a, q-2, q)

class M2:
    __slots__=['a','b','c','d','q']
    def __init__(s,a,b,c,d,q): s.a,s.b,s.c,s.d,s.q=a%q,b%q,c%q,d%q,q
    def det(s): return (s.a*s.d-s.b*s.c)%s.q
    def __mul__(s,o):
        q=s.q
        return M2((s.a*o.a+s.b*o.c)%q,(s.a*o.b+s.b*o.d)%q,
                  (s.c*o.a+s.d*o.c)%q,(s.c*o.b+s.d*o.d)%q,q)
    def to_tuple(s): return (s.a,s.b,s.c,s.d)

def is_irred(m):
    tr,det,q=(m.a+m.d)%m.q,m.det(),m.q
    return all((a*a-tr*a+det)%q!=0 for a in range(q))

def proj_action(m, pt, q):
    a,b=pt
    na=(m.a*a+m.b*b)%q; nb=(m.c*a+m.d*b)%q
    if nb!=0: return ((na*inverse_mod(nb,q))%q, 1)
    return (1,0) if na!=0 else None

def proj_points(q):
    return [(a,1) for a in range(q)] + [(1,0)]

# ── Data ──

q = 11
points = proj_points(q)
n_pts = len(points)

# Find a Singer-like element
singer = None
for a,b,c,d in cartesian_product(range(q), repeat=4):
    m = M2(a,b,c,d,q)
    if m.det()!=0 and is_irred(m):
        singer = m; break

# Find a non-Singer element (has eigenvalue, so fixes a projective point)
non_singer = M2(2,1,0,3,q)  # upper triangular → fixes (1,0)

# Compute orbits
def compute_orbit(m, pt, q, max_steps=50):
    orbit = [pt]
    cur = pt
    for _ in range(max_steps):
        cur = proj_action(m, cur, q)
        if cur == pt: break
        orbit.append(cur)
    return orbit

# ── Visualization ──

fig, axes = plt.subplots(1, 2, figsize=(14, 6))

for ax, (mat, title, is_singer) in zip(axes, [
    (singer, f'Singer-Like Element\n(irreducible charpoly, no fixed points)', True),
    (non_singer, f'Non-Singer Element\n(reducible charpoly, has fixed point)', False),
]):
    # Place points on a circle
    angles = np.linspace(0, 2*np.pi, n_pts, endpoint=False)
    x_pos = np.cos(angles)
    y_pos = np.sin(angles)

    # Draw points
    ax.scatter(x_pos, y_pos, s=120, c='steelblue', zorder=5, edgecolors='black')

    # Label points
    for i, pt in enumerate(points):
        label = f"{pt[0]}" if pt[1]==1 else "∞"
        offset = 0.15
        ax.annotate(label, (x_pos[i]*(1+offset), y_pos[i]*(1+offset)),
                   ha='center', va='center', fontsize=9, fontweight='bold')

    # Draw arrows for action
    for i, pt in enumerate(points):
        img = proj_action(mat, pt, q)
        j = points.index(img)
        if i == j:
            # Fixed point — draw self-loop
            ax.scatter([x_pos[i]], [y_pos[i]], s=300, facecolors='none',
                      edgecolors='red', linewidths=3, zorder=6)
        else:
            dx = x_pos[j] - x_pos[i]
            dy = y_pos[j] - y_pos[i]
            # Shorten arrow
            length = np.sqrt(dx**2 + dy**2)
            shrink = 0.12
            ax.annotate('', xy=(x_pos[j]-dx*shrink/length, y_pos[j]-dy*shrink/length),
                       xytext=(x_pos[i]+dx*shrink/length, y_pos[i]+dy*shrink/length),
                       arrowprops=dict(arrowstyle='->', color='coral',
                                      lw=1.5, connectionstyle='arc3,rad=0.2'))

    # Count fixed points
    fixed = sum(1 for pt in points if proj_action(mat, pt, q) == pt)

    ax.set_title(title, fontsize=12, fontweight='bold')
    ax.text(0, -1.5, f'Fixed points: {fixed}', ha='center', fontsize=11,
           color='red' if fixed > 0 else 'green',
           fontweight='bold')
    ax.set_xlim(-1.8, 1.8)
    ax.set_ylim(-1.8, 1.8)
    ax.set_aspect('equal')
    ax.axis('off')

fig.suptitle(f'Action on ℙ¹(𝔽_{q}): Singer vs Non-Singer Elements',
            fontsize=15, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('viz_projective_action.png', dpi=150, bbox_inches='tight')
print("Saved viz_projective_action.png")
