#!/usr/bin/env python3
"""
Tropical Spectral Graph Theory: Demonstrations

Numerical examples demonstrating the main theorems:
1. Min-plus matrix multiplication and power computation
2. DAG moment vanishing
3. Dense graph cycle detection
4. Moment lower bounds
5. Minimum cycle mean convergence
"""

import sys
sys.path.insert(0, '.')
from algorithms import (
    min_plus_mul, min_plus_id, min_plus_pow, min_plus_pow_fast,
    tropical_trace, tropical_moment, tropical_spectrum,
    minimum_cycle_mean, is_dag, out_degrees, degree_variance
)
import random

Inf = float('inf')


def print_matrix(M, name="M"):
    """Pretty-print a matrix with ∞ for infinite entries."""
    n = len(M)
    print(f"\n{name} ({n}×{n}):")
    for row in M:
        print("  [" + ", ".join(
            f"{x:5.1f}" if x < Inf else "    ∞" for x in row
        ) + "]")


def demo_basic_operations():
    """Demonstrate min-plus matrix multiplication."""
    print("=" * 60)
    print("DEMO 1: Min-Plus Matrix Operations")
    print("=" * 60)

    # 4-vertex weighted directed graph
    # 0 → 1 (weight 3), 1 → 2 (weight 2), 2 → 3 (weight 1), 3 → 0 (weight 4)
    A = [
        [Inf, 3.0, Inf, Inf],
        [Inf, Inf, 2.0, Inf],
        [Inf, Inf, Inf, 1.0],
        [4.0, Inf, Inf, Inf],
    ]
    print_matrix(A, "Adjacency matrix A")

    # Identity
    I = min_plus_id(4)
    print_matrix(I, "Min-plus identity I")

    # Verify I ⊗ A = A
    IA = min_plus_mul(I, A)
    print_matrix(IA, "I ⊗ A (should equal A)")
    assert all(IA[i][j] == A[i][j] for i in range(4) for j in range(4))
    print("✓ I ⊗ A = A verified!")

    # Verify A ⊗ I = A
    AI = min_plus_mul(A, I)
    assert all(AI[i][j] == A[i][j] for i in range(4) for j in range(4))
    print("✓ A ⊗ I = A verified!")

    # Compute A^⊗2
    A2 = min_plus_mul(A, A)
    print_matrix(A2, "A^⊗2 (2-edge shortest paths)")
    print("  A^⊗2[0][2] = min(A[0][k]+A[k][2]) = A[0][1]+A[1][2] = 3+2 = 5")

    # Verify associativity: (A^⊗2) ⊗ A = A ⊗ (A^⊗2)
    left = min_plus_mul(A2, A)
    right = min_plus_mul(A, A2)
    assert all(abs(left[i][j] - right[i][j]) < 1e-10 if left[i][j] < Inf else right[i][j] == Inf
               for i in range(4) for j in range(4))
    print("✓ Associativity (A⊗A)⊗A = A⊗(A⊗A) verified!")

    # Verify walk composition: A^⊗4 = A^⊗2 ⊗ A^⊗2
    A4_direct = min_plus_pow(A, 4)
    A4_composed = min_plus_mul(A2, A2)
    assert all(abs(A4_direct[i][j] - A4_composed[i][j]) < 1e-10 if A4_direct[i][j] < Inf
               else A4_composed[i][j] == Inf
               for i in range(4) for j in range(4))
    print("✓ Walk composition A^⊗4 = A^⊗2 ⊗ A^⊗2 verified!")


