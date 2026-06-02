#!/usr/bin/env python3
"""
Visualization 2: Variable-Rate vs Autonomous Shadowing Bounds

Compares the non-autonomous variable-rate bound with the autonomous
δ/(1-L) bound for SGD with cosine annealing schedule.
"""

import numpy as np
import matplotlib.pyplot as plt


def cosine_annealing_lipschitz(mu, eta0, T):
    L = []
    for t in range(T):
        eta_t = eta0 * (1 + np.cos(np.pi * t / T)) / 2
        L_t = abs(1 - eta_t * mu)
        L.append(L_t)
    return L


def accum_product(L, k, n):
    product = 1.0
    for j in range(k + 1, n):
        product *= L[j]
    return product


def accum_error_sum(L, n):
    total = 0.0
    for k in range(n):
        total += accum_product(L, k, n)
    return total


def main():
    mu = 1.0
    eta0 = 0.15
    T = 200
    delta = 0.01

    L = cosine_annealing_lipschitz(mu, eta0, T)
    L_max = max(L)

    steps = list(range(1, T + 1))
    var_bounds = [delta * accum_error_sum(L, t) for t in steps]
    auto_bound = delta / (1 - L_max) if L_max < 1 else float('inf')
    auto_bounds = [auto_bound] * len(steps)

    fig, axes = plt.subplots(2, 1, figsize=(12, 8), gridspec_kw={'height_ratios': [1, 2]})

    # Top: Lipschitz constants
    ax1 = axes[0]
    ax1.plot(range(T), L, 'b-', linewidth=1.5, label='L(t) = |1 - η(t)·μ|')
    ax1.axhline(y=L_max, color='red', linestyle='--', linewidth=1.5,
                label=f'L_max = {L_max:.4f}')
    ax1.set_ylabel('Lipschitz constant', fontsize=12)
    ax1.set_title(f'Cosine Annealing: μ={mu}, η₀={eta0}, T={T}', fontsize=14, fontweight='bold')
    ax1.legend(fontsize=11)
    ax1.grid(True, alpha=0.3)

    # Bottom: Shadowing bounds
    ax2 = axes[1]
    ax2.plot(steps, var_bounds, 'b-', linewidth=2, label='Variable-rate bound')
    ax2.plot(steps, auto_bounds, 'r--', linewidth=2, label=f'Autonomous bound δ/(1-L_max) = {auto_bound:.4f}')
    ax2.set_xlabel('Step t', fontsize=12)
    ax2.set_ylabel('Shadowing bound', fontsize=12)
    ax2.set_title('Variable-Rate vs Autonomous Shadowing Bound', fontsize=13)
    ax2.legend(fontsize=11)
    ax2.grid(True, alpha=0.3)

    # Add improvement annotation
    improvement = 1 - var_bounds[T//2] / auto_bound if auto_bound > 0 else 0
    ax2.annotate(f'{improvement*100:.1f}% tighter\nat midpoint',
                xy=(T//2, var_bounds[T//2]), xytext=(T//2 + 20, (var_bounds[T//2] + auto_bound)/2),
                arrowprops=dict(arrowstyle='->', color='green'),
                fontsize=12, color='green', fontweight='bold')

    plt.tight_layout()
    plt.savefig('variable_rate_comparison.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: variable_rate_comparison.png")


if __name__ == "__main__":
    main()
