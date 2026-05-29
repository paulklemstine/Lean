"""
Visualization 2: Tropical Phase Transition and √(log n) Scaling

Visualizes two key phenomena from the tropical universality theory:
1. The sharp phase transition in P(tropMargin > 0) as signal strength varies
2. The √(log n) scaling of the transition width, confirming extreme-value behavior

The phase transition curve is universal across entry distributions — a direct
consequence of the Lindeberg replacement theorem proved in this work.
"""

import numpy as np
import matplotlib.pyplot as plt


def tropical_margin(W):
    n = W.shape[0]
    if n < 2:
        return 0.0
    diag = np.diag(W)
    slack = 2 * W - diag[:, None] - diag[None, :]
    np.fill_diagonal(slack, np.inf)
    return float(np.min(slack))


# Phase transition experiment
fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))
fig.suptitle('Tropical Phase Transition: Universal Threshold at √(log n) Scale',
             fontsize=14, fontweight='bold', y=1.02)

# Panel 1: Phase transition curves for different distributions
sizes = [10, 20, 50]
deltas = np.linspace(-4, 4, 25)
num_trials = 300
rng = np.random.default_rng(42)

generators = {
    'Gaussian': lambda n, rng: rng.standard_normal((n, n)),
    'Rademacher': lambda n, rng: rng.choice([-1.0, 1.0], size=(n, n)),
}
colors_dist = {'Gaussian': '#2196F3', 'Rademacher': '#F44336'}
linestyles = {10: '-', 20: '--', 50: ':'}

for n in sizes:
    for name, gen in generators.items():
        probs = []
        for delta in deltas:
            count = 0
            for _ in range(num_trials):
                mean_mat = np.zeros((n, n))
                np.fill_diagonal(mean_mat, -delta)
                W = mean_mat + gen(n, rng)
                if tropical_margin(W) > 0:
                    count += 1
            probs.append(count / num_trials)

        label = f'{name}, n={n}'
        ax1.plot(deltas, probs, label=label,
                color=colors_dist[name], linestyle=linestyles[n],
                linewidth=1.8, alpha=0.8)

ax1.axhline(y=0.5, color='gray', linestyle=':', alpha=0.5)
ax1.axvline(x=0, color='gray', linestyle=':', alpha=0.5)
ax1.set_xlabel('Signal strength δ = μ_off - μ_diag', fontsize=11)
ax1.set_ylabel('P(tropMargin > 0)', fontsize=11)
ax1.set_title('Phase Transition Curves\n(Universality: curves overlap across distributions)', fontsize=11)
ax1.legend(fontsize=8, loc='upper left')
ax1.grid(True, alpha=0.3)

# Panel 2: Scaling of margin std with log(n)
sizes_scaling = [3, 5, 8, 10, 15, 20, 30, 50]
stds_gauss = []
stds_radem = []

for n in sizes_scaling:
    margins_g = [tropical_margin(rng.standard_normal((n, n))) for _ in range(400)]
    margins_r = [tropical_margin(rng.choice([-1.0, 1.0], size=(n, n))) for _ in range(400)]
    stds_gauss.append(np.std(margins_g))
    stds_radem.append(np.std(margins_r))

sqrt_logs = [np.sqrt(np.log(n)) for n in sizes_scaling]
ax2.scatter(sqrt_logs, stds_gauss, color='#2196F3', s=60, zorder=5, label='Gaussian σ')
ax2.scatter(sqrt_logs, stds_radem, color='#F44336', s=60, zorder=5, marker='s', label='Rademacher σ')

# Fit line
coeffs = np.polyfit(sqrt_logs, [(g+r)/2 for g, r in zip(stds_gauss, stds_radem)], 1)
x_fit = np.linspace(min(sqrt_logs), max(sqrt_logs), 50)
ax2.plot(x_fit, np.polyval(coeffs, x_fit), 'k--', alpha=0.5,
         label=f'Linear fit: σ ≈ {coeffs[0]:.2f}·√(log n) + {coeffs[1]:.2f}')

ax2.set_xlabel('√(log n)', fontsize=11)
ax2.set_ylabel('Std dev of tropical margin', fontsize=11)
ax2.set_title('√(log n) Scaling\n(Extreme-value behavior)', fontsize=11)
ax2.legend(fontsize=9)
ax2.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('viz_phase_transition.png', dpi=150, bbox_inches='tight')
print("Saved viz_phase_transition.png")
