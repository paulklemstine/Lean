#!/usr/bin/env python3
"""
demo.py — Tropical Decision Boundaries of ReLU Networks

Demonstrates the key results:
1. Depth-width asymmetry: deep networks create exponentially more regions
2. Tropical sum distributivity: summing ReLU neurons multiplies complexity
3. Decision boundary visualization for small networks
"""

import numpy as np

def relu(x):
    """ReLU activation function."""
    return np.maximum(x, 0)

def count_linear_regions_1d(weights_list, biases_list):
    """
    Count the number of linear regions of a 1D ReLU network.
    
    Parameters:
        weights_list: list of weight matrices (each w_{l+1} x w_l)
        biases_list: list of bias vectors (each w_{l+1})
    
    Returns:
        Number of distinct linear regions found by sampling
    """
    # Sample many points and track which neurons are active
    x = np.linspace(-10, 10, 100000)
    h = x.reshape(-1, 1)
    
    patterns = set()
    for W, b in zip(weights_list, biases_list):
        pre_activation = h @ W.T + b
        pattern = tuple((pre_activation > 0).astype(int).flatten().tolist())
        # Track activation pattern at each point
        h = relu(pre_activation)
    
    # Count distinct activation patterns
    activation_patterns = set()
    h = x.reshape(-1, 1)
    for i, (W, b) in enumerate(zip(weights_list, biases_list)):
        pre_act = h @ W.T + b
        for j in range(len(x)):
            pat = tuple((pre_act[j] > 0).astype(int))
            activation_patterns.add(pat)
        h = relu(pre_act)
    
    # More precise: count breakpoints
    output = x.copy()
    h = x.reshape(-1, 1)
    for W, b in zip(weights_list, biases_list):
        h = relu(h @ W.T + b)
    output = (h @ np.array([[1.0]])).flatten() if h.shape[1] > 1 else h.flatten()
    
    # Count sign changes in the derivative
    dx = np.diff(output)
    ddx = np.diff(dx)
    breakpoints = np.sum(np.abs(ddx) > 1e-8)
    
    return breakpoints + 1  # regions = breakpoints + 1


def depth_width_asymmetry_demo():
    """
    Demonstrate that (w+1)^L >> L*w + 1.
    Deep networks create exponentially more regions than shallow ones.
    """
    print("=" * 60)
    print("DEPTH-WIDTH ASYMMETRY THEOREM")
    print("=" * 60)
    print()
    print("For a depth-L, width-w network:")
    print("  Deep:    (w+1)^L linear regions")
    print("  Shallow: L*w + 1 linear regions (same total neurons)")
    print()
    
    print(f"{'Width w':>8} {'Depth L':>8} {'Deep (w+1)^L':>15} {'Shallow L*w+1':>15} {'Ratio':>10}")
    print("-" * 60)
    
    for w in [2, 3, 5, 10]:
        for L in [2, 3, 5, 10]:
            deep = (w + 1) ** L
            shallow = L * w + 1
            ratio = deep / shallow
            print(f"{w:>8} {L:>8} {deep:>15,} {shallow:>15} {ratio:>10.1f}")
    
    print()
    print("Key insight: The ratio grows EXPONENTIALLY with depth.")
    print("A 10-layer, 10-wide network has 11^10 ≈ 2.6 × 10^10 regions")
    print("vs a single layer with 100 neurons: only 101 regions.")
    print()


def tropical_sum_demo():
    """
    Demonstrate max(a1,a2) + max(b1,b2) = max(a1+b1, a1+b2, a2+b1, a2+b2).
    """
    print("=" * 60)
    print("TROPICAL SUM DISTRIBUTIVITY")
    print("=" * 60)
    print()
    
    np.random.seed(42)
    for trial in range(5):
        a1, a2, b1, b2 = np.random.randn(4)
        lhs = max(a1, a2) + max(b1, b2)
        rhs = max(a1+b1, a1+b2, a2+b1, a2+b2)
        print(f"Trial {trial+1}: max({a1:.3f}, {a2:.3f}) + max({b1:.3f}, {b2:.3f})")
        print(f"  LHS = {lhs:.6f}")
        print(f"  RHS = max({a1+b1:.3f}, {a1+b2:.3f}, {a2+b1:.3f}, {a2+b2:.3f}) = {rhs:.6f}")
        print(f"  Equal: {np.isclose(lhs, rhs)}")
        print()
    
    print("This identity explains why summing k ReLU neurons creates")
    print("at most 2^k affine pieces: each neuron has 2 pieces,")
    print("and the sum distributes over max to create all combinations.")
    print()


