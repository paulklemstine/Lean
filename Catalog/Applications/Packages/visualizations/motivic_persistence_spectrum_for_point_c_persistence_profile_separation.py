"""
Visualization: Persistence Profile Separation

Shows how the arithmetic persistence profile (Hankel rank profile)
separates signals with different spectral orders, illustrating
the bridge between arithmetic geometry and topological data analysis.

Creates a 2x2 panel:
- Top-left: Persistence profiles for different spectral orders
- Top-right: Vandermonde determinant magnitude vs number of eigenvalues
- Bottom-left: Spectral identifiability — collision search results
- Bottom-right: Prony reconstruction accuracy across spectral orders
"""

import numpy as np
import matplotlib.pyplot as plt
from numpy.linalg import matrix_rank, det
from itertools import combinations


def power_sum_signal(alphas, r_max):
    return np.array([sum(a**r for a in alphas) for r in range(r_max)])


def hankel_matrix(seq, n):
    H = np.zeros((n, n), dtype=seq.dtype)
    for i in range(n):
        for j in range(n):
            if i + j < len(seq):
                H[i, j] = seq[i + j]
    return H


fig, axes = plt.subplots(2, 2, figsize=(13, 10))
fig.suptitle('Arithmetic Persistence: Spectral Separation & Identifiability',
             fontsize=15, fontweight='bold')

# Panel 1: Persistence profiles showing separation
ax1 = axes[0, 0]
test_spectra = [
    ("m=1", [2.0]),
    ("m=2", [1.0, 3.0]),
    ("m=3", [1.0, 2.0, 3.0]),
    ("m=4", [1.0, 2.0, 3.0, 5.0]),
    ("m=5", [1.0, 2.0, 3.0, 5.0, 7.0]),
]
colors_main = ['#e41a1c', '#ff7f00', '#4daf4a', '#377eb8', '#984ea3']
n_max = 8
for (name, alphas), color in zip(test_spectra, colors_main):
    seq = power_sum_signal(np.array(alphas), 2 * n_max + 2)
    profile = [0]
    for n in range(1, n_max + 1):
        H = hankel_matrix(seq, n)
        profile.append(matrix_rank(H, tol=1e-10))
    ax1.plot(range(n_max + 1), profile, 'o-', color=color, label=name,
             markersize=7, linewidth=2)
    ax1.axhline(y=len(alphas), color=color, linestyle=':', alpha=0.3)
ax1.set_title('Persistence Profiles (Theorem 4)', fontsize=11)
ax1.set_xlabel('Truncation level n')
ax1.set_ylabel('rank(Hₙ) = persistence profile')
ax1.legend(title='Spectral order', fontsize=9)
ax1.grid(True, alpha=0.3)
ax1.set_yticks(range(6))

# Panel 2: Vandermonde determinant
ax2 = axes[0, 1]
m_values = range(2, 7)
det_magnitudes = []
for m in m_values:
    alphas = np.arange(1, m + 1, dtype=float)
    V = np.array([[a**i for i in range(m)] for a in alphas])
    d = abs(det(V))
    det_magnitudes.append(d)
ax2.semilogy(list(m_values), det_magnitudes, 'ko-', markersize=10, linewidth=2)
ax2.set_title('Vandermonde Determinant Magnitude', fontsize=11)
ax2.set_xlabel('Number of distinct eigenvalues m')
ax2.set_ylabel('|det V_m| (log scale)')
ax2.grid(True, alpha=0.3)
ax2.annotate('Nonzero ⟹ full rank\n(Theorem 2b)',
             xy=(4, det_magnitudes[2]), fontsize=9,
             xytext=(4.5, det_magnitudes[2] * 10),
             arrowprops=dict(arrowstyle='->', color='gray'))

# Panel 3: Identifiability collision search
ax3 = axes[1, 0]
search_sizes = [2, 3, 4]
powersum_collisions = []
profile_collisions = []
total_pairs_list = []

for m in search_sizes:
    vals = range(-3, 4)
    spectra = list(combinations(vals, m))
    n_pairs = 0
    ps_col = 0
    pr_col = 0
    for s1, s2 in combinations(spectra, 2):
        n_pairs += 1
        a1 = np.array(s1, dtype=float)
        a2 = np.array(s2, dtype=float)
        seq1 = power_sum_signal(a1, 2 * m + 2)
        seq2 = power_sum_signal(a2, 2 * m + 2)
        # Check power sum match for r < 2m
        if np.allclose(seq1[:2*m], seq2[:2*m]):
            if not np.allclose(sorted(s1), sorted(s2)):
                ps_col += 1
        # Check profile match
        p1 = [matrix_rank(hankel_matrix(seq1, n), tol=1e-10)
              for n in range(1, m + 2)]
        p2 = [matrix_rank(hankel_matrix(seq2, n), tol=1e-10)
              for n in range(1, m + 2)]
        if p1 == p2 and not np.allclose(sorted(s1), sorted(s2)):
            pr_col += 1
    total_pairs_list.append(n_pairs)
    powersum_collisions.append(ps_col)
    profile_collisions.append(pr_col)

x = np.arange(len(search_sizes))
width = 0.35
ax3.bar(x - width/2, powersum_collisions, width, label='Power sum collisions',
        color='#e41a1c', alpha=0.8)
ax3.bar(x + width/2, profile_collisions, width, label='Profile collisions',
        color='#377eb8', alpha=0.8)
ax3.set_xticks(x)
ax3.set_xticklabels([f'm={m}\n({n} pairs)' for m, n in
                      zip(search_sizes, total_pairs_list)])
ax3.set_title('Identifiability: Collision Search (Thm 3)', fontsize=11)
ax3.set_ylabel('Number of collisions')
ax3.legend()
ax3.grid(True, alpha=0.3, axis='y')
for i, (ps, pr) in enumerate(zip(powersum_collisions, profile_collisions)):
    ax3.text(i - width/2, ps + 0.5, str(ps), ha='center', fontsize=10)
    ax3.text(i + width/2, pr + 0.5, str(pr), ha='center', fontsize=10)

# Panel 4: Prony reconstruction accuracy
ax4 = axes[1, 1]
for m, color in zip([2, 3, 4], ['#e41a1c', '#4daf4a', '#377eb8']):
    alphas = np.arange(1, m + 1, dtype=float)
    errors = []
    sample_counts = range(2*m, 2*m + 8)
    for r_max in sample_counts:
        seq = power_sum_signal(alphas, r_max)
        H = np.array([[seq[i+j] for j in range(m)] for i in range(m)])
        h = np.array([seq[i+m] for i in range(m)])
        try:
            c = np.linalg.solve(H, -h)
            poly_c = np.zeros(m + 1)
            poly_c[m] = 1.0
            for i in range(m):
                poly_c[i] = c[i]
            roots = np.sort(np.real(np.roots(poly_c[::-1])))
            err = np.max(np.abs(roots - np.sort(alphas)))
        except Exception:
            err = 1.0
        errors.append(max(err, 1e-16))
    ax4.semilogy(list(sample_counts), errors, 'o-', color=color,
                 label=f'm={m}', markersize=6, linewidth=2)
ax4.axhline(y=1e-12, color='gray', linestyle='--', alpha=0.5,
            label='Machine ε')
ax4.set_title('Prony Reconstruction Accuracy', fontsize=11)
ax4.set_xlabel('Number of power sums')
ax4.set_ylabel('Max reconstruction error')
ax4.legend()
ax4.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('vis_persistence_separation.png', dpi=150, bbox_inches='tight')
print("Saved vis_persistence_separation.png")
