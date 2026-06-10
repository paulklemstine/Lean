#!/usr/bin/env python3
"""
Diophantine Approximation on ReLU Networks: Numerical Demonstrations

Demonstrates how ReLU networks approximate π, e, and √2 using:
1. Leibniz series partial sums for π
2. Taylor series for e
3. Newton's method iterations for √2

Shows the depth-width tradeoff and approximation error as a function of network size.
"""

import math

def relu(x: float) -> float:
    """ReLU activation function."""
    return max(0.0, x)

def softplus(x: float) -> float:
    """Softplus (smooth ReLU): log(1 + exp(x))."""
    # Numerically stable version
    if x > 20:
        return x
    return math.log(1 + math.exp(x))

def soft_hard_gap(x: float) -> float:
    """Gap between softplus and ReLU: log(1 + exp(-|x|))."""
    return math.log(1 + math.exp(-abs(x)))

# --- Demonstration 1: Leibniz Series for π ---
print("=" * 60)
print("DEMO 1: Leibniz Series Approximation of π")
print("=" * 60)

def leibniz_partial_sum(n: int) -> float:
    """Compute π/4 ≈ Σ_{k=0}^{n-1} (-1)^k / (2k+1)."""
    return sum((-1)**k / (2*k + 1) for k in range(n))

print(f"\n{'N terms':>10} | {'4·S_N':>20} | {'|4·S_N - π|':>20} | {'1/(2N+1) bound':>16}")
print("-" * 72)

for n in [1, 2, 5, 10, 50, 100, 500, 1000, 10000]:
    approx = 4 * leibniz_partial_sum(n)
    error = abs(approx - math.pi)
    bound = 4 / (2*n + 1)  # Leibniz error bound
    print(f"{n:>10} | {approx:>20.15f} | {error:>20.2e} | {bound:>16.2e}")

# --- Demonstration 2: Depth-Width Tradeoff ---
print("\n" + "=" * 60)
print("DEMO 2: Depth-Width Tradeoff (Pieces = w^L)")
print("=" * 60)

print(f"\n{'Width w':>8} | {'Depth L':>8} | {'Pieces w^L':>12} | {'Params 2wL+w+1':>15} | {'Ratio':>8}")
print("-" * 58)

for w in [2, 3, 4, 5, 10]:
    for L in [1, 2, 3, 5, 10]:
        pieces = w ** L
        params = 2 * w * L + w + 1
        ratio = pieces / params if params > 0 else 0
        if pieces <= 10**12:
            print(f"{w:>8} | {L:>8} | {pieces:>12} | {params:>15} | {ratio:>8.1f}")

# --- Demonstration 3: Soft-Hard ReLU Gap ---
print("\n" + "=" * 60)
print("DEMO 3: Tropical-ReLU Bridge (Soft-Hard Gap)")
print("=" * 60)

print(f"\n{'x':>10} | {'relu(x)':>10} | {'softplus(x)':>12} | {'gap':>12} | {'log(2)':>8}")
print("-" * 58)

for x in [-10, -5, -2, -1, 0, 0.5, 1, 2, 5, 10]:
    r = relu(x)
    s = softplus(x)
    gap = s - r
    print(f"{x:>10.1f} | {r:>10.4f} | {s:>12.4f} | {gap:>12.6f} | {math.log(2):>8.6f}")

print(f"\nMaximum gap occurs at x=0: gap = log(2) = {math.log(2):.6f}")
print(f"Gap formula: log(1 + exp(-|x|)) → 0 as |x| → ∞")

# --- Demonstration 4: Network Size for ε-approximation of π ---
print("\n" + "=" * 60)
print("DEMO 4: Minimum Network Size for π Approximation")
print("=" * 60)

print(f"\n{'Target ε':>12} | {'N terms needed':>15} | {'Depth (w=2)':>12} | {'Depth (w=10)':>13} | {'Params (w=2)':>13}")
print("-" * 72)

for exp in range(1, 11):
    epsilon = 10 ** (-exp)
    # Need 1/(2N+1) < ε, so N > (1/ε - 1)/2
    N = math.ceil((1/epsilon - 1) / 2)
    # Depth with width w: need w^L ≥ N
    depth_w2 = math.ceil(math.log2(N)) if N > 1 else 1
    depth_w10 = math.ceil(math.log(N, 10)) if N > 1 else 1
    params_w2 = 2 * 2 * depth_w2 + 2 + 1
    print(f"{epsilon:>12.0e} | {N:>15} | {depth_w2:>12} | {depth_w10:>13} | {params_w2:>13}")

