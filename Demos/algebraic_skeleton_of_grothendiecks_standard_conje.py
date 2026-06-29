#!/usr/bin/env python3
"""
Demonstration of the Algebraic Skeleton of Grothendieck's Standard Conjectures.

This script demonstrates:
1. Künneth projector rank additivity
2. Lefschetz kernel filtration for nilpotent operators
3. Hodge index theorem signature computation
4. Weight purity characterization
5. Primitive rank bound conjecture testing
"""

import numpy as np
from algorithms import (
    compute_kunneth_ranks,
    verify_orthogonal_idempotent,
    lefschetz_filtration,
    hodge_signature,
    weight_filtration_analysis,
    projector_complement,
    verify_primitive_rank_bound,
    random_nilpotent_matrix,
    build_surface_intersection_form,
)


def demo_kunneth_projectors():
    """Demonstrate Künneth projector rank additivity."""
    print("=" * 60)
    print("DEMO 1: Künneth Projector Rank Additivity")
    print("=" * 60)
    print()

    # Model: cohomology of CP^2 (projective plane)
    # H*(CP^2) = H^0 ⊕ H^2 ⊕ H^4, Betti numbers (1, 0, 1, 0, 1)
    # Using 3-dimensional space with projectors to each 1-d subspace
    pi0 = np.array([[1, 0, 0], [0, 0, 0], [0, 0, 0]], dtype=float)
    pi2 = np.array([[0, 0, 0], [0, 1, 0], [0, 0, 0]], dtype=float)
    pi4 = np.array([[0, 0, 0], [0, 0, 0], [0, 0, 1]], dtype=float)

    projectors = [pi0, pi2, pi4]
    idem, ortho, complete = verify_orthogonal_idempotent(projectors)
    print(f"  Model: Cohomology of CP² (dimension 3)")
    print(f"  Idempotent: {idem}")
    print(f"  Orthogonal: {ortho}")
    print(f"  Complete:   {complete}")

    ranks, additivity = compute_kunneth_ranks(projectors)
    print(f"  Graded ranks: {ranks}")
    print(f"  Sum of ranks: {sum(ranks)}")
    print(f"  Total dimension: 3")
    print(f"  Rank additivity verified: {additivity}")
    print()

    # Model: cohomology of a K3 surface
    # H*(K3) has Betti numbers (1, 0, 22, 0, 1), total dim = 24
    n = 24
    projectors_k3 = []
    sizes = [1, 0, 22, 0, 1]
    offset = 0
    for s in sizes:
        pi = np.zeros((n, n))
        for i in range(s):
            pi[offset + i, offset + i] = 1.0
        projectors_k3.append(pi)
        offset += s

    ranks_k3, additivity_k3 = compute_kunneth_ranks(projectors_k3)
    print(f"  Model: Cohomology of K3 surface (dimension 24)")
    print(f"  Betti numbers: {ranks_k3}")
    print(f"  Rank additivity verified: {additivity_k3}")
    print()


def demo_lefschetz_filtration():
    """Demonstrate Lefschetz kernel filtration."""
    print("=" * 60)
    print("DEMO 2: Lefschetz Kernel Filtration")
    print("=" * 60)
    print()

    # Nilpotent operator of weight 3 on R^6
    # Models L acting on H*(X) for a 3-fold
    L = np.array([
        [0, 1, 0, 0, 0, 0],
        [0, 0, 1, 0, 0, 0],
        [0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 1, 0],
        [0, 0, 0, 0, 0, 1],
        [0, 0, 0, 0, 0, 0],
    ], dtype=float)

    dims = lefschetz_filtration(L)
    print(f"  Nilpotent operator on R^6 (weight 3)")
    print(f"  Kernel filtration dimensions: {dims}")
    print(f"  Monotone: {all(dims[i] <= dims[i+1] for i in range(len(dims)-1))}")
    print(f"  Stabilizes at dimension: {dims[-1]}")
    print()

    # Random nilpotent of higher weight
    np.random.seed(42)
    L_rand = random_nilpotent_matrix(8, 4)
    dims_rand = lefschetz_filtration(L_rand)
    print(f"  Random nilpotent on R^8 (weight 4)")
    print(f"  Kernel filtration dimensions: {dims_rand}")
    print(f"  Monotone: {all(dims_rand[i] <= dims_rand[i+1] for i in range(len(dims_rand)-1))}")
    print()


