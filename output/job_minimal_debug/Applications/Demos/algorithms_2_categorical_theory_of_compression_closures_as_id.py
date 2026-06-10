#!/usr/bin/env python3
"""
Algorithms for Categorical Compression Monads.

Implements the key algorithms from the research paper:
1. Tropical normalization (the universal compression operator)
2. Idempotent monad fixed-point computation
3. MDL functional computation
4. Translation-invariant compression verification
"""

import numpy as np
from typing import Callable, Tuple, List, Optional


def tropical_normalize(x: np.ndarray) -> np.ndarray:
    """
    Tropical normalization: the canonical compression operator on R^n.

    Maps x to x - min(x), producing the unique representative of x's
    tropical projective class with minimum coordinate equal to zero.

    Time complexity: O(n)
    Space complexity: O(n)

    Args:
        x: Input vector in R^n

    Returns:
        Normalized vector with min = 0 and all entries >= 0

    Example:
        >>> tropical_normalize(np.array([3.0, 1.0, 4.0]))
        array([2., 0., 3.])
    """
    return x - np.min(x)


def verify_compression_operator(
    T: Callable[[np.ndarray], np.ndarray],
    n: int,
    num_tests: int = 100,
    tol: float = 1e-10
) -> dict:
    """
    Verify whether an operator T satisfies the axioms of a
    translation-invariant compression operator.

    Checks:
    1. Idempotence: T(T(x)) = T(x)
    2. Translation invariance: T(x + c*1) = T(x)
    3. Nonnegativity: T(x)_i >= 0
    4. Zero minimum: min(T(x)) = 0
    5. Same class: T(x) - x is constant

    Args:
        T: The operator to verify
        n: Dimension of input vectors
        num_tests: Number of random test vectors
        tol: Numerical tolerance

    Returns:
        Dictionary with verification results
    """
    rng = np.random.default_rng(42)
    results = {
        "idempotent": True,
        "translation_invariant": True,
        "nonneg": True,
        "min_zero": True,
        "same_class": True,
        "equals_tropical_normalize": True,
        "failures": []
    }

    for _ in range(num_tests):
        x = rng.uniform(-10, 10, size=n)
        Tx = T(x)
        TTx = T(Tx)

        # Idempotence
        if not np.allclose(Tx, TTx, atol=tol):
            results["idempotent"] = False
            results["failures"].append(f"Idempotence failed: T(T(x)) != T(x)")

        # Translation invariance
        c = rng.uniform(-10, 10)
        Txc = T(x + c)
        if not np.allclose(Tx, Txc, atol=tol):
            results["translation_invariant"] = False

        # Nonnegativity
        if not np.all(Tx >= -tol):
            results["nonneg"] = False

        # Zero minimum
        if not np.isclose(np.min(Tx), 0, atol=tol):
            results["min_zero"] = False

        # Same class
        diff = Tx - x
        if not np.allclose(diff, diff[0] * np.ones_like(diff), atol=tol):
            results["same_class"] = False

        # Equals tropical normalize
        Nx = tropical_normalize(x)
        if not np.allclose(Tx, Nx, atol=tol):
            results["equals_tropical_normalize"] = False

    return results


def mdl_functional(
    x: np.ndarray,
    T: Callable[[np.ndarray], np.ndarray],
    length: Callable[[np.ndarray], float]
) -> Tuple[float, float, float]:
    """
    Compute the MDL (Minimum Description Length) functional.

    Args:
        x: Input data vector
        T: Compression operator (monad action on objects)
        length: Length functional on vectors

    Returns:
        Tuple of (original_length, compressed_length, compression_gain)

    Example:
        >>> x = np.array([3.0, 1.0, 4.0])
        >>> mdl_functional(x, tropical_normalize, np.linalg.norm)
        (5.099..., 3.605..., 1.493...)
    """
    Tx = T(x)
    L_orig = length(x)
    L_comp = length(Tx)
    gain = L_orig - L_comp
    return L_orig, L_comp, gain


def closure_fixed_point_witness(
    c: Callable,
    x: float,
    L: Callable[[float], float]
) -> Tuple[float, float]:
    """
    Find the canonical fixed-point witness for a closure operator.

    For any closure operator c and element x, the closure c(x) is a
    fixed point of c that is >= x, with L(c(x)) <= L(c(x)) (trivially).

    This implements the categorical MDL bound: every element admits a
    canonical fixed-point representative.

    Args:
        c: Closure operator (idempotent, extensive, monotone)
        x: Input element
        L: Length functional

    Returns:
        Tuple of (fixed_point, length_of_fixed_point)
    """
    y = c(x)
    # Verify it's actually a fixed point
    assert np.isclose(c(y), y), f"c is not idempotent at c({x}) = {y}"
    assert x <= y + 1e-10, f"c is not extensive: {x} > {y}"
    return y, L(y)


def compare_compression_monads(
    T1: Callable[[np.ndarray], np.ndarray],
    T2: Callable[[np.ndarray], np.ndarray],
    length: Callable[[np.ndarray], float],
    test_vectors: List[np.ndarray]
) -> dict:
    """
    Compare two compression monads via MDL inequality.

    If T2 compresses more aggressively than T1 (shorter compressed length),
    then MDL(T2, x) <= MDL(T1, x) for all x.

    Args:
        T1: First compression operator
        T2: Second compression operator
        length: Length functional
        test_vectors: List of test vectors

    Returns:
        Dictionary with comparison results
    """
    results = {
        "T2_always_shorter": True,
        "comparisons": []
    }

    for x in test_vectors:
        L1 = length(T1(x))
        L2 = length(T2(x))
        results["comparisons"].append({
            "L_T1": L1,
            "L_T2": L2,
            "T2_shorter": L2 <= L1 + 1e-10
        })
        if L2 > L1 + 1e-10:
            results["T2_always_shorter"] = False

    return results


if __name__ == "__main__":
    print("Verifying tropical normalization satisfies all axioms...")
    results = verify_compression_operator(tropical_normalize, n=5)
    for key, val in results.items():
        if key != "failures":
            print(f"  {key}: {val}")
    print()

    print("MDL computation example:")
    x = np.array([3.0, 1.0, 4.0, 1.5, 9.0])
    L_orig, L_comp, gain = mdl_functional(x, tropical_normalize, np.linalg.norm)
    print(f"  Original length:   {L_orig:.4f}")
    print(f"  Compressed length: {L_comp:.4f}")
    print(f"  Compression gain:  {gain:.4f}")
    print()

    print("Comparing compression operators:")
    # T1: tropical normalize (canonical)
    # T2: a "stronger" compression that zeros out small values
    def aggressive_compress(x):
        n = tropical_normalize(x)
        n[n < 1.0] = 0.0
        return n

    test_vecs = [np.random.randn(5) * 3 + 2 for _ in range(10)]
    comparison = compare_compression_monads(
        tropical_normalize, aggressive_compress,
        np.linalg.norm, test_vecs
    )
    print(f"  T2 always shorter: {comparison['T2_always_shorter']}")
