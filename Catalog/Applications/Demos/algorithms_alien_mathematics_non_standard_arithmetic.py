#!/usr/bin/env python3
"""
Non-Standard Arithmetic: Core Algorithms

Type-hinted implementations of the key algorithms from the
non-standard arithmetic theory.
"""

from typing import Callable, List, Optional, Set, Tuple
from fractions import Fraction
import math


# =============================================================================
# Algorithm 1: Ultrapower Arithmetic
# =============================================================================

class UltrapowerElement:
    """
    Represents an element of the ultrapower ℕ^ℕ/U.
    
    In practice, we represent it as a finite-length sequence
    (a truncation of the infinite sequence) and use density-based
    "U-large" decisions as an approximation to a true free ultrafilter.
    """
    
    def __init__(self, seq: List[int], universe_size: int = 10000):
        """Initialize with a sequence of natural numbers."""
        self.seq = seq
        self.n = len(seq)
        self.universe_size = universe_size
    
    @staticmethod
    def standard(value: int, n: int = 10000) -> 'UltrapowerElement':
        """Create a standard element (constant sequence)."""
        return UltrapowerElement([value] * n, n)
    
    @staticmethod
    def identity(n: int = 10000) -> 'UltrapowerElement':
        """Create the diagonal/identity element (0, 1, 2, 3, ...)."""
        return UltrapowerElement(list(range(n)), n)
    
    def __add__(self, other: 'UltrapowerElement') -> 'UltrapowerElement':
        """Pointwise addition."""
        assert self.n == other.n
        return UltrapowerElement([a + b for a, b in zip(self.seq, other.seq)], self.n)
    
    def __mul__(self, other: 'UltrapowerElement') -> 'UltrapowerElement':
        """Pointwise multiplication."""
        assert self.n == other.n
        return UltrapowerElement([a * b for a, b in zip(self.seq, other.seq)], self.n)
    
    def __sub__(self, other: 'UltrapowerElement') -> 'UltrapowerElement':
        """Pointwise ℕ-subtraction (truncated at 0)."""
        assert self.n == other.n
        return UltrapowerElement([max(0, a - b) for a, b in zip(self.seq, other.seq)], self.n)
    
    def u_large_set(self, predicate: Callable[[int], bool]) -> float:
        """
        Compute the density of {i | predicate(seq[i])}.
        Returns a float in [0, 1]; values > 0.5 are "U-large".
        """
        count = sum(1 for x in self.seq if predicate(x))
        return count / self.n
    
    def is_infinite(self) -> bool:
        """Check if this element is "infinite" (exceeds every standard n)."""
        # An element is infinite if for every M, {i | seq[i] > M} is U-large
        # We check for several values of M
        for M in [10, 100, 1000]:
            density = self.u_large_set(lambda x, m=M: x > m)
            if density <= 0.5:
                return False
        return True
    
    def u_equivalent(self, other: 'UltrapowerElement') -> float:
        """Density of {i | seq[i] = other.seq[i]}."""
        assert self.n == other.n
        return sum(1 for a, b in zip(self.seq, other.seq) if a == b) / self.n
    
    def __repr__(self) -> str:
        if len(set(self.seq)) == 1:
            return f"Std({self.seq[0]})"
        return f"[{', '.join(str(x) for x in self.seq[:5])}, ...]"


# =============================================================================
# Algorithm 2: Overspill Detection
# =============================================================================

def overspill_check(
    predicate: Callable[[int], bool],
    max_standard: int = 10000
) -> Tuple[bool, Optional[int]]:
    """
    Check if a predicate P satisfies the overspill condition.
    
    Returns (holds_for_all_standard, first_failure) where:
    - holds_for_all_standard: True if P(k) holds for all k in [0, max_standard]
    - first_failure: The first k where P(k) fails, or None if it holds everywhere
    
    If holds_for_all_standard is True, then by the Overspill Principle,
    P must hold for some non-standard element in any free ultrapower.
    """
    for k in range(max_standard + 1):
        if not predicate(k):
            return (False, k)
    return (True, None)


def underspill_check(
    predicate: Callable[[int], bool],
    max_check: int = 10000
) -> Tuple[bool, Optional[int]]:
    """
    Check the underspill condition: if P fails for all "large" elements,
    find the standard failure point.
    
    Returns (has_standard_failure, failure_point).
    """
    for k in range(max_check, -1, -1):
        if not predicate(k):
            return (True, k)
    return (False, None)


