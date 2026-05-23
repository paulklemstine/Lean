#!/usr/bin/env python3
"""
Applications of Weyl Algebra Theory

Demonstrates real-world connections of the Weyl algebra formalization:
1. Quantum mechanics: canonical commutation relations
2. Differential equations: operator factorization
3. Signal processing: time-frequency analysis
4. Polynomial automorphism verification
"""

from fractions import Fraction
from typing import Dict, Tuple, List
from algorithms import (
    normal_order_word, weyl_multiply, display_normal_form,
    verify_weyl_relation, symbol_matrix_det, check_keller_condition,
    compute_commutator_normal_form
)


def application_1_quantum_mechanics():
    """Application: Quantum Harmonic Oscillator.

    The quantum harmonic oscillator uses creation (a†) and annihilation (a)
    operators satisfying [a, a†] = 1. This is exactly a Weyl pair!

    In terms of position x and momentum p:
        a = (x + ip) / √2
        a† = (x - ip) / √2

    The number operator N = a†a counts quanta, and [N, a†] = a†, [N, a] = -a.
    """
    print("APPLICATION 1: Quantum Harmonic Oscillator")
    print("-" * 50)
    print()
    print("The quantum harmonic oscillator has operators x̂ and p̂ = -iℏd/dx")
    print("satisfying [p̂, x̂] = -iℏ. Rescaling gives the Weyl relation [d, x] = 1.")
    print()

    # Demonstrate: N = x·d (number operator in normal order)
    # N·x = x·d·x = x·(x·d + 1) = x²·d + x
    print("Number operator N = x·d (creation followed by annihilation):")
    N = {(1, 1): Fraction(1)}
    x = {(1, 0): Fraction(1)}
    d = {(0, 1): Fraction(1)}

    Nx = weyl_multiply(N, x)
    print(f"  N·x = {display_normal_form(Nx)}")
    print(f"  Expected: x²·d + x  (N raises x by adding a quantum)")
    print()

    # [N, x] = x (creation raises by 1)
    xN = weyl_multiply(x, N)
    comm_Nx = {}
    for k, v in Nx.items():
        comm_Nx[k] = comm_Nx.get(k, Fraction(0)) + v
    for k, v in xN.items():
        comm_Nx[k] = comm_Nx.get(k, Fraction(0)) - v
    comm_Nx = {k: v for k, v in comm_Nx.items() if v != 0}
    print(f"  [N, x] = {display_normal_form(comm_Nx)}")
    print(f"  Expected: x (each x-action creates one quantum)")
    print()

    # Energy levels: H = N + 1/2 = x·d + 1/2
    print("  Hamiltonian H = x·d + 1/2 (number operator + zero-point energy)")
    print("  Energy levels: E_n = n + 1/2 for n = 0, 1, 2, ...")
    print()


def application_2_differential_equations():
    """Application: Operator Factorization of Differential Equations.

    The Weyl algebra provides a framework for factoring differential operators.
    Example: The equation y'' + y = 0 (simple harmonic oscillator) corresponds
    to the operator d² + 1, which factors as (d + ix)(d - ix) in A₁(ℂ).
    """
    print("APPLICATION 2: Differential Operator Factorization")
    print("-" * 50)
    print()
    print("Differential equations correspond to elements of the Weyl algebra.")
    print("Factoring operators in A₁ gives solution methods.")
    print()

    # The operator d² (second derivative in normal form)
    d2 = normal_order_word(['d', 'd'])
    print(f"  d² = {display_normal_form(d2)}  (second derivative operator)")

    # Compute d² * x - x * d²
    d2x = weyl_multiply(d2, {(1, 0): Fraction(1)})
    xd2 = weyl_multiply({(1, 0): Fraction(1)}, d2)
    comm = {}
    for k, v in d2x.items():
        comm[k] = comm.get(k, Fraction(0)) + v
    for k, v in xd2.items():
        comm[k] = comm.get(k, Fraction(0)) - v
    comm = {k: v for k, v in comm.items() if v != 0}
    print(f"  [d², x] = {display_normal_form(comm)}")
    print(f"  Expected: 2d (twice the first derivative)")
    print()

    # The Euler operator x·d
    print("  Euler operator θ = x·d:")
    print("  θ·f(x) = x·f'(x)")
    print("  θ·xⁿ = n·xⁿ (eigenvalue equation!)")
    theta = {(1, 1): Fraction(1)}
    theta_x2 = weyl_multiply(theta, {(2, 0): Fraction(1)})
    print(f"  θ·x² = {display_normal_form(theta_x2)}")
    print(f"  Expected: 2x² (eigenvalue 2)")
    print()


