#!/usr/bin/env python3
"""
Non-Standard Arithmetic: Core Algorithms

Type-hinted implementations of:
1. Ultrapower equivalence checking
2. Standard part computation
3. Overspill bound estimation
4. Bounded-infinite classification
"""

from typing import Callable, Optional, Tuple, List, Dict
from collections import Counter
import math


# Type aliases
Sequence = Callable[[int], int]
UltrafilterApprox = Callable[[set], bool]


def make_free_ultrafilter(sample_size: int = 10000) -> UltrafilterApprox:
    """Create an approximate free ultrafilter using density.

    A free ultrafilter on ℕ contains all cofinite sets. We approximate
    this by declaring a set U-large if its density in {0,...,N-1} exceeds 0.5.
    """
    def is_large(s: set) -> bool:
        restricted = {x for x in s if 0 <= x < sample_size}
        return len(restricted) / sample_size > 0.5
    return is_large


def ultra_eq(f: Sequence, g: Sequence, n: int = 10000) -> Tuple[bool, float]:
    """Check if f ~_U g (U-equivalent).

    Returns (is_equivalent, agreement_density).
    """
    agree = sum(1 for i in range(n) if f(i) == g(i))
    density = agree / n
    return (density > 0.5, density)


def standard_part(f: Sequence, n: int = 10000) -> Optional[int]:
    """Compute the standard part of a bounded element [f] ∈ ℕ*.

    Returns the unique m such that {i | f(i) = m} ∈ U,
    or None if no such m exists (element is infinite).
    """
    vals = [f(i) for i in range(n)]
    counter = Counter(vals)

    for val, count in counter.most_common():
        if count / n > 0.5:
            return val

    return None


def is_bounded(f: Sequence, n: int = 10000) -> Tuple[bool, Optional[int]]:
    """Check if [f] is bounded in ℕ* and return standard part if so.

    An element is bounded if ∃ m, {i | f(i) ≤ m} ∈ U.
    """
    vals = [f(i) for i in range(n)]

    # Try each potential bound
    for bound in sorted(set(vals)):
        le_count = sum(1 for v in vals if v <= bound)
        if le_count / n > 0.5:
            # Element is bounded by `bound`, compute standard part
            sp = standard_part(f, n)
            return (True, sp)

    return (False, None)


def is_infinite(f: Sequence, n: int = 10000, test_bounds: int = 20) -> bool:
    """Check if [f] is infinite in ℕ* (exceeds all standard naturals).

    Tests whether {i | k < f(i)} has density > 0.5 for several values of k.
    """
    vals = [f(i) for i in range(n)]
    for k in range(0, test_bounds * 100, test_bounds):
        exceeds = sum(1 for v in vals if v > k)
        if exceeds / n <= 0.5:
            return False
    return True


def overspill_bound(
    p: Callable[[int, int], bool],
    n: int = 10000
) -> Sequence:
    """Compute the overspill bound function f for property P.

    For each index i, f(i) = max{n | ∀ k ≤ n, P(i, k)}.
    By the overspill principle, if P(i, n) holds for all standard n
    on a U-large set, then f grows without bound U-a.e.
    """
    def f(i: int) -> int:
        bound = 0
        for k in range(i + 1):
            if p(i, k):
                bound = k
            else:
                break
        return bound
    return f


def classify_ultrapower_element(
    f: Sequence,
    n: int = 10000
) -> Dict[str, object]:
    """Classify an element [f] ∈ ℕ* as bounded or infinite.

    Returns a dictionary with classification info.
    """
    bounded, sp = is_bounded(f, n)
    inf = is_infinite(f, n)

    return {
        "bounded": bounded,
        "infinite": inf,
        "standard_part": sp,
        "sample_values": [f(i) for i in range(10)],
        "max_sampled": max(f(i) for i in range(n)),
    }


def descending_chain(f: Sequence, depth: int = 10) -> List[Sequence]:
    """Construct a descending chain from an infinite element [f].

    Returns [f, f-1, f-2, ...] demonstrating well-ordering failure.
    """
    chain = []
    for step in range(depth):
        g = lambda i, s=step: max(f(i) - s, 0)
        chain.append(g)
    return chain


def polynomial_transfer_check(
    poly_lhs: Callable[[int], int],
    poly_rhs: Callable[[int], int],
    a: Sequence,
    n: int = 10000,
) -> Tuple[bool, float]:
    """Check if a polynomial identity transfers through the ultrapower.

    Verifies: [poly_lhs ∘ a] =_U [poly_rhs ∘ a]
    """
    agree = sum(
        1 for i in range(n)
        if poly_lhs(a(i)) == poly_rhs(a(i))
    )
    density = agree / n
    return (density > 0.999, density)


# Example usage
if __name__ == "__main__":
    # Example 1: Classify elements
    print("Element Classification:")
    elements = {
        "constant 42": lambda i: 42,
        "identity (ω)": lambda i: i,
        "i mod 5": lambda i: i % 5,
        "i squared": lambda i: i * i,
    }
    for name, f in elements.items():
        info = classify_ultrapower_element(f)
        print(f"  [{name}]: {info}")
    print()

    # Example 2: Descending chain
    print("Descending Chain from ω:")
    omega = lambda i: i
    chain = descending_chain(omega, 5)
    for step, g in enumerate(chain):
        inf = is_infinite(g)
        print(f"  ω - {step}: infinite = {inf}, samples = {[g(i) for i in range(8)]}")
    print()

    # Example 3: Polynomial transfer
    print("Polynomial Transfer:")
    # (a+b)^2 = a^2 + 2ab + b^2
    a = lambda i: i
    b = lambda i: 2 * i + 1
    lhs = lambda x: (a(x) + b(x)) ** 2
    rhs = lambda x: a(x)**2 + 2*a(x)*b(x) + b(x)**2
    ok, density = polynomial_transfer_check(lhs, rhs, lambda i: i)
    print(f"  (a+b)² = a²+2ab+b²: transfers = {ok}, density = {density}")
