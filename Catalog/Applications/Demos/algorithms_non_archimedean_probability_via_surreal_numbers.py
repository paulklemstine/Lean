#!/usr/bin/env python3
"""
Algorithms for Non-Archimedean Probability Theory

Type-hinted implementations of the core algorithms used in
infinitesimal probability spaces.
"""

from fractions import Fraction
from typing import Dict, FrozenSet, Generic, List, Set, Tuple, TypeVar

T = TypeVar('T')


class InfNum:
    """Element of ℚ(ε): a + b·ε where ε is infinitesimal.

    Represents elements of a simple non-Archimedean extension of ℚ.
    Arithmetic is exact (using Fraction) to first order in ε.
    """

    __slots__ = ('std', 'inf')

    def __init__(self, std: Fraction = Fraction(0),
                 inf: Fraction = Fraction(0)):
        self.std = Fraction(std)
        self.inf = Fraction(inf)

    @staticmethod
    def from_int(n: int) -> 'InfNum':
        return InfNum(Fraction(n))

    @staticmethod
    def epsilon(coeff: int = 1) -> 'InfNum':
        return InfNum(Fraction(0), Fraction(coeff))

    def __add__(self, other: 'InfNum') -> 'InfNum':
        return InfNum(self.std + other.std, self.inf + other.inf)

    def __sub__(self, other: 'InfNum') -> 'InfNum':
        return InfNum(self.std - other.std, self.inf - other.inf)

    def __mul__(self, other: 'InfNum') -> 'InfNum':
        return InfNum(
            self.std * other.std,
            self.std * other.inf + self.inf * other.std
        )

    def __truediv__(self, other: 'InfNum') -> 'InfNum':
        if other.std == 0:
            raise ZeroDivisionError("Cannot divide by pure infinitesimal")
        inv = Fraction(1) / other.std
        return InfNum(
            self.std * inv,
            (self.inf * other.std - self.std * other.inf) * inv * inv
        )

    def __neg__(self) -> 'InfNum':
        return InfNum(-self.std, -self.inf)

    def __eq__(self, other: object) -> bool:
        if isinstance(other, InfNum):
            return self.std == other.std and self.inf == other.inf
        if isinstance(other, (int, Fraction)):
            return self.std == Fraction(other) and self.inf == 0
        return NotImplemented

    def __repr__(self) -> str:
        parts = []
        if self.std != 0:
            parts.append(str(self.std))
        if self.inf != 0:
            if self.inf == 1:
                parts.append("ε")
            elif self.inf == -1:
                parts.append("-ε")
            else:
                parts.append(f"{self.inf}ε")
        return " + ".join(parts) if parts else "0"

    def is_positive(self) -> bool:
        """Check if this number is positive in the non-Archimedean order."""
        return self.std > 0 or (self.std == 0 and self.inf > 0)

    def is_infinitesimal(self) -> bool:
        """Check if this number is infinitesimal (positive but smaller than all 1/n)."""
        return self.std == 0 and self.inf > 0

    def standard_part(self) -> Fraction:
        """Return the standard part (dropping infinitesimal terms)."""
        return self.std


def make_uniform_inf_prob_space(
    n: int,
    perturbations: Dict[int, Fraction] | None = None
) -> Dict[int, InfNum]:
    """
    Algorithm: Construct Uniform InfProbSpace on {0, ..., n-1}

    Pseudocode:
        INPUT: n ≥ 1, optional perturbations pᵢ with ∑pᵢ = 0
        OUTPUT: weights w[i] for i = 0..n-1
        FOR i = 0 TO n-1:
            w[i] = 1/n + pᵢ · ε
        VERIFY: sum(w[i]) = 1 and all w[i] > 0

    Args:
        n: Number of elements
        perturbations: Optional dict mapping element index to
            perturbation coefficient. Must sum to 0.
    Returns:
        Dict mapping element index to its InfNum weight.
    """
    if n <= 0:
        raise ValueError("n must be positive")

    base = Fraction(1, n)
    weights: Dict[int, InfNum] = {}

    if perturbations is None:
        perturbations = {}

    # Verify perturbations sum to 0
    total_pert = sum(perturbations.values(), Fraction(0))
    if total_pert != 0:
        raise ValueError(f"Perturbations must sum to 0, got {total_pert}")

    for i in range(n):
        p = perturbations.get(i, Fraction(0))
        weights[i] = InfNum(base, p)

    return weights


