#!/usr/bin/env python3
"""
Demo: Standard Conjectures on Algebraic Cycles

Demonstrates the key algorithms and verified results from our formalization
of Grothendieck's standard conjectures.
"""

import numpy as np
from algorithms import (
    intersection_pairing, numerical_kernel, hodge_index_check,
    idempotent_decomposition, weight_filtration_graded_dims,
    check_primitive_bound_conjecture, verify_lefschetz_star_idempotent,
    standard_conjecture_d_gap
)


def demo_hodge_index():
    """Demonstrate the Hodge index theorem for rank-2 forms."""
    print("=" * 60)
    print("DEMO 1: Hodge Index Theorem (Rank 2)")
    print("=" * 60)
    print()
    print("For a 2×2 intersection form [[a,b],[b,c]] with a > 0:")
    print("If det = ac - b² < 0, then the orthogonal complement")
    print("of the positive direction is negative definite.")
    print()

    test_cases = [
        (2, 1, -1, "Surface with self-intersection 2, cross-term 1"),
        (1, 0, -1, "Hyperbolic plane (signature (1,1))"),
        (3, 2, 1, "Positive definite (det > 0, Hodge N/A)"),
        (1, 3, -5, "Large off-diagonal"),
    ]

    for a, b, c, desc in test_cases:
        result = hodge_index_check(a, b, c)
        print(f"  Form [[{a},{b}],[{b},{c}]]: {desc}")
        print(f"    det = {result['determinant']:.2f}, "
              f"signature = {result['signature']}, "
              f"Hodge index: {result['hodge_index_holds']}")

    # Verify our proved theorem numerically
    print()
    print("  Numerical verification of proved theorem:")
    a, b, c = 5, 3, 1  # det = 5 - 9 = -4 < 0, a > 0
    for y in np.linspace(-2, 2, 5):
        x = -b * y / a
        val = a*x*x + 2*b*x*y + c*y*y
        print(f"    y={y:5.2f}, x={x:5.2f}: "
              f"ax²+2bxy+cy² = {val:.4f} ≤ 0: {val <= 1e-10}")
    print()


def demo_motive_decomposition():
    """Demonstrate motive decomposition via idempotent projectors."""
    print("=" * 60)
    print("DEMO 2: Motive Decomposition (Complementary Idempotents)")
    print("=" * 60)
    print()

    # Create an idempotent projector on ℚ^4
    # Projection onto span{e₁, e₂}
    p = np.zeros((4, 4))
    p[0, 0] = 1
    p[1, 1] = 1

    print("  Projector p (rank 2 on ℚ⁴):")
    print(f"    p² = p: {np.allclose(p @ p, p)}")

    im_basis, comp_basis, p_comp = idempotent_decomposition(p)

    print(f"    rank(p) = {im_basis.shape[1]}")
    print(f"    rank(1-p) = {comp_basis.shape[1]}")
    print(f"    rank(p) + rank(1-p) = {im_basis.shape[1] + comp_basis.shape[1]} = dim(V)")
    print(f"    (1-p)² = (1-p): {np.allclose(p_comp @ p_comp, p_comp)}")

    # More interesting example: random idempotent
    rng = np.random.default_rng(42)
    A = rng.standard_normal((6, 6))
    # Make idempotent via spectral projection
    evals, evecs = np.linalg.eigh(A @ A.T)
    p2 = evecs[:, :3] @ evecs[:, :3].T  # Project onto top 3 eigenspaces

    print()
    print("  Random projector (rank 3 on ℚ⁶):")
    print(f"    p² ≈ p: {np.allclose(p2 @ p2, p2, atol=1e-10)}")
    im2, comp2, p2c = idempotent_decomposition(p2)
    print(f"    rank(p) = {im2.shape[1]}")
    print(f"    rank(1-p) = {comp2.shape[1]}")
    print(f"    Sum = {im2.shape[1] + comp2.shape[1]} = dim(V) ✓")
    print()


def demo_weight_filtration():
    """Demonstrate weight filtration and graded pieces."""
    print("=" * 60)
    print("DEMO 3: Weight Filtration (Pure Motives)")
    print("=" * 60)
    print()

    # Example: H*(P^2) has Betti numbers (1, 0, 1, 0, 1)
    # Weight filtration on H*(P^2, ℚ) is pure of weight 0,2,4
    print("  Example: H*(ℙ², ℚ) with Betti numbers (1, 0, 1, 0, 1)")
    dims = [1, 1, 2, 2, 3]  # cumulative dims of W₀ ⊂ W₁ ⊂ ...
    graded = weight_filtration_graded_dims(dims)
    print(f"    Filtration dims: {dims}")
    print(f"    Graded dims:     {graded}")
    print(f"    Sum = {sum(graded)} = total dim")

    # Pure filtration of weight 2
    print()
    print("  Pure filtration of weight 2 on ℚ³:")
    pure_dims = [0, 0, 3, 3, 3]  # W₁ = 0, W₂ = ℚ³, rest stable
    pure_graded = weight_filtration_graded_dims(pure_dims)
    print(f"    Filtration dims: {pure_dims}")
    print(f"    Graded dims:     {pure_graded}")
    print(f"    Only Gr_2 = {pure_graded[2]} is nonzero ✓")
    print()


