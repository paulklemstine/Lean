#!/usr/bin/env python3
"""
Visualization: EML Depth Spectrum and Information Decay

Produces two plots:
1. Iterated exponential growth with depth annotations
2. Information-theoretic decay under different contraction rates
"""

import math

def main():
    try:
        import matplotlib
        matplotlib.use('Agg')
        import matplotlib.pyplot as plt
    except ImportError:
        print("matplotlib not available, skipping visualization")
        return

    fig, axes = plt.subplots(1, 2, figsize=(14, 5))

    # ---- Plot 1: Iterated exponential values ----
    ax1 = axes[0]
    xs = [i * 0.05 for i in range(21)]  # [0, 1] in steps of 0.05
    for n in range(5):
        ys = []
        for x in xs:
            try:
                val = x
                for _ in range(n):
                    val = math.exp(val)
                if val > 1e6:
                    val = float('nan')
            except OverflowError:
                val = float('nan')
            ys.append(val)
        label = f'E_{n}(x)' if n > 0 else 'E₀(x) = x'
        ax1.plot(xs, ys, label=label, linewidth=2)

    ax1.set_xlabel('x', fontsize=12)
    ax1.set_ylabel('E_n(x)', fontsize=12)
    ax1.set_title('Iterated Exponentials: transDepth = n', fontsize=13)
    ax1.set_ylim(0, 50)
    ax1.legend(fontsize=10)
    ax1.grid(True, alpha=0.3)

    # Add annotations
    ax1.annotate('Each exp() layer\nadds transDepth +1',
                xy=(0.6, 15), fontsize=9,
                bbox=dict(boxstyle='round', facecolor='lightyellow', alpha=0.8))

    # ---- Plot 2: Information decay ----
    ax2 = axes[1]
    K = 100
    depths = list(range(21))
    alphas = [0.95, 0.8, 0.6, 0.4, 0.2]
    colors = ['#e41a1c', '#ff7f00', '#4daf4a', '#377eb8', '#984ea3']

    for alpha, color in zip(alphas, colors):
        infos = [alpha**l * K for l in depths]
        ax2.plot(depths, infos, 'o-', color=color, label=f'α = {alpha}',
                markersize=3, linewidth=1.5)

    ax2.set_xlabel('Depth (layers)', fontsize=12)
    ax2.set_ylabel('Retained Information', fontsize=12)
    ax2.set_title(f'Information Decay: I(α,l) = α^l × K,  K={K}', fontsize=13)
    ax2.legend(fontsize=10)
    ax2.grid(True, alpha=0.3)
    ax2.set_ylim(0, 105)

    # Add theorem reference
    ax2.annotate('retainedInfo_geometric_decay:\nI(α,l) ≤ α·K for l ≥ 1',
                xy=(10, 70), fontsize=9,
                bbox=dict(boxstyle='round', facecolor='lightyellow', alpha=0.8))

    plt.tight_layout()
    plt.savefig('eml_depth_spectrum.png', dpi=150, bbox_inches='tight')
    print("Saved: eml_depth_spectrum.png")
    plt.close()


if __name__ == "__main__":
    main()
