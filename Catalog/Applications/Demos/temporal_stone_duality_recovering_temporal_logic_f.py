#!/usr/bin/env python3
"""
Applications of Temporal Stone Duality
=======================================

Real-world applications of fixpoint-based temporal model checking:
1. Network protocol verification (deadlock detection)
2. Concurrent system safety analysis
3. Game-theoretic safety verification
4. Distributed system invariant checking
"""

from typing import Dict, FrozenSet, List, Set, Tuple
from algorithms import (
    TransitionSystem, safety_model_check, compute_dual_points,
    descending_kleene_iteration
)


# ============================================================
# Application 1: Network Protocol Verification
# ============================================================

def app_network_protocol():
    """
    Verify safety properties of a simplified TCP-like protocol.

    States represent connection phases:
    0 = Closed
    1 = SYN_SENT
    2 = SYN_RECEIVED
    3 = ESTABLISHED
    4 = FIN_WAIT
    5 = TIME_WAIT
    6 = ERROR (unrecoverable)
    """
    print("=" * 60)
    print("Application 1: Network Protocol Verification")
    print("=" * 60)

    ts = TransitionSystem.from_edges(7, [
        (0, 1),  # Closed → SYN_SENT
        (1, 2),  # SYN_SENT → SYN_RECEIVED
        (1, 6),  # SYN_SENT → ERROR (timeout)
        (2, 3),  # SYN_RECEIVED → ESTABLISHED
        (2, 6),  # SYN_RECEIVED → ERROR
        (3, 4),  # ESTABLISHED → FIN_WAIT
        (3, 3),  # ESTABLISHED → ESTABLISHED (data transfer)
        (4, 5),  # FIN_WAIT → TIME_WAIT
        (5, 0),  # TIME_WAIT → Closed
        (6, 6),  # ERROR → ERROR (stuck)
    ])

    state_names = {
        0: "Closed", 1: "SYN_SENT", 2: "SYN_RECEIVED",
        3: "ESTABLISHED", 4: "FIN_WAIT", 5: "TIME_WAIT", 6: "ERROR"
    }

    # Safety property: "always not in ERROR state"
    P_no_error = frozenset([0, 1, 2, 3, 4, 5])
    result = safety_model_check(ts, P_no_error)

    print("\nSafety: 'Connection never enters ERROR state'")
    safe_states = result.fixpoint
    print(f"Safe states: {{{', '.join(state_names[s] for s in sorted(safe_states))}}}")
    print(f"Unsafe states: {{{', '.join(state_names[s] for s in sorted(set(range(7)) - safe_states))}}}")
    print(f"Iterations to converge: {result.iterations}")

    # Safety property: "always can eventually close"
    P_closable = frozenset([0, 3, 4, 5])  # States from which closing is possible
    result2 = safety_model_check(ts, P_closable)
    print(f"\nSafety: 'Always in a closable state'")
    print(f"Result: {{{', '.join(state_names[s] for s in sorted(result2.fixpoint))}}}")

    # Behavioral analysis
    dp = compute_dual_points(ts)
    print(f"\nBehavioral analysis:")
    print(f"  Definable predicates: {dp.n_predicates}")
    print(f"  All states distinguishable: {all(dp.separation_matrix.values())}")


# ============================================================
# Application 2: Concurrent System Safety
# ============================================================

def app_concurrent_safety():
    """
    Verify mutual exclusion in a Peterson-style protocol.

    States encode (process1_state, process2_state):
    0 = (idle, idle)
    1 = (requesting, idle)
    2 = (idle, requesting)
    3 = (critical, idle)
    4 = (idle, critical)
    5 = (requesting, requesting)  → one wins
    6 = (critical, requesting)    → p1 in critical, p2 waiting
    7 = (requesting, critical)    → p2 in critical, p1 waiting
    # NO state (critical, critical) — mutual exclusion
    """
    print("\n" + "=" * 60)
    print("Application 2: Concurrent System Safety (Mutex)")
    print("=" * 60)

    ts = TransitionSystem.from_edges(8, [
        (0, 1), (0, 2),     # Either process requests
        (1, 3), (1, 5),     # p1 enters critical or p2 also requests
        (2, 4), (2, 5),     # p2 enters critical or p1 also requests
        (3, 0),             # p1 leaves critical
        (4, 0),             # p2 leaves critical
        (5, 6), (5, 7),     # Contention: one wins
        (6, 4),             # p1 done, p2 enters
        (7, 3),             # p2 done, p1 enters
    ])

    # Safety: "never in mutual violation" (no state (critical, critical))
    # All states are safe since we don't have a (critical, critical) state
    P_mutex = frozenset(range(8))  # All states preserve mutex
    result = safety_model_check(ts, P_mutex)
    print(f"\nMutual exclusion holds from: {set(result.fixpoint)}")
    print(f"  (All {len(result.fixpoint)} states are safe)")

    # Liveness-related safety: "requesting processes eventually get served"
    # Check: from any state, can we always stay in non-deadlock states?
    P_no_deadlock = frozenset(s for s in range(8) if ts.successors(s))
    result2 = safety_model_check(ts, P_no_deadlock)
    print(f"\nNo deadlock: {set(result2.fixpoint)}")


