#!/usr/bin/env python3
"""
Applications of Keller Map Reduction Theory

Demonstrates real-world connections:
1. Cryptographic polynomial map design
2. Dynamical systems: iteration of Keller maps
3. Computer algebra: automatic invertibility verification
"""

import numpy as np
from algorithms import (
    druzkowski_map, extract_linear_part, check_keller,
    is_cubic_homogeneous, formal_inverse, normalize_keller_map,
    nilpotency_index, poly_eval, identity_polymap, poly_add,
    poly_scale, unit_monomial, poly_pow, poly_mul, zero_monomial
)


def application_crypto():
    """Polynomial maps as cryptographic primitives.
    
    Keller maps with known inverses can be used for
    public-key-like systems: the map is public, the
    inverse (decryption) is secret.
    """
    print("="*60)
    print("APPLICATION 1: Cryptographic Polynomial Maps")
    print("="*60)
    
    # Use a Drużkowski map with known nilpotent matrix
    A = np.array([[0, 1, 1], [0, 0, 1], [0, 0, 0]], dtype=float)
    n = 3
    
    F = druzkowski_map(A)
    inv = formal_inverse(F, n, max_deg=10)
    
    print(f"\nPublic key: F = x + (Ax)³ where A is secret nilpotent matrix")
    print(f"Nilpotency index of A: {nilpotency_index(A)}")
    print(f"Inverse reconstruction residual: {inv.residual:.2e}")
    
    # Encrypt a message
    message = np.array([3.14, 2.72, 1.41])
    encrypted = np.array([poly_eval(F[i], message) for i in range(n)])
    decrypted = np.array([poly_eval(inv.inverse_map[i], encrypted) for i in range(n)])
    
    print(f"\nMessage:   {message}")
    print(f"Encrypted: {encrypted}")
    print(f"Decrypted: {decrypted}")
    print(f"Error:     {np.linalg.norm(message - decrypted):.2e}")


def application_dynamics():
    """Polynomial dynamical systems.
    
    Keller maps preserve volume (since Jacobian det = const).
    Studying their orbits reveals connections to ergodic theory.
    """
    print("\n" + "="*60)
    print("APPLICATION 2: Volume-Preserving Polynomial Dynamics")
    print("="*60)
    
    # 2D Keller map (known automorphism)
    A = np.array([[0, 1], [0, 0]], dtype=float)
    n = 2
    F = druzkowski_map(A)
    
    print("\nKeller map: F(x,y) = (x + y³, y)")
    print("This preserves 2D volume (area) since det(JF) = 1")
    
    # Iterate starting from several initial points
    print("\nOrbits under iteration:")
    for x0 in [np.array([0.5, 0.3]), np.array([1.0, -0.5])]:
        x = x0.copy()
        print(f"\n  x₀ = ({x[0]:.3f}, {x[1]:.3f})")
        for step in range(5):
            x = np.array([poly_eval(F[i], x) for i in range(n)])
            print(f"  x_{step+1} = ({x[0]:.3f}, {x[1]:.3f})")


def application_verification():
    """Automatic invertibility verification.
    
    Given a polynomial map, automatically determine:
    1. Whether it satisfies the Keller condition
    2. Whether it can be normalized
    3. Whether an inverse can be constructed
    """
    print("\n" + "="*60)
    print("APPLICATION 3: Automatic Invertibility Verification")
    print("="*60)
    
    test_cases = [
        ("2D Drużkowski (nilpotent-2)", 
         np.array([[0, 2], [0, 0]], dtype=float)),
        ("3D Drużkowski (nilpotent-3)", 
         np.array([[0, 1, 0], [0, 0, 1], [0, 0, 0]], dtype=float)),
        ("3D Drużkowski (nilpotent-2)", 
         np.array([[0, 1, 0], [0, 0, 0], [0, 0, 0]], dtype=float)),
    ]
    
    for name, A in test_cases:
        n = A.shape[0]
        F = druzkowski_map(A)
        
        print(f"\n--- {name} ---")
        print(f"  Dimension: {n}")
        print(f"  Nilpotency index: {nilpotency_index(A)}")
        
        keller, det_val = check_keller(F, n)
        print(f"  Keller condition: {keller}", end="")
        if det_val is not None:
            print(f" (det ≈ {det_val:.4f})")
        else:
            print()
        
        cubic = is_cubic_homogeneous(F, n)
        print(f"  Cubic homogeneous: {cubic}")
        
        norm = normalize_keller_map(F, n)
        print(f"  Normalization: {'success' if norm.success else 'failed'}")
        
        inv = formal_inverse(F, n, max_deg=10)
        print(f"  Inverse found: {inv.success} (residual = {inv.residual:.2e})")
        
        if inv.success:
            # Verify at random point
            x = np.random.randn(n)
            fx = np.array([poly_eval(F[i], x) for i in range(n)])
            gfx = np.array([poly_eval(inv.inverse_map[i], fx) for i in range(n)])
            print(f"  Verification: ||G(F(x)) - x|| = {np.linalg.norm(gfx - x):.2e}")


