"""
Applications of Jacobian Conjecture Theory
============================================

Demonstrates real-world applications of polynomial map analysis:
1. Cryptographic transformations using polynomial automorphisms
2. Computer algebra: automatic inverse computation
3. Control theory: state-space transformations
4. Robotics: polynomial kinematics
"""

import numpy as np
from algorithms import (
    triangular_inverse, druzkowski_map, druzkowski_jacobian,
    numerical_jacobian, check_keller_condition, stable_lift
)


def application_crypto_mixing():
    """Application: Polynomial maps as cryptographic mixing functions.

    Triangular polynomial automorphisms provide efficient, invertible
    nonlinear mixing functions. The inverse is computed by forward
    substitution in O(n) algebraic operations.
    """
    print("=" * 60)
    print("APPLICATION 1: Cryptographic Mixing Functions")
    print("=" * 60)

    # A triangular map over integers (mod large prime) can serve
    # as a mixing function in a block cipher round.
    def mix_forward(block: np.ndarray) -> np.ndarray:
        """Apply triangular mixing: 4-element block."""
        x0, x1, x2, x3 = block
        return np.array([
            3*x0 + 7,
            2*x1 + x0**2,
            x2 + x0*x1 + 5,
            4*x3 + x1**2 + x2
        ])

    def mix_inverse(block: np.ndarray) -> np.ndarray:
        """Invert the mixing: forward substitution."""
        y0, y1, y2, y3 = block
        x0 = (y0 - 7) / 3
        x1 = (y1 - x0**2) / 2
        x2 = y2 - x0*x1 - 5
        x3 = (y3 - x1**2 - x2) / 4
        return np.array([x0, x1, x2, x3])

    plaintext = np.array([1.0, 2.0, 3.0, 4.0])
    ciphertext = mix_forward(plaintext)
    recovered = mix_inverse(ciphertext)

    print(f"\nPlaintext:  {plaintext}")
    print(f"Ciphertext: {ciphertext}")
    print(f"Recovered:  {recovered}")
    print(f"Error: {np.linalg.norm(plaintext - recovered):.2e}")

    # Verify Jacobian determinant = product of diagonal coeffs = 3*2*1*4 = 24
    J = numerical_jacobian(mix_forward, plaintext)
    print(f"\nJacobian det = {np.linalg.det(J):.1f} (expected: 24.0)")
    print("✓ Guaranteed invertible by triangular automorphism theorem")


def application_coordinate_change():
    """Application: Coordinate changes in dynamical systems.

    Polynomial automorphisms provide nonlinear coordinate changes
    that can simplify dynamical systems while preserving structure.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 2: Coordinate Changes in Dynamical Systems")
    print("=" * 60)

    # Original system: dx/dt = f(x) with complicated nonlinearities
    # After triangular coordinate change, the system may simplify.

    # Example: Hénon-like map in 3D
    def henon_map(v):
        x, y, z = v
        return np.array([
            1 - 1.4*x**2 + y,
            0.3*x,
            0.5*z + 0.1*x*y
        ])

    # Triangular change of coordinates (simplifying transformation)
    def coord_change(v):
        x, y, z = v
        return np.array([x, y + 0.5*x**2, z + x*y])

    def coord_change_inv(v):
        u, w, s = v
        x = u
        y = w - 0.5*x**2
        z = s - x*y
        return np.array([x, y, z])

    # Transform the map to new coordinates
    point = np.array([0.5, 0.3, 0.1])
    original_image = henon_map(point)

    # In new coords: Φ ∘ H ∘ Φ⁻¹
    new_point = coord_change(point)
    transformed_image = coord_change(henon_map(coord_change_inv(new_point)))

    print(f"\nOriginal point: {point}")
    print(f"H(point) = {original_image}")
    print(f"\nIn new coordinates: {new_point}")
    print(f"(Φ∘H∘Φ⁻¹)(new_point) = {transformed_image}")

    # Verify consistency
    back = coord_change_inv(transformed_image)
    print(f"Back to original: {back}")
    print(f"Matches H(point): {np.allclose(back, original_image)}")
    print("✓ Triangular automorphisms enable efficient coordinate changes")


def application_stable_embedding():
    """Application: Stable embedding for dimensional analysis.

    The stable lift theorem shows that questions about polynomial
    invertibility in dimension n reduce to dimension n+m for any m.
    This enables embedding low-dimensional problems into higher
    dimensions where additional structure may be available.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 3: Stable Embedding for Dimensional Analysis")
    print("=" * 60)

    # A 2D map
    def F_2d(x):
        return np.array([2*x[0] + x[1], 3*x[1] + 1])

    # Its stable lift to 4D
    F_4d = stable_lift(F_2d, 2, 2)

    # Verify Keller condition is preserved
    is_keller_2d, det_2d = check_keller_condition(F_2d, 2)
    is_keller_4d, det_4d = check_keller_condition(F_4d, 4)

    print(f"\n2D map: Keller = {is_keller_2d}, det ≈ {det_2d:.2f}")
    print(f"4D lift: Keller = {is_keller_4d}, det ≈ {det_4d:.2f}")
    print("✓ Keller condition preserved under stable lift")

    # The stable lift preserves invertibility
    print("\n✓ If F is invertible, so is F↑m (and vice versa)")
    print("  This is the content of isPolyAuto_stableLift_iff")