# ============================================================
# Application 3: Game Safety (Reachability Games)
# ============================================================

def app_game_safety():
    """
    Safety verification for a simple pursuit-evasion game.

    The evader wants to always stay safe; the pursuer wants to
    eventually catch the evader. The gfp of the safety operator
    gives the evader's winning region.

    Grid: 3x3, evader moves first, pursuer mirrors
    States encode (evader_pos, pursuer_pos) but simplified here.
    """
    print("\n" + "=" * 60)
    print("Application 3: Game Safety (Pursuit-Evasion)")
    print("=" * 60)

    # Simplified: 6 states representing game positions
    # 0,1,2 = evader safe, 3,4,5 = evader caught (unsafe)
    ts = TransitionSystem.from_edges(6, [
        (0, 1), (0, 2),     # Evader moves
        (1, 0), (1, 3),     # Safe → safe or caught
        (2, 0), (2, 4),     # Safe → safe or caught
        (3, 3),             # Caught (absorbing)
        (4, 4),             # Caught (absorbing)
        (5, 5),             # Caught (absorbing)
    ])

    P_safe = frozenset([0, 1, 2])
    result = safety_model_check(ts, P_safe)
    print(f"\nEvader's winning region (always safe): {set(result.fixpoint)}")
    print(f"Iterations: {result.iterations}")

    if result.fixpoint:
        print("  Evader can guarantee safety from these positions!")
    else:
        print("  Pursuer wins from all positions.")

    # The trace shows how the safe region shrinks
    print("\nIteration trace (safe region shrinks):")
    for i, X in enumerate(result.trace):
        print(f"  Step {i}: {set(X)}")


# ============================================================
# Application 4: Distributed Invariant Checking
# ============================================================

def app_distributed_invariant():
    """
    Check invariants of a token-ring protocol.

    States represent which node holds the token in a 4-node ring.
    The invariant: exactly one node holds the token at all times.
    """
    print("\n" + "=" * 60)
    print("Application 4: Distributed System (Token Ring)")
    print("=" * 60)

    # 4 nodes, token passes around the ring
    # State i = node i holds the token
    # Plus error states 4,5 for token loss/duplication
    ts = TransitionSystem.from_edges(6, [
        (0, 1),  # Pass token 0→1
        (1, 2),  # Pass token 1→2
        (2, 3),  # Pass token 2→3
        (3, 0),  # Pass token 3→0
        (0, 4),  # Token lost (error)
        (4, 4),  # Error absorbing
        (5, 5),  # Duplicate token error absorbing
    ])

    # Safety: "token is always held by exactly one node"
    P_valid = frozenset([0, 1, 2, 3])  # Valid states
    result = safety_model_check(ts, P_valid)
    print(f"\nValid token states: {set(result.fixpoint)}")
    print(f"  These states guarantee the token-ring invariant forever.")

    unsafe = set(range(6)) - result.fixpoint
    if unsafe:
        print(f"  Unsafe states (can lose invariant): {unsafe}")

    # Behavioral equivalence analysis
    dp = compute_dual_points(ts)
    print(f"\nBehavioral equivalence classes:")
    classes: Dict[FrozenSet, List[int]] = {}
    for s in range(ts.n_states):
        key = dp.dual_points[s]
        if key not in classes:
            classes[key] = []
        classes[key].append(s)

    for i, (_, states) in enumerate(classes.items()):
        state_names = [str(s) for s in states]
        print(f"  Class {i}: {{{', '.join(state_names)}}}")


if __name__ == "__main__":
    app_network_protocol()
    app_concurrent_safety()
    app_game_safety()
    app_distributed_invariant()
    print("\n" + "=" * 60)
    print("All applications completed successfully.")
    print("=" * 60)


#!/usr/bin/env python3
"""
Temporal Stone Duality: Recovering Temporal Logic from Fixpoint Algebra
=======================================================================

Concrete demonstrations of the theorems proved in the formal development.
Shows how model checking reduces to fixpoint iteration, how behavioral
equivalence is captured by dual points, and how the idempotent semiring
structure enables algebraic verification.
"""

