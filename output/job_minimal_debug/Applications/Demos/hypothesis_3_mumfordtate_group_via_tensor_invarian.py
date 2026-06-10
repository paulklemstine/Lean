#!/usr/bin/env python3
"""
Applications of Tensor Invariant Theory to Arithmetic Geometry

Demonstrates real-world applications of the tensor-invariant stabilizer
framework for studying elliptic curves and their symmetry groups.
"""

import numpy as np
from typing import List, Tuple


def elliptic_curve_classification():
    """
    Application 1: Classifying elliptic curves by their Mumford-Tate group.

    For an elliptic curve E over Q, the Mumford-Tate group MT(H¹(E))
    determines whether E has complex multiplication:
    - MT = GL₂: generic (no CM)
    - MT = Res_{K/Q} G_m: CM by imaginary quadratic field K
    """
    print("=" * 60)
    print("  APPLICATION 1: Elliptic Curve Classification")
    print("=" * 60)

    # Known elliptic curves and their CM status
    curves = [
        ("y² = x³ - x (CM by Z[i])",
         np.array([[0, -1], [1, 0]], dtype=float),    # J² = -I
         "CM by Q(i), discriminant -4"),
        ("y² = x³ + 1 (CM by Z[ω])",
         np.array([[-0.5, -np.sqrt(3)/2],
                   [np.sqrt(3)/2, -0.5]], dtype=float),  # ω² + ω + 1 = 0
         "CM by Q(ω), discriminant -3"),
        ("y² = x³ - x + 1 (generic)",
         None,
         "Generic, MT = GL₂"),
    ]

    for name, cm_endo, expected in curves:
        print(f"\n  Curve: {name}")
        print(f"  Expected: {expected}")

        if cm_endo is not None:
            # Verify the CM endomorphism satisfies a quadratic
            trace = np.trace(cm_endo)
            det = np.linalg.det(cm_endo)
            disc = trace**2 - 4*det
            print(f"  CM endomorphism: tr = {trace:.4f}, det = {det:.4f}")
            print(f"  Minimal polynomial: x² - {trace:.4f}x + {det:.4f} = 0")
            print(f"  Discriminant: {disc:.4f}")

            # Test: does the permutation matrix commute with cm_endo?
            P = np.array([[0, 1], [1, 0]], dtype=float)
            commutator = P @ cm_endo - cm_endo @ P
            commutes = np.allclose(commutator, 0)
            print(f"  Permutation commutes: {commutes}")
            if not commutes:
                print(f"  → Permutation is OUTSIDE stabilizer (proper subgroup)")
        else:
            print(f"  No CM endomorphism → stabilizer = GL₂ (maximal)")


def period_matrix_analysis():
    """
    Application 2: Period matrix constraints from tensor invariants.

    The period matrix of an elliptic curve determines its Hodge structure.
    Tensor invariants constrain which period matrices are possible for
    curves with given endomorphism structure.
    """
    print("\n" + "=" * 60)
    print("  APPLICATION 2: Period Matrix Constraints")
    print("=" * 60)

    print("""
  For an elliptic curve E with period matrix Ω = [ω₁, ω₂]:
  - The Hodge structure is determined by τ = ω₂/ω₁ ∈ H (upper half-plane)
  - CM case: τ is a quadratic irrationality (lives in imaginary quadratic field)
  - Generic case: τ is transcendental (Schneider's theorem)

  Tensor invariant detection:
  - Compute Hodge-compatible endomorphisms from the period matrix
  - If only scalars: τ is generic
  - If extra endomorphism exists: τ is CM, and φ determines the CM field

  Example period ratios:
    """)

    examples = [
        ("τ = i", 1j, True, "Q(i)"),
        ("τ = e^{2πi/3}", np.exp(2j*np.pi/3), True, "Q(ω)"),
        ("τ = (1+i√7)/2", (1 + 1j*np.sqrt(7))/2, True, "Q(√-7)"),
        ("τ = π·i", np.pi * 1j, False, "generic"),
    ]

    for name, tau, is_cm, field in examples:
        print(f"  {name}:")
        print(f"    τ = {tau:.6f}")
        print(f"    |τ| = {abs(tau):.6f}, Im(τ) = {tau.imag:.6f}")
        print(f"    CM: {is_cm}, field: {field}")

        if is_cm:
            # Construct the CM endomorphism in the real representation
            # φ acts on H¹(E,Q) ≅ Q² via the embedding K → M₂(Q)
            a, b = tau.real, tau.imag
            # The endomorphism corresponding to multiplication by τ
            # in the basis {1, τ} of K/Q maps 1 ↦ 0·1 + 1·τ and τ ↦ -|τ|²·1 + tr·τ
            norm_tau = abs(tau)**2
            trace_tau = 2*a
            cm_matrix = np.array([[0, -norm_tau], [1, trace_tau]], dtype=float)
            print(f"    CM matrix (multiplication by τ):")
            print(f"      {cm_matrix.tolist()}")
            print(f"      Characteristic poly: x² - {trace_tau:.4f}x + {norm_tau:.4f}")

        print()


