#!/usr/bin/env python3
"""
EML Stone-Weierstrass: Demonstration of Exp-Log Network Approximation Theory

This script demonstrates:
1. EML generators and their separation property
2. Approximation of continuous functions by EML networks
3. The tropical (Maslov) deformation limit
4. Depth hierarchy: depth-2 vs depth-1 expressiveness
"""

import numpy as np

def eml_generator(x: np.ndarray, w: float, b: float) -> np.ndarray:
    """EML affine-exponential generator: exp(w*x + b)"""
    return np.exp(w * x + b)

def log_sum_exp(a: float, b: float, t: float) -> float:
    """Smoothed max: (1/t) * log(exp(t*a) + exp(t*b))"""
    # Numerically stable computation
    m = max(t * a, t * b)
    return (1/t) * (m + np.log(np.exp(t*a - m) + np.exp(t*b - m)))

def demo_separation():
    """Demonstrate that EML generators separate points."""
    print("=" * 60)
    print("Demo 1: EML Separation Property")
    print("=" * 60)
    x, y = 1.0, 2.0
    print(f"Points: x = {x}, y = {y}")
    print(f"exp(x) = {np.exp(x):.6f}, exp(y) = {np.exp(y):.6f}")
    print(f"exp(x) ≠ exp(y): {np.exp(x) != np.exp(y)}")
    print()

    # Multiple generators
    params = [(1, 0), (2, -1), (0.5, 3)]
    for w, b in params:
        gx = eml_generator(np.array([x]), w, b)[0]
        gy = eml_generator(np.array([y]), w, b)[0]
        print(f"  exp({w}*x + {b}): g({x}) = {gx:.4f}, g({y}) = {gy:.4f}, separated: {gx != gy}")
    print()

def demo_approximation():
    """Demonstrate EML approximation of target functions."""
    print("=" * 60)
    print("Demo 2: EML Approximation of x² on [0, 1]")
    print("=" * 60)

    x = np.linspace(0, 1, 100)
    target = x**2

    # Simple EML approximation using linear combination of generators
    # f(x) ≈ c₁*exp(w₁*x+b₁) + c₂*exp(w₂*x+b₂) + c₃
    # Fit by least squares on sample points
    from numpy.linalg import lstsq

    # Basis functions
    basis = np.column_stack([
        eml_generator(x, 1.0, 0.0),
        eml_generator(x, -1.0, 0.0),
        eml_generator(x, 2.0, -1.0),
        eml_generator(x, 0.5, 0.5),
        np.ones_like(x)
    ])

    coeffs, _, _, _ = lstsq(basis, target, rcond=None)
    approx = basis @ coeffs
    error = np.max(np.abs(target - approx))

    print(f"  Using 4 EML generators + constant")
    print(f"  Coefficients: {coeffs}")
    print(f"  Max error: {error:.6e}")
    print(f"  Mean error: {np.mean(np.abs(target - approx)):.6e}")
    print()

def demo_tropical_limit():
    """Demonstrate the Maslov dequantization: log-sum-exp → max."""
    print("=" * 60)
    print("Demo 3: Tropical Limit (Maslov Dequantization)")
    print("=" * 60)

    a, b = 2.0, 5.0
    print(f"  a = {a}, b = {b}, max(a,b) = {max(a,b)}")
    print()
    print(f"  {'t':>10s}  {'(1/t)·log(exp(ta)+exp(tb))':>30s}  {'|error|':>10s}")
    print(f"  {'-'*10}  {'-'*30}  {'-'*10}")

    for t in [0.1, 0.5, 1, 2, 5, 10, 50, 100, 1000]:
        val = log_sum_exp(a, b, t)
        err = abs(val - max(a, b))
        print(f"  {t:>10.1f}  {val:>30.10f}  {err:>10.2e}")
    print()
    print("  → Converges to max(a, b) = 5.0 as t → ∞")
    print()

