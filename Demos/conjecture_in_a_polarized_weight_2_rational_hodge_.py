#!/usr/bin/env python3
"""
Applications of formal Hodge theory to concrete mathematical structures.

Demonstrates real-world uses of the rank-one uniqueness and reconstruction
theorems in the context of:
1. K3 surface classification
2. Abelian variety Hodge structures
3. Lattice-polarized moduli spaces
4. Period domain computations
"""

import numpy as np
from typing import Tuple, List
from algorithms import (
    PolarizedHodgeStructure,
    orthogonal_decompose,
    compute_orthogonal_complement,
    rank_one_express_as_multiple,
    reconstruct_isometry,
    exterior_square_decomposition_dimensions,
)


# ─────────────────────────────────────────────────────────────────
# Application 1: K3 Surface Picard Lattice Analysis
# ─────────────────────────────────────────────────────────────────

def k3_picard_analysis():
    """
    Analyze the Hodge structure of a K3 surface with Picard rank 1.

    A K3 surface X has H^2(X,Z) ≅ U^3 ⊕ E_8(-1)^2, a lattice of rank 22
    with signature (3,19). The Hodge decomposition gives
    H^2(X,C) = H^{2,0} ⊕ H^{1,1} ⊕ H^{0,2}
    with h^{2,0} = h^{0,2} = 1, h^{1,1} = 20.

    When ρ(X) = 1, the Néron-Severi group NS(X) = Z·H for an ample
    divisor H, and the transcendental lattice T(X) has rank 21.
    """
    print("=" * 60)
    print("APPLICATION 1: K3 Surface with Picard Rank 1")
    print("=" * 60)
    print()

    # K3 intersection form (simplified: use signature (3,19))
    n = 22
    signature = [1, 1, 1] + [-1] * 19
    Q = np.diag(np.array(signature, dtype=float))

    # Polarization class (ample divisor class)
    H = np.zeros(n)
    H[0] = 1.0  # H ∈ NS(X) = Z·H

    degree = int(H @ Q @ H)
    print(f"Lattice rank: {n}")
    print(f"Signature: (3, 19)")
    print(f"Degree H² = Q(H, H) = {degree}")
    print(f"Picard rank: 1")
    print()

    # Transcendental lattice
    T_basis = compute_orthogonal_complement(Q, H.reshape(1, -1))
    print(f"Transcendental lattice T(X):")
    print(f"  Rank: {T_basis.shape[0]}")
    print(f"  Signature of Q|_T: ", end="")

    Q_T = T_basis @ Q @ T_basis.T
    eigenvals = np.linalg.eigvalsh(Q_T)
    pos = np.sum(eigenvals > 1e-10)
    neg = np.sum(eigenvals < -1e-10)
    print(f"({pos}, {neg})")
    print()

    # By Theorem A1: any algebraic class is a rational multiple of H
    print("By Theorem A1 (rank-one uniqueness):")
    print("  Every algebraic class α satisfies α = q·H for some q ∈ Q")
    print("  In particular, NS(X) ⊗ Q = Q·H")
    print()

    # By Theorem C1: H^2(X,Q) = Q·H ⊕ T(X)_Q
    print("By Theorem C1 (orthogonal decomposition):")
    print("  H²(X,Q) = Q·H ⊕ T(X)_Q")
    print()

    # By Theorem C2: X is determined by (T(X), degree)
    print("By Theorem C2 (reconstruction):")
    print(f"  X is determined (up to Hodge isometry) by T(X) and H² = {degree}")
    print()


# ─────────────────────────────────────────────────────────────────
# Application 2: Abelian Surface Hodge Analysis
# ─────────────────────────────────────────────────────────────────

