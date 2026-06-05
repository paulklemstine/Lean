#!/usr/bin/env python3
"""
Non-Standard Arithmetic: Algorithms

Type-hinted implementations of the core algorithms and constructions
from the non-standard arithmetic formalization.
"""

from typing import Callable, List, Optional, Set, Tuple
import math


# ============================================================
# Algorithm 1: Infinitesimal Classification
# ============================================================

def classify_element(
    x: float,
    max_test_n: int = 10000
) -> str:
    """Classify an element as infinitesimal, bounded, or infinite.

    In a computationally bounded setting, we approximate the
    algebraic definitions:
    - Infinitesimal: n * |x| < 1 for all n up to max_test_n
    - Bounded: |x| ≤ max_test_n
    - Infinite: |x| > max_test_n

    Args:
        x: Element to classify
        max_test_n: Maximum natural number to test against

    Returns:
        Classification string: "infinitesimal", "bounded", or "infinite"
    """
    abs_x = abs(x)

    # Check infinitesimal: n * |x| < 1 for all positive n
    if all(n * abs_x < 1.0 for n in range(1, max_test_n + 1)):
        return "infinitesimal"

    # Check bounded: |x| ≤ some natural number
    if abs_x <= max_test_n:
        return "bounded"

    return "infinite"


def verify_ideal_property(
    bounded_vals: List[float],
    infinitesimal_vals: List[float],
    max_n: int = 1000
) -> List[Tuple[float, float, float, bool]]:
    """Verify the ideal property: bounded × infinitesimal = infinitesimal.

    Tests that for each pair (b, ε), the product b*ε remains
    infinitesimal (up to computational bounds).

    Returns list of (b, eps, product, is_product_infinitesimal).
    """
    results = []
    for b in bounded_vals:
        for eps in infinitesimal_vals:
            product = b * eps
            is_inf = all(n * abs(product) < 1.0 for n in range(1, max_n + 1))
            results.append((b, eps, product, is_inf))
    return results


# ============================================================
# Algorithm 2: Ultrafilter Simulation
# ============================================================

class CofiniteUltrafilter:
    """Simulates a 'cofinite-like' ultrafilter on finite subsets of ℕ.

    A free ultrafilter on ℕ contains all cofinite sets.
    We simulate this by declaring a set S ⊆ [0, N) to be 'U-large'
    if its complement in [0, N) has size < threshold.
    """

    def __init__(self, universe_size: int = 10000, threshold: float = 0.01):
        self.N = universe_size
        self.threshold = threshold

    def is_large(self, s: Set[int]) -> bool:
        """Check if set S is 'U-large' (complement is small)."""
        complement_size = sum(1 for i in range(self.N) if i not in s)
        return complement_size / self.N < self.threshold

    def transfer_and(self, s1: Set[int], s2: Set[int]) -> Tuple[bool, bool, bool]:
        """Verify conjunction transfer: if S1, S2 ∈ U then S1 ∩ S2 ∈ U."""
        l1 = self.is_large(s1)
        l2 = self.is_large(s2)
        l_inter = self.is_large(s1 & s2)
        return l1, l2, l_inter

    def transfer_imp(
        self,
        prop_p: Callable[[int], bool],
        prop_q: Callable[[int], bool]
    ) -> Tuple[bool, bool, bool]:
        """Verify implication transfer: P ∈ U and (P→Q) ∈ U implies Q ∈ U."""
        s_p = {i for i in range(self.N) if prop_p(i)}
        s_pq = {i for i in range(self.N) if not prop_p(i) or prop_q(i)}
        s_q = {i for i in range(self.N) if prop_q(i)}
        return self.is_large(s_p), self.is_large(s_pq), self.is_large(s_q)


# ============================================================
# Algorithm 3: Overspill Construction
# ============================================================

def construct_overflow_function(
    membership: Callable[[int, int], bool],
    universe_size: int = 1000,
    max_chain_depth: int = 100
) -> List[int]:
    """Construct the overflow function for a decreasing chain.

    Given a decreasing chain of sets S_n defined by membership(i, n),
    compute f(i) = max{n | membership(i, n)} for each i.

    This is the computational core of the overspill principle:
    f represents a 'nonstandard element' in the ultraproduct.

    Args:
        membership: Function (i, n) → bool indicating i ∈ S_n
        universe_size: Size of index set
        max_chain_depth: Maximum chain depth to check

    Returns:
        List f where f[i] = max{n | i ∈ S_n}
    """
    f = []
    for i in range(universe_size):
        max_n = 0
        for n in range(max_chain_depth):
            if membership(i, n):
                max_n = n
            else:
                break
        f.append(max_n)
    return f


