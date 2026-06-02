#!/usr/bin/env python3
"""
Visualization 3: Tropical Birkhoff Contraction

Demonstrates the oscillation contraction property of scrambling tropical
matrices, testing the Birkhoff contraction conjecture.
"""

import numpy as np
import matplotlib.pyplot as plt


def trop_mv(A, x):
    n = A.shape[0]
    return np.array([np.max(A[i, :] + x) for i in range(n)])


def oscillation(x):
    return float(np.max(x) - np.min(x))


def main():
    A = np.array([[0, -1, -2],
                  [-2, 0, -1],
                  [-1, -2, 0]], dtype=float)

    # Theoretical prediction
    diam = 2.0
    tau_predicted = np.tanh(diam / 4)

    np.random.seed(123)
    n_samples = 5000
    ratios = []

    for _ in range(n_samples):
        x = np.random.randn(3) * 10
        osc_x = oscillation(x)
        if osc_x < 1e-12:
            continue
        y = trop_mv(A, x)
        osc_y = oscillation(y)
        ratios.append(osc_y / osc_x)

    ratios = np.array(ratios)

    # Also track oscillation over iterated application
    x0 = np.array([10.0, 0.0, -5.0])
    n_iters = 50
    oscs = [oscillation(x0)]
    x_curr = x0.copy()
    for _ in range(n_iters):
        x_curr = trop_mv(A, x_curr)
        oscs.append(oscillation(x_curr))

    fig, axes = plt.subplots(1, 2, figsize=(14, 6))

    # Left: histogram of contraction ratios
    ax1 = axes[0]
    ax1.hist(ratios, bins=50, density=True, alpha=0.7, color='steelblue',
             edgecolor='white', linewidth=0.5)
    ax1.axvline(x=tau_predicted, color='red', linestyle='--', linewidth=2,
                label=f'Predicted τ = tanh(1/2) ≈ {tau_predicted:.4f}')
    ax1.axvline(x=np.max(ratios), color='orange', linestyle='-', linewidth=2,
                label=f'Max observed ≈ {np.max(ratios):.4f}')
    ax1.axvline(x=1.0, color='black', linestyle=':', linewidth=1.5,
                label='Non-expansive bound = 1')
    ax1.set_xlabel('osc(A⊗x) / osc(x)', fontsize=12)
    ax1.set_ylabel('Density', fontsize=12)
    ax1.set_title('Birkhoff Contraction Ratios', fontsize=14, fontweight='bold')
    ax1.legend(fontsize=10)
    ax1.grid(True, alpha=0.3)

    # Right: oscillation decay under iteration
    ax2 = axes[1]
    iters = range(n_iters + 1)
    ax2.semilogy(iters, oscs, 'b-o', markersize=3, linewidth=1.5,
                 label='osc(A^⊗n ⊗ x₀)')
    # Predicted decay: osc_0 * tau^n
    predicted_decay = [oscs[0] * tau_predicted**n for n in iters]
    ax2.semilogy(iters, predicted_decay, 'r--', linewidth=2,
                 label=f'Predicted: osc₀ · τⁿ (τ≈{tau_predicted:.3f})')
    ax2.set_xlabel('Iteration n', fontsize=12)
    ax2.set_ylabel('Oscillation (log scale)', fontsize=12)
    ax2.set_title('Oscillation Decay Under Tropical Iteration', fontsize=14, fontweight='bold')
    ax2.legend(fontsize=10)
    ax2.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('tropical_contraction.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: tropical_contraction.png")


if __name__ == "__main__":
    main()
