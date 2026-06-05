#!/usr/bin/env python3
"""
Algorithms for Non-Archimedean Probability Theory

Type-hinted implementations of the key algorithms from the research.
"""

from fractions import Fraction
from typing import (
    Callable,
    Dict,
    FrozenSet,
    Generic,
    List,
    Optional,
    Set,
    Tuple,
    TypeVar,
)


# ============================================================
# Core Data Types
# ============================================================


class SurrealTruncated:
    """
    Truncated surreal number: a + b·ε where ε = 1/ω.

    This captures the two-level structure sufficient for
    infinitesimal probability: a standard part (real) and
    an infinitesimal part.
    """

    def __init__(self, standard: Fraction = Fraction(0),
                 infinitesimal: Fraction = Fraction(0)):
        self.std: Fraction = standard
        self.inf: Fraction = infinitesimal

    def __add__(self, other: 'SurrealTruncated') -> 'SurrealTruncated':
        return SurrealTruncated(self.std + other.std, self.inf + other.inf)

    def __sub__(self, other: 'SurrealTruncated') -> 'SurrealTruncated':
        return SurrealTruncated(self.std - other.std, self.inf - other.inf)

    def __neg__(self) -> 'SurrealTruncated':
        return SurrealTruncated(-self.std, -self.inf)

    def __mul__(self, n: int) -> 'SurrealTruncated':
        return SurrealTruncated(self.std * n, self.inf * n)

    def __rmul__(self, n: int) -> 'SurrealTruncated':
        return self.__mul__(n)

    def __eq__(self, other: object) -> bool:
        if not isinstance(other, SurrealTruncated):
            return NotImplemented
        return self.std == other.std and self.inf == other.inf

    def __lt__(self, other: 'SurrealTruncated') -> bool:
        if self.std != other.std:
            return self.std < other.std
        return self.inf < other.inf

    def __le__(self, other: 'SurrealTruncated') -> bool:
        return self == other or self < other

    def __gt__(self, other: 'SurrealTruncated') -> bool:
        return other < self

    def __ge__(self, other: 'SurrealTruncated') -> bool:
        return other <= self

    def __repr__(self) -> str:
        parts: list[str] = []
        if self.std != 0:
            parts.append(str(self.std))
        if self.inf != 0:
            if self.inf == 1:
                parts.append("ε")
            elif self.inf == -1:
                parts.append("-ε")
            else:
                parts.append(f"({self.inf})ε")
        return " + ".join(parts) if parts else "0"

    def is_positive(self) -> bool:
        return self > SurrealTruncated()

    def is_infinitesimal(self) -> bool:
        return self.std == Fraction(0) and self.inf > 0

    def is_zero(self) -> bool:
        return self.std == Fraction(0) and self.inf == Fraction(0)


T = TypeVar('T')
ZERO_S = SurrealTruncated()
ONE_S = SurrealTruncated(Fraction(1))
EPSILON_S = SurrealTruncated(Fraction(0), Fraction(1))


# ============================================================
# Algorithm 1: Infinitesimal Measure Construction
# ============================================================