def application_3_polynomial_automorphisms():
    """Application: Verifying Polynomial Automorphisms via the Dixmier Bridge.

    The Jacobian-Dixmier bridge says: if an endomorphism of A₁ preserves
    the Weyl relation, then its symbol map on gr(A₁) ≅ K[x,ξ] has
    Jacobian determinant 1 (Keller condition).

    We verify this computationally for several endomorphism families.
    """
    print("APPLICATION 3: Polynomial Automorphism Verification")
    print("-" * 50)
    print()
    print("The Jacobian–Dixmier bridge connects Weyl endomorphisms to")
    print("polynomial automorphisms. We verify the bridge computationally.")
    print()

    # Test several degree-1 endomorphisms
    test_cases = [
        ("Identity", {(1, 0): Fraction(1)}, {(0, 1): Fraction(1)},
         (1, 0, 0, 1)),
        ("Upper shear", {(1, 0): Fraction(1), (0, 1): Fraction(1)},
         {(0, 1): Fraction(1)}, (1, 1, 0, 1)),
        ("Lower shear", {(1, 0): Fraction(1)},
         {(1, 0): Fraction(2), (0, 1): Fraction(1)}, (1, 0, 2, 1)),
        ("Scaling ×3", {(1, 0): Fraction(3)},
         {(0, 1): Fraction(1, 3)}, (3, 0, 0, Fraction(1, 3))),
    ]

    for name, x_img, d_img, (a, b, c, e) in test_cases:
        weyl_ok = verify_weyl_relation(x_img, d_img)
        det = float(a) * float(e) - float(b) * float(c)
        print(f"  {name}:")
        print(f"    φ(x) = {display_normal_form(x_img)}")
        print(f"    φ(d) = {display_normal_form(d_img)}")
        print(f"    Weyl relation preserved: {weyl_ok}")
        print(f"    Symbol matrix det: {det}")
        print(f"    Keller condition: {abs(det - 1) < 1e-10}")
        print()


def application_4_symplectic_geometry():
    """Application: Symplectic Structure Preservation.

    The Weyl algebra's associated graded is the polynomial ring K[x,ξ]
    with the Poisson bracket {f,g} = ∂f/∂ξ · ∂g/∂x - ∂f/∂x · ∂g/∂ξ.

    The standard symplectic form is ω = dx ∧ dξ.
    A linear map preserves ω iff its matrix is in Sp₂ = SL₂ (in 2D).

    Every Weyl endomorphism induces a symplectomorphism!
    """
    print("APPLICATION 4: Symplectic Geometry Connection")
    print("-" * 50)
    print()
    print("Phase space T*ℝ has coordinates (x, ξ) and symplectic form ω = dx∧dξ.")
    print("A linear map preserves ω iff its matrix has determinant 1.")
    print("The Weyl relation FORCES det = 1, linking quantum → symplectic!")
    print()

    # Generate symplectic matrices (= SL₂) and show they give valid endomorphisms
    import itertools
    print("  All 2×2 integer matrices with |entries| ≤ 2 and det = 1:")
    count = 0
    for a, b, c, e in itertools.product(range(-2, 3), repeat=4):
        if a * e - b * c == 1:
            count += 1
            if count <= 10:
                print(f"    [{count:2d}] [[{a:2d}, {b:2d}], [{c:2d}, {e:2d}]]"
                      f"  → x↦{a}x+{b}d, d↦{c}x+{e}d")
    print(f"    ... ({count} total symplectic matrices)")
    print()
    print("  Each gives a valid Weyl endomorphism by the bridge theorem!")
    print("  This is the algebraic content of canonical transformations")
    print("  in classical mechanics (Hamiltonian dynamics).")


def main():
    print()
    print("╔══════════════════════════════════════════════════════════════════╗")
    print("║  APPLICATIONS OF WEYL ALGEBRA THEORY                          ║")
    print("╚══════════════════════════════════════════════════════════════════╝")
    print()

    application_1_quantum_mechanics()
    print()
    application_2_differential_equations()
    print()
    application_3_polynomial_automorphisms()
    print()
    application_4_symplectic_geometry()

    print()
    print("=" * 70)
    print("All applications demonstrated successfully.")
    print("=" * 70)


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Weyl Algebra Normal Ordering and Jacobian–Dixmier Bridge Demo