def verify_overspill(
    f: List[int],
    membership: Callable[[int, int], bool],
    check_depth: int = 50
) -> dict:
    """Verify the overspill properties of an overflow function.

    Checks:
    1. For each n, the set {i | f(i) ≥ n} has high density (should be 'U-large')
    2. For each i, i ∈ S_{f(i)} (membership at the overflow point)

    Returns dict with verification results.
    """
    N = len(f)
    results = {
        "overflow_densities": {},
        "membership_rate": 0.0,
        "max_overflow": max(f) if f else 0,
        "mean_overflow": sum(f) / len(f) if f else 0.0,
    }

    # Check overflow property: {i | f(i) ≥ n} should be large
    for n in range(0, min(check_depth, max(f) + 1) if f else 0, 5):
        count = sum(1 for fi in f if fi >= n)
        results["overflow_densities"][n] = count / N

    # Check membership: i ∈ S_{f(i)}
    member_count = sum(1 for i, fi in enumerate(f) if membership(i, fi))
    results["membership_rate"] = member_count / N

    return results


# ============================================================
# Algorithm 4: Non-Archimedean Detector
# ============================================================

def detect_non_archimedean(
    abs_fn: Callable[[float], float],
    test_elements: List[float],
    max_n: int = 10000
) -> Tuple[bool, Optional[float]]:
    """Detect if a valued field is non-Archimedean by finding infinitesimals.

    Given an absolute value function and test elements, searches for
    a nonzero element x with n * |x| < 1 for all tested n.

    Returns (is_non_archimedean, witness_infinitesimal).
    """
    for x in test_elements:
        if x == 0:
            continue
        ax = abs_fn(x)
        if ax == 0:
            continue
        if all(n * ax < 1.0 for n in range(1, max_n + 1)):
            return True, x
    return False, None


def padic_absolute_value(x: int, p: int) -> float:
    """Compute the p-adic absolute value |x|_p.

    |x|_p = p^(-v_p(x)) where v_p(x) is the p-adic valuation.
    """
    if x == 0:
        return 0.0
    val = 0
    n = abs(x)
    while n % p == 0:
        val += 1
        n //= p
    return float(p) ** (-val)


# ============================================================
# Algorithm 5: Compositeness Transfer Check
# ============================================================

def verify_compositeness_transfer(
    f: Callable[[int], int],
    a: Callable[[int], int],
    b: Callable[[int], int],
    n_indices: int = 10000
) -> dict:
    """Verify that a factorization f = a * b transfers compositeness.

    Checks the three conditions of the compositeness transfer theorem:
    1. f(i) = a(i) * b(i) for 'most' i
    2. a(i) > 1 for 'most' i
    3. b(i) > 1 for 'most' i
    → f(i) is composite for 'most' i

    Returns verification statistics.
    """
    fact_count = 0
    a_gt1_count = 0
    b_gt1_count = 0
    composite_count = 0

    for i in range(n_indices):
        fi, ai, bi = f(i), a(i), b(i)
        if fi == ai * bi:
            fact_count += 1
        if ai > 1:
            a_gt1_count += 1
        if bi > 1:
            b_gt1_count += 1
        if fi > 1 and not _is_prime_simple(fi):
            composite_count += 1

    return {
        "factorization_density": fact_count / n_indices,
        "a_gt_1_density": a_gt1_count / n_indices,
        "b_gt_1_density": b_gt1_count / n_indices,
        "composite_density": composite_count / n_indices,
    }


def _is_prime_simple(n: int) -> bool:
    """Simple primality test."""
    if n < 2:
        return False
    if n < 4:
        return True
    if n % 2 == 0 or n % 3 == 0:
        return False
    i = 5
    while i * i <= n:
        if n % i == 0 or n % (i + 2) == 0:
            return False
        i += 6
    return True


if __name__ == "__main__":
    # Quick self-test
    print("Classification test:")
    for x in [0, 1e-10, 5.0, 1e20]:
        print(f"  {x} -> {classify_element(x)}")

    print("\nIdeal property test:")
    results = verify_ideal_property([1.0, 10.0], [1e-10, 1e-20])
    for b, eps, prod, is_inf in results:
        print(f"  {b} × {eps:.1e} = {prod:.1e}, infinitesimal: {is_inf}")

    print("\np-adic absolute values (p=5):")
    for x in [1, 5, 25, 125, 6]:
        print(f"  |{x}|_5 = {padic_absolute_value(x, 5):.6f}")
