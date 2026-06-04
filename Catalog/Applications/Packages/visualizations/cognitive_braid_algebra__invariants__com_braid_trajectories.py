#!/usr/bin/env python3
"""
Visualization: Cognitive Braid Trajectories

Plots the partial exponent sum trajectory for different types
of cognitive processes, showing how coherent vs confused thought
patterns differ in their complexity evolution.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def partial_sums(signs):
    """Compute running partial sums."""
    sums = [0]
    for s in signs:
        sums.append(sums[-1] + s)
    return sums


def main():
    fig, axes = plt.subplots(2, 2, figsize=(12, 10))

    # Define cognitive process types
    processes = {
        'Focused thought\n(all positive, coherence=1.0)': {
            'signs': [1, 1, 1, 1, 1, 1, 1, 1],
            'color': '#2ca02c',
            'ax': axes[0, 0]
        },
        'Creative insight\n(trefoil braid, coherence=1.0)': {
            'signs': [1, 1, 1],
            'color': '#d62728',
            'ax': axes[0, 1]
        },
        'Confused thinking\n(balanced, coherence=0.0)': {
            'signs': [1, -1, 1, -1, 1, -1, 1, -1],
            'color': '#9467bd',
            'ax': axes[1, 0]
        },
        'Mixed process\n(partial coherence=0.6)': {
            'signs': [1, 1, -1, 1, 1, -1, 1, -1, 1, 1],
            'color': '#ff7f0e',
            'ax': axes[1, 1]
        },
    }

    for title, info in processes.items():
        signs = info['signs']
        sums = partial_sums(signs)
        ax = info['ax']

        # Plot trajectory
        ax.plot(range(len(sums)), sums, 'o-', color=info['color'],
                linewidth=2, markersize=6)
        ax.fill_between(range(len(sums)), sums, alpha=0.15, color=info['color'])
        ax.axhline(y=0, color='black', linewidth=0.5, linestyle='-')

        # Annotate
        e = sum(signs)
        c = len(signs)
        cr = abs(e) / c if c > 0 else 0
        depth = max(abs(s) for s in sums)

        ax.set_title(title, fontsize=11, fontweight='bold')
        ax.set_xlabel('Step')
        ax.set_ylabel('Partial exponent sum')
        ax.text(0.02, 0.98,
                f'e = {e:+d}\nc = {c}\n|e|/c = {cr:.2f}\ndepth = {depth}',
                transform=ax.transAxes, fontsize=9, verticalalignment='top',
                bbox=dict(boxstyle='round', facecolor='wheat', alpha=0.5))
        ax.grid(True, alpha=0.3)
        ax.set_xticks(range(len(sums)))

    plt.suptitle('Cognitive Braid Trajectories\n'
                 'Partial exponent sums reveal thought structure',
                 fontsize=14, fontweight='bold')
    plt.tight_layout()
    plt.savefig('braid_trajectories.png', dpi=150, bbox_inches='tight')
    print("Saved braid_trajectories.png")


if __name__ == "__main__":
    main()
