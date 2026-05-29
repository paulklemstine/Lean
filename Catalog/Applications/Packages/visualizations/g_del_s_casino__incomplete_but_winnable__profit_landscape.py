#!/usr/bin/env python3
"""
Visualization 1: Profit Landscape of Gödel's Casino

Visualizes how the selective strategy's profit varies with the decidable
fraction, compared to naive and random strategies. Shows the profit ceiling
(tropical optimal) and the incompleteness gap.
"""

import numpy as np
import matplotlib.pyplot as plt

# Parameters
n_rounds = 100
n_trials = 500
fractions = np.linspace(0, 1, 21)

# Simulate
sel_profits = []
naive_profits_mean = []
naive_profits_std = []
random_profits_mean = []

np.random.seed(42)

for d in fractions:
    sel_trial = []
    naive_trial = []
    rand_trial = []
    for _ in range(n_trials):
        is_dec = np.random.random(n_rounds) < d
        truth = np.random.choice([True, False], n_rounds)

        # Selective: +1 on decidable, 0 on undecidable
        sel_profit = int(np.sum(is_dec))
        sel_trial.append(sel_profit)

        # Naive (bet TRUE): +1 if true, -1 if false
        naive_profit = int(np.sum(truth * 2 - 1))
        naive_trial.append(naive_profit)

        # Random: expected 0
        rand_bets = np.random.choice([True, False], n_rounds)
        rand_profit = int(np.sum((rand_bets == truth) * 2 - 1))
        rand_trial.append(rand_profit)

    sel_profits.append(np.mean(sel_trial))
    naive_profits_mean.append(np.mean(naive_trial))
    naive_profits_std.append(np.std(naive_trial))
    random_profits_mean.append(np.mean(rand_trial))

# Plot
fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

# Left: Profit vs decidable fraction
ax1.fill_between(fractions, n_rounds, sel_profits,
                  alpha=0.3, color='red', label='Incompleteness Gap')
ax1.plot(fractions, [n_rounds]*len(fractions), 'k--', linewidth=2,
         label='Tropical Optimal (ceiling)')
ax1.plot(fractions, sel_profits, 'b-o', linewidth=2, markersize=4,
         label='Selective Strategy')
ax1.fill_between(fractions,
                  np.array(naive_profits_mean) - np.array(naive_profits_std),
                  np.array(naive_profits_mean) + np.array(naive_profits_std),
                  alpha=0.2, color='orange')
ax1.plot(fractions, naive_profits_mean, 'r-s', linewidth=1.5, markersize=3,
         label='Naive Strategy (±1σ)')
ax1.plot(fractions, random_profits_mean, 'g-^', linewidth=1.5, markersize=3,
         label='Random Strategy')
ax1.axhline(y=0, color='gray', linestyle=':', alpha=0.5)

ax1.set_xlabel('Decidable Fraction', fontsize=12)
ax1.set_ylabel('Expected Profit', fontsize=12)
ax1.set_title("Gödel's Casino: Profit vs Decidability", fontsize=14)
ax1.legend(loc='upper left', fontsize=9)
ax1.set_xlim(0, 1)
ax1.set_ylim(-30, 110)

# Right: Incompleteness gap
gap = n_rounds - np.array(sel_profits)
ax2.bar(fractions, gap, width=0.04, color='indianred', alpha=0.8,
        edgecolor='darkred', label='Incompleteness Gap')
ax2.plot(fractions, n_rounds * (1 - fractions), 'k--', linewidth=2,
         label='Theoretical: n(1-d)')
ax2.set_xlabel('Decidable Fraction', fontsize=12)
ax2.set_ylabel('Incompleteness Gap (lost profit)', fontsize=12)
ax2.set_title('The Cost of Incompleteness', fontsize=14)
ax2.legend(fontsize=10)
ax2.set_xlim(0, 1)

plt.tight_layout()
plt.savefig('viz_profit_landscape.png', dpi=150, bbox_inches='tight')
print("Saved viz_profit_landscape.png")