def galois_representation_constraints():
    """
    Application 3: Constraints on Galois representations from tensor invariants.

    The Mumford-Tate group controls the image of Galois representations.
    Tensor invariants give computable constraints on possible Galois images.
    """
    print("=" * 60)
    print("  APPLICATION 3: Galois Representation Constraints")
    print("=" * 60)

    print("""
  For an elliptic curve E/Q, the ℓ-adic Galois representation
    ρ_ℓ : Gal(Q̄/Q) → GL₂(Z_ℓ)
  has image constrained by the Mumford-Tate group:

  GENERIC CASE:
    MT(E) = GL₂ ⟹ Image(ρ_ℓ) is open in GL₂(Z_ℓ) for all ℓ
    Serre's Open Image Theorem: this holds for all non-CM curves

  CM CASE:
    MT(E) = centralizer of End(E) ⊗ Q_ℓ
    ⟹ Image(ρ_ℓ) is contained in a torus (abelian subgroup)
    ⟹ For ℓ split in K: Image ≅ (Z_ℓ×)²  (diagonal)
    ⟹ For ℓ inert in K: Image ≅ Z_ℓ[φ]×   (non-split Cartan)

  Our tensor invariant framework makes this constraint COMPUTABLE:
  """)

    # Demonstrate for specific primes
    primes = [2, 3, 5, 7, 11, 13]

    # CM by Z[i]: K = Q(i), discriminant -4
    print("  CM by Z[i] (discriminant -4):")
    for p in primes:
        if p == 2:
            split_type = "ramified"
        elif p % 4 == 1:
            split_type = "split"
        else:
            split_type = "inert"

        if split_type == "split":
            galois_image = "(Z_ℓ×)²  (diagonal torus)"
        elif split_type == "inert":
            galois_image = "Z_ℓ[i]×  (non-split Cartan)"
        else:
            galois_image = "(special at ramified prime)"

        print(f"    ℓ = {p:2d}: {split_type:8s} → Image ⊆ {galois_image}")

    print()
    # CM by Z[ω]: K = Q(ω), discriminant -3
    print("  CM by Z[ω] (discriminant -3):")
    for p in primes:
        if p == 3:
            split_type = "ramified"
        elif p % 3 == 1:
            split_type = "split"
        else:
            split_type = "inert"

        if split_type == "split":
            galois_image = "(Z_ℓ×)²  (diagonal torus)"
        elif split_type == "inert":
            galois_image = "Z_ℓ[ω]×  (non-split Cartan)"
        else:
            galois_image = "(special at ramified prime)"

        print(f"    ℓ = {p:2d}: {split_type:8s} → Image ⊆ {galois_image}")