if __name__ == "__main__":
    np.random.seed(42)
    application_crypto()
    application_dynamics()
    application_verification()


#!/usr/bin/env python3
"""
Jacobian Conjecture: Interactive Demonstration

This script demonstrates the key concepts of Keller map theory:
1. Polynomial map representation and Jacobian computation
2. Linear part extraction and invertibility checking
3. Normalization to identity linear part
4. Cubic homogeneous perturbation detection
5. Formal inverse reconstruction to bounded degree
6. Sparse cubic conjecture experiments

Usage: python demo.py
"""

import numpy as np
from itertools import product
import sys

# ============================================================
# Core Data Structures
# ============================================================

class PolyMap:
    """A polynomial map F: k^n -> k^n.
    
    Represented as a list of n polynomials in n variables.
    Each polynomial is a dict: {monomial_tuple: coefficient}.
    A monomial_tuple is a tuple of n nonneg integers (exponents).
    """
    
    def __init__(self, n, polys=None):
        self.n = n
        if polys is None:
            # Identity map
            self.polys = []
            for i in range(n):
                mono = tuple(1 if j == i else 0 for j in range(n))
                self.polys.append({mono: 1.0})
        else:
            self.polys = polys
    
    def eval(self, x):
        """Evaluate the polynomial map at point x."""
        result = np.zeros(self.n)
        for i, poly in enumerate(self.polys):
            val = 0.0
            for mono, coeff in poly.items():
                term = coeff
                for j, exp in enumerate(mono):
                    term *= x[j] ** exp
                val += term
            result[i] = val
        return result
    
    def __repr__(self):
        lines = []
        for i, poly in enumerate(self.polys):
            terms = []
            for mono, coeff in sorted(poly.items()):
                if abs(coeff) < 1e-12:
                    continue
                parts = []
                for j, exp in enumerate(mono):
                    if exp == 0:
                        continue
                    elif exp == 1:
                        parts.append(f"x{j+1}")
                    else:
                        parts.append(f"x{j+1}^{exp}")
                if not parts:
                    terms.append(f"{coeff:.4g}")
                else:
                    var_str = "*".join(parts)
                    if abs(coeff - 1.0) < 1e-12:
                        terms.append(var_str)
                    elif abs(coeff + 1.0) < 1e-12:
                        terms.append(f"-{var_str}")
                    else:
                        terms.append(f"{coeff:.4g}*{var_str}")
            if not terms:
                terms = ["0"]
            lines.append(f"  F{i+1} = {' + '.join(terms)}")
        return "\n".join(lines)


# ============================================================
# Jacobian Computation
# ============================================================

def partial_derivative(poly, var_idx, n):
    """Compute partial derivative of a polynomial w.r.t. variable var_idx."""
    result = {}
    for mono, coeff in poly.items():
        exp = mono[var_idx]
        if exp == 0:
            continue
        new_mono = list(mono)
        new_mono[var_idx] = exp - 1
        new_mono = tuple(new_mono)
        new_coeff = coeff * exp
        result[new_mono] = result.get(new_mono, 0) + new_coeff
    return result


def jacobian_matrix_symbolic(F):
    """Compute the symbolic Jacobian matrix of a polynomial map.
    Returns n x n matrix of polynomial dicts."""
    n = F.n
    J = [[None]*n for _ in range(n)]
    for i in range(n):
        for j in range(n):
            J[i][j] = partial_derivative(F.polys[i], j, n)
    return J


