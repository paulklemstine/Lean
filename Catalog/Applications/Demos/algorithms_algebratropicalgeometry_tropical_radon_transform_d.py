#!/usr/bin/env python3
"""
Tropical Radon Transform — Algorithms

Complete implementations of the tropical Radon transform, adjoint reconstruction,
normal-form computation, support data validation, and minimal subfamily extraction.

All algorithms operate on finite types represented as integer arrays.
Complexity analysis is provided for each algorithm.
"""

import numpy as np
from typing import List, Tuple, Optional


def tropical_radon_transform(
    H: List[np.ndarray], f: np.ndarray
) -> np.ndarray:
    """
    Compute the tropical Radon transform (sup-plus convention).
    
    Radon_H(f)(h_i) = max_{x in X} (f(x) + h_i(x))
    
    Time complexity: O(|H| * |X|)
    Space complexity: O(|H|)
    
    Args:
        H: List of m arrays of length n (functionals h : X -> Z)
        f: Array of length n (signal f : X -> Z)
    
    Returns:
        Array of length m (Radon data)
    
    Example:
        >>> H = [np.array([1, 0, -1]), np.array([0, 2, 1])]
        >>> f = np.array([3, 1, 0])
        >>> tropical_radon_transform(H, f)
        array([4, 3])
    """
    return np.array([np.max(f + h) for h in H])


def tropical_adjoint_reconstruction(
    H: List[np.ndarray], F: np.ndarray
) -> np.ndarray:
    """
    Compute the tropical adjoint/reconstruction operator (inf-minus convention).
    
    Adjoint_H(F)(x) = min_{i} (F(h_i) - h_i(x))
    
    Time complexity: O(|H| * |X|)
    Space complexity: O(|X|)
    
    Args:
        H: List of m arrays of length n (functionals)
        F: Array of length m (measurement data)
    
    Returns:
        Array of length n (reconstructed signal)
    
    Example:
        >>> H = [np.array([1, 0, -1]), np.array([0, 2, 1])]
        >>> F = np.array([4, 3])
        >>> tropical_adjoint_reconstruction(H, F)
        array([3, 1, 2])
    """
    n = len(H[0])
    result = np.full(n, np.inf)
    for i, h in enumerate(H):
        result = np.minimum(result, F[i] - h)
    return result


def tropical_closure(
    H: List[np.ndarray], f: np.ndarray
) -> np.ndarray:
    """
    Compute the tropical closure (opening operator).
    
    closure(f) = Adjoint(Radon(f))
    
    This is the smallest normal-form function >= f. It is the tropical
    analogue of the convex conjugate's conjugate (Fenchel biconjugate).
    
    Time complexity: O(|H| * |X|)
    Space complexity: O(|X| + |H|)
    
    Args:
        H: List of m arrays of length n
        f: Array of length n
    
    Returns:
        Array of length n (tropical closure of f)
    """
    F = tropical_radon_transform(H, f)
    return tropical_adjoint_reconstruction(H, F)


def is_tropical_normal_form(
    H: List[np.ndarray], f: np.ndarray, tol: float = 1e-10
) -> bool:
    """
    Check if f is in tropical normal form: f = Adjoint(Radon(f)).
    
    Normal-form functions are the "tropically convex" functions representable
    as lower envelopes of shifted hyperplanes from H.
    
    Time complexity: O(|H| * |X|)
    
    Args:
        H: List of m arrays of length n
        f: Array of length n
        tol: Numerical tolerance for comparison
    
    Returns:
        True if f is in normal form
    """
    return np.allclose(f, tropical_closure(H, f), atol=tol)


def is_tropical_support_data(
    H: List[np.ndarray], F: np.ndarray, tol: float = 1e-10
) -> bool:
    """
    Check if F is valid tropical support data: Radon(Adjoint(F)) = F.
    
    Valid support data characterizes the image of the Radon transform
    on normal-form functions.
    
    Time complexity: O(|H| * |X|)
    
    Args:
        H: List of m arrays of length n
        F: Array of length m
        tol: Numerical tolerance
    
    Returns:
        True if F is valid support data
    """
    f = tropical_adjoint_reconstruction(H, F)
    F_recon = tropical_radon_transform(H, f)
    return np.allclose(F, F_recon, atol=tol)


def tropical_discrepancy(
    H: List[np.ndarray], F: np.ndarray
) -> np.ndarray:
    """
    Compute the tropical discrepancy of measurement data.
    
    delta(F)(h) = F(h) - Radon(Adjoint(F))(h) >= 0
    
    The discrepancy measures how far F is from being valid support data.
    delta = 0 everywhere iff F is in the image of the Radon transform.
    
    Time complexity: O(|H| * |X|)
    
    Args:
        H: List of m arrays of length n
        F: Array of length m
    
    Returns:
        Array of length m (non-negative discrepancies)
    """
    f = tropical_adjoint_reconstruction(H, F)
    F_recon = tropical_radon_transform(H, f)
    return F - F_recon


def certified_reconstruction(
    H: List[np.ndarray], F: np.ndarray
) -> Tuple[np.ndarray, bool, np.ndarray]:
    """
    Certified tropical tomography reconstruction pipeline.
    
    Given measurement data F, reconstruct a signal and certify whether
    the reconstruction is exact (i.e., F is valid support data).
    
    Time complexity: O(|H| * |X|)
    
    Args:
        H: List of m arrays of length n
        F: Array of length m
    
    Returns:
        Tuple of:
        - Reconstructed signal (array of length n)
        - Certification flag (True if F is valid support data)
        - Discrepancy vector (array of length m)
    """
    f_recon = tropical_adjoint_reconstruction(H, F)
    disc = tropical_discrepancy(H, F)
    is_certified = np.allclose(disc, 0)
    return f_recon, is_certified, disc


