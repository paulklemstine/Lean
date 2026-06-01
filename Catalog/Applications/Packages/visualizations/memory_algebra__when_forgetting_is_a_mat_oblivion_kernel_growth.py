#!/usr/bin/env python3
"""
Visualization: Oblivion Kernel Growth

Shows how the oblivion kernel (ghost experiences) grows exponentially
compared to the fixed number of distinguishable classes.
"""
import matplotlib.pyplot as plt
import numpy as np
from itertools import product
from collections import defaultdict


def encode(stream, gen_images, mod):
    result = 0
    for s in stream:
        result = (result + gen_images[s]) % mod
    return result


def main():
    alphabet = [0, 1]
    gen_images = {0: 2, 1: 3}
    mod = 6

    lengths = range(1, 10)
    total_streams = []
    kernel_sizes = []
    distinct_states = []

    for L in lengths:
        streams = list(product(alphabet, repeat=L))
        total = len(streams)
        total_streams.append(total)

        kernel_count = sum(1 for s in streams if encode(s, gen_images, mod) == 0)
        kernel_sizes.append(kernel_count)

        distinct = len({encode(s, gen_images, mod) for s in streams})
        distinct_states.append(distinct)

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))
    fig.suptitle('Oblivion Kernel Growth\n'
                 'Memory System: FreeMonoid({0,1}) → Z/6, generators 0→2, 1→3',
                 fontsize=13, fontweight='bold')

    # Left: Absolute counts
    ax1.set_title('Stream Counts by Length')
    ax1.semilogy(list(lengths), total_streams, 'ko-', label='Total streams (2ⁿ)',
                linewidth=2, markersize=6)
    ax1.semilogy(list(lengths), kernel_sizes, 'rs-', label='Oblivion kernel',
                linewidth=2, markersize=6)
    ax1.semilogy(list(lengths), distinct_states, 'b^-', label='Distinct states',
                linewidth=2, markersize=6)

    # Theoretical bound
    theoretical = [max(1, (2**L - mod) // mod) for L in lengths]
    ax1.semilogy(list(lengths), theoretical, 'r--', alpha=0.5,
                label='Lower bound ⌊(2ⁿ-6)/6⌋', linewidth=1)

    ax1.set_xlabel('Stream Length n')
    ax1.set_ylabel('Count (log scale)')
    ax1.legend()
    ax1.grid(True, alpha=0.3)

    # Right: Proportions
    ax2.set_title('Fraction of Streams in Oblivion Kernel')
    fractions = [k/t for k, t in zip(kernel_sizes, total_streams)]
    expected = [1/mod] * len(lengths)

    ax2.plot(list(lengths), fractions, 'rs-', label='Actual kernel fraction',
            linewidth=2, markersize=8)
    ax2.axhline(y=1/mod, color='gray', linestyle='--', alpha=0.7,
               label=f'Expected (1/{mod} = {1/mod:.4f})')

    ax2.set_xlabel('Stream Length n')
    ax2.set_ylabel('Fraction')
    ax2.legend()
    ax2.grid(True, alpha=0.3)
    ax2.set_ylim(0, max(fractions) * 1.3)

    plt.tight_layout()
    plt.savefig('viz_oblivion_kernel.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved viz_oblivion_kernel.png")


if __name__ == '__main__':
    main()