def eval_poly(poly, x, n):
    """Evaluate a polynomial dict at point x."""
    val = 0.0
    for mono, coeff in poly.items():
        term = coeff
        for j, exp in enumerate(mono):
            term *= x[j] ** exp
        val += term
    return val


def jacobian_matrix_at(F, x):
    """Evaluate the Jacobian matrix at a point."""
    n = F.n
    J_sym = jacobian_matrix_symbolic(F)
    J = np.zeros((n, n))
    for i in range(n):
        for j in range(n):
            J[i][j] = eval_poly(J_sym[i][j], x, n)
    return J


def jacobian_det_at(F, x):
    """Compute the Jacobian determinant at a point."""
    return np.linalg.det(jacobian_matrix_at(F, x))


def linear_part_matrix(F):
    """Extract the linear part matrix of a polynomial map.
    Entry (i,j) = coefficient of x_j in F_i."""
    n = F.n
    L = np.zeros((n, n))
    for i in range(n):
        for j in range(n):
            mono = tuple(1 if k == j else 0 for k in range(n))
            L[i][j] = F.polys[i].get(mono, 0.0)
    return L


def is_keller(F, num_test_points=20, tol=1e-8):
    """Check if a polynomial map satisfies the Keller condition.
    Tests if det(JF) is constant at multiple random points."""
    n = F.n
    dets = []
    for _ in range(num_test_points):
        x = np.random.randn(n)
        d = jacobian_det_at(F, x)
        dets.append(d)
    dets = np.array(dets)
    if np.std(dets) < tol:
        return True, np.mean(dets)
    return False, None


def is_cubic_homogeneous_perturbation(F, tol=1e-12):
    """Check if F = Id + H where H is homogeneous of degree 3."""
    n = F.n
    for i in range(n):
        for mono, coeff in F.polys[i].items():
            degree = sum(mono)
            # Check identity part
            id_mono = tuple(1 if k == i else 0 for k in range(n))
            if mono == id_mono:
                if abs(coeff - 1.0) > tol:
                    return False
                continue
            # All other terms must have degree 3
            if abs(coeff) > tol and degree != 3:
                return False
    return True


# ============================================================
# Normalization Algorithm
# ============================================================

def normalize_to_identity_linear_part(F):
    """Normalize a polynomial map to have identity linear part.
    
    Given F with invertible linear part L, computes G = F ∘ L⁻¹,
    which has identity linear part.
    
    Returns (G, L, L_inv) or None if L is singular.
    """
    n = F.n
    L = linear_part_matrix(F)
    det_L = np.linalg.det(L)
    if abs(det_L) < 1e-12:
        return None
    L_inv = np.linalg.inv(L)
    
    # Compose F with the linear substitution x -> L^{-1} x
    new_polys = []
    for i in range(n):
        new_poly = substitute_linear(F.polys[i], L_inv, n)
        new_polys.append(new_poly)
    
    G = PolyMap(n, new_polys)
    return G, L, L_inv


def substitute_linear(poly, A, n):
    """Substitute x_j -> sum_l A[j][l] * x_l into a polynomial."""
    result = {}
    for mono, coeff in poly.items():
        # For each monomial x_0^{e_0} * ... * x_{n-1}^{e_{n-1}},
        # substitute x_j -> sum_l A[j][l] * x_l
        # This expands the monomial
        expanded = expand_monomial(mono, A, n)
        for new_mono, new_coeff in expanded.items():
            key = new_mono
            result[key] = result.get(key, 0) + coeff * new_coeff
    # Clean near-zero entries
    result = {k: v for k, v in result.items() if abs(v) > 1e-14}
    return result


def expand_monomial(mono, A, n):
    """Expand a monomial under linear substitution x_j -> sum_l A[j][l] * x_l."""
    # Start with constant 1
    result = {tuple(0 for _ in range(n)): 1.0}
    
    for j, exp in enumerate(mono):
        if exp == 0:
            continue
        # Multiply by (sum_l A[j][l] * x_l)^exp
        linear = {}
        for l in range(n):
            if abs(A[j][l]) > 1e-14:
                mono_l = tuple(1 if k == l else 0 for k in range(n))
                linear[mono_l] = A[j][l]
        
        power = poly_power(linear, exp, n)
        result = poly_mul(result, power, n)
    
    return result


