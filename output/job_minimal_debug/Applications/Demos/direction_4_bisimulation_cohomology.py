#!/usr/bin/env python3
"""
Bisimulation Cohomology: Applications

Demonstrates practical applications of cohomological obstruction theory
for process equivalence in concurrent systems.

Applications:
  1. Process minimization with obstruction detection
  2. Compositional verification of parallel systems
  3. Depth-filtration analysis for protocol verification
"""

from typing import Dict, List, Set, Tuple
from algorithms import (
    LTS, State,
    compute_bisimulation_classes,
    compute_depth_equiv_classes,
    detect_h1_obstruction,
    find_all_obstructions,
    find_gap_depth,
    stabilization_depth,
    filtration_table,
    are_bisimilar,
)


# ─────────────────────────────────────────────────────────────────────
# Application 1: Process Minimization
# ─────────────────────────────────────────────────────────────────────

def minimize_lts(lts: LTS) -> Tuple[LTS, Dict[State, State]]:
    """Minimize an LTS by quotienting by bisimulation equivalence.

    Returns the minimized LTS and a mapping from original to representative states.

    Example:
        >>> lts = {0: {1}, 1: {2}, 2: {3}, 3: set()}
        >>> min_lts, mapping = minimize_lts(lts)
        >>> len(min_lts)  # Number of states in minimized system
        4
    """
    classes = compute_bisimulation_classes(lts)

    # Map each state to its representative (smallest in class)
    state_map: Dict[State, State] = {}
    for cls in classes:
        rep = min(cls)
        for s in cls:
            state_map[s] = rep

    # Build minimized LTS
    min_lts: LTS = {}
    for cls in classes:
        rep = min(cls)
        # Original state's successors, mapped to representatives
        orig = min(cls)  # Pick any member
        min_lts[rep] = {state_map[sp] for sp in lts[orig]}

    return min_lts, state_map


def minimization_report(lts: LTS, name: str = "System") -> str:
    """Generate a detailed minimization report with cohomological analysis."""
    lines = [f"=== Minimization Report: {name} ===", ""]

    # Original system
    lines.append(f"Original states: {len(lts)}")
    for s in sorted(lts.keys()):
        succs = sorted(lts[s])
        lines.append(f"  {s} → {{{', '.join(map(str, succs))}}}" if succs else f"  {s} → ∅")

    # Bisimulation analysis
    classes = compute_bisimulation_classes(lts)
    lines.append(f"\nBisimulation classes: {len(classes)}")
    for i, cls in enumerate(classes):
        lines.append(f"  Class {i}: {sorted(cls)}")

    # Minimized system
    min_lts, mapping = minimize_lts(lts)
    lines.append(f"\nMinimized states: {len(min_lts)}")
    lines.append(f"Reduction: {len(lts)} → {len(min_lts)} states")

    # Cohomological analysis
    stab = stabilization_depth(lts)
    lines.append(f"\nStabilization depth: {stab}")
    lines.append(f"\nDepth filtration:")
    lines.append(filtration_table(lts))

    # H¹ obstructions
    obstructions = find_all_obstructions(lts)
    if obstructions:
        lines.append(f"\nH¹ Obstructions detected: {len(obstructions)}")
        for s, t, gap in obstructions:
            lines.append(f"  States ({s}, {t}): gap at depth {gap}")
            lines.append(f"    → Local agreement at depth {gap} masks global distinction")
    else:
        lines.append("\nNo H¹ obstructions (depth-1 equivalence = bisimulation)")

    return "\n".join(lines)


# ─────────────────────────────────────────────────────────────────────
# Application 2: Protocol Verification
# ─────────────────────────────────────────────────────────────────────

def verify_protocol_equivalence(
    spec: LTS, impl: LTS, spec_state: State, impl_state: State
) -> str:
    """Verify whether an implementation is behaviorally equivalent to a specification.

    Uses the depth filtration to provide fine-grained diagnostic information
    when equivalence fails.
    """
    lines = ["=== Protocol Verification ===", ""]

    # Check bisimilarity
    # For cross-system comparison, we embed both into a single LTS
    # by offsetting implementation states
    offset = max(spec.keys()) + 1
    combined: LTS = {}
    for s in spec:
        combined[s] = set(spec[s])
    for s in impl:
        combined[s + offset] = {t + offset for t in impl[s]}

    impl_state_offset = impl_state + offset
    bisim = are_bisimilar(combined, spec_state, impl_state_offset)

    if bisim:
        lines.append("✓ Implementation is bisimilar to specification")
        lines.append("  No behavioral distinction possible by any observer")
    else:
        lines.append("✗ Implementation is NOT bisimilar to specification")
        lines.append("")

        # Find at what depth they diverge
        gap = find_gap_depth(combined, spec_state, impl_state_offset)
        if gap >= 0:
            lines.append(f"  Divergence detected at depth {gap + 1}")
            lines.append(f"  Systems agree on all experiments of length ≤ {gap}")
            lines.append(f"  but disagree on some experiment of length {gap + 1}")
            lines.append(f"  → This is an H¹ obstruction at level {gap}")

    return "\n".join(lines)


