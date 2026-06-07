#!/usr/bin/env python3
"""
Demo: Tropical Geometry of Neural Network Decision Boundaries

Demonstrates the key results:
1. ReLU networks compute piecewise linear functions
2. Decision boundaries are tropical hypersurfaces
3. Depth creates exponentially more linear regions than width
4. The tropical degree bounds the decision boundary complexity
"""

import numpy as np

def relu(x: np.ndarray) -> np.ndarray:
    """ReLU activation function."""
    return np.maximum(x, 0)

def single_layer_network(x: np.ndarray, W: np.ndarray, b: np.ndarray) -> np.ndarray:
    """Single hidden layer ReLU network: f(x) = sum_i relu(w_i * x + b_i)."""
    return np.sum(relu(np.outer(x, np.ones(W.shape[0])) * W + b), axis=1)

def count_linear_regions_1d(f, x_range: tuple, n_samples: int = 100000) -> int:
    """Count linear regions of a 1D piecewise linear function by detecting slope changes."""
    xs = np.linspace(x_range[0], x_range[1], n_samples)
    ys = np.array([f(x) for x in xs])
    # Compute slopes between consecutive points
    slopes = np.diff(ys) / np.diff(xs)
    # Count slope changes (up to numerical tolerance)
    slope_changes = np.sum(np.abs(np.diff(slopes)) > 1e-6)
    return int(slope_changes + 1)

def deep_relu_network_1d(x: float, weights: list, biases: list) -> float:
    """
    Deep ReLU network: f(x) = W_L * relu(W_{L-1} * relu(... relu(W_1 * x + b_1) ...) + b_{L-1}) + b_L
    weights[i] is a (w_{i+1}, w_i) matrix, biases[i] is a (w_{i+1},) vector.
    """
    h = np.array([x])
    for W, b in zip(weights[:-1], biases[:-1]):
        h = relu(W @ h + b)
    return float(weights[-1] @ h + biases[-1])

def demo_depth_separation():
    """Demonstrate that depth creates exponentially more linear regions."""
    print("=" * 60)
    print("DEPTH SEPARATION DEMONSTRATION")
    print("=" * 60)
    
    # Compare: depth-1 with 6 neurons vs depth-3 with 2 neurons per layer
    # Depth-1: at most 6+1 = 7 regions
    # Depth-3: at most (2+1)^3 = 27 regions
    
    np.random.seed(42)
    
    # Depth-1 network with 6 neurons
    W1 = np.random.randn(6)
    b1 = np.random.randn(6)
    out_w1 = np.random.randn(6)
    f_shallow = lambda x: np.dot(out_w1, relu(W1 * x + b1))
    
    # Depth-3 network with 2 neurons per layer
    W_deep = [
        np.random.randn(2, 1),
        np.random.randn(2, 2),
        np.random.randn(2, 2),
        np.random.randn(1, 2)
    ]
    b_deep = [np.random.randn(2), np.random.randn(2), np.random.randn(2), np.random.randn(1)]
    f_deep = lambda x: deep_relu_network_1d(x, W_deep, b_deep)
    
    shallow_regions = count_linear_regions_1d(f_shallow, (-10, 10))
    deep_regions = count_linear_regions_1d(f_deep, (-10, 10))
    
    print(f"\nShallow network (depth=1, width=6):")
    print(f"  Total neurons: 6")
    print(f"  Theoretical max regions: {6 + 1}")
    print(f"  Observed regions: {shallow_regions}")
    
    print(f"\nDeep network (depth=3, width=2):")
    print(f"  Total neurons: 6")
    print(f"  Theoretical max regions: {(2+1)**3}")
    print(f"  Observed regions: {deep_regions}")
    
    print(f"\nDepth advantage ratio: {(2+1)**3 / (6+1):.1f}x theoretical")