def compute_conditional_probability(
    weights: Dict[int, InfNum],
    event_a: Set[int],
    event_b: Set[int]
) -> InfNum:
    """
    Algorithm: Conditional Probability P(A | B)

    Pseudocode:
        INPUT: weights w, events A, B
        OUTPUT: P(A|B) = P(A∩B) / P(B)
        p_intersection = sum(w[i] for i in A ∩ B)
        p_b = sum(w[i] for i in B)
        RETURN p_intersection / p_b

    Args:
        weights: Probability weights for each element
        event_a: Set of elements in event A
        event_b: Set of elements in event B (must have positive probability)
    Returns:
        P(A | B) as an InfNum
    """
    intersection = event_a & event_b

    p_ab = InfNum.from_int(0)
    for i in intersection:
        p_ab = p_ab + weights[i]

    p_b = InfNum.from_int(0)
    for i in event_b:
        p_b = p_b + weights[i]

    return p_ab / p_b


def inclusion_exclusion(
    weights: Dict[int, InfNum],
    event_a: Set[int],
    event_b: Set[int]
) -> Tuple[InfNum, InfNum, InfNum]:
    """
    Algorithm: Inclusion-Exclusion for Two Sets

    Pseudocode:
        INPUT: weights w, events A, B
        OUTPUT: (P(A∪B), P(A), P(B), P(A∩B))
        P(A∪B) = P(A) + P(B) - P(A∩B)

    Returns:
        Tuple of (P(A∪B), P(A∩B), verification_value)
        where verification_value should equal P(A∪B)
    """
    p_a = InfNum.from_int(0)
    for i in event_a:
        p_a = p_a + weights[i]

    p_b = InfNum.from_int(0)
    for i in event_b:
        p_b = p_b + weights[i]

    p_ab = InfNum.from_int(0)
    for i in event_a & event_b:
        p_ab = p_ab + weights[i]

    p_union = InfNum.from_int(0)
    for i in event_a | event_b:
        p_union = p_union + weights[i]

    # Verify inclusion-exclusion
    computed = p_a + p_b - p_ab
    assert p_union == computed, \
        f"Inclusion-exclusion failed: {p_union} ≠ {computed}"

    return p_union, p_ab, computed


def archimedean_impossibility_witness(c: Fraction) -> int:
    """
    Algorithm: Find Archimedean Impossibility Witness

    Pseudocode:
        INPUT: c > 0 (rational)
        OUTPUT: N such that N · c > 1
        N = ceil(1/c) + 1
        VERIFY: N · c > 1

    Given a positive rational c, returns N such that N·c > 1.
    This demonstrates that no Archimedean field can assign
    equal weight c to infinitely many elements.
    """
    if c <= 0:
        raise ValueError("c must be positive")

    n = int(1 / c) + 1
    assert Fraction(n) * c > 1, f"{n} * {c} = {Fraction(n) * c} ≤ 1"
    return n


def product_measure(
    weights1: Dict[int, InfNum],
    weights2: Dict[int, InfNum]
) -> Dict[Tuple[int, int], InfNum]:
    """
    Algorithm: Product Measure Construction

    Pseudocode:
        INPUT: weights w₁ on Ω₁, weights w₂ on Ω₂
        OUTPUT: product weights on Ω₁ × Ω₂
        FOR (a, b) in Ω₁ × Ω₂:
            w[(a,b)] = w₁[a] · w₂[b]

    Constructs the product measure on the Cartesian product space.
    """
    result: Dict[Tuple[int, int], InfNum] = {}
    for a, wa in weights1.items():
        for b, wb in weights2.items():
            result[(a, b)] = wa * wb
    return result


if __name__ == "__main__":
    # Test: uniform space
    w = make_uniform_inf_prob_space(4)
    print("Uniform space on {0,1,2,3}:")
    for k, v in w.items():
        print(f"  w[{k}] = {v}")

    # Test: perturbed space
    w = make_uniform_inf_prob_space(3, {0: Fraction(1), 1: Fraction(0), 2: Fraction(-1)})
    print("\nPerturbed space on {0,1,2}:")
    for k, v in w.items():
        print(f"  w[{k}] = {v}")

    # Test: conditional probability
    p = compute_conditional_probability(w, {0, 1}, {0, 2})
    print(f"\nP({{0,1}} | {{0,2}}) = {p}")

    # Test: Archimedean witness
    N = archimedean_impossibility_witness(Fraction(1, 100))
    print(f"\nArchimedean witness for c=1/100: N = {N}")
    print(f"  {N} * 1/100 = {Fraction(N, 100)} > 1 ✓")

    # Test: product measure
    w1 = make_uniform_inf_prob_space(2)
    w2 = make_uniform_inf_prob_space(2)
    prod = product_measure(w1, w2)
    print(f"\nProduct space on {{0,1}} × {{0,1}}:")
    total = InfNum.from_int(0)
    for k, v in sorted(prod.items()):
        print(f"  w[{k}] = {v}")
        total = total + v
    print(f"Total = {total}")
