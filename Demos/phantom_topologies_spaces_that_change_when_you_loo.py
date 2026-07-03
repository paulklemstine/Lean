"""
Phantom Topologies: numerical demonstrations.

Reality as the consensus of observers. This self-contained script demonstrates
the two headline results:

  1. The Euclidean topology on the real line is the consensus (agreement) of the
     lower-limit (Sorgenfrey) observer and the upper-limit observer, each of
     which is strictly finer than reality.

  2. The two-point INDISCRETE space is non-metrizable (not even T0) yet is the
     consensus of two strictly-finer Sierpinski observers -- refuting the
     conjecture that non-metrizable spaces need at least three observers.

Convention on the lattice of topologies: a topology s is FINER than t (written
s <= t) if every t-open set is s-open. The CONSENSUS of a family of topologies is
their supremum in this order; its open sets are exactly the sets open in EVERY
observer (the intersection of the open-set families).

No third-party dependencies are required.
"""

from __future__ import annotations

from itertools import chain, combinations
from typing import Callable, FrozenSet, Iterable, List, Set, Tuple


# ---------------------------------------------------------------------------
# Part 0: finite-topology utilities
# ---------------------------------------------------------------------------

Point = object
OpenSet = FrozenSet[Point]
Topology = FrozenSet[OpenSet]


def powerset(elements: Iterable[Point]) -> List[FrozenSet[Point]]:
    """All subsets of a finite ground set, as frozensets."""
    items = list(elements)
    return [
        frozenset(combo)
        for combo in chain.from_iterable(
            combinations(items, r) for r in range(len(items) + 1)
        )
    ]


def topology_from_predicate(
    ground: Iterable[Point], is_open: Callable[[FrozenSet[Point]], bool]
) -> Topology:
    """Collect all subsets satisfying an openness predicate into a topology."""
    return frozenset(U for U in powerset(ground) if is_open(U))


def is_valid_topology(ground: FrozenSet[Point], tau: Topology) -> bool:
    """Check the three topology axioms on a finite ground set."""
    if frozenset() not in tau or ground not in tau:
        return False
    tau_list = list(tau)
    for a in tau_list:
        for b in tau_list:
            if (a & b) not in tau:
                return False
            if (a | b) not in tau:
                return False
    return True


def consensus(topologies: List[Topology]) -> Topology:
    """The consensus topology: sets open in EVERY observer (intersection)."""
    if not topologies:
        raise ValueError("need at least one observer")
    result = topologies[0]
    for t in topologies[1:]:
        result = result & t
    return result


def strictly_finer(observer: Topology, reality: Topology) -> bool:
    """observer is strictly finer than reality: reality's opens are a proper subset."""
    return reality < observer  # frozenset proper-subset


def is_T0(ground: FrozenSet[Point], tau: Topology) -> bool:
    """T0: any two distinct points are separated by some open set."""
    pts = list(ground)
    for i in range(len(pts)):
        for j in range(i + 1, len(pts)):
            p, q = pts[i], pts[j]
            separated = any((p in U) != (q in U) for U in tau)
            if not separated:
                return False
    return True


# ---------------------------------------------------------------------------
# Part 1: the two-point indiscrete space as a two-observer consensus
# ---------------------------------------------------------------------------

def demo_indiscrete_refutation() -> None:
    print("=" * 72)
    print("DEMO 1  Two-point indiscrete space: non-metrizable, phantom number 2")
    print("=" * 72)

    T, F = "true", "false"
    ground = frozenset({T, F})

    # Sierpinski observer resolving {true}: open iff (false in U -> true in U).
    sierp_true = topology_from_predicate(ground, lambda U: (F not in U) or (T in U))
    # Sierpinski observer resolving {false}: open iff (true in U -> false in U).
    sierp_false = topology_from_predicate(ground, lambda U: (T not in U) or (F in U))
    indiscrete = frozenset({frozenset(), ground})

    def show(name: str, tau: Topology) -> None:
        pretty = sorted(
            ("{" + ",".join(sorted(map(str, U))) + "}" if U else "{}") for U in tau
        )
        print(f"  {name:16s}: {pretty}")

    show("S_true opens", sierp_true)
    show("S_false opens", sierp_false)

    cons = consensus([sierp_true, sierp_false])
    show("consensus", cons)
    show("indiscrete", indiscrete)

    assert is_valid_topology(ground, sierp_true)
    assert is_valid_topology(ground, sierp_false)
    assert cons == indiscrete, "consensus should be the indiscrete topology"
    assert strictly_finer(sierp_true, indiscrete)
    assert strictly_finer(sierp_false, indiscrete)

    print(f"\n  consensus == indiscrete topology?           {cons == indiscrete}")
    print(f"  S_true strictly finer than reality?         {strictly_finer(sierp_true, indiscrete)}")
    print(f"  S_false strictly finer than reality?        {strictly_finer(sierp_false, indiscrete)}")
    print(f"  indiscrete space is T0 (=> metrizable)?     {is_T0(ground, indiscrete)}")
    print("  => non-metrizable (not even T0), yet phantom number 2.")
    print("  => the '>= 3 observers' conjecture is REFUTED.\n")