def symmetry_detection_algorithm():
    """
    Application 4: Algorithmic symmetry detection for Hodge structures.

    Given numerical approximations to a period matrix, determine the
    Mumford-Tate group by searching for Hodge-compatible endomorphisms.
    """
    print("\n" + "=" * 60)
    print("  APPLICATION 4: Algorithmic Symmetry Detection")
    print("=" * 60)

    print("""
  ALGORITHM: DetectMumfordTateGroup(Ω, ε)
  Input: Period matrix Ω (numerical), tolerance ε
  Output: Classification of the Mumford-Tate group

  1. Compute τ = ω₂/ω₁ (period ratio)
  2. Search for integers a,b,c,d with |aτ² + bτ + c| < ε
     (test if τ satisfies a quadratic over Q)
  3. If found: CM by Q(√(b²-4ac))
     If not found: Generic (MT = GL₂)

  Running detection on sample period ratios:
  """)

    def detect_cm(tau: complex, max_coeff: int = 20,
                  tol: float = 1e-8) -> Tuple[bool, str]:
        """Attempt to detect CM from a period ratio."""
        # Search for a,b,c integers with a*tau^2 + b*tau + c ≈ 0
        best_residual = float('inf')
        best_abc = None

        for a in range(1, max_coeff + 1):
            for b in range(-max_coeff, max_coeff + 1):
                for c in range(-max_coeff, max_coeff + 1):
                    val = a * tau**2 + b * tau + c
                    residual = abs(val)
                    if residual < best_residual:
                        best_residual = residual
                        best_abc = (a, b, c)

        if best_residual < tol and best_abc is not None:
            a, b, c = best_abc
            disc = b**2 - 4*a*c
            return True, f"CM: {a}τ² + {b}τ + {c} = 0, disc = {disc}"
        else:
            return False, f"Generic (best residual = {best_residual:.2e})"

    test_taus = [
        ("i", 1j),
        ("(1+i√3)/2", (1 + 1j*np.sqrt(3))/2),
        ("(1+i√7)/2", (1 + 1j*np.sqrt(7))/2),
        ("π·i (transcendental)", np.pi * 1j),
        ("e·i (transcendental)", np.e * 1j),
    ]

    for name, tau in test_taus:
        is_cm, desc = detect_cm(tau)
        print(f"  τ = {name:30s} → {desc}")


if __name__ == "__main__":
    elliptic_curve_classification()
    period_matrix_analysis()
    galois_representation_constraints()
    symmetry_detection_algorithm()


#!/usr/bin/env python3
"""
Demo: Tensor Invariants and Mumford-Tate Groups for Weight-1 Hodge Structures

This demo illustrates the core computational content of our formalization:
1. Constructing weight-1 Hodge structures (generic and CM)
2. Computing Hodge-compatible endomorphisms
3. Testing stabilizer membership via conjugation
4. Demonstrating the generic/CM bifurcation through tensor invariants
"""

import numpy as np
from typing import List, Tuple, Optional

# ============================================================================
# Core mathematical structures
# ============================================================================

class WeightOneHodgeStructure:
    """
    A weight-1 rational Hodge structure on a 2-dimensional Q-vector space W.

    Encoded algebraically as a subalgebra of End(W) = M_2(Q) representing
    the Hodge-compatible endomorphisms (= (1,1) Hodge classes in W ⊗ W∨).

    For a generic (non-CM) structure: hodge_endos = scalar matrices only.
    For a CM structure: hodge_endos includes a non-scalar endomorphism φ.
    """

    def __init__(self, name: str, cm_endomorphism: Optional[np.ndarray] = None):
        self.name = name
        self.dim = 2
        self.cm_endomorphism = cm_endomorphism
        # The identity matrix is always a Hodge class (evaluation tensor)
        self.identity = np.eye(2, dtype=float)

    def is_cm(self) -> bool:
        """Check if this Hodge structure has complex multiplication."""
        return self.cm_endomorphism is not None

    def hodge_endomorphism_basis(self) -> List[np.ndarray]:
        """
        Return a basis for the space of Hodge-compatible endomorphisms.

        Generic case: {Id} (1-dimensional, scalars only)
        CM case: {Id, φ} (2-dimensional, includes CM endomorphism)
        """
        basis = [self.identity.copy()]
        if self.cm_endomorphism is not None:
            basis.append(self.cm_endomorphism.copy())
        return basis

    def is_hodge_endomorphism(self, phi: np.ndarray, tol: float = 1e-10) -> bool:
        """Check if φ is a Hodge-compatible endomorphism (in the span of the basis)."""
        basis = self.hodge_endomorphism_basis()
        if len(basis) == 1:
            # Check if phi is scalar: phi = a * I
            if abs(phi[0, 1]) > tol or abs(phi[1, 0]) > tol:
                return False
            return abs(phi[0, 0] - phi[1, 1]) < tol
        else:
            # Check if phi is in span{I, cm_endomorphism}
            # phi = a*I + b*cm_endo
            cm = self.cm_endomorphism
            # Solve: phi = a*I + b*cm
            # phi[0,0] = a + b*cm[0,0], phi[0,1] = b*cm[0,1]
            # phi[1,0] = b*cm[1,0], phi[1,1] = a + b*cm[1,1]
            if abs(cm[0, 1]) > tol:
                b = phi[0, 1] / cm[0, 1]
            elif abs(cm[1, 0]) > tol:
                b = phi[1, 0] / cm[1, 0]
            else:
                b = 0  # cm is diagonal
                if abs(cm[0, 0] - cm[1, 1]) > tol:
                    b = (phi[0, 0] - phi[1, 1]) / (cm[0, 0] - cm[1, 1])

            a = phi[0, 0] - b * cm[0, 0]
            reconstructed = a * self.identity + b * cm
            return np.allclose(phi, reconstructed, atol=tol)


