#!/usr/bin/env python3
"""
Algorithms for Tropical Perturbation Amplification.

Implements the core mathematical objects and algorithms from the formal development,
with full type hints, docstrings, and complexity analysis.
"""

from typing import Dict, List, Tuple, Callable, TypeVar, Generic, Optional
import math
import itertools

T = TypeVar('T')
U = TypeVar('U')


class TropicalMaxFunctional(Generic[T]):
    """A tropical max functional on a finite support.

    Computes F(f) = max_{s in S} (f(s) + w(s)) for a finite support S
    and weight function w.

    Time complexity: O(|S|) per evaluation.
    Space complexity: O(|S|) for storing weights.
    """

    def __init__(self, support: List[T], weights: Dict[T, float]):
        """Initialize with support and weights.

        Args:
            support: The finite support set S.
            weights: Weight function w : S -> R.
        """
        if not support:
            raise ValueError("Support must be nonempty")
        self.support = list(support)
        self.weights = dict(weights)

    def evaluate(self, f: Callable[[T], float]) -> float:
        """Evaluate F(f) = max_{s in S} (f(s) + w(s)).

        Time complexity: O(|S|)

        Args:
            f: Input function f : S -> R.

        Returns:
            The tropical max value.
        """
        return max(f(s) + self.weights[s] for s in self.support)

    def perturbation_bound(self) -> float:
        """Compute the tropical perturbation bound log(|S|).

        Time complexity: O(1)

        Returns:
            log(|S|), the log-cardinality complexity measure.
        """
        return math.log(len(self.support))

    @staticmethod
    def product(
        func1: 'TropicalMaxFunctional[T]',
        func2: 'TropicalMaxFunctional[U]'
    ) -> 'TropicalMaxFunctional[Tuple[T, U]]':
        """Construct the product functional on S × T.

        Uses separable weights: w(s,t) = w1(s) + w2(t).

        Time complexity: O(|S| · |T|)
        Space complexity: O(|S| · |T|)

        Returns:
            Product functional with separable weights.
        """
        product_support = list(itertools.product(func1.support, func2.support))
        product_weights = {
            (s, t): func1.weights[s] + func2.weights[t]
            for s in func1.support
            for t in func2.support
        }
        return TropicalMaxFunctional(product_support, product_weights)

    def verify_separability(
        self,
        other: 'TropicalMaxFunctional[T]',
        f1: Callable[[T], float],
        f2: Callable[[T], float]
    ) -> Tuple[float, float, float]:
        """Verify the separability theorem numerically.

        For product functionals with separable inputs, checks that
        F(f1 ⊕ f2) = F1(f1) + F2(f2).

        Returns:
            Tuple of (product_value, sum_value, difference).
        """
        raise NotImplementedError("Use product_separability_check instead")


def product_separability_check(
    S: List, T: List,
    w1: Dict, w2: Dict,
    f1: Callable, f2: Callable
) -> Tuple[float, float, float]:
    """Check separability: tropMax(S×T, w1⊕w2, f1⊕f2) = tropMax(S,w1,f1) + tropMax(T,w2,f2).

    Time complexity: O(|S|·|T| + |S| + |T|) = O(|S|·|T|)

    Args:
        S, T: Support sets.
        w1, w2: Weight functions on S, T.
        f1, f2: Input functions on S, T.

    Returns:
        (product_value, factor_sum, difference)
    """
    # Product computation
    product_val = max(
        f1(s) + f2(t) + w1[s] + w2[t]
        for s in S for t in T
    )

    # Factor computation
    val_s = max(f1(s) + w1[s] for s in S)
    val_t = max(f2(t) + w2[t] for t in T)

    return product_val, val_s + val_t, abs(product_val - (val_s + val_t))


def perturbation_bound(support_size: int) -> float:
    """Compute the tropical perturbation bound.

    Algorithm: Simply compute log(|S|).
    Time complexity: O(1)
    Space complexity: O(1)

    Args:
        support_size: Cardinality of the support set.

    Returns:
        log(support_size), the tropical perturbation bound.
    """
    if support_size <= 0:
        raise ValueError("Support size must be positive")
    return math.log(support_size)