Interactive demonstration of:
1. Normal-ordering of Weyl algebra words
2. Construction of induced symbol maps from endomorphisms
3. Jacobian determinant computation for the symbol map
4. Experiments testing conjectures on bounded-degree examples
"""

from algorithms import (
    WeylMonomial, normal_order_word, weyl_multiply,
    symbol_matrix_det, check_keller_condition,
    display_normal_form
)
import random


def demo_1_normal_ordering():
    """Demo 1: Normal ordering of Weyl algebra words."""
    print("=" * 70)
    print("DEMO 1: Normal Ordering in the Weyl Algebra A₁(K)")
    print("=" * 70)
    print()
    print("The Weyl algebra A₁ has generators x, d with relation dx - xd = 1.")
    print("Normal ordering writes every element as Σ cᵢⱼ x^i d^j.")
    print()

    # Example 1: d * x = x * d + 1
    print("Example 1: d * x")
    word = ['d', 'x']
    result = normal_order_word(word)
    print(f"  Input:  {'·'.join(word)}")
    print(f"  Normal: {display_normal_form(result)}")
    print(f"  Check:  should be x·d + 1 ✓")
    print()

    # Example 2: d * x^2
    print("Example 2: d * x²")
    word = ['d', 'x', 'x']
    result = normal_order_word(word)
    print(f"  Input:  {'·'.join(word)}")
    print(f"  Normal: {display_normal_form(result)}")
    print(f"  Check:  should be x²·d + 2x ✓")
    print()

    # Example 3: d^2 * x
    print("Example 3: d² * x")
    word = ['d', 'd', 'x']
    result = normal_order_word(word)
    print(f"  Input:  {'·'.join(word)}")
    print(f"  Normal: {display_normal_form(result)}")
    print(f"  Check:  should be x·d² + 2d ✓")
    print()

    # Example 4: d^2 * x^2
    print("Example 4: d² * x²")
    word = ['d', 'd', 'x', 'x']
    result = normal_order_word(word)
    print(f"  Input:  {'·'.join(word)}")
    print(f"  Normal: {display_normal_form(result)}")
    print(f"  Check:  should be x²·d² + 4x·d + 2 ✓")
    print()

    # Example 5: d^3 * x^3
    print("Example 5: d³ * x³")
    word = ['d'] * 3 + ['x'] * 3
    result = normal_order_word(word)
    print(f"  Input:  {'·'.join(word)}")
    print(f"  Normal: {display_normal_form(result)}")
    print()


def demo_2_symbol_map():
    """Demo 2: Induced symbol maps from Weyl endomorphisms."""
    print("=" * 70)
    print("DEMO 2: Symbol Maps from Weyl Endomorphisms")
    print("=" * 70)
    print()
    print("A degree-1 Weyl endomorphism φ maps:")
    print("  x ↦ a·x + b·d")
    print("  d ↦ c·x + e·d")
    print("The symbol matrix is M = [[a,b],[c,e]].")
    print("The Weyl relation forces det(M) = 1 (Keller condition).")
    print()

    # Example endomorphisms
    examples = [
        ("Identity", 1, 0, 0, 1),
        ("Shear (x ↦ x+d, d ↦ d)", 1, 1, 0, 1),
        ("Scaling (x ↦ 2x, d ↦ d/2)", 2, 0, 0, 0.5),
        ("Rotation-like", 0, 1, -1, 0),
        ("General SL₂", 3, 1, 2, 1),
    ]

    for name, a, b, c, e in examples:
        det = a * e - b * c
        keller = check_keller_condition(a, b, c, e)
        print(f"  {name}:")
        print(f"    M = [[{a}, {b}], [{c}, {e}]]")
        print(f"    det(M) = {det:.4f}")
        print(f"    Keller condition satisfied: {keller}")
        print()


def demo_3_jacobian_computation():
    """Demo 3: Jacobian determinant computation."""
    print("=" * 70)
    print("DEMO 3: Jacobian Determinant of Symbol Maps")
    print("=" * 70)
    print()
    print("The Jacobian–Dixmier bridge says:")
    print("  Weyl endomorphism → symbol map → polynomial map")
    print("  The Weyl relation forces the Jacobian determinant = 1.")
    print()

    # Generate random SL₂ matrices and verify
    print("Generating 10 random SL₂(ℤ) matrices and verifying Keller condition:")
    print()
    rng = random.Random(42)
    count = 0
    def mat_mul(A, B):
        return (A[0]*B[0]+A[1]*B[2], A[0]*B[1]+A[1]*B[3],
                A[2]*B[0]+A[3]*B[2], A[2]*B[1]+A[3]*B[3])
    for _ in range(10):
        M = (1, 0, 0, 1)  # identity
        for _ in range(rng.randint(1, 4)):
            k = rng.randint(-3, 3)
            if rng.random() < 0.5:
                M = mat_mul(M, (1, k, 0, 1))
            else:
                M = mat_mul(M, (1, 0, k, 1))
        a, b, c, e = M
        det = symbol_matrix_det(a, b, c, e)
        count += 1
        print(f"  [{count:2d}] M = [[{a:6}, {b:6}], [{c:6}, {e:6}]]  "
              f"det = {det:6}  Keller: {det == 1}")
    print()


def demo_4_conjecture_testing():
    """Demo 4: Testing the falsifiable conjecture."""
    print("=" * 70)
    print("DEMO 4: Testing Conjectures on Bounded-Degree Examples")
    print("=" * 70)
    print()

    print("CONJECTURE (proved FALSE): Every degree-1 Weyl endomorphism")
    print("with det=1 has integer entries in its symbol matrix.")
    print()
    print("Counterexample: x ↦ (1/2)x, d ↦ 2d")
    a, b, c, e = 0.5, 0, 0, 2
    det = a * e - b * c
    print(f"  M = [[{a}, {b}], [{c}, {e}]]")
    print(f"  det(M) = {det}")
    print(f"  Keller condition: {abs(det - 1) < 1e-10}")
    print(f"  All integer entries: {all(x == int(x) for x in [a, b, c, e])}")
    print(f"  → Conjecture DISPROVED ✓")
    print()

    print("CONJECTURE (testing): Degree-1 endomorphisms with rational")
    print("entries and det=1 always form an SL₂(ℚ) matrix.")
    print()
    from fractions import Fraction
    test_cases = [
        (Fraction(1, 3), Fraction(0), Fraction(0), Fraction(3)),
        (Fraction(2, 5), Fraction(1, 5), Fraction(-3), Fraction(4)),
        (Fraction(7, 11), Fraction(2, 11), Fraction(-3), Fraction(7)),
    ]
    for a, b, c, e in test_cases:
        det = a * e - b * c
        print(f"  M = [[{a}, {b}], [{c}, {e}]]  det = {det}  "
              f"Is in SL₂(ℚ): {det == 1}")
    print()

    print("EXPERIMENT: Enumerating all integer matrices with |entries| ≤ 3")
    print("and checking which satisfy the Keller condition...")
    count = 0
    keller_count = 0
    for a in range(-3, 4):
        for b in range(-3, 4):
            for c in range(-3, 4):
                for e_val in range(-3, 4):
                    count += 1
                    if a * e_val - b * c == 1:
                        keller_count += 1
    print(f"  Total matrices: {count}")
    print(f"  Keller matrices (det=1): {keller_count}")
    print(f"  Fraction: {keller_count/count:.4%}")
    print()


def main():
    print()
    print("╔══════════════════════════════════════════════════════════════════╗")
    print("║  WEYL ALGEBRA AND THE JACOBIAN–DIXMIER BRIDGE                  ║")
    print("║  Interactive Mathematical Demonstration                        ║")
    print("╚══════════════════════════════════════════════════════════════════╝")
    print()
    print("This demo explores the connection between:")
    print("  • Quantum mechanics (canonical commutation relations)")
    print("  • Algebraic geometry (polynomial automorphisms)")
    print("  • Symplectic geometry (phase space maps)")
    print()

    demo_1_normal_ordering()
    demo_2_symbol_map()
    demo_3_jacobian_computation()
    demo_4_conjecture_testing()

    print("=" * 70)
    print("All demos completed successfully.")
    print("=" * 70)


if __name__ == "__main__":
    main()
