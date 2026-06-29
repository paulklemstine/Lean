"""
demo.py — Numerical demonstrations for
"Completeness of the Barrier Method and the Derivability Closure Operator".

An *implicational theory* on a set of atoms is a set of single-conclusion axioms
`a -> b`. *Derivability* is the reflexive-transitive closure of the axiom
relation, i.e. reachability in the directed graph of axioms.

This file is fully self-contained (standard library only) and demonstrates, with
concrete numerical examples, every headline result of the accompanying paper:

  * Derivability as graph reachability (Definition 2.2).
  * Soundness of the barrier method  (Lemma 3.2).
  * The conclusion-set is closed     (Lemma 4.1) -> least closed superset.
  * Completeness of the barrier method (Theorem 4.2) and the
    complete non-derivability certificate (Theorem 4.3).
  * The Kuratowski closure operator Cl: extensive / monotone / idempotent
    (Theorem 5.2).
  * The linear chain theory: boundary `a derives b <=> a <= b` (Theorem 6.2),
    axiom criticality (Theorem 6.4), the constructive segment chainSeg
    (Theorem 6.6), and decidability (Theorem 6.7).

Run:  python demo.py
"""

from __future__ import annotations

from itertools import combinations
from typing import Callable, FrozenSet, Iterable, List, Set, Tuple

# An implicational theory over a finite atom universe is given as a relation:
# a predicate Theory(a, b) that is True iff `a -> b` is an axiom.
Theory = Callable[[int, int], bool]


# --------------------------------------------------------------------------- #
# Core: derivability as reachability, and the barrier / closure machinery     #
# --------------------------------------------------------------------------- #
def successors(theory: Theory, universe: Iterable[int], a: int) -> Set[int]:
    """All `y` with axiom `a -> y` (one-step images of `a`)."""
    return {y for y in universe if theory(a, y)}


def reachable_set(theory: Theory, universe: Iterable[int], a: int) -> FrozenSet[int]:
    """
    Compute R(a) = Cl(theory, {a}): the set of all conclusions derivable from `a`
    (Definition 5.1 / Lemma 4.1). Forward fixpoint (BFS) — Algorithm A.
    """
    universe = list(universe)
    frontier: List[int] = [a]
    seen: Set[int] = {a}
    while frontier:
        x = frontier.pop()
        for y in successors(theory, universe, x):
            if y not in seen:
                seen.add(y)
                frontier.append(y)
    return frozenset(seen)


def derivable(theory: Theory, universe: Iterable[int], a: int, b: int) -> bool:
    """`a` derives `b` iff `b` lies in the reachable set R(a) (Theorem 4.2)."""
    return b in reachable_set(theory, universe, a)


def is_closed(theory: Theory, universe: Iterable[int], s: Set[int]) -> bool:
    """`s` is closed: every axiom out of a member of `s` lands back in `s` (Def 3.1)."""
    universe = list(universe)
    return all(y in s for x in s for y in successors(theory, universe, x))


def closure(theory: Theory, universe: Iterable[int], a_set: Iterable[int]) -> FrozenSet[int]:
    """Cl(theory, A) = union of R(a) over a in A (Definition 5.1)."""
    result: Set[int] = set()
    for a in a_set:
        result |= reachable_set(theory, universe, a)
    return frozenset(result)


def find_barrier(
    theory: Theory, universe: Iterable[int], a: int, b: int
) -> FrozenSet[int] | None:
    """
    Algorithm B: if `a` does not derive `b`, return the closed barrier R(a)
    witnessing it (a closed set containing `a` but not `b`); else None.
    This realises the complete non-derivability certificate (Theorem 4.3).
    """
    r = reachable_set(theory, universe, a)
    return None if b in r else r


# --------------------------------------------------------------------------- #
# The linear chain theory (Section 6)                                          #
# --------------------------------------------------------------------------- #
def chain_theory(a: int, b: int) -> bool:
    """chainT: axioms are exactly the successor steps `k -> k+1` (Definition 6.1)."""
    return b == a + 1


def chain_minus(m: int) -> Theory:
    """Punctured chain: chainT with the single axiom `m -> m+1` deleted (Def 6.3)."""
    return lambda a, b: (b == a + 1) and (a != m)


def chain_seg(a: int, n: int) -> List[int]:
    """
    chainSeg a n = [a, a+1, ..., a+n] — the explicit derivation segment of
    length n+1 from any source `a` (Definition 6.5 / Theorem 6.6).
    """
    return [i + a for i in range(n + 1)]


def chain_decide(a: int, b: int) -> bool:
    """Decidability of chain derivability: `a derives b <=> a <= b` (Thm 6.2/6.7)."""
    return a <= b


# --------------------------------------------------------------------------- #
# Demonstrations                                                               #
# --------------------------------------------------------------------------- #
def banner(title: str) -> None:
    print("\n" + "=" * 70)
    print(title)
    print("=" * 70)


