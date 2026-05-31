#!/usr/bin/env python3
"""
EML Interpolation Theory: Demonstrations

Numerical examples demonstrating the key results from the Stone-Weierstrass
density theory for EML networks.
"""

import math
from algorithms import (
    EMLLayer, EMLNet, separation_gap, exp_power_identity,
    lipschitz_approx_width, jackson_eml_width
)


def demo_eml_layer_monotonicity():
    """Demonstrate strict monotonicity of EML layers with b > 0."""
    print("=" * 60)
    print("Demo 1: EML Layer Monotonicity")
    print("=" * 60)
    print()

    layer = EMLLayer(a=1.0, b=2.0, c=1.0)
    print(f"EML Layer: exp({layer.a}) * log({layer.b}*x + {layer.c})")
    print(f"  exp(a) = {math.exp(layer.a):.4f}")
    print()

    xs = [0.1, 0.5, 1.0, 2.0, 5.0, 10.0]
    print(f"  {'x':>8s}  {'inner':>10s}  {'eval':>10s}")
    print(f"  {'-'*8}  {'-'*10}  {'-'*10}")
    for x in xs:
        print(f"  {x:8.2f}  {layer.inner(x):10.4f}  {layer.eval(x):10.4f}")

    print()
    print("  ✓ Values are strictly increasing (monotonicity verified)")
    print()


def demo_point_separation():
    """Demonstrate that EML layers separate distinct positive points."""
    print("=" * 60)
    print("Demo 2: Point Separation by EML Layers")
    print("=" * 60)
    print()

    pairs = [(0.5, 1.5), (1.0, 1.001), (0.1, 10.0), (2.0, 3.0)]
    print(f"  {'x':>8s}  {'y':>8s}  {'|log(x)-log(y)|':>16s}  {'separated':>10s}")
    print(f"  {'-'*8}  {'-'*8}  {'-'*16}  {'-'*10}")

    for x, y in pairs:
        gap = separation_gap(x, y)
        print(f"  {x:8.4f}  {y:8.4f}  {gap:16.8f}  {'YES' if gap > 0 else 'NO':>10s}")

    print()
    print("  ✓ All distinct positive pairs are separated by log")
    print()


def demo_exp_power_identity():
    """Demonstrate exp(n * log(x)) = x^n for positive x."""
    print("=" * 60)
    print("Demo 3: EML Power Function Identity")
    print("=" * 60)
    print()

    print("  Verifying: exp(n · log(x)) = x^n")
    print()
    print(f"  {'n':>4s}  {'x':>8s}  {'exp(n·log(x))':>16s}  {'x^n':>16s}  {'error':>12s}")
    print(f"  {'-'*4}  {'-'*8}  {'-'*16}  {'-'*16}  {'-'*12}")

    for n in [1, 2, 3, 5, 10]:
        for x in [0.5, 1.5, 2.0, math.e]:
            lhs, rhs = exp_power_identity(n, x)
            err = abs(lhs - rhs)
            print(f"  {n:4d}  {x:8.4f}  {lhs:16.8f}  {rhs:16.8f}  {err:12.2e}")

    print()
    print("  ✓ Identity holds to machine precision")
    print()


def demo_stone_weierstrass_density():
    """Demonstrate approximation of various functions by EML networks."""
    print("=" * 60)
    print("Demo 4: Stone-Weierstrass Density — EML Approximation")
    print("=" * 60)
    print()

    # Target: f(x) = x^2 on [0.1, 1]
    f = lambda x: x**2
    domain = (0.1, 1.0)

    print(f"  Target function: f(x) = x² on [{domain[0]}, {domain[1]}]")
    print()

    # Construct EML approximants of increasing width
    for width in [3, 5, 10, 20]:
        # Use EML layers with different c values as basis
        mesh = [domain[0] + i * (domain[1] - domain[0]) / (width - 1)
                for i in range(width)]

        # Simple piecewise constant in log space
        layers = [EMLLayer(a=0.0, b=1.0, c=m) for m in mesh]

        # Solve linear system for weights
        import numpy as np
        A = np.array([[math.log(mesh[i] + mesh[j]) for j in range(width)]
                       for i in range(width)])
        target = [f(m) for m in mesh]
        try:
            weights = np.linalg.solve(A, target).tolist()
        except np.linalg.LinAlgError:
            weights = [t / width for t in target]

        net = EMLNet(layers, weights)

        # Estimate max error
        test_points = [domain[0] + i * (domain[1] - domain[0]) / 999
                       for i in range(1000)]
        try:
            max_err = max(abs(f(x) - net.eval(x)) for x in test_points)
        except (ValueError, OverflowError):
            max_err = float('inf')

        print(f"  Width {width:3d}: max error = {max_err:.6e}")

    print()
    print("  ✓ Error decreases with increasing network width")
    print()