def demo_depth_hierarchy():
    """Demonstrate the strict depth hierarchy."""
    print("=" * 60)
    print("Demo 4: Depth Hierarchy — exp(exp(x)) vs exp(wx+b)")
    print("=" * 60)

    x_vals = np.array([-1.0, 0.0, 1.0, 2.0])

    depth2 = np.exp(np.exp(x_vals))
    print(f"  Depth-2: exp(exp(x))")
    for xi, yi in zip(x_vals, depth2):
        print(f"    x = {xi:5.1f}: exp(exp(x)) = {yi:.4f}")

    # Try to fit exp(wx+b) to match depth-2 at x=0 and x=1
    # exp(b) = exp(1) → b = 1
    # exp(w+b) = exp(e) → w = e - 1
    w = np.e - 1
    b = 1.0
    depth1 = np.exp(w * x_vals + b)

    print(f"\n  Best depth-1 fit: exp({w:.4f}*x + {b:.4f})")
    for xi, d2, d1 in zip(x_vals, depth2, depth1):
        print(f"    x = {xi:5.1f}: depth-2 = {d2:.4f}, depth-1 = {d1:.4f}, ratio = {d2/d1:.4f}")

    print(f"\n  The functions diverge dramatically — depth-2 grows doubly exponentially")
    print(f"  while depth-1 grows singly exponentially. No reparametrization can fix this.")
    print()

if __name__ == "__main__":
    demo_separation()
    demo_approximation()
    demo_tropical_limit()
    demo_depth_hierarchy()
    print("All demos completed successfully.")


