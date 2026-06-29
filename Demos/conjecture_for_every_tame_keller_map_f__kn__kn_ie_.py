#!/usr/bin/env python3
"""
Applications of Jacobian Conjecture reduction theory.

Demonstrates real-world applications of the formal theorems:
1. Certified symbolic inversion of polynomial maps
2. Nilpotence-based filtering of Keller map candidates
3. Complexity analysis of polynomial automorphism groups
"""

import numpy as np
from typing import List, Tuple, Dict, Optional
from itertools import product


# ============================================================
# Application 1: Certified Symbolic Inversion
# ============================================================

def invert_elementary_map(n: int, idx: int, coeff: float, 
                          poly_coeffs: Dict[tuple, float]) -> Dict[str, any]:
    """
    Invert an elementary polynomial map with certified degree bound.
    
    For F(x) where F_idx = coeff * x_idx + p(x_0,...,x_{idx-1}),
    the inverse is F⁻¹_idx = (1/coeff) * (x_idx - p(x_0,...,x_{idx-1})).
    
    Key theorem: deg(F⁻¹) = deg(F) for elementary maps.
    
    Returns:
        Dictionary with inverse map data and degree certificate.
    """
    assert coeff != 0, "Coefficient must be nonzero"
    
    # Compute inverse coefficients
    inv_coeff = 1.0 / coeff
    inv_poly = {}
    
    # x_idx coordinate of inverse: (1/coeff) * x_idx - (1/coeff) * p
    unit_idx = tuple(1 if j == idx else 0 for j in range(n))
    inv_poly[unit_idx] = inv_coeff
    
    for multi_idx, c in poly_coeffs.items():
        if multi_idx in inv_poly:
            inv_poly[multi_idx] -= inv_coeff * c
        else:
            inv_poly[multi_idx] = -inv_coeff * c
    
    # Degree computation
    forward_deg = max((sum(mi) for mi in poly_coeffs.keys()), default=0)
    forward_deg = max(forward_deg, 1)  # at least degree 1 from x_idx
    
    inverse_deg = max((sum(mi) for mi in inv_poly.keys()), default=0)
    
    return {
        'inverse_coord': inv_poly,
        'forward_degree': forward_deg,
        'inverse_degree': inverse_deg,
        'degree_preserved': forward_deg == inverse_deg,
        'degree_certificate': f"deg(F⁻¹) = {inverse_deg} = deg(F) = {forward_deg}"
    }


def invert_tame_composition(elementary_factors: List[dict]) -> dict:
    """
    Invert a tame automorphism given as a composition of elementary maps.
    
    Key theorem: For F = E₁ ∘ ... ∘ Eₖ, F⁻¹ = Eₖ⁻¹ ∘ ... ∘ E₁⁻¹,
    and deg(F⁻¹) ≤ ∏ᵢ deg(Eᵢ).
    
    Args:
        elementary_factors: List of elementary map specifications
        
    Returns:
        Inversion data with degree bounds.
    """
    degrees = [f['degree'] for f in elementary_factors]
    product_bound = 1
    for d in degrees:
        product_bound *= d
    
    n = elementary_factors[0].get('n', 2)
    tame_bound = max(degrees) ** max(n - 1, 0) if degrees else 1
    
    return {
        'num_factors': len(elementary_factors),
        'factor_degrees': degrees,
        'product_bound': product_bound,
        'tame_bound': tame_bound,
        'inverse_strategy': 'reverse composition of elementary inverses',
    }


# ============================================================
# Application 2: Keller Map Candidate Filter
# ============================================================

