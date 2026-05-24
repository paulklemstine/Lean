#!/usr/bin/env python3
"""
Algorithms for Boolean Topos Characterization of Determinism

Implements the core algorithms from the research paper:
1. Determinism checking with witness extraction
2. Diamond distributivity verification
3. Non-Boolean witness construction
4. Complement duality checking
5. Bisimulation computation
6. Branching entropy calculation

All algorithms include docstrings, type hints, and complexity analysis.
"""

from typing import (
    Dict, FrozenSet, List, Optional, Set, Tuple
)
from dataclasses import dataclass, field
from collections import defaultdict
import math

# ─── Core Types ───────────────────────────────────────────────────────

State = int
Action = str
Transition = Tuple[State, Action, State]


@dataclass
class LTS:
    """A labeled transition system.

    Attributes:
        states: Set of state identifiers
        actions: Set of action labels
        transitions: Set of (source, action, target) triples
    """
    states: Set[State]
    actions: Set[Action]
    transitions: Set[Transition]
    _succ: Dict[Tuple[State, Action], Set[State]] = field(
        default_factory=dict, repr=False
    )

    def __post_init__(self):
        self._succ = defaultdict(set)
        for s, a, t in self.transitions:
            self._succ[(s, a)].add(t)

    def successors(self, s: State, a: Action) -> Set[State]:
        """Get all a-successors of state s. O(1) amortized."""
        return self._succ.get((s, a), set())


# ─── Algorithm 1: Determinism Checker ─────────────────────────────────

@dataclass
class DeterminismResult:
    """Result of determinism check.

    Attributes:
        is_deterministic: Whether the LTS is fully deterministic
        witness: If nondeterministic, (state, action, successor1, successor2)
    """
    is_deterministic: bool
    witness: Optional[Tuple[State, Action, State, State]] = None


def check_determinism(lts: LTS) -> DeterminismResult:
    """Check if an LTS is fully deterministic.

    Algorithm: For each (state, action) pair, check if there is at most
    one successor. Return the first branching fork found.

    Complexity: O(|States| × |Actions| × max_branching)
        where max_branching = max |successors(s, a)| over all (s, a).

    Args:
        lts: The labeled transition system to check.

    Returns:
        DeterminismResult with is_deterministic flag and optional witness.

    Example:
        >>> lts = LTS({0, 1}, {"a"}, {(0, "a", 0), (0, "a", 1)})
        >>> result = check_determinism(lts)
        >>> result.is_deterministic
        False
        >>> result.witness
        (0, 'a', 0, 1)
    """
    for s in sorted(lts.states):
        for a in sorted(lts.actions):
            succs = sorted(lts.successors(s, a))
            if len(succs) >= 2:
                return DeterminismResult(
                    is_deterministic=False,
                    witness=(s, a, succs[0], succs[1])
                )
    return DeterminismResult(is_deterministic=True)


# ─── Algorithm 2: Diamond Modality ────────────────────────────────────

def diamond(lts: LTS, a: Action, P: FrozenSet[State]) -> FrozenSet[State]:
    """Compute the diamond modality ⟨a⟩P.

    ⟨a⟩P = {s ∈ States | ∃ t ∈ P, (s, a, t) ∈ Transitions}

    Complexity: O(|States| × max_branching)

    Args:
        lts: The labeled transition system.
        a: The action label.
        P: The target state predicate.

    Returns:
        The set of states from which P is reachable via action a.
    """
    return frozenset(
        s for s in lts.states
        if lts.successors(s, a) & P
    )


def box_modality(lts: LTS, a: Action, P: FrozenSet[State]) -> FrozenSet[State]:
    """Compute the box modality [a]P.

    [a]P = {s ∈ States | ∀ t, (s, a, t) ∈ Transitions → t ∈ P}

    Complexity: O(|States| × max_branching)
    """
    return frozenset(
        s for s in lts.states
        if lts.successors(s, a) <= P
    )


# ─── Algorithm 3: Diamond Distributivity Checker ─────────────────────

@dataclass
class DistributivityResult:
    """Result of diamond distributivity check."""
    is_distributive: bool
    witness: Optional[Dict] = None