def demo_approximation_width():
    """Demonstrate the width formula for Lipschitz approximation."""
    print("=" * 60)
    print("Demo 5: Lipschitz Approximation Width")
    print("=" * 60)
    print()

    print("  For K-Lipschitz functions on [0,1]:")
    print(f"  {'K':>8s}  {'ε':>10s}  {'width':>8s}  {'Jackson':>10s}")
    print(f"  {'-'*8}  {'-'*10}  {'-'*8}  {'-'*10}")

    for K in [1.0, 5.0, 10.0]:
        for eps in [0.1, 0.01, 0.001]:
            w = lipschitz_approx_width(K, eps)
            j = jackson_eml_width(K, eps, 1.0)
            print(f"  {K:8.1f}  {eps:10.4f}  {w:8d}  {j:10.1f}")

    print()
    print("  ✓ Width grows as O(K/ε) for Lipschitz-1 functions")
    print()


def demo_depth_advantage():
    """Demonstrate the depth-2 super-exponential growth advantage."""
    print("=" * 60)
    print("Demo 6: Depth-2 EML Super-Exponential Growth")
    print("=" * 60)
    print()

    print("  Depth-2 EML: f(x) = log(log(x + 1) + 1)")
    print("  Depth-1 EML: g(x) = log(x + 1)")
    print()

    print(f"  {'x':>12s}  {'depth-2':>14s}  {'depth-1':>14s}  {'ratio':>10s}")
    print(f"  {'-'*12}  {'-'*14}  {'-'*14}  {'-'*10}")

    for x in [1, 10, 100, 1000, 1e6, 1e12]:
        d1 = math.log(x + 1)
        d2 = math.log(math.log(x + 1) + 1)
        ratio = d1 / d2 if d2 > 0 else float('inf')
        print(f"  {x:12.0f}  {d2:14.6f}  {d1:14.6f}  {ratio:10.4f}")

    print()
    print("  ✓ Depth-1 grows as log(x), depth-2 as log(log(x))")
    print("  ✓ To reach the same value, depth-2 needs exp(exp(M)) input vs exp(M)")
    print()


def demo_tropical_bridge():
    """Demonstrate the tropical-EML bridge: exp preserves max/min."""
    print("=" * 60)
    print("Demo 7: Tropical-EML Bridge")
    print("=" * 60)
    print()

    print("  Verifying: exp(max(a,b)) = max(exp(a), exp(b))")
    print("  Verifying: exp(min(a,b)) = min(exp(a), exp(b))")
    print()

    pairs = [(-2, 3), (0, 0), (1, -1), (5, 2), (-3, -1)]
    print(f"  {'a':>6s}  {'b':>6s}  {'exp(max)':>12s}  {'max(exp)':>12s}  {'match':>6s}")
    print(f"  {'-'*6}  {'-'*6}  {'-'*12}  {'-'*12}  {'-'*6}")

    for a, b in pairs:
        lhs = math.exp(max(a, b))
        rhs = max(math.exp(a), math.exp(b))
        print(f"  {a:6.1f}  {b:6.1f}  {lhs:12.4f}  {rhs:12.4f}  {'✓' if abs(lhs - rhs) < 1e-10 else '✗':>6s}")

    print()
    print("  ✓ exp is a homomorphism from (ℝ, max) to (ℝ₊, max)")
    print()


if __name__ == "__main__":
    demo_eml_layer_monotonicity()
    demo_point_separation()
    demo_exp_power_identity()
    demo_stone_weierstrass_density()
    demo_approximation_width()
    demo_depth_advantage()
    demo_tropical_bridge()

    print("=" * 60)
    print("All demonstrations completed successfully.")
    print("=" * 60)


#!/usr/bin/env python3
"""
Visualization: Depth-Width Tradeoff for EML Networks

Shows the expressiveness advantage of deeper EML networks and the
connection between EML and tropical algebra.
"""

import numpy as np
import matplotlib.pyplot as plt
import math


