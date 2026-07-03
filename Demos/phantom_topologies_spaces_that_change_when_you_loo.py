"""
Phantom Topologies: numerical demonstrations.

A *phantom topology* on a finite set X is a family of "observer" topologies on X.
The *consensus* (real) topology is the collection of sets open in EVERY observer:
in the lattice of topologies it is the supremum (join), whose open sets are the
intersection of the observers' open-set collections. An observer is *strictly
finer* than the consensus when it has strictly more open sets. The *phantom
number* is the least number of strictly-finer observers whose consensus is a
given topology.

Central results demonstrated here:
  * Consensus = intersection of open-set collections.
  * Collapse Principle: any genuine k-observer representation (k >= 2, each
    observer strictly finer than the consensus) collapses to a genuine
    2-observer one.
  * Two-valued dichotomy: the finite phantom number is 2 (reducible topology) or
    unattainable (join-irreducible topology).
  * The Euclidean line is the consensus of the lower-limit and upper-limit
    topologies (illustrated on a finite discretization).

A "topology" on a finite universe is represented as a frozenset of frozensets:
the collection of open sets. It must contain the empty set and the whole set and
be closed under unions and intersections.
"""

from __future__ import annotations

from itertools import combinations
from typing import FrozenSet, Iterable, List, Optional, Tuple

Set = FrozenSet[int]
Topology = FrozenSet[Set]


# --------------------------------------------------------------------------- #
#  Basic topology utilities on a finite universe                              #
# --------------------------------------------------------------------------- #
def powerset(universe: Set) -> List[Set]:
    """All subsets of a finite universe, as frozensets."""
    elems = list(universe)
    return [
        frozenset(c)
        for r in range(len(elems) + 1)
        for c in combinations(elems, r)
    ]


def is_topology(opens: Iterable[Set], universe: Set) -> bool:
    """Check the three topology axioms on a finite universe."""
    O = set(opens)
    if frozenset() not in O or universe not in O:
        return False
    for a in O:
        for b in O:
            if (a | b) not in O or (a & b) not in O:
                return False
    return True


def discrete(universe: Set) -> Topology:
    """The discrete topology: every subset is open (finest topology)."""
    return frozenset(powerset(universe))


def indiscrete(universe: Set) -> Topology:
    """The indiscrete topology: only the empty set and the whole set are open."""
    return frozenset({frozenset(), universe})


def consensus(observers: List[Topology]) -> Topology:
    """
    Consensus (real) topology = supremum in the lattice of topologies.
    Its opens are the sets open in EVERY observer, i.e. the intersection of the
    observers' open-set collections.
    """
    if not observers:
        raise ValueError("need at least one observer")
    result = set(observers[0])
    for t in observers[1:]:
        result &= set(t)
    return frozenset(result)


def strictly_finer(observer: Topology, real: Topology) -> bool:
    """True iff `observer` has strictly more open sets than `real`."""
    return set(real) < set(observer)


# --------------------------------------------------------------------------- #
#  The Collapse Principle, constructively                                      #
# --------------------------------------------------------------------------- #
def collapse_to_two(
    observers: List[Topology], real: Topology
) -> Tuple[Topology, Topology]:
    """
    Constructive Collapse Principle. Given a genuine k-observer representation
    (k >= 2, each observer strictly finer than `real`, consensus == `real`),
    return a genuine 2-observer pair (b, c) with b, c strictly finer than `real`
    and consensus([b, c]) == real.

    Algorithm: peel one observer f_j; pool the rest into c. If c is strictly
    finer than reality, return (f_j, c). Otherwise the pooled remainder already
    equals reality, so recurse on the strictly smaller family. The recursion
    cannot bottom out at a single observer (a single strict observer can never
    have consensus equal to reality).
    """
    assert len(observers) >= 2, "need at least two observers"
    assert consensus(observers) == real, "consensus must equal reality"
    assert all(strictly_finer(o, real) for o in observers), "must be genuine"

    fam = list(observers)
    while True:
        f_j = fam[0]
        rest = fam[1:]
        pooled = consensus(rest)  # supremum of the remaining observers
        if strictly_finer(pooled, real):
            return f_j, pooled
        # pooled == real: recurse on the strictly smaller remaining family
        assert len(rest) >= 2, "recursion cannot bottom out at one observer"
        fam = rest


