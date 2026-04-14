#!/usr/bin/env python3
"""
SPB-EML Bridge Visualizer
==========================

Generates matplotlib plots showing key aspects of the SPB-EML bridge:
1. The SPB function surface
2. Cayley transform (ℝ → S¹)
3. Cauchy entropy additivity
4. SPB iteration spirals
5. The conversion diamond diagram

Save plots as PNG files for inclusion in papers.
"""

import numpy as np
import matplotlib.pyplot as plt
from matplotlib.patches import FancyArrowPatch, Circle
import matplotlib.patches as mpatches
from mpl_toolkits.mplot3d import Axes3D


def spb(x, y):
    with np.errstate(divide='ignore', invalid='ignore'):
        result = (x + y) / (1 - x * y)
        result = np.where(np.abs(1 - x * y) < 1e-10, np.nan, result)
    return result


def eml(x, y):
    with np.errstate(divide='ignore', invalid='ignore'):
        return np.exp(x) - np.log(y)


def cayley(x):
    return (1 + 1j * x) / (1 - 1j * x)


# ============================================================
# Plot 1: SPB Surface
# ============================================================

def plot_spb_surface():
    """3D surface plot of spb(x, y)"""
    fig = plt.figure(figsize=(10, 8))
    ax = fig.add_subplot(111, projection='3d')

    x = np.linspace(-2, 2, 200)
    y = np.linspace(-2, 2, 200)
    X, Y = np.meshgrid(x, y)
    Z = spb(X, Y)
    Z = np.clip(Z, -10, 10)

    surf = ax.plot_surface(X, Y, Z, cmap='RdBu_r', alpha=0.85,
                           linewidth=0, antialiased=True)
    ax.set_xlabel('x', fontsize=14)
    ax.set_ylabel('y', fontsize=14)
    ax.set_zlabel('spb(x,y)', fontsize=14)
    ax.set_title('SPB: (x+y)/(1−xy) — The Stereographic Sum', fontsize=16)
    ax.set_zlim(-10, 10)
    fig.colorbar(surf, shrink=0.5, aspect=10)

    plt.savefig('spb_surface.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("  Saved: spb_surface.png")


# ============================================================
# Plot 2: EML Surface
# ============================================================

def plot_eml_surface():
    """3D surface plot of eml(x, y)"""
    fig = plt.figure(figsize=(10, 8))
    ax = fig.add_subplot(111, projection='3d')

    x = np.linspace(-2, 2, 200)
    y = np.linspace(0.01, 5, 200)
    X, Y = np.meshgrid(x, y)
    Z = eml(X, Y)
    Z = np.clip(Z, -5, 15)

    surf = ax.plot_surface(X, Y, Z, cmap='viridis', alpha=0.85,
                           linewidth=0, antialiased=True)
    ax.set_xlabel('x', fontsize=14)
    ax.set_ylabel('y', fontsize=14)
    ax.set_zlabel('eml(x,y)', fontsize=14)
    ax.set_title('EML: eˣ − ln(y) — The Arithmetic Gate', fontsize=16)
    fig.colorbar(surf, shrink=0.5, aspect=10)

    plt.savefig('eml_surface.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("  Saved: eml_surface.png")


# ============================================================
# Plot 3: Cayley Transform
# ============================================================

def plot_cayley_transform():
    """Cayley transform mapping ℝ → S¹"""
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

    # Left: the real line with marked points
    t = np.linspace(-5, 5, 1000)
    ax1.axhline(y=0, color='k', linewidth=0.5)
    ax1.plot(t, np.zeros_like(t), 'b-', linewidth=2, alpha=0.3)

    special_t = [-3, -2, -1, -0.5, 0, 0.5, 1, 2, 3]
    colors = plt.cm.rainbow(np.linspace(0, 1, len(special_t)))

    for ti, c in zip(special_t, colors):
        ax1.plot(ti, 0, 'o', color=c, markersize=10, zorder=5)
        ax1.annotate(f'{ti}', (ti, 0.05), ha='center', fontsize=10)

    ax1.set_xlim(-4, 4)
    ax1.set_ylim(-0.5, 0.5)
    ax1.set_title('Real Line ℝ', fontsize=14)
    ax1.set_xlabel('t', fontsize=12)
    ax1.set_aspect('equal')

    # Right: the unit circle with mapped points
    theta = np.linspace(0, 2*np.pi, 200)
    ax2.plot(np.cos(theta), np.sin(theta), 'k-', linewidth=1)

    for ti, c in zip(special_t, colors):
        ci = cayley(ti)
        ax2.plot(ci.real, ci.imag, 'o', color=c, markersize=10, zorder=5)
        offset = 0.15
        ax2.annotate(f'C({ti})', (ci.real*(1+offset), ci.imag*(1+offset)),
                     ha='center', fontsize=9)

    ax2.set_xlim(-1.5, 1.5)
    ax2.set_ylim(-1.5, 1.5)
    ax2.set_aspect('equal')
    ax2.set_title('Unit Circle S¹', fontsize=14)
    ax2.axhline(y=0, color='k', linewidth=0.3)
    ax2.axvline(x=0, color='k', linewidth=0.3)

    fig.suptitle('Cayley Transform: C(t) = (1+it)/(1−it)', fontsize=16, y=1.02)
    plt.tight_layout()
    plt.savefig('cayley_transform.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("  Saved: cayley_transform.png")


# ============================================================
# Plot 4: Cauchy Entropy
# ============================================================

def plot_cauchy_entropy():
    """The Cauchy entropy H(t) = ln(1+t²) and its SPB additivity"""
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

    # Left: H(t) = ln(1 + t²)
    t = np.linspace(-4, 4, 500)
    H = np.log(1 + t**2)

    ax1.plot(t, H, 'b-', linewidth=2, label='H(t) = ln(1+t²)')
    ax1.fill_between(t, 0, H, alpha=0.1, color='blue')
    ax1.set_xlabel('t', fontsize=12)
    ax1.set_ylabel('H(t)', fontsize=12)
    ax1.set_title('Cauchy Entropy Function', fontsize=14)
    ax1.legend(fontsize=12)
    ax1.grid(True, alpha=0.3)

    # Right: Verify additivity
    x_vals = np.linspace(-1.5, 1.5, 50)
    y_vals = np.linspace(-1.5, 1.5, 50)
    X, Y = np.meshgrid(x_vals, y_vals)

    S = spb(X, Y)
    LHS = np.log(1 + S**2)
    RHS = np.log(1 + X**2) + np.log(1 + Y**2) - 2 * np.log(np.abs(1 - X*Y))
    error = np.abs(LHS - RHS)
    error = np.where(np.abs(1 - X*Y) < 0.01, np.nan, error)

    im = ax2.pcolormesh(X, Y, np.log10(error + 1e-20), cmap='viridis',
                        vmin=-16, vmax=-12)
    ax2.set_xlabel('x', fontsize=12)
    ax2.set_ylabel('y', fontsize=12)
    ax2.set_title('log₁₀(error) in Bridge Identity', fontsize=14)
    plt.colorbar(im, ax=ax2, label='log₁₀|LHS − RHS|')

    plt.tight_layout()
    plt.savefig('cauchy_entropy.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("  Saved: cauchy_entropy.png")


# ============================================================
# Plot 5: SPB Iteration Spiral
# ============================================================

def plot_spb_spiral():
    """SPB iteration on the unit circle via Cayley transform"""
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

    theta = np.pi / 7
    t = np.tan(theta)

    # Left: values on ℝ
    vals = [0]
    for n in range(20):
        vals.append(spb(vals[-1], t))

    ax1.plot(range(len(vals)), vals, 'bo-', markersize=5)
    ax1.set_xlabel('Iteration n', fontsize=12)
    ax1.set_ylabel('spb^n(0, tan(π/7))', fontsize=12)
    ax1.set_title('SPB Iteration on ℝ', fontsize=14)
    ax1.grid(True, alpha=0.3)
    ax1.axhline(y=0, color='k', linewidth=0.5)

    # Right: on S¹ via Cayley
    circle = plt.Circle((0, 0), 1, fill=False, color='k', linewidth=1)
    ax2.add_patch(circle)

    cayley_vals = [cayley(v) for v in vals]
    for i, (cv, v) in enumerate(zip(cayley_vals, vals)):
        color = plt.cm.plasma(i / len(vals))
        ax2.plot(cv.real, cv.imag, 'o', color=color, markersize=6)
        if i > 0:
            prev = cayley_vals[i-1]
            ax2.annotate('', xy=(cv.real, cv.imag),
                         xytext=(prev.real, prev.imag),
                         arrowprops=dict(arrowstyle='->', color=color,
                                        lw=1.5, alpha=0.6))

    ax2.set_xlim(-1.4, 1.4)
    ax2.set_ylim(-1.4, 1.4)
    ax2.set_aspect('equal')
    ax2.set_title('SPB Iteration on S¹ (via Cayley)', fontsize=14)
    ax2.axhline(y=0, color='k', linewidth=0.3)
    ax2.axvline(x=0, color='k', linewidth=0.3)

    plt.tight_layout()
    plt.savefig('spb_spiral.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("  Saved: spb_spiral.png")


# ============================================================
# Plot 6: The Bridge Diamond
# ============================================================

def plot_bridge_diamond():
    """Conceptual diagram of the SPB-EML bridge"""
    fig, ax = plt.subplots(1, 1, figsize=(10, 8))
    ax.set_xlim(-5, 5)
    ax.set_ylim(-4, 5)
    ax.set_aspect('equal')
    ax.axis('off')

    # Nodes
    nodes = {
        'add': (0, 4, '(ℝ, +)\nAddition', '#3498db'),
        'spb': (-4, 0, '(ℝ, spb)\nStereographic\nSum', '#e74c3c'),
        'mul': (4, 0, '(ℝ₊, ×)\nMultiplication', '#2ecc71'),
        'eml': (0, -3, '(ℝ, eml)\nExp-Minus-Log', '#9b59b6'),
    }

    for key, (x, y, label, color) in nodes.items():
        circle = plt.Circle((x, y), 1.2, facecolor=color, alpha=0.2,
                            edgecolor=color, linewidth=2)
        ax.add_patch(circle)
        ax.text(x, y, label, ha='center', va='center', fontsize=11,
                fontweight='bold')

    # Arrows with labels
    arrows = [
        ('spb', 'add', 'arctan', (-2.5, 2.5)),
        ('add', 'mul', 'exp', (2.5, 2.5)),
        ('spb', 'mul', 'exp∘arctan', (0, 0.5)),
        ('eml', 'spb', 'arctan∘(eˣ-ln y)', (-2.5, -2)),
        ('eml', 'mul', 'exp', (2.5, -2)),
        ('add', 'eml', 'x↦eml(x,1)-1', (1.5, 0.5)),
    ]

    for start, end_, label, (lx, ly) in arrows:
        sx, sy = nodes[start][0], nodes[start][1]
        ex, ey = nodes[end_][0], nodes[end_][1]

        # Shorten arrow to not overlap circles
        dx, dy = ex - sx, ey - sy
        dist = np.sqrt(dx**2 + dy**2)
        ux, uy = dx/dist, dy/dist
        sx2, sy2 = sx + 1.3*ux, sy + 1.3*uy
        ex2, ey2 = ex - 1.3*ux, ey - 1.3*uy

        ax.annotate('', xy=(ex2, ey2), xytext=(sx2, sy2),
                    arrowprops=dict(arrowstyle='->', lw=2, color='#333'))
        ax.text(lx, ly, label, ha='center', va='center', fontsize=10,
                style='italic', color='#555',
                bbox=dict(boxstyle='round,pad=0.3', facecolor='white',
                         edgecolor='#ccc', alpha=0.9))

    ax.set_title('The SPB–EML Bridge Diamond\n'
                 'Four algebraic structures, connected by natural homomorphisms',
                 fontsize=16, fontweight='bold', pad=20)

    plt.savefig('bridge_diamond.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("  Saved: bridge_diamond.png")


# ============================================================
# Main
# ============================================================

if __name__ == "__main__":
    print("Generating SPB-EML Bridge visualizations...")
    print()

    plot_spb_surface()
    plot_eml_surface()
    plot_cayley_transform()
    plot_cauchy_entropy()
    plot_spb_spiral()
    plot_bridge_diamond()

    print()
    print("All visualizations generated!")
