#!/usr/bin/env python3
"""
Algorithms for Tropical Perturbation Amplification

Implements the core algorithms from the research paper:
1. Tropical max functional evaluation
2. Tropical perturbation bound computation
3. Product weight construction
4. Weight recovery via test functions
5. Perturbation stability verification
"""

import math
from typing import TypeVar, Callable, Dict, List, Tuple, Set, Optional
from itertools import product as cartesian_product

T = TypeVar('T')


# =============================================================================
# Algorithm 1: Tropical Max Functional
# =============================================================================

def tropical_max_functional(
    support: List[T],
    weights: Dict[T, float],
    f: Callable[[T], float]
) -> float:
    """
    Compute the tropical max functional F(f) = max_{s ∈ S} (f(s) + w(s)).

    Time complexity: O(|S|)
    Space complexity: O(1)

    Args:
        support: Finite support set S
        weights: Weight function w : S → ℝ
        f: Input function f : S → ℝ

    Returns:
        The value max_{s ∈ S} (f(s) + w(s))

    Example:
        >>> S = [1, 2, 3]
        >>> w = {1: 0.5, 2: 1.0, 3: 0.2}
        >>> f = lambda x: x * 0.3
        >>> tropical_max_functional(S, w, f)
        1.9
    """
    if not support:
        raise ValueError("Support must be nonempty")
    return max(f(s) + weights[s] for s in support)


# =============================================================================
# Algorithm 2: Tropical Perturbation Bound
# =============================================================================

def tropical_perturbation_bound(support_size: int) -> float:
    """
    Compute the tropical perturbation bound: log |S|.

    This is the tropical entropy / complexity measure. It is:
    - Nonneg for nonempty supports
    - Zero for singletons
    - Additive under products: bound(S×T) = bound(S) + bound(T)
    - Monotone under inclusion: S ⊆ T → bound(S) ≤ bound(T)

    Time complexity: O(1)
    Space complexity: O(1)

    Args:
        support_size: Cardinality |S| of the support

    Returns:
        log(|S|) (natural logarithm)

    Example:
        >>> tropical_perturbation_bound(10)
        2.302585092994046
        >>> tropical_perturbation_bound(1)
        0.0
    """
    if support_size <= 0:
        return 0.0
    return math.log(support_size)


# =============================================================================
# Algorithm 3: Product Weight Construction
# =============================================================================

def product_weight(
    weights_S: Dict[T, float],
    weights_T: Dict[T, float]
) -> Dict[Tuple, float]:
    """
    Construct the product weight: w(s,t) = wS(s) + wT(t).

    This is the tropical tensor product of two weight functions.

    Time complexity: O(|S| × |T|)
    Space complexity: O(|S| × |T|)

    Args:
        weights_S: Weights on the first factor
        weights_T: Weights on the second factor

    Returns:
        Product weight dictionary on S × T

    Example:
        >>> wS = {'a': 1.0, 'b': 2.0}
        >>> wT = {'x': 0.5, 'y': 1.5}
        >>> pw = product_weight(wS, wT)
        >>> pw[('a', 'x')]
        1.5
    """
    result = {}
    for s, ws in weights_S.items():
        for t, wt in weights_T.items():
            result[(s, t)] = ws + wt
    return result


# =============================================================================
# Algorithm 4: Weight Recovery
# =============================================================================

def recover_weights(
    support: List[T],
    functional: Callable[[Callable[[T], float]], float],
    M: Optional[float] = None
) -> Dict[T, float]:
    """
    Recover the weights of a tropical max functional from its values.

    Uses the isolation test function technique from tropical_perturbation_exact_bound:
    for each s ∈ S, define f(a) = 0 if a = s, else -M, then F(f) ≈ w(s) for large M.

    Time complexity: O(|S|²) (|S| evaluations of the functional, each O(|S|))
    Space complexity: O(|S|)

    Args:
        support: The support set S
        functional: The tropical max functional F
        M: Isolation parameter (auto-computed if None)

    Returns:
        Recovered weight dictionary

    Example:
        >>> S = [1, 2, 3]
        >>> w = {1: 0.5, 2: 1.0, 3: 0.2}
        >>> F = lambda f: tropical_max_functional(S, w, f)
        >>> recovered = recover_weights(S, F)
        >>> all(abs(recovered[s] - w[s]) < 1e-10 for s in S)
        True
    """
    if M is None:
        # Use a first pass to estimate M
        max_val = functional(lambda _: 0)
        M = abs(max_val) + len(support) * 100.0

    recovered = {}
    for s in support:
        # Test function that isolates s
        def test_f(a, target=s):
            return 0.0 if a == target else -M
        recovered[s] = functional(test_f)
    return recovered


# =============================================================================
# Algorithm 5: Perturbation Stability Verifier
# =============================================================================

