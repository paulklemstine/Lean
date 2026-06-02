"""
Demo: Neural Decision Surface Topology

Demonstrates the key results from the framework:
1. Zaslavsky bounds and the exponential ceiling
2. Depth vs width tradeoff
3. Region counting via activation pattern sampling
4. Tropical-ReLU identity verification
"""

import numpy as np
from algorithms import (
    zaslavsky_bound,
    network_region_bound,
    exponential_bound,
    depth_width_comparison,
    count_linear_regions,
    random_relu_network,
    zaslavsky_recurrence_verify,
    tropical_relu_identity,
)


def demo_zaslavsky_table():
    """Print a table of Zaslavsky bounds."""
    print("╔══════════════════════════════════════════════════════╗")
    print("║          Zaslavsky Bound Z(m, n) Table              ║")
    print("╠══════╦══════╦══════╦══════╦══════╦══════╦═══════════╣")
    print("║  m\\n ║  1   ║  2   ║  3   ║  4   ║  5   ║  2^m      ║")
    print("╠══════╬══════╬══════╬══════╬══════╬══════╬═══════════╣")
    for m in range(1, 11):
        vals = [zaslavsky_bound(m, n) for n in range(1, 6)]
        exp_bound = 2**m
        print(f"║ {m:4d} ║ {vals[0]:4d} ║ {vals[1]:4d} ║ {vals[2]:4d} ║ {vals[3]:4d} ║ {vals[4]:4d} ║ {exp_bound:9d} ║")
    print("╚══════╩══════╩══════╩══════╩══════╩══════╩═══════════╝")
    print()
    print("Key observation: Z(m, n) ≤ 2^m always holds (Theorem 3.3)")
    print("Z(m, n) grows as O(m^n) for fixed n, but is capped at 2^m")
    print()


def demo_depth_width_tradeoff():
    """Demonstrate the exponential advantage of depth."""
    print("═══════════════════════════════════════════════════════")
    print("  Depth vs Width Tradeoff (input dimension n = 2)")
    print("═══════════════════════════════════════════════════════")
    print()
    
    width = 3
    print(f"Comparing: L layers of width {width} vs 1 layer of width {width}*L")
    print()
    print(f"{'Depth L':>8} {'Deep bound':>12} {'Shallow bound':>14} {'Ratio':>10} {'2^N':>12}")
    print("-" * 60)
    
    for depth in [1, 2, 3, 5, 8, 10, 15, 20]:
        result = depth_width_comparison(2, width, depth)
        print(f"{depth:>8} {result['deep_bound']:>12,} {result['shallow_bound']:>14,} "
              f"{result['ratio']:>10,} {result['deep_exponential_bound']:>12,}")
    
    print()
    print("The deep network's region bound grows EXPONENTIALLY in depth,")
    print("while the shallow network grows only POLYNOMIALLY (quadratically for n=2).")
    print()


def demo_tropical_identity():
    """Verify the tropical-ReLU identity max(a,b) = a + ReLU(b-a)."""
    print("═══════════════════════════════════════════════════════")
    print("  Tropical-ReLU Identity: max(a,b) = a + ReLU(b-a)")
    print("═══════════════════════════════════════════════════════")
    print()
    
    np.random.seed(123)
    test_cases = [(1.0, 3.0), (-2.0, 5.0), (7.0, 7.0), (0.0, -1.0),
                  (np.pi, np.e), (-100.0, 100.0)]
    # Add random cases
    for _ in range(4):
        a, b = np.random.randn(2) * 10
        test_cases.append((float(a), float(b)))
    
    all_match = True
    for a, b in test_cases:
        lhs, rhs = tropical_relu_identity(a, b)
        match = abs(lhs - rhs) < 1e-15
        all_match = all_match and match
        status = "✓" if match else "✗"
        print(f"  {status} max({a:8.3f}, {b:8.3f}) = {lhs:8.3f}, "
              f"a + ReLU(b-a) = {rhs:8.3f}")
    
    print(f"\nAll checks {'passed' if all_match else 'FAILED'}!")
    print()


