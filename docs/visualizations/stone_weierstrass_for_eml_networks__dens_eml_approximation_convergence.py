#!/usr/bin/env python3
"""
Visualization: EML Network Approximation Convergence

Shows how increasing the number of EML basis functions
improves approximation quality for various target functions.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt

def eml_approx(x, target_fn, n_terms, interval=(-1, 1)):
    a, b = interval
    n_samples = max(200, 5 * n_terms)
    x_fit = np.linspace(a, b, n_samples)
    y_fit = target_fn(x_fit)
    A = np.column_stack([np.exp(k * x_fit) for k in range(n_terms)])
    coeffs, _, _, _ = np.linalg.lstsq(A, y_fit, rcond=None)
    A_eval = np.column_stack([np.exp(k * x) for k in range(n_terms)])
    return A_eval @ coeffs

x = np.linspace(-1, 1, 500)
targets = {
    r"$x^2$": lambda t: t**2,
    r"$\sin(\pi x)$": lambda t: np.sin(np.pi * t),
    r"$|x|$": lambda t: np.abs(t),
    r"$x^3 - x$": lambda t: t**3 - t,
}

fig, axes = plt.subplots(2, 2, figsize=(12, 10))
fig.suptitle("EML Network Approximation (Stone-Weierstrass)", fontsize=16, fontweight='bold')

for ax, (name, fn) in zip(axes.flat, targets.items()):
    ax.plot(x, fn(x), 'k-', linewidth=2, label='Target')
    colors = ['#e41a1c', '#377eb8', '#4daf4a', '#984ea3']
    for n, color in zip([3, 5, 10, 20], colors):
        approx = eml_approx(x, fn, n)
        err = np.max(np.abs(fn(x) - approx))
        ax.plot(x, approx, '--', color=color, linewidth=1.2,
                label=f'N={n} (err={err:.1e})')
    ax.set_title(f'f(x) = {name}', fontsize=13)
    ax.legend(fontsize=8)
    ax.grid(True, alpha=0.3)
    ax.set_xlabel('x')
    ax.set_ylabel('f(x)')

plt.tight_layout()
plt.savefig('viz_approximation.png', dpi=150, bbox_inches='tight')
print("Saved viz_approximation.png")