class FinitelyAdditiveMeasure:
    """
    A finitely additive measure on a finite set, valued in
    truncated surreal numbers.

    Implements the FinAddMeasure structure from the Lean formalization.
    """

    def __init__(self, universe: FrozenSet[int], point_mass: Dict[int, SurrealTruncated]):
        """
        Construct a finitely additive measure.

        Args:
            universe: The finite sample space
            point_mass: Assignment of mass to each point
        """
        self.universe = universe
        self.point_mass = point_mass

        # Verify non-negativity (mass_nonneg)
        for a, m in point_mass.items():
            assert m >= ZERO_S, f"Point mass at {a} is negative: {m}"

    def measure(self, S: FrozenSet[int]) -> SurrealTruncated:
        """
        Compute the measure of a set S.
        μ(S) = Σ_{a ∈ S} pointMass(a)
        """
        result = ZERO_S
        for a in S:
            if a in self.point_mass:
                result = result + self.point_mass[a]
        return result

    def total_mass(self) -> SurrealTruncated:
        """Compute the total mass μ(Ω)."""
        return self.measure(self.universe)

    @staticmethod
    def uniform(universe: FrozenSet[int], epsilon: SurrealTruncated) -> 'FinitelyAdditiveMeasure':
        """
        Construct a uniform measure assigning mass ε to each point.

        Implements FinAddMeasure.uniform from the Lean formalization.
        """
        assert epsilon >= ZERO_S, "Point mass must be non-negative"
        point_mass = {a: epsilon for a in universe}
        return FinitelyAdditiveMeasure(universe, point_mass)

    def verify_additivity(self, S: FrozenSet[int], T: FrozenSet[int]) -> bool:
        """
        Verify finite additivity for disjoint sets S and T.
        Returns True iff μ(S ∪ T) = μ(S) + μ(T).
        """
        if S & T:
            raise ValueError("Sets must be disjoint")
        return self.measure(S | T) == self.measure(S) + self.measure(T)

    def verify_complementation(self, S: FrozenSet[int]) -> bool:
        """
        Verify complementation identity: μ(S) + μ(Sᶜ) = μ(Ω).
        """
        complement = self.universe - S
        return self.measure(S) + self.measure(complement) == self.total_mass()

    def verify_monotonicity(self, S: FrozenSet[int], T: FrozenSet[int]) -> bool:
        """
        Verify monotonicity: S ⊆ T ⟹ μ(S) ≤ μ(T).
        """
        if not S.issubset(T):
            raise ValueError("S must be a subset of T")
        return self.measure(S) <= self.measure(T)


# ============================================================
# Algorithm 2: Archimedean Obstruction Check
# ============================================================


def check_archimedean_obstruction(epsilon: float, u: float, max_n: int = 10**6) -> Optional[int]:
    """
    Check the Archimedean obstruction: find n such that n * ε > u.

    In an Archimedean ordered group (like ℝ), such n always exists.
    Returns n if found within max_n steps, None otherwise.

    This implements the constructive content of Theorem 1
    (archimedean_no_infinitesimal).

    Args:
        epsilon: The candidate infinitesimal
        u: The reference unit
        max_n: Maximum n to check

    Returns:
        The smallest n with n * epsilon > u, or None
    """
    if epsilon <= 0:
        return None  # Not a valid infinitesimal candidate

    n = int(u / epsilon) + 1
    if n <= max_n:
        return n
    return None


# ============================================================
# Algorithm 3: Infinitesimal Classification
# ============================================================


def classify_infinitesimal(x: SurrealTruncated, u: SurrealTruncated) -> str:
    """
    Classify the relationship between x and u.

    Returns one of:
    - "zero": x = 0
    - "infinitesimal": x is infinitesimal relative to u
    - "comparable": x and u are of the same order
    - "infinite": x is infinite relative to u
    - "negative": x is not positive

    Implements the classification from our Infinitesimal definition.
    """
    if x.is_zero():
        return "zero"
    if not x.is_positive():
        return "negative"

    # In our truncated model, x is infinitesimal relative to u iff
    # x.std = 0 and u.std > 0 (or both are infinitesimal but x.inf < u.inf for all n)
    if x.std == 0 and u.std > 0:
        return "infinitesimal"
    if x.std > 0 and u.std == 0:
        return "infinite"
    return "comparable"


# ============================================================
# Algorithm 4: Measure Discrimination
# ============================================================


def discrimination_table(n: int, epsilon: SurrealTruncated) -> Dict[int, SurrealTruncated]:
    """
    Compute the measure discrimination table for Fin(n).

    For a uniform measure with mass ε on each of n points,
    compute the measure of every possible cardinality.

    This demonstrates Theorem 14 (uniform_discriminates):
    different cardinalities give different measures.

    Args:
        n: Size of the universe
        epsilon: Point mass

    Returns:
        Dictionary mapping cardinality k to measure k * ε
    """
    return {k: k * epsilon for k in range(n + 1)}


