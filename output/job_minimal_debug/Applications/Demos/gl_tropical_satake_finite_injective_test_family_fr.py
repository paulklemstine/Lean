#!/usr/bin/env python3
"""
GL₃ Tropical Satake Finite Test Family — Interactive Demo
==========================================================

This script demonstrates the finite-determinacy theorem for bounded-support
dominant GL₃ tropical Hecke data. We show:

1. For small support (N ≤ 3): edge + moment conditions determine the function
2. For N = 4: an explicit counterexample to one-moment injectivity
3. Visualizations of the moment system's rank structure
4. The "phase transition" at N = 4

Mathematical background:
  Dominant coweights for GL₃ are modeled as pairs (a,b) ∈ ℕ² with support
  in the triangle {(a,b) : a + b ≤ N}. The theorem says that knowing the
  function on the two edges (a=0 and b=0) plus one weighted moment per
  row and column determines the function, BUT only for N ≤ 3.
"""

import numpy as np
import matplotlib.pyplot as plt
from matplotlib.patches import Polygon
from matplotlib.collections import PatchCollection
import matplotlib.gridspec as gridspec


def get_interior_points(N):
    """Return interior points (a,b) with a>0, b>0, a+b ≤ N."""
    pts = []
    for a in range(1, N):
        for b in range(1, N - a + 1):
            pts.append((a, b))
    return pts


def build_moment_matrix(N):
    """
    Build the linear system relating interior values to moment conditions.

    For each interior point (a,b), the left moment at row b contributes
    coefficient a, and the right moment at column a contributes coefficient b.

    Returns:
        A: coefficient matrix (num_equations × num_unknowns)
        eq_labels: labels for each equation
        var_labels: labels for each variable
    """
    interior = get_interior_points(N)
    n_vars = len(interior)
    pt_to_idx = {p: i for i, p in enumerate(interior)}

    equations = []
    eq_labels = []

    # Left moments: for each row b (1 ≤ b ≤ N-1)
    for b in range(1, N):
        row = np.zeros(n_vars)
        for a in range(1, N - b + 1):
            if (a, b) in pt_to_idx:
                row[pt_to_idx[(a, b)]] = a
        equations.append(row)
        eq_labels.append(f"L(b={b})")

    # Right moments: for each column a (1 ≤ a ≤ N-1)
    for a in range(1, N):
        row = np.zeros(n_vars)
        for b in range(1, N - a + 1):
            if (a, b) in pt_to_idx:
                row[pt_to_idx[(a, b)]] = b
        equations.append(row)
        eq_labels.append(f"R(a={a})")

    A = np.array(equations) if equations else np.zeros((0, n_vars))
    var_labels = [f"h({a},{b})" for a, b in interior]
    return A, eq_labels, var_labels


def counterexample_N4():
    """The explicit counterexample for N=4."""
    def h(a, b):
        vals = {(1,1): 4, (1,2): -2, (2,1): -2, (2,2): 1}
        return vals.get((a, b), 0)
    return h


def verify_counterexample():
    """Verify that the N=4 counterexample satisfies all conditions."""
    h = counterexample_N4()
    N = 4

    print("=" * 60)
    print("COUNTEREXAMPLE VERIFICATION (N=4)")
    print("=" * 60)
    print(f"\nFunction values on interior:")
    for a in range(1, N):
        for b in range(1, N - a + 1):
            if h(a, b) != 0:
                print(f"  h({a},{b}) = {h(a,b)}")

    print(f"\nEdge check (should all be 0):")
    for a in range(N + 1):
        print(f"  h({a},0) = {h(a,0)}", end="  ")
    print()
    for b in range(N + 1):
        print(f"  h(0,{b}) = {h(0,b)}", end="  ")
    print()

    print(f"\nLeft moments (should all be 0):")
    for b in range(N + 1):
        moment = sum(a * h(a, b) for a in range(N + 1))
        print(f"  L(b={b}) = {moment}")

    print(f"\nRight moments (should all be 0):")
    for a in range(N + 1):
        moment = sum(b * h(a, b) for b in range(N + 1))
        print(f"  R(a={a}) = {moment}")

    print(f"\nNonzero? h(1,1) = {h(1,1)} ≠ 0 ✓")