import itertools
from typing import Dict, FrozenSet, Set, Tuple, List


# --- Finite Transition System ---

class FTS:
    """A finite transition system with states 0..n-1."""

    def __init__(self, n: int, edges: List[Tuple[int, int]]):
        self.n = n
        self.states = set(range(n))
        self.edges = {}  # state -> set of successors
        for s in range(n):
            self.edges[s] = set()
        for s, t in edges:
            self.edges[s].add(t)

    def successors(self, s: int) -> Set[int]:
        return self.edges.get(s, set())

    def __repr__(self):
        return f"FTS(n={self.n}, edges={self.edges})"


# --- Predecessor Operators ---

def pre_all(fts: FTS, X: FrozenSet[int]) -> FrozenSet[int]:
    """Universal predecessor: states whose ALL successors are in X."""
    return frozenset(s for s in fts.states if fts.successors(s).issubset(X))


def pre_ex(fts: FTS, X: FrozenSet[int]) -> FrozenSet[int]:
    """Existential predecessor: states with SOME successor in X."""
    return frozenset(s for s in fts.states if fts.successors(s) & X)


# --- Safety Operator and GFP Computation ---

def box_op(fts: FTS, P: FrozenSet[int], X: FrozenSet[int]) -> FrozenSet[int]:
    """Safety operator: Φ_P(X) = P ∩ preAll(X)."""
    return P & pre_all(fts, X)


def compute_gfp(fts: FTS, P: FrozenSet[int]) -> Tuple[FrozenSet[int], int, List[FrozenSet[int]]]:
    """
    Compute the greatest fixpoint of the safety operator by
    descending Kleene iteration from ⊤ (= all states).

    Returns (gfp, num_iterations, trace_of_iterates).
    """
    top = frozenset(fts.states)
    current = top
    trace = [current]
    n_iter = 0

    while True:
        next_val = box_op(fts, P, current)
        n_iter += 1
        trace.append(next_val)
        if next_val == current:
            break
        current = next_val

    return current, n_iter, trace


# --- "Always P" Semantics (direct definition) ---

def satisfies_always(fts: FTS, P: FrozenSet[int], s: int, max_depth: int = 100) -> bool:
    """
    Check if state s satisfies 'always P': P holds at s and at
    every state reachable from s (BFS up to max_depth).
    """
    visited = set()
    frontier = {s}
    depth = 0

    while frontier and depth <= max_depth:
        for state in frontier:
            if state not in P:
                return False
        visited |= frontier
        next_frontier = set()
        for state in frontier:
            next_frontier |= fts.successors(state) - visited
        frontier = next_frontier
        depth += 1

    return True


def compute_always_set(fts: FTS, P: FrozenSet[int]) -> FrozenSet[int]:
    """Compute {s | satisfiesAlways(T, P, s)} directly."""
    return frozenset(s for s in fts.states if satisfies_always(fts, P, s))


# --- Behavioral Equivalence and Dual Points ---

def compute_definable_preds(fts: FTS) -> Set[FrozenSet[int]]:
    """
    Compute the set of all definable predicates (reachable by TLF formulas).
    This is a finite Boolean algebra over the finite state space.
    """
    preds = set()

    # Atoms: all singletons
    for s in fts.states:
        preds.add(frozenset([s]))

    # Top
    preds.add(frozenset(fts.states))

    # Generate all conjunctions and box applications up to closure
    changed = True
    while changed:
        changed = False
        new_preds = set()
        for p in preds:
            # box (pre_all)
            bp = pre_all(fts, p)
            if bp not in preds:
                new_preds.add(bp)

            # always (gfp)
            gfp, _, _ = compute_gfp(fts, p)
            if gfp not in preds:
                new_preds.add(gfp)

        # Conjunctions (pairwise)
        preds_list = list(preds)
        for i in range(len(preds_list)):
            for j in range(i, len(preds_list)):
                conj = preds_list[i] & preds_list[j]
                if conj not in preds:
                    new_preds.add(conj)

        if new_preds:
            preds |= new_preds
            changed = True

    return preds


def dual_point(fts: FTS, s: int, preds: Set[FrozenSet[int]]) -> FrozenSet:
    """The dual point of state s: the set of definable predicates containing s."""
    return frozenset(p for p in preds if s in p)


# === DEMO 1: Fixpoint Iteration ===

