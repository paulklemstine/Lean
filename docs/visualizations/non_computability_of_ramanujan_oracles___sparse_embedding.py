#!/usr/bin/env python3
"""
Visualization: Sparse Embedding Construction

Visualizes how the sparse embedding places arbitrary bits among correct
answers to construct a Ramanujan oracle.
"""

import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np
import random


def main():
    random.seed(42)
    
    # Truth assignment (primality-like)
    def truth(i: int) -> bool:
        if i < 2:
            return False
        return all(i % d != 0 for d in range(2, int(i**0.5) + 1))
    
    # Random seed function
    g_vals = [random.choice([True, False]) for _ in range(100)]
    g = lambda i: g_vals[i] if i < len(g_vals) else False
    
    # Sparse embedding
    def oracle(i: int) -> bool:
        if i % 21 == 0:
            return g(i // 21)
        return truth(i)
    
    n_show = 63  # Show first 63 positions (3 full blocks of 21)
    
    fig, axes = plt.subplots(3, 1, figsize=(16, 10))
    
    # Plot 1: Grid showing truth vs oracle
    ax1 = axes[0]
    for i in range(n_show):
        t = truth(i)
        o = oracle(i)
        is_free = i % 21 == 0
        correct = o == t
        
        # Color: green = correct, red = error, with border for free positions
        if correct:
            color = '#2ecc71'  # green
        else:
            color = '#e74c3c'  # red
        
        x = i % 21
        y = 2 - i // 21
        
        rect = plt.Rectangle((x, y), 0.9, 0.9,
                              facecolor=color,
                              edgecolor='gold' if is_free else 'gray',
                              linewidth=3 if is_free else 0.5)
        ax1.add_patch(rect)
        ax1.text(x + 0.45, y + 0.45, str(i), ha='center', va='center',
                 fontsize=6, color='white' if not correct else 'black')
    
    ax1.set_xlim(-0.1, 21.1)
    ax1.set_ylim(-0.2, 3.1)
    ax1.set_aspect('equal')
    ax1.set_title('Sparse Embedding: Position Grid (gold border = free positions)',
                  fontsize=13)
    ax1.set_xlabel('Position within block of 21', fontsize=11)
    
    green_patch = mpatches.Patch(color='#2ecc71', label='Correct')
    red_patch = mpatches.Patch(color='#e74c3c', label='Error')
    gold_patch = mpatches.Patch(edgecolor='gold', facecolor='white',
                                linewidth=2, label='Free (from g)')
    ax1.legend(handles=[green_patch, red_patch, gold_patch],
               loc='upper right', fontsize=9)
    
    # Plot 2: Running accuracy
    ax2 = axes[1]
    n_total = 1000
    running_acc = []
    for n in range(1, n_total + 1):
        errors = sum(1 for i in range(n) if oracle(i) != truth(i))
        running_acc.append(1 - errors / n)
    
    ax2.plot(range(1, n_total + 1), running_acc, 'b-', linewidth=0.8, alpha=0.7)
    ax2.axhline(y=0.95, color='r', linestyle='--', linewidth=1.5, label='95% threshold')
    ax2.axvline(x=420, color='orange', linestyle=':', linewidth=1.5, label='Warm-up (N=420)')
    ax2.fill_between(range(420, n_total + 1),
                     [0.95] * (n_total - 419),
                     [1.0] * (n_total - 419),
                     alpha=0.1, color='green')
    ax2.set_xlabel('Initial segment size n', fontsize=11)
    ax2.set_ylabel('Accuracy', fontsize=11)
    ax2.set_title('Running Accuracy of Sparse Embedding Oracle', fontsize=13)
    ax2.set_ylim(0.9, 1.01)
    ax2.legend(fontsize=10)
    ax2.grid(True, alpha=0.3)
    
    # Plot 3: Comparison of different spacings
    ax3 = axes[2]
    spacings = [5, 10, 15, 21, 30, 50]
    n_eval = 2000
    
    for s in spacings:
        def make_oracle(spacing):
            def o(i):
                if i % spacing == 0:
                    return g(i // spacing)
                return truth(i)
            return o
        
        o_s = make_oracle(s)
        accuracies = []
        check_points = list(range(100, n_eval + 1, 50))
        for n in check_points:
            errors = sum(1 for i in range(n) if o_s(i) != truth(i))
            accuracies.append(1 - errors / n)
        
        ax3.plot(check_points, accuracies, '-', linewidth=1.5,
                 label=f'spacing={s} (max error ≈ {100/s:.1f}%)')
    
    ax3.axhline(y=0.95, color='r', linestyle='--', linewidth=1.5, label='95% threshold')
    ax3.set_xlabel('Initial segment size n', fontsize=11)
    ax3.set_ylabel('Accuracy', fontsize=11)
    ax3.set_title('Accuracy for Different Embedding Spacings', fontsize=13)
    ax3.legend(fontsize=8, ncol=2)
    ax3.grid(True, alpha=0.3)
    ax3.set_ylim(0.75, 1.01)
    
    plt.tight_layout()
    plt.savefig('viz_sparse_embedding.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved viz_sparse_embedding.png")


if __name__ == "__main__":
    main()
