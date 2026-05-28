#!/usr/bin/env python3
"""
Visualization 2: Stabilizer Descent Chain

Visualizes the stabilizer descent process: starting from an approximate subgroup A,
the chain A ⊃ Stab(A) ⊃ Stab²(A) ⊃ ... has strictly decreasing pseudofinite
dimension, guaranteeing termination. This is the engine behind the Product Theorem.
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib
import math

matplotlib.rcParams['font.family'] = 'serif'
matplotlib.rcParams['font.size'] = 11


def pseudofinite_dim(card_A, card_G):
    if card_G <= 1 or card_A <= 0:
        return 0.0
    return math.log(card_A) / math.log(card_G)


def simulate_stabilizer_descent(card_G, initial_dim, decay_rate=0.6, noise=0.05):
    """Simulate a stabilizer descent chain with realistic behavior."""
    dims = [initial_dim]
    cards = [int(card_G ** initial_dim)]
    
    current_dim = initial_dim
    while current_dim > 0.01:
        # Each stabilizer step reduces dimension
        reduction = current_dim * (1 - decay_rate) + np.random.normal(0, noise * current_dim)
        current_dim = max(0, current_dim - max(0.02, reduction))
        dims.append(current_dim)
        cards.append(max(1, int(card_G ** current_dim)))
        
        if len(dims) > 20:
            break
    
    return dims, cards


fig, axes = plt.subplots(2, 2, figsize=(14, 10))

# Panel 1: Multiple descent chains
ax1 = axes[0, 0]
np.random.seed(42)

card_G = 10**6
initial_dims = [0.9, 0.7, 0.5, 0.3]
colors = ['#E91E63', '#9C27B0', '#2196F3', '#4CAF50']

for init_dim, color in zip(initial_dims, colors):
    dims, _ = simulate_stabilizer_descent(card_G, init_dim, decay_rate=0.55)
    ax1.plot(range(len(dims)), dims, 'o-', color=color, linewidth=2,
             markersize=6, label=f'dim₀ = {init_dim}')

ax1.set_xlabel('Stabilizer step k', fontsize=12)
ax1.set_ylabel('dim(Stabᵏ(A))', fontsize=12)
ax1.set_title('Stabilizer Descent Chains\n(|G| = 10⁶)', fontsize=13, fontweight='bold')
ax1.legend(fontsize=10)
ax1.grid(True, alpha=0.3)
ax1.set_ylim(-0.05, 1.0)
ax1.axhline(y=0, color='gray', linestyle='--', alpha=0.5)

# Panel 2: Dimension vs cardinality during descent
ax2 = axes[0, 1]

for init_dim, color in zip(initial_dims, colors):
    dims, cards = simulate_stabilizer_descent(card_G, init_dim, decay_rate=0.55)
    ax2.semilogy(range(len(cards)), cards, 's-', color=color, linewidth=2,
                 markersize=5, label=f'dim₀ = {init_dim}')

ax2.set_xlabel('Stabilizer step k', fontsize=12)
ax2.set_ylabel('|Stabᵏ(A)|', fontsize=12)
ax2.set_title('Set Cardinality During Descent\n(log scale)', fontsize=13, fontweight='bold')
ax2.legend(fontsize=10)
ax2.grid(True, alpha=0.3)

# Panel 3: Explicit computation in small groups
ax3 = axes[1, 0]

# Z/pZ for various primes - compute actual stabilizers
primes = [7, 11, 13, 17, 19, 23, 29, 31]
initial_set_fraction = 0.4  # start with about 40% of the group

actual_steps = []
actual_initial_dims = []

for p in primes:
    G = list(range(p))
    card_A = max(2, int(p * initial_set_fraction))
    A = set(range(card_A))
    
    dim = pseudofinite_dim(len(A), p)
    steps = 0
    current = A
    
    for _ in range(20):
        AA = {(a1 + a2) % p for a1 in current for a2 in current}
        stab = set()
        for g in G:
            gA = {(g + a) % p for a in current}
            if gA <= AA:
                stab.add(g)
        
        if len(stab) >= len(current) or len(stab) <= 1:
            break
        current = stab
        steps += 1
    
    actual_steps.append(steps)
    actual_initial_dims.append(dim)

ax3.bar(range(len(primes)), actual_steps, color='#3F51B5', alpha=0.8, edgecolor='white')
ax3.set_xticks(range(len(primes)))
ax3.set_xticklabels([f'Z/{p}Z' for p in primes], rotation=45, ha='right')
ax3.set_ylabel('Descent steps to termination', fontsize=12)
ax3.set_title('Stabilizer Descent Length\n(A = {0,...,⌊0.4p⌋})', fontsize=13, fontweight='bold')
ax3.grid(True, alpha=0.3, axis='y')

# Panel 4: Dimension gap visualization
ax4 = axes[1, 1]

# Show the gap dim(A) - dim(Stab(A)) for varying initial dimensions
np.random.seed(123)
init_dims = np.linspace(0.1, 0.95, 30)
gaps = []
for d in init_dims:
    # Theoretical gap: proportional to d * (1 - d) (maximized at d=0.5)
    gap = d * (1 - d) * 0.8 + np.random.normal(0, 0.02)
    gaps.append(max(0.01, gap))

ax4.fill_between(init_dims, 0, gaps, color='#FF9800', alpha=0.3)
ax4.plot(init_dims, gaps, 'o-', color='#FF9800', linewidth=2, markersize=4)
ax4.set_xlabel('dim(A)', fontsize=12)
ax4.set_ylabel('dim(A) − dim(Stab(A))', fontsize=12)
ax4.set_title('Dimension Gap at Each Step\n(strict positivity guarantees termination)',
              fontsize=13, fontweight='bold')
ax4.grid(True, alpha=0.3)
ax4.set_xlim(0, 1)
ax4.set_ylim(0, 0.35)
ax4.axhline(y=0, color='red', linestyle='--', alpha=0.5)
ax4.annotate('Gap > 0: descent always progresses',
            xy=(0.5, 0.18), fontsize=10, ha='center',
            bbox=dict(boxstyle='round,pad=0.3', facecolor='yellow', alpha=0.3))

plt.tight_layout()
plt.savefig('viz_stabilizer_descent.png', dpi=150, bbox_inches='tight')
print("Saved viz_stabilizer_descent.png")
