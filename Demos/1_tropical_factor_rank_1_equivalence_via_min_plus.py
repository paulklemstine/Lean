"""
Applications of Tropical Rank-One Theory

Demonstrates real-world applications of the tropical rank-1 equivalence theorem
in logistics, machine learning, and graph analysis.
"""

import numpy as np
from algorithms import rank_one_decompose, best_rank_one_approx_linf, delta2_matrix


def application_logistics():
    """
    Application 1: Separable Cost Recognition in Logistics
    
    A shipping company has warehouses and customers. We test whether the
    cost table decomposes as origin_cost + destination_cost, which enables
    independent pricing and massive simplification of the transport problem.
    """
    print("=" * 60)
    print("APPLICATION 1: Logistics — Separable Cost Detection")
    print("=" * 60)
    
    # Scenario A: Truly separable costs (zone-based pricing)
    warehouse_costs = np.array([10, 15, 8, 12, 20])  # loading cost per warehouse
    customer_costs = np.array([5, 12, 3, 8, 15, 7])   # delivery cost per customer
    
    cost_table = warehouse_costs[:, None] + customer_costs[None, :]
    
    print("\nScenario A: Zone-based pricing (should be separable)")
    print(f"Cost table ({cost_table.shape[0]} warehouses × {cost_table.shape[1]} customers):")
    print(cost_table)
    
    result = rank_one_decompose(cost_table.astype(float))
    if result:
        p, q = result
        print(f"✓ Separable! Origin costs: {p.astype(int)}, Destination costs: {q.astype(int)}")
    else:
        print("✗ Not separable")
    
    # Scenario B: Distance-dependent costs (not separable)
    np.random.seed(42)
    warehouse_pos = np.random.rand(4, 2) * 100
    customer_pos = np.random.rand(5, 2) * 100
    
    distance_costs = np.zeros((4, 5))
    for i in range(4):
        for j in range(5):
            distance_costs[i, j] = np.round(np.linalg.norm(warehouse_pos[i] - customer_pos[j]), 1)
    
    print(f"\nScenario B: Distance-based costs (should NOT be separable)")
    print(f"Cost table:")
    print(distance_costs)
    
    result = rank_one_decompose(distance_costs)
    if result:
        print("✓ Separable (surprising!)")
    else:
        print("✗ Not separable (as expected for distance-based costs)")
        p, q, err = best_rank_one_approx_linf(distance_costs)
        print(f"  Best rank-1 approximation error: {err:.2f}")
        print(f"  This measures the 'non-additive complexity' of the cost structure")