def maslov_dequantization_demo():
    """
    Demonstrate the Maslov dequantization: as ε→0,
    ε·log(e^(a/ε) + e^(b/ε)) → max(a, b).
    """
    print("=" * 60)
    print("MASLOV DEQUANTIZATION (TROPICAL = LIMIT OF CLASSICAL)")
    print("=" * 60)
    print()
    
    a, b = 3.0, 1.0
    print(f"a = {a}, b = {b}, max(a,b) = {max(a,b)}")
    print()
    print(f"{'ε':>10} {'ε·log(e^(a/ε)+e^(b/ε))':>25} {'max(a,b)':>10} {'Gap':>10}")
    print("-" * 60)
    
    for eps in [10.0, 1.0, 0.1, 0.01, 0.001, 0.0001]:
        # Numerically stable computation
        m = max(a/eps, b/eps)
        val = eps * (m + np.log(np.exp(a/eps - m) + np.exp(b/eps - m)))
        gap = val - max(a, b)
        print(f"{eps:>10.4f} {val:>25.10f} {max(a,b):>10.1f} {gap:>10.6f}")
    
    print()
    print(f"Upper bound gap: ε·log(2) = ε × {np.log(2):.4f}")
    print("The tropical semiring (ℝ, max, +) is the limit of")
    print("classical algebra under Maslov dequantization.")
    print()


def decision_boundary_demo():
    """
    Demonstrate decision boundary counting for small networks.
    """
    print("=" * 60)
    print("DECISION BOUNDARY STRUCTURE")
    print("=" * 60)
    print()
    
    # Single hidden layer, width w
    for w in [1, 2, 3, 5, 10]:
        # Random network
        np.random.seed(w)
        W1 = np.random.randn(w, 1)
        b1 = np.random.randn(w)
        W2 = np.random.randn(1, w)
        b2 = np.random.randn(1)
        
        # Compute output
        x = np.linspace(-5, 5, 100000)
        h = relu(x.reshape(-1, 1) @ W1.T + b1.reshape(1, -1))  # hidden
        y = (h @ W2.T + b2).flatten()
        
        # Count zero crossings (decision boundary points)
        zero_crossings = np.sum(np.abs(np.diff(np.sign(y))) > 0)
        
        # Theoretical bound: w (for single layer)
        print(f"Width {w:>2}: {zero_crossings:>3} boundary points (bound: {w})")
    
    print()
    print("For depth-L networks:")
    for L in [1, 2, 3, 4, 5]:
        w = 3
        np.random.seed(L * 100)
        
        x = np.linspace(-5, 5, 100000)
        h = x.reshape(-1, 1)
        
        for l in range(L):
            in_dim = 1 if l == 0 else w
            W = np.random.randn(w, in_dim) * 0.5
            b = np.random.randn(w) * 0.5
            h = relu(h @ W.T + b)
        
        W_out = np.random.randn(1, w)
        y = (h @ W_out.T).flatten()
        
        zero_crossings = np.sum(np.abs(np.diff(np.sign(y))) > 0)
        bound = (w + 1) ** L - 1
        
        print(f"Depth {L}, Width {w}: {zero_crossings:>5} boundary pts (bound: {bound:>6})")
    
    print()
    print("The bound (w+1)^L - 1 is tight: deep networks CAN create")
    print("exponentially many decision boundary components.")


def tropical_bezout_demo():
    """
    Demonstrate the tropical Bézout bound: d*n ≤ C(d+n, n).
    """
    print()
    print("=" * 60)
    print("TROPICAL BÉZOUT BRIDGE")
    print("=" * 60)
    print()
    print("d*n ≤ C(d+n, n): tropical intersection bound")
    print()
    
    from math import comb
    print(f"{'d':>5} {'n':>5} {'d*n':>8} {'C(d+n,n)':>10} {'Ratio':>8}")
    print("-" * 40)
    for d in [1, 2, 3, 5, 10]:
        for n in [1, 2, 3, 5]:
            product = d * n
            binomial = comb(d + n, n)
            print(f"{d:>5} {n:>5} {product:>8} {binomial:>10} {binomial/product:>8.2f}")


if __name__ == "__main__":
    depth_width_asymmetry_demo()
    tropical_sum_demo()
    maslov_dequantization_demo()
    decision_boundary_demo()
    tropical_bezout_demo()


