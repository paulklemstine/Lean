#!/usr/bin/env python3
"""
Visualization: Correlation Capacity Surface

Shows the correlation capacity K_ii(1-K_ii) as a function of two
key parameters: inverse temperature β and matrix eigenvalue λ.
The contraction theorem ensures the actual off-diagonal correlation
always lies below this surface.
"""
import numpy as np
import matplotlib.pyplot as plt
from mpl_toolkits.mplot3d import Axes3D

# Parameter ranges
betas = np.linspace(0.01, 10, 100)
lambdas = np.linspace(0.01, 5, 100)
B, LAM = np.meshgrid(betas, lambdas)

# Eigenvalue of K as function of β and λ: κ = βλ/(1+βλ)
kappa = B * LAM / (1 + B * LAM)

# Correlation capacity: κ(1-κ) = βλ/(1+βλ)²
capacity = kappa * (1 - kappa)

fig = plt.figure(figsize=(14, 6))

# 3D surface
ax1 = fig.add_subplot(121, projection='3d')
surf = ax1.plot_surface(B, LAM, capacity, cmap='viridis', alpha=0.8,
                        edgecolor='none')
ax1.set_xlabel(r'$\beta$ (inverse temperature)', fontsize=10)
ax1.set_ylabel(r'$\lambda$ (eigenvalue of $L$)', fontsize=10)
ax1.set_zlabel(r'$\kappa(1-\kappa)$', fontsize=10)
ax1.set_title('Correlation Capacity Surface\n'
              r'$\kappa(\beta, \lambda) = \frac{\beta\lambda}{(1+\beta\lambda)^2}$',
              fontsize=12)
ax1.view_init(elev=25, azim=-60)
fig.colorbar(surf, ax=ax1, shrink=0.5, aspect=10, pad=0.1)

# Contour plot
ax2 = fig.add_subplot(122)
levels = np.linspace(0, 0.25, 26)
contour = ax2.contourf(B, LAM, capacity, levels=levels, cmap='viridis')
ax2.contour(B, LAM, capacity, levels=[0.25], colors='red', linewidths=2,
            linestyles='--')

# Mark the maximum
# Maximum of βλ/(1+βλ)² over λ for fixed β: at λ = 1/β, giving 1/4
opt_betas = np.linspace(0.5, 10, 50)
opt_lambdas = 1.0 / opt_betas
ax2.plot(opt_betas, opt_lambdas, 'r-', linewidth=2,
         label=r'Optimal: $\lambda^* = 1/\beta$ (capacity $= 1/4$)')
ax2.scatter([1.0], [1.0], c='red', s=100, zorder=5,
            label=r'$(\beta, \lambda) = (1, 1)$: capacity $= 1/4$')

ax2.set_xlabel(r'$\beta$ (inverse temperature)', fontsize=11)
ax2.set_ylabel(r'$\lambda$ (eigenvalue of $L$)', fontsize=11)
ax2.set_title('Correlation Capacity Contours', fontsize=12)
ax2.legend(fontsize=9, loc='upper right')
fig.colorbar(contour, ax=ax2, shrink=0.8)

fig.suptitle('The 1/4 Bound: Maximum Correlation Capacity in DPPs',
             fontsize=14, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('correlation_capacity.png', dpi=150, bbox_inches='tight')
plt.close()