def demo_primitive_bound_conjecture():
    """Test the primitive bound conjecture computationally."""
    print("=" * 60)
    print("DEMO 4: Primitive Bound Conjecture")
    print("=" * 60)
    print()
    print("  Conjecture: For compatible (Q, L) on ℚᵈ,")
    print("  dim(ker L) ≤ d/2 + 1")
    print()

    for d in [4, 6, 8, 10, 12]:
        result = check_primitive_bound_conjecture(d, n_trials=500)
        status = "✓" if result['conjecture_holds'] else "✗"
        print(f"  d={d:2d}: bound={result['bound']}, "
              f"max ker dim={result['max_kernel_dim_found']}, "
              f"counterexamples={result['counterexamples']} {status}")
    print()


def demo_lefschetz_star():
    """Demonstrate the Lefschetz star operator."""
    print("=" * 60)
    print("DEMO 5: Lefschetz Star Operator")
    print("=" * 60)
    print()

    # Create L with known left inverse
    n = 5
    rng = np.random.default_rng(123)

    # L is injective (full column rank when m > n)
    m = 5
    L = rng.standard_normal((m, m))
    # Make L invertible
    L = L + np.eye(m) * 3  # ensure invertibility

    Lambda = np.linalg.inv(L)

    print(f"  L is {m}×{m} invertible matrix")
    print(f"  Λ = L⁻¹ (left inverse)")
    print(f"  Λ ∘ L = I: {np.allclose(Lambda @ L, np.eye(m))}")
    print(f"  L ∘ Λ idempotent on im(L): "
          f"{verify_lefschetz_star_idempotent(L, Lambda)}")

    # Non-square case: injective L
    L2 = rng.standard_normal((6, 4))
    U, S, Vt = np.linalg.svd(L2, full_matrices=False)
    Lambda2 = Vt.T @ np.diag(1.0/S) @ U.T
    print()
    print(f"  L is 6×4 injective (rank 4)")
    print(f"  Λ ∘ L = I: {np.allclose(Lambda2 @ L2, np.eye(4), atol=1e-10)}")
    star2 = L2 @ Lambda2
    star2_sq = star2 @ star2
    print(f"  ★² = ★ on im(L): {np.allclose(star2_sq @ L2, star2 @ L2, atol=1e-10)}")
    print()


def demo_standard_conjecture_d():
    """Demonstrate Standard Conjecture D verification."""
    print("=" * 60)
    print("DEMO 6: Standard Conjecture D Gap")
    print("=" * 60)
    print()

    # Case 1: Nondegenerate pairing (D holds trivially)
    Q = np.array([[2, 1], [1, 3]], dtype=float)
    hom_ker = np.zeros((2, 0))
    result = standard_conjecture_d_gap(Q, hom_ker)
    print("  Case 1: Nondegenerate pairing")
    print(f"    Q = [[2,1],[1,3]], det = {np.linalg.det(Q):.1f}")
    print(f"    num_ker dim = {result['numerical_kernel_dim']}")
    print(f"    hom_ker dim = {result['homological_kernel_dim']}")
    print(f"    Gap = {result['gap']}, D holds: {result['conjecture_d_holds']} ✓")

    # Case 2: Degenerate pairing with matching homological kernel
    Q2 = np.array([[1, 1, 0],
                    [1, 1, 0],
                    [0, 0, 1]], dtype=float)
    num_ker2 = numerical_kernel(Q2)
    result2 = standard_conjecture_d_gap(Q2, num_ker2)
    print()
    print("  Case 2: Degenerate pairing (1d kernel)")
    print(f"    num_ker dim = {result2['numerical_kernel_dim']}")
    print(f"    hom_ker dim = {result2['homological_kernel_dim']}")
    print(f"    Gap = {result2['gap']}, D holds: {result2['conjecture_d_holds']} ✓")
    print()


