#!/usr/bin/env python3
"""
Visualization 3: Critical Exponents and Universality Classes

Illustrates the fundamental identity α = log(λ)/log(μ) that links
pressure scaling eigenvalues to critical exponents. Shows how
different (λ, μ) pairs can yield the same critical exponent,
defining universality classes in the RG framework.
"""

import numpy as np
import matplotlib.pyplot as plt
from matplotlib.patches import FancyArrowPatch

fig, axes = plt.subplots(1, 3, figsize=(17, 5.5))

# ── Panel 1: Critical exponent surface ──
ax1 = axes[0]
lambdas = np.linspace(0.1, 10, 200)
mus = np.linspace(1.01, 5, 200)
L, M = np.meshgrid(lambdas, mus)
A = np.log(L) / np.log(M)

# Contour plot
levels = np.arange(-2, 5.1, 0.5)
cf = ax1.contourf(L, M, A, levels=levels, cmap='RdYlBu_r', alpha=0.8)
plt.colorbar(cf, ax=ax1, label=r'Critical exponent $\alpha$')
cs = ax1.contour(L, M, A, levels=[0.5, 1.0, 1.5, 2.0, 3.0],
                 colors='black', linewidths=1, alpha=0.5)
ax1.clabel(cs, inline=True, fontsize=9)

# Mark specific universality classes
points = [(4, 2, 2.0), (8, 2, 3.0), (9, 3, 2.0), (2, 2, 1.0)]
for lam, mu, alpha in points:
    ax1.plot(lam, mu, 'ko', markersize=8, zorder=5)
    ax1.annotate(f'α={alpha:.0f}', (lam, mu), textcoords="offset points",
                xytext=(8, 5), fontsize=9, fontweight='bold')

ax1.set_xlabel(r'Pressure scale $\lambda$', fontsize=12)
ax1.set_ylabel(r'Parameter scale $\mu$', fontsize=12)
ax1.set_title(r'$\alpha = \log\lambda / \log\mu$', fontsize=14)

# ── Panel 2: Power-law scaling ──
ax2 = axes[1]
t_values = np.linspace(0.01, 3, 200)

alphas = [0.5, 1.0, 1.5, 2.0, 3.0]
colors = plt.cm.plasma(np.linspace(0.1, 0.9, len(alphas)))

for alpha, color in zip(alphas, colors):
    P = t_values ** alpha
    ax2.plot(t_values, P, color=color, linewidth=2,
             label=f'α = {alpha}')

ax2.set_xlabel(r'Parameter $t$', fontsize=12)
ax2.set_ylabel(r'Pressure $\Pi(t) = t^\alpha$', fontsize=12)
ax2.set_title('Power-Law Profiles by Exponent', fontsize=14)
ax2.legend(fontsize=10)
ax2.grid(True, alpha=0.3)
ax2.set_ylim(0, 10)

# ── Panel 3: Universality class diagram ──
ax3 = axes[2]

# Draw circles for different universality classes
class_data = [
    (0.3, 0.7, 0.25, 'α = 1\n(Linear)', '#2196F3', [
        '(λ=2, μ=2)', '(λ=3, μ=3)', '(λ=5, μ=5)'
    ]),
    (0.7, 0.7, 0.22, 'α = 2\n(Quadratic)', '#FF5722', [
        '(λ=4, μ=2)', '(λ=9, μ=3)', '(λ=25, μ=5)'
    ]),
    (0.5, 0.25, 0.2, 'α = 3\n(Cubic)', '#4CAF50', [
        '(λ=8, μ=2)', '(λ=27, μ=3)'
    ]),
]

for cx, cy, r, label, color, members in class_data:
    circle = plt.Circle((cx, cy), r, fill=True, alpha=0.15, color=color)
    ax3.add_patch(circle)
    circle2 = plt.Circle((cx, cy), r, fill=False, color=color, linewidth=2)
    ax3.add_patch(circle2)
    ax3.text(cx, cy + r + 0.04, label, ha='center', va='bottom',
             fontsize=10, fontweight='bold', color=color)
    for i, member in enumerate(members):
        y = cy - 0.06 * (i - (len(members)-1)/2)
        ax3.text(cx, y, member, ha='center', va='center',
                 fontsize=8, color='black')

ax3.set_xlim(0, 1)
ax3.set_ylim(0, 1)
ax3.set_aspect('equal')
ax3.set_title('Universality Classes', fontsize=14)
ax3.text(0.5, 0.02, 'Ensembles with same α are in the same class',
         ha='center', fontsize=9, style='italic', color='gray')
ax3.axis('off')

plt.suptitle('Critical Exponents and Universality in Subgroup RG',
             fontsize=15, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('viz_critical_exponents.png', dpi=150, bbox_inches='tight')
print("Saved viz_critical_exponents.png")
