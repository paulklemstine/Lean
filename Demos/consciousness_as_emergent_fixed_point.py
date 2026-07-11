"""
demo.py — Numerical demonstrations of self-reference as a fixed point.

This self-contained script illustrates the five facets of the diagonal
fixed-point argument developed in the accompanying paper:

    1. Lawvere's fixed-point theorem: a complete self-model f : A -> (A -> B)
       forces every transformation g : B -> B to have a fixed point, realized
       by the explicit diagonal "strange-loop" witness.
    2. The Cantor / diagonal obstruction: a fixed-point-free transformation
       (Boolean NOT) certifies that no complete self-model exists, and the
       diagonal set exhibits a subset missed by any candidate surjection.
    3. The cardinal boundary: |B|^|A| > |A| for |B| >= 2, so finite systems
       cannot self-model completely.
    4. Knaster-Tarski: a monotone self-model on a finite complete lattice has
       a least fixed point, computed by iterating from the bottom element.
    5. Yoneda: a finite object is reconstructed, up to isomorphism, from its
       probe profile (the family of hom-sets into it).

Run with:  python demo.py
"""

from __future__ import annotations

from typing import Callable, Dict, FrozenSet, Sequence, Set, Tuple


# ---------------------------------------------------------------------------
# 1. Lawvere's fixed-point theorem via the diagonal construction
# ---------------------------------------------------------------------------

def build_selfmodel_realizing_twist(
    states: Sequence[int],
    base: Dict[Tuple[int, int], int],
    g: Callable[[int], int],
    s: int,
    a0: int,
) -> Callable[[int], Callable[[int], int]]:
    """Faithfully realize Lawvere's diagonal construction on a finite system.

    Lawvere's proof needs only that the *twisted lens* phi(a) = g(f(a)(a)) is
    realized by some state a0 (point-surjectivity at that one lens), not full
    surjectivity. We build such an f: rows a != a0 are given by `base`, and the
    row a0 is defined to equal phi, using a fixed point s = g(s) on the diagonal:

        f(a0)(a) = g(base[a, a])   for a != a0,   f(a0)(a0) = s.

    Then f(a0) == phi, so f(a0)(a0) = phi(a0) = g(f(a0)(a0)) is a fixed point.
    """
    assert g(s) == s, "s must be a fixed point of g"
    table: Dict[Tuple[int, int], int] = dict(base)
    for a in states:
        table[(a0, a)] = s if a == a0 else g(base[(a, a)])
    return lambda a: (lambda b: table[(a, b)])


def find_strange_loop(
    states: Sequence[int],
    f: Callable[[int], Callable[[int], int]],
    g: Callable[[int], int],
) -> Tuple[int, int]:
    """Locate a strange-loop state a0 whose row equals the twisted lens
    phi(a) = g(f(a)(a)); return (a0, f(a0)(a0)) with g(f(a0)(a0)) == f(a0)(a0)."""
    phi: Tuple[int, ...] = tuple(g(f(a)(a)) for a in states)
    for a0 in states:
        if tuple(f(a0)(a) for a in states) == phi:
            s = f(a0)(a0)
            assert g(s) == s, "diagonal construction failed"
            return a0, s
    raise ValueError("twisted lens is not realized by any state")


def demo_lawvere() -> None:
    print("=" * 70)
    print("1. Lawvere's fixed-point theorem (diagonal / strange-loop witness)")
    print("=" * 70)
    states = [0, 1, 2]  # state space A = {0, 1, 2}
    values = [0, 1, 2]  # observation palette B = {0, 1, 2}
    # A transformation of observations that HAS a fixed point (2 is fixed).
    g = lambda b: {0: 1, 1: 2, 2: 2}[b]
    s = 2  # the fixed point of g used on the loop diagonal
    a0 = 0  # the designated strange-loop state
    # Arbitrary base rows for the other states.
    base = {(a, b): (a * b + 1) % len(values) for a in states for b in states}
    f = build_selfmodel_realizing_twist(states, base, g, s, a0)
    found_a0, fixed = find_strange_loop(states, f, g)
    print(f"  |B| = {len(values)}, |A| = {len(states)}")
    print(f"  strange-loop state a0 = {found_a0}")
    print(f"  fixed observation s = f(a0)(a0) = {fixed},  g(s) = {g(fixed)}"
          f"  ->  g(s)==s: {g(fixed) == fixed}")
    print()


# ---------------------------------------------------------------------------
# 2. The Cantor / diagonal obstruction
# ---------------------------------------------------------------------------

def diagonal_missed_subset(
    A: Sequence[int], f: Callable[[int], FrozenSet[int]]
) -> FrozenSet[int]:
    """For any candidate f : A -> P(A), return the diagonal set
    D = { a in A : a not in f(a) }, which is provably NOT in the image of f."""
    return frozenset(a for a in A if a not in f(a))