def filter_keller_candidates_2d(candidates: List[np.ndarray], 
                                 tol: float = 1e-10) -> dict:
    """
    Filter 2D Keller map candidates using nilpotence criterion.
    
    For a polynomial map F = I + H where H is homogeneous of degree 3,
    the Keller condition det(JF) = 1 implies JH is nilpotent.
    
    In 2D: JH nilpotent ⟺ tr(JH) = 0 and det(JH) = 0.
    This is our theorem Matrix.isNilpotent_of_trace_zero_det_zero.
    
    Args:
        candidates: List of 2×2 Jacobian matrices to test
        
    Returns:
        Classification of candidates.
    """
    results = {
        'total': len(candidates),
        'pass_trace': 0,
        'pass_det': 0,
        'pass_nilpotent': 0,
        'pass_keller': 0,
        'details': [],
    }
    
    for i, JH in enumerate(candidates):
        tr = np.trace(JH)
        det = np.linalg.det(JH)
        
        trace_zero = abs(tr) < tol
        det_zero = abs(det) < tol
        is_nilpotent = trace_zero and det_zero
        
        # Check full Keller condition: det(I + JH) = 1
        keller = abs(np.linalg.det(np.eye(2) + JH) - 1.0) < tol
        
        if trace_zero:
            results['pass_trace'] += 1
        if det_zero:
            results['pass_det'] += 1
        if is_nilpotent:
            results['pass_nilpotent'] += 1
        if keller:
            results['pass_keller'] += 1
        
        results['details'].append({
            'index': i,
            'trace': float(tr),
            'det': float(det),
            'nilpotent': is_nilpotent,
            'keller': keller,
        })
    
    return results


def generate_random_keller_jacobians(n: int, count: int = 10) -> List[np.ndarray]:
    """
    Generate random nilpotent matrices (which automatically satisfy Keller).
    
    Strategy: generate strictly upper triangular matrices (always nilpotent).
    """
    matrices = []
    for _ in range(count):
        A = np.zeros((n, n))
        for i in range(n):
            for j in range(i + 1, n):
                A[i, j] = np.random.randn()
        matrices.append(A)
    return matrices


# ============================================================
# Application 3: Complexity Stratification
# ============================================================

def complexity_profile(degrees: List[int], n: int) -> dict:
    """
    Compute the complexity profile of a tame automorphism.
    
    Given the degree sequence of elementary factors, compute:
    - Forward degree
    - Inverse degree bound (product bound)
    - Tame inverse bound (d^{n-1})
    - Complexity ratio (inverse_bound / forward_degree)
    
    The complexity ratio measures "how hard inversion is" relative
    to the forward map. A key insight from our theorems is that this
    ratio is always bounded.
    """
    if not degrees:
        return {'forward_degree': 1, 'inverse_bound': 1, 'ratio': 1.0}
    
    # Forward degree: bounded by product
    forward = 1
    for d in degrees:
        forward *= d
    forward = min(forward, max(degrees) ** n)  # Tighter bound
    
    # Inverse degree bound
    inverse_product = 1
    for d in degrees:
        inverse_product *= d
    
    forward_actual = max(degrees)  # Typical case for triangular
    tame_bound = forward_actual ** max(n - 1, 0)
    
    return {
        'num_variables': n,
        'num_factors': len(degrees),
        'factor_degrees': degrees,
        'forward_degree': forward_actual,
        'inverse_product_bound': inverse_product,
        'inverse_tame_bound': tame_bound,
        'complexity_ratio': inverse_product / max(forward_actual, 1),
        'tame_ratio': tame_bound / max(forward_actual, 1),
    }


