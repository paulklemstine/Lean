"""
Visualization: Betti Number Scaling Under Coverings

Shows how the first Betti number b₁ grows under n-sheeted coverings:
  b₁(G̃) = n · b₁(G) - (n - 1)

This is the key formula that determines the "rank" of the limiting
Cohen-Lenstra distribution, connecting topology to number theory.
"""

import numpy as np
import matplotlib.pyplot as plt


# === Betti number formula ===

def betti_covering(b1_base: int, n_sheets: int) -> int:
    """b₁ of an n-sheeted covering: n * b₁(G) - (n - 1)"""
    return n_sheets * b1_base - (n_sheets - 1)

def cohen_lenstra_trivial_prob(p: int, b1: int) -> float:
    """P(trivial Sylow-p) = ∏_{i=1}^{b₁} (1 - p^{-i})"""
    prob = 1.0
    for i in range(1, b1 + 1):
        prob *= (1 - p**(-i))
    return prob


# === Create figure ===
fig, axes = plt.subplots(1, 3, figsize=(16, 5))

# Panel 1: Betti number growth
ax1 = axes[0]
n_range = range(1, 11)
for b1_base in [1, 2, 3, 4]:
    b1_values = [betti_covering(b1_base, n) for n in n_range]
    ax1.plot(n_range, b1_values, 'o-', linewidth=2, markersize=6,
             label=f'b₁(G) = {b1_base}')

ax1.set_xlabel('Number of sheets n', fontsize=12)
ax1.set_ylabel('b₁(covering)', fontsize=12)
ax1.set_title('Betti Number Growth Under Covering\nb₁(G̃) = n·b₁(G) - (n-1)',
              fontsize=12)
ax1.legend(fontsize=10)
ax1.grid(True, alpha=0.3)

# Panel 2: Cohen-Lenstra trivial probability vs b₁
ax2 = axes[1]
b1_range = range(1, 16)
for p in [2, 3, 5, 7]:
    probs = [cohen_lenstra_trivial_prob(p, b1) for b1 in b1_range]
    ax2.plot(b1_range, probs, 's-', linewidth=2, markersize=5,
             label=f'p = {p}')

ax2.set_xlabel('First Betti number b₁', fontsize=12)
ax2.set_ylabel('P(trivial Sylow-p)', fontsize=12)
ax2.set_title('Cohen-Lenstra: P(trivial p-part)\n∏(1 - p⁻ⁱ) for i=1..b₁',
              fontsize=12)
ax2.legend(fontsize=10)
ax2.grid(True, alpha=0.3)
ax2.set_ylim(0, 1)

# Panel 3: Phase diagram - p vs b₁ heatmap of trivial probability
ax3 = axes[2]
primes = [2, 3, 5, 7, 11, 13, 17, 19, 23, 29]
b1_vals = list(range(1, 11))
prob_matrix = np.zeros((len(primes), len(b1_vals)))

for i, p in enumerate(primes):
    for j, b1 in enumerate(b1_vals):
        prob_matrix[i, j] = cohen_lenstra_trivial_prob(p, b1)

im = ax3.imshow(prob_matrix, aspect='auto', cmap='viridis',
                interpolation='nearest', vmin=0, vmax=1)
ax3.set_xticks(range(len(b1_vals)))
ax3.set_xticklabels(b1_vals)
ax3.set_yticks(range(len(primes)))
ax3.set_yticklabels(primes)
ax3.set_xlabel('First Betti number b₁', fontsize=12)
ax3.set_ylabel('Prime p', fontsize=12)
ax3.set_title('Phase Diagram:\nP(trivial Sylow-p) by (p, b₁)', fontsize=12)
plt.colorbar(im, ax=ax3, shrink=0.8, label='Probability')

plt.tight_layout()
plt.savefig('betti_scaling.png', dpi=150, bbox_inches='tight')
print("Saved betti_scaling.png")
