import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np

fig, axes = plt.subplots(1, 3, figsize=(16, 5))

# Panel 1: Phase transition
ax = axes[0]
p = 0.1
stages = np.arange(0, 30)
for log_B, color in [(5, '#2196F3'), (10, '#4CAF50'), (15, '#FF9800'), (22, '#F44336')]:
    B = 10.0 ** log_B
    E = B * p ** stages
    n_star = int(np.ceil(log_B / np.log10(1/p)))
    ax.semilogy(stages, E, color=color, linewidth=2, label=f'B = 10^{log_B}')
    ax.axvline(n_star, color=color, linestyle=':', alpha=0.5)
ax.axhline(1.0, color='black', linestyle='--', linewidth=1, alpha=0.7, label='Silence threshold')
ax.set_xlabel('Number of filter stages (n)')
ax.set_ylabel('Expected survivors E[N]')
ax.set_title('Phase Transition to Silence (p = 0.1)')
ax.legend(fontsize=9)
ax.set_ylim(1e-10, 1e25)
ax.grid(True, alpha=0.3)

# Panel 2: Sensitivity
ax = axes[1]
probs = [0.5, 0.8, 0.001, 0.3, 0.9, 0.7, 0.6]
labels = ['f_p', 'n_e', 'f_l', 'f_i', 'f_c', 'R*', 'L']
cofactors = []
for i in range(len(probs)):
    c = 1.0
    for j, p_val in enumerate(probs):
        if j != i:
            c *= p_val
    cofactors.append(c)
colors = ['#2196F3'] * len(probs)
bottleneck = int(np.argmax(cofactors))
colors[bottleneck] = '#F44336'
ax.barh(range(len(probs)), cofactors, color=colors)
ax.set_yticks(range(len(probs)))
ax.set_yticklabels([f'{labels[i]} (p={probs[i]})' for i in range(len(probs))])
ax.set_xlabel('Cofactor (sensitivity)')
ax.set_title('Sensitivity Dominance (red = bottleneck)')
ax.set_xscale('log')
ax.grid(True, alpha=0.3, axis='x')

# Panel 3: Monte Carlo
ax = axes[2]
np.random.seed(42)
n_samples = 100000
n_factors = 7
log_products = np.zeros(n_samples)
for _ in range(n_factors):
    log_products += np.random.uniform(-6, 0, n_samples)
log_N = np.log10(1.5e10) + log_products
ax.hist(log_N, bins=100, density=True, color='#673AB7', alpha=0.7)
ax.axvline(0, color='#F44336', linewidth=2, linestyle='--', label='N = 1')
ax.set_xlabel('log10(N)')
ax.set_ylabel('Density')
fraction_above = np.mean(log_N > 0)
ax.set_title(f'Drake N Distribution (P(N>1) = {fraction_above:.4f})')
ax.legend()
ax.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('cascade_filter_visualization.png', dpi=150)
print('Saved: cascade_filter_visualization.png')