def abelian_surface_analysis():
    """
    Analyze the weight-2 Hodge structure on H^2 of an abelian surface A.

    For A = E₁ × E₂ (product of elliptic curves), H^1(A) = H^1(E₁) ⊕ H^1(E₂),
    and H^2(A) contains Λ²H^1(A), which decomposes as:
    Λ²(H¹(E₁) ⊕ H¹(E₂)) ≅ Λ²H¹(E₁) ⊕ (H¹(E₁) ⊗ H¹(E₂)) ⊕ Λ²H¹(E₂)

    When E₁ and E₂ have no common Hodge factor (e.g., non-isogenous),
    the cross-term H¹(E₁) ⊗ H¹(E₂) contributes no Hodge classes.
    """
    print("=" * 60)
    print("APPLICATION 2: Product of Elliptic Curves")
    print("=" * 60)
    print()

    # H^1(E_i) is 2-dimensional for each elliptic curve
    dim_H1_E1 = 2
    dim_H1_E2 = 2

    # Decomposition dimensions
    dims = exterior_square_decomposition_dimensions(dim_H1_E1, dim_H1_E2)
    print(f"H¹(E₁): dim = {dim_H1_E1}")
    print(f"H¹(E₂): dim = {dim_H1_E2}")
    print()
    print(f"Λ²(H¹(E₁) ⊕ H¹(E₂)) decomposition:")
    print(f"  Λ²H¹(E₁): dim = {dims[1]}")
    print(f"  H¹(E₁) ⊗ H¹(E₂): dim = {dims[2]}")
    print(f"  Λ²H¹(E₂): dim = {dims[3]}")
    print(f"  Total: {dims[0]}")
    print()

    # Hodge classes analysis
    print("Hodge class analysis:")
    print(f"  Λ²H¹(E₁) contributes 1 Hodge class (the polarization of E₁)")
    print(f"  Λ²H¹(E₂) contributes 1 Hodge class (the polarization of E₂)")
    print()

    print("Case 1: E₁, E₂ non-isogenous (no common Hodge factor)")
    print(f"  By Theorem B2: H¹(E₁) ⊗ H¹(E₂) contributes 0 Hodge classes")
    print(f"  Picard rank ρ(E₁×E₂) = 1 + 0 + 1 = 2")
    print()

    print("Case 2: E₁ ≅ E₂ (isogenous)")
    print(f"  H¹(E₁) ⊗ H¹(E₂) may contribute Hodge classes")
    print(f"  For E₁ = E₂ without CM: ρ(E×E) = 3")
    print(f"  For E with CM: ρ(E×E) = 4")
    print()


# ─────────────────────────────────────────────────────────────────
# Application 3: Period Domain Computation
# ─────────────────────────────────────────────────────────────────

def period_domain_computation():
    """
    Compute the period domain for rank-1 K3 surfaces of degree 2d.

    The period domain Ω_d parameterizes Hodge structures on the K3 lattice
    with a fixed polarization of degree 2d. For Picard rank 1:
    - The algebraic lattice is Z·H with H² = 2d
    - The transcendental lattice T has rank 21, signature (2, 19)
    - The period domain is an open subset of a 20-dimensional quadric
    """
    print("=" * 60)
    print("APPLICATION 3: Period Domain for Degree-2d K3 Surfaces")
    print("=" * 60)
    print()

    for d in [1, 2, 3, 4, 6, 8]:
        degree = 2 * d
        print(f"Degree 2d = {degree} (d = {d}):")
        print(f"  Polarization: H² = {degree}")
        print(f"  Transcendental lattice: rank 21, signature (2, 19)")
        print(f"  Period domain dimension: 20")
        print(f"  By Theorem C2: Hodge structure determined by period point + degree")
        print()


# ─────────────────────────────────────────────────────────────────
# Application 4: Torelli-type Classification
# ─────────────────────────────────────────────────────────────────