def demo_reachability_and_completeness() -> None:
    """
    A small finite 'diamond + tail' theory. We verify completeness (Theorem 4.2):
    `a derives b` <=> b is in EVERY closed set containing `a`, by brute force over
    all subsets that are closed.
    """
    banner("Demo 1: Derivability = membership in every closed set (Theorem 4.2)")
    universe = list(range(6))  # atoms 0..5
    edges = {(0, 1), (0, 2), (1, 3), (2, 3), (3, 4)}  # node 5 is isolated
    theory: Theory = lambda a, b: (a, b) in edges
    print(f"Atoms: {universe}")
    print(f"Axioms (a -> b): {sorted(edges)}")

    # All closed sets, by brute force.
    closed_sets = [
        frozenset(s)
        for k in range(len(universe) + 1)
        for s in combinations(universe, k)
        if is_closed(theory, universe, set(s))
    ]

    for a, b in [(0, 4), (0, 5), (1, 4), (3, 0), (4, 3)]:
        via_reach = derivable(theory, universe, a, b)
        # b in every closed set containing a?
        relevant = [s for s in closed_sets if a in s]
        via_closed = all(b in s for s in relevant)
        assert via_reach == via_closed, "Completeness violated!"
        tag = "DERIVES" if via_reach else "does NOT derive"
        print(f"  {a} {tag} {b:>2}   (reachability == 'in every closed set' : {via_reach})")
    print("  -> Soundness AND completeness of the barrier method confirmed.")


def demo_non_derivability_certificate() -> None:
    """For each non-derivable pair, extract and verify a closed barrier (Theorem 4.3)."""
    banner("Demo 2: Complete non-derivability certificate (Theorem 4.3)")
    universe = list(range(6))
    edges = {(0, 1), (0, 2), (1, 3), (2, 3), (3, 4)}
    theory: Theory = lambda a, b: (a, b) in edges
    for a, b in [(0, 5), (3, 0), (4, 0)]:
        barrier = find_barrier(theory, universe, a, b)
        assert barrier is not None, "expected a barrier"
        assert a in barrier and b not in barrier
        assert is_closed(theory, universe, set(barrier))
        print(f"  {a} -/-> {b}: closed barrier R({a}) = {sorted(barrier)}"
              f"  (contains {a}, excludes {b}, closed: True)")


def demo_closure_operator() -> None:
    """Verify the Kuratowski axioms for Cl (Theorem 5.2)."""
    banner("Demo 3: Cl is a Kuratowski closure operator (Theorem 5.2)")
    universe = list(range(6))
    edges = {(0, 1), (0, 2), (1, 3), (2, 3), (3, 4)}
    theory: Theory = lambda a, b: (a, b) in edges

    A: Set[int] = {0}
    B: Set[int] = {0, 5}
    cl_A = closure(theory, universe, A)
    cl_B = closure(theory, universe, B)
    cl_cl_A = closure(theory, universe, cl_A)

    print(f"  A          = {sorted(A)}")
    print(f"  Cl(A)      = {sorted(cl_A)}")
    print(f"  Extensive : A subset of Cl(A)            -> {A.issubset(cl_A)}")
    print(f"  Monotone  : A subset B => Cl A subset Cl B -> "
          f"{A.issubset(B) and cl_A.issubset(cl_B)}")
    print(f"  Idempotent: Cl(Cl(A)) == Cl(A)            -> {cl_cl_A == cl_A}")
    assert A.issubset(cl_A) and cl_A.issubset(cl_B) and cl_cl_A == cl_A
    print("  -> Idempotence IS transitivity of derivation, packaged as Cl o Cl = Cl.")


def demo_chain_theory() -> None:
    """Chain boundary, decidability, and the constructive segment (Section 6)."""
    banner("Demo 4: The linear chain theory (Theorems 6.2, 6.6, 6.7)")
    universe = list(range(0, 9))
    print("  Boundary  a derives b  <=>  a <= b  (and decision agrees):")
    for a, b in [(0, 5), (2, 7), (5, 5), (5, 2), (1, 0)]:
        reach = derivable(chain_theory, universe, a, b)
        decide = chain_decide(a, b)
        assert reach == decide == (a <= b)
        arrow = "->" if reach else "-/->"
        print(f"    {a} {arrow:>4} {b}   (a<=b : {a <= b})")

    print("\n  Constructive witness chainSeg(a, n) = [a, ..., a+n]:")
    for a, n in [(0, 5), (3, 4), (7, 2)]:
        seg = chain_seg(a, n)
        steps_ok = all(seg[i + 1] == seg[i] + 1 for i in range(len(seg) - 1))
        print(f"    chainSeg({a}, {n}) = {seg}   length = {len(seg)} (= n+1: "
              f"{len(seg) == n + 1}), valid chain: {steps_ok}")
        assert steps_ok and len(seg) == n + 1


def demo_axiom_criticality() -> None:
    """Deleting one axiom severs the chain; restoring it recovers (Theorem 6.4)."""
    banner("Demo 5: Every chain axiom is critical (Theorem 6.4)")
    universe = list(range(0, 9))
    n = 7
    print(f"  Full chain derives 0 -> {n}: {derivable(chain_theory, universe, 0, n)}")
    for m in range(0, n):
        punctured = chain_minus(m)
        broken = not derivable(punctured, universe, 0, n)
        # The closed prefix {0..m} is the barrier when the axiom m->m+1 is deleted.
        barrier = find_barrier(punctured, universe, 0, n)
        ok = broken and barrier is not None
        print(f"    delete axiom {m}->{m+1}: 0 -/-> {n}? {broken}   "
              f"barrier = {sorted(barrier) if barrier else None}")
        assert ok
    print("  -> Each single axiom carries every crossing derivation: criticality index 1.")


def main() -> None:
    demo_reachability_and_completeness()
    demo_non_derivability_certificate()
    demo_closure_operator()
    demo_chain_theory()
    demo_axiom_criticality()
    banner("All demonstrations passed.")


if __name__ == "__main__":
    main()
