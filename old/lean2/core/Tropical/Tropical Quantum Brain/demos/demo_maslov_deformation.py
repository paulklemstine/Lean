#!/usr/bin/env python3
"""
Maslov Deformation: The Bridge Between Quantum and Tropical
============================================================

Visualizes the one-parameter family of semirings T_β that interpolates
between quantum-like (soft) addition and tropical (hard) max.

The key formula: a ⊕_β b = (1/β) · log(e^{βa} + e^{βb})
  - β → 0:  arithmetic mean (quantum-like)  
  - β = 1:  LogSumExp (softmax / machine learning)
  - β → ∞:  max(a, b) (tropical)

The brain's neuromodulators tune β in real-time.
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.animation as animation
from matplotlib.colors import LinearSegmentedColormap
import os

def maslov_add(a, b, beta):
    """Maslov deformed addition: (1/β) · log(e^{βa} + e^{βb})
    
    Smoothly interpolates: arithmetic mean ←→ softmax ←→ max
    """
    if beta > 50:  # Numerical stability
        return np.maximum(a, b)
    if beta < 0.01:
        return (a + b) / 2
    # Use log-sum-exp trick for numerical stability
    m = np.maximum(a, b)
    return m + np.log(np.exp(beta * (a - m)) + np.exp(beta * (b - m))) / beta

def plot_maslov_convergence():
    """Show how LogSumExp converges to max as β → ∞"""
    fig, axes = plt.subplots(2, 2, figsize=(14, 12))
    fig.suptitle('Maslov Deformation: From Quantum to Tropical', 
                fontsize=16, fontweight='bold')
    
    a = 2.0
    b_vals = np.linspace(-3, 5, 200)
    betas = [0.1, 0.5, 1.0, 2.0, 5.0, 10.0, 50.0]
    
    # Plot 1: LogSumExp for different β
    ax = axes[0, 0]
    colors = plt.cm.plasma(np.linspace(0.1, 0.9, len(betas)))
    for beta, color in zip(betas, colors):
        result = [maslov_add(a, b, beta) for b in b_vals]
        ax.plot(b_vals, result, color=color, linewidth=2, label=f'β={beta}')
    
    # True max
    ax.plot(b_vals, np.maximum(a, b_vals), 'k--', linewidth=3, label='max (β=∞)', alpha=0.7)
    ax.axvline(x=a, color='gray', linestyle=':', alpha=0.5)
    ax.set_xlabel('b')
    ax.set_ylabel(f'a ⊕_β b  (a = {a})')
    ax.set_title('LogSumExp → max as β → ∞')
    ax.legend(fontsize=9)
    ax.grid(alpha=0.3)
    
    # Plot 2: Error bound
    ax = axes[0, 1]
    beta_range = np.linspace(0.1, 20, 200)
    a_test, b_test = 3.0, 1.0
    
    errors = [maslov_add(a_test, b_test, beta) - max(a_test, b_test) for beta in beta_range]
    bound = np.log(2) / beta_range
    
    ax.plot(beta_range, errors, 'b-', linewidth=2, label='Actual error')
    ax.plot(beta_range, bound, 'r--', linewidth=2, label='Upper bound: log(2)/β')
    ax.fill_between(beta_range, 0, bound, alpha=0.1, color='red')
    ax.set_xlabel('β (inverse temperature)')
    ax.set_ylabel('Error: (a ⊕_β b) - max(a,b)')
    ax.set_title('Maslov Sandwich Theorem')
    ax.legend()
    ax.grid(alpha=0.3)
    ax.set_ylim(0, 1.0)
    
    # Plot 3: Softmax as Maslov with β=1
    ax = axes[1, 0]
    x = np.linspace(-5, 5, 200)
    
    for beta in [0.2, 0.5, 1.0, 3.0, 10.0]:
        # Softmax probability of x over (x, 0)
        prob = np.exp(beta * x) / (np.exp(beta * x) + np.exp(beta * 0))
        ax.plot(x, prob, linewidth=2, label=f'β={beta}')
    
    # Step function (β → ∞)
    ax.plot(x, (x > 0).astype(float), 'k--', linewidth=2, label='β=∞ (step)', alpha=0.7)
    
    ax.set_xlabel('x')
    ax.set_ylabel('σ_β(x) = e^{βx} / (e^{βx} + 1)')
    ax.set_title('Softmax → Step Function (Tropical Projection)')
    ax.legend(fontsize=9)
    ax.grid(alpha=0.3)
    ax.axhline(y=0.5, color='gray', linestyle=':', alpha=0.3)
    ax.axvline(x=0, color='gray', linestyle=':', alpha=0.3)
    
    # Plot 4: 2D contour of Maslov addition
    ax = axes[1, 1]
    a_grid = np.linspace(-3, 3, 100)
    b_grid = np.linspace(-3, 3, 100)
    A, B = np.meshgrid(a_grid, b_grid)
    
    # Show the "corner" smoothing
    beta_show = 2.0
    Z = np.vectorize(lambda a, b: maslov_add(a, b, beta_show))(A, B)
    im = ax.contourf(A, B, Z, levels=30, cmap='viridis')
    ax.contour(A, B, Z, levels=15, colors='white', linewidths=0.5, alpha=0.5)
    
    # Mark the tropical "corner" a=b
    ax.plot(a_grid, a_grid, 'r--', linewidth=2, label='a = b (tropical variety)')
    
    ax.set_xlabel('a')
    ax.set_ylabel('b')
    ax.set_title(f'a ⊕_β b (β={beta_show}): Smoothed Tropical Addition')
    plt.colorbar(im, ax=ax)
    ax.legend()
    ax.set_aspect('equal')
    
    plt.tight_layout()
    plt.savefig(os.path.join(os.path.dirname(__file__), 'maslov_deformation.png'), dpi=150, bbox_inches='tight')
    plt.close()
    print("✓ Saved: maslov_deformation.png")

def plot_neural_beta_regimes():
    """Show how different β values correspond to different brain states"""
    fig, axes = plt.subplots(1, 4, figsize=(20, 5))
    fig.suptitle('Neural β Regimes: From Diffuse to Focused', 
                fontsize=16, fontweight='bold')
    
    np.random.seed(42)
    n_neurons = 50
    inputs = np.random.randn(n_neurons) * 2
    
    betas = [0.2, 1.0, 5.0, 50.0]
    titles = [
        'β = 0.2\n"Psychedelic"\nDiffuse, many active',
        'β = 1.0\n"Normal Waking"\nSoft competition',
        'β = 5.0\n"Focused Attention"\nSharp selection',
        'β = 50.0\n"Tunnel Vision"\nWinner-take-all'
    ]
    
    for ax, beta, title in zip(axes, betas, titles):
        # Softmax with temperature
        probs = np.exp(beta * inputs)
        probs = probs / probs.sum()
        
        colors = plt.cm.hot(probs / probs.max())
        ax.bar(range(n_neurons), probs, color=colors, edgecolor='none')
        ax.set_title(title, fontsize=11)
        ax.set_xlabel('Neuron index')
        ax.set_ylabel('Activation probability')
        ax.set_ylim(0, max(probs) * 1.3)
        
        # Entropy
        entropy = -np.sum(probs * np.log(probs + 1e-10))
        ax.text(0.95, 0.95, f'H = {entropy:.2f}', transform=ax.transAxes,
               fontsize=10, va='top', ha='right',
               bbox=dict(boxstyle='round', facecolor='wheat', alpha=0.5))
    
    plt.tight_layout()
    plt.savefig(os.path.join(os.path.dirname(__file__), 'neural_beta_regimes.png'), dpi=150, bbox_inches='tight')
    plt.close()
    print("✓ Saved: neural_beta_regimes.png")

def plot_maslov_phase_diagram():
    """Phase diagram showing the tropical-quantum transition"""
    fig, ax = plt.subplots(figsize=(12, 8))
    
    # Create phase diagram
    beta_range = np.linspace(0.01, 10, 500)
    n_range = np.linspace(1, 20, 500)
    B, N = np.meshgrid(beta_range, n_range)
    
    # "Order parameter": fraction of total probability in top-k neurons
    # For n neurons with random inputs, the expected max grows as √(2 log n)
    # The order parameter is roughly: P(winner) = e^{β·√(2 log N)} / (N · e^{β·0})
    # Simplified: σ = 1 / (1 + (N-1) · e^{-β·√(2 log N)})
    sigma = 1.0 / (1.0 + (N - 1) * np.exp(-B * np.sqrt(2 * np.log(N + 1))))
    
    im = ax.contourf(B, N, sigma, levels=50, cmap='RdYlBu_r')
    
    # Critical line: β_c ≈ log(N) / √(2 log N)
    n_crit = np.linspace(2, 20, 100)
    beta_crit = np.log(n_crit) / np.sqrt(2 * np.log(n_crit))
    ax.plot(beta_crit, n_crit, 'k-', linewidth=3, label='Critical line β_c(N)')
    
    # Annotate regions
    ax.text(1.0, 15, 'QUANTUM-LIKE\n(superposition)\nMany active\nUnconscious?', 
            fontsize=12, ha='center', va='center', color='blue', fontweight='bold',
            bbox=dict(boxstyle='round', facecolor='white', alpha=0.8))
    ax.text(7.0, 15, 'TROPICAL\n(winner-take-all)\nSingle winner\nAutomatic?',
            fontsize=12, ha='center', va='center', color='red', fontweight='bold',
            bbox=dict(boxstyle='round', facecolor='white', alpha=0.8))
    ax.text(3.5, 8, 'CRITICAL\nCONSCIOUS?',
            fontsize=14, ha='center', va='center', color='darkgreen', fontweight='bold',
            bbox=dict(boxstyle='round', facecolor='yellow', alpha=0.6))
    
    ax.set_xlabel('β (neural gain / inverse temperature)', fontsize=13)
    ax.set_ylabel('N (number of competing representations)', fontsize=13)
    ax.set_title('Phase Diagram: Tropical-Quantum Transition in Neural Networks',
                fontsize=15, fontweight='bold')
    plt.colorbar(im, ax=ax, label='Order parameter σ (winner dominance)')
    ax.legend(fontsize=12)
    
    plt.tight_layout()
    plt.savefig(os.path.join(os.path.dirname(__file__), 'maslov_phase_diagram.png'), dpi=150, bbox_inches='tight')
    plt.close()
    print("✓ Saved: maslov_phase_diagram.png")

if __name__ == '__main__':
    print("=" * 60)
    print("MASLOV DEFORMATION: Quantum → Tropical Bridge")
    print("=" * 60)
    print()
    
    plot_maslov_convergence()
    plot_neural_beta_regimes()
    plot_maslov_phase_diagram()
    
    print()
    print("All visualizations saved!")
    print("Key formula: a ⊕_β b = (1/β)·log(e^{βa} + e^{βb})")
    print("  β → 0:  quantum-like (soft, diffuse)")
    print("  β = 1:  softmax (machine learning)")
    print("  β → ∞:  tropical max (winner-take-all)")
