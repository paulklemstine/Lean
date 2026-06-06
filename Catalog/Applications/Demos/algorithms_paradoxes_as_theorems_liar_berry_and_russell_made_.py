#!/usr/bin/env python3
"""
Algorithms for Dialectical Algebra computations.

Type-hinted implementations of the core algorithms from the research:
1. Belnap bilattice operations
2. Dialectical rank computation
3. Paradox spectrum analysis
4. Product decomposition
5. Theory classification
"""

from enum import Enum
from typing import List, Tuple, Dict, Set, Optional
from dataclasses import dataclass


class BVal(Enum):
    """Belnap's four truth values."""
    T = "T"  # True only
    F = "F"  # False only
    B = "B"  # Both true and false
    N = "N"  # Neither true nor false

    def is_true(self) -> bool:
        return self in (BVal.T, BVal.B)

    def is_false(self) -> bool:
        return self in (BVal.F, BVal.B)

    def neg(self) -> 'BVal':
        _neg_map = {BVal.T: BVal.F, BVal.F: BVal.T, BVal.B: BVal.B, BVal.N: BVal.N}
        return _neg_map[self]

    def is_fixpoint(self) -> bool:
        return self.neg() == self

    def dialectical_rank(self) -> int:
        return 1 if self.is_fixpoint() else 0

    def to_bool_pair(self) -> Tuple[bool, bool]:
        _map = {BVal.T: (True, False), BVal.F: (False, True),
                BVal.B: (True, True), BVal.N: (False, False)}
        return _map[self]

    @staticmethod
    def from_bool_pair(p: Tuple[bool, bool]) -> 'BVal':
        _map = {(True, False): BVal.T, (False, True): BVal.F,
                (True, True): BVal.B, (False, False): BVal.N}
        return _map[p]


# --- Lattice Operations ---

def truth_le(a: BVal, b: BVal) -> bool:
    """Truth partial order: F ≤ N,B ≤ T."""
    if a == BVal.F or b == BVal.T:
        return True
    return a == b

def know_le(a: BVal, b: BVal) -> bool:
    """Knowledge partial order: N ≤ T,F ≤ B."""
    if a == BVal.N or b == BVal.B:
        return True
    return a == b

def k_meet(a: BVal, b: BVal) -> BVal:
    """Knowledge meet (consensus): componentwise AND on Bool × Bool."""
    pa, pb = a.to_bool_pair(), b.to_bool_pair()
    return BVal.from_bool_pair((pa[0] and pb[0], pa[1] and pb[1]))

def k_join(a: BVal, b: BVal) -> BVal:
    """Knowledge join (gullibility): componentwise OR on Bool × Bool."""
    pa, pb = a.to_bool_pair(), b.to_bool_pair()
    return BVal.from_bool_pair((pa[0] or pb[0], pa[1] or pb[1]))

def t_meet(a: BVal, b: BVal) -> BVal:
    """Truth meet (conjunction)."""
    table: Dict[Tuple[BVal, BVal], BVal] = {
        (BVal.T, BVal.T): BVal.T, (BVal.T, BVal.F): BVal.F,
        (BVal.T, BVal.B): BVal.B, (BVal.T, BVal.N): BVal.N,
        (BVal.F, BVal.T): BVal.F, (BVal.F, BVal.F): BVal.F,
        (BVal.F, BVal.B): BVal.F, (BVal.F, BVal.N): BVal.F,
        (BVal.B, BVal.T): BVal.B, (BVal.B, BVal.F): BVal.F,
        (BVal.B, BVal.B): BVal.B, (BVal.B, BVal.N): BVal.F,
        (BVal.N, BVal.T): BVal.N, (BVal.N, BVal.F): BVal.F,
        (BVal.N, BVal.B): BVal.F, (BVal.N, BVal.N): BVal.N,
    }
    return table[(a, b)]

def t_join(a: BVal, b: BVal) -> BVal:
    """Truth join (disjunction)."""
    table: Dict[Tuple[BVal, BVal], BVal] = {
        (BVal.T, BVal.T): BVal.T, (BVal.T, BVal.F): BVal.T,
        (BVal.T, BVal.B): BVal.T, (BVal.T, BVal.N): BVal.T,
        (BVal.F, BVal.T): BVal.T, (BVal.F, BVal.F): BVal.F,
        (BVal.F, BVal.B): BVal.B, (BVal.F, BVal.N): BVal.N,
        (BVal.B, BVal.T): BVal.T, (BVal.B, BVal.F): BVal.B,
        (BVal.B, BVal.B): BVal.B, (BVal.B, BVal.N): BVal.T,
        (BVal.N, BVal.T): BVal.T, (BVal.N, BVal.F): BVal.N,
        (BVal.N, BVal.B): BVal.T, (BVal.N, BVal.N): BVal.N,
    }
    return table[(a, b)]


# --- Theory Analysis ---

@dataclass
class ParadoxSpectrum:
    """The distribution of truth values in a theory."""
    n_true: int
    n_false: int
    n_both: int
    n_neither: int

    @property
    def total(self) -> int:
        return self.n_true + self.n_false + self.n_both + self.n_neither

    @property
    def dialectical_rank(self) -> int:
        return self.n_both + self.n_neither

    @property
    def is_classical(self) -> bool:
        return self.dialectical_rank == 0

    @property
    def is_nontrivial(self) -> bool:
        return self.n_true > 0 and self.n_false > 0


