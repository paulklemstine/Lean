"""
Demo: Tropical Geometry of Neural Network Decision Boundaries

This script demonstrates the key results from our research on the connection
between ReLU neural networks and tropical geometry.
"""

import numpy as np

def relu(x):
    """ReLU activation: max(x, 0)"""
    return np.maximum(x, 0)

def tropical_poly_eval(slopes, intercepts, x):
    """Evaluate a 1D tropical polynomial: max_i(slope_i * x + intercept_i)"""
    return np.max([s * x + b for s, b in zip(slopes, intercepts)])

def relu_as_tropical_rational(x):
    """ReLU as a tropical rational function:
    numerator = max(x, 0), denominator = 0"""
    num = np.maximum(x, 0)  # max(1*x + 0, 0*x + 0)
    den = 0                  # max(0*x + 0) = 0
    return num - den

# Demo 1: Verify ReLU = Tropical Rational
print("=" * 60)
print("Demo 1: ReLU as Tropical Rational Function")
print("=" * 60)
test_points = np.linspace(-5, 5, 11)
for x in test_points:
    r = relu(x)
    t = relu_as_tropical_rational(x)
    print(f"  x={x:6.2f}  relu={r:6.2f}  tropical={t:6.2f}  match={np.isclose(r, t)}")

# Demo 2: Width-Depth Tradeoff
print("\n" + "=" * 60)
print("Demo 2: Width-Depth Tradeoff (w*L ≤ w^L)")
print("=" * 60)
for w in range(2, 6):
    for L in range(2, 6):
        shallow = w * L
        deep = w ** L
        print(f"  w={w}, L={L}: shallow={shallow:6d}  deep={deep:6d}  "
              f"ratio={deep/shallow:8.1f}x  deep≥shallow={deep >= shallow}")

# Demo 3: Activation Pattern Counting
print("\n" + "=" * 60)
print("Demo 3: Activation Pattern Space = 2^w")
print("=" * 60)
for w in range(1, 8):
    patterns = 2 ** w
    print(f"  Width w={w}: {patterns:5d} activation patterns")

# Demo 4: Deep vs Shallow Region Bound
print("\n" + "=" * 60)
print("Demo 4: Deep (w+1)^L vs Shallow w*L+1")
print("=" * 60)
for w in [2, 3, 5, 10]:
    for L in [2, 3, 5, 10]:
        deep = (w + 1) ** L
        shallow = w * L + 1
        print(f"  w={w:2d}, L={L:2d}: deep={(w+1)}^{L}={deep:12d}  "
              f"shallow={w}*{L}+1={shallow:6d}  ratio={deep/shallow:10.1f}x")

# Demo 5: Connected Component Bound
print("\n" + "=" * 60)
print("Demo 5: Connected Components ≤ ∏wᵢ ≤ 2^(∑wᵢ)")
print("=" * 60)
architectures = [
    [4, 4],
    [8, 8, 8],
    [16, 16],
    [4, 8, 4],
    [32, 32, 32, 32],
]
for widths in architectures:
    prod_w = np.prod(widths)
    sum_w = sum(widths)
    exp_bound = 2 ** sum_w
    print(f"  Widths {str(widths):20s}: ∏wᵢ={prod_w:12d}  "
          f"2^(∑wᵢ)=2^{sum_w}={exp_bound:15d}  "
          f"tightness={prod_w/exp_bound:.6f}")

# Demo 6: Softmax → Max (Tropical Limit)
print("\n" + "=" * 60)
print("Demo 6: Softmax-to-Max Convergence (β → ∞)")
print("=" * 60)
x = np.array([1.0, 3.0, 2.0, 0.5])
true_max = np.max(x)
print(f"  x = {x}, max = {true_max}")
for beta in [0.1, 0.5, 1.0, 2.0, 5.0, 10.0, 50.0, 100.0]:
    lse = (1.0 / beta) * np.log(np.sum(np.exp(beta * x)))
    print(f"  β={beta:6.1f}: (1/β)log∑exp(βxᵢ) = {lse:.6f}  "
          f"gap = {lse - true_max:.6f}")

