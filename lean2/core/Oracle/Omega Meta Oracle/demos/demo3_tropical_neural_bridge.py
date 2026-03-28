#!/usr/bin/env python3
"""
Demo 3: Tropical Algebra ↔ Neural Network Bridge

Visualizes the connection between ReLU networks and tropical polynomials,
the LogSumExp/softmax dequantization, and the exp semiring homomorphism.

Run: python3 demo3_tropical_neural_bridge.py
Outputs: tropical_neural_bridge.png
"""

import numpy as np
import matplotlib.pyplot as plt
from matplotlib.gridspec import GridSpec

def relu(x):
    return np.maximum(x, 0)

def softmax(x, temperature=1.0):
    e = np.exp(x / temperature)
    return e / np.sum(e)

def logsumexp(x, temperature=1.0):
    return temperature * np.log(np.sum(np.exp(x / temperature)))

def main():
    fig = plt.figure(figsize=(18, 12))
    gs = GridSpec(2, 3, figure=fig, hspace=0.35, wspace=0.3)

    # --- Panel 1: ReLU as Tropical Addition ---
    ax1 = fig.add_subplot(gs[0, 0])
    ax1.set_title("ReLU = Tropical Addition\n$\\mathrm{ReLU}(x) = \\max(x, 0) = x \\oplus_{\\mathrm{trop}} 0$", fontsize=12)

    x = np.linspace(-3, 3, 200)
    ax1.plot(x, relu(x), 'b-', linewidth=3, label='ReLU(x) = max(x, 0)')
    ax1.plot(x, x, 'g--', linewidth=1, alpha=0.5, label='y = x')
    ax1.plot(x, np.zeros_like(x), 'r--', linewidth=1, alpha=0.5, label='y = 0')
    ax1.fill_between(x, relu(x), alpha=0.1, color='blue')

    ax1.axvline(x=0, color='k', linewidth=0.5, alpha=0.3)
    ax1.axhline(y=0, color='k', linewidth=0.5, alpha=0.3)
    ax1.set_xlabel('x', fontsize=11)
    ax1.set_ylabel('ReLU(x)', fontsize=11)
    ax1.legend(fontsize=9)
    ax1.grid(True, alpha=0.3)

    # Annotate
    ax1.annotate('Tropical\nsemiring:\nmax replaces +',
                xy=(1.5, 1.5), fontsize=9,
                bbox=dict(boxstyle='round', facecolor='lightyellow'))

    # --- Panel 2: Max of Affines = ReLU Network ---
    ax2 = fig.add_subplot(gs[0, 1])
    ax2.set_title("Max of Affines = ReLU Network\nmax(ax+b, cx+d) = ReLU(·) + ·", fontsize=12)

    x = np.linspace(-3, 3, 200)
    a, b, c, d = 2, -1, -0.5, 1

    f1 = a * x + b
    f2 = c * x + d
    max_f = np.maximum(f1, f2)
    relu_form = relu(f1 - f2) + f2

    ax2.plot(x, f1, 'b--', linewidth=1, alpha=0.5, label=f'{a}x + ({b})')
    ax2.plot(x, f2, 'r--', linewidth=1, alpha=0.5, label=f'{c}x + ({d})')
    ax2.plot(x, max_f, 'g-', linewidth=3, label='max(·, ·)')
    ax2.plot(x, relu_form, 'k:', linewidth=2, label='ReLU(·) + ·')

    # Mark the breakpoint
    x_break = (d - b) / (a - c)
    y_break = a * x_break + b
    ax2.plot(x_break, y_break, 'ro', markersize=10, zorder=5)
    ax2.annotate(f'Breakpoint\n({x_break:.2f}, {y_break:.2f})',
                xy=(x_break, y_break), xytext=(x_break + 0.5, y_break + 1),
                fontsize=9, arrowprops=dict(arrowstyle='->'))

    ax2.set_xlabel('x', fontsize=11)
    ax2.legend(fontsize=8)
    ax2.grid(True, alpha=0.3)

    # --- Panel 3: Tropical Dequantization ---
    ax3 = fig.add_subplot(gs[0, 2])
    ax3.set_title("Tropical Dequantization\n$\\epsilon \\cdot \\log\\sum e^{x_i/\\epsilon} \\to \\max(x_i)$",
                  fontsize=12)

    values = np.array([1.0, 3.0, 2.0, 0.5, -1.0])
    true_max = np.max(values)
    temperatures = np.logspace(-2, 2, 200)

    soft_maxes = [logsumexp(values, t) for t in temperatures]

    ax3.semilogx(temperatures, soft_maxes, 'b-', linewidth=2, label='LogSumExp(x; ε)')
    ax3.axhline(y=true_max, color='r', linestyle='--', linewidth=1.5,
               label=f'max(x) = {true_max}')
    ax3.axhline(y=true_max + np.log(len(values)), color='orange', linestyle=':',
               linewidth=1, label=f'max + ln(n) = {true_max + np.log(len(values)):.2f}')

    ax3.fill_between(temperatures, true_max, soft_maxes, alpha=0.1, color='blue')

    ax3.set_xlabel('Temperature ε', fontsize=11)
    ax3.set_ylabel('Soft-max value', fontsize=11)
    ax3.legend(fontsize=8)
    ax3.grid(True, alpha=0.3)

    ax3.annotate('ε → 0:\nTropical limit\n(hard max)',
                xy=(0.01, 3.05), fontsize=9,
                bbox=dict(boxstyle='round', facecolor='lightyellow'))
    ax3.annotate('ε → ∞:\nSmooth average',
                xy=(10, 1.5), fontsize=9,
                bbox=dict(boxstyle='round', facecolor='lightyellow'))

    # --- Panel 4: Softmax Temperature Sweep ---
    ax4 = fig.add_subplot(gs[1, 0])
    ax4.set_title("Softmax Temperature Sweep\nCool → Hot = argmax → uniform", fontsize=12)

    temps = [0.1, 0.5, 1.0, 2.0, 10.0]
    values = np.array([1.0, 3.0, 2.0, 0.5, -1.0])
    x_pos = np.arange(len(values))
    bar_width = 0.15

    colors_temp = plt.cm.coolwarm(np.linspace(0, 1, len(temps)))

    for i, (temp, color) in enumerate(zip(temps, colors_temp)):
        sm = softmax(values, temp)
        ax4.bar(x_pos + i * bar_width, sm, bar_width, color=color,
               label=f'T={temp}', alpha=0.8)

    ax4.set_xlabel('Component index', fontsize=11)
    ax4.set_ylabel('Softmax probability', fontsize=11)
    ax4.set_xticks(x_pos + bar_width * 2)
    ax4.set_xticklabels([f'x={v}' for v in values])
    ax4.legend(fontsize=8)
    ax4.grid(True, alpha=0.3, axis='y')

    # --- Panel 5: exp as Semiring Homomorphism ---
    ax5 = fig.add_subplot(gs[1, 1])
    ax5.set_title("exp: Semiring Homomorphism\n$(\\mathbb{R}, \\max, +) \\to (\\mathbb{R}_+, +, \\times)$",
                  fontsize=12)

    x = np.linspace(-2, 3, 200)
    y = np.linspace(-2, 3, 200)

    # Show exp(max(x,y)) = max(exp(x), exp(y))
    X, Y = np.meshgrid(x, y)
    lhs = np.exp(np.maximum(X, Y))
    rhs = np.maximum(np.exp(X), np.exp(Y))
    error = np.abs(lhs - rhs)

    im = ax5.pcolormesh(X, Y, np.log10(error + 1e-16), cmap='RdYlGn_r', shading='auto',
                       vmin=-16, vmax=0)
    plt.colorbar(im, ax=ax5, label='log₁₀(error)')

    ax5.set_xlabel('x', fontsize=11)
    ax5.set_ylabel('y', fontsize=11)
    ax5.set_aspect('equal')

    ax5.annotate('Error ≡ 0\n(exact identity)\nexp(max(x,y)) =\nmax(exp(x), exp(y))',
                xy=(0.5, 0.5), fontsize=9, color='white',
                bbox=dict(boxstyle='round', facecolor='black', alpha=0.5))

    # --- Panel 6: Full Pipeline Visualization ---
    ax6 = fig.add_subplot(gs[1, 2])
    ax6.set_title("The Full Pipeline\nSmooth → Tropical → Combinatorial", fontsize=12)

    # Show a smooth function and its tropicalization
    x = np.linspace(-3, 3, 500)

    # Original smooth function (sum of Gaussians)
    smooth = 2 * np.exp(-(x - 1)**2) + 1.5 * np.exp(-(x + 1)**2 / 0.5) + 0.5

    # Tropical approximation (piecewise linear)
    tropical = np.maximum(np.maximum(-np.abs(x - 1) + 2, -2 * np.abs(x + 1) + 1.5), 0.5)

    ax6.plot(x, smooth, 'b-', linewidth=2, label='Smooth function')
    ax6.plot(x, tropical, 'r-', linewidth=2, label='Tropical approximation')

    # Mark the max
    i_max_smooth = np.argmax(smooth)
    i_max_trop = np.argmax(tropical)

    ax6.plot(x[i_max_smooth], smooth[i_max_smooth], 'b*', markersize=15, zorder=10)
    ax6.plot(x[i_max_trop], tropical[i_max_trop], 'r*', markersize=15, zorder=10)

    ax6.annotate(f'Smooth max\n({x[i_max_smooth]:.2f}, {smooth[i_max_smooth]:.2f})',
                xy=(x[i_max_smooth], smooth[i_max_smooth]),
                xytext=(x[i_max_smooth] + 1, smooth[i_max_smooth] + 0.3),
                fontsize=8, arrowprops=dict(arrowstyle='->', color='blue'))

    ax6.set_xlabel('x', fontsize=11)
    ax6.set_ylabel('f(x)', fontsize=11)
    ax6.legend(fontsize=9)
    ax6.grid(True, alpha=0.3)

    # Verification badge
    fig.text(0.5, 0.01,
             '✓ ReLU=max, softmax normalization, exp homomorphism, LogSumExp bounds — all machine-verified in Lean 4',
             ha='center', fontsize=11, style='italic',
             bbox=dict(boxstyle='round,pad=0.3', facecolor='lightgreen', alpha=0.3))

    plt.savefig('demos/tropical_neural_bridge.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("✓ Saved: demos/tropical_neural_bridge.png")

if __name__ == '__main__':
    main()
