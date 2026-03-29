#!/usr/bin/env python3
"""
🔄 Strange Loops — Period Doubling, Fixed Points, and the Road to Chaos

Demonstrates:
1. The logistic map bifurcation diagram (period doubling → chaos)
2. Fixed points and periodic orbits
3. The Mandelbrot set (strange loop iteration z → z² + c)
4. Cobweb diagrams showing convergence to fixed points
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np

def logistic_map(r, x):
    return r * x * (1 - x)

def iterate_logistic(r, x0, n_iterations, n_skip):
    """Iterate the logistic map and return the attractor."""
    x = x0
    for _ in range(n_skip):
        x = logistic_map(r, x)
    results = []
    for _ in range(n_iterations):
        x = logistic_map(r, x)
        results.append(x)
    return results

def mandelbrot(c, max_iter):
    """Compute escape time for the Mandelbrot set."""
    z = 0
    for n in range(max_iter):
        if abs(z) > 2:
            return n
        z = z * z + c
    return max_iter

def cobweb(f, x0, n_steps, ax, r_val):
    """Draw a cobweb diagram."""
    x = np.linspace(0, 1, 300)
    y = f(r_val, x)

    ax.plot(x, y, 'b-', linewidth=2, label=f'f(x) = {r_val}x(1-x)')
    ax.plot(x, x, 'k--', linewidth=1, alpha=0.5, label='y = x')

    # Cobweb
    xn = x0
    path_x, path_y = [xn], [0]
    for _ in range(n_steps):
        yn = f(r_val, xn)
        path_x.extend([xn, yn])
        path_y.extend([yn, yn])
        xn = yn
    path_x.append(xn)
    path_y.append(0)

    ax.plot(path_x, path_y, 'r-', linewidth=0.8, alpha=0.7)
    ax.scatter([x0], [0], c='red', s=50, zorder=5)
    ax.set_xlim(0, 1)
    ax.set_ylim(0, 1)
    ax.set_aspect('equal')

def main():
    fig = plt.figure(figsize=(20, 16))
    fig.suptitle('🔄 Strange Loops: Period Doubling & The Road to Chaos\n'
                 'From fixed points through period doubling to chaos',
                 fontsize=16, fontweight='bold')

    # Panel 1: Bifurcation diagram
    ax1 = fig.add_subplot(2, 2, 1)
    r_values = np.linspace(2.5, 4.0, 2000)
    x0 = 0.5

    for r in r_values:
        attractor = iterate_logistic(r, x0, 200, 300)
        ax1.scatter([r] * len(attractor), attractor, s=0.02, c='navy', alpha=0.3)

    # Mark key bifurcation points
    ax1.axvline(x=3.0, color='red', linestyle='--', alpha=0.3, label='r=3: period 2')
    ax1.axvline(x=3.449, color='orange', linestyle='--', alpha=0.3, label='r≈3.449: period 4')
    ax1.axvline(x=3.5699, color='green', linestyle='--', alpha=0.3, label='r≈3.570: chaos')

    ax1.set_xlabel('r (growth rate)', fontsize=12)
    ax1.set_ylabel('x (attractor)', fontsize=12)
    ax1.set_title('Logistic Map Bifurcation Diagram\nf(x) = rx(1-x)', fontsize=12)
    ax1.legend(fontsize=8, loc='upper left')

    # Panels 2-4: Cobweb diagrams at different r values
    r_vals = [2.8, 3.2, 3.8]
    titles = [
        'r=2.8: Stable Fixed Point\n(convergent strange loop)',
        'r=3.2: Period-2 Cycle\n(oscillating strange loop)',
        'r=3.8: Chaos!\n(the loop shatters)'
    ]

    for idx, (r_val, title) in enumerate(zip(r_vals, titles)):
        ax = fig.add_subplot(2, 2, idx + 2)
        cobweb(logistic_map, 0.1, 80, ax, r_val)
        ax.set_title(title, fontsize=12)
        ax.set_xlabel('x_n', fontsize=11)
        ax.set_ylabel('x_{n+1}', fontsize=11)

    plt.tight_layout()
    plt.savefig('/workspace/request-project/demos/strange_loops_chaos.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("✓ Saved strange_loops_chaos.png")

    # Mandelbrot Set
    fig2, ax = plt.subplots(figsize=(14, 10))
    x_min, x_max = -2.5, 1.0
    y_min, y_max = -1.2, 1.2
    width, height = 1400, 960
    max_iter = 256

    x = np.linspace(x_min, x_max, width)
    y = np.linspace(y_min, y_max, height)
    image = np.zeros((height, width))

    for i in range(height):
        for j in range(width):
            c = complex(x[j], y[i])
            image[i][j] = mandelbrot(c, max_iter)

    ax.imshow(image, extent=[x_min, x_max, y_min, y_max], cmap='hot',
             aspect='auto', interpolation='bilinear')
    ax.set_title('🔄 The Mandelbrot Set\nThe Ultimate Strange Loop: z → z² + c\n'
                 'Fixed points, period-2, period-3, ... all periods coexist',
                 fontsize=14, fontweight='bold')
    ax.set_xlabel('Re(c)', fontsize=12)
    ax.set_ylabel('Im(c)', fontsize=12)

    # Annotate key regions
    ax.annotate('Main cardioid\n(fixed points)', xy=(-0.4, 0), fontsize=10,
               color='white', fontweight='bold', ha='center')
    ax.annotate('Period 2\nbulb', xy=(-1.0, 0), fontsize=10,
               color='white', fontweight='bold', ha='center')
    ax.annotate('Period 3\n(Li-Yorke\nimplies chaos!)', xy=(-0.12, 0.75), fontsize=9,
               color='cyan', fontweight='bold', ha='center')

    plt.tight_layout()
    plt.savefig('/workspace/request-project/demos/mandelbrot.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("✓ Saved mandelbrot.png")

    # Print Feigenbaum constant
    print("\n📊 The Feigenbaum Constant (universality of chaos):")
    print("-" * 60)
    print("  Bifurcation points of logistic map:")
    bifurcation_points = [3.0, 3.44949, 3.54409, 3.5644, 3.5688, 3.56969]
    for i, bp in enumerate(bifurcation_points):
        print(f"    Period {2**(i+1):4d}: r ≈ {bp:.5f}")
    print("\n  Feigenbaum ratio δ ≈ 4.669...")
    for i in range(len(bifurcation_points) - 2):
        d1 = bifurcation_points[i+1] - bifurcation_points[i]
        d2 = bifurcation_points[i+2] - bifurcation_points[i+1]
        if d2 > 0:
            ratio = d1 / d2
            print(f"    δ_{i+1} = {ratio:.4f}")
    print("  → Converges to Feigenbaum's universal constant δ = 4.6692...")
    print("  This constant appears in ALL chaotic systems — a mathematical Area 51 secret!")

if __name__ == "__main__":
    main()