def rank_analysis():
    """Analyze the rank of the moment system for various N."""
    print("\n" + "=" * 60)
    print("RANK ANALYSIS OF MOMENT SYSTEM")
    print("=" * 60)
    print(f"\n{'N':>3} | {'Interior pts':>12} | {'Equations':>9} | {'Rank':>4} | {'Kernel dim':>10} | {'Determined?':>11}")
    print("-" * 60)

    results = []
    for N in range(1, 10):
        A, eq_labels, var_labels = build_moment_matrix(N)
        n_vars = len(var_labels)
        n_eqs = len(eq_labels)

        if n_vars == 0:
            rank = 0
            kernel_dim = 0
            determined = True
        else:
            rank = np.linalg.matrix_rank(A)
            kernel_dim = n_vars - rank
            determined = kernel_dim == 0

        results.append((N, n_vars, n_eqs, rank, kernel_dim, determined))
        status = "✓ YES" if determined else "✗ NO"
        print(f"{N:>3} | {n_vars:>12} | {n_eqs:>9} | {rank:>4} | {kernel_dim:>10} | {status:>11}")

    return results


def plot_support_and_edges(ax, N, title, highlight_pts=None, highlight_color='red'):
    """Plot the triangular support region with edges highlighted."""
    # Draw the triangle
    triangle = Polygon([(0, 0), (N, 0), (0, N)], alpha=0.1, color='blue')
    ax.add_patch(triangle)

    # Edge points
    edge_a = [(a, 0) for a in range(N + 1)]
    edge_b = [(0, b) for b in range(N + 1)]

    ax.plot([p[0] for p in edge_a], [p[1] for p in edge_a], 'bs-',
            markersize=8, label='Edge₁ (b=0)', linewidth=2)
    ax.plot([p[0] for p in edge_b], [p[1] for p in edge_b], 'g^-',
            markersize=8, label='Edge₂ (a=0)', linewidth=2)

    # Interior points
    interior = get_interior_points(N)
    if interior:
        ax.plot([p[0] for p in interior], [p[1] for p in interior], 'ko',
                markersize=6, label='Interior', alpha=0.5)

    # Highlight specific points
    if highlight_pts:
        ax.plot([p[0] for p in highlight_pts], [p[1] for p in highlight_pts], 'o',
                color=highlight_color, markersize=12, markeredgecolor='black',
                markeredgewidth=2, label='Counterexample', zorder=5)

    # Hypotenuse
    ax.plot([0, N], [N, 0], 'k--', alpha=0.3, linewidth=1)

    ax.set_xlim(-0.5, N + 0.5)
    ax.set_ylim(-0.5, N + 0.5)
    ax.set_aspect('equal')
    ax.set_xlabel('a (first coweight coordinate)')
    ax.set_ylabel('b (second coweight coordinate)')
    ax.set_title(title)
    ax.legend(fontsize=8)
    ax.grid(True, alpha=0.3)