# --------------------------------------------------------------------------- #
#  Reducibility / phantom number on finite spaces                             #
# --------------------------------------------------------------------------- #
def all_topologies(universe: Set) -> List[Topology]:
    """Enumerate every topology on a small finite universe (brute force)."""
    P = powerset(universe)
    must = {frozenset(), universe}
    optional = [s for s in P if s not in must]
    tops: List[Topology] = []
    for r in range(len(optional) + 1):
        for extra in combinations(optional, r):
            cand = set(must) | set(extra)
            if is_topology(cand, universe):
                tops.append(frozenset(cand))
    return tops


def is_reducible(real: Topology, universe: Set) -> Optional[Tuple[Topology, Topology]]:
    """
    Decide reducibility: search for topologies b, c each strictly finer than
    `real` with consensus([b, c]) == real. Returns such a pair or None
    (join-irreducible). By the dichotomy, a pair exists iff the finite phantom
    number is 2.
    """
    finer = [t for t in all_topologies(universe) if strictly_finer(t, real)]
    for b, c in combinations(finer, 2):
        if consensus([b, c]) == real:
            return b, c
    # also allow b == c is pointless (would not be strictly finer pair giving real
    # unless a single observer equals real, excluded); check unordered pairs only
    return None


def phantom_number(real: Topology, universe: Set) -> str:
    """Return '2' if reducible, else 'unattainable (join-irreducible)'."""
    return "2" if is_reducible(real, universe) is not None else \
        "unattainable (join-irreducible)"


# --------------------------------------------------------------------------- #
#  The real line: lower-limit and upper-limit observers, and the squeeze       #
# --------------------------------------------------------------------------- #
# On the genuine real line the lower-limit ('right-looking') observer sees each
# half-open interval [x, b) as open, and the upper-limit ('left-looking')
# observer sees each (a, x] as open. A set U open to BOTH observers is Euclidean
# open, because around any point x we can glue a left piece (a, x] and a right
# piece [x, b) into a genuine two-sided interval (a, b) sitting inside U:
#
#            (a, x]  ∪  [x, b)  =  (a, b).
#
# We verify this gluing identity numerically at the level of interval endpoints.

def in_left_halfopen(a: float, x: float, t: float) -> bool:
    """Membership in (a, x]: a < t <= x."""
    return a < t <= x


def in_right_halfopen(x: float, b: float, t: float) -> bool:
    """Membership in [x, b): x <= t < b."""
    return x <= t < b


def in_open_interval(a: float, b: float, t: float) -> bool:
    """Membership in (a, b): a < t < b."""
    return a < t < b


def squeeze_holds(a: float, x: float, b: float, samples: int = 20001) -> bool:
    """
    Numerically verify (a, x] ∪ [x, b) = (a, b) for a < x < b by sampling the
    range (a, b) densely and checking that a point lies in (a, b) iff it lies in
    the left piece or the right piece.
    """
    lo, hi = a - 1.0, b + 1.0
    for k in range(samples):
        t = lo + (hi - lo) * k / (samples - 1)
        union = in_left_halfopen(a, x, t) or in_right_halfopen(x, b, t)
        interval = in_open_interval(a, b, t)
        if union != interval:
            return False
    return True


