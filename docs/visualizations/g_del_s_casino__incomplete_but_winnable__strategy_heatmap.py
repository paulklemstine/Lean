#!/usr/bin/env python3
"""
Visualization 2: Strategy Performance Heatmap

Shows a heatmap of strategy performance across different combinations
of decidable fraction and adversarial intensity. Illustrates how the
selective strategy's advantage grows under adversarial conditions.
"""

import numpy as np
import matplotlib.pyplot as plt

np.random.seed(42)

n_rounds = 100
n_trials = 200
dec_fracs = np.linspace(0.05, 0.95, 19)
adv_levels = np.linspace(0, 1, 21)  # 0 = random truth, 1 = all undecidable are false

advantage_matrix = np.zeros((len(adv_levels), len(dec_fracs)))
sel_matrix = np.zeros((len(adv_levels), len(dec_fracs)))

for i, adv in enumerate(adv_levels):
    for j, d in enumerate(dec_fracs):
        sel_total = 0
        naive_total = 0
        for _ in range(n_trials):
            is_dec = np.random.random(n_rounds) < d
            truth = np.random.choice([True, False], n_rounds)
            # Adversarial: undecidable statements biased toward FALSE
            for k in range(n_rounds):
                if not is_dec[k] and np.random.random() < adv:
                    truth[k] = False

            # Selective profit = number of decidable rounds
            sel_profit = int(np.sum(is_dec))

            # Naive profit = sum of (2*truth - 1)
            naive_profit = int(np.sum(truth * 2 - 1))

            sel_total += sel_profit
            naive_total += naive_profit

        advantage_matrix[i, j] = (sel_total - naive_total) / n_trials
        sel_matrix[i, j] = sel_total / n_trials

fig, axes = plt.subplots(1, 2, figsize=(15, 6))

# Left: Advantage heatmap
im1 = axes[0].imshow(advantage_matrix, aspect='auto', origin='lower',
                       cmap='RdYlGn', extent=[dec_fracs[0], dec_fracs[-1],
                                               adv_levels[0], adv_levels[-1]])
axes[0].set_xlabel('Decidable Fraction', fontsize=12)
axes[0].set_ylabel('Adversarial Intensity', fontsize=12)
axes[0].set_title('Selective Advantage over Naive Strategy', fontsize=13)
plt.colorbar(im1, ax=axes[0], label='Profit Advantage')

# Add contour lines
X, Y = np.meshgrid(dec_fracs, adv_levels)
cs = axes[0].contour(X, Y, advantage_matrix, levels=[0, 10, 20, 30, 40, 50],
                      colors='black', linewidths=0.5, alpha=0.5)
axes[0].clabel(cs, inline=True, fontsize=8)

# Right: Selective profit heatmap
im2 = axes[1].imshow(sel_matrix, aspect='auto', origin='lower',
                       cmap='Blues', extent=[dec_fracs[0], dec_fracs[-1],
                                             adv_levels[0], adv_levels[-1]])
axes[1].set_xlabel('Decidable Fraction', fontsize=12)
axes[1].set_ylabel('Adversarial Intensity', fontsize=12)
axes[1].set_title('Selective Strategy Profit (immune to adversary)', fontsize=13)
plt.colorbar(im2, ax=axes[1], label='Selective Profit')

# Note: selective profit doesn't depend on adversarial intensity
axes[1].annotate('Selective profit depends\nonly on decidable fraction\n(horizontal bands)',
                  xy=(0.5, 0.5), fontsize=10, ha='center', color='white',
                  fontweight='bold', bbox=dict(boxstyle='round', facecolor='navy', alpha=0.7))

plt.tight_layout()
plt.savefig('viz_strategy_heatmap.png', dpi=150, bbox_inches='tight')
print("Saved viz_strategy_heatmap.png")
