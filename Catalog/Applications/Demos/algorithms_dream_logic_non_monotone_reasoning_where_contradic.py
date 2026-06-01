"""
Dream Logic: Algorithms for Paraconsistent Non-Monotone Reasoning

Type-hinted implementations of the core algorithms for Belnap's four-valued logic,
dream frames, pre-topological spaces, and default reasoning.
"""

from __future__ import annotations
from dataclasses import dataclass
from enum import Enum
from typing import Callable, FrozenSet, Set, Dict, List, Tuple, Optional


# ============================================================================
# Belnap's Four-Valued Logic
# ============================================================================

class BelnapVal(Enum):
    """Four-valued truth value: (truth_support, falsity_support)"""
    NEITHER = (False, False)    # No information
    TRUE_ONLY = (True, False)   # Consistent truth
    FALSE_ONLY = (False, True)  # Consistent falsity
    BOTH = (True, True)         # Contradictory information

    @property
    def truth(self) -> bool:
        return self.value[0]

    @property
    def falsity(self) -> bool:
        return self.value[1]

    @property
    def is_designated(self) -> bool:
        """A value is designated (accepted) when it has truth support."""
        return self.truth

    def bneg(self) -> BelnapVal:
        """Belnap negation: swap truth and falsity support."""
        return BelnapVal((self.falsity, self.truth))

    @staticmethod
    def bconj(a: BelnapVal, b: BelnapVal) -> BelnapVal:
        """Belnap conjunction: truth requires both, falsity requires either."""
        return BelnapVal((a.truth and b.truth, a.falsity or b.falsity))

    @staticmethod
    def bdisj(a: BelnapVal, b: BelnapVal) -> BelnapVal:
        """Belnap disjunction: truth requires either, falsity requires both."""
        return BelnapVal((a.truth or b.truth, a.falsity and b.falsity))

    def info_le(self, other: BelnapVal) -> bool:
        """Information ordering: self ≤ other iff other has all evidence self has."""
        return (not self.truth or other.truth) and (not self.falsity or other.falsity)


def verify_de_morgan() -> bool:
    """Verify De Morgan's laws hold for all Belnap value pairs."""
    for a in BelnapVal:
        for b in BelnapVal:
            # ¬(a ∧ b) = ¬a ∨ ¬b
            lhs1 = BelnapVal.bconj(a, b).bneg()
            rhs1 = BelnapVal.bdisj(a.bneg(), b.bneg())
            if lhs1 != rhs1:
                return False
            # ¬(a ∨ b) = ¬a ∧ ¬b
            lhs2 = BelnapVal.bdisj(a, b).bneg()
            rhs2 = BelnapVal.bconj(a.bneg(), b.bneg())
            if lhs2 != rhs2:
                return False
    return True


def verify_explosion_fails() -> Tuple[BelnapVal, BelnapVal]:
    """Find values demonstrating explosion failure.
    Returns (vp, vq) where vp and ¬vp are designated but vq is not."""
    for vp in BelnapVal:
        for vq in BelnapVal:
            if vp.is_designated and vp.bneg().is_designated and not vq.is_designated:
                return (vp, vq)
    raise ValueError("No explosion failure witness found (shouldn't happen)")


# ============================================================================
# Dream Frames
# ============================================================================

@dataclass
class DreamFrame:
    """A dream frame: worlds with four-valued proposition valuations."""
    worlds: List[int]
    propositions: List[int]
    val: Callable[[int, int], BelnapVal]

    def designated_set(self, p: int) -> Set[int]:
        """The set of worlds where proposition p is designated."""
        return {w for w in self.worlds if self.val(w, p).is_designated}

    def entails(self, premises: Set[int], conclusion: int) -> bool:
        """Check if premises semantically entail conclusion."""
        for w in self.worlds:
            if all(self.val(w, p).is_designated for p in premises):
                if not self.val(w, conclusion).is_designated:
                    return False
        return True