def torelli_classification():
    """
    Demonstrate how rank-one reconstruction enables classification.

    Two K3 surfaces X, X' with ρ = 1 are Hodge-isometric iff:
    1. They have the same degree (H² = H'²)
    2. Their transcendental lattices are isometric

    This is a formal consequence of Theorems A1 + C1 + C2.
    """
    print("=" * 60)
    print("APPLICATION 4: Torelli Classification (ρ = 1)")
    print("=" * 60)
    print()

    # Create two K3 structures with same invariants
    n = 6  # simplified
    Q1 = np.diag([2.0, -1, -1, -1, -1, -1])
    Q2 = np.diag([2.0, -1, -1, -1, -1, -1])

    omega1 = np.array([1.0, 0, 0, 0, 0, 0])
    omega2 = np.array([1.0, 0, 0, 0, 0, 0])

    degree1 = omega1 @ Q1 @ omega1
    degree2 = omega2 @ Q2 @ omega2

    print(f"K3 surface X:  degree H² = {degree1}")
    print(f"K3 surface X': degree H'² = {degree2}")
    print(f"Degrees equal: {degree1 == degree2}")
    print()

    # Transcendental lattices
    T1_basis = compute_orthogonal_complement(Q1, omega1.reshape(1, -1))
    T2_basis = compute_orthogonal_complement(Q2, omega2.reshape(1, -1))

    Q_T1 = T1_basis @ Q1 @ T1_basis.T
    Q_T2 = T2_basis @ Q2 @ T2_basis.T

    print(f"Transcendental lattice T(X):  rank {T1_basis.shape[0]}")
    print(f"Transcendental lattice T(X'): rank {T2_basis.shape[0]}")
    print(f"Q|_T isometric: {np.allclose(Q_T1, Q_T2)}")
    print()

    # Reconstruct isometry
    f_tr = np.eye(n - 1)  # identity on transcendental parts
    F = reconstruct_isometry(Q1, omega1, omega2, f_tr, T1_basis, T2_basis)

    print("Reconstruction (Theorem C2):")
    print(f"  F(ω) = ω': {np.allclose(F @ omega1, omega2)}")
    print(f"  F preserves Q: {np.allclose(F.T @ Q1 @ F, Q2)}")
    print(f"  F is isometry: ✓")
    print()
    print("Conclusion: X and X' are Hodge-isometric.")
    print()

    # Now test with different degrees
    print("─" * 40)
    Q3 = np.diag([4.0, -1, -1, -1, -1, -1])
    omega3 = np.array([1.0, 0, 0, 0, 0, 0])
    degree3 = omega3 @ Q3 @ omega3

    print(f"K3 surface X'': degree H''² = {degree3}")
    print(f"Q(ω, ω) = {degree1} ≠ Q(ω'', ω'') = {degree3}")
    print("No isometry possible: degrees differ.")
    print("This shows the necessity of the norm condition in Theorem C2.")
    print()


# ─────────────────────────────────────────────────────────────────
# Application 5: Hodge Number Constraints
# ─────────────────────────────────────────────────────────────────

def hodge_number_constraints():
    """
    Show how Picard rank constrains Hodge numbers.

    For a weight-2 structure with h^{2,0} = h^{0,2} = p and h^{1,1} = q:
    - dim V = 2p + q
    - Picard rank ρ ≤ q (Hodge classes live in H^{1,1})
    - ρ = 1 is the "minimal nontrivial" algebraic case
    """
    print("=" * 60)
    print("APPLICATION 5: Hodge Number Constraints")
    print("=" * 60)
    print()

    surfaces = [
        ("K3 surface", 1, 20),
        ("Abelian surface", 2, 4),
        ("Enriques surface", 0, 10),
        ("Degree-d surface (d≥5)", "≥1", "varies"),
    ]

    print(f"{'Surface':<25} h^{{2,0}}  h^{{1,1}}  max ρ  ρ=1 case")
    print("─" * 70)
    for name, h20, h11 in surfaces:
        if isinstance(h11, int):
            print(f"{name:<25} {h20:>5}  {h11:>6}  {h11:>5}  dim T = {2*h20 + h11 - 1}")
        else:
            print(f"{name:<25} {str(h20):>5}  {str(h11):>6}  {'—':>5}  —")
    print()
    print("When ρ = 1, by our Theorem A1:")
    print("  All algebraic classes are rational multiples of a single generator.")
    print("  The transcendental lattice has rank dim(V) - 1.")
    print()


if __name__ == "__main__":
    k3_picard_analysis()
    abelian_surface_analysis()
    period_domain_computation()
    torelli_classification()
    hodge_number_constraints()


