#!/usr/bin/env python3
"""
Visualization 2: Arrhenius Rate Convergence at Low Temperature

Shows how Arrhenius transition rates from a metastably degenerate state
converge to equal dominance as inverse temperature β → ∞. Demonstrates
Theorem 4: equal rates ↔ equal barriers ↔ tropical balance.

This script is fully self-contained — no local imports needed.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt

# ── Setup ──

# State 0 has barriers [2.0, 2.0, 5.0, 7.0] to states 1-4
barriers = np.array([2.0, 2.0, 5.0, 7.0])
labels = ['Exit 1 (barrier=2)', 'Exit 2 (barrier=2)', 
          'Exit 3 (barrier=5)', 'Exit 4 (barrier=7)']
colors = ['#e74c3c', '#3498db', '#2ecc71', '#9b59b6']

betas = np.linspace(0.01, 5.0, 200)

fig, axes = plt.subplots(1, 3, figsize=(16, 5))

# ── Panel 1: Raw Arrhenius rates ──
ax1 = axes[0]
for idx, (b, label, color) in enumerate(zip(barriers, labels, colors)):
    rates = np.exp(-betas * b)
    ax1.plot(betas, rates, color=color, linewidth=2, label=label)

ax1.set_xlabel('Inverse Temperature β', fontsize=11)
ax1.set_ylabel('Rate  exp(−β·W)', fontsize=11)
ax1.set_title('Arrhenius Rates vs β', fontsize=13, fontweight='bold')
ax1.legend(fontsize=8, loc='upper right')
ax1.set_ylim(-0.05, 1.05)
ax1.axhline(y=0, color='gray', linewidth=0.5)

# Shade region where exits 1&2 dominate
ax1.fill_between(betas, 0, 1.05, where=betas > 1.5, alpha=0.05, color='blue')
ax1.text(3.5, 0.5, 'Low-T\nregime', fontsize=10, ha='center', style='italic',
         color='blue', alpha=0.7)

# ── Panel 2: Rate ratios (normalized) ──
ax2 = axes[1]
for idx, (b, label, color) in enumerate(zip(barriers, labels, colors)):
    rates = np.exp(-betas * b)
    total = sum(np.exp(-betas * bi) for bi in barriers)
    ratio = rates / total
    ax2.plot(betas, ratio, color=color, linewidth=2, label=label)

ax2.set_xlabel('Inverse Temperature β', fontsize=11)
ax2.set_ylabel('Escape Probability', fontsize=11)
ax2.set_title('Escape Probability Distribution', fontsize=13, fontweight='bold')
ax2.legend(fontsize=8, loc='right')
ax2.set_ylim(-0.05, 1.05)
ax2.axhline(y=0.5, color='gray', linewidth=0.5, linestyle='--', alpha=0.5)

# Annotate convergence
ax2.annotate('Both → 50%\n(equal barriers!)', xy=(4.5, 0.5), fontsize=9,
            ha='center', style='italic', color='red',
            bbox=dict(boxstyle='round,pad=0.3', facecolor='lightyellow'))

# ── Panel 3: Log-rate difference ──
ax3 = axes[2]
for idx in range(1, len(barriers)):
    diff = np.abs(np.exp(-betas * barriers[idx]) - np.exp(-betas * barriers[0]))
    # Avoid log(0)
    diff = np.maximum(diff, 1e-20)
    ax3.semilogy(betas, diff, color=colors[idx], linewidth=2,
                label=f'|rate₁ − rate{idx+1}|')

ax3.set_xlabel('Inverse Temperature β', fontsize=11)
ax3.set_ylabel('|Rate Difference| (log scale)', fontsize=11)
ax3.set_title('Rate Differences Decay', fontsize=13, fontweight='bold')
ax3.legend(fontsize=8)

# Annotate: equal barrier pair stays at 0
ax3.annotate('Equal barriers → \nidentically zero!', xy=(2.5, 1e-15),
            fontsize=9, ha='center', style='italic', color='red',
            bbox=dict(boxstyle='round,pad=0.3', facecolor='lightyellow'))

plt.suptitle('Theorem 4: Equal Arrhenius Rates ↔ Equal Barriers ↔ Tropical Balance',
             fontsize=14, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('viz_arrhenius_rates.png', dpi=150, bbox_inches='tight')
print("Saved viz_arrhenius_rates.png")
