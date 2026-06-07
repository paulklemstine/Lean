#!/usr/bin/env python3
"""
Tropical Decision Boundary Theory: Interactive Demo

Demonstrates the key results connecting ReLU neural networks to tropical geometry:
1. ReLU as a tropical polynomial
2. Depth amplification of linear regions
3. Activation pattern enumeration
4. Decision boundary visualization
"""

import numpy as np
from typing import List, Tuple


def relu(x: np.ndarray) -> np.ndarray:
    """ReLU activation: max(x, 0)"""
    return np.maximum(x, 0)


def max_linear_regions_1d(widths: List[int]) -> int:
    """Maximum number of linear regions for a 1D ReLU network.
    
    For architecture [w₁, ..., w_L], the bound is ∏(wᵢ + 1).
    This is Theorem region_bound_heterogeneous.
    """
    result = 1
    for w in widths:
        result *= (w + 1)
    return result


def relu_network_1d(x: np.ndarray, weights: List[np.ndarray], 
                     biases: List[np.ndarray]) -> np.ndarray:
    """Evaluate a 1D-input ReLU network.
    
    Args:
        x: Input array of shape (n,)
        weights: List of weight matrices [W₁, W₂, ..., W_L, W_out]
        biases: List of bias vectors [b₁, b₂, ..., b_L, b_out]
    
    Returns:
        Output array of shape (n,)
    """
    h = x.reshape(-1, 1)  # (n, 1)
    for W, b in zip(weights[:-1], biases[:-1]):
        h = relu(h @ W.T + b)
    h = h @ weights[-1].T + biases[-1]
    return h.squeeze()


def count_linear_regions_1d(f_values: np.ndarray) -> int:
    """Count the number of (approximate) linear regions of a 1D function.
    
    Uses second-difference to detect breakpoints.
    """
    # Compute second differences
    d2 = np.diff(f_values, n=2)
    # Breakpoints where curvature changes significantly
    threshold = np.max(np.abs(d2)) * 0.01
    breakpoints = np.sum(np.abs(d2) > threshold)
    return breakpoints + 1  # regions = breakpoints + 1


def tropical_poly_eval(slopes: np.ndarray, intercepts: np.ndarray, 
                        x: np.ndarray) -> np.ndarray:
    """Evaluate a tropical polynomial: max_i(a_i * x + b_i).
    
    This is Definition TropicalPoly1D.eval.
    """
    terms = slopes[:, None] * x[None, :] + intercepts[:, None]
    return np.max(terms, axis=0)


# ============================================================
# Demo 1: ReLU Algebraic Properties
# ============================================================
print("=" * 60)
print("Demo 1: ReLU Algebraic Properties")
print("=" * 60)

# relu_abs_identity: relu(x) = (x + |x|) / 2
x_test = np.array([-3, -1, 0, 1, 3, 5])
relu_direct = relu(x_test)
relu_abs = (x_test + np.abs(x_test)) / 2
print(f"\nrelu_abs_identity: relu(x) = (x + |x|) / 2")
print(f"  x     = {x_test}")
print(f"  relu  = {relu_direct}")
print(f"  (x+|x|)/2 = {relu_abs}")
print(f"  Match: {np.allclose(relu_direct, relu_abs)}")

# relu_idempotent: relu(relu(x)) = relu(x)
print(f"\nrelu_idempotent: relu(relu(x)) = relu(x)")
print(f"  relu(relu(x)) = {relu(relu(x_test))}")
print(f"  relu(x)       = {relu_direct}")
print(f"  Match: {np.allclose(relu(relu(x_test)), relu_direct)}")

# relu_not_additive: counterexample at x=1, y=-1
x, y = 1.0, -1.0
lhs = relu(np.array([x + y]))[0]
rhs = relu(np.array([x]))[0] + relu(np.array([y]))[0]
print(f"\nrelu_not_additive: relu(1 + (-1)) = {lhs} ≠ {rhs} = relu(1) + relu(-1)")

# relu_lipschitz: |relu(x) - relu(y)| ≤ |x - y|
x_vals = np.random.randn(1000)
y_vals = np.random.randn(1000)
lip_ratio = np.abs(relu(x_vals) - relu(y_vals)) / (np.abs(x_vals - y_vals) + 1e-10)
print(f"\nrelu_lipschitz: max |relu(x)-relu(y)|/|x-y| = {lip_ratio.max():.6f} ≤ 1.0")