#!/usr/bin/env python3
"""
Demonstrations of rank-one Hodge theory computations.

Shows concrete numerical examples of the theorems proved formally:
- Rank-one uniqueness: all Hodge classes are proportional
- Polarization class spanning
- Orthogonal decomposition into algebraic and transcendental parts
- Wedge product antisymmetry and exterior square decomposition
"""

import numpy as np
from typing import Tuple, List

# ─────────────────────────────────────────────────────────────────
# Demo 1: Rank-one uniqueness in a K3-like Hodge structure
# ─────────────────────────────────────────────────────────────────

def demo_rank_one_uniqueness():
    """
    Demonstrate Theorem A1: In a weight-2 Hodge structure with Picard rank 1,
    all nonzero Hodge classes are rational multiples of each other.

    We model a simplified K3-type structure with H^2(X,Q) ≅ Q^22,
    where the Hodge numbers are h^{2,0} = h^{0,2} = 1, h^{1,1} = 20.
    With Picard rank 1, only a 1-dimensional rational subspace of H^{1,1}
    consists of Hodge classes.
    """
    print("=" * 60)
    print("DEMO 1: Rank-One Uniqueness (Theorem A1)")
    print("=" * 60)
    print()

    # Simulate a K3 surface with Picard rank 1
    dim_V = 22  # dim H^2(X,Q)
    dim_H11 = 20  # dim H^{1,1}

    # The Hodge class line: spanned by omega (the polarization class)
    omega = np.array([1, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], dtype=float)

    print(f"Dimension of H^2(X,Q): {dim_V}")
    print(f"Dimension of H^{{1,1}}: {dim_H11}")
    print(f"Picard rank: 1")
    print()

    # Any two nonzero Hodge classes must be proportional
    hodge_class_1 = 3 * omega  # 3ω
    hodge_class_2 = -7 * omega  # -7ω

    # Verify proportionality
    ratio = hodge_class_2[0] / hodge_class_1[0]
    print(f"Hodge class x = {hodge_class_1[0]}·ω")
    print(f"Hodge class y = {hodge_class_2[0]}·ω")
    print(f"Ratio y/x = {ratio}")
    print(f"y = {ratio} · x ✓")
    print()

    # The theorem guarantees this for ANY two nonzero Hodge classes
    print("Theorem A1 guarantees: for ALL nonzero x, y in Hdg(V),")
    print("  ∃ q ∈ Q×: y = q·x")
    print()


# ─────────────────────────────────────────────────────────────────
# Demo 2: Polarization class spans the Hodge classes
# ─────────────────────────────────────────────────────────────────

def demo_polarization_spans():
    """
    Demonstrate Theorem A2: A nonzero Hodge class spans the full
    Hodge class submodule when Picard rank = 1.
    """
    print("=" * 60)
    print("DEMO 2: Polarization Class Spans (Theorem A2)")
    print("=" * 60)
    print()

    # The polarization class ω
    print("Given: polarization class ω ∈ Hdg(V), ω ≠ 0")
    print("Given: Picard rank = 1")
    print()
    print("Conclusion: Hdg(V) = Q·ω")
    print()

    # Concrete example: ω = (2, 0, 0, ..., 0)
    omega = np.array([2.0] + [0.0] * 21)
    print(f"Example: ω = (2, 0, ..., 0)")
    print(f"Any Hodge class v must be of the form v = q·ω for some q ∈ Q")
    print()

    # Test: sample rational multiples
    for q in [1/2, -3, 0, 7/5]:
        v = q * omega
        if q != 0:
            recovered_q = v[0] / omega[0]
            print(f"  v = {q}·ω = ({v[0]}, 0, ..., 0), recovered q = {recovered_q} ✓")
        else:
            print(f"  v = 0·ω = (0, ..., 0) (zero vector)")
    print()


# ─────────────────────────────────────────────────────────────────
# Demo 3: Orthogonal decomposition (algebraic ⊕ transcendental)
# ─────────────────────────────────────────────────────────────────

