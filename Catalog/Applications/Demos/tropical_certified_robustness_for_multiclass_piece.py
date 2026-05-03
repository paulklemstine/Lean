#!/usr/bin/env python3
"""
Top-K Certified Robustness Demo
================================

Demonstrates the formally verified top-k robustness theory for multiclass
piecewise-linear networks. Shows how the certified radius margin/(2K) guarantees
that the top-k prediction set is preserved under input perturbation.

This demo:
1. Constructs a simple max-affine (tropical) network with known Lipschitz constants.
2. Computes top-k margins at sample points.
3. Derives certified robustness radii.
4. Verifies the certificates empirically by sampling perturbations.
5. Compares coordinate-Lipschitz vs pairwise-Lipschitz certificates.
6. Visualizes decision boundaries and certified regions.
"""

import numpy as np
import matplotlib.pyplot as plt
from matplotlib.patches import Circle
from itertools import combinations
import os

# ============================================================
# 1. Max-Affine Network Construction
# ============================================================

def max_affine_layer(weights, biases, x):
    """
    Compute a max-affine layer: for each output class i,
      f_i(x) = max_t (w_{i,t} · x + b_{i,t})
    
    weights: shape (n_classes, n_pieces, input_dim)
    biases:  shape (n_classes, n_pieces)
    x:       shape (input_dim,)
    
    Returns: shape (n_classes,)
    """
    # For each class, take max over affine pieces
    scores = np.einsum('cpi,i->cp', weights, x) + biases  # (n_classes, n_pieces)
    return np.max(scores, axis=1)  # (n_classes,)


def max_affine_lipschitz(weights):
    """
    Compute the coordinate Lipschitz constant for each output class.
    For f_i(x) = max_t (w_{i,t} · x + b_{i,t}), the Lipschitz constant is
    max_t ||w_{i,t}||_2.
    
    Returns K = max_i K_i (uniform coordinate Lipschitz constant).
    """
    # For each class, each piece: compute ||w||_2
    norms = np.linalg.norm(weights, axis=2)  # (n_classes, n_pieces)
    Ki = np.max(norms, axis=1)  # per-class Lipschitz
    K = np.max(Ki)
    return K, Ki


def pairwise_lipschitz(weights, biases, i, j):
    """
    Compute an upper bound on the Lipschitz constant of f_i - f_j.
    For max-affine networks, L_{ij} ≤ K_i + K_j (triangle inequality),
    but can be tighter if we analyze the pairwise difference directly.
    
    For simplicity, return K_i + K_j as the bound.
    """
    _, Ki = max_affine_lipschitz(weights)
    return Ki[i] + Ki[j]


# ============================================================
# 2. Top-K Margin and Certified Radius
# ============================================================

def compute_scores(weights, biases, x):
    """Compute all class scores at point x."""
    return max_affine_layer(weights, biases, x)


def topk_set(scores, k):
    """Return the indices of the top-k classes (as a set)."""
    return set(np.argsort(scores)[-k:])


def topk_margin(scores, S):
    """
    Compute the top-k margin: min_{i ∈ S, j ∉ S} (f(x,i) - f(x,j)).
    This is the minimum gap between any in-set and out-set class.
    """
    n = len(scores)
    S_set = set(S)
    Sc = set(range(n)) - S_set
    if not S_set or not Sc:
        return float('inf')
    
    margin = float('inf')
    for i in S_set:
        for j in Sc:
            gap = scores[i] - scores[j]
            margin = min(margin, gap)
    return margin


def certified_radius_coordinate(margin, K):
    """
    Certified radius using coordinate Lipschitz bound: r* = margin / (2K).
    Corresponds to Theorem topk_stable_of_margin.
    """
    if K <= 0:
        return float('inf') if margin > 0 else 0.0
    return margin / (2 * K)


