#!/usr/bin/env python3
"""
Visualization: Tropical Deformation Limit

Shows how log-sum-exp converges to max as the temperature parameter t → ∞.
This is the Maslov dequantization that bridges EML networks to tropical geometry.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt

def log_sum_exp_2d(x: np.ndarray, a: float, b: float, t: float) -> np.ndarray:
    """(1/t) * log(exp(t*(a*x+c1)) + exp(t*(b*x+c2))) for tropical max of two lines."""
    u = t * (a * x + 1.0)
    v = t * (b * x - 0.5)
    m = np.maximum(u, v)
    return (1.0/t) * (m + np.log(np.exp(u - m) + np.exp(v - m)))

def main():
    x = np.linspace(-2, 2, 500)

    # Two linear functions whose max gives a tropical polynomial
    line1 = 0.8 * x + 1.0
    line2 = -0.5 * x - 0.5
    tropical_max = np.maximum(line1, line2)

    fig, axes = plt.subplots(2, 3, figsize=(14, 8))

    t_values = [0.5, 1.0, 2.0, 5.0, 20.0, 100.0]

    for ax, t in zip(axes.flatten(), t_values):
        smooth = log_sum_exp_2d(x, 0.8, -0.5, t)
        ax.plot(x, line1, 'b--', alpha=0.4, label='f₁(x)')
        ax.plot(x, line2, 'r--', alpha=0.4, label='f₂(x)')
        ax.plot(x, tropical_max, 'k-', linewidth=2, alpha=0.3, label='max(f₁, f₂)')
        ax.plot(x, smooth, 'g-', linewidth=2, label=f'LSE (t={t})')
        ax.set_title(f't = {t}', fontsize=14)
        ax.set_ylim(-2.5, 3.5)
        ax.legend(fontsize=8)
        ax.grid(True, alpha=0.3)

    fig.suptitle('Maslov Dequantization: log-sum-exp → max as t → ∞', fontsize=16, y=1.02)
    plt.tight_layout()
    plt.savefig('tropical_limit_visualization.png', dpi=150, bbox_inches='tight')
    print("Saved: tropical_limit_visualization.png")

if __name__ == "__main__":
    main()