# --------------------------------------------------------------------------- #
#  Demonstrations                                                              #
# --------------------------------------------------------------------------- #
def demo_consensus_and_collapse() -> None:
    print("=" * 68)
    print("DEMO 1: Consensus and the Collapse Principle")
    print("=" * 68)
    U = frozenset({0, 1})
    # Two Sierpinski-like observers on {0,1}, plus a redundant discrete observer.
    s0 = frozenset({frozenset(), frozenset({0}), U})      # {0} open
    s1 = frozenset({frozenset(), frozenset({1}), U})      # {1} open
    disc = discrete(U)                                    # everything open
    observers = [s0, s1, disc]
    real = consensus(observers)
    print(f"Universe: {sorted(U)}")
    print(f"Observer 1 opens (Sierpinski, {{0}} open): {_fmt(s0)}")
    print(f"Observer 2 opens (Sierpinski, {{1}} open): {_fmt(s1)}")
    print(f"Observer 3 opens (discrete, redundant):    {_fmt(disc)}")
    print(f"Consensus (real) topology:                 {_fmt(real)}")
    print(f"Consensus is the indiscrete topology?      {real == indiscrete(U)}")
    b, c = collapse_to_two(observers, real)
    print(f"Collapsed to two observers: b={_fmt(b)}, c={_fmt(c)}")
    print(f"consensus([b, c]) == real?                 {consensus([b, c]) == real}")
    print(f"both strictly finer than real?             "
          f"{strictly_finer(b, real) and strictly_finer(c, real)}")
    print()


def demo_dichotomy() -> None:
    print("=" * 68)
    print("DEMO 2: The two-valued dichotomy (phantom number is 2 or unattainable)")
    print("=" * 68)
    U = frozenset({0, 1, 2})
    indisc = indiscrete(U)
    disc = discrete(U)
    print(f"Universe: {sorted(U)}")
    print(f"Indiscrete topology  -> phantom number: {phantom_number(indisc, U)}")
    print(f"Discrete topology    -> phantom number: {phantom_number(disc, U)}")
    # A join-irreducible example: Sierpinski-type topology {∅, {0}, X} on 2 points.
    U2 = frozenset({0, 1})
    sierp = frozenset({frozenset(), frozenset({0}), U2})
    print(f"Sierpinski {{∅,{{0}},X}} -> phantom number: {phantom_number(sierp, U2)}")
    print()


def demo_real_line() -> None:
    print("=" * 68)
    print("DEMO 3: The Euclidean line = lower-limit  ⋁  upper-limit observer")
    print("=" * 68)
    print("Gluing identity behind the two-observer theorem for R:")
    print("    (a, x] ∪ [x, b) = (a, b)")
    print("A set open to both the left-looking and right-looking observer thus")
    print("contains a genuine two-sided neighbourhood around each of its points.")
    print()
    triples = [(-1.0, 0.0, 1.0), (0.0, 0.5, 2.0), (-3.2, -1.1, 4.7), (2.0, 2.25, 2.5)]
    for (a, x, b) in triples:
        ok = squeeze_holds(a, x, b)
        print(f"    a={a:+.2f}, x={x:+.2f}, b={b:+.2f}:  "
              f"(a,x] ∪ [x,b) = (a,b)?  {ok}")
    print()
    print("Phantom witnesses (each observer strictly finer than Euclidean):")
    print("    [0,1) is open to the right-looking observer but NOT Euclidean-open")
    print("          (no two-sided interval around 0 fits inside [0,1)).")
    print("    (0,1] is open to the left-looking observer but NOT Euclidean-open.")
    # Confirm the obstruction at the endpoint 0 for [0,1): every (0-eps, 0+eps)
    # pokes out to the left of [0,1).
    escapes = all((-eps) < 0 and not in_right_halfopen(0.0, 1.0, -eps)
                  for eps in (0.5, 0.1, 0.01, 1e-4))
    print(f"    every symmetric ball around 0 escapes [0,1)?  {escapes}")
    print()


def _fmt(top: Topology) -> str:
    inside = sorted((sorted(s) for s in top), key=lambda x: (len(x), x))
    return "{" + ", ".join("{" + ",".join(map(str, s)) + "}" for s in inside) + "}"


def main() -> None:
    demo_consensus_and_collapse()
    demo_dichotomy()
    demo_real_line()
    print("All demonstrations complete.")


if __name__ == "__main__":
    main()
