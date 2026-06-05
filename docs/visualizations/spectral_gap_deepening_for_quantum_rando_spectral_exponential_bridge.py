#!/usr/bin/env python3
"""
Visualization: Spectral-Exponential Bridge
(1-γ)^t ≤ exp(-γt) ≤ (1-γ/2)^t

Shows how the discrete spectral gap connects to continuous exponential decay.
"""
import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt

def plot_spectral_bridge():
    fig, axes = plt.subplots(1, 3, figsize=(15, 5))
    
    gammas = [0.1, 0.3, 0.7]
    t_vals = np.arange(0, 50, 1)
    
    for ax, gamma in zip(axes, gammas):
        lower = [(1 - gamma)**t for t in t_vals]
        middle = [np.exp(-gamma * t) for t in t_vals]
        upper = [(1 - gamma/2)**t for t in t_vals]
        
        ax.semilogy(t_vals, lower, 'b-', linewidth=2, label=f'$(1-\\gamma)^t$')
        ax.semilogy(t_vals, middle, 'r--', linewidth=2, label=f'$e^{{-\\gamma t}}$')
        ax.semilogy(t_vals, upper, 'g-.', linewidth=2, label=f'$(1-\\gamma/2)^t$')
        
        ax.fill_between(t_vals, lower, upper, alpha=0.1, color='purple')
        ax.set_xlabel('Steps (t)', fontsize=12)
        ax.set_ylabel('Decay', fontsize=12)
        ax.set_title(f'γ = {gamma}', fontsize=14)
        ax.legend(fontsize=10)
        ax.grid(True, alpha=0.3)
        ax.set_ylim(1e-8, 2)
    
    fig.suptitle('Spectral-Exponential Bridge: Sandwiching the Decay', fontsize=16, y=1.02)
    plt.tight_layout()
    plt.savefig('spectral_bridge.png', dpi=150, bbox_inches='tight')
    print("Saved spectral_bridge.png")

if __name__ == "__main__":
    plot_spectral_bridge()
