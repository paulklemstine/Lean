"""Visualization: Confusion heatmap for a memory system.

Shows which length-k streams get mapped to the same memory state,
visualized as a heatmap of the encoding function.
"""
import matplotlib.pyplot as plt
import numpy as np
from itertools import product


def encode_modular(stream, gen_map, modulus):
    """Encode a stream using modular arithmetic."""
    result = 0
    for s in stream:
        result = (result + gen_map[s]) % modulus
    return result


def main():
    alphabet = ['0', '1']
    modulus = 8
    gen_map = {'0': 1, '1': 3}
    max_k = 6

    fig, axes = plt.subplots(2, 3, figsize=(14, 9))
    fig.suptitle('Memory Confusion: Which Streams Share Memory States?',
                 fontsize=14, fontweight='bold')

    for idx, k in enumerate(range(1, max_k + 1)):
        ax = axes[idx // 3][idx % 3]
        streams = list(product(alphabet, repeat=k))
        encodings = [encode_modular(s, gen_map, modulus) for s in streams]

        n = len(streams)
        confusion_matrix = np.zeros((n, n))
        for i in range(n):
            for j in range(n):
                if encodings[i] == encodings[j]:
                    confusion_matrix[i][j] = 1

        ax.imshow(confusion_matrix, cmap='YlOrRd', aspect='auto')
        ax.set_title(f'Length {k} ({n} streams)', fontsize=10)
        ax.set_xlabel('Stream index')
        ax.set_ylabel('Stream index')

        # Count confusion classes
        unique_encodings = len(set(encodings))
        ax.text(0.02, 0.98, f'{unique_encodings} classes',
                transform=ax.transAxes, fontsize=8,
                verticalalignment='top',
                bbox=dict(boxstyle='round', facecolor='white', alpha=0.8))

    plt.tight_layout()
    plt.savefig('viz_confusion_heatmap.png', dpi=150)
    plt.close()
    print("Saved viz_confusion_heatmap.png")


if __name__ == '__main__':
    main()
