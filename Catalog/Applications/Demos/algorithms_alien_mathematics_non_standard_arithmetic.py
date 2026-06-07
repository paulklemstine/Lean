#!/usr/bin/env python3
"""
Algorithms for Non-Standard Arithmetic

Type-hinted implementations of the key constructions from the formalization.
"""

from __future__ import annotations
from typing import Callable, List, Set, Tuple, Optional
from dataclasses import dataclass
import math


# ─── Ultrafilter Simulation ───────────────────────────────────────────────────

@dataclass
class SimulatedUltrafilter:
    """A simulated free ultrafilter on ℕ, approximated by cofinite sets.
    
    A true ultrafilter on ℕ is a maximal consistent family of subsets.
    Free (non-principal) ultrafilters contain all cofinite sets.
    We simulate this by tracking the 'threshold' beyond which sets are considered large.
    """
    threshold: int = 0  # Sets containing {threshold, threshold+1, ...} are "large"
    
    def is_large(self, membership_test: Callable[[int], bool], universe: int = 10000) -> bool:
        """Check if a set (given by its characteristic function) is 'U-large'."""
        # Count how many elements ≥ threshold are in the set
        count = sum(1 for i in range(self.threshold, universe) if membership_test(i))
        total = universe - self.threshold
        return count > total * 0.99  # Cofinite = almost all elements
    
    def contains_cofinite(self, finite_exclude: Set[int]) -> bool:
        """A free ultrafilter contains the complement of any finite set."""
        return True  # By definition of free ultrafilter


# ─── Ultrapower Element ──────────────────────────────────────────────────────

@dataclass
class UltrapowerElement:
    """An element of the ultrapower ℕ*/U, represented by a function ℕ → ℕ."""
    representative: Callable[[int], int]
    name: str = "f"
    
    def is_nonstandard(self, U: SimulatedUltrafilter, max_check: int = 1000) -> bool:
        """Check if this element exceeds all standard naturals."""
        for n in range(max_check):
            # Check {i | n < f(i)} is U-large
            if not U.is_large(lambda i, n=n: self.representative(i) > n):
                return False
        return True
    
    def ultra_eq(self, other: UltrapowerElement, U: SimulatedUltrafilter) -> bool:
        """Check if two elements are U-equivalent."""
        return U.is_large(lambda i: self.representative(i) == other.representative(i))
    
    def ultra_le(self, other: UltrapowerElement, U: SimulatedUltrafilter) -> bool:
        """Check if self ≤ other in the ultrapower ordering."""
        return U.is_large(lambda i: self.representative(i) <= other.representative(i))
    
    @staticmethod
    def standard(n: int) -> UltrapowerElement:
        """The standard embedding of n into the ultrapower."""
        return UltrapowerElement(lambda _: n, name=f"std({n})")
    
    @staticmethod
    def identity() -> UltrapowerElement:
        """The identity function — the canonical non-standard element."""
        return UltrapowerElement(lambda i: i, name="id")


# ─── Overspill Construction ──────────────────────────────────────────────────

def overspill_witness(
    P: Callable[[int, int], bool],
    max_i: int = 10000
) -> Callable[[int], int]:
    """Construct the overspill witness function.
    
    Given a decidable property P(i, n), returns f where:
    f(i) = max{n ≤ i | ∀k ≤ n, P(i, k)}
    
    This is the Nat.findGreatest construction from the Lean proof.
    """
    def f(i: int) -> int:
        best = -1
        for n in range(i + 1):
            if all(P(i, k) for k in range(n + 1)):
                best = n
            else:
                break
        return max(best, 0)
    return f


def verify_overspill(
    P: Callable[[int, int], bool],
    f: Callable[[int], int],
    universe: int = 1000
) -> Tuple[bool, bool]:
    """Verify the two conditions of the overspill principle:
    1. f is non-standard (f(i) → ∞)
    2. P(i, f(i)) holds for 'most' i
    
    Returns (is_nonstandard, property_holds).
    """
    # Check non-standard: f(i) should grow without bound
    growth_check = all(f(i) >= min(i, 100) - 1 for i in range(100, universe))
    
    # Check P(i, f(i)) holds for most i
    holds_count = sum(1 for i in range(universe) if P(i, f(i)))
    property_ratio = holds_count / universe
    
    return growth_check, property_ratio > 0.95


