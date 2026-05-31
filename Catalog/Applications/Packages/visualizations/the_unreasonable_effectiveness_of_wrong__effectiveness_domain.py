#!/usr/bin/env python3
"""Visualization: Effectiveness Domain and Error Distribution

Shows how a theory's errors concentrate, leaving most phenomena with small error.
Demonstrates the half-domain theorem.
"""
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def plot_effectiveness():
    """Plot error distribution and effectiveness domain."""
    # Taylor approximation of sin(x)
    n = 50
    x = np.linspace(0, np.pi, n)
    truth = np.sin(x)
    
    orders = [1, 3, 5, 7]
    
    fig, axes = plt.subplots(2, 2, figsize=(14, 10))
    fig.suptitle('Error Distribution of Taylor Approximations to sin(x)\n'
                 'Half-Domain Theorem: at least half the points have error ≤ 2·MSE',
                 fontsize=13, fontweight='bold')
    
    for ax, order in zip(axes.flat, orders):
        # Compute Taylor approximation
        approx = np.zeros_like(x)
        for k in range(order + 1):
            if k % 2 == 1:
                sign = (-1) ** ((k - 1) // 2)
                approx += sign * x ** k / np.math.factorial(k)
        
        sq_errors = (approx - truth) ** 2
        mse = np.mean(sq_errors)
        threshold = 2 * mse
        
        effective = sq_errors <= threshold
        effective_count = np.sum(effective)
        
        # Plot
        colors = ['green' if e else 'red' for e in effective]
        ax.bar(range(n), sq_errors, color=colors, alpha=0.7, width=1.0)
        ax.axhline(y=threshold, color='blue', linestyle='--', linewidth=2,
                   label=f'2·MSE = {threshold:.2e}')
        ax.axhline(y=mse, color='orange', linestyle=':', linewidth=1.5,
                   label=f'MSE = {mse:.2e}')
        
        ax.set_xlabel('Phenomenon index')
        ax.set_ylabel('Squared error')
        ax.set_title(f'Order {order} Taylor: {effective_count}/{n} effective (≥{n//2} guaranteed)')
        ax.legend(fontsize=8)
        ax.set_yscale('log', nonpositive='clip')
        ax.grid(True, alpha=0.3)
    
    plt.tight_layout()
    plt.savefig('effectiveness_plot.png', dpi=150, bbox_inches='tight')
    print("Saved effectiveness_plot.png")


if __name__ == "__main__":
    plot_effectiveness()