def application_ml_weight_analysis():
    """
    Application 2: Neural Network Weight Matrix Analysis
    
    Tropical rank measures the combinatorial complexity of piecewise-linear
    functions (ReLU networks). A weight matrix with tropical rank 1 means
    the associated linear map has trivially simple tropical geometry.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 2: Neural Network Weight Analysis")
    print("=" * 60)
    
    np.random.seed(123)
    
    # Rank-1 weight matrix: represents a simple additive bias structure
    bias_in = np.random.randn(8)
    bias_out = np.random.randn(6)
    W_simple = bias_in[:, None] + bias_out[None, :]
    
    print(f"\nSimple weight matrix (8×6, rank-1 by construction):")
    result = rank_one_decompose(W_simple)
    print(f"  Tropical rank 1: {result is not None}")
    D = delta2_matrix(W_simple)
    print(f"  Max curvature |δ₂|: {np.max(np.abs(D)):.2e}")
    
    # Generic weight matrix: high tropical rank
    W_generic = np.random.randn(8, 6)
    
    print(f"\nGeneric weight matrix (8×6, random):")
    result = rank_one_decompose(W_generic)
    print(f"  Tropical rank 1: {result is not None}")
    D = delta2_matrix(W_generic)
    print(f"  Max curvature |δ₂|: {np.max(np.abs(D)):.4f}")
    
    _, _, err = best_rank_one_approx_linf(W_generic)
    print(f"  Best rank-1 approximation error: {err:.4f}")
    print(f"  Fraction of ‖W‖∞ explained by rank-1: {1 - err/np.max(np.abs(W_generic)):.1%}")


def application_graph_potentials():
    """
    Application 3: Graph Potential Detection
    
    On a complete bipartite graph K_{n,m}, edge weights form a matrix.
    The minor condition detects whether the weights come from vertex potentials
    (a coboundary / exact 1-cocycle). This is the discrete Hodge theory
    application: H¹(K_{n,m}; ℝ) = 0.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 3: Graph Potential Detection (Discrete Hodge Theory)")
    print("=" * 60)
    
    # Scenario: Potential-derived edge weights
    n, m = 5, 4
    vertex_potentials_left = np.array([3.0, 1.0, 4.0, 1.0, 5.0])
    vertex_potentials_right = np.array([9.0, 2.0, 6.0, 5.0])
    
    # Edge weight = potential difference (coboundary)
    edge_weights = vertex_potentials_left[:, None] + vertex_potentials_right[None, :]
    
    print(f"\nBipartite graph K_{{{n},{m}}} with potential-derived edge weights:")
    print(edge_weights)
    
    result = rank_one_decompose(edge_weights)
    if result:
        p, q = result
        print(f"\n✓ Exact 1-cocycle detected!")
        print(f"  Left potentials:  {p}")
        print(f"  Right potentials: {q}")
        print(f"  Interpretation: H¹(K_{{{n},{m}}}; ℝ) = 0 — every cocycle is exact")
    
    # Scenario: Non-potential edge weights (contains "curvature")
    print(f"\nAdding curvature (non-exact perturbation):")
    perturbation = np.zeros((n, m))
    perturbation[1, 2] = 0.5  # Local curvature defect
    perturbation[3, 0] = -0.3
    
    curved_weights = edge_weights + perturbation
    result = rank_one_decompose(curved_weights)
    if result is None:
        D = delta2_matrix(curved_weights)
        max_curv = np.max(np.abs(D))
        print(f"  ✗ Non-exact 1-cocycle (has curvature)")
        print(f"  Max discrete curvature |δ₂|: {max_curv:.4f}")
        print(f"  Interpretation: irreducible loop structure detected in cost network")


def application_dynamic_programming():
    """
    Application 4: DP Decomposition Certificate
    
    When a cost table in a dynamic programming problem is tropically rank-1,
    the DP decomposes into independent subproblems. The minor condition
    provides a checkable certificate for this decomposition.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 4: Dynamic Programming Decomposition")
    print("=" * 60)
    
    # Assignment cost for tasks (rows) to machines (columns)
    # If separable: task difficulty + machine inefficiency = total cost
    task_difficulty = np.array([2, 5, 1, 8, 3])
    machine_overhead = np.array([10, 7, 12, 9])
    
    cost = task_difficulty[:, None] + machine_overhead[None, :]
    
    print(f"\nTask-machine assignment costs (5 tasks × 4 machines):")
    print(cost)
    
    result = rank_one_decompose(cost.astype(float))
    if result:
        p, q = result
        print(f"\n✓ SEPARABLE — DP decomposes!")
        print(f"  Task difficulties: {p.astype(int)}")
        print(f"  Machine overheads: {q.astype(int)}")
        print(f"  Optimal assignment: assign each task to the cheapest machine (col {np.argmin(q)})")
        print(f"  Total cost = sum(task_difficulties) + {len(task_difficulty)} × min(machine_overheads)")
        total = np.sum(task_difficulty) + len(task_difficulty) * np.min(machine_overhead)
        print(f"           = {np.sum(task_difficulty)} + {len(task_difficulty)} × {np.min(machine_overhead)} = {total}")
    
    # Non-separable: some task-machine pairs have special synergies
    print(f"\nAdding task-machine synergies (breaks separability):")
    synergy = np.zeros_like(cost, dtype=float)
    synergy[0, 1] = -3  # Task 0 is faster on machine 1
    synergy[2, 3] = -5  # Task 2 is faster on machine 3
    
    cost_synergy = cost.astype(float) + synergy
    result = rank_one_decompose(cost_synergy)
    if result is None:
        print(f"  ✗ Not separable — genuine combinatorial optimization needed")
        _, _, err = best_rank_one_approx_linf(cost_synergy)
        print(f"  Approximation error from ignoring synergies: {err:.1f}")


if __name__ == "__main__":
    application_logistics()
    application_ml_weight_analysis()
    application_graph_potentials()
    application_dynamic_programming()


"""
Tropical Rank-One Factorization: Demonstrations and Verification