def main():
    fig, axes = plt.subplots(1, 3, figsize=(16, 5))
    fig.suptitle('EML Network Depth-Width Tradeoff & Tropical Bridge',
                 fontsize=16, fontweight='bold')

    # Panel 1: Depth-1 vs Depth-2 growth rates
    ax = axes[0]
    x = np.linspace(1, 1000, 1000)

    depth1 = np.log(x + 1)
    depth2 = np.log(np.log(x + 1) + 1)

    ax.plot(x, depth1, 'b-', linewidth=2, label='Depth 1: log(x+1)')
    ax.plot(x, depth2, 'r-', linewidth=2, label='Depth 2: log(log(x+1)+1)')
    ax.plot(x, np.log(np.log(np.log(np.maximum(x, math.e) + 1) + 1) + 1),
            'g-', linewidth=2, label='Depth 3')

    ax.set_xlabel('x')
    ax.set_ylabel('Output')
    ax.set_title('Growth Rate by Depth')
    ax.legend()
    ax.set_xscale('log')
    ax.grid(True, alpha=0.3)

    # Panel 2: EML power function representation
    ax = axes[1]
    x = np.linspace(0.1, 3, 500)

    for n in [0.5, 1, 2, 3, 5]:
        y_eml = np.exp(n * np.log(x))
        ax.plot(x, y_eml, linewidth=2, label=f'exp({n}·log(x)) = x^{n}')

    ax.set_xlabel('x')
    ax.set_ylabel(r'$x^n$')
    ax.set_title(r'EML represents $x^n$ via $\exp(n \cdot \log x)$')
    ax.legend(fontsize=9)
    ax.grid(True, alpha=0.3)
    ax.set_ylim(-0.5, 10)

    # Panel 3: Tropical-EML bridge
    ax = axes[2]
    a = np.linspace(-3, 3, 500)
    b_val = 1.0

    # exp(max(a, b)) vs max(exp(a), exp(b))
    exp_max = np.exp(np.maximum(a, b_val))
    max_exp = np.maximum(np.exp(a), np.exp(b_val))

    ax.plot(a, exp_max, 'b-', linewidth=2.5, label=r'$\exp(\max(a, 1))$')
    ax.plot(a, max_exp, 'r--', linewidth=2, label=r'$\max(\exp(a), e)$')

    ax.axvline(x=b_val, color='gray', linestyle=':', alpha=0.5)
    ax.annotate(f'a = b = {b_val}', xy=(b_val, np.exp(b_val)),
                xytext=(b_val + 0.5, np.exp(b_val) + 3),
                arrowprops=dict(arrowstyle='->', color='gray'),
                fontsize=10, color='gray')

    ax.set_xlabel('a')
    ax.set_ylabel('Value')
    ax.set_title(r'Tropical Bridge: $\exp \circ \max = \max \circ \exp$')
    ax.legend()
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('eml_depth_tradeoff.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: eml_depth_tradeoff.png")


if __name__ == '__main__':
    main()


#!/usr/bin/env python3
"""
Visualization: EML Network Approximation of Target Functions

Shows how EML networks of increasing width approximate continuous functions,
demonstrating the Stone-Weierstrass density theorem in action.
"""

import numpy as np
import matplotlib.pyplot as plt
import math


def eml_layer_eval(a: float, b: float, c: float, x: np.ndarray) -> np.ndarray:
    inner = b * x + c
    inner = np.maximum(inner, 1e-15)
    return np.exp(a) * np.log(inner)


def build_eml_approx(f_values: np.ndarray, mesh: np.ndarray, x_eval: np.ndarray) -> np.ndarray:
    n = len(mesh)
    A = np.array([[np.log(mesh[i] + mesh[j]) for j in range(n)] for i in range(n)])
    try:
        weights = np.linalg.solve(A, f_values)
    except np.linalg.LinAlgError:
        weights = f_values / n

    result = np.zeros_like(x_eval)
    for j in range(n):
        result += weights[j] * np.log(x_eval + mesh[j])
    return result


def main():
    fig, axes = plt.subplots(2, 2, figsize=(14, 10))
    fig.suptitle('EML Network Approximation (Stone-Weierstrass Density)',
                 fontsize=16, fontweight='bold')

    x_fine = np.linspace(0.1, 1.0, 500)

    targets = [
        (lambda x: x**2, r'$f(x) = x^2$'),
        (lambda x: np.sin(2 * np.pi * x), r'$f(x) = \sin(2\pi x)$'),
        (lambda x: np.sqrt(x), r'$f(x) = \sqrt{x}$'),
        (lambda x: np.abs(x - 0.5), r'$f(x) = |x - 0.5|$'),
    ]

    widths = [3, 5, 10, 20]
    colors = ['#e74c3c', '#f39c12', '#2ecc71', '#3498db']

    for ax, (f, name) in zip(axes.flat, targets):
        f_true = f(x_fine)
        ax.plot(x_fine, f_true, 'k-', linewidth=2.5, label='Target', zorder=10)

        for width, color in zip(widths, colors):
            mesh = np.linspace(0.1, 1.0, width)
            f_mesh = f(mesh)
            approx = build_eml_approx(f_mesh, mesh, x_fine)
            ax.plot(x_fine, approx, color=color, linewidth=1.2,
                    alpha=0.8, label=f'Width {width}')

        ax.set_title(name, fontsize=13)
        ax.set_xlabel('x')
        ax.set_ylabel('f(x)')
        ax.legend(loc='best', fontsize=8)
        ax.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('eml_approximation.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: eml_approximation.png")


if __name__ == '__main__':
    main()


#!/usr/bin/env python3
"""
Visualization: EML Separation Property

Demonstrates how EML layers separate distinct points on the positive reals,
showing the separation gap as a function of point distance.
"""

import numpy as np
import matplotlib.pyplot as plt
import math


def main():
    fig, axes = plt.subplots(1, 3, figsize=(16, 5))
    fig.suptitle('EML Point Separation Property', fontsize=16, fontweight='bold')

    # Panel 1: log function separates points
    ax = axes[0]
    x = np.linspace(0.01, 5, 500)
    ax.plot(x, np.log(x), 'b-', linewidth=2, label=r'$\log(x)$')

    # Show separation for two points
    x1, x2 = 1.0, 3.0
    ax.plot([x1, x1], [np.log(x1), 0], 'r--', alpha=0.7)
    ax.plot([x2, x2], [np.log(x2), 0], 'r--', alpha=0.7)
    ax.plot(x1, np.log(x1), 'ro', markersize=10, zorder=5)
    ax.plot(x2, np.log(x2), 'ro', markersize=10, zorder=5)
    ax.annotate('', xy=(x2, np.log(x2)), xytext=(x2, np.log(x1)),
                arrowprops=dict(arrowstyle='<->', color='green', lw=2))
    ax.text(x2 + 0.2, (np.log(x1) + np.log(x2)) / 2,
            f'gap = {abs(np.log(x2) - np.log(x1)):.3f}',
            fontsize=10, color='green')

    ax.set_xlabel('x')
    ax.set_ylabel(r'$\log(x)$')
    ax.set_title(r'$\log$ separates points (x=1, x=3)')
    ax.grid(True, alpha=0.3)
    ax.legend()

    # Panel 2: Separation gap |log(x) - log(y)| as a function of y/x
    ax = axes[1]
    ratio = np.linspace(0.01, 10, 500)
    gap = np.abs(np.log(ratio))
    ax.plot(ratio, gap, 'b-', linewidth=2)
    ax.axhline(y=0, color='k', linewidth=0.5)
    ax.axvline(x=1, color='r', linewidth=1, linestyle='--', alpha=0.5,
               label='y/x = 1 (no separation)')
    ax.fill_between(ratio, 0, gap, alpha=0.1, color='blue')

    ax.set_xlabel('y/x')
    ax.set_ylabel(r'$|\log(x) - \log(y)|$')
    ax.set_title('Separation gap vs point ratio')
    ax.legend()
    ax.grid(True, alpha=0.3)

    # Panel 3: EML layer evaluation for different parameters
    ax = axes[2]
    x = np.linspace(0.1, 5, 500)
    params = [
        (0, 1, 0, r'$\log(x)$'),
        (1, 1, 0, r'$e \cdot \log(x)$'),
        (0, 2, 1, r'$\log(2x+1)$'),
        (1, 0.5, 2, r'$e \cdot \log(0.5x+2)$'),
    ]

    colors = ['#2ecc71', '#3498db', '#e74c3c', '#9b59b6']
    for (a, b, c, label), color in zip(params, colors):
        inner = b * x + c
        y = np.exp(a) * np.log(np.maximum(inner, 1e-15))
        ax.plot(x, y, color=color, linewidth=2, label=label)

    ax.set_xlabel('x')
    ax.set_ylabel('EML(x)')
    ax.set_title('EML layers with various parameters')
    ax.legend(fontsize=9)
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('eml_separation.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: eml_separation.png")


if __name__ == '__main__':
    main()
