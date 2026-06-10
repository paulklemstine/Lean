"""
Fiber Unity Principle — Core Algorithms
========================================
Type-hinted implementations of fiber profile computation,
deficiency analysis, and erasure cost estimation.
"""

from __future__ import annotations
from collections import Counter
from math import log2, ceil
from typing import Callable, TypeVar, Sequence

A = TypeVar("A")
B = TypeVar("B")


def fiber_profile(f: Callable[[A], B], domain: Sequence[A]) -> list[int]:
    """Compute the fiber profile of f over the given domain.

    The fiber profile is the sorted (descending) list of preimage sizes.
    Time: O(|domain|).  Space: O(|codomain|).

    >>> fiber_profile(lambda x: x % 3, range(9))
    [3, 3, 3]
    >>> fiber_profile(lambda x: x % 3, range(10))
    [4, 3, 3]
    """
    counts = Counter(f(x) for x in domain)
    return sorted(counts.values(), reverse=True)


def deficiency(f: Callable[[A], B], domain: Sequence[A]) -> int:
    """Compute the deficiency: |domain| - |image(f)|.

    >>> deficiency(lambda x: x, range(5))
    0
    >>> deficiency(lambda x: 0, range(5))
    4
    """
    image_size = len(set(f(x) for x in domain))
    return len(domain) - image_size


def max_fiber_size(f: Callable[[A], B], domain: Sequence[A]) -> int:
    """Return the maximum fiber size (largest preimage cardinality).

    >>> max_fiber_size(lambda x: x % 2, range(6))
    3
    """
    profile = fiber_profile(f, domain)
    return max(profile) if profile else 0


def depth_lower_bound(f: Callable[[A], B], domain: Sequence[A]) -> int:
    """Decision tree depth lower bound: ceil(log2(max_fiber_size)).

    Any binary decision tree distinguishing elements within the
    largest fiber needs at least this many levels.

    >>> depth_lower_bound(lambda x: x % 2, range(8))
    2
    >>> depth_lower_bound(lambda x: 0, range(8))
    3
    """
    m = max_fiber_size(f, domain)
    return ceil(log2(m)) if m > 1 else 0


def erasure_cost_bits(f: Callable[[A], B], domain: Sequence[A]) -> float:
    """Total erasure cost in bits: log2(|domain|) - log2(|image|).

    This is the information-theoretic measure of how many bits of
    information the function destroys.

    >>> erasure_cost_bits(lambda x: x, range(8))
    0.0
    >>> round(erasure_cost_bits(lambda x: 0, range(8)), 4)
    3.0
    """
    n = len(domain)
    image_size = len(set(f(x) for x in domain))
    if image_size == 0 or n == 0:
        return 0.0
    return log2(n) - log2(image_size)


def weighted_landauer_cost(
    f: Callable[[A], B], domain: Sequence[A], kT: float = 1.0
) -> float:
    """Weighted Landauer erasure cost.

    W = kT * sum_b (s_b / N) * ln(s_b)

    where s_b is the fiber size of output b, N = |domain|.

    >>> round(weighted_landauer_cost(lambda x: 0, range(4)), 4)
    1.3863
    """
    from math import log

    n = len(domain)
    if n == 0:
        return 0.0
    profile = fiber_profile(f, domain)
    return kT * sum((s / n) * log(s) for s in profile)


def verify_fiber_partition(f: Callable[[A], B], domain: Sequence[A]) -> bool:
    """Verify the fiber partition theorem: sum of fiber sizes = |domain|.

    >>> verify_fiber_partition(lambda x: x % 3, range(12))
    True
    """
    profile = fiber_profile(f, domain)
    return sum(profile) == len(domain)


def verify_combinatorial_second_law(
    f: Callable[[A], B],
    g: Callable[[B], B],
    domain: Sequence[A],
) -> bool:
    """Verify that def(f) <= def(g ∘ f).

    >>> verify_combinatorial_second_law(lambda x: x % 4, lambda y: y % 2, range(8))
    True
    """
    def_f = deficiency(f, domain)
    def_gf = deficiency(lambda x: g(f(x)), domain)
    return def_f <= def_gf


def verify_unity_theorem(f: Callable[[A], B], domain: Sequence[A]) -> bool:
    """Verify: deficiency(f) + |image(f)| = |domain|.

    >>> verify_unity_theorem(lambda x: x % 3, range(9))
    True
    """
    d = deficiency(f, domain)
    image_size = len(set(f(x) for x in domain))
    return d + image_size == len(domain)


def fiber_renyi_entropy(
    f: Callable[[A], B], domain: Sequence[A], alpha: float
) -> float:
    """Compute the fiber Rényi entropy of order alpha.

    H_alpha = (1/(1-alpha)) * log2(sum_i (s_i/N)^alpha)

    Special cases:
    - alpha → 0: H_0 = log2(|image|)  (Hartley entropy)
    - alpha → 1: Shannon entropy
    - alpha → ∞: min-entropy = log2(N / max(s_i))

    >>> round(fiber_renyi_entropy(lambda x: x % 2, range(8), 2.0), 4)
    1.0
    """
    n = len(domain)
    if n == 0:
        return 0.0
    profile = fiber_profile(f, domain)
    probs = [s / n for s in profile]

    if alpha == 0:
        return log2(len(profile))
    elif abs(alpha - 1.0) < 1e-10:
        # Shannon entropy
        return -sum(p * log2(p) for p in probs if p > 0)
    elif alpha == float("inf"):
        return -log2(max(probs))
    else:
        power_sum = sum(p**alpha for p in probs)
        return (1 / (1 - alpha)) * log2(power_sum)


if __name__ == "__main__":
    import doctest

    doctest.testmod()