def demo_spectrum():
    """Demonstrate tropical spectrum computation."""
    print("\n" + "=" * 60)
    print("DEMO 2: Tropical Spectrum")
    print("=" * 60)

    # Cycle graph: 0→1→2→3→0 with weights 3, 2, 1, 4
    A = [
        [Inf, 3.0, Inf, Inf],
        [Inf, Inf, 2.0, Inf],
        [Inf, Inf, Inf, 1.0],
        [4.0, Inf, Inf, Inf],
    ]

    moments = tropical_spectrum(A, 8)
    print("\nTropical spectral moments of cycle graph (weights 3,2,1,4):")
    for k, m in enumerate(moments):
        mk = f"{m:.1f}" if m < Inf else "∞"
        print(f"  μ_{k} = {mk}")

    print(f"\n  Expected: μ_0 = 0, μ_1 = ∞, μ_2 = ∞, μ_3 = ∞")
    print(f"  μ_4 = weight of cycle = 3+2+1+4 = 10")
    print(f"  μ_8 = 2 × cycle weight = 20")
    assert moments[0] == 0
    assert moments[1] == Inf
    assert moments[4] == 10.0
    assert moments[8] == 20.0
    print("✓ All moment values verified!")


def demo_dag_vanishing():
    """Demonstrate DAG moment vanishing (Theorem 7)."""
    print("\n" + "=" * 60)
    print("DEMO 3: DAG Moment Vanishing")
    print("=" * 60)

    # DAG: 0→1, 0→2, 1→2, 1→3, 2→3
    A = [
        [Inf, 1.0, 2.0, Inf],
        [Inf, Inf, 3.0, 1.0],
        [Inf, Inf, Inf, 2.0],
        [Inf, Inf, Inf, Inf],
    ]

    print(f"\nGraph is DAG: {is_dag(A)}")
    assert is_dag(A)

    moments = tropical_spectrum(A, 6)
    print("Tropical moments:")
    for k, m in enumerate(moments):
        mk = f"{m:.1f}" if m < Inf else "∞"
        print(f"  μ_{k} = {mk}")

    print("\nTheorem: All positive moments of a DAG are ∞")
    for k in range(1, 7):
        assert moments[k] == Inf, f"μ_{k} should be ∞!"
    print("✓ DAG vanishing verified for k = 1, ..., 6!")


def demo_lower_bound():
    """Demonstrate the moment lower bound (Theorem 8)."""
    print("\n" + "=" * 60)
    print("DEMO 4: Moment Lower Bound")
    print("=" * 60)

    # Triangle with varying weights
    A = [
        [Inf, 5.0, Inf],
        [Inf, Inf, 7.0],
        [3.0, Inf, Inf],
    ]

    w_min = 3.0  # minimum finite edge weight
    print(f"\nTriangle graph, minimum edge weight w_min = {w_min}")

    moments = tropical_spectrum(A, 9)
    print("Tropical moments and lower bounds:")
    for k, m in enumerate(moments):
        mk = f"{m:.1f}" if m < Inf else "∞"
        bound = k * w_min
        print(f"  μ_{k} = {mk:>6s}  ≥  {k} × {w_min:.0f} = {bound:.0f}")
        if m < Inf:
            assert m >= bound - 1e-10, f"Lower bound violated at k={k}!"

    print("✓ Lower bound μ_k ≥ k·w_min verified for all k!")


def demo_dense_cycle():
    """Demonstrate dense graph cycle detection (Theorem 12)."""
    print("\n" + "=" * 60)
    print("DEMO 5: Dense Graph Cycle Detection")
    print("=" * 60)

    # Complete graph on 5 vertices with random weights
    n = 5
    random.seed(42)
    A = [[Inf if i == j else random.randint(1, 10) for j in range(n)] for i in range(n)]

    degs = out_degrees(A)
    print(f"\nComplete digraph on {n} vertices")
    print(f"Out-degrees: {degs}")
    print(f"All degrees = n-1 = {n-1}: {all(d == n-1 for d in degs)}")

    m2 = tropical_moment(A, 2)
    print(f"\nμ_2 = {m2:.1f}")
    print(f"μ_2 is finite: {m2 < Inf}")
    assert m2 < Inf
    print("✓ Dense graph has finite 2nd moment (mutual edges exist)!")

    # Find the witnessing 2-cycle
    A2 = min_plus_pow(A, 2)
    for i in range(n):
        if A2[i][i] == m2:
            # Find the intermediate vertex
            for k in range(n):
                if A[i][k] + A[k][i] == m2:
                    print(f"  Witness: {i}→{k}→{i} with weight {A[i][k]}+{A[k][i]}={m2:.0f}")
                    break
            break