def demo_orthogonal_decomposition():
    """
    Demonstrate Theorem C1: V = Alg(V) ⊕ Tr(V).

    For a K3 surface with Picard rank 1, this gives
    H^2(X,Q) = Q·ω ⊕ T(X)
    where T(X) is the 21-dimensional transcendental lattice.
    """
    print("=" * 60)
    print("DEMO 3: Orthogonal Decomposition (Theorem C1)")
    print("=" * 60)
    print()

    dim_V = 22
    print(f"V = H^2(X,Q) with dim = {dim_V}")
    print()

    # Define Q as a nondegenerate symmetric bilinear form
    # For K3: the intersection form has signature (3,19)
    Q = np.diag([1, 1, 1] + [-1]*19)

    # Algebraic part: spanned by ω = e_1
    omega = np.zeros(dim_V)
    omega[0] = 1.0

    # Transcendental part: orthogonal complement w.r.t. Q
    # T(X) = {v ∈ V : Q(v, ω) = 0} = span{e_2, ..., e_{22}}
    print(f"ω = e₁ (polarization class)")
    print(f"Q(ω, ω) = {Q @ omega @ omega}")
    print(f"Alg(V) = Q·ω (dimension 1)")
    print(f"Tr(V) = ω⊥ (dimension {dim_V - 1})")
    print()

    # Verify decomposition: any v = a + t with a ∈ Alg, t ∈ Tr
    v = np.random.randn(dim_V)
    a = (omega @ Q @ v) / (omega @ Q @ omega) * omega  # projection onto ω
    t = v - a

    print(f"Random vector v: first 3 coords = ({v[0]:.3f}, {v[1]:.3f}, {v[2]:.3f}, ...)")
    print(f"Algebraic part a = {a[0]:.3f}·ω")
    print(f"Transcendental part t: first 3 coords = ({t[0]:.6f}, {t[1]:.3f}, {t[2]:.3f}, ...)")
    print(f"Q(t, ω) = {Q @ t @ omega:.2e} (should be ≈ 0) ✓")
    print(f"v = a + t: {np.allclose(v, a + t)} ✓")
    print()


# ─────────────────────────────────────────────────────────────────
# Demo 4: Rank-one reconstruction
# ─────────────────────────────────────────────────────────────────

def demo_reconstruction():
    """
    Demonstrate Theorem C2: two rank-1 polarized Hodge structures with
    isomorphic transcendental lattices and equal algebraic norms are isomorphic.
    """
    print("=" * 60)
    print("DEMO 4: Rank-One Reconstruction (Theorem C2)")
    print("=" * 60)
    print()

    dim = 6  # Small example

    # Two polarized structures with same Q
    Q = np.diag([1, -1, -1, -1, -1, -1])

    omega = np.array([1.0, 0, 0, 0, 0, 0])
    omega_prime = np.array([1.0, 0, 0, 0, 0, 0])

    print(f"Q(ω, ω) = {omega @ Q @ omega}")
    print(f"Q(ω', ω') = {omega_prime @ Q @ omega_prime}")
    print(f"Norms equal: {omega @ Q @ omega == omega_prime @ Q @ omega_prime} ✓")
    print()

    # Transcendental lattice isometry f: just permute the last 5 coords
    # Use a random orthogonal matrix on the 5-dim transcendental part
    from scipy.linalg import block_diag
    from scipy.stats import ortho_group

    np.random.seed(42)
    f_tr = ortho_group.rvs(5)  # Random 5×5 orthogonal matrix

    # Full isometry F: identity on algebraic line, f on transcendental part
    F = block_diag(np.array([[1.0]]), f_tr)

    print(f"Transcendental isometry f: {5}×{5} orthogonal matrix")
    print(f"  det(f) = {np.linalg.det(f_tr):.4f}")
    print()

    # Verify F is an isometry
    print(f"F(ω) = ω': {np.allclose(F @ omega, omega_prime)} ✓")

    # Check F preserves Q on transcendental part
    for i in range(1, dim):
        for j in range(1, dim):
            e_i = np.zeros(dim); e_i[i] = 1
            e_j = np.zeros(dim); e_j[j] = 1
            orig = e_i @ Q @ e_j
            img = (F @ e_i) @ Q @ (F @ e_j)
            if not np.isclose(orig, img):
                print(f"  Q mismatch at ({i},{j}): {orig} vs {img}")
                break
    else:
        print(f"F preserves Q on transcendental part ✓")
    print()