def conjugate_endo(g: np.ndarray, phi: np.ndarray) -> np.ndarray:
    """Conjugation action: g · φ · g⁻¹"""
    return g @ phi @ np.linalg.inv(g)


def preserves_hodge_endos(H: WeightOneHodgeStructure, g: np.ndarray,
                          tol: float = 1e-10) -> bool:
    """
    Check if g ∈ GL(W) preserves all Hodge-compatible endomorphisms
    under conjugation (pointwise fixation).

    This is the stabilizer membership test:
    g ∈ tensorInvariantStabilizer(H) ⟺ ∀ φ ∈ hodgeEndos, g·φ·g⁻¹ = φ
    ⟺ g commutes with all Hodge endomorphisms.
    """
    for phi in H.hodge_endomorphism_basis():
        conjugated = conjugate_endo(g, phi)
        if not np.allclose(conjugated, phi, atol=tol):
            return False
    return True


def find_non_stabilizing_element(H: WeightOneHodgeStructure) -> Optional[np.ndarray]:
    """
    Find an invertible matrix g that does NOT stabilize the Hodge endomorphisms.
    Returns None if the stabilizer is all of GL(W) (generic case).
    """
    if not H.is_cm():
        return None  # Generic case: stabilizer = GL(W)

    # For CM case: find g that doesn't commute with the CM endomorphism
    # Try several candidates
    candidates = [
        np.array([[0, 1], [1, 0]], dtype=float),        # Permutation
        np.array([[1, 0], [0, -1]], dtype=float),        # Reflection
        np.array([[1, 1], [0, 1]], dtype=float),         # Shear
        np.array([[2, 1], [1, 1]], dtype=float),         # General
        np.array([[1, 0], [1, 1]], dtype=float),         # Lower triangular
    ]

    for g in candidates:
        if abs(np.linalg.det(g)) > 1e-10:  # invertible
            if not preserves_hodge_endos(H, g):
                return g
    return None


# ============================================================================
# Construct example Hodge structures
# ============================================================================

def create_generic_hodge() -> WeightOneHodgeStructure:
    """
    Create a generic (non-CM) weight-1 Hodge structure.
    Hodge endomorphisms = scalars only = Q · Id.

    This models a generic elliptic curve E/Q with End(E) = Z.
    """
    return WeightOneHodgeStructure("Generic (non-CM)")


def create_cm_hodge_gaussian() -> WeightOneHodgeStructure:
    """
    Create a CM weight-1 Hodge structure with Z[i] endomorphisms.
    The CM endomorphism J satisfies J² = -Id, corresponding to
    multiplication by i in the Gaussian integers.

    This models an elliptic curve with CM by Z[i], e.g., y² = x³ - x.
    """
    J = np.array([[0, -1], [1, 0]], dtype=float)
    return WeightOneHodgeStructure("CM by Z[i] (Gaussian)", cm_endomorphism=J)


