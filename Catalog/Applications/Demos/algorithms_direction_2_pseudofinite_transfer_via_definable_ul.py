#!/usr/bin/env python3
"""
Algorithms for Pseudofinite Transfer Analysis

Implements the core computational methods for testing the transfer conjecture
over families of definable subsets of GL(2, F_q).

Algorithms:
1. DefinableFamilyAnalyzer: Compute set sizes, product sets, and doubling ratios
2. CosetControlFinder: Find minimal coset covers for definable sets
3. TransferConjectureValidator: Aggregate evidence for/against the conjecture
"""

import itertools
from typing import List, Tuple, Dict, Optional, Callable
from dataclasses import dataclass


def is_prime(n: int) -> bool:
    """Primality test. O(sqrt(n))."""
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


@dataclass(frozen=True)
class Mat2:
    """Immutable 2x2 matrix over F_p."""
    a: int
    b: int
    c: int
    d: int
    p: int

    def det(self) -> int:
        return (self.a * self.d - self.b * self.c) % self.p

    def trace(self) -> int:
        return (self.a + self.d) % self.p

    def __mul__(self, other: 'Mat2') -> 'Mat2':
        assert self.p == other.p
        p = self.p
        return Mat2(
            (self.a * other.a + self.b * other.c) % p,
            (self.a * other.b + self.b * other.d) % p,
            (self.c * other.a + self.d * other.c) % p,
            (self.c * other.b + self.d * other.d) % p,
            p
        )

    def is_invertible(self) -> bool:
        return self.det() != 0


@dataclass
class FamilyAnalysis:
    """Results of analyzing a definable family at a specific prime."""
    prime: int
    set_size: int
    product_set_size: int
    doubling_ratio: float
    controlling_subgroup_type: str
    controlling_subgroup_size: int
    cosets_needed: int
    is_controlled: bool


class DefinableFamilyAnalyzer:
    """
    Analyze definable families of subsets of GL(2, F_p).

    Algorithm:
    1. Enumerate all elements of the family A_p ⊆ GL(2, F_p)
    2. Compute the product set A_p · A_p
    3. Calculate |A_p²| / |A_p|
    4. Search for controlling subgroups

    Complexity: O(p^4) for enumeration, O(|A|²) for product set.
    """

    def __init__(self, p: int):
        """Initialize with prime p."""
        assert is_prime(p), f"{p} is not prime"
        self.p = p

    def enumerate_gl2(self) -> List[Mat2]:
        """Enumerate all elements of GL(2, F_p). Size = p(p²-1)(p-1)."""
        p = self.p
        return [Mat2(a, b, c, d, p)
                for a, b, c, d in itertools.product(range(p), repeat=4)
                if (a * d - b * c) % p != 0]

    def product_set(self, A: List[Mat2]) -> set:
        """Compute A · A = {xy : x, y ∈ A}. Complexity: O(|A|²)."""
        return {x * y for x in A for y in A}

    def doubling_ratio(self, A: List[Mat2]) -> float:
        """Compute |A²| / |A|."""
        if not A:
            return float('inf')
        AA = self.product_set(A)
        return len(AA) / len(A)

    def analyze(self, A: List[Mat2]) -> FamilyAnalysis:
        """Full analysis of a definable family."""
        if not A:
            return FamilyAnalysis(self.p, 0, 0, 0, "empty", 0, 0, True)

        AA = self.product_set(A)
        ratio = len(AA) / len(A)

        # Try natural controlling subgroups
        ctrl_type, ctrl_size, cosets = self._find_best_control(A)

        return FamilyAnalysis(
            prime=self.p,
            set_size=len(A),
            product_set_size=len(AA),
            doubling_ratio=ratio,
            controlling_subgroup_type=ctrl_type,
            controlling_subgroup_size=ctrl_size,
            cosets_needed=cosets,
            is_controlled=(cosets <= 2 * ratio + 1)
        )

    def _find_best_control(self, A: List[Mat2]) -> Tuple[str, int, int]:
        """
        Find the best controlling subgroup among natural candidates.

        Candidates:
        - Borel subgroup (upper triangular)
        - Unipotent subgroup
        - Diagonal subgroup (torus)

        Returns: (subgroup_type, subgroup_size, cosets_needed)
        """
        A_set = set(A)
        p = self.p

        # Unipotent subgroup: [[1, b], [0, 1]]
        unipotent = {Mat2(1, b, 0, 1, p) for b in range(p)}

        # Upper triangular (Borel)
        borel = {Mat2(a, b, 0, d, p) for a, b, d in
                 itertools.product(range(p), repeat=3)
                 if (a * d) % p != 0}

        # Diagonal (torus)
        torus = {Mat2(a, 0, 0, d, p) for a, d in
                 itertools.product(range(1, p), repeat=2)}

        best = ("GL(2)", len(self.enumerate_gl2()), 1)

        for name, H in [("unipotent", unipotent), ("Borel", borel), ("torus", torus)]:
            if not H:
                continue
            cosets = self._count_cosets(A_set, H)
            if cosets < best[2] or (cosets == best[2] and len(H) < best[1]):
                best = (name, len(H), cosets)

        return best

    def _count_cosets(self, A: set, H: set) -> int:
        """Count minimum number of left cosets of H needed to cover A."""
        uncovered = set(A)
        cosets = 0
        while uncovered:
            # Pick an uncovered element
            g = next(iter(uncovered))
            # Remove all elements in the coset g·H
            coset = {g * h for h in H}
            uncovered -= coset
            cosets += 1
        return cosets