# Demo 7: Tropical Degree and Network Depth
print("\n" + "=" * 60)
print("Demo 7: Tropical Degree = ∏wᵢ = w^L (uniform width)")
print("=" * 60)
for w in [2, 3, 4, 5]:
    for L in [1, 2, 3, 4, 5]:
        degree = w ** L
        print(f"  w={w}, L={L}: tropical degree = {degree}")

print("\n" + "=" * 60)
print("All demos completed successfully!")
print("=" * 60)


"""
Visualization: Decision Boundaries of ReLU Networks as Tropical Hypersurfaces

Generates a 2D visualization of a ReLU network's decision boundary,
showing the piecewise linear structure and tropical geometry.
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.colors as mcolors


def relu(x):
    return np.maximum(x, 0)


def relu_network_2d(x1, x2, seed=42):
    """A 2-layer ReLU network with width 6 on 2D input."""
    rng = np.random.RandomState(seed)
    
    # Layer 1: 2 -> 6
    W1 = rng.randn(6, 2) * 1.5
    b1 = rng.randn(6) * 0.5
    
    # Layer 2: 6 -> 4
    W2 = rng.randn(4, 6) * 1.0
    b2 = rng.randn(4) * 0.3
    
    # Output: 4 -> 1
    w_out = rng.randn(4) * 0.5
    b_out = 0.0
    
    inp = np.stack([x1.ravel(), x2.ravel()], axis=0)
    h1 = relu(W1 @ inp + b1[:, None])
    h2 = relu(W2 @ h1 + b2[:, None])
    out = (w_out @ h2 + b_out).reshape(x1.shape)
    return out


def main():
    fig, axes = plt.subplots(1, 3, figsize=(18, 6))
    
    x = np.linspace(-3, 3, 500)
    X1, X2 = np.meshgrid(x, x)
    
    for idx, (seed, title) in enumerate([
        (42, "2-Layer, Width 6"),
        (17, "2-Layer, Width 6 (seed 2)"),
        (99, "2-Layer, Width 6 (seed 3)")
    ]):
        ax = axes[idx]
        Z = relu_network_2d(X1, X2, seed=seed)
        
        # Color map: positive vs negative regions
        ax.contourf(X1, X2, Z, levels=50, cmap='RdBu_r', alpha=0.8)
        
        # Decision boundary: f(x) = 0
        ax.contour(X1, X2, Z, levels=[0], colors='black', linewidths=2)
        
        # Activation boundaries (hyperplanes where neurons switch)
        ax.contour(X1, X2, Z, levels=20, colors='gray', linewidths=0.3, alpha=0.5)
        
        ax.set_title(f'Decision Boundary: {title}', fontsize=12, fontweight='bold')
        ax.set_xlabel('x₁')
        ax.set_ylabel('x₂')
        ax.set_aspect('equal')
    
    plt.suptitle('ReLU Network Decision Boundaries as Tropical Hypersurfaces',
                 fontsize=14, fontweight='bold', y=1.02)
    plt.tight_layout()
    plt.savefig('decision_boundary_visualization.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved decision_boundary_visualization.png")


if __name__ == "__main__":
    main()


"""
Visualization: Depth vs Width Tradeoff