# =============================================================================
# Algorithm 3: Transfer Verification
# =============================================================================

def verify_transfer(
    identity: Callable[[List[int]], bool],
    num_samples: int = 1000,
    max_val: int = 100
) -> Tuple[float, int]:
    """
    Verify that an algebraic identity transfers to the ultrapower.
    
    Tests the identity on random sequences and returns:
    - density: fraction of index positions where the identity holds
    - violations: number of positions where it fails
    
    For genuine algebraic identities (like commutativity), density should be 1.0.
    """
    import random
    random.seed(42)
    
    violations = 0
    total = 0
    
    for _ in range(num_samples):
        vals = [random.randint(0, max_val) for _ in range(10)]
        if not identity(vals):
            violations += 1
        total += 1
    
    density = 1.0 - violations / total
    return (density, violations)


# =============================================================================
# Algorithm 4: Ultrafilter Limit Computation
# =============================================================================

def ultrafilter_limit(
    sequence: Callable[[int], float],
    n_terms: int = 100000,
    tail_fraction: float = 0.01
) -> Tuple[float, float]:
    """
    Approximate the ultrafilter limit of a bounded sequence.
    
    For a free ultrafilter, the ultrafilter limit of a convergent sequence
    equals its ordinary limit. For oscillating sequences, the ultrafilter
    "chooses" a subsequential limit.
    
    Returns (limit_estimate, confidence) where confidence measures
    how stable the estimate is.
    """
    tail_size = max(1, int(n_terms * tail_fraction))
    tail_start = n_terms - tail_size
    
    tail_values = [sequence(i) for i in range(tail_start, n_terms)]
    
    limit_est = sum(tail_values) / len(tail_values)
    
    # Confidence: inverse of variance in the tail
    variance = sum((v - limit_est) ** 2 for v in tail_values) / len(tail_values)
    confidence = 1.0 / (1.0 + variance)
    
    return (limit_est, confidence)


# =============================================================================
# Algorithm 5: Descending Chain Construction
# =============================================================================

def descending_chain(
    infinite_element: UltrapowerElement,
    num_steps: int = 20
) -> List[UltrapowerElement]:
    """
    Construct a descending chain from an infinite element in *ℕ.
    
    Starting from [f], computes [f]-1, [f]-2, ..., [f]-k.
    In standard ℕ, such a chain must terminate. In *ℕ, it continues
    indefinitely from an infinite starting point.
    
    Returns the chain of ultrapower elements.
    """
    chain = [infinite_element]
    one = UltrapowerElement.standard(1, infinite_element.n)
    
    current = infinite_element
    for _ in range(num_steps):
        current = current - one
        chain.append(current)
    
    return chain


def verify_chain_descending(chain: List[UltrapowerElement]) -> List[float]:
    """
    Verify that each step in the chain is strictly descending U-a.e.
    
    Returns the density of {i | chain[k+1][i] < chain[k][i]} for each step.
    """
    densities = []
    for k in range(len(chain) - 1):
        n = chain[k].n
        strictly_less = sum(
            1 for i in range(n)
            if chain[k + 1].seq[i] < chain[k].seq[i]
        )
        densities.append(strictly_less / n)
    return densities


if __name__ == "__main__":
    # Quick self-test
    print("Testing UltrapowerElement...")
    
    # Standard elements
    three = UltrapowerElement.standard(3)
    five = UltrapowerElement.standard(5)
    eight = three + five
    assert all(x == 8 for x in eight.seq), "3 + 5 should be 8"
    
    # Infinite element
    omega = UltrapowerElement.identity()
    assert omega.is_infinite(), "Identity should be infinite"
    assert not three.is_infinite(), "Standard 3 should not be infinite"
    
    # Overspill
    result, failure = overspill_check(lambda k: k < 1000, max_standard=2000)
    assert not result and failure == 1000
    
    result, failure = overspill_check(lambda k: True, max_standard=1000)
    assert result and failure is None
    
    # Descending chain
    chain = descending_chain(omega, 10)
    densities = verify_chain_descending(chain)
    assert all(d > 0.99 for d in densities), f"Chain should be descending: {densities}"
    
    print("All tests passed!")
