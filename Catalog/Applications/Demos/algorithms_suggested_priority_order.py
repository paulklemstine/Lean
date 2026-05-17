#!/usr/bin/env python3
"""
Algorithms for Tropical Perturbation Amplification

Implements the core algorithms from the tropical amplification calculus,
including tropical max evaluation, perturbation bound computation,
product decomposition, and weight recovery.
"""

import numpy as np
from typing import List, Tuple, Optional, Callable


def tropical_max(
    weights: np.ndarray,
    f: np.ndarray
) -> float:
    """
    Evaluate the tropical max functional.

    F(f) = max_{s in S} (f(s) + w(s))

    Args:
        weights: Weight vector w of length |S|.
        f: Input function vector of length |S|.

    Returns:
        The tropical max value.

    Time complexity: O(|S|)
    Space complexity: O(1)

    >>> tropical_max(np.array([1.0, 2.0, 3.0]), np.array([0.0, 0.0, 0.0]))
    3.0
    """
    return float(np.max(f + weights))


def tropical_perturbation_bound(card: int) -> float:
    """
    Compute the tropical perturbation bound Φ(S) = log|S|.

    Args:
        card: Cardinality of the support set.

    Returns:
        log(card), or -inf if card <= 0.

    Time complexity: O(1)

    >>> abs(tropical_perturbation_bound(1)) < 1e-15
    True
    >>> abs(tropical_perturbation_bound(10) - np.log(10)) < 1e-15
    True
    """
    if card <= 0:
        return float('-inf')
    return float(np.log(card))


def tropical_bit_complexity(card: int) -> float:
    """
    Compute the tropical bit complexity = Φ(S) / log(2) = log₂|S|.

    This is the base-2 version of the perturbation bound.

    Args:
        card: Cardinality of the support set.

    Returns:
        log₂(card).

    Time complexity: O(1)
    """
    if card <= 0:
        return float('-inf')
    return float(np.log2(card))


def verify_tensorization(
    card_S: int,
    card_T: int,
    tol: float = 1e-14
) -> Tuple[float, float, bool]:
    """
    Verify the tensorization law Φ(S×T) = Φ(S) + Φ(T).

    Args:
        card_S: Cardinality of S.
        card_T: Cardinality of T.
        tol: Tolerance for floating-point comparison.

    Returns:
        Tuple of (lhs, rhs, verified).

    Time complexity: O(1)
    """
    lhs = tropical_perturbation_bound(card_S * card_T)
    rhs = (tropical_perturbation_bound(card_S)
           + tropical_perturbation_bound(card_T))
    return lhs, rhs, abs(lhs - rhs) < tol


def product_tropical_max(
    w1: np.ndarray,
    w2: np.ndarray,
    f1: np.ndarray,
    f2: np.ndarray
) -> Tuple[float, float, float]:
    """
    Compute tropical max on a product with separable weights and inputs.

    Verifies the separable decomposition theorem:
    tropMax(S×T, w1⊕w2, f1⊕f2) = tropMax(S, w1, f1) + tropMax(T, w2, f2)

    Args:
        w1: Weights for factor S.
        w2: Weights for factor T.
        f1: Input for factor S.
        f2: Input for factor T.

    Returns:
        Tuple of (product_max, sum_of_factor_maxes, error).

    Time complexity: O(|S| · |T|) for the product, O(|S| + |T|) for factors.
    """
    # Factor maxima (efficient)
    max_S = tropical_max(w1, f1)
    max_T = tropical_max(w2, f2)
    sum_maxes = max_S + max_T

    # Product maximum (brute force for verification)
    n_S, n_T = len(w1), len(w2)
    product_max = float('-inf')
    for i in range(n_S):
        for j in range(n_T):
            val = (f1[i] + f2[j]) + (w1[i] + w2[j])
            product_max = max(product_max, val)

    return product_max, sum_maxes, abs(product_max - sum_maxes)


def weight_recovery(
    weights: np.ndarray,
    target_index: int
) -> float:
    """
    Recover the weight at a specific index using the isolation method.

    Uses the test function f(a) = 0 if a = target, -M otherwise,
    where M is large enough to isolate the target.

    Args:
        weights: Weight vector.
        target_index: Index to recover.

    Returns:
        The recovered weight value.

    Time complexity: O(|S|)
    """
    M = np.max(np.abs(weights)) + 1
    f = np.full_like(weights, -M)
    f[target_index] = 0
    return tropical_max(weights, f)


def perturbation_error_bound(
    w1: np.ndarray,
    w2: np.ndarray,
    w1_pert: np.ndarray,
    w2_pert: np.ndarray
) -> Tuple[float, float, float]:
    """
    Compute the product perturbation error and its bound.

    Verifies: max_{(s,t)} |Δw_product(s,t)| ≤ max_s |Δw1(s)| + max_t |Δw2(t)|

    Args:
        w1, w2: Original factor weights.
        w1_pert, w2_pert: Perturbed factor weights.

    Returns:
        Tuple of (actual_max_error, bound, is_within_bound).

    Time complexity: O(|S| · |T|)
    """
    eps1 = np.max(np.abs(w1 - w1_pert))
    eps2 = np.max(np.abs(w2 - w2_pert))
    bound = eps1 + eps2

    max_error = 0.0
    for i in range(len(w1)):
        for j in range(len(w2)):
            prod_orig = w1[i] + w2[j]
            prod_pert = w1_pert[i] + w2_pert[j]
            max_error = max(max_error, abs(prod_orig - prod_pert))

    return max_error, bound, max_error <= bound + 1e-15


def n_fold_amplification_table(
    card_S: int,
    max_n: int = 20
) -> List[Tuple[int, int, float, float]]:
    """
    Generate the n-fold amplification table.

    For each n, computes |S^n|, Φ(S^n), and n·Φ(S).

    Args:
        card_S: Base support size.
        max_n: Maximum number of folds.

    Returns:
        List of (n, |S^n|, Φ(S^n), n·Φ(S)) tuples.

    Time complexity: O(max_n)
    """
    phi_S = tropical_perturbation_bound(card_S)
    result = []
    for n in range(1, max_n + 1):
        card_n = card_S ** n
        phi_n = tropical_perturbation_bound(card_n)
        expected = n * phi_S
        result.append((n, card_n, phi_n, expected))
    return result


if __name__ == "__main__":
    # Quick self-test
    print("Testing tropical_max...")
    assert abs(tropical_max(np.array([1., 2., 3.]), np.array([0., 0., 0.])) - 3.0) < 1e-15

    print("Testing tensorization...")
    for s in range(1, 20):
        for t in range(1, 20):
            _, _, ok = verify_tensorization(s, t)
            assert ok, f"Tensorization failed for |S|={s}, |T|={t}"

    print("Testing weight recovery...")
    w = np.array([1.5, -0.3, 2.7, 0.1])
    for i in range(len(w)):
        recovered = weight_recovery(w, i)
        assert abs(recovered - w[i]) < 1e-10, f"Recovery failed at index {i}"

    print("Testing separable decomposition...")
    np.random.seed(42)
    w1 = np.random.randn(5)
    w2 = np.random.randn(7)
    f1 = np.random.randn(5)
    f2 = np.random.randn(7)
    _, _, err = product_tropical_max(w1, w2, f1, f2)
    assert err < 1e-14, f"Separable decomposition error: {err}"

    print("All tests passed!")
