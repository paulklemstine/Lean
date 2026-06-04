"""
Visualization: Thue-Morse Sequence Self-Similarity and K-Kernel Structure

Produces a multi-panel figure showing:
1. The Thue-Morse sequence as a binary heatmap
2. Self-similar structure under decimation
3. K-kernel orbit visualization
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def bit_sum(n):
    """Compute binary digit sum (popcount)."""
    count = 0
    while n > 0:
        count += n & 1
        n >>= 1
    return count


def thue_morse(n):
    """Thue-Morse sequence: t(n) = popcount(n) mod 2."""
    return bit_sum(n) % 2


def compute_sequence(length):
    """Generate Thue-Morse sequence."""
    return [thue_morse(n) for n in range(length)]


def main():
    N = 256
    seq = compute_sequence(N)

    fig, axes = plt.subplots(2, 2, figsize=(14, 10))
    fig.suptitle('Thue-Morse Sequence: Self-Similarity and the Decidability Frontier',
                 fontsize=14, fontweight='bold')

    # Panel 1: Binary heatmap (16x16 grid)
    ax1 = axes[0, 0]
    grid = np.array(seq).reshape(16, 16)
    im = ax1.imshow(grid, cmap='binary', aspect='equal', interpolation='nearest')
    ax1.set_title('Thue-Morse as 16×16 Grid', fontsize=11)
    ax1.set_xlabel('Column (n mod 16)')
    ax1.set_ylabel('Row (n ÷ 16)')

    # Panel 2: Self-similarity - original vs even-indexed vs odd-indexed
    ax2 = axes[0, 1]
    n_show = 64
    original = seq[:n_show]
    even_sub = [seq[2 * i] for i in range(n_show)]
    odd_sub = [seq[2 * i + 1] for i in range(n_show)]

    for i, (label, s, color) in enumerate([
        ('t(n)', original, '#2196F3'),
        ('t(2n) = t(n)', even_sub, '#4CAF50'),
        ('t(2n+1) = 1−t(n)', odd_sub, '#F44336')
    ]):
        y_offset = 2 - i
        for j, v in enumerate(s):
            ax2.add_patch(plt.Rectangle((j, y_offset - 0.4), 1, 0.8,
                                         facecolor=color if v == 1 else 'white',
                                         edgecolor=color, alpha=0.7))
    ax2.set_xlim(0, n_show)
    ax2.set_ylim(-0.5, 2.5)
    ax2.set_yticks([0, 1, 2])
    ax2.set_yticklabels(['t(2n+1)', 't(2n)', 't(n)'])
    ax2.set_xlabel('Index')
    ax2.set_title('Self-Similarity: Decimation', fontsize=11)

    # Panel 3: Cumulative balance (partial sums showing equidistribution)
    ax3 = axes[1, 0]
    N_long = 1024
    long_seq = compute_sequence(N_long)
    cumsum = np.cumsum([2 * x - 1 for x in long_seq])
    ax3.plot(range(N_long), cumsum, color='#9C27B0', linewidth=0.5)
    ax3.axhline(y=0, color='gray', linestyle='--', alpha=0.5)
    ax3.set_xlabel('n')
    ax3.set_ylabel('Σ(2t(i)−1)')
    ax3.set_title('Cumulative Balance (Perfect Equidistribution)', fontsize=11)
    ax3.fill_between(range(N_long), cumsum, alpha=0.1, color='#9C27B0')

    # Panel 4: 2-kernel visualization
    ax4 = axes[1, 1]
    max_e = 4
    kernel_seqs = {}
    for e in range(max_e + 1):
        ke = 2 ** e
        for r in range(ke):
            sub = tuple(thue_morse(ke * n + r) for n in range(32))
            if sub not in kernel_seqs.values():
                kernel_seqs[(e, r)] = sub

    colors = ['#2196F3', '#F44336', '#4CAF50', '#FF9800']
    for idx, ((e, r), sub) in enumerate(kernel_seqs.items()):
        label = f'e={e}, r={r}'
        y_vals = [v + idx * 1.5 for v in sub[:32]]
        ax4.step(range(32), y_vals, where='mid', label=label,
                color=colors[idx % len(colors)], linewidth=1.5)

    ax4.set_xlabel('n')
    ax4.set_title(f'2-Kernel: {len(kernel_seqs)} Distinct Subsequences', fontsize=11)
    ax4.legend(fontsize=8, loc='upper right')
    ax4.set_yticks([])

    plt.tight_layout()
    plt.savefig('viz_thue_morse.png', dpi=150, bbox_inches='tight')
    print("Saved viz_thue_morse.png")


if __name__ == '__main__':
    main()
