#!/usr/bin/env python3
"""
Visualization: Non-Archimedean Probability Weight Distribution

Shows how uniform probability weights scale with set size, and
the impossibility of infinitesimal sums reaching 1.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np

def plot_weight_scaling():
    """Plot how uniform weight 1/n decreases with n."""
    fig, axes = plt.subplots(1, 2, figsize=(14, 5))
    
    # Left: weight vs n
    n_values = np.arange(1, 101)
    weights = 1.0 / n_values
    
    axes[0].plot(n_values, weights, 'b-', linewidth=2)
    axes[0].axhline(y=0, color='r', linestyle='--', alpha=0.5, label='Infinitesimal boundary')
    axes[0].set_xlabel('Number of elements (n)', fontsize=12)
    axes[0].set_ylabel('Uniform weight (1/n)', fontsize=12)
    axes[0].set_title('Weight Scaling: Never Reaches Zero', fontsize=14)
    axes[0].legend(fontsize=10)
    axes[0].set_ylim(-0.05, 1.05)
    axes[0].grid(True, alpha=0.3)
    
    # Add annotation
    axes[0].annotate(
        'For any finite n,\n1/n > 0 (not infinitesimal)',
        xy=(50, 0.02), xytext=(60, 0.4),
        arrowprops=dict(arrowstyle='->', color='red'),
        fontsize=11, color='red',
        bbox=dict(boxstyle='round,pad=0.3', facecolor='lightyellow')
    )
    
    # Right: sum of k copies of epsilon vs k
    k_values = np.arange(1, 201)
    
    for eps_inv in [10, 50, 200, 1000]:
        eps = 1.0 / eps_inv
        sums = k_values * eps
        valid = sums < 1
        axes[1].plot(k_values[valid], sums[valid], linewidth=2,
                     label=f'ε = 1/{eps_inv}')
    
    axes[1].axhline(y=1, color='red', linestyle='--', linewidth=2, label='Target = 1')
    axes[1].set_xlabel('Number of terms (k)', fontsize=12)
    axes[1].set_ylabel('Partial sum (k·ε)', fontsize=12)
    axes[1].set_title('Infinitesimal Sums: Cannot Reach 1', fontsize=14)
    axes[1].legend(fontsize=9, loc='upper left')
    axes[1].set_ylim(-0.05, 1.2)
    axes[1].grid(True, alpha=0.3)
    
    plt.tight_layout()
    plt.savefig('weight_scaling.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: weight_scaling.png")

def plot_conditional_probability():
    """Visualize conditional probability as weight reallocation."""
    fig, axes = plt.subplots(1, 3, figsize=(15, 4))
    
    n = 10
    uniform_weights = np.ones(n) / n
    
    # Original measure
    colors = ['steelblue'] * n
    axes[0].bar(range(n), uniform_weights, color=colors, edgecolor='navy', linewidth=0.5)
    axes[0].set_title('Original Measure μ', fontsize=13)
    axes[0].set_ylabel('Weight', fontsize=11)
    axes[0].set_ylim(0, 0.35)
    axes[0].set_xlabel('Element', fontsize=11)
    
    # Conditioning set B = {3, 4, 5, 6}
    B = {3, 4, 5, 6}
    cond_weights = np.zeros(n)
    p_B = sum(uniform_weights[i] for i in B)
    for i in range(n):
        if i in B:
            cond_weights[i] = uniform_weights[i] / p_B
    
    colors2 = ['lightgray' if i not in B else 'coral' for i in range(n)]
    axes[1].bar(range(n), cond_weights, color=colors2, edgecolor='darkred', linewidth=0.5)
    axes[1].set_title('Conditional μ(·|B), B={3,4,5,6}', fontsize=13)
    axes[1].set_ylim(0, 0.35)
    axes[1].set_xlabel('Element', fontsize=11)
    
    # Verify total mass
    for ax in axes[:2]:
        ax.axhline(y=1/n, color='gray', linestyle=':', alpha=0.5)
    
    # Chain rule visualization
    A = {2, 3, 4}
    bar_data = {
        'P(A∩B)': sum(uniform_weights[i] for i in A & B),
        'P(A|B)·P(B)': sum(cond_weights[i] for i in A) * p_B,
    }
    
    colors3 = ['coral', 'steelblue']
    bars = axes[2].bar(range(len(bar_data)), list(bar_data.values()),
                       color=colors3, edgecolor='black', linewidth=0.5)
    axes[2].set_xticks(range(len(bar_data)))
    axes[2].set_xticklabels(list(bar_data.keys()), fontsize=10)
    axes[2].set_title('Chain Rule Verification', fontsize=13)
    axes[2].set_ylabel('Value', fontsize=11)
    
    # Add value labels
    for bar, val in zip(bars, bar_data.values()):
        axes[2].text(bar.get_x() + bar.get_width()/2, bar.get_height() + 0.005,
                     f'{val:.4f}', ha='center', fontsize=10, fontweight='bold')
    
    plt.tight_layout()
    plt.savefig('conditional_probability.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: conditional_probability.png")

def plot_markov_inequality():
    """Visualize Markov's inequality."""
    fig, ax = plt.subplots(figsize=(10, 5))
    
    n = 50
    weights = np.ones(n) / n
    values = np.arange(n, dtype=float)
    
    E_f = np.sum(weights * values)
    
    c_values = np.linspace(1, 45, 100)
    actual_probs = [np.sum(weights[values >= c]) for c in c_values]
    markov_bounds = [E_f / c for c in c_values]
    
    ax.fill_between(c_values, actual_probs, alpha=0.3, color='steelblue', label='P(f ≥ c)')
    ax.plot(c_values, actual_probs, 'b-', linewidth=2)
    ax.plot(c_values, markov_bounds, 'r--', linewidth=2, label='E[f]/c (Markov bound)')
    
    ax.set_xlabel('Threshold c', fontsize=12)
    ax.set_ylabel('Probability', fontsize=12)
    ax.set_title("Markov's Inequality: P(f ≥ c) ≤ E[f]/c", fontsize=14)
    ax.legend(fontsize=12)
    ax.grid(True, alpha=0.3)
    ax.set_ylim(0, 1.1)
    
    # Annotate
    ax.annotate(f'E[f] = {E_f:.1f}', xy=(E_f, 0.5), fontsize=11,
                bbox=dict(boxstyle='round', facecolor='lightyellow'))
    
    plt.tight_layout()
    plt.savefig('markov_inequality.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: markov_inequality.png")

if __name__ == "__main__":
    plot_weight_scaling()
    plot_conditional_probability()
    plot_markov_inequality()
    print("\nAll visualizations generated successfully.")
