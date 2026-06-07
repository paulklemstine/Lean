#!/usr/bin/env python3
"""
Demo: EML Network Approximation via Stone-Weierstrass

Demonstrates that finite combinations of exp with +, *, and scalar multiplication
can approximate any continuous function on a compact interval.
"""

import numpy as np

def eml_basis(x, k):
    """k-th EML basis function: exp(k*x) normalized."""
    return np.exp(k * x)

def eml_approx(x, target_fn, n_terms=10, interval=(-1, 1)):
    """
    Approximate target_fn on interval using n_terms EML basis functions.
    Uses least-squares fitting of sum of c_k * exp(k*x).
    """
    a, b = interval
    # Sample points for fitting
    n_samples = max(100, 5 * n_terms)
    x_fit = np.linspace(a, b, n_samples)
    y_fit = target_fn(x_fit)
    
    # Build basis matrix
    A = np.column_stack([eml_basis(x_fit, k) for k in range(n_terms)])
    
    # Least squares solve
    coeffs, _, _, _ = np.linalg.lstsq(A, y_fit, rcond=None)
    
    # Evaluate approximation
    A_eval = np.column_stack([eml_basis(x, k) for k in range(n_terms)])
    return A_eval @ coeffs, coeffs

def demo_approximation():
    """Demonstrate EML approximation of various functions."""
    x = np.linspace(-1, 1, 1000)
    
    targets = {
        "x^2": lambda t: t**2,
        "sin(pi*x)": lambda t: np.sin(np.pi * t),
        "|x|": lambda t: np.abs(t),
        "x^3 - x": lambda t: t**3 - t,
    }
    
    print("=" * 70)
    print("EML Network Approximation Demo (Stone-Weierstrass)")
    print("=" * 70)
    
    for name, fn in targets.items():
        print(f"\nTarget: f(x) = {name}")
        print("-" * 40)
        for n in [3, 5, 10, 20]:
            approx, coeffs = eml_approx(x, fn, n_terms=n)
            error = np.max(np.abs(fn(x) - approx))
            print(f"  {n:3d} terms: max error = {error:.6e}")
    
    # Demonstrate the power depth-2 representation
    print("\n" + "=" * 70)
    print("Depth-2 Power Representation: x^n = exp(n * log(x))")
    print("=" * 70)
    x_pos = np.linspace(0.01, 2, 100)
    for n in [2, 3, 5, 10]:
        direct = x_pos ** n
        eml_rep = np.exp(n * np.log(x_pos))
        error = np.max(np.abs(direct - eml_rep))
        print(f"  x^{n:2d}: max |x^n - exp(n*log(x))| = {error:.2e}")
    
    # Demonstrate separation property
    print("\n" + "=" * 70)
    print("Separation Property: exp(x) separates distinct points")
    print("=" * 70)
    pairs = [(0.0, 0.1), (1.0, 1.001), (-1.0, 1.0), (0.5, 0.500001)]
    for x1, x2 in pairs:
        sep = abs(np.exp(x1) - np.exp(x2))
        print(f"  x={x1:.6f}, y={x2:.6f}: |exp(x)-exp(y)| = {sep:.2e}")

    # Lipschitz approximation rate
    print("\n" + "=" * 70)
    print("Lipschitz Approximation Rate")
    print("=" * 70)
    print("For L-Lipschitz f on [a,b], width O(L(b-a)/eps) suffices")
    L = 1.0  # Lipschitz constant for sin
    a, b_val = 0, 1
    for eps in [0.1, 0.01, 0.001]:
        width = int(np.ceil(L * (b_val - a) / (2 * eps)))
        x_test = np.linspace(a, b_val, 1000)
        approx, _ = eml_approx(x_test, np.sin, n_terms=width, interval=(a, b_val))
        actual_err = np.max(np.abs(np.sin(x_test) - approx))
        print(f"  eps={eps:.3f}: predicted width={width}, "
              f"actual max error={actual_err:.6e}")

if __name__ == "__main__":
    demo_approximation()


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


