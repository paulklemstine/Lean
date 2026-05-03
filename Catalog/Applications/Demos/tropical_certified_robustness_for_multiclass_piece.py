"""
Tropical Certified Robustness via Monotone Min-Margin Score Aggregation
=======================================================================

This demo illustrates the main theorem: for a multiclass neural network with
Lipschitz-bounded logits, a positive aggregated pairwise margin certificate
at a reference point x₀ guarantees that the predicted class is preserved for
all inputs within an ℓ∞-ball of radius ε around x₀.

We demonstrate with:
1. A synthetic 2D piecewise-linear network (ReLU-like) with 3 classes.
2. Computation of the margin vector and off-diagonal minimum certificate.
3. Visualization of certified robust regions vs. actual decision boundaries.
4. Comparison of different aggregators (min, harmonic mean, geometric mean).
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from matplotlib.patches import Rectangle
from matplotlib.colors import ListedColormap
import os

# --- Network definition: a simple 3-class PL network on ℝ² ---

def relu(x):
    return np.maximum(x, 0)

def make_network(seed=42):
    """Create a simple 3-class ReLU network f: ℝ² → ℝ³."""
    rng = np.random.RandomState(seed)
    W1 = rng.randn(8, 2) * 0.8
    b1 = rng.randn(8) * 0.3
    W2 = rng.randn(3, 8) * 0.5
    b2 = rng.randn(3) * 0.2
    return W1, b1, W2, b2

def forward(x, W1, b1, W2, b2):
    """Forward pass: x is (N, 2), returns (N, 3) logits."""
    h = relu(x @ W1.T + b1)
    return h @ W2.T + b2

def lipschitz_bound(W1, W2):
    """
    Conservative Lipschitz bound K for a 2-layer ReLU network.
    |f_i(x) - f_i(x')| ≤ K ‖x - x'‖∞ for each logit.
    Pairwise gap bound: |g_{ij}(x) - g_{ij}(x')| ≤ 2K‖x-x'‖∞.
    With d=2: total bound is 2*K*d*‖x-x'‖∞.
    """
    K = np.max(np.sum(np.abs(W2), axis=1)) * np.max(np.abs(W1))
    return K

def margin_vec(logits, y):
    """Compute margin vector: m_j = logit_y - logit_j."""
    return logits[:, y:y+1] - logits

def off_diag_min(mv, y):
    """Off-diagonal minimum: min_{j≠y} m_j."""
    mask = np.ones(mv.shape[1], dtype=bool)
    mask[y] = False
    return np.min(mv[:, mask], axis=1)

def certified_radius(mv, y, K, d):
    """
    Certified ℓ∞ radius: r = min_{j≠y} m_j / (2*K*d).
    From the main theorem: if offDiagMin(marginVec(f,y,x₀)) > 2*K*d*ε,
    then the predicted class is stable within ‖x-x₀‖∞ ≤ ε.
    """
    min_margin = off_diag_min(mv, y)
    return np.maximum(min_margin / (2 * K * d), 0)


# --- Demo 1: Visualize certified robust regions ---

def demo_certified_regions():
    """Visualize decision boundaries and certified robust regions."""
    W1, b1, W2, b2 = make_network()
    K = lipschitz_bound(W1, W2)
    d = 2

    xmin, xmax = -3, 3
    resolution = 300
    xx, yy = np.meshgrid(
        np.linspace(xmin, xmax, resolution),
        np.linspace(xmin, xmax, resolution)
    )
    grid = np.column_stack([xx.ravel(), yy.ravel()])
    logits = forward(grid, W1, b1, W2, b2)
    predictions = np.argmax(logits, axis=1).reshape(xx.shape)

    ref_points = np.array([
        [-1.5, 0.5], [0.0, -1.0], [1.5, 1.0],
        [-0.5, -1.5], [1.0, -0.5], [0.5, 1.5],
    ])
    ref_logits = forward(ref_points, W1, b1, W2, b2)
    ref_preds = np.argmax(ref_logits, axis=1)

    fig, axes = plt.subplots(1, 2, figsize=(16, 7))
    colors = ['#FF6B6B', '#4ECDC4', '#45B7D1']
    cmap = ListedColormap(colors)

    # Left: Decision boundaries with certified boxes
    ax = axes[0]
    ax.contourf(xx, yy, predictions, levels=[-0.5, 0.5, 1.5, 2.5],
                colors=colors, alpha=0.3)
    ax.contour(xx, yy, predictions, levels=[0.5, 1.5], colors='k', linewidths=1.5)

    for idx, (pt, pred) in enumerate(zip(ref_points, ref_preds)):
        mv = margin_vec(ref_logits[idx:idx+1], pred)
        radius = certified_radius(mv, pred, K, d)[0]
        rect = Rectangle(
            (pt[0] - radius, pt[1] - radius), 2 * radius, 2 * radius,
            linewidth=2, edgecolor=colors[pred], facecolor=colors[pred],
            alpha=0.25, linestyle='--'
        )
        ax.add_patch(rect)
        ax.plot(pt[0], pt[1], 'ko', markersize=6)
        ax.annotate(f'r={radius:.3f}', (pt[0], pt[1] + 0.15),
                   fontsize=8, ha='center',
                   bbox=dict(boxstyle='round,pad=0.2', facecolor='white', alpha=0.8))

    ax.set_xlim(xmin, xmax)
    ax.set_ylim(xmin, xmax)
    ax.set_xlabel('$x_1$', fontsize=12)
    ax.set_ylabel('$x_2$', fontsize=12)
    ax.set_title('Decision Boundaries with Certified $\\ell_\\infty$ Regions', fontsize=13)
    ax.set_aspect('equal')

    # Right: Certified radius heatmap
    ax = axes[1]
    radii = np.zeros(len(grid))
    for i in range(len(grid)):
        lg = logits[i:i+1]
        pred = np.argmax(lg, axis=1)[0]
        mv = margin_vec(lg, pred)
        radii[i] = certified_radius(mv, pred, K, d)[0]

    radii_grid = radii.reshape(xx.shape)
    im = ax.pcolormesh(xx, yy, radii_grid, cmap='viridis', shading='auto')
    ax.contour(xx, yy, predictions, levels=[0.5, 1.5], colors='white', linewidths=1.5)
    plt.colorbar(im, ax=ax, label='Certified radius $\\varepsilon$')
    ax.set_xlabel('$x_1$', fontsize=12)
    ax.set_ylabel('$x_2$', fontsize=12)
    ax.set_title('Certified Robustness Radius (Off-Diagonal Min)', fontsize=13)
    ax.set_aspect('equal')

    plt.tight_layout()
    plt.savefig('demos/figures/certified_regions.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("  Saved demos/figures/certified_regions.png")


# --- Demo 2: Certificate stability under perturbation ---

def demo_certificate_stability():
    """Show how the aggregated margin decreases under perturbation."""
    W1, b1, W2, b2 = make_network()
    K = lipschitz_bound(W1, W2)
    d = 2

    x0 = np.array([[0.5, 0.8]])
    logits0 = forward(x0, W1, b1, W2, b2)
    y = np.argmax(logits0, axis=1)[0]
    mv0 = margin_vec(logits0, y)
    cert0 = off_diag_min(mv0, y)[0]

    epsilons = np.linspace(0, cert0 / (2 * K * d) * 1.5, 200)
    n_samples = 500
    rng = np.random.RandomState(123)

    actual_min_margins = []
    actual_mean_margins = []
    theoretical_lower = []

    for eps in epsilons:
        perturbations = rng.uniform(-eps, eps, (n_samples, 2))
        x_perturbed = x0 + perturbations
        logits_perturbed = forward(x_perturbed, W1, b1, W2, b2)
        mv_perturbed = margin_vec(logits_perturbed, y)
        min_margins = off_diag_min(mv_perturbed, y)
        actual_min_margins.append(np.min(min_margins))
        actual_mean_margins.append(np.mean(min_margins))
        theoretical_lower.append(cert0 - 2 * K * d * eps)

    fig, ax = plt.subplots(figsize=(10, 6))
    ax.plot(epsilons, theoretical_lower, 'r--', linewidth=2,
            label='Theoretical lower bound: $\\Phi(v_{x_0}) - 2Kd\\varepsilon$')
    ax.plot(epsilons, actual_min_margins, 'b-', linewidth=1.5,
            label='Worst-case observed min-margin')
    ax.plot(epsilons, actual_mean_margins, 'g-', linewidth=1.5, alpha=0.7,
            label='Mean observed min-margin')
    ax.axhline(y=0, color='k', linestyle='-', linewidth=0.5)

    cert_radius = cert0 / (2 * K * d)
    ax.axvline(x=cert_radius, color='orange', linestyle=':', linewidth=2,
               label=f'Certified radius $\\varepsilon^*$ = {cert_radius:.4f}')
    ax.fill_between(epsilons, theoretical_lower, alpha=0.1, color='red')
    ax.set_xlabel('Perturbation radius $\\varepsilon$', fontsize=12)
    ax.set_ylabel('Min-margin certificate', fontsize=12)
    ax.set_title('Certificate Stability Under $\\ell_\\infty$ Perturbation', fontsize=13)
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('demos/figures/certificate_stability.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("  Saved demos/figures/certificate_stability.png")


# --- Demo 3: Compare different aggregators ---

def demo_aggregator_comparison():
    """Compare min vs other aggregators for certification."""
    W1, b1, W2, b2 = make_network()
    K = lipschitz_bound(W1, W2)
    d = 2

    resolution = 200
    xx, yy = np.meshgrid(
        np.linspace(-3, 3, resolution),
        np.linspace(-3, 3, resolution)
    )
    grid = np.column_stack([xx.ravel(), yy.ravel()])
    logits = forward(grid, W1, b1, W2, b2)
    predictions = np.argmax(logits, axis=1)

    def agg_min(mv, y):
        mask = np.ones(mv.shape[0], dtype=bool)
        mask[y] = False
        return np.min(mv[mask])

    def agg_harmonic_mean(mv, y):
        mask = np.ones(mv.shape[0], dtype=bool)
        mask[y] = False
        vals = mv[mask]
        if np.any(vals <= 0):
            return np.min(vals)
        return len(vals) / np.sum(1.0 / vals)

    def agg_geometric_mean(mv, y):
        mask = np.ones(mv.shape[0], dtype=bool)
        mask[y] = False
        vals = mv[mask]
        if np.any(vals <= 0):
            return np.min(vals)
        return np.exp(np.mean(np.log(vals)))

    aggregators = {
        'Off-Diagonal Min\n(Primary certificate)': agg_min,
        'Harmonic Mean\n(Satisfies DominatesMin)': agg_harmonic_mean,
        'Geometric Mean\n(Satisfies DominatesMin)': agg_geometric_mean,
    }

    fig, axes = plt.subplots(1, 3, figsize=(18, 5.5))
    for ax, (name, agg_fn) in zip(axes, aggregators.items()):
        radii = np.zeros(len(grid))
        for i in range(len(grid)):
            pred = predictions[i]
            mv = logits[i, pred] - logits[i]
            cert = agg_fn(mv, pred)
            radii[i] = max(cert / (2 * K * d), 0)

        radii_grid = radii.reshape(xx.shape)
        im = ax.pcolormesh(xx, yy, radii_grid, cmap='viridis', shading='auto',
                          vmin=0, vmax=np.percentile(radii, 95))
        ax.contour(xx, yy, predictions.reshape(xx.shape),
                  levels=[0.5, 1.5], colors='white', linewidths=1.5)
        plt.colorbar(im, ax=ax, label='Certified radius')
        ax.set_xlabel('$x_1$')
        ax.set_ylabel('$x_2$')
        ax.set_title(name, fontsize=11)
        ax.set_aspect('equal')

    plt.suptitle('Certified Radius Under Different Monotone Aggregators', fontsize=14, y=1.02)
    plt.tight_layout()
    plt.savefig('demos/figures/aggregator_comparison.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("  Saved demos/figures/aggregator_comparison.png")


# --- Demo 4: Verification of theorem hypotheses ---

def demo_verify_theorem():
    """Numerically verify all hypotheses of the main theorem."""
    W1, b1, W2, b2 = make_network()
    K = lipschitz_bound(W1, W2)
    d = 2

    print("=" * 60)
    print("THEOREM HYPOTHESIS VERIFICATION")
    print("=" * 60)
    print(f"\nNetwork: 2-layer ReLU, input dim d={d}, C=3 classes")
    print(f"Lipschitz constant K = {K:.4f}")
    print(f"Pairwise gap bound: 2*K*d = {2*K*d:.4f}")

    rng = np.random.RandomState(42)
    n_tests = 10000
    x1 = rng.randn(n_tests, 2) * 2
    x2 = x1 + rng.randn(n_tests, 2) * 0.5

    logits1 = forward(x1, W1, b1, W2, b2)
    logits2 = forward(x2, W1, b1, W2, b2)

    max_ratio = 0
    for i in range(3):
        for j in range(3):
            gap1 = logits1[:, i] - logits1[:, j]
            gap2 = logits2[:, i] - logits2[:, j]
            gap_diff = np.abs(gap1 - gap2)
            input_diff = np.max(np.abs(x1 - x2), axis=1)
            valid = input_diff > 1e-10
            if np.any(valid):
                ratio = np.max(gap_diff[valid] / input_diff[valid])
                max_ratio = max(max_ratio, ratio)

    print(f"\nNumerical Lipschitz verification ({n_tests} random pairs):")
    print(f"  Max observed |Δg_ij| / ‖Δx‖∞ = {max_ratio:.4f}")
    print(f"  Theoretical bound 2Kd = {2*K*d:.4f}")
    print(f"  Bound verified: {max_ratio <= 2*K*d + 1e-10}")

    # Compute certificates at test points
    print(f"\n{'='*60}")
    print("CERTIFICATE COMPUTATION & EMPIRICAL VERIFICATION")
    print("=" * 60)

    test_points = np.array([[0.5, 0.8], [-1.0, 0.3], [1.5, -0.5]])
    for pt in test_points:
        logits = forward(pt.reshape(1, -1), W1, b1, W2, b2)[0]
        pred = np.argmax(logits)
        margins = logits[pred] - logits
        mask = np.ones(3, dtype=bool)
        mask[pred] = False
        min_margin = np.min(margins[mask])
        radius = max(min_margin / (2 * K * d), 0)

        print(f"\n  x₀ = ({pt[0]:.1f}, {pt[1]:.1f})")
        print(f"  Logits: [{logits[0]:.4f}, {logits[1]:.4f}, {logits[2]:.4f}]")
        print(f"  Predicted class: {pred}")
        print(f"  Off-diag min margin: {min_margin:.4f}")
        print(f"  Certified ℓ∞ radius: {radius:.6f}")

        n_verify = 2000
        perturbations = rng.uniform(-radius, radius, (n_verify, 2))
        x_perturbed = pt + perturbations
        logits_perturbed = forward(x_perturbed, W1, b1, W2, b2)
        preds_perturbed = np.argmax(logits_perturbed, axis=1)
        all_stable = np.all(preds_perturbed == pred)
        print(f"  Empirical verification ({n_verify} samples): "
              f"{'ALL STABLE' if all_stable else 'UNSTABLE!'}")
    print()


if __name__ == '__main__':
    os.makedirs('demos/figures', exist_ok=True)

    print("=" * 60)
    print("Tropical Certified Robustness — Python Demonstrations")
    print("=" * 60)
    print()

    demo_verify_theorem()
    demo_certified_regions()
    demo_certificate_stability()
    demo_aggregator_comparison()

    print("\nAll demos complete!")