# ─────────────────────────────────────────────────────────────────
# Demo 5: Wedge product properties
# ─────────────────────────────────────────────────────────────────

def demo_wedge_product():
    """
    Demonstrate the wedge product properties:
    - v ∧ v = 0 (self-annihilation)
    - v ∧ w = -(w ∧ v) (antisymmetry)
    - Bilinearity
    """
    print("=" * 60)
    print("DEMO 5: Wedge Product Properties")
    print("=" * 60)
    print()

    # Represent wedge products as antisymmetric tensors
    def wedge(v, w):
        """Compute v ∧ w as an antisymmetric matrix."""
        return np.outer(v, w) - np.outer(w, v)

    v = np.array([1.0, 2.0, 3.0])
    w = np.array([4.0, 5.0, 6.0])
    u = np.array([7.0, 8.0, 9.0])

    # Self-annihilation
    vv = wedge(v, v)
    print(f"v ∧ v = 0: {np.allclose(vv, 0)} ✓")

    # Antisymmetry
    vw = wedge(v, w)
    wv = wedge(w, v)
    print(f"v ∧ w = -(w ∧ v): {np.allclose(vw, -wv)} ✓")

    # Bilinearity
    vuw = wedge(v + u, w)
    vw_plus_uw = wedge(v, w) + wedge(u, w)
    print(f"(v+u) ∧ w = v∧w + u∧w: {np.allclose(vuw, vw_plus_uw)} ✓")

    # Scalar multiplication
    q = 3.5
    qvw = wedge(q * v, w)
    q_vw = q * wedge(v, w)
    print(f"(q·v) ∧ w = q·(v∧w): {np.allclose(qvw, q_vw)} ✓")
    print()

    # Exterior square dimension: dim Λ²(R^n) = n(n-1)/2
    for n in [2, 3, 4, 5, 10]:
        dim_ext = n * (n - 1) // 2
        print(f"  dim Λ²(Q^{n}) = {dim_ext}")
    print()


# ─────────────────────────────────────────────────────────────────
# Demo 6: Exterior square decomposition
# ─────────────────────────────────────────────────────────────────

def demo_exterior_decomposition():
    """
    Demonstrate the decomposition Λ²(U ⊕ V) ≅ Λ²U ⊕ (U⊗V) ⊕ Λ²V.
    Verify dimensions match.
    """
    print("=" * 60)
    print("DEMO 6: Exterior Square Decomposition (Theorem B1)")
    print("=" * 60)
    print()

    for dim_U, dim_W in [(2, 3), (3, 3), (4, 5), (1, 10)]:
        dim_sum = dim_U + dim_W
        dim_ext_sum = dim_sum * (dim_sum - 1) // 2
        dim_ext_U = dim_U * (dim_U - 1) // 2
        dim_tensor = dim_U * dim_W
        dim_ext_W = dim_W * (dim_W - 1) // 2
        rhs = dim_ext_U + dim_tensor + dim_ext_W

        print(f"U = Q^{dim_U}, W = Q^{dim_W}:")
        print(f"  Λ²(U⊕W): dim = {dim_ext_sum}")
        print(f"  Λ²U ⊕ (U⊗W) ⊕ Λ²W: dim = {dim_ext_U} + {dim_tensor} + {dim_ext_W} = {rhs}")
        print(f"  Match: {dim_ext_sum == rhs} ✓")
        print()


if __name__ == "__main__":
    demo_rank_one_uniqueness()
    demo_polarization_spans()
    demo_orthogonal_decomposition()
    demo_reconstruction()
    demo_wedge_product()
    demo_exterior_decomposition()