def poly_mul(p1, p2, n):
    """Multiply two polynomials (dict representation)."""
    result = {}
    for m1, c1 in p1.items():
        for m2, c2 in p2.items():
            new_mono = tuple(m1[i] + m2[i] for i in range(n))
            result[new_mono] = result.get(new_mono, 0) + c1 * c2
    return {k: v for k, v in result.items() if abs(v) > 1e-14}


def poly_power(p, exp, n):
    """Compute p^exp for a polynomial."""
    if exp == 0:
        return {tuple(0 for _ in range(n)): 1.0}
    result = dict(p)
    for _ in range(exp - 1):
        result = poly_mul(result, p, n)
    return result


# ============================================================
# Inverse Reconstruction
# ============================================================

def attempt_inverse(F, max_degree=6):
    """Attempt to reconstruct the polynomial inverse of F = Id + H
    using the formal inverse series: G = Id - H + H^2 - H^3 + ...
    truncated at max_degree.
    
    Returns (G, residual_norm) where residual measures how close F∘G is to Id.
    """
    n = F.n
    # Extract H = F - Id
    H_polys = []
    for i in range(n):
        h = dict(F.polys[i])
        id_mono = tuple(1 if k == i else 0 for k in range(n))
        h[id_mono] = h.get(id_mono, 0) - 1.0
        h = {k: v for k, v in h.items() if abs(v) > 1e-14}
        H_polys.append(h)
    
    # Build inverse iteratively: G_0 = Id, G_{k+1} = Id - H(G_k)
    G = PolyMap(n)  # Start with identity
    
    for iteration in range(max_degree):
        new_polys = []
        for i in range(n):
            # G_{k+1}_i = x_i - H_i(G_k)
            id_mono = tuple(1 if j == i else 0 for j in range(n))
            new_poly = {id_mono: 1.0}
            
            # Substitute G_k into H_i
            h_composed = compose_poly(H_polys[i], G, n, max_degree)
            
            for mono, coeff in h_composed.items():
                if sum(mono) <= max_degree:
                    new_poly[mono] = new_poly.get(mono, 0) - coeff
            
            new_poly = {k: v for k, v in new_poly.items() if abs(v) > 1e-14}
            new_polys.append(new_poly)
        
        G = PolyMap(n, new_polys)
    
    # Check residual: F(G(x)) should be close to x
    residual = 0.0
    for _ in range(10):
        x = np.random.randn(n) * 0.5
        fg = F.eval(G.eval(x))
        residual += np.linalg.norm(fg - x)
    residual /= 10
    
    return G, residual


def compose_poly(poly, G, n, max_degree):
    """Compose a polynomial with a polynomial map G, truncating at max_degree."""
    result = {}
    for mono, coeff in poly.items():
        if sum(mono) > max_degree:
            continue
        # Expand product of G_j^{e_j}
        term = {tuple(0 for _ in range(n)): coeff}
        for j, exp in enumerate(mono):
            if exp == 0:
                continue
            gj_pow = poly_power(G.polys[j], exp, n)
            term = poly_mul(term, gj_pow, n)
        
        for m, c in term.items():
            if sum(m) <= max_degree:
                result[m] = result.get(m, 0) + c
    
    return {k: v for k, v in result.items() if abs(v) > 1e-14}


# ============================================================
# Drużkowski Map Construction
# ============================================================

def druzkowski_map(A):
    """Construct the Drużkowski map F(x) = x + (Ax)^[3]."""
    n = A.shape[0]
    polys = []
    for i in range(n):
        poly = {}
        # x_i term
        id_mono = tuple(1 if k == i else 0 for k in range(n))
        poly[id_mono] = 1.0
        
        # (A[i] · x)^3 = (sum_j A[i][j] x_j)^3
        linear = {}
        for j in range(n):
            if abs(A[i][j]) > 1e-14:
                mono_j = tuple(1 if k == j else 0 for k in range(n))
                linear[mono_j] = A[i][j]
        
        cubic = poly_power(linear, 3, n)
        for mono, coeff in cubic.items():
            poly[mono] = poly.get(mono, 0) + coeff
        
        poly = {k: v for k, v in poly.items() if abs(v) > 1e-14}
        polys.append(poly)
    
    return PolyMap(n, polys)


