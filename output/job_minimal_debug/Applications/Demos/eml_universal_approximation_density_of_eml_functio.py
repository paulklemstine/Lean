#!/usr/bin/env python3
"""
EML Universal Approximation — Demonstration

Demonstrates:
1. EML generators separating points on [0,1]^n
2. EML approximation of various continuous functions
3. Depth hierarchy: iterated exponentials at different depths
4. Width-for-depth tradeoff visualization
"""

import numpy as np
from typing import Callable, List, Tuple

def eml_generator(w: np.ndarray, b: float, x: np.ndarray) -> float:
    """EML exponential generator: exp(w^T x + b)"""
    return np.exp(np.dot(w, x) + b)

def eml_sum_approx(weights: List[Tuple[np.ndarray, float, float]],
                   x: np.ndarray) -> float:
    """Sum of weighted EML generators: ∑ cᵢ exp(wᵢᵀx + bᵢ)"""
    return sum(c * eml_generator(w, b, x) for w, b, c in weights)

def iter_exp(n: int, x: float) -> float:
    """Iterated exponential: E_0(x)=x, E_{n+1}(x)=exp(E_n(x))"""
    result = x
    for _ in range(n):
        result = np.exp(result)
    return result

def eml_chain_leaves(d: int) -> int:
    """Number of leaves in a depth-d EML chain: 2d+1"""
    return 2 * d + 1

def relu_width_for_tower(d: int) -> int:
    """ReLU width needed for depth-d exponential tower: 2^d"""
    return 2 ** d

# === Demo 1: Point Separation ===
print("=" * 60)
print("Demo 1: EML Generators Separate Points on [0,1]^2")
print("=" * 60)

x = np.array([0.3, 0.7])
y = np.array([0.3, 0.5])

# Find separating coordinate
j = np.argmax(np.abs(x - y))
w = np.zeros(2)
w[j] = 1.0

print(f"Point x = {x}")
print(f"Point y = {y}")
print(f"Separating coordinate: j = {j}")
print(f"exp(x_j) = exp({x[j]:.1f}) = {np.exp(x[j]):.6f}")
print(f"exp(y_j) = exp({y[j]:.1f}) = {np.exp(y[j]):.6f}")
print(f"Difference: {abs(np.exp(x[j]) - np.exp(y[j])):.6f}")
print()

# === Demo 2: Approximating |x - 0.5| on [0,1] ===
print("=" * 60)
print("Demo 2: EML Approximation of |x - 0.5| on [0,1]")
print("=" * 60)

target = lambda x: abs(x - 0.5)
xs = np.linspace(0, 1, 100)

# Simple EML approximation using a few exp generators
# f(x) ≈ c₀ + c₁ exp(a₁x + b₁) + c₂ exp(a₂x + b₂) + ...
# Fit by least squares
from numpy.linalg import lstsq

n_generators = 10
A = np.zeros((len(xs), n_generators + 1))
A[:, 0] = 1  # constant term

np.random.seed(42)
params = []
for i in range(n_generators):
    w_i = np.random.uniform(-3, 3)
    b_i = np.random.uniform(-2, 2)
    A[:, i + 1] = np.exp(w_i * xs + b_i)
    params.append((w_i, b_i))

target_vals = np.array([target(x) for x in xs])
coeffs, _, _, _ = lstsq(A, target_vals, rcond=None)

approx_vals = A @ coeffs
max_error = np.max(np.abs(target_vals - approx_vals))

print(f"Using {n_generators} EML generators")
print(f"Max approximation error: {max_error:.6f}")
print(f"Mean approximation error: {np.mean(np.abs(target_vals - approx_vals)):.6f}")
print()

# === Demo 3: Depth Hierarchy ===
print("=" * 60)
print("Demo 3: Iterated Exponential Depth Hierarchy")
print("=" * 60)

x_val = 0.5
for n in range(6):
    val = iter_exp(n, x_val)
    print(f"E_{n}({x_val}) = {val:.6e}  (requires EML depth {n})")
print()

# === Demo 4: Width-for-Depth Tradeoff ===
print("=" * 60)
print("Demo 4: Width-for-Depth Tradeoff (EML vs ReLU)")
print("=" * 60)

print(f"{'Depth':>6} | {'EML leaves':>12} | {'ReLU width':>12} | {'Ratio':>10}")
print("-" * 48)
for d in range(1, 16):
    eml_w = eml_chain_leaves(d)
    relu_w = relu_width_for_tower(d)
    ratio = relu_w / eml_w
    print(f"{d:>6} | {eml_w:>12} | {relu_w:>12} | {ratio:>10.1f}")
print()

# === Demo 5: Lipschitz Bounds ===
print("=" * 60)
print("Demo 5: EML Neuron Lipschitz Bounds on [0,1]")
print("=" * 60)

for w_val, b_val in [(1, 0), (2, 1), (5, 0), (10, -3)]:
    lip_bound = abs(w_val) * np.exp(abs(w_val) + abs(b_val))
    # Empirical Lipschitz constant
    xs_fine = np.linspace(0, 1, 10000)
    vals = np.exp(w_val * xs_fine + b_val)
    emp_lip = np.max(np.abs(np.diff(vals)) / np.abs(np.diff(xs_fine)))
    print(f"exp({w_val}x + {b_val:+d}): "
          f"Theoretical Lip ≤ {lip_bound:.2f}, "
          f"Empirical Lip ≈ {emp_lip:.2f}")
print()

# === Demo 6: Polynomial Bridge ===
print("=" * 60)
print("Demo 6: Polynomials Embedded in EML (depth 0)")
print("=" * 60)