# ============================================================
# Algorithm 5: Anti-Cancellation Verification
# ============================================================


def verify_anti_cancellation(masses: List[SurrealTruncated]) -> Tuple[bool, str]:
    """
    Verify the anti-cancellation property (Theorem 11):
    if all masses are positive, total is positive.

    Args:
        masses: List of point masses

    Returns:
        (result, explanation) tuple
    """
    if not masses:
        return (True, "Empty measure has zero total (vacuously true)")

    all_positive = all(m.is_positive() for m in masses)
    total = ZERO_S
    for m in masses:
        total = total + m

    if all_positive:
        if total.is_positive():
            return (True, f"All positive, total = {total} > 0. Anti-cancellation holds.")
        else:
            return (False, f"VIOLATION: All positive but total = {total} ≤ 0!")
    else:
        return (True, f"Not all positive, anti-cancellation not applicable. Total = {total}")


# ============================================================
# Main: Run all algorithms
# ============================================================


if __name__ == "__main__":
    print("=" * 60)
    print("Algorithm 1: Infinitesimal Measure Construction")
    print("=" * 60)

    universe = frozenset(range(5))
    mu = FinitelyAdditiveMeasure.uniform(universe, EPSILON_S)

    print(f"Universe: {set(universe)}")
    print(f"Point mass: {EPSILON_S}")
    print(f"Total mass: {mu.total_mass()}")

    S = frozenset({0, 1})
    T = frozenset({2, 3, 4})
    print(f"\nS = {set(S)}, μ(S) = {mu.measure(S)}")
    print(f"T = {set(T)}, μ(T) = {mu.measure(T)}")
    print(f"Additivity: {mu.verify_additivity(S, T)}")
    print(f"Complementation for S: {mu.verify_complementation(S)}")
    print(f"Monotonicity S ⊆ universe: {mu.verify_monotonicity(S, universe)}")

    print("\n" + "=" * 60)
    print("Algorithm 2: Archimedean Obstruction Check")
    print("=" * 60)

    for eps in [0.1, 0.01, 0.001, 1e-10]:
        n = check_archimedean_obstruction(eps, 1.0)
        print(f"ε = {eps}: n = {n}, n·ε = {n * eps if n else 'N/A'}")

    print("\n" + "=" * 60)
    print("Algorithm 3: Infinitesimal Classification")
    print("=" * 60)

    cases = [
        (ZERO_S, ONE_S, "0 vs 1"),
        (EPSILON_S, ONE_S, "ε vs 1"),
        (ONE_S, EPSILON_S, "1 vs ε"),
        (3 * EPSILON_S, ONE_S, "3ε vs 1"),
        (SurrealTruncated(Fraction(1, 2)), ONE_S, "1/2 vs 1"),
    ]

    for x, u, label in cases:
        print(f"  {label}: {classify_infinitesimal(x, u)}")

    print("\n" + "=" * 60)
    print("Algorithm 4: Discrimination Table for Fin(5)")
    print("=" * 60)

    table = discrimination_table(5, EPSILON_S)
    for k, m in table.items():
        print(f"  |S| = {k}: μ(S) = {m}")
    print(f"  All distinct: {len(set(str(v) for v in table.values())) == len(table)}")

    print("\n" + "=" * 60)
    print("Algorithm 5: Anti-Cancellation Verification")
    print("=" * 60)

    test_cases = [
        [EPSILON_S, EPSILON_S, EPSILON_S],
        [EPSILON_S, 2 * EPSILON_S, 3 * EPSILON_S],
        [ONE_S, EPSILON_S],
    ]

    for masses in test_cases:
        result, explanation = verify_anti_cancellation(masses)
        print(f"  {explanation}")