def verify_perturbation_stability(
    support: List[T],
    weights1: Dict[T, float],
    weights2: Dict[T, float],
    num_test_functions: int = 1000
) -> Tuple[float, float, bool]:
    """
    Verify the perturbation stability theorem:
    max_s |w1(s) - w2(s)| = max_f |F1(f) - F2(f)| (up to numerical precision).

    The stability constant is exactly 1: weight perturbation equals functional perturbation.

    Time complexity: O(num_test_functions × |S|)
    Space complexity: O(|S|)

    Args:
        support: The support set S
        weights1: First weight function
        weights2: Second weight function
        num_test_functions: Number of random test functions

    Returns:
        (weight_diff, functional_diff, is_stable) where:
        - weight_diff = max_s |w1(s) - w2(s)|
        - functional_diff = max observed |F1(f) - F2(f)|
        - is_stable = (functional_diff ≤ weight_diff + tolerance)

    Example:
        >>> S = [1, 2, 3]
        >>> w1 = {1: 1.0, 2: 2.0, 3: 3.0}
        >>> w2 = {1: 1.1, 2: 1.9, 3: 3.05}
        >>> diff_w, diff_f, stable = verify_perturbation_stability(S, w1, w2)
        >>> stable
        True
    """
    import random
    random.seed(42)

    weight_diff = max(abs(weights1[s] - weights2[s]) for s in support)

    max_functional_diff = 0.0
    for _ in range(num_test_functions):
        # Random test function
        values = {s: random.gauss(0, 10) for s in support}
        f = lambda x, v=values: v[x]

        f1 = tropical_max_functional(support, weights1, f)
        f2 = tropical_max_functional(support, weights2, f)
        max_functional_diff = max(max_functional_diff, abs(f1 - f2))

    is_stable = max_functional_diff <= weight_diff + 1e-10
    return weight_diff, max_functional_diff, is_stable


# =============================================================================
# Algorithm 6: Tensorization Verifier
# =============================================================================

def verify_tensorization(
    sizes: List[int]
) -> Tuple[float, float, float]:
    """
    Verify the tensorization law for a list of support sizes.

    Computes:
    - Product bound: log(∏ sizes)
    - Sum of bounds: Σ log(size)
    - Difference (should be ~0)

    Time complexity: O(k) where k = len(sizes)
    Space complexity: O(1)

    Args:
        sizes: List of support sizes [|S1|, |S2|, ..., |Sk|]

    Returns:
        (product_bound, sum_of_bounds, difference)

    Example:
        >>> verify_tensorization([3, 5, 7])
        (4.65..., 4.65..., 0.0)
    """
    product_size = 1
    for s in sizes:
        product_size *= s

    product_bound = math.log(product_size) if product_size > 0 else 0.0
    sum_of_bounds = sum(math.log(s) for s in sizes if s > 0)
    difference = abs(product_bound - sum_of_bounds)

    return product_bound, sum_of_bounds, difference


# =============================================================================
# Main: Run all algorithm demos
# =============================================================================

def main():
    print("=" * 60)
    print("  TROPICAL PERTURBATION AMPLIFICATION — ALGORITHMS")
    print("=" * 60)

    # Algorithm 1: Tropical max functional
    print("\n--- Algorithm 1: Tropical Max Functional ---")
    S = [1, 2, 3, 4, 5]
    w = {s: s * 0.5 for s in S}
    f = lambda x: -x * 0.3
    result = tropical_max_functional(S, w, f)
    print(f"  S = {S}, w(s) = 0.5s, f(s) = -0.3s")
    print(f"  F(f) = max_s (f(s) + w(s)) = {result:.4f}")

    # Algorithm 2: Perturbation bound
    print("\n--- Algorithm 2: Tropical Perturbation Bound ---")
    for n in [1, 2, 5, 10, 100, 1000]:
        print(f"  bound({n:>4}) = log({n:>4}) = {tropical_perturbation_bound(n):.6f}")

    # Algorithm 3: Product weight
    print("\n--- Algorithm 3: Product Weight Construction ---")
    wS = {'a': 1.0, 'b': 2.0}
    wT = {'x': 0.5, 'y': 1.5}
    pw = product_weight(wS, wT)
    print(f"  wS = {wS}")
    print(f"  wT = {wT}")
    for (s, t), v in sorted(pw.items()):
        print(f"  w({s},{t}) = {wS[s]:.1f} + {wT[t]:.1f} = {v:.1f}")

    # Algorithm 4: Weight recovery
    print("\n--- Algorithm 4: Weight Recovery ---")
    S = [1, 2, 3, 4]
    w = {1: 0.5, 2: 1.0, 3: 0.2, 4: 1.5}
    F = lambda f: tropical_max_functional(S, w, f)
    recovered = recover_weights(S, F)
    print(f"  Original weights:  {w}")
    print(f"  Recovered weights: { {s: round(v, 6) for s, v in recovered.items()} }")
    print(f"  Max error: {max(abs(w[s] - recovered[s]) for s in S):.2e}")

    # Algorithm 5: Perturbation stability
    print("\n--- Algorithm 5: Perturbation Stability ---")
    S = list(range(1, 11))
    w1 = {s: s * 0.3 for s in S}
    w2 = {s: s * 0.3 + 0.05 * ((-1)**s) for s in S}
    wd, fd, stable = verify_perturbation_stability(S, w1, w2)
    print(f"  Weight perturbation:    {wd:.6f}")
    print(f"  Functional perturbation: {fd:.6f}")
    print(f"  Stable (constant = 1):  {stable}")

    # Algorithm 6: Tensorization
    print("\n--- Algorithm 6: Tensorization Verification ---")
    test_cases = [
        [3, 5],
        [2, 3, 7],
        [10, 10, 10],
        [2, 2, 2, 2, 2],
    ]
    for sizes in test_cases:
        pb, sb, diff = verify_tensorization(sizes)
        print(f"  sizes={sizes}: product_bound={pb:.6f}, sum={sb:.6f}, diff={diff:.2e}")

    print(f"\n  ✓ All algorithms executed successfully!\n")


if __name__ == "__main__":
    main()