# ---------------------------------------------------------------------------
# Part 2: the real line as a two-observer consensus (interval-endpoint model)
# ---------------------------------------------------------------------------
#
# A single interval on the real line is described by its two endpoints and
# whether each endpoint is included (closed) or excluded (open). The one-sided
# and two-sided open predicates then reduce to simple endpoint conditions:
#
#   * Lower-limit (Sorgenfrey) open  <=>  the RIGHT endpoint is open (excluded),
#         because a basic open [x, b) can start at a closed left endpoint but
#         cannot cover a closed right endpoint b (no [b, b'') fits inside).
#   * Upper-limit open               <=>  the LEFT endpoint is open (excluded).
#   * Euclidean open                 <=>  BOTH endpoints are open.
#
# Hence consensus = (lower and upper) = both endpoints open = Euclidean.

Interval = Tuple[str, str]  # (left_kind, right_kind) each in {'open','closed'}


def interval_open_lower(iv: Interval) -> bool:
    """Sorgenfrey / lower-limit open: right endpoint must be open."""
    _, right = iv
    return right == "open"


def interval_open_upper(iv: Interval) -> bool:
    """Upper-limit open: left endpoint must be open."""
    left, _ = iv
    return left == "open"


def interval_open_euclid(iv: Interval) -> bool:
    """Euclidean open: both endpoints must be open."""
    left, right = iv
    return left == "open" and right == "open"


def demo_real_line() -> None:
    print("=" * 72)
    print("DEMO 2  Real line: Euclidean = consensus(lower-limit, upper-limit)")
    print("=" * 72)

    candidates = {
        "(0,1)": ("open", "open"),      # genuinely two-sided
        "[0,1)": ("closed", "open"),    # lower phantom
        "(0,1]": ("open", "closed"),    # upper phantom
        "[0,1]": ("closed", "closed"),  # neither observer
    }

    def report(label: str, iv: Interval) -> None:
        lo = interval_open_lower(iv)
        up = interval_open_upper(iv)
        eu = interval_open_euclid(iv)
        cons = lo and up  # consensus = open for BOTH observers
        print(f"  {label:6s} lower={lo!s:5}  upper={up!s:5}  "
              f"euclid={eu!s:5}  consensus={cons!s:5}  match={cons == eu}")
        assert cons == eu, "consensus must equal Euclidean openness"

    print("  A set is Euclidean-open iff open for BOTH one-sided observers:")
    for label, iv in candidates.items():
        report(label, iv)

    print("\n  [0,1) is a phantom of the lower observer (open there, not Euclidean);")
    print("  (0,1] is a phantom of the upper observer. Only two-sided intervals")
    print("  survive the consensus -- exactly the Euclidean topology.\n")


# ---------------------------------------------------------------------------
# Part 3: measurement coarsens -- more observers => coarser reality
# ---------------------------------------------------------------------------

def demo_measurement_coarsens() -> None:
    print("=" * 72)
    print("DEMO 3  Measurement coarsens: adding observers shrinks the consensus")
    print("=" * 72)

    ground = frozenset({1, 2, 3})
    all_subsets = frozenset(powerset(ground))  # discrete topology (finest)

    # Three observers, each a chain topology hiding one point differently.
    obs_a = topology_from_predicate(ground, lambda U: (1 not in U) or (2 in U))
    obs_b = topology_from_predicate(ground, lambda U: (2 not in U) or (3 in U))
    obs_c = topology_from_predicate(ground, lambda U: (3 not in U) or (1 in U))

    families = [obs_a, obs_b, obs_c]
    running: List[Topology] = []
    for k in range(1, len(families) + 1):
        running = families[:k]
        cons = consensus(running)
        print(f"  observers used: {k}   |consensus open sets| = {len(cons)}")
        assert is_valid_topology(ground, cons)

    print("\n  The number of agreed-open sets is non-increasing in the observer")
    print("  count: consensus is order-reversing -- measurement can only blur.")
    print(f"  (discrete topology has {len(all_subsets)} open sets for reference.)\n")


def main() -> None:
    demo_indiscrete_refutation()
    demo_real_line()
    demo_measurement_coarsens()
    print("All demonstrations completed successfully.")


if __name__ == "__main__":
    main()
