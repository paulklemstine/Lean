#!/usr/bin/env python3
"""
Visualization: q-Casimir Spectrum for Various q Values

Plots the q-Casimir eigenvalues lambda_n = [n]_q * [n+1]_q as a function of n
for several values of q, showing the transition from polynomial growth (q=1)
to exponential growth (q>1).
"""

import math


def q_integer(q, n):
    if n == 0:
        return 0.0
    if abs(q - 1.0) < 1e-15:
        return float(n)
    return (q**n - 1.0) / (q - 1.0)


def q_casimir(q, n):
    return q_integer(q, n) * q_integer(q, n + 1)


def spectral_gap(q, n):
    return q_casimir(q, n + 1) - q_casimir(q, n)


def main():
    try:
        import matplotlib
        matplotlib.use('Agg')
        import matplotlib.pyplot as plt
    except ImportError:
        print("matplotlib not available, skipping visualization")
        return

    fig, axes = plt.subplots(2, 2, figsize=(14, 10))

    q_values = [1.0, 1.2, 1.5, 2.0]
    colors = ['#2196F3', '#FF9800', '#4CAF50', '#E91E63']
    N = 15

    # Plot 1: Casimir eigenvalues
    ax = axes[0, 0]
    for q, color in zip(q_values, colors):
        ns = list(range(N))
        lambdas = [q_casimir(q, n) for n in ns]
        ax.plot(ns, lambdas, 'o-', color=color, label=f'q = {q}', markersize=4)
    ax.set_xlabel('n (representation label)')
    ax.set_ylabel('λ_n (Casimir eigenvalue)')
    ax.set_title('q-Casimir Eigenvalues')
    ax.legend()
    ax.set_yscale('log')
    ax.grid(True, alpha=0.3)

    # Plot 2: Spectral gaps
    ax = axes[0, 1]
    for q, color in zip(q_values, colors):
        ns = list(range(N - 1))
        gaps = [spectral_gap(q, n) for n in ns]
        ax.plot(ns, gaps, 's-', color=color, label=f'q = {q}', markersize=4)
    ax.set_xlabel('n')
    ax.set_ylabel('Δ_n (spectral gap)')
    ax.set_title('Spectral Gaps Δ_n = λ_{n+1} - λ_n')
    ax.legend()
    ax.set_yscale('log')
    ax.grid(True, alpha=0.3)

    # Plot 3: q-integers
    ax = axes[1, 0]
    for q, color in zip(q_values, colors):
        ns = list(range(1, N + 1))
        qints = [q_integer(q, n) for n in ns]
        ax.plot(ns, qints, '^-', color=color, label=f'q = {q}', markersize=4)
    ax.set_xlabel('n')
    ax.set_ylabel('[n]_q')
    ax.set_title('q-Integers [n]_q')
    ax.legend()
    ax.grid(True, alpha=0.3)

    # Plot 4: Gap ratios (Lyapunov exponent convergence)
    ax = axes[1, 1]
    N_lyap = 30
    for q, color in zip([1.2, 1.5, 2.0, 3.0], colors):
        ns = list(range(2, N_lyap))
        gaps = [spectral_gap(q, n) for n in range(N_lyap)]
        ratios = [math.log(gaps[n]) / n for n in ns if gaps[n] > 0]
        expected = 2 * math.log(q)
        ax.plot(ns[:len(ratios)], ratios, '-', color=color,
                label=f'q={q}, 2ln(q)={expected:.3f}', linewidth=1.5)
        ax.axhline(y=expected, color=color, linestyle='--', alpha=0.5)
    ax.set_xlabel('n')
    ax.set_ylabel('(1/n) · ln(Δ_n)')
    ax.set_title('Lyapunov Exponent Convergence')
    ax.legend(fontsize=8)
    ax.grid(True, alpha=0.3)

    plt.suptitle('Quantum Group Casimir Spectrum Analysis', fontsize=14, fontweight='bold')
    plt.tight_layout()
    plt.savefig('spectrum_analysis.png', dpi=150, bbox_inches='tight')
    print("Saved spectrum_analysis.png")


if __name__ == "__main__":
    main()
