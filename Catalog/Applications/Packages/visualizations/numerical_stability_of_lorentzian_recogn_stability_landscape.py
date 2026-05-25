"""
Visualization: Stability Landscape of Lorentzian Recognition

Visualizes how the spectral gap degrades under perturbation, showing
the certified stability region vs empirical destruction threshold.
This is the core visual that makes the perturbation theorem tangible.
"""

import numpy as np
import matplotlib.pyplot as plt
from algorithms import (compute_spectral_gap, elementary_symmetric_polynomial_hessian)

def generate_data():
    results = {}
    for n in [4, 5, 6]:
        H = elementary_symmetric_polynomial_hessian(n, 2)
        gap, _, _ = compute_spectral_gap(H)
        
        noise_fracs = np.linspace(0, 2.5, 50)
        preservation_rates = []
        residual_gaps = []
        
        for frac in noise_fracs:
            delta = gap * frac
            preserved = 0
            gaps_collected = []
            n_trials = 300
            
            for _ in range(n_trials):
                E = np.random.randn(n, n)
                E = (E + E.T) / 2
                spec_rad = np.max(np.abs(np.linalg.eigvalsh(E)))
                if spec_rad > 0:
                    E = E * (delta / spec_rad)
                
                g, sig, _ = compute_spectral_gap(H + E)
                if sig:
                    preserved += 1
                gaps_collected.append(g if sig else 0)
            
            preservation_rates.append(preserved / n_trials)
            residual_gaps.append(np.mean(gaps_collected))
        
        results[n] = {
            'noise_fracs': noise_fracs,
            'preservation_rates': preservation_rates,
            'residual_gaps': residual_gaps,
            'gap': gap
        }
    
    return results

results = generate_data()

fig, axes = plt.subplots(1, 2, figsize=(14, 6))

# Left panel: Preservation rates
ax1 = axes[0]
colors = ['#2196F3', '#FF5722', '#4CAF50']
for (n, data), color in zip(results.items(), colors):
    ax1.plot(data['noise_fracs'], data['preservation_rates'], 
             color=color, linewidth=2, label=f'n={n}, e₂')

ax1.axvline(x=1.0, color='red', linestyle='--', linewidth=2, alpha=0.7, label='Certified bound (δ=ε)')
ax1.axvspan(0, 1.0, alpha=0.1, color='green', label='Certified safe zone')
ax1.set_xlabel('Perturbation ratio δ/ε', fontsize=13)
ax1.set_ylabel('Fraction with Lorentzian signature', fontsize=13)
ax1.set_title('Signature Preservation Under Perturbation', fontsize=14)
ax1.legend(fontsize=10)
ax1.set_ylim(-0.05, 1.05)
ax1.grid(True, alpha=0.3)

# Right panel: Residual gap
ax2 = axes[1]
for (n, data), color in zip(results.items(), colors):
    theoretical_gap = [max(data['gap'] * (1 - f), 0) for f in data['noise_fracs']]
    ax2.plot(data['noise_fracs'], [g/data['gap'] for g in data['residual_gaps']], 
             color=color, linewidth=2, label=f'n={n} (empirical)')
    ax2.plot(data['noise_fracs'], [t/data['gap'] for t in theoretical_gap],
             color=color, linewidth=1, linestyle='--', alpha=0.5)

ax2.axvline(x=1.0, color='red', linestyle='--', linewidth=2, alpha=0.7)
ax2.set_xlabel('Perturbation ratio δ/ε', fontsize=13)
ax2.set_ylabel('Residual gap / original gap', fontsize=13)
ax2.set_title('Spectral Gap Degradation (dashed = theoretical)', fontsize=14)
ax2.legend(fontsize=10)
ax2.set_ylim(-0.1, 1.1)
ax2.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('stability_landscape.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved stability_landscape.png")