Shows how network depth provides exponential expressiveness gains
over width alone, with the tropical degree w^L growing much faster
than the shallow bound w*L.
"""

import numpy as np
import matplotlib.pyplot as plt


def main():
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))
    
    # Left panel: Deep vs Shallow for different widths
    ax1 = axes[0]
    L_vals = np.arange(1, 8)
    
    for w, color in [(2, 'blue'), (3, 'green'), (4, 'red'), (5, 'purple')]:
        deep = np.array([(w+1)**L for L in L_vals])
        shallow = np.array([w*L + 1 for L in L_vals])
        ax1.semilogy(L_vals, deep, 'o-', color=color, label=f'(w+1)^L, w={w}')
        ax1.semilogy(L_vals, shallow, 's--', color=color, alpha=0.5, label=f'w*L+1, w={w}')
    
    ax1.set_title('Deep vs Shallow Region Counts', fontsize=12, fontweight='bold')
    ax1.set_xlabel('Depth L')
    ax1.set_ylabel('Number of Regions')
    ax1.legend(fontsize=7, ncol=2)
    ax1.grid(True, alpha=0.3)
    
    # Right panel: Ratio deep/shallow
    ax2 = axes[1]
    L_vals = np.arange(2, 10)
    
    for w, color in [(2, 'blue'), (3, 'green'), (4, 'red'), (5, 'purple'), (10, 'orange')]:
        ratio = np.array([(w+1)**L / (w*L + 1) for L in L_vals])
        ax2.semilogy(L_vals, ratio, 'o-', color=color, label=f'w={w}')
    
    ax2.set_title('Expressiveness Ratio: Deep / Shallow', fontsize=12, fontweight='bold')
    ax2.set_xlabel('Depth L')
    ax2.set_ylabel('Ratio (w+1)^L / (w*L+1)')
    ax2.legend()
    ax2.grid(True, alpha=0.3)
    
    plt.suptitle('The Exponential Advantage of Depth',
                 fontsize=14, fontweight='bold')
    plt.tight_layout()
    plt.savefig('depth_width_tradeoff.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved depth_width_tradeoff.png")


if __name__ == "__main__":
    main()


"""
Visualization: Softmax-to-Max Tropical Limit

Shows how the log-sum-exp (softmax) converges to the max function
as the temperature parameter β → ∞. This is the fundamental
dequantization from classical to tropical geometry.
"""

import numpy as np
import matplotlib.pyplot as plt


def main():
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))
    
    # Left panel: LSE functions for different β
    ax1 = axes[0]
    x = np.linspace(-3, 3, 500)
    
    # Two affine functions
    f1 = 2 * x + 1
    f2 = -x + 2
    trop_max = np.maximum(f1, f2)
    
    ax1.plot(x, f1, '--', color='blue', alpha=0.5, label='2x + 1')
    ax1.plot(x, f2, '--', color='red', alpha=0.5, label='-x + 2')
    ax1.plot(x, trop_max, 'k-', linewidth=2, label='max (tropical)')
    
    for beta, color in [(0.5, '#ff9999'), (1, '#ff6666'), (2, '#ff3333'),
                        (5, '#cc0000'), (20, '#990000')]:
        lse = (1/beta) * np.log(np.exp(beta * f1) + np.exp(beta * f2))
        ax1.plot(x, lse, '-', color=color, alpha=0.7, label=f'β={beta}')
    
    ax1.set_title('Log-Sum-Exp → Max (Tropical Limit)', fontsize=12, fontweight='bold')
    ax1.set_xlabel('x')
    ax1.set_ylabel('f(x)')
    ax1.legend(loc='upper left', fontsize=8)
    ax1.set_ylim(-5, 10)
    ax1.grid(True, alpha=0.3)
    
    # Right panel: Convergence rate
    ax2 = axes[1]
    betas = np.logspace(-1, 3, 100)
    values = np.array([1.0, 3.0, 2.0, 0.5])
    true_max = np.max(values)
    
    gaps = []
    for beta in betas:
        v_max = np.max(values)
        lse = v_max + (1/beta) * np.log(np.sum(np.exp(beta * (values - v_max))))
        gaps.append(lse - true_max)
    
    ax2.loglog(betas, gaps, 'b-', linewidth=2)
    ax2.loglog(betas, np.log(len(values)) / betas, 'r--', linewidth=1,
              label=f'log(n)/β bound (n={len(values)})')
    
    ax2.set_title('Convergence Gap: LSE - max', fontsize=12, fontweight='bold')
    ax2.set_xlabel('β (temperature⁻¹)')
    ax2.set_ylabel('Gap = (1/β)log∑exp(βxᵢ) - max(xᵢ)')
    ax2.legend()
    ax2.grid(True, alpha=0.3)
    
    plt.suptitle('The Tropical Limit: From Smooth to Piecewise Linear',
                 fontsize=14, fontweight='bold')
    plt.tight_layout()
    plt.savefig('tropical_limit_visualization.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved tropical_limit_visualization.png")


if __name__ == "__main__":
    main()
