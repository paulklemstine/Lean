#!/usr/bin/env python3
"""
Visualization: Derivative Tree Growth and SAT-Branch Correspondence

Shows how the derivative tree of a polynomial grows exponentially
when degree is unbounded, and illustrates the structural parallel
with Boolean satisfiability search trees.
"""

import matplotlib.pyplot as plt
import numpy as np
import math

fig, axes = plt.subplots(1, 3, figsize=(18, 6))

# --- Panel 1: Growth rates comparison ---
ax1 = axes[0]
ds = np.arange(2, 18)

# Exact multiindex count for balanced regime (n = d)
exact = [math.comb(2*d - 3, d - 2) for d in ds]
lower = [2**(d-2) for d in ds]
upper = [d**(d-2) for d in ds]

ax1.semilogy(ds, exact, 'ko-', label='C(2d-3, d-2) exact', markersize=6, linewidth=2)
ax1.semilogy(ds, lower, 'b^--', label='2^(d-2) lower bound', markersize=5)
ax1.semilogy(ds, upper, 'rv--', label='d^(d-2) upper bound', markersize=5)

# Polynomial growth references
for c in [2, 3, 5]:
    poly = [d**c for d in ds]
    ax1.semilogy(ds, poly, ':', alpha=0.3, color='gray')
    ax1.text(ds[-1] + 0.3, poly[-1], f'd^{c}', fontsize=8, color='gray', va='center')

ax1.set_xlabel('Degree d (= n, balanced regime)', fontsize=12)
ax1.set_ylabel('Number of quadratic leaves', fontsize=12)
ax1.set_title('Exponential Leaf Growth\n(Formally Verified)', fontsize=13, fontweight='bold')
ax1.legend(fontsize=9, loc='upper left')
ax1.grid(True, alpha=0.3)

# --- Panel 2: SAT-Branch Correspondence ---
ax2 = axes[1]

# Number of assignments vs number of derivative branches
ms = np.arange(1, 14)
assignments = [2**m for m in ms]
branches = [math.comb(m + m - 1, m) for m in ms]  # C(2m-1, m) for n=m+1, d=m

ax2.semilogy(ms, assignments, 'bs-', label='2^m (assignments)', markersize=6, linewidth=2)
ax2.semilogy(ms, branches, 'ro-', label='C(2m-1,m) (branches)', markersize=6, linewidth=2)

ax2.fill_between(ms, assignments, branches, alpha=0.1, color='purple')

ax2.set_xlabel('m (variables / derivative depth)', fontsize=12)
ax2.set_ylabel('Count', fontsize=12)
ax2.set_title('Assignment-Branch Correspondence\n2^m ≤ branches (Theorem)', fontsize=13, fontweight='bold')
ax2.legend(fontsize=10)
ax2.grid(True, alpha=0.3)

# --- Panel 3: Certificate complexity heatmap ---
ax3 = axes[2]

n_range = np.arange(3, 16)
d_range = np.arange(3, 16)
log_cert = np.zeros((len(d_range), len(n_range)))

for i, d in enumerate(d_range):
    for j, n in enumerate(n_range):
        cert = math.comb(n + d - 3, d - 2)
        log_cert[i, j] = math.log2(cert) if cert > 0 else 0

im = ax3.imshow(log_cert, aspect='auto', cmap='YlOrRd',
                extent=[n_range[0]-0.5, n_range[-1]+0.5,
                        d_range[-1]+0.5, d_range[0]-0.5])
plt.colorbar(im, ax=ax3, label='log₂(certificate size)')

# Draw the diagonal d = n
ax3.plot(n_range, n_range, 'w--', linewidth=2, label='d = n (phase boundary)')
ax3.legend(fontsize=9, loc='upper left')

ax3.set_xlabel('Number of variables n', fontsize=12)
ax3.set_ylabel('Degree d', fontsize=12)
ax3.set_title('Certificate Complexity Landscape\n(log₂ scale)', fontsize=13, fontweight='bold')

plt.suptitle('Derivative Tree Growth and Complexity Barriers',
             fontsize=15, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('derivative_tree.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved derivative_tree.png")
