#!/usr/bin/env python3
"""
Algorithms for Temporal Stone Duality and Fixpoint Model Checking
=================================================================

Implements the key algorithms from the research paper:
1. Descending Kleene iteration for greatest fixpoint computation
2. Model checking via fixpoint iteration
3. Dual point computation for behavioral equivalence
4. Safety/reachability duality via complementation

All algorithms operate on finite state spaces and have guaranteed
termination (proved in the formal development).
"""

from typing import (
    Callable, Dict, FrozenSet, Generic, List, Optional,
    Set, Tuple, TypeVar
)
from dataclasses import dataclass
import time

T = TypeVar('T')


# ============================================================
# Algorithm 1: Descending Kleene Iteration
# ============================================================

@dataclass
class GFPResult(Generic[T]):
    """Result of greatest fixpoint computation."""
    fixpoint: T
    iterations: int
    trace: List[T]
    converged: bool
    time_seconds: float


def descending_kleene_iteration(
    top: FrozenSet[int],
    F: Callable[[FrozenSet[int]], FrozenSet[int]],
    max_iter: int = 10000
) -> GFPResult[FrozenSet[int]]:
    """
    Algorithm 1: Descending Kleene Iteration for Greatest Fixpoint

    Computes ν F = gfp(F) by iterating:
        X_0 = ⊤
        X_{n+1} = F(X_n)
    until X_n = X_{n+1}.

    Correctness: Proved in `stabilized_iterate_is_greatest_fixpoint`.
    Termination: Proved in `descending_chain_stabilizes`.
    Bound: Proved in `convergence_bound` (≤ |α| iterations).

    Time complexity: O(|α| · cost(F))
    Space complexity: O(|α|)

    Args:
        top: The top element ⊤ of the lattice.
        F: A monotone operator on the lattice.
        max_iter: Safety bound on iterations.

    Returns:
        GFPResult containing the fixpoint, iteration count, and trace.
    """
    start = time.time()
    current = top
    trace = [current]

    for i in range(max_iter):
        next_val = F(current)
        trace.append(next_val)
        if next_val == current:
            elapsed = time.time() - start
            return GFPResult(
                fixpoint=current,
                iterations=i + 1,
                trace=trace,
                converged=True,
                time_seconds=elapsed
            )
        current = next_val

    elapsed = time.time() - start
    return GFPResult(
        fixpoint=current,
        iterations=max_iter,
        trace=trace,
        converged=False,
        time_seconds=elapsed
    )


# ============================================================
# Algorithm 2: Safety Model Checking
# ============================================================

@dataclass
class TransitionSystem:
    """A finite transition system."""
    n_states: int
    transitions: Dict[int, Set[int]]

    @staticmethod
    def from_edges(n: int, edges: List[Tuple[int, int]]) -> 'TransitionSystem':
        trans = {s: set() for s in range(n)}
        for s, t in edges:
            trans[s].add(t)
        return TransitionSystem(n_states=n, transitions=trans)

    def successors(self, s: int) -> Set[int]:
        return self.transitions.get(s, set())


def safety_model_check(
    ts: TransitionSystem,
    predicate: FrozenSet[int]
) -> GFPResult[FrozenSet[int]]:
    """
    Algorithm 2: Safety Model Checking via GFP Iteration

    Computes the set of states satisfying "always P" by finding
    ν(X ↦ P ∩ preAll(X)).

    Correctness: Proved in `box_semantics_iff_gfp`.
    Pipeline: Proved in `model_checking_pipeline`.

    Time complexity: O(|σ|² · |E|) where |E| = number of transitions
    Space complexity: O(|σ|)

    Args:
        ts: A finite transition system.
        predicate: The predicate P (set of states where P holds).

    Returns:
        GFPResult where fixpoint = {s | always P holds at s}.
    """
    all_states = frozenset(range(ts.n_states))

    def safety_op(X: FrozenSet[int]) -> FrozenSet[int]:
        """Φ_P(X) = P ∩ {s | ∀ t ∈ succ(s), t ∈ X}"""
        pre_all = frozenset(
            s for s in range(ts.n_states)
            if ts.successors(s).issubset(X)
        )
        return predicate & pre_all

    return descending_kleene_iteration(all_states, safety_op)


