"""
Visualization: Tropical Morse Filtration and Running Euler Characteristic

Shows how the Euler characteristic evolves as simplices are added
one by one in order of increasing weight for three standard surfaces:
torus, projective plane, and Klein bottle.

The key insight is that each d-simplex contributes (-1)^d to χ,
and the final value always equals the topological Euler characteristic.
"""

import matplotlib.pyplot as plt
import matplotlib
matplotlib.use('Agg')
import itertools
from fractions import Fraction

# ── Inline core classes ──
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

def assign_weights(K, seed=42):
    import random
    rng = random.Random(seed)
    verts = sorted(K.vertices)
    vw = {v: Fraction(i * 100 + rng.randint(1, 99), 100) for i, v in enumerate(verts)}
    weight, counter, used = {}, 0, set()
    for sigma in sorted(K.faces, key=lambda s: (len(s), sorted(s))):
        base = max(vw[v] for v in sigma)
        w = base + Fraction(len(sigma), 1000) + Fraction(counter, 100000)
        while w in used:
            counter += 1
            w = base + Fraction(len(sigma), 1000) + Fraction(counter, 100000)
        weight[sigma] = w
        used.add(w)
        counter += 1
    return weight

# ── Surface constructors ──
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

# ── Build data ──
fig, axes = plt.subplots(1, 3, figsize=(16, 5), sharey=True)

surfaces = [
    ("Torus T² (χ=0)", torus(), '#2196F3'),
    ("Projective Plane RP² (χ=1)", rp2(), '#E91E63'),
    ("Klein Bottle (χ=0)", klein(), '#4CAF50'),
]

for ax, (name, S, color) in zip(axes, surfaces):
    w = assign_weights(S, seed=42)
    sorted_faces = sorted(S.faces, key=lambda s: (w[s], len(s)))

    steps = list(range(1, len(sorted_faces) + 1))
    running_chi = []
    cumulative = 0
    dims = []

    for sigma in sorted_faces:
        dim = len(sigma) - 1
        cumulative += (-1) ** dim
        running_chi.append(cumulative)
        dims.append(dim)

    chi = S.euler_characteristic()

    # Color by dimension
    colors_dim = {0: '#FF9800', 1: '#9C27B0', 2: '#00BCD4'}
    dim_labels = {0: 'vertex (+1)', 1: 'edge (-1)', 2: 'triangle (+1)'}

    for d in [0, 1, 2]:
        xs = [steps[i] for i in range(len(dims)) if dims[i] == d]
        ys = [running_chi[i] for i in range(len(dims)) if dims[i] == d]
        if xs:
            ax.scatter(xs, ys, c=colors_dim[d], s=12, alpha=0.7,
                      label=dim_labels[d], zorder=3)

    ax.plot(steps, running_chi, color=color, alpha=0.4, linewidth=1, zorder=2)
    ax.axhline(y=chi, color='red', linestyle='--', alpha=0.6, label=f'χ = {chi}')

    fv = S.f_vector()
    ax.set_title(name, fontsize=13, fontweight='bold')
    ax.set_xlabel('Filtration step', fontsize=11)
    ax.text(0.02, 0.02,
            f'f₀={fv.get(0,0)}, f₁={fv.get(1,0)}, f₂={fv.get(2,0)}',
            transform=ax.transAxes, fontsize=9, verticalalignment='bottom',
            bbox=dict(boxstyle='round', facecolor='wheat', alpha=0.5))

    if ax == axes[0]:
        ax.set_ylabel('Running Euler characteristic', fontsize=11)

    ax.legend(fontsize=8, loc='upper right')
    ax.grid(True, alpha=0.3)

fig.suptitle('Tropical Morse Filtration: Running Euler Characteristic',
             fontsize=15, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('viz_filtration.png', dpi=150, bbox_inches='tight')
print("Saved viz_filtration.png")