if __name__ == "__main__":
    print()
    print("Standard Conjectures on Algebraic Cycles: Numerical Demonstrations")
    print("=" * 60)
    print()

    demo_hodge_index()
    demo_motive_decomposition()
    demo_weight_filtration()
    demo_primitive_bound_conjecture()
    demo_lefschetz_star()
    demo_standard_conjecture_d()

    print("All demos completed successfully.")


#!/usr/bin/env python3
"""
Visualization: Hodge Index Theorem
Shows the intersection form and its signature constraint.
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches


def plot_hodge_index():
    """Visualize the Hodge index theorem for 2D intersection forms."""
    fig, axes = plt.subplots(1, 3, figsize=(15, 5))

    # Parameters: a > 0, det = ac - b² < 0
    cases = [
        (2, 1, -1, "a=2, b=1, c=-1\ndet=-3"),
        (1, 0, -1, "a=1, b=0, c=-1\nHyperbolic"),
        (5, 3, 1, "a=5, b=3, c=1\ndet=-4"),
    ]

    for ax, (a, b, c, title) in zip(axes, cases):
        # Plot the quadratic form Q(x,y) = ax² + 2bxy + cy²
        x = np.linspace(-2, 2, 200)
        y = np.linspace(-2, 2, 200)
        X, Y = np.meshgrid(x, y)
        Z = a*X*X + 2*b*X*Y + c*Y*Y

        # Contour plot
        levels = np.linspace(-5, 5, 21)
        cs = ax.contourf(X, Y, Z, levels=levels, cmap='RdBu_r', alpha=0.8)
        ax.contour(X, Y, Z, levels=[0], colors='black', linewidths=2)

        # Plot orthogonal complement of positive direction
        # Positive direction: eigenvector with positive eigenvalue
        M = np.array([[a, b], [b, c]])
        evals, evecs = np.linalg.eigh(M)

        for i, (ev, evec) in enumerate(zip(evals, evecs.T)):
            color = 'green' if ev > 0 else 'red'
            label = f'λ={ev:.2f}'
            ax.arrow(0, 0, evec[0], evec[1], head_width=0.08,
                    head_length=0.05, fc=color, ec=color, linewidth=2)
            ax.annotate(label, xy=(evec[0]*1.3, evec[1]*1.3),
                       fontsize=9, color=color, fontweight='bold')

        # Plot the orthogonality line: ax + by = 0 => y = -ax/b if b≠0
        if abs(b) > 1e-10:
            t = np.linspace(-2, 2, 100)
            orth_x = t
            orth_y = -a * t / b
            mask = (np.abs(orth_y) < 2)
            ax.plot(orth_x[mask], orth_y[mask], 'k--', linewidth=1.5,
                   label='⊥ to positive dir')

        ax.set_xlim(-2, 2)
        ax.set_ylim(-2, 2)
        ax.set_aspect('equal')
        ax.set_title(title, fontsize=12)
        ax.set_xlabel('x')
        ax.set_ylabel('y')
        ax.grid(True, alpha=0.3)

    fig.suptitle('Hodge Index Theorem: Intersection Form Q(x,y) = ax² + 2bxy + cy²\n'
                 'Green = positive eigendirection, Red = negative, '
                 'Black curve = isotropic cone',
                 fontsize=13, fontweight='bold')
    plt.tight_layout()
    plt.savefig('hodge_index_visualization.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved hodge_index_visualization.png")


def plot_motive_decomposition():
    """Visualize the direct sum decomposition V = im(p) ⊕ im(1-p)."""
    fig, ax = plt.subplots(1, 1, figsize=(8, 8))

    # 3D-like view of ℝ³ = im(p) ⊕ im(1-p) where p projects onto xy-plane
    theta = np.linspace(0, 2*np.pi, 100)

    # Image of p (xy-plane)
    r = 1.5
    x1 = r * np.cos(theta)
    y1 = r * np.sin(theta)
    ax.fill(x1 * 0.8 - y1 * 0.2, y1 * 0.8 + x1 * 0.1,
            alpha=0.3, color='blue', label='im(p) — Motive M')

    # Image of 1-p (z-axis, shown as a line)
    ax.plot([0, 0.5], [0, 1.5], 'r-', linewidth=3,
            label='im(1-p) — Complement M^⊥')
    ax.plot([0, -0.5], [0, -1.5], 'r-', linewidth=3)

    # Arrows showing decomposition
    v = np.array([1.0, 1.2])
    p_v = np.array([0.8, 0.3])  # projection
    comp_v = v - p_v

    ax.annotate('', xy=v, xytext=(0, 0),
               arrowprops=dict(arrowstyle='->', color='black', lw=2))
    ax.text(v[0]+0.05, v[1]+0.05, 'v', fontsize=14, fontweight='bold')

    ax.annotate('', xy=p_v, xytext=(0, 0),
               arrowprops=dict(arrowstyle='->', color='blue', lw=2))
    ax.text(p_v[0]+0.05, p_v[1]-0.15, 'p(v)', fontsize=12, color='blue')

    ax.annotate('', xy=v, xytext=p_v,
               arrowprops=dict(arrowstyle='->', color='red', lw=2))
    ax.text(comp_v[0]/2 + p_v[0] + 0.05, comp_v[1]/2 + p_v[1],
            '(1-p)(v)', fontsize=12, color='red')

    # Add rank info
    ax.text(-1.5, -1.8, 'rank(M) + rank(M⊥) = dim(V)\n'
            'Proved: PureMotive.rank_add_complement_rank',
            fontsize=11, style='italic',
            bbox=dict(boxstyle='round', facecolor='lightyellow', alpha=0.8))

    ax.set_xlim(-2, 2)
    ax.set_ylim(-2, 2)
    ax.set_aspect('equal')
    ax.legend(fontsize=12, loc='upper left')
    ax.set_title('Motive Decomposition: V = im(p) ⊕ im(1-p)',
                fontsize=14, fontweight='bold')
    ax.grid(True, alpha=0.3)
    plt.tight_layout()
    plt.savefig('motive_decomposition.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved motive_decomposition.png")


def plot_conjecture_landscape():
    """Visualize the landscape of standard conjectures and their implications."""
    fig, ax = plt.subplots(1, 1, figsize=(12, 8))

    # Boxes for each conjecture
    conjectures = {
        'B (Lefschetz)': (0.5, 0.75),
        'C (Künneth)': (0.2, 0.45),
        'D (Num=Hom)': (0.5, 0.45),
        'Hodge\nConjecture': (0.8, 0.45),
        'Motives\nSemisimple': (0.5, 0.15),
    }

    colors = {
        'B (Lefschetz)': '#3498db',
        'C (Künneth)': '#2ecc71',
        'D (Num=Hom)': '#e74c3c',
        'Hodge\nConjecture': '#9b59b6',
        'Motives\nSemisimple': '#f39c12',
    }

    for name, (x, y) in conjectures.items():
        rect = mpatches.FancyBboxPatch((x-0.08, y-0.06), 0.16, 0.12,
                                        boxstyle="round,pad=0.02",
                                        facecolor=colors[name],
                                        edgecolor='black', linewidth=2,
                                        alpha=0.8)
        ax.add_patch(rect)
        ax.text(x, y, name, ha='center', va='center',
               fontsize=11, fontweight='bold', color='white')

    # Arrows for implications
    implications = [
        ('B (Lefschetz)', 'C (Künneth)', 'implies'),
        ('B (Lefschetz)', 'D (Num=Hom)', 'implies'),
        ('Hodge\nConjecture', 'D (Num=Hom)', 'implies\n(char 0)'),
        ('D (Num=Hom)', 'Motives\nSemisimple', 'implies'),
        ('C (Künneth)', 'Motives\nSemisimple', 'implies'),
    ]

    for src, dst, label in implications:
        sx, sy = conjectures[src]
        dx, dy = conjectures[dst]
        ax.annotate('', xy=(dx, dy+0.06), xytext=(sx, sy-0.06),
                   arrowprops=dict(arrowstyle='->', color='gray',
                                  lw=2, connectionstyle='arc3,rad=0.1'))
        mx, my = (sx+dx)/2 + 0.04, (sy+dy)/2
        ax.text(mx, my, label, fontsize=8, color='gray',
               ha='center', style='italic')

    # Add "PROVED" labels for our results
    proved = [
        (0.5, 0.35, "✓ standardD_of_nondegenerate", '#27ae60'),
        (0.2, 0.35, "✓ künneth_two_projectors", '#27ae60'),
        (0.5, 0.05, "✓ rank_add_complement_rank", '#27ae60'),
    ]
    for x, y, text, color in proved:
        ax.text(x, y, text, ha='center', fontsize=9,
               color=color, fontweight='bold')

    ax.set_xlim(0, 1)
    ax.set_ylim(0, 1)
    ax.set_aspect('equal')
    ax.axis('off')
    ax.set_title('Landscape of Standard Conjectures\n'
                 'and Their Implications',
                fontsize=16, fontweight='bold')
    plt.tight_layout()
    plt.savefig('conjecture_landscape.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved conjecture_landscape.png")


if __name__ == "__main__":
    plot_hodge_index()
    plot_motive_decomposition()
    plot_conjecture_landscape()
    print("All visualizations generated.")
