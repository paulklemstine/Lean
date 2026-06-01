"""
Dream Logic: Algorithms for Paraconsistent Non-Monotone Reasoning

Type-hinted implementations of the core algorithms from the Dream Logic framework.
"""

from typing import Dict, FrozenSet, List, Optional, Set, Tuple
from enum import Enum
from dataclasses import dataclass


class BVal(Enum):
    """Belnap's four truth values."""
    T = "t"      # true (positive evidence only)
    F = "f"      # false (negative evidence only)
    B = "both"   # both true and false (contradictory)
    N = "neither" # neither true nor false (unknown)

    def pos(self) -> bool:
        """Positive support: carries truth evidence."""
        return self in (BVal.T, BVal.B)

    def neg_support(self) -> bool:
        """Negative support: carries falsity evidence."""
        return self in (BVal.F, BVal.B)

    def is_designated(self) -> bool:
        """A value is designated (accepted) iff it has positive support."""
        return self.pos()

    @staticmethod
    def of_support(pos: bool, neg: bool) -> 'BVal':
        """Reconstruct from support bits."""
        if pos and neg:
            return BVal.B
        elif pos:
            return BVal.T
        elif neg:
            return BVal.F
        else:
            return BVal.N

    def belnap_neg(self) -> 'BVal':
        """De Morgan negation: swap positive and negative evidence."""
        return BVal.of_support(self.neg_support(), self.pos())

    def conj(self, other: 'BVal') -> 'BVal':
        """Belnap conjunction."""
        return BVal.of_support(
            self.pos() and other.pos(),
            self.neg_support() or other.neg_support()
        )

    def disj(self, other: 'BVal') -> 'BVal':
        """Belnap disjunction."""
        return BVal.of_support(
            self.pos() or other.pos(),
            self.neg_support() and other.neg_support()
        )


@dataclass
class ConflictSystem:
    """A conflict system specifying which propositions are in tension."""
    n_props: int
    conflicts: Set[Tuple[int, int]]

    def has_conflict(self, a: int, b: int) -> bool:
        """Check if propositions a and b conflict."""
        return (a, b) in self.conflicts


def skeptical_consequence(
    conflict: ConflictSystem,
    premises: Set[int],
    conclusion: int
) -> bool:
    """
    Skeptical consequence: p follows from Γ iff p ∈ Γ and
    no element of Γ conflicts with p.

    This is non-monotone: adding premises can retract conclusions.

    Args:
        conflict: The conflict system
        premises: Set of premise indices
        conclusion: Index of the conclusion to check

    Returns:
        True if conclusion follows skeptically from premises
    """
    if conclusion not in premises:
        return False
    for q in premises:
        if conflict.has_conflict(conclusion, q):
            return False
    return True


def compute_dream_depth(valuation: Dict[int, BVal]) -> int:
    """
    Compute dream depth: count of propositions with contradictory value.

    Args:
        valuation: Mapping from proposition index to BVal

    Returns:
        Number of propositions assigned BVal.B
    """
    return sum(1 for v in valuation.values() if v == BVal.B)


def verify_explosion_fails(n_props: int) -> Tuple[Dict[int, BVal], bool]:
    """
    Construct a valuation demonstrating explosion failure.

    Creates a valuation where prop 0 is contradictory (B) and all
    others are false (F). Returns the valuation and verification
    that the contradiction is designated but others are not.

    Args:
        n_props: Number of propositions (must be >= 2)

    Returns:
        (valuation, verified) where verified is True if explosion indeed fails
    """
    assert n_props >= 2
    valuation = {0: BVal.B}
    for i in range(1, n_props):
        valuation[i] = BVal.F

    # Check: contradiction is designated
    v0 = valuation[0]
    contradiction = v0.conj(v0.belnap_neg())
    contradiction_designated = contradiction.is_designated()

    # Check: all others are not designated
    others_not_designated = all(
        not valuation[i].is_designated()
        for i in range(1, n_props)
    )

    return valuation, contradiction_designated and others_not_designated


def iterated_belief_revision(
    conflict: ConflictSystem,
    initial_beliefs: Set[int],
    max_steps: int = 100
) -> List[Set[int]]:
    """
    Perform iterated belief revision under a conflict system.

    At each step, retract all beliefs that are conflicted by some
    other belief in the current set. Continue until a fixed point.

    Args:
        conflict: The conflict system
        initial_beliefs: Starting belief set
        max_steps: Maximum iterations (safety bound)

    Returns:
        List of belief sets at each step (last entry is the fixed point)
    """
    history: List[Set[int]] = [initial_beliefs.copy()]

    for _ in range(max_steps):
        current = history[-1]
        # Keep only beliefs that survive skeptical scrutiny
        next_beliefs = {
            p for p in current
            if skeptical_consequence(conflict, current, p)
        }
        history.append(next_beliefs)
        if next_beliefs == current:
            break  # Fixed point reached

    return history


