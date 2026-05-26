"""
Visualization: Event Type Distribution Across Random 2-Complexes

Shows the statistical distribution of Birth/Kill/Torsion events
as triangles are inserted into random Linial-Meshulam-style complexes.
Reveals the torsion phase transition and tests the prime-local
torsion pulse conjecture.
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

def smith_normal_form_small(M):
    M = np.array(M, dtype=np.int64)
    m, n = M.shape
    S = M.copy()
    for k in range(min(m, n)):
        piv = None
        for i in range(k, m):
            for j in range(k, n):
                if S[i, j] != 0 and (piv is None or abs(S[i, j]) < abs(S[piv[0], piv[1]])):
                    piv = (i, j)
        if piv is None:
            break
        i, j = piv
        if i != k:
            S[[k, i]] = S[[i, k]]
        if j != k:
            S[:, [k, j]] = S[:, [j, k]]
        changed = True
        while changed:
            changed = False
            for i in range(k + 1, m):
                if S[i, k] != 0:
                    if S[i, k] % S[k, k] == 0:
                        S[i, :] -= (S[i, k] // S[k, k]) * S[k, :]
                    else:
                        g, x, y = _extended_gcd(int(S[k, k]), int(S[i, k]))
                        a, b = S[k, k] // g, S[i, k] // g
                        rk, ri = S[k, :].copy(), S[i, :].copy()
                        S[k, :] = x * rk + y * ri
                        S[i, :] = -b * rk + a * ri
                    changed = True
            for j in range(k + 1, n):
                if S[k, j] != 0:
                    if S[k, j] % S[k, k] == 0:
                        S[:, j] -= (S[k, j] // S[k, k]) * S[:, k]
                    else:
                        g, x, y = _extended_gcd(int(S[k, k]), int(S[k, j]))
                        a, b = S[k, k] // g, S[k, j] // g
                        ck, cj = S[:, k].copy(), S[:, j].copy()
                        S[:, k] = x * ck + y * cj
                        S[:, j] = -b * ck + a * cj
                    changed = True
        if S[k, k] < 0:
            S[k, :] *= -1
    # Enforce divisibility
    for _ in range(min(m, n)):
        for k in range(min(m, n) - 1):
            if S[k, k] != 0 and S[k+1, k+1] != 0 and S[k+1, k+1] % S[k, k] != 0:
                S[k, :] += S[k+1, :]
                ch = True
                while ch:
                    ch = False
                    for i in range(k+1, m):
                        if S[i, k] != 0:
                            if S[i, k] % S[k, k] == 0:
                                S[i, :] -= (S[i, k] // S[k, k]) * S[k, :]
                            else:
                                g, x, y = _extended_gcd(int(S[k, k]), int(S[i, k]))
                                a, b = S[k, k] // g, S[i, k] // g
                                rk, ri = S[k, :].copy(), S[i, :].copy()
                                S[k, :] = x * rk + y * ri
                                S[i, :] = -b * rk + a * ri
                            ch = True
                    for j in range(k+1, n):
                        if S[k, j] != 0:
                            if S[k, j] % S[k, k] == 0:
                                S[:, j] -= (S[k, j] // S[k, k]) * S[:, k]
                            else:
                                g, x, y = _extended_gcd(int(S[k, k]), int(S[k, j]))
                                a, b = S[k, k] // g, S[k, j] // g
                                ck, cj = S[:, k].copy(), S[:, j].copy()
                                S[:, k] = x * ck + y * cj
                                S[:, j] = -b * ck + a * cj
                            ch = True
                if S[k, k] < 0:
                    S[k, :] *= -1
    return S

def get_torsion(M):
    if M.size == 0 or M.shape[1] == 0:
        return []
    S = smith_normal_form_small(M)
    return sorted([abs(int(S[i,i])) for i in range(min(S.shape)) if abs(S[i,i]) > 1])

def boundary_matrix_2(edges_list, tris_list):
    if not edges_list or not tris_list:
        return np.zeros((max(len(edges_list), 1), 0), dtype=np.int64)
    edge_idx = {e: i for i, e in enumerate(edges_list)}
    M = np.zeros((len(edges_list), len(tris_list)), dtype=np.int64)
    for j, tri in enumerate(tris_list):
        verts = sorted(tri)
        for k, v in enumerate(verts):
            face = frozenset(verts[:k] + verts[k+1:])
            if face in edge_idx:
                M[edge_idx[face], j] = (-1) ** k
    return M

# ============================================================
# Run experiments
# ============================================================

random.seed(42)
np.random.seed(42)

n_vertices_list = [6, 7, 8]
n_trials = 15

fig, axes = plt.subplots(2, 3, figsize=(18, 10))

for col, nv in enumerate(n_vertices_list):
    all_edges = [frozenset({i, j}) for i in range(nv) for j in range(i+1, nv)]
    all_tris = [frozenset({i, j, k}) for i in range(nv)
                for j in range(i+1, nv) for k in range(j+1, nv)]
    n_tris = len(all_tris)

    # Cumulative event fractions
    birth_counts = np.zeros(n_tris)
    kill_counts = np.zeros(n_tris)
    torsion_counts = np.zeros(n_tris)
    mass_history = np.zeros(n_tris)

    for trial in range(n_trials):
        order = list(range(n_tris))
        random.shuffle(order)

        edges_list = sorted(all_edges, key=lambda e: tuple(sorted(e)))
        tris_so_far = []

        for step, idx in enumerate(order):
            tri = all_tris[idx]
            tris_so_far_old = list(tris_so_far)
            tris_so_far.append(tri)

            M_old = boundary_matrix_2(edges_list, tris_so_far_old)
            M_new = boundary_matrix_2(edges_list, tris_so_far)

            old_factors = get_torsion(M_old)
            new_factors = get_torsion(M_new)

            S_old = smith_normal_form_small(M_old) if M_old.shape[1] > 0 else np.zeros((1, 0), dtype=np.int64)
            S_new = smith_normal_form_small(M_new)
            old_rank = sum(1 for i in range(min(S_old.shape)) if S_old[i,i] != 0) if M_old.shape[1] > 0 else 0
            new_rank = sum(1 for i in range(min(S_new.shape)) if S_new[i,i] != 0)

            if old_rank == new_rank:
                if old_factors == new_factors:
                    birth_counts[step] += 1
                else:
                    torsion_counts[step] += 1
            else:
                kill_counts[step] += 1

            mass = 1
            for f in new_factors:
                mass *= f
            mass_history[step] += mass

    # Normalize
    birth_frac = np.cumsum(birth_counts) / (np.arange(n_tris) + 1) / n_trials
    kill_frac = np.cumsum(kill_counts) / (np.arange(n_tris) + 1) / n_trials
    torsion_frac = np.cumsum(torsion_counts) / (np.arange(n_tris) + 1) / n_trials
    avg_mass = mass_history / n_trials

    x = np.arange(n_tris) / n_tris  # Fraction of triangles inserted

    # Top row: stacked area of event fractions
    ax = axes[0, col]
    ax.fill_between(x, 0, birth_counts / n_trials, alpha=0.6, color='#4CAF50', label='Birth')
    ax.fill_between(x, birth_counts / n_trials,
                    (birth_counts + kill_counts) / n_trials, alpha=0.6, color='#2196F3', label='Kill')
    ax.fill_between(x, (birth_counts + kill_counts) / n_trials,
                    (birth_counts + kill_counts + torsion_counts) / n_trials,
                    alpha=0.6, color='#FF9800', label='Torsion')
    ax.set_xlabel('Insertion Step', fontsize=11)
    ax.set_ylabel('Events per Step', fontsize=11)
    ax.set_title(f'n = {nv} vertices ({n_tris} triangles)', fontsize=13, fontweight='bold')
    if col == 2:
        ax.legend(loc='upper right', fontsize=9)
    ax.grid(True, alpha=0.2)

    # Bottom row: torsion mass evolution
    ax2 = axes[1, col]
    ax2.plot(x, avg_mass, '-', color='#E65100', linewidth=1.5)
    ax2.fill_between(x, 1, avg_mass, alpha=0.2, color='#FF9800')
    ax2.set_xlabel('Fraction of Triangles Inserted', fontsize=11)
    ax2.set_ylabel('Avg Torsion Mass', fontsize=11)
    ax2.set_title(f'Torsion Mass Evolution (n={nv})', fontsize=13, fontweight='bold')
    ax2.set_yscale('symlog', linthresh=1)
    ax2.grid(True, alpha=0.2)

    # Mark torsion phase transition region
    if np.max(avg_mass) > 1:
        transition_idx = np.argmax(avg_mass > 1)
        ax2.axvline(x=x[transition_idx], color='red', linestyle='--', alpha=0.5,
                    label='Phase transition')
        ax2.legend(fontsize=9)

fig.suptitle('Simplex Insertion Event Distribution in Random 2-Complexes\n'
             '(Linial-Meshulam model, averaged over 15 trials)',
             fontsize=15, fontweight='bold')

plt.tight_layout()
plt.savefig('viz_event_distribution.png', dpi=150, bbox_inches='tight')
print("Saved viz_event_distribution.png")
