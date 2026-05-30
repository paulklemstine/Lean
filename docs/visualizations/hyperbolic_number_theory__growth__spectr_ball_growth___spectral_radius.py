#!/usr/bin/env python3
"""
Visualization: Free Group Ball Growth and Kesten Spectral Radius

This script visualizes the core results of Hyperbolic Number Theory:
1. Left panel: Ball size B(n) = 2·3^n - 1 for F₂ on a log scale, 
   showing exponential growth with base 3.
2. Right panel: Kesten spectral radius ρ = √(2k-1)/k as a function
   of the number of generators k, showing the universal spectral gap.
"""

import numpy as np
import matplotlib.pyplot as plt

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5.5))

# --- Panel 1: Ball Growth ---
ns = np.arange(0, 10)

# Compute ball sizes for different k
for k, color, label in [(1, '#888888', 'F₁ (ℤ)'), 
                          (2, '#2196F3', 'F₂'), 
                          (3, '#4CAF50', 'F₃'),
                          (4, '#FF9800', 'F₄')]:
    def ball_size(k_val, n_val):
        if k_val == 1:
            return 2 * n_val + 1
        growth = 2 * k_val - 1
        return 1 + k_val * (growth ** n_val - 1) // (k_val - 1)
    
    bs = [ball_size(k, int(n)) for n in ns]
    ax1.semilogy(ns, bs, 'o-', color=color, label=label, markersize=6, linewidth=2)

# Reference lines
ax1.semilogy(ns, 3**ns, '--', color='#2196F3', alpha=0.3, label='3ⁿ (lower bound)')
ax1.semilogy(ns, 5**ns, '--', color='#4CAF50', alpha=0.3, label='5ⁿ (F₃ rate)')

ax1.set_xlabel('Radius n', fontsize=13)
ax1.set_ylabel('Ball Size B(n)', fontsize=13)
ax1.set_title('Exponential Growth in Free Group Cayley Graphs', fontsize=14, fontweight='bold')
ax1.legend(fontsize=10, loc='upper left')
ax1.grid(True, alpha=0.3)
ax1.set_xlim(-0.5, 9.5)

# Annotate the F₂ formula
ax1.annotate('B(n) = 2·3ⁿ − 1', xy=(6, 2*3**6-1), fontsize=11,
            xytext=(4, 3**8), arrowprops=dict(arrowstyle='->', color='#2196F3'),
            color='#2196F3', fontweight='bold')

# --- Panel 2: Kesten Spectral Radius ---
ks = np.arange(2, 20)
rhos = np.sqrt(2 * ks - 1) / ks
gaps = 1 - rhos

ax2.bar(ks - 0.2, rhos, width=0.4, color='#E53935', alpha=0.8, label='Spectral radius ρ')
ax2.bar(ks + 0.2, gaps, width=0.4, color='#43A047', alpha=0.8, label='Spectral gap 1−ρ')
ax2.axhline(y=1, color='black', linestyle='--', linewidth=0.8, alpha=0.5)

# Mark the F₂ case
ax2.annotate('F₂: ρ = √3/2\n≈ 0.866', xy=(2, np.sqrt(3)/2), fontsize=10,
            xytext=(5, 0.95), arrowprops=dict(arrowstyle='->', color='#E53935'),
            color='#E53935', fontweight='bold',
            bbox=dict(boxstyle='round,pad=0.3', facecolor='white', edgecolor='#E53935', alpha=0.9))

ax2.set_xlabel('Number of Generators k', fontsize=13)
ax2.set_ylabel('Value', fontsize=13)
ax2.set_title('Kesten Spectral Bound: √(2k−1)/k < 1', fontsize=14, fontweight='bold')
ax2.legend(fontsize=10, loc='center right')
ax2.grid(True, alpha=0.3, axis='y')
ax2.set_xlim(1, 20)
ax2.set_ylim(0, 1.1)

plt.tight_layout()
plt.savefig('viz_growth.png', dpi=150, bbox_inches='tight')
print("Saved viz_growth.png")