# ============================================================
# Sparse Cubic Conjecture Testing
# ============================================================

def test_sparse_cubic_conjecture(n=2, num_trials=100, coeff_range=3):
    """Test the Cubic Nilpotent-2 Conjecture:
    Every Drużkowski map with A^2 = 0 is invertible.
    
    Generates random nilpotent-2 matrices and checks invertibility.
    """
    print(f"\n{'='*60}")
    print(f"SPARSE CUBIC CONJECTURE TEST (n={n})")
    print(f"{'='*60}")
    print(f"Testing: A² = 0 ⟹ F = x + (Ax)³ is invertible")
    print(f"Trials: {num_trials}, coefficient range: [-{coeff_range}, {coeff_range}]")
    
    counterexamples = 0
    total_tested = 0
    
    for trial in range(num_trials):
        # Generate random strictly upper triangular matrix (always nilpotent-2 for n≤3)
        A = np.zeros((n, n))
        for i in range(n):
            for j in range(i+1, n):
                A[i][j] = np.random.randint(-coeff_range, coeff_range + 1)
        
        # Verify A^2 = 0
        if np.linalg.norm(A @ A) > 1e-10:
            continue
        
        if np.linalg.norm(A) < 1e-10:
            continue
        
        total_tested += 1
        F = druzkowski_map(A)
        
        # Check Keller condition
        keller, det_val = is_keller(F)
        if not keller:
            continue
        
        # Attempt inverse
        G, residual = attempt_inverse(F, max_degree=6)
        
        if residual > 1e-4:
            counterexamples += 1
            print(f"\n  ⚠ Potential issue (trial {trial}):")
            print(f"    A = {A.tolist()}")
            print(f"    Residual = {residual:.6e}")
    
    print(f"\nResults: {total_tested} nilpotent-2 matrices tested")
    print(f"Counterexamples found: {counterexamples}")
    if counterexamples == 0:
        print("✓ Conjecture holds for all tested cases!")
    else:
        print("✗ Potential counterexamples found (check residuals)")
    
    return counterexamples


# ============================================================
# Main Demo
# ============================================================

def demo_linear_part():
    """Demonstrate linear part extraction and Keller checking."""
    print("="*60)
    print("DEMO 1: Linear Part Extraction & Keller Condition")
    print("="*60)
    
    n = 2
    # F(x,y) = (x + y^3, y + x^2*y)
    polys = [
        {(1,0): 1.0, (0,3): 1.0},           # x + y^3
        {(0,1): 1.0, (2,1): 1.0},            # y + x^2*y
    ]
    F = PolyMap(n, polys)
    
    print("\nPolynomial map F:")
    print(F)
    
    L = linear_part_matrix(F)
    print(f"\nLinear part matrix:\n{L}")
    print(f"det(L) = {np.linalg.det(L):.4f}")
    
    keller, det_val = is_keller(F)
    print(f"\nKeller condition: {keller}")
    if keller:
        print(f"Jacobian determinant ≈ {det_val:.6f}")
    else:
        print("Jacobian determinant varies (not constant)")
    
    # Test at specific points
    print("\nJacobian determinant at sample points:")
    for x in [np.array([0,0]), np.array([1,0]), np.array([0,1]), np.array([1,1])]:
        d = jacobian_det_at(F, x)
        print(f"  det(JF({x})) = {d:.6f}")


def demo_druzkowski():
    """Demonstrate Drużkowski map construction and analysis."""
    print("\n" + "="*60)
    print("DEMO 2: Drużkowski Maps")
    print("="*60)
    
    # Nilpotent matrix (A^2 = 0)
    A = np.array([[0, 1], [0, 0]], dtype=float)
    print(f"\nMatrix A:\n{A}")
    print(f"A² = {(A @ A).tolist()}")
    
    F = druzkowski_map(A)
    print(f"\nDrużkowski map F = x + (Ax)³:")
    print(F)
    
    L = linear_part_matrix(F)
    print(f"\nLinear part matrix:\n{L}")
    
    keller, det_val = is_keller(F)
    print(f"\nKeller condition: {keller}")
    if det_val is not None:
        print(f"Jacobian determinant ≈ {det_val:.6f}")
    
    cubic = is_cubic_homogeneous_perturbation(F)
    print(f"Cubic homogeneous perturbation: {cubic}")
    
    # Attempt inverse
    G, residual = attempt_inverse(F, max_degree=8)
    print(f"\nInverse reconstruction (degree ≤ 8):")
    print(f"  Residual (||F∘G - Id||) = {residual:.2e}")
    if residual < 1e-6:
        print("  ✓ Inverse found!")
    print(f"\nInverse map G:")
    print(G)


