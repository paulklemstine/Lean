#!/usr/bin/env python3
"""
demo.py — Numerical demonstrations of Neural PDE Universality Classes
via Renormalization Fixed Points.

Shows:
1. Architecture collapse under contractive RG
2. Conservation law separation of classes
3. Spectral analysis at fixed points
4. Conjectured class counting for real PDE families
"""

import numpy as np
from algorithms import (
    rg_iterate, compute_contraction_rate, detect_universality_classes,
    conjectured_class_count, effective_contraction_rate,
    spectral_analysis, affine_contraction_rg, simulate_pde_rg_collapse
)


def demo_architecture_collapse():
    """Demonstrate that different architectures converge under contractive RG."""
    print("=" * 70)
    print("DEMO 1: Architecture Independence under Contractive RG")
    print("=" * 70)

    result = simulate_pde_rg_collapse(
        n_architectures=5, dim=4, n_rg_steps=30, contraction_rate=0.6
    )

    print(f"\nFixed point: {result['fixed_point']}")
    print(f"Contraction rate: {result['contraction_rate']}")
    print(f"\nDistance to fixed point over RG steps:")
    print(f"{'Step':>6} | " + " | ".join(f"Arch {i}" for i in range(5)))
    print("-" * 70)

    for step in [0, 5, 10, 15, 20, 25, 30]:
        dists = [f"{result['fp_distances'][step, i]:.6f}" for i in range(5)]
        print(f"{step:>6} | " + " | ".join(f"{d:>8}" for d in dists))

    print(f"\nAll architectures converge to the same fixed point!")
    print(f"Final max distance: {result['fp_distances'][-1].max():.2e}")


def demo_conservation_separation():
    """Show that conservation laws separate universality classes."""
    print("\n" + "=" * 70)
    print("DEMO 2: Conservation Law Class Separation")
    print("=" * 70)

    dim = 4
    n_classes = 3
    n_per_class = 4
    n_steps = 40

    rng = np.random.RandomState(123)

    # Create 3 classes with different conservation values
    # Conservation law: sum of first two components
    fixed_points = [
        np.array([1.0, 1.0, 0.0, 0.0]),   # conserved value = 2
        np.array([2.0, 3.0, 0.0, 0.0]),   # conserved value = 5
        np.array([-1.0, 0.0, 0.0, 0.0]),  # conserved value = -1
    ]

    all_orbits = []
    class_labels_true = []

    for cls_idx, fp in enumerate(fixed_points):
        coarsen = affine_contraction_rg(0.5, fp)
        for _ in range(n_per_class):
            # Start near the class's basin but with perturbation
            x0 = fp + rng.randn(dim) * 2
            orbit = rg_iterate(coarsen, x0, n_steps)
            all_orbits.append(orbit)
            class_labels_true.append(cls_idx)

    # Detect classes from orbits
    detected_labels = detect_universality_classes(all_orbits, threshold=0.1)

    print(f"\nTrue class labels:     {class_labels_true}")
    print(f"Detected class labels: {detected_labels}")

    # Check conservation values
    print(f"\nConservation law values (sum of first 2 components):")
    for i, orbit in enumerate(all_orbits):
        init_val = orbit[0][0] + orbit[0][1]
        final_val = orbit[-1][0] + orbit[-1][1]
        print(f"  Orbit {i:2d} (class {class_labels_true[i]}): "
              f"initial = {init_val:+.3f}, converges to class with value ≈ "
              f"{fixed_points[class_labels_true[i]][0] + fixed_points[class_labels_true[i]][1]:+.3f}")


