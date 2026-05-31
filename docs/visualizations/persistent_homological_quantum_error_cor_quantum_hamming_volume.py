#!/usr/bin/env python3
"""
Visualization: Quantum Hamming volume and error correction capacity.

Shows how the quantum Hamming volume V(n,t) grows with n and t,
and the resulting bounds on the number of correctable errors.
"""
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
import math


def quantum_hamming_volume(n, t):
    """Sum_{i=0}^{t} 3^i * C(n, i)."""
    return sum(3**i * math.comb(n, i) for i in range(t + 1))


def main():
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))

    # Left: Hamming volume heatmap
    ax = axes[0]
    ns = list(range(5, 51))
    ts = list(range(0, 11))
    data = np.zeros((len(ts), len(ns)))

    for i, t in enumerate(ts):
        for j, n in enumerate(ns):
            v = quantum_hamming_volume(n, t)
            data[i, j] = np.log10(max(v, 1))

    im = ax.imshow(data, aspect='auto', origin='lower',
                   extent=[ns[0], ns[-1], ts[0], ts[-1]],
                   cmap='viridis')
    plt.colorbar(im, ax=ax, label='log₁₀ V(n,t)')
    ax.set_xlabel('n (qubits)', fontsize=12)
    ax.set_ylabel('t (correctable errors)', fontsize=12)
    ax.set_title('Quantum Hamming Volume V(n,t)', fontsize=13)

    # Right: Maximum correctable errors from Hamming bound
    ax2 = axes[1]
    for k in [1, 2, 4, 8, 16]:
        ns_plot = list(range(max(5, k + 2), 201))
        t_max = []
        for n in ns_plot:
            t = 0
            while t <= n and quantum_hamming_volume(n, t) * (2 ** k) <= 2 ** n:
                t += 1
            t_max.append(max(0, t - 1))

        ax2.plot(ns_plot, t_max, label=f'k={k}', linewidth=2)

    ax2.set_xlabel('n (physical qubits)', fontsize=12)
    ax2.set_ylabel('t_max (max correctable errors)', fontsize=12)
    ax2.set_title('Quantum Hamming Bound: Max Correctable Errors', fontsize=13)
    ax2.legend(fontsize=10)
    ax2.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('viz_hamming_volume.png', dpi=150)
    print("Saved viz_hamming_volume.png")


if __name__ == "__main__":
    main()