# ============================================================
# Demo 2: Depth Amplification
# ============================================================
print("\n" + "=" * 60)
print("Demo 2: Depth Amplification of Linear Regions")
print("=" * 60)

print("\nTheorem: maxLinearRegions1D(replicate(L, w)) = (w+1)^L")
print(f"\n{'Depth L':>8} {'Width w':>8} {'Regions':>12} {'Formula':>12} {'Match':>6}")
print("-" * 50)
for L in range(1, 7):
    for w in [2, 4, 8]:
        regions = max_linear_regions_1d([w] * L)
        formula = (w + 1) ** L
        print(f"{L:>8} {w:>8} {regions:>12} {formula:>12} {regions == formula:>6}")

print("\nKey insight: exponential growth in DEPTH, polynomial in WIDTH")
print(f"  Width 10, Depth 1:  {max_linear_regions_1d([10]):>12} regions")
print(f"  Width 10, Depth 5:  {max_linear_regions_1d([10]*5):>12} regions")
print(f"  Width 10, Depth 10: {max_linear_regions_1d([10]*10):>12} regions")
print(f"  Width 50, Depth 1:  {max_linear_regions_1d([50]):>12} regions")
print(f"  Same total width (50), depth 5, w=10: {max_linear_regions_1d([10]*5):>12} regions")

# ============================================================
# Demo 3: Tropical Polynomial Representation
# ============================================================
print("\n" + "=" * 60)
print("Demo 3: ReLU as Tropical Polynomial")
print("=" * 60)

x = np.linspace(-3, 3, 1000)

# relu(x) = max(1*x + 0, 0*x + 0)
slopes = np.array([1.0, 0.0])
intercepts = np.array([0.0, 0.0])
trop_relu = tropical_poly_eval(slopes, intercepts, x)
direct_relu = relu(x)
print(f"\nrelu_tropical_eval: max(x, 0) matches relu(x)")
print(f"  Max error: {np.max(np.abs(trop_relu - direct_relu)):.2e}")

# A single hidden layer network as tropical rational
np.random.seed(42)
w_hidden = 5
W1 = np.random.randn(w_hidden, 1) * 2
b1 = np.random.randn(w_hidden)
W2 = np.random.randn(1, w_hidden)
b2 = np.random.randn(1)

output = relu_network_1d(x, [W1, W2], [b1, b2])
regions = count_linear_regions_1d(output)
max_regions = max_linear_regions_1d([w_hidden])

print(f"\nSingle-layer network (width={w_hidden}):")
print(f"  Observed linear regions: {regions}")
print(f"  Maximum possible: {max_regions}")
print(f"  Bound satisfied: {regions <= max_regions}")

# ============================================================
# Demo 4: Activation Patterns
# ============================================================
print("\n" + "=" * 60)
print("Demo 4: Activation Pattern Statistics")
print("=" * 60)

def count_activation_patterns(x: np.ndarray, W: np.ndarray, b: np.ndarray) -> int:
    """Count distinct activation patterns for a single layer."""
    pre_activation = x.reshape(-1, 1) @ W.T + b
    patterns = (pre_activation > 0).astype(int)
    unique_patterns = set(map(tuple, patterns))
    return len(unique_patterns)

for w in [3, 5, 8, 10]:
    W1 = np.random.randn(w, 1) * 2
    b1 = np.random.randn(w)
    x_fine = np.linspace(-10, 10, 100000)
    n_patterns = count_activation_patterns(x_fine, W1, b1)
    max_patterns = 2 ** w
    print(f"\n  Width {w:>2}: {n_patterns:>5} realizable / {max_patterns:>5} total patterns "
          f"({100*n_patterns/max_patterns:.1f}%)")

# ============================================================
# Demo 5: Depth Amplification in Practice
# ============================================================
print("\n" + "=" * 60)
print("Demo 5: Depth Amplification — Actual vs Theoretical Bound")
print("=" * 60)

