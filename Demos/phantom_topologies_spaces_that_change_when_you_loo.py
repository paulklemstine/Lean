"""
Phantom Topologies: numerical demonstrations.

A *phantom topology* on a finite set X is a family of topologies (observers).
The *consensus* (real) topology is the collection of sets open for EVERY
observer -- i.e. the intersection of the observers' open-set families, which is
the supremum in the lattice of topologies (finer <-> more open sets).

This script demonstrates, entirely self-contained:

  1. Consensus computation and the "measurement coarsens" monotonicity.
  2. The co-excluded-point observers coExcl(a) = {emptyset, X, X\\{a}}.
  3. The Indiscrete Splitting Theorem: for p != q,
        coExcl(p) join coExcl(q) = indiscrete topology,
     with each observer strictly finer than the indiscrete topology.
  4. The Extremal Dichotomy: indiscrete splits, discrete is rigid.
  5. Brute-force verification of splittability / rigidity on all topologies
     of a small finite set.

Topologies are represented as a Python `frozenset` of `frozenset`s (open sets).
"""

from __future__ import annotations

from itertools import combinations, chain
from typing import FrozenSet, Iterable, List, Set, Tuple

# A topology is a frozenset of open sets; each open set is a frozenset of points.
Point = int
OpenSet = FrozenSet[Point]
Topology = FrozenSet[OpenSet]


# --------------------------------------------------------------------------- #
# Core topology utilities
# --------------------------------------------------------------------------- #
def powerset(xs: Iterable[Point]) -> List[FrozenSet[Point]]:
    """All subsets of `xs` as frozensets."""
    items = list(xs)
    return [
        frozenset(c)
        for r in range(len(items) + 1)
        for c in combinations(items, r)
    ]


def is_topology(opens: Set[OpenSet], universe: FrozenSet[Point]) -> bool:
    """Check the topology axioms for `opens` on `universe`."""
    if frozenset() not in opens or universe not in opens:
        return False
    for a in opens:
        for b in opens:
            if (a & b) not in opens:  # finite intersections
                return False
            if (a | b) not in opens:  # (finite) unions suffice for finite sets
                return False
    return True


def all_topologies(universe: FrozenSet[Point]) -> List[Topology]:
    """Brute-force enumerate every topology on a small finite `universe`."""
    subsets = powerset(universe)
    # Every topology must contain emptyset and the universe; the remaining
    # candidate open sets are the "middle" subsets.
    middle = [s for s in subsets if s != frozenset() and s != universe]
    topologies: List[Topology] = []
    for r in range(len(middle) + 1):
        for chosen in combinations(middle, r):
            opens = set(chosen) | {frozenset(), universe}
            if is_topology(opens, universe):
                topologies.append(frozenset(opens))
    return topologies


def consensus(observers: Iterable[Topology]) -> Topology:
    """Consensus / real topology: sets open in EVERY observer (intersection)."""
    observers = list(observers)
    result = observers[0]
    for t in observers[1:]:
        result = result & t
    return frozenset(result)


def finer(a: Topology, b: Topology) -> bool:
    """`a` is finer than or equal to `b` (a has all of b's open sets)."""
    return b <= a


def strictly_finer(a: Topology, b: Topology) -> bool:
    return finer(a, b) and a != b


# --------------------------------------------------------------------------- #
# Named topologies and the co-excluded-point construction
# --------------------------------------------------------------------------- #
def discrete(universe: FrozenSet[Point]) -> Topology:
    return frozenset(powerset(universe))


def indiscrete(universe: FrozenSet[Point]) -> Topology:
    return frozenset({frozenset(), universe})


def co_excl(a: Point, universe: FrozenSet[Point]) -> Topology:
    """coExcl(a): open sets are emptyset, universe, and universe \\ {a}."""
    return frozenset({frozenset(), universe, universe - {a}})


