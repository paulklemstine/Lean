"""
Proof Phase Transitions: Implicational Theories as Monotone Reachability
========================================================================

Numerical demonstrations of the five structural pillars formalized in the
accompanying development:

  1. Monotonicity        - adding axioms can only add derivable pairs.
  2. Barrier method      - an axiom-closed cut certifies non-derivability.
  3. Chain sharp boundary- in the chain theory `chainT`, a derives b iff a <= b.
  4. Axiom criticality   - deleting one chain axiom k -> k+1 breaks a proof.
  5. Constructive witness- explicit derivation 0 -> 1 -> ... -> n of length n.

Plus an empirical look at the probabilistic phase transition: as edge density p
rises, the probability that 0 reaches n-1 in a random implicational theory jumps
from near 0 to near 1 across a narrow window (Friedgut sharp-threshold regime).

Self-contained: standard library only.
"""

from __future__ import annotations

import random
from collections import deque
from typing import Dict, FrozenSet, List, Optional, Set, Tuple

# A theory is a set of directed edges (axioms) a -> b over atoms 0..n-1.
Edge = Tuple[int, int]
Theory = FrozenSet[Edge]


# --------------------------------------------------------------------------- #
# Core: derivability as graph reachability (Definition 2.2)                    #
# --------------------------------------------------------------------------- #
def reachable_set(theory: Theory, source: int) -> Set[int]:
    """Forward reachable set of `source` = all atoms derivable from it.

    Implements the reflexive-transitive closure by BFS. The returned set is, by
    construction, axiom-closed and contains `source`: it is exactly the barrier
    (invariant cut) of Theorem 3.3.
    """
    adj: Dict[int, List[int]] = {}
    for a, b in theory:
        adj.setdefault(a, []).append(b)
    seen: Set[int] = {source}
    queue: deque[int] = deque([source])
    while queue:
        x = queue.popleft()
        for y in adj.get(x, ()):
            if y not in seen:
                seen.add(y)
                queue.append(y)
    return seen


def derivable(theory: Theory, a: int, b: int) -> bool:
    """`Derivable theory a b`: is b reachable from a? (a == b is reflexivity.)"""
    return b in reachable_set(theory, a)


def min_proof_length(theory: Theory, a: int, b: int) -> Optional[int]:
    """Length of the shortest derivation a -> ... -> b, or None if unreachable."""
    adj: Dict[int, List[int]] = {}
    for x, y in theory:
        adj.setdefault(x, []).append(y)
    dist: Dict[int, int] = {a: 0}
    queue: deque[int] = deque([a])
    while queue:
        x = queue.popleft()
        if x == b:
            return dist[x]
        for y in adj.get(x, ()):
            if y not in dist:
                dist[y] = dist[x] + 1
                queue.append(y)
    return dist.get(b)


# --------------------------------------------------------------------------- #
# The chain theory chainT: axioms k -> k+1 (Definition 2.3)                    #
# --------------------------------------------------------------------------- #
def chain_theory(n: int) -> Theory:
    """chainT restricted to atoms 0..n: the edges {k -> k+1 : 0 <= k < n}."""
    return frozenset((k, k + 1) for k in range(n))


def chain_minus(n: int, m: int) -> Theory:
    """The punctured chain: chainT with the single axiom m -> m+1 deleted."""
    return frozenset((k, k + 1) for k in range(n) if k != m)


def chain_path(n: int) -> List[int]:
    """The explicit constructive derivation 0 -> 1 -> ... -> n (Definition 3.9)."""
    return list(range(n + 1))


# --------------------------------------------------------------------------- #
# Pillar demonstrations                                                        #
# --------------------------------------------------------------------------- #
def demo_monotonicity() -> None:
    print("=" * 70)
    print("PILLAR I  -  Monotonicity (Theorems 3.1 / 3.2)")
    print("=" * 70)
    n = 6
    # Sparse theory: missing the link 2 -> 3.
    sparse: Theory = frozenset({(0, 1), (1, 2), (3, 4), (4, 5)})
    dense: Theory = sparse | {(2, 3)}  # superset of axioms
    print(f"  Sparse theory derives 0 -> 5 ?  {derivable(sparse, 0, 5)}")
    print(f"  Dense  theory derives 0 -> 5 ?  {derivable(dense, 0, 5)}")
    # Monotonicity: everything derivable in sparse stays derivable in dense.
    ok = all(
        (not derivable(sparse, a, b)) or derivable(dense, a, b)
        for a in range(n)
        for b in range(n)
    )
    print(f"  Adding axioms never removed a derivable pair: {ok}")
    print()