def certified_radius_pairwise(scores, S, pairwise_L):
    """
    Certified radius using pairwise Lipschitz bounds: r* = min_{(i,j)} gap_{ij} / L_{ij}.
    Corresponds to Theorem topk_stable_of_pairwise_lipschitz.
    """
    n = len(scores)
    S_set = set(S)
    Sc = set(range(n)) - S_set
    
    radius = float('inf')
    for i in S_set:
        for j in Sc:
            gap = scores[i] - scores[j]
            Lij = pairwise_L[i][j]
            if Lij > 0:
                radius = min(radius, gap / Lij)
            elif gap <= 0:
                return 0.0
    return radius


# ============================================================
# 3. Empirical Verification
# ============================================================

def verify_certificate(weights, biases, x, S, radius, n_samples=10000):
    """
    Empirically verify that the top-k set S is preserved within the certified radius.
    Returns (n_preserved, n_total, n_violated).
    """
    d = x.shape[0]
    S_set = set(S)
    n_preserved = 0
    n_violated = 0
    
    for _ in range(n_samples):
        # Random perturbation within the ball
        delta = np.random.randn(d)
        delta = delta / np.linalg.norm(delta) * np.random.uniform(0, radius)
        y = x + delta
        
        scores_y = compute_scores(weights, biases, y)
        # Check strict dominance
        preserved = True
        for i in S_set:
            for j in set(range(len(scores_y))) - S_set:
                if scores_y[i] <= scores_y[j]:
                    preserved = False
                    break
            if not preserved:
                break
        
        if preserved:
            n_preserved += 1
        else:
            n_violated += 1
    
    return n_preserved, n_samples, n_violated


# ============================================================
# 4. Demo: 2D Input, 5-Class Max-Affine Network
# ============================================================

def create_demo_network():
    """Create a 5-class max-affine network in 2D."""
    np.random.seed(42)
    n_classes = 5
    n_pieces = 3
    input_dim = 2
    
    # Manually designed weights for nice geometry
    weights = np.array([
        # Class 0: dominant in upper-right
        [[2.0, 1.5], [1.0, 2.5], [0.5, 0.5]],
        # Class 1: dominant in lower-right
        [[2.5, -1.0], [1.5, -0.5], [0.5, -2.0]],
        # Class 2: dominant in left
        [[-2.0, 0.5], [-1.5, 1.0], [-1.0, -0.5]],
        # Class 3: dominant in center-up
        [[0.5, 2.0], [-0.5, 2.5], [0.0, 1.5]],
        # Class 4: dominant in center-down
        [[0.5, -2.0], [-0.5, -1.5], [0.0, -2.5]],
    ])
    
    biases = np.array([
        [0.0, -0.5, 0.5],
        [0.5, 0.0, -0.5],
        [1.0, 0.5, 0.0],
        [-0.5, 0.0, 0.5],
        [0.0, 0.5, -0.5],
    ])
    
    return weights, biases