def demo_hodge_index():
    """Demonstrate the Hodge index theorem."""
    print("=" * 60)
    print("DEMO 3: Hodge Index Theorem")
    print("=" * 60)
    print()

    # Intersection form of a surface with Picard number 3
    Q = build_surface_intersection_form([1, 0, 3, 0, 1])
    p, q, z = hodge_signature(Q)
    print(f"  Intersection form for surface with ρ = 3")
    print(f"  Matrix: diag(1, -1, -1)")
    print(f"  Signature: ({p}, {q}), zero eigenvalues: {z}")
    print(f"  Hodge index signature (1, ρ-1) = (1, 2): {(p, q) == (1, 2)}")
    print(f"  p + q = dim(V): {p + q == 3}")
    print()

    # Intersection form of a K3 surface (Picard number 20)
    Q_k3 = np.diag([1.0] + [-1.0] * 19)
    p_k3, q_k3, z_k3 = hodge_signature(Q_k3)
    print(f"  K3 surface with Picard number 20")
    print(f"  Signature: ({p_k3}, {q_k3})")
    print(f"  Hodge index verified: {(p_k3, q_k3) == (1, 19)}")
    print()


def demo_weight_purity():
    """Demonstrate weight purity characterization."""
    print("=" * 60)
    print("DEMO 4: Weight Purity Theorem")
    print("=" * 60)
    print()

    # Pure weight filtration (smooth projective variety)
    pure_dims = [0, 0, 5, 5, 5]  # W_0=0, W_1=0, W_2=5=top
    is_pure, weight, graded = weight_filtration_analysis(pure_dims, 5)
    print(f"  Pure filtration: dims = {pure_dims}")
    print(f"  Is pure: {is_pure}")
    print(f"  Pure weight: {weight}")
    print(f"  Graded dimensions: {graded}")
    print()

    # Mixed weight filtration (singular variety)
    mixed_dims = [0, 2, 3, 5, 5]  # nontrivial mixing
    is_pure_m, weight_m, graded_m = weight_filtration_analysis(mixed_dims, 5)
    print(f"  Mixed filtration: dims = {mixed_dims}")
    print(f"  Is pure: {is_pure_m}")
    print(f"  Pure weight: {weight_m}")
    print(f"  Graded dimensions: {graded_m}")
    print()


def demo_primitive_rank_bound():
    """Test the Primitive Rank Bound Conjecture."""
    print("=" * 60)
    print("DEMO 5: Primitive Rank Bound Conjecture")
    print("=" * 60)
    print()

    np.random.seed(12345)
    total_tests = 0
    total_pass = 0

    for n in range(3, 15):
        for w in range(1, min(n, 6)):
            for trial in range(100):
                L = random_nilpotent_matrix(n, w)
                holds, ker_dim, weight, dim = verify_primitive_rank_bound(L)
                total_tests += 1
                if holds:
                    total_pass += 1

    print(f"  Tested {total_tests} random nilpotent matrices")
    print(f"  Conjecture holds: {total_pass}/{total_tests}")
    print(f"  Success rate: {total_pass/total_tests*100:.1f}%")
    print()

    # Show a specific example
    L_ex = random_nilpotent_matrix(6, 3)
    holds, ker_dim, weight, dim = verify_primitive_rank_bound(L_ex)
    print(f"  Example: 6×6 nilpotent, weight {weight}")
    print(f"  dim(ker L) = {ker_dim}")
    print(f"  dim(ker L) × (w+1) = {ker_dim * (weight + 1)} ≥ {dim} = dim(V): {holds}")
    print()