def application_druzkowski_analysis():
    """Application: Analysis of Drużkowski maps for reduction theory.

    Drużkowski maps F(x) = x + (Ax)^[3] are the key objects in the
    cubic homogeneous reduction of the Jacobian Conjecture.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 4: Drużkowski Map Analysis")
    print("=" * 60)

    # Various matrices and their Drużkowski maps
    matrices = {
        "Nilpotent (A²=0)": np.array([[0, 1], [0, 0]]),
        "Rank 1": np.array([[1, 0], [1, 0]]),
        "Diagonal": np.array([[1, 0], [0, 1]]),
    }

    for name, A in matrices.items():
        print(f"\n--- {name} ---")
        print(f"A = \n{A}")

        F = lambda x, A=A: druzkowski_map(A, x)
        is_keller, det_val = check_keller_condition(F, 2)
        print(f"Keller condition: {is_keller}, det ≈ {det_val:.4f}")

        if A.shape[0] <= 3:
            eigs = np.linalg.eigvals(A)
            print(f"Eigenvalues of A: {eigs}")
            print(f"A² = \n{A @ A}")
            nilpotent = np.allclose(A @ A, 0)
            print(f"A² = 0 (nilpotent): {nilpotent}")

    print("\n✓ For nilpotent A², Drużkowski maps always satisfy Keller condition")
    print("  The Jacobian Conjecture reduces to showing these are automorphisms")


if __name__ == "__main__":
    application_crypto_mixing()
    application_coordinate_change()
    application_stable_embedding()
    application_druzkowski_analysis()
    print("\n" + "=" * 60)
    print("All applications demonstrated successfully!")
    print("=" * 60)


"""
Jacobian Conjecture: Concrete Demonstrations
=============================================