This script demonstrates the core theorems connecting min-plus rank-1 factorization,
additive separability, and tropical 2x2 minor vanishing.
"""

import numpy as np
from typing import Optional, Tuple


def is_rank_one(A: np.ndarray, tol: float = 1e-10) -> Tuple[bool, Optional[Tuple[np.ndarray, np.ndarray]]]:
    """
    Test whether a matrix A is tropically rank-1 (additively separable).
    
    Uses the basepoint reconstruction theorem: pick base row 0, base column 0,
    define p[i] = A[i,0] and q[j] = A[0,j] - A[0,0], then check A[i,j] == p[i] + q[j].
    
    Returns (is_rank_one, (p, q) or None).
    """
    n, m = A.shape
    if n == 0 or m == 0:
        return True, (np.zeros(n), np.zeros(m))
    
    p = A[:, 0].copy()
    q = A[0, :] - A[0, 0]
    
    reconstructed = p[:, None] + q[None, :]
    if np.allclose(A, reconstructed, atol=tol):
        return True, (p, q)
    return False, None


def max_minor_defect(A: np.ndarray) -> float:
    """
    Compute the maximum |delta_2(A)| over all 2x2 submatrices.
    
    delta_2(A)(i,i',j,j') = A[i,j] + A[i',j'] - A[i,j'] - A[i',j]
    """
    n, m = A.shape
    max_def = 0.0
    for i in range(n):
        for i2 in range(i + 1, n):
            for j in range(m):
                for j2 in range(j + 1, m):
                    d = abs(A[i, j] + A[i2, j2] - A[i, j2] - A[i2, j])
                    max_def = max(max_def, d)
    return max_def


def generate_rank_one(n: int, m: int, seed: int = 42) -> Tuple[np.ndarray, np.ndarray, np.ndarray]:
    """Generate a random rank-1 matrix A[i,j] = p[i] + q[j]."""
    rng = np.random.RandomState(seed)
    p = rng.randn(n) * 3
    q = rng.randn(m) * 3
    A = p[:, None] + q[None, :]
    return A, p, q


def demo_exact_rank_one():
    """Demonstrate exact rank-1 recognition and gauge uniqueness."""
    print("=" * 60)
    print("DEMO 1: Exact Rank-1 Recognition")
    print("=" * 60)
    
    n, m = 5, 4
    A, p_orig, q_orig = generate_rank_one(n, m)
    
    print(f"\nGenerated {n}x{m} rank-1 matrix A[i,j] = p[i] + q[j]")
    print(f"Original p = {np.round(p_orig, 4)}")
    print(f"Original q = {np.round(q_orig, 4)}")
    print(f"\nA =\n{np.round(A, 4)}")
    
    is_r1, decomp = is_rank_one(A)
    print(f"\nRank-1 test: {is_r1}")
    
    if decomp:
        p_rec, q_rec = decomp
        print(f"Reconstructed p = {np.round(p_rec, 4)}")
        print(f"Reconstructed q = {np.round(q_rec, 4)}")
        
        # Verify gauge uniqueness: p' = p + c, q' = q - c
        c = p_rec[0] - p_orig[0]
        print(f"\nGauge constant c = {c:.6f}")
        print(f"p_rec - p_orig = {np.round(p_rec - p_orig, 10)} (should be constant {c:.6f})")
        print(f"q_rec - q_orig = {np.round(q_rec - q_orig, 10)} (should be constant {-c:.6f})")
    
    print(f"\nMax minor defect: {max_minor_defect(A):.2e} (should be ~0)")


def demo_non_rank_one():
    """Demonstrate detection of non-rank-1 matrices."""
    print("\n" + "=" * 60)
    print("DEMO 2: Non-Rank-1 Matrix Detection")
    print("=" * 60)
    
    A = np.array([
        [0.0, 1.0, 3.0],
        [2.0, 4.0, 5.0],
        [1.0, 2.0, 6.0]
    ])
    
    print(f"\nA =\n{A}")
    is_r1, _ = is_rank_one(A)
    print(f"Rank-1 test: {is_r1}")
    print(f"Max minor defect: {max_minor_defect(A):.4f}")
    
    # Find a violating rectangle
    n, m = A.shape
    for i in range(n):
        for i2 in range(i + 1, n):
            for j in range(m):
                for j2 in range(j + 1, m):
                    d = A[i, j] + A[i2, j2] - A[i, j2] - A[i2, j]
                    if abs(d) > 1e-10:
                        print(f"\nViolating rectangle: rows ({i},{i2}), cols ({j},{j2})")
                        print(f"  A[{i},{j}] + A[{i2},{j2}] = {A[i,j]} + {A[i2,j2]} = {A[i,j]+A[i2,j2]}")
                        print(f"  A[{i},{j2}] + A[{i2},{j}] = {A[i,j2]} + {A[i2,j]} = {A[i,j2]+A[i2,j]}")
                        print(f"  Defect delta_2 = {d}")
                        break


def demo_perturbation():
    """Demonstrate stability: small perturbation → small minor defect."""
    print("\n" + "=" * 60)
    print("DEMO 3: Perturbation Stability")
    print("=" * 60)
    
    n, m = 6, 6
    A_base, _, _ = generate_rank_one(n, m, seed=123)
    
    print(f"\n{'Perturbation ε':>20} {'Max |δ₂|':>15} {'Ratio |δ₂|/ε':>15}")
    print("-" * 52)
    
    for eps in [0.001, 0.01, 0.1, 0.5, 1.0, 2.0]:
        rng = np.random.RandomState(999)
        noise = rng.uniform(-eps, eps, (n, m))
        A_noisy = A_base + noise
        defect = max_minor_defect(A_noisy)
        ratio = defect / eps if eps > 0 else 0
        print(f"{eps:>20.3f} {defect:>15.6f} {ratio:>15.4f}")
    
    print("\n(Ratio should be bounded by 4, per the Lipschitz bound |δ₂(E)| ≤ 4‖E‖∞)")


def demo_minplus_maxplus_duality():
    """Demonstrate that min-plus and max-plus rank agree at rank 1."""
    print("\n" + "=" * 60)
    print("DEMO 4: Min-Plus / Max-Plus Duality at Rank 1")
    print("=" * 60)
    
    A, p, q = generate_rank_one(4, 5, seed=77)
    neg_A = -A
    
    print(f"\nA is rank-1: {is_rank_one(A)[0]}")
    print(f"-A is rank-1: {is_rank_one(neg_A)[0]}")
    print(f"\nSince min-plus rank 1 ↔ additive separability ↔ max-plus rank 1,")
    print(f"negating preserves the rank-1 property.")
    print(f"\nA minor defect: {max_minor_defect(A):.2e}")
    print(f"-A minor defect: {max_minor_defect(neg_A):.2e}")


def demo_row_difference_invariance():
    """Demonstrate that rank-1 implies row differences are column-independent."""
    print("\n" + "=" * 60)
    print("DEMO 5: Row-Difference Invariance")
    print("=" * 60)
    
    A, _, _ = generate_rank_one(4, 5, seed=55)
    
    print(f"\nRank-1 matrix A:")
    print(np.round(A, 4))
    
    print(f"\nRow differences A[0,:] - A[1,:] (should be constant):")
    diffs = A[0, :] - A[1, :]
    print(np.round(diffs, 10))
    print(f"Std dev: {np.std(diffs):.2e}")
    
    print(f"\nRow differences A[2,:] - A[3,:] (should be constant):")
    diffs = A[2, :] - A[3, :]
    print(np.round(diffs, 10))
    print(f"Std dev: {np.std(diffs):.2e}")


if __name__ == "__main__":
    demo_exact_rank_one()
    demo_non_rank_one()
    demo_perturbation()
    demo_minplus_maxplus_duality()
    demo_row_difference_invariance()


"""
Generate visualizations for Tropical Rank-One Theory.
Saves figures as PNG files encoded in base64 for JSON packaging.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import base64
import io
import json


