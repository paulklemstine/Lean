#!/usr/bin/env python3
"""
Hodge Conjecture: Computational Demonstrations

Numerical examples illustrating the structural theorems of the Hodge
conjecture formalization. Each example corresponds to a formally verified
theorem in Lean 4.
"""

import numpy as np
from algorithms import (
    WeightTwoHodgeStructure,
    PolarizedHodgeStructure,
    BilinearForm,
    K3LatticeData,
    AbelianVarietyData,
    construct_k3_hodge_structure,
    verify_transcendental_hodge_disjointness,
    verify_hodge_conjecture_rank_one,
)


def demo_rank_one_hodge_conjecture():
    """
    Demo 1: Hodge conjecture for Picard rank 1

    Corresponding Lean theorem: hodgeConj_of_picard_rank_one
    If the Picard rank is 1 and there's a nonzero algebraic class,
    every Hodge class is a rational multiple of it.
    """
    print("=" * 60)
    print("DEMO 1: Hodge Conjecture for Picard Rank 1")
    print("=" * 60)

    # V = ℚ^4, H^{1,1} is 1-dimensional, spanned by (1, 2, 0, 0)
    h11_basis = np.array([[1.0, 2.0, 0.0, 0.0]])
    hs = WeightTwoHodgeStructure(dim=4, h11_basis=h11_basis)

    print(f"  Space dimension: {hs.dim}")
    print(f"  Picard rank: {hs.picard_rank()}")
    print(f"  Hodge level: {hs.hodge_level()}")

    # Algebraic generator
    gen = np.array([1.0, 2.0, 0.0, 0.0])
    print(f"\n  Algebraic generator: {gen}")
    print(f"  Is Hodge class: {hs.is_hodge_class(gen)}")

    # Test other vectors
    test_vectors = [
        np.array([3.0, 6.0, 0.0, 0.0]),   # 3 * gen → Hodge class
        np.array([0.5, 1.0, 0.0, 0.0]),    # 0.5 * gen → Hodge class
        np.array([1.0, 0.0, 0.0, 0.0]),    # not proportional → not Hodge
    ]

    for v in test_vectors:
        is_hc = hs.is_hodge_class(v)
        print(f"  {v} is Hodge: {is_hc}")
        if is_hc and not np.allclose(gen, 0):
            ratio = v[0] / gen[0]
            print(f"    → ratio to generator: {ratio}")

    result = verify_hodge_conjecture_rank_one(hs, gen)
    print(f"\n  HC verified for rank 1: {result}")


def demo_transcendental_hodge_disjointness():
    """
    Demo 2: Transcendental lattice ∩ Hodge classes = {0}

    Corresponding Lean theorem: transcendental_inter_hodge_eq_bot
    Under a nondegenerate symmetric form with V = HC + T,
    the transcendental lattice and Hodge classes are disjoint.
    """
    print("\n" + "=" * 60)
    print("DEMO 2: Transcendental-Hodge Disjointness")
    print("=" * 60)

    # V = ℚ^3 with standard form Q = diag(1, -1, -1)
    Q_matrix = np.diag([1.0, -1.0, -1.0])
    Q = BilinearForm(Q_matrix)

    # H^{1,1} spanned by first two standard basis vectors
    h11_basis = np.array([[1.0, 0.0, 0.0], [0.0, 1.0, 0.0]])
    hs = WeightTwoHodgeStructure(dim=3, h11_basis=h11_basis)
    phs = PolarizedHodgeStructure(hodge=hs, Q=Q)

    print(f"  Dimension: {hs.dim}")
    print(f"  Q matrix:\n{Q.matrix}")
    print(f"  Q symmetric: {Q.is_symmetric()}")
    print(f"  Q nondegenerate: {Q.is_nondegenerate()}")
    print(f"  Q signature: {Q.signature()}")
    print(f"\n  Picard rank: {hs.picard_rank()}")

    hc_basis = hs.hodge_classes_basis()
    tl_basis = phs.transcendental_lattice_basis()
    print(f"  Hodge classes basis:\n{hc_basis}")
    print(f"  Transcendental lattice basis:\n{tl_basis}")

    disjoint = verify_transcendental_hodge_disjointness(phs)
    print(f"\n  T ∩ HC = {{0}}: {disjoint}")


