#!/usr/bin/env python3
"""
Visualization: Hessian Descent Landscape

Visualizes the boundary between Lorentzian and non-Lorentzian regions
in the space of 2×2 symmetric matrices parameterized by (a, b, c).
Shows that the Lorentzian region is exactly {ac ≤ b²} — the region
below the determinant surface.

This demonstrates Theorem B: the full 2×2 equivalence between
Lorentzian signature and the coefficient inequality ac ≤ b².
"""

import numpy as np
import matplotlib.pyplot as plt
from matplotlib import cm
from mpl_toolkits.mplot3d import Axes3D

fig = plt.figure(figsize=(16, 6))

# --- Panel 1: The determinant surface b² = ac ---
ax1 = fig.add_subplot(131, projection='3d')

a_vals = np.linspace(0.1, 3, 50)
c_vals = np.linspace(0.1, 3, 50)
A, C = np.meshgrid(a_vals, c_vals)
B_boundary = np.sqrt(A * C)  # b² = ac boundary

ax1.plot_surface(A, B_boundary, C, alpha=0.5, cmap='coolwarm',
                  edgecolor='none')
ax1.set_xlabel('a (diagonal)')
ax1.set_ylabel('b (off-diagonal)')
ax1.set_zlabel('c (diagonal)')
ax1.set_title('Lorentzian Boundary\nb² = ac')

# Add sample Lorentzian points (below surface)
np.random.seed(42)
for _ in range(30):
    a = np.random.uniform(0.2, 2.5)
    c = np.random.uniform(0.2, 2.5)
    b = np.random.uniform(np.sqrt(a * c), np.sqrt(a * c) + 1)
    ax1.scatter(a, b, c, c='green', s=10, alpha=0.7)

# Non-Lorentzian points (above surface)
for _ in range(30):
    a = np.random.uniform(0.2, 2.5)
    c = np.random.uniform(0.2, 2.5)
    b = np.random.uniform(0, np.sqrt(a * c) * 0.8)
    ax1.scatter(a, b, c, c='red', s=10, alpha=0.7)

# --- Panel 2: 2D slice at c = 1 ---
ax2 = fig.add_subplot(132)

a_range = np.linspace(0.01, 4, 200)
b_boundary = np.sqrt(a_range)

ax2.fill_between(a_range, b_boundary, 5, alpha=0.3, color='green',
                  label='Lorentzian (b² ≥ ac)')
ax2.fill_between(a_range, 0, b_boundary, alpha=0.3, color='red',
                  label='Not Lorentzian (b² < ac)')
ax2.plot(a_range, b_boundary, 'k-', linewidth=2, label='b² = ac boundary')

ax2.set_xlabel('a (diagonal entry)', fontsize=12)
ax2.set_ylabel('b (off-diagonal entry)', fontsize=12)
ax2.set_title('2×2 Lorentzian Region (c = 1)', fontsize=13)
ax2.legend(fontsize=10)
ax2.set_xlim(0, 4)
ax2.set_ylim(0, 4)

# --- Panel 3: Eigenvalue spectrum transition ---
ax3 = fig.add_subplot(133)

b_values = np.linspace(0, 3, 200)
a_fixed, c_fixed = 1.0, 1.0

eig1_list = []
eig2_list = []
for b in b_values:
    M = np.array([[a_fixed, b], [b, c_fixed]])
    eigs = np.sort(np.linalg.eigvalsh(M))
    eig1_list.append(eigs[0])
    eig2_list.append(eigs[1])

ax3.plot(b_values, eig1_list, 'b-', linewidth=2, label='λ₁ (smaller)')
ax3.plot(b_values, eig2_list, 'r-', linewidth=2, label='λ₂ (larger)')
ax3.axhline(y=0, color='k', linestyle='--', alpha=0.5)
ax3.axvline(x=1.0, color='gray', linestyle=':', alpha=0.7,
             label='b = √(ac) = 1')

ax3.fill_betweenx([-2, 4], 1.0, 3.0, alpha=0.15, color='green')
ax3.fill_betweenx([-2, 4], 0.0, 1.0, alpha=0.15, color='red')

ax3.annotate('Lorentzian\n(1 pos eig)', xy=(2, 0.5), fontsize=11,
              ha='center', color='green', fontweight='bold')
ax3.annotate('Not Lorentzian\n(2 pos eigs)', xy=(0.5, 0.5), fontsize=11,
              ha='center', color='red', fontweight='bold')

ax3.set_xlabel('b (off-diagonal)', fontsize=12)
ax3.set_ylabel('Eigenvalue', fontsize=12)
ax3.set_title('Eigenvalue Transition\n(a = c = 1)', fontsize=13)
ax3.legend(fontsize=10)
ax3.set_xlim(0, 3)
ax3.set_ylim(-2, 4)

plt.tight_layout()
plt.savefig('viz_hessian_landscape.png', dpi=150, bbox_inches='tight')
print("Saved viz_hessian_landscape.png")