def demo_region_counting():
    """Count linear regions of random networks and compare to bounds."""
    print("═══════════════════════════════════════════════════════")
    print("  Linear Region Counting (Monte Carlo)")
    print("═══════════════════════════════════════════════════════")
    print()
    
    np.random.seed(42)
    architectures = [
        ([3], "2→3→1"),
        ([3, 3], "2→3→3→1"),
        ([4, 4], "2→4→4→1"),
        ([5], "2→5→1"),
        ([2, 2, 2], "2→2→2→2→1"),
        ([10], "2→10→1"),
    ]
    
    num_trials = 5
    num_samples = 50000
    
    print(f"{'Architecture':>14} {'Bound':>8} {'2^N':>8} {'Max regions':>12} {'Ratio':>8}")
    print("-" * 55)
    
    for widths, name in architectures:
        bound = network_region_bound(2, widths)
        exp_b = exponential_bound(widths)
        max_regions = 0
        
        for _ in range(num_trials):
            W, b = random_relu_network(2, widths)
            # Only count regions in hidden layers (exclude output)
            regions = count_linear_regions(W[:-1], b[:-1], num_samples=num_samples)
            max_regions = max(max_regions, regions)
        
        ratio = max_regions / bound if bound > 0 else 0
        print(f"{name:>14} {bound:>8} {exp_b:>8} {max_regions:>12} {ratio:>8.2%}")
    
    print()
    print("The ratio observed/bound shows how close generic networks")
    print("come to the theoretical maximum.")
    print()


def demo_recurrence():
    """Verify the Zaslavsky recurrence for many values."""
    print("═══════════════════════════════════════════════════════")
    print("  Zaslavsky Recurrence: Z(m+1,n) = Z(m,n) + Z(m,n-1)")
    print("═══════════════════════════════════════════════════════")
    print()
    
    all_pass = True
    for m in range(20):
        for n in range(1, 15):
            if not zaslavsky_recurrence_verify(m, n):
                print(f"  FAILED at m={m}, n={n}")
                all_pass = False
    
    if all_pass:
        print("  ✓ Verified for all m ∈ [0,19], n ∈ [1,14]")
    
    # Show a few examples
    print()
    print("  Examples:")
    for m in [0, 1, 3, 5]:
        for n in [1, 2, 3]:
            z_next = zaslavsky_bound(m + 1, n)
            z_curr = zaslavsky_bound(m, n)
            z_prev = zaslavsky_bound(m, n - 1)
            print(f"    Z({m+1},{n}) = {z_next} = Z({m},{n}) + Z({m},{n-1}) = {z_curr} + {z_prev}")
    print()


if __name__ == "__main__":
    print()
    print("████████████████████████████████████████████████████████")
    print("█  Neural Decision Surface Topology — Demonstrations  █")
    print("████████████████████████████████████████████████████████")
    print()
    
    demo_zaslavsky_table()
    demo_depth_width_tradeoff()
    demo_tropical_identity()
    demo_recurrence()
    demo_region_counting()
    
    print("All demonstrations complete.")


"""
Visualization: Decision Surface of a ReLU Network

Shows the piecewise linear decision boundary and linear regions
for a 2D input ReLU network.
"""
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def relu(x):
    return np.maximum(x, 0)


def forward(x, weights, biases):
    h = x
    for W, b in zip(weights[:-1], biases[:-1]):
        h = relu(W @ h + b)
    return weights[-1] @ h + biases[-1]


def activation_pattern(x, weights, biases):
    h = x
    pattern = []
    for W, b in zip(weights[:-1], biases[:-1]):
        pre = W @ h + b
        pattern.extend((pre > 0).tolist())
        h = relu(pre)
    return tuple(pattern)


