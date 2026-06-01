#!/usr/bin/env python3
"""Visualization: Unique Games Value Landscape."""
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
import random
import itertools

class Perm:
    def __init__(self, m):
        self.m = list(m)
        self.k = len(m)
    def __call__(self, x):
        return self.m[x]
    @staticmethod
    def rand(k):
        m = list(range(k))
        random.shuffle(m)
        return Perm(m)

def game_value_brute(n, k, edges, constraints):
    best = 0.0
    w = 1.0 / len(edges) if edges else 0.0
    for sigma in itertools.product(range(k), repeat=n):
        val = sum(w for e in edges if constraints[e](sigma[e[0]]) == sigma[e[1]])
        best = max(best, val)
    return best

def main():
    random.seed(123)
    fig, axes = plt.subplots(1, 3, figsize=(18, 5))

    # Plot 1: Value vs density for different k
    ax = axes[0]
    n = 5
    densities = np.linspace(0.1, 1.0, 10)
    for k, color in [(2, 'blue'), (3, 'green'), (5, 'red')]:
        vals_mean = []
        vals_std = []
        for p in densities:
            vals = []
            for _ in range(15):
                edges = []
                constraints = {}
                for i in range(n):
                    for j in range(i+1, n):
                        if random.random() < p:
                            e = (i, j)
                            edges.append(e)
                            constraints[e] = Perm.rand(k)
                if edges:
                    v = game_value_brute(n, k, edges, constraints)
                    vals.append(v)
            if vals:
                vals_mean.append(np.mean(vals))
                vals_std.append(np.std(vals))
            else:
                vals_mean.append(0)
                vals_std.append(0)
        ax.errorbar(densities, vals_mean, yerr=vals_std, fmt='o-',
                   color=color, label=f'k={k}', capsize=3, linewidth=2)
        ax.axhline(y=1/k, color=color, linestyle=':', alpha=0.5)

    ax.set_xlabel('Edge Density p', fontsize=12)
    ax.set_ylabel('Optimal Value', fontsize=12)
    ax.set_title(f'Game Value vs Density (n={n})', fontsize=13)
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3)

    # Plot 2: Value distribution histogram
    ax = axes[1]
    n, k = 5, 3
    values = []
    for _ in range(100):
        edges = []
        constraints = {}
        for i in range(n):
            for j in range(i+1, n):
                if random.random() < 0.5:
                    e = (i, j)
                    edges.append(e)
                    constraints[e] = Perm.rand(k)
        if edges:
            v = game_value_brute(n, k, edges, constraints)
            values.append(v)

    ax.hist(values, bins=20, color='steelblue', edgecolor='black', alpha=0.7)
    ax.axvline(x=1/k, color='red', linestyle='--', linewidth=2,
              label=f'1/k = {1/k:.3f}')
    ax.axvline(x=np.mean(values), color='orange', linestyle='--', linewidth=2,
              label=f'Mean = {np.mean(values):.3f}')
    ax.set_xlabel('Optimal Value', fontsize=12)
    ax.set_ylabel('Count', fontsize=12)
    ax.set_title(f'Value Distribution (n={n}, k={k})', fontsize=13)
    ax.legend(fontsize=11)

    # Plot 3: Composition product decay
    ax = axes[2]
    game_values = np.linspace(0.5, 0.99, 50)
    for num_games, color in [(2, 'blue'), (3, 'green'), (5, 'red'), (10, 'purple')]:
        products = game_values ** num_games
        ax.plot(game_values, products, '-', color=color, linewidth=2,
               label=f'{num_games} games')

    ax.set_xlabel('Individual Game Value v', fontsize=12)
    ax.set_ylabel('Product v^m', fontsize=12)
    ax.set_title('Composition Value Decay', fontsize=13)
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('viz_game_landscape.png', dpi=150, bbox_inches='tight')
    print("Saved viz_game_landscape.png")

if __name__ == "__main__":
    main()
