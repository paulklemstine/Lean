"""
Visualization: Tropical Interleaving Distance — Strict Gap Phenomenon

This script visualizes the core mathematical discovery: the strict gap
between pointwise (barcode) distance and interleaving distance for
tropical persistence modules. It shows step modules, their shifts,
and why interleaving requires larger shifts than pointwise comparison.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def step_module_val(k, i):
    """Step module at k: 0 for i <= k, 1 for i > k."""
    return 0 if i <= k else 1


def plot_interleaving_gap():
    fig, axes = plt.subplots(2, 2, figsize=(14, 10))

    # Panel 1: Two step modules showing the gap
    ax = axes[0, 0]
    xs = np.arange(-2, 8)
    m_vals = [step_module_val(0, i) for i in xs]
    n_vals = [step_module_val(2, i) for i in xs]

    ax.step(xs, m_vals, where='post', linewidth=2.5, color='#2196F3', label='M = step(0)')
    ax.step(xs, n_vals, where='post', linewidth=2.5, color='#FF5722', label='N = step(2)')

    # Highlight the gap region
    for i in range(1, 3):
        ax.annotate('', xy=(i, 0), xytext=(i, 1),
                    arrowprops=dict(arrowstyle='<->', color='#4CAF50', lw=2))
    ax.text(1.5, 0.5, '|M-N|=1', ha='center', fontsize=11, color='#4CAF50', fontweight='bold')

    ax.set_xlabel('Index i', fontsize=12)
    ax.set_ylabel('Value', fontsize=12)
    ax.set_title('Step Modules: Pointwise Distance = 1', fontsize=13, fontweight='bold')
    ax.legend(fontsize=11, loc='upper left')
    ax.set_ylim(-0.3, 1.6)
    ax.grid(True, alpha=0.3)

    # Panel 2: Why δ=1 interleaving fails
    ax = axes[0, 1]
    n_shifted_1 = [step_module_val(2, i + 1) for i in xs]

    ax.step(xs, m_vals, where='post', linewidth=2.5, color='#2196F3', label='M = step(0)')
    ax.step(xs, n_shifted_1, where='post', linewidth=2, color='#FF5722',
            linestyle='--', label='N shifted by δ=1')

    ax.annotate('M(1)=1 > N(2)=0\nFAILS!', xy=(1, 1), xytext=(2.5, 1.3),
                fontsize=11, color='red', fontweight='bold',
                arrowprops=dict(arrowstyle='->', color='red', lw=2))

    ax.set_xlabel('Index i', fontsize=12)
    ax.set_ylabel('Value', fontsize=12)
    ax.set_title('δ=1 Interleaving FAILS', fontsize=13, fontweight='bold', color='red')
    ax.legend(fontsize=11, loc='upper left')
    ax.set_ylim(-0.3, 1.8)
    ax.grid(True, alpha=0.3)

    # Panel 3: δ=2 interleaving succeeds
    ax = axes[1, 0]
    n_shifted_2 = [step_module_val(2, i + 2) for i in xs]
    m_shifted_2 = [step_module_val(0, i + 2) for i in xs]

    ax.step(xs, m_vals, where='post', linewidth=2.5, color='#2196F3', label='M')
    ax.step(xs, n_shifted_2, where='post', linewidth=2, color='#FF5722',
            linestyle='--', label='N(·+2)')

    ax.fill_between(xs, m_vals, n_shifted_2, alpha=0.15, color='green',
                     step='post')
    ax.set_xlabel('Index i', fontsize=12)
    ax.set_ylabel('Value', fontsize=12)
    ax.set_title('δ=2 Interleaving SUCCEEDS ✓', fontsize=13, fontweight='bold', color='green')
    ax.legend(fontsize=11, loc='upper left')
    ax.set_ylim(-0.3, 1.6)
    ax.grid(True, alpha=0.3)
    ax.text(3, 0.3, 'M(i) ≤ N(i+2) ∀i', fontsize=11, color='green', fontweight='bold')

    # Panel 4: Ratio d_I/d_B for step modules
    ax = axes[1, 1]
    ks = list(range(1, 21))
    ratios = [k / 1.0 for k in ks]  # d_I = k, d_B = 1

    ax.bar(ks, ratios, color='#9C27B0', alpha=0.7, edgecolor='#7B1FA2')
    ax.axhline(y=1, color='gray', linestyle='--', alpha=0.5, label='d_I = d_B')
    ax.set_xlabel('Gap k = step position difference', fontsize=12)
    ax.set_ylabel('Ratio d_I / d_B', fontsize=12)
    ax.set_title('Ratio Grows Unboundedly', fontsize=13, fontweight='bold')
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3)

    plt.suptitle('Tropical Interleaving Distance: The Strict Gap Phenomenon',
                 fontsize=15, fontweight='bold', y=1.02)
    plt.tight_layout()
    plt.savefig('viz_interleaving.png', dpi=150, bbox_inches='tight')
    print("Saved viz_interleaving.png")


if __name__ == "__main__":
    plot_interleaving_gap()