def demo_cantor() -> None:
    print("=" * 70)
    print("2. Cantor / diagonal obstruction: no surjection A -> P(A)")
    print("=" * 70)
    A = list(range(4))
    # An arbitrary attempt at a surjection A -> P(A).
    attempt: Dict[int, FrozenSet[int]] = {
        0: frozenset(),
        1: frozenset({0, 1}),
        2: frozenset({1, 2, 3}),
        3: frozenset({0, 3}),
    }
    f = lambda a: attempt[a]
    D = diagonal_missed_subset(A, f)
    image = {f(a) for a in A}
    print(f"  A = {A},  |P(A)| = {2 ** len(A)} but |A| = {len(A)}")
    print(f"  diagonal set D = {set(D)}")
    print(f"  is D in the image of f? {D in image}  (must be False -> f not onto)")
    # Boolean NOT is fixed-point-free -> obstruction, i.e. Cantor.
    not_map = lambda b: not b
    print(f"  NOT has a fixed point? {any(not_map(b) == b for b in (False, True))}"
          f"  -> fixed-point-free, so no complete self-model into Bool")
    print()


# ---------------------------------------------------------------------------
# 3. The cardinal boundary
# ---------------------------------------------------------------------------

def self_modeling_deficit(card_A: int, card_B: int) -> int:
    """The self-modeling deficit |B|^|A| - |A|: strictly positive whenever
    |B| >= 2, certifying that no finite complete self-model exists."""
    return card_B ** card_A - card_A


def demo_cardinal_boundary() -> None:
    print("=" * 70)
    print("3. Cardinal boundary: |B|^|A| > |A| forbids finite self-models")
    print("=" * 70)
    print(f"  {'|A|':>4} {'|B|':>4} {'|A->B|=|B|^|A|':>16} {'deficit':>12}")
    for card_A in range(1, 7):
        for card_B in (2, 3):
            deficit = self_modeling_deficit(card_A, card_B)
            print(f"  {card_A:>4} {card_B:>4} {card_B**card_A:>16} {deficit:>12}")
    print("  deficit > 0 always (for |B| >= 2): completeness impossible.")
    print()


# ---------------------------------------------------------------------------
# 4. Knaster-Tarski least fixed point on a finite complete lattice
# ---------------------------------------------------------------------------

def least_fixed_point_powerset(
    ground: Sequence[int], f: Callable[[FrozenSet[int]], FrozenSet[int]]
) -> FrozenSet[int]:
    """Compute the least fixed point of a monotone f on the powerset lattice of
    `ground`, by Kleene iteration from the bottom element (the empty set)."""
    current: FrozenSet[int] = frozenset()
    while True:
        nxt = f(current)
        if nxt == current:
            return current
        current = nxt


def demo_tarski() -> None:
    print("=" * 70)
    print("4. Knaster-Tarski least fixed point (monotone self-model)")
    print("=" * 70)
    ground = list(range(5))
    # Monotone operator: reachability closure from seed {0} under successor +2.
    edges = {0: {2}, 2: {4}, 1: {3}, 3: {1}}

    def f(S: FrozenSet[int]) -> FrozenSet[int]:
        out = set(S) | {0}  # always include seed 0 (monotone, adds bottom info)
        for x in list(S):
            out |= edges.get(x, set())
        return frozenset(out)

    lfp = least_fixed_point_powerset(ground, f)
    print(f"  ground set = {ground}")
    print(f"  least fixed point lfp(f) = {sorted(lfp)}")
    print(f"  is it a fixed point? {f(lfp) == lfp}")
    print()


# ---------------------------------------------------------------------------
# 5. Yoneda reconstruction from the probe profile (finite category)
# ---------------------------------------------------------------------------

def probe_profile(
    objects: Sequence[str], hom: Dict[Tuple[str, str], Set[str]], X: str
) -> Dict[str, Set[str]]:
    """The probe profile of X: for every object Z, the hom-set Hom(Z, X)."""
    return {Z: hom.get((Z, X), set()) for Z in objects}


def reconstruct_up_to_iso(
    objects: Sequence[str], hom: Dict[Tuple[str, str], Set[str]]
) -> Dict[str, Tuple[Tuple[str, int], ...]]:
    """Reconstruct each object's isomorphism invariant from its probe profile:
    the multiset of hom-set sizes indexed by probe object. By Yoneda, distinct
    objects have distinct profiles up to relabeling."""
    invariants: Dict[str, Tuple[Tuple[str, int], ...]] = {}
    for X in objects:
        prof = probe_profile(objects, hom, X)
        invariants[X] = tuple(sorted((Z, len(m)) for Z, m in prof.items()))
    return invariants


def demo_yoneda() -> None:
    print("=" * 70)
    print("5. Yoneda: a system is determined by the ways it can be probed")
    print("=" * 70)
    objects = ["A", "B", "C"]
    # Hom-sets in a small category (identities implicit; sizes are what matter).
    hom = {
        ("A", "A"): {"id_A"},
        ("B", "B"): {"id_B"},
        ("C", "C"): {"id_C"},
        ("A", "B"): {"u"},
        ("A", "C"): {"v", "w"},
        ("B", "C"): {"t"},
    }
    invariants = reconstruct_up_to_iso(objects, hom)
    for X in objects:
        print(f"  probe profile of {X}: {invariants[X]}")
    distinct = len(set(invariants.values())) == len(objects)
    print(f"  all objects distinguished by their probe profiles? {distinct}")
    print("  -> objects are determined, up to isomorphism, by their probes.")
    print()


# ---------------------------------------------------------------------------

def main() -> None:
    demo_lawvere()
    demo_cantor()
    demo_cardinal_boundary()
    demo_tarski()
    demo_yoneda()
    print("All demonstrations completed.")


if __name__ == "__main__":
    main()