def demo_tropical_degree():
    """Show how tropical degree relates to network architecture."""
    print("\n" + "=" * 60)
    print("TROPICAL DEGREE BOUNDS")
    print("=" * 60)
    
    print("\nFor a depth-L, width-w network:")
    print(f"{'L':>3} {'w':>3} {'(w+1)^L':>12} {'2^(wL)':>12} {'Ratio':>8}")
    print("-" * 42)
    for L in [1, 2, 3, 4, 5]:
        for w in [2, 4, 8]:
            montufar = (w + 1) ** L
            exponential = 2 ** (w * L)
            ratio = exponential / montufar if montufar > 0 else float('inf')
            print(f"{L:>3} {w:>3} {montufar:>12} {exponential:>12} {ratio:>8.1f}")

def demo_decision_boundary():
    """Demonstrate decision boundary structure."""
    print("\n" + "=" * 60)
    print("DECISION BOUNDARY ANALYSIS")
    print("=" * 60)
    
    np.random.seed(123)
    
    for depth in [1, 2, 3, 4]:
        width = 3
        # Build random deep network
        weights = []
        biases = []
        in_dim = 1
        for _ in range(depth):
            weights.append(np.random.randn(width, in_dim))
            biases.append(np.random.randn(width))
            in_dim = width
        weights.append(np.random.randn(1, width))
        biases.append(np.random.randn(1))
        
        f = lambda x, w=weights, b=biases: deep_relu_network_1d(x, w, b)
        
        # Count zero crossings
        xs = np.linspace(-10, 10, 100000)
        ys = np.array([f(x) for x in xs])
        sign_changes = np.sum(np.diff(np.sign(ys)) != 0)
        regions = count_linear_regions_1d(f, (-10, 10))
        
        print(f"\nDepth={depth}, Width={width}:")
        print(f"  Theoretical max regions: {(width+1)**depth}")
        print(f"  Observed regions: {regions}")
        print(f"  Zero crossings (decision boundary): {sign_changes}")
        print(f"  Tropical degree bound: {(width+1)**depth - 1}")

def demo_convexity_barrier():
    """Show that single-layer networks compute convex functions."""
    print("\n" + "=" * 60)
    print("CONVEXITY BARRIER (XOR IMPOSSIBILITY)")
    print("=" * 60)
    
    # Single layer with positive output weights: always convex
    np.random.seed(42)
    W = np.array([1.0, -1.0, 0.5])
    b = np.array([-1.0, 0.5, -0.3])
    out_w = np.abs(np.random.randn(3))  # positive weights
    
    f = lambda x: np.dot(out_w, relu(W * x + b))
    
    xs = np.linspace(-5, 5, 1000)
    ys = np.array([f(x) for x in xs])
    
    # Check convexity: f((x+y)/2) <= (f(x) + f(y))/2
    violations = 0
    for i in range(0, len(xs) - 2, 2):
        mid = f((xs[i] + xs[i+2]) / 2)
        avg = (ys[i] + ys[i+2]) / 2
        if mid > avg + 1e-10:
            violations += 1
    
    print(f"\nSingle-layer network with positive output weights:")
    print(f"  Convexity violations: {violations} (expected: 0)")
    print(f"  This means the zero set is an interval (at most)")
    print(f"  → Cannot represent XOR-like decision boundaries!")
    print(f"  → Need depth ≥ 2 to break the convexity barrier")

if __name__ == "__main__":
    demo_depth_separation()
    demo_tropical_degree()
    demo_decision_boundary()
    demo_convexity_barrier()
    
    print("\n" + "=" * 60)
    print("KEY INSIGHT: Neural network decision boundaries are tropical")
    print("hypersurfaces. The tropical degree (algebraic complexity)")
    print("grows as (w+1)^L — exponentially in depth but polynomially")
    print("in width. This explains why deep networks are exponentially")
    print("more expressive than shallow ones.")
    print("=" * 60)


#!/usr/bin/env python3
"""Visualization: Depth Separation in ReLU Networks.

Shows how depth creates exponentially more linear regions than width,
demonstrating the tropical degree gap between deep and shallow networks.
"""
import numpy as np
import matplotlib.pyplot as plt
import matplotlib
matplotlib.use('Agg')


def relu(x):
    return np.maximum(x, 0)