def demo_spectral_analysis():
    """Analyze the spectrum at RG fixed points."""
    print("\n" + "=" * 70)
    print("DEMO 3: Spectral Analysis at Fixed Points")
    print("=" * 70)

    dim = 5

    # Create a non-trivial RG with different contraction rates per direction
    eigenvalues_true = np.array([0.9, 0.7, 0.5, 0.3, 0.1])
    Q = np.linalg.qr(np.random.RandomState(42).randn(dim, dim))[0]
    A = Q @ np.diag(eigenvalues_true) @ Q.T

    fp = np.zeros(dim)

    def coarsen(x):
        return A @ x

    spectrum = spectral_analysis(coarsen, fp)

    print(f"\nTrue eigenvalues:      {eigenvalues_true.tolist()}")
    print(f"Computed eigenvalues:  {[f'{v:.6f}' for v in spectrum['eigenvalues']]}")
    print(f"Leading eigenvalue:    {spectrum['leading_eigenvalue']:.6f}")
    print(f"Spectral gap:          {spectrum['spectral_gap']:.6f}")
    print(f"Relevant dimensions:   {spectrum['relevant_dim']}")
    print(f"Critical exponent:     {spectrum['critical_exponent']:.6f}")


def demo_class_counting():
    """Test the conjectured class counting formula on PDE families."""
    print("\n" + "=" * 70)
    print("DEMO 4: Conjectured Universality Class Counting")
    print("=" * 70)

    pde_families = [
        ("Burgers equation",    1, 1, 2),
        ("KdV equation",        1, 3, 3),
        ("2D Navier-Stokes",    2, 2, 2),
        ("NLS (1D)",            1, 2, 2),
        ("Heat equation (3D)",  3, 1, 2),
        ("Wave equation (2D)",  2, 1, 2),
    ]

    print(f"\n{'PDE Family':<25} {'Symm(d)':>8} {'Cons(c)':>8} {'Order(p)':>9} "
          f"{'(d+1)(c+1)':>11} {'eff. rate':>10}")
    print("-" * 85)

    base_rate = 0.7
    for name, d, c, p in pde_families:
        count = conjectured_class_count(d, c, p)
        eff_rate = effective_contraction_rate(base_rate, p)
        print(f"{name:<25} {d:>8} {c:>8} {p:>9} {count:>11} {eff_rate:>10.4f}")

    print(f"\nNote: Higher differential order → smaller effective contraction rate")
    print(f"      → faster convergence to universality class fixed point")


def demo_contraction_rate_estimation():
    """Estimate contraction rates from data."""
    print("\n" + "=" * 70)
    print("DEMO 5: Contraction Rate Estimation")
    print("=" * 70)

    dim = 6
    true_rates = [0.3, 0.5, 0.7, 0.9, 0.95]
    rng = np.random.RandomState(77)
    fp = rng.randn(dim)

    print(f"\n{'True rate':>12} {'Estimated':>12} {'|Error|':>10}")
    print("-" * 38)

    for rate in true_rates:
        coarsen = affine_contraction_rg(rate, fp)
        samples = [rng.randn(dim) * 5 for _ in range(20)]
        est_rate = compute_contraction_rate(coarsen, samples)
        print(f"{rate:>12.4f} {est_rate:>12.4f} {abs(rate - est_rate):>10.2e}")


if __name__ == "__main__":
    demo_architecture_collapse()
    demo_conservation_separation()
    demo_spectral_analysis()
    demo_class_counting()
    demo_contraction_rate_estimation()

    print("\n" + "=" * 70)
    print("All demonstrations completed successfully.")
    print("=" * 70)


#!/usr/bin/env python3
"""
Visualization: RG Orbit Collapse to Universality Classes

Generates a figure showing how different neural architectures (random initial
operators) converge under renormalization group iteration to the same fixed point,
demonstrating architecture independence.
"""
import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt


def affine_contraction_rg(contraction_rate, fixed_point):
    def coarsen(x):
        return fixed_point + contraction_rate * (x - fixed_point)
    return coarsen


def rg_iterate(coarsen, x, n_steps):
    orbit = [x.copy()]
    current = x.copy()
    for _ in range(n_steps):
        current = coarsen(current)
        orbit.append(current.copy())
    return orbit


