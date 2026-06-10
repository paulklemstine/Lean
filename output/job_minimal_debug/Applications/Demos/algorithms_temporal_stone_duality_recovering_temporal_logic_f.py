#!/usr/bin/env python3
"""
Algorithms for Temporal Stone Duality
======================================

Implements the core algorithms from the research paper:

1. Descending Kleene Iteration for Greatest Fixpoint Computation
2. Ascending Kleene Iteration for Least Fixpoint Computation
3. Finite Model Checking via Safety Operator
4. Behavioral Equivalence via Dual Point Computation
5. Idempotent Semiring Fixpoint Computation
"""

from typing import Set, Dict, List, Tuple, FrozenSet, Callable, Optional
from dataclasses import dataclass
import time


# ---------------------------------------------------------------------------
# Data Structures
# ---------------------------------------------------------------------------

@dataclass(frozen=True)
class TransitionSystem:
    """
    A finite labeled transition system.

    Attributes:
        states: frozenset of states
        transitions: dict mapping state -> frozenset of successor states
        labels: dict mapping label name -> frozenset of states satisfying it
    """
    states: FrozenSet
    transitions: Dict
    labels: Dict

    @staticmethod
    def from_edges(states: set, edges: list, labels: dict = None) -> 'TransitionSystem':
        """Create a transition system from a list of (source, target) edges."""
        trans = {s: set() for s in states}
        for src, tgt in edges:
            trans[src].add(tgt)
        return TransitionSystem(
            states=frozenset(states),
            transitions={s: frozenset(t) for s, t in trans.items()},
            labels={k: frozenset(v) for k, v in (labels or {}).items()}
        )

    def successors(self, s) -> FrozenSet:
        return self.transitions.get(s, frozenset())


# ---------------------------------------------------------------------------
# Algorithm 1: Descending Kleene Iteration (Greatest Fixpoint)
# ---------------------------------------------------------------------------

def descending_kleene(
    operator: Callable[[FrozenSet], FrozenSet],
    top: FrozenSet,
    max_iter: Optional[int] = None
) -> Tuple[FrozenSet, List[FrozenSet], int]:
    """
    Descending Kleene iteration for computing greatest fixpoints.

    Given a monotone operator Φ on a finite powerset lattice,
    computes the greatest fixpoint by iterating from ⊤:
        X₀ = ⊤, X_{n+1} = Φ(Xₙ)
    until stabilization.

    Args:
        operator: monotone function on frozensets
        top: the top element (universe)
        max_iter: optional bound on iterations

    Returns:
        (fixpoint, history, num_iterations)

    Complexity:
        Time: O(n · |Φ|) where n = |top| and |Φ| is the cost of one operator application
        Space: O(n²) for storing the history
        Convergence: at most |top| iterations (by pigeonhole on strictly decreasing chain)
    """
    if max_iter is None:
        max_iter = len(top) + 1

    history = [top]
    current = top

    for i in range(1, max_iter + 1):
        next_val = operator(current)
        history.append(next_val)
        if next_val == current:
            return current, history, i
        current = next_val

    return current, history, max_iter


# ---------------------------------------------------------------------------
# Algorithm 2: Ascending Kleene Iteration (Least Fixpoint)
# ---------------------------------------------------------------------------

def ascending_kleene(
    operator: Callable[[FrozenSet], FrozenSet],
    bot: FrozenSet = frozenset(),
    top: FrozenSet = frozenset(),
    max_iter: Optional[int] = None
) -> Tuple[FrozenSet, List[FrozenSet], int]:
    """
    Ascending Kleene iteration for computing least fixpoints.

    Computes: X₀ = ⊥, X_{n+1} = Φ(Xₙ) until stabilization.

    Args:
        operator: monotone function on frozensets
        bot: the bottom element (usually empty set)
        top: universe (for bounding iterations)
        max_iter: optional bound

    Returns:
        (fixpoint, history, num_iterations)

    Complexity: Same as descending_kleene.
    """
    if max_iter is None:
        max_iter = len(top) + 1

    history = [bot]
    current = bot

    for i in range(1, max_iter + 1):
        next_val = operator(current)
        history.append(next_val)
        if next_val == current:
            return current, history, i
        current = next_val

    return current, history, max_iter


# ---------------------------------------------------------------------------
# Algorithm 3: Safety Model Checking
# ---------------------------------------------------------------------------

def safety_model_check(
    ts: TransitionSystem,
    safe_predicate: FrozenSet
) -> Tuple[FrozenSet, int, List[FrozenSet]]:
    """
    Model check "always P" via greatest fixpoint computation.

    Implements Theorem B: the set of states satisfying "always P"
    equals the greatest fixpoint of X ↦ P ∩ universalPre(X).

    Args:
        ts: the finite transition system
        safe_predicate: P, the set of safe states

    Returns:
        (safe_invariant, iterations, history)
        where safe_invariant = {s | always P holds at s}

    Complexity:
        Time: O(|S|² · |E|) where |S| = states, |E| = edges
        Space: O(|S|²)
        Convergence: at most |S| iterations

    Pseudocode:
        SAFETY-MODEL-CHECK(T, P):
          X ← S  (all states)
          repeat
            X' ← P ∩ {s ∈ S | ∀t. (s→t) ⟹ t ∈ X}
            if X' = X then return X
            X ← X'
    """
    def universal_pre(X: FrozenSet) -> FrozenSet:
        return frozenset(s for s in ts.states if ts.successors(s) <= X)

    def safety_op(X: FrozenSet) -> FrozenSet:
        return safe_predicate & universal_pre(X)

    return descending_kleene(safety_op, ts.states)


