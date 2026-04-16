#!/usr/bin/env python3
"""
EML Operator Explorer — Interactive Visualization and Computation

This script provides comprehensive visualizations and numerical experiments
for the EML operator eml(x, y) = exp(x) - ln(y) and its derived quantities.

Demos include:
1. EML surface and level curves
2. g-map iteration and convergence
3. σ-EML activation function analysis
4. Diagonal orbit dynamics (super-exponential growth)
5. EML entropy vs Shannon entropy comparison
6. Fixed point localization
7. Bregman divergence connection
8. EML as information operator (KL divergence decomposition)
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')  # Non-interactive backend
import matplotlib.pyplot as plt
from matplotlib import cm
from mpl_toolkits.mplot3d import Axes3D
import os

OUTPUT_DIR = os.path.dirname(os.path.abspath(__file__))

# ============================================================
# Core EML functions
# ============================================================

def eml(x, y):
    """The EML operator: eml(x, y) = exp(x) - ln(y)."""
    return np.exp(x) - np.log(y)

def diag(z):
    """Diagonal map: d(z) = exp(z) - ln(z)."""
    return np.exp(z) - np.log(z)

def gmap(z):
    """Off-diagonal g-map: g(z) = e - ln(z)."""
    return np.e - np.log(z)

def sigma_eml(x):
    """σ-EML activation: σ_eml(x) = exp(x) - ln(1 + exp(-x))."""
    return np.exp(x) - np.log(1 + np.exp(-x))

def softplus(x):
    """Softplus: ln(1 + exp(x))."""
    return np.log(1 + np.exp(x))

# ============================================================
# Demo 1: EML Surface Plot
# ============================================================

def demo_eml_surface():
    """Plot the EML operator as a 3D surface."""
    fig = plt.figure(figsize=(12, 8))
    ax = fig.add_subplot(111, projection='3d')

    x = np.linspace(-2, 2, 100)
    y = np.linspace(0.1, 5, 100)
    X, Y = np.meshgrid(x, y)
    Z = eml(X, Y)

    # Clip for visualization
    Z = np.clip(Z, -5, 10)

    surf = ax.plot_surface(X, Y, Z, cmap=cm.viridis, alpha=0.8,
                           linewidth=0, antialiased=True)
    ax.set_xlabel('x', fontsize=12)
    ax.set_ylabel('y', fontsize=12)
    ax.set_zlabel('eml(x, y)', fontsize=12)
    ax.set_title('EML Operator: eml(x, y) = exp(x) − ln(y)', fontsize=14)
    fig.colorbar(surf, shrink=0.5, aspect=5)

    plt.tight_layout()
    plt.savefig(os.path.join(OUTPUT_DIR, 'eml_surface.png'), dpi=150)
    plt.close()
    print("✓ EML surface plot saved")

# ============================================================
# Demo 2: EML Level Curves
# ============================================================

def demo_eml_level_curves():
    """Plot level curves of the EML operator."""
    fig, ax = plt.subplots(figsize=(10, 7))

    x = np.linspace(-2, 3, 400)
    y = np.linspace(0.01, 10, 400)
    X, Y = np.meshgrid(x, y)
    Z = eml(X, Y)

    levels = [-2, -1, 0, 1, 2, 3, 5, 7, 10]
    cs = ax.contour(X, Y, Z, levels=levels, cmap='coolwarm', linewidths=1.5)
    ax.clabel(cs, inline=True, fontsize=10, fmt='%.0f')

    # Mark the neutral point (0, e) where eml = 0
    ax.plot(0, np.e, 'ko', markersize=8, label='Neutral point (0, e)')
    ax.annotate('eml = 0', xy=(0, np.e), xytext=(0.5, np.e+1),
                fontsize=11, arrowprops=dict(arrowstyle='->', color='black'))

    ax.set_xlabel('x', fontsize=12)
    ax.set_ylabel('y', fontsize=12)
    ax.set_title('Level Curves of eml(x, y) = exp(x) − ln(y)', fontsize=14)
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig(os.path.join(OUTPUT_DIR, 'eml_level_curves.png'), dpi=150)
    plt.close()
    print("✓ EML level curves saved")

# ============================================================
# Demo 3: g-Map Iteration and Convergence
# ============================================================

def demo_gmap_convergence():
    """Visualize g-map iteration convergence from various starting points."""
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))

    # Left: cobweb diagram
    ax = axes[0]
    z = np.linspace(0.01, 5, 1000)
    g_vals = gmap(z)

    ax.plot(z, g_vals, 'b-', linewidth=2, label='g(z) = e − ln(z)')
    ax.plot(z, z, 'k--', linewidth=1, label='y = z')

    # Find fixed point numerically
    from scipy.optimize import brentq
    z_star = brentq(lambda z: gmap(z) - z, 1.5, 3)
    ax.plot(z_star, z_star, 'r*', markersize=15, label=f'Fixed point z* ≈ {z_star:.4f}')

    # Cobweb from z0 = 0.5
    z0 = 0.5
    zn = z0
    for _ in range(15):
        zn1 = gmap(zn)
        ax.plot([zn, zn], [zn, zn1], 'g-', alpha=0.6, linewidth=0.8)
        ax.plot([zn, zn1], [zn1, zn1], 'g-', alpha=0.6, linewidth=0.8)
        zn = zn1

    # Cobweb from z0 = 4
    zn = 4.0
    for _ in range(15):
        zn1 = gmap(zn)
        ax.plot([zn, zn], [zn, zn1], 'm-', alpha=0.6, linewidth=0.8)
        ax.plot([zn, zn1], [zn1, zn1], 'm-', alpha=0.6, linewidth=0.8)
        zn = zn1

    ax.set_xlim(0, 5)
    ax.set_ylim(0, 5)
    ax.set_xlabel('z', fontsize=12)
    ax.set_ylabel('g(z)', fontsize=12)
    ax.set_title('g-Map Cobweb Diagram', fontsize=14)
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)

    # Right: convergence rate
    ax = axes[1]
    starts = [0.1, 0.5, 1.0, 2.0, 3.0, 4.0, 5.0]
    for z0 in starts:
        orbit = [z0]
        zn = z0
        for _ in range(30):
            zn = gmap(zn)
            orbit.append(zn)
        ax.plot(orbit, '-o', markersize=3, label=f'z₀ = {z0}')

    ax.axhline(y=z_star, color='r', linestyle='--', label=f'z* ≈ {z_star:.4f}')
    ax.set_xlabel('Iteration n', fontsize=12)
    ax.set_ylabel('g^n(z₀)', fontsize=12)
    ax.set_title('g-Map Convergence from Various Starts', fontsize=14)
    ax.legend(fontsize=9, ncol=2)
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig(os.path.join(OUTPUT_DIR, 'gmap_convergence.png'), dpi=150)
    plt.close()
    print(f"✓ g-map convergence plot saved (z* ≈ {z_star:.6f})")

# ============================================================
# Demo 4: σ-EML Activation Function
# ============================================================

def demo_sigma_eml():
    """Compare σ-EML with standard activation functions."""
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))

    x = np.linspace(-5, 3, 1000)

    # Left: σ-EML vs other activations
    ax = axes[0]
    ax.plot(x, sigma_eml(x), 'b-', linewidth=2.5, label='σ-EML(x)')
    ax.plot(x, 1 / (1 + np.exp(-x)), 'r--', linewidth=1.5, label='Sigmoid(x)')
    ax.plot(x, np.maximum(0, x), 'g--', linewidth=1.5, label='ReLU(x)')
    ax.plot(x, softplus(x), 'm--', linewidth=1.5, label='Softplus(x)')
    ax.plot(x, np.tanh(x), 'c--', linewidth=1.5, label='tanh(x)')

    ax.axhline(y=0, color='k', linewidth=0.5)
    ax.axvline(x=0, color='k', linewidth=0.5)

    # Find zero crossing
    from scipy.optimize import brentq
    x_zero = brentq(sigma_eml, -3, 0)
    ax.plot(x_zero, 0, 'ko', markersize=8)
    ax.annotate(f'Zero at x ≈ {x_zero:.3f}', xy=(x_zero, 0),
                xytext=(x_zero+1, -1), fontsize=10,
                arrowprops=dict(arrowstyle='->', color='black'))

    ax.set_xlabel('x', fontsize=12)
    ax.set_ylabel('Activation value', fontsize=12)
    ax.set_title('σ-EML vs Standard Activations', fontsize=14)
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)
    ax.set_ylim(-3, 8)

    # Right: derivative comparison
    ax = axes[1]
    dx = 1e-6
    sigma_eml_deriv = (sigma_eml(x + dx) - sigma_eml(x - dx)) / (2 * dx)
    sigmoid_deriv = np.exp(-x) / (1 + np.exp(-x))**2
    relu_deriv = (x > 0).astype(float)

    ax.plot(x, sigma_eml_deriv, 'b-', linewidth=2.5, label="σ-EML'(x)")
    ax.plot(x, sigmoid_deriv, 'r--', linewidth=1.5, label="Sigmoid'(x)")
    ax.plot(x, relu_deriv, 'g--', linewidth=1.5, label="ReLU'(x)")

    ax.set_xlabel('x', fontsize=12)
    ax.set_ylabel('Derivative', fontsize=12)
    ax.set_title('Activation Derivatives (No Vanishing Gradient for σ-EML)', fontsize=14)
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)
    ax.set_ylim(-0.5, 10)

    plt.tight_layout()
    plt.savefig(os.path.join(OUTPUT_DIR, 'sigma_eml_activation.png'), dpi=150)
    plt.close()
    print(f"✓ σ-EML activation plot saved (zero crossing at x ≈ {x_zero:.6f})")

# ============================================================
# Demo 5: Diagonal Orbit Super-Exponential Growth
# ============================================================

def demo_diagonal_dynamics():
    """Visualize the explosive growth of diagonal orbits."""
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))

    # Left: orbits from various starting points (log scale)
    ax = axes[0]
    starts = [0.5, 1.0, 1.5, 2.0]
    for z0 in starts:
        orbit = [z0]
        zn = z0
        for i in range(6):
            try:
                zn = diag(zn)
                if zn > 1e300:
                    break
                orbit.append(zn)
            except (OverflowError, RuntimeWarning):
                break
        ax.semilogy(range(len(orbit)), orbit, '-o', markersize=6, label=f'z₀ = {z0}')

    ax.set_xlabel('Iteration n', fontsize=12)
    ax.set_ylabel('d^n(z₀) (log scale)', fontsize=12)
    ax.set_title('Diagonal Orbit Growth (Super-Exponential)', fontsize=14)
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)

    # Right: comparison with lower bounds
    ax = axes[1]
    z0 = 1.0
    n_vals = range(5)
    orbit = [z0]
    zn = z0
    for i in range(4):
        zn = diag(zn)
        orbit.append(zn)

    linear_bound = [z0 + n for n in n_vals]
    exp_bound = [np.exp(z0 + n) - (z0 + n) + 1 if n > 0 else z0 for n in n_vals]

    ax.semilogy(list(n_vals), orbit, 'b-o', linewidth=2, markersize=8, label='Actual d^n(1)')
    ax.semilogy(list(n_vals), linear_bound, 'r--', linewidth=1.5, label='Linear bound: z+n')
    ax.semilogy(list(n_vals), exp_bound, 'g--', linewidth=1.5, label='Exp bound: e^(z+n)-(z+n)+1')

    ax.set_xlabel('Iteration n', fontsize=12)
    ax.set_ylabel('Value (log scale)', fontsize=12)
    ax.set_title('Orbit vs Lower Bounds (z₀ = 1)', fontsize=14)
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig(os.path.join(OUTPUT_DIR, 'diagonal_dynamics.png'), dpi=150)
    plt.close()
    print("✓ Diagonal dynamics plot saved")

# ============================================================
# Demo 6: EML Entropy vs Shannon Entropy
# ============================================================

def demo_eml_entropy():
    """Compare EML entropy with Shannon entropy for binary distributions."""
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))

    # Binary distribution: (p, 1-p)
    p_vals = np.linspace(0.001, 0.999, 1000)

    # Shannon entropy: -p*ln(p) - (1-p)*ln(1-p)
    H_shannon = -p_vals * np.log(p_vals) - (1 - p_vals) * np.log(1 - p_vals)

    # EML entropy: (p - ln(p)) + ((1-p) - ln(1-p))
    H_eml = (p_vals - np.log(p_vals)) + ((1 - p_vals) - np.log(1 - p_vals))

    # Normalized EML entropy: H_eml - n (n=2 for binary)
    H_eml_norm = H_eml - 2

    ax = axes[0]
    ax.plot(p_vals, H_shannon, 'b-', linewidth=2, label='Shannon H(p)')
    ax.plot(p_vals, H_eml, 'r-', linewidth=2, label='EML H_eml(p)')
    ax.plot(p_vals, H_eml_norm, 'g--', linewidth=2, label='Normalized H_eml - 2')

    ax.axhline(y=np.log(2), color='b', linestyle=':', alpha=0.5, label=f'Shannon max = ln(2) ≈ {np.log(2):.3f}')
    ax.set_xlabel('p (probability of outcome 1)', fontsize=12)
    ax.set_ylabel('Entropy', fontsize=12)
    ax.set_title('EML Entropy vs Shannon Entropy (Binary)', fontsize=14)
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)

    # Right: n-ary uniform distributions
    ax = axes[1]
    n_vals = range(2, 21)
    shannon_uniform = [np.log(n) for n in n_vals]
    eml_uniform = [n * (1/n - np.log(1/n)) for n in n_vals]
    eml_norm_uniform = [h - n for h, n in zip(eml_uniform, n_vals)]

    ax.plot(list(n_vals), shannon_uniform, 'bo-', linewidth=2, label='Shannon (uniform)')
    ax.plot(list(n_vals), eml_uniform, 'rs-', linewidth=2, label='EML (uniform)')
    ax.plot(list(n_vals), eml_norm_uniform, 'g^-', linewidth=2, label='EML - n (uniform)')

    ax.set_xlabel('Number of outcomes n', fontsize=12)
    ax.set_ylabel('Entropy value', fontsize=12)
    ax.set_title('Entropy of Uniform Distributions', fontsize=14)
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig(os.path.join(OUTPUT_DIR, 'eml_entropy.png'), dpi=150)
    plt.close()
    print("✓ EML entropy comparison saved")

# ============================================================
# Demo 7: Fixed Point Localization and Lambert W
# ============================================================

def demo_fixed_point():
    """Visualize the g-map fixed point and Lambert W connection."""
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))

    from scipy.optimize import brentq

    # Left: h(z) = z + ln(z) and e
    ax = axes[0]
    z = np.linspace(0.01, 5, 1000)
    h = z + np.log(z)

    ax.plot(z, h, 'b-', linewidth=2, label='h(z) = z + ln(z)')
    ax.axhline(y=np.e, color='r', linestyle='--', linewidth=1.5, label=f'y = e ≈ {np.e:.4f}')

    z_star = brentq(lambda z: z + np.log(z) - np.e, 1, 4)
    ax.plot(z_star, np.e, 'r*', markersize=15, label=f'z* ≈ {z_star:.6f}')

    # Mark interval (2, e)
    ax.axvspan(2, np.e, alpha=0.15, color='green', label='Interval (2, e)')

    ax.set_xlabel('z', fontsize=12)
    ax.set_ylabel('h(z)', fontsize=12)
    ax.set_title('Fixed Point: z + ln(z) = e', fontsize=14)
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)
    ax.set_xlim(0, 5)
    ax.set_ylim(-5, 5)

    # Right: Lambert W connection — z*exp(z) = exp(e)
    ax = axes[1]
    z = np.linspace(0.01, 4, 1000)
    f = z * np.exp(z)

    ax.plot(z, f, 'b-', linewidth=2, label='f(z) = z·exp(z)')
    ax.axhline(y=np.exp(np.e), color='r', linestyle='--', linewidth=1.5,
               label=f'y = exp(e) ≈ {np.exp(np.e):.2f}')
    ax.plot(z_star, z_star * np.exp(z_star), 'r*', markersize=15,
            label=f'z* ≈ {z_star:.6f}')

    ax.set_xlabel('z', fontsize=12)
    ax.set_ylabel('z·exp(z)', fontsize=12)
    ax.set_title('Lambert W: z*·exp(z*) = exp(e)', fontsize=14)
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)
    ax.set_ylim(0, 30)

    plt.tight_layout()
    plt.savefig(os.path.join(OUTPUT_DIR, 'fixed_point_lambert.png'), dpi=150)
    plt.close()
    print(f"✓ Fixed point plot saved (z* ≈ {z_star:.10f})")
    print(f"  Lambert W check: z*·exp(z*) = {z_star * np.exp(z_star):.6f}, exp(e) = {np.exp(np.e):.6f}")

# ============================================================
# Demo 8: EML Decomposition Visualization
# ============================================================

def demo_decomposition():
    """Visualize the additive decomposition eml(x,y) = (exp(x)-1) + (1-ln(y))."""
    fig, axes = plt.subplots(1, 3, figsize=(18, 5))

    x = np.linspace(-2, 2, 200)
    y = np.linspace(0.1, 5, 200)

    # Left: exponential deviation α(x) = exp(x) - 1
    ax = axes[0]
    alpha = np.exp(x) - 1
    ax.plot(x, alpha, 'b-', linewidth=2)
    ax.axhline(y=0, color='k', linewidth=0.5)
    ax.axvline(x=0, color='k', linewidth=0.5)
    ax.fill_between(x, alpha, 0, alpha=0.1, color='blue')
    ax.set_xlabel('x', fontsize=12)
    ax.set_ylabel('α(x) = exp(x) - 1', fontsize=12)
    ax.set_title('Exponential Deviation', fontsize=14)
    ax.grid(True, alpha=0.3)

    # Middle: logarithmic deviation β(y) = 1 - ln(y)
    ax = axes[1]
    beta = 1 - np.log(y)
    ax.plot(y, beta, 'r-', linewidth=2)
    ax.axhline(y=0, color='k', linewidth=0.5)
    ax.axvline(x=np.e, color='k', linewidth=0.5, linestyle='--')
    ax.fill_between(y, beta, 0, alpha=0.1, color='red')
    ax.set_xlabel('y', fontsize=12)
    ax.set_ylabel('β(y) = 1 - ln(y)', fontsize=12)
    ax.set_title('Logarithmic Deviation', fontsize=14)
    ax.grid(True, alpha=0.3)

    # Right: combined — heatmap of α(x) + β(y)
    ax = axes[2]
    X, Y = np.meshgrid(x, y)
    Z = (np.exp(X) - 1) + (1 - np.log(Y))

    im = ax.pcolormesh(X, Y, Z, cmap='RdBu_r', vmin=-3, vmax=8, shading='auto')
    ax.contour(X, Y, Z, levels=[0], colors='black', linewidths=2)
    ax.plot(0, np.e, 'k*', markersize=12)
    ax.annotate('(0, e): eml = 0', xy=(0, np.e), xytext=(0.5, np.e+0.5), fontsize=10)
    fig.colorbar(im, ax=ax, label='eml(x, y)')
    ax.set_xlabel('x', fontsize=12)
    ax.set_ylabel('y', fontsize=12)
    ax.set_title('eml = α(x) + β(y)', fontsize=14)

    plt.tight_layout()
    plt.savefig(os.path.join(OUTPUT_DIR, 'eml_decomposition.png'), dpi=150)
    plt.close()
    print("✓ EML decomposition plot saved")

# ============================================================
# Demo 9: EML Convexity/Concavity
# ============================================================

def demo_convexity():
    """Demonstrate convexity in x and concavity in y."""
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))

    # Left: convexity in x (fixed y=1)
    ax = axes[0]
    x = np.linspace(-2, 2, 200)
    y_fixed = 1.0
    f = eml(x, y_fixed)

    ax.plot(x, f, 'b-', linewidth=2, label=f'eml(x, {y_fixed})')

    # Show Jensen's inequality
    x1, x2 = -1, 1.5
    midpoint = (x1 + x2) / 2
    chord_val = (eml(x1, y_fixed) + eml(x2, y_fixed)) / 2
    mid_val = eml(midpoint, y_fixed)

    ax.plot([x1, x2], [eml(x1, y_fixed), eml(x2, y_fixed)], 'r--', linewidth=1.5, label='Chord')
    ax.plot(midpoint, chord_val, 'r^', markersize=10, label=f'Chord midpoint = {chord_val:.3f}')
    ax.plot(midpoint, mid_val, 'gv', markersize=10, label=f'eml(mid) = {mid_val:.3f}')
    ax.annotate('', xy=(midpoint, mid_val), xytext=(midpoint, chord_val),
                arrowprops=dict(arrowstyle='<->', color='purple', lw=2))

    ax.set_xlabel('x', fontsize=12)
    ax.set_ylabel('eml(x, 1)', fontsize=12)
    ax.set_title('Convexity in x (Jensen Gap)', fontsize=14)
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)

    # Right: concavity in y (fixed x=0)
    ax = axes[1]
    y = np.linspace(0.1, 5, 200)
    x_fixed = 0.0
    f = eml(x_fixed, y)

    ax.plot(y, f, 'b-', linewidth=2, label=f'eml({x_fixed}, y)')

    y1, y2 = 0.5, 4.0
    midpoint_y = (y1 + y2) / 2
    chord_val_y = (eml(x_fixed, y1) + eml(x_fixed, y2)) / 2
    mid_val_y = eml(x_fixed, midpoint_y)

    ax.plot([y1, y2], [eml(x_fixed, y1), eml(x_fixed, y2)], 'r--', linewidth=1.5, label='Chord')
    ax.plot(midpoint_y, chord_val_y, 'rv', markersize=10, label=f'Chord midpoint = {chord_val_y:.3f}')
    ax.plot(midpoint_y, mid_val_y, 'g^', markersize=10, label=f'eml(mid) = {mid_val_y:.3f}')

    ax.set_xlabel('y', fontsize=12)
    ax.set_ylabel('eml(0, y)', fontsize=12)
    ax.set_title('Concavity in y (Reverse Jensen Gap)', fontsize=14)
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig(os.path.join(OUTPUT_DIR, 'eml_convexity.png'), dpi=150)
    plt.close()
    print("✓ EML convexity/concavity plot saved")

# ============================================================
# Demo 10: EML Optimal Transport Cost
# ============================================================

def demo_optimal_transport():
    """Explore EML as an optimal transport cost function."""
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))

    # Left: cost matrix visualization
    ax = axes[0]
    x = np.linspace(-1, 2, 50)
    y = np.linspace(0.1, 4, 50)
    X, Y = np.meshgrid(x, y)
    C = eml(X, Y)

    im = ax.pcolormesh(X, Y, C, cmap='hot', shading='auto')
    ax.contour(X, Y, C, levels=10, colors='white', linewidths=0.5, alpha=0.5)
    fig.colorbar(im, ax=ax, label='Transport cost eml(x,y)')
    ax.set_xlabel('Source x', fontsize=12)
    ax.set_ylabel('Target y', fontsize=12)
    ax.set_title('EML Transport Cost c(x,y) = exp(x) − ln(y)', fontsize=14)

    # Right: cost asymmetry visualization
    ax = axes[1]
    t = np.linspace(0.1, 4, 200)

    # Cost from 0 to y and from y to 1 (using ln(y) as source)
    c_forward = eml(0, t)  # cost from x=0 to y=t
    c_backward = eml(np.log(t), np.ones_like(t))  # cost from x=ln(t) to y=1

    ax.plot(t, c_forward, 'b-', linewidth=2, label='eml(0, y): fixed source x=0')
    ax.plot(t, c_backward, 'r-', linewidth=2, label='eml(ln(y), 1): "reverse"')
    ax.plot(t, c_forward - c_backward, 'g--', linewidth=1.5, label='Asymmetry gap')

    ax.axhline(y=0, color='k', linewidth=0.5)
    ax.set_xlabel('y', fontsize=12)
    ax.set_ylabel('Transport cost', fontsize=12)
    ax.set_title('Cost Asymmetry: EML is not symmetric', fontsize=14)
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig(os.path.join(OUTPUT_DIR, 'eml_transport.png'), dpi=150)
    plt.close()
    print("✓ EML optimal transport plot saved")

# ============================================================
# Demo 11: Bregman Divergence Connection
# ============================================================

def demo_bregman():
    """Show EML diagonal as Bregman divergence of -ln."""
    fig, ax = plt.subplots(figsize=(10, 7))

    p = np.linspace(0.1, 4, 200)

    # f(x) = -ln(x), Bregman divergence D_f(p, 1) = -ln(p) + ln(1) + (1/1)(p - 1) = p - 1 - ln(p)
    bregman = p - 1 - np.log(p)
    eml_diag = p - np.log(p)  # = Bregman + 1

    ax.plot(p, eml_diag, 'b-', linewidth=2.5, label='p − ln(p) [EML diagonal]')
    ax.plot(p, bregman, 'r-', linewidth=2, label='p − 1 − ln(p) [Bregman D_{−ln}(p‖1)]')
    ax.axhline(y=1, color='b', linestyle=':', alpha=0.5)
    ax.axhline(y=0, color='r', linestyle=':', alpha=0.5)

    ax.plot(1, 1, 'bo', markersize=10)
    ax.plot(1, 0, 'ro', markersize=10)
    ax.annotate('Minimum at p=1', xy=(1, 0), xytext=(2, 0.5), fontsize=11,
                arrowprops=dict(arrowstyle='->', color='red'))

    ax.set_xlabel('p', fontsize=12)
    ax.set_ylabel('Value', fontsize=12)
    ax.set_title('EML Diagonal = Bregman Divergence + 1', fontsize=14)
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig(os.path.join(OUTPUT_DIR, 'eml_bregman.png'), dpi=150)
    plt.close()
    print("✓ Bregman divergence connection plot saved")

# ============================================================
# Demo 12: EML KL Divergence Decomposition
# ============================================================

def demo_kl_divergence():
    """Show how KL divergence decomposes into EML differences."""
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))

    # Binary distributions P = (p, 1-p), Q = (q, 1-q)
    ax = axes[0]
    q_vals = np.linspace(0.01, 0.99, 200)
    p_fixed = 0.3

    # Standard KL
    kl = p_fixed * np.log(p_fixed / q_vals) + (1 - p_fixed) * np.log((1 - p_fixed) / (1 - q_vals))

    # EML decomposition: sum of eml(ln(pi), qi) - eml(ln(pi), pi)
    eml_term1 = eml(np.log(p_fixed), q_vals) - eml(np.log(p_fixed), p_fixed)
    eml_term2 = eml(np.log(1 - p_fixed), 1 - q_vals) - eml(np.log(1 - p_fixed), 1 - p_fixed)
    kl_eml = eml_term1 + eml_term2

    ax.plot(q_vals, kl, 'b-', linewidth=2.5, label='KL(P‖Q)')
    ax.plot(q_vals, kl_eml, 'r--', linewidth=2, label='EML decomposition')
    ax.axvline(x=p_fixed, color='g', linestyle=':', label=f'q = p = {p_fixed}')

    ax.set_xlabel('q', fontsize=12)
    ax.set_ylabel('KL divergence', fontsize=12)
    ax.set_title(f'KL(P‖Q) via EML (P = ({p_fixed}, {1-p_fixed}))', fontsize=14)
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)
    ax.set_ylim(0, 5)

    # Right: EML self-entropy landscape
    ax = axes[1]
    p = np.linspace(0.01, 0.99, 200)
    h_eml_binary = (p - np.log(p)) + ((1-p) - np.log(1-p))
    h_shannon = -p * np.log(p) - (1-p) * np.log(1-p)

    ax.plot(p, h_eml_binary, 'b-', linewidth=2, label='H_EML(p, 1-p)')
    ax.plot(p, h_shannon, 'r-', linewidth=2, label='H_Shannon(p, 1-p)')
    ax.axhline(y=2, color='b', linestyle=':', alpha=0.5, label='EML lower bound = 2')
    ax.axhline(y=np.log(2), color='r', linestyle=':', alpha=0.5, label=f'Shannon max = ln(2)')

    ax.set_xlabel('p', fontsize=12)
    ax.set_ylabel('Entropy', fontsize=12)
    ax.set_title('Binary Entropy Comparison', fontsize=14)
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig(os.path.join(OUTPUT_DIR, 'eml_kl_divergence.png'), dpi=150)
    plt.close()
    print("✓ KL divergence decomposition plot saved")

# ============================================================
# Main
# ============================================================

if __name__ == '__main__':
    print("=" * 60)
    print("EML Operator Explorer — Generating Visualizations")
    print("=" * 60)

    demo_eml_surface()
    demo_eml_level_curves()
    demo_gmap_convergence()
    demo_sigma_eml()
    demo_diagonal_dynamics()
    demo_eml_entropy()
    demo_fixed_point()
    demo_decomposition()
    demo_convexity()
    demo_optimal_transport()
    demo_bregman()
    demo_kl_divergence()

    print("\n" + "=" * 60)
    print("All visualizations generated successfully!")
    print("=" * 60)