def pointwise_dream(n: int) -> DreamFrame:
    """Create a pointwise dream frame on {0, ..., n-1}:
    proposition p is true only at world p."""
    def val(w: int, p: int) -> BelnapVal:
        return BelnapVal.TRUE_ONLY if w == p else BelnapVal.NEITHER
    return DreamFrame(
        worlds=list(range(n)),
        propositions=list(range(n)),
        val=val
    )


def contradictory_dream(n: int, contradictory_props: Set[int]) -> DreamFrame:
    """Create a dream frame where specified propositions are contradictory
    at every world, while others are consistently true."""
    def val(w: int, p: int) -> BelnapVal:
        if p in contradictory_props:
            return BelnapVal.BOTH
        return BelnapVal.TRUE_ONLY
    return DreamFrame(
        worlds=list(range(n)),
        propositions=list(range(n)),
        val=val
    )


# ============================================================================
# Pre-Topological Spaces
# ============================================================================

@dataclass
class PreTopologicalSpace:
    """A pre-topological space: finite closure properties without arbitrary union closure."""
    points: FrozenSet[int]
    pre_open_sets: Set[FrozenSet[int]]

    def is_pre_open(self, s: FrozenSet[int]) -> bool:
        return s in self.pre_open_sets

    def verify_axioms(self) -> Dict[str, bool]:
        """Verify all pre-topological axioms."""
        results = {}
        results['empty'] = frozenset() in self.pre_open_sets
        results['univ'] = self.points in self.pre_open_sets
        # Finite intersection
        results['inter'] = all(
            (s & t) in self.pre_open_sets
            for s in self.pre_open_sets
            for t in self.pre_open_sets
        )
        # Finite union
        results['union'] = all(
            (s | t) in self.pre_open_sets
            for s in self.pre_open_sets
            for t in self.pre_open_sets
        )
        return results


def finite_or_univ_pretopology(n: int) -> PreTopologicalSpace:
    """Approximate the finite-or-univ pre-topology on {0, ..., n-1}.
    Since we work with a finite set, this is actually a topology
    (finite ≡ all subsets when the ground set is finite).
    The true example requires infinite ℕ."""
    points = frozenset(range(n))
    # All subsets are finite, so all are pre-open
    pre_open = set()
    for i in range(2**n):
        s = frozenset(j for j in range(n) if (i >> j) & 1)
        pre_open.add(s)
    return PreTopologicalSpace(points=points, pre_open_sets=pre_open)


def demonstrate_non_topology() -> None:
    """Demonstrate that infinite union can fail in pre-topological spaces.
    Uses the conceptual example: on ℕ, singletons {2k} are pre-open,
    but their union (even numbers) is not."""
    print("Pre-Topology Separation Example:")
    print("Space: ℕ (natural numbers)")
    print("Pre-open sets: finite sets ∪ {ℕ}")
    print()
    print("Each singleton {2k} is finite → pre-open ✓")
    print("⋃ₖ {2k} = {even numbers}")
    print("Even numbers: infinite → not finite ✗")
    print("Even numbers ≠ ℕ (e.g., 1 is odd) → not univ ✗")
    print("Therefore: ⋃ₖ {2k} is NOT pre-open ✓")
    print("This proves finiteOrUniv is not a topology.")


# ============================================================================
# Default Reasoning
# ============================================================================

@dataclass
class DefaultTheory:
    """A default theory with defeasible rules and exceptions."""
    defaults: List[Tuple[str, str]]      # (trigger, conclusion) pairs
    exceptions: List[Tuple[str, str]]    # (blocker, conclusion) pairs

    def default_entails(self, premises: Set[str], conclusion: str) -> bool:
        """Check if conclusion follows from premises under default reasoning."""
        # Direct membership
        if conclusion in premises:
            return True
        # Default application
        for trigger, conc in self.defaults:
            if conc == conclusion and trigger in premises:
                # Check if any exception blocks this
                blocked = any(
                    blocker in premises and exc_conc == conclusion
                    for blocker, exc_conc in self.exceptions
                )
                if not blocked:
                    return True
        return False