def demo_fixpoint_iteration():
    """Demonstrate that gfp of safety operator = 'always P' semantics."""
    print("=" * 70)
    print("DEMO 1: Fixpoint Iteration = 'Always P' Semantics")
    print("=" * 70)

    # A simple transition system: 0 → 1 → 2 → 3 → 3 (self-loop)
    #                              0 → 4 (deadlock)
    fts = FTS(5, [(0, 1), (0, 4), (1, 2), (2, 3), (3, 3)])
    P = frozenset([0, 1, 2, 3])  # P = all except state 4

    print(f"\nTransition system: {fts.n} states")
    for s in range(fts.n):
        print(f"  {s} → {fts.successors(s)}")
    print(f"\nPredicate P = {set(P)}")

    # Compute gfp
    gfp, n_iter, trace = compute_gfp(fts, P)
    print(f"\nDescending Kleene iteration (from ⊤ = {set(fts.states)}):")
    for i, t in enumerate(trace):
        print(f"  Iter {i}: {set(t)}")
    print(f"\nGFP = {set(gfp)} (converged in {n_iter} iterations)")

    # Compute always set directly
    always_set = compute_always_set(fts, P)
    print(f"Always-P set (direct) = {set(always_set)}")
    print(f"\n✓ GFP == Always-P: {gfp == always_set}")

    # Verify: state 0 reaches state 4 ∉ P, so 0 ∉ always-P
    # States 1,2,3 stay in P forever (3 loops)
    print("\nInterpretation:")
    for s in range(fts.n):
        status = "✓ always P" if s in always_set else "✗ not always P"
        print(f"  State {s}: {status}")


# === DEMO 2: Convergence Bound ===

def demo_convergence_bound():
    """Show that iteration converges within |states| steps."""
    print("\n" + "=" * 70)
    print("DEMO 2: Convergence Bound")
    print("=" * 70)

    # Chain of states: 0 → 1 → 2 → ... → n-1 → n-1
    for n in [3, 5, 8, 10]:
        edges = [(i, i + 1) for i in range(n - 1)] + [(n - 1, n - 1)]
        fts = FTS(n, edges)
        P = frozenset(range(1, n))  # P excludes state 0

        gfp, n_iter, trace = compute_gfp(fts, P)
        print(f"  n={n}: converged in {n_iter} iterations (bound = {2**n}), "
              f"gfp = {set(gfp)}")


# === DEMO 3: Dual Points and Behavioral Equivalence ===

def demo_dual_points():
    """Demonstrate that dual points separate states."""
    print("\n" + "=" * 70)
    print("DEMO 3: Dual Points and Behavioral Equivalence")
    print("=" * 70)

    # Two states with identical local structure but different global behavior
    # 0 → 1, 1 → 1 (loop)
    # 2 → 3, 3 → 4, 4 → 4 (longer chain then loop)
    fts = FTS(5, [(0, 1), (1, 1), (2, 3), (3, 4), (4, 4)])

    print(f"\nTransition system:")
    for s in range(fts.n):
        print(f"  {s} → {fts.successors(s)}")

    preds = compute_definable_preds(fts)
    print(f"\nNumber of definable predicates: {len(preds)}")

    print("\nDual points (theories of states):")
    dual_points = {}
    for s in range(fts.n):
        dp = dual_point(fts, s, preds)
        dual_points[s] = dp
        print(f"  State {s}: |theory| = {len(dp)}")

    print("\nSeparation check (distinct states → distinct dual points):")
    for s in range(fts.n):
        for t in range(s + 1, fts.n):
            separated = dual_points[s] != dual_points[t]
            print(f"  States {s}, {t}: {'separated ✓' if separated else 'NOT separated ✗'}")


# === DEMO 4: Idempotent Semiring Structure ===

def demo_semiring():
    """Demonstrate the idempotent semiring structure of Set σ."""
    print("\n" + "=" * 70)
    print("DEMO 4: Idempotent Semiring Structure")
    print("=" * 70)

    states = frozenset(range(4))
    A = frozenset([0, 1])
    B = frozenset([1, 2])
    C = frozenset([2, 3])

    print(f"\nStates = {set(states)}")
    print(f"A = {set(A)}, B = {set(B)}, C = {set(C)}")

    # Union is idempotent (addition)
    print(f"\nA ∪ A = {set(A | A)} (idempotent: {A | A == A})")

    # Intersection distributes over union (multiplication over addition)
    lhs = A & (B | C)
    rhs = (A & B) | (A & C)
    print(f"A ∩ (B ∪ C) = {set(lhs)}")
    print(f"(A ∩ B) ∪ (A ∩ C) = {set(rhs)}")
    print(f"Distributivity: {lhs == rhs}")

    # Natural order: A ⊆ B iff A ∪ B = B
    print(f"\nA ⊆ (A ∪ B) ↔ A ∪ (A ∪ B) = (A ∪ B): "
          f"{A | (A | B) == A | B}")


