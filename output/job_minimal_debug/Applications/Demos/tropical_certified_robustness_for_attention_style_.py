#!/usr/bin/env python3
"""
Tropical Certified Robustness for Attention-Style Gating Networks
=================================================================

This demo illustrates the formally verified robustness certificates for
piecewise-affine gating networks. We construct concrete numerical examples
of gated expert blocks and compute certified perturbation radii.

Key concepts demonstrated:
1. Gated blocks as convex combinations of affine experts
2. Cellwise affine structure (route fibers)
3. Lipschitz constant computation via row-sum norms
4. Margin-to-robustness certificates
5. Visualization of robustness regions and expert routing
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
from matplotlib.colors import LinearSegmentedColormap
import os

# ============================================================================
# Core definitions matching the Lean formalization
# ============================================================================

class AffineMapVec:
    """Affine map ℝ^d → ℝ^o as (matrix, bias) pair."""
    def __init__(self, matrix, bias):
        self.matrix = np.array(matrix, dtype=float)  # shape (o, d)
        self.bias = np.array(bias, dtype=float)        # shape (o,)

    def eval(self, x):
        """Evaluate: A @ x + b"""
        return self.matrix @ np.array(x) + self.bias

    def linf_row_sums(self):
        """Row-sum operator norm for L∞ → L∞."""
        return np.sum(np.abs(self.matrix), axis=1)

    def linf_norm(self):
        """Maximum row-sum = L∞ operator norm."""
        return np.max(self.linf_row_sums())


class GatedBlock:
    """
    A gated block: finite experts with finite-valued routing.

    experts: list of AffineMapVec (indexed by ι)
    selector: dict mapping σ → weight vector over experts
    route: function from input x → σ (selector index)
    """
    def __init__(self, experts, selector, route_fn):
        self.experts = experts
        self.selector = selector
        self.route_fn = route_fn

    def eval(self, x):
        """Evaluate: ∑ᵢ sel(route(x), i) · experts[i](x)"""
        s = self.route_fn(x)
        weights = self.selector[s]
        result = np.zeros_like(self.experts[0].eval(x))
        for i, (w, expert) in enumerate(zip(weights, self.experts)):
            result += w * expert.eval(x)
        return result

    def combined_affine(self, s):
        """The combined affine map for a fixed route value s."""
        weights = self.selector[s]
        d = self.experts[0].matrix.shape[1]
        o = self.experts[0].matrix.shape[0]
        combined_matrix = np.zeros((o, d))
        combined_bias = np.zeros(o)
        for w, expert in zip(weights, self.experts):
            combined_matrix += w * expert.matrix
            combined_bias += w * expert.bias
        return AffineMapVec(combined_matrix, combined_bias)


def compute_lipschitz_bound(experts):
    """Compute K = max over experts of L∞ operator norm."""
    return max(expert.linf_norm() for expert in experts)


def compute_margin(output, predicted_class):
    """Compute pairwise logit-gap margin m = min_{j≠c} (f_c - f_j)."""
    c = predicted_class
    gaps = [output[c] - output[j] for j in range(len(output)) if j != c]
    return min(gaps) if gaps else float('inf')


def certified_radius(margin, lipschitz_K):
    """Certified robustness radius: m / (2K)."""
    if lipschitz_K <= 0:
        return float('inf')
    return margin / (2 * lipschitz_K)


# ============================================================================
# Demo 1: Simple 2D → 3-class gated network
# ============================================================================

def demo_basic_gating():
    """
    Construct a gated network with 2 experts routing based on input region.
    Demonstrates the cellwise affine structure and robustness certificate.
    """
    print("=" * 70)
    print("DEMO 1: Basic Gated Expert Block")
    print("=" * 70)

    # Two affine experts: ℝ² → ℝ³ (3 classes)
    expert1 = AffineMapVec(
        matrix=[[2.0, -1.0], [-1.0, 1.5], [0.5, 0.5]],
        bias=[1.0, 0.0, -0.5]
    )
    expert2 = AffineMapVec(
        matrix=[[-1.0, 2.0], [1.0, -0.5], [0.5, 1.0]],
        bias=[0.0, 1.0, 0.5]
    )

    # Selector: two routing options
    # Route 0: 70% expert1, 30% expert2 (convex combination)
    # Route 1: 30% expert1, 70% expert2
    selector = {
        0: [0.7, 0.3],
        1: [0.3, 0.7]
    }

    # Route based on which halfplane x is in
    def route_fn(x):
        return 0 if x[0] + x[1] > 0 else 1

    block = GatedBlock([expert1, expert2], selector, route_fn)

    # Test point
    x = np.array([1.0, 0.5])
    output = block.eval(x)
    predicted_class = np.argmax(output)

    print(f"\nInput: x = {x}")
    print(f"Route: {route_fn(x)}")
    print(f"Output logits: {output}")
    print(f"Predicted class: {predicted_class}")

    # Verify cellwise affine property
    s = route_fn(x)
    combined = block.combined_affine(s)
    combined_output = combined.eval(x)
    print(f"\nCombined affine (route {s}) output: {combined_output}")
    print(f"Direct eval matches combined: {np.allclose(output, combined_output)}")

    # Compute Lipschitz bound and margin
    K = compute_lipschitz_bound([expert1, expert2])
    margin = compute_margin(output, predicted_class)
    radius = certified_radius(margin, K)

    print(f"\nExpert 1 L∞ norm: {expert1.linf_norm():.4f}")
    print(f"Expert 2 L∞ norm: {expert2.linf_norm():.4f}")
    print(f"Global Lipschitz bound K: {K:.4f}")
    print(f"Logit-gap margin m: {margin:.4f}")
    print(f"Certified robustness radius m/(2K): {radius:.4f}")

    # Verify robustness empirically
    print(f"\nEmpirical verification (1000 random perturbations within radius):")
    n_tests = 1000
    all_robust = True
    for _ in range(n_tests):
        delta = np.random.uniform(-radius * 0.99, radius * 0.99, size=2)
        if np.max(np.abs(delta)) < radius:
            perturbed_output = block.eval(x + delta)
            if np.argmax(perturbed_output) != predicted_class:
                all_robust = False
                break
    print(f"  All perturbations preserved class: {all_robust}")

    return block, x, predicted_class, K, margin, radius


# ============================================================================
# Demo 2: Visualization of robustness regions
# ============================================================================

def demo_visualization(block, x_center, pred_class, K, margin, radius):
    """Visualize the decision boundaries, routing regions, and certified radius."""
    print("\n" + "=" * 70)
    print("DEMO 2: Visualization of Robustness Regions")
    print("=" * 70)

    fig, axes = plt.subplots(1, 3, figsize=(18, 5.5))

    # Grid for visualization
    x_range = np.linspace(x_center[0] - 2, x_center[0] + 2, 200)
    y_range = np.linspace(x_center[1] - 2, x_center[1] + 2, 200)
    XX, YY = np.meshgrid(x_range, y_range)

    # --- Panel 1: Route regions ---
    ax = axes[0]
    route_map = np.zeros_like(XX)
    for i in range(XX.shape[0]):
        for j in range(XX.shape[1]):
            route_map[i, j] = block.route_fn(np.array([XX[i, j], YY[i, j]]))

    ax.contourf(XX, YY, route_map, levels=[-0.5, 0.5, 1.5],
                colors=['#FFE0B2', '#B3E5FC'], alpha=0.7)
    ax.contour(XX, YY, route_map, levels=[0.5], colors='gray', linewidths=2)
    ax.plot(*x_center, 'k*', markersize=15, zorder=5)
    circle = plt.Circle(x_center, radius, fill=False, color='red',
                         linewidth=2, linestyle='--')
    ax.add_patch(circle)
    ax.set_title('Routing Regions', fontsize=13)
    ax.set_xlabel('x₁')
    ax.set_ylabel('x₂')
    ax.legend([mpatches.Patch(color='#FFE0B2', alpha=0.7),
               mpatches.Patch(color='#B3E5FC', alpha=0.7)],
              ['Route 0', 'Route 1'], loc='upper right')
    ax.set_aspect('equal')

    # --- Panel 2: Classification map ---
    ax = axes[1]
    class_map = np.zeros_like(XX)
    for i in range(XX.shape[0]):
        for j in range(XX.shape[1]):
            pt = np.array([XX[i, j], YY[i, j]])
            output = block.eval(pt)
            class_map[i, j] = np.argmax(output)

    cmap = LinearSegmentedColormap.from_list('classes',
        ['#EF5350', '#66BB6A', '#42A5F5'], N=3)
    ax.contourf(XX, YY, class_map, levels=[-0.5, 0.5, 1.5, 2.5],
                cmap=cmap, alpha=0.6)
    ax.plot(*x_center, 'k*', markersize=15, zorder=5)
    circle = plt.Circle(x_center, radius, fill=False, color='black',
                         linewidth=2, linestyle='--')
    ax.add_patch(circle)
    ax.set_title(f'Classification Map (predicted: {pred_class})', fontsize=13)
    ax.set_xlabel('x₁')
    ax.set_ylabel('x₂')
    ax.legend([mpatches.Patch(color='#EF5350', alpha=0.6),
               mpatches.Patch(color='#66BB6A', alpha=0.6),
               mpatches.Patch(color='#42A5F5', alpha=0.6)],
              ['Class 0', 'Class 1', 'Class 2'], loc='upper right')
    ax.set_aspect('equal')

    # --- Panel 3: Margin landscape ---
    ax = axes[2]
    margin_map = np.zeros_like(XX)
    for i in range(XX.shape[0]):
        for j in range(XX.shape[1]):
            pt = np.array([XX[i, j], YY[i, j]])
            output = block.eval(pt)
            pc = np.argmax(output)
            margin_map[i, j] = compute_margin(output, pc)

    im = ax.contourf(XX, YY, margin_map, levels=20, cmap='viridis')
    plt.colorbar(im, ax=ax, label='Logit-gap margin')
    ax.plot(*x_center, 'k*', markersize=15, zorder=5)
    circle = plt.Circle(x_center, radius, fill=False, color='red',
                         linewidth=2, linestyle='--')
    ax.add_patch(circle)
    ax.set_title('Margin Landscape', fontsize=13)
    ax.set_xlabel('x₁')
    ax.set_ylabel('x₂')
    ax.set_aspect('equal')

    plt.suptitle('Tropical Certified Robustness for Gated Expert Network',
                 fontsize=14, fontweight='bold')
    plt.tight_layout()
    plt.savefig(os.path.join(os.path.dirname(__file__),
                'tropical_gating_robustness.png'), dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: tropical_gating_robustness.png")


# ============================================================================
# Demo 3: Multi-layer network with Lipschitz composition
# ============================================================================

def demo_composition():
    """
    Demonstrate Lipschitz constant composition through multiple gated layers.
    K(g ∘ f) ≤ K(g) · K(f)
    """
    print("\n" + "=" * 70)
    print("DEMO 3: Lipschitz Composition Through Layers")
    print("=" * 70)

    # Layer 1: ℝ³ → ℝ⁴ (two experts)
    e1_l1 = AffineMapVec(
        matrix=[[0.5, 0.3, -0.2], [-0.1, 0.4, 0.3],
                [0.2, -0.1, 0.5], [0.3, 0.2, -0.1]],
        bias=[0.1, -0.1, 0.2, 0.0]
    )
    e2_l1 = AffineMapVec(
        matrix=[[-0.3, 0.5, 0.1], [0.4, -0.2, 0.3],
                [0.1, 0.3, -0.4], [-0.2, 0.1, 0.5]],
        bias=[-0.1, 0.2, 0.0, 0.1]
    )

    # Layer 2: ℝ⁴ → ℝ² (two experts)
    e1_l2 = AffineMapVec(
        matrix=[[0.4, -0.2, 0.3, 0.1], [-0.1, 0.5, -0.2, 0.3]],
        bias=[0.1, -0.1]
    )
    e2_l2 = AffineMapVec(
        matrix=[[-0.3, 0.4, 0.1, -0.2], [0.2, -0.1, 0.4, 0.2]],
        bias=[0.0, 0.2]
    )

    K1 = compute_lipschitz_bound([e1_l1, e2_l1])
    K2 = compute_lipschitz_bound([e1_l2, e2_l2])

    print(f"\nLayer 1 Lipschitz bound: K₁ = {K1:.4f}")
    print(f"  Expert 1 norm: {e1_l1.linf_norm():.4f}")
    print(f"  Expert 2 norm: {e2_l1.linf_norm():.4f}")
    print(f"\nLayer 2 Lipschitz bound: K₂ = {K2:.4f}")
    print(f"  Expert 1 norm: {e1_l2.linf_norm():.4f}")
    print(f"  Expert 2 norm: {e2_l2.linf_norm():.4f}")
    print(f"\nComposed bound: K₂ · K₁ = {K2 * K1:.4f}")

    # Verify empirically
    print("\nEmpirical verification of composition bound:")
    max_ratio = 0
    x_test = np.random.randn(3)
    for _ in range(10000):
        y_test = x_test + np.random.randn(3) * 0.01
        # Layer 1 output (using just expert 1 for simplicity)
        f_x = e1_l1.eval(x_test)
        f_y = e1_l1.eval(y_test)
        # Layer 2 output
        gf_x = e1_l2.eval(f_x)
        gf_y = e1_l2.eval(f_y)

        norm_diff_out = np.max(np.abs(gf_x - gf_y))
        norm_diff_in = np.max(np.abs(x_test - y_test))
        if norm_diff_in > 1e-10:
            ratio = norm_diff_out / norm_diff_in
            max_ratio = max(max_ratio, ratio)

    print(f"  Max observed |g∘f(x) - g∘f(y)|∞ / |x - y|∞ = {max_ratio:.4f}")
    print(f"  Theoretical bound K₂·K₁ = {K2 * K1:.4f}")
    print(f"  Bound is valid: {max_ratio <= K2 * K1 + 1e-10}")


# ============================================================================
# Demo 4: Same-route local robustness (tighter certificate)
# ============================================================================

def demo_local_robustness():
    """
    Demonstrate the tighter local certificate when the route doesn't change.
    """
    print("\n" + "=" * 70)
    print("DEMO 4: Same-Route Local Robustness Certificate")
    print("=" * 70)

    # Single expert block (identity routing, always route 0)
    expert1 = AffineMapVec(
        matrix=[[3.0, -0.5], [-1.0, 2.0], [0.5, 1.0]],
        bias=[1.0, 0.5, -1.0]
    )
    expert2 = AffineMapVec(
        matrix=[[0.5, 1.0], [1.5, -0.5], [-0.5, 2.0]],
        bias=[0.0, 1.0, 0.5]
    )

    selector = {0: [0.6, 0.4], 1: [0.4, 0.6]}

    # Route: sign of x[0]
    def route_fn(x):
        return 0 if x[0] >= 0 else 1

    block = GatedBlock([expert1, expert2], selector, route_fn)

    x = np.array([0.5, 0.3])
    output = block.eval(x)
    predicted_class = np.argmax(output)

    K_global = compute_lipschitz_bound([expert1, expert2])
    margin = compute_margin(output, predicted_class)
    r_global = certified_radius(margin, K_global)

    # For same-route, the combined affine map might have smaller norm
    s = route_fn(x)
    combined = block.combined_affine(s)
    K_local = combined.linf_norm()
    r_local = certified_radius(margin, K_local)

    print(f"\nInput: x = {x}")
    print(f"Output: {output}")
    print(f"Predicted class: {predicted_class}")
    print(f"Margin: {margin:.4f}")
    print(f"\nGlobal Lipschitz K: {K_global:.4f}")
    print(f"Local (same-route) K: {K_local:.4f}")
    print(f"\nGlobal certified radius: {r_global:.4f}")
    print(f"Local certified radius:  {r_local:.4f}")
    print(f"Improvement factor: {r_local/r_global:.2f}x")

    # Check that local radius doesn't cross route boundary
    route_boundary_dist = abs(x[0])  # distance to x[0] = 0
    effective_local_r = min(r_local, route_boundary_dist)
    print(f"\nRoute boundary distance: {route_boundary_dist:.4f}")
    print(f"Effective local radius: {effective_local_r:.4f}")


# ============================================================================
# Demo 5: Robustness certificate table
# ============================================================================

def demo_certificate_table():
    """
    Generate a table of robustness certificates for different network configurations.
    """
    print("\n" + "=" * 70)
    print("DEMO 5: Robustness Certificate Table")
    print("=" * 70)

    np.random.seed(42)
    configs = [
        {"d": 2, "o": 3, "n_experts": 2, "name": "Small (2→3, 2 exp)"},
        {"d": 5, "o": 4, "n_experts": 3, "name": "Medium (5→4, 3 exp)"},
        {"d": 10, "o": 5, "n_experts": 4, "name": "Large (10→5, 4 exp)"},
        {"d": 20, "o": 10, "n_experts": 5, "name": "XLarge (20→10, 5 exp)"},
    ]

    print(f"\n{'Config':<25} {'K':>8} {'margin':>8} {'radius':>10} {'class':>6}")
    print("-" * 60)

    for cfg in configs:
        d, o, n_exp = cfg['d'], cfg['o'], cfg['n_experts']

        # Random experts with bounded weights
        experts = []
        for _ in range(n_exp):
            W = np.random.randn(o, d) * 0.3
            b = np.random.randn(o) * 0.1
            experts.append(AffineMapVec(W, b))

        # Random convex selector
        raw_weights = np.random.exponential(1.0, size=n_exp)
        weights = raw_weights / raw_weights.sum()
        selector = {0: weights.tolist()}

        def route_fn(x):
            return 0

        block = GatedBlock(experts, selector, route_fn)
        x = np.random.randn(d)
        output = block.eval(x)
        pred = np.argmax(output)
        K = compute_lipschitz_bound(experts)
        m = compute_margin(output, pred)
        r = certified_radius(m, K)

        print(f"{cfg['name']:<25} {K:>8.4f} {m:>8.4f} {r:>10.4f} {pred:>6}")


# ============================================================================
# Main
# ============================================================================

if __name__ == "__main__":
    print("╔══════════════════════════════════════════════════════════════════╗")
    print("║  Tropical Certified Robustness for Gating Networks — Demo      ║")
    print("║  Companion to formally verified Lean 4 proofs                  ║")
    print("╚══════════════════════════════════════════════════════════════════╝\n")

    block, x, pred, K, margin, radius = demo_basic_gating()
    demo_visualization(block, x, pred, K, margin, radius)
    demo_composition()
    demo_local_robustness()
    demo_certificate_table()

    print("\n" + "=" * 70)
    print("All demos complete. See tropical_gating_robustness.png for visualization.")
    print("=" * 70)
