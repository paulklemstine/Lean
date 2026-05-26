"""
Visualization: Surface Classification via Tropical Morse Signatures

Compares three standard surfaces (torus, projective plane, Klein bottle)
using their tropical Morse event profiles and f-vectors. Shows how the
signed event sum distinguishes surfaces with different Euler characteristics.
"""

import matplotlib.pyplot as plt
import matplotlib
matplotlib.use('Agg')
import numpy as np
import itertools
from fractions import Fraction

# ── Inline core ──
class SimplicialComplex:
    def __init__(self, faces=None):
        self.faces = set(faces) if faces else set()
        to_add = set()
        for sigma in self.faces:
            for k in range(1, len(sigma)):
                for tau in itertools.combinations(sigma, k):
                    to_add.add(frozenset(tau))
        self.faces |= to_add

    @property
    def vertices(self):
        return {v for s in self.faces for v in s}

    def euler_characteristic(self):
        return sum((-1) ** (len(s) - 1) for s in self.faces)

    def f_vector(self):
        fv = {}
        for s in self.faces:
            d = len(s) - 1
            fv[d] = fv.get(d, 0) + 1
        return fv

# ── Surfaces ──
def torus():
    tris = [(0,1,2),(0,2,3),(0,3,4),(0,4,5),(0,5,6),(0,1,6),
            (1,2,4),(2,3,5),(3,4,6),(4,5,1),(5,6,2),(6,1,3),(1,3,5),(2,4,6)]
    return SimplicialComplex({frozenset(t) for t in tris})

def rp2():
    tris = [(0,1,2),(0,2,3),(0,3,4),(0,4,5),(0,1,5),
            (1,2,4),(2,3,5),(3,4,1),(4,5,2),(5,1,3)]
    return SimplicialComplex({frozenset(t) for t in tris})

def klein():
    tris = [(0,1,4),(0,4,3),(1,2,5),(1,5,4),(2,0,3),(2,3,5),
            (3,4,7),(3,7,6),(4,5,8),(4,8,7),(5,3,6),(5,6,8),
            (6,7,1),(6,1,0),(7,8,2),(7,2,1),(8,6,0),(8,0,2)]
    return SimplicialComplex({frozenset(t) for t in tris})

# ── Build figure ──
fig, axes = plt.subplots(2, 2, figsize=(14, 10))

surfaces = [
    ("Torus T²", torus(), '#2196F3'),
    ("RP²", rp2(), '#E91E63'),
    ("Klein Bottle", klein(), '#4CAF50'),
]

# Panel 1: f-vector comparison (bar chart)
ax = axes[0, 0]
x = np.arange(3)
width = 0.25
for i, (name, S, color) in enumerate(surfaces):
    fv = S.f_vector()
    vals = [fv.get(d, 0) for d in range(3)]
    ax.bar(x + i * width, vals, width, label=name, color=color, alpha=0.8)
ax.set_xticks(x + width)
ax.set_xticklabels(['f₀ (vertices)', 'f₁ (edges)', 'f₂ (triangles)'])
ax.set_ylabel('Count')
ax.set_title('f-Vector Comparison', fontweight='bold')
ax.legend()
ax.grid(axis='y', alpha=0.3)

# Panel 2: Euler characteristic and signed sums
ax = axes[0, 1]
names = [name for name, _, _ in surfaces]
chis = [S.euler_characteristic() for _, S, _ in surfaces]
colors = [c for _, _, c in surfaces]
bars = ax.bar(names, chis, color=colors, alpha=0.8, edgecolor='black')
ax.set_ylabel('Euler Characteristic χ')
ax.set_title('Euler Characteristic Comparison', fontweight='bold')
ax.axhline(y=0, color='gray', linestyle='-', alpha=0.5)
for bar, chi in zip(bars, chis):
    ax.text(bar.get_x() + bar.get_width()/2, bar.get_height() + 0.05,
            f'χ = {chi}', ha='center', va='bottom', fontweight='bold', fontsize=12)
ax.grid(axis='y', alpha=0.3)
ax.set_ylim(-0.5, 1.8)

# Panel 3: Signed contribution by dimension
ax = axes[1, 0]
for i, (name, S, color) in enumerate(surfaces):
    fv = S.f_vector()
    signed = [(-1)**d * fv.get(d, 0) for d in range(3)]
    ax.bar(x + i * width, signed, width, label=name, color=color, alpha=0.8)
ax.set_xticks(x + width)
ax.set_xticklabels(['dim 0: +f₀', 'dim 1: -f₁', 'dim 2: +f₂'])
ax.set_ylabel('Signed contribution')
ax.set_title('Signed Event Contributions by Dimension', fontweight='bold')
ax.legend()
ax.axhline(y=0, color='gray', linestyle='-', alpha=0.5)
ax.grid(axis='y', alpha=0.3)

# Panel 4: 3f₂ = 2f₁ verification
ax = axes[1, 1]
for i, (name, S, color) in enumerate(surfaces):
    fv = S.f_vector()
    f1 = fv.get(1, 0)
    f2 = fv.get(2, 0)
    ax.scatter([3 * f2], [2 * f1], s=200, color=color, label=name,
              edgecolors='black', zorder=5)
    ax.annotate(name, (3 * f2, 2 * f1), textcoords="offset points",
               xytext=(10, 5), fontsize=10)

# Add y=x line
max_val = max(3 * S.f_vector().get(2, 0) for _, S, _ in surfaces) + 5
ax.plot([0, max_val], [0, max_val], 'k--', alpha=0.5, label='3f₂ = 2f₁')
ax.set_xlabel('3 · f₂')
ax.set_ylabel('2 · f₁')
ax.set_title('Surface Relation: 3f₂ = 2f₁', fontweight='bold')
ax.legend()
ax.set_aspect('equal')
ax.grid(True, alpha=0.3)

fig.suptitle('Surface Classification via Higher-Dimensional Tropical Morse Theory',
             fontsize=14, fontweight='bold', y=1.01)
plt.tight_layout()
plt.savefig('viz_surface_comparison.png', dpi=150, bbox_inches='tight')
print("Saved viz_surface_comparison.png")
