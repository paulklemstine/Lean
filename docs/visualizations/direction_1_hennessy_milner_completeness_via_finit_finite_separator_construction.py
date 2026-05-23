#!/usr/bin/env python3
"""
Algorithms for Hennessy–Milner Logic and Bisimulation

Implements:
1. Partition refinement for bisimulation equivalence classes
2. Bounded-depth HM formula generation and model checking
3. Finite separator construction (the key algorithmic contribution)
4. Modal depth analysis

All algorithms come with complexity analysis in docstrings.
"""

from __future__ import annotations
from dataclasses import dataclass
from typing import Dict, FrozenSet, List, Optional, Set, Tuple


# ============================================================
# Data Structures
# ============================================================

@dataclass
class LTS:
    """
    Labeled transition system with finite state and action sets.

    Attributes:
        states: List of state identifiers
        actions: List of action labels
        transitions: Map from (state, action) to set of successor states
    """
    states: List[int]
    actions: List[str]
    transitions: Dict[Tuple[int, str], Set[int]]

    def succs(self, s: int, a: str) -> Set[int]:
        """Get successor states of s via action a. O(1) lookup."""
        return self.transitions.get((s, a), set())

    def predecessors(self, t: int, a: str) -> Set[int]:
        """Get predecessor states: {s | s --a--> t}. O(|S|) scan."""
        return {s for s in self.states if t in self.succs(s, a)}

    def is_image_finite(self) -> bool:
        """Check if all successor sets are finite (always true for finite LTS)."""
        return True  # Finite data structure guarantees this


@dataclass(frozen=True)
class HMFormula:
    """Base class for Hennessy–Milner formulas."""
    pass

@dataclass(frozen=True)
class TT(HMFormula):
    """Truth constant ⊤."""
    def __repr__(self): return "⊤"

@dataclass(frozen=True)
class Conj(HMFormula):
    """Binary conjunction φ ∧ ψ."""
    left: HMFormula
    right: HMFormula
    def __repr__(self): return f"({self.left} ∧ {self.right})"

@dataclass(frozen=True)
class Neg(HMFormula):
    """Negation ¬φ."""
    sub: HMFormula
    def __repr__(self): return f"¬{self.sub}"

@dataclass(frozen=True)
class Diamond(HMFormula):
    """Diamond modality ⟨a⟩φ."""
    action: str
    sub: HMFormula
    def __repr__(self): return f"⟨{self.action}⟩{self.sub}"


# ============================================================
# Algorithm 1: Model Checking
# ============================================================

def model_check(lts: LTS, s: int, phi: HMFormula) -> bool:
    """
    Check whether state s satisfies formula phi in the given LTS.

    Complexity: O(|phi| * |S| * max_branching) where |phi| is formula size.
    For image-finite systems, this is bounded by the formula structure.
    """
    if isinstance(phi, TT):
        return True
    if isinstance(phi, Conj):
        return model_check(lts, s, phi.left) and model_check(lts, s, phi.right)
    if isinstance(phi, Neg):
        return not model_check(lts, s, phi.sub)
    if isinstance(phi, Diamond):
        return any(model_check(lts, t, phi.sub) for t in lts.succs(s, phi.action))
    raise ValueError(f"Unknown formula type: {type(phi)}")


def modal_depth(phi: HMFormula) -> int:
    """Compute the modal depth of an HM formula. O(|phi|)."""
    if isinstance(phi, TT): return 0
    if isinstance(phi, Conj): return max(modal_depth(phi.left), modal_depth(phi.right))
    if isinstance(phi, Neg): return modal_depth(phi.sub)
    if isinstance(phi, Diamond): return modal_depth(phi.sub) + 1
    return 0


# ============================================================
# Algorithm 2: Partition Refinement (Paige-Tarjan style)
# ============================================================