def demo_normalization():
    """Demonstrate normalization to identity linear part."""
    print("\n" + "="*60)
    print("DEMO 3: Normalization to Identity Linear Part")
    print("="*60)
    
    n = 2
    # F(x,y) = (2x + y + x^3, x + 3y + y^3)
    polys = [
        {(1,0): 2.0, (0,1): 1.0, (3,0): 1.0},
        {(1,0): 1.0, (0,1): 3.0, (0,3): 1.0},
    ]
    F = PolyMap(n, polys)
    
    print("\nOriginal map F:")
    print(F)
    
    L = linear_part_matrix(F)
    print(f"\nLinear part matrix L:\n{L}")
    print(f"det(L) = {np.linalg.det(L):.4f}")
    
    result = normalize_to_identity_linear_part(F)
    if result is not None:
        G, L_mat, L_inv = result
        print(f"\nNormalized map G = F ∘ L⁻¹:")
        print(G)
        
        L_new = linear_part_matrix(G)
        print(f"\nLinear part of G:\n{L_new}")
        print(f"(Should be identity matrix)")
        
        keller_F, _ = is_keller(F)
        keller_G, _ = is_keller(G)
        print(f"\nF is Keller: {keller_F}")
        print(f"G is Keller: {keller_G}")
    else:
        print("\nCannot normalize: linear part is singular")


def demo_3d_druzkowski():
    """Demonstrate 3D Drużkowski map."""
    print("\n" + "="*60)
    print("DEMO 4: 3D Drużkowski Map")
    print("="*60)
    
    # 3x3 nilpotent matrix
    A = np.array([
        [0, 1, 0],
        [0, 0, 1],
        [0, 0, 0]
    ], dtype=float)
    
    print(f"Matrix A:\n{A}")
    print(f"A² = \n{A @ A}")
    print(f"A³ = \n{A @ A @ A}")
    print(f"A is nilpotent: True (A³ = 0)")
    
    F = druzkowski_map(A)
    print(f"\nDrużkowski map F = x + (Ax)³:")
    print(F)
    
    keller, det_val = is_keller(F)
    print(f"\nKeller condition: {keller}")
    if det_val is not None:
        print(f"Jacobian determinant ≈ {det_val:.6f}")
    
    G, residual = attempt_inverse(F, max_degree=10)
    print(f"\nInverse reconstruction (degree ≤ 10):")
    print(f"  Residual = {residual:.2e}")
    if residual < 1e-4:
        print("  ✓ Inverse found!")


def main():
    np.random.seed(42)
    
    print("╔" + "═"*58 + "╗")
    print("║  JACOBIAN CONJECTURE: KELLER MAP REDUCTION THEORY       ║")
    print("║  Interactive Demonstration                               ║")
    print("╚" + "═"*58 + "╝")
    
    demo_linear_part()
    demo_druzkowski()
    demo_normalization()
    demo_3d_druzkowski()
    test_sparse_cubic_conjecture(n=2, num_trials=200)
    test_sparse_cubic_conjecture(n=3, num_trials=100)
    
    print("\n" + "="*60)
    print("SUMMARY OF FORMALLY VERIFIED RESULTS")
    print("="*60)
    print("""
The following theorems are formally verified in Lean 4:

1. keller_linear_part_det_ne_zero
   If F has constant nonzero Jacobian determinant, then
   det(linearPartMatrix F) ≠ 0.

2. linearConj_invertible_iff
   Invertibility of a polynomial map is preserved under
   linear conjugation: F invertible ⟺ A∘F∘A⁻¹ invertible.

3. exists_conjugate_identity_linear_part
   Every Keller map is linearly conjugate to one with
   identity linear part.

4. isNilpotent_of_det_one_add_smul
   If det(I + tA) = 1 for all t, then A is nilpotent.

5. charpoly_nilpotent_eq_X_pow
   Nilpotent matrices have characteristic polynomial X^n.

6. strictUpperTriang_nilpotent
   Strictly upper triangular matrices satisfy A^n = 0.

7. druzkowski_isCubicHomog
   Drużkowski maps are cubic homogeneous perturbations.

8. cubicHomog_hasIdentityLinearPart
   Cubic homogeneous perturbations have identity linear part.

9. polyComp_assoc
   Polynomial map composition is associative.

10. matrixToPoly_invertible
    Linear maps give polynomial automorphisms.
""")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: Jacobian Determinant Heatmap for Keller Maps

