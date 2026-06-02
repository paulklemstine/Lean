#!/usr/bin/env python3
"""
Sheaf-Theoretic Data Integration: Demonstration
=================================================

Numerical examples demonstrating the main theorems:
1. Čech coboundary identity δ² = 0
2. Consistency defect characterization
3. Laplacian-defect identity
4. Mean optimality
5. Tropical consistency
"""

from algorithms import (
    consistency_defect, is_consistent, weighted_defect, laplacian_form,
    source_mean, deviation_sum, deviation_decomposition,
    tropical_cost, cech_delta0, cech_delta1, verify_coboundary_sq_zero,
    tropical_shortest_path_merge, overlap_nerve_laplacian
)
import math


def demo_coboundary_identity():
    """Demonstrate δ¹ ∘ δ⁰ = 0."""
    print("=" * 60)
    print("DEMO 1: Čech Coboundary Identity (δ² = 0)")
    print("=" * 60)
    
    test_data = [
        [1.0, 3.0, 7.0, 2.0],
        [0.0, 0.0, 0.0, 0.0],
        [1.5, -2.3, 4.7],
        [42.0],
        [math.pi, math.e, math.sqrt(2), 1.0, -1.0],
    ]
    
    for i, f in enumerate(test_data):
        result = verify_coboundary_sq_zero(f)
        print(f"  Test {i+1}: f = {f}")
        print(f"    δ¹(δ⁰(f)) = 0? {result}")
    print()


def demo_defect_characterization():
    """Demonstrate defect = 0 ⟺ consistent."""
    print("=" * 60)
    print("DEMO 2: Defect Characterization")
    print("=" * 60)
    
    # Consistent data
    f_consistent = [5.0, 5.0, 5.0, 5.0]
    d = consistency_defect(f_consistent)
    print(f"  Consistent: f = {f_consistent}")
    print(f"    defect = {d}, is_consistent = {is_consistent(f_consistent)}")
    
    # Inconsistent data
    f_inconsistent = [1.0, 2.0, 3.0, 4.0]
    d = consistency_defect(f_inconsistent)
    print(f"  Inconsistent: f = {f_inconsistent}")
    print(f"    defect = {d}, is_consistent = {is_consistent(f_inconsistent)}")
    
    # Quadratic scaling
    alpha = 3.0
    f = [1.0, 4.0, 2.0]
    d_f = consistency_defect(f)
    d_af = consistency_defect([alpha * x for x in f])
    print(f"\n  Quadratic scaling: α = {alpha}, f = {f}")
    print(f"    defect(f) = {d_f}")
    print(f"    defect(α·f) = {d_af}")
    print(f"    α²·defect(f) = {alpha**2 * d_f}")
    print(f"    Match: {abs(d_af - alpha**2 * d_f) < 1e-10}")
    print()


def demo_laplacian_identity():
    """Demonstrate weighted_defect = 2 · laplacian_form."""
    print("=" * 60)
    print("DEMO 3: Laplacian-Defect Identity")
    print("=" * 60)
    
    f = [1.0, 3.0, 2.0, 5.0]
    # Symmetric weight matrix (overlap counts)
    w = [
        [0, 3, 1, 2],
        [3, 0, 4, 0],
        [1, 4, 0, 2],
        [2, 0, 2, 0],
    ]
    
    wd = weighted_defect(f, w)
    lf = laplacian_form(f, w)
    
    print(f"  f = {f}")
    print(f"  Overlap weights:")
    for row in w:
        print(f"    {row}")
    print(f"  weighted_defect = {wd}")
    print(f"  laplacian_form = {lf}")
    print(f"  2 · laplacian_form = {2 * lf}")
    print(f"  Identity holds: {abs(wd - 2 * lf) < 1e-10}")
    
    # Show the Laplacian matrix
    L = overlap_nerve_laplacian(w)
    print(f"\n  Graph Laplacian L:")
    for row in L:
        print(f"    {[f'{x:6.1f}' for x in row]}")
    print()