# x^3 - 2x^2 + x + 1 is directly an EML expression
poly = lambda x: x**3 - 2*x**2 + x + 1
print("Polynomial p(x) = x³ - 2x² + x + 1")
print("EML expression: add(mul(mul(var, var), var), add(neg(mul(const(2), mul(var, var))), add(var, const(1))))")
print()
for x_test in [0, 0.25, 0.5, 0.75, 1.0]:
    print(f"  p({x_test}) = {poly(x_test):.6f}")
print(f"\nPolynomial represented at EML depth 0 (no exp needed)")
print(f"EML can ALSO represent exp(x) at depth 1 — strictly extending polynomials")

print("\n" + "=" * 60)
print("All demos completed successfully.")
print("=" * 60)


#!/usr/bin/env python3
"""
Visualization: EML Depth-Width Tradeoff

Shows the exponential gap between EML chain leaves (linear) and ReLU width
(exponential) as a function of depth.
"""

import numpy as np

try:
    import matplotlib
    matplotlib.use('Agg')
    import matplotlib.pyplot as plt

    depths = np.arange(1, 21)
    eml_leaves = 2 * depths + 1
    relu_width = 2.0 ** depths

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

    # Left: absolute comparison (log scale)
    ax1.semilogy(depths, eml_leaves, 'b-o', label='EML chain leaves (2d+1)', markersize=5)
    ax1.semilogy(depths, relu_width, 'r-s', label='ReLU width (2^d)', markersize=5)
    ax1.fill_between(depths, eml_leaves, relu_width, alpha=0.2, color='green',
                     label='EML advantage region')
    ax1.set_xlabel('Composition Depth d', fontsize=12)
    ax1.set_ylabel('Parameters / Width', fontsize=12)
    ax1.set_title('EML vs ReLU: Parameter Efficiency', fontsize=14)
    ax1.legend(fontsize=10)
    ax1.grid(True, alpha=0.3)
    ax1.set_xticks(depths[::2])

    # Right: ratio
    ratio = relu_width / eml_leaves
    ax2.semilogy(depths, ratio, 'g-^', markersize=6, linewidth=2)
    ax2.set_xlabel('Composition Depth d', fontsize=12)
    ax2.set_ylabel('ReLU Width / EML Leaves', fontsize=12)
    ax2.set_title('Depth Advantage Ratio (diverges to ∞)', fontsize=14)
    ax2.grid(True, alpha=0.3)
    ax2.set_xticks(depths[::2])

    # Annotate key points
    for d in [5, 10, 15, 20]:
        idx = d - 1
        ax2.annotate(f'{ratio[idx]:.0f}x',
                    xy=(depths[idx], ratio[idx]),
                    xytext=(5, 10), textcoords='offset points',
                    fontsize=9, ha='left')

    plt.tight_layout()
    plt.savefig('depth_tradeoff.png', dpi=150, bbox_inches='tight')
    print("Saved depth_tradeoff.png")

except ImportError:
    print("matplotlib not available; skipping visualization")


#!/usr/bin/env python3
"""
Visualization: EML Approximation of Continuous Functions

Shows how sums of EML generators exp(w*x + b) approximate various
continuous functions on [0,1].
"""

import numpy as np

try:
    import matplotlib
    matplotlib.use('Agg')
    import matplotlib.pyplot as plt

    def greedy_eml_fit(f, xs, n_gen, seed=42):
        rng = np.random.default_rng(seed)
        target = np.array([f(x) for x in xs])
        A = np.ones((len(xs), n_gen + 1))
        params = []
        for i in range(n_gen):
            w = rng.uniform(-5, 5)
            b = rng.uniform(-3, 3)
            A[:, i + 1] = np.exp(w * xs + b)
            params.append((w, b))
        coeffs, _, _, _ = np.linalg.lstsq(A, target, rcond=None)
        return A @ coeffs, np.max(np.abs(target - A @ coeffs))

    xs = np.linspace(0, 1, 500)

    functions = [
        (lambda x: abs(x - 0.5), '|x - 0.5|'),
        (lambda x: np.sin(4 * np.pi * x), 'sin(4πx)'),
        (lambda x: np.where(x < 0.5, 0.0, 1.0), 'step(x - 0.5)'),
        (lambda x: x * np.sin(10 * x), 'x·sin(10x)'),
    ]

    fig, axes = plt.subplots(2, 2, figsize=(14, 10))

    for ax, (f, name) in zip(axes.flat, functions):
        target = np.array([f(x) for x in xs])
        
        for n_gen, color, ls in [(5, 'orange', '--'), (15, 'green', '-.'), (50, 'red', '-')]:
            approx, err = greedy_eml_fit(f, xs, n_gen)
            ax.plot(xs, approx, color=color, linestyle=ls, linewidth=1.5,
                   label=f'N={n_gen} (err={err:.4f})', alpha=0.8)
        
        ax.plot(xs, target, 'b-', linewidth=2, label=f'Target: {name}')
        ax.set_title(f'EML Approximation of {name}', fontsize=12)
        ax.legend(fontsize=8, loc='best')
        ax.grid(True, alpha=0.3)
        ax.set_xlim(0, 1)

    plt.suptitle('EML Universal Approximation on [0,1]', fontsize=14, y=1.02)
    plt.tight_layout()
    plt.savefig('eml_approximation.png', dpi=150, bbox_inches='tight')
    print("Saved eml_approximation.png")

except ImportError:
    print("matplotlib not available; skipping visualization")