def verify_tensorization(card_s: int, card_t: int) -> Tuple[float, float, float]:
    """Verify the tensorization law: log(|S×T|) = log(|S|) + log(|T|).

    Algorithm: Direct computation and comparison.
    Time complexity: O(1)

    Args:
        card_s, card_t: Cardinalities of factor supports.

    Returns:
        (product_bound, factor_sum, difference)
    """
    product_bound = perturbation_bound(card_s * card_t)
    factor_sum = perturbation_bound(card_s) + perturbation_bound(card_t)
    return product_bound, factor_sum, abs(product_bound - factor_sum)


def n_fold_bound(card_s: int, n: int) -> float:
    """Compute the n-fold amplification bound.

    Algorithm: n * log(|S|)
    Time complexity: O(1)

    Args:
        card_s: Base support cardinality.
        n: Number of copies.

    Returns:
        n * log(card_s), the n-fold amplification bound.
    """
    return n * perturbation_bound(card_s)


def perturbation_error_bound(eps1: float, eps2: float) -> float:
    """Compute the compositional perturbation error bound.

    For factor perturbations bounded by ε₁ and ε₂, the product
    functional perturbation is bounded by ε₁ + ε₂.

    Algorithm: Simple addition.
    Time complexity: O(1)

    Returns:
        eps1 + eps2
    """
    return eps1 + eps2


def weight_recovery(
    support: List[T],
    functional: Callable[[Callable[[T], float]], float],
    M: float = 1000.0
) -> Dict[T, float]:
    """Recover weights from a tropical max functional by probing.

    Algorithm:
    For each s in S, define the isolation function
    f_s(x) = M if x == s else -M, where M is large.
    Then F(f_s) ≈ w(s) + M for large M.

    Time complexity: O(|S|²) (|S| probes, each O(|S|))
    Space complexity: O(|S|)

    Args:
        support: The support set S.
        functional: The functional F to probe.
        M: Large constant for isolation.

    Returns:
        Recovered weights dictionary.
    """
    weights = {}
    for s in support:
        f_s = lambda x, target=s: M if x == target else -M
        weights[s] = functional(f_s) - M
    return weights


# ============================================================
# Example usage
# ============================================================

if __name__ == "__main__":
    print("Tropical Perturbation Amplification — Algorithm Demonstrations")
    print("=" * 60)

    # Create two factor functionals
    S = [1, 2, 3, 4, 5]
    T = ['a', 'b', 'c']
    w1 = {s: 0.1 * s for s in S}
    w2 = {'a': 0.3, 'b': -0.1, 'c': 0.5}

    F1 = TropicalMaxFunctional(S, w1)
    F2 = TropicalMaxFunctional(T, w2)

    print(f"\nFactor 1: S = {S}, bound = {F1.perturbation_bound():.4f}")
    print(f"Factor 2: T = {T}, bound = {F2.perturbation_bound():.4f}")

    # Product
    F_prod = TropicalMaxFunctional.product(F1, F2)
    print(f"Product: |S×T| = {len(F_prod.support)}, bound = {F_prod.perturbation_bound():.4f}")
    print(f"Sum of bounds: {F1.perturbation_bound() + F2.perturbation_bound():.4f}")

    # Tensorization verification
    print(f"\nTensorization check:")
    pb, fs, diff = verify_tensorization(len(S), len(T))
    print(f"  log(|S×T|) = {pb:.6f}")
    print(f"  log(|S|) + log(|T|) = {fs:.6f}")
    print(f"  Difference: {diff:.2e}")

    # Separability check
    f1 = lambda x: x ** 2
    f2 = lambda t: {'a': 1, 'b': 2, 'c': 3}[t]
    pv, fsum, d = product_separability_check(S, T, w1, w2, f1, f2)
    print(f"\nSeparability check:")
    print(f"  Product eval: {pv:.6f}")
    print(f"  Factor sum:   {fsum:.6f}")
    print(f"  Difference:   {d:.2e}")

    # N-fold amplification
    print(f"\nN-fold amplification for |S| = {len(S)}:")
    for n in range(1, 6):
        print(f"  n={n}: bound = {n_fold_bound(len(S), n):.4f}")

    # Weight recovery
    print(f"\nWeight recovery:")
    recovered = weight_recovery(S, F1.evaluate)
    for s in S:
        print(f"  s={s}: true w={w1[s]:.3f}, recovered w={recovered[s]:.3f}, "
              f"diff={abs(w1[s] - recovered[s]):.2e}")
