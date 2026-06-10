#!/usr/bin/env python3
"""
Tropical Decision Boundaries: Numerical Demonstrations

Demonstrates the key results from our formal proofs:
1. Activation pattern counting for multi-layer networks
2. Depth-width exponential gap
3. LogSumExp tropical approximation convergence
4. Zaslavsky bound verification
5. Decision boundary visualization for 1D and 2D networks
"""

import numpy as np
from typing import List, Tuple

def relu(x: np.ndarray) -> np.ndarray:
    """ReLU activation: max(x, 0)"""
    return np.maximum(x, 0)

def logsumexp(x: np.ndarray, beta: float = 1.0) -> float:
    """LogSumExp: (1/beta) * log(sum(exp(beta * x_i)))"""
    shifted = beta * x - np.max(beta * x)  # numerical stability
    return np.max(x) + (1/beta) * np.log(np.sum(np.exp(shifted)))

# ============================================================
# Demo 1: Activation Pattern Counting
# ============================================================
print("=" * 60)
print("Demo 1: Activation Pattern Counting")
print("=" * 60)
print()
print("Theorem: For an L-layer network with widths w_1,...,w_L:")
print("  prod(2^w_i) = 2^(sum(w_i))")
print()

for widths in [[3, 4, 2], [5, 5, 5], [2, 2, 2, 2, 2], [10, 1]]:
    prod_bound = np.prod([2**w for w in widths])
    sum_bound = 2**sum(widths)
    print(f"  widths = {widths}")
    print(f"    Product: prod(2^w_i) = {prod_bound}")
    print(f"    Sum:     2^(sum w_i) = {sum_bound}")
    print(f"    Equal: {prod_bound == sum_bound}")
    print()

# ============================================================
# Demo 2: Depth-Width Exponential Gap
# ============================================================
print("=" * 60)
print("Demo 2: Depth-Width Exponential Gap")
print("=" * 60)
print()
print("Theorem: For L >= 2, w >= 2: L * 2^w <= 2^(L*w)")
print()

print(f"{'L':>4} {'w':>4} {'L*2^w':>12} {'2^(L*w)':>12} {'Ratio':>10}")
print("-" * 46)
for L in [2, 3, 4, 5]:
    for w in [2, 3, 4, 5]:
        sum_bound = L * (2**w)
        prod_bound = 2**(L*w)
        ratio = prod_bound / sum_bound
        print(f"{L:>4} {w:>4} {sum_bound:>12} {prod_bound:>12} {ratio:>10.1f}")
print()

# ============================================================
# Demo 3: LogSumExp Tropical Approximation
# ============================================================
print("=" * 60)
print("Demo 3: LogSumExp Tropical Approximation")
print("=" * 60)
print()
print("Theorem: max(x_i) <= LSE_beta(x) <= max(x_i) + log(n)/beta")
print()

x = np.array([1.0, 3.5, 2.1, 0.7, 4.2])
n = len(x)
true_max = np.max(x)
print(f"  x = {x}")
print(f"  max(x) = {true_max}")
print(f"  n = {n}")
print()

print(f"{'beta':>8} {'LSE':>10} {'Lower':>10} {'Upper':>10} {'Gap':>10}")
print("-" * 52)
for beta in [0.1, 0.5, 1.0, 2.0, 5.0, 10.0, 50.0, 100.0]:
    lse = logsumexp(x, beta)
    lower = true_max
    upper = true_max + np.log(n) / beta
    gap = lse - true_max
    print(f"{beta:>8.1f} {lse:>10.6f} {lower:>10.6f} {upper:>10.6f} {gap:>10.6f}")
print()

# ============================================================
# Demo 4: Zaslavsky Bound Verification
# ============================================================
print("=" * 60)
print("Demo 4: Zaslavsky Bound Verification")
print("=" * 60)
print()
print("Theorem: sum_{j=0}^{min(n,k)} C(k,j) <= (k+1)^n")
print()

