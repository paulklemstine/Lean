#!/usr/bin/env python3
"""
Algorithms for Algebraic Graded Tower Theory

Type-hinted implementations of the core algorithms for computing
tower invariants, defect sequences, and checking structural properties.
"""

from typing import List, Tuple, Set, Optional, Callable
from dataclasses import dataclass
from math import gcd
from functools import reduce


def divisors(n: int) -> List[int]:
    """Compute all positive divisors of n in ascending order.

    Time complexity: O(sqrt(n))
    """
    if n <= 0:
        return []
    small: List[int] = []
    large: List[int] = []
    i = 1
    while i * i <= n:
        if n % i == 0:
            small.append(i)
            if i != n // i:
                large.append(n // i)
        i += 1
    return small + large[::-1]


@dataclass
class TowerLevel:
    """Represents a single level in an algebraic graded tower."""
    cardinality: int
    group_name: str = "Unknown"


@dataclass
class TowerTransition:
    """Represents a transition between consecutive tower levels."""
    domain_card: int
    codomain_card: int
    kernel_card: int
    image_card: int

    @property
    def defect(self) -> int:
        """The defect: card(codomain) - card(image)."""
        return self.codomain_card - self.image_card

    @property
    def index(self) -> int:
        """The index [codomain : image]."""
        return self.codomain_card // self.image_card

    @property
    def is_injective(self) -> bool:
        """Whether the transition is injective (trivial kernel)."""
        return self.kernel_card == 1

    @property
    def is_surjective(self) -> bool:
        """Whether the transition is surjective (zero defect)."""
        return self.defect == 0

    @property
    def is_bijective(self) -> bool:
        """Whether the transition is bijective."""
        return self.is_injective and self.is_surjective


class AlgebraicGradedTower:
    """
    An algebraic graded tower: a sequence of finite groups connected
    by group homomorphisms.

    Implements the computation of all tower invariants and verification
    of the structural theorems.
    """

    def __init__(self, levels: List[TowerLevel], transitions: List[TowerTransition]):
        """Initialize tower from levels and transitions.

        Args:
            levels: List of TowerLevel objects (length n+1)
            transitions: List of TowerTransition objects (length n)
        """
        if len(transitions) != len(levels) - 1:
            raise ValueError("Need exactly len(levels)-1 transitions")
        self.levels = levels
        self.transitions = transitions
        self._validate()

    def _validate(self) -> None:
        """Validate the kernel-range factorization at each level."""
        for i, t in enumerate(self.transitions):
            # Check kernel-range factorization
            if t.domain_card != t.kernel_card * t.image_card:
                raise ValueError(
                    f"Level {i}: kernel-range factorization fails: "
                    f"{t.domain_card} != {t.kernel_card} * {t.image_card}"
                )
            # Check Lagrange divisibility
            if t.codomain_card % t.image_card != 0:
                raise ValueError(
                    f"Level {i}: Lagrange violation: "
                    f"{t.image_card} does not divide {t.codomain_card}"
                )

    @property
    def height(self) -> int:
        """The height n of the tower (number of transitions)."""
        return len(self.transitions)

    def defect_sequence(self) -> List[int]:
        """Compute the defect sequence [defect(0), ..., defect(n-1)]."""
        return [t.defect for t in self.transitions]

    def kernel_sequence(self) -> List[int]:
        """Compute the kernel cardinality sequence."""
        return [t.kernel_card for t in self.transitions]

    def index_sequence(self) -> List[int]:
        """Compute the index sequence [index(0), ..., index(n-1)]."""
        return [t.index for t in self.transitions]

    def cardinality_sequence(self) -> List[int]:
        """Compute the level cardinality sequence."""
        return [l.cardinality for l in self.levels]

    def is_injective_tower(self) -> bool:
        """Check if all transitions are injective."""
        return all(t.is_injective for t in self.transitions)

    def is_surjective_tower(self) -> bool:
        """Check if all transitions are surjective."""
        return all(t.is_surjective for t in self.transitions)

    def is_exact_tower(self) -> bool:
        """Check if all transitions are bijective."""
        return all(t.is_bijective for t in self.transitions)

    def verify_defect_index_identity(self) -> List[bool]:
        """Verify defect = (index - 1) * image_card at each level."""
        results = []
        for t in self.transitions:
            expected = (t.index - 1) * t.image_card
            results.append(t.defect == expected)
        return results

    def verify_defect_quantization(self) -> List[bool]:
        """Verify that defect = codomain_card - d for some d | codomain_card."""
        results = []
        for t in self.transitions:
            d = t.image_card
            ok = (t.codomain_card % d == 0) and (t.defect == t.codomain_card - d)
            results.append(ok)
        return results

    def achievable_defects_at(self, i: int) -> Set[int]:
        """Compute achievable defects at level i based on codomain order."""
        cod_card = self.levels[i + 1].cardinality
        return {cod_card - d for d in divisors(cod_card)}


def compute_achievable_defect_spectrum(group_order: int) -> List[int]:
    """
    Compute the sorted list of achievable defect values for a group tower
    level with codomain of given order.

    By the Defect Quantization Theorem:
        achievable defects = {group_order - d : d | group_order}

    Algorithm:
        1. Enumerate all divisors d of group_order
        2. Compute group_order - d for each
        3. Sort and return

    Time complexity: O(sqrt(group_order))
    """
    return sorted(group_order - d for d in divisors(group_order))


def check_injective_tower_feasibility(cardinalities: List[int]) -> Tuple[bool, Optional[int]]:
    """
    Check whether a cardinality sequence is feasible for an injective
    algebraic tower (i.e., each card divides the next).

    Returns (feasible, first_failing_index or None).

    Algorithm:
        For each consecutive pair, check divisibility.

    Time complexity: O(n) where n = len(cardinalities) - 1
    """
    for i in range(len(cardinalities) - 1):
        if cardinalities[i + 1] % cardinalities[i] != 0:
            return False, i
    return True, None


def check_surjective_tower_feasibility(cardinalities: List[int]) -> Tuple[bool, Optional[int]]:
    """
    Check whether a cardinality sequence is feasible for a surjective
    algebraic tower (i.e., each card divides the previous).

    Returns (feasible, first_failing_index or None).
    """
    for i in range(len(cardinalities) - 1):
        if cardinalities[i] % cardinalities[i + 1] != 0:
            return False, i
    return True, None


def check_prime_tower_rigidity(cardinalities: List[int]) -> Tuple[bool, str]:
    """
    Check the Prime Tower Rigidity Theorem conditions.

    If all cardinalities are prime and the tower is injective,
    all cardinalities must be equal.

    Returns (is_rigid, explanation).
    """
    def is_prime(n: int) -> bool:
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

    all_prime = all(is_prime(c) for c in cardinalities)
    if not all_prime:
        non_prime = [c for c in cardinalities if not is_prime(c)]
        return False, f"Not all prime. Non-prime values: {non_prime}"

    feasible, _ = check_injective_tower_feasibility(cardinalities)
    if not feasible:
        return True, "All prime but divisibility fails — no injective tower exists"

    all_equal = len(set(cardinalities)) == 1
    if all_equal:
        return True, f"All levels have cardinality {cardinalities[0]} — tower is trivially exact"
    else:
        return True, "CONTRADICTION: all prime, divisibility holds, but not all equal (impossible)"


def build_symmetric_group_tower(max_n: int) -> AlgebraicGradedTower:
    """
    Build the symmetric group tower S_1 -> S_2 -> ... -> S_max_n
    with natural embeddings (injective).

    Card(S_k) = k!, kernel at each level is trivial.
    """
    from math import factorial

    levels = [TowerLevel(factorial(k), f"S_{k}") for k in range(1, max_n + 1)]
    transitions = []
    for i in range(len(levels) - 1):
        dom = levels[i].cardinality
        cod = levels[i + 1].cardinality
        transitions.append(TowerTransition(
            domain_card=dom,
            codomain_card=cod,
            kernel_card=1,  # injective
            image_card=dom   # by kernel-range factorization
        ))

    return AlgebraicGradedTower(levels, transitions)


if __name__ == "__main__":
    # Example: Symmetric group tower
    tower = build_symmetric_group_tower(6)
    print("Symmetric Group Tower S_1 -> S_2 -> ... -> S_6")
    print(f"  Cardinalities: {tower.cardinality_sequence()}")
    print(f"  Defect sequence: {tower.defect_sequence()}")
    print(f"  Index sequence: {tower.index_sequence()}")
    print(f"  Injective: {tower.is_injective_tower()}")
    print(f"  Defect-Index Identity: {tower.verify_defect_index_identity()}")
    print(f"  Defect Quantization: {tower.verify_defect_quantization()}")

    # Achievable defect spectrum
    print("\nAchievable Defect Spectra:")
    for n in [6, 12, 24, 60]:
        spectrum = compute_achievable_defect_spectrum(n)
        print(f"  Order {n}: {spectrum}")

    # Prime tower rigidity
    print("\nPrime Tower Rigidity Check:")
    for cards in [[5,5,5], [3,5,7], [7,7,7,7], [2,3,5]]:
        is_rigid, explanation = check_prime_tower_rigidity(cards)
        print(f"  {cards}: {explanation}")