def partition_refinement(lts: LTS) -> List[FrozenSet[int]]:
    """
    Compute bisimulation equivalence classes via partition refinement.

    This is the standard Paige–Tarjan algorithm adapted for
    multi-action LTS.

    Complexity: O(|Act| * |S| * log|S|) with proper implementation.
    This simplified version is O(|Act| * |S|^2 * rounds).

    Returns: List of equivalence classes (frozensets of states).
    """
    # Initial partition: all states in one block
    partition = [frozenset(lts.states)]

    def block_of(s: int) -> int:
        """Return the index of the block containing s."""
        for i, block in enumerate(partition):
            if s in block:
                return i
        return -1

    changed = True
    rounds = 0
    while changed:
        changed = False
        rounds += 1
        new_partition: List[FrozenSet[int]] = []

        for block in partition:
            # Compute signature for each state in the block
            signatures: Dict[tuple, Set[int]] = {}
            for s in block:
                sig = tuple(
                    frozenset(block_of(t) for t in lts.succs(s, a))
                    for a in lts.actions
                )
                signatures.setdefault(sig, set()).add(s)

            new_blocks = [frozenset(v) for v in signatures.values()]
            if len(new_blocks) > 1:
                changed = True
            new_partition.extend(new_blocks)

        partition = new_partition

    return partition


def refinement_depth(lts: LTS) -> int:
    """
    Compute the number of refinement rounds until stabilization.
    This bounds the modal depth of distinguishing formulas.
    """
    partition = [frozenset(lts.states)]

    def block_of(s: int) -> int:
        for i, block in enumerate(partition):
            if s in block:
                return i
        return -1

    rounds = 0
    changed = True
    while changed:
        changed = False
        rounds += 1
        new_partition: List[FrozenSet[int]] = []
        for block in partition:
            signatures: Dict[tuple, Set[int]] = {}
            for s in block:
                sig = tuple(
                    frozenset(block_of(t) for t in lts.succs(s, a))
                    for a in lts.actions
                )
                signatures.setdefault(sig, set()).add(s)
            new_blocks = [frozenset(v) for v in signatures.values()]
            if len(new_blocks) > 1:
                changed = True
            new_partition.extend(new_blocks)
        partition = new_partition

    return rounds


# ============================================================
# Algorithm 3: Finite Separator Construction
# ============================================================

def generate_formulas_up_to_depth(actions: List[str], depth: int) -> List[HMFormula]:
    """
    Generate all HM formulas up to given modal depth.

    Complexity: Exponential in depth, but finite for any fixed depth.
    This is used as a brute-force fallback for finding distinguishing formulas.
    """
    if depth < 0:
        return []

    base = [TT(), Neg(TT())]
    if depth == 0:
        return base

    prev = generate_formulas_up_to_depth(actions, depth - 1)
    result = list(prev)

    # Diamond modalities (increase depth by 1)
    for a in actions:
        for phi in prev:
            if modal_depth(phi) <= depth - 1:
                result.append(Diamond(a, phi))

    # Negations (preserve depth)
    for phi in prev:
        result.append(Neg(phi))

    # Binary conjunctions (max of depths)
    for i, phi in enumerate(prev):
        for psi in prev[i:]:
            result.append(Conj(phi, psi))

    return result


def find_distinguishing_formula(
    lts: LTS, s: int, t: int, max_depth: int = 6
) -> Optional[HMFormula]:
    """
    Find a formula satisfied by s but not t.

    Strategy: enumerate formulas by increasing modal depth.
    For image-finite LTS, if s and t are not bisimilar, a
    distinguishing formula exists with depth ≤ refinement_depth.

    Complexity: O(|formulas_at_depth_d| * |S|) per depth level.
    """
    for d in range(max_depth + 1):
        for phi in generate_formulas_up_to_depth(lts.actions, d):
            if model_check(lts, s, phi) and not model_check(lts, t, phi):
                return phi
    return None


def list_conj(formulas: List[HMFormula]) -> HMFormula:
    """Build finite conjunction from a list. O(n) where n = len(formulas)."""
    if not formulas:
        return TT()
    result = formulas[-1]
    for phi in reversed(formulas[:-1]):
        result = Conj(phi, result)
    return result


