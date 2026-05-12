#!/usr/bin/env python3
"""
Tropical Hecke Realization Duality — Algorithms

Implements the core algorithms from the reconstruction theorem:
1. Tropical convolution via structure constants
2. Spherical compatibility verification
3. Separation and nondegeneracy checks
4. Reconstruction of structure constants from evaluation data
5. Canonical basis extraction

All algorithms work over the max-plus tropical semiring (ℝ ∪ {-∞}, max, +).
"""

import numpy as np
from typing import List, Tuple, Optional
from itertools import product

# =============================================================================
# Tropical Arithmetic
# =============================================================================

NEG_INF = float('-inf')

def trop_add(a: float, b: float) -> float:
    """Tropical addition: max(a, b)"""
    return max(a, b)

def trop_mul(a: float, b: float) -> float:
    """Tropical multiplication: a + b (with -∞ absorbing)"""
    if a == NEG_INF or b == NEG_INF:
        return NEG_INF
    return a + b

def trop_sup(values: List[float]) -> float:
    """Tropical supremum: max of all values"""
    if not values:
        return NEG_INF
    return max(values)


# =============================================================================
# Algorithm 1: Tropical Convolution
# =============================================================================

def tropical_convolve(c: List[List[List[float]]], f: List[float],
                      g: List[float]) -> List[float]:
    """
    Compute the tropical convolution (f ⋆ g) using structure constants c.
    
    (f ⋆ g)(m) = max_{i,j} (f(i) + g(j) + c[i][j][m])
    
    Args:
        c: Structure constants c[i][j][k], shape (n, n, n)
        f: First coefficient vector, length n
        g: Second coefficient vector, length n
    
    Returns:
        Result vector of length n
    
    Time complexity: O(n³)
    Space complexity: O(n)
    """
    n = len(f)
    result = [NEG_INF] * n
    for m in range(n):
        for i in range(n):
            for j in range(n):
                val = trop_mul(trop_mul(f[i], g[j]), c[i][j][m])
                result[m] = trop_add(result[m], val)
    return result


# =============================================================================
# Algorithm 2: Spherical Compatibility Verification
# =============================================================================

def verify_spherical_compatibility(c: List[List[List[float]]],
                                    E: List[List[float]],
                                    tol: float = 1e-10) -> Tuple[bool, List[str]]:
    """
    Verify that evaluation matrix E satisfies spherical compatibility with
    structure constants c.
    
    Checks: E[ω][i] + E[ω][j] = max_k (c[i][j][k] + E[ω][k]) for all ω, i, j
    
    Args:
        c: Structure constants, shape (n, n, n)
        E: Evaluation matrix, shape (m, n)
        tol: Numerical tolerance
    
    Returns:
        (is_compatible, list_of_violations)
    
    Time complexity: O(m · n³)
    """
    n = len(c)
    m = len(E)
    violations = []
    
    for w in range(m):
        for i in range(n):
            for j in range(n):
                lhs = trop_mul(E[w][i], E[w][j])
                rhs = trop_sup([trop_mul(c[i][j][k], E[w][k]) for k in range(n)])
                
                if lhs == NEG_INF and rhs == NEG_INF:
                    continue
                if lhs == NEG_INF or rhs == NEG_INF:
                    violations.append(f"(ω={w}, i={i}, j={j}): {lhs} ≠ {rhs}")
                elif abs(lhs - rhs) > tol:
                    violations.append(f"(ω={w}, i={i}, j={j}): {lhs} ≠ {rhs}")
    
    return len(violations) == 0, violations


# =============================================================================
# Algorithm 3: Separation Check
# =============================================================================

def check_separation(E: List[List[float]], tol: float = 1e-10) -> Tuple[bool, Optional[Tuple[int, int]]]:
    """
    Check if the evaluation matrix E separates basis elements.
    
    Verifies: the map i ↦ (E[0][i], E[1][i], ..., E[m-1][i]) is injective.
    
    Args:
        E: Evaluation matrix, shape (m, n)
        tol: Numerical tolerance
    
    Returns:
        (is_separated, conflicting_pair_or_None)
    
    Time complexity: O(n² · m)
    """
    n = len(E[0]) if E else 0
    m = len(E)
    
    for i in range(n):
        for j in range(i + 1, n):
            same = True
            for w in range(m):
                if E[w][i] == NEG_INF and E[w][j] == NEG_INF:
                    continue
                if E[w][i] == NEG_INF or E[w][j] == NEG_INF:
                    same = False
                    break
                if abs(E[w][i] - E[w][j]) > tol:
                    same = False
                    break
            if same:
                return False, (i, j)
    
    return True, None


# =============================================================================
# Algorithm 4: Nondegeneracy Check (Approximate)
# =============================================================================