# === DEMO 5: Safety/Reachability Duality ===

def demo_duality():
    """Demonstrate ν/μ duality via complementation."""
    print("\n" + "=" * 70)
    print("DEMO 5: Safety/Reachability (ν/μ) Duality")
    print("=" * 70)

    # Ring: 0 → 1 → 2 → 0
    fts = FTS(3, [(0, 1), (1, 2), (2, 0)])
    P = frozenset([0, 1])  # P = {0, 1}

    print(f"\nTransition system (ring): {fts.n} states")
    for s in range(fts.n):
        print(f"  {s} → {fts.successors(s)}")
    print(f"P = {set(P)}")

    # GFP (safety / "always P")
    gfp, _, _ = compute_gfp(fts, P)
    print(f"\nν(safety operator) = {set(gfp)}")
    print(f"  = states where P holds invariantly")

    # Complement = LFP of dual (reachability / "eventually ¬P")
    complement = fts.states - gfp
    print(f"\nComplement of ν = {set(complement)}")
    print(f"  = states that eventually reach ¬P")

    # Direct reachability check
    not_P = fts.states - P
    print(f"\n¬P = {set(not_P)}")
    for s in fts.states:
        reaches_not_P = any(
            satisfies_always(fts, frozenset(fts.states - not_P), s) is False
            for _ in [None]
        )
        # Actually check if s can reach ¬P
        visited = set()
        frontier = {s}
        can_reach = False
        while frontier:
            for state in frontier:
                if state in not_P:
                    can_reach = True
                    break
            if can_reach:
                break
            visited |= frontier
            frontier = set().union(*(fts.successors(x) for x in frontier)) - visited
        status = "reaches ¬P" if can_reach else "never reaches ¬P"
        in_complement = "in complement" if s in complement else "not in complement"
        print(f"  State {s}: {status} ({in_complement})")


if __name__ == "__main__":
    demo_fixpoint_iteration()
    demo_convergence_bound()
    demo_dual_points()
    demo_semiring()
    demo_duality()
    print("\n" + "=" * 70)
    print("All demos completed successfully.")
    print("=" * 70)


#!/usr/bin/env python3
"""Generate PACKAGE.json with all artifacts."""

import json
import sys

# Read all source files
def read_file(path):
    with open(path, 'r') as f:
        return f.read()

article = read_file('ARTICLE.md')
research_paper = read_file('RESEARCH_PAPER.md')
future_directions = read_file('FUTURE_DIRECTIONS.md')
demo_code = read_file('demo.py')
algorithms_code = read_file('algorithms.py')
applications_code = read_file('applications.py')
lean_code = read_file('Logic/TemporalFixpointSemantics.lean')
lean_bridge = read_file('Bridges/LogicComputation/TemporalStoneSemiringDuality.lean')

# Generate visualizations
import matplotlib
matplotlib.use('Agg')
from visualizations import viz_fixpoint_convergence, viz_dual_points, viz_safety_operator, viz_duality

b64_conv = viz_fixpoint_convergence()
b64_dual = viz_dual_points()
b64_safety = viz_safety_operator()
b64_duality = viz_duality()

package = {
    "title": "Temporal Stone Duality: Recovering Temporal Logic from Idempotent Semiring Fixpoints",
    "domain": "Logic / Order Theory / Formal Verification",
    "article": article,
    "research_paper": research_paper,
    "future_directions": future_directions,
    "demos": [
        {
            "name": "Fixpoint Iteration and Model Checking Demo",
            "code": demo_code
        },
        {
            "name": "Applications: Protocol and System Verification",
            "code": applications_code
        }
    ],
    "algorithms": [
        {
            "name": "Descending Kleene Iteration (GFP Computation)",
            "pseudocode": "Input: Finite lattice α, monotone F : α → α\nOutput: gfp(F)\n\nX ← ⊤\nrepeat\n    X' ← F(X)\n    if X' = X then return X\n    X ← X'\n\nComplexity: O(|α| · cost(F)) time, O(|α|) space\nTermination: Guaranteed in ≤ |α| iterations (Theorem 3.4)",
            "code": algorithms_code
        }
    ],
    "visualizations": [
        {
            "name": "Fixpoint Iteration Convergence",
            "data": b64_conv
        },
        {
            "name": "Dual Point Structure and Behavioral Separation",
            "data": b64_dual
        },
        {
            "name": "Safety Operator and Fixpoint Structure",
            "data": b64_safety
        },
        {
            "name": "Order Duality: Greatest vs Least Fixpoints",
            "data": b64_duality
        }
    ],
    "lean_proofs": lean_code + "\n\n-- Bridge file:\n\n" + lean_bridge
}