# ─────────────────────────────────────────────────────────────────────
# Application 3: Compositional Analysis
# ─────────────────────────────────────────────────────────────────────

def parallel_composition(lts1: LTS, lts2: LTS) -> LTS:
    """Compute the synchronous parallel composition of two LTS.

    States are pairs (s1, s2). Both components must take a step simultaneously.
    """
    result: LTS = {}
    states1, states2 = sorted(lts1.keys()), sorted(lts2.keys())
    n2 = len(states2)

    for s1 in states1:
        for s2 in states2:
            composite_state = s1 * n2 + s2
            successors = set()
            for sp1 in lts1[s1]:
                for sp2 in lts2[s2]:
                    successors.add(sp1 * n2 + sp2)
            result[composite_state] = successors

    return result


# ─────────────────────────────────────────────────────────────────────
# Demo
# ─────────────────────────────────────────────────────────────────────

def main():
    print("=" * 70)
    print("BISIMULATION COHOMOLOGY: Applications")
    print("=" * 70)

    # Application 1: Minimization of the witness system
    print("\n" + "=" * 70)
    print("APPLICATION 1: Process Minimization")
    print("=" * 70)

    witness: LTS = {0: {1, 2}, 1: set(), 2: {1}}
    print(minimization_report(witness, "Witness System"))

    # A system with genuine redundancy
    print("\n")
    redundant: LTS = {0: {2, 3}, 1: {2, 3}, 2: set(), 3: set()}
    print(minimization_report(redundant, "Redundant System"))

    # Application 2: Protocol Verification
    print("\n" + "=" * 70)
    print("APPLICATION 2: Protocol Verification")
    print("=" * 70)

    # Specification: can do two steps
    spec: LTS = {0: {1}, 1: {2}, 2: set()}
    # Implementation 1: also two steps (correct)
    impl1: LTS = {0: {1}, 1: {2}, 2: set()}
    # Implementation 2: only one step (incorrect)
    impl2: LTS = {0: {1}, 1: set()}

    print("\n--- Correct Implementation ---")
    print(verify_protocol_equivalence(spec, impl1, 0, 0))

    print("\n--- Faulty Implementation ---")
    print(verify_protocol_equivalence(spec, impl2, 0, 0))

    # Application 3: Parallel composition analysis
    print("\n" + "=" * 70)
    print("APPLICATION 3: Parallel Composition")
    print("=" * 70)

    p1: LTS = {0: {1}, 1: {0}}  # Oscillator
    p2: LTS = {0: {1}, 1: set()}  # One-shot

    composed = parallel_composition(p1, p2)
    print("\nComponent 1: Oscillator (0↔1)")
    print("Component 2: One-shot (0→1→∅)")
    print("\nComposed system:")
    print(minimization_report(composed, "Parallel Composition"))


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Bisimulation Cohomology: Computational Demo

Enumerates all unary-action 3-state labeled transition systems (LTS),
computes one-step agreement, bisimulation equivalence, and depth-filtration
gaps to detect H¹ cohomological obstructions.

This demonstrates the theory formalized in
  Pythagorean/YonedaBisimulation/BisimCohomology.lean
