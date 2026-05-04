"""
Tropical Stone–Weierstrass Theorem: Demonstrations and Visualizations

This script demonstrates the Tropical Stone–Weierstrass theorem through
concrete numerical examples on [0,1]. It shows how finite max-min envelopes
of shifted functions can uniformly approximate arbitrary continuous functions.

The theorem states: if A ⊆ C(X, ℝ) on a compact Hausdorff space is closed under
pointwise max, pointwise min, constant shifts, contains all constants, and
tropically separates points, then A is uniformly dense in C(X, ℝ).
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from matplotlib.gridspec import GridSpec
import os

# Create output directory
os.makedirs("demos/figures", exist_ok=True)


# ============================================================================
# Core tropical operations
# ============================================================================

def affine_func(a, b):
    """Return the affine function x ↦ ax + b."""
    return lambda x: a * x + b

def tropical_sup_envelope(funcs, x):
    """Compute pointwise max of a list of functions (tropical sum)."""
    vals = np.array([f(x) for f in funcs])
    return np.max(vals, axis=0)

def tropical_inf_envelope(funcs, x):
    """Compute pointwise min of a list of functions."""
    vals = np.array([f(x) for f in funcs])
    return np.min(vals, axis=0)


def approximate_from_below(target_func, x_grid, n_pieces=10):
    """
    Build a piecewise-linear convex approximation from below using
    sup of affine functions (tangent lines at sample points).
    """
    sample_points = np.linspace(x_grid[0], x_grid[-1], n_pieces)
    h = 1e-8
    funcs = []
    for x0 in sample_points:
        y0 = target_func(x0)
        slope = (target_func(x0 + h) - target_func(x0 - h)) / (2 * h)
        funcs.append(affine_func(slope, y0 - slope * x0))
    return tropical_sup_envelope(funcs, x_grid), funcs


def approximate_with_max_min(target_func, x_grid, n_inner=8, n_outer=8):
    """
    Two-pass approximation implementing the proof of Tropical Stone–Weierstrass:
    1. For each anchor x_j, build an inf-envelope g_{x_j} ≤ f + ε near x_j
    2. Take the sup of all inf-envelopes to get global approximation
    """
    anchors = np.linspace(x_grid[0], x_grid[-1], n_outer)
    inner_points = np.linspace(x_grid[0], x_grid[-1], n_inner)
    h = 1e-8
    inf_envelopes = []
    
    for x_anchor in anchors:
        affines = []
        for x_inner in inner_points:
            if abs(x_inner - x_anchor) < 1e-10:
                y0 = target_func(x_anchor)
                slope = (target_func(x_anchor + h) - target_func(x_anchor - h)) / (2 * h)
            else:
                y1 = target_func(x_anchor)
                y2 = target_func(x_inner)
                slope = (y2 - y1) / (x_inner - x_anchor)
            intercept = target_func(x_anchor) - slope * x_anchor
            affines.append(affine_func(slope, intercept))
        
        inf_env = tropical_inf_envelope(affines, x_grid)
        inf_envelopes.append(inf_env)
    
    result = np.max(np.array(inf_envelopes), axis=0)
    return result


# ============================================================================
# Figure 1: The two-pass construction visualized
# ============================================================================

def plot_two_pass_construction():
    x = np.linspace(0, 1, 500)
    target = lambda t: np.sin(2 * np.pi * t) * 0.5 + 0.3 * t
    f = target(x)
    
    fig = plt.figure(figsize=(16, 10))
    gs = GridSpec(2, 2, figure=fig, hspace=0.3, wspace=0.3)
    
    ax1 = fig.add_subplot(gs[0, 0])
    ax1.plot(x, f, 'k-', linewidth=2, label='Target f(x)')
    ax1.set_title('Target Function f(x) = sin(2πx)/2 + 0.3x', fontsize=11)
    ax1.set_xlabel('x'); ax1.set_ylabel('f(x)')
    ax1.legend(); ax1.grid(True, alpha=0.3)
    
    ax2 = fig.add_subplot(gs[0, 1])
    ax2.plot(x, f, 'k-', linewidth=2, label='Target f')
    anchors = [0.15, 0.4, 0.65, 0.9]
    colors = ['#e41a1c', '#377eb8', '#4daf4a', '#984ea3']
    inf_envs = []
    
    for anchor, color in zip(anchors, colors):
        inner_pts = np.linspace(0, 1, 12)
        affines = []
        h = 1e-8
        for xp in inner_pts:
            y1 = target(anchor)
            if abs(xp - anchor) < 1e-10:
                slope = (target(anchor + h) - target(anchor - h)) / (2 * h)
            else:
                slope = (target(xp) - y1) / (xp - anchor)
            intercept = y1 - slope * anchor
            affines.append(affine_func(slope, intercept))
        
        inf_env = tropical_inf_envelope(affines, x)
        inf_envs.append(inf_env)
        ax2.plot(x, inf_env, color=color, linewidth=1.5, alpha=0.7,
                label=f'inf-envelope at x={anchor}')
        ax2.axvline(anchor, color=color, linestyle=':', alpha=0.3)
    
    ax2.set_title('Pass 1: Inf-Envelopes (min of affines)', fontsize=11)
    ax2.set_xlabel('x'); ax2.legend(fontsize=8); ax2.grid(True, alpha=0.3)
    
    ax3 = fig.add_subplot(gs[1, 0])
    sup_result = np.max(np.array(inf_envs), axis=0)
    ax3.plot(x, f, 'k-', linewidth=2, label='Target f')
    ax3.fill_between(x, f - 0.3, f + 0.3, alpha=0.1, color='gray', label='ε-tube (ε=0.3)')
    ax3.plot(x, sup_result, 'r-', linewidth=2, label='sup of inf-envelopes')
    ax3.set_title('Pass 2: Sup of Inf-Envelopes (4 anchors)', fontsize=11)
    ax3.set_xlabel('x'); ax3.legend(fontsize=9); ax3.grid(True, alpha=0.3)
    
    ax4 = fig.add_subplot(gs[1, 1])
    ax4.plot(x, f, 'k-', linewidth=2, label='Target f')
    for n_outer, style, lbl in [(4, '--', '4'), (8, '-.', '8'), (16, '-', '16'), (32, '-', '32')]:
        approx = approximate_with_max_min(target, x, n_inner=12, n_outer=n_outer)
        err = np.max(np.abs(f - approx))
        ax4.plot(x, approx, style, linewidth=1.5, alpha=0.8,
                label=f'{lbl} anchors (err={err:.4f})')
    
    ax4.set_title('Convergence: More Anchors → Better Approximation', fontsize=11)
    ax4.set_xlabel('x'); ax4.legend(fontsize=8); ax4.grid(True, alpha=0.3)
    
    fig.suptitle('Tropical Stone–Weierstrass: Two-Pass Construction', 
                fontsize=14, fontweight='bold', y=0.98)
    plt.savefig('demos/figures/two_pass_construction.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("  Saved: demos/figures/two_pass_construction.png")


# ============================================================================
# Figure 2: Approximation of various functions
# ============================================================================

def plot_various_approximations():
    x = np.linspace(0, 1, 500)
    targets = [
        (lambda t: np.sin(4 * np.pi * t), 'sin(4πx)', 'Oscillatory'),
        (lambda t: np.exp(-10 * (t - 0.5)**2), 'exp(-10(x-0.5)²)', 'Gaussian bump'),
        (lambda t: np.abs(t - 0.5) - 0.25, '|x-0.5| - 0.25', 'V-shape'),
        (lambda t: t**3 - t**2 + 0.2*t, 'x³ - x² + 0.2x', 'Cubic'),
    ]
    
    fig, axes = plt.subplots(2, 2, figsize=(14, 10))
    for ax, (func, name, desc) in zip(axes.flat, targets):
        f = func(x)
        for n, color, label in [(8, '#377eb8', '8×8'), (16, '#e41a1c', '16×16'), 
                                 (32, '#4daf4a', '32×32')]:
            approx = approximate_with_max_min(func, x, n_inner=n, n_outer=n)
            err = np.max(np.abs(f - approx))
            ax.plot(x, approx, color=color, linewidth=1, alpha=0.8,
                   label=f'{label}: err={err:.4f}')
        ax.plot(x, f, 'k-', linewidth=2, label=f'f(x) = {name}')
        ax.set_title(f'{desc}: {name}', fontsize=11)
        ax.legend(fontsize=8); ax.grid(True, alpha=0.3)
    
    fig.suptitle('Tropical Approximation of Various Functions', fontsize=14, fontweight='bold')
    plt.tight_layout()
    plt.savefig('demos/figures/various_approximations.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("  Saved: demos/figures/various_approximations.png")


# ============================================================================
# Figure 3: Convergence rate analysis
# ============================================================================

def plot_convergence_rates():
    x = np.linspace(0, 1, 1000)
    targets = [
        (lambda t: np.sin(2 * np.pi * t), 'sin(2πx)'),
        (lambda t: t * (1 - t), 'x(1-x)'),
        (lambda t: np.exp(-5 * (t - 0.3)**2), 'Gaussian'),
    ]
    
    n_values = [4, 6, 8, 12, 16, 24, 32, 48, 64]
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))
    
    for func, name in targets:
        f = func(x)
        errors = []
        for n in n_values:
            approx = approximate_with_max_min(func, x, n_inner=n, n_outer=n)
            err = np.max(np.abs(f - approx))
            errors.append(max(err, 1e-16))
        ax1.loglog(n_values, errors, 'o-', label=name, linewidth=2, markersize=6)
    
    ns = np.array(n_values, dtype=float)
    ax1.loglog(ns, 2.0 / ns**2, 'k--', alpha=0.4, label='O(1/n²) reference')
    ax1.set_xlabel('Number of pieces (n)', fontsize=12)
    ax1.set_ylabel('Sup-norm error ‖f - g‖∞', fontsize=12)
    ax1.set_title('Convergence Rate of Tropical Approximation', fontsize=12)
    ax1.legend(fontsize=10); ax1.grid(True, alpha=0.3, which='both')
    
    func = lambda t: np.sin(2 * np.pi * t)
    f = func(x)
    for n, color in [(8, '#377eb8'), (16, '#e41a1c'), (32, '#4daf4a')]:
        approx = approximate_with_max_min(func, x, n_inner=n, n_outer=n)
        ax2.plot(x, np.abs(f - approx), color=color, linewidth=1.5,
                label=f'n={n}', alpha=0.8)
    ax2.set_xlabel('x', fontsize=12); ax2.set_ylabel('|f(x) - g(x)|', fontsize=12)
    ax2.set_title('Pointwise Error for sin(2πx)', fontsize=12)
    ax2.legend(fontsize=10); ax2.grid(True, alpha=0.3)
    
    plt.tight_layout()
    plt.savefig('demos/figures/convergence_rates.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("  Saved: demos/figures/convergence_rates.png")


# ============================================================================
# Figure 4: Why inf closure is necessary
# ============================================================================

def plot_counterexample():
    x = np.linspace(0.001, 0.999, 500)
    f_func = lambda t: np.sqrt(t * (1 - t))
    f = f_func(x)
    
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))
    
    ax1.plot(x, f, 'k-', linewidth=2.5, label='f(x) = √(x(1-x)) (concave)')
    for n_affines in [5, 10, 20]:
        approx_below, _ = approximate_from_below(f_func, x, n_pieces=n_affines)
        err = np.max(np.abs(f - approx_below))
        ax1.plot(x, approx_below, '--', linewidth=1.5, alpha=0.7,
                label=f'sup of {n_affines} affines (err={err:.4f})')
    ax1.set_title('Sup-only (convex) approximation of concave f', fontsize=11)
    ax1.set_xlabel('x'); ax1.legend(fontsize=8); ax1.grid(True, alpha=0.3)
    
    ax2.plot(x, f, 'k-', linewidth=2.5, label='f(x) = √(x(1-x))')
    for n, color in [(8, '#377eb8'), (16, '#e41a1c'), (32, '#4daf4a')]:
        approx = approximate_with_max_min(f_func, x, n_inner=n, n_outer=n)
        err = np.max(np.abs(f - approx))
        ax2.plot(x, approx, color=color, linewidth=1.5, alpha=0.8,
                label=f'max-min {n}×{n} (err={err:.4f})')
    ax2.set_title('Max-min approximation (with inf) succeeds', fontsize=11)
    ax2.set_xlabel('x'); ax2.legend(fontsize=8); ax2.grid(True, alpha=0.3)
    
    fig.suptitle('Why Inf Closure Is Necessary', fontsize=12, fontweight='bold')
    plt.tight_layout()
    plt.savefig('demos/figures/counterexample_no_inf.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("  Saved: demos/figures/counterexample_no_inf.png")


# ============================================================================
# Figure 5: Tropical neural network application
# ============================================================================

def plot_tropical_neural_network():
    x = np.linspace(0, 1, 500)
    target = lambda t: 0.5 * np.sin(6 * np.pi * t) * np.exp(-2 * t) + 0.5
    f = target(x)
    
    fig, axes = plt.subplots(1, 3, figsize=(16, 5))
    configs = [(4, 4), (8, 8), (16, 16)]
    
    for ax, (no, ni) in zip(axes, configs):
        approx = approximate_with_max_min(target, x, n_inner=ni, n_outer=no)
        err = np.max(np.abs(f - approx))
        ax.plot(x, f, 'k-', linewidth=2, label='Target')
        ax.plot(x, approx, 'r-', linewidth=1.5, label='Tropical NN')
        ax.fill_between(x, f - err, f + err, alpha=0.1, color='blue')
        ax.set_title(f'{no}×{ni} tropical neurons\n‖f-g‖∞ = {err:.5f}', fontsize=11)
        ax.set_xlabel('x'); ax.legend(fontsize=9); ax.grid(True, alpha=0.3)
    
    fig.suptitle('Tropical Neural Network Universal Approximation\n'
                '(guaranteed by Tropical Stone–Weierstrass)',
                fontsize=13, fontweight='bold')
    plt.tight_layout()
    plt.savefig('demos/figures/tropical_neural_network.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("  Saved: demos/figures/tropical_neural_network.png")


# ============================================================================
# Run all
# ============================================================================

if __name__ == '__main__':
    print("=" * 60)
    print("Tropical Stone–Weierstrass Theorem: Demonstrations")
    print("=" * 60)
    
    print("\n1. Two-pass construction visualization...")
    plot_two_pass_construction()
    print("2. Approximation of various functions...")
    plot_various_approximations()
    print("3. Convergence rate analysis...")
    plot_convergence_rates()
    print("4. Counterexample: why inf closure is needed...")
    plot_counterexample()
    print("5. Tropical neural network application...")
    plot_tropical_neural_network()
    
    print("\n" + "=" * 60)
    print("All demonstrations complete!")
    print("Figures saved in demos/figures/")
    print("=" * 60)