def build_finite_separator(
    lts: LTS, s_prime: int, t_succs: Set[int], max_depth: int = 6
) -> Optional[HMFormula]:
    """
    Build a finite conjunction ψ such that s' ⊨ ψ and ∀ t' ∈ t_succs, t' ⊭ ψ.

    This is the computational realization of the finitary separator theorem
    (exists_finitary_separator in the formalization).

    The algorithm:
    1. For each t' in t_succs, find φ_{t'} with s' ⊨ φ_{t'} ∧ t' ⊭ φ_{t'}
    2. Return ψ = ⋀_{t'} φ_{t'}

    Correctness:
    - s' ⊨ ψ because s' satisfies each conjunct
    - For each t' ∈ t_succs: t' ⊭ φ_{t'}, hence t' ⊭ ψ

    Complexity: O(|t_succs| * cost_of_find_distinguishing)
    """
    if not t_succs:
        return TT()

    formulas = []
    for t_prime in t_succs:
        phi = find_distinguishing_formula(lts, s_prime, t_prime, max_depth)
        if phi is None:
            return None  # s' and t' are HM-equivalent
        formulas.append(phi)

    return list_conj(formulas)


def build_step_separator(
    lts: LTS, s: int, t: int, action: str, s_prime: int,
    max_depth: int = 6
) -> Optional[HMFormula]:
    """
    Build a one-step separator: ⟨a⟩ψ satisfied by s but not t.

    Precondition: s --a--> s' and no a-successor of t is HM-equiv to s'.

    This is the key step in the Hennessy–Milner transfer proof:
    1. t_succs = succs(t, a)
    2. Build separator ψ for s' vs t_succs
    3. Return ⟨a⟩ψ

    Then: s ⊨ ⟨a⟩ψ (via s') but t ⊭ ⟨a⟩ψ (all a-succs of t fail ψ).
    """
    t_succs = lts.succs(t, action)
    separator = build_finite_separator(lts, s_prime, t_succs, max_depth)
    if separator is None:
        return None
    return Diamond(action, separator)


# ============================================================
# Algorithm 4: Verified Comparison
# ============================================================

def verify_hm_equals_bisim(lts: LTS, max_depth: int = 5) -> bool:
    """
    Verify that HM-equivalence = bisimilarity for all state pairs.

    Returns True if the Hennessy–Milner theorem holds for this LTS.

    Complexity: O(|S|^2 * (partition_refinement + formula_check))
    """
    blocks = partition_refinement(lts)

    for s in lts.states:
        for t in lts.states:
            if s >= t:
                continue
            bisim = any(s in b and t in b for b in blocks)
            hm_eq = True
            for d in range(max_depth + 1):
                for phi in generate_formulas_up_to_depth(lts.actions, d):
                    if model_check(lts, s, phi) != model_check(lts, t, phi):
                        hm_eq = False
                        break
                if not hm_eq:
                    break
            if bisim != hm_eq:
                return False
    return True


# ============================================================
# Main demonstration
# ============================================================

if __name__ == "__main__":
    # Example: Milner's vending machine
    lts = LTS(
        states=[0, 1, 2, 3, 4, 5],
        actions=["coin", "tea", "coffee"],
        transitions={
            (0, "coin"): {1, 2},
            (1, "tea"): {3},
            (1, "coffee"): {3},
            (2, "tea"): {3},
            (4, "coin"): {5},
            (5, "tea"): {3},
            (5, "coffee"): {3},
        }
    )

    print("Vending machine LTS:")
    for (s, a), ts in sorted(lts.transitions.items()):
        if ts:
            print(f"  {s} --{a}--> {ts}")

    print("\nPartition refinement:")
    blocks = partition_refinement(lts)
    for block in sorted(blocks, key=lambda b: min(b)):
        print(f"  {sorted(block)}")

    print(f"\nRefinement depth: {refinement_depth(lts)}")

    print("\nVerifying HM = bisim:", verify_hm_equals_bisim(lts, 3))

    # Find distinguishing formula between 0 and 4
    phi = find_distinguishing_formula(lts, 0, 4, 4)
    if phi:
        print(f"\nDistinguishing formula for (0, 4): {phi}")
        print(f"  Modal depth: {modal_depth(phi)}")
        print(f"  0 ⊨ φ: {model_check(lts, 0, phi)}")
        print(f"  4 ⊨ φ: {model_check(lts, 4, phi)}")
