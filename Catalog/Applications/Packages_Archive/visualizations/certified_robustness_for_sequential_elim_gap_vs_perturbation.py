import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np

gamma = 3.0
eps_range = np.linspace(0, 2.0, 200)
effective_gap = gamma - 2 * eps_range

fig, ax = plt.subplots(figsize=(8, 5))
ax.plot(eps_range, effective_gap, 'b-', linewidth=2, label='Effective gap γ - 2ε')
ax.axhline(y=0, color='r', linestyle='--', alpha=0.7, label='Zero (instability threshold)')
ax.axvline(x=gamma/2, color='g', linestyle=':', alpha=0.7, label=f'Critical ε = γ/2 = {gamma/2}')
ax.fill_between(eps_range, effective_gap, 0, where=effective_gap > 0, alpha=0.15, color='blue', label='Certified stable region')
ax.set_xlabel('Perturbation magnitude ε', fontsize=12)
ax.set_ylabel('Effective gap (γ - 2ε)', fontsize=12)
ax.set_title(f'Gap Certificate Degradation (γ = {gamma})', fontsize=14)
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)
plt.tight_layout()
plt.savefig('gap_vs_perturbation.png', dpi=150)
print('Saved gap_vs_perturbation.png')