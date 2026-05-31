#!/usr/bin/env python3
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np

def main():
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))
    ax1 = axes[0]
    depths = np.arange(0, 13)
    for eps0, color, label in [(0.5, '#e74c3c', 'ε₀=0.5'), (0.3, '#3498db', 'ε₀=0.3'), (0.1, '#2ecc71', 'ε₀=0.1')]:
        errors = [eps0 ** (1.5 ** n) for n in depths]
        ax1.semilogy(depths, errors, 'o-', color=color, label=label, linewidth=2)
    ax1.set_xlabel('SK Depth n'); ax1.set_ylabel('Error'); ax1.set_title('SK Convergence'); ax1.legend(); ax1.grid(True, alpha=0.3)
    ax2 = axes[1]
    L = np.linspace(0.1, 50, 200)
    for gap, color, label in [(0.2, '#e74c3c', 'Δ=0.2'), (0.5, '#3498db', 'Δ=0.5'), (1.0, '#2ecc71', 'Δ=1.0')]:
        ax2.semilogy(L, np.exp(-gap*L), color=color, label=label, linewidth=2)
    ax2.set_xlabel('System Size L'); ax2.set_ylabel('Error'); ax2.set_title('Topological Protection'); ax2.legend(); ax2.grid(True, alpha=0.3)
    plt.tight_layout(); plt.savefig('sk_convergence.png', dpi=150)

if __name__ == '__main__': main()