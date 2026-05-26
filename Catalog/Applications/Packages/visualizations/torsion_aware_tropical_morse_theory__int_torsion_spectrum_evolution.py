"""
Visualization: Torsion Spectrum Evolution Under Simplex Insertion

Shows how the torsion spectrum (invariant factors of H₁) evolves as
triangles are added to a random 2-complex, with events color-coded
by the trichotomy classification.

This visualization makes the "tropical torsion pulse" conjecture
tangible: each insertion changes at most one invariant factor.
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import random

# ============================================================
# Inline all needed functions (self-contained)
# ============================================================

def _extended_gcd(a, b):
    if b == 0:
        return a, 1, 0
    g, x1, y1 = _extended_gcd(b, a % b)
    return g, y1, x1 - (a // b) * y1

def smith_normal_form(M):
    M = np.array(M, dtype=np.int64)
    m, n = M.shape
    S = M.copy()
    U = np.eye(m, dtype=np.int64)
    V = np.eye(n, dtype=np.int64)

    for k in range(min(m, n)):
        # Find pivot
        min_val, min_pos = None, None
        for i in range(k, m):
            for j in range(k, n):
                if S[i, j] != 0 and (min_val is None or abs(S[i, j]) < abs(min_val)):
                    min_val, min_pos = S[i, j], (i, j)
        if min_pos is None:
            break
        i, j = min_pos
        if i != k:
            S[[k, i]] = S[[i, k]]; U[[k, i]] = U[[i, k]]
        if j != k:
            S[:, [k, j]] = S[:, [j, k]]; V[:, [k, j]] = V[:, [j, k]]

        changed = True
        while changed:
            changed = False
            for i in range(k + 1, m):
                if S[i, k] != 0:
                    if S[i, k] % S[k, k] == 0:
                        q = S[i, k] // S[k, k]
                        S[i, :] -= q * S[k, :]; U[i, :] -= q * U[k, :]
                    else:
                        g, x, y = _extended_gcd(int(S[k, k]), int(S[i, k]))
                        a, b = S[k, k] // g, S[i, k] // g
                        rk, ri = S[k, :].copy(), S[i, :].copy()
                        S[k, :] = x * rk + y * ri; S[i, :] = -b * rk + a * ri
                        uk, ui = U[k, :].copy(), U[i, :].copy()
                        U[k, :] = x * uk + y * ui; U[i, :] = -b * uk + a * ui
                    changed = True
            for j in range(k + 1, n):
                if S[k, j] != 0:
                    if S[k, j] % S[k, k] == 0:
                        q = S[k, j] // S[k, k]
                        S[:, j] -= q * S[:, k]; V[:, j] -= q * V[:, k]
                    else:
                        g, x, y = _extended_gcd(int(S[k, k]), int(S[k, j]))
                        a, b = S[k, k] // g, S[k, j] // g
                        ck, cj = S[:, k].copy(), S[:, j].copy()
                        S[:, k] = x * ck + y * cj; S[:, j] = -b * ck + a * cj
                        vk, vj = V[:, k].copy(), V[:, j].copy()
                        V[:, k] = x * vk + y * vj; V[:, j] = -b * vk + a * vj
                    changed = True
        if S[k, k] < 0:
            S[k, :] *= -1; U[k, :] *= -1

    for _ in range(min(m, n)):
        for k in range(min(m, n) - 1):
            if S[k, k] != 0 and S[k+1, k+1] != 0 and S[k+1, k+1] % S[k, k] != 0:
                S[k, :] += S[k+1, :]; U[k, :] += U[k+1, :]
                ch = True
                while ch:
                    ch = False
                    for i in range(k+1, m):
                        if S[i, k] != 0:
                            if S[i, k] % S[k, k] == 0:
                                q = S[i, k] // S[k, k]
                                S[i, :] -= q * S[k, :]; U[i, :] -= q * U[k, :]
                            else:
                                g, x, y = _extended_gcd(int(S[k, k]), int(S[i, k]))
                                a, b = S[k, k] // g, S[i, k] // g
                                rk, ri = S[k, :].copy(), S[i, :].copy()
                                S[k, :] = x * rk + y * ri; S[i, :] = -b * rk + a * ri
                                uk, ui = U[k, :].copy(), U[i, :].copy()
                                U[k, :] = x * uk + y * ui; U[i, :] = -b * uk + a * ui
                            ch = True
                    for j in range(k+1, n):
                        if S[k, j] != 0:
                            if S[k, j] % S[k, k] == 0:
                                q = S[k, j] // S[k, k]
                                S[:, j] -= q * S[:, k]; V[:, j] -= q * V[:, k]
                            else:
                                g, x, y = _extended_gcd(int(S[k, k]), int(S[k, j]))
                                a, b = S[k, k] // g, S[k, j] // g
                                ck, cj = S[:, k].copy(), S[:, j].copy()
                                S[:, k] = x * ck + y * cj; S[:, j] = -b * ck + a * cj
                                vk, vj = V[:, k].copy(), V[:, j].copy()
                                V[:, k] = x * vk + y * vj; V[:, j] = -b * vk + a * vj
                            ch = True
                if S[k, k] < 0:
                    S[k, :] *= -1; U[k, :] *= -1
    return S, U, V

def get_torsion_factors(M):
    if M.size == 0 or M.shape[1] == 0:
        return []
    S, _, _ = smith_normal_form(M)
    return sorted([abs(int(S[i, i])) for i in range(min(S.shape)) if abs(S[i, i]) > 1])

class SimpleComplex:
    def __init__(self, nv):
        self.nv = nv
        self.edges = set()
        self.triangles = set()

    def add_edge(self, e):
        self.edges.add(e)

    def add_triangle(self, t):
        self.triangles.add(t)

    def boundary_2(self):
        edges = sorted(self.edges, key=lambda e: tuple(sorted(e)))
        tris = sorted(self.triangles, key=lambda t: tuple(sorted(t)))
        if not edges or not tris:
            return np.zeros((max(len(edges), 1), 0), dtype=np.int64)
        edge_idx = {e: i for i, e in enumerate(edges)}
        M = np.zeros((len(edges), len(tris)), dtype=np.int64)
        for j, tri in enumerate(tris):
            verts = sorted(tri)
            for k, v in enumerate(verts):
                face = frozenset(verts[:k] + verts[k+1:])
                if face in edge_idx:
                    M[edge_idx[face], j] = (-1) ** k
        return M


# ============================================================
# Run experiment and visualize
# ============================================================

random.seed(123)
np.random.seed(123)
n_vertices = 7

K = SimpleComplex(n_vertices)
for i in range(n_vertices):
    for j in range(i+1, n_vertices):
        K.add_edge(frozenset({i, j}))

all_tris = []
for i in range(n_vertices):
    for j in range(i+1, n_vertices):
        for k in range(j+1, n_vertices):
            all_tris.append(frozenset({i, j, k}))
random.shuffle(all_tris)

# Track evolution
steps = []
torsion_history = []
event_colors = []

M_old = K.boundary_2()
old_factors = get_torsion_factors(M_old)

for idx, tri in enumerate(all_tris):
    K.add_triangle(tri)
    M_new = K.boundary_2()
    new_factors = get_torsion_factors(M_new)

    # Classify event
    S_old, _, _ = smith_normal_form(M_old) if M_old.shape[1] > 0 else (np.zeros((1, 0), dtype=np.int64), None, None)
    S_new, _, _ = smith_normal_form(M_new)
    old_rank = sum(1 for i in range(min(S_old.shape)) if S_old[i, i] != 0) if M_old.shape[1] > 0 else 0
    new_rank = sum(1 for i in range(min(S_new.shape)) if S_new[i, i] != 0)

    if old_rank == new_rank:
        if old_factors == new_factors:
            color = '#4CAF50'  # Green: birth free
            event = 'Birth'
        else:
            color = '#FF9800'  # Orange: torsion change
            event = 'Torsion'
    else:
        color = '#2196F3'  # Blue: kill free
        event = 'Kill'

    steps.append(idx + 1)
    torsion_history.append(new_factors.copy())
    event_colors.append(color)

    M_old = M_new
    old_factors = new_factors

# ============================================================
# Create visualization
# ============================================================

fig, (ax1, ax2) = plt.subplots(2, 1, figsize=(14, 10), gridspec_kw={'height_ratios': [2, 1]})

# Top panel: Torsion spectrum evolution (heatmap-style)
max_factors = max(len(t) for t in torsion_history) if torsion_history else 1
max_factors = max(max_factors, 1)

# Create heatmap data
heatmap = np.zeros((max_factors, len(steps)))
for i, factors in enumerate(torsion_history):
    for j, f in enumerate(factors):
        heatmap[j, i] = np.log2(f) if f > 0 else 0

im = ax1.imshow(heatmap, aspect='auto', cmap='YlOrRd', interpolation='nearest',
                origin='lower', extent=[0.5, len(steps)+0.5, -0.5, max_factors-0.5])

# Mark event types on top
for i, color in enumerate(event_colors):
    ax1.plot(i + 1, max_factors - 0.3, 's', color=color, markersize=4)

ax1.set_xlabel('Insertion Step', fontsize=12)
ax1.set_ylabel('Invariant Factor Index', fontsize=12)
ax1.set_title('Torsion Spectrum Evolution Under Triangle Insertion', fontsize=14, fontweight='bold')

cbar = plt.colorbar(im, ax=ax1, label='log₂(factor)')

# Legend
birth_patch = mpatches.Patch(color='#4CAF50', label='Free Birth')
kill_patch = mpatches.Patch(color='#2196F3', label='Free Kill')
torsion_patch = mpatches.Patch(color='#FF9800', label='Torsion Change')
ax1.legend(handles=[birth_patch, kill_patch, torsion_patch], loc='upper right', fontsize=10)

# Bottom panel: Torsion mass over time
masses = [1]
for factors in torsion_history:
    m = 1
    for f in factors:
        m *= f
    masses.append(m)

ax2.fill_between(range(len(masses)), masses, alpha=0.3, color='#FF9800')
ax2.plot(range(len(masses)), masses, 'o-', color='#E65100', markersize=3, linewidth=1.5)

# Mark torsion events
for i, color in enumerate(event_colors):
    if color == '#FF9800':
        ax2.axvline(x=i+1, color='#FF9800', alpha=0.3, linewidth=1)

ax2.set_xlabel('Insertion Step', fontsize=12)
ax2.set_ylabel('Torsion Mass |Tor(H₁)|', fontsize=12)
ax2.set_title('Torsion Mass Evolution (Product of Invariant Factors)', fontsize=14, fontweight='bold')
ax2.set_yscale('symlog', linthresh=1)
ax2.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('viz_torsion_spectrum.png', dpi=150, bbox_inches='tight')
print("Saved viz_torsion_spectrum.png")
