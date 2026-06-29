#!/usr/bin/env python3
"""
Neural Stone Duality — Core Algorithms

Type-hinted implementations of the key algorithms from the paper.
"""

from math import comb
from typing import FrozenSet, List, Optional, Set, Tuple
from dataclasses import dataclass
from enum import Enum


# ---------- Binomial Sum ----------

def binomial_sum(n: int, d: int) -> int:
    """
    Compute the binomial sum Φ(n, d) = Σ_{k=0}^{d} C(n, k).

    This quantity bounds:
    - The number of regions in a hyperplane arrangement (Zaslavsky)
    - The size of a VC-dimension-d set family (Sauer-Shelah)
    - The number of activation patterns of a neural layer

    Args:
        n: Number of hyperplanes / neurons / ground set size
        d: Dimension / VC dimension bound

    Returns:
        The partial sum of binomial coefficients
    """
    return sum(comb(n, k) for k in range(min(d, n) + 1))


def binomial_sum_pascal(n: int, d: int) -> Tuple[int, int, int]:
    """
    Verify Pascal's recurrence: Φ(n+1, d+1) = Φ(n, d+1) + Φ(n, d).

    Returns:
        (lhs, rhs_term1, rhs_term2) where lhs = rhs_term1 + rhs_term2
    """
    lhs = binomial_sum(n + 1, d + 1)
    t1 = binomial_sum(n, d + 1)
    t2 = binomial_sum(n, d)
    assert lhs == t1 + t2, f"Pascal failed: {lhs} != {t1} + {t2}"
    return lhs, t1, t2


# ---------- Activation Signatures ----------

@dataclass(frozen=True)
class ActivationSignature:
    """Boolean activation pattern for n neurons."""
    pattern: Tuple[bool, ...]

    @property
    def n_neurons(self) -> int:
        return len(self.pattern)

    def __repr__(self) -> str:
        bits = ''.join('1' if b else '0' for b in self.pattern)
        return f"Sig({bits})"


class TropicalActivation:
    """Tropical activation value: either inactive or active with magnitude."""

    class Kind(Enum):
        INACTIVE = 0
        ACTIVE = 1

    def __init__(self, kind: 'TropicalActivation.Kind', magnitude: float = 0.0):
        self.kind = kind
        self.magnitude = magnitude if kind == self.Kind.ACTIVE else 0.0

    @staticmethod
    def inactive() -> 'TropicalActivation':
        return TropicalActivation(TropicalActivation.Kind.INACTIVE)

    @staticmethod
    def active(magnitude: float) -> 'TropicalActivation':
        return TropicalActivation(TropicalActivation.Kind.ACTIVE, magnitude)

    def to_bool(self) -> bool:
        """Coarsen to Boolean: active -> True, inactive -> False."""
        return self.kind == self.Kind.ACTIVE

    @staticmethod
    def tmax(a: 'TropicalActivation', b: 'TropicalActivation') -> 'TropicalActivation':
        """Tropical maximum (idempotent, commutative, associative)."""
        if a.kind == TropicalActivation.Kind.INACTIVE:
            return b
        if b.kind == TropicalActivation.Kind.INACTIVE:
            return a
        return TropicalActivation.active(max(a.magnitude, b.magnitude))

    @staticmethod
    def tadd(a: 'TropicalActivation', b: 'TropicalActivation') -> 'TropicalActivation':
        """Tropical addition (absorbing inactive element)."""
        if a.kind == TropicalActivation.Kind.INACTIVE or b.kind == TropicalActivation.Kind.INACTIVE:
            return TropicalActivation.inactive()
        return TropicalActivation.active(a.magnitude + b.magnitude)

    def __repr__(self) -> str:
        if self.kind == self.Kind.INACTIVE:
            return "⊥"
        return f"↑{self.magnitude:.2f}"


@dataclass(frozen=True)
class TropicalSignature:
    """Tropical activation signature for n neurons."""
    values: Tuple[Tuple[str, float], ...]  # ('active', mag) or ('inactive', 0)

    def to_bool(self) -> ActivationSignature:
        """Coarsen to Boolean signature."""
        return ActivationSignature(
            tuple(v[0] == 'active' for v in self.values)
        )


# ---------- Set Families and VC Dimension ----------

SetFamilyType = Set[FrozenSet[int]]