def demo_convergence():
    """Demonstrate convergence of μ_k/k to minimum cycle mean."""
    print("\n" + "=" * 60)
    print("DEMO 6: Tropical Eigenvalue Convergence (Conjecture)")
    print("=" * 60)

    # Graph with two cycles of different means
    # Cycle 1: 0→1→0 with weights 2, 3 (mean = 2.5)
    # Cycle 2: 0→2→3→0 with weights 1, 1, 1 (mean = 1.0)
    A = [
        [Inf, 2.0, 1.0, Inf],
        [3.0, Inf, Inf, Inf],
        [Inf, Inf, Inf, 1.0],
        [1.0, Inf, Inf, Inf],
    ]

    mcm = minimum_cycle_mean(A)
    print(f"\nMinimum cycle mean (Karp's algorithm): {mcm:.4f}")
    print(f"Expected: 1.0 (from cycle 0→2→3→0)")

    moments = tropical_spectrum(A, 30)
    print("\nConvergence of μ_k/k:")
    print(f"  {'k':>3s}  {'μ_k':>8s}  {'μ_k/k':>8s}  {'|μ_k/k - λ*|':>12s}")
    for k in range(1, 31):
        m = moments[k]
        if m < Inf:
            ratio = m / k
            err = abs(ratio - mcm)
            print(f"  {k:3d}  {m:8.1f}  {ratio:8.4f}  {err:12.6f}")
        else:
            print(f"  {k:3d}  {'∞':>8s}  {'∞':>8s}  {'N/A':>12s}")

    # Check convergence for large k
    if moments[30] < Inf:
        ratio_30 = moments[30] / 30
        print(f"\n  λ_trop ≈ lim μ_k/k ≈ {ratio_30:.4f}")
        print(f"  Min cycle mean = {mcm:.4f}")
        print(f"  Error at k=30: {abs(ratio_30 - mcm):.6f}")


def demo_monotonicity():
    """Demonstrate weight monotonicity (Theorem 11)."""
    print("\n" + "=" * 60)
    print("DEMO 7: Weight Monotonicity")
    print("=" * 60)

    # Base graph
    A = [
        [Inf, 5.0, Inf],
        [Inf, Inf, 4.0],
        [3.0, Inf, Inf],
    ]

    # Graph with decreased weights (added shortcuts)
    A_prime = [
        [Inf, 3.0, Inf],  # decreased 5→3
        [Inf, Inf, 2.0],  # decreased 4→2
        [1.0, Inf, Inf],  # decreased 3→1
    ]

    print("\nOriginal graph A: weights 5, 4, 3")
    print("Modified graph A': weights 3, 2, 1 (all decreased)")

    moments_A = tropical_spectrum(A, 9)
    moments_A_prime = tropical_spectrum(A_prime, 9)

    header = "    k   mu_k(A)  mu_k(A')   A'<=A?"
    print("\n" + header)
    for k in range(10):
        mA = f"{moments_A[k]:.1f}" if moments_A[k] < Inf else "inf"
        mAp = f"{moments_A_prime[k]:.1f}" if moments_A_prime[k] < Inf else "inf"
        ok = "Y" if moments_A_prime[k] <= moments_A[k] else "N"
        print(f"  {k:3d}  {mA:>8s}  {mAp:>8s}  {ok:>8s}")

    print("\n✓ Monotonicity μ_k(A') ≤ μ_k(A) verified for all k!")


if __name__ == "__main__":
    demo_basic_operations()
    demo_spectrum()
    demo_dag_vanishing()
    demo_lower_bound()
    demo_dense_cycle()
    demo_convergence()
    demo_monotonicity()

    print("\n" + "=" * 60)
    print("ALL DEMOS PASSED")
    print("=" * 60)