def demo_barrier() -> None:
    print("=" * 70)
    print("PILLAR II  -  Barrier method certifies non-derivability (Theorem 3.3)")
    print("=" * 70)
    n = 5
    T = chain_theory(n)  # 0->1->2->3->4->5
    # Claim: 1 does NOT derive 0 (chain_no_backward).
    cut = reachable_set(T, 1)  # the barrier: an axiom-closed set containing 1
    print(f"  Barrier (reachable from 1): {sorted(cut)}")
    print(f"  Is 0 inside the barrier?    {0 in cut}  ->  0 NOT derivable from 1")
    print(f"  Verified ¬Derivable chainT 1 0: {not derivable(T, 1, 0)}")
    print()


def demo_chain_boundary() -> None:
    print("=" * 70)
    print("PILLAR III  -  Sharp boundary: a derives b iff a <= b (Theorem 3.6)")
    print("=" * 70)
    n = 6
    T = chain_theory(n)
    mism = 0
    for a in range(n + 1):
        for b in range(n + 1):
            if derivable(T, a, b) != (a <= b):
                mism += 1
    print(f"  Atoms 0..{n}: derivable(a,b) == (a <= b) for all pairs? {mism == 0}")
    print(f"  Example: derivable(2,5)={derivable(T,2,5)}, derivable(5,2)={derivable(T,5,2)}")
    print()


def demo_criticality() -> None:
    print("=" * 70)
    print("PILLAR IV  -  Every chain axiom is critical (Theorems 3.7 / 3.8)")
    print("=" * 70)
    n = 6
    for m in range(n):
        full = chain_theory(n)
        punctured = chain_minus(n, m)
        broken = not derivable(punctured, 0, m + 1)
        restored = derivable(full, 0, m + 1)
        print(
            f"  delete {m}->{m+1}: 0 derives {m+1}? "
            f"{not broken!s:<5}  full theory restores it? {restored}"
        )
    print()


def demo_constructive_witness() -> None:
    print("=" * 70)
    print("PILLAR V  -  Constructive witness of length exactly n (Theorems 3.10/3.11)")
    print("=" * 70)
    for n in (3, 7, 12):
        path = chain_path(n)
        T = chain_theory(n)
        valid = all((path[i], path[i + 1]) in T for i in range(len(path) - 1))
        steps = len(path) - 1
        bfs = min_proof_length(T, 0, n)
        print(
            f"  n={n:2d}: path={path}  valid_chain={valid}  "
            f"length={steps}  shortest(BFS)={bfs}"
        )
    print()


# --------------------------------------------------------------------------- #
# The probabilistic phase transition (Section 5.1)                            #
# --------------------------------------------------------------------------- #
def random_theory(n: int, p: float, rng: random.Random) -> Theory:
    """Erdos-Renyi style: include each directed edge a->b (a != b) w.p. p."""
    return frozenset(
        (a, b)
        for a in range(n)
        for b in range(n)
        if a != b and rng.random() < p
    )


def reach_probability(n: int, p: float, trials: int, rng: random.Random) -> float:
    """Empirical P[ 0 derives n-1 ] in a random theory of edge density p."""
    hits = sum(
        derivable(random_theory(n, p, rng), 0, n - 1) for _ in range(trials)
    )
    return hits / trials


def demo_phase_transition() -> None:
    print("=" * 70)
    print("PHASE TRANSITION  -  P[0 reaches n-1] vs edge density p (Section 5.1)")
    print("=" * 70)
    rng = random.Random(20240611)
    n, trials = 40, 200
    print(f"  n={n} atoms, {trials} random theories per density value")
    print(f"  {'p':>7} | {'P[derivable]':>13} | bar")
    print("  " + "-" * 52)
    for i in range(0, 11):
        p = i / 200.0  # densities near the 1/n scale where the jump occurs
        prob = reach_probability(n, p, trials, rng)
        bar = "#" * int(round(prob * 30))
        print(f"  {p:>7.4f} | {prob:>13.3f} | {bar}")
    print("\n  Note the sharp rise: monotone reachability => sharp threshold.")
    print()


def main() -> None:
    demo_monotonicity()
    demo_barrier()
    demo_chain_boundary()
    demo_criticality()
    demo_constructive_witness()
    demo_phase_transition()


if __name__ == "__main__":
    main()