#!/usr/bin/env python3
"""
Visualization: Depth-Width Asymmetry in ReLU Networks

Shows the exponential gap between deep and shallow network region counts.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt


def plot_depth_width_asymmetry():
    """Plot (w+1)^L vs L*w+1 for various w and L."""
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))
    
    # Left: Fix w, vary L
    ax = axes[0]
    for w in [2, 3, 5, 10]:
        L_vals = np.arange(1, 11)
        deep = (w + 1.0) ** L_vals
        shallow = L_vals * w + 1
        ax.semilogy(L_vals, deep, 'o-', label=f'Deep: (w+1)^L, w={w}', markersize=4)
        ax.semilogy(L_vals, shallow, 's--', label=f'Shallow: Lw+1, w={w}', 
                    markersize=4, alpha=0.5)
    
    ax.set_xlabel('Depth L', fontsize=12)
    ax.set_ylabel('Max Linear Regions', fontsize=12)
    ax.set_title('Depth-Width Asymmetry\n(Fixed Width, Varying Depth)', fontsize=13)
    ax.legend(fontsize=8, ncol=2)
    ax.grid(True, alpha=0.3)
    
    # Right: Fix total neurons N = w*L, optimize depth
    ax = axes[1]
    for N in [10, 20, 50, 100]:
        depths = []
        regions = []
        for L in range(1, N + 1):
            w = N // L
            if w < 1:
                break
            depths.append(L)
            regions.append((w + 1) ** L)
        
        ax.semilogy(depths, regions, 'o-', label=f'N={N} neurons', markersize=3)
    
    ax.set_xlabel('Depth L (width = N/L)', fontsize=12)
    ax.set_ylabel('Max Linear Regions', fontsize=12)
    ax.set_title('Optimal Depth for Fixed Neuron Budget\n(regions = (N/L + 1)^L)', fontsize=13)
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)
    
    plt.tight_layout()
    plt.savefig('depth_width_asymmetry.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: depth_width_asymmetry.png")


def plot_decision_boundaries():
    """Visualize decision boundaries for networks of increasing depth."""
    def relu(x):
        return np.maximum(x, 0)
    
    fig, axes = plt.subplots(2, 3, figsize=(15, 8))
    axes = axes.flatten()
    
    np.random.seed(42)
    
    for idx, L in enumerate([1, 2, 3, 4, 5, 8]):
        w = 3  # width
        x = np.linspace(-3, 3, 10000)
        h = x.reshape(-1, 1)
        
        for l in range(L):
            in_dim = 1 if l == 0 else w
            W = np.random.randn(w, in_dim) * 0.8
            b = np.random.randn(w) * 0.3
            h = relu(h @ W.T + b)
        
        W_out = np.random.randn(1, w) * 0.5
        b_out = np.random.randn(1) * 0.1
        y = (h @ W_out.T + b_out).flatten()
        
        ax = axes[idx]
        ax.plot(x, y, 'b-', linewidth=0.8)
        ax.axhline(y=0, color='r', linewidth=0.5, linestyle='--')
        
        # Mark zero crossings
        crossings = np.where(np.abs(np.diff(np.sign(y))) > 0)[0]
        for c in crossings:
            ax.axvline(x=x[c], color='r', alpha=0.3, linewidth=0.5)
        
        bound = (w + 1) ** L - 1
        ax.set_title(f'Depth {L}, Width {w}\n{len(crossings)} zeros (bound: {bound})', fontsize=10)
        ax.set_xlim(-3, 3)
        ax.grid(True, alpha=0.2)
    
    plt.suptitle('Decision Boundaries of ReLU Networks (Increasing Depth)', fontsize=14, y=1.02)
    plt.tight_layout()
    plt.savefig('decision_boundaries.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: decision_boundaries.png")


def plot_maslov_dequantization():
    """Visualize the Maslov dequantization convergence."""
    fig, axes = plt.subplots(1, 2, figsize=(14, 5))
    
    x = np.linspace(-3, 3, 1000)
    a_vals = x
    b = 0.0
    
    ax = axes[0]
    # True max
    true_max = np.maximum(a_vals, b)
    ax.plot(x, true_max, 'k-', linewidth=2, label='max(x, 0) = ReLU(x)')
    
    for eps in [2.0, 1.0, 0.5, 0.1]:
        smooth = eps * np.log(np.exp(a_vals / eps) + np.exp(b / eps))
        ax.plot(x, smooth, '--', linewidth=1.5, label=f'ε = {eps}', alpha=0.7)
    
    ax.set_xlabel('x', fontsize=12)
    ax.set_ylabel('f(x)', fontsize=12)
    ax.set_title('Maslov Dequantization\nSmooth → Tropical (ReLU)', fontsize=13)
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)
    
    # Right: gap convergence
    ax = axes[1]
    eps_vals = np.logspace(-3, 1, 100)
    a, b = 3.0, 1.0
    gaps = []
    for eps in eps_vals:
        m = max(a/eps, b/eps)
        val = eps * (m + np.log(np.exp(a/eps - m) + np.exp(b/eps - m)))
        gaps.append(val - max(a, b))
    
    ax.loglog(eps_vals, gaps, 'b-', linewidth=2, label='Actual gap')
    ax.loglog(eps_vals, eps_vals * np.log(2), 'r--', linewidth=1.5, label='ε·log(2) bound')
    ax.set_xlabel('ε', fontsize=12)
    ax.set_ylabel('Gap from max(a,b)', fontsize=12)
    ax.set_title('Dequantization Gap Convergence\n(a=3, b=1)', fontsize=13)
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)
    
    plt.tight_layout()
    plt.savefig('maslov_dequantization.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: maslov_dequantization.png")


if __name__ == "__main__":
    plot_depth_width_asymmetry()
    plot_decision_boundaries()
    plot_maslov_dequantization()
