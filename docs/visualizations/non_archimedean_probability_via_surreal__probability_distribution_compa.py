#!/usr/bin/env python3
"""
Visualization: Non-Archimedean vs Archimedean Probability Measures

Creates a figure comparing probability distributions in standard (ℝ-valued)
and non-Archimedean settings, illustrating the key theorems.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np


def plot_archimedean_vs_nonarch():
    """
    Side-by-side comparison of Archimedean and non-Archimedean probability.
    """
    fig, axes = plt.subplots(1, 3, figsize=(16, 5))
    
    # Panel 1: Standard uniform distribution
    ax1 = axes[0]
    n = 6
    weights = [1/n] * n
    labels = [f"$x_{{{i+1}}}$" for i in range(n)]
    colors = ['#3498db'] * n
    ax1.bar(range(n), weights, color=colors, edgecolor='black', linewidth=0.5)
    ax1.axhline(y=1/n, color='red', linestyle='--', alpha=0.7, label=f'1/n = {1/n:.3f}')
    ax1.set_title('Standard Uniform\n(Archimedean)', fontsize=13, fontweight='bold')
    ax1.set_xlabel('Element')
    ax1.set_ylabel('Probability')
    ax1.set_ylim(0, 0.35)
    ax1.set_xticks(range(n))
    ax1.set_xticklabels(labels)
    ax1.legend(fontsize=9)
    ax1.text(2.5, 0.25, f'Total = 1\nAll weights = 1/{n}',
             ha='center', fontsize=10, 
             bbox=dict(boxstyle='round', facecolor='wheat', alpha=0.5))
    
    # Panel 2: Pigeonhole illustration
    ax2 = axes[1]
    # Try to make all weights < 1/n — fails!
    attempt_weights = [1/n - 0.02] * n
    actual_total = sum(attempt_weights)
    gap = 1 - actual_total
    
    ax2.bar(range(n), attempt_weights, color='#e74c3c', alpha=0.6, 
            edgecolor='black', linewidth=0.5, label=f'Attempted: 1/{n} - 0.02')
    ax2.axhline(y=1/n, color='blue', linestyle='--', alpha=0.7, label=f'Threshold 1/{n}')
    ax2.set_title('Pigeonhole Theorem\n(Why ℝ fails)', fontsize=13, fontweight='bold')
    ax2.set_xlabel('Element')
    ax2.set_ylabel('Probability')
    ax2.set_ylim(0, 0.35)
    ax2.set_xticks(range(n))
    ax2.set_xticklabels(labels)
    ax2.legend(fontsize=9, loc='upper right')
    ax2.text(2.5, 0.25, f'Total = {actual_total:.2f} < 1\n⚠ Normalization fails!',
             ha='center', fontsize=10, color='red',
             bbox=dict(boxstyle='round', facecolor='lightyellow', alpha=0.8))
    
    # Panel 3: Non-Archimedean measure with infinitesimal perturbation
    ax3 = axes[2]
    base = 1/n
    perturbations = [0.01, -0.02, 0.01, 0.01, -0.02, 0.01]  # Sum to 0
    nonarch_weights = [base + p for p in perturbations]
    
    bar_colors = ['#2ecc71' if p >= 0 else '#f39c12' for p in perturbations]
    ax3.bar(range(n), nonarch_weights, color=bar_colors, 
            edgecolor='black', linewidth=0.5)
    ax3.axhline(y=1/n, color='red', linestyle='--', alpha=0.7, label=f'1/{n}')
    ax3.set_title('Non-Archimedean Measure\n(ε-perturbations)', fontsize=13, fontweight='bold')
    ax3.set_xlabel('Element')
    ax3.set_ylabel('Probability')
    ax3.set_ylim(0, 0.35)
    ax3.set_xticks(range(n))
    ax3.set_xticklabels([f"$x_{{{i+1}}}$\n$+{p}ε$" if p >= 0 else f"$x_{{{i+1}}}$\n${p}ε$" 
                          for i, p in enumerate(perturbations)])
    ax3.legend(fontsize=9)
    ax3.text(2.5, 0.28, 'Total = 1 ✓\nAll weights ≠ 0 ✓\n(infinitesimal ≠ zero)',
             ha='center', fontsize=9,
             bbox=dict(boxstyle='round', facecolor='lightgreen', alpha=0.5))
    
    plt.tight_layout()
    plt.savefig('nonarch_probability_comparison.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: nonarch_probability_comparison.png")


def plot_conditional_probability_regions():
    """
    Illustrate why conditional probability is always defined in
    non-Archimedean fields but can be undefined in ℝ.
    """
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(12, 5))
    
    # Left: Standard probability — conditioning on P(B)=0 is undefined
    theta = np.linspace(0, 2*np.pi, 100)
    
    # Draw sample space
    ax1.add_patch(plt.Circle((0, 0), 1, fill=False, edgecolor='black', linewidth=2))
    ax1.add_patch(mpatches.FancyBboxPatch((-0.6, -0.3), 0.8, 0.6, 
                                           boxstyle="round,pad=0.05",
                                           facecolor='#3498db', alpha=0.3, 
                                           edgecolor='#2980b9', linewidth=2))
    ax1.plot(0.3, 0.4, 'ro', markersize=12, zorder=5)
    ax1.text(0.3, 0.55, 'B = {point}', ha='center', fontsize=11, fontweight='bold', color='red')
    ax1.text(-0.2, 0, 'A', ha='center', fontsize=14, fontweight='bold', color='#2980b9')
    ax1.text(0, -1.3, 'Standard ℝ-valued', ha='center', fontsize=12, fontweight='bold')
    ax1.text(0, -1.55, 'P(B) = 0 → P(A|B) = 0/0 = ???', ha='center', fontsize=10, color='red')
    ax1.set_xlim(-1.3, 1.3)
    ax1.set_ylim(-1.8, 1.3)
    ax1.set_aspect('equal')
    ax1.axis('off')
    ax1.set_title('Archimedean (ℝ)', fontsize=14, fontweight='bold')
    
    # Right: Non-Archimedean — always defined
    ax2.add_patch(plt.Circle((0, 0), 1, fill=False, edgecolor='black', linewidth=2))
    ax2.add_patch(mpatches.FancyBboxPatch((-0.6, -0.3), 0.8, 0.6,
                                           boxstyle="round,pad=0.05",
                                           facecolor='#3498db', alpha=0.3,
                                           edgecolor='#2980b9', linewidth=2))
    ax2.add_patch(plt.Circle((0.3, 0.4), 0.12, facecolor='#2ecc71', alpha=0.5,
                              edgecolor='#27ae60', linewidth=2, zorder=5))
    ax2.text(0.3, 0.55, 'B = {point}', ha='center', fontsize=11, fontweight='bold', color='#27ae60')
    ax2.text(-0.2, 0, 'A', ha='center', fontsize=14, fontweight='bold', color='#2980b9')
    ax2.text(0, -1.3, 'Non-Archimedean', ha='center', fontsize=12, fontweight='bold')
    ax2.text(0, -1.55, 'P(B) = ε > 0 → P(A|B) = P(A∩B)/ε ✓', ha='center', fontsize=10, color='#27ae60')
    ax2.set_xlim(-1.3, 1.3)
    ax2.set_ylim(-1.8, 1.3)
    ax2.set_aspect('equal')
    ax2.axis('off')
    ax2.set_title('Non-Archimedean (Surreal-valued)', fontsize=14, fontweight='bold')
    
    plt.suptitle('Conditional Probability: Always Defined with Infinitesimals',
                 fontsize=15, fontweight='bold', y=1.02)
    plt.tight_layout()
    plt.savefig('conditional_probability_comparison.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: conditional_probability_comparison.png")


def plot_pigeonhole_bound():
    """
    Plot the pigeonhole lower bound 1/n as a function of n,
    showing how it constrains real-valued probability.
    """
    fig, ax = plt.subplots(figsize=(8, 5))
    
    ns = np.arange(1, 51)
    bounds = 1.0 / ns
    
    ax.plot(ns, bounds, 'b-o', markersize=3, linewidth=1.5, label='Lower bound 1/n')
    ax.fill_between(ns, bounds, 1, alpha=0.1, color='blue', label='Feasible region (ℝ)')
    ax.fill_between(ns, 0, bounds, alpha=0.1, color='red', label='Infeasible in ℝ')
    
    # Annotate
    ax.annotate('For n=10:\nsome P(xᵢ) ≥ 0.1', xy=(10, 0.1), xytext=(20, 0.3),
                arrowprops=dict(arrowstyle='->', color='black'),
                fontsize=10, ha='center',
                bbox=dict(boxstyle='round', facecolor='wheat', alpha=0.5))
    
    ax.set_xlabel('Number of elements (n)', fontsize=12)
    ax.set_ylabel('Minimum point probability', fontsize=12)
    ax.set_title('Archimedean Pigeonhole Theorem:\nMax point probability ≥ 1/n', 
                 fontsize=14, fontweight='bold')
    ax.legend(fontsize=10)
    ax.set_ylim(0, 0.5)
    ax.grid(True, alpha=0.3)
    
    # Add non-Archimedean note
    ax.text(35, 0.02, 'Non-Archimedean:\nall weights can be\ninfinitesimal ε ≈ 0',
            fontsize=9, ha='center', style='italic',
            bbox=dict(boxstyle='round', facecolor='lightgreen', alpha=0.5))
    
    plt.tight_layout()
    plt.savefig('pigeonhole_bound.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: pigeonhole_bound.png")


if __name__ == "__main__":
    plot_archimedean_vs_nonarch()
    plot_conditional_probability_regions()
    plot_pigeonhole_bound()
    print("\nAll visualizations generated.")