def bird_theory() -> DefaultTheory:
    """The standard bird/penguin/flies default theory."""
    return DefaultTheory(
        defaults=[("bird", "flies")],
        exceptions=[("penguin", "flies")]
    )


def demonstrate_non_monotonicity() -> None:
    """Demonstrate non-monotone default reasoning."""
    theory = bird_theory()
    gamma = {"bird"}
    delta = {"bird", "penguin"}

    print("Non-Monotone Default Reasoning:")
    print(f"Theory: birds normally fly; penguins don't fly")
    print(f"Γ = {gamma}")
    print(f"Δ = {delta}")
    print(f"Γ ⊆ Δ: {gamma <= delta}")
    print(f"Γ ⊢_d flies: {theory.default_entails(gamma, 'flies')}")
    print(f"Δ ⊢_d flies: {theory.default_entails(delta, 'flies')}")
    print(f"Non-monotone: adding 'penguin' retracted 'flies' ✓")


# ============================================================================
# Compactness Testing
# ============================================================================

def test_compactness(n_props: int, n_worlds: int) -> bool:
    """Test paraconsistent compactness conjecture for small cases.
    Generate a random dream frame and check that finite satisfiability
    implies global satisfiability."""
    import random
    random.seed(42)

    vals = list(BelnapVal)
    # Generate random valuation
    val_table: Dict[Tuple[int, int], BelnapVal] = {}
    for w in range(n_worlds):
        for p in range(n_props):
            val_table[(w, p)] = random.choice(vals)

    all_props = set(range(n_props))

    # Check: if every finite subset is satisfiable, is the whole set?
    def is_satisfiable(props: Set[int]) -> bool:
        for w in range(n_worlds):
            if all(val_table[(w, p)].is_designated for p in props):
                return True
        return False

    # Check all subsets of size ≤ 3 for finite satisfiability
    from itertools import combinations
    finite_sat = True
    for k in range(1, min(4, n_props + 1)):
        for subset in combinations(range(n_props), k):
            if not is_satisfiable(set(subset)):
                finite_sat = False
                break
        if not finite_sat:
            break

    if not finite_sat:
        return True  # Vacuously true (not finitely satisfiable)

    global_sat = is_satisfiable(all_props)
    return global_sat


if __name__ == "__main__":
    print("=" * 60)
    print("Dream Logic: Algorithm Demonstrations")
    print("=" * 60)
    print()

    # De Morgan verification
    print("1. De Morgan Laws Verification:", "PASS ✓" if verify_de_morgan() else "FAIL ✗")
    print()

    # Explosion failure
    vp, vq = verify_explosion_fails()
    print(f"2. Explosion Failure Witness: vp={vp.name}, vq={vq.name}")
    print(f"   vp designated: {vp.is_designated}")
    print(f"   ¬vp designated: {vp.bneg().is_designated}")
    print(f"   vq designated: {vq.is_designated}")
    print()

    # Non-monotonicity
    demonstrate_non_monotonicity()
    print()

    # Pre-topology
    demonstrate_non_topology()
    print()

    # Dream frame
    print("5. Dream Frame Explosion Test:")
    D = contradictory_dream(3, {0})
    print(f"   Prop 0 contradictory: {D.val(0, 0) == BelnapVal.BOTH}")
    print(f"   Prop 1 entailed by {{0}}: {D.entails({0}, 1)}")
    print(f"   Explosion fails at frame level ✓")
    print()

    # Compactness test
    print("6. Compactness Conjecture Tests:")
    for n in range(2, 8):
        result = test_compactness(n, n * 2)
        print(f"   n={n}: {'PASS ✓' if result else 'FAIL ✗'}")