#!/usr/bin/env python3
"""
Visualization: EML Depth Hierarchy

Shows that depth-2 EML functions (exp(exp(x))) are fundamentally
different from depth-1 functions (exp(wx+b)), demonstrating the
strict depth hierarchy proven in depth2_not_affine_exp.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt

def main():
    x = np.linspace(-1, 2, 300)

    # Depth-2: exp(exp(x))
    depth2 = np.exp(np.exp(x))

    # Best depth-1 fits matching at different point pairs
    # Fit 1: match at x=0, x=1
    # exp(b) = exp(1) = e → b = 1
    # exp(w+1) = exp(e) → w = e-1
    w1, b1 = np.e - 1, 1.0
    fit1 = np.exp(w1 * x + b1)

    # Fit 2: match at x=-1, x=0
    # exp(-w+b) = exp(exp(-1)) → -w+b = exp(-1)
    # exp(b) = exp(1) = e → b = 1
    # → w = 1 - exp(-1)
    w2, b2 = 1 - np.exp(-1), 1.0
    fit2 = np.exp(w2 * x + b2)

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

    # Linear scale
    ax1.plot(x, depth2, 'b-', linewidth=2.5, label='Depth-2: exp(exp(x))')
    ax1.plot(x, fit1, 'r--', linewidth=2, label=f'Depth-1: exp({w1:.3f}x + {b1:.1f})')
    ax1.plot(x, fit2, 'g--', linewidth=2, label=f'Depth-1: exp({w2:.3f}x + {b2:.1f})')
    ax1.set_xlabel('x', fontsize=12)
    ax1.set_ylabel('f(x)', fontsize=12)
    ax1.set_title('Linear Scale', fontsize=14)
    ax1.legend(fontsize=10)
    ax1.grid(True, alpha=0.3)
    ax1.set_ylim(0, 100)

    # Log scale
    ax2.semilogy(x, depth2, 'b-', linewidth=2.5, label='Depth-2: exp(exp(x))')
    ax2.semilogy(x, fit1, 'r--', linewidth=2, label=f'Depth-1: exp({w1:.3f}x + {b1:.1f})')
    ax2.semilogy(x, fit2, 'g--', linewidth=2, label=f'Depth-1: exp({w2:.3f}x + {b2:.1f})')
    ax2.set_xlabel('x', fontsize=12)
    ax2.set_ylabel('f(x) (log scale)', fontsize=12)
    ax2.set_title('Logarithmic Scale', fontsize=14)
    ax2.legend(fontsize=10)
    ax2.grid(True, alpha=0.3)

    fig.suptitle('EML Depth Hierarchy: Depth-2 ≠ Depth-1', fontsize=16, y=1.02)
    plt.tight_layout()
    plt.savefig('depth_hierarchy_visualization.png', dpi=150, bbox_inches='tight')
    print("Saved: depth_hierarchy_visualization.png")

if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: EML Approximation of Continuous Functions

Demonstrates the Stone-Weierstrass density result by showing how
EML generators can approximate various target functions with
increasing accuracy as more generators are added.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt

def eml_generator(x: np.ndarray, w: float, b: float) -> np.ndarray:
    return np.exp(np.clip(w * x + b, -500, 500))

def fit_eml(x: np.ndarray, target: np.ndarray,
            params: list) -> tuple:
    basis = np.column_stack(
        [eml_generator(x, w, b) for w, b in params] + [np.ones_like(x)]
    )
    coeffs, _, _, _ = np.linalg.lstsq(basis, target, rcond=None)
    approx = basis @ coeffs
    return approx, float(np.max(np.abs(target - approx)))

def main():
    x = np.linspace(0, 1, 200)
    targets = {
        'x²': x**2,
        'sin(2πx)': np.sin(2 * np.pi * x),
        '|x - 0.5|': np.abs(x - 0.5),
    }

    generator_sets = [
        [(1, 0), (-1, 0)],
        [(1, 0), (-1, 0), (2, -1), (-2, 1)],
        [(1, 0), (-1, 0), (2, -1), (-2, 1), (3, -2), (-3, 2), (0.5, 0.5), (-0.5, -0.5)],
        [(i*0.7, j*0.5) for i in range(-3, 4) for j in range(-2, 3)],
    ]
    n_gens = [len(g) for g in generator_sets]

    fig, axes = plt.subplots(len(targets), len(generator_sets), figsize=(18, 10))

    for row, (name, target) in enumerate(targets.items()):
        for col, (params, ng) in enumerate(zip(generator_sets, n_gens)):
            ax = axes[row, col]
            approx, error = fit_eml(x, target, params)
            ax.plot(x, target, 'b-', linewidth=2, alpha=0.7, label='Target')
            ax.plot(x, approx, 'r--', linewidth=1.5, label=f'EML (n={ng})')
            ax.fill_between(x, target, approx, alpha=0.15, color='red')
            ax.set_title(f'{name}, {ng} gens\nerror = {error:.2e}', fontsize=10)
            ax.grid(True, alpha=0.3)
            if row == 0 and col == 0:
                ax.legend(fontsize=8)

    fig.suptitle('EML Approximation: Stone-Weierstrass in Action', fontsize=16, y=1.02)
    plt.tight_layout()
    plt.savefig('eml_approximation_visualization.png', dpi=150, bbox_inches='tight')
    print("Saved: eml_approximation_visualization.png")

if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: Tropical Deformation Limit

Shows how log-sum-exp converges to max as the temperature parameter t → ∞.
This is the Maslov dequantization that bridges EML networks to tropical geometry.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt

def log_sum_exp_2d(x: np.ndarray, a: float, b: float, t: float) -> np.ndarray:
    """(1/t) * log(exp(t*(a*x+c1)) + exp(t*(b*x+c2))) for tropical max of two lines."""
    u = t * (a * x + 1.0)
    v = t * (b * x - 0.5)
    m = np.maximum(u, v)
    return (1.0/t) * (m + np.log(np.exp(u - m) + np.exp(v - m)))

def main():
    x = np.linspace(-2, 2, 500)

    # Two linear functions whose max gives a tropical polynomial
    line1 = 0.8 * x + 1.0
    line2 = -0.5 * x - 0.5
    tropical_max = np.maximum(line1, line2)

    fig, axes = plt.subplots(2, 3, figsize=(14, 8))

    t_values = [0.5, 1.0, 2.0, 5.0, 20.0, 100.0]

    for ax, t in zip(axes.flatten(), t_values):
        smooth = log_sum_exp_2d(x, 0.8, -0.5, t)
        ax.plot(x, line1, 'b--', alpha=0.4, label='f₁(x)')
        ax.plot(x, line2, 'r--', alpha=0.4, label='f₂(x)')
        ax.plot(x, tropical_max, 'k-', linewidth=2, alpha=0.3, label='max(f₁, f₂)')
        ax.plot(x, smooth, 'g-', linewidth=2, label=f'LSE (t={t})')
        ax.set_title(f't = {t}', fontsize=14)
        ax.set_ylim(-2.5, 3.5)
        ax.legend(fontsize=8)
        ax.grid(True, alpha=0.3)

    fig.suptitle('Maslov Dequantization: log-sum-exp → max as t → ∞', fontsize=16, y=1.02)
    plt.tight_layout()
    plt.savefig('tropical_limit_visualization.png', dpi=150, bbox_inches='tight')
    print("Saved: tropical_limit_visualization.png")

if __name__ == "__main__":
    main()