from math import comb

print(f"{'n':>4} {'k':>4} {'Zaslavsky':>12} {'(k+1)^n':>12} {'Ratio':>8}")
print("-" * 44)
for n_dim in [1, 2, 3, 4, 5]:
    for k_hyp in [1, 3, 5, 10]:
        zaslavsky = sum(comb(k_hyp, j) for j in range(min(n_dim, k_hyp) + 1))
        poly_bound = (k_hyp + 1) ** n_dim
        ratio = poly_bound / zaslavsky if zaslavsky > 0 else float('inf')
        print(f"{n_dim:>4} {k_hyp:>4} {zaslavsky:>12} {poly_bound:>12} {ratio:>8.2f}")
print()

# ============================================================
# Demo 5: 1D ReLU Network Decision Boundary
# ============================================================
print("=" * 60)
print("Demo 5: 1D ReLU Network Decision Boundary")
print("=" * 60)
print()

def relu_network_1d(x: float, layers: List[Tuple[np.ndarray, np.ndarray]]) -> float:
    """Evaluate a 1D ReLU network at point x."""
    val = np.array([x])
    for W, b in layers:
        val = relu(W @ val + b)
    return float(val[0]) if len(val) == 1 else float(val.sum())

# Simple 2-layer network
W1 = np.array([[1.0], [-1.0]])
b1 = np.array([0.0, 1.0])
W2 = np.array([[1.0, -2.0]])
b2 = np.array([-0.5])

layers = [(W1, b1), (W2, b2)]

print("Network: 2 layers, widths [2, 1]")
print("Expected max linear regions: 2^2 = 4")
print()

# Find decision boundary (zeros of the output)
xs = np.linspace(-3, 3, 1000)
ys = [relu_network_1d(x, layers) for x in xs]

# Find sign changes (approximate zeros)
zeros = []
for i in range(len(ys) - 1):
    if ys[i] * ys[i+1] < 0 or ys[i] == 0:
        zeros.append(xs[i])

# Count linear regions (changes in slope)
slopes = np.diff(ys) / np.diff(xs)
region_changes = sum(1 for i in range(len(slopes)-1) 
                     if abs(slopes[i+1] - slopes[i]) > 0.01)

print(f"  Decision boundary points (approximate zeros): {len(zeros)}")
print(f"  Number of slope changes: {region_changes}")
print(f"  Bend bound (2^w - 1)^L = (2^2 - 1)^2 = 9")
print()

# ============================================================
# Demo 6: Depth Separation
# ============================================================
print("=" * 60)
print("Demo 6: Depth Separation - max of 2^L values")
print("=" * 60)
print()

for L in range(1, 7):
    n_leaves = 2**L
    deep_width = 2
    shallow_width = (n_leaves + 1) // 2
    print(f"  L={L}: max of {n_leaves} values")
    print(f"    Deep:    depth={L}, width={deep_width}, total={L*deep_width} neurons")
    print(f"    Shallow: depth=2, width={shallow_width}, total={2*shallow_width} neurons")
    print(f"    Savings: {2*shallow_width - L*deep_width} neurons ({2*shallow_width/(L*deep_width):.1f}x)")
    print()

print("=" * 60)
print("All demonstrations complete.")
print("=" * 60)


