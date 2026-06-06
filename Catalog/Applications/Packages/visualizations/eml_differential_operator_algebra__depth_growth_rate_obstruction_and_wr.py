"""
Visualization: Growth Rate Obstruction for Airy Solutions

This script creates a visualization comparing the growth rates of EML functions
at various depths with the growth of Airy function solutions. The key insight
is that Airy solutions grow like exp(2x^{3/2}/3), which is "between" the growth
classes available to EML functions of any fixed depth.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt

def create_growth_comparison():
    """Create the growth comparison plot."""
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

    # Left panel: log-scale growth comparison
    x = np.linspace(0.5, 8, 200)

    # Depth 0: polynomial growth
    poly_growth = x**3

    # Depth 1: exponential growth
    exp_growth = np.exp(x)
    exp2_growth = np.exp(2*x)

    # Airy growth: exp(2/3 * x^{3/2})
    airy_growth = np.exp(2/3 * x**(1.5))

    ax1.semilogy(x, poly_growth, 'b-', linewidth=2, label='$x^3$ (depth 0)')
    ax1.semilogy(x, exp_growth, 'g-', linewidth=2, label='$e^x$ (depth 1)')
    ax1.semilogy(x, airy_growth, 'r-', linewidth=3, label='$e^{2x^{3/2}/3}$ (Airy)')
    ax1.semilogy(x, exp2_growth, 'g--', linewidth=2, label='$e^{2x}$ (depth 1)')

    ax1.set_xlabel('x', fontsize=14)
    ax1.set_ylabel('Function value (log scale)', fontsize=14)
    ax1.set_title('Growth Rate Obstruction', fontsize=16)
    ax1.legend(fontsize=11, loc='upper left')
    ax1.grid(True, alpha=0.3)
    ax1.set_ylim([1e-1, 1e15])

    # Right panel: the exponent comparison
    x2 = np.linspace(1, 20, 200)

    # Exponents of different growth classes
    linear_exp = x2  # exp(x)
    quadratic_exp = x2**2  # exp(x^2) - depth 1 can do this via exp(x^2)
    airy_exp = 2/3 * x2**1.5  # Airy exponent

    ax2.plot(x2, linear_exp, 'g-', linewidth=2, label='$x$ (in $e^x$)')
    ax2.plot(x2, airy_exp, 'r-', linewidth=3, label='$\\frac{2}{3}x^{3/2}$ (Airy exponent)')
    ax2.plot(x2, quadratic_exp, 'm--', linewidth=2, label='$x^2$ (in $e^{x^2}$)')
    ax2.fill_between(x2, linear_exp, airy_exp, alpha=0.15, color='red',
                      label='Gap: $x < \\frac{2}{3}x^{3/2}$ but $< x^2$')

    ax2.set_xlabel('x', fontsize=14)
    ax2.set_ylabel('Exponent value', fontsize=14)
    ax2.set_title('Airy Exponent is Non-EML', fontsize=16)
    ax2.legend(fontsize=10, loc='upper left')
    ax2.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('Applications/EMLDiffEq/growth_obstruction.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved growth_obstruction.png")


def create_wronskian_plot():
    """Create plot showing Abel's identity for Airy equation."""
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

    # Numerical Airy solutions via RK4
    def solve_airy(y0, yp0, x_range, n=2000):
        x0, x1 = x_range
        h = (x1 - x0) / n
        xs, ys, yps = [x0], [y0], [yp0]
        x, y, yp = x0, y0, yp0
        for _ in range(n):
            k1y, k1yp = yp, x * y
            k2y, k2yp = yp + 0.5*h*k1yp, (x + 0.5*h) * (y + 0.5*h*k1y)
            k3y, k3yp = yp + 0.5*h*k2yp, (x + 0.5*h) * (y + 0.5*h*k2y)
            k4y, k4yp = yp + h*k3yp, (x + h) * (y + h*k3y)
            y += h/6 * (k1y + 2*k2y + 2*k3y + k4y)
            yp += h/6 * (k1yp + 2*k2yp + 2*k3yp + k4yp)
            x += h
            xs.append(x); ys.append(y); yps.append(yp)
        return np.array(xs), np.array(ys), np.array(yps)

    xs, y1, y1p = solve_airy(1, 0, (-10, 5))
    _, y2, y2p = solve_airy(0, 1, (-10, 5))

    # Plot solutions
    ax1.plot(xs, y1, 'b-', linewidth=2, label='$y_1$ (Ai-like)')
    ax1.plot(xs, y2, 'r-', linewidth=2, label='$y_2$ (Bi-like)')
    ax1.set_xlabel('x', fontsize=14)
    ax1.set_ylabel('y', fontsize=14)
    ax1.set_title('Airy Equation Solutions', fontsize=16)
    ax1.legend(fontsize=12)
    ax1.grid(True, alpha=0.3)
    ax1.set_ylim([-2, 3])

    # Wronskian
    W = y1 * y2p - y2 * y1p
    ax2.plot(xs, W, 'k-', linewidth=2, label='$W(x) = y_1 y_2\' - y_2 y_1\'$')
    ax2.axhline(y=W[0], color='r', linestyle='--', alpha=0.7, label=f'$W(0) = {W[0]:.4f}$')
    ax2.set_xlabel('x', fontsize=14)
    ax2.set_ylabel('Wronskian', fontsize=14)
    ax2.set_title("Abel's Identity: W = const (p=0)", fontsize=16)
    ax2.legend(fontsize=12)
    ax2.grid(True, alpha=0.3)
    ax2.set_ylim([W[0]-0.1, W[0]+0.1])

    plt.tight_layout()
    plt.savefig('Applications/EMLDiffEq/wronskian_airy.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved wronskian_airy.png")


def create_depth_filtration_diagram():
    """Visualize the depth filtration of the EML algebra."""
    fig, ax = plt.subplots(figsize=(10, 8))

    # Draw boxes for each depth level
    levels = [
        (0, 'Rational Functions\n$\\frac{P(x)}{Q(x)}$', '#E3F2FD',
         ['$x$', '$x^2+1$', '$\\frac{1}{x}$', '$\\frac{x^2-1}{x+3}$']),
        (1, 'Depth-1 EML\n$\\exp, \\log$ of rationals', '#E8F5E9',
         ['$e^x$', '$\\ln x$', '$e^x - \\ln x$', '$\\frac{e^x}{x}$']),
        (2, 'Depth-2 EML\n$\\exp(\\exp), \\log(\\log)$, etc.', '#FFF3E0',
         ['$e^{e^x}$', '$\\ln(\\ln x)$', '$e^{x \\ln x}$']),
        (3, 'Depth-3+ EML\nHigher nesting', '#FCE4EC',
         ['$e^{e^{e^x}}$', '$\\ln(e^{\\ln x} + 1)$']),
    ]

    for depth, label, color, examples in levels:
        y = 6 - 1.8 * depth
        rect = plt.Rectangle((0.5, y - 0.7), 9, 1.4, facecolor=color,
                              edgecolor='black', linewidth=2)
        ax.add_patch(rect)
        ax.text(1.2, y + 0.3, f'Depth {depth}: {label}', fontsize=12, fontweight='bold',
                va='center')
        ex_str = ',  '.join(examples)
        ax.text(1.2, y - 0.3, f'Examples: {ex_str}', fontsize=10, va='center',
                style='italic')

    # Arrow showing differentiation preserves depth
    ax.annotate('', xy=(8.5, 1.5), xytext=(8.5, 5.8),
                arrowprops=dict(arrowstyle='<->', color='red', lw=2))
    ax.text(8.7, 3.7, '$\\frac{d}{dx}$\npreserves\ndepth', fontsize=13,
            color='red', fontweight='bold', ha='left')

    # Airy solution annotation
    ax.annotate('Airy: $e^{\\frac{2}{3}x^{3/2}}$\n(NOT EML — fractional power)',
                xy=(5, 0.3), fontsize=13, color='purple', fontweight='bold',
                ha='center',
                bbox=dict(boxstyle='round,pad=0.3', facecolor='#F3E5F5',
                          edgecolor='purple', linewidth=2))

    ax.set_xlim(0, 10)
    ax.set_ylim(-0.5, 7)
    ax.set_aspect('equal')
    ax.axis('off')
    ax.set_title('EML Depth Filtration: A Tower of Function Classes', fontsize=18,
                 fontweight='bold', pad=20)

    plt.tight_layout()
    plt.savefig('Applications/EMLDiffEq/depth_filtration.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved depth_filtration.png")


if __name__ == '__main__':
    create_growth_comparison()
    create_wronskian_plot()
    create_depth_filtration_diagram()
    print("\nAll visualizations created!")