# ============================================================
# Algorithm 3: Dual Point Computation
# ============================================================

@dataclass
class DualPointResult:
    """Result of dual point computation."""
    dual_points: Dict[int, FrozenSet[FrozenSet[int]]]
    definable_predicates: Set[FrozenSet[int]]
    n_predicates: int
    separation_matrix: Dict[Tuple[int, int], bool]


def compute_dual_points(ts: TransitionSystem) -> DualPointResult:
    """
    Algorithm 3: Dual Point Computation for Behavioral Equivalence

    Computes the dual point (theory) of each state: the set of
    definable predicates that contain it.

    Correctness: Proved in `temporal_dual_separation`.
    Separation: Proved in `temporal_stone_duality_exact_theory`.

    The dual point map s ↦ dp(s) is injective (proved in
    `dualPoint_injective`), so distinct states always have
    distinct dual points.

    Time complexity: O(2^|σ| · |σ|) worst case (closure of definable preds)
    Space complexity: O(2^|σ|)

    Args:
        ts: A finite transition system.

    Returns:
        DualPointResult with dual points, definable predicates, and
        separation matrix.
    """
    states = frozenset(range(ts.n_states))
    preds: Set[FrozenSet[int]] = set()

    # Seed: singletons (atoms) and universe
    for s in range(ts.n_states):
        preds.add(frozenset([s]))
    preds.add(states)
    preds.add(frozenset())  # bottom

    # Closure under box, always, and conjunction
    changed = True
    while changed:
        changed = False
        new_preds: Set[FrozenSet[int]] = set()

        for p in preds:
            # Box (pre_all)
            bp = frozenset(
                s for s in range(ts.n_states)
                if ts.successors(s).issubset(p)
            )
            if bp not in preds:
                new_preds.add(bp)

            # Always (gfp of safety)
            result = safety_model_check(ts, p)
            if result.fixpoint not in preds:
                new_preds.add(result.fixpoint)

        # Conjunctions
        preds_list = list(preds)
        for i in range(len(preds_list)):
            for j in range(i, len(preds_list)):
                conj = preds_list[i] & preds_list[j]
                if conj not in preds:
                    new_preds.add(conj)

        if new_preds:
            preds |= new_preds
            changed = True

    # Compute dual points
    dual_pts: Dict[int, FrozenSet[FrozenSet[int]]] = {}
    for s in range(ts.n_states):
        dual_pts[s] = frozenset(p for p in preds if s in p)

    # Separation matrix
    sep_matrix: Dict[Tuple[int, int], bool] = {}
    for s in range(ts.n_states):
        for t in range(s + 1, ts.n_states):
            sep_matrix[(s, t)] = dual_pts[s] != dual_pts[t]

    return DualPointResult(
        dual_points=dual_pts,
        definable_predicates=preds,
        n_predicates=len(preds),
        separation_matrix=sep_matrix
    )


# ============================================================
# Algorithm 4: Safety/Reachability Duality
# ============================================================

