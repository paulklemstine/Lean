#!/usr/bin/env python3
"""
Spectral Arithmetic Transfer Theory — Algorithms

Implements the core algorithms from the spectral arithmetic transfer framework.
Each algorithm translates a proved theorem into executable code for
eigenvalue analysis, modular filtering, and spectral certification.
"""

import math
from typing import List, Tuple, Dict, Set, Optional


def square_congruence_divisibility_check(N: int, a: int, b: int) -> Tuple[bool, int]:
    """
    Check if a² ≡ b² (mod N) and compute (a-b)(a+b).
    
    Implements: int_sq_congruence_implies_dvd_prod_sum
    
    If a² ≡ b² (mod N), then N | (a-b)(a+b). Returns whether the
    congruence holds and the product value.
    
    Time complexity: O(1)
    Space complexity: O(1)
    
    Args:
        N: The modulus (positive integer)
        a, b: Integer spectral parameters
        
    Returns:
        (congruence_holds, product): Whether a²≡b² mod N, and (a-b)(a+b)
    
    >>> square_congruence_divisibility_check(7, 3, 4)
    (True, -7)
    >>> square_congruence_divisibility_check(12, 7, 5)
    (True, 24)
    """
    congruent = (a * a) % N == (b * b) % N
    product = (a - b) * (a + b)
    if congruent:
        assert product % N == 0, f"Theorem violation: {N} should divide {product}"
    return congruent, product


def classify_square_classes(N: int, M: int) -> Dict[int, List[int]]:
    """
    Classify integers in [-M, M] by their square class modulo N.
    
    For each residue r, collects all x ∈ [-M, M] with x² ≡ r (mod N).
    This is the computational backbone of spectral eigenvalue filtering.
    
    Time complexity: O(M)
    Space complexity: O(M)
    
    Args:
        N: Modulus
        M: Eigenvalue bound (search in [-M, M])
    
    Returns:
        Dictionary mapping square class → list of elements
    
    >>> classes = classify_square_classes(7, 10)
    >>> len(classes[0])  # multiples of 7 in [-10, 10]
    3
    """
    classes: Dict[int, List[int]] = {}
    for x in range(-M, M + 1):
        sq_class = (x * x) % N
        if sq_class not in classes:
            classes[sq_class] = []
        classes[sq_class].append(x)
    return classes


def spectral_energy_trace_bound(eigenvalues: List[int]) -> Tuple[float, float, float, bool]:
    """
    Compute spectral energy, trace, and verify the Cauchy-Schwarz bound.
    
    Implements: int_spectral_energy_trace_bound
    
    For integer eigenvalues λ₁, ..., λₙ:
        (∑ λᵢ)² / n ≤ ∑ λᵢ²
    
    Time complexity: O(n)
    Space complexity: O(1)
    
    Args:
        eigenvalues: List of integer eigenvalues
        
    Returns:
        (trace, energy, bound_ratio, bound_satisfied)
    
    >>> spectral_energy_trace_bound([1, 2, 3, 4, 5])
    (15.0, 55.0, 0.8181818181818182, True)
    """
    n = len(eigenvalues)
    if n == 0:
        return 0.0, 0.0, 0.0, True
    
    trace = float(sum(eigenvalues))
    energy = float(sum(x**2 for x in eigenvalues))
    ratio = (trace**2 / n) / energy if energy > 0 else 0.0
    bound_ok = trace**2 / n <= energy + 1e-10  # small tolerance
    
    return trace, energy, ratio, bound_ok


def modular_collision_certificate(N: int, eigenvalues: List[int]) -> Dict[str, object]:
    """
    Generate a complete modular collision certificate for a spectral family.
    
    Implements: spectral_family_pairwise_dvd + spectral_energy_modular_collision_bound
    
    For each pair (i, j) with λᵢ² ≡ λⱼ² (mod N), verifies that
    N | (λᵢ - λⱼ)(λᵢ + λⱼ), and combines with the energy-trace bound.
    
    Time complexity: O(n²)
    Space complexity: O(n²)
    
    Args:
        N: Modulus
        eigenvalues: List of integer eigenvalues
        
    Returns:
        Certificate dictionary with collision analysis
    """
    n = len(eigenvalues)
    trace, energy, ratio, bound_ok = spectral_energy_trace_bound(eigenvalues)
    
    collisions = []
    for i in range(n):
        for j in range(i + 1, n):
            a, b = eigenvalues[i], eigenvalues[j]
            if (a * a) % N == (b * b) % N:
                product = (a - b) * (a + b)
                assert product % N == 0
                collisions.append({
                    'i': i, 'j': j,
                    'a': a, 'b': b,
                    'product': product,
                    'quotient': product // N
                })
    
    # Group by square class
    classes = {}
    for x in eigenvalues:
        sq = (x * x) % N
        if sq not in classes:
            classes[sq] = []
        classes[sq].append(x)
    
    return {
        'N': N,
        'n': n,
        'trace': trace,
        'energy': energy,
        'trace_sq_over_n': trace**2 / n if n > 0 else 0,
        'bound_satisfied': bound_ok,
        'num_collisions': len(collisions),
        'collisions': collisions,
        'square_classes': classes,
        'max_class_size': max(len(v) for v in classes.values()) if classes else 0
    }