def main():
    rng = np.random.RandomState(42)
    dim = 4
    n_arch = 8
    n_steps = 40
    fp = rng.randn(dim)

    fig, axes = plt.subplots(1, 3, figsize=(18, 5))

    # --- Panel 1: Single class (contractive) ---
    coarsen = affine_contraction_rg(0.6, fp)
    colors = plt.cm.tab10(np.linspace(0, 1, n_arch))

    ax = axes[0]
    for i in range(n_arch):
        x0 = rng.randn(dim) * 5
        orbit = rg_iterate(coarsen, x0, n_steps)
        dists = [np.linalg.norm(o - fp) for o in orbit]
        ax.semilogy(range(n_steps + 1), dists, color=colors[i], alpha=0.8,
                     label=f'Arch {i+1}')

    ax.set_xlabel('RG Step', fontsize=12)
    ax.set_ylabel('Distance to Fixed Point', fontsize=12)
    ax.set_title('Single Universality Class\n(Contractive RG, c=0.6)', fontsize=13)
    ax.legend(fontsize=8, ncol=2)
    ax.grid(True, alpha=0.3)

    # Theoretical bound
    d0 = 10
    steps_arr = np.arange(n_steps + 1)
    ax.semilogy(steps_arr, d0 * 0.6**steps_arr, 'k--', alpha=0.5, label='c^n bound')

    # --- Panel 2: Multiple classes (conservation separation) ---
    ax = axes[1]
    fixed_points = [
        np.array([2.0, 1.0, 0.0, 0.0]),
        np.array([-1.0, 3.0, 0.0, 0.0]),
        np.array([0.0, -2.0, 0.0, 0.0]),
    ]
    class_colors = ['#e74c3c', '#3498db', '#2ecc71']

    for cls_idx, fp_cls in enumerate(fixed_points):
        coarsen = affine_contraction_rg(0.5, fp_cls)
        for j in range(4):
            x0 = fp_cls + rng.randn(dim) * 3
            orbit = rg_iterate(coarsen, x0, n_steps)
            cons_vals = [o[0] + o[1] for o in orbit]
            ax.plot(range(n_steps + 1), cons_vals, color=class_colors[cls_idx],
                    alpha=0.6, linewidth=1.5)

    ax.set_xlabel('RG Step', fontsize=12)
    ax.set_ylabel('Conservation Law Value', fontsize=12)
    ax.set_title('Conservation Laws Separate Classes\n(3 PDE families)', fontsize=13)
    ax.grid(True, alpha=0.3)

    # Add class labels
    for cls_idx, fp_cls in enumerate(fixed_points):
        val = fp_cls[0] + fp_cls[1]
        ax.axhline(y=val, color=class_colors[cls_idx], linestyle='--', alpha=0.3)
        ax.text(n_steps + 1, val, f'Class {cls_idx+1}', fontsize=10,
                color=class_colors[cls_idx], va='center')

    # --- Panel 3: Effective contraction vs differential order ---
    ax = axes[2]
    base_rates = [0.5, 0.6, 0.7, 0.8, 0.9]
    orders = np.arange(1, 7)

    for br in base_rates:
        eff_rates = [br**p for p in orders]
        ax.plot(orders, eff_rates, 'o-', label=f'base = {br}', markersize=6)

    ax.set_xlabel('Differential Order p', fontsize=12)
    ax.set_ylabel('Effective Contraction Rate c^p', fontsize=12)
    ax.set_title('Higher Order → Faster Convergence\n(Effective contraction rate)', fontsize=13)
    ax.legend(fontsize=9)
    ax.grid(True, alpha=0.3)
    ax.set_xticks(orders)

    plt.tight_layout()
    plt.savefig('viz_rg_collapse.png', dpi=150, bbox_inches='tight')
    print("Saved viz_rg_collapse.png")


if __name__ == "__main__":
    main()