def check_diamond_distributive(lts: LTS) -> DistributivityResult:
    """Check if ⟨a⟩(P ∩ Q) = ⟨a⟩P ∩ ⟨a⟩Q for all a, P, Q.

    Algorithm: Exhaustively enumerate all pairs of state subsets and
    check the distributivity equation for each action.

    Complexity: O(|Actions| × 4^|States| × |States|)
        Exponential in |States| but feasible for |States| ≤ 5.

    Args:
        lts: The labeled transition system.

    Returns:
        DistributivityResult with is_distributive flag and optional witness.

    Note: By Theorem A, this is equivalent to check_determinism, but
    the exhaustive check provides independent computational validation.
    """
    states_list = sorted(lts.states)
    n = len(states_list)

    for a in sorted(lts.actions):
        for mask_p in range(1 << n):
            P = frozenset(states_list[i] for i in range(n)
                          if mask_p & (1 << i))
            for mask_q in range(1 << n):
                Q = frozenset(states_list[i] for i in range(n)
                              if mask_q & (1 << i))
                lhs = diamond(lts, a, P & Q)
                rhs = diamond(lts, a, P) & diamond(lts, a, Q)
                if lhs != rhs:
                    return DistributivityResult(
                        is_distributive=False,
                        witness={
                            "action": a,
                            "P": set(P),
                            "Q": set(Q),
                            "diamond_PQ": set(lhs),
                            "diamond_P_inter_diamond_Q": set(rhs),
                            "gap": set(rhs - lhs),
                        }
                    )

    return DistributivityResult(is_distributive=True)


# ─── Algorithm 4: Non-Boolean Witness Constructor ─────────────────────

@dataclass
class NonBooleanWitness:
    """An explicit witness of non-Boolean modal behavior."""
    state: State
    action: Action
    successor_1: State
    successor_2: State
    explanation: str


def construct_nonboolean_witness(lts: LTS) -> Optional[NonBooleanWitness]:
    """Construct canonical non-Boolean witness from branching fork.

    If s has two distinct a-successors t₁ ≠ t₂, the witness is:
      P = {t₁}, Q = {t₂}
      s ∈ ⟨a⟩P ∩ ⟨a⟩Q  (since t₁ and t₂ are both reachable)
      s ∉ ⟨a⟩(P ∩ Q)   (since {t₁} ∩ {t₂} = ∅)

    Complexity: O(|States| × |Actions|)
        Linear scan — the witness is immediate from the first fork.

    Args:
        lts: The labeled transition system.

    Returns:
        NonBooleanWitness if the LTS is nondeterministic, None otherwise.
    """
    result = check_determinism(lts)
    if result.is_deterministic:
        return None
    s, a, t1, t2 = result.witness
    return NonBooleanWitness(
        state=s, action=a, successor_1=t1, successor_2=t2,
        explanation=(
            f"Branching fork: state {s} has {a}-successors {t1} and {t2}.\n"
            f"  P = {{{t1}}}, Q = {{{t2}}}\n"
            f"  ⟨{a}⟩P = {set(diamond(lts, a, frozenset({t1})))}\n"
            f"  ⟨{a}⟩Q = {set(diamond(lts, a, frozenset({t2})))}\n"
            f"  ⟨{a}⟩(P∩Q) = ∅\n"
            f"  State {s} witnesses ⟨{a}⟩P ∩ ⟨{a}⟩Q ≠ ⟨{a}⟩(P∩Q)"
        )
    )


# ─── Algorithm 5: Bisimulation Computation ───────────────────────────

def compute_bisimulation(lts: LTS) -> Dict[State, FrozenSet[State]]:
    """Compute the bisimulation equivalence classes.

    Algorithm: Partition refinement.
    1. Start with all states in one block.
    2. Refine: split blocks where states differ in their
       ability to reach other blocks via some action.
    3. Repeat until stable.

    Complexity: O(|States|² × |Actions| × |Transitions|)
        Polynomial — this is the standard Kanellakis-Smolka algorithm.

    Args:
        lts: The labeled transition system.

    Returns:
        Dictionary mapping each state to its equivalence class.
    """
    # Initial partition: all states in one block
    partition = [frozenset(lts.states)]

    changed = True
    while changed:
        changed = False
        new_partition: List[FrozenSet[State]] = []

        for block in partition:
            # Try to split this block
            split = _try_split(lts, block, partition)
            if len(split) > 1:
                changed = True
            new_partition.extend(split)

        partition = new_partition

    # Build equivalence class mapping
    result = {}
    for block in partition:
        for s in block:
            result[s] = block
    return result


def _try_split(
    lts: LTS,
    block: FrozenSet[State],
    partition: List[FrozenSet[State]]
) -> List[FrozenSet[State]]:
    """Try to split a block based on transition behavior."""
    if len(block) <= 1:
        return [block]

    for a in lts.actions:
        for target_block in partition:
            # Split based on whether states can reach target_block via a
            can_reach = frozenset(
                s for s in block
                if lts.successors(s, a) & target_block
            )
            cannot_reach = block - can_reach
            if can_reach and cannot_reach:
                return [can_reach, cannot_reach]

    return [block]


