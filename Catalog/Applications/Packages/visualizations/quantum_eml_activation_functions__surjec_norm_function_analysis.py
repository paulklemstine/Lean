#!/usr/bin/env python3
"""
Visualization: Quantum EML Norm Function and Lower Bound

Shows qemlNorm(r) = ‖log(1+ri)‖ alongside its components and the arctan lower bound.
"""
import numpy as np
import matplotlib.pyplot as plt


def qeml_norm(r):
    return np.abs(np.log(1 + r * 1j))


def main():
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))

    r = np.linspace(-20, 20, 1000)
    r_pos = np.linspace(0.01, 20, 500)

    # Panel 1: Norm function and its components
    ax = axes[0]
    norm_vals = qeml_norm(r)
    re_part = 0.5 * np.log(1 + r**2)
    im_part = np.arctan(r)

    ax.plot(r, norm_vals, 'b-', linewidth=2, label='‖log(1+ri)‖ (full norm)')
    ax.plot(r, re_part, 'r--', linewidth=1.5, label='½log(1+r²) (real part)')
    ax.plot(r, np.abs(im_part), 'g-.', linewidth=1.5, label='|arctan(r)| (lower bound)')
    ax.fill_between(r, np.abs(im_part), norm_vals, alpha=0.1, color='blue',
                    label='Gap above bound')
    ax.set_xlabel('r')
    ax.set_ylabel('Value')
    ax.set_title('Quantum EML Norm: Components and Lower Bound')
    ax.legend()
    ax.grid(True, alpha=0.3)
    ax.set_ylim(0, 5)

    # Panel 2: Norm function showing divergence (proves tendsto_atTop)
    ax = axes[1]
    r_large = np.linspace(0, 1000, 2000)
    ax.plot(r_large, qeml_norm(r_large), 'b-', linewidth=2, label='‖log(1+ri)‖')
    ax.plot(r_large, 0.5 * np.log(1 + r_large**2), 'r--', linewidth=1.5,
            label='½log(1+r²) (→ ∞)')
    ax.set_xlabel('r')
    ax.set_ylabel('qemlNorm(r)')
    ax.set_title('Norm Divergence (proves tendsto_atTop)')
    ax.legend()
    ax.grid(True, alpha=0.3)

    plt.suptitle('Quantum EML Norm Analysis', fontsize=14, fontweight='bold')
    plt.tight_layout()
    plt.savefig('Applications/qeml_norm_analysis.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: Applications/qeml_norm_analysis.png")


if __name__ == "__main__":
    main()