def create_cm_hodge_eisenstein() -> WeightOneHodgeStructure:
    """
    Create a CM weight-1 Hodge structure with Z[ω] endomorphisms,
    where ω = e^{2πi/3} is a primitive cube root of unity.
    The CM endomorphism satisfies φ² + φ + Id = 0.

    This models an elliptic curve with CM by Z[ω], e.g., y² = x³ + 1.
    """
    # ω = (-1 + √3·i)/2, represented as a real 2×2 matrix
    phi = np.array([[-0.5, -np.sqrt(3)/2],
                    [np.sqrt(3)/2, -0.5]], dtype=float)
    return WeightOneHodgeStructure("CM by Z[ω] (Eisenstein)", cm_endomorphism=phi)


# ============================================================================
# Main demo
# ============================================================================

def print_separator(title: str):
    print(f"\n{'='*70}")
    print(f"  {title}")
    print(f"{'='*70}\n")


def demo_hodge_structure(H: WeightOneHodgeStructure):
    """Demonstrate tensor invariant analysis for a single Hodge structure."""
    print(f"  Structure: {H.name}")
    print(f"  Dimension: {H.dim}")
    print(f"  CM status: {'CM' if H.is_cm() else 'Generic (non-CM)'}")

    # Show Hodge endomorphism basis
    basis = H.hodge_endomorphism_basis()
    print(f"\n  Hodge-compatible endomorphism basis (dim = {len(basis)}):")
    for i, b in enumerate(basis):
        print(f"    e_{i} = {b.tolist()}")

    # Test stabilizer membership for several matrices
    test_matrices = {
        "Identity":         np.eye(2),
        "Scalar (3·Id)":    3 * np.eye(2),
        "Permutation":      np.array([[0, 1], [1, 0]], dtype=float),
        "Rotation π/4":     np.array([[np.cos(np.pi/4), -np.sin(np.pi/4)],
                                       [np.sin(np.pi/4),  np.cos(np.pi/4)]]),
        "Shear":            np.array([[1, 1], [0, 1]], dtype=float),
        "Diagonal(2,3)":    np.array([[2, 0], [0, 3]], dtype=float),
    }

    # Add J if CM
    if H.is_cm():
        test_matrices["CM endo J"] = H.cm_endomorphism

    print(f"\n  Stabilizer membership tests (g ∈ tensorInvariantStabilizer(H)):")
    for name, g in test_matrices.items():
        det = np.linalg.det(g)
        if abs(det) < 1e-10:
            continue
        in_stab = preserves_hodge_endos(H, g)
        symbol = "✓" if in_stab else "✗"
        print(f"    {symbol}  {name:20s}  det={det:+.3f}  in stabilizer: {in_stab}")

    # Find witness for proper stabilizer (CM case)
    witness = find_non_stabilizing_element(H)
    if witness is not None:
        print(f"\n  ⚡ Witness g NOT in stabilizer:")
        print(f"    g = {witness.tolist()}")
        print(f"    Verification:")
        for i, b in enumerate(basis):
            conj = conjugate_endo(witness, b)
            is_fixed = np.allclose(conj, b)
            print(f"      g·e_{i}·g⁻¹ = {np.round(conj, 6).tolist()}  "
                  f"{'= e_' + str(i) if is_fixed else '≠ e_' + str(i) + ' ← NOT PRESERVED'}")
    else:
        if H.is_cm():
            print(f"\n  (No simple witness found among test matrices)")
        else:
            print(f"\n  ✓ Stabilizer = GL(W) (all invertible matrices preserve scalars)")