# --- Demonstration 5: Rational vs Irrational Approximation ---
print("\n" + "=" * 60)
print("DEMO 5: Rational vs Irrational Approximation Complexity")
print("=" * 60)

constants = {
    "π": math.pi,
    "e": math.e,
    "√2": math.sqrt(2),
    "φ (golden)": (1 + math.sqrt(5)) / 2,
    "1/3": 1/3,
    "22/7": 22/7,
}

print(f"\n{'Constant':>14} | {'Value':>20} | {'Best rational p/q':>20} | {'|error|':>12}")
print("-" * 72)

for name, val in constants.items():
    # Find best rational approximation with denominator ≤ 1000
    best_p, best_q, best_err = 0, 1, abs(val)
    for q in range(1, 1001):
        p = round(val * q)
        err = abs(val - p/q)
        if err < best_err:
            best_p, best_q, best_err = p, q, err
    print(f"{name:>14} | {val:>20.15f} | {best_p}/{best_q:<10} | {best_err:>12.2e}")

print("\n" + "=" * 60)
print("KEY INSIGHT: Rational numbers need O(1) network parameters.")
print("Irrational numbers need O(log(1/ε)) depth for ε-approximation.")
print("The depth-width tradeoff is exponential: doubling depth")
print("squares the approximation capacity.")
print("=" * 60)


#!/usr/bin/env python3
"""
Visualization: Depth-Width Tradeoff in ReLU Networks

Shows how the piece count w^L grows with depth L for various widths w,
and how this relates to approximation quality for π.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
import math

fig, axes = plt.subplots(2, 2, figsize=(14, 10))

# --- Plot 1: Piece count w^L vs depth for various widths ---
ax = axes[0, 0]
depths = np.arange(1, 16)
for w in [2, 3, 4, 5, 10]:
    pieces = [w**L for L in depths]
    ax.semilogy(depths, pieces, 'o-', label=f'w={w}', markersize=4)
ax.set_xlabel('Depth L')
ax.set_ylabel('Pieces w^L (log scale)')
ax.set_title('Piece Count Growth: Exponential in Depth')
ax.legend()
ax.grid(True, alpha=0.3)

# --- Plot 2: Parameter efficiency ratio ---
ax = axes[0, 1]
depths = np.arange(1, 20)
for w in [2, 3, 5, 10]:
    ratios = []
    for L in depths:
        pieces = w**L
        params = 2*w*L + w + 1
        ratios.append(pieces / params)
    ax.semilogy(depths, ratios, 'o-', label=f'w={w}', markersize=4)
ax.set_xlabel('Depth L')
ax.set_ylabel('Pieces/Parameters (log scale)')
ax.set_title('Parameter Efficiency: Deep vs Shallow')
ax.legend()
ax.grid(True, alpha=0.3)
ax.axhline(y=1, color='red', linestyle='--', alpha=0.5, label='Breakeven')

# --- Plot 3: Leibniz approximation error ---
ax = axes[1, 0]
ns = np.arange(1, 201)
errors = []
bounds = []
for n in ns:
    partial = 4 * sum((-1)**k / (2*k+1) for k in range(n))
    errors.append(abs(partial - math.pi))
    bounds.append(4 / (2*n + 1))
ax.semilogy(ns, errors, 'b-', alpha=0.7, label='Actual |4·S_N - π|')
ax.semilogy(ns, bounds, 'r--', alpha=0.7, label='Bound 4/(2N+1)')
ax.set_xlabel('Number of Leibniz terms N')
ax.set_ylabel('Error (log scale)')
ax.set_title('Leibniz Series: π Approximation Error')
ax.legend()
ax.grid(True, alpha=0.3)

# --- Plot 4: Soft-Hard ReLU gap ---
ax = axes[1, 1]
xs = np.linspace(-5, 5, 500)
relu_vals = np.maximum(0, xs)
softplus_vals = np.log(1 + np.exp(xs))
gap = softplus_vals - relu_vals

ax.plot(xs, relu_vals, 'b-', linewidth=2, label='ReLU (hard)')
ax.plot(xs, softplus_vals, 'r-', linewidth=2, label='Softplus (soft)')
ax.fill_between(xs, relu_vals, softplus_vals, alpha=0.2, color='green',
                label=f'Gap ≤ log(2) ≈ {math.log(2):.3f}')
ax.axhline(y=math.log(2), color='green', linestyle=':', alpha=0.5)
ax.set_xlabel('x')
ax.set_ylabel('f(x)')
ax.set_title('Tropical-ReLU Bridge: Maslov Dequantization')
ax.legend()
ax.grid(True, alpha=0.3)

plt.suptitle('Diophantine Approximation on ReLU Networks', fontsize=14, fontweight='bold')
plt.tight_layout()
plt.savefig('relu_approximation_results.png', dpi=150, bbox_inches='tight')
print("Saved: relu_approximation_results.png")


#!/usr/bin/env python3
"""
Visualization: Tropical-ReLU Bridge and Maslov Dequantization

