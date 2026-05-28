#!/usr/bin/env python3
"""
Visualization 3: Multiindex Space and Boolean Assignment Encoding

Illustrates the combinatorial structure underlying the Lorentzian certificate
complexity framework:
  - How Boolean assignments map to multiindices
  - The exponential growth of multiindex counts
  - The injection from {0,1}^n to derivative directions

Creates a multi-panel figure showing the algebraic encoding.
"""

import matplotlib.pyplot as plt
import matplotlib
matplotlib.use('Agg')
import numpy as np
from itertools import product
import math


# ============================================================
# Multiindex enumeration
# ============================================================

def enumerate_multiindices(n, d):
    """All multiindices α in n variables with Σα = d."""
    if n == 0:
        return [()] if d == 0 else []
    if n == 1:
        return [(d,)]
    result = []
    for k in range(d + 1):
        for rest in enumerate_multiindices(n - 1, d - k):
            result.append((k,) + rest)
    return result


def assignment_to_multiindex(tau, n):
    """Map Boolean assignment τ ∈ {0,1}^n to multiindex in 2n variables."""
    alpha = [0] * (2 * n)
    for i in range(n):
        if tau[i]:
            alpha[2 * i] = 1
        else:
            alpha[2 * i + 1] = 1
    return tuple(alpha)


# ============================================================
# Collect data
# ============================================================

# Multiindex counts for different (n, d) pairs
max_n = 8
max_d = 8
counts = np.zeros((max_n, max_d))
for n in range(1, max_n + 1):
    for d in range(1, max_d + 1):
        mis = enumerate_multiindices(n, d)
        counts[n-1, d-1] = len(mis)

# Boolean assignment encoding data
encoding_data = []
for n in range(1, 7):
    assignments = list(product([0, 1], repeat=n))
    multiindices = [assignment_to_multiindex(tau, n) for tau in assignments]
    encoding_data.append({
        'n': n,
        'n_assignments': len(assignments),
        'n_multiindices': len(set(multiindices)),
        'all_distinct': len(set(multiindices)) == len(assignments)
    })


# ============================================================
# Create visualization
# ============================================================

fig = plt.figure(figsize=(15, 10))

# Panel 1: Multiindex count heatmap
ax1 = fig.add_subplot(2, 2, 1)
im = ax1.imshow(np.log2(counts + 1), aspect='auto', cmap='YlOrRd',
                origin='lower', extent=[0.5, max_d+0.5, 0.5, max_n+0.5])
ax1.set_xlabel('Degree d', fontsize=12)
ax1.set_ylabel('Variables n', fontsize=12)
ax1.set_title('log₂(Multiindex Count)', fontsize=12)
plt.colorbar(im, ax=ax1, label='log₂(count)')

# Add count annotations
for i in range(min(6, max_n)):
    for j in range(min(6, max_d)):
        val = int(counts[i, j])
        if val < 10000:
            ax1.text(j+1, i+1, str(val), ha='center', va='center',
                    fontsize=7, color='black' if counts[i,j] < 100 else 'white')

# Panel 2: Growth curves
ax2 = fig.add_subplot(2, 2, 2)
for n in [2, 3, 4, 5]:
    ds = list(range(1, max_d + 1))
    cs = [counts[n-1, d-1] for d in ds]
    ax2.semilogy(ds, cs, 'o-', linewidth=2, markersize=6, label=f'n={n}')

# Add n^d upper bounds
ds_fine = np.linspace(1, max_d, 100)
for n in [2, 3, 4]:
    ax2.semilogy(ds_fine, n**ds_fine, '--', alpha=0.3, linewidth=1)

ax2.set_xlabel('Degree d', fontsize=12)
ax2.set_ylabel('Multiindex count', fontsize=12)
ax2.set_title('Multiindex Count Growth (≤ n^d)', fontsize=12)
ax2.legend(fontsize=10)
ax2.grid(True, alpha=0.3)

# Panel 3: Boolean assignment encoding
ax3 = fig.add_subplot(2, 2, 3)
ns_enc = [d['n'] for d in encoding_data]
n_assign = [d['n_assignments'] for d in encoding_data]
n_multi = [d['n_multiindices'] for d in encoding_data]

x = np.arange(len(ns_enc))
width = 0.35
bars1 = ax3.bar(x - width/2, n_assign, width, label='Boolean assignments (2^n)',
                color='steelblue', alpha=0.8)
bars2 = ax3.bar(x + width/2, n_multi, width, label='Distinct multiindices',
                color='coral', alpha=0.8)

ax3.set_xlabel('n (variables)', fontsize=12)
ax3.set_ylabel('Count', fontsize=12)
ax3.set_title('Assignment → Multiindex Injection', fontsize=12)
ax3.set_xticks(x)
ax3.set_xticklabels(ns_enc)
ax3.legend(fontsize=10)
ax3.set_yscale('log')
ax3.grid(True, alpha=0.3, axis='y')

# Panel 4: Example encoding for n=3
ax4 = fig.add_subplot(2, 2, 4)
n_example = 3
assignments_3 = list(product([0, 1], repeat=n_example))
multiindices_3 = [assignment_to_multiindex(tau, n_example) for tau in assignments_3]

# Show as a table-like visualization
y_positions = list(range(len(assignments_3)))
for idx, (tau, alpha) in enumerate(zip(assignments_3, multiindices_3)):
    tau_str = ''.join(str(b) for b in tau)
    alpha_str = ','.join(str(a) for a in alpha)
    color = 'steelblue' if sum(tau) > n_example // 2 else 'coral'

    ax4.barh(idx, sum(tau), height=0.4, color=color, alpha=0.6)
    ax4.text(-0.5, idx, f'τ=({tau_str})', ha='right', va='center', fontsize=8,
             fontfamily='monospace')
    ax4.text(n_example + 0.3, idx, f'α=({alpha_str})', ha='left', va='center',
             fontsize=8, fontfamily='monospace')

ax4.set_xlabel('Weight of τ (number of true variables)', fontsize=10)
ax4.set_ylabel('Assignment index', fontsize=10)
ax4.set_title(f'Boolean → Multiindex Encoding (n={n_example})', fontsize=12)
ax4.set_xlim(-3, n_example + 4)
ax4.grid(True, alpha=0.3, axis='x')

plt.tight_layout()
plt.savefig('viz_multiindex_space.png', dpi=150, bbox_inches='tight')
print("Saved viz_multiindex_space.png")