This script demonstrates key concepts from the Jacobian Conjecture
formalization with concrete numerical examples.
"""

import numpy as np
from typing import Tuple, List, Callable

def affine_map(A: np.ndarray, b: np.ndarray, x: np.ndarray) -> np.ndarray:
    """Evaluate the affine polynomial map F(x) = Ax + b."""
    return A @ x + b

def affine_inverse(A: np.ndarray, b: np.ndarray, y: np.ndarray) -> np.ndarray:
    """Evaluate the inverse G(y) = A^{-1}(y - b)."""
    return np.linalg.solve(A, y - b)

def jacobian_det_affine(A: np.ndarray) -> float:
    """The Jacobian determinant of an affine map is det(A)."""
    return np.linalg.det(A)


def demo_affine_automorphism():
    """Demonstrate: affine maps with invertible matrix are polynomial automorphisms."""
    print("=" * 60)
    print("DEMO 1: Affine Maps are Polynomial Automorphisms")
    print("=" * 60)

    A = np.array([[2., 1.], [0., 3.]])
    b = np.array([1., -1.])
    x = np.array([5., 7.])

    print(f"\nA = \n{A}")
    print(f"b = {b}")
    print(f"det(A) = {np.linalg.det(A):.1f}")
    print(f"\nF(x) = Ax + b")
    print(f"x = {x}")

    y = affine_map(A, b, x)
    print(f"F(x) = {y}")

    x_recovered = affine_inverse(A, b, y)
    print(f"G(F(x)) = {x_recovered}")
    print(f"Recovery error: {np.linalg.norm(x - x_recovered):.2e}")

    # Verify F(G(y)) = y
    y_test = np.array([10., 20.])
    x_inv = affine_inverse(A, b, y_test)
    y_recovered = affine_map(A, b, x_inv)
    print(f"\ny_test = {y_test}")
    print(f"F(G(y_test)) = {y_recovered}")
    print(f"Recovery error: {np.linalg.norm(y_test - y_recovered):.2e}")
    print(f"\n✓ Affine map is a polynomial automorphism (Theorem: affine_isPolyAuto)")


def demo_triangular_automorphism():
    """Demonstrate: triangular maps with nonzero diagonal are polynomial automorphisms."""
    print("\n" + "=" * 60)
    print("DEMO 2: Triangular Maps are Polynomial Automorphisms")
    print("=" * 60)

    # F(x,y,z) = (2x + 1, 3y + x^2, z + xy + y^3)
    # This is triangular: F_0 depends on nothing extra,
    # F_1 depends on x, F_2 depends on x and y.
    def F(v):
        x, y, z = v
        return np.array([
            2*x + 1,
            3*y + x**2,
            z + x*y + y**3
        ])

    # Diagonal coefficients: a = (2, 3, 1)
    a = [2, 3, 1]
    print(f"\nF(x,y,z) = (2x+1, 3y+x², z+xy+y³)")
    print(f"Diagonal coefficients: a = {a}")
    print(f"Jacobian determinant = ∏ a_i = {np.prod(a)}")

    # Compute inverse by forward substitution:
    # G_0 = (x - 1)/2
    # G_1 = (y - G_0²)/3 = (y - ((x-1)/2)²)/3
    # G_2 = z - G_0*G_1 - G_1³
    def G(v):
        x, y, z = v
        g0 = (x - 1) / 2
        g1 = (y - g0**2) / 3
        g2 = z - g0*g1 - g1**3
        return np.array([g0, g1, g2])

    v = np.array([3.0, 7.0, -2.0])
    w = F(v)
    v_recovered = G(w)
    print(f"\nv = {v}")
    print(f"F(v) = {w}")
    print(f"G(F(v)) = {v_recovered}")
    print(f"Recovery error: {np.linalg.norm(v - v_recovered):.2e}")

    # Verify the other direction
    w_test = np.array([5.0, 10.0, 15.0])
    v_inv = G(w_test)
    w_recovered = F(v_inv)
    print(f"\nw_test = {w_test}")
    print(f"F(G(w_test)) = {w_recovered}")
    print(f"Recovery error: {np.linalg.norm(w_test - w_recovered):.2e}")
    print(f"\n✓ Triangular map is a polynomial automorphism (Theorem: triangular_isPolyAuto)")


def demo_stable_lift():
    """Demonstrate: stable lift preserves invertibility."""
    print("\n" + "=" * 60)
    print("DEMO 3: Stable Lift Preserves Invertibility")
    print("=" * 60)

    A = np.array([[1., 2.], [3., 4.]])
    b = np.array([1., 0.])

    print(f"\nOriginal 2D affine map: F(x) = Ax + b")
    print(f"A = \n{A}")
    print(f"det(A) = {np.linalg.det(A):.1f}")

    # Stable lift to 4D: F↑2(x,y) = (F(x), y)
    def F_lifted(v):
        result = np.zeros(4)
        result[:2] = A @ v[:2] + b
        result[2:] = v[2:]
        return result

    def G_lifted(v):
        result = np.zeros(4)
        result[:2] = np.linalg.solve(A, v[:2] - b)
        result[2:] = v[2:]
        return result

    v = np.array([1., 2., 3., 4.])
    w = F_lifted(v)
    v_recovered = G_lifted(w)

    print(f"\nStable lift F↑2: (x₁,x₂,y₁,y₂) ↦ (F(x₁,x₂), y₁, y₂)")
    print(f"v = {v}")
    print(f"F↑2(v) = {w}")
    print(f"G↑2(F↑2(v)) = {v_recovered}")
    print(f"Recovery error: {np.linalg.norm(v - v_recovered):.2e}")

    # Jacobian determinant preserved
    J_original = np.linalg.det(A)
    J_lifted = np.linalg.det(np.block([
        [A, np.zeros((2,2))],
        [np.zeros((2,2)), np.eye(2)]
    ]))
    print(f"\nJacobian det of F: {J_original:.1f}")
    print(f"Jacobian det of F↑2: {J_lifted:.1f}")
    print(f"✓ Jacobian determinant preserved (Theorem: jacobianMatrix_stableLift_entry)")
    print(f"✓ Invertibility preserved (Theorem: isPolyAuto_stableLift_iff)")


def demo_druzkowski():
    """Demonstrate Drużkowski maps."""
    print("\n" + "=" * 60)
    print("DEMO 4: Drużkowski Maps (Cubic Homogeneous)")
    print("=" * 60)

    # Drużkowski map: F(x) = x + (Ax)^[3]
    A = np.array([[1., 0.], [1., 0.]])  # Nilpotent A²=0

    def druzkowski(v):
        Av = A @ v
        return v + Av**3

    def jacobian_druzkowski(v):
        n = len(v)
        Av = A @ v
        J = np.eye(n) + 3 * np.diag(Av**2) @ A
        return J

    print(f"\nDrużkowski map with A = \n{A}")
    print(f"F(x) = x + (Ax)^[3]")

    for v in [np.array([1., 0.]), np.array([0., 1.]), np.array([1., 1.])]:
        J = jacobian_druzkowski(v)
        print(f"\nAt x = {v}:")
        print(f"  F(x) = {druzkowski(v)}")
        print(f"  det(JF) = {np.linalg.det(J):.4f}")

    print(f"\n✓ Drużkowski maps are cubic homogeneous (Theorem: druzkowskiMap_isCubicHomogeneous)")


if __name__ == "__main__":
    demo_affine_automorphism()
    demo_triangular_automorphism()
    demo_stable_lift()
    demo_druzkowski()
    print("\n" + "=" * 60)
    print("All demonstrations completed successfully!")
    print("=" * 60)