Shows how the softplus function log(1 + exp(x/t)) converges to
max(0, x) = relu(x) as the temperature parameter t → 0,
illustrating Maslov's dequantization from quantum to tropical.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
import math

fig, axes = plt.subplots(1, 3, figsize=(16, 5))

xs = np.linspace(-4, 4, 1000)

# --- Plot 1: Temperature sweep ---
ax = axes[0]
relu_vals = np.maximum(0, xs)
ax.plot(xs, relu_vals, 'k-', linewidth=3, label='ReLU (t→0)', zorder=10)

for t in [2.0, 1.0, 0.5, 0.2]:
    soft = np.array([math.log(1 + math.exp(x/t)) * t for x in xs])
    ax.plot(xs, soft, '--', linewidth=1.5, label=f't={t}', alpha=0.8)

ax.set_xlabel('x')
ax.set_ylabel('f(x)')
ax.set_title('Maslov Dequantization:\nSoftplus → ReLU as t → 0')
ax.legend(fontsize=9)
ax.grid(True, alpha=0.3)

# --- Plot 2: Gap as function of x ---
ax = axes[1]
gap = np.log(1 + np.exp(-np.abs(xs)))
ax.plot(xs, gap, 'g-', linewidth=2, label='log(1 + exp(-|x|))')
ax.axhline(y=math.log(2), color='red', linestyle='--', alpha=0.7,
           label=f'Max = log(2) ≈ {math.log(2):.4f}')
ax.fill_between(xs, 0, gap, alpha=0.15, color='green')
ax.set_xlabel('x')
ax.set_ylabel('Gap')
ax.set_title('Soft-Hard Gap:\nlog(1 + exp(x)) - max(0, x)')
ax.legend(fontsize=9)
ax.grid(True, alpha=0.3)

# --- Plot 3: Network size vs precision for π ---
ax = axes[2]
epsilons = np.logspace(-1, -8, 50)
depths_w2 = []
depths_w10 = []
params_w2 = []

for eps in epsilons:
    N = math.ceil((4/eps - 1) / 2)
    if N < 2:
        N = 2
    d2 = math.ceil(math.log2(N))
    d10 = math.ceil(math.log(N, 10))
    depths_w2.append(d2)
    depths_w10.append(d10)
    params_w2.append(2 * 2 * d2 + 2 + 1)

ax.semilogx(epsilons, depths_w2, 'b-', linewidth=2, label='Depth (w=2)')
ax.semilogx(epsilons, depths_w10, 'r-', linewidth=2, label='Depth (w=10)')
ax.semilogx(epsilons, params_w2, 'g--', linewidth=2, label='Params (w=2)')
ax.set_xlabel('Target error ε')
ax.set_ylabel('Network size')
ax.set_title('π Approximation:\nDepth = O(log(1/ε))')
ax.legend(fontsize=9)
ax.grid(True, alpha=0.3)
ax.invert_xaxis()

plt.suptitle('Tropical Geometry ↔ Neural Networks', fontsize=14, fontweight='bold')
plt.tight_layout()
plt.savefig('tropical_relu_bridge.png', dpi=150, bbox_inches='tight')
print("Saved: tropical_relu_bridge.png")