def demo_hodge_index_theorem():
    """
    Demo 3: Hodge Index Theorem for K3 surfaces

    The intersection form on a K3 surface has signature (3, 19) on H^2.
    Restricted to the Picard lattice (= Hodge classes), it has signature (1, ρ-1).
    """
    print("\n" + "=" * 60)
    print("DEMO 3: Hodge Index Theorem for K3 Surfaces")
    print("=" * 60)

    for rho in [1, 2, 5, 10, 20]:
        k3 = K3LatticeData(picard_rank=rho)
        phs = construct_k3_hodge_structure(rho)

        pos, neg = phs.hodge_index()
        hit_ok = phs.verify_hodge_index_theorem()

        print(f"\n  K3 with ρ = {rho:2d}:")
        print(f"    Transcendental rank: {k3.transcendental_rank}")
        print(f"    NS signature: {k3.ns_signature}")
        print(f"    T signature: {k3.transcendental_signature}")
        print(f"    Computed Q|_HC signature: ({pos}, {neg})")
        print(f"    Hodge index theorem: {'✓' if hit_ok else '✗'}")
        print(f"    HC for K3: {'Known ✓' if k3.hodge_conjecture_holds() else 'Unknown'}")


def demo_level_zero():
    """
    Demo 4: Level zero ⟹ HC trivially true

    Corresponding Lean theorem: hodgeConj_of_level_zero
    When H^{1,1} = V_ℂ, every rational class is Hodge, so HC holds trivially.
    """
    print("\n" + "=" * 60)
    print("DEMO 4: Level Zero Triviality")
    print("=" * 60)

    # Full rank: H^{1,1} = ℂ^3
    h11_basis = np.eye(3)
    hs = WeightTwoHodgeStructure(dim=3, h11_basis=h11_basis)

    print(f"  Dimension: {hs.dim}")
    print(f"  Picard rank: {hs.picard_rank()}")
    print(f"  Hodge level: {hs.hodge_level()}")
    print(f"  Level zero: {hs.hodge_level() == 0}")

    # Every vector is a Hodge class
    for v in [np.array([1, 0, 0]), np.array([0, 1, 0]), np.array([1, 1, 1])]:
        print(f"  {v} is Hodge: {hs.is_hodge_class(v.astype(float))}")


def demo_abelian_variety():
    """
    Demo 5: Abelian variety Hodge conjecture status

    For abelian varieties, the HC is known in certain cases:
    - Always for H^2 (Lefschetz 1,1)
    - For simple abelian varieties of prime dimension
    - For dimensions ≤ 3
    """
    print("\n" + "=" * 60)
    print("DEMO 5: Abelian Variety Hodge Conjecture Status")
    print("=" * 60)

    for g in range(1, 7):
        av = AbelianVarietyData(dimension=g)
        print(f"\n  Abelian variety, dim g = {g}:")
        print(f"    H^2 rank: {av.h2_rank}")
        for p in range(1, g + 1):
            known = av.hodge_conjecture_known(p)
            status = "Known ✓" if known else "Open ?"
            print(f"    HC for H^{2*p}: {status}")


def demo_polarization_constraints():
    """
    Demo 6: Polarization form properties

    Demonstrates that Q-orthogonal complement of ⊤ is {0} (nondegeneracy)
    and Q-orthogonal complement of {0} is ⊤.

    Corresponding Lean theorems: qOrthogonal_top_eq_bot, qOrthogonal_bot_eq_top
    """
    print("\n" + "=" * 60)
    print("DEMO 6: Polarization Form Properties")
    print("=" * 60)

    # Example: standard form on ℚ^3
    Q = BilinearForm(np.array([[2, 1, 0], [1, 3, 1], [0, 1, 2]], dtype=float))

    print(f"  Q matrix:\n{Q.matrix}")
    print(f"  Symmetric: {Q.is_symmetric()}")
    print(f"  Nondegenerate: {Q.is_nondegenerate()}")
    print(f"  Signature: {Q.signature()}")

    # Q-orthogonal complement of full space
    # Should be {0} if nondegenerate
    print(f"\n  Q⊥(ℚ³) = {{0}}: {Q.is_nondegenerate()}")

    # Check: find vectors orthogonal to everything
    # Solve Q @ v = 0
    null_space = np.linalg.svd(Q.matrix)[2]
    min_sv = np.linalg.svd(Q.matrix)[1].min()
    print(f"  Smallest singular value of Q: {min_sv:.6f}")
    print(f"  (> 0 confirms nondegeneracy)")