def demo_applications():
    """Run all application demonstrations."""
    
    print("=" * 70)
    print("APPLICATION 1: Certified Symbolic Inversion")
    print("=" * 70)
    
    # Invert elementary map F(x,y) = (x + y², y)
    result = invert_elementary_map(
        n=2, idx=0, coeff=1.0,
        poly_coeffs={(0, 2): 1.0}  # y²
    )
    print("\nElementary map: F(x,y) = (x + y², y)")
    print(f"  Forward degree: {result['forward_degree']}")
    print(f"  Inverse degree: {result['inverse_degree']}")
    print(f"  {result['degree_certificate']}")
    
    # Invert composition
    factors = [
        {'n': 3, 'degree': 2, 'desc': 'x₀ += x₁²'},
        {'n': 3, 'degree': 3, 'desc': 'x₁ += x₂³'},
        {'n': 3, 'degree': 2, 'desc': 'x₂ += x₀²'},
    ]
    comp_result = invert_tame_composition(factors)
    print(f"\nTame composition of {comp_result['num_factors']} elementary maps:")
    for f in factors:
        print(f"  {f['desc']} (degree {f['degree']})")
    print(f"  Product bound on inverse degree: {comp_result['product_bound']}")
    print(f"  Tame bound d^(n-1): {comp_result['tame_bound']}")
    
    print("\n" + "=" * 70)
    print("APPLICATION 2: Keller Map Candidate Filter")
    print("=" * 70)
    
    # Generate and filter candidates
    np.random.seed(42)
    
    # Mix of nilpotent and non-nilpotent matrices
    candidates = generate_random_keller_jacobians(2, 5)
    # Add some non-nilpotent ones
    candidates.append(np.array([[1, 0], [0, 1]], dtype=float))
    candidates.append(np.array([[0.5, 1], [0, 0.5]], dtype=float))
    
    results = filter_keller_candidates_2d(candidates)
    print(f"\nFiltered {results['total']} candidate Jacobian matrices:")
    print(f"  Pass trace test: {results['pass_trace']}")
    print(f"  Pass det test: {results['pass_det']}")
    print(f"  Pass nilpotence: {results['pass_nilpotent']}")
    print(f"  Pass Keller: {results['pass_keller']}")
    
    for d in results['details']:
        status = "✓ NILPOTENT" if d['nilpotent'] else "✗ NOT NILPOTENT"
        print(f"  Matrix {d['index']}: tr={d['trace']:.4f}, det={d['det']:.4f} → {status}")
    
    print("\n" + "=" * 70)
    print("APPLICATION 3: Complexity Stratification")
    print("=" * 70)
    
    # Analyze different tame automorphisms
    test_cases = [
        ([2], 2, "Single elementary, dim 2"),
        ([2, 3], 2, "Two elementaries, dim 2"),
        ([2, 2, 2], 3, "Three degree-2 elementaries, dim 3"),
        ([3, 3, 3, 3], 4, "Four degree-3 elementaries, dim 4"),
        ([5, 5], 3, "Two degree-5 elementaries, dim 3"),
    ]
    
    print(f"\n{'Description':<45} {'deg(F)':>6} {'∏dᵢ':>8} {'d^(n-1)':>8} {'Ratio':>8}")
    print("-" * 80)
    for degrees, n, desc in test_cases:
        profile = complexity_profile(degrees, n)
        print(f"{desc:<45} {profile['forward_degree']:>6} "
              f"{profile['inverse_product_bound']:>8} "
              f"{profile['inverse_tame_bound']:>8} "
              f"{profile['tame_ratio']:>8.1f}")


if __name__ == "__main__":
    demo_applications()


#!/usr/bin/env python3
"""
Demonstration of theorems from the Jacobian Conjecture reduction theory.

This module provides concrete numerical examples illustrating:
1. The nilpotence detection criterion: det(I + tA) = 1 for all t implies A nilpotent
2. Degree bounds for polynomial map compositions
3. Nilpotent matrix power vanishing (Cayley-Hamilton sharpening)
"""

import numpy as np
from typing import Optional

def det_one_plus_tA(A: np.ndarray, t: float) -> float:
    """Compute det(I + t*A) for a given matrix A and scalar t."""
    n = A.shape[0]
    return float(np.linalg.det(np.eye(n) + t * A))


def check_nilpotence_criterion(A: np.ndarray, num_samples: int = 100) -> dict:
    """
    Test whether det(I + tA) = 1 for many values of t.
    If so, A should be nilpotent by our theorem.
    
    Returns a dictionary with:
    - 'det_constant': whether det(I + tA) ≈ 1 for all sampled t
    - 'is_nilpotent': whether A^n ≈ 0
    - 'nilpotence_index': smallest k such that A^k ≈ 0
    - 'max_det_deviation': maximum |det(I + tA) - 1| over samples
    """
    n = A.shape[0]
    
    # Sample many t values
    t_values = np.linspace(-10, 10, num_samples)
    dets = [det_one_plus_tA(A, t) for t in t_values]
    max_dev = max(abs(d - 1.0) for d in dets)
    
    # Check nilpotence
    power = np.eye(n)
    nilpotence_index = None
    for k in range(1, n + 1):
        power = power @ A
        if np.allclose(power, 0, atol=1e-10):
            nilpotence_index = k
            break
    
    An = np.linalg.matrix_power(A, n)
    
    return {
        'det_constant': max_dev < 1e-10,
        'is_nilpotent': np.allclose(An, 0, atol=1e-10),
        'nilpotence_index': nilpotence_index,
        'max_det_deviation': max_dev,
        'matrix_size': n,
    }