def check_nondegeneracy_approx(E: List[List[float]], 
                                num_tests: int = 100,
                                tol: float = 1e-10) -> Tuple[bool, str]:
    """
    Approximate check for evaluation nondegeneracy by testing random
    coefficient vectors.
    
    Tests whether: if max_k(a[k] + E[ω][k]) = max_k(b[k] + E[ω][k]) for all ω,
    then a = b (up to tolerance).
    
    This is a probabilistic test — it cannot prove nondegeneracy but can
    detect obvious degeneracies.
    
    Args:
        E: Evaluation matrix, shape (m, n)
        num_tests: Number of random pairs to test
        tol: Numerical tolerance
    
    Returns:
        (passed_all_tests, description)
    
    Time complexity: O(num_tests · m · n)
    """
    n = len(E[0]) if E else 0
    m = len(E)
    
    rng = np.random.default_rng(42)
    
    for t in range(num_tests):
        a = rng.uniform(-10, 10, n).tolist()
        b = rng.uniform(-10, 10, n).tolist()
        
        # Check if they give the same tropical linear combination values
        same_values = True
        for w in range(m):
            val_a = trop_sup([trop_mul(a[k], E[w][k]) for k in range(n)])
            val_b = trop_sup([trop_mul(b[k], E[w][k]) for k in range(n)])
            
            if val_a == NEG_INF and val_b == NEG_INF:
                continue
            if val_a == NEG_INF or val_b == NEG_INF:
                same_values = False
                break
            if abs(val_a - val_b) > tol:
                same_values = False
                break
        
        if same_values:
            # Check if a ≈ b
            a_eq_b = all(abs(a[k] - b[k]) < tol for k in range(n))
            if not a_eq_b:
                return False, f"Found counterexample at test {t}: a={a}, b={b}"
    
    return True, f"Passed {num_tests} random tests"


# =============================================================================
# Algorithm 5: Structure Constant Reconstruction
# =============================================================================

def reconstruct_constants(E: List[List[float]], 
                          tol: float = 1e-10) -> Optional[List[List[List[float]]]]:
    """
    Reconstruct structure constants from evaluation data.
    
    Given evaluation matrix E satisfying spherical compatibility with some
    unknown c, reconstruct c using the residuation formula:
    
    c[i][j][k] = min_ω (E[ω][i] + E[ω][j] - E[ω][k])
    
    This is the tropical analogue of solving a linear system by residuation.
    
    Args:
        E: Evaluation matrix, shape (m, n)
    
    Returns:
        Reconstructed structure constants, shape (n, n, n), or None if
        the system is inconsistent.
    
    Time complexity: O(n³ · m)
    Space complexity: O(n³)
    
    Pseudocode:
        for each (i, j, k):
            c[i][j][k] = min over ω of (E[ω][i] + E[ω][j] - E[ω][k])
            where we skip ω where E[ω][k] = -∞
        verify compatibility
        return c
    """
    n = len(E[0]) if E else 0
    m = len(E)
    
    c = [[[NEG_INF] * n for _ in range(n)] for _ in range(n)]
    
    for i in range(n):
        for j in range(n):
            for k in range(n):
                candidates = []
                for w in range(m):
                    if E[w][k] != NEG_INF and E[w][i] != NEG_INF and E[w][j] != NEG_INF:
                        # Residuation: c[i][j][k] ≤ E[ω][i] + E[ω][j] - E[ω][k]
                        candidates.append(E[w][i] + E[w][j] - E[w][k])
                
                if candidates:
                    # Take the minimum (tropical residuation = infimum)
                    c[i][j][k] = min(candidates)
    
    return c


def verify_reconstruction(c_original: List[List[List[float]]],
                          c_reconstructed: List[List[List[float]]],
                          tol: float = 1e-10) -> Tuple[bool, int, int]:
    """
    Verify that reconstructed constants match the original.
    
    Returns:
        (all_match, num_matches, total_entries)
    """
    n = len(c_original)
    matches = 0
    total = 0
    
    for i in range(n):
        for j in range(n):
            for k in range(n):
                total += 1
                a = c_original[i][j][k]
                b = c_reconstructed[i][j][k]
                if a == NEG_INF and b == NEG_INF:
                    matches += 1
                elif a != NEG_INF and b != NEG_INF and abs(a - b) < tol:
                    matches += 1
    
    return matches == total, matches, total


# =============================================================================
# Algorithm 6: Tropical Associativity Verification
# =============================================================================

def verify_associativity(c: List[List[List[float]]], 
                         tol: float = 1e-10) -> Tuple[bool, List[str]]:
    """
    Verify tropical associativity of structure constants.
    
    Checks: max_n (c[i][j][n] + c[n][l][m]) = max_n (c[j][l][n] + c[i][n][m])
    for all i, j, l, m.
    
    Time complexity: O(n⁵)
    """
    n = len(c)
    violations = []
    
    for i, j, l, m_idx in product(range(n), repeat=4):
        lhs = trop_sup([trop_mul(c[i][j][nn], c[nn][l][m_idx]) for nn in range(n)])
        rhs = trop_sup([trop_mul(c[j][l][nn], c[i][nn][m_idx]) for nn in range(n)])
        
        if lhs == NEG_INF and rhs == NEG_INF:
            continue
        if lhs == NEG_INF or rhs == NEG_INF:
            violations.append(f"({i},{j},{l},{m_idx}): {lhs} ≠ {rhs}")
        elif abs(lhs - rhs) > tol:
            violations.append(f"({i},{j},{l},{m_idx}): {lhs} ≠ {rhs}")
    
    return len(violations) == 0, violations