if __name__ == "__main__":
    print("HODGE CONJECTURE: COMPUTATIONAL DEMONSTRATIONS")
    print("=" * 60)
    print("Each demo corresponds to a formally verified theorem.\n")

    demo_rank_one_hodge_conjecture()
    demo_transcendental_hodge_disjointness()
    demo_hodge_index_theorem()
    demo_level_zero()
    demo_abelian_variety()
    demo_polarization_constraints()

    print("\n" + "=" * 60)
    print("All demonstrations completed.")
    print("See Algebra/HodgeConjecture/ for the formal Lean 4 proofs.")


#!/usr/bin/env python3
"""
Visualization 1: Hodge Diamond and Signature Diagram for K3 Surfaces

Displays how the intersection form signature distributes between
the Picard lattice NS(X) and the transcendental lattice T(X)
as the Picard rank varies.
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches


def plot_k3_lattice_decomposition():
    """Plot K3 lattice decomposition for varying Picard rank."""
    fig, axes = plt.subplots(1, 3, figsize=(16, 5))

    rho_values = list(range(1, 21))

    # Panel 1: Rank decomposition
    ax = axes[0]
    ns_ranks = rho_values
    t_ranks = [22 - r for r in rho_values]
    ax.bar(rho_values, ns_ranks, color='#2196F3', alpha=0.8, label='NS(X) rank')
    ax.bar(rho_values, t_ranks, bottom=ns_ranks, color='#FF9800', alpha=0.8,
           label='T(X) rank')
    ax.set_xlabel('Picard rank ρ', fontsize=12)
    ax.set_ylabel('Rank', fontsize=12)
    ax.set_title('K3 Lattice Decomposition', fontsize=14)
    ax.legend(fontsize=10)
    ax.set_ylim(0, 24)
    ax.axhline(y=22, color='gray', linestyle='--', alpha=0.5, label='Total = 22')
    ax.set_xticks([1, 5, 10, 15, 20])

    # Panel 2: Signature diagram
    ax = axes[1]
    ns_pos = [1] * 20
    ns_neg = [r - 1 for r in rho_values]
    t_pos = [2] * 20
    t_neg = [20 - r for r in rho_values]

    ax.plot(rho_values, ns_pos, 'b-o', markersize=4, label='NS⁺ (= 1, HIT)')
    ax.plot(rho_values, ns_neg, 'b--s', markersize=4, label='NS⁻ (= ρ-1)')
    ax.plot(rho_values, t_pos, 'r-o', markersize=4, label='T⁺ (= 2)')
    ax.plot(rho_values, t_neg, 'r--s', markersize=4, label='T⁻ (= 20-ρ)')

    ax.set_xlabel('Picard rank ρ', fontsize=12)
    ax.set_ylabel('Eigenvalue count', fontsize=12)
    ax.set_title('Signature Distribution', fontsize=14)
    ax.legend(fontsize=9, loc='center right')
    ax.set_xticks([1, 5, 10, 15, 20])

    # Panel 3: Hodge diamond for K3
    ax = axes[2]
    ax.set_xlim(-3, 3)
    ax.set_ylim(-0.5, 4.5)
    ax.set_aspect('equal')
    ax.axis('off')
    ax.set_title('K3 Hodge Diamond', fontsize=14)

    # Hodge numbers for K3: h^{p,q}
    diamond = {
        (0, 0): ('1', 2, 4),
        (1, 0): ('0', 1, 3),
        (0, 1): ('0', 3, 3),
        (2, 0): ('1', 0, 2),
        (1, 1): ('20', 2, 2),
        (0, 2): ('1', 4, 2),
        (2, 1): ('0', 1, 1),
        (1, 2): ('0', 3, 1),
        (2, 2): ('1', 2, 0),
    }

    for (p, q), (val, x, y) in diamond.items():
        color = '#2196F3' if p == q else '#FF9800'
        ax.text(x - 2, y, val, ha='center', va='center', fontsize=16,
                fontweight='bold', color=color,
                bbox=dict(boxstyle='round,pad=0.3', facecolor='white',
                         edgecolor=color, alpha=0.8))

    # Labels
    ax.text(-2.5, 2, 'h^{p,q}', ha='center', va='center', fontsize=12,
            fontstyle='italic', color='gray')
    blue_patch = mpatches.Patch(color='#2196F3', label='Hodge classes (p=q)')
    orange_patch = mpatches.Patch(color='#FF9800', label='Non-Hodge (p≠q)')
    ax.legend(handles=[blue_patch, orange_patch], fontsize=9, loc='lower center')

    plt.tight_layout()
    plt.savefig('hodge_k3_lattice.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: hodge_k3_lattice.png")


def plot_hodge_conjecture_landscape():
    """Plot the known/unknown landscape of the Hodge conjecture."""
    fig, ax = plt.subplots(figsize=(10, 7))

    # Abelian varieties: dimension g, cohomological degree 2p
    max_g = 8
    max_p = 8

    # Create grid
    known = np.zeros((max_g, max_p))
    for g in range(1, max_g + 1):
        for p in range(1, min(g, max_p) + 1):
            if p == 1:
                known[g-1, p-1] = 1  # Lefschetz (1,1)
            elif p == g:
                known[g-1, p-1] = 1  # Hard Lefschetz from p=1
            elif g <= 3:
                known[g-1, p-1] = 1  # Small dimensions
            elif g in [5, 7] and p == 1:
                known[g-1, p-1] = 1  # Prime dimension, p=1
            else:
                known[g-1, p-1] = 0.5  # Open

    # Custom colormap: green = known, yellow = open, gray = N/A
    cmap = plt.cm.colors.ListedColormap(['#f0f0f0', '#FFD54F', '#4CAF50'])
    bounds = [0, 0.25, 0.75, 1.25]
    norm = plt.cm.colors.BoundaryNorm(bounds, cmap.N)

    im = ax.imshow(known, cmap=cmap, norm=norm, aspect='equal')

    ax.set_xticks(range(max_p))
    ax.set_yticks(range(max_g))
    ax.set_xticklabels([f'H^{2*p}' for p in range(1, max_p + 1)])
    ax.set_yticklabels([f'g={g}' for g in range(1, max_g + 1)])
    ax.set_xlabel('Cohomological degree', fontsize=12)
    ax.set_ylabel('Abelian variety dimension', fontsize=12)
    ax.set_title('Hodge Conjecture for Abelian Varieties:\nKnown Cases', fontsize=14)

    # Add text labels
    for g in range(max_g):
        for p in range(max_p):
            if p < g + 1:
                if known[g, p] == 1:
                    ax.text(p, g, '✓', ha='center', va='center', fontsize=14,
                           color='white', fontweight='bold')
                elif known[g, p] == 0.5:
                    ax.text(p, g, '?', ha='center', va='center', fontsize=14,
                           color='black', fontweight='bold')

    # Legend
    green_patch = mpatches.Patch(color='#4CAF50', label='Known (proved)')
    yellow_patch = mpatches.Patch(color='#FFD54F', label='Open')
    gray_patch = mpatches.Patch(color='#f0f0f0', label='N/A (p > g)')
    ax.legend(handles=[green_patch, yellow_patch, gray_patch],
             loc='lower right', fontsize=10)

    plt.tight_layout()
    plt.savefig('hodge_conjecture_landscape.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: hodge_conjecture_landscape.png")


if __name__ == "__main__":
    plot_k3_lattice_decomposition()
    plot_hodge_conjecture_landscape()
    print("All visualizations generated.")


#!/usr/bin/env python3
"""
Visualization 2: Polarization Form and Orthogonal Decomposition