for depth in [1, 2, 3, 4]:
    width = 4
    weights = []
    biases_list = []
    
    # Input layer
    W = np.random.randn(width, 1) * 2
    b = np.random.randn(width)
    weights.append(W)
    biases_list.append(b)
    
    # Hidden layers
    for _ in range(depth - 1):
        W = np.random.randn(width, width) * (2.0 / np.sqrt(width))
        b = np.random.randn(width)
        weights.append(W)
        biases_list.append(b)
    
    # Output layer
    W = np.random.randn(1, width)
    b = np.random.randn(1)
    weights.append(W)
    biases_list.append(b)
    
    x_fine = np.linspace(-5, 5, 100000)
    output = relu_network_1d(x_fine, weights, biases_list)
    observed = count_linear_regions_1d(output)
    theoretical = max_linear_regions_1d([width] * depth)
    exp_bound = 2 ** (width * depth)
    
    print(f"\n  Depth {depth}, Width {width}:")
    print(f"    Observed regions:    {observed:>8}")
    print(f"    Product bound:       {theoretical:>8}  = (w+1)^L = {width+1}^{depth}")
    print(f"    Exponential bound:   {exp_bound:>8}  = 2^(W*L) = 2^{width*depth}")

# ============================================================
# Demo 6: Max-Min Duality
# ============================================================
print("\n" + "=" * 60)
print("Demo 6: Max-Min Duality: max(a,b) + min(a,b) = a + b")
print("=" * 60)

a_vals = np.random.randn(5)
b_vals = np.random.randn(5)
for a, b in zip(a_vals, b_vals):
    lhs = max(a, b) + min(a, b)
    rhs = a + b
    print(f"  max({a:.2f}, {b:.2f}) + min({a:.2f}, {b:.2f}) = "
          f"{max(a,b):.2f} + {min(a,b):.2f} = {lhs:.2f} = {rhs:.2f} ✓")

print("\n" + "=" * 60)
print("All demos complete.")
print("=" * 60)


#!/usr/bin/env python3
"""
Visualization: Linear Region Growth with Depth

Shows the exponential amplification of linear regions as network depth increases,
demonstrating the Depth Amplification Theorem: regions = (w+1)^L.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt


def relu(x):
    return np.maximum(x, 0)


def make_network_1d(depth, width, seed=42):
    """Create a random 1D ReLU network."""
    np.random.seed(seed)
    weights = []
    biases = []
    
    # First layer: 1 -> width
    weights.append(np.random.randn(width, 1) * 2)
    biases.append(np.random.randn(width))
    
    # Hidden layers: width -> width
    for _ in range(depth - 1):
        weights.append(np.random.randn(width, width) * (2.0 / np.sqrt(width)))
        biases.append(np.random.randn(width))
    
    # Output layer: width -> 1
    weights.append(np.random.randn(1, width))
    biases.append(np.random.randn(1))
    
    return weights, biases


def eval_network(x, weights, biases):
    """Evaluate network on array of inputs."""
    h = x.reshape(-1, 1)
    for W, b in zip(weights[:-1], biases[:-1]):
        h = relu(h @ W.T + b)
    return (h @ weights[-1].T + biases[-1]).squeeze()


def count_regions(y):
    """Count linear regions by detecting slope changes."""
    dy = np.diff(y)
    d2y = np.diff(dy)
    threshold = np.max(np.abs(d2y)) * 0.01 if np.max(np.abs(d2y)) > 0 else 1
    return np.sum(np.abs(d2y) > threshold) + 1


# Create figure
fig, axes = plt.subplots(2, 3, figsize=(15, 10))
fig.suptitle('Depth Amplification: Linear Regions of ReLU Networks\n'
             'Theorem: maxRegions = (w+1)^L', fontsize=14, fontweight='bold')

x = np.linspace(-3, 3, 10000)
width = 4

for idx, depth in enumerate([1, 2, 3, 4, 5, 6]):
    ax = axes[idx // 3, idx % 3]
    
    ws, bs = make_network_1d(depth, width, seed=42 + idx)
    y = eval_network(x, ws, bs)
    
    regions = count_regions(y)
    max_regions = (width + 1) ** depth
    
    ax.plot(x, y, 'b-', linewidth=1.5)
    ax.axhline(y=0, color='r', linestyle='--', alpha=0.5, label='Decision boundary')
    ax.set_title(f'Depth {depth}: {regions} regions (max {max_regions})')
    ax.set_xlabel('x')
    ax.set_ylabel('f(x)')
    ax.grid(True, alpha=0.3)
    ax.legend(fontsize=8)

plt.tight_layout()
plt.savefig('depth_amplification.png', dpi=150, bbox_inches='tight')
print("Saved depth_amplification.png")

# Second figure: Growth curves
fig2, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

# Region count vs depth
depths = range(1, 8)
for w in [2, 3, 4, 6]:
    max_vals = [(w + 1) ** d for d in depths]
    ax1.semilogy(list(depths), max_vals, 'o-', label=f'width={w}', markersize=5)

ax1.set_xlabel('Depth L', fontsize=12)
ax1.set_ylabel('Max Linear Regions (log scale)', fontsize=12)
ax1.set_title('Exponential Growth: (w+1)^L', fontsize=13)
ax1.legend()
ax1.grid(True, alpha=0.3)

# Product bound vs exponential bound
widths_list = [[4]*d for d in range(1, 8)]
product_bounds = [(4+1)**d for d in range(1, 8)]
exp_bounds = [2**(4*d) for d in range(1, 8)]

ax2.semilogy(list(range(1, 8)), product_bounds, 'bo-', label='Product bound: (w+1)^L', markersize=6)
ax2.semilogy(list(range(1, 8)), exp_bounds, 'r^--', label='Exp bound: 2^(wL)', markersize=6)
ax2.set_xlabel('Depth L (width=4)', fontsize=12)
ax2.set_ylabel('Bound (log scale)', fontsize=12)
ax2.set_title('Product vs Exponential Bound', fontsize=13)
ax2.legend()
ax2.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('region_bounds.png', dpi=150, bbox_inches='tight')
print("Saved region_bounds.png")


#!/usr/bin/env python3
"""
Visualization: Tropical Polynomial Representation of ReLU Networks