def trace(family: SetFamilyType, subset: FrozenSet[int]) -> SetFamilyType:
    """
    Compute the trace (restriction) of a set family to a subset.
    trace(F, S) = {A ∩ S : A ∈ F}
    """
    return {A & subset for A in family}


def shatters(family: SetFamilyType, subset: FrozenSet[int]) -> bool:
    """
    Check if a set family shatters a subset.
    F shatters S iff trace(F, S) = P(S) (all subsets of S appear).
    """
    tr = trace(family, subset)
    # Check if all subsets of `subset` appear in the trace
    elements = list(subset)
    n = len(elements)
    for mask in range(1 << n):
        sub = frozenset(elements[i] for i in range(n) if mask & (1 << i))
        if sub not in tr:
            return False
    return True


def vc_dimension(family: SetFamilyType, ground_size: int) -> int:
    """
    Compute the VC dimension of a set family on ground set [ground_size].
    VC(F) = max{|S| : F shatters S}.
    """
    best = 0
    for size in range(ground_size + 1):
        found = False
        for subset in _subsets_of_size(ground_size, size):
            if shatters(family, subset):
                found = True
                best = size
                break
        if not found and size > best:
            break
    return best


def _subsets_of_size(n: int, k: int):
    """Generate all k-element subsets of {0, ..., n-1}."""
    if k == 0:
        yield frozenset()
        return
    if k > n:
        return
    from itertools import combinations
    for combo in combinations(range(n), k):
        yield frozenset(combo)


def verify_sauer_shelah(family: SetFamilyType, ground_size: int) -> Tuple[int, int, int, bool]:
    """
    Verify the Sauer-Shelah bound for a specific family.

    Returns:
        (|F|, VC(F), Φ(n, VC(F)), bound_holds)
    """
    d = vc_dimension(family, ground_size)
    bound = binomial_sum(ground_size, d)
    return len(family), d, bound, len(family) <= bound


# ---------- Region Counting ----------

def count_relu_regions(
    weights: List[List[float]],
    biases: List[float],
    grid_points: List[List[float]]
) -> Tuple[int, List[ActivationSignature]]:
    """
    Count distinct activation regions of a single ReLU layer.

    Args:
        weights: n_neurons × input_dim weight matrix
        biases: n_neurons bias vector
        grid_points: List of input points to evaluate

    Returns:
        (count, list of distinct signatures)
    """
    import numpy as np
    W = np.array(weights)
    b = np.array(biases)

    signatures: Set[Tuple[bool, ...]] = set()
    for x in grid_points:
        pre = W @ np.array(x) + b
        sig = tuple(p > 0 for p in pre)
        signatures.add(sig)

    return len(signatures), [ActivationSignature(s) for s in signatures]


def multi_layer_region_bound(width: int, depth: int) -> int:
    """
    Compute the multi-layer region count bound: (2w)^L.

    Args:
        width: Number of neurons per layer
        depth: Number of layers

    Returns:
        Upper bound on the number of distinct activation patterns
    """
    return (2 * width) ** depth


# ---------- Refinement ----------

def refinement_bound(m1: int, m2: int) -> int:
    """
    Compute the refinement bound for composing two layers.
    The composite has at most m1 * m2 regions.
    """
    return m1 * m2


if __name__ == "__main__":
    # Quick self-test
    print("Testing binomial_sum...")
    assert binomial_sum(5, 0) == 1
    assert binomial_sum(5, 5) == 32
    assert binomial_sum(5, 2) == 1 + 5 + 10  # 16

    print("Testing Pascal recurrence...")
    for n in range(7):
        for d in range(7):
            binomial_sum_pascal(n, d)

    print("Testing VC dimension...")
    F: SetFamilyType = {frozenset(), frozenset({0}), frozenset({1}), frozenset({0, 1})}
    assert vc_dimension(F, 3) == 2  # shatters {0,1}

    F_vc0: SetFamilyType = {frozenset({0, 2})}
    assert vc_dimension(F_vc0, 4) == 0

    print("Testing Sauer-Shelah verification...")
    size, vc, bound, holds = verify_sauer_shelah(F, 3)
    print(f"  |F|={size}, VC={vc}, Φ(3,{vc})={bound}, holds={holds}")
    assert holds

    print("All tests passed! ✓")