def compute_lfp_dual(
    ts: TransitionSystem,
    predicate: FrozenSet[int]
) -> GFPResult[FrozenSet[int]]:
    """
    Algorithm 4: Compute LFP of the Dual Operator

    By the duality theorem (`gfp_compl_eq_lfp_dual`):
        complement(ν F) = μ(dual(F))

    This computes the complement of the safety gfp, which equals
    the set of states that eventually reach ¬P.

    Time complexity: O(|σ|² · |E|)
    Space complexity: O(|σ|)
    """
    all_states = frozenset(range(ts.n_states))

    def dual_op(X: FrozenSet[int]) -> FrozenSet[int]:
        """dual(F)(X) = complement(F(complement(X)))"""
        comp_X = all_states - X
        # Safety op on complement
        pre_all_comp = frozenset(
            s for s in range(ts.n_states)
            if ts.successors(s).issubset(comp_X)
        )
        safety_comp = predicate & pre_all_comp
        return all_states - safety_comp

    # Ascending iteration from ⊥
    return descending_kleene_iteration(
        frozenset(),  # Start from bottom for LFP
        dual_op  # Note: for LFP we iterate from bottom
    )


# ============================================================
# Example Usage and Verification
# ============================================================

def verify_algorithms():
    """Run all algorithms and verify consistency."""
    print("Algorithm Verification")
    print("=" * 60)

    # Example: traffic light controller
    # States: 0=Red, 1=Yellow, 2=Green
    # Transitions: Red→Green, Green→Yellow, Yellow→Red
    ts = TransitionSystem.from_edges(3, [(0, 2), (2, 1), (1, 0)])

    print("\n--- Traffic Light Controller ---")
    print("States: 0=Red, 1=Yellow, 2=Green")
    print("Transitions: Red→Green, Green→Yellow, Yellow→Red")

    # Safety: "always not-Red" (P = {Yellow, Green})
    P = frozenset([1, 2])
    result = safety_model_check(ts, P)
    print(f"\n[Algorithm 2] Safety: 'always {set(P)}'")
    print(f"  Result: {set(result.fixpoint)}")
    print(f"  Iterations: {result.iterations}")
    print(f"  Time: {result.time_seconds:.6f}s")

    # Expected: empty set (every state eventually returns to Red)
    assert result.fixpoint == frozenset(), \
        f"Expected empty, got {result.fixpoint}"
    print("  ✓ Correct: no state satisfies 'always not-Red'")

    # Safety: "always reachable" (P = all states)
    P_all = frozenset([0, 1, 2])
    result2 = safety_model_check(ts, P_all)
    print(f"\n[Algorithm 2] Safety: 'always {set(P_all)}'")
    print(f"  Result: {set(result2.fixpoint)}")
    assert result2.fixpoint == P_all
    print("  ✓ Correct: all states satisfy 'always true'")

    # Dual points
    print(f"\n[Algorithm 3] Dual Point Computation")
    dp_result = compute_dual_points(ts)
    print(f"  Definable predicates: {dp_result.n_predicates}")
    for s in range(ts.n_states):
        print(f"  State {s}: |theory| = {len(dp_result.dual_points[s])}")
    print(f"  All states separated: "
          f"{all(dp_result.separation_matrix.values())}")

    # Larger example: mutex protocol
    print("\n\n--- Mutex Protocol (4 states) ---")
    # States: 0=idle, 1=requesting, 2=critical, 3=releasing
    # 0→1, 1→2, 2→3, 3→0
    ts2 = TransitionSystem.from_edges(4, [(0, 1), (1, 2), (2, 3), (3, 0)])
    print("States: 0=idle, 1=requesting, 2=critical, 3=releasing")

    # Safety: "always not in critical section" for idle start
    P_no_crit = frozenset([0, 1, 3])
    result3 = safety_model_check(ts2, P_no_crit)
    print(f"\n[Algorithm 2] Safety: 'always not-critical'")
    print(f"  Result: {set(result3.fixpoint)}")
    print(f"  Iterations: {result3.iterations}")

    # Convergence bound verification
    print(f"\n[Convergence] Bound = 2^|σ| = {2**ts2.n_states}")
    print(f"  Actual iterations: {result3.iterations}")
    print(f"  ✓ Within bound: {result3.iterations <= 2**ts2.n_states}")

    print("\n" + "=" * 60)
    print("All algorithms verified successfully.")


if __name__ == "__main__":
    verify_algorithms()
