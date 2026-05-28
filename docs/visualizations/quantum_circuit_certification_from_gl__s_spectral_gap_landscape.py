"""
Visualization: Spectral Gap Landscape

Plots the distribution of spectral gaps across different generator pairs
in GL₂(𝔽₅), testing the optimal spectral gap conjecture Δ ≥ 1/(2√q).

This script is fully self-contained — no local imports.
"""

import numpy as np
import matplotlib.pyplot as plt
from itertools import product


def gl2_fq_elements(q):
    elements = []
    for a, b, c, d in product(range(q), repeat=4):
        if (a * d - b * c) % q != 0:
            elements.append(np.array([[a, b], [c, d]], dtype=int))
    return elements


def build_idx_map(elements, q):
    idx_map = {}
    for i, A in enumerate(elements):
        key = tuple(int(A[r, c] % q) for r in range(2) for c in range(2))
        idx_map[key] = i
    return idx_map


def mat_inv(A, q):
    det = int((A[0, 0] * A[1, 1] - A[0, 1] * A[1, 0]) % q)
    det_inv = pow(det, q - 2, q)
    return (det_inv * np.array([[A[1, 1], -A[0, 1]], [-A[1, 0], A[0, 0]]])) % q


def compute_gap(elements, g, h, q, idx_map):
    """Compute spectral gap for a generator pair."""
    N = len(elements)
    g_inv, h_inv = mat_inv(g, q), mat_inv(h, q)
    T = np.zeros((N, N))
    for i, x in enumerate(elements):
        for s in [g, g_inv, h, h_inv]:
            sx = (s @ x) % q
            key = tuple(int(sx[r, c] % q) for r in range(2) for c in range(2))
            T[idx_map[key], i] += 0.25
    eigs = np.sort(np.real(np.linalg.eigvals(T)))[::-1]
    return 1.0 - eigs[1], eigs


# Setup
q = 5
elements = gl2_fq_elements(q)
N = len(elements)
idx_map = build_idx_map(elements, q)

# Sample random generator pairs and compute their spectral gaps
np.random.seed(42)
num_samples = 200
gaps = []
design_depths_01 = []

for _ in range(num_samples):
    i1, i2 = np.random.choice(N, 2, replace=False)
    g_test = elements[i1]
    h_test = elements[i2]
    try:
        gap_val, _ = compute_gap(elements, g_test, h_test, q, idx_map)
        if gap_val > 1e-10:  # Only connected graphs
            gaps.append(gap_val)
            depth = int(np.ceil(np.log(10) / np.log(1 / (1 - gap_val))))
            design_depths_01.append(depth)
    except Exception:
        pass

conjecture_bound = 1 / (2 * np.sqrt(q))

# Also compute gap for our specific pair
g_specific = np.array([[0, 1], [4, 1]], dtype=int)
h_specific = np.array([[1, 1], [0, 1]], dtype=int)
gap_specific, eigs_specific = compute_gap(elements, g_specific, h_specific, q, idx_map)

# Plot
fig, axes = plt.subplots(1, 3, figsize=(16, 5))

# Plot 1: Histogram of spectral gaps
ax1 = axes[0]
ax1.hist(gaps, bins=30, color='#2196F3', alpha=0.7, edgecolor='white')
ax1.axvline(x=conjecture_bound, color='red', linestyle='--', linewidth=2,
            label=f'Conjecture: 1/(2√{q}) = {conjecture_bound:.4f}')
ax1.axvline(x=gap_specific, color='#4CAF50', linestyle='-', linewidth=2,
            label=f'Our pair: Δ = {gap_specific:.4f}')
ax1.set_xlabel('Spectral Gap Δ', fontsize=12)
ax1.set_ylabel('Count', fontsize=12)
ax1.set_title(f'Spectral Gap Distribution\n({num_samples} random pairs in GL₂(𝔽₅))',
              fontsize=13)
ax1.legend(fontsize=9)
ax1.grid(True, alpha=0.3)

# Plot 2: Gap vs Design Depth
ax2 = axes[1]
ax2.scatter(gaps, design_depths_01, s=15, alpha=0.6, color='#FF9800')
ax2.axvline(x=conjecture_bound, color='red', linestyle='--', linewidth=1.5)
ax2.scatter([gap_specific],
            [int(np.ceil(np.log(10) / np.log(1 / (1 - gap_specific))))],
            s=100, color='#4CAF50', zorder=5, marker='*',
            label=f'Our pair')
ax2.set_xlabel('Spectral Gap Δ', fontsize=12)
ax2.set_ylabel('Design Depth (ε=0.1)', fontsize=12)
ax2.set_title('Spectral Gap vs Design Depth', fontsize=13)
ax2.legend(fontsize=10)
ax2.grid(True, alpha=0.3)

# Plot 3: Full eigenvalue spectrum for our pair
ax3 = axes[2]
sorted_eigs = np.sort(np.real(eigs_specific))[::-1]
ax3.bar(range(min(80, len(sorted_eigs))), sorted_eigs[:80],
        color='#9C27B0', alpha=0.7, width=1.0)
ax3.axhline(y=1 - gap_specific, color='#FF5722', linestyle='--',
            linewidth=2, label=f'1−Δ = {1-gap_specific:.4f}')
ax3.axhline(y=-1 + gap_specific, color='#FF5722', linestyle='--',
            linewidth=1)
ax3.set_xlabel('Eigenvalue Index', fontsize=12)
ax3.set_ylabel('Eigenvalue', fontsize=12)
ax3.set_title(f'Walk Operator Spectrum\n(Δ = {gap_specific:.4f})', fontsize=13)
ax3.legend(fontsize=10)
ax3.grid(True, alpha=0.3)

plt.suptitle('Spectral Landscape of GL₂(𝔽₅) Cayley Graphs',
             fontsize=14, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('spectral_landscape.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved spectral_landscape.png")