def main():
    np.random.seed(42)

    # Create a 2->4->4->1 network
    W1 = np.random.randn(4, 2) * 0.8
    b1 = np.random.randn(4) * 0.3
    W2 = np.random.randn(4, 4) * 0.8
    b2 = np.random.randn(4) * 0.3
    W3 = np.random.randn(1, 4) * 0.8
    b3 = np.random.randn(1) * 0.3

    weights = [W1, W2, W3]
    biases = [b1, b2, b3]

    # Grid for visualization
    resolution = 500
    x_range = np.linspace(-3, 3, resolution)
    y_range = np.linspace(-3, 3, resolution)
    X, Y = np.meshgrid(x_range, y_range)
    
    # Compute output and activation patterns
    Z = np.zeros_like(X)
    patterns = {}
    pattern_map = np.zeros_like(X, dtype=int)
    
    for i in range(resolution):
        for j in range(resolution):
            point = np.array([X[i, j], Y[i, j]])
            Z[i, j] = forward(point, weights, biases)[0]
            pat = activation_pattern(point, weights, biases)
            if pat not in patterns:
                patterns[pat] = len(patterns)
            pattern_map[i, j] = patterns[pat]

    num_regions = len(patterns)
    
    fig, axes = plt.subplots(1, 3, figsize=(18, 5.5))
    
    # Plot 1: Network output (the PL function)
    ax1 = axes[0]
    c1 = ax1.contourf(X, Y, Z, levels=30, cmap='RdBu_r')
    ax1.contour(X, Y, Z, levels=[0], colors='black', linewidths=2)
    plt.colorbar(c1, ax=ax1, label='Network output')
    ax1.set_title(f'ReLU Network Output (2→4→4→1)', fontsize=13)
    ax1.set_xlabel('x₁')
    ax1.set_ylabel('x₂')
    
    # Plot 2: Linear regions (activation patterns)
    ax2 = axes[1]
    c2 = ax2.contourf(X, Y, pattern_map, levels=num_regions, cmap='tab20')
    ax2.contour(X, Y, pattern_map, colors='black', linewidths=0.3, alpha=0.5)
    ax2.set_title(f'Linear Regions ({num_regions} found, bound={49+1})', fontsize=13)
    ax2.set_xlabel('x₁')
    ax2.set_ylabel('x₂')
    
    # Plot 3: Decision boundary detail
    ax3 = axes[2]
    ax3.contourf(X, Y, np.sign(Z), levels=[-1.5, 0, 1.5], colors=['#ff9999', '#9999ff'], alpha=0.5)
    ax3.contour(X, Y, Z, levels=[0], colors='black', linewidths=2)
    # Show some hyperplane boundaries from layer 1
    for k in range(4):
        # Layer 1 hyperplane: W1[k] @ x + b1[k] = 0
        w = W1[k]
        b = b1[k]
        if abs(w[1]) > 1e-10:
            x_line = np.linspace(-3, 3, 100)
            y_line = -(w[0] * x_line + b) / w[1]
            mask = (y_line >= -3) & (y_line <= 3)
            ax3.plot(x_line[mask], y_line[mask], '--', color='green', alpha=0.4, linewidth=1)
    ax3.set_title('Decision Boundary (class boundary in black)', fontsize=13)
    ax3.set_xlabel('x₁')
    ax3.set_ylabel('x₂')
    ax3.set_xlim(-3, 3)
    ax3.set_ylim(-3, 3)
    
    plt.tight_layout()
    plt.savefig('decision_surface.png', dpi=150, bbox_inches='tight')
    print(f"Saved decision_surface.png ({num_regions} linear regions found)")


if __name__ == "__main__":
    main()


"""
Visualization: Depth vs Width Tradeoff

Plots the exponential advantage of depth in ReLU network region counting.
"""
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
from math import comb, prod


def zaslavsky_bound(m: int, n: int) -> int:
    return sum(comb(m, k) for k in range(n + 1))


def network_region_bound(input_dim: int, layer_widths: list) -> int:
    return prod(zaslavsky_bound(w, input_dim) for w in layer_widths)


def main():
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))

    # Plot 1: Deep vs Shallow for varying depth
    input_dim = 2
    width = 3
    depths = list(range(1, 16))

    deep_bounds = [network_region_bound(input_dim, [width] * d) for d in depths]
    shallow_bounds = [network_region_bound(input_dim, [width * d]) for d in depths]
    exp_bounds = [2 ** (width * d) for d in depths]

    ax1 = axes[0]
    ax1.semilogy(depths, deep_bounds, 'b-o', label=f'Deep: Z({width},2)^L', linewidth=2, markersize=6)
    ax1.semilogy(depths, shallow_bounds, 'r-s', label=f'Shallow: Z({width}L,2)', linewidth=2, markersize=6)
    ax1.semilogy(depths, exp_bounds, 'k--', label=f'Exponential: 2^({width}L)', linewidth=1.5, alpha=0.5)
    ax1.set_xlabel('Depth L (total neurons = 3L)', fontsize=12)
    ax1.set_ylabel('Region Bound', fontsize=12)
    ax1.set_title('Depth vs Width Tradeoff (n=2, w=3)', fontsize=14)
    ax1.legend(fontsize=10)
    ax1.grid(True, alpha=0.3)

    # Plot 2: Zaslavsky bound vs dimension
    ax2 = axes[1]
    ms = list(range(1, 21))
    for n in [1, 2, 3, 5]:
        zs = [zaslavsky_bound(m, n) for m in ms]
        ax2.semilogy(ms, zs, '-o', label=f'Z(m, {n})', markersize=4)
    
    exp_vals = [2**m for m in ms]
    ax2.semilogy(ms, exp_vals, 'k--', label='2^m (upper bound)', linewidth=2, alpha=0.5)
    ax2.set_xlabel('Number of hyperplanes m', fontsize=12)
    ax2.set_ylabel('Zaslavsky Bound Z(m, n)', fontsize=12)
    ax2.set_title('Zaslavsky Bound Growth', fontsize=14)
    ax2.legend(fontsize=10)
    ax2.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('depth_width_tradeoff.png', dpi=150, bbox_inches='tight')
    print("Saved depth_width_tradeoff.png")


if __name__ == "__main__":
    main()