def find_minimal_subfamily(
    H: List[np.ndarray], test_functions: Optional[List[np.ndarray]] = None
) -> Tuple[List[int], List[np.ndarray]]:
    """
    Find a minimal subfamily B ⊆ H that preserves injectivity on normal forms.
    
    Uses greedy elimination: try removing each functional and check if
    injectivity is preserved on a set of test functions.
    
    Time complexity: O(|H|^2 * |test| * |X|) where |test| is the number of
    test functions used for validation.
    
    Args:
        H: List of m arrays of length n
        test_functions: Optional list of test functions. If None, generates
                       a default grid of test functions.
    
    Returns:
        Tuple of:
        - Indices of minimal subfamily in H
        - The minimal subfamily itself
    
    Algorithm:
        1. Start with B = H (all indices)
        2. For each h_i in B:
           a. Remove h_i to get B' = B \ {h_i}
           b. Check if all test normal forms under B are still
              distinguishable under B'
           c. If yes, keep h_i removed; if no, add it back
        3. Return the surviving subfamily
    """
    n = len(H[0])
    
    # Generate test functions if not provided
    if test_functions is None:
        test_functions = []
        for i in range(n):
            for v in range(-3, 4):
                f = np.zeros(n, dtype=float)
                f[i] = v
                test_functions.append(f)
    
    # Compute normal forms and their Radon data under full H
    normal_data = []
    for f in test_functions:
        f_nf = tropical_closure(H, f)
        R = tropical_radon_transform(H, f_nf)
        normal_data.append((f_nf, R))
    
    # Greedy elimination
    active = list(range(len(H)))
    
    for i in range(len(H)):
        if i not in active:
            continue
        
        # Try removing H[i]
        candidate = [j for j in active if j != i]
        if len(candidate) == 0:
            continue
        
        H_candidate = [H[j] for j in candidate]
        
        # Check if injectivity is preserved
        radon_map = {}
        injective = True
        for f in test_functions:
            f_nf = tropical_closure(H_candidate, f)
            R = tropical_radon_transform(H_candidate, f_nf)
            key = tuple(R)
            if key in radon_map:
                if not np.allclose(radon_map[key], f_nf):
                    injective = False
                    break
            radon_map[key] = f_nf
        
        if injective:
            active = candidate
    
    return active, [H[i] for i in active]


def galois_connection_verify(
    H: List[np.ndarray], f: np.ndarray, F: np.ndarray
) -> Tuple[bool, bool, bool]:
    """
    Verify the Galois connection for given f and F.
    
    Checks:
    1. LHS: ∀h, Radon(f)(h) ≤ F(h)
    2. RHS: ∀x, f(x) ≤ Adjoint(F)(x) 
    3. LHS ↔ RHS
    
    Args:
        H: List of m arrays of length n
        f: Array of length n
        F: Array of length m
    
    Returns:
        Tuple of (LHS holds, RHS holds, equivalence holds)
    """
    R = tropical_radon_transform(H, f)
    A = tropical_adjoint_reconstruction(H, F)
    
    lhs = np.all(R <= F + 1e-10)
    rhs = np.all(f <= A + 1e-10)
    
    return bool(lhs), bool(rhs), bool(lhs) == bool(rhs)


if __name__ == "__main__":
    print("Tropical Radon Transform — Algorithm Examples")
    print("=" * 60)
    
    # Setup
    H = [
        np.array([1, 0, -1], dtype=float),
        np.array([0, 2, 1], dtype=float),
        np.array([-1, -1, 3], dtype=float),
    ]
    
    # Example 1: Full reconstruction pipeline
    print("\n--- Certified Reconstruction Pipeline ---")
    f_original = np.array([3.0, 1.0, 0.0])
    f_nf = tropical_closure(H, f_original)
    F_data = tropical_radon_transform(H, f_nf)
    
    f_recon, certified, disc = certified_reconstruction(H, F_data)
    print(f"Original:      {f_original}")
    print(f"Normal form:   {f_nf}")
    print(f"Measurements:  {F_data}")
    print(f"Reconstructed: {f_recon}")
    print(f"Certified:     {certified}")
    print(f"Discrepancy:   {disc}")
    
    # Example 2: Minimal subfamily
    print("\n--- Minimal Subfamily Extraction ---")
    indices, B = find_minimal_subfamily(H)
    print(f"Full family H: {len(H)} functionals")
    print(f"Minimal subfamily B: {len(B)} functionals (indices {indices})")
    for i, b in zip(indices, B):
        print(f"  h_{i} = {b}")
    
    # Example 3: Galois connection verification
    print("\n--- Galois Connection Verification ---")
    f_test = np.array([2.0, 1.0, 0.0])
    for F_val in [np.array([10.0, 10.0, 10.0]), np.array([1.0, 1.0, 1.0])]:
        lhs, rhs, equiv = galois_connection_verify(H, f_test, F_val)
        print(f"  f={f_test}, F={F_val}: LHS={lhs}, RHS={rhs}, ↔={equiv}")