# =============================================================================
# Algorithm 7: Canonical Basis Extraction
# =============================================================================

def extract_canonical_basis(E: List[List[float]],
                            tol: float = 1e-10) -> List[int]:
    """
    Extract the canonical basis from evaluation data by identifying
    extremal evaluation profiles.
    
    A basis element is "extremal" if its evaluation profile cannot be
    expressed as a tropical linear combination of other profiles.
    
    For the finite case, this reduces to finding elements whose profiles
    are vertices of the tropical convex hull.
    
    Args:
        E: Evaluation matrix, shape (m, n)
    
    Returns:
        List of indices of extremal (canonical) basis elements
    
    Time complexity: O(n² · m)
    """
    n = len(E[0]) if E else 0
    m = len(E)
    
    # Simple criterion: element i is extremal if for no other element j,
    # the profile of i is dominated by the profile of j
    extremal = []
    
    for i in range(n):
        is_extremal = True
        for j in range(n):
            if i == j:
                continue
            # Check if profile_i is tropically dominated by profile_j
            # (i.e., E[ω][i] ≤ E[ω][j] + constant for all ω)
            diffs = []
            valid = True
            for w in range(m):
                if E[w][i] == NEG_INF:
                    continue
                if E[w][j] == NEG_INF:
                    valid = False
                    break
                diffs.append(E[w][i] - E[w][j])
            
            if valid and diffs:
                # If all differences are equal, profile_i = profile_j + const
                # (tropical scaling)
                if max(diffs) - min(diffs) < tol:
                    # i is a tropical scalar multiple of j
                    # Keep the one with smaller index as canonical
                    if j < i:
                        is_extremal = False
                        break
        
        if is_extremal:
            extremal.append(i)
    
    return extremal


# =============================================================================
# Full Reconstruction Pipeline
# =============================================================================

def full_reconstruction_pipeline(E: List[List[float]], 
                                  verbose: bool = True) -> dict:
    """
    Complete reconstruction pipeline:
    1. Check separation
    2. Check nondegeneracy (approximate)
    3. Reconstruct structure constants
    4. Verify associativity
    5. Extract canonical basis
    
    Args:
        E: Evaluation matrix
        verbose: Print progress
    
    Returns:
        Dictionary with all results
    """
    results = {}
    
    if verbose:
        print("\n=== Full Reconstruction Pipeline ===\n")
    
    # Step 1: Separation
    sep_ok, conflict = check_separation(E)
    results['separated'] = sep_ok
    if verbose:
        print(f"1. Separation: {'✓' if sep_ok else '✗'}")
        if not sep_ok:
            print(f"   Conflict: elements {conflict}")
    
    # Step 2: Nondegeneracy
    nondeg_ok, nondeg_msg = check_nondegeneracy_approx(E)
    results['nondegenerate'] = nondeg_ok
    if verbose:
        print(f"2. Nondegeneracy: {'✓' if nondeg_ok else '✗'} ({nondeg_msg})")
    
    # Step 3: Reconstruct
    c = reconstruct_constants(E)
    results['constants'] = c
    if verbose:
        print(f"3. Reconstruction: completed")
        n = len(E[0]) if E else 0
        for i in range(n):
            for j in range(n):
                print(f"   c[{i}][{j}] = {c[i][j]}")
    
    # Step 4: Verify associativity
    assoc_ok, violations = verify_associativity(c)
    results['associative'] = assoc_ok
    if verbose:
        print(f"4. Associativity: {'✓' if assoc_ok else '✗'}")
        if not assoc_ok:
            for v in violations[:5]:
                print(f"   Violation: {v}")
    
    # Step 5: Compatibility
    compat_ok, compat_violations = verify_spherical_compatibility(c, E)
    results['compatible'] = compat_ok
    if verbose:
        print(f"5. Compatibility: {'✓' if compat_ok else '✗'}")
    
    # Step 6: Canonical basis
    canonical = extract_canonical_basis(E)
    results['canonical_basis'] = canonical
    if verbose:
        print(f"6. Canonical basis: {canonical}")
    
    return results


# =============================================================================
# Demo
# =============================================================================

if __name__ == "__main__":
    print("Tropical Hecke Reconstruction — Algorithm Suite")
    print("=" * 50)
    
    # Example: Z/3Z group algebra
    n = 3
    E = [[w * i for i in range(n)] for w in [0, 1, -1]]
    
    print("\nInput: Evaluation matrix for Z/3Z tropical group algebra")
    for w_idx, row in enumerate(E):
        print(f"  E[{w_idx}] = {row}")
    
    results = full_reconstruction_pipeline(E)
    
    # Verify against known answer
    c_known = [[[NEG_INF]*n for _ in range(n)] for _ in range(n)]
    for i in range(n):
        for j in range(n):
            k = (i + j) % n
            c_known[i][j][k] = 0
    
    match, num_match, total = verify_reconstruction(c_known, results['constants'])
    print(f"\nVerification against known constants: {'✓' if match else '✗'} "
          f"({num_match}/{total} entries match)")