# ─── Transfer Principles ─────────────────────────────────────────────────────

def transfer_division_algorithm(
    a: Callable[[int], int],
    b: Callable[[int], int],
    universe: int = 1000
) -> float:
    """Verify the division algorithm transfers.
    
    Returns the fraction of indices where a(i) = b(i)*q(i) + r(i) with r(i) < b(i).
    Should be 1.0 for all valid inputs (universal truth).
    """
    valid = 0
    total = 0
    for i in range(universe):
        if b(i) > 0:
            total += 1
            q, r = divmod(a(i), b(i))
            if a(i) == b(i) * q + r and r < b(i):
                valid += 1
    return valid / total if total > 0 else 1.0


def transfer_gcd_properties(
    a: Callable[[int], int],
    b: Callable[[int], int],
    universe: int = 1000
) -> float:
    """Verify GCD transfer: gcd(a(i), b(i)) divides both a(i) and b(i).
    
    Returns fraction of indices where the property holds (should be 1.0).
    """
    valid = 0
    for i in range(universe):
        g = math.gcd(a(i), b(i))
        if a(i) % g == 0 and b(i) % g == 0:
            valid += 1
    return valid / universe


def ultrapower_dichotomy(
    g: Callable[[int], int],
    universe: int = 10000
) -> str:
    """Classify an ultrapower element as 'nonstandard' or 'bounded'.
    
    Returns 'nonstandard' if g(i) → ∞, or 'bounded by N' if g(i) ≤ N for most i.
    """
    # Find if g is bounded
    max_val = max(g(i) for i in range(universe))
    
    # Check if g grows without bound
    for bound in [10, 100, 1000]:
        exceeding = sum(1 for i in range(universe) if g(i) > bound)
        if exceeding < universe * 0.5:
            return f"bounded by {bound}"
    
    return f"nonstandard (max value in [0,{universe}) = {max_val})"


# ─── Non-Archimedean Detection ───────────────────────────────────────────────

def detect_non_archimedean(
    f: Callable[[int], int],
    max_multiplier: int = 100,
    universe: int = 1000
) -> bool:
    """Check if f represents a non-Archimedean element.
    
    Returns True if for all n*k with n,k ≤ max_multiplier,
    {i | n*k < f(i)} is 'large' (cofinite).
    """
    for n in range(1, max_multiplier + 1):
        for k in range(1, max_multiplier + 1):
            product = n * k
            exceeding = sum(1 for i in range(universe) if f(i) > product)
            if exceeding < universe * 0.9:
                return False
    return True


if __name__ == "__main__":
    print("Algorithm Demonstrations")
    print("=" * 60)
    
    # Demo 1: Overspill
    print("\n1. Overspill Witness Construction")
    P = lambda i, n: i > n * n  # P(i,n) = "i > n²"
    f = overspill_witness(P)
    ns, ph = verify_overspill(P, f, 500)
    print(f"   P(i,n) = 'i > n²'")
    print(f"   f = overspill witness")
    print(f"   Non-standard: {ns}")
    print(f"   P(i, f(i)) holds: {ph}")
    print(f"   Sample values: f(100)={f(100)}, f(400)={f(400)}, f(900)={f(900)}")
    
    # Demo 2: Transfer
    print("\n2. Division Algorithm Transfer")
    a = lambda i: i * i + 3 * i + 7
    b = lambda i: i + 1
    ratio = transfer_division_algorithm(a, b)
    print(f"   a(i) = i² + 3i + 7, b(i) = i + 1")
    print(f"   Division holds for {ratio:.0%} of indices")
    
    # Demo 3: Dichotomy
    print("\n3. Ultrapower Dichotomy")
    examples = [
        ("i²", lambda i: i * i),
        ("i mod 7", lambda i: i % 7),
        ("2^(i mod 10)", lambda i: 2 ** (i % 10)),
        ("i", lambda i: i),
    ]
    for name, g in examples:
        result = ultrapower_dichotomy(g)
        print(f"   g(i) = {name}: {result}")
