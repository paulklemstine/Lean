#!/usr/bin/env python3
"""
Visualization 2: Torsion Echo Distribution Comparison

Samples random Erdős–Rényi graphs G(n, p) in the critical window and compares
the empirical distributions of torsion echoes at different primes. If the
distributions differ across primes, this provides computational evidence for
the Arithmetic Non-Universality Conjecture.

The plot shows histograms of echo_2, echo_3, and echo_5 side by side, making
the prime-specific behavior visually apparent.
"""

import numpy as np
import matplotlib.pyplot as plt
from collections import defaultdict


def padic_valuation(p: int, n: int) -> int:
    if n == 0 or p < 2:
        return 0
    n = abs(n)
    v = 0
    while n % p == 0:
        n //= p
        v += 1
    return v


def smith_normal_form_diag(M: np.ndarray) -> list:
    if M.size == 0:
        return []
    M = M.copy().astype(np.int64)
    rows, cols = M.shape
    n = min(rows, cols)
    diag = []
    for k in range(n):
        subM = M[k:, k:]
        if np.all(subM == 0):
            break
        nonzero = np.argwhere(subM != 0)
        abs_vals = np.abs(subM[nonzero[:, 0], nonzero[:, 1]])
        idx = nonzero[np.argmin(abs_vals)]
        pi, pj = idx[0] + k, idx[1] + k
        M[[k, pi]] = M[[pi, k]]
        M[:, [k, pj]] = M[:, [pj, k]]
        changed = True
        iters = 0
        while changed and iters < 3000:
            changed = False
            iters += 1
            for i in range(k + 1, rows):
                if M[i, k] != 0:
                    q = int(M[i, k]) // int(M[k, k])
                    M[i] -= q * M[k]
                    if M[i, k] != 0:
                        if abs(M[i, k]) < abs(M[k, k]):
                            M[[k, i]] = M[[i, k]]
                        changed = True
            for j in range(k + 1, cols):
                if M[k, j] != 0:
                    q = int(M[k, j]) // int(M[k, k])
                    M[:, j] -= q * M[:, k]
                    if M[k, j] != 0:
                        if abs(M[k, j]) < abs(M[k, k]):
                            M[:, [k, j]] = M[:, [j, k]]
                        changed = True
            for i in range(k + 1, rows):
                for j in range(k + 1, cols):
                    if int(M[i, j]) % int(M[k, k]) != 0:
                        M[i] += M[k]
                        changed = True
                        break
                if changed:
                    break
        diag.append(abs(int(M[k, k])))
    return diag


def torsion_echo(p, factors):
    return sum(padic_valuation(p, d) for d in factors)


def erdos_renyi_edges(n, p, rng):
    edges = set()
    for i in range(n):
        for j in range(i + 1, n):
            if rng.random() < p:
                edges.add((i, j))
    return edges


def build_flag_complex(n, edges, max_dim=2):
    adj = defaultdict(set)
    for i, j in edges:
        adj[i].add(j)
        adj[j].add(i)
    simplices = {0: [(v,) for v in range(n)]}
    for k in range(1, max_dim + 1):
        new = []
        for s in simplices.get(k - 1, []):
            last = s[-1]
            cands = set(range(last + 1, n))
            for v in s:
                cands &= adj[v]
            for v in sorted(cands):
                new.append(s + (v,))
        simplices[k] = new
        if not new:
            break
    return simplices


def boundary_matrix_fn(simplices_k, simplices_km1):
    if not simplices_k or not simplices_km1:
        return np.zeros((len(simplices_km1), len(simplices_k)), dtype=np.int64)
    idx = {s: i for i, s in enumerate(simplices_km1)}
    B = np.zeros((len(simplices_km1), len(simplices_k)), dtype=np.int64)
    for j, sigma in enumerate(simplices_k):
        for fi in range(len(sigma)):
            face = sigma[:fi] + sigma[fi + 1:]
            if face in idx:
                B[idx[face], j] = (-1) ** fi
    return B


# ──────────────────────────────────────────────────────────────────
# Sampling experiment
# ──────────────────────────────────────────────────────────────────

rng = np.random.default_rng(42)
n_vertices = 12
p_edge = n_vertices ** (-0.5) * 1.8  # critical window
n_samples = 200
primes_to_check = [2, 3, 5]
colors_map = {2: '#e41a1c', 3: '#377eb8', 5: '#4daf4a'}

echo_data = {p: [] for p in primes_to_check}

for trial in range(n_samples):
    edges = erdos_renyi_edges(n_vertices, p_edge, rng)
    simplices = build_flag_complex(n_vertices, edges, 2)

    total_echo = {p: 0 for p in primes_to_check}
    for k in range(1, 3):
        if k in simplices and simplices[k] and k - 1 in simplices:
            B = boundary_matrix_fn(simplices[k], simplices[k - 1])
            snf = smith_normal_form_diag(B)
            nontrivial = [d for d in snf if d > 1]
            for p in primes_to_check:
                total_echo[p] += torsion_echo(p, nontrivial)

    for p in primes_to_check:
        echo_data[p].append(total_echo[p])

# ──────────────────────────────────────────────────────────────────
# Plot
# ──────────────────────────────────────────────────────────────────

fig, axes = plt.subplots(1, 3, figsize=(15, 5), sharey=True)

for idx, p in enumerate(primes_to_check):
    ax = axes[idx]
    data = echo_data[p]
    max_val = max(data) if data else 0
    bins = np.arange(-0.5, max_val + 1.5, 1)
    ax.hist(data, bins=bins, color=colors_map[p], alpha=0.7, edgecolor='black',
            linewidth=0.5, density=True)
    ax.set_title(f'echo$_{p}$', fontsize=14, fontweight='bold')
    ax.set_xlabel('Torsion Echo Value', fontsize=12)
    if idx == 0:
        ax.set_ylabel('Density', fontsize=12)
    mean_val = np.mean(data)
    std_val = np.std(data)
    ax.axvline(mean_val, color='black', linestyle='--', linewidth=1.5,
               label=f'μ={mean_val:.2f}, σ={std_val:.2f}')
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)

fig.suptitle(
    f'Torsion Echo Distributions for Random Flag Complexes\n'
    f'G({n_vertices}, {p_edge:.3f}), {n_samples} samples',
    fontsize=15, fontweight='bold', y=1.02
)

plt.tight_layout()
plt.savefig('viz_echo_distribution.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved viz_echo_distribution.png")