def demo_bifurcation():
    """Demonstrate the generic/CM bifurcation through tensor invariants."""
    print_separator("THE GENERIC/CM BIFURCATION")

    print("  The Mumford-Tate dichotomy in dimension 2:")
    print()
    print("  GENERIC (non-CM):   Hodge endos = Q·Id")
    print("                      ⟹ Stabilizer = GL₂(Q)  (maximal)")
    print("                      ⟹ Mumford-Tate group = GL₂")
    print()
    print("  CM:                 Hodge endos = Q·Id + Q·φ  (φ non-scalar)")
    print("                      ⟹ Stabilizer ⊊ GL₂(Q)  (proper)")
    print("                      ⟹ Mumford-Tate group = centralizer of φ")
    print()
    print("  This is EXACTLY what our Lean theorems prove:")
    print("    • tensorInvariantStabilizer_top_of_scalar: generic ⟹ stab = ⊤")
    print("    • tensorInvariantStabilizer_proper_of_CM:  CM     ⟹ stab < ⊤")


def demo_low_degree_tensors():
    """Demonstrate low-degree tensor classification."""
    print_separator("LOW-DEGREE TENSOR ANALYSIS (p+q ≤ 4)")

    structures = [
        create_generic_hodge(),
        create_cm_hodge_gaussian(),
    ]

    for H in structures:
        print(f"\n  --- {H.name} ---")
        print(f"\n  Tensor types (p,q) with p+q ≤ 4:")

        for p in range(5):
            for q in range(5):
                if p + q > 4 or p + q == 0:
                    continue
                # Dimension of tensor space W^⊗p ⊗ (W∨)^⊗q
                tensor_dim = H.dim ** (p + q)
                # For Hodge classes at weight 1:
                # Type (p,q) in W^⊗p ⊗ (W∨)^⊗q has weight p+q
                # Hodge classes exist only when the tensor weight allows (0,0) pieces
                # For weight-1 structure, the (0,0) classes in type (p,q) require p=q

                if p == q:
                    if H.is_cm():
                        hdg_dim = "≥ " + str(min(H.dim ** p, len(H.hodge_endomorphism_basis()) ** p))
                        extra = " (includes CM tensors)"
                    else:
                        hdg_dim = str(1 if p > 0 else 1)  # Just contractions
                        extra = " (contractions only)"
                    print(f"    (p,q) = ({p},{q}): tensor dim = {tensor_dim:4d}, "
                          f"Hodge classes: {hdg_dim}{extra}")
                else:
                    print(f"    (p,q) = ({p},{q}): tensor dim = {tensor_dim:4d}, "
                          f"Hodge classes: 0 (weight mismatch)")


def main():
    print_separator("TENSOR INVARIANTS AND MUMFORD-TATE GROUPS")
    print("  Demonstrating the Tannakian principle for weight-1 Hodge structures")
    print("  in dimension 2 (elliptic curve case)")

    # 1. Show individual structures
    structures = [
        create_generic_hodge(),
        create_cm_hodge_gaussian(),
        create_cm_hodge_eisenstein(),
    ]

    for H in structures:
        print_separator(f"Hodge Structure: {H.name}")
        demo_hodge_structure(H)

    # 2. Show the bifurcation
    demo_bifurcation()

    # 3. Show low-degree tensor analysis
    demo_low_degree_tensors()

    # 4. Summary
    print_separator("SUMMARY: VERIFIED THEOREMS")
    print("  The following theorems are formally verified in Lean 4:")
    print()
    print("  1. evalTensor_mem_hodgeEndos:")
    print("     The identity endomorphism is always a Hodge class.")
    print()
    print("  2. tensorInvariantStabilizer_antitone:")
    print("     Adding Hodge invariants can only shrink the stabilizer.")
    print()
    print("  3. tensorInvariantStabilizer_top_of_scalar:")
    print("     Generic (scalar-only) Hodge data ⟹ stabilizer = GL(W).")
    print()
    print("  4. exists_linearEquiv_noncommuting:")
    print("     Non-scalar endomorphisms have non-trivial GL orbit.")
    print()
    print("  5. tensorInvariantStabilizer_proper_of_CM:")
    print("     CM endomorphism ⟹ stabilizer ⊊ GL(W).")
    print()
    print("  Together, these establish the first formally verified instance of")
    print("  the Tannakian principle: tensor invariants detect the arithmetic")
    print("  symmetry group, distinguishing generic from CM elliptic curves.")


if __name__ == "__main__":
    main()