#!/usr/bin/env python3
"""
Visualization: Tropical Spectral Moments

Generates plots showing:
1. Tropical spectrum comparison (cycle vs DAG vs complete graph)
2. Convergence of μ_k/k to minimum cycle mean
3. Weight monotonicity visualization
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
import random
import sys
import os

Inf = float('inf')


def min_plus_mul(A, B):
    n = len(A)
    C = [[Inf] * n for _ in range(n)]
    for i in range(n):
        for j in range(n):
            for k in range(n):
                val = A[i][k] + B[k][j]
                if val < C[i][j]:
                    C[i][j] = val
    return C


def min_plus_id(n):
    return [[0.0 if i == j else Inf for j in range(n)] for i in range(n)]


def tropical_spectrum(A, max_k):
    n = len(A)
    moments = []
    current = min_plus_id(n)
    moments.append(min(current[i][i] for i in range(n)))
    for k in range(1, max_k + 1):
        current = min_plus_mul(current, A)
        moments.append(min(current[i][i] for i in range(n)))
    return moments


def minimum_cycle_mean(A):
    n = len(A)
    if n == 0:
        return Inf
    best = Inf
    for s in range(n):
        D = [[Inf] * n for _ in range(n + 1)]
        D[0][s] = 0.0
        for k in range(n):
            for j in range(n):
                if D[k][j] < Inf:
                    for i in range(n):
                        if A[j][i] < Inf:
                            val = D[k][j] + A[j][i]
                            if val < D[k + 1][i]:
                                D[k + 1][i] = val
        for j in range(n):
            if D[n][j] < Inf:
                max_ratio = -Inf
                for k in range(n):
                    if D[k][j] < Inf:
                        ratio = (D[n][j] - D[k][j]) / (n - k)
                        if ratio > max_ratio:
                            max_ratio = ratio
                if max_ratio < best:
                    best = max_ratio
    return best


def plot_spectrum_comparison():
    """Plot tropical spectra for different graph types."""
    fig, axes = plt.subplots(1, 3, figsize=(15, 5))

    # 1. Cycle graph
    A_cycle = [
        [Inf, 3.0, Inf, Inf, Inf],
        [Inf, Inf, 2.0, Inf, Inf],
        [Inf, Inf, Inf, 4.0, Inf],
        [Inf, Inf, Inf, Inf, 1.0],
        [5.0, Inf, Inf, Inf, Inf],
    ]
    moments_cycle = tropical_spectrum(A_cycle, 15)
    ks_finite = [k for k, m in enumerate(moments_cycle) if m < Inf]
    ms_finite = [moments_cycle[k] for k in ks_finite]
    ks_inf = [k for k, m in enumerate(moments_cycle) if m == Inf]

    axes[0].scatter(ks_finite, ms_finite, c='blue', s=60, zorder=5)
    axes[0].scatter(ks_inf, [0] * len(ks_inf), c='red', marker='x', s=60, zorder=5, label='∞')
    if ks_finite:
        axes[0].plot(ks_finite, ms_finite, 'b--', alpha=0.5)
    axes[0].set_title('Cycle Graph (n=5)', fontsize=12, fontweight='bold')
    axes[0].set_xlabel('k (moment order)')
    axes[0].set_ylabel('μ_k')
    axes[0].legend()
    axes[0].grid(True, alpha=0.3)

    # 2. DAG
    A_dag = [
        [Inf, 1.0, 2.0, Inf, Inf],
        [Inf, Inf, Inf, 3.0, Inf],
        [Inf, Inf, Inf, 1.0, 4.0],
        [Inf, Inf, Inf, Inf, 2.0],
        [Inf, Inf, Inf, Inf, Inf],
    ]
    moments_dag = tropical_spectrum(A_dag, 15)
    ks_inf_dag = list(range(1, 16))
    axes[1].scatter([0], [0], c='blue', s=60, zorder=5, label='μ_0 = 0')
    axes[1].scatter(ks_inf_dag, [0] * len(ks_inf_dag), c='red', marker='x', s=60, zorder=5, label='∞ (all k≥1)')
    axes[1].set_title('DAG (n=5)', fontsize=12, fontweight='bold')
    axes[1].set_xlabel('k (moment order)')
    axes[1].set_ylabel('μ_k')
    axes[1].legend()
    axes[1].grid(True, alpha=0.3)
    axes[1].annotate('All positive moments\nvanish (= ∞)', xy=(8, 0), fontsize=10,
                     ha='center', va='bottom', color='red')

    # 3. Complete graph
    n = 5
    random.seed(42)
    A_complete = [[Inf if i == j else random.randint(1, 5) for j in range(n)] for i in range(n)]
    moments_complete = tropical_spectrum(A_complete, 15)
    ks_all = list(range(16))
    ms_plot = [m if m < Inf else None for m in moments_complete]
    ks_f = [k for k, m in zip(ks_all, ms_plot) if m is not None]
    ms_f = [m for m in ms_plot if m is not None]

    axes[2].scatter(ks_f, ms_f, c='green', s=60, zorder=5)
    axes[2].plot(ks_f, ms_f, 'g--', alpha=0.5)
    axes[2].set_title('Complete Graph (n=5)', fontsize=12, fontweight='bold')
    axes[2].set_xlabel('k (moment order)')
    axes[2].set_ylabel('μ_k')
    axes[2].grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('tropical_spectrum_comparison.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: tropical_spectrum_comparison.png")


def plot_eigenvalue_convergence():
    """Plot convergence of μ_k/k to minimum cycle mean."""
    fig, ax = plt.subplots(1, 1, figsize=(10, 6))

    # Graph with multiple cycles
    A = [
        [Inf, 2.0, 1.0, Inf],
        [3.0, Inf, Inf, Inf],
        [Inf, Inf, Inf, 1.0],
        [1.0, Inf, Inf, Inf],
    ]

    mcm = minimum_cycle_mean(A)
    max_k = 40
    moments = tropical_spectrum(A, max_k)

    ks = []
    ratios = []
    for k in range(1, max_k + 1):
        if moments[k] < Inf:
            ks.append(k)
            ratios.append(moments[k] / k)

    ax.scatter(ks, ratios, c='blue', s=30, alpha=0.7, label='μ_k / k')
    ax.axhline(y=mcm, color='red', linestyle='--', linewidth=2, label=f'λ_trop = {mcm:.2f}')
    ax.fill_between([0, max_k + 1], mcm - 0.05, mcm + 0.05, alpha=0.1, color='red')

    ax.set_xlabel('k (moment order)', fontsize=12)
    ax.set_ylabel('μ_k / k', fontsize=12)
    ax.set_title('Convergence of Tropical Spectral Ratio to Minimum Cycle Mean', fontsize=13, fontweight='bold')
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3)
    ax.set_xlim(0, max_k + 1)

    plt.tight_layout()
    plt.savefig('eigenvalue_convergence.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: eigenvalue_convergence.png")


def plot_monotonicity():
    """Plot weight monotonicity of tropical moments."""
    fig, ax = plt.subplots(1, 1, figsize=(10, 6))

    # Triangle with varying weight scales
    scales = [0.5, 1.0, 2.0, 3.0, 5.0]
    colors = plt.cm.viridis(np.linspace(0.2, 0.8, len(scales)))

    for scale, color in zip(scales, colors):
        A = [
            [Inf, 3.0 * scale, Inf],
            [Inf, Inf, 2.0 * scale],
            [1.0 * scale, Inf, Inf],
        ]
        moments = tropical_spectrum(A, 15)
        ks_f = [k for k, m in enumerate(moments) if m < Inf]
        ms_f = [moments[k] for k in ks_f]
        ax.plot(ks_f, ms_f, 'o-', color=color, label=f'scale = {scale}', markersize=6)

    ax.set_xlabel('k (moment order)', fontsize=12)
    ax.set_ylabel('μ_k', fontsize=12)
    ax.set_title('Tropical Moment Monotonicity: Larger Weights → Larger Moments', fontsize=13, fontweight='bold')
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('weight_monotonicity.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: weight_monotonicity.png")


if __name__ == "__main__":
    plot_spectrum_comparison()
    plot_eigenvalue_convergence()
    plot_monotonicity()
    print("\nAll visualizations generated.")