def fig_to_base64(fig):
    """Convert matplotlib figure to base64-encoded PNG data URI."""
    buf = io.BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight')
    buf.seek(0)
    b64 = base64.b64encode(buf.read()).decode('utf-8')
    plt.close(fig)
    return f"data:image/png;base64,{b64}"


def viz_rank_one_matrix():
    """Visualize a rank-1 matrix and its decomposition."""
    p = np.array([1, 3, -2, 0.5, 2.5])
    q = np.array([2, -1, 4, 0, 3.5, -0.5])
    A = p[:, None] + q[None, :]
    
    fig, axes = plt.subplots(1, 4, figsize=(16, 4), gridspec_kw={'width_ratios': [6, 1, 1, 6]})
    
    im = axes[0].imshow(A, cmap='RdYlBu_r', aspect='auto')
    axes[0].set_title('A (rank-1 matrix)', fontsize=13)
    axes[0].set_xlabel('Column j')
    axes[0].set_ylabel('Row i')
    for i in range(5):
        for j in range(6):
            axes[0].text(j, i, f'{A[i,j]:.1f}', ha='center', va='center', fontsize=9)
    plt.colorbar(im, ax=axes[0], shrink=0.8)
    
    axes[1].barh(range(5), p, color='steelblue', height=0.6)
    axes[1].set_title('p(i)', fontsize=13)
    axes[1].set_yticks(range(5))
    axes[1].invert_yaxis()
    
    axes[2].bar(range(6), q, color='coral', width=0.6)
    axes[2].set_title('q(j)', fontsize=13)
    axes[2].set_xticks(range(6))
    
    reconstructed = p[:, None] + q[None, :]
    axes[3].imshow(reconstructed, cmap='RdYlBu_r', aspect='auto')
    axes[3].set_title('p(i) + q(j) = A', fontsize=13)
    axes[3].set_xlabel('Column j')
    for i in range(5):
        for j in range(6):
            axes[3].text(j, i, f'{reconstructed[i,j]:.1f}', ha='center', va='center', fontsize=9)
    
    fig.suptitle('Tropical Rank-1 Decomposition: A(i,j) = p(i) + q(j)', fontsize=15, y=1.02)
    plt.tight_layout()
    return fig_to_base64(fig)


