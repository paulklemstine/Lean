"""
Sheaf Cohomology Robustness — Interactive Demo

Demonstrates the key results:
1. Persistent robustness filtration for a simple 2D classifier
2. Composition robustness bounds for multi-layer networks
3. Mayer-Vietoris gluing of local certificates
4. Weight perturbation stability
5. Čech cohomology computation on a cover
"""

import numpy as np
from algorithms import (
    compute_lipschitz_robustness_radius,
    composition_robustness_radius,
    mayer_vietoris_robustness_radius,
    cech_cohomology_vanishes,
    sheaf_lipschitz_globalization,
    weight_perturbation_stability,
    refinement_radius_comparison,
)


def demo_lipschitz_robustness():
    """Demo 1: Lipschitz Robustness Radius"""
    print("=" * 60)
    print("Demo 1: Lipschitz Robustness Radius")
    print("=" * 60)

    margins = [0.5, 1.0, 2.0, 0.1]
    lip_consts = [1.0, 2.0, 0.5, 10.0]

    print(f"{'Margin':>8} {'Lipschitz':>10} {'Radius':>8}")
    print("-" * 30)
    for m, L in zip(margins, lip_consts):
        r = compute_lipschitz_robustness_radius(m, L)
        print(f"{m:8.2f} {L:10.2f} {r:8.4f}")

    print()


def demo_composition_robustness():
    """Demo 2: Multi-Layer Composition Robustness"""
    print("=" * 60)
    print("Demo 2: Composition Robustness (Multi-Layer)")
    print("=" * 60)

    configs = [
        {"margin": 1.0, "L1": 1.0, "L2": 1.0, "desc": "Unit Lipschitz"},
        {"margin": 2.0, "L1": 3.0, "L2": 2.0, "desc": "Deep network"},
        {"margin": 0.5, "L1": 10.0, "L2": 5.0, "desc": "High Lipschitz"},
        {"margin": 5.0, "L1": 1.5, "L2": 1.2, "desc": "High margin"},
    ]

    print(f"{'Config':>18} {'Margin':>7} {'L1':>5} {'L2':>5} {'Radius':>8}")
    print("-" * 48)
    for c in configs:
        r = composition_robustness_radius(c["margin"], c["L1"], c["L2"])
        print(f"{c['desc']:>18} {c['margin']:7.2f} {c['L1']:5.1f} {c['L2']:5.1f} {r:8.4f}")

    print()


def demo_mayer_vietoris():
    """Demo 3: Mayer-Vietoris Gluing"""
    print("=" * 60)
    print("Demo 3: Mayer-Vietoris Robustness Gluing")
    print("=" * 60)

    covers = [
        [1.0, 1.0],
        [0.5, 2.0],
        [0.1, 0.3, 0.5],
        [1.0, 1.0, 1.0, 1.0],
        [0.8, 0.9, 1.0, 0.7, 0.6],
    ]

    for radii in covers:
        global_r = mayer_vietoris_robustness_radius(radii)
        print(f"  Local radii: {radii}")
        print(f"  Global radius: {global_r:.4f}")
        print()


def demo_cech_cohomology():
    """Demo 4: Čech Cohomology Computation"""
    print("=" * 60)
    print("Demo 4: Čech Cohomology on Finite Cover")
    print("=" * 60)

    # Example 1: A valid cocycle (coboundary)
    n = 3
    potential = np.array([1.0, 2.5, -0.5])
    cocycle = np.zeros((n, n))
    for i in range(n):
        for j in range(n):
            cocycle[i, j] = potential[j] - potential[i]

    vanishes, pot = cech_cohomology_vanishes(cocycle)
    print(f"  Coboundary from potential {potential}:")
    print(f"  H¹ vanishes: {vanishes}")
    if pot is not None:
        print(f"  Recovered potential: {pot}")
    print()

    # Example 2: Random cocycle (should also vanish for finite sets)
    n = 4
    base = np.random.randn(n)
    cocycle2 = np.zeros((n, n))
    for i in range(n):
        for j in range(n):
            cocycle2[i, j] = base[j] - base[i]

    vanishes2, pot2 = cech_cohomology_vanishes(cocycle2)
    print(f"  Random coboundary (n=4):")
    print(f"  H¹ vanishes: {vanishes2}")
    print()


def demo_sheaf_lipschitz():
    """Demo 5: Sheaf-Lipschitz Globalization"""
    print("=" * 60)
    print("Demo 5: Sheaf-Lipschitz Globalization")
    print("=" * 60)

    # 4-region ReLU network
    margins = [1.2, 0.8, 1.5, 0.3]
    lip_consts = [2.0, 1.5, 3.0, 0.5]

    global_r = sheaf_lipschitz_globalization(margins, lip_consts)
    print(f"  Margins:    {margins}")
    print(f"  Lipschitz:  {lip_consts}")
    local_radii = [m/L for m, L in zip(margins, lip_consts)]
    print(f"  Local radii: {[f'{r:.4f}' for r in local_radii]}")
    print(f"  Global radius: {global_r:.4f}")
    print(f"  Bottleneck: region {np.argmin(local_radii)} (radius {min(local_radii):.4f})")
    print()