Illustrates the Q-orthogonal decomposition V = HC ⊕ T
and the Hodge index theorem signature constraints.
"""

import numpy as np
import matplotlib.pyplot as plt
from matplotlib.patches import FancyArrowPatch
from mpl_toolkits.mplot3d import Axes3D


def plot_orthogonal_decomposition_2d():
    """
    2D illustration of V = HC ⊕ T with Q-orthogonality.
    Shows that T ∩ HC = {0} when V = HC + T.
    """
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))

    # Left panel: Standard Q-orthogonal decomposition
    ax = axes[0]
    ax.set_xlim(-3, 3)
    ax.set_ylim(-3, 3)
    ax.set_aspect('equal')

    # HC subspace: x-axis
    ax.axhline(y=0, color='#2196F3', linewidth=2, label='Hodge classes (HC)')
    ax.arrow(-2.5, 0, 5, 0, head_width=0.1, head_length=0.1, fc='#2196F3', ec='#2196F3')

    # T subspace: y-axis (Q-orthogonal)
    ax.axvline(x=0, color='#FF9800', linewidth=2, label='Transcendental (T)')
    ax.arrow(0, -2.5, 0, 5, head_width=0.1, head_length=0.1, fc='#FF9800', ec='#FF9800')

    # Show decomposition of a vector
    v = np.array([2, 1.5])
    ax.plot(*v, 'ko', markersize=8, zorder=5)
    ax.annotate('v', v + np.array([0.1, 0.1]), fontsize=14)

    # Projections
    ax.plot([v[0], v[0]], [0, v[1]], 'k--', alpha=0.5)
    ax.plot([0, v[0]], [v[1], v[1]], 'k--', alpha=0.5)
    ax.plot(v[0], 0, 's', color='#2196F3', markersize=10, zorder=5)
    ax.annotate('v_HC', (v[0] + 0.1, -0.3), fontsize=12, color='#2196F3')
    ax.plot(0, v[1], 's', color='#FF9800', markersize=10, zorder=5)
    ax.annotate('v_T', (-0.5, v[1] + 0.1), fontsize=12, color='#FF9800')

    # Intersection point
    ax.plot(0, 0, 'r*', markersize=15, zorder=6)
    ax.annotate('T ∩ HC = {0}', (0.2, -0.5), fontsize=11, color='red',
               fontweight='bold')

    ax.set_title('Q-Orthogonal Decomposition\nV = HC ⊕ T', fontsize=14)
    ax.legend(fontsize=10, loc='upper left')
    ax.grid(True, alpha=0.3)

    # Right panel: Non-orthogonal case (Q degenerate on HC)
    ax = axes[1]
    ax.set_xlim(-3, 3)
    ax.set_ylim(-3, 3)
    ax.set_aspect('equal')

    # HC subspace: diagonal line
    t_vals = np.linspace(-3, 3, 100)
    ax.plot(t_vals, t_vals, color='#2196F3', linewidth=2, label='HC = span{(1,1)}')

    # T subspace (for Q with Q(e1,e1)=0, Q(e1,e2)=1): also diagonal!
    ax.plot(t_vals, t_vals * 1.0, color='#FF9800', linewidth=2, linestyle='--',
           label='T = span{(1,1)} (!)')

    # Show overlap
    ax.fill_between(t_vals, t_vals - 0.1, t_vals + 0.1, alpha=0.3, color='red')
    ax.annotate('T ∩ HC ≠ {0}\n(Q degenerate\non HC)',
               (1.5, 0.5), fontsize=11, color='red', fontweight='bold',
               bbox=dict(boxstyle='round', facecolor='lightyellow', alpha=0.8))

    ax.set_title('Degenerate Case\nT ∩ HC ≠ {0} possible!', fontsize=14)
    ax.legend(fontsize=10, loc='upper left')
    ax.grid(True, alpha=0.3)

    plt.suptitle('Transcendental-Hodge Disjointness\n'
                'Requires V = HC + T (spanning condition)',
                fontsize=15, fontweight='bold', y=1.02)
    plt.tight_layout()
    plt.savefig('polarization_decomposition.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: polarization_decomposition.png")


def plot_hodge_index_signature():
    """
    Visualize the Hodge index theorem signature for varying Picard rank.
    The positive part always has dimension 1 (by the Hodge index theorem).
    """
    fig, ax = plt.subplots(figsize=(10, 6))

    rho_values = list(range(1, 21))

    # For K3 surface: H^2 has signature (3, 19)
    # NS(X) has signature (1, ρ-1)
    # T(X) has signature (2, 20-ρ)

    # Stacked bar: positive and negative eigenvalues
    pos_ns = [1] * 20
    neg_ns = [r - 1 for r in rho_values]

    bars_pos = ax.bar(rho_values, pos_ns, color='#4CAF50', alpha=0.8,
                     label='Positive eigenvalues')
    bars_neg = ax.bar(rho_values, neg_ns, bottom=pos_ns, color='#F44336',
                     alpha=0.8, label='Negative eigenvalues')

    # Annotations
    ax.axhline(y=1, color='#4CAF50', linestyle='--', alpha=0.5)
    ax.annotate('Hodge Index = 1\n(always!)', (15, 1.3),
               fontsize=12, color='#4CAF50', fontweight='bold',
               bbox=dict(boxstyle='round', facecolor='white', alpha=0.8))

    ax.set_xlabel('Picard rank ρ', fontsize=13)
    ax.set_ylabel('Eigenvalue count of Q|_{NS}', fontsize=13)
    ax.set_title('Hodge Index Theorem for K3 Surfaces\n'
                'Q restricted to Picard lattice has signature (1, ρ−1)',
                fontsize=14)
    ax.legend(fontsize=11)
    ax.set_xticks([1, 5, 10, 15, 20])
    ax.set_ylim(0, 22)

    plt.tight_layout()
    plt.savefig('hodge_index_signature.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: hodge_index_signature.png")


def plot_proof_structure():
    """
    Visualize the logical structure of the Hodge conjecture proofs.
    """
    fig, ax = plt.subplots(figsize=(12, 8))
    ax.set_xlim(0, 12)
    ax.set_ylim(0, 10)
    ax.axis('off')

    # Theorem boxes
    theorems = {
        'Defs': (6, 9, '#E3F2FD', 'Definitions\nWeightTwoHS, AlgebraicData\nPolarizedHS, HodgeMorphism'),
        'RankOne': (3, 7, '#C8E6C9', 'rank_one_proportional\n1-dim ℚ-submodule\nproportionality'),
        'HCRank1': (3, 5, '#A5D6A7', 'hodgeConj_of_picard_rank_one\nHC holds for ρ = 1'),
        'QOrth': (9, 7, '#FFF9C4', 'qOrthogonal_symm\nQ-symmetry of\northogonal complement'),
        'TH': (9, 5, '#FFE082', 'transcendental_inter_\nhodge_eq_bot\nT ∩ HC = {0}'),
        'FullRank': (3, 3, '#B3E5FC', 'hodgeClasses_eq_top_of_\nfull_rank\nρ = dim(V) ⟹ HC = V'),
        'LevelZero': (3, 1, '#81D4FA', 'hodgeConj_of_level_zero\nHC trivial at level 0'),
        'Funct': (9, 3, '#FFCCBC', 'hodgeConj_functorial_surj\nHC transfers under\nsurjective morphisms'),
        'QTop': (9, 1, '#FFE0B2', 'qOrthogonal_top_eq_bot\nQ⊥(V) = {0}'),
    }

    for name, (x, y, color, text) in theorems.items():
        bbox = dict(boxstyle='round,pad=0.4', facecolor=color, edgecolor='gray',
                   linewidth=1.5)
        ax.text(x, y, text, ha='center', va='center', fontsize=8,
               bbox=bbox, fontfamily='monospace')

    # Arrows showing dependencies
    arrows = [
        ((6, 8.5), (3, 7.5)),    # Defs → RankOne
        ((6, 8.5), (9, 7.5)),    # Defs → QOrth
        ((3, 6.5), (3, 5.5)),    # RankOne → HCRank1
        ((9, 6.5), (9, 5.5)),    # QOrth → TH
        ((3, 4.5), (3, 3.5)),    # ... → FullRank
        ((3, 2.5), (3, 1.5)),    # FullRank → LevelZero
        ((6, 8.5), (9, 3.5)),    # Defs → Funct
    ]

    for start, end in arrows:
        ax.annotate('', xy=end, xytext=start,
                   arrowprops=dict(arrowstyle='->', color='gray',
                                 connectionstyle='arc3,rad=0.1'))

    ax.set_title('Proof Dependency Graph\nHodge Conjecture Formalization',
                fontsize=16, fontweight='bold', pad=20)

    plt.tight_layout()
    plt.savefig('proof_structure.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: proof_structure.png")


if __name__ == "__main__":
    plot_orthogonal_decomposition_2d()
    plot_hodge_index_signature()
    plot_proof_structure()
    print("All polarization visualizations generated.")