def demo_projector_algebra():
    """Demonstrate correspondence algebra projector operations."""
    print("=" * 60)
    print("DEMO 6: Projector Algebra (Motivic Correspondences)")
    print("=" * 60)
    print()

    # Random projector
    np.random.seed(42)
    A = np.random.randn(5, 5)
    U, _, _ = np.linalg.svd(A)
    # Project onto first 2 columns of U
    p = U[:, :2] @ U[:, :2].T

    print(f"  Random rank-2 projector p on R^5")
    print(f"  p² = p: {np.allclose(p @ p, p)}")

    # Complement
    q = projector_complement(p)
    print(f"  q = 1 - p")
    print(f"  q² = q: {np.allclose(q @ q, q)}")
    print(f"  rank(p) + rank(q) = {int(np.round(np.linalg.matrix_rank(p)))} + {int(np.round(np.linalg.matrix_rank(q)))} = {int(np.round(np.linalg.matrix_rank(p))) + int(np.round(np.linalg.matrix_rank(q)))}")

    # Transpose projector
    pt = p.T
    print(f"  p^T is projector: {np.allclose(pt @ pt, pt)}")

    # Self-adjoint composition
    ptp = p.T @ p
    print(f"  (p^T·p)^T = p^T·p: {np.allclose(ptp.T, ptp)}")
    print()


if __name__ == "__main__":
    demo_kunneth_projectors()
    demo_lefschetz_filtration()
    demo_hodge_index()
    demo_weight_purity()
    demo_primitive_rank_bound()
    demo_projector_algebra()

    print("=" * 60)
    print("All demonstrations completed successfully.")
    print("=" * 60)


#!/usr/bin/env python3
"""Visualization of Lefschetz kernel filtrations for nilpotent operators."""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt


def random_nilpotent_matrix(n: int, weight: int) -> np.ndarray:
    """Generate a random nilpotent matrix with given nilpotency weight."""
    J = np.zeros((n, n))
    for i in range(min(weight - 1, n - 1)):
        J[i, i + 1] = 1.0
    P = np.random.randn(n, n)
    while np.abs(np.linalg.det(P)) < 0.01:
        P = np.random.randn(n, n)
    return P @ J @ np.linalg.inv(P)


def lefschetz_filtration(L: np.ndarray) -> list:
    """Compute kernel filtration dimensions."""
    n = L.shape[0]
    dims = [0]
    power = np.eye(n)
    for k in range(1, n + 2):
        power = power @ L
        ker_dim = n - int(np.round(np.linalg.matrix_rank(power, tol=1e-10)))
        dims.append(ker_dim)
        if ker_dim == n:
            break
    return dims