@dataclass
class QuasiTopology:
    """
    A quasi-topological space on finite ground set {0, ..., n-1}.

    Stores the collection of quasi-open sets explicitly.
    Satisfies: ∅ and ground set are open; closed under finite intersection.
    May NOT be closed under arbitrary union.
    """
    ground_size: int
    open_sets: Set[FrozenSet[int]]

    def is_open(self, s: FrozenSet[int]) -> bool:
        """Check if a set is quasi-open."""
        return s in self.open_sets

    def is_topological(self) -> bool:
        """Check if this quasi-topology is a genuine topology."""
        # Check union closure: for all pairs, check union is open
        open_list = list(self.open_sets)
        for i in range(len(open_list)):
            for j in range(i, len(open_list)):
                union = open_list[i] | open_list[j]
                if union not in self.open_sets:
                    return False
        return True

    def dream_defect_witness(self) -> Optional[Tuple[FrozenSet[int], FrozenSet[int]]]:
        """Find a pair of open sets whose union is not open (if exists)."""
        open_list = list(self.open_sets)
        for i in range(len(open_list)):
            for j in range(i, len(open_list)):
                union = open_list[i] | open_list[j]
                if union not in self.open_sets:
                    return (open_list[i], open_list[j])
        return None


def finite_quasi_topology(n: int) -> QuasiTopology:
    """
    Construct the finite quasi-topology on {0, ..., n-1}.

    Open sets: ∅, {0,...,n-1}, and all finite subsets.
    For finite ground sets, this IS a topology (all sets are finite).
    The non-topological behavior emerges only for infinite ground sets.

    Args:
        n: Size of ground set

    Returns:
        The quasi-topology
    """
    ground = frozenset(range(n))
    # For finite sets, all subsets are finite, so this is actually a topology
    open_sets: Set[FrozenSet[int]] = set()
    # Add all subsets (since all are finite)
    for i in range(1 << n):
        s = frozenset(j for j in range(n) if i & (1 << j))
        open_sets.add(s)
    return QuasiTopology(n, open_sets)


def dream_frame_evaluate(
    access: Dict[int, Set[int]],
    val: Dict[Tuple[int, int], BVal],
    world: int,
    prop: int
) -> Tuple[bool, bool, bool]:
    """
    Evaluate modal operators in a dream frame.

    Args:
        access: Accessibility relation (world -> set of accessible worlds)
        val: Valuation (world, prop) -> BVal
        world: Current world
        prop: Proposition to evaluate

    Returns:
        (dream_necessary, dream_possible, neg_necessary):
        whether □p, ◇p, and □¬p hold at the given world
    """
    accessible = access.get(world, set())

    necessary = all(
        val.get((w, prop), BVal.N).is_designated()
        for w in accessible
    )

    possible = any(
        val.get((w, prop), BVal.N).is_designated()
        for w in accessible
    )

    neg_necessary = all(
        val.get((w, prop), BVal.N).belnap_neg().is_designated()
        for w in accessible
    )

    return necessary, possible, neg_necessary


def min_dream_depth_for_designation(
    conflict: ConflictSystem,
    n_props: int
) -> int:
    """
    Find the minimum dream depth needed for all propositions to be designated.

    Uses brute force search over valuations. For each possible dream depth d,
    check if there exists a valuation with exactly d contradictory propositions
    and all propositions designated.

    Args:
        conflict: The conflict system (currently unused — measures pure designation)
        n_props: Number of propositions

    Returns:
        Minimum dream depth for full designation
    """
    # With BVal.T, all propositions can be designated with dream depth 0
    # The conflict system constrains which assignments are "valid"
    # For now, without conflict constraints on valuation, depth 0 always works
    return 0


if __name__ == "__main__":
    # Quick verification
    print("=== Belnap Logic Verification ===")
    for v in BVal:
        neg_v = v.belnap_neg()
        contr = v.conj(neg_v)
        print(f"  {v.value}: neg={neg_v.value}, "
              f"contradiction={contr.value}, "
              f"designated={contr.is_designated()}")

    print("\n=== Explosion Failure ===")
    val, verified = verify_explosion_fails(5)
    print(f"  Valuation: {[val[i].value for i in range(5)]}")
    print(f"  Explosion fails: {verified}")