class TransferConjectureValidator:
    """
    Validate the transfer conjecture across a range of primes.

    The conjecture states: for uniformly polynomially definable families
    A_q ⊆ GL(2, F_q) of bounded description complexity, if
    |A_q²| ≤ K|A_q| for ultrafilter-many q, then A_ω is controlled
    by a definable subgroup of complexity bounded solely in terms of K
    and the formula complexity.

    Algorithm:
    1. For each prime p in the test range:
       a. Construct A_p using the family definition
       b. Compute doubling ratio
       c. Find minimal controlling subgroup
    2. Check if doubling ratios are bounded
    3. Check if control complexity is bounded
    4. Report verdict with confidence level

    Complexity: O(Σ_p p^4) over the test range.
    """

    def __init__(self, family_fn: Callable, name: str,
                 primes: Optional[List[int]] = None):
        self.family_fn = family_fn
        self.name = name
        self.primes = primes or [p for p in range(3, 30) if is_prime(p)]

    def validate(self) -> Dict:
        """Run the full validation pipeline."""
        results = []
        for p in self.primes:
            analyzer = DefinableFamilyAnalyzer(p)
            A = self.family_fn(p)
            analysis = analyzer.analyze(A)
            results.append(analysis)

        ratios = [r.doubling_ratio for r in results if r.set_size > 0]
        cosets = [r.cosets_needed for r in results if r.set_size > 0]

        verdict = {
            "family": self.name,
            "primes_tested": self.primes,
            "results": results,
            "max_doubling_ratio": max(ratios) if ratios else None,
            "min_doubling_ratio": min(ratios) if ratios else None,
            "max_cosets": max(cosets) if cosets else None,
            "bounded_doubling": max(ratios) < 100 if ratios else None,
            "bounded_control": max(cosets) < 100 if cosets else None,
            "supports_conjecture": (
                max(ratios) < 100 and max(cosets) < 100
            ) if ratios and cosets else None,
        }
        return verdict


# ============================================================
# Concrete family constructors (taking prime p, returning list)
# ============================================================

def family_unipotent_squares(p: int) -> List[Mat2]:
    """Unipotent matrices [[1, t²], [0, 1]]."""
    seen = set()
    result = []
    for t in range(p):
        t2 = (t * t) % p
        key = (1, t2, 0, 1)
        if key not in seen:
            seen.add(key)
            result.append(Mat2(1, t2, 0, 1, p))
    return result


def family_trace_one_upper(p: int) -> List[Mat2]:
    """Upper triangular with trace = 1."""
    result = []
    for a in range(p):
        d = (1 - a) % p
        if (a * d) % p == 0:
            continue
        for b in range(p):
            result.append(Mat2(a, b, 0, d, p))
    return result


def family_scalar_unipotent(p: int) -> List[Mat2]:
    """Scalar-times-unipotent: [[a, ab], [0, a]] with a = t² ≠ 0."""
    seen = set()
    result = []
    for t in range(1, p):
        a = (t * t) % p
        for b in range(p):
            ab = (a * b) % p
            key = (a, ab, 0, a)
            if key not in seen:
                seen.add(key)
                result.append(Mat2(a, ab, 0, a, p))
    return result


if __name__ == "__main__":
    families = [
        ("Unipotent squares", family_unipotent_squares),
        ("Trace-1 upper triangular", family_trace_one_upper),
        ("Scalar-unipotent", family_scalar_unipotent),
    ]

    primes = [p for p in range(3, 24) if is_prime(p)]

    for name, fn in families:
        validator = TransferConjectureValidator(fn, name, primes)
        verdict = validator.validate()

        print(f"\n{'='*60}")
        print(f"  {name}")
        print(f"{'='*60}")
        print(f"  Doubling ratio: [{verdict['min_doubling_ratio']:.3f}, "
              f"{verdict['max_doubling_ratio']:.3f}]")
        print(f"  Max cosets needed: {verdict['max_cosets']}")
        print(f"  Supports conjecture: {verdict['supports_conjecture']}")
        for r in verdict['results']:
            print(f"    p={r.prime:>3}: |A|={r.set_size:>5}, "
                  f"|A²|={r.product_set_size:>5}, "
                  f"ratio={r.doubling_ratio:>6.3f}, "
                  f"ctrl={r.controlling_subgroup_type}, "
                  f"cosets={r.cosets_needed}")
