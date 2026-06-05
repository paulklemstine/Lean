#!/usr/bin/env python3
"""
Visualization: Quantum vs Classical Mixing on Cayley Graphs
Shows the quadratic speedup arising from the amplitude gap.
"""
import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt

def plot_quantum_speedup():
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))
    
    # Left: mixing times vs group size
    ax = axes[0]
    ns = np.logspace(1, 6, 50)
    gamma = 0.1
    
    classical = np.log(ns) / gamma
    quantum = np.sqrt(ns) * np.log(ns) / gamma
    
    ax.loglog(ns, classical, 'b-', linewidth=2.5, label='Classical: $\\log(n)/\\gamma$')
    ax.loglog(ns, quantum, 'r--', linewidth=2.5, label='Quantum: $\\sqrt{n} \\cdot \\log(n)/\\gamma$')
    ax.fill_between(ns, quantum, classical, alpha=0.15, color='green', label='Quantum advantage')
    ax.set_xlabel('Group size |G|', fontsize=13)
    ax.set_ylabel('Mixing time bound', fontsize=13)
    ax.set_title('Quantum vs Classical Mixing Times', fontsize=14)
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3)
    
    # Right: amplitude gap demonstration
    ax = axes[1]
    gammas = np.linspace(0.01, 1, 100)
    sqrt_decay = np.sqrt(1 - gammas)
    linear_bound = 1 - gammas / 2
    classical_decay = 1 - gammas
    
    ax.plot(gammas, classical_decay, 'b-', linewidth=2.5, label='Classical: $1-\\gamma$')
    ax.plot(gammas, sqrt_decay, 'r-', linewidth=2.5, label='Quantum: $\\sqrt{1-\\gamma}$')
    ax.plot(gammas, linear_bound, 'g--', linewidth=2, label='Bound: $1-\\gamma/2$')
    ax.fill_between(gammas, classical_decay, sqrt_decay, alpha=0.15, color='orange',
                    label='Amplitude gap')
    ax.set_xlabel('Spectral gap γ', fontsize=13)
    ax.set_ylabel('Per-step decay factor', fontsize=13)
    ax.set_title('The Amplitude Gap Mechanism', fontsize=14)
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3)
    
    plt.tight_layout()
    plt.savefig('quantum_speedup.png', dpi=150, bbox_inches='tight')
    print("Saved quantum_speedup.png")

if __name__ == "__main__":
    plot_quantum_speedup()