def demo_weight_perturbation():
    """Demo 6: Weight Perturbation Stability"""
    print("=" * 60)
    print("Demo 6: Weight Perturbation Stability")
    print("=" * 60)

    original_radius = 1.0
    deltas = [0.0, 0.1, 0.3, 0.5, 0.8, 0.99, 1.0]
    margin = 1.5  # margin lower bound on the R-ball

    print(f"  Original radius: {original_radius}")
    print(f"  Margin lower bound: {margin}")
    print(f"{'Delta':>8} {'Preserved':>10} {'Status':>12}")
    print("-" * 35)
    for delta in deltas:
        new_r = weight_perturbation_stability(margin, delta, original_radius)
        status = "robust" if new_r > 0 else "VULNERABLE"
        print(f"{delta:8.2f} {new_r:10.4f} {status:>12}")
    print()


def demo_refinement():
    """Demo 7: Cover Refinement Comparison"""
    print("=" * 60)
    print("Demo 7: Cover Refinement Improvement")
    print("=" * 60)

    coarse = [0.5, 0.3]
    fine = [0.6, 0.4, 0.7, 0.5]
    ref_map = [0, 0, 1, 1]  # fine[0],fine[1] refine coarse[0], etc.

    c, f, improved = refinement_radius_comparison(coarse, fine, ref_map)
    print(f"  Coarse radii: {coarse} → global = {c:.4f}")
    print(f"  Fine radii:   {fine} → global = {f:.4f}")
    print(f"  Refinement improved: {improved}")
    print()


if __name__ == "__main__":
    np.random.seed(42)

    demo_lipschitz_robustness()
    demo_composition_robustness()
    demo_mayer_vietoris()
    demo_cech_cohomology()
    demo_sheaf_lipschitz()
    demo_weight_perturbation()
    demo_refinement()

    print("=" * 60)
    print("All demos completed successfully.")
    print("=" * 60)


"""
Visualization: Composition Robustness and Layer-wise Degradation

Shows how the certified robustness radius degrades as the number of
Lipschitz layers increases — the composition robustness theorem in action.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt


def main():
    fig, axes = plt.subplots(1, 3, figsize=(16, 5))

    # Plot 1: Radius vs number of layers
    ax = axes[0]
    margin = 2.0
    n_layers_range = range(1, 11)

    for L in [1.1, 1.5, 2.0, 3.0]:
        radii = [margin / (L ** n) for n in n_layers_range]
        ax.semilogy(list(n_layers_range), radii, 'o-', label=f'L = {L}', linewidth=2)

    ax.set_xlabel('Number of layers', fontsize=12)
    ax.set_ylabel('Certified radius (log scale)', fontsize=12)
    ax.set_title('Composition Robustness\nvs. Network Depth', fontsize=13, fontweight='bold')
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)

    # Plot 2: Radius vs margin (fixed depth)
    ax = axes[1]
    margins = np.linspace(0.1, 5.0, 50)
    L1, L2 = 2.0, 1.5

    ax.plot(margins, margins / (L1 * L2), 'b-', linewidth=2,
            label=f'2 layers (L₁={L1}, L₂={L2})')
    ax.plot(margins, margins / (L1 * L2 * 1.3), 'r--', linewidth=2,
            label=f'3 layers (+L₃=1.3)')
    ax.plot(margins, margins / (L1 * L2 * 1.3 * 1.1), 'g:', linewidth=2,
            label=f'4 layers (+L₄=1.1)')

    ax.set_xlabel('Margin m', fontsize=12)
    ax.set_ylabel('Certified radius', fontsize=12)
    ax.set_title('Certified Radius\nvs. Margin', fontsize=13, fontweight='bold')
    ax.legend(fontsize=9)
    ax.grid(True, alpha=0.3)

    # Plot 3: Cover refinement improvement
    ax = axes[2]
    np.random.seed(42)
    n_trials = 50
    n_regions_range = [2, 3, 5, 8, 12, 20]
    avg_radii = []
    std_radii = []

    for n_reg in n_regions_range:
        trial_radii = []
        for _ in range(n_trials):
            margins = np.random.exponential(1.0, size=n_reg) + 0.1
            lips = np.random.exponential(1.0, size=n_reg) + 0.5
            local_r = margins / lips
            trial_radii.append(np.min(local_r))
        avg_radii.append(np.mean(trial_radii))
        std_radii.append(np.std(trial_radii))

    ax.errorbar(n_regions_range, avg_radii, yerr=std_radii,
                fmt='s-', linewidth=2, capsize=5, color='purple')
    ax.set_xlabel('Number of cover regions', fontsize=12)
    ax.set_ylabel('Expected global radius', fontsize=12)
    ax.set_title('Global Radius vs.\nCover Granularity', fontsize=13, fontweight='bold')
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('composition_robustness.png', dpi=150, bbox_inches='tight')
    print("Saved: composition_robustness.png")


if __name__ == "__main__":
    main()


"""
Visualization: Persistent Robustness Filtration

