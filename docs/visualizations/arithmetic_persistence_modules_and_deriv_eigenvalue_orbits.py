"""
Visualization: Frobenius Eigenvalue Orbits and Persistence

Shows how Frobenius eigenvalues on the complex plane generate
persistence module data through their powers α^r.
"""

import numpy as np
import matplotlib.pyplot as plt
from matplotlib.patches import Circle

def get_eigenvalues(p, trace):
    disc = trace**2 - 4*p
    alpha = (trace + np.sqrt(complex(disc))) / 2
    beta = (trace - np.sqrt(complex(disc))) / 2
    return alpha, beta

fig, axes = plt.subplots(2, 3, figsize=(15, 10))

p = 5
traces = [0, 1, -1, 2, -2, 3]
max_r = 30

for idx, trace in enumerate(traces):
    row, col = idx // 3, idx % 3
    ax = axes[row, col]
    
    alpha, beta = get_eigenvalues(p, trace)
    
    # Plot unit circle scaled by sqrt(p)
    theta = np.linspace(0, 2*np.pi, 100)
    ax.plot(np.sqrt(p) * np.cos(theta), np.sqrt(p) * np.sin(theta),
            'k--', alpha=0.3, linewidth=1)
    
    # Plot powers of eigenvalues
    rs = np.arange(1, max_r + 1)
    alphas_r = np.array([alpha**r for r in rs])
    betas_r = np.array([beta**r for r in rs])
    
    # Color by r value
    cmap = plt.cm.viridis
    for i, r in enumerate(rs):
        color = cmap(i / len(rs))
        ax.plot(alphas_r[i].real, alphas_r[i].imag, 'o', color=color,
                markersize=max(2, 6 - i*0.15), alpha=0.7)
        ax.plot(betas_r[i].real, betas_r[i].imag, 's', color=color,
                markersize=max(2, 6 - i*0.15), alpha=0.7)
    
    # Mark initial eigenvalues
    ax.plot(alpha.real, alpha.imag, 'r*', markersize=12, zorder=5, label='α')
    ax.plot(beta.real, beta.imag, 'b*', markersize=12, zorder=5, label='β')
    
    # Power sum annotation
    s1 = round(power_sum := (alpha + beta).real)
    s2 = round((alpha**2 + beta**2).real)
    
    ax.set_title(f'trace = {trace}\ns₁={s1}, s₂={s2}', fontsize=10)
    ax.set_aspect('equal')
    ax.grid(True, alpha=0.2)
    ax.set_xlim(-p**2.5, p**2.5)
    ax.set_ylim(-p**2.5, p**2.5)
    
    if idx == 0:
        ax.legend(fontsize=8, loc='upper left')

plt.suptitle(f'Frobenius Eigenvalue Orbits α^r, β^r on the Complex Plane (p={p})',
             fontsize=14, fontweight='bold')
plt.tight_layout()
plt.savefig('eigenvalue_orbits.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved eigenvalue_orbits.png")