# ---------------------------------------------------------------------------
# Algorithm 4: Behavioral Equivalence via Dual Points
# ---------------------------------------------------------------------------

def compute_behavioral_equivalence(
    ts: TransitionSystem,
    depth: int = 3
) -> Dict[Tuple, FrozenSet]:
    """
    Compute behavioral equivalence classes via dual point theory.

    Implements Theorem A: two states are behaviorally equivalent iff
    they agree on all definable predicates (= have equal dual points).

    Args:
        ts: the transition system
        depth: formula depth for generating definable predicates

    Returns:
        Dictionary mapping each state to its equivalence class.

    Complexity:
        Time: O(|S| · |D|) where |D| = number of definable predicates
        Space: O(|S| · |D|)

    Pseudocode:
        BEHAVIORAL-EQUIV(T):
          D ← generate definable predicates of T
          for each state s:
            dual(s) ← {P ∈ D | s ∈ P}
          return partition by equal dual points
    """
    # Generate definable predicates by closure
    preds = set()
    preds.add(ts.states)  # ⊤
    preds.add(frozenset())  # ⊥

    # Add label predicates
    for name, states in ts.labels.items():
        preds.add(states)

    # Close under Boolean operations and modalities up to depth
    for _ in range(depth):
        new_preds = set()
        for P in preds:
            # Complement
            new_preds.add(ts.states - P)
            # Universal predecessor (□)
            box_P = frozenset(s for s in ts.states if ts.successors(s) <= P)
            new_preds.add(box_P)
            # Existential predecessor (◇)
            dia_P = frozenset(s for s in ts.states if ts.successors(s) & P)
            new_preds.add(dia_P)
        for P in preds:
            for Q in preds:
                new_preds.add(P & Q)
                new_preds.add(P | Q)
        preds |= new_preds

    # Compute dual points
    dual_points = {}
    for s in ts.states:
        dual_points[s] = frozenset(P for P in preds if s in P)

    # Partition into equivalence classes
    classes = {}
    for s in ts.states:
        key = dual_points[s]
        if key not in classes:
            classes[key] = set()
        classes[key].add(s)

    return {s: frozenset(classes[dual_points[s]]) for s in ts.states}


# ---------------------------------------------------------------------------
# Algorithm 5: Complete Model Checking Pipeline
# ---------------------------------------------------------------------------

def model_checking_pipeline(
    ts: TransitionSystem,
    property_name: str
) -> dict:
    """
    Complete model checking pipeline (Theorem A + B + C).

    Implements the full reduction:
        temporal formula → monotone operator → finite iteration →
        fixpoint → behavioral equivalence → decidability

    Args:
        ts: the finite transition system
        property_name: name of the atomic proposition to check "always P"

    Returns:
        Dictionary with all results:
        - 'safe_states': states satisfying P
        - 'invariant': states satisfying "always P"
        - 'iterations': number of Kleene iterations
        - 'history': iteration history
        - 'equiv_classes': behavioral equivalence classes
        - 'is_decidable': True (always, for finite systems)
    """
    P = ts.labels.get(property_name, frozenset())

    # Step 1: Compute GFP (Theorems B + C)
    invariant, iterations, history = safety_model_check(ts, P)

    # Step 2: Compute behavioral equivalence (Theorem A)
    equiv = compute_behavioral_equivalence(ts)

    return {
        'safe_states': P,
        'invariant': invariant,
        'iterations': iterations,
        'history': history,
        'equiv_classes': equiv,
        'is_decidable': True,
        'num_states': len(ts.states),
        'num_safe': len(P),
        'num_invariant': len(invariant),
    }


# ---------------------------------------------------------------------------
# Benchmarks
# ---------------------------------------------------------------------------

def benchmark_chain(n: int) -> dict:
    """Benchmark on a chain graph: 0 → 1 → 2 → ... → n-1 → 0."""
    states = set(range(n))
    edges = [(i, (i + 1) % n) for i in range(n)]
    labels = {'safe': frozenset(range(n - 1))}  # all except last
    ts = TransitionSystem.from_edges(states, edges, labels)

    start = time.time()
    result = model_checking_pipeline(ts, 'safe')
    elapsed = time.time() - start

    return {
        'n': n,
        'time': elapsed,
        'iterations': result['iterations'],
        'invariant_size': result['num_invariant'],
    }


def benchmark_complete(n: int) -> dict:
    """Benchmark on a complete graph with n states."""
    states = set(range(n))
    edges = [(i, j) for i in range(n) for j in range(n)]
    labels = {'safe': frozenset(range(n))}
    ts = TransitionSystem.from_edges(states, edges, labels)

    start = time.time()
    result = model_checking_pipeline(ts, 'safe')
    elapsed = time.time() - start

    return {
        'n': n,
        'time': elapsed,
        'iterations': result['iterations'],
        'invariant_size': result['num_invariant'],
    }


if __name__ == "__main__":
    print("Algorithm Benchmarks")
    print("=" * 60)

    print("\nChain graphs (0 → 1 → ... → n-1 → 0):")
    print(f"{'n':>6} {'time (ms)':>12} {'iterations':>12} {'|invariant|':>12}")
    for n in [10, 50, 100, 500, 1000]:
        r = benchmark_chain(n)
        print(f"{r['n']:>6} {r['time']*1000:>12.2f} {r['iterations']:>12} {r['invariant_size']:>12}")

    print("\nComplete graphs (n states, all edges):")
    print(f"{'n':>6} {'time (ms)':>12} {'iterations':>12} {'|invariant|':>12}")
    for n in [5, 10, 20, 50]:
        r = benchmark_complete(n)
        print(f"{r['n']:>6} {r['time']*1000:>12.2f} {r['iterations']:>12} {r['invariant_size']:>12}")
