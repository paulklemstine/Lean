"""
Visualization: EML Width-Depth Bounds and Power Representation

Standalone matplotlib script visualizing the structural bounds
and exact power representation from the EML interpolation theory.
"""

import math
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def plot_width_depth_bound():
    """Plot the width ≤ 2^depth bound for various EML expressions."""
    fig, axes = plt.subplots(1, 2, figsize=(14, 5))

    # Left: 2^depth bound
    ax = axes[0]
    depths = np.arange(0, 8)
    max_widths = 2 ** depths

    ax.bar(depths, max_widths, alpha=0.3, color='steelblue', label='Max width = 2^depth')
    ax.plot(depths, max_widths, 'o-', color='steelblue', linewidth=2)

    # Sample expression points
    sample_depths = [0, 0, 1, 1, 2, 2, 3, 3, 4, 5]
    sample_widths = [1, 1, 1, 1, 2, 1, 2, 4, 3, 2]
    sample_names = ['const', 'var', 'exp(v)', 'log(v)', 'v+v', 'exp²(v)',
                    'v+exp(v)', '(v+v)*(v+v)', 'power(3)', 'exp⁵(v)']

    ax.scatter(sample_depths, sample_widths, c='crimson', s=80, zorder=5,
               label='Example EML expressions')

    for i, name in enumerate(sample_names):
        ax.annotate(name, (sample_depths[i], sample_widths[i]),
                    textcoords="offset points", xytext=(5, 5),
                    fontsize=7, color='crimson')

    ax.set_xlabel('Depth', fontsize=12)
    ax.set_ylabel('Width', fontsize=12)
    ax.set_title('Width-Depth Bound: width ≤ 2^depth', fontsize=13)
    ax.legend(fontsize=10)
    ax.set_yscale('log', base=2)
    ax.grid(True, alpha=0.3)

    # Right: Power representation error
    ax = axes[1]
    xs = np.linspace(0.01, 3.0, 500)

    for n in [1, 2, 3, 5]:
        eml_vals = np.exp(n * np.log(xs))
        exact_vals = xs ** n
        errors = np.abs(eml_vals - exact_vals)
        ax.plot(xs, errors, label=f'n={n}', linewidth=2)

    ax.set_xlabel('x', fontsize=12)
    ax.set_ylabel('|exp(n·log(x)) − x^n|', fontsize=12)
    ax.set_title('EML Power Representation Error', fontsize=13)
    ax.legend(fontsize=10)
    ax.set_yscale('symlog', linthresh=1e-16)
    ax.set_ylim(-1e-16, 1e-12)
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('eml_bounds.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: eml_bounds.png")


def plot_soft_max_convergence():
    """Plot convergence of soft-max to true max."""
    fig, axes = plt.subplots(1, 2, figsize=(14, 5))

    # Left: soft-max function shape
    ax = axes[0]
    xs = np.linspace(-2, 2, 500)
    a_val = 0.0

    for t in [0.5, 1, 2, 5, 20]:
        # soft_max(x, 0) for varying t
        m = np.maximum(t * xs, t * a_val)
        soft = (m + np.log(np.exp(t * xs - m) + np.exp(t * a_val - m))) / t
        ax.plot(xs, soft, label=f't={t}', linewidth=2)

    # True max
    ax.plot(xs, np.maximum(xs, 0), 'k--', linewidth=2, label='max(x, 0)')

    ax.set_xlabel('x', fontsize=12)
    ax.set_ylabel('soft_max(x, 0)', fontsize=12)
    ax.set_title('Soft-Max Convergence to Max', fontsize=13)
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)

    # Right: error vs temperature
    ax = axes[1]
    ts = np.logspace(-1, 3, 100)

    for a, b in [(3, 7), (1, 2), (0, 1)]:
        exact = max(a, b)
        errors = []
        for t in ts:
            m = max(t * a, t * b)
            sm = (m + math.log(math.exp(t * a - m) + math.exp(t * b - m))) / t
            errors.append(abs(sm - exact))
        ax.plot(ts, errors, label=f'max({a},{b})', linewidth=2)

    # Theoretical bound: ln(2)/t
    ax.plot(ts, np.log(2) / ts, 'k--', linewidth=2, label='ln(2)/t bound')

    ax.set_xlabel('Temperature t', fontsize=12)
    ax.set_ylabel('|soft_max − max|', fontsize=12)
    ax.set_title('Tropical-Classical Bridge Error', fontsize=13)
    ax.set_xscale('log')
    ax.set_yscale('log')
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('eml_soft_max.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: eml_soft_max.png")


def plot_eml_approximation():
    """Plot EML approximation of various functions."""
    fig, axes = plt.subplots(2, 2, figsize=(12, 10))

    # Top-left: x^2 via exp(2*log(x))
    ax = axes[0, 0]
    xs = np.linspace(0.01, 2.0, 500)
    ax.plot(xs, xs ** 2, 'b-', linewidth=2, label='x²')
    ax.plot(xs, np.exp(2 * np.log(xs)), 'r--', linewidth=2, label='exp(2·log(x))')
    ax.set_xlabel('x')
    ax.set_title('x² = exp(2·log(x))')
    ax.legend()
    ax.grid(True, alpha=0.3)

    # Top-right: x^5 via exp(5*log(x))
    ax = axes[0, 1]
    xs = np.linspace(0.01, 1.5, 500)
    ax.plot(xs, xs ** 5, 'b-', linewidth=2, label='x⁵')
    ax.plot(xs, np.exp(5 * np.log(xs)), 'r--', linewidth=2, label='exp(5·log(x))')
    ax.set_xlabel('x')
    ax.set_title('x⁵ = exp(5·log(x))')
    ax.legend()
    ax.grid(True, alpha=0.3)

    # Bottom-left: |x-0.5| approximation via soft-max
    ax = axes[1, 0]
    xs = np.linspace(0, 1, 500)
    target = np.abs(xs - 0.5)
    ax.plot(xs, target, 'b-', linewidth=2, label='|x − 0.5|')

    for t in [2, 5, 20]:
        # |x - 0.5| = max(x - 0.5, 0.5 - x) via soft-max
        a = xs - 0.5
        b = 0.5 - xs
        m = np.maximum(t * a, t * b)
        soft = (m + np.log(np.exp(t * a - m) + np.exp(t * b - m))) / t
        ax.plot(xs, soft, '--', linewidth=1.5, label=f'EML (t={t})')

    ax.set_xlabel('x')
    ax.set_title('|x − 0.5| via log-sum-exp')
    ax.legend(fontsize=9)
    ax.grid(True, alpha=0.3)

    # Bottom-right: Exp Lipschitz constant growth
    ax = axes[1, 1]
    Ms = np.linspace(0, 5, 500)
    ax.plot(Ms, np.exp(Ms), 'b-', linewidth=2)
    ax.fill_between(Ms, 0, np.exp(Ms), alpha=0.1, color='blue')
    ax.set_xlabel('M (domain bound)')
    ax.set_ylabel('exp(M) (Lipschitz constant)')
    ax.set_title('Lipschitz Constant of exp on [-M, M]')
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('eml_approximation.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: eml_approximation.png")


if __name__ == "__main__":
    plot_width_depth_bound()
    plot_soft_max_convergence()
    plot_eml_approximation()
    print("\nAll visualizations generated.")