def demo_nilpotence_criterion():
    """Demonstrate the nilpotence criterion with concrete examples."""
    print("=" * 70)
    print("DEMO 1: Nilpotence Detection from Determinant Constraint")
    print("Theorem: det(I + tA) = 1 for all t  ⟹  A is nilpotent")
    print("=" * 70)
    
    # Example 1: Strictly upper triangular matrix (always nilpotent)
    print("\n--- Example 1: 3×3 strictly upper triangular matrix ---")
    A1 = np.array([
        [0, 2, 3],
        [0, 0, 5],
        [0, 0, 0]
    ], dtype=float)
    print(f"A = \n{A1}")
    result = check_nilpotence_criterion(A1)
    print(f"det(I + tA) = 1 for all t? {result['det_constant']}")
    print(f"A is nilpotent? {result['is_nilpotent']}")
    print(f"Nilpotence index: {result['nilpotence_index']}")
    print(f"Max |det(I+tA) - 1|: {result['max_det_deviation']:.2e}")
    
    # Example 2: 2×2 nilpotent matrix
    print("\n--- Example 2: 2×2 matrix with trace 0 and det 0 ---")
    A2 = np.array([
        [1, 1],
        [-1, -1]
    ], dtype=float)
    print(f"A = \n{A2}")
    print(f"trace(A) = {np.trace(A2)}")
    print(f"det(A) = {np.linalg.det(A2):.6f}")
    result = check_nilpotence_criterion(A2)
    print(f"det(I + tA) = 1 for all t? {result['det_constant']}")
    print(f"A is nilpotent? {result['is_nilpotent']}")
    print(f"Nilpotence index: {result['nilpotence_index']}")
    
    # Example 3: 4×4 nilpotent matrix (Jacobian of a cubic map)
    print("\n--- Example 3: 4×4 nilpotent Jacobian-type matrix ---")
    # Construct A such that A² = 0 (modeling JH for a Drużkowski-type map)
    A3 = np.array([
        [0, 1, 0, 0],
        [0, 0, 0, 0],
        [0, 0, 0, 1],
        [0, 0, 0, 0]
    ], dtype=float)
    print(f"A = \n{A3}")
    result = check_nilpotence_criterion(A3)
    print(f"det(I + tA) = 1 for all t? {result['det_constant']}")
    print(f"A is nilpotent? {result['is_nilpotent']}")
    print(f"Nilpotence index: {result['nilpotence_index']}")
    
    # Example 4: Non-nilpotent matrix (should fail the criterion)
    print("\n--- Example 4: Non-nilpotent matrix (control) ---")
    A4 = np.array([
        [1, 0],
        [0, 1]
    ], dtype=float)
    print(f"A = \n{A4}")
    result = check_nilpotence_criterion(A4)
    print(f"det(I + tA) = 1 for all t? {result['det_constant']}")
    print(f"A is nilpotent? {result['is_nilpotent']}")
    print(f"Max |det(I+tA) - 1|: {result['max_det_deviation']:.2e}")
    
    # Example 5: A more complex nilpotent matrix
    print("\n--- Example 5: 5×5 nilpotent matrix with index 3 ---")
    A5 = np.zeros((5, 5))
    A5[0, 1] = 1; A5[1, 2] = 1; A5[2, 3] = 0
    A5[3, 4] = 0; A5[0, 2] = 2
    print(f"A = \n{A5}")
    result = check_nilpotence_criterion(A5)
    print(f"det(I + tA) = 1 for all t? {result['det_constant']}")
    print(f"A is nilpotent? {result['is_nilpotent']}")
    print(f"Nilpotence index: {result['nilpotence_index']}")