def main():
    np.random.seed(42)
    fig, axes = plt.subplots(2, 2, figsize=(12, 10))
    fig.suptitle("Lefschetz Kernel Filtrations for Nilpotent Operators",
                 fontsize=16, fontweight='bold')

    configs = [
        (6, 3, "6-dim, weight 3 (surface)"),
        (8, 4, "8-dim, weight 4 (3-fold)"),
        (10, 5, "10-dim, weight 5 (4-fold)"),
        (12, 3, "12-dim, weight 3 (surface, large)"),
    ]

    for ax, (n, w, title) in zip(axes.flat, configs):
        # Plot multiple random instances
        for trial in range(5):
            L = random_nilpotent_matrix(n, w)
            dims = lefschetz_filtration(L)
            ks = list(range(len(dims)))
            alpha = 0.3 if trial > 0 else 1.0
            lw = 1 if trial > 0 else 2.5
            ax.plot(ks, dims, 'o-', alpha=alpha, linewidth=lw,
                    color='steelblue' if trial > 0 else 'darkblue',
                    markersize=4 if trial > 0 else 6)

        ax.set_xlabel("Power k")
        ax.set_ylabel("dim(ker L^k)")
        ax.set_title(title)
        ax.axhline(y=n, color='red', linestyle='--', alpha=0.5, label=f'dim(V) = {n}')
        ax.set_ylim(-0.5, n + 1)
        ax.legend(fontsize=9)
        ax.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig("filtration_visualization.png", dpi=150, bbox_inches='tight')
    print("Saved filtration_visualization.png")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""Visualization of Hodge index theorem signatures."""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt


def hodge_signature(Q: np.ndarray) -> tuple:
    """Compute signature of a symmetric matrix."""
    eigs = np.linalg.eigvalsh(Q)
    tol = 1e-10
    return int(np.sum(eigs > tol)), int(np.sum(eigs < -tol)), int(np.sum(np.abs(eigs) <= tol))


def main():
    fig, axes = plt.subplots(1, 3, figsize=(15, 5))
    fig.suptitle("Hodge Index Theorem: Intersection Form Signatures",
                 fontsize=14, fontweight='bold')

    # Panel 1: Signature vs Picard number
    ax = axes[0]
    picard_numbers = list(range(1, 21))
    pos_ranks = []
    neg_ranks = []
    for rho in picard_numbers:
        Q = np.diag([1.0] + [-1.0] * (rho - 1))
        p, q, _ = hodge_signature(Q)
        pos_ranks.append(p)
        neg_ranks.append(q)

    ax.bar(picard_numbers, pos_ranks, label='Positive rank', color='steelblue', alpha=0.8)
    ax.bar(picard_numbers, neg_ranks, bottom=pos_ranks, label='Negative rank',
           color='coral', alpha=0.8)
    ax.set_xlabel('Picard number ρ')
    ax.set_ylabel('Rank')
    ax.set_title('Hodge Index: Signature (1, ρ-1)')
    ax.legend()
    ax.grid(True, alpha=0.3, axis='y')

    # Panel 2: Eigenvalue distribution for random perturbation of Hodge form
    ax = axes[1]
    np.random.seed(42)
    rho = 10
    Q_base = np.diag([1.0] + [-1.0] * (rho - 1))
    perturbations = [0, 0.01, 0.05, 0.1, 0.2]
    colors = plt.cm.viridis(np.linspace(0, 0.8, len(perturbations)))

    for eps, color in zip(perturbations, colors):
        P = np.random.randn(rho, rho)
        P = (P + P.T) / 2  # symmetrize
        Q = Q_base + eps * P
        eigs = np.sort(np.linalg.eigvalsh(Q))
        ax.plot(range(rho), eigs, 'o-', color=color, label=f'ε = {eps}',
                markersize=5, linewidth=1.5)

    ax.axhline(y=0, color='black', linestyle='-', linewidth=0.5)
    ax.set_xlabel('Eigenvalue index')
    ax.set_ylabel('Eigenvalue')
    ax.set_title(f'Perturbed Hodge Form (ρ = {rho})')
    ax.legend(fontsize=8)
    ax.grid(True, alpha=0.3)

    # Panel 3: Positive-negative disjointness visualization
    ax = axes[2]
    theta = np.linspace(0, 2 * np.pi, 200)
    # Positive cone (small)
    r_pos = 0.3
    x_pos = r_pos * np.cos(theta)
    y_pos = r_pos * np.sin(theta)
    ax.fill(x_pos, y_pos, color='steelblue', alpha=0.3, label='Positive cone')
    ax.plot(x_pos, y_pos, color='steelblue', linewidth=2)

    # Negative region (complement)
    r_neg_outer = 1.5
    r_neg_inner = 0.5
    x_neg_out = r_neg_outer * np.cos(theta)
    y_neg_out = r_neg_outer * np.sin(theta)
    x_neg_in = r_neg_inner * np.cos(theta[::-1])
    y_neg_in = r_neg_inner * np.sin(theta[::-1])
    ax.fill(np.concatenate([x_neg_out, x_neg_in]),
            np.concatenate([y_neg_out, y_neg_in]),
            color='coral', alpha=0.2, label='Negative region')
    ax.plot(x_neg_out, y_neg_out, color='coral', linewidth=2)

    ax.plot(0, 0, 'ko', markersize=8, zorder=5)
    ax.annotate('Origin\n(only intersection)', (0, 0), (0.3, -0.8),
                fontsize=9, ha='center',
                arrowprops=dict(arrowstyle='->', color='black'))
    ax.set_xlim(-2, 2)
    ax.set_ylim(-2, 2)
    ax.set_aspect('equal')
    ax.set_title('Pos-Neg Disjointness')
    ax.legend(loc='upper right', fontsize=8)
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig("hodge_index_visualization.png", dpi=150, bbox_inches='tight')
    print("Saved hodge_index_visualization.png")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""Visualization of the Primitive Rank Bound Conjecture."""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt


def random_nilpotent_matrix(n: int, weight: int) -> np.ndarray:
    """Generate a random nilpotent matrix with given nilpotency weight."""
    J = np.zeros((n, n))
    for i in range(min(weight - 1, n - 1)):
        J[i, i + 1] = 1.0
    P = np.random.randn(n, n)
    while np.abs(np.linalg.det(P)) < 0.01:
        P = np.random.randn(n, n)
    return P @ J @ np.linalg.inv(P)