Shows how ReLU networks compute tropical rational functions:
pointwise maxima of affine functions.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt


def relu(x):
    return np.maximum(x, 0)


# Figure 1: ReLU as tropical polynomial
fig, axes = plt.subplots(1, 3, figsize=(15, 5))

x = np.linspace(-3, 3, 1000)

# Panel 1: ReLU = max(x, 0)
ax = axes[0]
ax.plot(x, x, 'b--', alpha=0.5, label='f₁(x) = x')
ax.plot(x, np.zeros_like(x), 'g--', alpha=0.5, label='f₂(x) = 0')
ax.plot(x, relu(x), 'r-', linewidth=2.5, label='max(f₁, f₂) = ReLU(x)')
ax.axvline(x=0, color='orange', linestyle=':', alpha=0.7, label='Bend point')
ax.set_title('ReLU as Tropical Polynomial\nmax(x, 0)', fontsize=12)
ax.set_xlabel('x')
ax.set_ylabel('y')
ax.legend(fontsize=9)
ax.grid(True, alpha=0.3)
ax.set_ylim(-1, 3.5)

# Panel 2: Single hidden layer as sum of tropical monomials
ax = axes[1]
np.random.seed(42)
w = 4
slopes = np.random.randn(w) * 2
intercepts = np.random.randn(w)
output_weights = np.random.randn(w)

# Plot individual neurons
for i in range(w):
    neuron = output_weights[i] * relu(slopes[i] * x + intercepts[i])
    ax.plot(x, neuron, '--', alpha=0.4, label=f'c_{i}·ReLU(a_{i}x+b_{i})')

# Plot sum
network_output = sum(output_weights[i] * relu(slopes[i] * x + intercepts[i]) for i in range(w))
ax.plot(x, network_output, 'k-', linewidth=2.5, label='Network output')

# Mark breakpoints
for i in range(w):
    if abs(slopes[i]) > 0.01:
        bp = -intercepts[i] / slopes[i]
        if -3 < bp < 3:
            ax.axvline(x=bp, color='orange', linestyle=':', alpha=0.3)

ax.set_title(f'Single Layer (width={w})\nSum of ReLU neurons', fontsize=12)
ax.set_xlabel('x')
ax.set_ylabel('f(x)')
ax.legend(fontsize=7, loc='upper left')
ax.grid(True, alpha=0.3)

# Panel 3: Max-of-affine (tropical polynomial)
ax = axes[2]
n_terms = 5
slopes_t = np.array([-2, -1, 0, 1, 2.5])
intercepts_t = np.array([3, 1, -0.5, 0.5, -2])

for i in range(n_terms):
    line = slopes_t[i] * x + intercepts_t[i]
    ax.plot(x, line, '--', alpha=0.4, label=f'{slopes_t[i]:.1f}x + {intercepts_t[i]:.1f}')