def plot_decision_boundary_and_certificates(weights, biases, k=2):
    """
    Plot the top-k decision boundary and certified robustness regions.
    """
    fig, axes = plt.subplots(1, 3, figsize=(18, 6))
    
    # Grid for decision boundary
    x_range = np.linspace(-2, 2, 200)
    y_range = np.linspace(-2, 2, 200)
    X, Y = np.meshgrid(x_range, y_range)
    
    n_classes = weights.shape[0]
    K, Ki = max_affine_lipschitz(weights)
    
    # Compute top-k sets over the grid
    topk_labels = np.zeros((200, 200), dtype=int)
    margins = np.zeros((200, 200))
    cert_radii_coord = np.zeros((200, 200))
    
    for ix in range(200):
        for iy in range(200):
            x = np.array([X[iy, ix], Y[iy, ix]])
            scores = compute_scores(weights, biases, x)
            S = topk_set(scores, k)
            # Encode top-k set as a label for coloring
            label = sum(2**i for i in S)
            topk_labels[iy, ix] = label
            
            margin = topk_margin(scores, S)
            margins[iy, ix] = margin
            cert_radii_coord[iy, ix] = certified_radius_coordinate(margin, K)
    
    # --- Panel 1: Top-k decision regions ---
    ax = axes[0]
    ax.contourf(X, Y, topk_labels, levels=30, cmap='tab20', alpha=0.7)
    ax.contour(X, Y, topk_labels, levels=30, colors='black', linewidths=0.3)
    ax.set_title(f'Top-{k} Decision Regions\n(colors = different top-{k} sets)', fontsize=12)
    ax.set_xlabel('$x_1$')
    ax.set_ylabel('$x_2$')
    ax.set_aspect('equal')
    
    # --- Panel 2: Margin heatmap ---
    ax = axes[1]
    im = ax.contourf(X, Y, margins, levels=20, cmap='viridis')
    plt.colorbar(im, ax=ax, label='Top-k margin')
    ax.contour(X, Y, topk_labels, levels=30, colors='white', linewidths=0.3, alpha=0.5)
    ax.set_title(f'Top-{k} Margin\n(min gap between in-set and out-set)', fontsize=12)
    ax.set_xlabel('$x_1$')
    ax.set_ylabel('$x_2$')
    ax.set_aspect('equal')
    
    # --- Panel 3: Certified radius heatmap with sample certificates ---
    ax = axes[2]
    im = ax.contourf(X, Y, cert_radii_coord, levels=20, cmap='plasma')
    plt.colorbar(im, ax=ax, label='Certified radius $r^*$')
    
    # Draw certified balls at a few sample points
    sample_points = [
        np.array([1.0, 0.5]),
        np.array([-1.0, 0.5]),
        np.array([0.5, -1.0]),
        np.array([0.0, 1.0]),
        np.array([1.5, -0.5]),
    ]
    
    for pt in sample_points:
        scores = compute_scores(weights, biases, pt)
        S = topk_set(scores, k)
        margin = topk_margin(scores, S)
        r_cert = certified_radius_coordinate(margin, K)
        
        if r_cert > 0.01:
            circle = Circle(pt, r_cert, fill=False, edgecolor='lime',
                          linewidth=2, linestyle='--')
            ax.add_patch(circle)
            ax.plot(*pt, 'o', color='lime', markersize=5)
    
    ax.set_title(f'Certified Radius $r^* = \\mathrm{{margin}}/(2K)$\n$K={K:.2f}$', fontsize=12)
    ax.set_xlabel('$x_1$')
    ax.set_ylabel('$x_2$')
    ax.set_xlim(-2, 2)
    ax.set_ylim(-2, 2)
    ax.set_aspect('equal')
    
    plt.tight_layout()
    plt.savefig('demos/topk_decision_regions.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: demos/topk_decision_regions.png")


def plot_pairwise_vs_coordinate(weights, biases, k=2):
    """
    Compare coordinate-Lipschitz vs pairwise-Lipschitz certified radii.
    """
    np.random.seed(123)
    K, Ki = max_affine_lipschitz(weights)
    n_classes = weights.shape[0]
    
    # Build pairwise Lipschitz matrix (using K_i + K_j bound)
    pairwise_L = np.zeros((n_classes, n_classes))
    for i in range(n_classes):
        for j in range(n_classes):
            pairwise_L[i][j] = Ki[i] + Ki[j]
    
    # Sample random points and compare certificates
    n_samples = 500
    coord_radii = []
    pairwise_radii = []
    
    for _ in range(n_samples):
        x = np.random.uniform(-1.5, 1.5, size=2)
        scores = compute_scores(weights, biases, x)
        S = topk_set(scores, k)
        margin = topk_margin(scores, S)
        
        r_coord = certified_radius_coordinate(margin, K)
        r_pair = certified_radius_pairwise(scores, S, pairwise_L)
        
        coord_radii.append(r_coord)
        pairwise_radii.append(r_pair)
    
    coord_radii = np.array(coord_radii)
    pairwise_radii = np.array(pairwise_radii)
    
    fig, axes = plt.subplots(1, 2, figsize=(14, 5))
    
    # Scatter plot comparison
    ax = axes[0]
    ax.scatter(coord_radii, pairwise_radii, alpha=0.3, s=10, c='steelblue')
    max_r = max(coord_radii.max(), pairwise_radii.max()) * 1.05
    ax.plot([0, max_r], [0, max_r], 'r--', label='$r_{pair} = r_{coord}$')
    ax.set_xlabel('Coordinate-Lipschitz radius $r^*_{\\mathrm{coord}}$')
    ax.set_ylabel('Pairwise-Lipschitz radius $r^*_{\\mathrm{pair}}$')
    ax.set_title('Pairwise vs Coordinate Certificates\n(points above diagonal = pairwise is tighter)')
    ax.legend()
    ax.set_aspect('equal')
    
    # Improvement ratio histogram
    ax = axes[1]
    # Only where both are positive
    mask = (coord_radii > 1e-8) & (pairwise_radii > 1e-8)
    ratios = pairwise_radii[mask] / coord_radii[mask]
    ax.hist(ratios, bins=40, color='steelblue', edgecolor='black', alpha=0.7)
    ax.axvline(1.0, color='red', linestyle='--', label='Equal')
    ax.axvline(np.median(ratios), color='green', linestyle='-', linewidth=2,
               label=f'Median ratio = {np.median(ratios):.2f}')
    ax.set_xlabel('Ratio $r^*_{\\mathrm{pair}} / r^*_{\\mathrm{coord}}$')
    ax.set_ylabel('Count')
    ax.set_title('Improvement from Pairwise Certificates')
    ax.legend()
    
    plt.tight_layout()
    plt.savefig('demos/pairwise_vs_coordinate.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: demos/pairwise_vs_coordinate.png")


def run_empirical_verification(weights, biases, k=2):
    """
    Verify certificates at several points.
    """
    K, _ = max_affine_lipschitz(weights)
    
    print("\n" + "="*70)
    print(f"EMPIRICAL VERIFICATION (k={k}, K={K:.3f})")
    print("="*70)
    
    test_points = [
        np.array([1.0, 0.5]),
        np.array([-1.0, 0.5]),
        np.array([0.5, -1.0]),
        np.array([0.0, 0.0]),
        np.array([1.5, 1.0]),
    ]
    
    for pt in test_points:
        scores = compute_scores(weights, biases, pt)
        S = topk_set(scores, k)
        margin = topk_margin(scores, S)
        r_cert = certified_radius_coordinate(margin, K)
        
        print(f"\nPoint x = {pt}")
        print(f"  Scores: {scores}")
        print(f"  Top-{k} set S = {sorted(S)}")
        print(f"  Margin = {margin:.4f}")
        print(f"  Certified radius r* = {r_cert:.4f}")
        
        if r_cert > 0.001:
            n_preserved, n_total, n_violated = verify_certificate(
                weights, biases, pt, S, r_cert * 0.99, n_samples=5000
            )
            print(f"  Verification (r=0.99·r*): {n_preserved}/{n_total} preserved, "
                  f"{n_violated} violated")
            assert n_violated == 0, "Certificate violated! This should never happen."
            print(f"  ✓ Certificate verified: 0 violations in {n_total} samples")
        else:
            print(f"  (radius too small, skipping empirical verification)")


def plot_margin_landscape(weights, biases, k=2):
    """
    3D surface plot of the top-k margin landscape.
    """
    fig = plt.figure(figsize=(10, 7))
    ax = fig.add_subplot(111, projection='3d')
    
    x_range = np.linspace(-2, 2, 100)
    y_range = np.linspace(-2, 2, 100)
    X, Y = np.meshgrid(x_range, y_range)
    
    Z = np.zeros_like(X)
    for ix in range(100):
        for iy in range(100):
            x = np.array([X[iy, ix], Y[iy, ix]])
            scores = compute_scores(weights, biases, x)
            S = topk_set(scores, k)
            Z[iy, ix] = topk_margin(scores, S)
    
    surf = ax.plot_surface(X, Y, Z, cmap='viridis', alpha=0.8,
                           linewidth=0, antialiased=True)
    ax.set_xlabel('$x_1$')
    ax.set_ylabel('$x_2$')
    ax.set_zlabel('Top-k margin')
    ax.set_title(f'Top-{k} Margin Landscape\n(higher = more robust)')
    plt.colorbar(surf, ax=ax, shrink=0.6, label='Margin')
    
    plt.savefig('demos/margin_landscape.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: demos/margin_landscape.png")


def plot_subset_preservation(weights, biases):
    """
    Demonstrate the subset preservation theorem:
    even if the full top-k set permutes internally, a designated
    target subset T ⊆ S cannot drop below outside classes.
    """
    fig, ax = plt.subplots(1, 1, figsize=(8, 6))
    
    K, _ = max_affine_lipschitz(weights)
    n_classes = weights.shape[0]
    
    # Choose a point and its top-3 set
    x0 = np.array([0.8, 0.3])
    scores0 = compute_scores(weights, biases, x0)
    k = 3
    S = topk_set(scores0, k)
    
    # Target subset: top-1 class within S
    best_in_S = max(S, key=lambda i: scores0[i])
    T = {best_in_S}
    
    # Compute margin for T against S^c
    Sc = set(range(n_classes)) - S
    T_margin = min(scores0[i] - scores0[j] for i in T for j in Sc)
    r_T = T_margin / (2 * K)
    
    # Full S margin
    S_margin = topk_margin(scores0, S)
    r_S = certified_radius_coordinate(S_margin, K)
    
    # Trace scores along a perturbation direction
    direction = np.array([1.0, 0.3])
    direction = direction / np.linalg.norm(direction)
    
    ts = np.linspace(-r_T * 1.5, r_T * 1.5, 200)
    score_traces = np.zeros((n_classes, len(ts)))
    
    for idx, t in enumerate(ts):
        y = x0 + t * direction
        score_traces[:, idx] = compute_scores(weights, biases, y)
    
    class_names = [f'Class {i}' for i in range(n_classes)]
    colors = plt.cm.Set1(np.linspace(0, 1, n_classes))
    
    for i in range(n_classes):
        style = '-' if i in S else '--'
        lw = 2.5 if i in T else (1.5 if i in S else 1.0)
        label = class_names[i]
        if i in T:
            label += ' (target T)'
        elif i in S:
            label += ' (in S)'
        else:
            label += ' (outside S)'
        ax.plot(ts, score_traces[i], style, color=colors[i], linewidth=lw, label=label)
    
    # Mark certified regions
    ax.axvspan(-r_S, r_S, alpha=0.1, color='blue', label=f'Full S cert. (r={r_S:.3f})')
    ax.axvspan(-r_T, r_T, alpha=0.15, color='green', label=f'Target T cert. (r={r_T:.3f})')
    ax.axvline(0, color='gray', linestyle=':', alpha=0.5)
    
    ax.set_xlabel('Perturbation distance $t$')
    ax.set_ylabel('Class score $f(x + t \\cdot d, i)$')
    ax.set_title(f'Subset Preservation: T={sorted(T)} within S={sorted(S)}\n'
                 f'T never drops below outside classes within green region')
    ax.legend(fontsize=8, loc='upper left')
    
    plt.tight_layout()
    plt.savefig('demos/subset_preservation.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: demos/subset_preservation.png")


# ============================================================
# Main
# ============================================================

if __name__ == '__main__':
    os.makedirs('demos', exist_ok=True)
    
    print("Creating demo network...")
    weights, biases = create_demo_network()
    K, Ki = max_affine_lipschitz(weights)
    
    print(f"\nNetwork: 5 classes, 3 pieces each, 2D input")
    print(f"Coordinate Lipschitz constants: {Ki}")
    print(f"Uniform Lipschitz constant K = {K:.3f}")
    
    print("\n--- Generating visualizations ---")
    plot_decision_boundary_and_certificates(weights, biases, k=2)
    plot_pairwise_vs_coordinate(weights, biases, k=2)
    plot_margin_landscape(weights, biases, k=2)
    plot_subset_preservation(weights, biases)
    
    run_empirical_verification(weights, biases, k=2)
    
    print("\n" + "="*70)
    print("DEMO COMPLETE")
    print("="*70)
    print("\nAll certificates verified — no violations found.")
    print("This empirically confirms the formal theorems proved in Lean 4.")
