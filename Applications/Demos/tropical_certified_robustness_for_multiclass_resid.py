#!/usr/bin/env python3
"""
Certified Robustness for Multiclass Residual Networks — Interactive Demo

This script demonstrates the core theorems from the Lean formalization:
1. Residual block Lipschitz calculus: x ↦ x + g(x) with constant (1 + K_g)
2. Compositional Lipschitz bounds: product of (1 + K_i) for each block
3. Margin perturbation bounds: |margin change| ≤ 2K · d∞
4. Certified radius computation: r* = γ / (2K)

We build concrete residual networks, compute certified radii at test points,
and visualize the robustness certificates.
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.patches as patches
import os

# ─── Residual Network Components ───────────────────────────────────────────────

def relu(x):
    """ReLU activation (piecewise-linear, tropical)."""
    return np.maximum(x, 0)

def make_residual_block(W, b):
    """Create a residual block x ↦ x + relu(W @ x + b).
    Returns (block_fn, lipschitz_constant)."""
    K_g = np.linalg.norm(W, ord=np.inf)  # L∞ → L∞ operator norm
    def block(x):
        return x + relu(W @ x + b)
    return block, K_g

def compose_residual_blocks(blocks_with_constants):
    """Compose residual blocks and compute product Lipschitz constant.
    
    For blocks with constants K_1, ..., K_n, the composite has
    Lipschitz constant ∏_i (1 + K_i).
    """
    K_total = 1.0
    for _, K_i in blocks_with_constants:
        K_total *= (1 + K_i)
    
    def composite(x):
        z = x.copy()
        for block_fn, _ in blocks_with_constants:
            z = block_fn(z)
        return z
    return composite, K_total

def make_linear_head(W_head, b_head):
    """Create linear classification head: logits = W_head @ features + b_head.
    Returns (head_fn, lipschitz_constant)."""
    K_head = np.linalg.norm(W_head, ord=np.inf)
    def head(x):
        return W_head @ x + b_head
    return head, K_head

# ─── Certified Radius Computation ─────────────────────────────────────────────

def compute_gap(logits, y):
    """Compute the gap: min_{j ≠ y} (logits[y] - logits[j])."""
    C = len(logits)
    margins = [logits[y] - logits[j] for j in range(C) if j != y]
    return min(margins)

def certified_radius(gap, K):
    """Certified L∞ radius: r* = γ / (2K).
    
    This is the main result: for r < r*, the predicted class is guaranteed
    to be stable under any L∞ perturbation of radius r.
    """
    if K <= 0:
        return float('inf') if gap > 0 else 0
    return gap / (2 * K)

def linf_dist(x, y):
    """L∞ distance between vectors."""
    return np.max(np.abs(x - y))

# ─── Demo 1: Residual Block Lipschitz Bound ────────────────────────────────────

def demo_residual_lipschitz():
    """Verify the residual block Lipschitz bound empirically."""
    print("=" * 70)
    print("Demo 1: Residual Block Lipschitz Bound")
    print("=" * 70)
    print()
    print("Theorem: If g is K_g-Lipschitz (L∞), then x ↦ x + g(x)")
    print("         is (1 + K_g)-Lipschitz (L∞).")
    print()
    
    np.random.seed(42)
    d = 5
    W = np.random.randn(d, d) * 0.3
    b = np.random.randn(d) * 0.1
    
    block, K_g = make_residual_block(W, b)
    K_block = 1 + K_g
    
    print(f"  Dimension d = {d}")
    print(f"  g(x) = relu(Wx + b) with K_g = {K_g:.4f}")
    print(f"  Predicted Lipschitz constant: 1 + K_g = {K_block:.4f}")
    print()
    
    # Empirical verification
    n_trials = 10000
    max_ratio = 0
    ratios = []
    for _ in range(n_trials):
        x = np.random.randn(d)
        y = np.random.randn(d)
        d_in = linf_dist(x, y)
        if d_in < 1e-10:
            continue
        d_out = linf_dist(block(x), block(y))
        ratio = d_out / d_in
        ratios.append(ratio)
        max_ratio = max(max_ratio, ratio)
    
    print(f"  Empirical max ratio: {max_ratio:.4f}")
    print(f"  Bound satisfied: {max_ratio <= K_block + 1e-10}")
    print(f"  Slack: {K_block - max_ratio:.4f}")
    print()
    
    return ratios, K_block

# ─── Demo 2: Compositional Lipschitz Constant ─────────────────────────────────

def demo_compositional_lipschitz():
    """Demonstrate multiplicative Lipschitz composition for residual blocks."""
    print("=" * 70)
    print("Demo 2: Compositional Lipschitz for Residual Networks")
    print("=" * 70)
    print()
    print("Theorem: For n residual blocks with constants K_1, ..., K_n,")
    print("         the composition has Lipschitz constant ∏_i (1 + K_i).")
    print()
    
    np.random.seed(123)
    d = 4
    n_blocks = 4
    
    blocks = []
    block_constants = []
    for i in range(n_blocks):
        W = np.random.randn(d, d) * 0.2
        b = np.random.randn(d) * 0.05
        block_fn, K_g = make_residual_block(W, b)
        blocks.append((block_fn, K_g))
        block_constants.append(K_g)
        print(f"  Block {i+1}: K_g = {K_g:.4f}, factor = {1 + K_g:.4f}")
    
    composite, K_total = compose_residual_blocks(blocks)
    print(f"\n  Product constant: ∏(1 + K_i) = {K_total:.4f}")
    
    # Empirical verification
    n_trials = 10000
    max_ratio = 0
    for _ in range(n_trials):
        x = np.random.randn(d)
        y = np.random.randn(d)
        d_in = linf_dist(x, y)
        if d_in < 1e-10:
            continue
        d_out = linf_dist(composite(x), composite(y))
        max_ratio = max(max_ratio, d_out / d_in)
    
    print(f"  Empirical max ratio: {max_ratio:.4f}")
    print(f"  Bound satisfied: {max_ratio <= K_total + 1e-10}")
    print()
    
    return block_constants, K_total

# ─── Demo 3: Certified Robustness Certificate ─────────────────────────────────

def demo_certified_radius():
    """Full certified radius computation for a residual classifier."""
    print("=" * 70)
    print("Demo 3: Certified Robustness Radius")
    print("=" * 70)
    print()
    print("Main Theorem: For K-Lipschitz network f with argmax class y")
    print("              and gap γ = min_{j≠y} (f_y(x) - f_j(x)),")
    print("              classification is stable for L∞ radius r < γ/(2K).")
    print()
    
    np.random.seed(42)
    d = 8   # input dimension
    C = 5   # number of classes
    
    # Build a 3-block residual network + linear head
    blocks = []
    for i in range(3):
        W = np.random.randn(d, d) * 0.15
        b = np.random.randn(d) * 0.05
        block_fn, K_g = make_residual_block(W, b)
        blocks.append((block_fn, K_g))
    
    composite, K_body = compose_residual_blocks(blocks)
    
    W_head = np.random.randn(C, d) * 0.3
    b_head = np.random.randn(C) * 0.1
    head_fn, K_head = make_linear_head(W_head, b_head)
    
    K_network = K_head * K_body
    
    def network(x):
        return head_fn(composite(x))
    
    print(f"  Architecture: {d}D input -> 3 residual blocks -> {C}-class logits")
    print(f"  K_body = {K_body:.4f}")
    print(f"  K_head = {K_head:.4f}")
    print(f"  K_network = K_head * K_body = {K_network:.4f}")
    print()
    
    # Test on multiple points
    n_test = 6
    results = []
    for t in range(n_test):
        x = np.random.randn(d) * 0.5
        logits = network(x)
        y_pred = np.argmax(logits)
        gap = compute_gap(logits, y_pred)
        r_cert = certified_radius(gap, K_network)
        
        print(f"  Point {t+1}: predicted class = {y_pred}, "
              f"gap gamma = {gap:.4f}, certified r* = {r_cert:.4f}")
        
        # Verify: random perturbations within certified radius
        n_verify = 1000
        stable = True
        for _ in range(n_verify):
            delta = np.random.uniform(-r_cert * 0.99, r_cert * 0.99, size=d)
            x_pert = x + delta
            y_pert = np.argmax(network(x_pert))
            if y_pert != y_pred:
                stable = False
                break
        
        print(f"          Verified stable under {n_verify} random perturbations: {stable}")
        results.append((x, y_pred, gap, r_cert, logits))
    
    print()
    return results, K_network, network, d, C

# ─── Demo 4: Margin Perturbation Visualization ────────────────────────────────

def demo_margin_perturbation(network, x0, y_pred, K_network, d):
    """Visualize how margins degrade under perturbation."""
    print("=" * 70)
    print("Demo 4: Margin Degradation Under Perturbation")
    print("=" * 70)
    print()
    
    logits0 = network(x0)
    C = len(logits0)
    gap = compute_gap(logits0, y_pred)
    r_cert = certified_radius(gap, K_network)
    
    # Sweep perturbation magnitude
    radii = np.linspace(0, r_cert * 2.5, 200)
    min_margins = []
    theoretical_lower = []
    
    for r in radii:
        # Find worst-case perturbation direction (approximate)
        worst_margin = float('inf')
        for _ in range(100):
            delta = np.random.randn(d)
            if np.max(np.abs(delta)) > 0:
                delta = delta / np.max(np.abs(delta)) * r  # L∞ norm = r
            x_pert = x0 + delta
            logits_pert = network(x_pert)
            m = compute_gap(logits_pert, y_pred)
            worst_margin = min(worst_margin, m)
        min_margins.append(worst_margin)
        theoretical_lower.append(gap - 2 * K_network * r)
    
    fig, ax = plt.subplots(figsize=(10, 6))
    ax.plot(radii, min_margins, 'b-', linewidth=2, label='Empirical worst-case margin')
    ax.plot(radii, theoretical_lower, 'r--', linewidth=2, 
            label=r'Theoretical lower bound: $\gamma - 2K \cdot r$')
    ax.axhline(y=0, color='gray', linewidth=0.5)
    ax.axvline(x=r_cert, color='green', linewidth=2, linestyle=':', 
               label=f'Certified radius r* = {r_cert:.4f}')
    ax.fill_betweenx([-1, max(min_margins)*1.1], 0, r_cert, alpha=0.1, color='green')
    ax.set_xlabel(r'Perturbation radius $r$ ($L^\infty$)', fontsize=13)
    ax.set_ylabel('Minimum margin', fontsize=13)
    ax.set_title('Margin Degradation Under L-infinity Perturbation', fontsize=14)
    ax.legend(fontsize=11)
    ax.set_ylim(bottom=min(min(theoretical_lower), min(min_margins)) - 0.1)
    plt.tight_layout()
    plt.savefig('demos/margin_degradation.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("  Saved: demos/margin_degradation.png")
    print()

# ─── Demo 5: 2D Decision Boundary Visualization ───────────────────────────────

def demo_2d_decision_boundary():
    """Visualize certified radius balls on a 2D decision boundary."""
    print("=" * 70)
    print("Demo 5: 2D Decision Boundary with Certified Radii")
    print("=" * 70)
    print()
    
    np.random.seed(99)
    d = 2
    C = 3
    
    # Simple 2D residual network
    W1 = np.array([[0.5, -0.3], [0.2, 0.4]])
    b1 = np.array([0.1, -0.1])
    block1, K1 = make_residual_block(W1, b1)
    
    W2 = np.array([[0.3, 0.1], [-0.2, 0.5]])
    b2 = np.array([-0.05, 0.05])
    block2, K2 = make_residual_block(W2, b2)
    
    composite, K_body = compose_residual_blocks([(block1, K1), (block2, K2)])
    
    W_head = np.array([[1.0, 0.5], [-0.5, 1.0], [0.3, -0.8]])
    b_head = np.array([0.0, 0.1, -0.1])
    head_fn, K_head = make_linear_head(W_head, b_head)
    K_net = K_head * K_body
    
    def net_2d(x):
        return head_fn(composite(x))
    
    # Create decision boundary plot
    x_range = np.linspace(-3, 3, 300)
    y_range = np.linspace(-3, 3, 300)
    XX, YY = np.meshgrid(x_range, y_range)
    
    predictions = np.zeros_like(XX, dtype=int)
    for i in range(XX.shape[0]):
        for j in range(XX.shape[1]):
            pt = np.array([XX[i, j], YY[i, j]])
            predictions[i, j] = np.argmax(net_2d(pt))
    
    fig, ax = plt.subplots(figsize=(10, 8))
    colors = ['#FF6B6B', '#4ECDC4', '#45B7D1']
    cmap = plt.cm.colors.ListedColormap(colors)
    ax.contourf(XX, YY, predictions, levels=[-0.5, 0.5, 1.5, 2.5], 
                colors=colors, alpha=0.3)
    ax.contour(XX, YY, predictions, levels=[0.5, 1.5], colors='black', 
               linewidths=1.5)
    
    # Sample points and draw certified radius boxes
    test_points = [
        np.array([1.0, 0.5]),
        np.array([-1.0, 1.0]),
        np.array([0.5, -1.5]),
        np.array([-0.5, -0.5]),
        np.array([2.0, -1.0]),
        np.array([-2.0, 0.0]),
    ]
    
    for pt in test_points:
        logits = net_2d(pt)
        y_pred = np.argmax(logits)
        gap = compute_gap(logits, y_pred)
        r = certified_radius(gap, K_net)
        
        # Draw L∞ ball as a square
        rect = patches.Rectangle(
            (pt[0] - r, pt[1] - r), 2*r, 2*r,
            linewidth=2, edgecolor=colors[y_pred], 
            facecolor=colors[y_pred], alpha=0.4
        )
        ax.add_patch(rect)
        ax.plot(pt[0], pt[1], 'ko', markersize=5)
        ax.annotate(f'r*={r:.3f}', (pt[0], pt[1] + r + 0.1), 
                    fontsize=8, ha='center')
    
    ax.set_xlabel('$x_1$', fontsize=13)
    ax.set_ylabel('$x_2$', fontsize=13)
    ax.set_title(f'Decision Boundaries with Certified L-inf Robustness Balls\n'
                 f'(Network Lipschitz constant K = {K_net:.2f})', fontsize=13)
    ax.set_xlim(-3, 3)
    ax.set_ylim(-3, 3)
    ax.set_aspect('equal')
    plt.tight_layout()
    plt.savefig('demos/decision_boundary_certified.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("  Saved: demos/decision_boundary_certified.png")
    print()

# ─── Demo 6: Lipschitz Constant vs Depth Trade-off ────────────────────────────

def demo_depth_tradeoff():
    """Show how certified radius changes with network depth."""
    print("=" * 70)
    print("Demo 6: Depth vs Certified Radius Trade-off")
    print("=" * 70)
    print()
    
    np.random.seed(42)
    d = 4
    C = 3
    
    depths = list(range(1, 16))
    avg_radii = []
    lip_constants = []
    
    for n_blocks in depths:
        # Build network with n_blocks residual blocks
        blocks = []
        for _ in range(n_blocks):
            W = np.random.randn(d, d) * 0.1  # small weights
            b = np.random.randn(d) * 0.02
            block_fn, K_g = make_residual_block(W, b)
            blocks.append((block_fn, K_g))
        
        composite, K_body = compose_residual_blocks(blocks)
        W_head = np.random.randn(C, d) * 0.3
        b_head = np.zeros(C)
        head_fn, K_head = make_linear_head(W_head, b_head)
        K_net = K_head * K_body
        
        def net(x, _comp=composite, _head=head_fn):
            return _head(_comp(x))
        
        # Average certified radius over test points
        radii_list = []
        for _ in range(50):
            x = np.random.randn(d) * 0.5
            logits = net(x)
            y_pred = np.argmax(logits)
            gap = compute_gap(logits, y_pred)
            if gap > 0:
                radii_list.append(certified_radius(gap, K_net))
        
        avg_r = np.mean(radii_list) if radii_list else 0
        avg_radii.append(avg_r)
        lip_constants.append(K_net)
        print(f"  Depth {n_blocks:2d}: K_net = {K_net:.2f}, avg r* = {avg_r:.4f}")
    
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))
    
    ax1.semilogy(depths, lip_constants, 'b-o', linewidth=2, markersize=6)
    ax1.set_xlabel('Number of Residual Blocks', fontsize=13)
    ax1.set_ylabel('Network Lipschitz Constant K', fontsize=13)
    ax1.set_title('Lipschitz Constant Growth with Depth', fontsize=13)
    ax1.grid(True, alpha=0.3)
    
    ax2.plot(depths, avg_radii, 'r-o', linewidth=2, markersize=6)
    ax2.set_xlabel('Number of Residual Blocks', fontsize=13)
    ax2.set_ylabel('Average Certified Radius r*', fontsize=13)
    ax2.set_title('Certified Radius vs Network Depth', fontsize=13)
    ax2.grid(True, alpha=0.3)
    
    plt.tight_layout()
    plt.savefig('demos/depth_tradeoff.png', dpi=150, bbox_inches='tight')
    plt.close()
    print(f"\n  Saved: demos/depth_tradeoff.png")
    print()

# ─── Main ──────────────────────────────────────────────────────────────────────

if __name__ == "__main__":
    os.makedirs('demos', exist_ok=True)
    
    print()
    print("=" * 70)
    print("  Certified Robustness for Multiclass Residual Networks")
    print("  Interactive Demonstration of Formally Verified Theorems")
    print("=" * 70)
    print()
    
    # Demo 1: Single residual block
    ratios, K_block = demo_residual_lipschitz()
    
    # Demo 2: Compositional Lipschitz
    block_constants, K_total = demo_compositional_lipschitz()
    
    # Demo 3: Full certified radius
    results, K_net, network, d, C = demo_certified_radius()
    
    # Demo 4: Margin degradation
    x0, y_pred, gap0, r_cert0, logits0 = results[0]
    demo_margin_perturbation(network, x0, y_pred, K_net, d)
    
    # Demo 5: 2D visualization
    demo_2d_decision_boundary()
    
    # Demo 6: Depth trade-off
    demo_depth_tradeoff()
    
    print("=" * 70)
    print("All demos completed. Visualizations saved to demos/")
    print("=" * 70)
