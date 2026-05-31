#!/usr/bin/env python3
"""Visualization: Wrong Theory Superiority

Shows how a globally worse theory can be locally superior,
demonstrating the wrong_theory_local_superiority theorem.
"""
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def plot_superiority():
    """Plot theory comparison showing local superiority of 'wrong' theory."""
    n = 100
    x = np.linspace(0, 2 * np.pi, n)
    truth = np.sin(x)
    
    # Theory A: constant zero (simple, globally decent)
    theory_a = np.zeros_like(x)
    
    # Theory B: 5th order Taylor (great near 0, terrible far away)
    theory_b = x - x**3/6 + x**5/120
    
    err_a = (theory_a - truth) ** 2
    err_b = (theory_b - truth) ** 2
    
    mse_a = np.mean(err_a)
    mse_b = np.mean(err_b)
    
    fig, axes = plt.subplots(3, 1, figsize=(12, 12))
    fig.suptitle('Wrong Theory Local Superiority\n'
                 'A globally worse theory can outperform on specific subdomains',
                 fontsize=14, fontweight='bold')
    
    # Panel 1: Predictions vs truth
    ax = axes[0]
    ax.plot(x, truth, 'k-', linewidth=2, label='Truth: sin(x)')
    ax.plot(x, theory_a, 'b--', linewidth=1.5, label=f'Theory A: 0 (MSE={mse_a:.3f})')
    ax.plot(x, theory_b, 'r--', linewidth=1.5, label=f'Theory B: Taylor-5 (MSE={mse_b:.3f})')
    ax.set_ylabel('Value')
    ax.set_title('Predictions')
    ax.legend()
    ax.grid(True, alpha=0.3)
    
    # Panel 2: Squared errors
    ax = axes[1]
    ax.semilogy(x, err_a + 1e-20, 'b-', linewidth=1.5, label='Error: Theory A', alpha=0.8)
    ax.semilogy(x, err_b + 1e-20, 'r-', linewidth=1.5, label='Error: Theory B', alpha=0.8)
    ax.set_ylabel('Squared Error (log scale)')
    ax.set_title('Error Comparison')
    ax.legend()
    ax.grid(True, alpha=0.3)
    
    # Panel 3: Which theory wins at each point
    ax = axes[2]
    b_wins = err_b < err_a
    a_wins = err_a < err_b
    ax.fill_between(x, 0, 1, where=b_wins, color='red', alpha=0.4,
                    label=f'Theory B better ({np.sum(b_wins)}/{n} points)')
    ax.fill_between(x, 0, 1, where=a_wins, color='blue', alpha=0.4,
                    label=f'Theory A better ({np.sum(a_wins)}/{n} points)')
    ax.set_xlabel('x')
    ax.set_ylabel('Superiority Domain')
    ax.set_title('Domain Partition: Who Wins Where?')
    ax.legend()
    ax.set_yticks([])
    ax.grid(True, alpha=0.3)
    
    plt.tight_layout()
    plt.savefig('superiority_plot.png', dpi=150, bbox_inches='tight')
    print("Saved superiority_plot.png")


if __name__ == "__main__":
    plot_superiority()
