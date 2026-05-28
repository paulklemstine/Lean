#!/usr/bin/env python3
"""
Visualization: Spectral Obstruction for Lorentzian Quadratic Forms

Shows the eigenvalue landscape for 2x2 symmetric matrices and
classifies them as Lorentzian or non-Lorentzian based on eigenvalue sign.

This visualizes:
- positive_definite_not_lorentzian (2 positive eigenvalues → not Lorentzian)
- neg_semidefinite_is_lorentzian (0 positive eigenvalues → Lorentzian)
- The transition at exactly 1 positive eigenvalue (Lorentzian boundary)
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from matplotlib.patches import FancyArrowPatch


fig, axes = plt.subplots(1, 2, figsize=(14, 6))

# Panel 1: Classification of 2x2 symmetric matrices by eigenvalue signature
ax1 = axes[0]

# For A = [[a, b], [b, c]], eigenvalues are ((a+c) ± sqrt((a-c)² + 4b²)) / 2
# Number of positive eigenvalues depends on trace and determinant:
# trace = a + c, det = ac - b²
# 2 positive: trace > 0 and det > 0
# 1 positive: det < 0
# 0 positive: trace < 0 and det > 0

trace_range = np.linspace(-4, 4, 300)
det_range = np.linspace(-4, 4, 300)
T, D = np.meshgrid(trace_range, det_range)

# Classify regions
# Number of positive eigenvalues:
# eigenvalues = (T ± sqrt(T² - 4D)) / 2
# Both positive: T > 0, D > 0
# One positive, one negative: D < 0
# Both negative: T < 0, D > 0
# Complex (D > T²/4): never for real symmetric

region = np.zeros_like(T)  # 0: impossible (above discriminant)
mask_real = D <= T**2 / 4

# 2 positive eigenvalues (positive definite)
mask_2pos = mask_real & (T > 0) & (D > 0)
# 1 positive, 1 negative
mask_1pos = mask_real & (D < 0)
# 0 positive eigenvalues (negative semidefinite or definite)
mask_0pos = mask_real & (T < 0) & (D > 0)
# 1 positive, 1 zero (boundary)
mask_1pos0 = mask_real & (D == 0) & (T > 0)
# Both zero
mask_0 = (T == 0) & (D == 0)

# Assign colors
colors = np.ones((*T.shape, 4))  # RGBA, default white
colors[mask_2pos] = [1.0, 0.3, 0.3, 0.8]    # Red: not Lorentzian
colors[mask_1pos] = [0.3, 0.8, 0.3, 0.8]    # Green: Lorentzian (1 pos)
colors[mask_0pos] = [0.3, 0.5, 1.0, 0.8]    # Blue: Lorentzian (0 pos)
colors[~mask_real] = [0.95, 0.95, 0.95, 0.3]  # Light grey: impossible

ax1.imshow(colors, extent=[-4, 4, -4, 4], origin='lower', aspect='auto')

# Draw boundaries
t_line = np.linspace(-4, 4, 500)
# D = 0 line (one eigenvalue is zero)
ax1.axhline(y=0, color='black', linewidth=1.5, alpha=0.5)
# T = 0 line
ax1.axvline(x=0, color='black', linewidth=1.5, alpha=0.5)
# Discriminant curve D = T²/4
ax1.plot(t_line, t_line**2/4, 'k-', linewidth=2, label='Discriminant = 0')

# Labels
ax1.text(2, 2, 'NOT\nLorentzian\n(2 pos. eig.)', ha='center', fontsize=10,
         fontweight='bold', color='darkred')
ax1.text(2, -2, 'Lorentzian\n(1 pos. eig.)', ha='center', fontsize=10,
         fontweight='bold', color='darkgreen')
ax1.text(-2, -2, 'Lorentzian\n(1 pos. eig.)', ha='center', fontsize=10,
         fontweight='bold', color='darkgreen')
ax1.text(-2, 2, 'Lorentzian\n(0 pos. eig.)', ha='center', fontsize=10,
         fontweight='bold', color='darkblue')

# Example points
examples = [
    (2, 1, 'I₂', 'ko'),    # Identity: not Lorentzian
    (0, -1, 'M₂', 'g^'),   # Minkowski: Lorentzian
    (-2, 1, '-I₂', 'bs'),   # Negative identity: Lorentzian
    (0, 0, '0', 'kD'),      # Zero: Lorentzian
]
for tr, det, name, marker in examples:
    ax1.plot(tr, det, marker, markersize=10, markeredgecolor='black', markeredgewidth=1.5)
    ax1.annotate(name, (tr, det), textcoords="offset points",
                 xytext=(10, 10), fontsize=11, fontweight='bold')

ax1.set_xlabel('trace(A) = λ₁ + λ₂', fontsize=12)
ax1.set_ylabel('det(A) = λ₁ · λ₂', fontsize=12)
ax1.set_title('Lorentzian Classification\nof 2×2 Symmetric Matrices', fontsize=13)
ax1.set_xlim(-4, 4)
ax1.set_ylim(-4, 4)

# Panel 2: Eigenvalue cones
ax2 = axes[1]

# Draw the Lorentzian cone in eigenvalue space
lam1 = np.linspace(-3, 3, 300)
lam2 = np.linspace(-3, 3, 300)
L1, L2 = np.meshgrid(lam1, lam2)

# Count positive eigenvalues
n_pos = (L1 > 0).astype(int) + (L2 > 0).astype(int)

# Color by Lorentzian status
colors2 = np.ones((*L1.shape, 4))
colors2[n_pos == 0] = [0.3, 0.5, 1.0, 0.6]    # Blue: neg semidefinite
colors2[n_pos == 1] = [0.3, 0.8, 0.3, 0.6]    # Green: Lorentzian
colors2[n_pos == 2] = [1.0, 0.3, 0.3, 0.6]    # Red: not Lorentzian

ax2.imshow(colors2, extent=[-3, 3, -3, 3], origin='lower', aspect='auto')
ax2.axhline(y=0, color='black', linewidth=1.5)
ax2.axvline(x=0, color='black', linewidth=1.5)

# Annotations
ax2.text(1.5, 1.5, 'NOT\nLorentzian', ha='center', fontsize=11,
         fontweight='bold', color='darkred')
ax2.text(-1.5, -1.5, 'Neg. semidef.\n(Lorentzian)', ha='center', fontsize=11,
         fontweight='bold', color='darkblue')
ax2.text(1.5, -1.5, 'Exactly 1 pos.\n(Lorentzian)', ha='center', fontsize=11,
         fontweight='bold', color='darkgreen')
ax2.text(-1.5, 1.5, 'Exactly 1 pos.\n(Lorentzian)', ha='center', fontsize=11,
         fontweight='bold', color='darkgreen')

# Key point examples
ax2.plot(1, 1, 'ko', markersize=10, markeredgewidth=2)
ax2.annotate('I₂ (1,1)', (1, 1), xytext=(15, 10),
             textcoords="offset points", fontsize=10, fontweight='bold')
ax2.plot(1, -1, 'g^', markersize=10, markeredgewidth=2)
ax2.annotate('Mink (1,-1)', (1, -1), xytext=(15, -15),
             textcoords="offset points", fontsize=10, fontweight='bold')

ax2.set_xlabel('Eigenvalue λ₁', fontsize=12)
ax2.set_ylabel('Eigenvalue λ₂', fontsize=12)
ax2.set_title('Lorentzian Condition\nin Eigenvalue Space', fontsize=13)

plt.tight_layout()
plt.savefig('viz_spectral_obstruction.png', dpi=150, bbox_inches='tight')
print("Saved viz_spectral_obstruction.png")
