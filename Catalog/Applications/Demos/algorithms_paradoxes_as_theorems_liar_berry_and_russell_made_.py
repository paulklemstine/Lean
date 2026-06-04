"""
Algorithms for Coherent Paradox Systems

Type-hinted implementations of the key algorithms from the research paper.
"""

from enum import Enum
from typing import List, Set, Tuple, Optional, Dict
from dataclasses import dataclass


class TruthVal(Enum):
    """Belnap four-valued truth value."""
    T = "T"
    F = "F"
    B = "B"
    N = "N"


# Truth tables
NEG_TABLE: Dict[TruthVal, TruthVal] = {
    TruthVal.T: TruthVal.F,
    TruthVal.F: TruthVal.T,
    TruthVal.B: TruthVal.B,
    TruthVal.N: TruthVal.N,
}

CONJ_TABLE: Dict[Tuple[TruthVal, TruthVal], TruthVal] = {
    (TruthVal.T, TruthVal.T): TruthVal.T,
    (TruthVal.T, TruthVal.F): TruthVal.F,
    (TruthVal.T, TruthVal.B): TruthVal.B,
    (TruthVal.T, TruthVal.N): TruthVal.N,
    (TruthVal.F, TruthVal.T): TruthVal.F,
    (TruthVal.F, TruthVal.F): TruthVal.F,
    (TruthVal.F, TruthVal.B): TruthVal.F,
    (TruthVal.F, TruthVal.N): TruthVal.F,
    (TruthVal.B, TruthVal.T): TruthVal.B,
    (TruthVal.B, TruthVal.F): TruthVal.F,
    (TruthVal.B, TruthVal.B): TruthVal.B,
    (TruthVal.B, TruthVal.N): TruthVal.F,
    (TruthVal.N, TruthVal.T): TruthVal.N,
    (TruthVal.N, TruthVal.F): TruthVal.F,
    (TruthVal.N, TruthVal.B): TruthVal.F,
    (TruthVal.N, TruthVal.N): TruthVal.N,
}


def neg(v: TruthVal) -> TruthVal:
    """Belnap negation."""
    return NEG_TABLE[v]


def is_true(v: TruthVal) -> bool:
    """At-least-true predicate."""
    return v in (TruthVal.T, TruthVal.B)


def is_false(v: TruthVal) -> bool:
    """At-least-false predicate."""
    return v in (TruthVal.F, TruthVal.B)


def is_neg_fixed_point(v: TruthVal) -> bool:
    """Check if v is a fixed point of negation (paradox-enabling)."""
    return neg(v) == v


@dataclass
class CPSConfig:
    """Configuration for a Coherent Paradox System."""
    n: int
    truth_assignment: List[TruthVal]
    liar_index: int

    def validate(self) -> bool:
        """Validate CPS axioms."""
        if len(self.truth_assignment) != self.n:
            return False
        if self.n < 3:
            return False
        if self.truth_assignment[self.liar_index] != TruthVal.B:
            return False
        if not any(v == TruthVal.T for v in self.truth_assignment):
            return False
        if not any(v == TruthVal.F for v in self.truth_assignment):
            return False
        return True


def construct_cps(n: int, k: int) -> Optional[CPSConfig]:
    """
    Construct a CPS on n sentences with k dialetheias.

    Algorithm:
    1. Assign B to sentences 0, ..., k-1
    2. Assign T to sentence k
    3. Assign F to sentence k+1
    4. Assign N to remaining sentences

    Returns None if constraints are violated (k < 1 or k > n-2 or n < 3).

    Time complexity: O(n)
    Space complexity: O(n)
    """
    if n < 3 or k < 1 or k > n - 2:
        return None

    truth = ([TruthVal.B] * k +
             [TruthVal.T] +
             [TruthVal.F] +
             [TruthVal.N] * (n - k - 2))

    config = CPSConfig(n=n, truth_assignment=truth, liar_index=0)
    assert config.validate()
    return config


def verify_self_soundness(config: CPSConfig, provable: Set[int]) -> bool:
    """
    Verify self-soundness: all provable sentences must be at-least-true.

    Time complexity: O(|provable|)
    """
    return all(is_true(config.truth_assignment[i]) for i in provable)


def max_sound_provable_set(config: CPSConfig) -> Set[int]:
    """
    Compute the maximal sound provable set (all T ∨ B sentences).

    Time complexity: O(n)
    """
    return {i for i in range(config.n)
            if is_true(config.truth_assignment[i])}


def compute_degrees(config: CPSConfig) -> Dict[str, int]:
    """
    Compute the four degree functions.

    Time complexity: O(n)
    """
    return {
        "dialectheia": sum(1 for v in config.truth_assignment if v == TruthVal.B),
        "true": sum(1 for v in config.truth_assignment if v == TruthVal.T),
        "false": sum(1 for v in config.truth_assignment if v == TruthVal.F),
        "gap": sum(1 for v in config.truth_assignment if v == TruthVal.N),
    }


def verify_value_partition(config: CPSConfig) -> bool:
    """
    Verify the value partition theorem: all degrees sum to n.

    Time complexity: O(n)
    """
    degrees = compute_degrees(config)
    return sum(degrees.values()) == config.n


def verify_paradox_soundness_duality(config: CPSConfig) -> bool:
    """
    Verify the paradox-soundness duality:
    |max sound provable set| = trueDegree + dialetheiaDegree.

    Time complexity: O(n)
    """
    degrees = compute_degrees(config)
    max_provable = max_sound_provable_set(config)
    return len(max_provable) == degrees["true"] + degrees["dialectheia"]


def classify_sentence(v: TruthVal) -> str:
    """Classify a sentence by its truth value."""
    classifications = {
        TruthVal.T: "purely true",
        TruthVal.F: "purely false",
        TruthVal.B: "dialetheia (both true and false)",
        TruthVal.N: "gap (neither true nor false)",
    }
    return classifications[v]


def find_negation_fixed_points() -> List[TruthVal]:
    """
    Find all negation fixed points in the four-valued logic.
    These are the paradox-enabling truth values.

    Time complexity: O(1)
    """
    return [v for v in TruthVal if is_neg_fixed_point(v)]


# Verification
if __name__ == "__main__":
    # Test CPS construction
    for n in range(3, 10):
        for k in range(1, n - 1):
            config = construct_cps(n, k)
            assert config is not None
            assert config.validate()
            degrees = compute_degrees(config)
            assert degrees["dialectheia"] == k
            assert verify_value_partition(config)
            assert verify_paradox_soundness_duality(config)

    print("All algorithm tests passed!")

    # Show fixed points
    fps = find_negation_fixed_points()
    print(f"Negation fixed points: {[v.value for v in fps]}")