# --------------------------------------------------------------------------- #
# Splittability
# --------------------------------------------------------------------------- #
def is_splittable(tau: Topology, universe: FrozenSet[Point]) -> Tuple[bool, object]:
    """
    Return (True, (a, b)) if tau = consensus(a, b) with a, b strictly finer
    than tau; otherwise (False, None).
    """
    finer_topologies = [
        t for t in all_topologies(universe) if strictly_finer(t, tau)
    ]
    for a, b in combinations(finer_topologies, 2):
        if consensus([a, b]) == tau:
            return True, (a, b)
    # also allow a == b? strictly finer pair with a possibly equal is covered
    for a in finer_topologies:
        if consensus([a, a]) == tau:  # trivial, never equals a strictly finer tau
            pass
    return False, None


def fmt(t: Topology) -> str:
    inner = sorted(("{" + ",".join(map(str, sorted(s))) + "}") if s else "{}"
                   for s in t)
    return "{ " + ", ".join(inner) + " }"


# --------------------------------------------------------------------------- #
# Demonstrations
# --------------------------------------------------------------------------- #
def demo_consensus_monotonicity() -> None:
    print("=" * 70)
    print("1. Consensus and 'measurement coarsens'")
    print("=" * 70)
    U = frozenset({0, 1, 2})
    a = co_excl(0, U)
    b = co_excl(1, U)
    c = co_excl(2, U)
    print(f"observer a = coExcl(0): {fmt(a)}")
    print(f"observer b = coExcl(1): {fmt(b)}")
    con_ab = consensus([a, b])
    con_abc = consensus([a, b, c])
    print(f"consensus(a,b)   = {fmt(con_ab)}  (#opens={len(con_ab)})")
    print(f"consensus(a,b,c) = {fmt(con_abc)}  (#opens={len(con_abc)})")
    print("Each observer is finer than the consensus:",
          finer(a, con_ab) and finer(b, con_ab))
    print("Adding observers never increases #opens:",
          len(con_abc) <= len(con_ab))
    print()


def demo_indiscrete_splitting() -> None:
    print("=" * 70)
    print("2. Indiscrete Splitting Theorem")
    print("=" * 70)
    for n in (2, 3, 4, 5):
        U = frozenset(range(n))
        p, q = 0, 1
        a, b = co_excl(p, U), co_excl(q, U)
        top = indiscrete(U)
        join = consensus([a, b])
        print(f"|X| = {n}:  coExcl({p}) join coExcl({q}) == indiscrete ? "
              f"{join == top};  "
              f"both strictly finer ? "
              f"{strictly_finer(a, top) and strictly_finer(b, top)}")
    print()


def demo_extremal_dichotomy() -> None:
    print("=" * 70)
    print("3. Extremal Dichotomy (brute force over all topologies)")
    print("=" * 70)
    for n in (2, 3):
        U = frozenset(range(n))
        top = indiscrete(U)
        bot = discrete(U)
        split_top, witness = is_splittable(top, U)
        split_bot, _ = is_splittable(bot, U)
        print(f"|X| = {n}:  indiscrete splittable ? {split_top};  "
              f"discrete splittable ? {split_bot}")
        if witness:
            a, b = witness
            print(f"          witness for indiscrete: a={fmt(a)}  b={fmt(b)}")
    print()


def demo_rigid_census() -> None:
    print("=" * 70)
    print("4. Census of rigid (non-splittable) topologies")
    print("=" * 70)
    for n in (2, 3):
        U = frozenset(range(n))
        tops = all_topologies(U)
        rigid = [t for t in tops if not is_splittable(t, U)[0]]
        print(f"|X| = {n}: {len(tops)} topologies total, "
              f"{len(rigid)} rigid, {len(tops) - len(rigid)} splittable")
    print()


def main() -> None:
    demo_consensus_monotonicity()
    demo_indiscrete_splitting()
    demo_extremal_dichotomy()
    demo_rigid_census()
    print("All demonstrations complete.")


if __name__ == "__main__":
    main()
