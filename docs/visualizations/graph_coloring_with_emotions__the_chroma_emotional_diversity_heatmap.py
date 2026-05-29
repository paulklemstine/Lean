"""
Visualization: Emotional Diversity Heatmap

Shows the emotional diversity index D(K_n, k) = k^(n) / k^n as a heatmap,
revealing how the interaction between group size and emotion count
determines the fraction of valid emotion assignments.
"""

import matplotlib.pyplot as plt
import numpy as np

def falling_factorial(k, n):
    """k^(n) = k(k-1)...(k-n+1)"""
    result = 1.0
    for i in range(n):
        result *= max(k - i, 0)
    return result

n_max = 10
k_max = 12

diversity = np.zeros((n_max, k_max))

for n in range(1, n_max + 1):
    for k in range(1, k_max + 1):
        ff = falling_factorial(k, n)
        total = k ** n
        diversity[n - 1, k - 1] = ff / total if total > 0 else 0

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(16, 7))

# Heatmap of diversity
im = ax1.imshow(diversity, aspect='auto', cmap='RdYlGn', origin='lower',
                vmin=0, vmax=1, interpolation='nearest')
ax1.set_xlabel('Number of emotions k', fontsize=13)
ax1.set_ylabel('Group size n (complete graph K_n)', fontsize=13)
ax1.set_title('Emotional Diversity of Complete Groups\nD(K_n, k) = k⁽ⁿ⁾/kⁿ', fontsize=14)
ax1.set_xticks(range(k_max))
ax1.set_xticklabels(range(1, k_max + 1))
ax1.set_yticks(range(n_max))
ax1.set_yticklabels(range(1, n_max + 1))

# Annotate cells
for n in range(n_max):
    for k in range(k_max):
        val = diversity[n, k]
        color = 'white' if val < 0.3 or val > 0.85 else 'black'
        ax1.text(k, n, f'{val:.2f}', ha='center', va='center',
                 fontsize=7, color=color, fontweight='bold')

plt.colorbar(im, ax=ax1, label='Emotional Diversity Index', shrink=0.8)

# Mark the k=6 column (Ekman's emotions)
ax1.axvline(x=4.5, color='red', linewidth=2, linestyle='--', alpha=0.7)
ax1.axvline(x=5.5, color='red', linewidth=2, linestyle='--', alpha=0.7)
ax1.text(5, n_max - 0.3, 'k=6\n(Ekman)', ha='center', va='top',
         color='red', fontsize=9, fontweight='bold')

# Plot 2: Diversity curves
for n in [2, 3, 4, 5, 6, 8, 10]:
    k_range = np.arange(1, k_max + 1)
    div = [falling_factorial(k, n) / (k ** n) if k > 0 else 0 for k in k_range]
    ax2.plot(k_range, div, 'o-', label=f'n={n}', linewidth=2, markersize=5)

ax2.set_xlabel('Number of emotions k', fontsize=13)
ax2.set_ylabel('Emotional Diversity D(K_n, k)', fontsize=13)
ax2.set_title('Diversity vs. Emotion Count\nfor Complete Social Groups', fontsize=14)
ax2.legend(title='Group size', fontsize=9)
ax2.grid(True, alpha=0.3)
ax2.set_ylim(-0.05, 1.05)
ax2.axvline(x=6, color='red', linestyle='--', alpha=0.5)
ax2.text(6.2, 0.95, 'Ekman\'s 6', color='red', fontsize=10)
ax2.axhline(y=1, color='gray', linestyle=':', alpha=0.3)

plt.tight_layout()
plt.savefig('diversity_heatmap.png', dpi=150, bbox_inches='tight')
print("Saved diversity_heatmap.png")
