#!/usr/bin/env python3
"""
Visualization 3: Representation Family Landscape of GL₂(𝔽_q)

Visualizes the four irreducible families showing their dimensions,
multiplicities, and relative contribution to the spectral decomposition.
Creates a heatmap of operator norms across families and primes.
"""

import numpy as np
import matplotlib.pyplot as plt

fig, axes = plt.subplots(1, 2, figsize=(14, 6))

# Left panel: Family dimension and count as q grows
ax1 = axes[0]
primes = np.array([5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47])

det_count = primes - 1
ps_count = (primes - 1) * (primes - 2) // 2
st_count = primes - 1
cu_count = primes * (primes - 1) // 2

total = det_count + ps_count + st_count + cu_count

ax1.stackplot(primes,
              det_count / total * 100,
              ps_count / total * 100,
              st_count / total * 100,
              cu_count / total * 100,
              labels=['Det Twists (dim 1)',
                      f'Principal Series (dim q−1)',
                      f'Steinberg (dim q)',
                      f'Cuspidal (dim q−1)'],
              colors=['#2196F3', '#F44336', '#4CAF50', '#FF9800'],
              alpha=0.8)
ax1.set_xlabel('Prime q', fontsize=13)
ax1.set_ylabel('Fraction of irreducibles (%)', fontsize=13)
ax1.set_title('Distribution of Irreducible Families', fontsize=14, fontweight='bold')
ax1.legend(loc='center right', fontsize=9)
ax1.set_ylim(0, 100)
ax1.grid(True, alpha=0.2, axis='y')

# Right panel: Heatmap of operator norm bounds
ax2 = axes[1]
primes_small = [5, 7, 11, 13, 17, 19, 23]
families = ['Det Twist', 'Principal\nSeries', 'Steinberg', 'Cuspidal']

# Compute theoretical bounds
data = np.zeros((4, len(primes_small)))
for j, q in enumerate(primes_small):
    data[0, j] = np.cos(2 * np.pi / (q - 1))  # Det twist
    data[1, j] = 1 - 1/(2*q)                    # Principal series
    data[2, j] = min(1.0, 2/np.sqrt(q))        # Steinberg
    data[3, j] = min(1.0, 2/(q-1))             # Cuspidal

im = ax2.imshow(data, cmap='RdYlGn_r', aspect='auto', vmin=0, vmax=1)
ax2.set_xticks(range(len(primes_small)))
ax2.set_xticklabels([str(q) for q in primes_small], fontsize=11)
ax2.set_yticks(range(4))
ax2.set_yticklabels(families, fontsize=11)
ax2.set_xlabel('Prime q', fontsize=13)
ax2.set_title('Operator Norm Bounds by Family', fontsize=14, fontweight='bold')

# Add text annotations
for i in range(4):
    for j in range(len(primes_small)):
        text = f'{data[i,j]:.2f}'
        color = 'white' if data[i,j] > 0.6 else 'black'
        ax2.text(j, i, text, ha='center', va='center', fontsize=9,
                fontweight='bold', color=color)

plt.colorbar(im, ax=ax2, label='Operator norm bound', shrink=0.8)

# Highlight the dominant row
ax2.add_patch(plt.Rectangle((-0.5, 0.5), len(primes_small), 1,
              fill=False, edgecolor='red', linewidth=2.5, linestyle='--'))
ax2.annotate('Dominant family', xy=(len(primes_small)-0.5, 1),
             xytext=(len(primes_small)+0.5, 0.5),
             arrowprops=dict(arrowstyle='->', color='red'),
             fontsize=10, color='red', fontweight='bold')

plt.tight_layout()
plt.savefig('rep_family_landscape.png', dpi=150, bbox_inches='tight')
print("Saved rep_family_landscape.png")
