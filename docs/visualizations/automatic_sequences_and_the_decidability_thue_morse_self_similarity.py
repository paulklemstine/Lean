"""
Visualization: The Thue-Morse Sequence and Its Self-Similar Structure

This script creates a multi-panel visualization showing:
1. The Thue-Morse sequence as a binary strip
2. Self-similarity: overlaying t(n) and t(2n) 
3. Autocorrelation function (showing non-periodicity)
4. The sequence as a 2D fractal pattern
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.colors as mcolors


def bit_sum(n):
    """Count 1-bits in n."""
    count = 0
    while n > 0:
        count += n & 1
        n >>= 1
    return count


def thue_morse(n):
    """Thue-Morse sequence: popcount(n) mod 2."""
    return bit_sum(n) % 2


# Generate sequence
N = 256
seq = np.array([thue_morse(n) for n in range(N)])

fig, axes = plt.subplots(2, 2, figsize=(14, 10))
fig.suptitle('The Thue-Morse Sequence: Order from Self-Similarity', 
             fontsize=16, fontweight='bold')

# Panel 1: Binary strip
ax1 = axes[0, 0]
strip = seq[:128].reshape(1, -1)
ax1.imshow(np.tile(strip, (8, 1)), cmap='binary', aspect='auto', interpolation='nearest')
ax1.set_title('Binary Representation (first 128 terms)', fontsize=12)
ax1.set_xlabel('Index n')
ax1.set_yticks([])

# Panel 2: Self-similarity
ax2 = axes[0, 1]
n_show = 64
x = np.arange(n_show)
seq_n = np.array([thue_morse(n) for n in range(n_show)])
seq_2n = np.array([thue_morse(2*n) for n in range(n_show)])
seq_2n1 = np.array([thue_morse(2*n+1) for n in range(n_show)])

ax2.step(x, seq_n + 0.02, where='mid', label='t(n)', color='#2196F3', linewidth=1.5)
ax2.step(x, seq_2n - 0.02, where='mid', label='t(2n) = t(n)', color='#FF5722', 
         linewidth=1.5, linestyle='--')
ax2.set_title('Self-Similarity: t(2n) = t(n)', fontsize=12)
ax2.set_xlabel('n')
ax2.set_ylabel('Value')
ax2.legend(fontsize=10)
ax2.set_ylim(-0.2, 1.3)

# Panel 3: Autocorrelation
ax3 = axes[1, 0]
max_lag = 64
autocorr = []
for lag in range(1, max_lag + 1):
    matches = sum(1 for i in range(N - lag) if seq[i] == seq[i + lag])
    autocorr.append(matches / (N - lag))

ax3.bar(range(1, max_lag + 1), autocorr, color='#4CAF50', alpha=0.7, width=0.8)
ax3.axhline(y=0.5, color='red', linestyle='--', alpha=0.5, label='Random baseline (0.5)')
ax3.set_title('Autocorrelation: No Period Dominates', fontsize=12)
ax3.set_xlabel('Lag')
ax3.set_ylabel('Match fraction')
ax3.legend(fontsize=10)

# Panel 4: 2D fractal pattern (arrange sequence on a grid)
ax4 = axes[1, 1]
side = 16
grid = np.array([thue_morse(i * side + j) for i in range(side) for j in range(side)])
grid = grid.reshape(side, side)

# Create a custom colormap
cmap = mcolors.ListedColormap(['#1a237e', '#ffeb3b'])
ax4.imshow(grid, cmap=cmap, interpolation='nearest')
ax4.set_title(f'2D Pattern ({side}×{side} grid)', fontsize=12)
ax4.set_xlabel('Column')
ax4.set_ylabel('Row')

# Add grid lines
for i in range(side + 1):
    ax4.axhline(y=i-0.5, color='gray', linewidth=0.3)
    ax4.axvline(x=i-0.5, color='gray', linewidth=0.3)

plt.tight_layout()
plt.savefig('viz_thue_morse.png', dpi=150, bbox_inches='tight')
print("Saved viz_thue_morse.png")