def verify_bound(L: np.ndarray) -> tuple:
    """Check primitive rank bound."""
    n = L.shape[0]
    ker_dim = n - int(np.round(np.linalg.matrix_rank(L, tol=1e-10)))
    power = L.copy()
    weight = 0
    for k in range(1, n + 1):
        if np.allclose(power, 0, atol=1e-10):
            weight = k - 1
            break
        power = power @ L
    else:
        weight = n
    ratio = ker_dim * (weight + 1) / n if n > 0 else 1.0
    return ker_dim, weight, ratio


def main():
    np.random.seed(42)
    fig, axes = plt.subplots(1, 3, figsize=(15, 5))
    fig.suptitle("Primitive Rank Bound Conjecture: dim(ker L) × (w+1) ≥ dim(V)",
                 fontsize=14, fontweight='bold')

    # Panel 1: Scatter plot of ratio vs dimension
    ax = axes[0]
    dims = range(3, 20)
    ratios_by_dim = {d: [] for d in dims}

    for n in dims:
        for w in range(1, min(n, 8)):
            for _ in range(50):
                L = random_nilpotent_matrix(n, w)
                _, _, ratio = verify_bound(L)
                ratios_by_dim[n].append(ratio)

    box_data = [ratios_by_dim[d] for d in dims]
    bp = ax.boxplot(box_data, positions=list(dims), widths=0.6,
                    patch_artist=True,
                    boxprops=dict(facecolor='steelblue', alpha=0.5),
                    medianprops=dict(color='darkblue', linewidth=2))
    ax.axhline(y=1.0, color='red', linestyle='--', linewidth=2,
               label='Conjecture bound (ratio ≥ 1)')
    ax.set_xlabel('Matrix dimension')
    ax.set_ylabel('dim(ker L) × (w+1) / dim(V)')
    ax.set_title('Ratio Distribution by Dimension')
    ax.legend()
    ax.grid(True, alpha=0.3)

    # Panel 2: Ratio vs weight for fixed dimension
    ax = axes[1]
    n_fixed = 12
    for w in range(1, 8):
        ratios = []
        for _ in range(200):
            L = random_nilpotent_matrix(n_fixed, w)
            _, _, r = verify_bound(L)
            ratios.append(r)
        ax.scatter([w] * len(ratios), ratios, alpha=0.3, s=10, color='steelblue')
        ax.plot(w, np.mean(ratios), 'ro', markersize=8, zorder=5)

    ax.axhline(y=1.0, color='red', linestyle='--', linewidth=2)
    ax.set_xlabel('Nilpotency weight w')
    ax.set_ylabel('dim(ker L) × (w+1) / dim(V)')
    ax.set_title(f'Fixed Dimension n = {n_fixed}')
    ax.grid(True, alpha=0.3)

    # Panel 3: Heatmap of minimum ratio
    ax = axes[2]
    dims_hm = range(3, 16)
    weights_hm = range(1, 10)
    min_ratios = np.full((len(list(weights_hm)), len(list(dims_hm))), np.nan)

    for i, w in enumerate(weights_hm):
        for j, n in enumerate(dims_hm):
            if w >= n:
                continue
            ratios = []
            for _ in range(100):
                L = random_nilpotent_matrix(n, w)
                _, _, r = verify_bound(L)
                ratios.append(r)
            min_ratios[i, j] = min(ratios)

    im = ax.imshow(min_ratios, aspect='auto', cmap='RdYlGn',
                   vmin=0.5, vmax=3.0,
                   extent=[2.5, 15.5, 9.5, 0.5])
    plt.colorbar(im, ax=ax, label='Min ratio')
    ax.set_xlabel('Matrix dimension n')
    ax.set_ylabel('Nilpotency weight w')
    ax.set_title('Minimum Ratio (green = conjecture holds)')
    ax.set_xticks(list(dims_hm))
    ax.set_yticks(list(weights_hm))

    plt.tight_layout()
    plt.savefig("primitive_bound_visualization.png", dpi=150, bbox_inches='tight')
    print("Saved primitive_bound_visualization.png")


if __name__ == "__main__":
    main()
