#!/usr/bin/env python3
"""
algorithms.py — Core algorithms for non-standard arithmetic computations.

Implements:
1. UltrafilterApprox: Finite approximation to ultrafilter selection
2. TransferEngine: Automated property transfer checker
3. OverspillDetector: Identifies when overspill applies
"""

from typing import Callable, List, Tuple, Optional, TypeVar
import math

T = TypeVar('T')


class UltrafilterApprox:
    """
    Finite approximation to an ultrafilter on ℕ.

    Uses a 'selection function' that, given a partition of {0,...,N-1},
    returns the selected block. For a free ultrafilter approximation,
    we select the block with the largest elements (cofinality bias).

    In the limit N → ∞, this approximates the behavior of a free
    ultrafilter selecting cofinite sets.
    """

    def __init__(self, size: int = 1000, bias: str = "cofinal"):
        """
        Args:
            size: Approximation universe size
            bias: Selection strategy ('cofinal', 'density', 'random')
        """
        self.size = size
        self.bias = bias

    def is_large(self, predicate: Callable[[int], bool]) -> bool:
        """Check if {i | predicate(i)} would be U-large."""
        count = sum(1 for i in range(self.size) if predicate(i))
        if self.bias == "cofinal":
            # Check if predicate holds for all sufficiently large i
            tail_size = self.size // 10
            tail_count = sum(1 for i in range(self.size - tail_size, self.size)
                           if predicate(i))
            return tail_count == tail_size  # Must hold on entire tail
        elif self.bias == "density":
            return count > self.size // 2
        else:
            return count > self.size // 2

    def select_color(self, coloring: Callable[[int], int],
                     num_colors: int) -> int:
        """Select the unique U-large color class."""
        counts = [0] * num_colors
        for i in range(self.size):
            counts[coloring(i)] += 1
        return max(range(num_colors), key=lambda c: counts[c])

    def transfer_and(self, p: Callable[[int], bool],
                     q: Callable[[int], bool]) -> bool:
        """Check if P ∧ Q holds U-a.e., given P and Q hold U-a.e."""
        return self.is_large(lambda i: p(i) and q(i))

    def transfer_or(self, p: Callable[[int], bool],
                    q: Callable[[int], bool]) -> Tuple[bool, bool]:
        """Determine which of P, Q is U-large (at least one must be)."""
        p_large = self.is_large(p)
        q_large = self.is_large(q)
        return (p_large, q_large)


class TransferEngine:
    """
    Checks whether arithmetic properties transfer through ultraproducts.

    Given a property P on ℕ expressed as a predicate, verifies that:
    - P(f(i)) holds U-a.e.
    - The transfer preserves logical connectives
    """

    def __init__(self, ultra: UltrafilterApprox):
        self.ultra = ultra

    def check_pointwise(self, f: Callable[[int], int],
                        prop: Callable[[int], bool]) -> bool:
        """Check if prop(f(i)) holds U-a.e."""
        return self.ultra.is_large(lambda i: prop(f(i)))

    def check_divisibility(self, f: Callable[[int], int],
                           g: Callable[[int], int]) -> bool:
        """Check if f | g holds U-a.e."""
        return self.ultra.is_large(
            lambda i: f(i) != 0 and g(i) % f(i) == 0
        )

    def check_primality(self, f: Callable[[int], int]) -> bool:
        """Check if f(i) is prime U-a.e."""
        def is_prime(n: int) -> bool:
            if n < 2:
                return False
            for d in range(2, int(n**0.5) + 1):
                if n % d == 0:
                    return False
            return True
        return self.ultra.is_large(lambda i: is_prime(f(i)))

    def verify_bezout(self, f: Callable[[int], int],
                      g: Callable[[int], int]) -> bool:
        """Verify Bezout's identity transfers: ∃ a,b: gcd(f,g) = f·a + g·b."""
        def bezout_holds(i: int) -> bool:
            d = math.gcd(f(i), g(i))
            # Extended Euclidean algorithm
            if f(i) == 0 and g(i) == 0:
                return True
            _, a, b = extended_gcd(f(i), g(i))
            return d == f(i) * a + g(i) * b
        return self.ultra.is_large(bezout_holds)


class OverspillDetector:
    """
    Detects overspill phenomena in finite approximations.

    Overspill: if an internal property holds for all 'standard' elements
    (n < threshold), it must hold for some element beyond the threshold.
    """

    def __init__(self, threshold: int = 100, universe: int = 1000):
        self.threshold = threshold
        self.universe = universe

    def check_overspill(self, prop: Callable[[int], bool]) -> Optional[int]:
        """
        If prop holds for all n < threshold, find the first
        witness beyond threshold where it still holds.

        Returns the witness, or None if overspill fails
        (which would mean the property is 'external', like 'being standard').
        """
        # Verify prop holds for all standard elements
        for n in range(self.threshold):
            if not prop(n):
                return None

        # Search for overspill witness
        for n in range(self.threshold, self.universe):
            if prop(n):
                return n
        return None

    def detect_internal(self, prop: Callable[[int], bool]) -> bool:
        """
        Heuristically determine if a property is 'internal' (transfers)
        vs 'external' (doesn't transfer).

        Internal properties: defined by arithmetic operations
        External properties: reference the 'standard' predicate
        """
        witness = self.check_overspill(prop)
        return witness is not None

    def find_overspill_boundary(self, prop: Callable[[int], bool]) -> int:
        """Find the largest element where prop still holds."""
        last_true = -1
        for n in range(self.universe):
            if prop(n):
                last_true = n
        return last_true


def extended_gcd(a: int, b: int) -> Tuple[int, int, int]:
    """Extended Euclidean algorithm. Returns (gcd, x, y) where a*x + b*y = gcd."""
    if a == 0:
        return b, 0, 1
    gcd, x, y = extended_gcd(b % a, a)
    return gcd, y - (b // a) * x, x


def compute_ultra_element(f: Callable[[int], int],
                          g: Callable[[int], int],
                          op: str = "add",
                          size: int = 20) -> List[int]:
    """
    Compute the pointwise operation of two UltraNat representatives.

    Returns the result sequence for visual inspection.
    """
    if op == "add":
        return [f(i) + g(i) for i in range(size)]
    elif op == "mul":
        return [f(i) * g(i) for i in range(size)]
    elif op == "gcd":
        return [math.gcd(f(i), g(i)) for i in range(size)]
    else:
        raise ValueError(f"Unknown operation: {op}")


if __name__ == "__main__":
    # Example usage
    U = UltrafilterApprox(size=500)
    engine = TransferEngine(U)
    detector = OverspillDetector(threshold=50, universe=500)

    # Check factorial divisibility
    print("Factorial divisibility by 6:", engine.check_divisibility(
        lambda i: 6, lambda i: math.factorial(max(i, 1))
    ))

    # Check primality of p(i) = 2i+1 (not always prime)
    print("Primality of 2i+1:", engine.check_primality(lambda i: 2*i+1))

    # Overspill: "n < 1000" holds for all standard n < 50
    witness = detector.check_overspill(lambda n: n < 1000)
    print(f"Overspill witness for 'n < 1000': {witness}")

    # "Being standard" does NOT overspill
    witness = detector.check_overspill(lambda n: n < 50)
    print(f"Overspill for 'n < 50' (external): {witness}")