#!/usr/bin/env python3
"""
Visualization: EML Depth-Width Tradeoff

Shows the relationship between EML chain depth and
the functions that can be exactly represented.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt

x = np.linspace(0.1, 3, 500)

fig, axes = plt.subplots(1, 3, figsize=(15, 5))
fig.suptitle("EML Depth Hierarchy: Exact Representations", fontsize=15, fontweight='bold')

# Depth 0: identity
ax = axes[0]
ax.set_title("Depth 0: Affine", fontsize=12)
for a, b in [(1, 0), (2, -1), (0.5, 1)]:
    ax.plot(x, a * x + b, label=f'{a}x + {b}')
ax.legend()
ax.grid(True, alpha=0.3)
ax.set_xlabel('x')

# Depth 1: exp(ax + b)
ax = axes[1]
ax.set_title("Depth 1: exp(ax + b)", fontsize=12)
for a, b in [(1, 0), (0.5, -1), (-1, 2)]:
    ax.plot(x, np.exp(a * x + b), label=f'exp({a}x + {b})')
ax.legend()
ax.grid(True, alpha=0.3)
ax.set_xlabel('x')

# Depth 2: x^n = exp(n log x)
ax = axes[2]
ax.set_title("Depth 2: $x^n$ = exp(n·log x)", fontsize=12)
for n in [2, 3, 5]:
    direct = x ** n
    eml = np.exp(n * np.log(x))
    ax.plot(x, direct, '-', linewidth=2, label=f'$x^{n}$ (direct)')
    ax.plot(x, eml, '--', linewidth=1, label=f'exp({n}·log x)')
ax.legend(fontsize=8)
ax.grid(True, alpha=0.3)
ax.set_xlabel('x')
ax.set_ylim(0, 30)

plt.tight_layout()
plt.savefig('viz_depth_tradeoff.png', dpi=150, bbox_inches='tight')
print("Saved viz_depth_tradeoff.png")


#!/usr/bin/env python3
"""
Visualization: EML Separation Property

Shows how exp separates points and the multivariate separation structure.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt

fig, axes = plt.subplots(1, 3, figsize=(15, 5))
fig.suptitle("EML Separation Properties", fontsize=15, fontweight='bold')

# Plot 1: exp separates points
ax = axes[0]
x = np.linspace(-2, 2, 500)
ax.plot(x, np.exp(x), 'b-', linewidth=2)
pairs = [(-1, 0.5), (0, 1), (-0.5, 1.5)]
for x1, x2 in pairs:
    ax.plot([x1, x2], [np.exp(x1), np.exp(x2)], 'ro-', markersize=6)
    ax.annotate(f'gap={abs(np.exp(x1)-np.exp(x2)):.2f}',
                xy=((x1+x2)/2, (np.exp(x1)+np.exp(x2))/2),
                fontsize=8, ha='center')
ax.set_title("exp(x) Separates Points", fontsize=12)
ax.set_xlabel('x')
ax.set_ylabel('exp(x)')
ax.grid(True, alpha=0.3)

# Plot 2: Separation gap vs distance
ax = axes[1]
base_points = np.linspace(-2, 2, 20)
for delta in [0.01, 0.1, 0.5]:
    gaps = np.abs(np.exp(base_points + delta) - np.exp(base_points))
    ax.plot(base_points, gaps, '-o', markersize=3, label=f'δ={delta}')
ax.set_title("Separation Gap |exp(x+δ) - exp(x)|", fontsize=12)
ax.set_xlabel('x')
ax.set_ylabel('Gap')
ax.legend()
ax.grid(True, alpha=0.3)
ax.set_yscale('log')

# Plot 3: Multivariate separation (2D)
ax = axes[2]
np.random.seed(42)
points = np.random.randn(10, 2) * 0.5
for i in range(len(points)):
    for j in range(i+1, len(points)):
        x1, x2 = points[i], points[j]
        # Find separating coordinate
        diffs = np.abs(x1 - x2)
        sep_coord = np.argmax(diffs)
        color = 'red' if sep_coord == 0 else 'blue'
        ax.plot([x1[0], x2[0]], [x1[1], x2[1]], '-', color=color, alpha=0.2)
ax.scatter(points[:, 0], points[:, 1], c='black', s=50, zorder=5)
ax.set_title("Multivariate: Separating Coordinates", fontsize=12)
ax.set_xlabel('$x_1$')
ax.set_ylabel('$x_2$')
ax.legend(['coord 0 sep.', 'coord 1 sep.'], fontsize=8)
ax.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('viz_separation.png', dpi=150, bbox_inches='tight')
print("Saved viz_separation.png")