def demo_mean_optimality():
    """Demonstrate mean minimizes deviation sum."""
    print("=" * 60)
    print("DEMO 4: Mean Optimality")
    print("=" * 60)
    
    f = [2.0, 4.0, 6.0, 8.0, 10.0]
    m = source_mean(f)
    
    print(f"  f = {f}")
    print(f"  mean = {m}")
    print(f"  deviation from mean = {deviation_sum(f, m):.4f}")
    
    # Compare with other constants
    test_constants = [0.0, 3.0, 5.0, m, 7.0, 12.0]
    print(f"\n  Deviation from various constants:")
    for c in test_constants:
        d = deviation_sum(f, c)
        marker = " ← OPTIMAL" if abs(c - m) < 1e-10 else ""
        print(f"    c = {c:6.2f}: D(f,c) = {d:8.4f}{marker}")
    
    # Bias-variance decomposition
    c = 3.0
    var_part, bias_part, total = deviation_decomposition(f, c)
    print(f"\n  Bias-Variance Decomposition (c = {c}):")
    print(f"    D(f, mean) = {var_part:.4f}")
    print(f"    n·(mean-c)² = {bias_part:.4f}")
    print(f"    Total D(f,c) = {total:.4f}")
    print(f"    Direct computation = {deviation_sum(f, c):.4f}")
    print(f"    Match: {abs(total - deviation_sum(f, c)) < 1e-10}")
    print()


def demo_tropical_consistency():
    """Demonstrate tropical consistency cost properties."""
    print("=" * 60)
    print("DEMO 5: Tropical Consistency")
    print("=" * 60)
    
    r = 0.1  # 10% error rate
    
    # Additivity
    C1, C2 = 5, 8
    t1 = tropical_cost(r, C1)
    t2 = tropical_cost(r, C2)
    t_sum = tropical_cost(r, C1 + C2)
    print(f"  Error rate r = {r}")
    print(f"  τ(r, {C1}) = {t1:.6f}")
    print(f"  τ(r, {C2}) = {t2:.6f}")
    print(f"  τ(r, {C1}+{C2}) = {t_sum:.6f}")
    print(f"  τ(r,{C1}) + τ(r,{C2}) = {t1 + t2:.6f}")
    print(f"  Additivity: {abs(t_sum - t1 - t2) < 1e-10}")
    
    # Monotonicity
    print(f"\n  Monotonicity (r = {r}):")
    for C in range(1, 11):
        t = tropical_cost(r, C)
        prob = math.exp(-t)
        print(f"    C = {C:2d}: τ = {t:.6f}, P(consistent) = {prob:.6f}")
    print()


def demo_tropical_merge():
    """Demonstrate tropical shortest-path merge optimization."""
    print("=" * 60)
    print("DEMO 6: Tropical Optimal Merge")
    print("=" * 60)
    
    n = 5
    labels = ["Radiology", "Cardiology", "ER", "Lab", "Pharmacy"]
    
    # Overlap weights (shared features)
    weights = [
        [0, 2, 5, 3, 0],
        [2, 0, 4, 1, 0],
        [5, 4, 0, 6, 3],
        [3, 1, 6, 0, 2],
        [0, 0, 3, 2, 0],
    ]
    
    # Error rates
    error_rates = [
        [0.0, 0.05, 0.08, 0.10, 0.0],
        [0.05, 0.0, 0.06, 0.12, 0.0],
        [0.08, 0.06, 0.0, 0.04, 0.09],
        [0.10, 0.12, 0.04, 0.0, 0.07],
        [0.0, 0.0, 0.09, 0.07, 0.0],
    ]
    
    total_cost, mst_edges = tropical_shortest_path_merge(
        n, weights, error_rates
    )
    
    print(f"  Data sources: {labels}")
    print(f"\n  Overlap weights:")
    for i in range(n):
        for j in range(i+1, n):
            if weights[i][j] > 0:
                print(f"    {labels[i]} ↔ {labels[j]}: "
                      f"{weights[i][j]} features, "
                      f"error rate {error_rates[i][j]:.0%}")
    
    print(f"\n  Optimal merge order (MST):")
    for u, v in mst_edges:
        cost = tropical_cost(error_rates[u][v], int(weights[u][v]))
        print(f"    {labels[u]} ↔ {labels[v]}: "
              f"tropical cost = {cost:.6f}")
    print(f"\n  Total integration cost: {total_cost:.6f}")
    print()


def demo_defect_monotonicity():
    """Demonstrate that restricting to subsets decreases defect."""
    print("=" * 60)
    print("DEMO 7: Defect Monotonicity")
    print("=" * 60)
    
    f = [1.0, 5.0, 3.0, 7.0, 2.0]
    full_defect = consistency_defect(f)
    print(f"  f = {f}")
    print(f"  Full defect (n={len(f)}): {full_defect}")
    
    # Test subsets of various sizes
    subsets = [
        [0, 1, 2, 3, 4],
        [0, 1, 2, 3],
        [0, 2, 4],
        [1, 3],
        [2],
    ]
    
    for S in subsets:
        f_sub = [f[i] for i in S]
        sub_defect = consistency_defect(f_sub)
        print(f"  Subset {S}: defect = {sub_defect:.1f} "
              f"{'≤' if sub_defect <= full_defect + 1e-10 else '>'} "
              f"{full_defect:.1f}")
    print()


