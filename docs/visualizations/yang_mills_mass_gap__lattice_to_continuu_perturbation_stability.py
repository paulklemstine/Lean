#!/usr/bin/env python3
"""
Visualization: Perturbation Stability of the Spectral Gap
==========================================================
Demonstrates Theorem 4.3: the spectral gap is robust under
small perturbations of eigenvalues. Shows how the certified
lower bound tracks the actual gap as perturbation size increases.
"""

import numpy as np
import matplotlib.pyplot as plt

np.random.seed(42)

# Original spectrum
E = np.array([0.0, 0.5, 1.2, 1.8, 2.5, 3.1])
n = len(E)
original_gap = E[1] - E[0]

# Sweep perturbation size
epsilons = np.linspace(0, 0.24, 50)
n_trials = 200

certified_bounds = []
actual_gaps_mean = []
actual_gaps_min = []
actual_gaps_max = []

for eps in epsilons:
    cert = original_gap - 2 * eps
    certified_bounds.append(cert)
    
    trial_gaps = []
    for _ in range(n_trials):
        perturbation = np.random.uniform(-eps, eps, n)
        E_pert = E + perturbation
        E_pert_sorted = np.sort(E_pert)
        trial_gaps.append(E_pert_sorted[1] - E_pert_sorted[0])
    
    actual_gaps_mean.append(np.mean(trial_gaps))
    actual_gaps_min.append(np.min(trial_gaps))
    actual_gaps_max.append(np.max(trial_gaps))

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

# Left: Gap bounds
ax1.fill_between(epsilons, actual_gaps_min, actual_gaps_max, 
                 alpha=0.3, color='#2196F3', label='Actual gap range')
ax1.plot(epsilons, actual_gaps_mean, color='#2196F3', linewidth=2, 
         label='Mean actual gap')
ax1.plot(epsilons, certified_bounds, color='#F44336', linewidth=2.5, 
         linestyle='--', label='Certified bound (Δ-2ε)')
ax1.axhline(y=0, color='gray', linestyle='-', alpha=0.3)
ax1.set_xlabel("Perturbation ε", fontsize=14)
ax1.set_ylabel("Spectral Gap", fontsize=14)
ax1.set_title("Perturbation Stability (Theorem 4.3)", fontsize=16)
ax1.legend(fontsize=11)
ax1.grid(True, alpha=0.3)

# Right: Spectrum visualization
eps_demo = 0.1
ax2.barh(range(n), E, height=0.4, color='#2196F3', alpha=0.7, label='Original')
for trial in range(20):
    pert = np.random.uniform(-eps_demo, eps_demo, n)
    E_pert = E + pert
    ax2.scatter(E_pert, np.arange(n) + np.random.uniform(-0.15, 0.15, n),
               color='#F44336', alpha=0.3, s=15)

# Add gap annotation
ax2.annotate('', xy=(E[0], -0.3), xytext=(E[1], -0.3),
            arrowprops=dict(arrowstyle='<->', color='green', lw=2))
ax2.text((E[0]+E[1])/2, -0.6, f'Gap = {original_gap}', ha='center', 
         fontsize=12, color='green')

ax2.set_xlabel("Energy", fontsize=14)
ax2.set_ylabel("Eigenvalue Index", fontsize=14)
ax2.set_title(f"Spectrum with ε={eps_demo} Perturbation", fontsize=16)
ax2.set_yticks(range(n))
ax2.legend(['Original spectrum', 'Perturbed samples'], fontsize=11)
ax2.grid(True, alpha=0.3, axis='x')

plt.tight_layout()
plt.savefig("perturbation_stability.png", dpi=150, bbox_inches='tight')
print("Saved: perturbation_stability.png")