with open('PACKAGE.json', 'w') as f:
    json.dump(package, f, indent=2, ensure_ascii=False)

print(f"Generated PACKAGE.json ({len(json.dumps(package))} chars)")


#!/usr/bin/env python3
"""
Visualizations for Temporal Stone Duality
==========================================

Generates matplotlib figures showing:
1. Fixpoint iteration convergence
2. Lattice of definable predicates
3. Dual point separation
4. Safety operator action
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np
from algorithms import TransitionSystem, safety_model_check, compute_dual_points
import base64
import io


def fig_to_base64(fig) -> str:
    """Convert a matplotlib figure to a base64 data URI."""
    buf = io.BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight')
    buf.seek(0)
    b64 = base64.b64encode(buf.read()).decode('utf-8')
    plt.close(fig)
    return f"data:image/png;base64,{b64}"


def viz_fixpoint_convergence():
    """Visualize the descending Kleene iteration converging to the GFP."""
    fig, axes = plt.subplots(1, 3, figsize=(15, 5))

    # Example: chain 0 → 1 → 2 → 3 → 4 → 4
    # P = {1, 2, 3, 4} (exclude state 0)
    ts = TransitionSystem.from_edges(5, [
        (0, 1), (1, 2), (2, 3), (3, 4), (4, 4)
    ])
    P = frozenset([1, 2, 3, 4])
    result = safety_model_check(ts, P)

    # Plot 1: Set sizes over iterations
    ax = axes[0]
    sizes = [len(X) for X in result.trace]
    ax.plot(range(len(sizes)), sizes, 'bo-', linewidth=2, markersize=8)
    ax.set_xlabel('Iteration', fontsize=12)
    ax.set_ylabel('|X_n|', fontsize=12)
    ax.set_title('Descending Chain\n(Set Size vs Iteration)', fontsize=13)
    ax.set_xticks(range(len(sizes)))
    ax.grid(True, alpha=0.3)
    ax.fill_between(range(len(sizes)), sizes, alpha=0.15, color='blue')

    # Plot 2: State membership across iterations
    ax = axes[1]
    n_states = ts.n_states
    n_iters = len(result.trace)
    membership = np.zeros((n_states, n_iters))
    for j, X in enumerate(result.trace):
        for s in X:
            membership[s, j] = 1

    im = ax.imshow(membership, cmap='Blues', aspect='auto',
                   interpolation='nearest')
    ax.set_xlabel('Iteration', fontsize=12)
    ax.set_ylabel('State', fontsize=12)
    ax.set_title('State Membership\n(Blue = in X_n)', fontsize=13)
    ax.set_xticks(range(n_iters))
    ax.set_yticks(range(n_states))
    plt.colorbar(im, ax=ax, shrink=0.8)

    # Plot 3: Convergence for different system sizes
    ax = axes[2]
    sizes_list = [3, 5, 8, 12, 15]
    iters_list = []
    for n in sizes_list:
        edges = [(i, i+1) for i in range(n-1)] + [(n-1, n-1)]
        ts_n = TransitionSystem.from_edges(n, edges)
        P_n = frozenset(range(1, n))
        res = safety_model_check(ts_n, P_n)
        iters_list.append(res.iterations)

    ax.bar(range(len(sizes_list)), iters_list, color='steelblue', alpha=0.7)
    ax.plot(range(len(sizes_list)), sizes_list, 'r--', linewidth=2,
            label='|states| bound')
    ax.set_xticks(range(len(sizes_list)))
    ax.set_xticklabels([str(n) for n in sizes_list])
    ax.set_xlabel('Number of States', fontsize=12)
    ax.set_ylabel('Iterations to Converge', fontsize=12)
    ax.set_title('Convergence Speed\nvs System Size', fontsize=13)
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)

    fig.suptitle('Fixpoint Iteration Convergence', fontsize=15, fontweight='bold')
    plt.tight_layout()
    fig.savefig('viz_convergence.png', dpi=150, bbox_inches='tight')
    b64 = fig_to_base64(fig)
    print("Generated viz_convergence.png")
    return b64


def viz_dual_points():
    """Visualize the dual point structure and separation."""
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))

    # Example transition system
    ts = TransitionSystem.from_edges(5, [
        (0, 1), (1, 1), (2, 3), (3, 4), (4, 4)
    ])

    dp = compute_dual_points(ts)

    # Plot 1: Dual point sizes
    ax = axes[0]
    sizes = [len(dp.dual_points[s]) for s in range(ts.n_states)]
    colors = plt.cm.Set2(np.linspace(0, 1, ts.n_states))
    bars = ax.bar(range(ts.n_states), sizes, color=colors, edgecolor='black',
                  linewidth=1.5)
    ax.set_xlabel('State', fontsize=12)
    ax.set_ylabel('|Theory(s)|', fontsize=12)
    ax.set_title('Theory Size per State\n(Dual Point Cardinality)', fontsize=13)
    ax.set_xticks(range(ts.n_states))
    for i, (bar, size) in enumerate(zip(bars, sizes)):
        ax.text(bar.get_x() + bar.get_width()/2, bar.get_height() + 0.1,
                str(size), ha='center', va='bottom', fontweight='bold')
    ax.grid(True, alpha=0.3, axis='y')

    # Plot 2: Separation matrix (Hamming distance between dual points)
    ax = axes[1]
    n = ts.n_states
    dist_matrix = np.zeros((n, n))
    for s in range(n):
        for t in range(n):
            # Symmetric difference of theories
            diff = dp.dual_points[s].symmetric_difference(dp.dual_points[t])
            dist_matrix[s, t] = len(diff)

    im = ax.imshow(dist_matrix, cmap='YlOrRd', interpolation='nearest')
    ax.set_xlabel('State', fontsize=12)
    ax.set_ylabel('State', fontsize=12)
    ax.set_title('Theory Distance Matrix\n(|Theory(s) △ Theory(t)|)', fontsize=13)
    ax.set_xticks(range(n))
    ax.set_yticks(range(n))
    for i in range(n):
        for j in range(n):
            ax.text(j, i, str(int(dist_matrix[i, j])),
                    ha='center', va='center', fontsize=11,
                    color='white' if dist_matrix[i, j] > dist_matrix.max()/2 else 'black')
    plt.colorbar(im, ax=ax, shrink=0.8)

    fig.suptitle('Dual Point Structure and Behavioral Separation',
                 fontsize=15, fontweight='bold')
    plt.tight_layout()
    fig.savefig('viz_dual_points.png', dpi=150, bbox_inches='tight')
    b64 = fig_to_base64(fig)
    print("Generated viz_dual_points.png")
    return b64


def viz_safety_operator():
    """Visualize the safety operator's action on the predicate lattice."""
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))

    # Traffic light: 0=Red, 1=Yellow, 2=Green
    ts = TransitionSystem.from_edges(3, [(0, 2), (2, 1), (1, 0)])

    # Plot 1: Iteration trace for different predicates
    ax = axes[0]
    predicates = [
        (frozenset([0, 1, 2]), "All states", 'steelblue'),
        (frozenset([1, 2]), "Not-Red", 'coral'),
        (frozenset([0, 1]), "Not-Green", 'mediumseagreen'),
        (frozenset([0]), "Only Red", 'gold'),
    ]

    for P, label, color in predicates:
        result = safety_model_check(ts, P)
        sizes = [len(X) for X in result.trace]
        ax.plot(range(len(sizes)), sizes, 'o-', label=label,
                color=color, linewidth=2, markersize=7)

    ax.set_xlabel('Iteration', fontsize=12)
    ax.set_ylabel('|X_n|', fontsize=12)
    ax.set_title('Safety Iteration\nfor Different Predicates', fontsize=13)
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)
    ax.set_xticks(range(6))

    # Plot 2: Lattice of fixpoint-definable predicates
    ax = axes[1]
    all_subsets = []
    for r in range(4):
        for s in __import__('itertools').combinations(range(3), r):
            all_subsets.append(frozenset(s))

    # Compute which are fixpoint-definable
    fixpoint_preds = set()
    for sub in all_subsets:
        result = safety_model_check(ts, sub)
        fixpoint_preds.add(result.fixpoint)

    # Draw Hasse diagram (simplified)
    positions = {}
    y_levels = {0: [], 1: [], 2: [], 3: []}
    for s in all_subsets:
        y_levels[len(s)].append(s)

    for level, subsets in y_levels.items():
        for i, s in enumerate(subsets):
            x = (i - len(subsets)/2 + 0.5) * 1.5
            positions[s] = (x, level)

    for s, (x, y) in positions.items():
        is_fp = s in fixpoint_preds
        color = 'steelblue' if is_fp else 'lightgray'
        edge = 'darkblue' if is_fp else 'gray'
        size = 800 if is_fp else 400
        ax.scatter(x, y, s=size, c=color, edgecolors=edge,
                   linewidths=2, zorder=5)
        label = str(set(s)) if s else '∅'
        ax.annotate(label, (x, y), textcoords="offset points",
                    xytext=(0, -20), ha='center', fontsize=8)

    # Draw edges (inclusion)
    for s in all_subsets:
        for t in all_subsets:
            if s < t and len(t) == len(s) + 1:
                x1, y1 = positions[s]
                x2, y2 = positions[t]
                ax.plot([x1, x2], [y1, y2], 'gray', alpha=0.3, linewidth=1)

    ax.set_title('Predicate Lattice\n(Blue = Fixpoint-Definable)', fontsize=13)
    ax.set_ylabel('Subset Size', fontsize=12)
    ax.set_yticks(range(4))
    ax.set_xlim(-3, 3)

    legend_elements = [
        mpatches.Patch(facecolor='steelblue', edgecolor='darkblue',
                       label='Fixpoint-definable'),
        mpatches.Patch(facecolor='lightgray', edgecolor='gray',
                       label='Not fixpoint-definable'),
    ]
    ax.legend(handles=legend_elements, fontsize=10, loc='upper right')

    fig.suptitle('Safety Operator and Fixpoint Structure',
                 fontsize=15, fontweight='bold')
    plt.tight_layout()
    fig.savefig('viz_safety_operator.png', dpi=150, bbox_inches='tight')
    b64 = fig_to_base64(fig)
    print("Generated viz_safety_operator.png")
    return b64


