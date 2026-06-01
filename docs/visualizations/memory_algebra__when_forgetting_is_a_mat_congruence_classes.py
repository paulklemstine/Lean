#!/usr/bin/env python3
"""
Visualization: Information Loss Congruence Classes

Shows how experience streams are grouped into equivalence classes
by a memory system, illustrating the compression and information loss.
"""
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np
from itertools import product
from collections import defaultdict
from typing import Dict, List, Tuple


def encode_stream(stream: Tuple[int, ...], gen_images: Dict[int, int],
                  mod: int) -> int:
    result = 0
    for s in stream:
        result = (result + gen_images[s]) % mod
    return result


def generate_streams(alphabet: List[int], length: int) -> List[Tuple[int, ...]]:
    return list(product(alphabet, repeat=length))


def main():
    alphabet = [0, 1]
    gen_images = {0: 1, 1: 3}
    mod = 4
    colors = ['#e74c3c', '#3498db', '#2ecc71', '#f39c12']

    fig, axes = plt.subplots(2, 3, figsize=(15, 10))
    fig.suptitle('Information Loss Congruence Classes\n'
                 'Memory System: FreeMonoid({0,1}) → Z/4, generators 0→1, 1→3',
                 fontsize=14, fontweight='bold')

    for idx, n in enumerate(range(1, 7)):
        ax = axes[idx // 3][idx % 3]
        streams = generate_streams(alphabet, n)

        classes: Dict[int, List[str]] = defaultdict(list)
        for s in streams:
            state = encode_stream(s, gen_images, mod)
            label = ''.join(map(str, s))
            classes[state].append(label)

        # Bar chart of class sizes
        states = sorted(classes.keys())
        sizes = [len(classes[s]) for s in states]
        bars = ax.bar(states, sizes, color=[colors[s] for s in states],
                      edgecolor='black', linewidth=0.5)

        ax.set_title(f'Length {n}: {len(streams)} streams → {len(classes)} classes',
                     fontsize=10)
        ax.set_xlabel('Memory State')
        ax.set_ylabel('Class Size')
        ax.set_xticks(states)

        # Annotate with example streams
        for i, s in enumerate(states):
            members = classes[s]
            if len(members) <= 3:
                text = '\n'.join(members)
            else:
                text = '\n'.join(members[:2]) + f'\n+{len(members)-2} more'
            ax.annotate(text, xy=(s, sizes[i]), xytext=(0, 5),
                        textcoords='offset points', ha='center', va='bottom',
                        fontsize=6, fontfamily='monospace')

    plt.tight_layout()
    plt.savefig('viz_congruence_classes.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved viz_congruence_classes.png")


if __name__ == '__main__':
    main()