Standalone script that generates a figure showing how the persistent robust set
shrinks as the perturbation radius increases, creating a "robustness barcode."
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from matplotlib.patches import Circle
from matplotlib.collections import PatchCollection


def score_gap_2d(x: np.ndarray, centers: np.ndarray, weights: np.ndarray) -> float:
    """Simple 2-class RBF classifier score gap."""
    dists = np.linalg.norm(x - centers, axis=1)
    activations = np.exp(-dists**2)
    return float(np.dot(weights, activations))


def is_robust_at_radius(
    x: np.ndarray, radius: float, score_gap_fn, n_samples: int = 200
) -> bool:
    """Check if point x is in the persistent robust set at given radius."""
    d = x.shape[0]
    for _ in range(n_samples):
        delta = np.random.uniform(-radius, radius, size=d)
        if score_gap_fn(x + delta) <= 0:
            return False
    return True


def main():
    np.random.seed(42)

    # Setup classifier
    centers = np.array([[0.3, 0.3], [0.7, 0.7], [0.3, 0.7], [0.7, 0.3]])
    weights = np.array([1.5, 1.0, -1.2, -0.8])

    def sg(x):
        return score_gap_2d(x, centers, weights)

    # Grid of test points
    grid_n = 40
    xs = np.linspace(0, 1, grid_n)
    ys = np.linspace(0, 1, grid_n)
    XX, YY = np.meshgrid(xs, ys)
    points = np.column_stack([XX.ravel(), YY.ravel()])

    # Compute persistent robust sets at different radii
    radii = [0.0, 0.02, 0.05, 0.1, 0.15, 0.2]

    fig, axes = plt.subplots(2, 3, figsize=(14, 9))
    fig.suptitle('Persistent Robustness Filtration', fontsize=16, fontweight='bold')

    for idx, (ax, r) in enumerate(zip(axes.flat, radii)):
        # Score gap values
        sg_vals = np.array([sg(p) for p in points]).reshape(grid_n, grid_n)

        # Background: score gap heatmap
        im = ax.contourf(XX, YY, sg_vals, levels=20, cmap='RdYlGn', alpha=0.5)
        ax.contour(XX, YY, sg_vals, levels=[0], colors='black', linewidths=2)

        if r > 0:
            # Compute robust set
            robust = np.array([is_robust_at_radius(p, r, sg, 100) for p in points])
            robust_grid = robust.reshape(grid_n, grid_n)

            # Overlay robust region
            ax.contourf(XX, YY, robust_grid.astype(float), levels=[0.5, 1.5],
                       colors=['blue'], alpha=0.25)
            ax.contour(XX, YY, robust_grid.astype(float), levels=[0.5],
                      colors='blue', linewidths=1.5, linestyles='--')

        # Mark centers
        pos_centers = centers[weights > 0]
        neg_centers = centers[weights < 0]
        ax.scatter(pos_centers[:, 0], pos_centers[:, 1], c='green', s=60,
                  marker='^', zorder=5, edgecolors='black', label='+ class')
        ax.scatter(neg_centers[:, 0], neg_centers[:, 1], c='red', s=60,
                  marker='v', zorder=5, edgecolors='black', label='- class')

        ax.set_title(f'r = {r:.2f}', fontsize=12)
        ax.set_xlim(0, 1)
        ax.set_ylim(0, 1)
        ax.set_aspect('equal')
        if idx == 0:
            ax.legend(loc='lower right', fontsize=8)

    plt.tight_layout()
    plt.savefig('persistent_robustness_filtration.png', dpi=150, bbox_inches='tight')
    print("Saved: persistent_robustness_filtration.png")

    # Plot 2: Robustness barcode
    fig2, ax2 = plt.subplots(figsize=(10, 5))

    test_radii = np.linspace(0, 0.25, 30)
    n_test_points = 200
    test_points = np.random.rand(n_test_points, 2)

    robust_fracs = []
    for r in test_radii:
        if r == 0:
            frac = np.mean([sg(p) > 0 for p in test_points])
        else:
            frac = np.mean([is_robust_at_radius(p, r, sg, 50) for p in test_points])
        robust_fracs.append(frac)

    ax2.fill_between(test_radii, robust_fracs, alpha=0.3, color='blue')
    ax2.plot(test_radii, robust_fracs, 'b-', linewidth=2, label='Fraction robust')
    ax2.set_xlabel('Perturbation radius r', fontsize=13)
    ax2.set_ylabel('Fraction of points in R(r)', fontsize=13)
    ax2.set_title('Robustness Persistence Curve', fontsize=15, fontweight='bold')
    ax2.legend(fontsize=12)
    ax2.grid(True, alpha=0.3)
    ax2.set_ylim(0, 1.05)

    plt.tight_layout()
    plt.savefig('robustness_barcode.png', dpi=150, bbox_inches='tight')
    print("Saved: robustness_barcode.png")


if __name__ == "__main__":
    main()