"""

from itertools import product
from typing import Dict, FrozenSet, List, Set, Tuple

# Type aliases
State = int
Action = str
LTS = Dict[State, Set[State]]  # state -> set of successor states (unary action)


def all_unary_3state_lts() -> List[LTS]:
    """Enumerate all LTS over {0,1,2} with a single action.
    Each state can transition to any subset of {0,1,2}, giving 2^3 = 8
    choices per state and 8^3 = 512 total LTS."""
    states = [0, 1, 2]
    subsets = []
    for mask in range(8):
        s = set()
        for i in range(3):
            if mask & (1 << i):
                s.add(i)
        subsets.append(s)

    result = []
    for s0, s1, s2 in product(subsets, repeat=3):
        result.append({0: set(s0), 1: set(s1), 2: set(s2)})
    return result


def one_step_agreement(lts: LTS, s: State, t: State) -> bool:
    """Check if states s and t agree on one-step experiments.
    For a unary alphabet, this means: s has successors iff t has successors."""
    return bool(lts[s]) == bool(lts[t])


def depth_n_equiv(lts: LTS, n: int, s: State, t: State) -> bool:
    """Check if s and t are depth-n equivalent (agree on all traces of length ≤ n).
    Uses a fixpoint computation."""
    if n == 0:
        return True  # All states are depth-0 equivalent
    # For depth n, s ~_n t iff:
    # 1. s ~_{n-1} t
    # 2. For every successor s' of s, there exists a successor t' of t with s' ~_{n-1} t'
    # 3. For every successor t' of t, there exists a successor s' of s with s' ~_{n-1} t'
    if not depth_n_equiv(lts, n - 1, s, t):
        return False
    for sp in lts[s]:
        if not any(depth_n_equiv(lts, n - 1, sp, tp) for tp in lts[t]):
            if lts[t]:  # t has successors but none match
                return False
            else:  # t has no successors
                return False
    for tp in lts[t]:
        if not any(depth_n_equiv(lts, n - 1, sp, tp) for sp in lts[s]):
            if lts[s]:
                return False
            else:
                return False
    return True


def trace_accepted(lts: LTS, s: State, trace: List[Action]) -> bool:
    """Check if state s accepts the given trace."""
    if not trace:
        return True
    return any(trace_accepted(lts, sp, trace[1:]) for sp in lts[s])


def trace_depth_equiv(lts: LTS, n: int, s: State, t: State) -> bool:
    """Check depth-n equivalence by checking all traces of length ≤ n."""
    def all_traces(length):
        if length == 0:
            return [[]]
        return [['a'] + t for t in all_traces(length - 1)]

    for k in range(n + 1):
        for tr in all_traces(k):
            if trace_accepted(lts, s, tr) != trace_accepted(lts, t, tr):
                return False
    return True


def compute_bisimulation(lts: LTS) -> List[Set[State]]:
    """Compute bisimulation equivalence classes using partition refinement."""
    states = list(lts.keys())

    # Initial partition: states with successors vs without
    has_succ = {s for s in states if lts[s]}
    no_succ = {s for s in states if not lts[s]}
    partition = []
    if has_succ:
        partition.append(has_succ)
    if no_succ:
        partition.append(no_succ)
    if not partition:
        partition = [set(states)]

    changed = True
    while changed:
        changed = False
        new_partition = []
        for block in partition:
            # Try to split this block
            splits = {}
            for s in block:
                # Signature: for each block in partition, which blocks can s reach?
                sig = frozenset(
                    i for i, b in enumerate(partition)
                    if any(sp in b for sp in lts[s])
                )
                if sig not in splits:
                    splits[sig] = set()
                splits[sig].add(s)
            if len(splits) > 1:
                changed = True
            new_partition.extend(splits.values())
        partition = new_partition

    return partition


def are_bisimilar(lts: LTS, s: State, t: State) -> bool:
    """Check if s and t are bisimilar."""
    classes = compute_bisimulation(lts)
    for cls in classes:
        if s in cls and t in cls:
            return True
    return False


def find_gap_depth(lts: LTS, s: State, t: State, max_depth: int = 10) -> int:
    """Find the smallest depth n where s and t are depth-n equiv but not depth-(n+1) equiv.
    Returns -1 if no gap found within max_depth."""
    for n in range(max_depth):
        if trace_depth_equiv(lts, n, s, t) and not trace_depth_equiv(lts, n + 1, s, t):
            return n
    return -1


def detect_h1_obstruction(lts: LTS, s: State, t: State) -> bool:
    """Detect H¹ obstruction: one-step agreement but not bisimilar."""
    return one_step_agreement(lts, s, t) and not are_bisimilar(lts, s, t)


def lts_to_string(lts: LTS) -> str:
    """Pretty-print an LTS."""
    lines = []
    for s in sorted(lts.keys()):
        succs = sorted(lts[s])
        if succs:
            lines.append(f"  {s} → {{{', '.join(map(str, succs))}}}")
        else:
            lines.append(f"  {s} → ∅ (dead end)")
    return "\n".join(lines)


def main():
    print("=" * 70)
    print("BISIMULATION COHOMOLOGY: Computational Exploration")
    print("Enumerating all unary-action 3-state LTS")
    print("=" * 70)

    all_lts = all_unary_3state_lts()
    print(f"\nTotal LTS enumerated: {len(all_lts)}")

    # Find all systems with H¹ obstructions
    obstruction_systems = []
    for idx, lts in enumerate(all_lts):
        for s in range(3):
            for t in range(s + 1, 3):
                if detect_h1_obstruction(lts, s, t):
                    gap = find_gap_depth(lts, s, t)
                    obstruction_systems.append((idx, lts, s, t, gap))

    print(f"\nSystems with H¹ obstructions (one-step agree, not bisimilar): {len(obstruction_systems)}")
    print("-" * 70)

    # Display first few examples
    shown = set()
    for idx, lts, s, t, gap in obstruction_systems[:20]:
        lts_key = tuple(tuple(sorted(lts[k])) for k in range(3))
        if lts_key in shown:
            continue
        shown.add(lts_key)
        print(f"\n--- LTS #{idx} ---")
        print(lts_to_string(lts))
        print(f"  States {s} and {t}: one-step agree ✓, NOT bisimilar ✗")
        if gap >= 0:
            print(f"  Gap depth: {gap} (depth-{gap} equiv but not depth-{gap+1} equiv)")
            print(f"  → H¹ OBSTRUCTION DETECTED at depth {gap}")
        classes = compute_bisimulation(lts)
        print(f"  Bisimulation classes: {[sorted(c) for c in classes]}")

    # Verify the main witness system from the Lean formalization
    print("\n" + "=" * 70)
    print("VERIFICATION: Main Witness System (from Lean formalization)")
    print("=" * 70)
    witness = {0: {1, 2}, 1: set(), 2: {1}}
    print(lts_to_string(witness))
    print(f"\nOne-step agreement (0, 2): {one_step_agreement(witness, 0, 2)}")
    print(f"Bisimilar (0, 2): {are_bisimilar(witness, 0, 2)}")
    print(f"Depth-0 equiv (0, 2): {trace_depth_equiv(witness, 0, 0, 2)}")
    print(f"Depth-1 equiv (0, 2): {trace_depth_equiv(witness, 1, 0, 2)}")
    print(f"Depth-2 equiv (0, 2): {trace_depth_equiv(witness, 2, 0, 2)}")
    print(f"H¹ obstruction (0, 2): {detect_h1_obstruction(witness, 0, 2)}")
    gap = find_gap_depth(witness, 0, 2)
    print(f"Gap depth: {gap}")
    print(f"Bisimulation classes: {[sorted(c) for c in compute_bisimulation(witness)]}")

    # Statistics
    print("\n" + "=" * 70)
    print("STATISTICS")
    print("=" * 70)

    n_with_obstruction = len(set(
        tuple(tuple(sorted(lts[k])) for k in range(3))
        for _, lts, _, _, _ in obstruction_systems
    ))
    print(f"Distinct LTS with H¹ obstruction: {n_with_obstruction} / {len(all_lts)}")

    # Check conjectures
    print("\n" + "=" * 70)
    print("CONJECTURE TESTING")
    print("=" * 70)

    # Conjecture A: For every 3-state unary LTS, if one-step equiv but not bisimilar,
    # then HasNontrivialH1Obstruction (which is exactly the definition)
    print("\nConjecture A: One-step agreement + not bisimilar ↔ H¹ obstruction")
    print("  (This is true by definition in our framework)")

    # Conjecture C: Minimal cardinality for obstruction is 3
    print("\nConjecture C: Checking 1-state and 2-state systems...")
    found_small = False
    for n_states in [1, 2]:
        states = list(range(n_states))
        subsets = [set()]
        for s in states:
            new = [ss | {s} for ss in subsets]
            subsets.extend(new)
        subsets = list(set(frozenset(s) for s in subsets))

        for combo in product(subsets, repeat=n_states):
            small_lts = {i: set(combo[i]) for i in range(n_states)}
            for s in range(n_states):
                for t in range(s + 1, n_states):
                    if detect_h1_obstruction(small_lts, s, t):
                        found_small = True
                        print(f"  COUNTEREXAMPLE at {n_states} states!")

    if not found_small:
        print("  No obstructions in 1-state or 2-state systems.")
        print("  Conjecture C CONFIRMED: minimal cardinality is 3.")

    # Gap depth distribution
    print("\n" + "=" * 70)
    print("GAP DEPTH DISTRIBUTION")
    print("=" * 70)
    gap_counts: Dict[int, int] = {}
    for _, _, _, _, gap in obstruction_systems:
        gap_counts[gap] = gap_counts.get(gap, 0) + 1
    for depth in sorted(gap_counts.keys()):
        print(f"  Gap at depth {depth}: {gap_counts[depth]} pairs")


if __name__ == "__main__":
    main()
