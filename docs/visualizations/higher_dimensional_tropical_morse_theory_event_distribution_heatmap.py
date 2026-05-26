"""
Visualization: Tropical Morse Event Heatmap

Shows the distribution of filtration events by dimension and filtration step
for three standard surfaces. The heatmap reveals the structural pattern of
how simplices of different dimensions enter the filtration.
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
fig, axes = plt.subplots(1, 3, figsize=(16, 5))

surfaces = [
    ("Torus T² (χ=0)", torus()),
    ("RP² (χ=1)", rp2()),
    ("Klein Bottle (χ=0)", klein()),
]

for ax, (name, S) in zip(axes, surfaces):
    w = assign_weights(S, seed=42)
    sorted_faces = sorted(S.faces, key=lambda s: (w[s], len(s)))

    n = len(sorted_faces)
    # Create a matrix: rows = dimension (0,1,2), columns = filtration steps
    # Value = cumulative count of events of that dimension up to step i
    max_dim = 2
    matrix = np.zeros((max_dim + 1, n))

    for i, sigma in enumerate(sorted_faces):
        dim = len(sigma) - 1
        if i > 0:
            matrix[:, i] = matrix[:, i-1]
        if dim <= max_dim:
            matrix[dim, i] += 1

    # Plot stacked area
    colors = ['#FF9800', '#9C27B0', '#00BCD4']
    labels = ['Vertices (dim 0)', 'Edges (dim 1)', 'Triangles (dim 2)']

    steps = np.arange(1, n + 1)
    ax.stackplot(steps, matrix[0], matrix[1], matrix[2],
                 labels=labels, colors=colors, alpha=0.7)

    # Overlay running chi
    running_chi = []
    cumulative = 0
    for sigma in sorted_faces:
        cumulative += (-1) ** (len(sigma) - 1)
        running_chi.append(cumulative)

    ax2 = ax.twinx()
    ax2.plot(steps, running_chi, 'k-', linewidth=2, alpha=0.8, label='Running χ')
    ax2.axhline(y=S.euler_characteristic(), color='red', linestyle='--',
                alpha=0.6, linewidth=1.5)

    ax.set_title(name, fontsize=13, fontweight='bold')
    ax.set_xlabel('Filtration step')
    if ax == axes[0]:
        ax.set_ylabel('Cumulative simplex count')
    if ax == axes[2]:
        ax2.set_ylabel('Running Euler characteristic')

    ax.legend(loc='upper left', fontsize=8)
    ax2.legend(loc='center right', fontsize=8)

fig.suptitle('Tropical Morse Event Distribution Across Filtration',
             fontsize=14, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('viz_event_heatmap.png', dpi=150, bbox_inches='tight')
print("Saved viz_event_heatmap.png")