def deep_relu_1d(x, weights, biases):
    h = np.array([x])
    for W, b in zip(weights[:-1], biases[:-1]):
        h = relu(W @ h + b)
    return float(weights[-1] @ h + biases[-1])


def make_network(widths, seed=42):
    rng = np.random.RandomState(seed)
    weights, biases = [], []
    in_dim = 1
    for w in widths:
        weights.append(rng.randn(w, in_dim))
        biases.append(rng.randn(w))
        in_dim = w
    weights.append(rng.randn(1, in_dim))
    biases.append(rng.randn(1))
    return weights, biases


def count_regions(f, xmin=-10, xmax=10, n=100000):
    xs = np.linspace(xmin, xmax, n)
    ys = np.array([f(x) for x in xs])
    slopes = np.diff(ys) / np.diff(xs)
    return int(np.sum(np.abs(np.diff(slopes)) > 1e-6) + 1)


fig, axes = plt.subplots(2, 3, figsize=(15, 10))
fig.suptitle('Depth Separation: ReLU Networks as Tropical Polynomials', fontsize=16)

configs = [
    ([6], 'Shallow: 1×6'),
    ([3, 3], 'Medium: 2×3'),
    ([2, 2, 2], 'Deep: 3×2'),
    ([4, 4], 'Wide: 2×4'),
    ([2, 2, 2, 2], 'Deeper: 4×2'),
    ([2, 2, 2, 2, 2], 'Deepest: 5×2'),
]

xs = np.linspace(-5, 5, 10000)

for idx, (widths, title) in enumerate(configs):
    ax = axes[idx // 3][idx % 3]
    W, B = make_network(widths)
    f = lambda x, w=W, b=B: deep_relu_1d(x, w, b)
    ys = np.array([f(x) for x in xs])
    
    regions = count_regions(f, -5, 5)
    theoretical = 1
    for w in widths:
        theoretical *= (w + 1)
    
    ax.plot(xs, ys, 'b-', linewidth=1.5)
    ax.axhline(y=0, color='r', linestyle='--', alpha=0.5, label='Decision boundary')
    
    # Mark zero crossings
    for i in range(len(ys) - 1):
        if ys[i] * ys[i+1] < 0:
            x_cross = xs[i] - ys[i] * (xs[i+1] - xs[i]) / (ys[i+1] - ys[i])
            ax.axvline(x=x_cross, color='g', alpha=0.3, linewidth=0.5)
    
    ax.set_title(f'{title}\nRegions: {regions}/{theoretical} (obs/max)')
    ax.set_xlabel('x')
    ax.set_ylabel('f(x)')
    ax.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('/workspace/request-project/Novelty/depth_separation.png', dpi=150)
print("Saved: depth_separation.png")

# Second figure: region count scaling
fig2, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))
fig2.suptitle('Tropical Degree Scaling with Network Architecture', fontsize=14)

# Left: regions vs depth for fixed width
depths = range(1, 8)
for w in [2, 3, 4]:
    regions = [(w + 1) ** L for L in depths]
    ax1.semilogy(list(depths), regions, 'o-', label=f'width={w}', markersize=6)

ax1.set_xlabel('Depth L')
ax1.set_ylabel('Max Linear Regions (log scale)')
ax1.set_title('Exponential Growth with Depth')
ax1.legend()
ax1.grid(True, alpha=0.3)

# Right: parameter efficiency
for w in [2, 3, 4, 8]:
    depths_list = list(range(1, 10))
    efficiency = [L * np.log2(w + 1) / (w * (L + 1) + L) for L in depths_list]
    ax2.plot(depths_list, efficiency, 'o-', label=f'width={w}', markersize=6)

ax2.set_xlabel('Depth L')
ax2.set_ylabel('Bits of expressiveness per parameter')
ax2.set_title('Parameter Efficiency: Deep > Shallow')
ax2.legend()
ax2.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('/workspace/request-project/Novelty/scaling_analysis.png', dpi=150)
print("Saved: scaling_analysis.png")