if __name__ == "__main__":
    demo_coboundary_identity()
    demo_defect_characterization()
    demo_laplacian_identity()
    demo_mean_optimality()
    demo_tropical_consistency()
    demo_tropical_merge()
    demo_defect_monotonicity()
    
    print("=" * 60)
    print("All demonstrations completed successfully.")
    print("=" * 60)


#!/usr/bin/env python3
"""
Visualization: Consistency Defect Landscape

Shows how the consistency defect varies as a function of data values,
demonstrating the quadratic bowl shape with minimum at the mean.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def consistency_defect_2d(x, y, fixed_values):
    """Compute defect for values [x, y] + fixed_values."""
    all_vals = [x, y] + fixed_values
    n = len(all_vals)
    total = 0.0
    for i in range(n):
        for j in range(n):
            total += (all_vals[j] - all_vals[i]) ** 2
    return total


def deviation_sum(values, c):
    """Sum of squared deviations from constant c."""
    return sum((v - c) ** 2 for v in values)


def main():
    fig, axes = plt.subplots(1, 3, figsize=(18, 5))

    # Plot 1: Deviation sum as function of c
    ax1 = axes[0]
    f = [2.0, 4.0, 6.0, 8.0, 10.0]
    mean_f = sum(f) / len(f)
    cs = np.linspace(-2, 14, 200)
    devs = [deviation_sum(f, c) for c in cs]

    ax1.plot(cs, devs, 'b-', linewidth=2)
    ax1.axvline(x=mean_f, color='r', linestyle='--', linewidth=1.5, label=f'Mean = {mean_f}')
    ax1.plot(mean_f, deviation_sum(f, mean_f), 'ro', markersize=10, zorder=5)
    ax1.set_xlabel('Imputation value c', fontsize=12)
    ax1.set_ylabel('D(f, c)', fontsize=12)
    ax1.set_title('Mean Minimizes Deviation', fontsize=14)
    ax1.legend(fontsize=11)
    ax1.grid(True, alpha=0.3)

    # Plot 2: Tropical cost as function of error rate
    ax2 = axes[1]
    rs = np.linspace(0.01, 0.99, 200)
    for C in [1, 3, 5, 10, 20]:
        costs = [-C * np.log(1 - r) for r in rs]
        ax2.plot(rs, costs, linewidth=2, label=f'C = {C}')

    ax2.set_xlabel('Error rate r', fontsize=12)
    ax2.set_ylabel('Tropical cost τ(r, C)', fontsize=12)
    ax2.set_title('Tropical Consistency Cost', fontsize=14)
    ax2.legend(fontsize=10)
    ax2.set_ylim(0, 10)
    ax2.grid(True, alpha=0.3)

    # Plot 3: Defect scaling
    ax3 = axes[2]
    f_base = [1.0, 3.0, 5.0, 2.0]
    alphas = np.linspace(0, 3, 100)

    def defect(vals):
        n = len(vals)
        return sum((vals[j] - vals[i]) ** 2 for i in range(n) for j in range(n))

    base_defect = defect(f_base)
    defects = [defect([a * x for x in f_base]) for a in alphas]
    predicted = [a ** 2 * base_defect for a in alphas]

    ax3.plot(alphas, defects, 'b-', linewidth=2, label='defect(α·f)')
    ax3.plot(alphas, predicted, 'r--', linewidth=2, label='α²·defect(f)')
    ax3.set_xlabel('Scale factor α', fontsize=12)
    ax3.set_ylabel('Consistency defect', fontsize=12)
    ax3.set_title('Quadratic Scaling of Defect', fontsize=14)
    ax3.legend(fontsize=11)
    ax3.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('viz_defect_landscape.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved viz_defect_landscape.png")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: Overlap Nerve and Laplacian Spectrum

Shows the overlap network between data sources and the eigenvalue
spectrum of its Laplacian, illustrating the spectral gap.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def overlap_nerve_laplacian(weights):
    """Compute the graph Laplacian."""
    n = len(weights)
    L = np.zeros((n, n))
    for i in range(n):
        deg = sum(weights[i])
        L[i, i] = deg
        for j in range(n):
            if i != j:
                L[i, j] = -weights[i][j]
    return L


def main():
    fig, axes = plt.subplots(1, 3, figsize=(18, 5))

    # Define overlap nerve
    labels = ["Radiology", "Cardiology", "ER", "Lab", "Pharmacy"]
    n = len(labels)
    weights = np.array([
        [0, 3, 5, 3, 0],
        [3, 0, 4, 1, 0],
        [5, 4, 0, 6, 3],
        [3, 1, 6, 0, 2],
        [0, 0, 3, 2, 0],
    ], dtype=float)

    # Plot 1: Overlap network
    ax1 = axes[0]
    # Circular layout
    angles = np.linspace(0, 2 * np.pi, n, endpoint=False)
    positions = np.column_stack([np.cos(angles), np.sin(angles)]) * 1.5

    # Draw edges with thickness proportional to weight
    for i in range(n):
        for j in range(i + 1, n):
            if weights[i][j] > 0:
                ax1.plot(
                    [positions[i, 0], positions[j, 0]],
                    [positions[i, 1], positions[j, 1]],
                    'b-', linewidth=weights[i][j] * 0.8, alpha=0.4
                )
                mid = (positions[i] + positions[j]) / 2
                ax1.text(mid[0], mid[1], f'{int(weights[i][j])}',
                        fontsize=9, ha='center', va='center',
                        bbox=dict(boxstyle='round,pad=0.2', facecolor='white', alpha=0.8))

    for i in range(n):
        ax1.plot(positions[i, 0], positions[i, 1], 'o', markersize=20,
                color='steelblue', zorder=5)
        offset = positions[i] * 1.3
        ax1.text(offset[0], offset[1], labels[i], fontsize=10,
                ha='center', va='center', fontweight='bold')

    ax1.set_xlim(-2.5, 2.5)
    ax1.set_ylim(-2.5, 2.5)
    ax1.set_aspect('equal')
    ax1.set_title('Overlap Nerve', fontsize=14)
    ax1.axis('off')

    # Plot 2: Laplacian eigenvalue spectrum
    ax2 = axes[1]
    L = overlap_nerve_laplacian(weights)
    eigenvalues = np.sort(np.linalg.eigvalsh(L))

    ax2.bar(range(n), eigenvalues, color='steelblue', alpha=0.8, edgecolor='navy')
    ax2.set_xlabel('Eigenvalue index', fontsize=12)
    ax2.set_ylabel('λ', fontsize=12)
    ax2.set_title('Laplacian Spectrum', fontsize=14)
    ax2.set_xticks(range(n))
    ax2.set_xticklabels([f'λ_{i+1}' for i in range(n)])

    # Highlight spectral gap
    if n > 1:
        ax2.annotate(f'λ₂ = {eigenvalues[1]:.2f}\n(spectral gap)',
                    xy=(1, eigenvalues[1]), xytext=(2, eigenvalues[1] + 1),
                    arrowprops=dict(arrowstyle='->', color='red'),
                    fontsize=10, color='red', fontweight='bold')
    ax2.grid(True, alpha=0.3, axis='y')

    # Plot 3: Defect vs data vector angle
    ax3 = axes[2]
    # Compute defect for data vectors parameterized by angle
    # Use f = cos(θ) * v1 + sin(θ) * v2 where v1, v2 are eigenvectors
    eigvals, eigvecs = np.linalg.eigh(L)
    thetas = np.linspace(0, 2 * np.pi, 200)

    # Use eigenvectors 1 and 2 (indices 1 and 2)
    v1 = eigvecs[:, 1]  # Fiedler vector
    v2 = eigvecs[:, 2]

    defects = []
    for theta in thetas:
        f = np.cos(theta) * v1 + np.sin(theta) * v2
        d = sum(weights[i][j] * (f[j] - f[i]) ** 2
               for i in range(n) for j in range(n))
        defects.append(d)

    ax3.plot(np.degrees(thetas), defects, 'b-', linewidth=2)
    ax3.axhline(y=2 * eigvals[1], color='r', linestyle='--',
               label=f'2λ₂ = {2*eigvals[1]:.2f}', linewidth=1.5)
    ax3.set_xlabel('Angle θ (degrees)', fontsize=12)
    ax3.set_ylabel('Weighted defect', fontsize=12)
    ax3.set_title('Defect on Eigenplane', fontsize=14)
    ax3.legend(fontsize=11)
    ax3.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('viz_overlap_nerve.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved viz_overlap_nerve.png")


if __name__ == "__main__":
    main()