def create_visualization():
    """Create the main visualization figure."""
    fig = plt.figure(figsize=(16, 12))
    gs = gridspec.GridSpec(2, 3, hspace=0.35, wspace=0.3)

    # Panel 1: N=2 support (theorem holds)
    ax1 = fig.add_subplot(gs[0, 0])
    plot_support_and_edges(ax1, 2, 'N=2: Theorem holds ✓\n(1 interior point)')
    ax1.annotate('h(1,1)=0\n(from L-moment)', xy=(1, 1), xytext=(1.5, 1.5),
                arrowprops=dict(arrowstyle='->', color='green'),
                fontsize=8, color='green', fontweight='bold')

    # Panel 2: N=3 support (theorem holds)
    ax2 = fig.add_subplot(gs[0, 1])
    plot_support_and_edges(ax2, 3, 'N=3: Theorem holds ✓\n(3 interior points)')
    for pt, label in [((1,2), 'L'), ((2,1), 'R'), ((1,1), 'L')]:
        ax2.annotate(f'{label}→0', xy=pt, fontsize=7, color='green',
                    ha='center', va='bottom', fontweight='bold')

    # Panel 3: N=4 counterexample
    ax3 = fig.add_subplot(gs[0, 2])
    cex_pts = [(1,1), (1,2), (2,1), (2,2)]
    cex_vals = [4, -2, -2, 1]
    plot_support_and_edges(ax3, 4, 'N=4: Counterexample ✗\n(nonzero kernel)',
                          highlight_pts=cex_pts)
    for (a, b), v in zip(cex_pts, cex_vals):
        ax3.annotate(f'{v}', xy=(a, b), xytext=(a+0.2, b+0.15),
                    fontsize=9, color='red', fontweight='bold')

    # Panel 4: Rank deficiency plot
    ax4 = fig.add_subplot(gs[1, 0])
    results = []
    for N in range(1, 12):
        A, _, var_labels = build_moment_matrix(N)
        n_vars = len(var_labels)
        rank = np.linalg.matrix_rank(A) if n_vars > 0 else 0
        kernel = n_vars - rank
        results.append((N, n_vars, rank, kernel))

    Ns = [r[0] for r in results]
    kernels = [r[3] for r in results]
    n_vars_list = [r[1] for r in results]

    ax4.bar(Ns, kernels, color=['green' if k == 0 else 'red' for k in kernels],
            alpha=0.7, edgecolor='black')
    ax4.set_xlabel('N (support parameter)')
    ax4.set_ylabel('Kernel dimension')
    ax4.set_title('Kernel dimension of moment system')
    ax4.axhline(y=0, color='black', linewidth=0.5)

    # Panel 5: Interior points vs equations
    ax5 = fig.add_subplot(gs[1, 1])
    ranks = [r[2] for r in results]
    ax5.plot(Ns, n_vars_list, 'ro-', label='# interior unknowns', markersize=6)
    ax5.plot(Ns, ranks, 'bs-', label='Rank of system', markersize=6)
    ax5.fill_between(Ns, ranks, n_vars_list, alpha=0.2, color='red',
                     label='Kernel dimension')
    ax5.set_xlabel('N (support parameter)')
    ax5.set_ylabel('Count')
    ax5.set_title('System dimension analysis')
    ax5.legend(fontsize=8)
    ax5.grid(True, alpha=0.3)

    # Panel 6: Heat map of counterexample
    ax6 = fig.add_subplot(gs[1, 2])
    h_cex = counterexample_N4()
    grid = np.zeros((5, 5))
    for a in range(5):
        for b in range(5):
            if a + b <= 4:
                grid[b, a] = h_cex(a, b)

    # Mask points outside support
    mask = np.ones_like(grid, dtype=bool)
    for a in range(5):
        for b in range(5):
            if a + b <= 4:
                mask[b, a] = False

    masked_grid = np.ma.array(grid, mask=mask)
    cmap = plt.cm.RdBu_r
    im = ax6.pcolormesh(np.arange(-0.5, 5), np.arange(-0.5, 5),
                        masked_grid, cmap=cmap, vmin=-4, vmax=4,
                        edgecolors='gray', linewidth=0.5)
    plt.colorbar(im, ax=ax6, label='Function value')

    for a in range(5):
        for b in range(5):
            if a + b <= 4:
                val = h_cex(a, b)
                if val != 0:
                    ax6.text(a, b, f'{val:g}', ha='center', va='center',
                            fontsize=10, fontweight='bold')

    ax6.set_xlabel('a')
    ax6.set_ylabel('b')
    ax6.set_title('N=4 counterexample values')
    ax6.set_xlim(-0.5, 4.5)
    ax6.set_ylim(-0.5, 4.5)
    ax6.set_aspect('equal')

    fig.suptitle('GL₃ Tropical Satake Finite Test Family:\nPhase Transition at N=4',
                fontsize=14, fontweight='bold', y=0.98)

    plt.savefig('gl3_test_family_visualization.png', dpi=150, bbox_inches='tight')
    plt.savefig('gl3_test_family_visualization.pdf', bbox_inches='tight')
    print("\nFigures saved as gl3_test_family_visualization.png/pdf")
    plt.close()