def is_bisim_equality(lts: LTS) -> bool:
    """Check if bisimilarity implies equality (identity closure).

    Complexity: Same as compute_bisimulation.
    """
    classes = compute_bisimulation(lts)
    return all(len(cls) == 1 for cls in classes.values())


# ─── Algorithm 6: Branching Entropy ──────────────────────────────────

def branching_entropy(lts: LTS) -> float:
    """Compute the average branching entropy of an LTS.

    For each (state, action) pair, the branching entropy is the
    log₂ of the number of successors (0 for deterministic pairs).
    The overall entropy is the average over all pairs.

    This measures how much "nondeterministic information" the system
    carries. It is 0 iff the system is fully deterministic.

    Complexity: O(|States| × |Actions|)

    Args:
        lts: The labeled transition system.

    Returns:
        Average branching entropy in bits.
    """
    total = 0.0
    count = 0
    for s in lts.states:
        for a in lts.actions:
            n_succs = len(lts.successors(s, a))
            if n_succs > 0:
                total += math.log2(n_succs)
            count += 1
    return total / count if count > 0 else 0.0


def nondistributivity_score(lts: LTS) -> int:
    """Compute the non-distributivity score.

    Defined as max over all (s, a) of (|successors(s,a)| - 1).
    This is 0 iff the LTS is deterministic.

    Measures the worst-case branching at any single point.

    Complexity: O(|States| × |Actions|)
    """
    score = 0
    for s in lts.states:
        for a in lts.actions:
            n = len(lts.successors(s, a))
            score = max(score, n - 1)
    return score


# ─── Usage Examples ──────────────────────────────────────────────────

if __name__ == "__main__":
    print("=" * 60)
    print(" Algorithms for Boolean Topos Characterization")
    print("=" * 60)

    # Example 1: Deterministic system
    det_lts = LTS(
        states={0, 1, 2},
        actions={"a", "b"},
        transitions={(0, "a", 1), (1, "a", 2), (2, "a", 0),
                     (0, "b", 2), (1, "b", 0), (2, "b", 1)}
    )
    print("\n--- Deterministic 3-Cycle ---")
    print(f"  Deterministic: {check_determinism(det_lts)}")
    print(f"  Distributive:  {check_diamond_distributive(det_lts)}")
    print(f"  Bisim classes: {compute_bisimulation(det_lts)}")
    print(f"  Bisim=Equality: {is_bisim_equality(det_lts)}")
    print(f"  Branching entropy: {branching_entropy(det_lts):.4f}")
    print(f"  Non-dist score: {nondistributivity_score(det_lts)}")

    # Example 2: Nondeterministic system
    nondet_lts = LTS(
        states={0, 1, 2},
        actions={"a"},
        transitions={(0, "a", 1), (0, "a", 2), (1, "a", 1), (2, "a", 2)}
    )
    print("\n--- Nondeterministic Branch ---")
    det_result = check_determinism(nondet_lts)
    print(f"  Deterministic: {det_result}")
    dist_result = check_diamond_distributive(nondet_lts)
    print(f"  Distributive:  {dist_result}")
    witness = construct_nonboolean_witness(nondet_lts)
    if witness:
        print(f"  Non-Boolean witness:\n    {witness.explanation}")
    print(f"  Bisim classes: {compute_bisimulation(nondet_lts)}")
    print(f"  Bisim=Equality: {is_bisim_equality(nondet_lts)}")
    print(f"  Branching entropy: {branching_entropy(nondet_lts):.4f}")
    print(f"  Non-dist score: {nondistributivity_score(nondet_lts)}")

    # Example 3: Bisimilar but distinct states
    bisim_lts = LTS(
        states={0, 1, 2, 3},
        actions={"a"},
        transitions={(0, "a", 2), (1, "a", 3),
                     (2, "a", 2), (3, "a", 3)}
    )
    print("\n--- Bisimilar Distinct States ---")
    print(f"  Deterministic: {check_determinism(bisim_lts)}")
    classes = compute_bisimulation(bisim_lts)
    print(f"  Bisim classes: {classes}")
    print(f"  Bisim=Equality: {is_bisim_equality(bisim_lts)}")
    print(f"  (States 0,1 and 2,3 are bisimilar but distinct)")