def demo_trace_vanishing():
    """Demonstrate that nilpotent matrices have vanishing traces of all powers."""
    print("\n" + "=" * 70)
    print("DEMO 2: Trace Vanishing for Nilpotent Matrices")
    print("Theorem: det(I + tA) = 1 for all t  ⟹  tr(A^k) = 0 for all k ≥ 1")
    print("=" * 70)
    
    # Nilpotent matrix
    A = np.array([
        [0, 1, 2],
        [0, 0, 3],
        [0, 0, 0]
    ], dtype=float)
    print(f"\nA = \n{A}")
    
    print("\nTraces of powers of A:")
    for k in range(1, 8):
        Ak = np.linalg.matrix_power(A, k)
        print(f"  tr(A^{k}) = {np.trace(Ak):.10f}")


def demo_degree_composition():
    """Demonstrate the degree bound for polynomial map compositions."""
    print("\n" + "=" * 70)
    print("DEMO 3: Degree Growth under Composition")
    print("Theorem: deg(F ∘ G) ≤ deg(F) · deg(G)")
    print("=" * 70)
    
    # Simulate polynomial degree growth
    # For elementary maps: F(x,y) = (x + y², y)
    # deg(F) = 2, deg(F⁻¹) = 2
    # For F∘F: (x + (y²) + y², y) = (x + 2y², y), deg = 2
    # But composition of different elementary maps can increase:
    # G(x,y) = (x, y + x³), deg(G) = 3
    # F∘G(x,y) = (x + (y+x³)², y+x³), deg = 6 = 2·3
    
    print("\nExample: Elementary maps in 2 variables")
    print("  F(x,y) = (x + y², y)         — deg(F) = 2")
    print("  G(x,y) = (x, y + x³)         — deg(G) = 3")
    print("  F∘G(x,y) = (x + (y+x³)², y+x³)")
    print("           = (x + y² + 2x³y + x⁶, y + x³)")
    print("  deg(F∘G) = 6 = deg(F) · deg(G)  ✓")
    
    print("\nDegree bound is tight in this case!")
    
    print("\nDegree growth for iterated composition:")
    print("  F¹ = F: deg = 2")
    print("  F² = F∘F: deg ≤ 2² = 4")
    print("  F³ = F∘F∘F: deg ≤ 2³ = 8")
    print("  Fⁿ: deg ≤ 2ⁿ")
    
    print("\nFor inverse of composition of k elementary maps:")
    print("  If each has degree dᵢ, then deg(inverse) ≤ ∏ dᵢ")
    print("  This gives the tame inverse degree bound: deg(F⁻¹) ≤ deg(F)^(n-1)")


def demo_cayley_hamilton_sharpening():
    """Demonstrate the Cayley-Hamilton sharpening for nilpotent matrices."""
    print("\n" + "=" * 70)
    print("DEMO 4: Cayley-Hamilton Nilpotence Index Bound")
    print("Theorem: A nilpotent n×n matrix satisfies A^n = 0")
    print("=" * 70)
    
    for n in [2, 3, 4, 5]:
        # Create nilpotent matrix with maximal nilpotence index n
        A = np.zeros((n, n))
        for i in range(n - 1):
            A[i, i + 1] = 1  # shift matrix
        
        print(f"\n--- {n}×{n} shift matrix (nilpotence index = {n}) ---")
        
        for k in range(1, n + 2):
            Ak = np.linalg.matrix_power(A, k)
            norm = np.max(np.abs(Ak))
            is_zero = "= 0 ✓" if norm < 1e-14 else f"≠ 0 (max entry: {norm:.4f})"
            print(f"  A^{k} {is_zero}")


if __name__ == "__main__":
    demo_nilpotence_criterion()
    demo_trace_vanishing()
    demo_degree_composition()
    demo_cayley_hamilton_sharpening()
    
    print("\n" + "=" * 70)
    print("All demonstrations completed successfully.")
    print("=" * 70)