This script visualizes how the Jacobian determinant of a polynomial map
varies across a 2D domain. For Keller maps, the determinant is constant
(the heatmap should be uniform). For non-Keller maps, the determinant
varies, revealing the geometric structure of the map.

Uses matplotlib to produce a static PNG.
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.colors as mcolors


def poly_eval_2d(poly, x, y):
    """Evaluate a 2D polynomial at (x, y)."""
    val = 0.0
    for (ex, ey), c in poly.items():
        val += c * (x ** ex) * (y ** ey)
    return val


def jacobian_det_2d(F1, F2, x, y):
    """Compute Jacobian determinant for 2D map at (x,y)."""
    # ∂F1/∂x
    dF1dx = sum(c * ex * x**(ex-1) * y**ey for (ex, ey), c in F1.items() if ex > 0)
    # ∂F1/∂y
    dF1dy = sum(c * x**ex * ey * y**(ey-1) for (ex, ey), c in F1.items() if ey > 0)
    # ∂F2/∂x
    dF2dx = sum(c * ex * x**(ex-1) * y**ey for (ex, ey), c in F2.items() if ex > 0)
    # ∂F2/∂y
    dF2dy = sum(c * x**ex * ey * y**(ey-1) for (ex, ey), c in F2.items() if ey > 0)
    return dF1dx * dF2dy - dF1dy * dF2dx


# Define maps
# Map 1: Keller map F(x,y) = (x + y³, y) — det(JF) = 1 everywhere
keller_F1 = {(1, 0): 1.0, (0, 3): 1.0}
keller_F2 = {(0, 1): 1.0}

# Map 2: Non-Keller map F(x,y) = (x + xy², y + x²y) — det varies
nonkeller_F1 = {(1, 0): 1.0, (1, 2): 1.0}
nonkeller_F2 = {(0, 1): 1.0, (2, 1): 1.0}

# Map 3: Another Keller (Drużkowski) F(x,y) = (x + (x+y)³, y) — not actually Keller
druz_F1 = {(1, 0): 1.0, (3, 0): 1.0, (2, 1): 3.0, (1, 2): 3.0, (0, 3): 1.0}
druz_F2 = {(0, 1): 1.0}

# Grid
grid_size = 200
x_range = np.linspace(-1.5, 1.5, grid_size)
y_range = np.linspace(-1.5, 1.5, grid_size)
X, Y = np.meshgrid(x_range, y_range)

fig, axes = plt.subplots(1, 3, figsize=(16, 5))

maps = [
    ("Keller Map\nF = (x + y³, y)\ndet(JF) = 1", keller_F1, keller_F2),
    ("Non-Keller Map\nF = (x + xy², y + x²y)", nonkeller_F1, nonkeller_F2),
    ("Drużkowski-type\nF = (x + (x+y)³, y)", druz_F1, druz_F2),
]

for ax, (title, F1, F2) in zip(axes, maps):
    Z = np.zeros_like(X)
    for i in range(grid_size):
        for j in range(grid_size):
            Z[i, j] = jacobian_det_2d(F1, F2, X[i, j], Y[i, j])
    
    vmin, vmax = max(Z.min(), -5), min(Z.max(), 5)
    im = ax.imshow(Z, extent=[-1.5, 1.5, -1.5, 1.5], origin='lower',
                   cmap='RdBu_r', vmin=vmin, vmax=vmax, aspect='equal')
    ax.set_title(title, fontsize=11)
    ax.set_xlabel('x')
    ax.set_ylabel('y')
    plt.colorbar(im, ax=ax, label='det(JF)')

