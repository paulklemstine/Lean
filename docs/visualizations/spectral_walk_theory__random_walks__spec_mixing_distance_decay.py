#!/usr/bin/env python3
"""
Visualization: Mixing Distance Decay

Shows the exponential decay of mixing distance d(t) = (1-γ)^t · √n
for different cycle graph sizes.
"""

import math

def main():
    try:
        import matplotlib.pyplot as plt
        import numpy as np
    except ImportError:
        print("matplotlib/numpy not available.")
        return

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))

    # Plot 1: Mixing distance decay for different n
    colors = ['#1f77b4', '#ff7f0e', '#2ca02c', '#d62728', '#9467bd']
    for i, n in enumerate([10, 20, 50, 100, 200]):
        gamma = 1 - math.cos(2 * math.pi / n)
        lam2 = 1 - gamma
        max_t = int(3 * n**2)
        ts = np.linspace(0, max_t, 500)
        ds = np.array([lam2**t * math.sqrt(n) for t in ts])
        ax1.semilogy(ts / n**2, ds, color=colors[i], linewidth=1.5,
                     label=f'$C_{{{n}}}$')

    ax1.axhline(y=0.01, color='black', linestyle=':', alpha=0.5,
                label=r'$\epsilon = 0.01$')
    ax1.set_xlabel(r'$t / n^2$', fontsize=12)
    ax1.set_ylabel(r'Mixing distance $d(t)$', fontsize=12)
    ax1.set_title('Mixing Distance Decay (Normalized Time)', fontsize=14)
    ax1.legend(fontsize=10)
    ax1.grid(True, alpha=0.3)

    # Plot 2: Classical vs Quantum relaxation time
    ns = np.arange(5, 501)
    classical = np.array([1.0 / (1 - math.cos(2 * math.pi / n)) for n in ns])
    quantum = np.array([1.0 / math.sqrt(1 - math.cos(2 * math.pi / n)) for n in ns])

    ax2.loglog(ns, classical, 'b-', linewidth=2, label=r'Classical: $1/\gamma$')
    ax2.loglog(ns, quantum, 'r-', linewidth=2, label=r'Quantum: $1/\sqrt{\gamma}$')
    ax2.loglog(ns, ns**2 / (2*np.pi**2), 'b--', alpha=0.4, label=r'$n^2/(2\pi^2)$')
    ax2.loglog(ns, ns / (np.sqrt(2)*np.pi), 'r--', alpha=0.4, label=r'$n/(\sqrt{2}\pi)$')
    ax2.fill_between(ns, quantum, classical, alpha=0.1, color='green')
    ax2.set_xlabel('Number of vertices n', fontsize=12)
    ax2.set_ylabel('Relaxation time', fontsize=12)
    ax2.set_title('Classical vs Quantum Relaxation', fontsize=14)
    ax2.legend(fontsize=10)
    ax2.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('mixing_decay.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved mixing_decay.png")


if __name__ == "__main__":
    main()