# Max envelope
envelope = np.max([slopes_t[i] * x + intercepts_t[i] for i in range(n_terms)], axis=0)
ax.plot(x, envelope, 'r-', linewidth=2.5, label='max (tropical poly)')

# Find and mark bend points
for i in range(len(x) - 2):
    d2 = envelope[i+2] - 2*envelope[i+1] + envelope[i]
    if abs(d2) > 0.01:
        ax.plot(x[i+1], envelope[i+1], 'ko', markersize=4)

ax.set_title(f'Tropical Polynomial\nmax of {n_terms} affine functions', fontsize=12)
ax.set_xlabel('x')
ax.set_ylabel('f(x)')
ax.legend(fontsize=7)
ax.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('tropical_representation.png', dpi=150, bbox_inches='tight')
print("Saved tropical_representation.png")

# Figure 2: Activation patterns and the activation complex
fig2, axes2 = plt.subplots(1, 2, figsize=(12, 5))

# Panel 1: Activation patterns of a 2-neuron layer
ax = axes2[0]
x = np.linspace(-3, 3, 1000)
w1, b1 = 1.5, -0.5
w2, b2 = -1.0, 1.0

# Color regions by activation pattern
h1 = w1 * x + b1
h2 = w2 * x + b2

colors = []
for i in range(len(x)):
    p = (h1[i] > 0, h2[i] > 0)
    if p == (False, False): colors.append('lightblue')
    elif p == (True, False): colors.append('lightgreen')
    elif p == (False, True): colors.append('lightyellow')
    else: colors.append('lightcoral')

# Plot as colored bands
for i in range(len(x) - 1):
    ax.axvspan(x[i], x[i+1], color=colors[i], alpha=0.6)

# Plot neuron hyperplanes
bp1 = -b1 / w1 if abs(w1) > 0.01 else None
bp2 = -b2 / w2 if abs(w2) > 0.01 else None
if bp1 is not None:
    ax.axvline(x=bp1, color='blue', linewidth=2, label=f'Neuron 1: x={bp1:.2f}')
if bp2 is not None:
    ax.axvline(x=bp2, color='red', linewidth=2, label=f'Neuron 2: x={bp2:.2f}')

ax.set_title('Activation Patterns (2 neurons)\nRegions colored by pattern', fontsize=12)
ax.set_xlabel('x')
ax.legend(fontsize=9)
ax.set_yticks([])

# Panel 2: Activation complex as graph
ax = axes2[1]
# For 2 neurons: 4 possible patterns, show which are realized
patterns = set()
for xi in x:
    p = (h1[np.argmin(np.abs(x - xi))] > 0, h2[np.argmin(np.abs(x - xi))] > 0)
    patterns.add(p)

# Draw Boolean cube
positions = {
    (False, False): (0, 0),
    (True, False): (1, 0),
    (False, True): (0, 1),
    (True, True): (1, 1),
}

for p, (px, py) in positions.items():
    color = 'green' if p in patterns else 'lightgray'
    size = 300 if p in patterns else 100
    ax.scatter(px, py, s=size, c=color, zorder=5, edgecolors='black', linewidths=2)
    label = f"({int(p[0])},{int(p[1])})"
    ax.annotate(label, (px, py), textcoords="offset points", xytext=(10, 10), fontsize=11)

# Draw adjacency edges
edges = [
    ((False, False), (True, False)),
    ((False, False), (False, True)),
    ((True, False), (True, True)),
    ((False, True), (True, True)),
]
for p1, p2 in edges:
    x1, y1 = positions[p1]
    x2, y2 = positions[p2]
    color = 'green' if (p1 in patterns and p2 in patterns) else 'lightgray'
    lw = 2 if (p1 in patterns and p2 in patterns) else 0.5
    ax.plot([x1, x2], [y1, y2], '-', color=color, linewidth=lw, zorder=1)

ax.set_title('Activation Complex\n(green = realizable patterns)', fontsize=12)
ax.set_xlim(-0.3, 1.5)
ax.set_ylim(-0.3, 1.5)
ax.set_xlabel('Neuron 1')
ax.set_ylabel('Neuron 2')
ax.set_aspect('equal')
ax.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('activation_complex.png', dpi=150, bbox_inches='tight')
print("Saved activation_complex.png")