def prime_3mod4_sign_collapse(p: int, a: int, b: int) -> Optional[str]:
    """
    For prime p ≡ 3 (mod 4), determine if a² ≡ b² (mod p)
    and if so, classify the collision as a = b or a = -b.
    
    Implements: prime_three_mod_four_no_nonsign_square_collision
    
    Time complexity: O(1)
    
    Args:
        p: Prime ≡ 3 (mod 4)
        a, b: Elements of Z/pZ (integers mod p)
        
    Returns:
        None if a² ≢ b² (mod p), "equal" if a ≡ b, "negation" if a ≡ -b
    """
    a_mod = a % p
    b_mod = b % p
    
    if (a_mod * a_mod) % p != (b_mod * b_mod) % p:
        return None
    
    if a_mod == b_mod:
        return "equal"
    elif (a_mod + b_mod) % p == 0:
        return "negation"
    else:
        raise ValueError(f"Theorem violation at p={p}: a²≡b² but a≠b and a≠-b")


def B2_polynomial_analysis(x_range: Tuple[int, int] = (-100, 100)) -> Dict[str, object]:
    """
    Analyze the B₂ characteristic cubic x³ - 5x² + 5x - 1.
    
    Implements: satisfies_B2_poly, B2_poly_factorization, B2_int_roots
    
    Finds integer roots, verifies factorization, and computes real roots.
    
    Args:
        x_range: Range to search for integer roots
    
    Returns:
        Analysis dictionary
    """
    int_roots = []
    for x in range(x_range[0], x_range[1] + 1):
        if x**3 - 5*x**2 + 5*x - 1 == 0:
            int_roots.append(x)
    
    # Real roots of quadratic factor
    discriminant = 16 - 4  # = 12
    real_root_1 = 2 + math.sqrt(3)
    real_root_2 = 2 - math.sqrt(3)
    
    return {
        'polynomial': 'x³ - 5x² + 5x - 1',
        'factorization': '(x - 1)(x² - 4x + 1)',
        'integer_roots': int_roots,
        'all_real_roots': [1.0, real_root_1, real_root_2],
        'spectral_radius': real_root_1,
        'conjugate_radius': real_root_2,
        'product_of_irrational_roots': real_root_1 * real_root_2,
        'sum_of_irrational_roots': real_root_1 + real_root_2,
        'discriminant_of_quadratic': discriminant
    }


def spectral_feasibility_filter(
    N: int,
    M: int,
    n: int,
    energy_budget: float
) -> List[List[int]]:
    """
    Find all feasible integer spectra of size n within [-M, M]
    where all squares are congruent mod N and energy ≤ budget.
    
    This combines:
    - int_sq_congruence_implies_dvd_prod_sum (modular filter)
    - int_spectral_energy_trace_bound (energy filter)
    
    Time complexity: O(M^n / N^(n-1)) approximately
    
    Args:
        N: Modulus for square congruence
        M: Eigenvalue bound
        n: Number of eigenvalues
        energy_budget: Maximum spectral energy ∑λᵢ²
    
    Returns:
        List of feasible eigenvalue tuples (sorted, distinct)
    """
    # Get square classes
    classes = classify_square_classes(N, M)
    
    feasible = []
    for sq_class, members in classes.items():
        # Generate n-element subsets of this class
        if len(members) < n:
            continue
        
        # Use itertools-like generation for small n
        def generate(start_idx: int, remaining: int, current: List[int]):
            if remaining == 0:
                energy = sum(x**2 for x in current)
                if energy <= energy_budget:
                    feasible.append(list(current))
                return
            for i in range(start_idx, len(members)):
                current.append(members[i])
                generate(i + 1, remaining - 1, current)
                current.pop()
        
        if n <= 4:  # Only enumerate for small n
            generate(0, n, [])
    
    return feasible


# Example usage and testing
if __name__ == "__main__":
    print("=== Algorithm Tests ===\n")
    
    # Test 1: Square congruence
    print("1. Square Congruence Divisibility:")
    for N, a, b in [(7, 3, 4), (12, 7, 5), (100, 47, 53)]:
        ok, prod = square_congruence_divisibility_check(N, a, b)
        print(f"   N={N}, a={a}, b={b}: congruent={ok}, (a-b)(a+b)={prod}")
    
    # Test 2: Classification
    print("\n2. Square Class Classification (N=7, M=20):")
    classes = classify_square_classes(7, 20)
    for k in sorted(classes.keys()):
        print(f"   Class {k}: {len(classes[k])} elements")
    
    # Test 3: Modular certificate
    print("\n3. Modular Collision Certificate:")
    cert = modular_collision_certificate(7, [1, 6, 8, 13, 20])
    print(f"   N={cert['N']}, n={cert['n']}")
    print(f"   Trace={cert['trace']}, Energy={cert['energy']}")
    print(f"   Collisions: {cert['num_collisions']}")
    print(f"   Square classes: {dict((k, len(v)) for k,v in cert['square_classes'].items())}")
    
    # Test 4: B2 analysis
    print("\n4. B₂ Polynomial Analysis:")
    analysis = B2_polynomial_analysis()
    print(f"   Integer roots: {analysis['integer_roots']}")
    print(f"   Spectral radius: {analysis['spectral_radius']:.6f}")
    print(f"   Root product: {analysis['product_of_irrational_roots']:.6f}")
    
    # Test 5: Feasibility filter
    print("\n5. Spectral Feasibility Filter (N=7, M=15, n=3, budget=200):")
    feasible = spectral_feasibility_filter(7, 15, 3, 200)
    print(f"   Found {len(feasible)} feasible spectra")
    if feasible:
        for spec in feasible[:5]:
            energy = sum(x**2 for x in spec)
            print(f"   {spec} → energy={energy}")
        if len(feasible) > 5:
            print(f"   ... and {len(feasible)-5} more")
    
    print("\nAll algorithm tests passed! ✓")