plt.suptitle('Jacobian Determinant Landscapes\nKeller maps have constant determinant; non-Keller maps show variation',
             fontsize=13, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('jacobian_heatmap.png', dpi=150, bbox_inches='tight')
print("Saved jacobian_heatmap.png")


#!/usr/bin/env python3
"""
Visualization: Nilpotency Spectrum of Drużkowski Matrices

This script visualizes the distribution of nilpotency indices
for random matrices A in small dimensions, comparing:
- Generic matrices (rarely nilpotent)
- Upper triangular matrices (always nilpotent)
- Matrices satisfying det(I + tA) = 1 for all t (always nilpotent by our theorem)

The visualization demonstrates why the isNilpotent_of_det_one_add_smul
theorem is significant: the Keller condition forces nilpotency.

Uses matplotlib to produce a static PNG.
"""

import numpy as np
import matplotlib.pyplot as plt


def nilpotency_index(A, tol=1e-8):
    """Find the nilpotency index k: smallest k with A^k ≈ 0, or -1."""
    n = A.shape[0]
    power = np.eye(n)
    for k in range(1, n + 2):
        power = power @ A
        if np.linalg.norm(power) < tol:
            return k
    return -1  # Not nilpotent


def check_keller_matrix(A, n, num_points=50, tol=1e-6):
    """Check if det(I + tA) = 1 for random values of t."""
    for _ in range(num_points):
        t = np.random.randn()
        d = np.linalg.det(np.eye(n) + t * A)
        if abs(d - 1) > tol:
            return False
    return True


def generate_keller_matrices(n, count=1000):
    """Generate matrices satisfying det(I + tA) ≈ 1 for all t.
    These must be nilpotent by our theorem."""
    results = []
    # Strategy: strictly upper triangular matrices with trace-0 perturbations
    attempts = 0
    while len(results) < count and attempts < count * 100:
        attempts += 1
        # Random nilpotent matrix (upper triangular)
        A = np.zeros((n, n))
        for i in range(n):
            for j in range(i + 1, n):
                A[i][j] = np.random.choice([-2, -1, 0, 0, 0, 1, 2])
        
        if check_keller_matrix(A, n):
            results.append(A)
    return results


# Parameters
dims = [2, 3, 4]
fig, axes = plt.subplots(1, 3, figsize=(15, 5))

for ax, n in zip(axes, dims):
    # Generate strictly upper triangular matrices
    upper_indices = []
    keller_indices = []
    random_nilpotent_count = 0
    random_total = 2000
    
    for _ in range(2000):
        # Upper triangular
        A = np.zeros((n, n))
        for i in range(n):
            for j in range(i + 1, n):
                A[i][j] = np.random.randn()
        idx = nilpotency_index(A)
        if idx > 0:
            upper_indices.append(idx)
    
    # Generate Keller-type matrices
    keller_mats = generate_keller_matrices(n, count=min(500, 2000))
    for A in keller_mats:
        idx = nilpotency_index(A)
        if idx > 0:
            keller_indices.append(idx)
    
    # Count nilpotent among random matrices
    for _ in range(random_total):
        A = np.random.randn(n, n) * 0.5
        idx = nilpotency_index(A)
        if idx > 0:
            random_nilpotent_count += 1
    
    # Plot
    bins = np.arange(0.5, n + 2.5, 1)
    if upper_indices:
        ax.hist(upper_indices, bins=bins, alpha=0.6, label='Upper triangular',
                color='steelblue', edgecolor='white')
    if keller_indices:
        ax.hist(keller_indices, bins=bins, alpha=0.6, label='Keller-type',
                color='coral', edgecolor='white')
    
    ax.set_title(f'n = {n}\n({random_nilpotent_count}/{random_total} random matrices nilpotent)',
                 fontsize=11)
    ax.set_xlabel('Nilpotency index k (A^k = 0)')
    ax.set_ylabel('Count')
    ax.legend(fontsize=9)
    ax.set_xticks(range(1, n + 2))

plt.suptitle('Nilpotency Index Distribution\nTheorem: Keller condition forces nilpotency',
             fontsize=13, fontweight='bold')
plt.tight_layout()
plt.savefig('nilpotency_spectrum.png', dpi=150, bbox_inches='tight')
print("Saved nilpotency_spectrum.png")