def viz_curvature_heatmap():
    """Visualize the discrete curvature (delta_2) for rank-1 vs non-rank-1 matrices."""
    fig, axes = plt.subplots(1, 2, figsize=(14, 5))
    
    # Rank-1 matrix: zero curvature
    p = np.array([1, 3, -2, 0.5])
    q = np.array([2, -1, 4, 0])
    A = p[:, None] + q[None, :]
    
    n, m = A.shape
    D1 = np.zeros((n*(n-1)//2, m*(m-1)//2))
    row_labels, col_labels = [], []
    ri = 0
    for i in range(n):
        for i2 in range(i+1, n):
            ci = 0
            for j in range(m):
                for j2 in range(j+1, m):
                    D1[ri, ci] = A[i,j] + A[i2,j2] - A[i,j2] - A[i2,j]
                    if ri == 0:
                        col_labels.append(f'({j},{j2})')
                    ci += 1
            row_labels.append(f'({i},{i2})')
            ri += 1
    
    im1 = axes[0].imshow(D1, cmap='RdBu_r', vmin=-3, vmax=3, aspect='auto')
    axes[0].set_title('δ₂ for Rank-1 Matrix\n(all zeros = flat)', fontsize=12)
    axes[0].set_ylabel('Row pairs (i, i\')')
    axes[0].set_xlabel('Column pairs (j, j\')')
    axes[0].set_yticks(range(len(row_labels)))
    axes[0].set_yticklabels(row_labels, fontsize=8)
    axes[0].set_xticks(range(len(col_labels)))
    axes[0].set_xticklabels(col_labels, fontsize=8)
    for r in range(D1.shape[0]):
        for c in range(D1.shape[1]):
            axes[0].text(c, r, f'{D1[r,c]:.1f}', ha='center', va='center', fontsize=9)
    plt.colorbar(im1, ax=axes[0], shrink=0.8)
    
    # Non-rank-1 matrix: nonzero curvature
    B = np.array([[0, 1, 3, 2], [2, 4, 5, 3], [1, 2, 6, 4], [3, 3, 7, 8.0]])
    n, m = B.shape
    D2 = np.zeros((n*(n-1)//2, m*(m-1)//2))
    row_labels2, col_labels2 = [], []
    ri = 0
    for i in range(n):
        for i2 in range(i+1, n):
            ci = 0
            for j in range(m):
                for j2 in range(j+1, m):
                    D2[ri, ci] = B[i,j] + B[i2,j2] - B[i,j2] - B[i2,j]
                    if ri == 0:
                        col_labels2.append(f'({j},{j2})')
                    ci += 1
            row_labels2.append(f'({i},{i2})')
            ri += 1
    
    im2 = axes[1].imshow(D2, cmap='RdBu_r', vmin=-3, vmax=3, aspect='auto')
    axes[1].set_title('δ₂ for Non-Rank-1 Matrix\n(nonzero = curved)', fontsize=12)
    axes[1].set_ylabel('Row pairs (i, i\')')
    axes[1].set_xlabel('Column pairs (j, j\')')
    axes[1].set_yticks(range(len(row_labels2)))
    axes[1].set_yticklabels(row_labels2, fontsize=8)
    axes[1].set_xticks(range(len(col_labels2)))
    axes[1].set_xticklabels(col_labels2, fontsize=8)
    for r in range(D2.shape[0]):
        for c in range(D2.shape[1]):
            axes[1].text(c, r, f'{D2[r,c]:.1f}', ha='center', va='center', fontsize=9)
    plt.colorbar(im2, ax=axes[1], shrink=0.8)
    
    fig.suptitle('Discrete Curvature δ₂: Flatness vs. Curvature', fontsize=14, y=1.02)
    plt.tight_layout()
    return fig_to_base64(fig)


def viz_perturbation_stability():
    """Visualize how minor defects grow with perturbation magnitude."""
    np.random.seed(42)
    n, m = 8, 8
    p = np.random.randn(n) * 3
    q = np.random.randn(m) * 3
    A = p[:, None] + q[None, :]
    
    epsilons = np.logspace(-3, 1, 30)
    max_defects = []
    mean_defects = []
    
    for eps in epsilons:
        defects = []
        for _ in range(20):
            noise = np.random.uniform(-eps, eps, (n, m))
            B = A + noise
            max_d = 0
            for i in range(n):
                for i2 in range(i+1, n):
                    for j in range(m):
                        for j2 in range(j+1, m):
                            d = abs(B[i,j] + B[i2,j2] - B[i,j2] - B[i2,j])
                            max_d = max(max_d, d)
            defects.append(max_d)
        max_defects.append(np.max(defects))
        mean_defects.append(np.mean(defects))
    
    fig, ax = plt.subplots(figsize=(10, 6))
    ax.loglog(epsilons, max_defects, 'o-', color='crimson', label='Max |δ₂| (worst case)', markersize=4)
    ax.loglog(epsilons, mean_defects, 's-', color='steelblue', label='Mean |δ₂| (average)', markersize=4)
    ax.loglog(epsilons, 4 * epsilons, '--', color='gray', label='Theoretical bound 4ε', linewidth=2)
    ax.loglog(epsilons, 2 * epsilons, ':', color='gray', label='2ε reference', linewidth=1)
    ax.set_xlabel('Perturbation magnitude ε', fontsize=12)
    ax.set_ylabel('Minor defect |δ₂|', fontsize=12)
    ax.set_title('Stability: Minor Defects vs. Perturbation Size', fontsize=14)
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3)
    plt.tight_layout()
    return fig_to_base64(fig)


def viz_three_way_equivalence():
    """Conceptual diagram of the three-way equivalence."""
    fig, ax = plt.subplots(figsize=(10, 7))
    ax.set_xlim(-2, 12)
    ax.set_ylim(-1, 10)
    ax.set_aspect('equal')
    ax.axis('off')
    
    # Three nodes of the equivalence
    centers = [(5, 9), (1, 2), (9, 2)]
    labels = [
        'Min-Plus\nFactor Rank ≤ 1\nA(i,j) = U(i,0) + V(0,j)',
        'Additive\nSeparability\nA(i,j) = p(i) + q(j)',
        'Tropical 2×2\nMinor Vanishing\nA(i,j)+A(i\',j\') = A(i,j\')+A(i\',j)'
    ]
    colors = ['#4ECDC4', '#FF6B6B', '#45B7D1']
    
    for (x, y), label, color in zip(centers, labels, colors):
        circle = plt.Circle((x, y), 1.8, color=color, alpha=0.3, linewidth=2, edgecolor=color)
        ax.add_patch(circle)
        ax.text(x, y, label, ha='center', va='center', fontsize=9, fontweight='bold',
                bbox=dict(boxstyle='round,pad=0.3', facecolor='white', alpha=0.8))
    
    # Arrows between nodes
    arrow_style = dict(arrowstyle='<->', color='#2C3E50', lw=2.5,
                       connectionstyle='arc3,rad=0.1')
    
    ax.annotate('', xy=(2.5, 3.3), xytext=(3.5, 7.5),
                arrowprops=arrow_style)
    ax.annotate('', xy=(7.5, 3.3), xytext=(6.5, 7.5),
                arrowprops=arrow_style)
    ax.annotate('', xy=(3, 2), xytext=(7, 2),
                arrowprops=arrow_style)
    
    # Labels on arrows
    ax.text(2.3, 5.5, 'Thm 1', fontsize=10, fontweight='bold', color='#2C3E50',
            rotation=65, ha='center')
    ax.text(7.7, 5.5, 'Thm 3', fontsize=10, fontweight='bold', color='#2C3E50',
            rotation=-65, ha='center')
    ax.text(5, 1.3, 'Thm 2', fontsize=10, fontweight='bold', color='#2C3E50',
            ha='center')
    
    ax.set_title('Three-Way Equivalence: Tropical Rank-One Structure Theorem',
                 fontsize=14, fontweight='bold', pad=20)
    
    # Domain labels
    domains = [
        (5, -0.5, 'Tropical Linear Algebra ↔ Monge Geometry ↔ Discrete Potential Theory')
    ]
    for x, y, text in domains:
        ax.text(x, y, text, ha='center', va='center', fontsize=10, style='italic',
                color='#7F8C8D')
    
    plt.tight_layout()
    return fig_to_base64(fig)


if __name__ == "__main__":
    print("Generating visualizations...")
    
    results = {}
    
    print("  1. Rank-1 decomposition...")
    results['decomposition'] = viz_rank_one_matrix()
    
    print("  2. Curvature heatmap...")
    results['curvature'] = viz_curvature_heatmap()
    
    print("  3. Perturbation stability...")
    results['stability'] = viz_perturbation_stability()
    
    print("  4. Three-way equivalence diagram...")
    results['equivalence'] = viz_three_way_equivalence()
    
    # Save results for use by package generator
    with open('viz_data.json', 'w') as f:
        json.dump(results, f)
    
    print("Done! Visualizations saved to viz_data.json")