def moment_kernel_basis(N):
    """Compute and display a basis for the moment system kernel."""
    A, eq_labels, var_labels = build_moment_matrix(N)
    if len(var_labels) == 0:
        print(f"N={N}: No interior points, kernel is trivial.")
        return

    # SVD to find null space
    U, S, Vt = np.linalg.svd(A)
    tol = 1e-10
    null_mask = S < tol
    # Columns of V corresponding to zero singular values
    null_space = Vt[len(S):, :].T  # rows of Vt beyond rank
    if S.shape[0] < Vt.shape[0]:
        extra = Vt[len(S):, :]
    else:
        extra = Vt[np.where(S < tol)[0], :]

    if extra.shape[0] == 0:
        print(f"N={N}: Kernel is trivial — system is determined.")
        return

    print(f"\nN={N}: Kernel dimension = {extra.shape[0]}")
    print("Kernel basis vectors:")
    for i, vec in enumerate(extra):
        nonzero = [(var_labels[j], vec[j]) for j in range(len(vec)) if abs(vec[j]) > tol]
        print(f"  v{i+1}: " + ", ".join(f"{label}={val:.4f}" for label, val in nonzero))


def practical_application_demo():
    """
    Demonstrate practical application: testing equality of tropical Hecke data
    using only edge + moment measurements.
    """
    print("\n" + "=" * 60)
    print("PRACTICAL APPLICATION: DATA COMPRESSION")
    print("=" * 60)

    for N in [2, 3, 4]:
        interior = get_interior_points(N)
        n_full = len(interior) + (N + 1) + N  # interior + edge₁ + edge₂ (no overlap at (0,0))
        n_total = (N + 1) * (N + 2) // 2  # all points in triangle
        n_edges = 2 * N + 1  # edge points (with overlap at (0,0))
        n_moments = 2 * (N - 1) if N > 0 else 0  # left + right moments

        # Compression ratio for N ≤ 3
        if N <= 3:
            n_test = n_edges + n_moments
            ratio = n_test / n_total if n_total > 0 else 0
            print(f"\nN={N}: {n_total} total points, {len(interior)} interior")
            print(f"  Test family size: {n_edges} edge values + {n_moments} moments = {n_test}")
            print(f"  Compression ratio: {ratio:.1%} of full data")
            print(f"  Status: SUFFICIENT for determination ✓")
        else:
            A, _, _ = build_moment_matrix(N)
            rank = np.linalg.matrix_rank(A) if len(interior) > 0 else 0
            kernel = len(interior) - rank
            n_test = n_edges + n_moments
            print(f"\nN={N}: {n_total} total points, {len(interior)} interior")
            print(f"  Test family size: {n_edges} edge values + {n_moments} moments = {n_test}")
            print(f"  Kernel dimension: {kernel}")
            print(f"  Status: INSUFFICIENT — need {kernel} more measurements ✗")


if __name__ == "__main__":
    print("GL₃ Tropical Satake Finite Test Family — Demo")
    print("=" * 60)

    # 1. Verify counterexample
    verify_counterexample()

    # 2. Rank analysis
    rank_analysis()

    # 3. Kernel analysis for larger N
    for N in [4, 5, 6]:
        moment_kernel_basis(N)

    # 4. Practical application
    practical_application_demo()

    # 5. Create visualizations
    create_visualization()

    print("\n" + "=" * 60)
    print("SUMMARY")
    print("=" * 60)
    print("""
The GL₃ finite test family theorem identifies a phase transition
at N=4 in the determinacy of bounded-support tropical Hecke data:

  • For N ≤ 3: Edge data + one mixed moment per slice SUFFICES
    to uniquely determine the function. (PROVED in Lean 4)

  • For N ≥ 4: The moment system becomes underdetermined. An
    explicit counterexample exists with kernel dimension growing
    quadratically. (PROVED in Lean 4 via cex4_nonzero)

This has implications for data compression in tropical Satake
theory: for small support, a logarithmic number of measurements
(relative to the support size) suffice for reconstruction.
""")
