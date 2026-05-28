#!/usr/bin/env python3
"""
Visualization: Hessian Descent — Lorentzian Signature vs Coefficient Inequalities

This script visualizes the relationship between the Lorentzian signature condition
(at most one positive eigenvalue) and the pairwise coefficient inequality
(A(i,i)*A(j,j) ≤ A(i,j)²) for 2×2 and 3×3 matrices.

The key insight: in 2D, the conditions are equivalent (blue = green region).
In 3D, pairwise det ≤ 0 is strictly weaker than Lorentzianity (gap region in red).
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from matplotlib.patches import FancyBboxPatch

fig, axes = plt.subplots(1, 3, figsize=(18, 5.5))

# ============================================================
# Panel 1: 2×2 case — full equivalence
# ============================================================
ax = axes[0]
ax.set_title('2×2 Matrices: Full Equivalence', fontsize=13, fontweight='bold')

# For [[1, b], [b, 1]], Lorentzian iff 1 ≤ b² iff |b| ≥ 1
# Pairwise det ≤ 0 iff same condition
b_vals = np.linspace(-3, 3, 500)
# Eigenvalues: 1+b, 1-b
eig1 = 1 + b_vals
eig2 = 1 - b_vals
n_pos = (eig1 > 0).astype(int) + (eig2 > 0).astype(int)
is_lorentzian = n_pos <= 1
pairwise_ok = b_vals**2 >= 1

ax.fill_between(b_vals, -1, 3, where=is_lorentzian, alpha=0.3, color='blue',
                label='Lorentzian (≤1 pos eigenvalue)')
ax.fill_between(b_vals, -1, 3, where=pairwise_ok, alpha=0.2, color='green',
                label='Pairwise det ≤ 0')
ax.plot(b_vals, eig1, 'r-', linewidth=1.5, label='λ₁ = 1+b')
ax.plot(b_vals, eig2, 'b-', linewidth=1.5, label='λ₂ = 1−b')
ax.axhline(y=0, color='k', linewidth=0.5)
ax.axvline(x=1, color='gray', linewidth=0.5, linestyle='--')
ax.axvline(x=-1, color='gray', linewidth=0.5, linestyle='--')
ax.set_xlabel('Off-diagonal entry b', fontsize=11)
ax.set_ylabel('Eigenvalue / Region', fontsize=11)
ax.set_ylim(-3, 3.5)
ax.legend(fontsize=8, loc='upper center')
ax.text(0, -2.5, 'NOT Lorentzian\n(2 pos eigenvalues)', ha='center',
        fontsize=9, color='red', style='italic')
ax.text(2, -2.5, 'Lorentzian ✓', ha='center', fontsize=9, color='blue')

# ============================================================
# Panel 2: 3×3 counterexample landscape
# ============================================================
ax = axes[1]
ax.set_title('3×3 Matrices: Gap Between Conditions', fontsize=13, fontweight='bold')

# Matrix [[1, t, s], [t, 1, -t*s], [s, -t*s, 1]] with t,s > 0
# Pairwise: 1 ≤ t², 1 ≤ s², 1 ≤ (ts)²  → need |t|,|s| ≥ 1
np.random.seed(42)
n_samples = 2000
t_vals = np.random.uniform(0.5, 3.0, n_samples)
s_vals = np.random.uniform(0.5, 3.0, n_samples)

lorentzian_points = []
pairwise_only_points = []
neither_points = []

for t, s in zip(t_vals, s_vals):
    A = np.array([[1, t, s], [t, 1, -t*s], [s, -t*s, 1]])
    eigs = np.linalg.eigvalsh(A)
    n_pos = np.sum(eigs > 1e-10)
    is_lor = n_pos <= 1

    pw_ok = (t**2 >= 1 - 1e-10) and (s**2 >= 1 - 1e-10) and ((t*s)**2 >= 1 - 1e-10)

    if is_lor and pw_ok:
        lorentzian_points.append((t, s))
    elif pw_ok and not is_lor:
        pairwise_only_points.append((t, s))
    else:
        neither_points.append((t, s))

if neither_points:
    pts = np.array(neither_points)
    ax.scatter(pts[:, 0], pts[:, 1], c='lightgray', s=8, alpha=0.5, label='Neither')
if pairwise_only_points:
    pts = np.array(pairwise_only_points)
    ax.scatter(pts[:, 0], pts[:, 1], c='red', s=12, alpha=0.7,
               label='Pairwise only (NOT Lorentzian)')
if lorentzian_points:
    pts = np.array(lorentzian_points)
    ax.scatter(pts[:, 0], pts[:, 1], c='blue', s=8, alpha=0.5, label='Lorentzian')

ax.set_xlabel('Parameter t', fontsize=11)
ax.set_ylabel('Parameter s', fontsize=11)
ax.legend(fontsize=8)
ax.set_xlim(0.5, 3)
ax.set_ylim(0.5, 3)

# ============================================================
# Panel 3: Eigenvalue distribution for nonneg counterexamples
# ============================================================
ax = axes[2]
ax.set_title('Eigenvalue Distribution:\nNonneg Matrices with Pairwise Det ≤ 0', fontsize=12, fontweight='bold')

np.random.seed(123)
all_eigs = []
colors = []
for _ in range(500):
    n = 3
    diag = np.random.exponential(1.0, n)
    A = np.zeros((n, n))
    for i in range(n):
        A[i, i] = diag[i]
    for i in range(n):
        for j in range(i+1, n):
            min_val = np.sqrt(A[i,i]*A[j,j])
            A[i,j] = min_val * np.random.uniform(1.0, 3.0)
            A[j,i] = A[i,j]

    # Check pairwise
    pw_ok = True
    for i in range(n):
        for j in range(n):
            if A[i,i]*A[j,j] > A[i,j]**2 + 1e-10:
                pw_ok = False
    if not pw_ok:
        continue

    eigs = sorted(np.linalg.eigvalsh(A))
    n_pos = sum(1 for e in eigs if e > 1e-10)
    all_eigs.append(eigs)
    colors.append('blue' if n_pos <= 1 else 'red')

if all_eigs:
    eigs_arr = np.array(all_eigs)
    for idx, c in enumerate(colors):
        ax.scatter([eigs_arr[idx, 0]], [eigs_arr[idx, 1]], c=c, s=10, alpha=0.5)

    ax.set_xlabel('Smallest eigenvalue λ₁', fontsize=11)
    ax.set_ylabel('Middle eigenvalue λ₂', fontsize=11)

    # Add legend
    from matplotlib.lines import Line2D
    legend_elements = [
        Line2D([0], [0], marker='o', color='w', markerfacecolor='blue',
               markersize=8, label='Lorentzian (≤1 pos)'),
        Line2D([0], [0], marker='o', color='w', markerfacecolor='red',
               markersize=8, label='NOT Lorentzian (2+ pos)')
    ]
    ax.legend(handles=legend_elements, fontsize=8)
    ax.axhline(y=0, color='k', linewidth=0.5, linestyle='--')
    ax.axvline(x=0, color='k', linewidth=0.5, linestyle='--')

plt.tight_layout()
plt.savefig('hessian_descent_viz.png', dpi=150, bbox_inches='tight')
print("Saved hessian_descent_viz.png")
