"""
Visualization: Eigenvalue Perturbation and Signature Control

Shows how eigenvalues of a Lorentzian Hessian move under perturbation,
illustrating the spectral gap as a "buffer zone" that prevents the
second eigenvalue from crossing zero.
"""

import numpy as np
import matplotlib.pyplot as plt
from algorithms import elementary_symmetric_polynomial_hessian

n = 5
H = elementary_symmetric_polynomial_hessian(n, 2)
eigenvalues_orig = np.sort(np.linalg.eigvalsh(H))[::-1]
gap = -eigenvalues_orig[1]

fig, axes = plt.subplots(1, 3, figsize=(16, 5))

# Panel 1: Eigenvalue trajectories under increasing perturbation
ax1 = axes[0]
n_steps = 100
delta_range = np.linspace(0, 2.5 * gap, n_steps)
n_trails = 20

for trail in range(n_trails):
    np.random.seed(trail * 42)
    E = np.random.randn(n, n)
    E = (E + E.T) / 2
    E = E / np.max(np.abs(np.linalg.eigvalsh(E)))  # normalize
    
    ev_trajectories = np.zeros((n_steps, n))
    for i, delta in enumerate(delta_range):
        H_pert = H + delta * E
        ev_trajectories[i] = np.sort(np.linalg.eigvalsh(H_pert))[::-1]
    
    for k in range(n):
        color = '#E53935' if k == 0 else '#1565C0' if k == 1 else '#90A4AE'
        alpha = 0.3 if trail > 0 else 0.8
        lw = 1.5 if trail == 0 else 0.5
        ax1.plot(delta_range / gap, ev_trajectories[:, k], 
                color=color, alpha=alpha, linewidth=lw)

ax1.axhline(y=0, color='black', linewidth=1.5, linestyle='-')
ax1.axvline(x=1.0, color='red', linewidth=2, linestyle='--', alpha=0.7)
ax1.fill_between([0, 1.0], [-3*gap, -3*gap], [eigenvalues_orig[0]*1.5]*2, 
                 alpha=0.08, color='green')
ax1.set_xlabel('Perturbation δ/ε', fontsize=12)
ax1.set_ylabel('Eigenvalue', fontsize=12)
ax1.set_title('Eigenvalue Trajectories\n(red=λ₁, blue=λ₂, gray=others)', fontsize=12)
ax1.set_ylim(-3*gap, eigenvalues_orig[0]*1.5)
ax1.grid(True, alpha=0.3)

# Panel 2: Distribution of second eigenvalue at δ = 0.5ε vs δ = 1.5ε
ax2 = axes[1]
n_samples = 1000
second_evs_safe = []
second_evs_danger = []

for _ in range(n_samples):
    E = np.random.randn(n, n)
    E = (E + E.T) / 2
    E = E / np.max(np.abs(np.linalg.eigvalsh(E)))
    
    H_safe = H + 0.5 * gap * E
    H_danger = H + 1.5 * gap * E
    
    evs_safe = np.sort(np.linalg.eigvalsh(H_safe))[::-1]
    evs_danger = np.sort(np.linalg.eigvalsh(H_danger))[::-1]
    
    second_evs_safe.append(evs_safe[1])
    second_evs_danger.append(evs_danger[1])

ax2.hist(second_evs_safe, bins=40, alpha=0.6, color='#4CAF50', label='δ = 0.5ε (safe)', density=True)
ax2.hist(second_evs_danger, bins=40, alpha=0.6, color='#F44336', label='δ = 1.5ε (risky)', density=True)
ax2.axvline(x=0, color='black', linewidth=2, linestyle='-', label='Zero threshold')
ax2.set_xlabel('Second eigenvalue λ₂', fontsize=12)
ax2.set_ylabel('Density', fontsize=12)
ax2.set_title('Distribution of λ₂ Under Perturbation', fontsize=12)
ax2.legend(fontsize=10)
ax2.grid(True, alpha=0.3)

# Panel 3: Condition number vs dimension
ax3 = axes[2]
n_values = range(3, 12)
condition_numbers = []
gaps = []
for nv in n_values:
    H_temp = elementary_symmetric_polynomial_hessian(nv, 2)
    evs = np.sort(np.linalg.eigvalsh(H_temp))[::-1]
    g = -evs[1]
    max_ev = evs[0]
    condition_numbers.append(max_ev / g if g > 0 else float('inf'))
    gaps.append(g)

ax3.bar(list(n_values), condition_numbers, color='#7E57C2', alpha=0.7, edgecolor='#4A148C')
ax3.set_xlabel('Dimension n', fontsize=12)
ax3.set_ylabel('Condition number κ_L', fontsize=12)
ax3.set_title('Lorentzian Condition Number\nfor e₂(x₁,...,xₙ)', fontsize=12)
ax3.grid(True, alpha=0.3, axis='y')

plt.tight_layout()
plt.savefig('eigenvalue_perturbation.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved eigenvalue_perturbation.png")