def viz_duality():
    """Visualize ν/μ duality: safety vs reachability."""
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))

    # Ring: 0 → 1 → 2 → 3 → 0
    ts = TransitionSystem.from_edges(4, [(0, 1), (1, 2), (2, 3), (3, 0)])

    predicates_to_check = [
        frozenset([0, 1]),
        frozenset([0, 1, 2]),
        frozenset([0]),
        frozenset([0, 1, 2, 3]),
    ]

    # Plot 1: GFP sizes for different predicates
    ax = axes[0]
    gfp_sizes = []
    complement_sizes = []
    labels = []
    for P in predicates_to_check:
        result = safety_model_check(ts, P)
        gfp_sizes.append(len(result.fixpoint))
        complement_sizes.append(4 - len(result.fixpoint))
        labels.append(str(set(P)))

    x = np.arange(len(labels))
    width = 0.35
    bars1 = ax.bar(x - width/2, gfp_sizes, width, label='νF (Safety)',
                   color='steelblue', alpha=0.8)
    bars2 = ax.bar(x + width/2, complement_sizes, width, label='μ(dual F) (Reach)',
                   color='coral', alpha=0.8)
    ax.set_xlabel('Predicate P', fontsize=12)
    ax.set_ylabel('Number of States', fontsize=12)
    ax.set_title('ν/μ Duality\n(Safety vs Reachability)', fontsize=13)
    ax.set_xticks(x)
    ax.set_xticklabels(labels, fontsize=9)
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3, axis='y')

    # Plot 2: Convergence comparison
    ax = axes[1]
    # Compare safety and reachability convergence speeds
    sizes_range = range(3, 12)
    safety_iters = []
    for n in sizes_range:
        edges = [(i, (i+1) % n) for i in range(n)]
        ts_n = TransitionSystem.from_edges(n, edges)
        P = frozenset(range(n // 2))
        res = safety_model_check(ts_n, P)
        safety_iters.append(res.iterations)

    ax.plot(list(sizes_range), safety_iters, 'bo-', linewidth=2,
            markersize=7, label='Iterations')
    ax.plot(list(sizes_range), list(sizes_range), 'r--', linewidth=2,
            label='Linear bound', alpha=0.7)
    ax.set_xlabel('Ring Size (n)', fontsize=12)
    ax.set_ylabel('Iterations to Converge', fontsize=12)
    ax.set_title('Convergence on\nn-state Ring', fontsize=13)
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)

    fig.suptitle('Order Duality: Greatest vs Least Fixpoints',
                 fontsize=15, fontweight='bold')
    plt.tight_layout()
    fig.savefig('viz_duality.png', dpi=150, bbox_inches='tight')
    b64 = fig_to_base64(fig)
    print("Generated viz_duality.png")
    return b64


if __name__ == "__main__":
    b64_conv = viz_fixpoint_convergence()
    b64_dual = viz_dual_points()
    b64_safety = viz_safety_operator()
    b64_duality = viz_duality()
    print("\nAll visualizations generated successfully.")
    print(f"  viz_convergence.png: {len(b64_conv)} chars (base64)")
    print(f"  viz_dual_points.png: {len(b64_dual)} chars (base64)")
    print(f"  viz_safety_operator.png: {len(b64_safety)} chars (base64)")
    print(f"  viz_duality.png: {len(b64_duality)} chars (base64)")
