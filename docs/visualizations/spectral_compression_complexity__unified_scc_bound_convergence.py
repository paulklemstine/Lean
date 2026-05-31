"""
Visualization: SCC Bound Convergence

Shows that the SCC generalization bound converges to zero as n → ∞,
verifying the consistency theorem for different network configurations.
"""

import math
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def scc_bound(scc_val, n, delta):
    """Compute sqrt(SCC * log(2n)/n + log(1/delta)/n)."""
    inner = scc_val * math.log(2*n) / n + math.log(1/delta) / n
    return math.sqrt(max(0, inner))


def main():
    delta = 0.05
    n_values = np.logspace(1.5, 6, 300).astype(int)
    n_values = sorted(set(n_values))

    fig, axes = plt.subplots(1, 2, figsize=(12, 5))

    # Plot 1: Bound vs n for different SCC values
    ax = axes[0]
    scc_configs = [
        (100, '#2196F3', 'SCC = 100 (shallow, wide)'),
        (1000, '#FF9800', 'SCC = 1,000'),
        (10000, '#FF5722', 'SCC = 10,000'),
        (80000, '#9C27B0', 'SCC = 80,000 (deep, narrow)'),
    ]

    for scc_val, color, label in scc_configs:
        bounds = [scc_bound(scc_val, n, delta) for n in n_values]
        ax.plot(n_values, bounds, color=color, linewidth=2, label=label)

    ax.set_xlabel('Sample Size n', fontsize=12)
    ax.set_ylabel('Generalization Bound', fontsize=12)
    ax.set_title('SCC Bound Convergence to Zero', fontsize=13)
    ax.set_xscale('log')
    ax.set_yscale('log')
    ax.legend(fontsize=9)
    ax.grid(True, alpha=0.3)

    # Add O(1/sqrt(n)) reference line
    ref_n = np.array(n_values)
    ref = 50 / np.sqrt(ref_n)
    ax.plot(ref_n, ref, 'k--', alpha=0.3, linewidth=1, label='O(1/√n)')
    ax.legend(fontsize=9)

    # Plot 2: Bound² × n (should converge to SCC × ln(2))
    ax = axes[1]
    for scc_val, color, label in scc_configs:
        convergence = [scc_bound(scc_val, n, delta)**2 * n for n in n_values]
        ax.plot(n_values, convergence, color=color, linewidth=2, label=label)
        # Reference line
        ax.axhline(y=scc_val * math.log(2), color=color, linestyle='--',
                   alpha=0.4, linewidth=1)

    ax.set_xlabel('Sample Size n', fontsize=12)
    ax.set_ylabel('Bound² × n', fontsize=12)
    ax.set_title('Asymptotic Rate (→ SCC × ln 2)', fontsize=13)
    ax.set_xscale('log')
    ax.set_yscale('log')
    ax.legend(fontsize=9)
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('viz_convergence.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved viz_convergence.png")


if __name__ == "__main__":
    main()