def compute_spectrum(truth: List[BVal]) -> ParadoxSpectrum:
    """Compute the paradox spectrum of a theory.

    Time complexity: O(n) where n = len(truth).
    """
    counts = {BVal.T: 0, BVal.F: 0, BVal.B: 0, BVal.N: 0}
    for v in truth:
        counts[v] += 1
    return ParadoxSpectrum(
        n_true=counts[BVal.T], n_false=counts[BVal.F],
        n_both=counts[BVal.B], n_neither=counts[BVal.N]
    )


def dialectical_rank(truth: List[BVal]) -> int:
    """Compute the dialectical rank of a theory.

    The rank equals the number of paradoxical (fixpoint-valued) sentences.
    Time complexity: O(n).
    """
    return sum(1 for v in truth if v.is_fixpoint())


def is_self_sound(truth: List[BVal], provable: Set[int]) -> bool:
    """Check if a theory is self-sound: provable → at-least-true.

    Time complexity: O(|provable|).
    """
    return all(truth[i].is_true() for i in provable)


def find_independent_paradoxes(truth: List[BVal]) -> List[Tuple[int, int]]:
    """Find all pairs of independent paradoxical sentences.

    Two paradoxical sentences are independent iff they have different
    fixpoint values (one B, one N).
    Time complexity: O(n²).
    """
    b_indices = [i for i, v in enumerate(truth) if v == BVal.B]
    n_indices = [i for i, v in enumerate(truth) if v == BVal.N]
    return [(i, j) for i in b_indices for j in n_indices]


def verify_fixpoint_sublattice() -> bool:
    """Verify the fixpoint sublattice theorem computationally.

    Check that kMeet and kJoin of fixpoints are fixpoints,
    but tMeet and tJoin of fixpoints may not be.
    """
    fixpoints = [v for v in BVal if v.is_fixpoint()]
    # Check knowledge closure
    for a in fixpoints:
        for b in fixpoints:
            km = k_meet(a, b)
            kj = k_join(a, b)
            if not km.is_fixpoint():
                return False
            if not kj.is_fixpoint():
                return False
    # Verify truth non-closure
    tm = t_meet(BVal.B, BVal.N)
    tj = t_join(BVal.B, BVal.N)
    assert not tm.is_fixpoint(), "tMeet(B,N) should not be a fixpoint"
    assert not tj.is_fixpoint(), "tJoin(B,N) should not be a fixpoint"
    return True


def verify_collapse_theorem() -> str:
    """Demonstrate the dialectical collapse theorem.

    Show that EM forces kBot = kTop, contradicting non-triviality.
    """
    # In BVal: kBot = N, kTop = B
    # EM says every element is T or F
    # N must be T or F. But neg(T) = F ≠ T and neg(F) = T ≠ F
    # So N cannot be a fixpoint if N ∈ {T, F} — contradiction.
    for assignment_N in [BVal.T, BVal.F]:
        for assignment_B in [BVal.T, BVal.F]:
            if assignment_N == assignment_B:
                continue  # kBot ≠ kTop
            # Check: neg(assignment_N) should equal assignment_N (fixpoint)
            if assignment_N.neg() != assignment_N:
                return (f"Collapse: if N={assignment_N.value}, "
                        f"neg(N)={assignment_N.neg().value}≠{assignment_N.value}")
    return "Collapse verified: no consistent EM assignment exists"


def product_decomposition_demo() -> None:
    """Demonstrate the BVal ≅ Bool × Bool isomorphism."""
    print("Product Decomposition: BVal ≅ Bool × Bool")
    print("-" * 45)
    for v in BVal:
        p = v.to_bool_pair()
        roundtrip = BVal.from_bool_pair(p)
        neg_via_swap = BVal.from_bool_pair((p[1], p[0]))
        print(f"  {v.value} → ({int(p[0])},{int(p[1])}) → {roundtrip.value} | "
              f"swap → ({int(p[1])},{int(p[0])}) = neg = {neg_via_swap.value}")
    # Verify isomorphism
    for v in BVal:
        assert BVal.from_bool_pair(v.to_bool_pair()) == v
    for b1 in [True, False]:
        for b2 in [True, False]:
            p = (b1, b2)
            assert BVal.from_bool_pair(p).to_bool_pair() == p
    print("  ✓ Isomorphism verified (both directions)")


if __name__ == "__main__":
    # Run all verifications
    print("=== Dialectical Algebra Algorithms ===\n")

    print("1. Fixpoint Sublattice Theorem:")
    result = verify_fixpoint_sublattice()
    print(f"   Verified: {result}\n")

    print("2. Collapse Theorem:")
    result = verify_collapse_theorem()
    print(f"   {result}\n")

    print("3. Product Decomposition:")
    product_decomposition_demo()

    print("\n4. Theory Analysis:")
    theories = [
        ("Classical",     [BVal.T, BVal.F, BVal.T, BVal.F, BVal.T]),
        ("One paradox",   [BVal.T, BVal.B, BVal.F, BVal.T, BVal.F]),
        ("Independent",   [BVal.T, BVal.B, BVal.F, BVal.N, BVal.T]),
        ("Max paradox",   [BVal.B, BVal.B, BVal.N, BVal.B, BVal.N]),
    ]
    for name, truth in theories:
        spec = compute_spectrum(truth)
        indep = find_independent_paradoxes(truth)
        sound = is_self_sound(truth, {0, 1} if len(truth) > 1 else {0})
        print(f"  {name}: rank={spec.dialectical_rank}, "
              f"classical={spec.is_classical}, "
              f"independent_pairs={len(indep)}, "
              f"self_sound={sound}")