#!/usr/bin/env python3
"""
Visualization: Tropical Decision Boundaries of ReLU Networks

Generates plots showing:
1. 1D piecewise linear function and its decision boundary
2. Depth-width exponential gap
3. LogSumExp convergence to tropical max
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from matplotlib.gridspec import GridSpec


def relu(x):
    return np.maximum(x, 0)


def logsumexp_smooth(x_vals, beta):
    """Smooth max approximation via LogSumExp."""
    shifted = beta * x_vals - np.max(beta * x_vals, axis=0, keepdims=True)
    return np.max(x_vals, axis=0) + (1/beta) * np.log(np.sum(np.exp(shifted), axis=0))


def make_relu_network_1d(x, W1, b1, W2, b2):
    """Two-layer ReLU network in 1D."""
    h = relu(W1[:, np.newaxis] * x[np.newaxis, :] + b1[:, np.newaxis])
    return (W2 @ h + b2).flatten()


fig = plt.figure(figsize=(18, 12))
gs = GridSpec(2, 3, figure=fig, hspace=0.35, wspace=0.3)

# ---- Plot 1: 1D Piecewise Linear Function ----
ax1 = fig.add_subplot(gs[0, 0])
x = np.linspace(-3, 3, 1000)

# Affine pieces
pieces = [
    (1.5, -1.0),   # 1.5x - 1
    (-0.5, 2.0),   # -0.5x + 2
    (0.3, -0.5),   # 0.3x - 0.5
    (-1.0, 1.5),   # -x + 1.5
]

y_pieces = np.array([a * x + b for a, b in pieces])
y_max = np.max(y_pieces, axis=0)

for i, (a, b) in enumerate(pieces):
    ax1.plot(x, a * x + b, '--', alpha=0.4, linewidth=1)
ax1.plot(x, y_max, 'b-', linewidth=2.5, label='max (tropical poly)')

# Mark bend points
for i in range(len(x) - 1):
    if abs(np.diff(y_max)[i]) > 0.01:
        argmax_i = np.argmax(y_pieces[:, i])
        argmax_next = np.argmax(y_pieces[:, i+1])
        if argmax_i != argmax_next:
            ax1.plot(x[i], y_max[i], 'ro', markersize=8, zorder=5)

ax1.set_xlabel('x', fontsize=12)
ax1.set_ylabel('f(x)', fontsize=12)
ax1.set_title('Tropical Polynomial\n(max of affine functions)', fontsize=13)
ax1.legend(fontsize=10)
ax1.grid(True, alpha=0.3)

# ---- Plot 2: ReLU Network Decision Boundary ----
ax2 = fig.add_subplot(gs[0, 1])

W1 = np.array([2.0, -1.5, 1.0, -0.5])
b1 = np.array([-1.0, 2.0, -0.5, 1.0])
W2 = np.array([1.0, -2.0, 0.5, -1.0])
b2 = np.array([-0.3])

x = np.linspace(-3, 3, 1000)
y = make_relu_network_1d(x, W1, b1, W2, b2)

ax2.plot(x, y, 'b-', linewidth=2.5, label='Network output')
ax2.axhline(y=0, color='r', linestyle='--', linewidth=1, alpha=0.7, label='Decision boundary')
ax2.fill_between(x, y, 0, where=(y > 0), alpha=0.15, color='green', label='Class +1')
ax2.fill_between(x, y, 0, where=(y < 0), alpha=0.15, color='red', label='Class -1')

# Mark zeros
for i in range(len(y) - 1):
    if y[i] * y[i+1] < 0:
        x0 = x[i] - y[i] * (x[i+1] - x[i]) / (y[i+1] - y[i])
        ax2.plot(x0, 0, 'ko', markersize=10, zorder=5)

ax2.set_xlabel('x', fontsize=12)
ax2.set_ylabel('f(x)', fontsize=12)
ax2.set_title('ReLU Network Decision Boundary\n(zeros of tropical rational)', fontsize=13)
ax2.legend(fontsize=9, loc='upper right')
ax2.grid(True, alpha=0.3)

# ---- Plot 3: Depth-Width Gap ----
ax3 = fig.add_subplot(gs[0, 2])

widths = range(2, 9)
for L in [2, 3, 4, 5]:
    deep = [2**(L*w) for w in widths]
    ax3.semilogy(list(widths), deep, 'o-', linewidth=2, markersize=5, label=f'2^(L·w), L={L}')

for L in [2, 3, 4, 5]:
    shallow = [L * 2**w for w in widths]
    ax3.semilogy(list(widths), shallow, 's--', linewidth=1, markersize=4, alpha=0.5, label=f'L·2^w, L={L}')

ax3.set_xlabel('Width w', fontsize=12)
ax3.set_ylabel('Number of regions', fontsize=12)
ax3.set_title('Depth-Width Exponential Gap\nDeep (solid) vs Shallow (dashed)', fontsize=13)
ax3.legend(fontsize=8, ncol=2)
ax3.grid(True, alpha=0.3)

# ---- Plot 4: LogSumExp Convergence ----
ax4 = fig.add_subplot(gs[1, 0])

values = np.array([1.0, 3.0, 2.5, 0.5, 4.0])
n = len(values)
true_max = np.max(values)

betas = np.logspace(-1, 2, 100)
lse_values = []
for beta in betas:
    shifted = beta * values - np.max(beta * values)
    lse = true_max + (1/beta) * np.log(np.sum(np.exp(shifted)))
    lse_values.append(lse)

ax4.semilogx(betas, lse_values, 'b-', linewidth=2.5, label='LSE(β)')
ax4.semilogx(betas, [true_max]*len(betas), 'g--', linewidth=1.5, label='max (tropical)')
ax4.semilogx(betas, [true_max + np.log(n)/b for b in betas], 'r--', linewidth=1.5, label='max + log(n)/β')
ax4.fill_between(betas, true_max, [true_max + np.log(n)/b for b in betas], alpha=0.1, color='orange')

ax4.set_xlabel('Inverse temperature β', fontsize=12)
ax4.set_ylabel('Value', fontsize=12)
ax4.set_title('LogSumExp → Tropical Max\n(Dequantization)', fontsize=13)
ax4.legend(fontsize=10)
ax4.grid(True, alpha=0.3)

# ---- Plot 5: Zaslavsky Bound ----
ax5 = fig.add_subplot(gs[1, 1])

from math import comb

for n_dim in [1, 2, 3, 4]:
    ks = range(1, 16)
    zas = [sum(comb(k, j) for j in range(min(n_dim, k) + 1)) for k in ks]
    poly = [(k+1)**n_dim for k in ks]
    ax5.plot(list(ks), zas, 'o-', linewidth=2, markersize=4, label=f'Zaslavsky, n={n_dim}')
    ax5.plot(list(ks), poly, 's--', linewidth=1, markersize=3, alpha=0.5, label=f'(k+1)^{n_dim}')

ax5.set_xlabel('Number of hyperplanes k', fontsize=12)
ax5.set_ylabel('Number of regions', fontsize=12)
ax5.set_title('Zaslavsky Bound vs (k+1)^n', fontsize=13)
ax5.legend(fontsize=8, ncol=2)
ax5.set_yscale('log')
ax5.grid(True, alpha=0.3)

# ---- Plot 6: Bend Count vs Region Count ----
ax6 = fig.add_subplot(gs[1, 2])

ws = range(1, 8)
for L in [1, 2, 3, 4]:
    regions = [(2**w)**L for w in ws]
    bends = [(2**w - 1)**L for w in ws]
    ax6.semilogy(list(ws), regions, 'o-', linewidth=2, markersize=5, label=f'Regions, L={L}')
    ax6.semilogy(list(ws), bends, 's--', linewidth=1.5, markersize=4, alpha=0.6, label=f'Bends, L={L}')

ax6.set_xlabel('Width w', fontsize=12)
ax6.set_ylabel('Count', fontsize=12)
ax6.set_title('Regions vs Bends\n(2^w)^L vs (2^w-1)^L', fontsize=13)
ax6.legend(fontsize=8, ncol=2)
ax6.grid(True, alpha=0.3)

plt.suptitle('Tropical Geometry of Neural Network Decision Boundaries', 
             fontsize=16, fontweight='bold', y=0.98)
plt.savefig('tropical_decision_boundaries.png', dpi=150, bbox_inches='tight')
print("Saved: tropical_decision_boundaries.png")
